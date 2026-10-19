---
stage: Release Notes
group: Monthly Release
date: 2025-05-15
title: "极狐GitLab 18.0 发布说明"
description: "极狐GitLab 18.0 发布，专业版和旗舰版均包含 Duo"
---

<!-- markdownlint-disable -->
<!-- vale off -->

2025 年 5 月 20 日，极狐GitLab 18.0 发布，包含以下功能。

<a id="primary-features"></a>

## 主要功能

<a id="gitlab-premium-and-ultimate-with-duo"></a>

### 包含 Duo 的极狐GitLab 专业版和旗舰版

<!-- categories: Code Suggestions, Duo Chat -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 附加组件: Duo Pro, Duo Enterprise
- 链接: [文档](../../user/gitlab_duo/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/538857)

{{< /details >}}

我们很高兴地宣布推出包含 Duo 的极狐GitLab 专业版和包含 Duo 的极狐GitLab 旗舰版。极狐GitLab 专业版和旗舰版现已包含 AI 原生功能。

极狐GitLab 的 AI 原生功能包括 IDE 中的代码建议和 Chat。开发团队可以使用这些功能来：

- 分析、理解和解释代码
- 更快地编写安全代码
- 快速生成测试以保持代码质量
- 轻松重构代码以提升性能或使用特定库

<a id="repository-x-ray-now-available-on-gitlab-duo-self-hosted"></a>

### 代码仓库 X-Ray 现已在极狐GitLab Duo 自部署版本上提供

<!-- categories: Self-Hosted Models -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: 私有化部署
- 附加组件: Duo Enterprise
- 链接: [文档](../../user/project/repository/code_suggestions/repository_xray.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/17756)

{{< /details >}}

您现在可以在极狐GitLab Duo 自部署版本上结合代码建议使用代码仓库 X-Ray。此功能在极狐GitLab Duo 自部署版本上处于测试版，在极狐GitLab 私有化部署实例上已正式发布。

<a id="automatic-reviews-with-duo-code-review"></a>

### 使用 Duo 代码评审进行自动评审

<!-- categories: Code Review Workflow -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 附加组件: Duo Enterprise
- 链接: [文档](../../user/project/merge_requests/duo_in_merge_requests.md)

{{< /details >}}

Duo 代码评审在评审过程中提供有价值的见解，但目前需要您在每个合并请求上手动请求评审。

现在，您可以通过更新项目的合并请求设置，将极狐GitLab Duo 代码评审配置为在合并请求上自动运行。启用后，Duo 代码评审会自动评审合并请求，除非：

- 该合并请求被标记为草稿。
- 该合并请求不包含任何变更。

自动评审可确保您项目中的所有代码都得到评审，从而持续提升整个代码库的代码质量。

<a id="code-suggestions-prompt-caching"></a>

### 代码建议提示缓存

