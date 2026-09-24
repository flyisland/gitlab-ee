---
stage: Solutions Architecture
group: Solutions Architecture
info: This page is owned by the Solutions Architecture team.
description: 了解混合 React Native 移动应用的极狐GitLab DevSecOps 工作流，包括 CI/CD 设置、Snyk 安全扫描、Sauce Labs 功能测试和 ServiceNow 集成。
title: DevSecOps 工作流 - 移动应用
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

本文档为极狐GitLab DevSecOps 工作流解决方案提供指导和功能细节，该解决方案用于构建和交付混合 (React Native) 移动应用。

对于使用 fastlane 的原生移动应用，请参考产品文档。

说明中包括一个使用 `react-native-community/cli` 启动的示例 [**React Native**](https://reactnative.dev) 应用程序，并提供了在 iOS 和 Android 设备上的跨平台解决方案。该示例项目提供了一个端到端的解决方案，用于使用极狐GitLab CI/CD 流水线来构建、测试和部署移动应用程序。

## 入门指南

按照以下步骤使用此 React Native 移动应用示例项目，通过极狐GitLab 快速启动您的移动应用交付。

### 下载解决方案组件

1. 从您的客户团队获取邀请码。
1. 使用邀请码从[解决方案组件商店](https://cloud.gitlab-accelerator-marketplace.com)下载解决方案组件。

### 设置解决方案组件项目

- 产品加速器市场的移动应用解决方案组件已下载。在解决方案包中，包含带有 CI/CD 文件的移动应用示例项目。
- 创建一个新的极狐GitLab CI/CD 目录项目，以便在您的环境中托管 Snyk 组件。在移动应用解决方案包中，包含 Snyk CI/CD 组件项目文件，可用于设置 Snyk CI/CD 目录项目。
  1. 创建一个新的极狐GitLab 项目来托管此 Snyk CI/CD 目录项目
  1. 将提供的文件复制到您的项目中
  1. 在项目设置中配置所需的 CI/CD 变量
  1. 确保该项目被标记为 CI/CD 目录项目。有关更多信息，请参见[发布组件项目](../../ci/components/_index.md#publish-a-component-project)。

  > [!note]
  > JihuLab.com 上提供了一个公共的极狐GitLab Snyk 组件。如果您可以访问
  > 公共的极狐GitLab Snyk 组件，则无需设置自己的 Snyk CI/CD 目录
  > 项目。而是可以直接根据其文档使用该公共组件。

- 使用“带有 ServiceNow 的变更控制工作流”解决方案包来配置 DevOps 变更速度与极狐GitLab 的集成，以便在需要变更控制的部署中自动在 ServiceNow 中创建变更请求。请参阅[带有 ServiceNow 解决方案组件的变更控制工作流](integrated_servicenow.md)文档，并与您的客户团队联系以获取访问代码来下载“带有 ServiceNow 的变更控制工作流”解决方案包。
- 将 CI YAML 文件复制到您的项目中：
  - `.gitlab-ci.yml`
  - `pipelines` 目录下的 `build-android.yml`。如果 `build-android.yml` 文件放在 `/pipeline` 以外的位置，您需要更新 `.gitlab-ci.yml` 中的文件路径，因为主 `.gitlab-ci.yml` 文件引用 `build-android.yml` 文件用于构建作业。
  - `pipelines` 目录下的 `build-ios.yml`。如果 `build-ios.yml` 文件放在 `/pipeline` 以外的位置，您需要更新 `.gitlab-ci.yml` 中的文件路径，因为主 `.gitlab-ci.yml` 文件引用 `build-ios.yml` 文件用于构建作业。

  ```yaml
  include:
    - local: "pipelines/build-ios.yml"
      inputs:
        image: macos-15-xcode-16
        tag: saas-macos-medium-m1
    - local: "pipelines/build-android.yml"
      inputs:
        image: reactnativecommunity/react-native-android
  ```

- 在您的项目设置中配置所需的 CI/CD 变量。请参阅以下部分以了解流水线的工作原理。

## 流水线如何工作

此流水线专为 React Native 项目设计，处理 iOS 和 Android 的构建、测试和部署移动应用。

此项目包含一个简单的 reactCounter 演示应用，用于 iOS 和 Android 的 React Native 构建。此版本尚未对产物进行签名，因此我们目前无法上传到 TestFlight 或 Play 商店。

每次更改都使用一个组件来自动升级语义化版本号，该版本号被存储为一个临时变量，用于将通用软件包提交到软件包仓库。

## 流水线结构

流水线由以下阶段和作业组成：

1. `prebuild`
   - `单元测试`
   - `Snyk 扫描`
1. `build`
   - `构建 iOS 软件包`
   - `构建 Android 软件包`
1. `test`
   - `依赖项扫描`
   - `SAST 扫描`
1. `functional-test`
   - `上传_ios/android_应用到_sauce_labs`
   - `automated_test_appium_saucelabs`
1. `app-distribution`
   - `app_distribution_sauce_android`
   - `app_distribution_sauce_ios`
1. `beta-release`
   - `beta-release-dev`
   - `beta-release-approval`

## 前提条件

移动流水线工作流中集成了多个第三方工具。要成功运行流水线，请确保满足以下前提条件。

### 使用组件进行 Snyk 集成

为了使用极狐GitLab Snyk CI/CD 组件进行安全扫描，请确保您的极狐GitLab 群组或项目已经与 Snyk 连接，如果没有，请遵循[此教程](https://docs.snyk.io/scm-ide-and-ci-cd-integrations/snyk-scm-integrations/gitlab)进行配置。

在移动应用项目中，为 Snyk 集成添加所需的变量。

#### 所需的 CI/CD 变量

| 变量 | 描述 | 示例值 |
|----------|-------------|---------------|
| `SNYK_TOKEN` | 用于访问 Snyk 的 API 令牌 | `d7da134c-xxxxxxxxxx` |

此移动应用演示项目使用私有 Snyk 组件，这就是为什么我们为移动应用项目添加了以下额外变量来访问私有 Snyk 组件项目，但如果您的 Snyk 组件是公开的或在群组内可访问，则不需要这样做。

```yaml
SNYK_PROJECT_ACCESS_USERNAME: "MOBILE_APP_SNYK_COMPONENT_ACCESS"
DOCKER_AUTH_CONFIG: '{"auths":{"registry.gitlab.com":{"username":"$SNYK_PROJECT_ACCESS_USERNAME","password":"$SNYK_PROJECT_ACCESS_TOKEN"}}}'
```

#### 更新组件路径

更新 `.gitlab-ci.yml` 文件中的组件路径，以便流水线能够成功引用 Snyk 组件。

```yaml
 - component: $CI_SERVER_FQDN/gitlab-com/product-accelerator/work-streams/packaging/snyk/snyk@1.0.0 #snky sast scan, this examples uses the component in GitLab the product accelerator group. Please update the path and stage accordingly.
    inputs:
      stage: prebuild
      token: $SNYK_TOKEN
```

### Sauce Labs 集成

此移动应用演示项目 CI/CD 与 Sauce Labs 集成以进行自动化功能测试。为了在 Sauce Labs 中运行自动化测试，需要将应用程序上传到 Sauce Labs 应用存储。您需要在极狐GitLab 中为项目设置所需变量，以访问 Sauce Labs 并上传产物。

#### 所需的 CI/CD 变量

| 变量 | 描述 | 示例值 |
|----------|-------------|---------------|
| `SAUCE_USERNAME` | Sauce Labs 用户名| `rz` |
| `SAUCE_ACCESS_KEY` | 用于访问 Sauce Labs 的 API 密钥 | `9f5wewwc-xxxxxxx` |
| `APP_FILE_PATH_IOS` | 用于查找构建产物的文件路径 | `ios/build/reactCounter.ipa` |
| `APP_FILE_PATH_ANDROID` | 用于查找构建产物的文件路径 | `android/app/build/outputs/apk/release/app-release.apk` |

#### 使用 Appium 进行自动化测试

为了使用 SauceLabs 进行自动化测试，应用必须上传到 SauceLab 应用管理。流水线使用 API 端点将应用上传到 SauceLabs，并使其可用于测试。

在 `tests/appium` 中添加了一个 Appium 测试脚本文件，用于使用 WebdriverIO 和 Sauce Labs 测试 React Native 移动应用。测试脚本将使用以下环境变量来访问 SauceLabs

``` bash
# 使用项目中定义的变量
const SAUCE_USERNAME = process.env.SAUCE_USERNAME;
const SAUCE_ACCESS_KEY = process.env.SAUCE_ACCESS_KEY;
```

#### 应用分发（Android 和 iOS）

极狐GitLab 流水线将应用构建分发到 SauceLabs TestFairy 用于演示目的。SauceLabs TestFairy 允许用户将应用的新版本分发给测试人员进行审查和测试。

### ServiceNow 集成

此移动应用演示项目的 CI/CD 与 ServiceNow 集成，用于变更控制。当流水线到达启用了 ServiceNow 变更控制的部署作业时，它将自动创建一个变更请求。一旦变更请求获得批准，部署作业将继续。在这个演示项目中，beta 版本发布审批作业在 ServiceNow 中设有门禁，需要手动批准才能继续。

#### CI/CD 变量

为了使流水线能够与 ServiceNow 通信，需要创建 webhook 集成。如果您使用 API 端点与 ServiceNow 通信，则需要包含以下变量。然而，在使用 ServiceNow DevOps 变更速度集成时，这不是必需的。作为 ServiceNow DevOps 变更速度上线的一部分，webhook 将被创建。

| 变量 | 描述 | 示例值 |
|----------|-------------|---------------|
| `SNOW_URL` | 您的 ServiceNow 实例的 URL| `https://<SNOW_INSTANCE>.com/` |
| `SNOW_TOOLID` | ServiceNow 实例 ID | `3b5w345629212105c5ddaccwonworw2` |
| `SNOW_TOKEN` | 用于访问 ServiceNow 的 API 令牌| `Oxxxxxxxxxx` |

## 包含的文件和组件

移动应用项目流水线包含几个外部配置和组件：

- 用于 iOS 和 Android 的本地构建配置
- SAST (static application security testing) 组件
- 自动语义化版本控制组件
- 依赖项扫描
- Snyk SAST 扫描组件

## 备注

请联系您的客户团队以获取邀请码来访问解决方案组件，并就任何其他问题与我们联系。