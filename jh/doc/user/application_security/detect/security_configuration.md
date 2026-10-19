---
stage: Security Risk Management
group: Security Platform Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 安全配置
description: 配置、测试、合规、扫描和启用。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以为单个项目配置安全扫描器，也可以创建由多个项目共享的扫描器配置。手动配置每个项目可提供最大的灵活性，但在规模扩大后难以维护。对于多个项目或群组，共享扫描器配置更易于管理，同时仍可在需要时进行一定程度的自定义。

例如，如果您有 10 个项目手动应用了相同的安全扫描配置，那么每次更改都必须执行 10 次。相反，如果您创建一个共享的 CI/CD 配置，则只需执行一次更改。

<a id="configure-an-individual-project"></a>

## 配置单个项目

要配置单个项目中的安全扫描，您可以：

- 编辑 CI/CD 配置文件。
- 在 UI 中编辑 CI/CD 配置。

<a id="with-a-cicd-file"></a>

### 使用 CI/CD 文件

要手动为单个项目启用安全扫描，您可以：

- 启用单个安全扫描器。
- 使用 AutoDevOps 启用所有安全扫描器。

AutoDevOps 提供了启用大多数安全扫描器的最省力途径。但是，与启用单个安全扫描器相比，其自定义选项有限。

<a id="enable-individual-security-scanners"></a>

#### 启用单个安全扫描器

要启用单个安全扫描工具并可自定义设置，请将安全扫描器的模板包含到您的 `.gitlab-ci.yml` 文件中。

有关如何启用单个安全扫描器的说明，请参阅其文档。

<a id="enable-security-scanning-by-using-auto-devops"></a>

#### 使用 Auto DevOps 启用安全扫描

要使用默认设置启用以下安全扫描工具，请启用
[Auto DevOps](../../../topics/autodevops/_index.md)：

