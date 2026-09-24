---
stage: Verify
group: Mobile DevOps
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Apple App Store Connect
---

{{< details >}}

- 适用版本: 基础版，专业版，旗舰版
- 适用平台: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 15.8 中引入，通过名为 `apple_app_store_integration` 的功能标志控制，默认关闭。
- 在极狐GitLab 15.10 中正式发布（GA），功能标志 `apple_app_store_integration` 被移除。

{{< /history >}}

此功能是极狐GitLab 开发的 [移动 DevOps](../../../ci/mobile_devops/_index.md) 的一部分。
该功能仍在开发中，但你可以：

- [请求功能](https://gitlab.com/gitlab-org/incubation-engineering/mobile-devops/feedback/-/issues/new?description_template=feature_request)。
- [报告错误](https://gitlab.com/gitlab-org/incubation-engineering/mobile-devops/feedback/-/issues/new?description_template=report_bug)。
- [分享反馈](https://gitlab.com/gitlab-org/incubation-engineering/mobile-devops/feedback/-/issues/new?description_template=general_feedback)。

使用 Apple App Store Connect 集成，你可以将 CI/CD 流水线配置为与 [App Store Connect](https://appstoreconnect.apple.com) 连接。
通过此集成，你可以为 iOS，iPadOS，macOS，tvOS 和 watchOS 构建和发布应用。

Apple App Store Connect 集成开箱即用地支持 [fastlane](https://fastlane.tools/)。你还可以将此集成与其他构建工具一起使用。

<a id="enable-the-integration-in-gitlab"></a>

## 在极狐GitLab 中启用集成

前提条件：

- 你必须拥有已加入 [Apple Developer Program](https://developer.apple.com/programs/enroll/) 的 Apple ID。
- 你必须在 Apple App Store Connect 门户中为你的项目[生成一个新的私钥](https://developer.apple.com/documentation/appstoreconnectapi/creating_api_keys_for_app_store_connect_api)。

要在极狐GitLab 中启用 Apple App Store Connect 集成：

1. 在顶部导航栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **设置** > **集成**。
1. 选择 **Apple App Store Connect**。
1. 在 **启用集成** 下，选中 **激活** 复选框。
1. 提供 Apple App Store Connect 配置信息：
   - **Issuer ID**：Apple App Store Connect 的颁发者 ID。
   - **Key ID**：生成的私钥的密钥 ID。
   - **Private key**：生成的私钥。此密钥只能下载一次。
   - **Protected branches and tags only**：勾选后，仅在受保护的分支和标签上设置变量。
1. 选择 **保存更改**。

启用集成后：

- 将创建全局变量 `$APP_STORE_CONNECT_API_KEY_ISSUER_ID`，`$APP_STORE_CONNECT_API_KEY_KEY_ID`，`$APP_STORE_CONNECT_API_KEY_KEY` 和 `$APP_STORE_CONNECT_API_KEY_IS_KEY_CONTENT_BASE64`，供 CI/CD 使用。
- `$APP_STORE_CONNECT_API_KEY_KEY` 包含 Base64 编码的私钥。
- `$APP_STORE_CONNECT_API_KEY_IS_KEY_CONTENT_BASE64` 始终为 `true`。

<a id="security-considerations"></a>

## 安全注意事项

<a id="cicd-variable-security"></a>

### CI/CD 变量安全

推送到 `.gitlab-ci.yml` 文件的恶意代码可能会危及你的变量，包括
`$APP_STORE_CONNECT_API_KEY_KEY`，并将其发送到第三方服务器。更多信息，请参见
[CI/CD 变量安全性](../../../ci/variables/_index.md#cicd-variable-security)。

<a id="enable-the-integration-in-fastlane"></a>

## 在 fastlane 中启用集成

要在 fastlane 中启用集成并上传 TestFlight 或公共 App Store 发布版本，你可以将以下代码添加到应用的 `fastlane/Fastfile` 中：

```ruby
app_store_connect_api_key
```