---
stage: Release Notes
group: Monthly Release
date: 2025-09-18
title: "极狐GitLab 18.4 发布说明"
description: "极狐GitLab 18.4 发布，极狐GitLab Duo 模型选择功能现已正式可用"
---

<!-- markdownlint-disable -->
<!-- vale off -->

2025 年 9 月 18 日，极狐GitLab 18.4 正式发布，带来了以下新功能。

<a id="primary-features"></a>

## 主要功能

<a id="gitlab-duo-model-selection-now-generally-available"></a>

### 极狐GitLab Duo 模型选择功能现已正式可用

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Add-ons: Duo Core, Duo Pro, Duo Enterprise
- Links: [文档](../../user/gitlab_duo/model_selection.md#select-a-model-for-a-feature)

{{< /details >}}

极狐GitLab Duo 模型选择功能现已正式可用，让组织能够更好地控制哪些 AI 模型为其开发工作流提供支持。

JihuLab.com 上顶级群组的所有者以及私有化部署的管理员现在可以从各种极狐GitLab AI 模型供应商中选择一个特定模型，用于其极狐GitLab Duo 功能，并通过极狐GitLab 托管的 AI 网关进行访问。

隶属于 JihuLab.com 上多个命名空间的极狐GitLab 用户现在还可以设置一个默认命名空间，以确保在所有开发环境中保持一致的 AI 模型偏好。有关极狐GitLab Duo 模型选择的更多信息，请[阅读博客](https://about.gitlab.com/blog/speed-meets-governance-model-selection-comes-to-gitlab-duo/)。

<a id="gitlab-knowledge-graph"></a>

### 极狐GitLab 知识图谱

{{< details >}}

- Tier: 免费版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](https://gitlab-org.gitlab.io/rust/knowledge-graph/)

{{< /details >}}

极狐GitLab 知识图谱在你的代码库中提供了丰富的代码智能。开发者可以在更具上下文的情况下理解和导航他们的项目，从而更轻松地规划变更、执行影响分析，并与极狐GitLab Duo Agent 协作，加速开发任务。

极狐GitLab Duo Agent Platform 利用知识图谱来提高 AI Agent 的准确性。通过映射代码库中的文件和定义，知识图谱提供了增强的上下文，使 Duo Agent 能够理解你整个本地工作空间中的关系，从而更快、更精确地响应复杂问题。

此版本的知识图谱专注于本地代码索引，命令行工具 (CLI) 将你的代码库转换为一个动态的、可嵌入的图数据库，用于 RAG。你可以使用简单的一行脚本安装它，解析本地仓库，并通过 MCP 连接来查询你的工作空间。

我们对知识图谱项目的愿景分为两步：构建一个充满活力的基础版，开发者今天就可以在本地运行，这将作为未来在 JihuLab.com 和私有化部署实例中完全集成的知识图谱服务的基础。

此功能处于测试状态。请在[议题 160](https://gitlab.com/gitlab-org/rust/knowledge-graph/-/issues/160) 中提供反馈。

<a id="end-user-model-selection-now-available-with-gitlab-duo"></a>

### 极狐GitLab Duo 现已支持最终用户模型选择

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Add-ons: Duo Core, Duo Pro, Duo Enterprise
- Links: [文档](../../user/gitlab_duo/model_selection.md#select-a-model-for-a-feature)

{{< /details >}}

针对最终用户的极狐GitLab Duo 模型选择功能现已在 JihuLab.com 上开放公开测试。用户现在可以直接在极狐GitLab UI 中为极狐GitLab Duo Agentic Chat 选择其偏好的模型，使开发者能够个性化地控制他们的 AI 辅助体验。

当 JihuLab.com 上的命名空间所有者允许时，最终用户可以从可用的极狐GitLab AI 供应商模型中进行选择，用于极狐GitLab Duo Agentic Chat。命名空间所有者可以继续通过命名空间设置来设定组织范围的模型偏好，或者允许最终用户自行选择模型。

要开始使用，请在极狐GitLab Duo Agentic Chat 中查找模型下拉菜单，以选择你的首选模型。请注意，更改模型将启动一个新的会话，并且你的偏好会被记住，以供将来会话使用。

<a id="cicd-job-tokens-can-authenticate-git-push-requests"></a>

### CI/CD 作业令牌可认证 Git Push 请求

{{< details >}}

- Tier: 免费版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../ci/jobs/ci_job_token.md#allow-git-push-requests-to-your-project-repository)

{{< /details >}}

你现在可以允许在项目中生成的 CI/CD 作业令牌向该项目的代码仓认证 Git Push 请求。
你可以通过 UI 中的作业令牌权限设置来启用此功能，或者使用项目 API 端点中的 `[ci_push_repository_for_job_token_allowed](../../api/projects.md#edit-a-project)` 参数来启用此功能。

<a id="gitlab-duo-context-exclusion"></a>

### 极狐GitLab Duo 上下文排除

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Add-ons: Duo Pro, Duo Enterprise
- Links: [文档](../../user/gitlab_duo/context.md#exclude-context-from-code-review)

{{< /details >}}

极狐GitLab Duo 上下文排除功能允许你控制哪些项目内容被排除作为极狐GitLab Duo 的上下文。这有助于保护敏感信息，例如密码文件和配置文件。你可以排除单个文件、特定目录、特定文件类型，或者这些的任意组合。

此功能目前处于测试阶段。请在[议题 566244](https://gitlab.com/gitlab-org/gitlab/-/issues/566244) 中提供有关极狐GitLab Duo 上下文排除的反馈。

<a id="simulate-cicd-pipelines-against-different-branch"></a>

### 针对不同分支模拟 CI/CD 流水线

{{< details >}}

- Tier: 免费版，专业版，旗舰版
- Offering: GitLab Dedicated
- Links: [文档](../../ci/pipeline_editor/_index.md#validate-cicd-configuration)

{{< /details >}}

此前，在使用流水线编辑器并通过 **Validate** 标签页验证你的更改时，你只能针对默认分支运行模拟。在此版本中，我们扩展了此功能。你现在可以选择任何分支来模拟流水线。这项改进让你能够更灵活地测试和验证你的流水线。你可以确保它们在不同情况下（包括你的稳定分支或功能分支）都能按预期工作。

<a id="agentic-core"></a>

## Agentic 核心

<a id="automatic-duo-code-review-for-groups-and-applications"></a>

### 针对群组和应用的自动 Duo 代码审核

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Add-ons: Duo Enterprise
- Links: [文档](../../user/project/merge_requests/duo_in_merge_requests.md)

{{< /details >}}

你现在可以使用群组或应用程序设置为多个项目启用自动 Duo 代码审核。这可以帮助你快速为群组中的所有项目启用 Duo 代码审核，而不是逐个启用特定项目。

此功能目前仅在 JihuLab.com 上可用，我们计划在未来的版本中将其提供给极狐GitLab 私有化部署。请在[议题 517386](https://gitlab.com/gitlab-org/gitlab/-/issues/517386) 中提供反馈。

<a id="additional-supported-models-for-gitlab-duo-self-hosted"></a>

### 极狐GitLab Duo 自托管版支持更多模型

{{< details >}}

- Tier: 专业版，旗舰版
- Add-ons: Duo Enterprise
- Links: [文档](../../administration/gitlab_duo_self_hosted/supported_models_and_hardware_requirements.md#supported-models)

{{< /details >}}

拥有极狐GitLab Duo Enterprise 的极狐GitLab 私有化部署客户现在可以使用更多受支持的模型与极狐GitLab Duo 配合使用。
现在，Azure OpenAI 支持国内 SOTA 大模型。vLLM 和 Azure OpenAI 也支持开源国内 SOTA 大模型 20B 和 120B。
如需就使用这些模型与极狐GitLab Duo Self-Hosted 反馈意见，请参阅[议题 523918](https://gitlab.com/gitlab-org/gitlab/-/issues/523918)。

<a id="duo-code-review-on-gitlab-duo-self-hosted-is-generally-available"></a>

### 极狐GitLab Duo Self-Hosted 上的 Duo 代码审核现已正式可用

{{< details >}}

- Tier: 专业版，旗舰版
- Add-ons: Duo Enterprise
- Links: [文档](../../administration/gitlab_duo_self_hosted/_index.md#gitlab-duo)

{{< /details >}}

极狐GitLab Duo Self-Hosted 上的极狐GitLab Duo 代码审核现已正式可用。使用极狐GitLab Duo Self-Hosted 上的代码审核，可以在不影响数据主权的情况下加速你的开发流程。当代码审核检查你的合并请求时，它会识别潜在的错误并建议你直接应用的改进。在请求人工审核之前，使用代码审核来迭代和改进你的更改。此功能支持 Mistral、Meta Llama 和国内 SOTA 大模型系列。

请在[议题 517386](https://gitlab.com/gitlab-org/gitlab/-/issues/517386) 中提供对代码审核的反馈。

<a id="unified-devops-and-security"></a>

## 统一 DevOps 与安全

<a id="pipeline-secret-detection-now-excludes-certain-files-and-directories-by-default"></a>

### 流水线密钥检测现默认排除特定文件和目录

{{< details >}}

- Tier: 免费版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/secret_detection/pipeline/_index.md#excluded-items)

{{< /details >}}

流水线密钥检测现在会自动排除[特定文件类型和目录](../../user/application_security/secret_detection/pipeline/_index.md#excluded-items)，如果它们包含密钥的可能性很低，从而提高扫描性能。这些变更已在分析器[版本 7.11.0](https://gitlab.com/gitlab-org/security-products/analyzers/secrets/-/releases/v7.11.0) 中发布。

<a id="secret-detection-analyzer-git-fetching-improvements"></a>

### 密钥检测分析器 Git 获取改进

{{< details >}}

- Tier: 免费版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/secret_detection/pipeline/_index.md#how-the-analyzer-fetches-commits)

{{< /details >}}

密钥检测分析器版本 [7.12.0](https://gitlab.com/gitlab-org/security-products/analyzers/secrets/-/releases/v[7.12.0](https://gitlab.com/gitlab-org/security-products/analyzers/secrets/-/releases/v7.12.0)) 对 Git 提交的获取方式进行了显著改进。分析器现在会解析从 `SECRET_DETECTION_LOG_OPTIONS` 传入的 `--depth` 和 `--since` 选项，因此你可以进一步指定要扫描的提交数量。分析器还会根据上下文选择合适的获取策略，这防止了一个已知问题，即即使配置了浅层深度，也可能不必要地获取数百万个提交。

这项增强减少了作业超时，降低了资源消耗，并提供了更可预测的扫描性能。体验更快的密钥检测扫描，尤其是在大型仓库中，并提供与实际获取行为相匹配的更清晰的日志。

<a id="significantly-faster-advanced-sast-scanning"></a>

### 显著加快的高级 SAST 扫描

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/sast/gitlab_advanced_sast.md)

{{< /details >}}

当你在合并请求和流水线中启用安全扫描时，每一分钟都很重要。
我们定期发布高级 SAST 的性能改进，目标既包括引擎也包括其检测规则。

在此版本中，我们重点介绍一项特定改进，该改进在我们的基准测试和实际测试中将扫描运行时间缩短了多达 78%。
我们在扫描过程中对性能敏感的部分增加了缓存，从而显著加快了大型仓库的扫描速度。

此改进在高级 SAST 分析器版本 2.9.6 及更高版本中自动启用。
你可以通过[检查扫描作业日志](../../user/application_security/sast/gitlab_advanced_sast.md)来查看你正在使用的分析器版本。

<a id="operational-container-scanning-severity-threshold-configuration"></a>

### 运维容器扫描严重性阈值配置

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/clusters/agent/vulnerabilities.md#configure-trivy-severity-threshold-filter)

{{< /details >}}

你现在可以配置运维容器扫描 (OCS) 仅返回达到或超过某个严重性级别的漏洞。
设置严重性阈值后，低于所选严重性的漏洞将不再在漏洞报告、API 有效负载和其他报告机制中返回。
这可以帮助你专注于你想要修复的漏洞。

要启用此过滤，请在 OCS 配置中[设置 `severity_threshold`](../../user/clusters/agent/vulnerabilities.md#configure-trivy-severity-threshold-filter)。

我们非常感谢来自 [John Walsh](https://gitlab.com/mjohnw) 的社区贡献。
要了解更多关于为极狐GitLab 做贡献的信息，请查看[社区贡献计划](https://about.gitlab.com/community/contribute/)。

<a id="publish-opentofu-modules-and-providers-to-the-gitlab-container-registry-with-cicd-templates"></a>

### 使用 CI/CD 模板将 OpenTofu 模块和 providers 发布到极狐GitLab 容器镜像仓库

{{< details >}}

- Tier: 免费版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](https://gitlab.com/components/opentofu#publish-providers-to-the-gitlab-oci-registry)

{{< /details >}}

极狐GitLab 容器镜像仓库现在支持托管 OpenTofu 模块和 providers 的媒体类型。

[OpenTofu CI/CD 组件](https://gitlab.com/components/opentofu)的版本 [3.1.0](https://gitlab.com/components/opentofu/-/releases/[3.1.0](https://gitlab.com/components/opentofu/-/releases/3.1.0)) 支持一个新的 `provider-release` 模板，使用 OCI 格式将 OpenTofu provider 部署到极狐GitLab 镜像仓库中。现在，你可以直接在极狐GitLab 中托管私有的 OpenTofu providers。

此外，`module-release` 模板现在还支持一个新的 `type` 输入，你可以将其设置为 `oci`，以使用 OCI 格式将 OpenTofu 模块部署到极狐GitLab 镜像仓库中。

<a id="bypass-confirmation-for-enterprise-users-when-reassigning-placeholders"></a>

### 重新分配占位符时绕过企业用户确认

{{< details >}}

- Tier: Silver, Gold
- Offering: JihuLab.com
- Links: [文档](../../user/import/mapping/reassignment.md#bypass-confirmation-when-reassigning-placeholder-users)

{{< /details >}}

具有群组所有者角色的用户现在可以在将占位符重新分配给该群组中的活跃企业用户时绕过用户确认。这样，企业用户就不必一直检查电子邮件以确认重新分配。在设置的时间限制过后，对所有新的重新分配将再次发送电子邮件确认请求。

重新分配完成后，企业用户仍会收到通知邮件，确保整个过程透明。

<a id="configure-how-to-view-issues-from-the-issues-page"></a>

### 配置如何从议题页面查看议题

{{< details >}}

- Tier: 免费版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/issues/managing_issues.md#open-issues-in-a-panel)

{{< /details >}}

你现在可以完全控制列表页面的视图，选择显示哪些元数据以及是否在抽屉中打开工作项，从而更容易专注于对你最重要的信息。

此前，所有元数据字段始终可见，这可能会使浏览工作项变得难以招架。现在，你可以通过打开或关闭特定字段（如指派人、标签、日期和里程碑）来自定义你的视图。

使用新的切换开关在抽屉视图和全页导航之间切换，你可以在保持列表上下文的同时快速查看详细信息，或者在需要更多屏幕空间进行详细编辑和全面导航时打开完整页面。

<a id="enhanced-parent-filtering-for-epic-and-issue-lists"></a>

### 为史诗和议题列表增强的父级过滤

{{< details >}}

- Tier: 免费版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/issues/_index.md)

{{< /details >}}

我们已将议题和史诗页面上的“史诗”过滤器替换为更灵活的“父级”过滤器。此更改允许你按任何父工作项进行过滤，而不仅仅是史诗。你现在可以轻松地通过父议题过滤来查找子任务，或通过父史诗过滤来查找议题，从而让你在议题和史诗列表中更好地了解你的工作层次结构。

<a id="issue-boards-now-show-complete-epic-hierarchies"></a>

### 议题板现在显示完整的史诗层次结构

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/issue_board.md#filter-issues)

{{< /details >}}

当你在议题板中按父史诗过滤时，现在可以查看来自子史诗的所有议题，这与议题页面的现有工作方式保持一致。这项改进有助于你更好地跟踪和可视化完整的史诗层次结构，而不会遗漏嵌套在子史诗中的任何议题，从而使你的项目管理工作流更高效、更可靠。

<a id="text-editors-toolbar-parity"></a>

### 文本编辑器工具栏统一

{{< details >}}

- Tier: 免费版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/rich_text_editor.md)

{{< /details >}}

极狐GitLab 纯文本编辑器现在包含与富文本编辑器相同的格式选项。纯文本编辑器工具栏已更新，增加了一个 **更多选项** 菜单，可访问高级格式化工具，例如：

- 代码块
- 详情块
- 水平分割线
- Mermaid 图表
- PlantUML 图表
- 目录

两个编辑器现在具有一致的按钮位置和分隔符，使得在编辑模式之间切换更容易，同时保持对熟悉的格式选项的访问。

<a id="vulnerability-details-shows-the-auto-resolve-pipeline-id"></a>

### 漏洞详情显示自动解决流水线 ID

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/policies/vulnerability_management_policy.md)

{{< /details >}}

在对已自动解决但随后又被重新检测到的漏洞进行故障排除时，将当前流水线与漏洞被解决时的流水线进行比较可能会有所帮助。

如果漏洞被自动解决，漏洞详情页面中的漏洞备注现在会包含发生该情况时的流水线 ID。

<a id="enhanced-controls-for-who-can-download-job-artifacts"></a>

### 增强对谁可以下载作业产物的控制

{{< details >}}

- Tier: 免费版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../ci/yaml/_index.md#artifactsaccess)

{{< /details >}}

在极狐GitLab 16.11 中，我们添加了 `artifacts:access` 关键字，使用户能够控制产物是可以被所有有权访问流水线的用户下载，还是仅被具有开发者角色或更高权限的用户下载，或者完全不允许任何用户下载。

在此版本中，你现在可以将谁可以下载产物限制为仅限维护者角色或更高权限，这为你控制谁可以下载作业产物提供了一个额外选项。

<a id="gitlab-runner-184"></a>

### 极狐GitLab Runner 18.4

{{< details >}}

- Tier: 免费版，专业版，旗舰版
- Offering: GitLab Dedicated
- Links: [文档](https://gitlab.cn/docs/runner)

{{< /details >}}

我们今天还发布了极狐GitLab Runner 18.4！极狐GitLab Runner 是一个高可扩展的构建代理，可运行你的 CI/CD 作业并将结果发送回极狐GitLab 实例。极狐GitLab Runner 与极狐GitLab CI/CD（包含在极狐GitLab 中的开源持续集成服务）协同工作。

<a id="bug-fixes"></a>

#### 错误修复

- [FIPS Runner 在极狐GitLab Runner 18.2.1 中无法启动作业](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/38963)
- [在 OpenShift 4.16.27 上升级到 Operator v1.37.0 后，具有自定义 ConfigMap 和安全上下文约束 (SCC) 的 Runner 的 `chown` 命令失败](https://gitlab.com/gitlab-org/gl-openshift/gitlab-runner-operator/-/issues/246)
- [由于在 17.2 中过早移除，在极狐GitLab 17.x.x 版本中恢复 `FF_RETRIEVE_POD_WARNING_EVENTS`](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/38851)
- [所有极狐GitLab Runner 作业因文件系统权限错误而失败](https://gitlab.com/gitlab-org/gl-openshift/gitlab-runner-operator/-/issues/214)
- [构建作业因权限被拒绝错误而偶发失败](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/37464)
- [极狐GitLab Runner Helm Chart 升级破坏了变量](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/30851)
- [启用 `FF_USE_FASTZIP` 不会启用 fastzip](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/28989)
- [极狐GitLab Runner 在尝试停止通过一次性请求创建的 Spot 实例时遇到 `UnsupportedOperation` 错误](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/28865)
- [极狐GitLab Runner 的长轮询在 Kubernetes 部署环境中无法正常工作](https://gitlab.com/gitlab-org/gitlab/-/issues/331460)
- [允许管理员覆盖 image:Kubernetes:user 值](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/38894)
所有变更的列表可在 GitLab Runner 的 [更新日志](https://gitlab.com/gitlab-org/gitlab-runner/blob/18-4-stable/[CHANGELOG](https://gitlab.com/gitlab-org/gitlab-runner/blob/18-4-stable/CHANGELOG.md).md) 中找到。