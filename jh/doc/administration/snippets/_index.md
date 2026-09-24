---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Configure snippets settings for your 极狐GitLab instance.
title: 代码片段
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

为防止实例上的代码片段滥用，可配置最大代码片段大小，在用户创建或更新代码片段时强制执行。现有代码片段不受限制影响，除非用户更新它们且内容发生更改。默认限制为 52428800 字节（50 MB）。

<a id="configure-the-snippet-size-limit"></a>

## 配置代码片段大小限制

要配置代码片段大小限制，可使用 Rails 控制台或[应用设置 API](../../api/settings.md)。限制必须以字节为单位。

此设置在[**管理员**区域设置](../settings/_index.md)中不可用。

<a id="use-the-rails-console"></a>

### 使用 Rails 控制台

要通过 Rails 控制台配置此设置：

1. [启动 Rails 控制台](../operations/rails_console.md#starting-a-rails-console-session)。
1. 更新代码片段最大文件大小：

   ```ruby
   ApplicationSetting.first.update!(snippet_size_limit: 50.megabytes)
   ```

要检索当前值，启动 Rails 控制台并运行：

  ```ruby
  Gitlab::CurrentSettings.snippet_size_limit
  ```

<a id="use-the-api"></a>

### 使用 API

要通过应用设置 API 设置限制（类似于[更新任何其他设置](../../api/settings.md#update-application-settings)），使用以下命令：

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>"
  --url "https://gitlab.example.com/api/v4/application/settings?snippet_size_limit=52428800"
```

要[从 API 检索当前值](../../api/settings.md#retrieve-details-on-current-application-settings)：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/application/settings"
```

