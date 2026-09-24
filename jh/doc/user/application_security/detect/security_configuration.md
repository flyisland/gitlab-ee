---
stage: Security Risk Management
group: Security Platform Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 安全配置
description: Configuration, testing, compliance, scanning, and enablement.
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以单独为项目配置安全扫描器，也可以创建供多个项目共享的扫描器配置。手动配置每个项目能获得最大的灵活性，但在大规模部署时难以维护。对于多个项目或群组，共享扫描器配置在便于管理的同时，仍然保留了部分必要的自定义能力。

例如，如果您有 10 个项目都手动应用了相同的安全扫描配置，那么进行一次修改就必须重复 10 次。而如果您创建了共享的 CI/CD 配置，则只需修改一次。

<a id="configure-an-individual-project"></a>

## 配置单个项目

要配置单个项目的安全扫描，您可以：

- 编辑 CI/CD 配置文件。
- 通过 UI 编辑 CI/CD 配置。

<a id="with-a-cicd-file"></a>

### 使用 CI/CD 文件

要手动启用单个项目的安全扫描，您可以：

- 启用单个安全扫描器。
- 使用 Auto DevOps 启用所有安全扫描器。

Auto DevOps 为您启用大多数安全扫描器提供了最省力的途径。但与启用单个安全扫描器相比，它的自定义选项有限。

<a id="enable-individual-security-scanners"></a>

#### 启用单个安全扫描器

要启用单个安全扫描工具并自定义设置，请在您的 `.gitlab-ci.yml` 文件中包含相应安全扫描器的模板。

有关如何启用单个安全扫描器的说明，请参阅它们的文档。

<a id="enable-security-scanning-by-using-auto-devops"></a>

#### 使用 Auto DevOps 启用安全扫描

要使用默认设置启用以下安全扫描工具，请启用
[Auto DevOps](../../../topics/autodevops/_index.md)：

