---
stage: Application Security Testing
group: Static Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: IaC 扫描
description: 漏洞检测、配置分析和流水线集成。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

IaC 扫描在 CI/CD 流水线中运行，检查基础设施定义文件中已知的漏洞。在漏洞被提交到默认分支之前识别它们，以便主动应对应用程序的风险。

IaC 扫描分析器会输出 JSON 格式的报告作为[作业产物](../../../ci/yaml/artifacts_reports.md#artifactsreportssast)。

在极狐GitLab 旗舰版中，IaC 扫描结果还会被进一步处理，因此你可以：

- 在合并请求中查看它们。
- 在审批工作流中使用它们。
- 在漏洞报告中审查它们。

<a id="getting-started"></a>

## 快速入门

如果你是 IaC 扫描的新手，请按照以下步骤为你的项目启用它。

先决条件：

- 项目的维护者或所有者角色。
- 至少 4 GB RAM 以确保稳定的性能。
- 基于 Linux 且使用 Docker 或 Kubernetes 执行器的极狐GitLab Runner。如果你在 JihuLab.com 上使用托管级 Runner，默认已经启用了 Docker 或 Kubernetes 执行器。
  - 不支持 Windows 上的极狐GitLab Runner。
  - 不支持 AMD64 以外的 CPU 架构。
- 极狐GitLab CI/CD 配置文件（`.gitlab-ci.yml`）必须包含 `test` 阶段。`test` 阶段默认已包含，但如果你重新定义了阶段，必须显式添加它。

要启用 IaC 扫描：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 进入 **构建** > **流水线编辑器**。
1. 添加 IaC 扫描 CI/CD 模板或组件。

   要使用模板，请添加以下行：

   ```yaml
   include:
     - template: Jobs/SAST-IaC.gitlab-ci.yml
   ```

   要使用 CI/CD 组件，请添加以下行：

   ```yaml
   include:
     - component: gitlab.com/components/sast/iac-sast@main
   ```

1. 选择 **验证** 选项卡，然后选择 **验证流水线**。

   消息 **模拟成功完成** 表示文件有效。
1. 选择 **编辑** 选项卡。
1. 填写字段：
   - 提交消息。
   - 分支。例如 `add-iac`。
1. 选中 **使用这些更改创建新合并请求** 复选框，然后选择 **提交更改**。

   合并请求页面将打开。
1. 按照你标准的工作流程填写字段，然后选择 **创建合并请求**。
1. 按照你标准的工作流程审查和编辑合并请求，然后选择 **合并**。

此时，IaC 扫描已在你的流水线中启用：

- IaC 扫描作业在每个流水线中运行，并执行 KICS 分析器。
- 分析器会判断项目是否包含受支持的 IaC 文件。
- 如果找到受支持的文件，分析器将扫描漏洞。
- 如果没有找到受支持的文件，作业会完成但无发现结果。

相应的作业会出现在流水线的 `test` 阶段下。

你可以在 [IaC 扫描示例项目](https://jihulab.com/gitlab-cn/security-products/demos/analyzer-configurations/kics/iac-getting-started) 中查看一个实际示例。

### 后续步骤

启用 IaC 扫描之后，你可以：

- 详细了解如何[理解结果](#understanding-the-results)
- 查看[优化提示](#optimize-iac-scanning)
- 制定[向更多项目推广的计划](#roll-out)

<a id="understanding-the-results"></a>

## 理解结果

先决条件：

- 项目的安全经理、开发者、维护者或所有者角色。

你可以在流水线中审查漏洞：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **构建** > **流水线**。
1. 选择流水线。
1. 选择 **安全** 选项卡。
1. 选择一个漏洞以查看其详细信息，包括：
   - 描述：解释漏洞的原因、潜在影响以及建议的修复步骤。
   - 状态：表明漏洞是否已被分类或已解决。
   - 严重性：[了解有关严重性级别的更多信息](../vulnerabilities/severities.md)。
   - 位置：显示发现问题的文件名和行号。选择文件路径将在代码视图中打开对应的行。
   - 扫描器：标识检测到漏洞的分析器。
   - 标识符：用于分类漏洞的一系列参考信息，例如 CWE 标识符和检测到该漏洞的规则 ID。

在旗舰版中，你还可以下载安全扫描结果：

先决条件：

- 项目的安全经理、开发者、维护者或所有者角色。

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **构建** > **流水线**。
1. 选择流水线。
1. 选择 **安全** 选项卡。
1. 在流水线的 **安全** 选项卡中，选择 **下载结果**。

有关更多详细信息，请参阅[流水线安全报告](../detect/security_scanning_results.md)。

> [!note]
> 发现结果是在功能分支上生成的。当它们被合并到默认分支时，就会变为漏洞。在评估你的安全态势时，这一区别很重要。

查看 IaC 扫描结果的其他方式：

- [合并请求部件](../sast/_index.md#merge-request-widget)：显示新引入或已解决的发现结果。
- [合并请求变更视图](../sast/_index.md#merge-request-changes-view)：在发生变更的行上显示内联注释。
- [漏洞报告](../vulnerability_report/_index.md)：显示默认分支上已确认的漏洞。

<a id="supported-languages-and-frameworks"></a>

## 支持的语言和框架

IaC 扫描支持多种 IaC 配置文件。当项目中检测到任何受支持的配置文件时，将使用 [KICS](https://kics.io/) 进行扫描。混合多种 IaC 配置文件的项目也受支持。

受支持的配置格式：

- Ansible
- AWS CloudFormation
- Azure Resource Manager

  > [!note]
  > IaC 扫描可以分析 JSON 格式的 Azure Resource Manager 模板。如果你使用 [Bicep](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/overview) 编写模板，则必须使用 [Bicep CLI](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/bicep-cli) 将 Bicep 文件转换为 JSON 后，IaC 扫描才能对其进行分析。

- Dockerfile
- Google Deployment Manager
- Kubernetes
- OpenAPI
- Terraform

  > [!note]
  > 自定义注册表中的 Terraform 模块不会进行漏洞扫描。

<a id="optimize-iac-scanning"></a>

## 优化 IaC 扫描

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

你可以优化 IaC 扫描以减少噪音并专注于相关发现结果：

- 使用 `sast-ruleset.toml` 文件禁用特定规则。
- 使用 `sast-ruleset.toml` 文件覆盖规则属性（如严重性）。
- 在这些文件中使用 KICS 注释来禁用对特定文件的扫描。

使用 `sast-ruleset.toml` 文件来禁用规则或覆盖规则属性。这种方法具有以下优点：

- 与极狐GitLab 漏洞管理集成，当规则被禁用时，可自动解决现有发现结果。
- 对你的安全策略决策进行版本控制的文档记录。
- 在推广 IaC 扫描时，可以选择跨多个项目共享规则集。

### 规则集定义

每个 IaC 扫描规则都包含在一个 `ruleset` 部分中，该部分包含以下内容：

- 规则的 `type` 字段。对于 IaC 扫描，标识符类型是 `kics_id`。
- 规则标识符的 `value` 字段。KICS 规则标识符是字母数字字符串。要查找规则标识符：
  - 在 [JSON 报告产物](#reports-json-format) 中找到它。
  - 在 [KICS 查询列表](https://docs.kics.io/latest/queries/all-queries/) 中搜索规则名称，并复制显示的字母数字标识符。当检测到违反规则时，规则名称会显示在[漏洞详细信息页面](../vulnerabilities/_index.md)上。

### 禁用规则

你可以禁用特定的 IaC 扫描规则。之前由已禁用规则检测到的发现结果将被[自动解决](#automatic-vulnerability-resolution)。

先决条件：

- 项目的维护者或所有者角色。

要禁用分析器规则：

1. 如果尚不存在，请在项目根目录下创建一个 `.gitlab` 目录。
1. 如果尚不存在，请在 `.gitlab` 目录中创建一个名为 `sast-ruleset.toml` 的自定义规则集文件。
1. 在 `ruleset` 部分的上下文中，将 `disabled` 标志设置为 `true`。
1. 在一个或多个 `ruleset` 子部分中，列出要禁用的规则。

在将 `sast-ruleset.toml` 文件合并到默认分支后，已禁用规则的现有发现结果将被[自动解决](#automatic-vulnerability-resolution)。

例如，在以下 `sast-ruleset.toml` 文件中，通过匹配标识符的 `type` 和 `value`，将禁用的规则分配给 `kics` 分析器：

```toml
[kics]
  [[kics.ruleset]]
    disable = true
    [kics.ruleset.identifier]
      type = "kics_id"
      value = "8212e2d7-e683-49bc-bf78-d6799075c5a7"

  [[kics.ruleset]]
    disable = true
    [kics.ruleset.identifier]
      type = "kics_id"
      value = "b03a748a-542d-44f4-bb86-9199ab4fd2d5"
```

### 禁用对文件的扫描

要完全禁用一个文件或仅对某个规则禁用扫描，请在该文件中使用
[KICS 注释](https://docs.kics.io/latest/running-kics/#using_commands_on_scanned_files_as_comments)。

此功能仅适用于某些类型的 IaC 文件。有关受支持文件类型的列表，请参阅 [KICS 文档](https://docs.kics.io/latest/running-kics/#using_commands_on_scanned_files_as_comments)。

- 要跳过对整个文件的扫描，请在文件顶部添加 `# kics-scan ignore` 作为注释。
- 要禁用在整个文件中的特定规则，请在文件顶部添加 `# kics-scan disable=<kics_id>` 作为注释。

### 覆盖规则

你可以覆盖特定的 IaC 扫描规则以进行自定义。例如，为规则分配较低的严重性，或者链接到你自己的关于如何修复某个发现结果的文档。

先决条件：

- 项目的维护者或所有者角色。

要覆盖规则：

1. 如果尚不存在，请在项目根目录下创建一个 `.gitlab` 目录。
1. 如果尚不存在，请在 `.gitlab` 目录中创建一个名为 `sast-ruleset.toml` 的自定义规则集文件。
1. 在一个或多个 `ruleset.identifier` 子部分中，列出要覆盖的规则。
1. 在 `ruleset` 部分的 `ruleset.override` 上下文中，提供要覆盖的键。可以覆盖任意组合的键。有效的键包括：
   - description
   - message
   - name
   - severity（有效选项为：Critical、High、Medium、Low、Unknown、Info）

例如，在以下 `sast-ruleset.toml` 文件中，通过标识符的 `type` 和 `value` 匹配规则，然后进行覆盖：

```toml
[kics]
  [[kics.ruleset]]
    [kics.ruleset.identifier]
      type = "kics_id"
      value = "8212e2d7-e683-49bc-bf78-d6799075c5a7"
    [kics.ruleset.override]
      description = "被覆盖的描述"
      message = "被覆盖的消息"
      name = "被覆盖的名称"
      severity = "Info"
```

<a id="offline-configuration"></a>

## 离线配置

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

离线环境对通过互联网访问外部资源具有有限、受限或间歇性的访问权限。对于此类环境中的实例，IaC 扫描需要进行一些配置更改。本节中的说明必须与[离线环境](../offline_deployments/_index.md)中的说明一起完成。

### 配置极狐GitLab Runner

默认情况下，Runner 会尝试从极狐GitLab 容器镜像仓库拉取 Docker 镜像，即使本地已有副本。你应该使用此默认设置，以确保 Docker 镜像保持最新。但是，如果没有网络连接可用，你必须更改默认的极狐GitLab Runner `pull_policy` 变量。

将极狐GitLab Runner 的 CI/CD 变量 `pull_policy` 配置为 [`if-not-present`](https://docs.gitlab.com/runner/executors/docker/#using-the-if-not-present-pull-policy)。

### 使用本地 IaC 分析器镜像

如果你想从本地 Docker 注册表而不是极狐GitLab 容器镜像仓库获取镜像，请使用本地 IaC 分析器镜像。

先决条件：

- 项目的维护者或所有者角色。
- 导入 Docker 镜像到本地离线 Docker 注册表取决于你的网络安全策略。请咨询你的 IT 人员以找到可接受的批准流程来导入或临时访问外部资源。

要使用本地 IaC 分析器镜像：

1. 将默认的 IaC 分析器镜像从 `registry.gitlab.com` 导入到你的[本地 Docker 容器镜像仓库](../../packages/container_registry/_index.md)：

   ```plaintext
   registry.gitlab.com/security-products/kics:6
   ```

   IaC 分析器的镜像是[定期更新](../detect/vulnerability_scanner_maintenance.md)的，因此你应该定期更新本地副本。

1. 将 CI/CD 变量 `SECURE_ANALYZERS_PREFIX` 设置为本地 Docker 容器镜像仓库。

   ```yaml
   include:
     - template: Jobs/SAST-IaC.gitlab-ci.yml

   variables:
     SECURE_ANALYZERS_PREFIX: "localhost:5000/analyzers"
   ```

现在，IaC 作业应该使用分析器 Docker 镜像的本地副本，而无需互联网访问。

<a id="use-a-specific-analyzer-version"></a>

## 使用特定版本的分析器

极狐GitLab 管理的 CI/CD 模板指定了一个主要版本，并自动拉取该主要版本中最新发布的分析器。在某些情况下，您可能需要使用特定版本。例如，您可能需要避免之后版本中的回归问题。

先决条件：

- 项目的维护者或所有者角色。

要使用特定版本的分析器：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **构建** > **流水线编辑器**。
1. 在包含 `SAST-IaC.gitlab-ci.yml` 模板的行之后，添加 `SAST_ANALYZER_IMAGE_TAG` CI/CD 变量。

   > [!note]
   > 仅在特定作业中设置此变量。如果在顶层设置，你设置的版本将用于其他 SAST 分析器。

   将标签设置为：

   - 一个主要版本，例如 `3`。你的流水线将使用该主要版本中发布的任何次要或补丁更新。
   - 一个次要版本，例如 `3.7`。你的流水线将使用该次要版本中发布的任何补丁更新。
   - 一个补丁版本，例如 `3.7.0`。你的流水线将不接收任何更新。

此示例使用 IaC 分析器的特定次要版本：

```yaml
include:
  - template: Jobs/SAST-IaC.gitlab-ci.yml

kics-iac-sast:
  variables:
    SAST_ANALYZER_IMAGE_TAG: "3.1"
```

<a id="supported-distributions"></a>

## 支持的发行版

极狐GitLab 扫描器基于 Alpine 基础镜像构建，以保持体积小且易于维护。

### 使用启用 FIPS 的镜像

除了标准镜像外，极狐GitLab 还提供[启用 FIPS 的 Red Hat UBI](https://www.redhat.com/en/blog/introducing-red-hat-universal-base-image) 版本的扫描器镜像。

要在流水线中使用启用 FIPS 的镜像，请将 `SAST_IMAGE_SUFFIX` 设置为 `-fips`，或修改标准标签加上 `-fips` 扩展名。

以下示例使用 `SAST_IMAGE_SUFFIX` CI/CD 变量。

```yaml
variables:
  SAST_IMAGE_SUFFIX: '-fips'

include:
  - template: Jobs/SAST-IaC.gitlab-ci.yml
```

<a id="automatic-vulnerability-resolution"></a>

## 自动漏洞解决

{{< history >}}

- 在极狐GitLab 15.9 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/368284)，配置了名为 `sec_mark_dropped_findings_as_resolved` 的项目级功能标志。
- 于极狐GitLab 16.2 [正式发布](https://gitlab.com/gitlab-org/gitlab/-/issues/375128)。功能标志 `sec_mark_dropped_findings_as_resolved` 被移除。

{{< /history >}}

为了帮助你专注于仍然相关的漏洞，在以下情况下，IaC 扫描会自动[解决](../vulnerabilities/_index.md#vulnerability-status-values)漏洞：

- 你[禁用了一个预定义规则](#disable-rules)。
- 我们从默认规则集中移除了一个规则。

如果你稍后重新启用该规则，这些发现结果将重新开放以供分类。

漏洞管理系统在自动解决漏洞时会添加一条备注。

<a id="reports-json-format"></a>

## 报告 JSON 格式

IaC 扫描器会按照现有的 SAST 报告格式输出 JSON 报告文件。有关更多信息，请参阅此报告的[模式](https://gitlab.com/gitlab-org/security-products/security-report-schemas/-/blob/master/dist/sast-report-format.json)。

JSON 报告文件可以从以下位置下载：

- CI/CD 流水线页面。
- 合并请求的流水线选项卡，通过[设置 `artifacts: paths`](../../../ci/yaml/_index.md#artifactspaths) 为 `gl-sast-report.json`。

有关更多信息，请参阅[下载产物](../../../ci/jobs/job_artifacts.md)。

<a id="roll-out"></a>

## 推广

在为一个项目验证了 IaC 扫描结果后，你可以在其他项目上采用相同的方法。

- 使用[强制扫描执行](../detect/security_configuration.md#create-a-shared-configuration)在群组中应用 IaC 扫描设置。
- 通过[指定远程配置文件](../sast/customize_rulesets.md#use-a-remote-ruleset-file)来共享和重用中央规则集。

<a id="troubleshooting"></a>

## 故障排除

在使用 IaC 扫描时，你可能会遇到以下问题。

### IaC 扫描发现结果意外显示为 `不再检测到`

如果之前检测到的发现结果意外显示为 `不再检测到`，可能是因为扫描器更新。更新可能会禁用那些被发现无效或误报的规则，然后这些发现结果会标记为 `不再检测到`。

### 作业日志中的 `exec /bin/sh: exec format error` 消息

你可能会在作业日志中看到 `exec /bin/sh: exec format error` 的错误。当你尝试在 AMD64 以外的架构上运行 IaC 扫描分析器时，会出现此问题。有关 IaC 扫描的先决条件详情，请参阅[先决条件](#getting-started)。