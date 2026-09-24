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

{{< history >}}

- 在 GitLab 15.10 [引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/111621)，带有一个名为 `google_play_integration` 的[功能标志](../../../administration/feature_flags/_index.md)，默认禁用。
- 在 GitLab 15.11 [GA](https://gitlab.com/gitlab-org/gitlab/-/issues/389611)。功能标志 `google_play_integration` 已移除。

{{< /history >}}

此功能是极狐GitLab 开发的 [Mobile DevOps](../../../ci/mobile_devops/_index.md) 的一部分。

通过 Google Play 集成，您可以配置 CI/CD 流水线连接至 [Google Play Console](https://play.google.com/console/developers)，从而为 Android 设备构建和发布应用。

Google Play 集成可与 [fastlane](https://fastlane.tools/) 开箱即用。您也可以将此集成与其他构建工具结合使用。

## 在极狐GitLab 中启用集成

前提条件：

- 您必须拥有 [Google Play Console](https://play.google.com/console/developers) 开发者账号。
- 您必须从 Google Cloud 控制台为您的项目[生成一个新的服务账号密钥](https://developers.google.com/android-publisher/getting_started)。

要在极狐GitLab 中启用 Google Play 集成：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **集成**。
1. 选择 **Google Play**。
1. 在 **启用集成**，选择 **Active** 复选框。
1. 在 **软件包名称** 中，输入应用的软件包名称（例如，`com.gitlab.app_name`）。
1. 可选。在 **仅在受保护的分支和标签上** 下，勾选 **仅在受保护的分支和标签上设置变量** 复选框。
1. 在 **服务账号密钥 (.JSON)** 中，拖入或上传您的密钥文件。
1. 可选。选择 **测试设置**。
1. 选择 **保存更改**。

启用集成后，将创建全局变量 `$SUPPLY_PACKAGE_NAME` 和 `$SUPPLY_JSON_KEY_DATA`，供 CI/CD 使用。

### CI/CD 变量安全

推送到 `.gitlab-ci.yml` 文件的恶意代码可能会泄露您的变量，包括 `$SUPPLY_JSON_KEY_DATA`，并将其发送到第三方服务器。更多信息，请参见 [CI/CD 变量安全](../../../ci/variables/_index.md#cicd-variable-security)。

## 在 fastlane 中启用集成

要在 fastlane 中启用集成并将构建上传到 Google Play 的指定轨道，您可以将以下代码添加到应用的 `fastlane/Fastfile` 中：

```ruby
upload_to_play_store(
  track: 'internal',
  aab: '../build/app/outputs/bundle/release/app-release.aab'
)
```