---
stage: Create
group: Import
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 排查 GitHub 迁移问题
description: "Troubleshooting GitHub import issues including failed processes, missing prefixes, and large project errors."
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

从 GitHub 导入项目到极狐GitLab 时，你可能会遇到以下问题。

<a id="manually-continue-a-previously-failed-import-process"></a>

## 手动继续之前失败的导入过程

在某些情况下，GitHub 导入过程可能无法导入仓库。这会导致极狐GitLab 中止项目导入过程，并要求手动导入仓库。管理员可以为失败的导入过程手动导入仓库：

1. 打开 Rails 控制台。
1. 在控制台中运行以下一系列命令：

   ```ruby
   project_id = <PROJECT_ID>
   github_access_token =  <GITHUB_ACCESS_TOKEN>
   github_repository_path = '<GROUP>/<REPOSITORY>'

   github_repository_url = "https://#{github_access_token}@github.com/#{github_repository_path}.git"

   # Find project by ID
   project = Project.find(project_id)
   # Set import URL and credentials
   project.import_url = github_repository_url
   project.import_type = 'github'
   project.import_source = github_repository_path
   project.save!
   # Create an import state if the project was created manually and not from a failed import
   project.create_import_state if project.import_state.blank?
   # Set state to start
   project.import_state.force_start

   # Optional: If your import had certain optional stages selected or a timeout strategy
   # set, you can reset them here. Below is an example.
   # The params follow the format documented in the API:
   # https://gitlab.cn/docs/api/import/#import-repository-from-github
   Gitlab::GithubImport::Settings
   .new(project)
   .write(
     timeout_strategy: "optimistic",
     optional_stages: {
       single_endpoint_issue_events_import: true,
       single_endpoint_notes_import: true,
       attachments_import: true,
       collaborators_import: true
     }
   )

   # Trigger import from second step
   Gitlab::GithubImport::Stage::ImportRepositoryWorker.perform_async(project.id)
   ```

<a id="import-fails-due-to-missing-prefix"></a>

## 导入因缺少前缀而失败

在极狐GitLab 16.5 及更高版本中，你可能会收到一条错误，提示 `导入因 GitHub 错误而失败：(HTTP 406)`。

出现此问题是因为，在极狐GitLab 16.5 中，路径前缀 `api/v3` 已从 GitHub 导入器中移除。这是因为导入器停止使用 `Gitlab::LegacyGithubImport::Client`。该客户端在从 GitHub Enterprise URL 导入时会自动添加 `api/v3` 前缀。

要解决此错误，请在从 GitHub Enterprise URL 导入时[添加 `api/v3` 前缀](https://jihulab.com/gitlab-cn/gitlab/-/issues/438358#note_1978902725)。

<a id="errors-when-importing-large-projects"></a>

## 导入大型项目时的错误

GitHub 导入器在导入大型项目时可能会遇到一些错误。

<a id="missing-comments"></a>

### 缺少评论

GitHub API 有一个限制，会阻止导入超过大约 30,000 条笔记或差异笔记。当达到此限制时，GitHub API 会返回以下错误：

```plaintext
为了保持 API 对所有人的快速响应，此资源的分页受到限制。请检查 Link 响应头中的 rel=last 链接关系，以了解你可以回溯到多远。
```

当导入有大量评论的 GitHub 项目时，请选择 **使用替代评论导入方法** [要导入的附加项目](github.md#select-additional-items-to-import) 复选框。此设置会使导入过程花费更长时间，因为它会增加执行导入所需的网络请求数量。

<a id="gitlab-instance-cannot-connect-to-github"></a>

## 极狐GitLab 实例无法连接到 GitHub

运行极狐GitLab 15.10 或更早版本且位于代理之后的私有化部署实例，无法解析 `github.com` 或 `api.github.com` 的 DNS。极狐GitLab 实例在导入期间无法连接到 GitHub，你必须在[本地请求的允许列表](../../../security/webhooks.md#allow-outbound-requests-to-certain-ip-addresses-and-domains)中添加 `github.com` 和 `api.github.com` 条目。