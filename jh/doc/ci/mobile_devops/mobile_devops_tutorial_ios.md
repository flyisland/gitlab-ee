---
stage: Verify
group: Mobile DevOps
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: '教程：使用极狐GitLab Mobile DevOps 构建 iOS 应用'
---

在本教程中，您将使用极狐GitLab CI/CD 创建一个流水线，用于构建您的 iOS 移动应用、使用您的凭据对其进行签名，并将其分发到应用商店。

要设置移动 DevOps：

1. [设置您的构建环境](#set-up-your-build-environment)
1. [使用 fastlane 配置代码签名](#configure-code-signing-with-fastlane)
1. [使用 Apple Store 集成和 fastlane 设置应用分发](#set-up-app-distribution-with-apple-store-integration-and-fastlane)

<a id="before-you-begin"></a>

## 开始之前

在开始本教程之前，请确保您具备：

- 一个可访问 CI/CD 流水线的极狐GitLab 账号
- 您的移动应用代码位于极狐GitLab 代码仓库中
- 一个 Apple Developer 账号
- 已在本地安装 [`fastlane`](https://fastlane.tools)

<a id="set-up-your-build-environment"></a>

## 设置您的构建环境

使用[极狐GitLab 托管的 Runner](../runners/_index.md)，
或设置[自管理 Runner](https://gitlab.cn/docs/runner/#use-self-managed-runners) 以完全控制构建环境。

1. 在代码仓库根目录中创建一个 `.gitlab-ci.yml` 文件。
1. 添加[支持的 macOS 镜像](../runners/hosted_runners/macos.md#supported-macos-images)，以在 [macOS 极狐GitLab 托管 Runner](../runners/hosted_runners/macos.md)（测试版）上运行作业：

   ```yaml
   test:
     image: macos-14-xcode-15
     stage: test
     script:
       - fastlane test
     tags:
       - saas-macos-medium-m1
   ```

<a id="configure-code-signing-with-fastlane"></a>

## 使用 fastlane 配置代码签名

要为 iOS 设置代码签名，请使用 fastlane 将已签名的证书上传到极狐GitLab：

1. 初始化 fastlane：

   ```shell
   fastlane init
   ```

1. 使用以下配置生成 `Matchfile`：

   ```shell
   fastlane match init
   ```

1. 在 Apple Developer 门户中生成证书和描述文件，并将这些文件上传到极狐GitLab：

   ```shell
   PRIVATE_TOKEN=YOUR-TOKEN bundle exec fastlane match development
   ```

1. 可选。如果您已为项目创建了签名证书和预配描述文件，请使用 `fastlane match import` 将现有文件加载到极狐GitLab：

   ```shell
   PRIVATE_TOKEN=YOUR-TOKEN bundle exec fastlane match import
   ```

系统会提示您输入文件路径。提供这些详细信息后，您的文件将上传并显示在项目的 CI/CD 设置中。如果在导入过程中提示输入 `git_url`，可以安全地将其留空并按 <kbd>enter</kbd>。

以下是使用此配置的示例 `fastlane/Fastfile` 和 `.gitlab-ci.yml` 文件：

- `fastlane/Fastfile`：

  ```ruby
  default_platform(:ios)

  platform :ios do
    desc "Build and sign the application for development"
    lane :build do
      setup_ci

      match(type: 'development', readonly: is_ci)

      build_app(
        project: "ios demo.xcodeproj",
        scheme: "ios demo",
        configuration: "Debug",
        export_method: "development"
      )
    end
  end
  ```

- `.gitlab-ci.yml`：

  ```yaml
  build_ios:
    image: macos-12-xcode-14
    stage: build
    script:
      - fastlane build
    tags:
      - saas-macos-medium-m1
  ```

<a id="set-up-app-distribution-with-apple-store-integration-and-fastlane"></a>

## 使用 Apple Store 集成和 fastlane 设置应用分发

可以使用 Mobile DevOps 分发集成将已签名的构建上传到 Apple App Store。

先决条件：

- 您必须拥有一个已加入 Apple Developer Program 的 Apple ID。
- 您必须在 Apple App Store Connect 门户中为您的项目生成新的私钥。

要使用 Apple Store 集成和 fastlane 创建 iOS 分发：

1. 为 App Store Connect API 生成 API 密钥。在 Apple App Store Connect 门户中，[为您的项目生成新的私钥](https://developer.apple.com/documentation/appstoreconnectapi/creating-api-keys-for-app-store-connect-api)。
1. 启用 Apple App Store Connect 集成：
   1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
   1. 选择**设置** > **集成**。
   1. 选择 **Apple App Store Connect**。
   1. 在**启用集成**下，选中**活跃**复选框。
   1. 提供 Apple App Store Connect 配置信息：
      - **发行者 ID**：Apple App Store Connect 的 Issuer ID。
      - **密钥 ID**：所生成私钥的 Key ID。
      - **私钥**：所生成的私钥。此密钥只能下载一次。
      - **仅受保护的分支和标签**：启用后仅在受保护的分支和标签上设置变量。
   1. 选择**保存更改**。
1. 将发布步骤添加到您的流水线和 fastlane 配置中。

以下是示例 `fastlane/Fastfile`：

```ruby
default_platform(:ios)

platform :ios do
  desc "Build and sign the application for distribution, upload to TestFlight"
  lane :beta do
    setup_ci

    match(type: 'appstore', readonly: is_ci)

    app_store_connect_api_key

    increment_build_number(
      build_number: latest_testflight_build_number(initial_build_number: 1) + 1,
      xcodeproj: "ios demo.xcodeproj"
    )

    build_app(
      project: "ios demo.xcodeproj",
      scheme: "ios demo",
      configuration: "Release",
      export_method: "app-store"
    )

    upload_to_testflight
  end
end
```

以下是示例 `.gitlab-ci.yml`：

```yaml
beta_ios:
  image: macos-12-xcode-14
  stage: beta
  script:
    - fastlane beta
```

恭喜！您的应用现已设置为可自动构建、签名和分发。尝试创建一个合并请求来触发您的第一个流水线。

<a id="sample-projects"></a>

## 示例项目

以下平台提供了配置了流水线以构建、签名和发布移动应用的示例 Mobile DevOps 项目：

- Android
- Flutter
- iOS

在 [Mobile DevOps Demo Projects](https://gitlab.com/gitlab-org/incubation-engineering/mobile-devops/demo-projects/) 群组中查看所有项目。
