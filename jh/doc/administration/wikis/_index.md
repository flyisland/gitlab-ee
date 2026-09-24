---
stage: Plan
group: Knowledge
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Wiki 设置
description: Configure Wiki settings.
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

调整您的极狐GitLab 实例的 Wiki 设置。

<a id="wiki-page-content-size-limit"></a>

## Wiki 页面内容大小限制

您可以设置 Wiki 页面的最大内容大小限制。此限制可防止该功能被滥用。默认值为 **5242880 字节** (5 MB)。

<a id="how-does-it-work"></a>

### 它是如何工作的？

内容大小限制在通过极狐GitLab UI 或 API 创建或更新 Wiki 页面时生效。通过 Git 推送的本地更改不会进行验证。

为避免破坏现有 Wiki 页面，此限制仅在 Wiki 页面再次编辑且内容更改时才生效。

<a id="wiki-page-content-size-limit-configuration"></a>

### Wiki 页面内容大小限制配置

此设置无法通过 [**管理员** 区域设置](../settings/_index.md) 进行配置。要配置此设置，请使用 Rails 控制台或 [应用设置 API](../../api/settings.md)。

> [!note]
> 限制的值必须以字节为单位。最小值为 1024 字节。

<a id="wiki-page-content-size-limit-through-the-rails-console"></a>

#### 通过 Rails 控制台

要通过 Rails 控制台配置此设置：

1. 启动 Rails 控制台：

   ```shell
   # 对于 Omnibus 安装
   sudo gitlab-rails console

   # 对于源码安装
   sudo -u git -H bundle exec rails console -e production
   ```

1. 更新 Wiki 页面最大内容大小：

   ```ruby
   ApplicationSetting.first.update!(wiki_page_max_content_bytes: 5.megabytes)
   ```

要检索当前值，请启动 Rails 控制台并运行：

  ```ruby
  Gitlab::CurrentSettings.wiki_page_max_content_bytes
  ```

<a id="wiki-page-content-size-limit-through-the-api"></a>

#### 通过 API

要通过应用设置 API 设置 Wiki 页面大小限制，请使用命令，就像您 [更新其他设置](../../api/settings.md#update-application-settings) 一样：

```shell
curl --request PUT --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/application/settings?wiki_page_max_content_bytes=5242880"
```

您还可以使用 API 来 [检索当前值](../../api/settings.md#retrieve-details-on-current-application-settings)：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/application/settings"
```

<a id="reduce-wiki-repository-size"></a>

### 减少 Wiki 仓库大小

Wiki 会计入 [命名空间存储大小](../settings/account_and_limit_settings.md) 中，因此您应使 Wiki 仓库尽可能精简。

有关压缩仓库的工具的更多信息，请阅读关于 [减少仓库大小](../../user/project/repository/repository_size.md#methods-to-reduce-repository-size) 的文档。

<a id="allow-uri-includes-for-asciidoc"></a>

## 允许 AsciiDoc 的 URI 包含

{{< history >}}

- Introduced in 极狐GitLab 16.1。

{{< /history >}}

包含指令从独立页面或外部 URL 导入内容，并将其作为当前文档内容的一部分显示。要启用 AsciiDoc 包含，请通过 Rails 控制台或 API 启用该功能。

<a id="allow-uri-includes-for-asciidoc-through-the-rails-console"></a>

### 通过 Rails 控制台

要通过 Rails 控制台配置此设置：

1. 启动 Rails 控制台：

   ```shell
   # 对于 Omnibus 安装
   sudo gitlab-rails console

   # 对于源码安装
   sudo -u git -H bundle exec rails console -e production
   ```

1. 更新 Wiki 以允许 AsciiDoc 的 URI 包含：

   ```ruby
   ApplicationSetting.first.update!(wiki_asciidoc_allow_uri_includes: true)
   ```

要检查是否启用了包含，请启动 Rails 控制台并运行：

  ```ruby
  Gitlab::CurrentSettings.wiki_asciidoc_allow_uri_includes
  ```

<a id="allow-uri-includes-for-asciidoc-through-the-api"></a>

### 通过 API

要通过 [应用设置 API](../../api/settings.md#update-application-settings) 设置 Wiki 以允许 AsciiDoc 的 URI 包含，请使用 `curl` 命令：

```shell
curl --request PUT --header "PRIVATE-TOKEN: <your_access_token>" \
  "https://gitlab.example.com/api/v4/application/settings?wiki_asciidoc_allow_uri_includes=true"
```