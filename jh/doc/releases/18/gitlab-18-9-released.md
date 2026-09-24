---
stage: Release Notes
group: Monthly Release
date: 2026-02-19
title: "极狐GitLab 18.9 发布说明"
description: "极狐GitLab 18.9 发布，极狐GitLab Duo Agent Platform 自部署模型现在可用于云许可证"
---

<!-- markdownlint-disable -->
<!-- vale off -->

2026 年 2 月 19 日，极狐GitLab 18.9 发布，包含以下功能。

<a id="primary-features"></a>

## 主要功能

<a id="gitlab-duo-agent-platform-self-hosted-models-now-available-for-cloud-licenses"></a>

### 极狐GitLab Duo Agent Platform 自部署模型现在可用于云许可证

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署
- Links: [文档](../../administration/gitlab_duo_self_hosted/_index.md#gitLab-duo-agent-platform) | [相关史诗](https://jihulab.com/groups/gitlab-cn/-/work_items/20949)

{{< /details >}}

极狐GitLab Duo Agent Platform 现已面向持有云许可证的私有化部署客户正式提供。此功能的计费方式为[基于用量](../../subscriptions/gitlab_credits.md)。

管理员可以配置[兼容的模型](../../administration/gitlab_duo_self_hosted/supported_models_and_hardware_requirements.md#compatible-models)用于极狐GitLab Duo Agent Platform。

尚未使用旗舰版？[开始免费试用，包含 Duo Agent Platform](https://gitlab.cn/docs/#gitlab-duo-agent-platform-available-in-ultimate-trials)。

<a id="vulnerability-resolution-with-gitlab-duo-agent-platform-beta"></a>

### 使用极狐GitLab Duo Agent Platform 进行漏洞修复（Beta）

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [文档](../../user/duo_agent_platform/flows/foundational_flows/agentic_sast_vulnerability_resolution.md) | [相关史诗](https://jihulab.com/groups/gitlab-cn/-/work_items/20150)

{{< /details >}}

对 SAST 漏洞进行分类和修复是应用安全中最耗时的任务之一。在识别出真正的漏洞后，开发人员需要理解该发现，定位受影响的代码，并编写适当的修复方案。所有这些都需要时间和专业知识。
在极狐GitLab 18.9 中，我们引入了 Agentic SAST 漏洞修复。当你为 SAST 漏洞触发修复时，极狐GitLab Duo 会自主分析该发现，推理周围的代码上下文，生成上下文感知的修复方案，并创建一个合并请求，无需任何人工干预。

主要功能包括：

- 多步骤 Agentic 修复：极狐GitLab Duo Agent Platform 不是生成单一代码建议，而是推理漏洞，评估代码库，并生成一个信息充分的修复方案。
- 自动创建合并请求：为严重和高危 SAST 漏洞生成一个可供审查的合并请求，其中包含提议的代码修复。
- 质量评分：每个生成的修复都包含质量评估，以便审查者可以快速评估对提议修复方案的信心。

SAST 漏洞修复可从漏洞报告和单个漏洞详情页面使用。你可以直接从单个漏洞详情页面触发修复。

此功能作为旗舰版客户的免费 Beta 提供。

<a id="navigate-repositories-with-collapsible-file-tree"></a>

### 使用可折叠文件树浏览仓库

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [文档](../../user/project/repository/files/file_tree_browser.md) | [相关史诗](https://jihulab.com/groups/gitlab-cn/-/epics/17781)

{{< /details >}}

你现在可以使用可折叠的文件树浏览仓库文件。该树提供了项目结构的全面视图，你可以内联展开和折叠目录，在仓库不同部分的文件之间跳转，并在工作时保持上下文。

当你查看仓库文件或目录时，文件树显示为一个可调整大小的侧边栏。你可以使用键盘快捷键切换可见性，按名称或扩展名过滤文件，并在复杂的项目层次结构中导航。该树与你当前的位置同步，因此当你在主内容区域选择一个文件时，树会更新以显示该文件。

你现有的仓库结构和文件组织保持不变。由于在文件之间移动所需的页面加载更少，此功能可从小型项目扩展到包含数千个文件的大型代码库。

<a id="include-cicd-inputs-from-a-file"></a>

### 从文件包含 CI/CD 输入

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [文档](../../ci/inputs/_index.md#define-pipeline-inputs-in-external-files) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/415636)

{{< /details >}}

以前，流水线输入只能直接在流水线的 spec 部分中定义。这一限制使得跨多个项目重用输入配置变得困难。

在此版本中，你现在可以使用熟悉的 `include` 关键字从外部文件包含输入定义。能够在单独的位置维护输入列表，有助于你跨多个项目或流水线实现可管理的解决方案。你可以维护集中化的输入配置，甚至从外部来源动态管理输入值。

<a id="web-based-commit-signing-on-gitlabcom"></a>

### 在 JihuLab.com 上进行基于 Web 的提交签名

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/repository/signed_commits/web_commits.md) | [相关史诗](https://jihulab.com/groups/gitlab-cn/-/work_items/17775)

{{< /details >}}

确保提交经过加密签名对于代码完整性和满足合规性要求至关重要。以前，基于 Web 的提交签名仅适用于私有化部署实例。

JihuLab.com 现在支持基于 Web 的提交签名。当为群组或项目启用时，通过极狐GitLab Web 界面创建的提交将自动使用极狐GitLab 签名密钥进行签名，并显示 **已验证** 徽章，为你的仓库提供加密的真实性证明。

关键细节：

- 根据你的需求在群组或项目设置中启用。
- 启用后，所有基于 Web 的提交（Web IDE 编辑、合并、API 操作）都会自动签名。

这使 JihuLab.com 的安全能力与私有化部署保持一致，并为整个组织的全面提交签名策略奠定了基础。

<a id="container-virtual-registry-now-available-beta"></a>

### 容器虚拟镜像仓库现已可用（Beta）

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [文档](../../user/packages/virtual_registry/container/_index.md) | [相关史诗](https://jihulab.com/groups/gitlab-cn/-/work_items/20820)

{{< /details >}}

现代基于容器的开发需要从多个镜像仓库访问镜像，包括 Docker Hub、Harbor、Quay 和私有仓库。如果没有容器虚拟镜像仓库，平台工程师必须配置每个项目和 CI/CD 流水线以单独认证并从多个仓库拉取。这造成了配置复杂性，通过顺序仓库查询减慢了拉取速度，并使跨容器源实施一致的安全策略变得困难。

容器虚拟镜像仓库通过将多个上游容器仓库聚合在一个端点后解决了这些挑战。平台工程师可以通过一个 URL 使用长期令牌认证配置 Docker Hub、Harbor、Quay 和其他仓库。智能缓存提高了拉取性能，同时与极狐GitLab 认证系统集成，实现集中访问控制和审计日志记录。

容器虚拟镜像仓库 API 目前作为 Beta 版提供给极狐GitLab 专业版和旗舰版客户。Beta 参与者可以使用[极狐GitLab API](../../api/container_virtual_registries.md) 创建容器虚拟镜像仓库，使用可共享的配置配置多个上游源，并通过虚拟镜像仓库拉取容器镜像。请注意，Beta 版不支持需要 IAM 认证的仓库。对需要 IAM 认证的云提供商仓库的支持在[此史诗](https://jihulab.com/groups/gitlab-cn/-/work_items/20919)中跟踪。

在 JihuLab.com 上，此功能位于功能标志后。

<a id="new-security-dashboard-chart-vulnerabilities-by-age"></a>

### 新的安全仪表板图表：按存在时间划分的漏洞

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [文档](../../user/application_security/security_dashboard/_index.md#vulnerabilities-by-age) | [相关史诗](https://jihulab.com/groups/gitlab-cn/-/work_items/17417)

{{< /details >}}

新的 **按存在时间划分的漏洞** 图表帮助你了解漏洞在你的环境中已存在多长时间。

该图表显示了未解决漏洞的分布情况，基于自首次检测以来的时间量。你可以按严重性或报告类型对漏洞进行分组，帮助你识别可能需要修复活动的区域。

<a id="agentic-core"></a>

## Agentic Core

<a id="scale-and-deployments"></a>

## 规模与部署

<a id="non-billable-minimal-access-users"></a>

### 不计费的 Minimal Access 用户

{{< details >}}

- Tier: 专业版
- Offering: 私有化部署
- Links: [文档](../../user/permissions.md#users-with-minimal-access) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/584275)

{{< /details >}}

以前，使用身份提供商在私有化部署专业版上自动配置用户的组织可能会遇到潜在问题。当身份提供商同步尝试添加超出许可席位限制的用户时，管理员必须为不需要活动访问权限的用户购买额外席位，或手动干预以防止失败。

现在，在私有化部署专业版订阅中，具有 Minimal Access 角色的用户不再计入计费席位，这与 JihuLab.com 专业版、JihuLab.com 旗舰版和私有化部署旗舰版上的 minimal access 工作方式保持一致。
此更改解锁了[受限访问](../../administration/settings/sign_up_restrictions.md#restricted-access)功能，该功能会在身份提供商同步期间自动将 Minimal Access 角色分配给否则会超出席位限制的用户。此更改可保持同步顺利进行，而不会出现意外的计费超额或人工干预。

<a id="geo-data-management-view-on-primary-site"></a>

### 主站点上的 Geo 数据管理视图

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署
- Links: [文档](../../administration/admin_area.md#data-management)

{{< /details >}}

你现在可以直接从主站点排查和验证数据完整性，这得益于新的数据管理视图，该视图将详细的验证状态信息带到了主 Geo 站点。此增强功能消除了访问辅助站点进行基本验证和故障排除任务的需要。

以前，此验证状态只能通过辅助站点 UI 访问。现在，通过主站点上的数据管理视图，你可以：

- 在主站点上查看所有可复制数据类型的详细验证状态
- 直接从主 UI 执行数据清理和故障排除任务
- 在添加辅助站点之前，在主站点上设置和验证你的 Geo 配置

此增强功能是朝着通过 UI 实现全面自助故障排除迈出的第一步，减少了在常规维护和问题解决中访问多个站点的需要。

<a id="gitlab-duo-agent-platform-available-in-ultimate-trials"></a>

### 极狐GitLab Duo Agent Platform 在旗舰版试用中可用

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [文档](../../subscriptions/free_trials.md#gitlab-duo-agent-platform-trials) | [相关史诗](https://jihulab.com/groups/gitlab-cn/-/work_items/20353)

{{< /details >}}

评估极狐GitLab 的团队现在可以测试能够自动化复杂开发工作流程并减少手动任务的 Agentic AI 功能。注册极狐GitLab 旗舰版试用，即可获得 Duo Agent Platform 的访问权限，每个用户有 24 个评估积分，从而在 30 天的评估期内亲身体验自主任务执行和多步骤工作流编排。评估积分自提供之日起 30 天内有效，因此在开始前请考虑团队的准备情况。

[开始免费试用](https://jihulab.com/-/trial_registrations/new)。当前付费客户可以通过客户团队获取评估积分。[联系销售](https://gitlab.cn/sales/)了解更多信息。

<a id="zero-downtime-upgrades-now-supported-for-cloud-native-hybrid-deployments"></a>

### 云原生混合部署现支持零停机升级

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署
- Links: [文档](https://gitlab.cn/docs/charts/installation/upgrade/#upgrade-with-zero-downtime)

{{< /details >}}

零停机升级现正式支持云原生混合部署。

企业客户要求其 DevSecOps 平台始终可用，这使得与升级相关的停机成为重大运营问题。
到目前为止，零停机升级仅支持基于 Linux 软件包的高可用性部署，这促使许多客户选择基于虚拟机的架构，即使云原生 Kubernetes 部署更适合其基础设施策略。

我们多年来一直在以零停机方式升级我们自己的云原生混合 SaaS 实例。
在此版本中，我们将同样的运营体验带给在 Kubernetes 上运行极狐GitLab 的私有化部署客户。

升级程序已经过全面测试，现已完整记录，让你有信心在版本升级期间保持可用性。

<a id="archive-a-group-and-its-content"></a>

### 归档群组及其内容

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [文档](../../user/group/manage.md#archive-a-group) | [相关史诗](https://jihulab.com/groups/gitlab-cn/-/epics/15019)

{{< /details >}}

管理已完成的计划和废弃的项目现在更加容易。
你现在可以一次性归档整个群组，包括所有子群组和项目，无需手动逐个归档每个项目。

当你归档一个群组时：

- 所有嵌套的子群组和项目都会自动归档。
- 归档的内容会移至 **未激活** 选项卡，并带有清晰的状态徽章。
- 群组数据保持完全可访问的只读模式，以供参考或恢复。
- 写权限在已归档的群组及其内容中被禁用。

除了 **设置** 页面，你还可以直接从列表视图的操作菜单中归档群组和项目。无需在多个屏幕之间导航以完成简单的管理任务。
这个备受期待的功能大幅减少了管理开销，同时通过清晰区分活跃和非活跃工作，使你的工作区保持井然有序。

<a id="valkey-as-replacement-option-for-redis-beta"></a>

### Valkey 作为 Redis 的替代选项（Beta）

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署
- Links: [文档](../../administration/redis/_index.md#use-valkey-instead-of-redis)

{{< /details >}}

从极狐GitLab 18.9 开始，Valkey 作为 Linux 软件包中 Redis 的可选替代品捆绑提供。
Redis 将其许可证更改为 AGPLv3，这不适合开源客户。为了保证我们私有化部署客户的安全性和可维护性，我们正在从 Redis 过渡到 Valkey，这是一个社区驱动的分支，保留了宽松的 BSD 许可证。

过渡时间表：

- 极狐GitLab 18.9（此版本）：Valkey 作为可选替代品捆绑提供（Beta）。你可以根据自己的方便从 Redis 切换到 Valkey。包含 Valkey Sentinel 支持。
- 极狐GitLab 19.0（2026 年 5 月）：Valkey 成为默认选项，Redis 二进制文件将从 Linux 软件包中移除。现有的 Redis 配置设置仍然有效，并为了向后兼容而被尊重。

此过渡仅影响 Linux 软件包中捆绑的 Redis。使用外部 Redis 部署的规模化架构客户可以继续使用 Redis。
我们正在监控 Redis 和 Valkey 之间潜在的功能差异，并将在生态系统发展过程中提供指导。

<a id="unified-devops-and-security"></a>

## 统一 DevOps 与安全

<a id="dependency-scanning-with-sbom-support-for-java-pomxml-manifest-files"></a>

### 依赖扫描支持 Java pom.xml 清单文件的 SBOM

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [文档](../../user/application_security/dependency_scanning/dependency_scanning_sbom/_index.md#manifest-fallback) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/585886)

{{< /details >}}

极狐GitLab [使用 SBOM 进行依赖扫描](../../user/application_security/dependency_scanning/dependency_scanning_sbom/_index.md) 现在支持扫描 Java `pom.xml` 清单文件。
以前，使用 Maven 的 Java 项目的依赖扫描需要存在 graph 文件。
现在，当 graph 文件不可用时，分析器会自动回退到扫描 `pom.xml` 文件，仅提取和报告直接依赖项以进行漏洞分析。
此改进使 Java 项目更容易启用依赖扫描，而无需 graph 文件。

要启用清单回退，请将 CI/CD 变量 `DS_ENABLE_MANIFEST_FALLBACK` 设置为 `"true"`。

<a id="dependency-scanning-with-sbom-support-for-python-requirementstxt-manifest-files"></a>

### 依赖扫描支持 Python requirements.txt 清单文件的 SBOM

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
管理和可视化整个组织的安全扫描器覆盖范围。此版本引入了安全配置配置文件，从密钥检测配置文件开始。安全团队现在拥有更强大的指挥中心，可以大规模保护您的组织。

**基于配置文件的安全配置**

无需为每个项目手动编辑 YAML 文件，您现在可以使用预配置的安全配置配置文件，该配置文件具有以下优势：

- 标准化治理：预配置的配置文件应用适当的边界，而不会中断生产力。您可以应用标准化的安全最佳实践，而无需自定义角色配置。
- 可扩展管理：通过一次操作将同一配置文件应用于数百或数千个项目。

密钥检测配置文件是第一个可用的安全配置配置文件。它提供以下优势：

- 主动识别并阻止密钥提交到您的仓库。
- 一个配置文件管理整个开发工作流程中的密钥检测。无需为不同的触发类型管理单独的配置。

**增强的安全清单**

安全清单已升级，可作为评估每个群组安全状况的主要仪表板：

- 群组和项目层次结构：通过清晰的图标轻松区分清单中的子群组和项目。
- 批量操作：新的 **批量操作** 菜单允许您同时对所有选定的项目和子群组应用或禁用安全扫描器配置文件。
- 可视化覆盖状态：通过颜色编码的状态栏（已启用、未启用或失败）快速识别差距，并带有详细信息工具提示。
- 配置文件状态指示器：查看配置文件详细信息中可用的触发类型。

<a id="security-attributes"></a>

### 安全属性

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [文档](../../user/application_security/attributes/_index.md)

{{< /details >}}

安全属性，[在极狐GitLab 18.6 中作为测试版引入](gitlab-18-6-released.md#security-attributes-beta)，现已 GA。

安全属性允许安全团队将业务上下文应用于其项目，包括业务影响、应用程序、业务部门、互联网暴露和位置。您还可以创建自定义属性类别以匹配组织的分类法。通过应用这些属性，您可以根据风险状况和组织上下文筛选和优先处理安全清单中的项目。

<a id="security-dashboards:-vulnerabilities-over-time-chart-improvements"></a>

### 安全仪表板：随时间变化的漏洞图表改进

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [文档](../../user/application_security/security_dashboard/_index.md#vulnerabilities-over-time)

{{< /details >}}

**随时间变化的漏洞** 图表已更新，可提供更准确的漏洞清单视图。

该图表之前包含了不再检测到的漏洞，导致数字膨胀，无法准确反映活跃漏洞的状态。

<a id="view-ci/cd-job-metrics-for-projects-(limited-availability)"></a>

### 查看项目的 CI/CD 作业指标（有限可用性）

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [文档](../../user/analytics/ci_cd_analytics.md#cicd-job-performance-metrics)

{{< /details >}}

极狐GitLab CI/CD 分析现在结合了 CI/CD 流水线和 CI/CD 作业性能趋势，使开发者能够快速识别低效或有问题的 CI/CD 作业。这些功能直接包含在极狐GitLab UI 中，因此开发者可以在上下文中获得所需的工具，以识别和修复可能严重影响开发团队速度和整体生产力的 CI/CD 性能问题。对于平台管理员，此视图中的 CI/CD 作业数据还减少了在企业规模运营极狐GitLab 时依赖外部或自定义构建的 CI/CD 可观测性解决方案的需求。

<a id="add-timestamps-to-ci-job-logs"></a>

### 为 CI 作业日志添加时间戳

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [文档](../../ci/jobs/job_logs.md#timestamps)

{{< /details >}}

您现在可以在每个 CI 作业日志行上查看时间戳，以识别性能瓶颈并调试长时间运行的作业。时间戳以 UTC 格式显示。使用时间戳来排查性能问题、识别瓶颈并测量特定构建步骤的持续时间。对于私有化部署，需要极狐GitLab Runner 18.7 或更高版本。

<a id="ci/cd-catalog-component-analytics"></a>

### CI/CD 目录组件分析

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [文档](../../ci/components/_index.md#view-catalog-resource-analytics)

{{< /details >}}

以前，团队无法了解 CI/CD 目录组件项目在整个组织中的使用情况。现在，您可以高级别查看使用计数和采用模式，帮助您了解哪些组件项目最有价值，并优化您的目录投资。

<a id="view-security-reports-from-child-pipelines-in-merge-requests"></a>

### 在合并请求中查看子流水线的安全报告

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Links: [文档](../../ci/pipelines/downstream_pipelines.md#view-child-pipeline-reports-in-merge-requests)

{{< /details >}}

您现在可以直接在合并请求小部件中查看来自子流水线的安全与合规报告。以前，您必须手动浏览多个流水线来识别安全问题，这造成了低效的工作流程，尤其是在单体仓库和复杂的测试设置中。

通过此增强功能，合并请求小部件将子流水线的报告与父流水线结果直接并排显示，每个子流水线的报告单独呈现，并且可以下载产物。这提供了所有安全检查的统一视图，显著减少了调查故障所花费的时间，并在使用父子流水线时加快了合并请求审查。