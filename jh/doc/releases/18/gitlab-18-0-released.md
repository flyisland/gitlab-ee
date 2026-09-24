---
stage: Release Notes
group: Monthly Release
date: 2025-05-15
title: "极狐GitLab 18.0 发布说明"
description: "GitLab 18.0 released with GitLab Premium and Ultimate with Duo"
---

<!-- markdownlint-disable -->
<!-- vale off -->

2025 年 5 月 15 日，极狐GitLab 18.0 发布，带来以下新功能。

此外，我们要感谢所有贡献者，特别是本月的杰出贡献者。

<a id="this-month’s-notable-contributor-michael-hofer"></a>

## 本月的杰出贡献者：Michael Hofer

Michael Hofer 既是顶尖贡献者，也是社区领袖，积极支持着极狐GitLab 的开源使命。
今年他已贡献[超过 50 次](https://contributors.gitlab.com/users/karras?fromDate=2025-01-01&toDate=2025-05-12)，
他的工作增强了极狐GitLab 的 Geo 功能和基于 OpenBao 的密钥管理器。
他在[四月 Hackathon](https://contributors.gitlab.com/hackathon?hackathonName=2025_04) 中拔得头筹，同时还为其他贡献者提供支持并领导社区项目。

“我真心感激每个人都能为极狐GitLab 做出贡献！”Michael 说。
“与团队合作非常愉快，过程充满乐趣，每个人都非常乐于助人，尤其是当我们携手推动 OpenBao 和 SLSA 这样的开源计划时。”

Michael 是 [Adfinis](https://adfinis.com/en/) 的首席技术官，这家国际 IT 服务提供商专注于规划、构建和运行关键的开源工作负载。
他热衷于促进协作，并在组织间推广开源解决方案。

最近，Adfinis 参加了极狐GitLab 的 [Co-Create 项目](https://gitlab.cn/community/co-create/)，该项目将组织与极狐GitLab 的产品及工程团队配对，
共同构建极狐GitLab。
“我们强烈推荐所有组织参与 Co-Create，”Michael 说。“它带来了一系列出色的贡献，包括无根 Podman 构建、Glimmer 语法高亮以及其他改进。”

“Geo 团队非常欣赏并享受与 Michael 合作，”极狐GitLab 工程经理 [Lucie Zhao](https://gitlab.com/luciezhao) 表示，她提名 Michael 获得这一荣誉。
“凭借他在过去几个里程碑中的出色贡献，他已经成为我们团队中最知名的社区贡献者。”

极狐GitLab 团队成员 [Lee Tickett](https://gitlab.com/leetickett-gitlab)、[Chloe Fons](https://gitlab.com/c_fons) 和 [Alex Scheel](https://gitlab.com/cipherboy-gitlab) 支持了这一提名。
Alex 补充道：“Michael 在 OpenBao 中的领导力使我们能够有效协作，为客户提供符合极狐GitLab 价值观的、透明的密钥管理解决方案。”

感谢 Michael 和 Adfinis 团队共同打造极狐GitLab！

<a id="primary-features"></a>

## 主要功能

<a id="gitlab-premium-and-ultimate-with-duo"></a>

### 含 Duo 的极狐GitLab 专业版和旗舰版

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Add-ons: Duo Pro, Duo Enterprise
- Links: [Documentation](../../user/gitlab_duo/_index.md) | [Related issue](https://jihulab.com/gitlab-cn/gitlab/-/issues/538857)

{{< /details >}}

我们激动地宣布含 Duo 的极狐GitLab 专业版和含 Duo 的极狐GitLab 旗舰版。极狐GitLab 专业版和旗舰版现在包含 AI 原生功能。

极狐GitLab 的 AI 原生功能包括 IDE 中的代码建议和 Chat。开发团队可以使用这些功能来：

- 分析、理解和解释代码
- 更快地编写安全代码
- 快速生成测试以保持代码质量
- 轻松重构代码以提升性能或使用特定库

<a id="repository-x-ray-now-available-on-gitlab-duo-self-hosted"></a>

### 自部署极狐GitLab Duo 现已支持 Repository X-Ray

{{< details >}}

- Tier: 专业版，旗舰版
- Add-ons: Duo Enterprise
- Links: [Documentation](../../user/project/repository/code_suggestions/repository_xray.md) | [Related epic](https://jihulab.com/groups/gitlab-cn/-/epics/17756)

{{< /details >}}

您现在可以在自部署极狐GitLab Duo 上配合代码建议使用 Repository X-Ray。此功能在自部署极狐GitLab Duo 中为 beta 阶段，并在极狐GitLab 私有化部署实例上正式可用。

<a id="automatic-reviews-with-duo-code-review"></a>

### 使用 Duo Code Review 的自动审查

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Add-ons: Duo Enterprise
- Links: [Documentation](../../user/project/merge_requests/duo_in_merge_requests.md)

{{< /details >}}

Duo Code Review 在审查过程中提供了宝贵的见解，但目前需要您在每个合并请求上手动请求审查。

您现在可以配置极狐GitLab Duo Code Review 来自动对合并请求进行审查，方法是更新项目的合并请求设置。启用后，Duo Code Review 会自动审查合并请求，除非：

- 合并请求标记为草稿。
- 合并请求没有包含任何更改。

自动审查可确保您项目中的所有代码都经过审查，从而持续提高整个代码库的代码质量。

<a id="code-suggestions-prompt-caching"></a>

### 代码建议提示缓存

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Add-ons: Duo Pro, Duo Enterprise
- Links: [Documentation](../../user/project/repository/code_suggestions/_index.md#prompt-caching) | [Related epic](https://jihulab.com/groups/gitlab-cn/-/epics/17489)

{{< /details >}}

代码建议现在包含提示缓存。提示缓存通过避免重新处理已缓存的提示和输入数据，显著改善了代码补全的延迟。缓存数据不会被记录到任何持久性存储中，您还可以在极狐GitLab Duo 设置中选择禁用提示缓存。

<a id="improved-duo-code-review-context"></a>

### 改进的 Duo Code Review 上下文

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Add-ons: Duo Enterprise
- Links: [Documentation](../../user/project/merge_requests/duo_in_merge_requests.md)

{{< /details >}}

Duo Code Review 现在提供了更全面的上下文，以实现更好的分析。
主要改进如下：

- 包含合并请求的标题和描述，以更好地理解拟议更改的目的。
- 同时检查所有差异以识别跨文件关联并减少误报。
- 提供已更改文件的完整内容，以理解修改如何适应现有代码模式。

这些改进减少了不准确的建议，并提供了更相关、更高质量的代码审查。

<a id="scale-and-deployments"></a>

## 扩展与部署

<a id="list-only-enterprise-users-for-contributions-reassignment-on-gitlabcom"></a>

### 在 JihuLab.com 上仅列出企业用户以进行贡献重新分配

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [Documentation](../../user/group/import/direct_transfer_migrations.md#user-membership-mapping) | [Related issue](https://jihulab.com/gitlab-cn/gitlab/-/issues/510673)

{{< /details >}}

在此版本中，我们改进了占位用户映射体验，将用户选择下拉列表缩小到仅与顶级群组关联的企业用户。
此前，在将贡献重新分配给 JihuLab.com 导入的用户时，您会在下拉列表中看到平台上的所有活跃用户，这使得识别正确用户变得困难，尤其是在 SCIM 供应修改了用户名的情况下。现在，如果您的顶级群组使用了企业用户功能，下拉列表将只显示由您组织认领的用户，从而显著减少用户重新分配过程中出错的可能性。
同样的范围也适用于基于 CSV 的重新分配，防止意外分配给组织外的用户。

<a id="delete-groups-and-placeholder-users"></a>

### 删除群组和占位用户

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [Documentation](../../user/import/mapping/post_migration_mapping.md#placeholder-user-deletion) | [Related issue](https://jihulab.com/gitlab-cn/gitlab/-/issues/473256)

{{< /details >}}

在极狐GitLab 18.0 中，当您删除顶级群组时，与该群组关联的占位用户也会被删除。如果占位用户也关联到其他项目，则他们只会从顶级群组中被移除。
这样一来，不必要的占位用户将被移除，而不会破坏其他项目的历史记录或归属。

<a id="gitlab-chart-90-released-with-breaking-changes"></a>

### 极狐GitLab chart 9.0 发布，包含破坏性变更

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [Documentation](https://gitlab.cn/docs/charts/releases/9_0/) | [Related issue](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/5927)

{{< /details >}}

- [破坏性变更](../../update/deprecations.md#postgresql-14-和-15-不再支持): 已移除对 PostgreSQL 14 和 15 的支持。升级前请确保您运行的是 PostgreSQL 16。
- [破坏性变更](../../update/deprecations.md#prometheus-子图的重要更新): 捆绑的 Prometheus chart 已从 15.3 更新到 27.11。随此升级，Prometheus 版本也从 2.38 更新到 3.0。需要手动步骤才能完成升级。如果您启用了 Alertmanager、Node Exporter 或 Pushgateway，还必须更新您的 Helm 值。有关更多信息，请参阅[迁移指南](https://gitlab.cn/docs/charts/releases/9_0.html#prometheus-升级)。
- [破坏性变更](../../update/deprecations.md#回退支持-gitlab-nginx-chart-控制器镜像版本-131): 默认的 NGINX 控制器镜像已从 1.3.1 更新到 1.11.2。如果您正在使用极狐GitLab NGINX chart，并且已设置了自己的 NGINX RBAC 规则，则必须存在新的 RBAC 规则。有关更多信息，请参阅[升级指南](https://gitlab.cn/docs/charts/releases/8_0/#upgrade-to-86x-851-843-836)以了解更多信息。

<a id="deletion-protection-available-for-all-users"></a>

### 所有用户均可使用删除保护

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [Documentation](../../administration/settings/visibility_and_access_controls.md#deletion-protection) | [Related epic](https://jihulab.com/groups/gitlab-cn/-/epics/17208) | [Related issue](https://jihulab.com/gitlab-cn/gitlab/-/issues/526405)

{{< /details >}}

项目和群组的延迟删除现已成为一项核心安全功能，适用于所有极狐GitLab 用户，包括基础版用户。在已删除的群组和项目被永久移除之前，会提供一段宽限期（在 JihuLab.com 上为 7 天）。此功能允许您从意外删除中恢复，而无需进行复杂的恢复操作。

通过将数据安全作为核心功能，极狐GitLab 能够更好地保护您的工作免受数据丢失事件的影响。

<a id="delayed-project-deletion-for-user-namespaces"></a>

### 用户命名空间的延迟项目删除

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [Documentation](../../user/project/working_with_projects.md#delete-a-project) | [Related issue](https://jihulab.com/gitlab-cn/gitlab/-/issues/536244)

{{< /details >}}

延迟项目删除现在适用于用户命名空间中的项目（个人项目）。此前，这种防止意外数据丢失的保障仅适用于群组命名空间。当您在用户命名空间中删除项目时，该项目现在将进入“待删除”状态，持续时间由您的实例设置决定（JihuLab.com 上为 7 天），而不是被立即删除。这将创建一个恢复窗口，您可以在必要时恢复项目。

我们希望这项增强功能能让您在管理极狐GitLab 中的个人项目时更加安心。

<a id="new-active-parameter-for-groups-and-projects-rest-apis"></a>

### 群组和项目 REST API 的新 `active` 参数

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [Documentation](../../api/projects.md#list-projects)

{{< /details >}}

我们为群组和项目 REST API 添加了一个新的 `active` 参数，该参数简化了基于状态筛选群组的方式。当设置为 `true` 时，仅返回未归档或未标记为删除的群组或项目。当设置为 `false` 时，仅返回已归档或标记为删除的群组或项目。如果未定义该参数，则不应用任何筛选。这项增强功能通过简单的 API 调用即可针对特定状态，帮助您高效管理工作流程。

感谢 [@dagaranupam](https://gitlab.com/dagaranupam) 将此参数添加到项目 API。

<a id="rate-limits-for-groups-projects-and-users-api"></a>

### 群组、项目和用户 API 的速率限制

{{< details >}}

- Tier: 基础版，Silver，Gold
- Offering: JihuLab.com
- Links: [Documentation](../../user/jihulab_com/_index.md#jihulabcom-specific-rate-limits) | [Related issue](https://jihulab.com/gitlab-cn/gitlab/-/issues/461316)

{{< /details >}}

我们为项目、群组和用户增加了 API 速率限制，以提高平台稳定性和所有用户的性能。这些更改是为了应对不断增加的、影响我们服务的 API 流量。

这些限制是根据平均使用模式精心设定的，应为大多数用例提供足够的容量。如果您超过这些限制，将收到“429 Too Many Requests”的响应。

有关具体速率限制和实施信息的完整详情，请[阅读相关博客文章](https://about.gitlab.com/blog/rate-limitations-announced-for-projects-groups-and-users-apis/)。

<a id="unified-devops-and-security"></a>

## 统一 DevOps 与安全

<a id="security-scanners-now-support-mr-pipelines"></a>

### 安全扫描器现已支持 MR 流水线

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [Documentation](../../user/application_security/detect/roll_out_security_scanning.md)

{{< /details >}}

您现在可以选择在[合并请求 (MR) 流水线](../../ci/pipelines/merge_request_pipelines.md)中运行[应用安全测试 (AST) 扫描器](../../user/application_security/detect/_index.md)。
为了尽量减少对流水线的影响，这是一个您可以选择加入的行为。

以前，默认行为取决于您是使用[稳定版还是最新版 CI/CD 模板](../../user/application_security/detect/security_configuration.md#template-editions)来启用扫描器：

- 在稳定模板中，扫描作业仅在分支流水线中运行。不支持 MR 流水线。
- 在最新模板中，扫描作业在 MR 打开时于 MR 流水线中运行，并在没有关联 MR 时于分支流水线中运行。您无法控制此行为。

现在，新的选项 `AST_ENABLE_MR_PIPELINES` 允许您控制是否在 MR 流水线中运行作业。
稳定模板和最新模板的默认行为保持不变。具体来说：

- 稳定模板默认情况下继续在分支流水线中运行扫描作业，但您可以设置 `AST_ENABLE_MR_PIPELINES: "true"`，以便在 MR 打开时改用 MR 流水线。
- 最新模板默认情况下在 MR 打开时继续在 MR 流水线中运行扫描作业，但您可以设置 `AST_ENABLE_MR_PIPELINES: "false"` 以改用分支流水线。

此改进适用于除 API Discovery（`API-Discovery.gitlab-ci.yml`）之外的所有安全扫描模板，该模板当前默认为 MR 流水线。
我们还更改了 API Discovery 模板，使其与极狐GitLab 18.0 中的其他稳定模板保持一致，默认使用分支流水线。

<a id="display-and-filter-archived-projects-in-the-compliance-projects-report"></a>

### 在合规项目报告中显示和筛选已归档项目

{{< details >}}

- Tier: 旗舰版，专业版
- Offering: JihuLab.com
- Links: [Documentation](../../user/compliance/compliance_center/compliance_projects_report.md#filter-the-compliance-projects-report) | [Related issue](https://jihulab.com/gitlab-cn/gitlab/-/issues/500520)

{{< /details >}}

在合规项目报告中，您可以查看应用于群组或子群组内项目的合规框架。

然而，该报告以前无法显示项目是否已归档，而这对于管理活动项目和已归档项目的合规性来说可能是很有用的信息。

因此，我们添加了一个指示器来显示项目是否已归档。这将为您在审查活动项目和已归档项目的合规框架时提供更好的可见性和上下文。

此功能包括：

- 合规项目报告中每个项目的已归档状态徽章，用以显示项目是否已归档。
- 一个筛选器，允许您在已归档、未归档或所有项目之间切换。

<a id="create-a-workspace-from-merge-requests"></a>

### 从合并请求创建工作区

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [Documentation](../../user/workspace/configuration.md#create-a-workspace)

{{< /details >}}

您现在可以通过新的 **在 Workspace 中打开** 选项，直接从合并请求创建工作区。此功能会自动配置一个工作区，其中包含合并请求的分支和上下文，使您能够：

- 在完全配置好的环境中审查代码更改。
- 在合并请求分支上运行测试，以验证功能。
- 在无需本地设置的情况下对合并请求进行额外修改。

<a id="view-open-merge-requests-targeting-files"></a>

### 查看针对文件的开放合并请求

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [Documentation](../../user/project/repository/files/_index.md#view-open-merge-requests-for-a-file) | [Related issue](https://jihulab.com/gitlab-cn/gitlab/-/issues/448868)

{{< /details >}}

以前，在处理代码文件时，您无法了解其他分支中还有谁在修改同一文件。这种缺乏可见性的情况导致合并冲突、重复工作和低效协作。

现在，您可以轻松识别所有修改您正在仓库中查看的文件的开放合并请求。此功能可帮助您：

- 在潜在合并冲突发生之前识别它们。
- 避免重复进行已经在进行中的工作。
- 通过提供对进行中更改的可见性来改进协作。

一个徽章会显示修改该文件的开放合并请求数量，悬停在其上会弹出一个包含这些合并请求列表的弹出框。

<a id="shared-kubernetes-namespace-for-workspaces"></a>

### 工作区的共享 Kubernetes 命名空间

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [Documentation](../../user/workspace/settings.md#shared_namespace)

{{< /details >}}

您现在可以在共享的 Kubernetes 命名空间中创建极狐GitLab 工作区。这消除了为每个工作区创建新命名空间的需要，并且无需授予代理提升的 ClusterRole 权限。借助此功能，您可以更轻松地在安全或受限环境中采用工作区，为扩展提供了一条更简单的路径。

要启用共享命名空间，请在您的代理配置文件中设置 `shared_namespace` 字段，以指定您希望用于所有工作区的 Kubernetes 命名空间。

感谢通过[极狐GitLab Co-Create 项目](https://gitlab.cn/community/co-create/)帮助构建此功能的六位社区贡献者！

<a id="improved-pod-status-visualizations-in-the-dashboard-for-kubernetes"></a>

### Kubernetes Dashboard 中改进的 Pod 状态可视化

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [Documentation](../../ci/environments/kubernetes_dashboard.md) | [Related issue](https://jihulab.com/gitlab-cn/gitlab/-/issues/525081)

{{< /details >}}

您可以使用 Kubernetes Dashboard 来监控已部署的应用程序。到目前为止，像 `CrashLoopBackOff` 或 `ImagePullBackOff` 这样的容器错误的 Pod 会显示为“Pending”或“Running”状态，这使得在不使用 `kubectl` 的情况下难以识别问题部署。

在极狐GitLab 18.0 中，UI 中的错误状态会显示特定容器的状态，类似于 `kubectl` 输出。现在，您无需离开极狐GitLab 界面即可快速识别并排查故障 Pod。

<a id="exclude-packages-from-license-approval-rules"></a>

### 将软件包排除在许可证批准规则之外

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [Documentation](../../user/application_security/policies/merge_request_approval_policies.md#license_finding-rule-type) | [Related epic](https://jihulab.com/groups/gitlab-cn/-/epics/10203)

{{< /details >}}

在合并请求批准策略中，这项对许可证批准策略的新增强功能为法律与合规团队提供了对哪些软件包可以使用特定许可证的更多控制。您现在可以为预先批准的软件包创建例外，即使它们使用的许可证通常会被您组织的策略阻止。

以前，在许可证批准策略中，如果您阻止了像 AGPL-3.0 这样的许可证，它将在您组织内的所有软件包中被阻止。这在以下情况下带来了挑战：

- 您的法律团队预先批准了特定软件包，但这些软件包带有原本受限的许可证。
- 您需要在数百个项目中使用同一个软件包。
- 不同的团队需要不同的许可证例外。

通过此版本，您可以在保持严格许可证治理的同时允许必要的例外，从而显著减少批准瓶颈和手动审查。例如，您可以：

- 使用 Package URL (PURL) 格式为您的许可证批准规则定义特定于软件包的例外。
- 允许特定软件包（或软件包版本）使用原本受限的许可证。
- 阻止特定软件包（或软件包版本）使用通常允许的许可证。

要添加例外，在创建或编辑许可证批准策略时请遵循以下工作流程：

1. 在您的群组中，前往 **安全与合规** > **策略**
1. 创建或编辑许可证批准策略。
1. 在可视化编辑器中找到新的软件包例外选项，或在 YAML 模式下进行配置。
1. 为许可证选择允许列表或拒绝列表模式。
1. 将特定许可证添加到您的策略中。
1. 对于每个许可证，以 PURL 格式定义软件包例外（例如，`pkg:npm/@angular/animation@12.3.1`）。
1. 指定将这些软件包包含在许可证规则中还是排除在外。

然后，策略会强制执行您的许可证规则，同时遵守定义的例外情况，为您在整个组织内提供精细的许可证合规控制。
{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/glql/_index.md) | 相关史诗

{{< /details >}}

我们对极狐GitLab 查询语言 (GLQL) 视图进行了重大改进。这些改进包括支持：

- 所有日期类型的 `>=` 和 `<=` 操作符
- 视图中的 **视图操作** 下拉菜单
- **重新加载** 操作
- 字段别名
- 在 GLQL 表中将列别名为自定义名称

我们欢迎您对此增强功能及 GLQL 视图的整体反馈。

### Pages 模板改进

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/pages/getting_started/pages_new_project_template.md#project-templates)

{{< /details >}}

极狐GitLab 为[热门静态站点生成器的模板](https://jihulab.com/pages)提供支持。我们使用评分框架深入评估了现有模板，并精简列表，仅包含最受欢迎的模板。

精简极狐GitLab Pages 的模板简化了网站创建流程。使用模板，即使技术知识有限，也能快速上线专业外观的站点。增强的模板还提供现代、响应式的设计，无需定制开发工作。

### 使用 Jira 集成 API 从漏洞配置 Jira 议题

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../api/project_integrations.md#jira-issues) | 相关议题

{{< /details >}}

以前，您必须在 **项目设置** 页面配置集成以[从漏洞创建 Jira 议题](../../integration/jira/configure.md#create-a-jira-issue-for-a-vulnerability)。

现在，您可以通过项目集成 API 配置此集成，从而自动进行设置。

### 提高重新检测漏洞的可追溯性

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/vulnerabilities/_index.md#vulnerability-status-values) | 相关议题

{{< /details >}}

以前，当已解决的漏洞被重新检测并更改状态时，漏洞详情不会提供信息来指示状态变更的时间及原因。

现在，当已解决的漏洞因出现在新扫描中而变更状态时，极狐GitLab 会在漏洞历史中添加系统备注。这些附加信息有助于用户理解漏洞为何变更状态。

### 从漏洞报告将漏洞批量添加到议题

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/vulnerability_report/_index.md#add-vulnerabilities-to-an-existing-issue) | 相关史诗

{{< /details >}}

在此版本中，您现在可以从漏洞报告将漏洞批量添加到新的或现有的极狐GitLab 议题。
您现在可以将多个议题和漏洞关联起来。此外，相关漏洞现在会列在议题页面中。

### 禁用用户邀请

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../administration/settings/visibility_and_access_controls.md) | 相关议题

{{< /details >}}

您现在可以移除邀请成员加入群组或项目的能力。

- 在 JihuLab.com 上，此设置由拥有企业用户的群组所有者配置，并应用于顶级群组内的任何子群组或项目。启用此设置后，任何用户都不能发送邀请。
- 在极狐GitLab 私有化部署上，此设置由管理员配置，并应用于整个实例。管理员仍然可以直接邀请用户。

此功能帮助组织严格管控成员访问权限。

### 使用极狐GitLab 用户名进行 LDAP 认证

{{< details >}}

- Tier: 专业版，旗舰版
- Links: [文档](../../administration/auth/ldap/_index.md) | 相关议题

{{< /details >}}

LDAP 用户现在可以使用其极狐GitLab 用户名认证请求。以前，如果极狐GitLab 用户名与其 LDAP 用户名不匹配，极狐GitLab 会返回认证错误。这一变更帮助用户在极狐GitLab 和 LDAP 系统中保持不同的命名约定，而不会中断审批工作流。

### 支持 SHA256 SAML 证书

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../integration/saml.md) | 相关议题

{{< /details >}}

极狐GitLab 现在自动检测并支持用于群组 SAML 认证的 SHA1 和 SHA256 证书指纹。这既保持了对现有 SHA1 指纹的向后兼容性，又增加了对更安全的 SHA256 指纹的支持。此次升级对于准备即将到来的 ruby-saml 2.x 版本（将 SHA256 设为默认值）至关重要。

### 作业令牌的细粒度权限（测试版）

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../ci/jobs/fine_grained_permissions.md) | 相关史诗

{{< /details >}}

流水线安全性变得更加灵活。作业令牌是用于在流水线中访问资源的临时凭证。到目前为止，这些令牌从用户那里继承了完整的权限，通常导致过宽的访问能力。

通过我们新的[作业令牌细粒度权限](../../ci/jobs/fine_grained_permissions.md)测试版功能，您现在可以精确控制作业令牌在项目内可以访问哪些特定资源。这使您能够在 CI/CD 工作流中实施最小权限原则，仅授予每个作业完成任务所需的最低访问权限。

我们正在积极收集有关此功能的社区反馈。如果您有问题，想分享实施经验，或希望与我们的团队直接讨论潜在改进，请访问我们的[反馈议题](https://gitlab.com/gitlab-org/gitlab/-/issues/519575)。

### 自定义角色的新权限

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/custom_roles/_index.md) | 相关史诗

{{< /details >}}

您可以创建具有[管理受保护环境](https://gitlab.com/gitlab-org/gitlab/-/issues/471385)权限的自定义角色。
自定义角色允许您仅授予用户完成任务所需的特定权限。
这有助于您定义适合群组需求角色，并可减少需要所有者或维护者角色的用户数量。

### 项目的新 CI/CD 分析视图（有限可用性）

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../user/analytics/ci_cd_analytics.md) | 相关议题

{{< /details >}}

重新设计的 CI/CD 分析视图改变了您的开发团队分析、监控和优化流水线性能及可靠性的方式。开发者可以在极狐GitLab UI 中访问直观的可视化，显示性能趋势和可靠性指标。将这些洞察嵌入项目仓库中，消除了干扰开发者流程的上下文切换。团队可以识别并解决消耗生产力的流水线瓶颈。这一增强功能可以加快开发周期、提升协作，并让您以数据驱动的方式自信地优化极狐GitLab 中的 CI/CD 工作流。

### GitLab Runner 18.0

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](https://gitlab.cn/docs/runner)

{{< /details >}}

我们今天还发布了 GitLab Runner 18.0！GitLab Runner 是高度可扩展的构建代理，用于运行您的 CI/CD 作业并将结果发送回极狐GitLab 实例。GitLab Runner 与极狐GitLab CI/CD 配合使用，极狐GitLab CI/CD 是极狐GitLab 自带的开源持续集成服务。

#### 新增功能

- [在 GitLab Runner 构建错误分类中添加 `ConfigurationError` 和 `ExitCodeInvalidConfiguration`](https://gitlab.com/gitlab-org/gitlab/-/issues/514297)
- [改进云存储缓存上传失败时的云提供商错误消息](https://gitlab.com/gitlab-org/gitlab-runner/-/merge_requests/5527)

#### 错误修复

- [即使不允许，GitLab Runner 仍可能使用已缓存的镜像](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/38706)

所有更改的列表位于 GitLab Runner [CHANGELOG](https://jihulab.com/gitlab-cn/gitlab-runner/blob/18-0-stable/CHANGELOG.md) 中。

## 相关主题

- [错误修复](https://jihulab.com/groups/gitlab-cn/-/issues/?sort=updated_desc&state=closed&label_name%5B%5D=type%3A%3Abug&or%5Blabel_name%5D%5B%5D=workflow%3A%3Acomplete&or%5Blabel_name%5D%5B%5D=workflow%3A%3Averification&or%5Blabel_name%5D%5B%5D=workflow%3A%3Aproduction&milestone_title=18.0)
- [性能改进](https://jihulab.com/groups/gitlab-cn/-/issues/?sort=updated_desc&state=closed&label_name%5B%5D=bug%3A%3Aperformance&or%5Blabel_name%5D%5B%5D=workflow%3A%3Acomplete&or%5Blabel_name%5D%5B%5D=workflow%3A%3Averification&or%5Blabel_name%5D%5B%5D=workflow%3A%3Aproduction&milestone_title=18.0)
- [用户界面改进](https://papercuts.jihulab.com/?milestone=18.0)
- [弃用和删除](../../update/deprecations.md)
- [升级说明](../../update/versions/_index.md)