- [Auto SAST](../../../topics/autodevops/stages.md#auto-sast)
- [Auto secret detection](../../../topics/autodevops/stages.md#auto-secret-detection)
- [Auto DAST](../../../topics/autodevops/stages.md#auto-dast)
- [Auto dependency scanning](../../../topics/autodevops/stages.md#auto-dependency-scanning)
- [Auto container scanning](../../../topics/autodevops/stages.md#auto-container-scanning)

虽然您无法直接自定义 Auto DevOps，但可以
[将 Auto DevOps 模板包含在项目的 `.gitlab-ci.yml` 文件中](../../../topics/autodevops/customize.md#customize-gitlab-ciyml)
并根据需要覆盖其设置。

<a id="with-the-ui"></a>

### 通过 UI

使用 **安全配置** 页面查看和配置项目的安全测试和漏洞管理设置。

**安全测试** 选项卡通过检查默认分支上最新提交的 CI/CD 流水线，来反映每个安全工具的状态。

启用
: 在流水线输出中找到了安全测试工具的产物。

未启用
: 要么没有 CI/CD 流水线存在，要么在流水线输出中未找到安全测试工具的产物。

<a id="view-security-configuration-page"></a>

#### 查看安全配置页面

先决条件：

- 项目的安全经理、维护者或所有者角色。

要查看项目的安全配置：

1. 在顶部菜单栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **安全** > **安全配置**。

要查看 CI/CD 配置文件的历史变更，请选择 **配置历史**。

<a id="edit-a-projects-security-configuration"></a>

#### 编辑项目的安全配置

先决条件：

- 项目的安全经理、维护者或所有者角色。

要编辑项目的安全配置：

1. 在顶部菜单栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **安全** > **安全配置**。
1. 选择您要启用或配置的安全扫描器，并按照说明进行操作。

有关如何启用和配置单个安全扫描器的更多详细信息，请参阅它们的文档。

<a id="create-a-shared-configuration"></a>

## 创建共享配置

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

要对多个项目应用相同的安全扫描配置，请使用以下方法之一：

- [扫描执行策略](../policies/scan_execution_policies.md)
- [流水线执行策略](../policies/pipeline_execution_policies.md)

这两种方法都允许将 CI/CD 配置（包括安全扫描）定义一次，然后应用到多个项目和群组。与单独配置每个项目相比，这些方法有几个优势，包括：

- 只需对配置做一次更改，而无需针对每个项目更改。
- 进行配置更改的权限受到限制，从而实现了职责分离。

<a id="customize-security-scanning"></a>

## 自定义安全扫描

您可以根据自己的需求和环境自定义安全扫描。有关如何自定义单个安全扫描器的详细信息，请参阅它们的文档。

<a id="best-practices"></a>

### 最佳实践

在自定义安全扫描配置时：

- 在将更改合并到默认分支之前，请务必通过合并请求来测试所有对安全扫描工具的自定义。如果不这样做，可能会导致意外结果，包括产生大量误报。
- 仅根据需要覆盖模板中的值。所有其他值都从模板继承。
- 对于生产工作流，请使用每个模板的稳定版本。稳定版本的变更频率较低，破坏性更改仅发生在极狐GitLab 的主要版本之间。最新版本包含最近的更改，但在极狐GitLab 的次要版本之间可能会有重大更改。

<a id="template-editions"></a>

### 模板版本

极狐GitLab 应用安全工具最多有两个模板版本：

- **稳定版**：稳定版模板是默认版本。它提供可靠且一致的应用安全体验。对于大多数需要 CI/CD 流水线稳定性和可预测行为的用户和项目，您应该使用稳定版模板。
- **最新版**：最新版模板适用于那些希望访问和测试前沿功能的用户。它通过模板名称中的 `latest` 一词来标识。它不被视为稳定版本，并可能包含计划用于下一个主要版本的破坏性更改。此模板允许您在功能成为稳定版本的一部分之前尝试新功能和更新。

> [!note]
> 请勿在同一项目中混合使用安全模板。混合使用不同安全模板版本可能会导致合并请求流水线和分支流水线同时运行。

<a id="override-the-default-registry-base-address"></a>

### 覆盖默认仓库基础地址

默认情况下，极狐GitLab 安全扫描器使用 `registry.gitlab.com/security-products` 作为 Docker 镜像的基础地址。您可以通过将 CI/CD 变量 `SECURE_ANALYZERS_PREFIX` 设置为另一个地址来为大多数扫描器覆盖此地址。这会一次性影响所有扫描器。

[容器镜像扫描](../container_scanning/_index.md)分析器是一个例外，它不使用 `SECURE_ANALYZERS_PREFIX` 变量。要覆盖其 Docker 镜像，请参阅
[在离线环境中运行容器镜像扫描](../container_scanning/_index.md#offline-environment) 的说明。

<a id="use-security-scanning-tools-with-merge-request-pipelines"></a>

### 在合并请求流水线中使用安全扫描工具

默认情况下，应用安全作业配置为仅针对分支流水线运行。
要在[合并请求流水线](../../../ci/pipelines/merge_request_pipelines.md)中使用它们，
您可以：

- 将 CI/CD 变量 `AST_ENABLE_MR_PIPELINES` 设置为 `"true"`（在 18.0 中引入）（推荐）
- 使用[已默认启用合并请求流水线的最新版模板](#模板版本)

例如，要同时运行 SAST 和依赖扫描并启用合并请求流水线，可使用以下配置：

```yaml
include:
  - template: Jobs/Dependency-Scanning.v2.gitlab-ci.yml
  - template: Jobs/SAST.gitlab-ci.yml

variables:
  AST_ENABLE_MR_PIPELINES: "true"
```

<a id="use-a-custom-scanning-stage"></a>

### 使用自定义扫描阶段

默认情况下，安全扫描器模板使用预定义的 `test` 阶段。要让它们在另一个阶段运行，请将自定义阶段的名称添加到 `.gitlab-ci.yml` 文件的 `stages:` 部分。

有关覆盖安全作业的更多信息，请参见：

- [覆盖 SAST 作业](../sast/_index.md#override-sast-jobs)。
- [覆盖依赖扫描作业](../dependency_scanning/dependency_scanning_sbom/_index.md#customizing-analyzer-behavior)。
- [覆盖容器镜像扫描作业](../container_scanning/_index.md#overriding-the-container-scanning-template)。
- [覆盖密钥检测作业](../secret_detection/pipeline/configure.md)。
- [覆盖 DAST 作业](../dast/browser/_index.md)。

<a id="troubleshooting"></a>

## 故障排除

在配置安全扫描时，您可能会遇到以下问题。

<a id="error-chosen-stage-test-does-not-exist"></a>

### 错误：`所选阶段 test 不存在`

在运行流水线时，您可能会收到一个错误，提示 `所选阶段 test 不存在`。

此问题在安全扫描作业使用的阶段未在 `.gitlab-ci.yml` 文件中声明时发生。

要解决此问题，您可以：

- 在 `.gitlab-ci.yml` 中添加一个 `test` 阶段：

  ```yaml
  stages:
    - test
    - unit-tests

  include:
    - template: Jobs/Dependency-Scanning.v2.gitlab-ci.yml
    - template: Jobs/SAST.gitlab-ci.yml
    - template: Jobs/Secret-Detection.gitlab-ci.yml

  custom job:
    stage: unit-tests
    script:
      - echo "custom job"
  ```

- 覆盖每个安全作业的默认阶段。例如，要使用名为 `unit-tests` 的预定义阶段：

  ```yaml
  stages:
    - unit-tests

  include:
    - template: Jobs/Dependency-Scanning.v2.gitlab-ci.yml
      inputs:
        stage: unit-tests
    - template: Jobs/SAST.gitlab-ci.yml
    - template: Jobs/Secret-Detection.gitlab-ci.yml

  sast:
    stage: unit-tests

  .secret-analyzer:
    stage: unit-tests

  custom job:
    stage: unit-tests
    script:
      - echo "custom job"
  ```