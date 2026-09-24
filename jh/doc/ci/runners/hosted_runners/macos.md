---
stage: Production Engineering
group: Runners Platform
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: macOS 上的托管 Runner
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Status: Beta

{{< /details >}}

macOS 上的托管 Runner 提供了一个按需的 macOS 环境，与 极狐GitLab [CI/CD](../../_index.md) 完全集成。您可以使用这些 Runner 为 Apple 生态系统（macOS、iOS、watchOS、tvOS）构建、测试和部署应用。我们的 [Mobile DevOps 部分](../../mobile_devops/mobile_devops_tutorial_ios.md#set-up-your-build-environment) 提供了关于构建和部署 iOS 移动应用的功能、文档和指导。

macOS 上的托管 Runner 处于 [测试版](../../../policy/development_stages_support.md#beta) 阶段，并面向开源项目以及专业版和旗舰版计划的客户提供。macOS 上的托管 Runner 的 [正式发布（GA）](../../../policy/development_stages_support.md#generally-available) 计划在 [史诗 8267](https://jihulab.com/groups/gitlab-cn/-/epics/8267) 中提出。

在使用之前，请查看影响 macOS 托管 Runner 的 [已知问题和使用限制](#known-issues-and-usage-constraints) 列表。

<a id="machine-types-available-for-macos"></a>

macOS 可用的机器类型

极狐GitLab 为 macOS 上的托管 Runner 提供以下机器类型。要针对 x86-64 目标进行构建，您可以使用 Rosetta 2 模拟 Intel x86-64 环境。

| Runner 标签               | vCPU | 内存 | 存储 |
| ------------------------ | ----- | ------ | ------- |
| `saas-macos-medium-m1`   | 4     | 8 GB   | 50 GB   |
| `saas-macos-large-m2pro` | 6     | 16 GB  | 50 GB   |

<a id="supported-macos-images"></a>

支持的 macOS 镜像

与我们的 Linux 托管 Runner（您可以运行任何 Docker 镜像）相比，极狐GitLab 为 macOS 提供了一组虚拟机镜像。

您可以在以下镜像之一中执行构建，这些镜像在您的 `.gitlab-ci.yml` 文件中指定。每个镜像运行特定版本的 macOS 和 Xcode。

| 虚拟机镜像                   | 状态       |              |
|----------------------------|--------------|--------------|
| `macos-14-xcode-15`        | `已弃用` | [预装软件](https://gitlab-org.gitlab.io/ci-cd/shared-runners/images/macos-image-inventory/macos-14-xcode-15/) |
| `macos-15-xcode-16`        | `GA`         | [预装软件](https://gitlab-org.gitlab.io/ci-cd/shared-runners/images/macos-image-inventory/macos-15-xcode-16/) |
| `macos-26-xcode-26`        | `GA`         | [预装软件](https://gitlab-org.gitlab.io/ci-cd/shared-runners/images/macos-image-inventory/macos-26-xcode-26/) |

如果未指定镜像，macOS Runner 将使用 `macos-15-xcode-16`。

<a id="image-update-policy-for-macos"></a>

macOS 镜像更新策略

镜像和已安装的组件会随着每次极狐GitLab 发布而更新，以保持预装软件的最新状态。极狐GitLab 通常支持多个版本的预装软件。有关更多信息，请参阅 [预装软件的完整列表](https://jihulab.com/gitlab-cn/ci-cd/shared-runners/images/job-images/-/tree/main/toolchain)。

macOS 和 Xcode 的主要版本和次要版本在 Apple 发布后的里程碑中提供。

新的主要版本镜像最初作为测试版提供，并在第一个次要版本发布时正式发布（GA）。由于一次仅支持两个正式发布（GA）的镜像，最旧的镜像将变为已弃用，并将根据 [支持的镜像生命周期](_index.md#supported-image-lifecycle) 在三个月后移除。

当新的主要版本正式发布（GA）时，它将成为所有 macOS 作业的默认镜像。

<a id="example-gitlab-ci-yml-file"></a>

`.gitlab-ci.yml` 文件示例

以下示例 `.gitlab-ci.yml` 文件展示了如何开始使用 macOS 上的托管 Runner：

```yaml
.macos_saas_runners:
  tags:
    - saas-macos-medium-m1
  image: macos-14-xcode-15
  before_script:
    - echo "由 ${GITLAB_USER_NAME} / @${GITLAB_USER_LOGIN} 启动"

build:
  extends:
    - .macos_saas_runners
  stage: build
  script:
    - echo "在构建作业中运行脚本"

test:
  extends:
    - .macos_saas_runners
  stage: test
  script:
    - echo "在测试作业中运行脚本"
```

<a id="code-signing-ios-projects-with-fastlane"></a>

使用 fastlane 对 iOS 项目进行代码签名

在将极狐GitLab 与 Apple 服务集成、安装到设备或部署到 Apple App Store 之前，您必须对应用进行 [代码签名](https://developer.apple.com/documentation/security/code_signing_services)。

每个 macOS 虚拟机镜像上的 Runner 都包含 [fastlane](https://fastlane.tools/)，这是一个旨在简化移动应用部署的开源解决方案。

有关如何为应用设置代码签名的信息，请参阅 [Mobile DevOps 文档](../../mobile_devops/mobile_devops_tutorial_ios.md#configure-code-signing-with-fastlane) 中的说明。

相关主题：

- [Apple 开发者支持 - 代码签名](https://forums.developer.apple.com/forums/thread/707080)
- [代码签名最佳实践指南](https://codesigning.guide/)
- [fastlane 与 Apple 服务认证指南](https://docs.fastlane.tools/getting-started/ios/authentication/)

<a id="optimizing-homebrew"></a>

优化 Homebrew

默认情况下，Homebrew 在任何操作开始时都会检查更新。Homebrew 的发布周期可能比极狐GitLab macOS 镜像的发布周期更频繁。这种发布周期的差异可能会导致调用 `brew` 的步骤在 Homebrew 进行更新时花费额外的时间来完成。

为了减少因意外的 Homebrew 更新而导致的构建时间，请在 `.gitlab-ci.yml` 中设置 `HOMEBREW_NO_AUTO_UPDATE` 变量：

```yaml
variables:
  HOMEBREW_NO_AUTO_UPDATE: 1
```

<a id="optimizing-cocoapods"></a>

优化 CocoaPods

如果您在项目中使用 CocoaPods，应考虑以下优化以提高 CI 性能。

**CocoaPods CDN**

您可以使用内容分发网络（CDN）访问从 CDN 下载软件包，而无需克隆整个项目仓库。CDN 访问在 CocoaPods 1.8 或更高版本中可用，并且所有极狐GitLab macOS 托管 Runner 都支持。

要启用 CDN 访问，请确保您的 Podfile 以以下内容开头：

```ruby
source 'https://cdn.cocoapods.org/'
```

**使用极狐GitLab 缓存**

在极狐GitLab 中对 CocoaPods 软件包使用缓存，以便仅在 pod 发生变化时运行 `pod install`，这可以提高构建性能。

要为项目 [配置缓存](../../caching/_index.md)：

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
1. 更新作业脚本，以便在调用 `pod install` 之前检查已安装的依赖项：

   ```shell
   bundle exec pod check || bundle exec pod install
   ```

**将 pods 纳入源代码管理**

您还可以 [将 pods 目录纳入源代码管理](https://guides.cocoapods.org/using/using-cocoapods.html#should-i-check-the-pods-directory-into-source-control)。这消除了在 CI 作业中安装 pods 的需要，但会增加项目仓库的整体大小。

<a id="known-issues-and-usage-constraints"></a>

已知问题和使用限制

- 如果虚拟机镜像不包含作业所需的特定软件版本，则必须获取并安装所需的软件。这会导致作业执行时间增加。
- 无法使用您自己的操作系统镜像。
- 用户 `gitlab` 的钥匙串未公开提供。您必须自行创建钥匙串。
- macOS 上的托管 Runner 以无头模式运行。任何需要 UI 交互的工作负载（如 `testmanagerd`）均不受支持。
- 由于 Apple silicon 芯片具有能效核心和性能核心，作业性能可能在执行之间有所不同。您无法控制核心分配或调度，这可能导致不一致。
- 用于 macOS 托管 Runner 的 AWS 裸金属 macOS 机器可用性有限。当没有可用机器时，作业可能会经历更长的排队时间。
- macOS 上的托管 Runner 实例有时不响应请求，这会导致作业挂起，直到达到最大作业持续时间。
- macOS 默认使用不区分大小写的文件系统。如果您有仅大小写不同的重复文件路径，此行为可能导致意外错误。这些重复路径可能存在于 Git 工作树或存储分支和标签的 Git 引用中。