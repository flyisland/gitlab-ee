---
stage: Release Notes
group: Monthly Release
date: 2025-09-18
title: "极狐GitLab 18.4 发布说明"
description: "极狐GitLab 18.4 发布，极狐GitLab Duo 模型选择现已正式发布"
---

<!-- markdownlint-disable -->
<!-- vale off -->

2025 年 9 月 18 日，极狐GitLab 18.4 正式发布，带来了以下新功能。

<a id="primary-features"></a>

## 主要功能

<a id="gitlab-duo-model-selection-now-generally-available"></a>

### 极狐GitLab Duo 模型选择现已正式发布

<!-- categories: Model Personalization -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 附加组件: Duo Core, Duo Pro, Duo Enterprise
- 链接: [文档](../../user/gitlab_duo/model_selection.md#select-a-model-for-a-feature) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/18818)

{{< /details >}}

极狐GitLab Duo 模型选择已正式发布，让组织能够更好地控制由哪些 AI 模型为其开发工作流提供支持。

JihuLab.com 上顶级群组的所有者以及私有化部署的管理员，现在可以从多种极狐GitLab AI 模型供应商中选择特定模型，用于其极狐GitLab Duo 功能，并通过极狐GitLab 托管的 AI 网关访问。

JihuLab.com 上属于多个命名空间的极狐GitLab 用户现在还可以设置默认命名空间，以确保在所有开发场景中保持一致的 AI 模型偏好。有关极狐GitLab Duo 模型选择的更多信息，[请阅读博客](https://about.gitlab.com/blog/speed-meets-governance-model-selection-comes-to-gitlab-duo/)。

<a id="gitlab-knowledge-graph"></a>

### 极狐GitLab 知识图谱

<!-- categories: Duo Agent Platform, Duo Chat, Code Suggestions, Vulnerability Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](https://gitlab-org.gitlab.io/rust/knowledge-graph/) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/17514)

{{< /details >}}

极狐GitLab 知识图谱可在您的整个代码库中提供丰富的代码智能。开发者可以借助更丰富的上下文理解和浏览项目，从而更轻松地规划变更、执行影响分析，并与极狐GitLab Duo Agent 协作以加速开发任务。

极狐GitLab Duo Agent Platform 利用知识图谱来提高 AI Agent 的准确性。通过映射整个代码库中的文件和定义，知识图谱提供增强的上下文，使 Duo Agent 能够理解整个本地工作区中的关系，从而更快、更精确地回答复杂问题。

本次发布的知识图谱侧重于本地代码索引，其 CLI 可将您的代码库转换为一个实时、可嵌入的图数据库，用于 RAG。您可以通过简单的一行脚本安装它，解析本地代码仓库，并通过 MCP 连接以查询您的工作区。

我们对知识图谱项目的愿景有两个方面：构建一个充满活力的社区版，开发者现在就可以在本地运行，它将作为未来在 JihuLab.com 和私有化部署实例中完全集成的知识图谱服务的基础。

此功能处于测试版状态。请在[议题 160](https://gitlab.com/gitlab-org/rust/knowledge-graph/-/issues/160)中提供反馈。

<a id="end-user-model-selection-now-available-with-gitlab-duo"></a>

### 极狐GitLab Duo 现已支持最终用户模型选择

<!-- categories: Model Personalization -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com
- 附加组件: Duo Core, Duo Pro, Duo Enterprise
- 链接: [文档](../../user/gitlab_duo/model_selection.md#select-a-model-for-a-feature) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/19251)

{{< /details >}}

面向最终用户的极狐GitLab Duo 模型选择现已在 JihuLab.com 上公开测试。用户现在可以直接在极狐GitLab UI 中为极狐GitLab Duo Agentic Chat 选择首选模型，让开发者能够个性化地控制其 AI 辅助体验。

当 JihuLab.com 上的命名空间所有者允许时，最终用户可以从可用的极狐GitLab AI 供应商模型中进行选择，用于极狐GitLab Duo Agentic Chat。命名空间所有者可以继续通过命名空间设置来设置组织范围的模型偏好，或允许最终用户选择模型。

要开始使用，请在极狐GitLab Duo Agentic Chat 中查找模型下拉菜单，以选择您的首选模型。请注意，更改模型将开始新的对话，您的偏好将在未来的会话中被记住。

<a id="cicd-job-tokens-can-authenticate-git-push-requests"></a>

### CI/CD 作业令牌可对 Git push 请求进行身份验证

<!-- categories: System Access -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/jobs/ci_job_token.md#allow-git-push-requests-to-your-project-repository) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/389060)

{{< /details >}}

您现在可以允许在项目中生成的 CI/CD 作业令牌对项目代码仓库的 Git push 请求进行身份验证。可通过 UI 中的作业令牌权限设置启用此功能，或者使用项目 REST API 端点中的 `[ci_push_repository_for_job_token_allowed](../../api/projects.md#edit-a-project)` 参数启用。

<a id="gitlab-duo-context-exclusion"></a>

### 极狐GitLab Duo 上下文排除

<!-- categories: Duo Agent Platform, Duo Chat, Code Suggestions, Vulnerability Management -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 附加组件: Duo Pro, Duo Enterprise
- 链接: [文档](../../user/gitlab_duo/context.md#exclude-context-from-code-review) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/17124)

{{< /details >}}

极狐GitLab Duo 上下文排除让您可以控制将哪些项目内容排除在极狐GitLab Duo 的上下文之外。这有助于保护密码文件和配置文件等敏感信息。您可以排除单个文件、特定目录、特定文件类型，或这些的任意组合。

此功能目前处于测试版。请在[议题 566244](https://gitlab.com/gitlab-org/gitlab/-/issues/566244)中提供有关极狐GitLab Duo 上下文排除的反馈。

<a id="simulate-cicd-pipelines-against-different-branch"></a>

### 针对不同分支模拟 CI/CD 流水线

<!-- categories: Pipeline Composition -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 链接: [文档](../../ci/pipeline_editor/_index.md#validate-cicd-configuration) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/482676)

{{< /details >}}

此前，使用流水线编辑器并通过验证标签页验证更改时，您只能针对默认分支运行模拟。在此版本中，我们扩展了此功能。您现在可以选择任意分支来模拟流水线。这一改进让您在测试和验证流水线时拥有更大的灵活性。您可以确保它们在不同情况下（包括稳定分支或功能分支）都能按预期运行。

<a id="agentic-core"></a>

## AI 功能

<a id="automatic-duo-code-review-for-groups-and-applications"></a>

### 针对群组和应用程序的自动 Duo 代码评审

<!-- categories: Code Review Workflow -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com
- 附加组件: Duo Enterprise
- 链接: [文档](../../user/project/merge_requests/duo_in_merge_requests.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/554070)

{{< /details >}}

您现在可以使用群组或应用程序设置，为多个项目启用自动 Duo 代码评审。这可以帮助您快速为群组中的所有项目启用 Duo 代码评审，而无需逐个启用特定项目。

此功能目前在 JihuLab.com 上可用，我们计划在未来的版本中将其提供给极狐GitLab 私有化部署。请在[议题 517386](https://gitlab.com/gitlab-org/gitlab/-/issues/517386)中提供反馈。

<a id="additional-supported-models-for-gitlab-duo-self-hosted"></a>

### 极狐GitLab Duo 自部署版本新增支持的模型

<!-- categories: Self-Hosted Models -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: 私有化部署
- 附加组件: Duo Enterprise
- 链接: [文档](../../administration/gitlab_duo_self_hosted/supported_models_and_hardware_requirements.md#supported-models) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/16742)

{{< /details >}}

使用极狐GitLab Duo Enterprise 的极狐GitLab 私有化部署客户现在可以在极狐GitLab Duo 中使用更多受支持的模型。
Azure OpenAI 现已支持 OpenAI GPT-5。vLLM 和 Azure OpenAI 现在也支持开源 OpenAI GPT OSS 20B 和 120B。
如需提供有关在极狐GitLab Duo 自部署版本中使用这些模型的反馈，请参阅[议题 523918](https://gitlab.com/gitlab-org/gitlab/-/issues/523918)。

<a id="duo-code-review-on-gitlab-duo-self-hosted-is-generally-available"></a>

### Duo 代码评审在极狐GitLab Duo 自部署版本上已正式发布

<!-- categories: Code Suggestions, Self-Hosted Models -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: 私有化部署
- 附加组件: Duo Enterprise
- 链接: [文档](../../administration/gitlab_duo_self_hosted/_index.md#gitlab-duo) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/548975)

{{< /details >}}

极狐GitLab Duo 代码评审在极狐GitLab Duo 自部署版本上已正式发布。在极狐GitLab Duo 自部署版本上使用代码评审，可以在不影响数据主权的情况下加速您的开发流程。当代码评审审查您的合并请求时，它会识别潜在的错误并建议改进，供您直接应用。在请求人工评审之前，使用代码评审对您的更改进行迭代和改进。此功能支持 Mistral、Meta Llama、Anthropic Claude 和 OpenAI GPT 模型系列。

请在[议题 517386](https://gitlab.com/gitlab-org/gitlab/-/issues/517386)中提供有关代码评审的反馈。

<a id="unified-devops-and-security"></a>

## 统一的 DevOps 与安全

<a id="pipeline-secret-detection-now-excludes-certain-files-and-directories-by-default"></a>

### 流水线密钥检测现在默认排除某些文件和目录

<!-- categories: Secret Detection -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/secret_detection/pipeline/_index.md#excluded-items) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/560147)

{{< /details >}}

流水线密钥检测现在会自动排除[某些文件类型和目录](../../user/application_security/secret_detection/pipeline/_index.md#excluded-items)（如果它们包含密钥的可能性较低），从而提高扫描性能。这些更改已在分析器 [7.11.0 版本](https://gitlab.com/gitlab-org/security-products/analyzers/secrets/-/releases/v7.11.0)中发布。

<a id="secret-detection-analyzer-git-fetching-improvements"></a>

### 密钥检测分析器 Git 获取改进

<!-- categories: Secret Detection -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/secret_detection/pipeline/_index.md#how-the-analyzer-fetches-commits) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/17315)

{{< /details >}}

密钥检测分析器的 [7.12.0 版本](https://gitlab.com/gitlab-org/security-products/analyzers/secrets/-/releases/v7.12.0)对 Git 提交的获取方式进行了重大改进。分析器现在会解析从 `SECRET_DETECTION_LOG_OPTIONS` 传入的 `--depth` 和 `--since` 选项，因此您可以进一步指定要扫描的提交数量。分析器还会根据上下文选择合适的获取策略，从而避免了一个已知问题：即使配置了浅层深度，也可能不必要地获取数百万个提交。

此增强功能可减少作业超时、降低资源消耗，并提供更可预测的扫描性能。您可以体验更快的密钥检测扫描（尤其是在大型代码仓库中），并获得与实际获取行为相符的更清晰的日志。

<a id="significantly-faster-advanced-sast-scanning"></a>

### 显著加快的高级 SAST 扫描

<!-- categories: SAST -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/sast/gitlab_advanced_sast.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/16561)

{{< /details >}}

在合并请求和流水线中启用安全扫描时，每一分钟都很重要。我们定期发布高级 SAST 的性能改进，同时针对引擎及其检测规则。

在此版本中，我们重点介绍一项具体改进，它在我们的基准测试和实际测试中将扫描运行时间缩短了多达 78%。我们在扫描过程中对性能敏感的部分添加了缓存，从而显著加快了大型代码仓库中的扫描速度。

此改进在高级 SAST 分析器 2.9.6 及更高版本中自动启用。您可以通过[查看扫描作业日志](../../user/application_security/sast/gitlab_advanced_sast.md)来查看您正在使用的分析器版本。

<a id="operational-container-scanning-severity-threshold-configuration"></a>

### 运维容器扫描严重性阈值配置

<!-- categories: Software Composition Analysis -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/clusters/agent/vulnerabilities.md#configure-trivy-severity-threshold-filter) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/559278)

{{< /details >}}

您现在可以将运维容器扫描（OCS）配置为仅返回达到或超过特定严重性级别的漏洞。设置严重性阈值后，低于您所选严重性的漏洞将不再在漏洞报告、API 负载和其他报告机制中返回。这可以帮助您专注于想要修复的漏洞。

要启用此过滤功能，请在 OCS 配置中[设置 `severity_threshold`](../../user/clusters/agent/vulnerabilities.md#configure-trivy-severity-threshold-filter)。

我们衷心感谢 [John Walsh](https://gitlab.com/mjohnw)的这一社区贡献。要了解有关为 GitLab 贡献的更多信息，请查看[社区贡献计划](https://about.gitlab.com/community/contribute/)。

<a id="publish-opentofu-modules-and-providers-to-the-gitlab-container-registry-with-cicd-templates"></a>

### 使用 CI/CD 模板将 OpenTofu 模块和提供程序发布到极狐GitLab 容器镜像仓库

<!-- categories: Infrastructure as Code -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](https://gitlab.com/components/opentofu#publish-providers-to-the-gitlab-oci-registry) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/562715)

{{< /details >}}

极狐GitLab 容器镜像仓库现在支持用于托管 OpenTofu 模块和提供程序的媒体类型。

[OpenTofu CI/CD 组件](https://gitlab.com/components/opentofu)的
[3.1.0 版本](https://gitlab.com/components/opentofu/-/releases/3.1.0)支持一个新的 `provider-release` 模板，可使用 OCI 格式将 OpenTofu 提供程序部署到极狐GitLab 仓库中。现在，您可以直接在极狐GitLab 中托管私有 OpenTofu 提供程序。

此外，`module-release` 模板现在支持一个新的 `type` 输入，您可以将其设置为 `oci`，
以使用 OCI 格式将 OpenTofu 模块部署到极狐GitLab 仓库中。

<a id="bypass-confirmation-for-enterprise-users-when-reassigning-placeholders"></a>

### 企业用户在重新分配占位符时绕过确认

<!-- categories: Importers -->

{{< details >}}

- 交付方式: JihuLab.com
- 链接: [文档](../../user/import/mapping/reassignment.md#bypass-confirmation-when-reassigning-placeholder-users) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/17871)

{{< /details >}}

拥有群组所有者角色的用户现在可以在将该群组中的占位符重新分配给活跃的企业用户时绕过用户确认。这样，企业用户就不必不断检查电子邮件来确认重新分配。达到该设置的时间限制后，所有新的重新分配都会再次发送电子邮件确认请求。

重新分配完成后，企业用户仍会收到通知电子邮件，从而确保整个过程的透明度。

<a id="configure-how-to-view-issues-from-the-issues-page"></a>

### 从议题页面配置议题的查看方式

<!-- categories: Portfolio Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/issues/managing_issues.md#open-issues-in-a-panel) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/570776)

{{< /details >}}

您现在可以完全控制列表页面的视图，选择显示哪些元数据以及是否在抽屉中打开工作项，从而更轻松地专注于对您最重要的信息。

此前，所有元数据字段始终可见，这可能会使浏览工作项变得困难。现在，您可以通过打开或关闭特定字段（如指派人、标记、日期和里程碑）来自定义视图。

通过新的切换开关，您可以在抽屉视图和整页导航之间切换，从而在保持列表上下文的同时快速查看详细信息，或者在需要更多屏幕空间进行详细编辑和全面导航时打开整页。

<a id="enhanced-parent-filtering-for-epic-and-issue-lists"></a>

### 增强的史诗和议题列表父项过滤

<!-- categories: Portfolio Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/issues/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/556200)

{{< /details >}}

我们将议题和史诗页面上的“史诗”过滤器替换为更灵活的“父项”过滤器。此更改让您可以按任意父工作项进行过滤，而不仅仅是史诗。您现在可以通过按父议题过滤轻松找到子任务，或通过按父史诗过滤找到议题，从而在议题和史诗列表中更好地了解您的工作层级。

<a id="issue-boards-now-show-complete-epic-hierarchies"></a>

### 议题看板现在显示完整的史诗层级

<!-- categories: Portfolio Management -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/issue_board.md#filter-issues) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/358416)

{{< /details >}}

在议题看板中按父史诗过滤时，您现在可以查看子史诗中的所有议题，这与议题页面的工作方式保持一致。此改进可帮助您更好地跟踪和可视化完整的史诗层级，而不会遗漏嵌套在子史诗中的任何议题，使您的项目管理流程更高效、更可靠。

<a id="text-editors-toolbar-parity"></a>

### 文本编辑器工具栏一致性

<!-- categories: Markdown -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/rich_text_editor.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/507377)

{{< /details >}}

极狐GitLab 纯文本编辑器现在包含与富文本编辑器相同的格式选项。纯文本编辑器工具栏已更新，新增了“更多选项”菜单，可提供对高级格式工具的访问，例如：

- 代码块
- 详情块
- 水平分隔线
- Mermaid 图表
- PlantUML 图表
- 目录

两个编辑器现在具有一致的按钮位置和分隔符，使您可以在编辑模式之间更轻松地切换，同时保持对熟悉格式选项的访问。

<a id="vulnerability-details-shows-the-auto-resolve-pipeline-id"></a>

### 漏洞详情显示自动解决流水线 ID

<!-- categories: Vulnerability Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/policies/vulnerability_management_policy.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/566392)

{{< /details >}}

在对已自动解决、后来又重新检测到的漏洞进行故障排除时，将当前流水线与解决该漏洞的流水线进行比较可能会有所帮助。

如果漏洞被自动解决，漏洞详情页面中的漏洞评论现在会包含其发生时的流水线 ID。

<a id="enhanced-controls-for-who-can-download-job-artifacts"></a>

### 增强了对谁可以下载作业产物的控制

<!-- categories: Artifact Security -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/yaml/_index.md#artifactsaccess) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/454398)

{{< /details >}}

在极狐GitLab 16.11 中，我们添加了 `artifacts:access` 关键字，使用户能够控制产物是可以由所有有权访问流水线的用户下载，还是仅由拥有开发者角色或更高角色的用户下载，或者任何用户都不能下载。

在此版本中，您现在可以将可下载产物的人员限制为仅拥有维护者角色或更高角色的用户，为您控制谁可以下载作业产物提供了又一个选项。

<a id="gitlab-runner-184"></a>

### 极狐GitLab Runner 18.4

<!-- categories: GitLab Runner Core -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 链接: [文档](https://gitlab.cn/docs/runner/)

{{< /details >}}

我们今天还发布了极狐GitLab Runner 18.4！极狐GitLab Runner 是高度可扩展的构建代理，负责运行您的 CI/CD 作业并将结果发送回极狐GitLab 实例。极狐GitLab Runner 与极狐GitLab CI/CD 协同工作，后者是极狐GitLab 中包含的开源持续集成服务。

<a id="bug-fixes"></a>

#### 缺陷修复

- [FIPS Runner 无法使用极狐GitLab Runner 18.2.1 启动作业](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/38963)
- [在 OpenShift 4.16.27 上升级到 Operator v1.37.0 后，具有自定义 ConfigMap 和安全上下文约束（SCC）的 Runner 的 `chown` 命令失败](https://gitlab.com/gitlab-org/gl-openshift/gitlab-runner-operator/-/issues/246)
- [由于在 17.2 中过早移除，在极狐GitLab 17.x.x 版本中恢复 `FF_RETRIEVE_POD_WARNING_EVENTS`](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/38851)
- [所有极狐GitLab Runner 作业因文件系统权限错误而失败](https://gitlab.com/gitlab-org/gl-openshift/gitlab-runner-operator/-/issues/214)
- [构建作业偶发因权限被拒绝错误而失败](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/37464)
- [极狐GitLab Runner Helm chart 升级破坏了变量](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/30851)
- [启用 `FF_USE_FASTZIP` 并不会启用 fastzip](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/28989)
- [极狐GitLab Runner 在尝试停止通过一次性请求创建的 Spot 实例时遇到 `UnsupportedOperation` 错误](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/28865)
- [在 Kubernetes 部署环境中，极狐GitLab Runner 的长轮询无法正常工作](https://gitlab.com/gitlab-org/gitlab/-/issues/331460)
- [允许管理员覆盖 image:Kubernetes:user 值](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/38894)

所有更改的列表见极狐GitLab Runner [CHANGELOG](https://gitlab.com/gitlab-org/gitlab-runner/blob/18-4-stable/CHANGELOG.md)。