<!-- categories: Code Suggestions -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 附加组件: Duo Pro, Duo Enterprise
- 链接: [文档](../../user/project/repository/code_suggestions/_index.md#prompt-caching) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/17489)

{{< /details >}}

代码建议现在包含提示缓存。提示缓存通过避免重新处理已缓存的提示和输入数据，显著改善代码补全延迟。缓存的数据绝不会记录到任何持久化存储中，您可以选择在极狐GitLab Duo 设置中禁用提示缓存。

<a id="improved-duo-code-review-context"></a>

### 改进的 Duo 代码评审上下文

<!-- categories: Code Review Workflow -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 附加组件: Duo Enterprise
- 链接: [文档](../../user/project/merge_requests/duo_in_merge_requests.md)

{{< /details >}}

Duo 代码评审现在提供更全面的上下文，以改进分析。主要改进包括：

- 包含合并请求的标题和描述，以更好地理解所提议变更的目的。
- 同时检查所有差异，以识别跨文件关系并减少误报。
- 提供已更改文件的完整内容，以了解修改如何融入现有代码模式。

这些增强功能可减少不准确的建议，并交付更相关、更高质量的代码评审。

<a id="scale-and-deployments"></a>

## 规模与部署

<a id="list-only-enterprise-users-for-contributions-reassignment-on-gitlabcom"></a>

### 在 JihuLab.com 上仅列出企业用户以重新分配贡献

<!-- categories: Importers -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/group/import/direct_transfer_migrations.md#user-membership-mapping) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/510673)

{{< /details >}}

在此版本中，我们改进了占位用户映射体验，将用户选择下拉列表缩小到仅显示与顶级群组关联的企业用户。此前，在导入到 JihuLab.com 后重新分配用户贡献时，下拉列表中会显示平台上的所有活跃用户，这使得识别正确的用户变得困难，尤其是当 SCIM 预配修改了用户名时。现在，如果您的顶级群组使用企业用户功能，下拉列表将仅显示由您的组织认领的用户，从而显著降低用户重新分配过程中出错的可能性。同样的范围限定也应用于基于 CSV 的重新分配，防止意外分配给组织之外的用户。

<a id="support-for-multiple-workspaces-in-the-gitlab-for-slack-app"></a>

### GitLab for Slack 应用支持多个工作区

<!-- categories: Settings -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 链接: [文档](../../administration/settings/slack_app.md#enable-support-for-multiple-workspaces) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/424190)

{{< /details >}}

GitLab for Slack 应用现在为极狐GitLab 私有化部署客户支持多个工作区。启用多个工作区后，拥有联合 Slack 环境的组织可以在其所有工作区中保持无缝的极狐GitLab 集成。要启用多工作区支持，请将 GitLab for Slack 应用配置为[未列出的分布式应用](https://api.slack.com/distribution#unlisted-distributed-apps)。

<a id="delete-groups-and-placeholder-users"></a>

### 删除群组和占位用户

<!-- categories: Importers -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/import/mapping/post_migration_mapping.md#placeholder-user-deletion) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/473256)

{{< /details >}}

在极狐GitLab 18.0 中，当您删除顶级群组时，与该群组关联的占位用户也会被删除。如果占位用户与其他项目关联，则仅从顶级群组中移除。这样，无需破坏其他项目的历史记录或归属信息，即可移除不必要的占位用户。

<a id="gitlab-chart-90-released-with-breaking-changes"></a>

### GitLab chart 9.0 发布，包含破坏性变更

<!-- categories: Cloud Native Installation, Omnibus Package -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](https://gitlab.cn/docs/charts/releases/9_0/) | [相关议题](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/5927)

{{< /details >}}

- [破坏性变更](../../update/deprecations.md#postgresql-14-and-15-no-longer-supported)：已移除对 PostgreSQL 14 和 15 的支持。升级前请确保您运行的是 PostgreSQL 16。
- [破坏性变更](../../update/deprecations.md#major-update-of-the-prometheus-subchart)：内置的 Prometheus chart 已从 15.3 更新到 27.11。随着 Prometheus chart 升级，Prometheus 版本也从 2.38 更新到 3.0。执行升级需要手动步骤。如果您启用了 Alertmanager、Node Exporter 或 Pushgateway，还必须更新您的 Helm 值。有关更多信息，请参阅[迁移指南](https://gitlab.cn/docs/charts/releases/9_0/#prometheus-upgrade)。
- [破坏性变更](../../update/deprecations.md#fallback-support-for-gitlab-nginx-chart-controller-image-v131)：默认 NGINX 控制器镜像已从版本 1.3.1 更新到 1.11.2。如果您使用 GitLab NGINX chart，并且设置了自己的 NGINX RBAC 规则，则必须存在新的 RBAC 规则。有关更多信息，请参阅[升级指南](https://gitlab.cn/docs/charts/releases/8_0/#upgrade-to-86x-851-843-836)。

<a id="event-data-collection"></a>

### 事件数据收集

<!-- categories: Application Instrumentation -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 链接: [文档](../../administration/settings/event_data.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/510333)

{{< /details >}}

在极狐GitLab 18.0 中，我们正在启用从极狐GitLab 私有化部署实例收集事件级产品使用数据。与聚合数据不同，事件级数据为极狐GitLab 提供了更深入的用量洞察，使我们能够改善平台上的用户体验并提高功能采用率。有关如何调整数据共享设置的详细说明，请参阅我们的文档。

<a id="deletion-protection-available-for-all-users"></a>

### 所有用户均可使用删除保护

<!-- categories: Groups & Projects -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../administration/settings/visibility_and_access_controls.md#deletion-protection) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/17208) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/526405)

{{< /details >}}

项目和群组延迟删除现在对所有极狐GitLab 用户可用，包括基础版用户。这一重要的安全功能在被删除的群组和项目被永久移除之前增加了一个宽限期（在 JihuLab.com 上为 7 天）。此功能允许从意外删除中恢复，而无需复杂的恢复操作。

通过将数据安全作为核心功能，极狐GitLab 可以帮助更好地保护您的工作免受数据丢失事件的影响。

<a id="delayed-project-deletion-for-user-namespaces"></a>

### 用户命名空间的延迟项目删除

<!-- categories: Groups & Projects -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/working_with_projects.md#delete-a-project) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/536244)

{{< /details >}}

延迟项目删除现在可用于用户命名空间中的项目（个人项目）。此前，这一防止意外数据丢失的保护措施仅适用于群组命名空间。当您删除用户命名空间中的项目时，它现在将进入“待删除”状态，持续时间为您的实例设置中配置的时长（在 JihuLab.com 上为 7 天），而不是立即删除。这创建了一个恢复窗口，您可以在需要时恢复该项目。

我们希望这一增强功能能让您在极狐GitLab 中管理个人项目时更加安心。

<a id="new-active-parameter-for-groups-and-projects-rest-apis"></a>

### 群组和项目 REST API 的新 `active` 参数

<!-- categories: Groups & Projects -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../api/projects.md#list-projects)

{{< /details >}}

我们为群组和项目 REST API 添加了一个新的 `active` 参数，可简化按状态筛选群组。当设置为 `true` 时，仅返回未归档或未标记为删除的群组或项目。当设置为 `false` 时，仅返回已归档或标记为删除的群组或项目。如果未定义该参数，则不应用筛选。此增强功能可帮助您通过简单的 API 调用定位特定状态，从而高效管理工作流。

感谢 [@dagaranupam](https://gitlab.com/dagaranupam) 为项目 API 添加此参数。

<a id="rate-limits-for-groups-projects-and-users-api"></a>

### 群组、项目和用户 API 的速率限制

<!-- categories: Groups & Projects -->

{{< details >}}

- 适用版本: 基础版
- 交付方式: JihuLab.com
- 链接: [文档](../../user/jihulab_com/_index.md#jihulabcom-specific-rate-limits) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/461316)

{{< /details >}}

我们为项目、群组和用户添加了 API 速率限制，以改善所有用户的平台稳定性和性能。这些变更是为了应对影响我们服务的 API 流量增长。

这些限制是根据平均使用模式精心设置的，应为大多数用例提供足够的容量。如果您超过这些限制，您将收到“429 Too Many Requests”响应。

有关特定速率限制和实施信息的完整详情，请[阅读相关博客文章](https://about.gitlab.com/blog/rate-limitations-announced-for-projects-groups-and-users-apis/)。

<a id="unified-devops-and-security"></a>

## 统一 DevOps 与安全

<a id="security-scanners-now-support-mr-pipelines"></a>

### 安全扫描器现在支持合并请求流水线

<!-- categories: API Security, Container Scanning, DAST, Fuzz Testing, SAST, Secret Detection, Software Composition Analysis -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/detect/roll_out_security_scanning.md)

{{< /details >}}

您现在可以选择在[合并请求流水线](../../ci/pipelines/merge_request_pipelines.md)中运行[应用程序安全测试（AST）扫描器](../../user/application_security/detect/_index.md)。为尽量减少对您流水线的影响，这是一项您可以选择启用的行为。

此前，默认行为取决于您使用[稳定版还是最新版 CI/CD 模板版本](../../user/application_security/detect/security_configuration.md#template-editions)来启用扫描器：

- 在稳定版模板中，扫描作业仅在分支流水线中运行。不支持合并请求流水线。
- 在最新版模板中，当合并请求处于打开状态时，扫描作业在合并请求流水线中运行；如果没有关联的合并请求，则在分支流水线中运行。您无法控制此行为。

现在，一个新选项 `AST_ENABLE_MR_PIPELINES` 允许您控制是否在合并请求流水线中运行作业。稳定版和最新版模板的默认行为保持不变。具体来说：

- 稳定版模板默认继续在分支流水线中运行扫描作业，但当合并请求处于打开状态时，您可以设置 `AST_ENABLE_MR_PIPELINES: "true"`来改用合并请求流水线。
- 最新版模板默认在合并请求处于打开状态时在合并请求流水线中运行扫描作业，但您可以设置 `AST_ENABLE_MR_PIPELINES: "false"`来改用分支流水线。

此改进影响所有安全扫描模板，但 API Discovery（`API-Discovery.gitlab-ci.yml`）除外，它目前默认使用合并请求流水线。我们还在极狐GitLab 18.0 中更改了 API Discovery 模板，使其与其他稳定版模板保持一致，并默认使用分支流水线。

<a id="display-and-filter-archived-projects-in-the-compliance-projects-report"></a>

### 在合规项目报告中显示和筛选已归档项目

<!-- categories: Compliance Management -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/compliance/compliance_center/compliance_projects_report.md#filter-the-compliance-projects-report) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/500520)

{{< /details >}}

在合规项目报告中，您可以查看应用于群组或子群组内项目的合规框架。

然而，该报告缺少显示项目是否已归档的能力，而这可能是管理活跃项目和已归档项目合规性的有用信息。

因此，我们添加了一个指示器来显示项目是否已归档。这将在您审查活跃项目和已归档项目的合规框架时，为您提供更好的可见性和上下文。

此功能包括：

- 合规项目报告中每个项目的归档状态徽章，用于显示项目是否已归档。
- 一个筛选器，允许您在已归档、未归档或所有项目之间切换。

<a id="create-a-workspace-from-merge-requests"></a>

### 从合并请求创建工作区

<!-- categories: Workspaces -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/workspace/configuration.md#create-a-workspace)

{{< /details >}}

您现在可以使用新的**在 Workspace 中打开**选项直接从合并请求创建工作区。此功能会自动使用合并请求的分支和上下文配置工作区，让您可以：

- 在完全配置的环境中审查代码变更。
- 在合并请求分支上运行测试以验证功能。
- 无需本地设置即可对合并请求进行额外修改。

<a id="view-open-merge-requests-targeting-files"></a>

### 查看针对文件的打开的合并请求

<!-- categories: Source Code Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/repository/files/_index.md#view-open-merge-requests-for-a-file) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/448868)

{{< /details >}}

此前，在处理代码文件时，您无法了解还有谁可能在其他分支中修改同一文件。这种缺乏了解会导致合并冲突、重复工作和低效协作。

现在，您可以轻松识别所有修改您正在代码仓库中查看的文件的打开的合并请求。此功能可帮助您：

- 在潜在合并冲突发生之前识别它们。
- 避免重复正在进行的工作。
- 通过提供对进行中变更的可见性来改善协作。

徽章会显示修改该文件的打开的合并请求数量，将鼠标悬停在其上会显示一个弹出窗口，其中列出这些合并请求。

<a id="shared-kubernetes-namespace-for-workspaces"></a>

### 工作区共享 Kubernetes 命名空间

<!-- categories: Workspaces -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/workspace/settings.md#shared_namespace)

{{< /details >}}

您现在可以在共享的 Kubernetes 命名空间中创建极狐GitLab 工作区。这消除了为每个工作区创建新命名空间的需要，也消除了向代理授予提升的 ClusterRole 权限的要求。借助此功能，您可以更轻松地在安全或受限环境中采用工作区，提供更简单的扩展路径。

要启用共享命名空间，请在您的代理配置文件中设置 `shared_namespace` 字段，以指定您想用于所有工作区的 Kubernetes 命名空间。

感谢通过 [GitLab 的 Co-Create 计划](https://about.gitlab.com/community/co-create/)帮助构建此功能的六位社区贡献者！

<a id="improved-pod-status-visualizations-in-the-dashboard-for-kubernetes"></a>

### 改进 Kubernetes 仪表板中的 Pod 状态可视化

<!-- categories: Deployment Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/environments/kubernetes_dashboard.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/525081)

{{< /details >}}

您可以使用 Kubernetes 仪表板来监控已部署的应用程序。到目前为止，具有容器错误（如 `CrashLoopBackOff` 或 `ImagePullBackOff`）的 Pod 会显示为“Pending”或“Running”状态，这使得不使用 `kubectl` 就很难识别有问题的部署。

在极狐GitLab 18.0 中，UI 中的错误状态会显示特定容器的状态，类似于 `kubectl`的输出。现在，您无需离开极狐GitLab 界面即可快速识别和排查失败的 Pod。

<a id="exclude-packages-from-license-approval-rules"></a>

### 从许可证审批规则中排除软件包

<!-- categories: Security Policy Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/policies/merge_request_approval_policies.md#license_finding-rule-type) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/10203)

{{< /details >}}

在合并请求审批策略中，这一对许可证审批策略的新增强功能让法律和合规团队可以更好地控制哪些软件包可以使用特定许可证。您现在可以为预先批准的软件包创建例外，即使它们使用的许可证通常会被您组织的策略阻止。

此前，在许可证审批策略中，如果您阻止了 AGPL-3.0 等许可证，它会在整个组织内对所有软件包都被阻止。这在以下情况下会带来挑战：

- 您的法律团队预先批准了具有其他受限许可证的特定软件包。
- 您需要在数百个项目中跨项目使用同一个软件包。
- 不同团队需要不同的许可证例外。

通过此版本，您可以在保持严格许可证治理的同时允许必要的例外，从而显著减少审批瓶颈和人工审查。例如，您可以：

- 使用 Package URL (PURL) 格式为您的许可证审批规则定义特定于软件包的例外。
- 允许特定软件包（或软件包版本）使用其他受限许可证。
- 阻止特定软件包（或软件包版本）使用通常允许的许可证。

要添加例外，请在创建或编辑许可证审批策略时遵循以下工作流：

1. 在您的群组中，转到**安全与合规** > **策略**
1. 创建或编辑许可证审批策略。
1. 在可视化编辑器中找到新的软件包例外选项，或在 YAML 模式下配置它们。
1. 在许可证的允许名单或拒绝名单模式之间选择。
1. 将特定许可证添加到您的策略中。
1. 对于每个许可证，以 PURL 格式定义软件包例外（例如 `pkg:npm/@angular/animation@12.3.1`）。
1. 指定是将这些软件包包含在许可证规则中还是从中排除。

然后，该策略会在遵守所定义例外的同时执行您的许可证规则，让您可以对组织内的许可证合规性进行精细控制。

<a id="limit-maximum-user-session-length"></a>

### 限制用户会话的最大时长

<!-- categories: System Access -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 链接: [文档](../../administration/settings/account_and_limit_settings.md#set-sessions-to-expire-from-creation-date) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/395038)

{{< /details >}}

管理员现在可以选择用户会话的最大时长是从初始登录还是从上次活动开始计算。用户会收到会话即将结束的通知，但无法阻止会话过期或延长会话。此功能默认禁用。

感谢 [John Parent](https://gitlab.kitware.com/john.parent)的贡献！

<a id="gitlab-query-language-views-enhancements"></a>

### 极狐GitLab 查询语言视图增强

<!-- categories: Wiki, Team Planning -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/glql/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/15008)

{{< /details >}}

我们对极狐GitLab 查询语言（GLQL）视图进行了重大改进。这些改进包括支持：

- 适用于所有日期类型的`>=`和`<=`运算符
- 视图中的**视图操作**下拉列表
- **Reload** 操作
- 字段别名
- 在 GLQL 表中将列别名设置为自定义名称

我们欢迎您在[议题 509791](https://gitlab.com/gitlab-org/gitlab/-/issues/509791)中就此增强功能以及 GLQL 视图总体情况提供反馈。

<a id="pages-template-improvements"></a>

### Pages 模板改进

<!-- categories: Pages -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/pages/getting_started/pages_new_project_template.md#project-templates)

{{< /details >}}

极狐GitLab 提供[流行静态站点生成器的模板](https://gitlab.com/pages)。我们使用评分框架深入研究了可用模板，并精简了列表，仅包含最流行的模板。

精简 GitLab Pages 可用模板可简化网站创建过程。使用模板，只需最少的技术专业知识即可启动外观专业的站点。增强的模板还提供现代、响应式的设计，无需自定义开发工作。

<a id="configure-jira-issues-from-vulnerabilities-using-the-jira-integration-api"></a>

### 使用 Jira 集成 API 从漏洞配置 Jira 议题

<!-- categories: Vulnerability Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../api/project_integrations.md#jira-issues) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/454574)

{{< /details >}}

此前，您必须从**项目设置**页面配置集成，才能[从漏洞创建 Jira 议题](../../integration/jira/configure.md#create-a-jira-issue-for-a-vulnerability)。

您现在可以从项目集成 API 配置此集成，这使您可以自动化设置。

<a id="improved-traceability-of-redetected-vulnerabilities"></a>

### 改进重新检测到的漏洞的可追溯性

<!-- categories: Vulnerability Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/vulnerabilities/_index.md#vulnerability-status-values) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/523452)

{{< /details >}}

此前，当已解决的漏洞被重新检测到并更改状态时，漏洞详情未提供信息来指示状态更改发生的时间和原因。

现在，当已解决的漏洞因出现在新扫描中而更改状态时，极狐GitLab 会向漏洞历史记录添加一条系统评论。这些附加信息可帮助用户了解漏洞状态更改的原因。

<a id="bulk-add-vulnerabilities-to-issues-from-the-vulnerability-report"></a>

### 从漏洞报告批量将漏洞添加到议题

<!-- categories: Vulnerability Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/vulnerability_report/_index.md#add-vulnerabilities-to-an-existing-issue) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/13216)

{{< /details >}}

通过此版本，您现在可以从漏洞报告批量将漏洞添加到新的或现有的极狐GitLab 议题。您现在可以将多个议题和漏洞关联在一起。此外，相关漏洞现在会列在议题页面中。

<a id="disable-user-invitations"></a>

### 禁用用户邀请

<!-- categories: System Access -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../administration/settings/visibility_and_access_controls.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/19618)

{{< /details >}}

您现在可以移除邀请成员加入群组或项目的能力。

- 在 JihuLab.com 上，此设置由拥有企业用户的群组所有者配置，并适用于顶级群组内的任何子群组或项目。启用此设置后，任何用户都无法发送邀请。
- 在极狐GitLab 私有化部署上，此设置由管理员配置，并适用于整个实例。管理员仍然可以直接邀请用户。

此功能可帮助组织对成员访问保持严格控制。

<a id="ldap-authentication-with-gitlab-username"></a>

### 使用极狐GitLab 用户名进行 LDAP 身份验证

<!-- categories: System Access -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../administration/auth/ldap/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/215357)

{{< /details >}}

LDAP 用户现在可以使用其极狐GitLab 用户名对请求进行身份验证。此前，如果极狐GitLab 用户名与其 LDAP 用户名不匹配，极狐GitLab 会返回身份验证错误。此变更可帮助用户在极狐GitLab 和 LDAP 系统中保持独立的命名约定，而不会中断审批工作流。

<a id="support-for-sha256-saml-certificates"></a>

### 支持 SHA256 SAML 证书

<!-- categories: System Access -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../integration/saml.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/524624)

{{< /details >}}

极狐GitLab 现在会自动检测并支持群组 SAML 身份验证的 SHA1 和 SHA256 证书指纹。这保持了对现有 SHA1 指纹的向后兼容性，同时增加了对更安全的 SHA256 指纹的支持。此升级对于为即将发布的 ruby-saml 2.x 版本（该版本将把 SHA256 设为默认值）做好准备至关重要。

<a id="granular-permissions-for-job-tokens-in-beta"></a>

### 作业令牌的精细权限（测试版）

<!-- categories: Permissions -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/jobs/fine_grained_permissions.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/16199)

{{< /details >}}

流水线安全性变得更加灵活。作业令牌是临时凭证，用于提供对流水线中资源的访问权限。到目前为止，这些令牌会继承用户的完整权限，往往导致不必要的宽泛访问能力。

借助我们新的[作业令牌精细权限](../../ci/jobs/fine_grained_permissions.md)测试版功能，您现在可以精确控制作业令牌在项目中可以访问哪些特定资源。这使您可以在 CI/CD 工作流中实施最小权限原则，仅授予每个作业完成任务所需的最小访问权限。

我们正在积极寻求社区对此功能的反馈。如果您有疑问、想分享您的实施经验，或希望就潜在改进直接与我们的团队交流，请访问我们的[反馈议题](https://gitlab.com/gitlab-org/gitlab/-/issues/519575)。

<a id="new-permissions-for-custom-roles"></a>

### 自定义角色的新权限

<!-- categories: Permissions -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/custom_roles/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/14746)

{{< /details >}}

您可以使用[管理受保护环境](https://gitlab.com/gitlab-org/gitlab/-/issues/471385)权限创建自定义角色。自定义角色允许您仅授予用户完成任务所需的特定权限。这有助于您定义适合群组需求的自定义角色，并可以减少需要维护者或所有者角色的用户数量。

<a id="new-cicd-analytics-view-for-projects-in-limited-availability"></a>

### 项目的新 CI/CD 分析视图（限量提供）

<!-- categories: Fleet Visibility -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 链接: [文档](../../user/analytics/ci_cd_analytics.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/444468)

{{< /details >}}

重新设计的 CI/CD 分析视图改变了您的开发团队分析、监控和优化流水线性能与可靠性的方式。开发者可以在极狐GitLab UI 中访问直观的可视化，了解性能趋势和可靠性指标。将这些见解嵌入您的项目代码仓库，可消除打断开发者心流的上下文切换。团队可以识别并解决拖累生产力的流水线瓶颈。此增强功能可带来更快的开发周期、更好的协作，以及以数据为依据的信心，帮助您优化极狐GitLab 中的 CI/CD 工作流。

<a id="gitlab-runner-180"></a>

### 极狐GitLab Runner 18.0

<!-- categories: GitLab Runner Core -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 链接: [文档](https://gitlab.cn/docs/runner/)

{{< /details >}}

我们今天还发布了极狐GitLab Runner 18.0！极狐GitLab Runner 是高度可扩展的构建代理，负责运行您的 CI/CD 作业并将结果发送回极狐GitLab 实例。极狐GitLab Runner 与极狐GitLab CI/CD 协同工作，后者是极狐GitLab 中包含的开源持续集成服务。

<a id="whats-new"></a>

#### 新增内容

- [将 `ConfigurationError` 和 `ExitCodeInvalidConfiguration` 添加到极狐GitLab Runner 构建错误分类中](https://gitlab.com/gitlab-org/gitlab/-/issues/514297)
- [改进缓存上传到云存储失败时的云提供商错误消息](https://gitlab.com/gitlab-org/gitlab-runner/-/merge_requests/5527)

<a id="bug-fixes"></a>

#### 缺陷修复

- [极狐GitLab Runner 即使在禁止的情况下也能使用缓存的镜像](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/38706)

所有变更的列表位于极狐GitLab Runner [CHANGELOG](https://gitlab.com/gitlab-org/gitlab-runner/blob/18-0-stable/CHANGELOG.md)中。
