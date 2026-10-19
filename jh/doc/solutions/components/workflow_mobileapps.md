---
stage: Solutions Architecture
group: Solutions Architecture
info: This page is owned by the Solutions Architecture team.
description: 了解适用于混合 React Native 移动应用的极狐GitLab DevSecOps 工作流，包括 CI/CD 设置、Snyk 安全扫描、Sauce Labs 功能测试和 ServiceNow 集成。
title: DevSecOps 工作流 - 移动应用
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

本文档提供用于构建和交付混合（React Native）移动应用的极狐GitLab DevSecOps 工作流解决方案的说明和功能详情。

对于使用 fastlane 的原生移动应用，请参阅产品文档。

这些说明包含一个示例 [**React Native**](https://reactnative.dev) 应用，该应用使用 `react-native-community/cli` 引导创建，并提供适用于 iOS 和 Android 设备的跨平台解决方案。该示例项目提供了一套端到端解决方案，用于使用极狐GitLab CI/CD 流水线构建、测试和部署移动应用。

<a id="getting-started"></a>

## 入门

请按照以下步骤使用此 React Native 移动应用示例项目，快速启动使用极狐GitLab 的移动应用交付。

<a id="download-the-solution-component"></a>

### 下载解决方案组件

1. 从您的客户团队获取邀请码。
1. 使用您的邀请码从[解决方案组件网上商店](https://cloud.gitlab-accelerator-marketplace.com)下载解决方案组件。

<a id="set-up-the-solution-component-project"></a>

### 设置解决方案组件项目

- 已从 Product Accelerator 市场下载移动应用解决方案组件。该解决方案包包含带有 CI/CD 文件的移动应用示例项目。
- 创建一个新的极狐GitLab CI/CD catalog 项目，以在您的环境中托管 Snyk 组件。移动应用解决方案包包含 Snyk CI/CD 组件项目文件，可让您设置 Snyk CI/CD catalog 项目。
  1. 创建一个新的极狐GitLab 项目来托管此 Snyk CI/CD catalog 项目
  1. 将提供的文件复制到您的项目中
  1. 在项目设置中配置所需的 CI/CD 变量
  1. 确保该项目已标记为 CI/CD catalog 项目。更多信息，请参阅[发布组件项目](../../ci/components/_index.md#publish-a-component-project)。

  > [!note]
  > 公共的极狐GitLab Snyk 组件可在 JihuLab.com 上使用。如果您可以访问
  > 公共的极狐GitLab Snyk 组件，则无需设置自己的 Snyk CI/CD catalog
  > 项目。相反，请按照其文档直接使用公共组件。

- 使用 Change Control Workflow with ServiceNow 解决方案包，配置 DevOps Change Velocity 与极狐GitLab 的集成，以便为需要变更控制的部署自动在 ServiceNow 中创建变更请求。请参阅[使用 ServiceNow 的变更控制工作流解决方案组件](integrated_servicenow.md)文档，并与您的客户团队合作获取访问码，以下载 Change Control Workflow with ServiceNow 解决方案包。
- 将 CI YAML 文件复制到您的项目中：
  - `.gitlab-ci.yml`
  - `build-android.yml` 位于 `pipelines` 目录中。如果 `build-android.yml` 文件放在 `/pipeline` 之外的其他位置，您需要更新 `.gitlab-ci.yml`中的文件路径，因为主 `.gitlab-ci.yml` 文件会为构建作业引用 `build-android.yml` 文件。
  - `build-ios.yml` 位于 `pipelines` 目录中。如果 `build-ios.yml` 文件放在 `/pipeline` 之外的其他位置，您需要更新 `.gitlab-ci.yml`中的文件路径，因为主 `.gitlab-ci.yml` 文件会为构建作业引用 `build-ios.yml` 文件。

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

- 在项目设置中配置所需的 CI/CD 变量。请参阅以下部分了解流水线的工作方式。

<a id="how-the-pipeline-works"></a>

## 流水线的工作方式

此流水线专为 React Native 项目设计，处理 iOS 和 Android 的构建、测试以及移动应用的部署。

此项目包含一个简单的 reactCounter 演示应用，用于为 iOS 和 Android 构建 React Native。此版本尚未对产物进行签名，因此无法上传到 TestFlight 或 Play Store。

每次变更都会使用一个组件进行语义化版本号递增，该版本号存储为临时变量，用于将通用软件包提交到软件包仓库。

<a id="pipeline-structure"></a>

## 流水线结构

该流水线包含以下阶段和作业：

1. `prebuild`
   - `unit test`
   - `Snyk scans`
1. `build`
   - `build IoS package`
   - `build Android package`
1. `test`
   - `dependency scanning`
   - `SAST scanning`
1. `functional-test`
   - `upload_ios/android_app_to_sauce_labs`
   - `automated_test_appium_saucelabs`
1. `app-distribution`
   - `app_distribution_sauce_android`
   - `app_distribution_sauce_ios`
1. `beta-release`
   - `beta-release-dev`
   - `beta-release-approval`

<a id="prerequisites"></a>

## 先决条件

移动流水线工作流中集成了多个第三方工具。为了成功运行该流水线，请确保满足以下先决条件。

<a id="snyk-integration-using-the-component"></a>

### 使用组件集成 Snyk

为了使用极狐GitLab Snyk CI/CD 组件进行安全扫描，请确保您在极狐GitLab 中的群组或项目已与 Snyk 连接；如果尚未连接，请按照[本教程](https://docs.snyk.io/scm-ide-and-ci-cd-integrations/snyk-scm-integrations/gitlab)进行配置。

在移动应用项目中，添加 Snyk 集成所需的变量。

<a id="required-cicd-variables"></a>

#### 必需的 CI/CD 变量

| 变量 | 描述 | 示例值 |
|----------|-------------|---------------|
| `SNYK_TOKEN` | 用于访问 Snyk 的 API 令牌 | `d7da134c-xxxxxxxxxx` |

此移动应用演示项目使用私有的 Snyk 组件。因此，我们为移动应用项目添加了以下额外变量，以访问私有 Snyk 组件项目；但如果您的 Snyk 组件是公共的，或可在您的群组内访问，则无需这样做。

```yaml
SNYK_PROJECT_ACCESS_USERNAME: "MOBILE_APP_SNYK_COMPONENT_ACCESS"
DOCKER_AUTH_CONFIG: '{"auths":{"registry.gitlab.com":{"username":"$SNYK_PROJECT_ACCESS_USERNAME","password":"$SNYK_PROJECT_ACCESS_TOKEN"}}}'
```

<a id="update-the-component-path"></a>

#### 更新组件路径

更新 `.gitlab-ci.yml` 文件中的组件路径，以便流水线能够成功引用 Snyk 组件。

```yaml
 - component: $CI_SERVER_FQDN/gitlab-com/product-accelerator/work-streams/packaging/snyk/snyk@1.0.0 #snky sast scan, this examples uses the component in GitLab the product accelerator group. Please update the path and stage accordingly.
    inputs:
      stage: prebuild
      token: $SNYK_TOKEN
```

<a id="sauce-labs-integration"></a>

### Sauce Labs 集成

此移动应用演示项目的 CI/CD 已与 Sauce Labs 集成，用于自动化功能测试。为了在 Sauce Labs 中运行自动化测试，需要将应用上传到 Sauce Labs 应用存储。您需要在极狐GitLab 中为项目设置所需的变量，以访问 Sauce Labs 并上传产物。

<a id="required-cicd-variables-1"></a>

#### 必需的 CI/CD 变量

| 变量 | 描述 | 示例值 |
|----------|-------------|---------------|
| `SAUCE_USERNAME` | Sauce Labs 用户名| `rz` |
| `SAUCE_ACCESS_KEY` | 用于访问 Sauce Labs 的 API 密钥  | `9f5wewwc-xxxxxxx` |
| `APP_FILE_PATH_IOS` | 用于查找构建产物的文件路径 | `ios/build/reactCounter.ipa` |
| `APP_FILE_PATH_ANDROID` | 用于查找构建产物的文件路径 | `android/app/build/outputs/apk/release/app-release.apk` |

<a id="use-appium-for-automated-testing"></a>

#### 使用 Appium 进行自动化测试

为了使用 SauceLabs 进行自动化测试，必须将应用上传到 SauceLab App Management。该流水线使用 API 端点将应用上传到 SauceLabs，并使其可用于测试。

在 `tests/appium`中添加了一个 Appium 测试脚本文件，用于使用 WebdriverIO 和 Sauce Labs 测试 React Native 移动应用。该测试脚本将使用以下环境变量来访问 SauceLabs

``` bash
# Using the variables defined in the project

const SAUCE_USERNAME = process.env.SAUCE_USERNAME;
const SAUCE_ACCESS_KEY = process.env.SAUCE_ACCESS_KEY;

```

<a id="app-distribution-android-and-ios"></a>

#### 应用分发（Android 和 iOS）

极狐GitLab 流水线将应用构建分发给 SauceLabs TestFairy 以供演示。SauceLabs TestFairy 允许用户将应用的新版本提供给测试人员，以供审阅和测试。

<a id="servicenow-integration"></a>

### ServiceNow 集成

此移动应用演示项目的 CI/CD 已与 ServiceNow 集成，用于变更控制。当流水线到达在 ServiceNow 中启用了变更控制的部署作业时，它将自动创建变更请求。变更请求获批后，部署作业将继续执行。在此演示项目中，beta 发布审批作业在 ServiceNow 中设有门禁，需要手动批准才能继续。

<a id="cicd-variables"></a>

#### CI/CD 变量

为了让流水线与 ServiceNow 通信，需要创建 webhook 集成。如果您使用 API 端点与 ServiceNow 通信，则需要包含以下变量。但是，使用 ServiceNow DevOps Change Velocity 集成时则不需要这样做。作为 ServiceNow DevOps Change Velocity 入门的一部分，webhook 将被创建。

| 变量 | 描述 | 示例值 |
|----------|-------------|---------------|
| `SNOW_URL` | 您的 ServiceNow 实例的 URL| `https://<SNOW_INSTANCE>.com/` |
| `SNOW_TOOLID` | ServiceNow 实例 ID  | `3b5w345629212105c5ddaccwonworw2` |
| `SNOW_TOKEN` | 用于访问 ServiceNow 的 API 令牌| `Oxxxxxxxxxx` |

<a id="included-files-and-components"></a>

## 包含的文件和组件

移动应用项目流水线包含若干外部配置和组件：

- iOS 和 Android 的本地构建配置
- SAST（静态应用安全测试）组件
- 自动语义化版本组件
- 依赖扫描
- Snyk SAST 扫描组件

<a id="notes"></a>

## 说明

请联系您的客户团队，以获取访问解决方案组件的邀请码，以及咨询任何其他问题。
