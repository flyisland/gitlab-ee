---
stage: Release Notes
group: Monthly Release
date: 2026-04-16
title: "极狐GitLab 18.11 发布说明"
description: "极狐GitLab 18.11 发布，漏洞解决功能在极狐GitLab Duo Agent Platform GA"
---

<!-- markdownlint-disable -->
<!-- vale off -->

2026 年 4 月 16 日，极狐GitLab 18.11 发布，包含以下功能。

## 主要功能

### 漏洞解决在极狐GitLab Duo Agent Platform GA

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

Agentic SAST 漏洞解决现在在极狐GitLab 18.11 的极狐GitLab Duo Agent Platform 上 GA。它作为 SAST 扫描的一部分运行，在 SAST 误报检测运行后，或针对单个 SAST 漏洞手动触发时运行。

Agentic SAST 漏洞解决：

- 自主分析发现并推理周围的代码上下文。
- 自动为严重和高危 SAST 漏洞创建包含建议代码修复的可审查合并请求。
- 提供质量评估，以便审查者快速评估建议修复的可信度。
- 允许你直接从漏洞详情页面应用解决方案。

欢迎在[议题 585626](https://gitlab.com/gitlab-org/gitlab/-/issues/585626) 中提供反馈。

### 极狐GitLab Data Analyst Foundational Agent 现已 GA

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

Data Analyst Agent 是一个专门的 AI 聊天助手，帮助你查询、可视化和呈现极狐GitLab 平台上的数据。

由[极狐GitLab Query Language (GLQL)](../../user/glql/_index.md) 支持，Data Analyst 可以检索和分析每个受支持的[数据源](../../user/glql/data_sources/_index.md)的数据，并提供关于软件开发健康和工程效率的清晰、可操作的见解。

这些见解可以直接在 Agent 输出中可视化，并直接嵌入到议题和史诗中以供进一步评估。

### CI Expert Agent 以测试版推出

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

AI 驱动的 CI Expert Agent 现在以测试版提供。该 Agent 帮助团队从极狐GitLab 代码到第一个可工作的流水线，无需从空白的 `.gitlab-ci.yml` 开始。

使用极狐GitLab Duo Agent Platform，该 Agent 检查你的仓库，询问一些关于构建和测试过程的引导性问题，并生成一个可运行的流水线，你可以审查、编辑和提交。

这将流水线创建转变为对话式、上下文感知的体验，同时仍让你在准备演进和优化配置后完全控制 YAML。

### 自动化漏洞严重性覆盖

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

默认漏洞严重性并不总能反映你组织的实际风险。仅限内部服务的严重 CVE 可能不需要与面向公众的应用相同的紧迫性，但团队却花费大量时间分类与其风险模型不匹配的发现。

漏洞管理策略现在可以根据 CVE ID、CWE ID、文件路径和目录等条件自动调整漏洞的严重性。应用策略时，它会更新默认分支上匹配条件的所有漏洞的严重性。手动覆盖仍然优先，所有更改都记录在漏洞的历史记录和审计事件中。

这减少了分类工作，确保开发者专注于对你业务最重要的发现。

### 在子群组和项目中创建服务账户

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

团队现在可以在子群组和项目中创建服务账户。你可以将专用服务账户附加到单个子群组或项目，并像管理该命名空间的其他成员一样管理其访问权限，而不是使用广泛的顶级群组机器人。群组和子群组服务账户可以被邀请到它们创建所在的群组或任何后代子群组和项目。项目服务账户仅限于其自己的项目。

### 服务账户在极狐GitLab 基础版中可用

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

服务账户现在在 JihuLab.com 的所有层级中可用。以前仅限于专业版和旗舰版，服务账户让你执行自动化操作、访问数据或运行计划流程，而无需将凭据绑定到单个团队成员。它们通常用于流水线和第三方集成，其中凭据必须保持稳定，无论团队如何变化。在极狐GitLab 基础版上，每个顶级群组最多可以创建 100 个服务账户，包括在子群组或项目中创建的服务账户。

### 个人访问令牌的细粒度权限现已可用（测试版）

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

细粒度个人访问令牌 (PAT) 现在以测试版提供。与授予你所属的每个项目和群组访问权限的传统 PAT 不同，细粒度 PAT 让你将每个令牌限制为特定的资源和操作。这减少了令牌泄露或受损的潜在影响。

你现有的 PAT 继续像以前一样工作，你仍然可以创建没有细粒度权限的传统 PAT。

此测试版涵盖了大约 75% 的极狐GitLab REST API。完整的 REST API 覆盖、GraphQL 强制执行和管理员策略控制计划在 GA 版本中实现。

要分享反馈，请参阅[史诗 18555](https://gitlab.com/groups/gitlab-org/-/epics/18555)。

### 安全仪表板中的 Top CWE 图表

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

Top CWE 图表现在在新的安全仪表板上可用。识别你的项目或实例中最常见的 CWE，以确定培训、改进或计划优化的机会。用户可以按严重性对仪表板数据进行分组，并按严重性、项目和报告类型过滤仪表板。

### 在 Kubernetes 上部署 Gitaly

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

你现在可以将 Gitaly 部署在 Kubernetes 上，作为一种完全支持的部署方法。这让你在使用 Kubernetes 编排能力进行扩展、高可用性和资源管理时，在管理极狐GitLab 基础设施方面拥有更大的灵活性。以前，Kubernetes 部署需要自定义配置，且未正式支持，这使得在容器化环境中维护可靠的 Gitaly 部署变得困难。

### 手动运行 MR 流水线时重新配置输入

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

CI/CD 输入的一个强大方面是，你可以使用新值手动运行新流水线以进行运行时自定义。这在合并请求 (MR) 流水线中以前不可用，但在此版本中，你现在也可以在 MR 流水线中自定义输入。

在为 MR 流水线配置输入后，你可以在每次为合并请求运行新流水线时，选择性地修改这些输入并更改流水线行为。

## Agentic Core

### 极狐GitLab Duo Agentic Chat 的默认模型从 Haiku 4.5 更新到 Sonnet 4.6

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

我们进行了更新以改善你在极狐GitLab 中的 Agentic Chat 体验。Agentic Chat 的默认模型已从 Claude Haiku 4.5 升级到 Claude Sonnet 4.6，托管在 Vertex AI 上。Claude Sonnet 4.6 提供了更好的推理和响应质量，但使用的极狐GitLab Credit 乘数高于 Haiku 4.5。

你可以使用[模型选择](../../user/duo_agent_platform/model_selection.md#select-a-model-for-a-feature)设置选择替代模型，包括 Haiku。如果你已经选择了特定模型，你的选择将保留。此更新仅影响默认值，不会覆盖任何现有选择。有关按模型划分的 Credit 乘数信息，请参阅[极狐GitLab Credits 文档](../../subscriptions/gitlab_credits.md)。

### 在自定义流定义中配置工具

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

你现在可以直接在自定义流定义中配置工具选项和参数值，以取代 LLM 默认值。这让你在自定义流中对工具的行为有更精确、一致的控制，从而更容易在该流中执行护栏和特定参数值。

### Mistral AI 现在作为极狐GitLab Duo Agent Platform 中的自部署模型受支持

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab Duo Agent Platform 现在支持 Mistral AI 作为自部署模型部署的 LLM 平台。极狐GitLab 私有化部署客户可以将 Mistral AI 与现有受支持的平台一起配置，包括 AWS Bedrock、Google Vertex AI、Azure OpenAI、Anthropic 和 OpenAI。这为团队运行 AI 驱动的功能提供了更多选择。

## 扩展与部署

### 在极狐GitLab Credits 仪表板中查看历史月份

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

Customers Portal 中的极狐GitLab Credits 仪表板现在支持历史月份导航。计费管理员可以浏览过去的计费月份，以查看每日使用趋势、比较不同时期的消耗模式，并将使用情况与发票进行核对。以前，仪表板只显示当前计费月份。通过此改进，管理员可以根据历史数据做出更明智的 Credit 分配决策并预测未来需求。

### 为极狐GitLab Credits 设置订阅级使用上限

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

管理员现在可以在订阅级别为按需 Credits 设置每月使用上限。当按需 Credit 总消耗达到配置的上限时，该订阅上所有用户的极狐GitLab Duo Agent Platform 访问权限将自动暂停，直到下一个计费周期开始或管理员调整上限。此设置为组织提供了防止意外超额账单的硬性护栏，消除了更广泛推出 Agent Platform 的关键障碍。上限在每个计费周期自动重置，管理员在达到上限时会收到电子邮件通知。

### 设置每用户极狐GitLab Credits 上限

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

管理员现在可以为每个计费周期的极狐GitLab Credits 设置可选的每用户使用上限。当单个用户的总 Credit 消耗达到配置的限制时，仅该用户的极狐GitLab Duo Agent Platform 访问权限被暂停，而其他用户继续不受影响。这防止任何单个用户消耗组织 Credit 池的不成比例份额，并为管理员提供对使用分配的精细控制。每用户使用上限与订阅级使用上限一起工作，以先达到的上限为准。

### Linux 软件包改进

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

在极狐GitLab 19.0 中，最低支持的 PostgreSQL 版本将是版本 17。为准备此更改，在不使用 [PostgreSQL Cluster](../../administration/postgresql/replication_and_failover.md) 的实例上，升级到极狐GitLab 18.11 将尝试自动将 PostgreSQL 升级到版本 17。

如果你使用 [PostgreSQL Cluster](../../administration/postgresql/replication_and_failover.md) 或[选择退出此自动升级](https://docs.gitlab.com/omnibus/settings/database/#opt-out-of-automatic-postgresql-upgrades)，你必须[手动升级到 PostgreSQL 17](https://docs.gitlab.com/omnibus/settings/database/#upgrade-packaged-postgresql-server) 才能升级到极狐GitLab 19.0。

### 容器镜像仓库元数据数据库的备份和恢复支持

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

用于 Linux 软件包安装的极狐GitLab `backup` Rake 任务和用于 Cloud Native (Helm) 安装的 `[backup-utility](https://gitlab.cn/docs/charts/backup-restore/)` 现在支持[容器镜像仓库元数据数据库](../../administration/packages/container_registry_metadata_database.md)。你现在可以备份存储在元数据数据库中的 blob、manifest、标签和其他数据的引用，从而在恶意或意外数据损坏时实现恢复。

### 探索中群组的新导航体验

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

我们很高兴宣布对 **探索** 中的群组列表进行改进，让你更容易发现极狐GitLab 实例中的群组。重新设计的界面引入了选项卡式布局，包含两个视图：

- **活跃** 选项卡：浏览所有可访问的群组，帮助你发现相关社区和项目。
- **不活跃** 选项卡：查看已归档的群组和待删除的群组，以了解群组生命周期状态。

这些更改简化了群组发现，并更清晰地显示了哪些群组可以加入。

### 项目的异步转移

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

在极狐GitLab 的早期版本中，大型群组和项目的转移可能会超时。随着我们将群组和项目转向使用统一状态模型进行转移、归档和删除等操作，你将获得更一致的行为、更好的状态历史和审计详情可见性，以及更少的超时，特别是通过异步处理进行长时间运行的转移操作。

## 统一 DevOps 与安全

### ClickHouse 对私有化部署 GA

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

对于极狐GitLab 私有化部署实例，我们现在为极狐GitLab [ClickHouse 集成](../../integration/clickhouse.md)提供了改进的建议和配置指导。客户可以选择自带集群，或使用 ClickHouse Cloud（推荐）设置选项。此集成为多个仪表板提供支持，并解锁了对分析空间中各种 API 端点的访问。

这个可扩展、高性能的数据库是极狐GitLab 分析基础设施计划中的更大架构改进的一部分。

### Duo 和 SDLC 趋势仪表板上的增强极狐GitLab Duo Agent Platform 分析

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Add-ons: Duo Pro, Duo Enterprise

{{< /details >}}

极狐GitLab Duo 和 SDLC 趋势仪表板提供了改进的分析功能，以衡量极狐GitLab Duo 对软件交付的影响。仪表板现在包括用于每月 Agent Platform 独立用户和 Agentic Chat 会话的新单一统计面板。此外，以前显示为使用百分比（相对于席位分配）的指标已更新为严格报告使用计数。此更改解决了[问题](https://gitlab.com/gitlab-org/gitlab/-/work_items/590326)，其中计数缺少在新使用计费模型下控制的 Agent Platform 使用情况。

### GLQL 现在可以访问项目、流水线和作业数据源

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

[极狐GitLab Query Language (GLQL)](../../user/glql/_index.md) 现在可以访问三个新的数据源：项目、流水线和作业。这些新数据源也可作为嵌入式视图使用，让团队直接在 Wiki、议题和合并请求描述以及仓库 Markdown 文件中展示流水线结果、作业状态和项目概览。GLQL 还为 [Data Analyst Agent](../../user/duo_agent_platform/agents/foundational_agents/data_analyst.md) 提供支持。

借助这些新类型，Agent 可以检查 CI/CD 作业结果、调试故障，并提供流水线执行的详细概览，以及提供命名空间中项目的准确概览。

### Maven 和 Python SBOM 扫描的依赖项解析

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用 SBOM 的极狐GitLab 依赖项扫描现在支持为 Maven 和 Python 项目自动生成依赖项图。以前，依赖项扫描要求用户提供锁定文件或图文件才能获得准确的依赖项分析。现在，当锁定文件或图文件不可用时，分析器会自动尝试生成一个。此改进使 Maven 和 Python 项目更容易启用依赖项扫描，而无需锁定文件。

### Advanced SAST 的增量扫描

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

你现在可以使用极狐GitLab Advanced SAST 执行仅分析代码库中已更改部分的增量扫描，与完整仓库扫描相比，显著缩短了扫描时间。此功能是基于差异扫描的进一步迭代，因为它为代码库生成完整结果。

通过仅扫描已更改的代码而不是整个代码库，你的团队可以将安全测试更无缝地集成到他们的开发工作流中，而不会牺牲速度或增加摩擦。

### 未验证的漏洞（测试版）

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

Advanced SAST 现在可以直接在漏洞报告中显示未验证的漏洞（无法完全从源追溯到汇的发现）。如果你对误报的容忍度高于漏报，请启用此功能。
此功能处于测试阶段。

<a id="kubernetes-1-35-support"></a>

### Kubernetes 1.35 支持

{{< details >}}

- Tier：基础版，专业版，旗舰版
- Offering：JihuLab.com，私有化部署
- Links：[文档](../../user/clusters/agent/_index.md#supported-kubernetes-versions-for-gitlab-features) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/work_items/584225)

{{< /details >}}

极狐GitLab 现已完全支持 Kubernetes 1.35 版本。如果要将应用部署到 Kubernetes 并访问所有功能，请将连接的集群升级到最新版本。
更多信息，请参阅 [GitLab 功能支持的 Kubernetes 版本](../../user/clusters/agent/_index.md#supported-kubernetes-versions-for-gitlab-features)。

<a id="prefer-mode-for-the-container-registry-metadata-database"></a>

### 容器镜像仓库元数据数据库的 Prefer 模式

{{< details >}}

- Tier：基础版，专业版，旗舰版
- Offering：私有化部署
- Links：[文档](../../administration/packages/container_registry_metadata_database.md#prefer-mode) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/595480)

{{< /details >}}

你现在可以将容器镜像仓库元数据数据库设置为 `prefer` 模式，这是一个新的配置选项，与现有的 `true` 和 `false` 值并列。在 prefer 模式下，镜像仓库会自动根据安装的当前状态检测应该使用元数据数据库还是回退到旧版存储。

如果你的镜像仓库有尚未导入数据库的现有文件系统元数据，镜像仓库会继续使用旧版存储，直到你完成元数据导入。如果数据库已在使用中，或者在全新安装上，镜像仓库将直接使用数据库。

在未来的版本中，`prefer` 模式将成为新 Linux 软件包安装的默认设置。现有安装不会受到影响。更多信息，请参阅 [议题 595480](https://jihulab.com/gitlab-cn/gitlab/-/work_items/595480)。

<a id="package-protection-rules-now-support-terraform-modules"></a>

### 软件包保护规则现支持 Terraform 模块

{{< details >}}

- Tier：基础版，专业版，旗舰版
- Offering：JihuLab.com，私有化部署
- Links：[文档](../../user/packages/package_registry/package_protection_rules.md) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/592761)

{{< /details >}}

通过内置的极狐GitLab Terraform 模块注册表发布 Terraform 模块的团队无法限制谁可以推送新模块版本。软件包保护规则支持多种软件包格式，但未包括 `terraform_module`，这使得基础设施团队无法在项目级别控制推送权限。

现在，你可以创建范围限定为 `terraform_module` 的软件包保护规则，根据最低角色限制推送访问权限。该支持在 UI 软件包类型下拉框、REST API、GraphQL API 以及极狐GitLab Terraform provider 资源中均可用。

<a id="release-evidence-now-includes-packages"></a>

### 发布证据现包括软件包

{{< details >}}

- Tier：基础版，专业版，旗舰版
- Offering：JihuLab.com，私有化部署
- Links：[文档](../../user/project/releases/release_evidence.md#include-packages-as-release-evidence) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/work_items/283995)

{{< /details >}}

创建极狐GitLab 发布时，发布到软件包仓库的软件包不会自动关联到该发布。团队必须手动构建软件包 URL，并通过 API 或流水线脚本将其作为发布链接附加，这增加了摩擦和发布记录不完整的风险。

极狐GitLab 现在会在软件包版本与发布标签匹配时，自动将软件包包含在发布证据中。这创建了发布与其关联软件包之间可验证、可审计的链接，无需任何手动步骤，从而使源代码、产物和软件包都包含在一个完整的发布快照中。

<a id="wiki-sidebar-toggle-repositioned-for-easier-access"></a>

### Wiki 侧边栏切换按钮重新定位，更易于访问

{{< details >}}

- Tier：基础版，专业版，旗舰版
- Offering：JihuLab.com，私有化部署
- Links：[文档](../../user/project/wiki/_index.md#sidebar) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/work_items/580569)

{{< /details >}}

Wiki 侧边栏切换按钮现在位于左侧，紧邻其控制的侧边栏。

当侧边栏折叠时，该切换按钮会保持可见，作为一个浮动控件，这样你无需滚动回页面顶部即可重新打开它。

<a id="sticky-action-bar-on-wiki-pages"></a>

### Wiki 页面上的粘性操作栏

{{< details >}}

- Tier：基础版，专业版，旗舰版
- Offering：JihuLab.com，私有化部署
- Links：[文档](../../user/project/wiki/_index.md) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/work_items/590255)

{{< /details >}}

Wiki 页面上的操作栏现在是粘性的，因此在你滚动页面时会保持可见。之前，你必须滚动回顶部才能访问编辑、查看页面历史或管理模板等操作。现在，无论你在页面中向下滚动多远，页面标题和关键操作（包括编辑、新建页面、模板、页面历史等）都触手可及。

<a id="epic-weights"></a>

### 史诗权重

{{< details >}}

- Tier：专业版，旗舰版
- Offering：JihuLab.com，私有化部署
- Links：[文档](../../user/work_items/weight.md) | [相关史诗](https://jihulab.com/gitlab-cn/gitlab/-/work_items/12273)

{{< /details >}}

史诗现在支持权重，使得在规划时更容易估算和优先处理大规模计划。

在将史诗分解为子议题之前，你可以分配一个初步权重来表示你的最初估算值。
在你分解史诗时，权重会自动更新，以反映所有子议题的汇总总数。
这与议题和任务的权重汇总机制一致。

在史诗详情页，你可以看到初步权重和来自子议题的汇总权重，这为你在持续改进估算时提供了所需的信息。

<a id="block-merge-requests-with-high-exploitability-risk"></a>

### 阻止高可利用性风险的合并请求

{{< details >}}

- Tier：旗舰版
- Offering：JihuLab.com，私有化部署
- Links：[文档](../../user/application_security/policies/merge_request_approval_policies.md#vulnerability_attributes-object) | [相关史诗](https://jihulab.com/gitlab-cn/gitlab/-/epics/16311)

{{< /details >}}

之前，合并请求（MR）审批策略可以根据漏洞严重性阻止 MR，但并非所有漏洞都具有相同的风险。仅凭 CVSS 严重性无法判断 CVE 是否正在被利用或被利用的可能性有多高。这导致审批策略产生大量干扰，浪费了开发人员和安全团队的时间。

你现在可以使用已知被利用漏洞（KEV）和漏洞利用预测评分系统（EPSS）数据来配置 MR 审批策略。当发现项在 KEV 目录中（正在野外主动利用）或其 EPSS 分数高于某个阈值时，可以阻止或要求审批。MR 中的策略违规包含 KEV 和 EPSS 语境，以便开发人员理解触发安全门的原因。

这使得安全团队能够精确控制哪些发现项进行阻止或警告，减少警报疲劳，并保持执行与当前威胁形势保持一致。

<a id="assign-cvss-4-0-scores-to-vulnerabilities"></a>

### 为漏洞分配 CVSS 4.0 评分

{{< details >}}

- Tier：旗舰版
- Offering：JihuLab.com，私有化部署
- Links：[文档](../../user/application_security/vulnerabilities/severities.md) | [相关史诗](https://jihulab.com/gitlab-cn/gitlab/-/epics/18697)

{{< /details >}}

CVSS 4.0 是用于评估和评级漏洞严重性的行业标准的最新版本。你现在可以在 UI 中查看和访问 CVSS 4.0 评分，包括漏洞详情页面和漏洞报告。你也可以使用 API 查询该评分。

<a id="improved-row-interaction-in-the-vulnerability-report"></a>

### 漏洞报告中行交互的改进

{{< details >}}

- Tier：旗舰版
- Offering：JihuLab.com，私有化部署
- Links：[文档](../../user/application_security/vulnerability_report/_index.md) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/work_items/561414)

{{< /details >}}

之前，你必须选中行描述才能从漏洞报告导航到漏洞详情页面。

现在，你可以选中行内的任意位置直接转到其详情。漏洞描述和文件位置的链接样式仅在你悬停时出现，并且键盘导航也已改进。

这些更改使漏洞报告更加直观和易于访问。

<a id="export-a-security-dashboard-as-a-pdf"></a>

### 将安全仪表板导出为 PDF

{{< details >}}

- Tier：旗舰版
- Offering：JihuLab.com，私有化部署
- Links：[文档](../../user/application_security/security_dashboard/_index.md#export-as-pdf) | [相关史诗](https://jihulab.com/gitlab-cn/gitlab/-/epics/18203)

{{< /details >}}

你可以将安全仪表板导出为 PDF，用于报告和演示。导出会捕获仪表板中所有图表和面板的当前状态，包括任何活动过滤器。

<a id="sast-scanning-in-security-configuration-profiles"></a>

### 安全配置配置文件中的 SAST 扫描

{{< details >}}

- Tier：旗舰版
- Offering：JihuLab.com，私有化部署
- Links：[文档](../../user/application_security/configuration/security_configuration_profiles.md) | [相关史诗](https://jihulab.com/gitlab-cn/gitlab/-/work_items/19951)

{{< /details >}}

在 极狐GitLab 18.9 中，我们引入了安全配置配置文件，并带有 **密钥检测 - 默认** 配置文件。在 极狐GitLab 18.11 中，配置文件现在扩展到 SAST，并附带 **静态应用安全测试 (SAST) - 默认** 配置文件，为你提供了一个统一的控制界面，可以在所有项目中应用标准化的静态分析覆盖，而无需触碰任何 CI/CD 配置文件。

该配置文件激活两种扫描触发器：

- **合并请求流水线**：每当有新提交推送到具有开放合并请求的分支时，自动运行 SAST 扫描。结果仅包含由合并请求引入的新漏洞。
- **分支流水线（仅默认分支）**：当变更合并或推送到默认分支时自动运行，提供默认分支 SAST 状况的完整视图。

<a id="security-attribute-filters-in-group-security-dashboards"></a>

### 群组安全仪表板中的安全属性过滤器

{{< details >}}

- Tier：旗舰版
- Offering：JihuLab.com，私有化部署
- Links：[文档](../../user/application_security/security_dashboard/_index.md#filter-the-entire-dashboard) | [相关史诗](https://jihulab.com/gitlab-cn/gitlab/-/epics/18201)

{{< /details >}}

你现在可以根据已应用于该群组中项目的安全属性，来过滤群组安全仪表板中的结果。

可用的安全属性如下：

- 业务影响
- 应用
- 业务单元
- 互联网暴露
- 位置

<a id="security-manager-role-beta"></a>

### 安全经理角色（测试版）

{{< details >}}

- Tier：基础版，专业版，旗舰版
- Offering：JihuLab.com，私有化部署
- Links：[文档](../../user/permissions.md)

{{< /details >}}

安全经理角色现作为测试功能提供，它提供了一组专为安全专业人员设计的新的默认权限集。安全团队不再需要开发者或维护者角色来访问安全功能，从而消除了过度授权的顾虑，同时保持了职责分离。

拥有安全经理角色的用户具有以下访问权限：

- **漏洞管理**：跨群组和项目查看、分类和管理漏洞，包括漏洞报告和安全仪表板。
- **安全清单**：查看群组的安全清单，以了解所有项目的扫描器覆盖情况。
- **安全配置配置文件**：查看群组的安全配置配置文件。
- **合规工具**：查看群组或项目的审计事件、合规中心、合规框架和依赖项列表。
- **密钥推送保护**：为群组启用密钥推送保护。
- **按需 DAST**：为群组创建并运行按需 DAST 扫描。

要开始使用，请转到群组，选择 **管理** > **成员** 以邀请成员并分配安全经理角色。

<a id="identifier-list-popover-in-the-vulnerability-report"></a>

### 漏洞报告中的标识符列表弹出框

{{< details >}}

- Tier：旗舰版
- Offering：JihuLab.com，私有化部署
- Links：[文档](../../user/application_security/vulnerability_report/_index.md) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/work_items/564939)

{{< /details >}}

漏洞报告现在在每一行中将主要的 CVE 标识符显示为可点击链接。当存在多个标识符时，
一个"`+N 更多`"弹出框会列出所有标识符。列表中的每个标识符都链接到其外部参考
（例如 CVE、CWE 或 WASC 数据库），因此你可以快速访问更多详情而无需离开报告。

<a id="gitlab-runner-18-11"></a>

### 极狐GitLab Runner 18.11

{{< details >}}

- Tier：基础版，专业版，旗舰版
- Offering：JihuLab.com，私有化部署
- Links：[文档](https://gitlab.cn/docs/runner)

{{< /details >}}

我们今天还发布了 极狐GitLab Runner 18.11！极狐GitLab Runner 是高可扩展的构建代理，用于运行你的 CI/CD 作业并将结果发送回 极狐GitLab 实例。极狐GitLab Runner 与 极狐GitLab CI/CD 协同工作，后者是 极狐GitLab 自带的开源持续集成服务。

#### 新增功能

- [创建带捆绑依赖的 `concrete` 辅助镜像](https://jihulab.com/gitlab-cn/gitlab-runner/-/work_items/39286)
- [从 Runner 配置而非环境变量读取作业路由器功能标志](https://jihulab.com/gitlab-cn/gitlab-runner/-/work_items/39280)

#### 错误修复

- [重构后 Runner 二进制文件路径不正确](https://jihulab.com/gitlab-cn/gitlab-runner/-/work_items/39329)
- [缓存操作导致流水线挂起](https://jihulab.com/gitlab-cn/gitlab-runner/-/work_items/39279)
- [极狐GitLab Runner 18.9.0 中的 `docker-machine` 二进制文件引用了 CVE-2025-68121](https://jihulab.com/gitlab-cn/gitlab-runner/-/work_items/39276)
- [当凭证助手二进制文件在 `DOCKER_AUTH_CONFIG` 中缺失时，Runner 静默回退到作业负载凭证](https://jihulab.com/gitlab-cn/gitlab-runner/-/work_items/39201)
- [不同作业中 `CONCURRENT_PROJECT_ID` 不唯一，导致构建目录冲突](https://jihulab.com/gitlab-cn/gitlab-runner/-/work_items/38307)
- [产物上传因等待响应头超时而失败](https://jihulab.com/gitlab-cn/gitlab-runner/-/work_items/37220)
- [用户定义的 `after_script` 在失败的 `pre_build_script` 后执行，并绕过 `post_build_script`](https://jihulab.com/gitlab-cn/gitlab-runner/-/work_items/3116)

完整变更列表请见 极狐GitLab Runner [CHANGELOG](https://jihulab.com/gitlab-cn/gitlab-runner/blob/18-11-stable/CHANGELOG.md)。