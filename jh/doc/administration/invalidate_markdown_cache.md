---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Markdown 缓存
description: 使 Markdown 缓存失效。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

出于性能原因，极狐GitLab 会在以下字段中缓存 Markdown 文本的 HTML 版本：

- 评论。
- 议题描述。
- 合并请求描述。

这些缓存的版本可能会过时，例如当 `external_url` 配置选项发生更改时。缓存文本中的链接仍会指向旧的 URL。

<a id="invalidate-the-cache"></a>

## 使缓存失效

你可以通过 API 或 Rails 控制台使 Markdown 缓存失效。

<a id="use-the-api"></a>

### 使用 API

先决条件：

- 你必须具有管理员访问权限。

要使用 API 使现有缓存失效：

1. 通过发送 PUT 请求，增加应用程序设置中的 `local_markdown_version` 设置：

   ```shell
   curl --request PUT --header "PRIVATE-TOKEN: <your_access_token>" \
     --url "https://gitlab.example.com/api/v4/application/settings?local_markdown_version=<increased_number>"
   ```

有关此 API 端点的更多信息，请参见[更新应用程序设置](../api/settings.md#update-application-settings)。

<a id="use-the-rails-console"></a>

### 使用 Rails 控制台

先决条件：

- 你必须具有 [Rails 控制台](operations/rails_console.md) 访问权限。

<a id="for-a-group"></a>

#### 针对群组

要使群组的缓存失效：

1. 启动 Rails 控制台：

   ```shell
   sudo gitlab-rails console
   ```

1. 查找要更新的群组：

   ```ruby
   group = Group.find(<group_id>)
   ```

1. 使群组中所有项目的缓存失效：

   ```ruby
   group.all_projects.each_slice(10) do |projects|
     projects.each do |project|
       # 使议题失效
       project.issues.update_all(
         description_html: nil,
         title_html: nil
       )

       # 使合并请求失效
       project.merge_requests.update_all(
         description_html: nil,
         title_html: nil
       )

       # 使备注/评论失效
       project.notes.update_all(note_html: nil)
     end

     # 更新 10 个项目后暂停一秒钟
     sleep 1
   end
   ```

<a id="for-a-project"></a>

#### 针对项目

要使单个项目的缓存失效：

1. 启动 Rails 控制台：

   ```shell
   sudo gitlab-rails console
   ```

1. 查找要更新的项目：

   ```ruby
   project = Project.find(<project_id>)
   ```

1. 使议题失效：

   ```ruby
   project.issues.update_all(
     description_html: nil,
     title_html: nil
   )
   ```

1. 使合并请求失效：

   ```ruby
   project.merge_requests.update_all(
     description_html: nil,
     title_html: nil
   )
   ```

1. 使备注和评论失效：

   ```ruby
   project.notes.update_all(note_html: nil)
   ```

