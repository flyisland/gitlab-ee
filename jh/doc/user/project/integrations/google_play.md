---
stage: Verify
group: Mobile DevOps
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Google Play
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

通过 Google Play 集成，您可以配置 CI/CD 流水线连接到 [Google Play Console](https://play.google.com/console/about/)，以便为 Android 设备构建和发布应用。

Google Play 集成可与 [fastlane](https://fastlane.tools/) 开箱即用。您也可以将此集成与其他构建工具配合使用。

<a id="enable-the-integration-in-gitlab"></a>

## 在极狐GitLab 中启用集成

先决条件：

- 您必须拥有 [Google Play Console](https://play.google.com/console/about/) 开发者账号。
- 您必须从 Google Cloud 控制台[为您的项目生成新的服务账号密钥](https://developers.google.com/android-publisher/getting_started)。

要在极狐GitLab 中启用 Google Play 集成：

1. 在顶部栏中，选择**搜索或跳转到**，找到您的项目。
1. 在左侧边栏中，选择**设置** > **集成**。
1. 选择 **Google Play**。
1. 在**启用集成**中，选中**活跃**复选框。
1. 在**软件包名称**中，输入应用的软件包名称（例如 `com.gitlab.app_name`）。
1. 可选。在**仅受保护分支和标签**下，选中**仅在受保护分支和标签上设置变量**复选框。
1. 在**服务账号密钥 (.JSON)**中，拖入或上传您的密钥文件。
1. 可选。选择**测试设置**。
1. 选择**保存更改**。

启用集成后，将创建全局变量 `$SUPPLY_PACKAGE_NAME` 和 `$SUPPLY_JSON_KEY_DATA` 供 CI/CD 使用。

<a id="cicd-variable-security"></a>

### CI/CD 变量安全

推送到 `.gitlab-ci.yml` 文件的恶意代码可能会泄露您的变量（包括 `$SUPPLY_JSON_KEY_DATA`），并将其发送到第三方服务器。有关更多信息，请参见 [CI/CD 变量安全](../../../ci/variables/_index.md#cicd-variable-security)。

<a id="enable-the-integration-in-fastlane"></a>

## 在 fastlane 中启用集成

要在 fastlane 中启用集成并将构建上传到 Google Play 中的指定轨道，您可以将以下代码添加到应用的 `fastlane/Fastfile`中：

```ruby
upload_to_play_store(
  track: 'internal',
  aab: '../build/app/outputs/bundle/release/app-release.aab'
)
```
