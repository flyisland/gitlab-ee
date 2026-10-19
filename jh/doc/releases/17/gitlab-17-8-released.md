---
stage: Release Notes
group: Monthly Release
date: 2025-01-16
title: "极狐GitLab 17.8 发布说明"
description: "GitLab 17.8 released with Enhance security with protected container repositories"
---

<!-- markdownlint-disable -->
<!-- vale off -->

2025 年 1 月 16 日，极狐GitLab 17.8 发布了以下功能。

此外，我们要感谢所有贡献者，包括本月的杰出贡献者。

## 本月的杰出贡献者

<a id="this-months-notable-contributor"></a>

每个人都可以[提名极狐GitLab 社区贡献者](https://gitlab.com/gitlab-org/developer-relations/contributor-success/team-task/-/issues/490)！
支持我们的活跃候选人，或添加新的提名！🙌

通过共创计划，[Océane Legrand](https://gitlab.com/oceane_scania) 一直与 Juan Pablo Gonzalez 合作，领导增强 Conan 软件包仓库功能集的工作。
他们的工作重点是使该功能接近 GA 就绪状态，同时实现 Conan 版本 2 支持。
这次合作展示了共创计划如何推动极狐GitLab 软件包仓库功能的重大改进。

他们由极狐GitLab 贡献者成功团队高级全栈工程师 [Raimund Hook](https://gitlab.com/stingrayza) 提名，他强调了他们在 Conan 软件包仓库功能上的持续合作和不断迭代。
他们的工作体现了极狐GitLab 价值观，并将惠及平台上所有 Conan 用户。

Océane Legrand 是 Scania 的全栈开发人员，负责维护他们在 AWS 上的私有化部署极狐GitLab 实例。
Océane 说：“我在开源方面的工作对极狐GitLab 和 Scania 都有影响。”
“通过共创计划做出贡献让我获得了新技能，比如 Ruby 经验和后台迁移。当我的 Scania 团队在升级过程中遇到问题时，我能够帮助排查，因为我已经通过该计划遇到过这个问题。”

[详细了解极狐GitLab 的共创计划](https://about.gitlab.com/community/co-create/)，客户可以直接与我们的产品和工程团队合作开发新功能并增强现有功能。

## 主要功能

<a id="primary-features"></a>

### 使用受保护的容器仓库增强安全性

<a id="enhance-security-with-protected-container-repositories"></a>

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../user/packages/container_registry/container_repository_protection_rules.md)

{{< /details >}}

我们非常高兴地宣布推出受保护的容器仓库，这是极狐GitLab 容器镜像仓库中的一项新功能，旨在解决管理容器镜像时的安全和控制挑战。组织经常面临敏感容器仓库的未授权访问、意外修改、缺乏细粒度控制以及难以维持合规性等问题。该解决方案通过严格的访问控制、对推送、拉取和管理操作的细粒度权限以及与极狐GitLab CI/CD 流水线的无缝集成，提供了增强的安全性。

受保护的容器仓库通过降低安全漏洞风险和关键资产的意外更改，为用户带来价值。此功能在保持安全性的同时不牺牲开发速度，从而简化工作流程，改善容器镜像仓库的整体治理，并让您放心，重要的容器资产已根据组织需求得到保护。

此功能和[受保护的软件包](https://gitlab.com/groups/gitlab-org/-/epics/5574)功能均来自 `gerardo-navarro` 和西门子团队的社区贡献。感谢 Gerardo 和西门子团队的其他成员对极狐GitLab 的众多贡献！如果您有兴趣了解更多关于 Gerardo 和西门子团队如何贡献此更改的信息，请观看此视频，其中 Gerardo 根据他作为外部贡献者的经验分享了贡献极狐GitLab 的经验和最佳实践。

### 列出与发布相关的部署

<a id="list-the-deployments-related-to-a-release"></a>

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/releases/_index.md)

{{< /details >}}

虽然极狐GitLab 长期以来一直支持从 Git 标签创建发布并跟踪部署，但这些信息以前分散在多个难以整合的地方。现在，您可以在发布页面上直接查看与发布相关的所有部署。发布经理可以快速验证发布已部署到何处以及哪些环境正在等待部署。这补充了现有的部署页面集成，该集成显示标记部署的发布说明。

我们要感谢 [Anton Kalmykov](https://gitlab.com/antonkalmykov) 为极狐GitLab 贡献了这两个功能。

### 机器学习模型实验跟踪 GA

<a id="machine-learning-model-experiments-tracking-in-ga"></a>

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../user/project/ml/experiment_tracking/_index.md)

{{< /details >}}

在创建机器学习模型时，数据科学家经常尝试不同的参数、配置和特征工程来提高模型性能。跟踪所有这些元数据和相关产物以便数据科学家以后能够复现实验并非易事。机器学习实验跟踪使他们能够将参数、指标和产物直接记录到极狐GitLab 中，从而方便以后访问，同时将所有实验数据保留在极狐GitLab 环境中。此功能现已正式发布，具有增强的数据显示、增强的权限、与极狐GitLab 的更深入集成以及错误修复。

### 大型 M2 Pro 托管 Runner 在 macOS 上（Beta）

<a id="large-m2-pro-hosted-runners-on-macos-beta"></a>

{{< details >}}

- Tier: Silver, Gold
- Offering: JihuLab.com
- Links: [文档](../../ci/runners/hosted_runners/macos.md)

{{< /details >}}

我们将 M2 Pro 性能带给移动 DevOps 团队！

与 M1 Runner 相比，性能提升高达 2 倍，与 x86-64 macOS Runner 相比，性能提升高达 6 倍，您可以在构建和部署应用程序时提高开发团队的速度。

完全集成到极狐GitLab CI/CD 并按需可用，团队现在可以更快地为 Apple 生态系统无缝创建、测试和部署应用程序。

立即试用新的 M2 Pro Runner，在 `.gitlab-ci.yml` 文件中使用 `saas-macos-large-m2pro` 作为标签。

## Agentic 核心

<a id="agentic-core"></a>

### 极狐GitLab MLOps Python 客户端 Beta

<a id="gitlab-mlops-python-client-beta"></a>

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](https://gitlab.com/gitlab-org/modelops/mlops/gitlab-mlops)

{{< /details >}}

数据科学家和机器学习工程师主要在 Python 环境中工作，但将他们的机器学习工作流程与极狐GitLab 的 MLOps 功能集成通常需要上下文切换并了解极狐GitLab 的 API 结构。这可能会在他们的开发过程中产生摩擦，并减慢他们跟踪实验、管理模型产物以及与团队成员协作的能力。

新的极狐GitLab MLOps Python 客户端为极狐GitLab 的 MLOps 功能提供了一个无缝的 Pythonic 接口。数据科学家现在可以直接从他们的 Python 脚本和笔记本与极狐GitLab 的[实验跟踪](../../user/project/ml/experiment_tracking/_index.md)和[模型仓库](../../user/project/ml/model_registry/_index.md)功能进行交互。该客户端包括：

- **极狐GitLab 实验跟踪**：在极狐GitLab 内轻松跟踪机器学习实验。
- **模型仓库集成**：在极狐GitLab 的模型仓库中注册和管理模型。
- **实验管理**：直接从客户端创建和管理实验。
- **运行跟踪**：轻松启动和监控训练运行。

这种集成使数据科学家能够专注于模型开发，同时自动将他们的 ML 生命周期元数据捕获到极狐GitLab 中。Python 客户端与现有的 ML 工作流程无缝协作，并且需要最少的设置，使极狐GitLab 的 MLOps 功能更易于数据科学社区访问。

我们欢迎更广泛的 Python 和数据科学社区在我们的[项目仓库](https://gitlab.com/gitlab-org/modelops/mlops/gitlab-mlops)中做出贡献并直接分享反馈。

## 扩展与部署

<a id="scale-and-deployments"></a>

### 查看待删除的子群组和项目

<a id="view-subgroups-and-projects-pending-deletion"></a>

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/group/_index.md#view-inactive-groups)

{{< /details >}}

当您将群组标记为删除时，您需要了解所有受影响的子群组和项目。以前，只有被标记为删除的群组会显示“待删除”标签，而其子群组和项目不会显示，这使得很难确定哪些内容计划被删除。

现在，当群组被标记为删除时，其所有子群组和项目都将显示“待删除”标签。这种改进的可见性有助于您在整个群组层次结构中快速区分活跃内容和即将删除的内容。

### 在议题或合并请求中跟踪多个待办事项

<a id="track-multiple-to-do-items-in-an-issue-or-merge-request"></a>

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/todos.md#actions-that-create-to-do-items)

{{< /details >}}

您现在可以在单个议题或合并请求中跟踪多个讨论和提及。通过新的多个待办事项功能，您将为每次提及或操作收到单独的待办事项，确保您不会错过重要的更新或需要您关注的请求。此增强功能可帮助您更有效地管理工作，并更高效地响应团队的需求。

### 群组的项目创建保护现在包括所有者

<a id="project-creation-protection-for-groups-now-includes-owners"></a>

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/group/_index.md#specify-who-can-add-projects-to-a-group)

{{< /details >}}

可以使用 **允许创建项目** 设置将项目创建限制为群组中的特定角色。所有者角色现在可用作选项，使您能够将新项目创建限制为具有群组所有者角色的用户。此角色以前在选择选项中不可用。

感谢 [@yasuk](https://gitlab.com/yasuk) 的社区贡献！

## 统一 DevOps 与安全

<a id="unified-devops-and-security"></a>

### 密钥检测现在包括修复步骤

<a id="secret-detection-now-includes-remediation-steps"></a>

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/secret_detection/_index.md)

{{< /details >}}

快速修复暴露的密钥对于最大限度地降低攻击者使用暴露的凭据侵入系统的风险非常重要。正确的修复需要多个步骤，而不仅仅是删除密钥，例如轮换凭据和调查潜在的未授权访问。为了帮助保护您的系统安全，密钥检测现在为每种检测到的密钥类型包含特定的修复步骤。此指导可帮助您系统地处理暴露问题并降低安全漏洞的风险。修复步骤将在流水线完成后显示在所有漏洞上。

### 查找解决漏洞的提交

<a id="find-the-commit-that-resolved-a-vulnerability"></a>

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/vulnerabilities/_index.md#vulnerability-resolution)

{{< /details >}}

以前，当不再检测到漏洞时，我们没有为用户提供查看漏洞何时何地得到解决的方法。
现在，我们显示一个指向解决漏洞的提交 SHA 的链接，从而提供更好的可追溯性和对解决过程的洞察。这使得安全团队和开发团队更容易协作，并更有效地管理漏洞。

### 使用角色将项目成员定义为代码所有者

<a id="use-roles-to-define-project-members-as-code-owners"></a>

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/codeowners/reference.md#add-a-role-as-a-code-owner)

{{< /details >}}

您现在可以在 `CODEOWNERS` 文件中使用角色作为代码所有者，以更有效地管理基于角色的专业知识和审批。无需列出单个用户或创建群组，您可以使用以下语法：

- `@@developers` - 引用所有具有开发者角色的用户。
- `@@maintainers` - 引用所有具有维护者角色的用户。
- `@@owners` - 引用所有具有所有者角色的用户。

例如，添加 `* @@maintainers` 要求仓库中所有更改都获得任何维护者的批准。

这简化了代码所有者管理，因为团队成员加入、离开或在项目中更改角色。`CODEOWNERS` 文件无需手动更新即可保持最新，因为极狐GitLab 会自动包含所有具有指定角色的用户。

### 在 Kubernetes 仪表板上查看暂停的 Flux 协调

<a id="view-paused-flux-reconciliations-on-the-dashboard-for-kubernetes"></a>

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../ci/environments/kubernetes_dashboard.md)

{{< /details >}}

以前，当您从 Kubernetes 仪表板暂停 Flux 协调时，没有明确的暂停状态指示器。我们向现有状态指示器集中添加了一个新的“已暂停”状态，清楚地显示 Flux 协调何时暂停，并提供对部署状态的更好可见性。

### 在 Kubernetes 仪表板上搜索 Pod

<a id="search-for-pods-on-the-dashboard-for-kubernetes"></a>

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../ci/environments/kubernetes_dashboard.md)

{{< /details >}}

在 Kubernetes 仪表板上，在大型部署中查找特定 Pod 可能非常耗时。一个新的搜索栏可让您按名称快速筛选 Pod。搜索适用于所有可用的 Pod，您可以将其与状态筛选器结合使用，以准确找到需要监控或排查的 Pod。

### 在合并请求审批策略中支持多个不同的审批操作

<a id="support-multiple-distinct-approval-actions-in-merge-request-approval-policies"></a>

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/policies/merge_request_approval_policies.md)

{{< /details >}}

以前，合并请求审批策略每个策略仅支持一个审批规则，允许一组审批者以“或”条件叠加。因此，强制执行来自不同角色、个人审批者或独立群组的分层安全审批更具挑战性。

通过此更新，您可以为每个合并请求审批策略创建最多五个审批规则，从而实现更灵活、更强大的审批策略。每个规则可以指定不同的审批者或角色，并且每个规则独立评估。例如，安全团队可以定义复杂的审批工作流程，例如要求来自 A 组的一名审批者和来自 B 组的一名审批者，或者来自特定角色的一名审批者和来自指定群组的一名审批者，从而确保在敏感工作流程中合规并增强控制。

此改进的示例用途包括：

- **不同角色审批：** 一个来自开发者角色的审批和一个来自维护者角色的审批。
- **角色和群组审批**：一个来自开发者或维护者的审批，以及一个来自安全群组成员的单独审批。
- **不同群组审批：** 一个来自 Python 专家群组成员的审批，以及另一个来自安全群组成员的单独审批。

### 极狐GitLab Pages 的主域名重定向

<a id="primary-domain-redirect-for-gitlab-pages"></a>

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/pages/_index.md#primary-domain)

{{< /details >}}

您现在可以在极狐GitLab Pages 中设置主域名，以自动将所有来自自定义域名的请求重定向到您的主域名。这有助于保持 SEO 排名，并通过将访问者引导至您的首选域名来提供一致的品牌体验，无论他们最初使用哪个 URL 访问您的站点。

### 使用受保护的软件包保护您的依赖项

<a id="safeguard-your-dependencies-with-protected-packages"></a>

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/packages/package_registry/package_protection_rules.md)

