---
stage: Verify
group: Mobile DevOps
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Apple App Store Connect
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

此功能是 GitLab 开发的 [Mobile DevOps](../../../ci/mobile_devops/_index.md)的一部分。
该功能仍在开发中，但您可以：

- [请求新功能](https://gitlab.com/gitlab-org/incubation-engineering/mobile-devops/feedback/-/issues/new?description_template=feature_request)。
- [报告缺陷](https://gitlab.com/gitlab-org/incubation-engineering/mobile-devops/feedback/-/issues/new?description_template=report_bug)。
- [分享反馈](https://gitlab.com/gitlab-org/incubation-engineering/mobile-devops/feedback/-/issues/new?description_template=general_feedback)。

使用 Apple App Store Connect 集成，您可以配置 CI/CD 流水线以连接到 [App Store Connect](https://appstoreconnect.apple.com)。
通过此集成，您可以为 iOS、iPadOS、macOS、tvOS 和 watchOS 构建并发布应用。

Apple App Store Connect 集成可与 [fastlane](https://fastlane.tools/) 开箱即用。您也可以将此集成与其他构建工具配合使用。

<a id="enable-the-integration-in-gitlab"></a>

## 在极狐GitLab 中启用集成

先决条件：

- 您必须拥有已加入 [Apple Developer Program](https://developer.apple.com/programs/enroll/)的 Apple ID。
- 您必须在 Apple App Store Connect 门户中为您的项目[生成新的私钥](https://developer.apple.com/documentation/appstoreconnectapi/creating_api_keys_for_app_store_connect_api)。

要在极狐GitLab 中启用 Apple App Store Connect 集成：

1. 在顶部栏中，选择**搜索或跳转到**，找到您的项目。
1. 在左侧边栏中，选择**设置** > **集成**。
1. 选择 **Apple App Store Connect**。
1. 在**启用集成**下，选中**活跃**复选框。
1. 提供 Apple App Store Connect 配置信息：
   - **颁发者 ID**：Apple App Store Connect 的颁发者 ID。
   - **密钥 ID**：所生成私钥的密钥 ID。
   - **私钥**：所生成的私钥。此密钥只能下载一次。
   - **仅受保护的分支和标签**：启用后，仅在受保护的分支和标签上设置变量。
1. 选择**保存更改**。

启用集成后：

- 会创建全局变量 `$APP_STORE_CONNECT_API_KEY_ISSUER_ID`、`$APP_STORE_CONNECT_API_KEY_KEY_ID`、`$APP_STORE_CONNECT_API_KEY_KEY` 和 `$APP_STORE_CONNECT_API_KEY_IS_KEY_CONTENT_BASE64`，供 CI/CD 使用。
- `$APP_STORE_CONNECT_API_KEY_KEY` 包含 Base64 编码的私钥。
- `$APP_STORE_CONNECT_API_KEY_IS_KEY_CONTENT_BASE64` 始终为 `true`。

<a id="security-considerations"></a>

## 安全注意事项

<a id="cicd-variable-security"></a>

### CI/CD 变量安全

推送到您的 `.gitlab-ci.yml` 文件中的恶意代码可能会泄露您的变量（包括 `$APP_STORE_CONNECT_API_KEY_KEY`），并将其发送到第三方服务器。有关更多信息，请参见 [CI/CD 变量安全](../../../ci/variables/_index.md#cicd-variable-security)。

<a id="enable-the-integration-in-fastlane"></a>

## 在 fastlane 中启用集成

要在 fastlane 中启用集成并上传 TestFlight 或公开的 App Store 版本，您可以将以下代码添加到应用的 `fastlane/Fastfile`中：

```ruby
app_store_connect_api_key
```
