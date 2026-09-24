---
stage: Verify
group: Mobile DevOps
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: '教程：使用 极狐GitLab Mobile DevOps 构建 iOS 应用'
---

在本教程中，你将使用 极狐GitLab CI/CD 创建一个流水线，用于构建你的 iOS 移动应用，
使用你的凭据对其进行签名，并将其分发到应用商店。

要设置移动 DevOps，请执行以下操作：

1. [设置你的构建环境](#set-up-your-build-environment)
1. [使用 fastlane 配置代码签名](#configure-code-signing-with-fastlane)
1. [使用 Apple Store 集成和 fastlane 设置应用分发](#set-up-app-distribution-with-apple-store-integration-and-fastlane)

<a id="before-you-begin"></a>

## 开始之前

在开始本教程之前，请确保你具有：

- 一个可访问 CI/CD 流水线的 极狐GitLab 账户
- 极狐GitLab 仓库中有你的移动应用代码
- 一个 Apple Developer 账户
- 本地已安装 [`fastlane`](https://fastlane.tools)

<a id="set-up-your-build-environment"></a>

## 设置你的构建环境

使用 [极狐GitLab 托管的 runner](../runners/_index.md)，
或者设置 [私有化部署 runner](https://gitlab.cn/docs/runner/#use-self-managed-runners) 以获得对构建环境的完全控制。

1. 在仓库根目录中创建一个 `.gitlab-ci.yml` 文件。
1. 添加一个 [支持的 macOS 镜像](../runners/hosted_runners/macos.md#supported-macos-images) 以在 [macOS 极狐GitLab 托管的 runner](../runners/hosted_runners/macos.md)（测试版）上运行作业：

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

要为 iOS 设置代码签名，请使用 fastlane 将已签名的证书上传到 极狐GitLab：

1. 初始化 fastlane：

   ```shell
   fastlane init
   ```

1. 使用配置生成一个 `Matchfile`：

   ```shell
   fastlane match init
   ```

1. 在 Apple Developer 门户中生成证书和描述文件，并将这些文件上传到 极狐GitLab：

   ```shell
   PRIVATE_TOKEN=YOUR-TOKEN bundle exec fastlane match development
   ```

1. 可选。如果你已经为项目创建了签名证书和预配描述文件，可使用 `fastlane match import` 将现有文件加载到 极狐GitLab：

   ```shell
   PRIVATE_TOKEN=YOUR-TOKEN bundle exec fastlane match import
   ```

系统会提示你输入文件路径。提供这些详细信息后，文件将上传并在项目的 CI/CD 设置中可见。如果在导入过程中提示输入 `git_url`，可将其留空并按 <kbd>回车</kbd>。

以下是使用此配置的示例 `fastlane/Fastfile` 和 `.gitlab-ci.yml` 文件：

- `fastlane/Fastfile`：

  ```ruby
  default_platform(:ios)

  platform :ios do
    desc "构建并签名开发版应用"
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

使用 Mobile DevOps 分发集成可以将签名后的构建上传到 Apple App Store。

前提条件：

- 你必须拥有已加入 Apple Developer Program 的 Apple ID。
- 必须在 Apple App Store Connect 门户中为项目生成新的私钥。

要使用 Apple Store 集成和 fastlane 创建 iOS 分发，请执行以下操作：

1. 为 App Store Connect API 生成 API 密钥。在 Apple App Store Connect 门户中，[为项目生成新的私钥](https://developer.apple.com/documentation/appstoreconnectapi/creating_api_keys_for_app_store_connect_api)。
1. 启用 Apple App Store Connect 集成：
   1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
   1. 选择 **设置** > **集成**。
   1. 选择 **Apple App Store Connect**。
   1. 在 **启用集成** 下，勾选 **活跃** 复选框。
   1. 提供 Apple App Store Connect 配置信息：
      - **Issuer ID**：Apple App Store Connect 的 Issuer ID。
      - **Key ID**：生成私钥的 Key ID。
      - **Private key**：生成的私钥。此密钥只能下载一次。
      - **仅受保护的分支和标签**：启用此项以仅对受保护的分支和标签设置变量。
   1. 选择 **保存更改**。
1. 将发布步骤添加到你的流水线和 fastlane 配置中。

以下是示例 `fastlane/Fastfile`：

```ruby
default_platform(:ios)

platform :ios do
  desc "构建并签名分发版应用，上传至 TestFlight"
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

恭喜你！你的应用现已设置好自动构建、签名和分发。尝试创建一个合并请求来触发你的第一条流水线。

<a id="sample-projects"></a>

## 示例项目

以下平台提供了配置好流水线以构建、签名和发布移动应用的 Mobile DevOps 示例项目：

- Android
- Flutter
- iOS

查看 [Mobile DevOps 示例项目](https://jihulab.com/gitlab-cn/incubation-engineering/mobile-devops/demo-projects/) 群组中的所有项目。