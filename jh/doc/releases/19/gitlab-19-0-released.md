---
stage: Release Notes
group: Monthly Release
date: 2026-05-22
title: 极狐GitLab 19.0
description: 极狐GitLab 19.0 发布，支持群组级自定义审查指令，适用于极狐GitLab Duo
---

2026 年 5 月 22 日，极狐GitLab 19.0 发布，包含以下功能。

<!-- Copy this template, and paste it into the doc section where it belongs:

Primary feature, Agentic Core, Scale and Deployments, or Unified DevOps and Security.

Update all the information as needed.

### Feature explanation here

{{< details >}}

- Tier: Free, Premium, Ultimate
- Offering: GitLab.com, GitLab Self-Managed, GitLab Dedicated
- Links: [Documentation](../../ci/yaml/_index.md), [Related issue](https://gitlab.com/groups/gitlab-org/-/work_items/17754)

{{< /details >}}

Now write 125 words or fewer to explain the value of this improvement.
Use phrases that start with, "In previous versions of GitLab, you couldn't... Now you can..."

Use present tense, and speak about "you" instead of "the user."
-->

<a id="primary-features"></a>

## 主要功能

<a id="group-level-custom-review-instructions-for-gitlab-duo"></a>

### 群组级自定义审查指令，适用于极狐GitLab Duo

<!-- categories: Duo Code Review -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 附加组件: 极狐GitLab Duo Enterprise
- 链接: [文档](../../user/gitlab_duo/customize_duo/review_instructions.md#configure-custom-review-instructions-for-a-group), [相关议题](https://gitlab.com/groups/gitlab-org/-/work_items/21504)

{{< /details >}}

在极狐GitLab 的早期版本中，您只能在项目级别为极狐GitLab Duo 定义自定义审查指令。在同一群组中跨多个项目工作的团队必须在每个项目中重复相同的指令。

现在，您可以为整个群组及其子群组配置共享的自定义审查指令。

在群组中选择一个项目作为模板。当极狐GitLab Duo 执行代码审查时，它会将群组级别的 `.gitlab/duo/mr-review-instructions.yaml` 文件与单个项目中定义的任何指令合并。

Code Review Flow 和极狐GitLab Duo Code Review 均支持群组级自定义指令。

<a id="configure-work-item-types"></a>

### 配置工作项类型

<!-- categories: Team Planning -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/work_items/configurable_work_item_types.md), [相关史诗](https://gitlab.com/groups/gitlab-org/-/work_items/9365)

{{< /details >}}

以前，工作项类型只能是**议题**或**任务**。现在，您可以在项目中配置自定义工作项类型，以匹配团队规划和跟踪工作的方式。

您可以创建或重命名类型为**用户故事**、**缺陷**或**维护**。每个工作项都会显示其类型名称和唯一图标。新类型支持自定义字段和状态生命周期，并会出现在您的已保存视图和议题看板中。顶层群组（JihuLab.com）或组织（极狐GitLab 私有化部署）中的类型配置会级联到所有项目。

您还可以控制每个项目可用的类型。一次性在所有项目中启用或禁用某个类型，或让单个项目管理其自身的类型可见性。当您在项目中禁用某个类型时，现有工作项不受影响。

<a id="gitlab-secrets-manager-now-available-in-open-beta"></a>

### 极狐GitLab 密钥管理器现已开放公开测试版

<!-- categories: Secrets Management -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/secrets/secrets_manager/_index.md), [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/21731)

{{< /details >}}

在极狐GitLab 的早期版本中，极狐GitLab 密钥管理器仅对封闭测试版用户开放。大多数团队依赖外部服务，例如 HashiCorp Vault 或 AWS Secrets Manager。

极狐GitLab 密钥管理器现已在 JihuLab.com 和极狐GitLab 私有化部署上向专业版和旗舰版客户开放公开测试版。启用极狐GitLab 密钥管理器后，项目和群组所有者可以在极狐GitLab 中存储、检索和引用 CI/CD 密钥。密钥的作用域限定为项目或群组，并且仅可由明确请求它们的流水线作业访问。

在公开测试版期间，极狐GitLab 密钥管理器遵循[测试版支持策略](../../policy/development_stages_support.md#beta)，可能尚未准备好用于生产环境。

如需分享反馈，请参阅[议题 598100](https://gitlab.com/gitlab-org/gitlab/-/issues/598100)。

<a id="gitlab-duo-developer-enhancements-for-merge-request-workflows"></a>

### 面向合并请求工作流的极狐GitLab Duo Developer 增强功能

<!-- categories: Duo Agent Platform -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/duo_agent_platform/flows/foundational_flows/developer.md), [相关议题](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/228817)

{{< /details >}}

极狐GitLab Duo Developer 现在支持多种触发方式：将其分配给议题、选择**生成合并请求**，或在任何议题或合并请求讨论线程中 `@mention` 它，以将反馈、待办事项和设计问题转化为代码变更、后续合并请求或研究摘要。

配置了 `AGENTS.md` 和 `agent-config.yml` 后，极狐GitLab Duo Developer 会在提交前运行您的测试和检查。在顶层群组或实例管理员启用 Developer Flow 后，极狐GitLab 会自动为符合条件的项目添加提及和分配触发器。

<a id="dependency-scanning-by-using-sbom-generally-available"></a>

### 基于 SBOM 的依赖扫描功能正式发布

<!-- categories: Software Composition Analysis -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/dependency_scanning/dependency_scanning_sbom/_index.md), [相关史诗](https://gitlab.com/groups/gitlab-org/-/work_items/20456)

{{< /details >}}

极狐GitLab 基于 SBOM 的依赖扫描器已正式发布。Maven、Gradle 和 Python 项目现在可以全面了解其完整依赖树中的漏洞，包括通过传递引入的易受攻击的软件包，而不仅仅是直接声明的那些。

该分析器现在包含针对 Maven、Gradle 和 Python 项目的自动依赖解析。当不存在锁定文件或已解析的依赖关系图时，分析器会自动调用工具来解析完整的传递依赖关系图，然后再进行扫描。依赖解析默认启用，除了包含 v2 依赖扫描模板外，几乎不需要额外配置。

对于无法进行依赖解析的项目，分析器会回退到清单扫描。它会解析 `pom.xml`、`requirements.txt`、`build.gradle` 和 `build.gradle.kts` 以识别直接依赖项。清单扫描确保团队始终能获得漏洞覆盖的起点，即使对于没有锁定文件或构建文件的项目也是如此。

清单扫描默认启用，仅返回直接依赖项。如需完整的传递覆盖，请启用依赖解析，或手动提供依赖锁定文件或依赖关系图导出。

<a id="agentic-core"></a>

## AI 功能

<a id="filter-exact-code-search-results-by-repository"></a>

### 按代码仓筛选精确代码搜索结果

<!-- categories: Global Search -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/search/exact_code_search.md#syntax), [相关议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/488467)

{{< /details >}}

现在，您可以按代码仓筛选精确代码搜索结果。使用 `repo:` 语法，您可以直接将搜索查询限定到特定代码仓或代码仓模式，而无需进入单个项目。

例如，搜索 `def authenticate repo:my-group/my-project` 仅返回来自该代码仓的结果。您还可以使用部分路径或模式来匹配多个代码仓。

<a id="merge-request-ready-event-trigger"></a>

### 合并请求就绪事件触发器

<!-- categories: Duo Agent Platform -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/duo_agent_platform/triggers/_index.md), [相关议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/592454)

{{< /details >}}

现在，您可以配置 Flow 和外部 Agent，使其在**合并请求就绪**事件上运行。

当草稿合并请求被标记为准备审查时，极狐GitLab Duo 会自动运行该 Flow 或外部 Agent。

要配置触发器，请前往项目中的 **AI** > **触发器**。

此功能受 `merge_request_ready_flow_trigger` 功能标志控制，默认禁用。

<a id="claude-opus-47-now-available-in-gitlab-duo-agent-platform"></a>

### 国内 SOTA 模型现已在极狐GitLab Duo Agent Platform 中可用

<!-- categories: Duo Agent Platform -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/duo_agent_platform/model_selection.md#supported-models), [相关议题](https://gitlab.com/gitlab-org/modelops/applied-ml/code-suggestions/ai-assist/-/work_items/2177)

{{< /details >}}

国内 SOTA 模型现已在极狐GitLab Duo Agent Platform 中可用。国内 SOTA 模型为需要持续推理、精确指令遵循以及在呈现结果前进行自我验证的复杂多步骤任务带来了有意义的改进。这包括支持 CI/CD 流水线、代码审查、漏洞修复等 Flow。

<a id="support-for-self-hosted-gemini-models"></a>

### 支持自部署国内 SOTA 模型

<!-- categories: Self-Hosted Models -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../administration/gitlab_duo_self_hosted/supported_models_and_hardware_requirements.md#compatible-models), [相关议题](https://gitlab.com/groups/gitlab-org/-/work_items/21186)

{{< /details >}}

极狐GitLab Duo Agent Platform 自部署版本现在与国内 SOTA 模型兼容。国内 SOTA 模型支持多种 Flow，包括 Code Review Flow、SAST 漏洞修复 Flow、修复 CI/CD 流水线 Flow 等。

<a id="expanded-open-source-model-support-in-gitlab-duo-agent-platform"></a>

### 极狐GitLab Duo Agent Platform 中扩展的开源模型支持

<!-- categories: Self-Hosted Models -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../administration/gitlab_duo_self_hosted/supported_models_and_hardware_requirements.md#supported-models), [相关议题](https://gitlab.com/groups/gitlab-org/-/work_items/21186)

{{< /details >}}

极狐GitLab Duo Agent Platform 现在支持更多用于自部署的开源模型，包括国内 SOTA 模型、GLM-5.1-FP8 等。这有助于客户在各种环境中（包括离线环境和网络受限部署）驱动 Agentic 工作流。

<a id="per-session-tool-approvals-with-admin-controls"></a>

### 基于会话的工具审批与管理员控制

<!-- categories: Duo Agent Platform, Duo Chat -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/gitlab_duo_chat/agentic_chat.md#tool-approvals), [相关议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/596366)

{{< /details >}}

在极狐GitLab Duo Agentic Chat 代表您使用工具之前，需要获得您的批准。每次工具调用都需要单独的批准。

现在，您可以一次性批准一个受信任的工具用于整个会话，从而简化工作流。

管理员控制会话工具审批是否可用。以下设置从实例级联到群组再到项目：

- **默认开启**
- **默认关闭**
- **始终关闭**

群组和子群组可以修改此设置，除非管理员将其设置为**始终关闭**。

默认设置为**默认关闭**，确保每次工具调用都需要明确批准，除非管理员更改此设置。

<a id="resolve-merge-conflicts-with-gitlab-duo-beta"></a>

### 使用极狐GitLab Duo 解决合并冲突（测试版）

<!-- categories: Duo Agent Platform, Code Review Workflow -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/merge_requests/conflicts.md#resolve-conflicts-with-gitlab-duo), [相关议题](https://gitlab.com/groups/gitlab-org/-/work_items/20688)

{{< /details >}}

在极狐GitLab 的早期版本中，即使对于简单的情况，您也必须在极狐GitLab UI 或命令行中手动解决合并冲突。

现在，极狐GitLab Duo 可以自主分析合并冲突、编辑冲突文件、创建提交并推送到源分支。从**解决冲突**页面或直接从合并请求小部件触发冲突解决。完成后，极狐GitLab Duo 会发布一条摘要评论，以便审查者了解更改内容。

极狐GitLab Duo 遵守分支保护规则，不会强制推送到受保护分支。

此功能处于测试阶段，受 `mr_ai_resolve_conflicts` 功能标志控制，默认启用。

<a id="restrict-the-ai-catalog-to-a-group-hierarchy"></a>

### 将 AI 目录限制到群组层级

<!-- categories: AI Catalog -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/duo_agent_platform/ai_catalog.md#restrict-the-ai-catalog-to-a-group-hierarchy), [相关议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/594617)

{{< /details >}}

顶层群组所有者现在可以将 AI 目录限制为仅显示其群组层级内项目所拥有的 Agent 和 Flow。这将阻止该群组中的任何用户查看或启用不属于此层级的 Agent、外部 Agent 或 Flow。

<a id="admin-defined-network-access-controls-for-agent-platform-remote-flows"></a>

### 管理员定义的 Agent Platform 远程 Flow 网络访问控制

<!-- categories: Duo Agent Platform -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/duo_agent_platform/environment_sandbox.md#configure-a-network-policy), [相关议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/593149)

{{< /details >}}

管理员现在可以直接在设置中为极狐GitLab Duo Agent Platform 远程 Flow 定义集中式网络策略。JihuLab.com 上的顶层群组管理员和极狐GitLab 私有化部署上的实例管理员可以配置组织范围的域名拒绝列表和允许列表，项目会自动继承这些列表。另一个设置控制项目是否可以使用自定义条目扩展已批准的域名列表。策略在运行时对所有远程 Flow 强制执行，为安全团队和平台团队提供一致的 Agent 网络出口治理层。

<a id="scale-and-deployments"></a>

## 扩展与部署

<a id="postgresql-17-minimum-requirement"></a>

### PostgreSQL 17 最低要求

<!-- categories: Omnibus Package -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../administration/package_information/postgresql_versions.md), [相关议题](https://gitlab.com/gitlab-org/omnibus-gitlab/-/work_items/9792)

{{< /details >}}

PostgreSQL 的最低支持版本现为 17。如果您使用捆绑的 PostgreSQL 16，请在安装极狐GitLab 19.0 之前[升级捆绑的 PostgreSQL 服务器](https://gitlab.cn/docs/omnibus/settings/database/#upgrade-packaged-postgresql-server)。

<a id="linux-package-support-for-ubuntu-2004-discontinued"></a>

### Linux 软件包停止支持 Ubuntu 20.04

<!-- categories: Omnibus Package -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../install/package/_index.md#supported-platforms), [相关议题](https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/8915)

{{< /details >}}

Ubuntu 20.04 已于 2025 年 5 月结束标准支持。从极狐GitLab 19.0 开始，不再为 Ubuntu 20.04 提供 Linux 软件包。极狐GitLab 18.11 是为该发行版提供软件包的最后一个版本。在升级到极狐GitLab 19.0 之前，请迁移到 Ubuntu 22.04 或其他[受支持的操作系统](../../install/package/_index.md#supported-platforms)。

<a id="redis-6-support-removed"></a>

### 移除 Redis 6 支持

<!-- categories: Omnibus Package -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../install/requirements.md), [相关议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/585839)

{{< /details >}}

极狐GitLab 19.0 移除了对 Redis 6 的支持。如果您使用外部 Redis 6 部署，请在升级前迁移到 Redis 7.2 或 Valkey 7.2。Linux 软件包中包含的捆绑 Redis 自极狐GitLab 16.2 起已使用 Redis 7，不受影响。

<a id="mattermost-removed-from-the-linux-package"></a>

### 从 Linux 软件包中移除 Mattermost

<!-- categories: Omnibus Package -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](https://docs.mattermost.com/administration-guide/onboard/migrate-gitlab-omnibus.html), [相关议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/590798)

{{< /details >}}

极狐GitLab 19.0 从 Linux 软件包中移除了捆绑的 Mattermost。如果您当前使用捆绑的 Mattermost，请参阅[从 Linux 软件包迁移到 Mattermost 独立部署](https://docs.mattermost.com/administration-guide/onboard/migrate-gitlab-omnibus.html)了解迁移说明。未使用捆绑 Mattermost 的客户不受影响。

<a id="linux-package-support-for-suse-distributions-discontinued"></a>

### Linux 软件包停止支持 SUSE 发行版

<!-- categories: Omnibus Package -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../install/docker/installation.md), [相关议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/590801)

{{< /details >}}

极狐GitLab 19.0 终止了对 SUSE 发行版的 Linux 软件包支持，这会影响 openSUSE Leap 15.6、SUSE Linux Enterprise Server 12.5 和 SUSE Linux Enterprise Server 15.6。极狐GitLab 18.11 是为这些发行版提供 Linux 软件包的最后一个版本。要继续使用 SUSE 发行版，请迁移到[极狐GitLab 的 Docker 部署](../../install/docker/installation.md)。

<a id="spamcheck-removed-from-linux-package-and-gitlab-helm-chart"></a>

### 从 Linux 软件包和 GitLab Helm Chart 中移除 Spamcheck

<!-- categories: Omnibus Package, Cloud Native Installation -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../administration/reporting/spamcheck.md), [相关议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/590796)

{{< /details >}}

[Spamcheck](../../administration/reporting/spamcheck.md) 在极狐GitLab 19.0 中从 Linux 软件包和 GitLab Helm Chart 中移除。当前未使用 Spamcheck 的客户不受影响。如果您使用捆绑的 Spamcheck，可以使用 [Docker](https://gitlab.com/gitlab-org/gl-security/security-engineering/security-automation/spam/spamcheck) 单独部署它。无需进行数据迁移。

<a id="nginx-ingress-replaced-by-gateway-api-with-envoy-gateway"></a>

### NGINX Ingress 被 Gateway API 与 Envoy Gateway 取代

<!-- categories: Cloud Native Installation -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](https://gitlab.cn/docs/charts/), [相关议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/590800)

{{< /details >}}

Gateway API 与 Envoy Gateway 在极狐GitLab 19.0 中成为 GitLab Helm Chart 的默认网络配置，取代了已于 2026 年 3 月停止服务的 NGINX Ingress。如果立即迁移到 Envoy Gateway 不可行，您可以明确重新启用捆绑的 NGINX Ingress，该功能将保留至计划在极狐GitLab 20.0 中移除。此更改不影响 Linux 软件包中使用的 NGINX，也不影响使用外部管理的 Ingress 或 Gateway API 控制器的 Helm Chart 实例。

<a id="bundled-postgresql-redis-and-minio-removed-from-gitlab-helm-chart"></a>

### 从 GitLab Helm Chart 中移除捆绑的 PostgreSQL、Redis 和 MinIO

<!-- categories: Cloud Native Installation -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](https://docs.gitlab.com/charts/installation/migration/bundled_chart_migration/), [相关议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/590797)

{{< /details >}}

捆绑的 Bitnami PostgreSQL、Bitnami Redis 和 MinIO Chart 在极狐GitLab 19.0 中从 GitLab Helm Chart 和极狐GitLab Operator 中移除，且无替代方案。这些组件仅用于概念验证和测试环境，不建议用于生产环境。如果您运行的实例使用了这些捆绑服务中的任何一个，请在升级到极狐GitLab 19.0 之前按照[迁移指南](https://docs.gitlab.com/charts/installation/migration/bundled_chart_migration/)配置外部服务。

<a id="reliable-scim-user-deprovisioning-for-large-groups"></a>

### 大型群组的可靠 SCIM 用户取消预配

<!-- categories: User Management -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com
- 链接: [文档](../../development/internal_api/_index.md#group-scim-api), [相关议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/521324)

{{< /details >}}

对于通过 SCIM 管理大量用户的大型组织，取消预配群组成员可能会超时并返回 `500` 错误。SCIM `DELETE` 和 `PATCH` 请求现在会立即返回成功响应。成员资格移除是异步处理的，因此身份提供商和 SCIM 客户端会收到一致的成功响应。

<a id="unified-devops-and-security"></a>

## 统一 DevOps 与安全

<a id="auto-remediation-for-vulnerable-dependencies-experiment"></a>

### 易受攻击依赖项的自动修复（实验阶段）

<!-- categories: Software Composition Analysis -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com
- 链接: [文档](../../user/application_security/remediate/auto_remediation.md), [相关史诗](https://gitlab.com/groups/gitlab-org/-/work_items/17403)

{{< /details >}}

依赖项的自动修复现已在极狐GitLab 19.0 中作为实验功能提供。当依赖扫描检测到存在已知修复的易受攻击 Ruby 依赖项时，极狐GitLab 会自动打开一个合并请求以将其更新到安全版本，无需人工干预。该实验仅支持 Ruby 项目。

每次流水线后，极狐GitLab 会识别具有可用补丁或次要版本升级的最高严重性漏洞。极狐GitLab 生成清单文件更改，并通过服务账户打开一个合并请求。该合并请求随后会经过您项目的标准审查和批准工作流。

在实验期间，每个项目一次最多可以打开三个自动修复合并请求。

如需分享反馈或请求试用该实验，请在[史诗 600511](https://gitlab.com/gitlab-org/gitlab/-/work_items/600511) 上留言。要在您的项目上启用该实验，GitLab 团队成员必须为您的项目启用 `dependency_management_auto_remediation` 功能标志。

<a id="dependency-scanning-in-security-configuration-profiles"></a>

### 安全配置配置文件中的依赖扫描

<!-- categories: Security Testing Configuration -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/configuration/security_configuration_profiles.md), [相关议题](https://gitlab.com/groups/gitlab-org/-/work_items/19952)

{{< /details >}}

极狐GitLab 18.11 引入了针对 SAST 和密钥检测的安全配置配置文件。现在，依赖扫描也可通过**依赖扫描 - 默认**配置文件使用。此配置文件为您提供了一个统一的控制面，无需编辑单个 CI/CD 配置文件即可在所有项目中应用标准化的 SCA 覆盖。

该配置文件激活两个扫描触发器：

- **合并请求流水线**：每次有新提交推送到带有未关闭合并请求的分支时，自动运行依赖扫描。结果仅包含该合并请求引入的新漏洞。
- **分支流水线（仅默认分支）**：当更改被合并或推送到默认分支时自动运行，提供默认分支依赖状况的完整视图。

<a id="dependency-resolution-for-gradle-sbom-scanning"></a>

### Gradle SBOM 扫描的依赖解析

<!-- categories: Software Composition Analysis -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/dependency_scanning/dependency_scanning_sbom/_index.md#dependency-resolution), [相关史诗](https://gitlab.com/groups/gitlab-org/-/work_items/590734)

{{< /details >}}

使用 SBOM 的极狐GitLab 依赖扫描现在会自动为 Gradle 项目生成依赖关系图（`gradle.graph.txt`）。以前，Gradle 依赖扫描要求您在构建过程中手动生成依赖关系图。现在，当关系图文件不可用时，分析器会自动生成一个，从而为使用 Gradle 的 Java 和 Kotlin 项目移除了这一手动步骤。

<a id="remediation-guidance-for-api-security-testing-findings"></a>

### API 安全测试发现的修复指导

<!-- categories: API Security -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/api_security_testing/checks/_index.md), [相关议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/584601)

{{< /details >}}

API 安全漏洞报告现在包含每个发现的修复指导。以前，API 安全测试会识别漏洞，但不提供如何修复的指导。开发者必须独立研究修复步骤。现在，每个发现都直接在漏洞报告中包含特定于漏洞的修复步骤以及相关的 OWASP 和 CWE 标识符参考。

以下检查现在包含修复指导：

- [应用程序信息](../../user/application_security/api_security_testing/checks/application_information_check.md)
- [明文认证](../../user/application_security/api_security_testing/checks/cleartext_authentication_check.md)
- [CORS](../../user/application_security/api_security_testing/checks/cors_check.md)
- [DNS 重新绑定](../../user/application_security/api_security_testing/checks/dns_rebinding_check.md)
- [框架调试模式](../../user/application_security/api_security_testing/checks/framework_debug_mode_check.md)
- [Heartbleed OpenSSL 漏洞](../../user/application_security/api_security_testing/checks/heartbleed_open_ssl_check.md)
- [HTML 注入](../../user/application_security/api_security_testing/checks/html_injection_check.md)
- [不安全的 HTTP 方法](../../user/application_security/api_security_testing/checks/insecure_http_methods_check.md)
- [JSON 劫持](../../user/application_security/api_security_testing/checks/json_hijacking_check.md)
- [JSON 注入](../../user/application_security/api_security_testing/checks/json_injection_check.md)
- [开放重定向](../../user/application_security/api_security_testing/checks/open_redirect_check.md)
- [操作系统命令注入](../../user/application_security/api_security_testing/checks/os_command_injection_check.md)
- [路径遍历](../../user/application_security/api_security_testing/checks/path_traversal_check.md)
- [敏感文件](../../user/application_security/api_security_testing/checks/sensitive_file_disclosure_check.md)
- [敏感信息](../../user/application_security/api_security_testing/checks/sensitive_information_disclosure_check.md)
- [会话 Cookie](../../user/application_security/api_security_testing/checks/session_cookie_check.md)
- [Shellshock](../../user/application_security/api_security_testing/checks/shellshock_check.md)
- [SQL 注入](../../user/application_security/api_security_testing/checks/sql_injection_check.md)
- [TLS 配置](../../user/application_security/api_security_testing/checks/tls_server_configuration_check.md)
- [认证令牌](../../user/application_security/api_security_testing/checks/authentication_token_check.md)
- [XML 注入](../../user/application_security/api_security_testing/checks/xml_injection_check.md)

<a id="security-data-in-merge-request-reports-tab"></a>

### 合并请求报告选项卡中的安全数据

<!-- categories: Vulnerability Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/merge_requests/reports.md), [相关史诗](https://gitlab.com/groups/gitlab-org/-/work_items/20406)

{{< /details >}}

合并请求包含一个新的报告选项卡，该选项卡显示来自安全扫描的所有发现、许可证合规性结果以及针对该流水线的代码质量报告。

活动动态中的极狐GitLab 机器人评论仍然可用，用于查看阻止该合并请求被合并的任何策略违规。

<a id="improved-array-support-for-cicd-inputs"></a>

### CI/CD 输入改进的数组支持

<!-- categories: Pipeline Composition -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/inputs/_index.md#access-individual-array-elements), [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/587657)

{{< /details >}}

CI/CD 输入现在改进了对数组的支持。使用数组索引运算符 `[]` 来访问数组输入中的特定元素。此增强功能在您的流水线配置中提供了更灵活、更强大的输入插值能力，使您能够直接引用单个数组项，而无需额外的处理步骤。

<a id="select-multiple-values-for-pipeline-inputs"></a>

### 为流水线输入选择多个值

<!-- categories: Pipeline Composition -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/inputs/_index.md#array-inputs-with-options), [相关议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/566155)

{{< /details >}}

以前，在 UI 中选择输入选项时，您只能选择单个值，这限制了具有更复杂选项的流水线的灵活性。

现在，当您从 UI 运行带有输入的流水线时，您可以从下拉列表中选择多个值，所选值会组合成一个数组，例如 `["option1","option2"]`。这使得在多个实例上重启服务、构建多个 Docker 镜像、使用多个标签组合运行测试，或在一次流水线运行中跨多个目标执行任何操作变得简单。

<a id="detailed-cicd-catalog-component-usage-analytics"></a>

### 详细的 CI/CD 目录组件使用分析

<!-- categories: Component Catalog -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/components/_index.md#view-component-usage-details), [相关议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/579460)

{{< /details >}}

当您在 CI/CD 目录中管理 CI/CD 组件时，使用详情对于管理升级、执行合规性以及沟通重大变更至关重要。您需要知道哪些项目使用了您的组件，以及它们正在使用哪些版本。以前，这些信息不可用，使得通知正确的维护者、安全地计划弃用或确保项目保持最新的安全补丁变得困难。

目录资源页面中的组件使用详情视图现在会精确显示哪些项目使用了每个组件、它们运行的版本，以及它们是最新版本还是过时版本。使用旧版本的项目会显示在顶部，以便您可以优先进行外联、推动安全修复的采用，并确保整个组织拥有顺畅的升级路径。

<a id="configure-parallel-pipeline-limits-for-merge-trains"></a>

### 配置合并队列的并行流水线限制

<!-- categories: Continuous Integration (CI) -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../administration/cicd/limits.md#merge-train-parallel-pipeline-limit), [相关议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/374188)

{{< /details >}}

在极狐GitLab 的早期版本中，您无法更改合并队列中最多 20 个并行流水线的限制，这迫使您要么让 Runner 不堪重负，要么完全跳过合并队列。现在，您可以配置每个合并队列的并行流水线限制，以平衡 Runner 负载和合并吞吐量。您可以按项目或实例范围设置此限制。将限制设置为 1 意味着每个合并请求一次运行一个，针对干净的目标分支。

感谢 [Norman Debald (@Modjo85)](https://gitlab.com/Modjo85) 的社区贡献。

<a id="customize-default-merge-request-titles"></a>

### 自定义默认合并请求标题

<!-- categories: Code Review Workflow -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/merge_requests/title_templates.md), [相关议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/16080)

{{< /details >}}

在极狐GitLab 的早期版本中，新合并请求的默认标题来自源分支或第一次提交，您无法在项目中强制执行一致的命名约定。

现在，您可以为每个项目配置默认的合并请求标题模板。模板支持源分支、目标分支、第一次提交主题、关联议题 ID、议题标题以及源分支名称的人类可读版本等变量。例如，模板 `Resolve %{issue_id} "%{issue_title}"` 会生成类似 `Resolve 123 "Fix login bug"` 的标题。您仍然可以在创建合并请求之前编辑标题。

<a id="secure-webhooks-with-hmac-signing-tokens"></a>

### 使用 HMAC 签名令牌保护 Webhook 安全

<!-- categories: Importers -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/integrations/webhooks.md#signing-tokens), [相关议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/19367)

{{< /details >}}

现有的 `X-Gitlab-Token` 标头以明文形式发送静态密钥，使 Webhook 容易受到拦截和重放攻击。

您现在可以为任何 Webhook 添加签名令牌。极狐GitLab 使用签名令牌计算基于以下内容的 HMAC-SHA256 签名：

- 唯一的 Webhook ID。
- 请求的时间戳。
- Webhook 的负载。

随后，极狐GitLab 通过 `webhook-signature` 标头发送计算结果，并同时发送 `webhook-id` 和 `webhook-timestamp` 标头，遵循 [Standard Webhooks](https://www.standardwebhooks.com/) 规范。

您可以重新计算签名以确认请求确实来自极狐GitLab，并且负载未被修改。通过同时验证时间戳，您可以拒绝重放的请求。

感谢 [Van Anderson](https://gitlab.com/van.m.anderson) 和 [Norman Debald](https://gitlab.com/Modjo85) 的社区贡献！

<a id="cross-project-pushes-using-cicd-job-tokens"></a>

### 使用 CI/CD 作业令牌进行跨项目推送

<!-- categories: Continuous Integration (CI) -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/jobs/ci_job_token.md#allow-cross-project-git-push-requests-from-allowlisted-projects), [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/479907)

{{< /details >}}

在极狐GitLab 的早期版本中，您只能使用 CI/CD 作业令牌（`CI_JOB_TOKEN`）推送到运行该流水线的同一代码仓。跨项目推送需要个人访问令牌或部署令牌。

现在，您可以在以下情况下使用作业令牌推送到另一个项目：

1. 目标项目选择加入。
2. 启动该流水线的用户在目标项目中至少具有开发者角色。

此功能受 `allow_push_to_allowlisted_projects` 功能标志控制，在极狐GitLab 19.0 中默认禁用。请让您的管理员启用它。

<a id="mermaid-diagram-rendering-upgraded-to-version-11"></a>

### Mermaid 图表渲染升级至版本 11

<!-- categories: Markdown -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/markdown.md#mermaid), [相关议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/491514)

{{< /details >}}

极狐GitLab 现在使用 [Mermaid 版本 11](../../user/markdown.md#mermaid) 来渲染 Markdown 中的图表。

以前，极狐GitLab 支持 Mermaid 版本 10。通过此次升级，您可以访问 Mermaid 11 中引入的所有新图表类型、语法改进和缺陷修复，包括流程图、序列图等的增强渲染。

<a id="rapid-diffs-for-merge-request-reviews-beta"></a>

### 合并请求审查的快速差异（测试版）

<!-- categories: Code Review Workflow -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/merge_requests/changes.md#rapid-diffs), [相关议题](https://gitlab.com/groups/gitlab-org/-/work_items/18457)

{{< /details >}}

在极狐GitLab 的早期版本中，您必须等待**更改**选项卡加载所有文件后才能开始审查，这拖慢了大型审查的速度。

现在，您可以使用快速差异来审查合并请求，体验更快的初始加载、更流畅的滚动以及跨文件的更灵敏交互。快速差异使用了与提交页面相同的技术。

快速差异处于测试阶段。经典差异体验中的某些功能尚不可用。您可以随时切换回去。

<a id="gitlab-runner-190"></a>

### GitLab Runner 19.0

<!-- categories: GitLab Runner Core -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](https://gitlab.cn/docs/runner/)

{{< /details >}}

今天，我们还发布了 GitLab Runner 19.0！GitLab Runner 是一个高度可扩展的构建代理，用于运行您的 CI/CD 作业并将结果发送回极狐GitLab 实例。GitLab Runner 与极狐GitLab CI/CD（极狐GitLab 中包含的开源持续集成服务）协同工作。

<a id="whats-new"></a>

#### 新增功能

- [Runner 仪表化：功能协商、OTLP 导出客户端和首个 `job_execution` 跨度](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/39231)
- [为 Runner 配置添加可配置的准备阶段超时](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/26583)

<a id="bug-fixes"></a>

#### 缺陷修复

- [`FF_SCRIPTS_TO_STEPS` 功能标志实现的全面修复](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/39403)
- [下载 S3 缓存时出现 `SignatureDoesNotMatch` 错误](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/39402)
- [GitLab Runner 在 AWS 中使用 S3 缓存时出现运行时错误](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/39386)
- [GitLab Runner 18.9.0 及更高版本中 `amd64`、`arm64`、`arm` 和 `armhf` 的 RPM S3 下载链接损坏](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/39362)
- [Windows 上负退出代码报告不正确](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/39292)
- [Kubernetes 执行器服务容器命名文档不正确](https://gitlab.com/gitlab-org/gitlab-runner/-/work_items/39235)

所有更改的列表请参见 GitLab Runner [CHANGELOG](https://gitlab.com/gitlab-org/gitlab-runner/blob/19-0-stable/CHANGELOG.md)。
