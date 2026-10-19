---
stage: Production Engineering
group: Runners Platform
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 了解如何在 macOS 上使用 JihuLab.com 的托管 Runner 运行 CI/CD 作业、构建 macOS 和 iOS 应用程序，并为您的应用程序配置预安装的构建工具。
title: macOS 上的托管 Runner
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Status: 测试版

{{< /details >}}

macOS 上的托管 Runner 提供按需的 macOS 环境，并与极狐GitLab [CI/CD](../../_index.md) 完全集成。
您可以使用这些 Runner 为 Apple 生态系统（macOS、iOS、watchOS、tvOS）构建、测试和部署应用程序。
我们的 [Mobile DevOps 部分](../../mobile_devops/mobile_devops_tutorial_ios.md#set-up-your-build-environment)提供了为 iOS 构建和部署移动应用程序的功能、文档和指导。

macOS 上的托管 Runner 处于[测试版](../../../policy/development_stages_support.md#beta)，面向开源计划以及使用专业版和旗舰版套餐的客户提供。macOS 上的托管 Runner 的[正式发布](../../../policy/development_stages_support.md#generally-available)已在[史诗 8267](https://gitlab.com/groups/gitlab-org/-/epics/8267)中提出。

在使用 macOS 上的托管 Runner 之前，请查看影响它们的[已知问题和用法限制](#known-issues-and-usage-constraints)列表。

<a id="machine-types-available-for-macos"></a>

## macOS 可用的机器类型

极狐GitLab 为 macOS 上的托管 Runner 提供以下机器类型。要构建 x86-64 目标，您可以使用 Rosetta 2 模拟 Intel x86-64 环境。

| Runner 标签               | vCPUs | 内存 | 存储 |
| ------------------------ | ----- | ------ | ------- |
| `saas-macos-medium-m1`   | 4     | 8 GB   | 50 GB   |
| `saas-macos-large-m2pro` | 6     | 16 GB  | 50 GB   |

<a id="supported-macos-images"></a>

## 支持的 macOS 镜像

与我们在 Linux 上的托管 Runner（您可以在其中运行任何 Docker 镜像）相比，极狐GitLab 为 macOS 提供了一组虚拟机镜像。

您可以在以下镜像之一中执行构建，并在 `.gitlab-ci.yml` 文件中指定该镜像。每个镜像都运行特定版本的 macOS 和 Xcode。

| 虚拟机镜像                   | 状态       |              |
|----------------------------|--------------|--------------|
| `macos-15-xcode-16`        | `GA`         | [预安装软件](https://gitlab-org.gitlab.io/ci-cd/shared-runners/images/macos-image-inventory/macos-15-xcode-16/) |
| `macos-26-xcode-26`        | `GA`         | [预安装软件](https://gitlab-org.gitlab.io/ci-cd/shared-runners/images/macos-image-inventory/macos-26-xcode-26/) |
| `macos-27-xcode-27`        | `beta`       | [预安装软件](https://gitlab-org.gitlab.io/ci-cd/shared-runners/images/macos-image-inventory/macos-27-xcode-27/) |

如果未指定镜像，macOS Runner 将使用 `macos-26-xcode-26`。

<a id="image-update-policy-for-macos"></a>

## macOS 镜像更新策略

镜像和已安装组件会随每个极狐GitLab 版本一起更新，以保持预安装软件为最新版本。极狐GitLab 通常支持多个版本的预安装软件。有关更多信息，请参阅[预安装软件完整列表](https://gitlab.com/gitlab-org/ci-cd/shared-runners/images/job-images/-/tree/main/toolchain)。

macOS 和 Xcode 的主要版本和次要版本会在 Apple 发布后的下一个里程碑中提供。

新的主要版本镜像最初以测试版形式提供，并在第一个次要版本发布时正式发布。由于一次仅支持两个正式发布的镜像，最旧的镜像将被弃用，并在三个月后根据[支持的镜像生命周期](_index.md#supported-image-lifecycle)移除。

当新的主要版本正式发布时，它将成为所有 macOS 作业的默认镜像。

<a id="example-gitlab-ciyml-file"></a>

## 示例 `.gitlab-ci.yml` 文件

以下示例 `.gitlab-ci.yml` 文件展示了如何开始使用 macOS 上的托管 Runner：

```yaml
.macos_saas_runners:
  tags:
    - saas-macos-medium-m1
  image: macos-26-xcode-26
  before_script:
    - echo "started by ${GITLAB_USER_NAME} / @${GITLAB_USER_LOGIN}"

build:
  extends:
    - .macos_saas_runners
  stage: build
  script:
    - echo "running scripts in the build job"

test:
  extends:
    - .macos_saas_runners
  stage: test
  script:
    - echo "running scripts in the test job"
```

<a id="code-signing-ios-projects-with-fastlane"></a>

## 使用 fastlane 为 iOS 项目进行代码签名

在将极狐GitLab 与 Apple 服务集成、安装到设备或部署到 Apple App Store 之前，您必须对应用程序进行[代码签名](https://developer.apple.com/documentation/security/code-signing-services)。

macOS 虚拟机镜像上的每个 Runner 都包含 [fastlane](https://fastlane.tools/)，
这是一个旨在简化移动应用部署的开源解决方案。

有关如何为应用程序设置代码签名的信息，请参阅 [Mobile DevOps 文档](../../mobile_devops/mobile_devops_tutorial_ios.md#configure-code-signing-with-fastlane)中的说明。

相关主题：

- [Apple 开发者支持 - 代码签名](https://forums.developer.apple.com/forums/thread/707080)
- [代码签名最佳实践指南](https://codesigning.guide/)
- [fastlane 与 Apple 服务认证指南](https://docs.fastlane.tools/getting-started/ios/authentication/)

<a id="optimizing-homebrew"></a>

## 优化 Homebrew

默认情况下，Homebrew 会在任何操作开始时检查更新。Homebrew 的发布周期可能比极狐GitLab macOS 镜像的发布周期更频繁。这种发布周期的差异可能导致调用 `brew`的步骤需要额外时间才能完成，因为 Homebrew 正在执行更新。

为减少因意外的 Homebrew 更新而导致的构建时间，请在 `.gitlab-ci.yml`中设置 `HOMEBREW_NO_AUTO_UPDATE` 变量：

```yaml
variables:
  HOMEBREW_NO_AUTO_UPDATE: 1
```

<a id="optimizing-cocoapods"></a>

## 优化 CocoaPods

如果您在项目中使用 CocoaPods，应考虑以下优化措施以提高 CI 性能。

<a id="enable-cdn-access"></a>

### 启用 CDN 访问

您可以使用内容分发网络（CDN）访问从 CDN 下载软件包，而无需克隆整个项目代码仓库。CDN 访问在 CocoaPods 1.8 或更高版本中可用，并受所有 macOS 上的极狐GitLab 托管 Runner 支持。

要启用 CDN 访问，请确保您的 Podfile 以以下内容开头：

```ruby
source 'https://cdn.cocoapods.org/'
```

<a id="use-gitlab-caching"></a>

### 使用极狐GitLab 缓存

在极狐GitLab 中对 CocoaPods 软件包使用缓存，以便仅在 pod 发生变化时运行 `pod install`，这可以提高构建性能。

要为您的项目[配置缓存](../../caching/_index.md)：

1. 将 `cache` 配置添加到您的 `.gitlab-ci.yml` 文件中：

   ```yaml
   cache:
     key:
       files:
        - Podfile.lock
   paths:
     - Pods
   ```

1. 将 [`cocoapods-check`](https://guides.cocoapods.org/plugins/optimising-ci-times.html) 插件添加到您的项目中。
1. 更新作业脚本，使其在调用 `pod install` 之前检查已安装的依赖项：

   ```shell
   bundle exec pod check || bundle exec pod install
   ```

<a id="include-pods-in-source-control"></a>

### 将 pod 纳入源代码管理

您也可以[将 pods 目录纳入源代码管理](https://guides.cocoapods.org/using/using-cocoapods.html#should-i-check-the-pods-directory-into-source-control)。这样就不需要在 CI 作业中安装 pod，但会增加项目代码仓库的整体大小。

<a id="known-issues-and-usage-constraints"></a>

## 已知问题和用法限制

- 如果虚拟机镜像不包含您的作业所需的特定软件版本，则必须获取并安装所需软件。这会导致作业执行时间增加。
- 无法使用您自己的操作系统镜像。
- 用户 `gitlab`的钥匙串不公开可用。您必须改为创建一个钥匙串。
- macOS 上的托管 Runner 以无头模式运行。
  不支持任何需要 UI 交互的工作负载，例如 `testmanagerd`。
- 由于 Apple 芯片具有能效核心和
  性能核心，作业性能可能因作业执行而异。您无法控制核心分配或调度，这可能导致不一致。
- 用于 macOS 上的托管 Runner 的 AWS 裸机 macOS 机器可用性有限。当没有可用机器时，作业可能会经历较长的排队时间。
- macOS 上的托管 Runner 实例有时不响应请求，这会导致作业挂起，直到达到最大作业时长。
- macOS 默认使用不区分大小写的文件系统。
  如果您有仅大小写不同的重复文件路径，此行为可能导致意外错误。
  这些重复路径可能位于 Git 工作树或存储分支和标签的 Git 引用中。