{{< /details >}}

我们非常高兴地推出对受保护的 PyPI 软件包的支持，这是一项旨在增强极狐GitLab 软件包仓库安全性和稳定性的新功能。在快节奏的软件开发世界中，意外修改或删除软件包可能会中断整个开发过程。受保护的软件包通过允许您保护最重要的依赖项免受意外更改来解决此问题。

从极狐GitLab 17.8 开始，您可以通过创建保护规则来保护 PyPI 软件包。如果软件包与保护规则匹配，则只有指定用户可以更新或删除该软件包。借助此功能，您可以防止意外更改，提高对监管要求的合规性，并通过减少手动监督的需求来简化工作流程。

### 史诗的可自定义颜色

<a id="customizable-colors-for-epics"></a>

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/group/epics/manage_epics.md#epic-color)

{{< /details >}}

您现在可以更灵活地对史诗进行分类，扩展的颜色选项集包括预定义值和自定义 RGB 或十六进制代码。这种增强的视觉自定义功能使您可以轻松地将史诗与团队、公司计划或层次结构级别关联起来，从而更轻松地在路线图和史诗板上确定优先级并组织工作。

您的管理员必须启用[史诗的新外观](../../user/group/epics/_index.md#epics-as-work-items)。

### 史诗祖先

<a id="epic-ancestors"></a>

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/group/epics/_index.md#relationships-between-epics-and-other-items)

{{< /details >}}

通过重新设计的祖先小部件，导航您的[史诗层次结构](../../user/group/epics/_index.md#relationships-between-epics-and-other-items)变得更加容易，该小部件现在以面包屑格式显眼地显示在每个史诗的顶部。您可以快速掌握史诗之间的关系，一目了然地查看直接父级和最终父级，帮助您保持对项目结构的清晰概览，并轻松在相关史诗之间移动。

您的管理员必须启用[史诗的新外观](../../user/group/epics/_index.md#epics-as-work-items)。

### 史诗健康状态

<a id="epic-health-status"></a>

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/group/epics/manage_epics.md#health-status)

{{< /details >}}

您现在可以通过史诗的新健康状态功能轻松传达项目的进度。通过将状态设置为“正常”、“需要注意”或“有风险”，您将获得史诗健康状况的快速视觉指示器，从而管理风险并让利益相关者了解项目的整体状态。

您的管理员必须启用[史诗的新外观](../../user/group/epics/_index.md#epics-as-work-items)。

### 史诗父级

<a id="epic-parent"></a>

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/group/epics/_index.md#relationships-between-epics-and-other-items)

{{< /details >}}

您现在可以像处理议题一样，直接从史诗中添加父级，轻松管理史诗层次结构。这种简化的流程为您组织工作提供了更大的灵活性，使您能够快速建立史诗之间的关系，并为项目维护清晰的结构。

您的管理员必须启用[史诗的新外观](../../user/group/epics/_index.md#epics-as-work-items)。

### 跟踪在史诗上花费的时间

<a id="track-time-spent-on-epics"></a>

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/time_tracking.md)

{{< /details >}}

您现在可以直接在史诗中跟踪时间，从而更精细地控制项目的时间管理。这项新功能允许您记录在项目不同方面花费的时间，帮助您监控进度、按计划进行，并在完成冲刺和里程碑时控制预算。

### 在史诗、议题和目标中的子项上显示迭代字段

<a id="show-iteration-field-on-child-items-in-epics-issues-and-objectives"></a>

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/group/iterations/_index.md)

{{< /details >}}

在查看史诗详情时，计划者需要能够看到哪些子议题已计划到迭代（冲刺）中，哪些尚未计划。这将使团队更容易确保所有已定义的工作都已安排到冲刺中。

对于史诗，您的管理员必须启用[史诗的新外观](../../user/group/epics/_index.md#epics-as-work-items)。

### 史诗的 Webhook

<a id="webhooks-for-epics"></a>

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/integrations/webhook_events.md)

{{< /details >}}

通过史诗 Webhook 增强您的工作流程自动化，当史诗发生更改时，您可以在首选工具中接收实时更新。通过将极狐GitLab 与其他服务集成，您可以增强协作，随时了解项目发展，并简化流程，而无需不断切换应用程序。

您的管理员必须启用[史诗的新外观](../../user/group/epics/_index.md#epics-as-work-items)。

### 将漏洞添加为支持的 Webhook 事件

<a id="add-vulnerabilities-as-supported-webhook-events"></a>

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/integrations/webhook_events.md#vulnerability-events)

{{< /details >}}

引入一个 Webhook 集成，为与漏洞相关的操作生成事件，以便您自动化并与外部资源集成。例如，当创建漏洞或漏洞状态更改时，会生成事件。

### 为 `override_ci` 策略强制执行集中式工作流规则

<a id="enforce-centralized-workflow-rules-for-the-override_ci-strategy"></a>

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/policies/pipeline_execution_policies.md#override_project_ci)

{{< /details >}}
{{< /details >}}

在流水线执行策略中，`override_ci` 策略现在支持使用工作流规则，以帮助对策略中定义的作业以及使用 `include:project` 时项目配置中定义的作业进行策略执行。通过在策略中定义工作流规则，你可以根据特定规则（例如配置阻止在项目中使用分支流水线的规则）过滤掉由流水线执行策略执行的作业。

为了将工作流规则的使用范围限制为仅针对策略中定义的作业，最佳实践是为作业定义规则，而不是在策略中全局定义。或者，你可以使用单独的 `include` 字段对作业和规则进行分组。

以前，在使用 `override_ci` 策略时，工作流规则只能应用于流水线执行策略中定义的作业。

`inject_ci` 策略保持不变，工作流规则只能用于控制策略作业何时执行，而不会影响项目的工作流规则。

<a id="make-skip_ci-configurable-for-pipeline-execution-policies"></a>

### 使 `skip_ci` 可用于流水线执行策略的配置

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [Documentation](../../user/application_security/policies/pipeline_execution_policies.md#skip_ci-type)

{{< /details >}}

我们为流水线执行策略（PEPs）引入了一个新的配置选项，该选项可以更灵活地处理 `[skip ci]` 指令。此功能解决了某些自动化流程（例如语义发布）需要绕过流水线执行，同时仍确保执行关键的安全与合规检查的场景。

要使用此功能，请在流水线执行策略 YAML 配置中将 `skip_ci` 设置为 `allowed: false`，或在策略编辑器中启用 **阻止用户跳过流水线**。然后，指定允许使用 `[skip ci]` 的用户或服务账号。默认情况下，所有用户都将被阻止跳过流水线执行作业，除非他们在 `skip_ci` 配置中作为例外被排除。

<a id="manage-concurrency-of-scheduled-scan-execution-pipelines"></a>

### 管理计划扫描执行流水线的并发性

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [Documentation](../../user/application_security/policies/scan_execution_policies.md#concurrency-control)

{{< /details >}}

为了提高全局计划扫描执行策略的可扩展性，我们引入了一项新功能，可以在扫描执行策略中配置时间窗口。`time_window` 属性定义了策略创建和执行新计划的时间段，以确保最佳性能。

要使用新属性，请使用 YAML 模式更新你的策略，并遵循 [`time_window` 架构](../../user/application_security/policies/scan_execution_policies.md#time_window-schema)。你可以为计划应运行的时间窗口提供一个以秒为单位的值。例如，`86400` 表示 24 小时的时间窗口。然后提供 `distribution: random` 字段和值，以强制计划在定义的时间窗口内随机时间执行。

<a id="scaling-ui-performance-for-the-frameworks-report-tab-in-the-compliance-center"></a>

### 提升合规中心“框架”报告标签页的 UI 性能

{{< details >}}

- Tier: 旗舰版，专业版
- Offering: JihuLab.com
- Links: [Documentation](../../user/compliance/compliance_center/compliance_frameworks_report.md)

{{< /details >}}

在极狐GitLab 17.8 中，我们对后端进行了更改，以确保即使在合规中心的 **框架** 报告标签页中有上千个合规框架，合规中心也能保持快速响应。

此外，当你在 **框架** 标签页中点击某个框架以获取更多信息时，极狐GitLab 会在右侧弹出菜单中返回最多 1,000 个与该特定框架关联的项目，作为信息的一部分。

<a id="pipeline-limits-available-in-gitlab-community-edition"></a>

### 极狐GitLab 基础版中提供流水线限制

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [Documentation](../../administration/settings/continuous_integration.md#set-cicd-limits)

{{< /details >}}

管理员现在可以通过为极狐GitLab 基础版实例设置 CI/CD 限制来控制流水线资源使用。以前，此功能仅在极狐GitLab 企业版中可用。