- [Auto SAST](../../../topics/autodevops/stages.md#auto-sast)
- [Auto 密钥检测](../../../topics/autodevops/stages.md#auto-secret-detection)
- [Auto DAST](../../../topics/autodevops/stages.md#auto-dast)
- [Auto 依赖扫描](../../../topics/autodevops/stages.md#auto-dependency-scanning)
- [Auto 容器扫描](../../../topics/autodevops/stages.md#auto-container-scanning)

虽然您无法直接自定义 Auto DevOps，但您可以[将 Auto DevOps 模板包含到项目的 `.gitlab-ci.yml` 文件中](../../../topics/autodevops/customize.md#customize-gitlab-ciyml)并根据需要覆盖其设置。

<a id="with-the-ui"></a>

### 使用 UI

使用**安全配置**页面查看和配置项目的安全测试和漏洞管理设置。

**安全测试**标签页通过检查默认分支上最近一次提交中的 CI/CD 流水线，反映每个安全工具的状态。

已启用
: 在流水线的输出中找到了该安全测试工具的产物。

未启用
: 要么不存在 CI/CD 流水线，要么在流水线的输出中未找到该安全测试工具的产物。

<a id="view-security-configuration-page"></a>

#### 查看安全配置页面

先决条件：

- 项目的安全管理员、维护者或所有者角色。

要查看项目的安全配置：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**安全** > **安全配置**。

要查看 CI/CD 配置文件更改的历史视图，请选择**配置历史**。

<a id="edit-a-projects-security-configuration"></a>

#### 编辑项目的安全配置

先决条件：

- 项目的安全管理员、维护者或所有者角色。

要编辑项目的安全配置：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**安全** > **安全配置**。
1. 选择您要启用或配置的安全扫描器，然后按照说明操作。

有关如何启用和配置单个安全扫描器的更多详细信息，请参阅其文档。

<a id="create-a-shared-configuration"></a>

## 创建共享配置

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

要将相同的安全扫描配置应用于多个项目，请使用以下方法之一：

- [扫描执行策略](../policies/scan_execution_policies.md)
- [流水线执行策略](../policies/pipeline_execution_policies.md)

这些方法都允许将 CI/CD 配置（包括安全扫描）定义一次，并应用于多个项目和群组。与逐个配置每个项目相比，这些方法具有多项优势，包括：

- 配置更改只需执行一次，而无需为每个项目分别执行。
- 进行配置更改的权限受到限制，从而实现职责分离。

<a id="customize-security-scanning"></a>

## 自定义安全扫描

您可以根据自己的需求和环境自定义安全扫描。有关如何自定义单个安全扫描器的详细信息，请参阅其文档。

<a id="best-practices"></a>

### 最佳实践

自定义安全扫描配置时：

- 在将更改合并到默认分支之前，使用合并请求测试安全扫描工具的所有自定义设置。否则可能会产生意外结果，包括大量误报。
- [包含](../../../ci/yaml/_index.md#include)扫描工具的 CI/CD 模板。不要复制模板的内容。
- 仅在需要时覆盖模板中的值。所有其他值均从模板继承。
- 在生产工作流中使用每个模板的稳定版。稳定版变更频率较低，破坏性变更仅在极狐GitLab 主要版本之间进行。最新版包含最新的更改，但在极狐GitLab 次要版本之间可能有重大变更。

<a id="template-editions"></a>

### 模板版本

极狐GitLab 应用安全工具最多有三种模板版本：

- **稳定版**：稳定版模板是默认版本。它提供可靠且一致的应用安全体验。对于大多数用户以及需要在 CI/CD 流水线中保持稳定性和可预测行为的项目，您应使用稳定版模板。
- **最新版**：最新版模板适用于希望访问和测试前沿功能的用户。它通过模板名称中的 `latest` 一词来标识。它不被视为稳定版，可能包含计划在下一个主要版本中发布的破坏性变更。此模板允许您在稳定版发布之前试用新功能和更新。
- **版本化**：版本化模板引入了与稳定版模板不向后兼容的破坏性变更。版本化模板在模板名称中带有版本后缀（如 `v2`、`v3`）。每个版本在其主要版本内是稳定的，但由于存在破坏性变更，您必须选择启用才能采用。只有依赖扫描提供版本化模板（`Dependency-Scanning.v2.gitlab-ci.yml`），它运行
  [使用 SBOM 的依赖扫描](../dependency_scanning/dependency_scanning_sbom/_index.md)。有关
  更多信息，请参阅
  [迁移指南](../dependency_scanning/migration_guide_to_sbom_based_scans.md)。

> [!note]
> 不要在同一项目中混用**稳定版**和**最新版**安全模板。混用不同的安全模板版本可能导致
> 合并请求和分支流水线同时运行。

<a id="override-the-default-registry-base-address"></a>

### 覆盖默认的镜像仓库基础地址

默认情况下，极狐GitLab 安全扫描器使用 `registry.gitlab.com/security-products` 作为 Docker 镜像的基础地址。您可以通过将 CI/CD 变量 `SECURE_ANALYZERS_PREFIX` 设置为其他位置，为大多数扫描器覆盖此地址。这会影响所有扫描器。

[容器扫描](../container_scanning/_index.md)分析器是一个例外，它不使用 `SECURE_ANALYZERS_PREFIX` 变量。要覆盖其 Docker 镜像，请参阅[在离线环境中运行容器扫描](../container_scanning/_index.md#offline-environment)的说明。

<a id="use-security-scanning-tools-with-merge-request-pipelines"></a>

### 在合并请求流水线中使用安全扫描工具

默认情况下，应用安全作业配置为仅针对分支流水线运行。要将它们与[合并请求流水线](../../../ci/pipelines/merge_request_pipelines.md)一起使用，您可以：

- 将 CI/CD 变量 `AST_ENABLE_MR_PIPELINES` 设置为 `"true"`（[在 18.0 中引入](https://gitlab.com/gitlab-org/gitlab/-/issues/410880)）（推荐）
- 使用 [`latest` 版本模板](#template-editions)，它默认启用合并请求流水线。

例如，要在启用合并请求流水线的情况下同时运行 SAST 和依赖扫描，可使用以下配置：

```yaml
include:
  - template: Jobs/Dependency-Scanning.v2.gitlab-ci.yml
  - template: Jobs/SAST.gitlab-ci.yml

variables:
  AST_ENABLE_MR_PIPELINES: "true"
```

<a id="use-a-custom-scanning-stage"></a>

### 使用自定义扫描阶段

安全扫描器模板默认使用预定义的 `test` 阶段。要让它们改为在其他阶段运行，请将自定义阶段的名称添加到 `.gitlab-ci.yml` 文件的 `stages:` 部分。

有关覆盖安全作业的更多信息，请参阅：

- [覆盖 SAST 作业](../sast/_index.md#override-sast-jobs)。
- [覆盖依赖扫描作业](../dependency_scanning/dependency_scanning_sbom/_index.md#customizing-analyzer-behavior)。
- [覆盖容器扫描作业](../container_scanning/_index.md#overriding-the-container-scanning-template)。
- [覆盖密钥检测作业](../secret_detection/pipeline/configure.md)。
- [覆盖 DAST 作业](../dast/browser/_index.md)。

<a id="troubleshooting"></a>

## 故障排除

配置安全扫描时，您可能会遇到以下问题。

<a id="error-chosen-stage-test-does-not-exist"></a>

### 错误：`chosen stage test does not exist`

运行流水线时，您可能会收到错误 `chosen stage test does not exist`。

当安全扫描作业使用的阶段未在 `.gitlab-ci.yml` 文件中声明时，会出现此问题。

要解决此问题，您可以：

- 在您的 `.gitlab-ci.yml`中添加一个 `test` 阶段：

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

- 覆盖每个安全作业的默认阶段。例如，要使用名为 `unit-tests`的预定义阶段：

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
