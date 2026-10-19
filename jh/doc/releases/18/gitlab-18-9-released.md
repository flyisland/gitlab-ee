---
stage: Release Notes
group: Monthly Release
date: 2026-02-19
title: "极狐GitLab 18.9 发布说明"
description: "极狐GitLab 18.9 发布，极狐GitLab Duo Agent Platform 自部署模型现已面向云许可证提供"
---

<!-- markdownlint-disable -->
<!-- vale off -->

2026 年 2 月 19 日，极狐GitLab 18.9 发布，包含以下功能。

<a id="primary-features"></a>

## 主要功能

<a id="gitlab-duo-agent-platform-self-hosted-models-now-available-for-cloud-licenses"></a>

### 极狐GitLab Duo Agent Platform 自部署模型现已面向云许可证提供

<!-- categories: Self-Hosted Models -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../administration/gitlab_duo_self_hosted/_index.md#gitLab-duo-agent-platform) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/work_items/20949)

{{< /details >}}

极狐GitLab Duo Agent Platform 现已面向拥有云许可证的极狐GitLab 私有化部署客户正式发布。此功能的计费方式为[基于用量](../../subscriptions/gitlab_credits.md)。

管理员可以为极狐GitLab Duo Agent Platform 配置[兼容模型](../../administration/gitlab_duo_self_hosted/supported_models_and_hardware_requirements.md#compatible-models)。使用 AWS Bedrock 或 Azure OpenAI 的管理员还可以配置 Anthropic Claude 或 OpenAI GPT 模型。

尚未使用旗舰版？[开始免费试用，其中包含 Duo Agent Platform](https://gitlab.cn/docs/#gitlab-duo-agent-platform-available-in-ultimate-trials)。

<a id="vulnerability-resolution-with-gitlab-duo-agent-platform-beta"></a>

### 使用极狐GitLab Duo Agent Platform 解决漏洞（测试版）

<!-- categories: Vulnerability Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/duo_agent_platform/flows/foundational_flows/agentic_sast_vulnerability_resolution.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/work_items/20150)

{{< /details >}}

对 SAST 漏洞进行分诊和修复是应用安全中最耗时的任务之一。在识别出真实漏洞后，开发者需要理解该发现、定位受影响的代码并编写适当的修复。这些都需要时间和专业知识。在极狐GitLab 18.9 中，我们推出了 Agentic SAST 漏洞解决功能。当您触发对某个 SAST 漏洞的解决时，极狐GitLab Duo 会自主分析该发现、推理周围的代码上下文、生成上下文感知的修复，并在无需任何人工干预的情况下创建合并请求。

主要能力包括：

- Agentic 多步骤解决：极狐GitLab Duo Agent Platform 不是只生成单条代码建议，而是对该漏洞进行推理、评估代码库，并生成有充分依据的修复。
- 自动创建合并请求：针对严重级别和高危级别 SAST 漏洞，生成包含建议代码修复的、可供评审的合并请求。
- 质量评分：每个生成的修复都包含质量评估，以便审核人可以快速判断所建议修复的可信度。

SAST 漏洞解决功能可从漏洞报告和单个漏洞详情页面使用。您可以直接从单个漏洞详情页面触发解决。

此功能作为免费测试版面向旗舰版客户提供。欢迎您在[议题 585626](https://gitlab.com/gitlab-org/gitlab/-/work_items/585626)中提供反馈。

<a id="navigate-repositories-with-collapsible-file-tree"></a>

### 使用可折叠文件树浏览代码仓库

<!-- categories: Source Code Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/repository/files/file_tree_browser.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/17781)

{{< /details >}}

您现在可以使用可折叠文件树浏览代码仓库文件。该树提供项目结构的全面视图，因此您可以就地展开和折叠目录、在代码仓库不同部分的文件之间跳转，并在工作时保持上下文。

当您查看代码仓库文件或目录时，文件树会显示为可调整大小的侧边栏。您可以使用键盘快捷键切换其可见性、按名称或扩展名筛选文件，并在复杂的项目层级中导航。该树会与您的当前位置同步，因此当您在主要内容区域中选择某个文件时，该树会更新以显示该文件。

您现有的代码仓库结构和文件组织保持不变。由于在文件之间移动所需的页面加载次数更少，此功能可从小型项目扩展到包含数千个文件的大型代码库。

<a id="include-cicd-inputs-from-a-file"></a>

### 从文件包含 CI/CD 输入

<!-- categories: Pipeline Composition -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/inputs/_index.md#define-pipeline-inputs-in-external-files) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/415636)

{{< /details >}}

此前，流水线输入只能直接在流水线的 spec 部分中定义。这一限制使得在多个项目之间复用输入配置变得困难。

在此版本中，您现在可以使用熟悉的 `include` 关键字从外部文件包含输入定义。能够将输入列表维护在单独的位置，有助于您在多个项目或流水线之间获得可管理的解决方案。您可以维护集中式输入配置，甚至可以从外部来源动态管理输入值。

<a id="web-based-commit-signing-on-gitlabcom"></a>

### JihuLab.com 上基于 Web 的提交签名

<!-- categories: Source Code Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com
- 链接: [文档](../../user/project/repository/signed_commits/web_commits.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/work_items/17775)

{{< /details >}}

确保提交经过加密签名对于代码完整性和满足合规要求至关重要。此前，基于 Web 的提交签名仅适用于极狐GitLab 私有化部署。

JihuLab.com 现在支持基于 Web 的提交签名。当为群组或项目启用后，通过极狐GitLab Web 界面创建的提交会自动使用极狐GitLab 签名密钥进行签名，并显示 **已验证** 徽章，为您的代码仓库提供加密的真实性证明。

关键细节：

- 根据您的需求在群组或项目设置中启用。
- 启用后，所有基于 Web 的提交（Web IDE 编辑、合并、API 操作）都会自动签名。

这使 JihuLab.com 的安全能力与极狐GitLab 私有化部署保持一致，并为在整个组织中实施全面的提交签名策略奠定了基础。

<a id="container-virtual-registry-now-available-beta"></a>

### 容器虚拟仓库现已推出（测试版）

<!-- categories: Virtual Registry -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/packages/virtual_registry/container/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/work_items/20820)

{{< /details >}}

现代基于容器的开发需要从多个镜像仓库访问镜像，包括 Docker Hub、Harbor、Quay 和私有镜像仓库。如果没有容器虚拟仓库，平台工程师必须为每个项目和 CI/CD 流水线单独配置，以便分别向多个镜像仓库进行身份验证并从中拉取。这会造成配置复杂性、因按顺序查询镜像仓库而拖慢拉取速度，并使跨容器来源实施一致的安全策略变得困难。

容器虚拟仓库通过将多个上游容器镜像仓库聚合到单个端点后面来解决这些挑战。平台工程师可以通过一个 URL 配置 Docker Hub、Harbor、Quay 和其他镜像仓库，并使用长期有效的令牌进行身份验证。智能缓存可提升拉取性能，同时与极狐GitLab 身份验证系统集成，实现集中式访问控制和审计日志记录。

容器虚拟仓库 API 目前以测试版形式面向极狐GitLab 专业版和旗舰版客户提供。测试版参与者可以使用[极狐GitLab API](../../api/container_virtual_registries.md) 创建容器虚拟仓库、通过可共享的配置配置多个上游来源，并通过虚拟仓库拉取容器镜像。请注意，测试版不支持需要 IAM 身份验证的镜像仓库。对需要 IAM 身份验证的云提供商镜像仓库的支持记录在[此史诗](https://gitlab.com/groups/gitlab-org/-/work_items/20919)中。

在 JihuLab.com 上，此功能受功能标志控制。如需请求访问权限或分享反馈，请在[反馈议题](https://gitlab.com/gitlab-org/gitlab/-/work_items/589630)中发表评论。

<a id="new-security-dashboard-chart-vulnerabilities-by-age"></a>

### 新的安全仪表板图表：按存在时长统计的漏洞

<!-- categories: Vulnerability Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/security_dashboard/_index.md#vulnerabilities-by-age) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/work_items/17417)

{{< /details >}}

新的**按存在时长统计的漏洞**图表可帮助您了解漏洞在您的环境中已存在多长时间。

该图表根据漏洞自首次被检测以来经过的时间，显示未解决漏洞的分布情况。您可以按严重级别或报告类型对漏洞进行分组，从而帮助您识别可能需要开展修复活动的地方。

<a id="agentic-core"></a>

## AI 功能

<a id="oauth-support-in-jetbrains-ides-for-self-managed-and-dedicated"></a>

### 私有化部署的 JetBrains IDE 中的 OAuth 支持

<!-- categories: Editor Extensions -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: 私有化部署
- 附加组件: Duo Core, Duo Pro, Duo Enterprise
- 链接: [文档](https://gitlab.cn/docs/jh/editor_extensions/jetbrains_ide/setup/#authenticate-with-gitlab) | [相关议题](https://gitlab.com/gitlab-org/editor-extensions/gitlab-jetbrains-plugin/-/issues/1337)

{{< /details >}}

适用于 JetBrains IDE 的极狐GitLab Duo 插件现在支持极狐GitLab 私有化部署的 OAuth 身份验证。这意味着所有 JetBrains 用户现在都可以享受更快、更安全的登录体验。无需个人访问令牌。

<a id="scale-and-deployments"></a>

## 规模与部署

<a id="non-billable-minimal-access-users"></a>

### 不计费的最小访问权限用户

<!-- categories: Seat Cost Management -->

{{< details >}}

- 适用版本: 专业版
- 交付方式: 私有化部署
- 链接: [文档](../../user/permissions.md#users-with-minimal-access) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/584275)

{{< /details >}}

此前，使用身份提供商在极狐GitLab 私有化部署专业版上自动预配用户的组织可能会遇到一个潜在问题。当身份提供商同步尝试添加超出许可席位数量的用户时，管理员必须要么为不需要活跃访问权限的用户购买额外席位，要么手动干预以防止失败。

现在，极狐GitLab 私有化部署专业版订阅中具有最小访问权限角色的用户不再计为计费席位，这使其与 JihuLab.com 专业版、JihuLab.com 旗舰版和极狐GitLab 私有化部署旗舰版中最小访问权限的工作方式保持一致。此变更解锁了[受限访问](../../subscriptions/manage_seats.md#restricted-access)功能，该功能会在身份提供商同步期间自动为原本会超出席位限制的用户分配最小访问权限角色。此变更使同步保持平稳运行，不会出现意外的计费超额或需要手动干预。

<a id="geo-data-management-view-on-primary-site"></a>

### 主站点上的 Geo 数据管理视图

<!-- categories: Disaster Recovery, Geo Replication -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../administration/admin_area.md#data-management)

{{< /details >}}

您现在可以直接从主站点排查和验证数据完整性，这得益于新的数据管理视图，它将详细的验证状态信息带到了 Geo 主站点。此增强功能使您无需访问从站点即可执行基本的验证和故障排除任务。

此前，此验证状态只能通过从站点 UI 访问。现在，借助主站点上的数据管理视图，您可以：

- 在主站点上查看所有可复制数据类型的详细验证状态
- 直接从主 UI 执行数据清理和故障排除任务
- 在添加从站点之前，在主站点上设置并验证您的 Geo 配置

此增强功能是迈向通过 UI 进行全面自助故障排除的第一步，减少了对多个站点的访问需求，以进行日常维护和问题解决。

<a id="gitlab-duo-agent-platform-available-in-ultimate-trials"></a>

### 极狐GitLab Duo Agent Platform 已在旗舰版试用中提供

<!-- categories: Acquisition, Duo Agent Platform -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../subscriptions/free_trials.md#gitlab-duo-agent-platform-trials) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/work_items/20353)

{{< /details >}}

正在评估极狐GitLab 的团队现在可以测试 Agentic AI 能力，这些能力可自动执行复杂的开发工作流并减少手动任务。注册极狐GitLab 旗舰版试用，即可获得 Duo Agent Platform 的访问权限，每位用户有 24 个评估额度，让您在 30 天的评估期内亲身体验自主任务执行和多步骤工作流编排。评估额度自预配之日起 30 天内有效，因此请在开始前考虑您团队的准备情况。

[开始免费试用](https://jihulab.com/-/trial_registrations/new)。当前付费客户可以通过其客户团队获取评估额度。[联系销售](https://gitlab.cn/contact-form)了解更多信息。

<a id="zero-downtime-upgrades-now-supported-for-cloud-native-hybrid-deployments"></a>

### Cloud Native Hybrid 部署现已支持零停机升级

<!-- categories: Cloud Native Installation -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](https://gitlab.cn/docs/charts/installation/upgrade/#upgrade-with-zero-downtime)

{{< /details >}}

Cloud Native Hybrid 部署现已正式支持零停机升级。

企业客户要求其 DevSecOps 平台始终可用，因此与升级相关的停机是一个重大的运维问题。到目前为止，零停机升级仅支持基于 Linux 软件包的高可用部署，这促使许多客户转向基于虚拟机的架构，即使云原生 Kubernetes 部署更适合其基础设施策略。

多年来，我们一直在以零停机方式升级自己的 Cloud Native Hybrid SaaS 实例。在此版本中，我们将同样的运维体验带给在 Kubernetes 上运行极狐GitLab 的私有化部署客户。

升级流程已经过全面测试，现已提供完整文档，让您有信心在版本升级期间保持可用性。

<a id="archive-a-group-and-its-content"></a>

### 归档群组及其内容

<!-- categories: Groups & Projects -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/group/manage.md#archive-a-group) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/15019)

{{< /details >}}

管理已完成的举措和已放弃的项目现在更加容易。您现在可以通过一次操作归档整个群组，包括所有子群组和项目，无需再逐个手动归档每个项目。

当您归档群组时：

- 所有嵌套的子群组和项目都会自动归档。
- 已归档的内容会移动到**非活跃**标签页，并带有清晰的状态徽章。
- 群组数据在只读模式下仍可完全访问，以供参考或恢复。
- 已归档群组及其内容的写入权限会被禁用。

除了**设置**页面之外，您还可以直接从列表视图的操作菜单中归档群组和项目。执行简单的管理任务时，无需再浏览多个屏幕。这一备受期待的功能大幅减少了管理开销，同时通过清晰区分活跃和非活跃工作，让您的工作区保持井然有序。请在[史诗 18616](https://gitlab.com/groups/gitlab-org/-/epics/18616)中分享您的反馈。

<a id="valkey-as-replacement-option-for-redis-beta"></a>

### 使用 Valkey 替代 Redis（测试版）

<!-- categories: Omnibus Package -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../administration/redis/_index.md#use-valkey-instead-of-redis)

{{< /details >}}

从极狐GitLab 18.9 开始，Valkey 作为 Redis 的可选替代品捆绑在 Linux 软件包中。
Redis 将其许可证更改为 AGPLv3，这不适合开源客户。为了保障我们极狐GitLab 私有化部署客户的安全性和可维护性，我们正在从 Redis 过渡到 Valkey，这是一个社区驱动的分支，维持宽松的 BSD 许可证。

过渡时间线：

- 极狐GitLab 18.9（此版本）：Valkey 作为可选替代品（测试版）捆绑提供。您可以在方便时从 Redis 切换到 Valkey。包含 Valkey Sentinel 支持。
- 极狐GitLab 19.0（2026 年 5 月）：Valkey 成为默认选项，Redis 二进制文件将从 Linux 软件包中移除。现有的 Redis 配置设置仍然有效，并出于向后兼容性而继续被沿用。

此过渡仅影响 Linux 软件包中捆绑的 Redis。使用外部 Redis 部署的横向扩展架构客户可以继续使用 Redis。我们正在监测 Redis 和 Valkey 之间可能出现的功能差异，并将在生态系统发展过程中提供指导。

<a id="unified-devops-and-security"></a>

## 统一 DevOps 与安全

<a id="dependency-scanning-with-sbom-support-for-java-pomxml-manifest-files"></a>

### 依赖扫描通过 SBOM 支持 Java pom.xml 清单文件

<!-- categories: Software Composition Analysis -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/dependency_scanning/dependency_scanning_sbom/_index.md#manifest-fallback) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/585886)

{{< /details >}}

极狐GitLab [通过 SBOM 进行依赖扫描](../../user/application_security/dependency_scanning/dependency_scanning_sbom/_index.md)现在支持扫描 Java `pom.xml` 清单文件。此前，对使用 Maven 的 Java 项目进行依赖扫描需要存在图文件。现在，当图文件不可用时，分析器会自动回退到扫描 `pom.xml` 文件，仅提取并报告直接依赖项以进行漏洞分析。此改进使 Java 项目更容易启用依赖扫描，而无需图文件。

要启用清单回退，请将 `DS_ENABLE_MANIFEST_FALLBACK` CI/CD 变量设置为 `"true"`。

<a id="dependency-scanning-with-sbom-support-for-python-requirementstxt-manifest-files"></a>

### 依赖扫描通过 SBOM 支持 Python requirements.txt 清单文件

<!-- categories: Software Composition Analysis -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/dependency_scanning/dependency_scanning_sbom/_index.md#manifest-fallback) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/586921)

{{< /details >}}

极狐GitLab [通过 SBOM 进行依赖扫描](../../user/application_security/dependency_scanning/dependency_scanning_sbom/_index.md)现在支持扫描 Python `requirements.txt` 清单文件。此前，对 Python 项目进行依赖扫描需要存在锁定文件。现在，当锁定文件不可用时，分析器会自动回退到扫描 `requirements.txt` 文件，仅提取并报告直接依赖项以进行漏洞分析。此改进使 Python 项目更容易启用依赖扫描，而无需锁定文件。

要启用清单回退，请将 `DS_ENABLE_MANIFEST_FALLBACK` CI/CD 变量设置为 `"true"`。

<a id="restrict-personal-snippets-for-enterprise-users"></a>

### 限制企业用户的个人代码片段

<!-- categories: Source Code Management -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com
- 链接: [文档](../../user/group/manage.md#restrict-personal-snippets-for-enterprise-users)

{{< /details >}}

使用 JihuLab.com 的组织需要确保企业用户不会通过个人代码片段意外泄露敏感代码。此前，无法阻止用户在其个人命名空间中创建代码片段，如果代码片段被无意中设置为公开，可能会带来安全风险。

群组所有者现在可以限制企业用户创建个人代码片段，从而帮助更严格地控制代码的共享位置。限制后，企业用户无法在其个人命名空间中创建代码片段。

<a id="rapid-diffs-improves-performance-for-commit-changes"></a>

### Rapid Diffs 提升提交变更的性能

<!-- categories: Source Code Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/repository/commits/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/work_items/17804)

{{< /details >}}

评审包含大量变更文件或大量修改的提交可能会很慢。Rapid Diffs 技术现在为提交页面（`/-/commits/<SHA>`）提供支持，带来更快的加载时间、更流畅的滚动和更灵敏的交互。

借助 Rapid Diffs，您会注意到：

- 无分页的体验。
- 更快的初始加载，让您可以更早开始处理代码。
- 焕然一新的界面，带有新的文件浏览器，可在文件之间更快导航。
- 即使变更文件数量庞大，交互也保持灵敏。

所有现有功能均得以保留。随着 Rapid Diffs 扩展到极狐GitLab 的其他领域，同样的性能优势也将随之而来。

<a id="support-for-bitbucket-cloud-api-tokens-in-import-api"></a>

### 导入 API 中支持 Bitbucket Cloud API 令牌

<!-- categories: Importers -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../api/import.md#import-repository-from-bitbucket-cloud)

{{< /details >}}

极狐GitLab 导入 API 现在支持 Bitbucket Cloud API 令牌，提供了一种更安全的方式从 Bitbucket Cloud 导入代码仓库。

[Atlassian 已弃用应用密码](https://www.atlassian.com/blog/bitbucket/bitbucket-cloud-transitions-to-api-tokens-enhancing-security-with-app-password-deprecation)，转而使用 API 令牌，我们计划在 19.0 中移除对应用密码的支持。

通过极狐GitLab UI 从 Bitbucket Cloud 导入不受此变更影响。

<a id="centralized-security-governance-and-configuration"></a>

### 集中式安全治理与配置

<!-- categories: Vulnerability Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/configuration/security_configuration_profiles.md)

{{< /details >}}

管理和可视化整个组织中的安全扫描器覆盖情况。此版本引入了安全配置配置文件，首先从密钥检测配置文件开始。安全团队现在拥有更强大的指挥中心，可以大规模保护您的组织。

**基于配置文件的安全配置**

您不再需要为每个项目手动编辑 YAML 文件，现在可以使用预配置的安全配置配置文件，它们具有以下优势：

- 标准化治理：预配置的配置文件会应用适当的边界，而不会中断生产力。您可以应用标准化的安全最佳实践，而无需自定义角色配置。
- 可扩展的管理：通过一次操作即可将同一配置文件应用到数百或数千个项目。

密钥检测配置文件是第一个可用的安全配置配置文件。它具有以下优势：

- 主动识别并阻止密钥被提交到您的代码仓库。
- 一个配置文件即可管理整个开发工作流中的密钥检测。无需为不同的触发类型管理单独的配置。

**增强的安全清单**

安全清单已升级，可作为您评估每个群组安全态势的主要仪表板：

- 群组和项目层级：通过清晰的图标轻松区分清单中的子群组和项目。
- 批量操作：新的**批量操作**菜单允许您同时对所有选定的项目和子群组应用或禁用安全扫描器配置文件。
- 可视化覆盖状态：通过带颜色编码的状态条（已启用、未启用或失败）以及用于查看详情的工具提示，快速识别缺口。
- 配置文件状态指示器：查看配置文件详情中可用的触发类型。

<a id="security-attributes"></a>

### 安全属性

<!-- categories: Security Asset Inventories -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/attributes/_index.md)

{{< /details >}}

安全属性（[在极狐GitLab 18.6 中作为测试版引入](gitlab-18-6-released.md#security-attributes-beta)）现已正式发布。

安全属性允许安全团队将业务上下文应用到其项目，包括业务影响、应用程序、业务部门、互联网暴露情况和位置。您还可以创建自定义属性类别，以匹配您组织的分类体系。通过应用这些属性，您可以根据风险态势和组织上下文对安全清单中的条目进行筛选和优先级排序。

<a id="security-dashboards-vulnerabilities-over-time-chart-improvements"></a>

### 安全仪表板：随时间变化的漏洞图表改进

<!-- categories: Vulnerability Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/security_dashboard/_index.md#vulnerabilities-over-time) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/work_items/19780)

{{< /details >}}

**随时间变化的漏洞**图表已更新，以提供更准确的漏洞清单视图。

该图表此前包含不再被检测到的漏洞，导致数字虚高，无法准确反映活跃漏洞的状态。

我们了解到另外两个问题，它们在某些情况下可能会略微改变计数。请关注[议题 590022](https://gitlab.com/gitlab-org/gitlab/-/issues/590022) 和[议题 590018](https://gitlab.com/gitlab-org/gitlab/-/issues/590018) 以获取更新。

<a id="view-cicd-job-metrics-for-projects-limited-availability"></a>

### 查看项目的 CI/CD 作业指标（限量提供）

<!-- categories: Fleet Visibility -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/analytics/ci_cd_analytics.md#cicd-job-performance-metrics) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/18548)

{{< /details >}}

极狐GitLab CI/CD 分析现在将 CI/CD 流水线和 CI/CD 作业性能趋势结合起来，使开发者能够快速识别低效或有问题的 CI/CD 作业。这些能力直接内置于极狐GitLab UI 中，因此开发者可以在上下文中使用所需的工具来识别和修复可能显著影响开发团队速度和整体生产力的 CI/CD 性能问题。对于平台管理员，此视图中的 CI/CD 作业数据还减少了在企业规模上运维极狐GitLab 时依赖外部或自建 CI/CD 可观测性解决方案的需求。

<a id="add-timestamps-to-ci-job-logs"></a>

### 为 CI 作业日志添加时间戳

<!-- categories: Continuous Integration (CI) -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/jobs/job_logs.md#timestamps) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/202293)

{{< /details >}}

您现在可以查看每行 CI 作业日志上的时间戳，以识别性能瓶颈并调试长时间运行的作业。时间戳以 UTC 格式显示。使用时间戳来排查性能问题、识别瓶颈并测量特定构建步骤的持续时间。极狐GitLab 私有化部署需要极狐GitLab Runner 18.7 或更高版本。

<a id="cicd-catalog-component-analytics"></a>

### CI/CD Catalog 组件分析

<!-- categories: Pipeline Composition -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/components/_index.md#view-cicd-catalog-project-analytics) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/579458)

{{< /details >}}

此前，团队无法了解 CI/CD Catalog 组件项目在其组织中的使用情况。现在您可以查看高层次的用量计数和采用模式，帮助您了解哪些组件项目最有价值，并优化您的目录投入。

<a id="view-security-reports-from-child-pipelines-in-merge-requests"></a>

### 在合并请求中查看子流水线的安全报告

<!-- categories: Continuous Integration (CI) -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/pipelines/downstream_pipelines.md#view-child-pipeline-reports-in-merge-requests) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/18377)

{{< /details >}}

您现在可以直接在合并请求小组件中查看来自子流水线的安全和合规报告。此前，您必须手动浏览多个流水线来识别安全问题，这会造成低效的工作流，尤其是在单体代码仓库和复杂测试设置中。

通过此增强功能，合并请求小组件会直接显示来自子流水线的报告，与父流水线结果并列，每个子流水线的报告单独呈现，且产物可供下载。这提供了所有安全检查的统一视图，显著减少了调查失败所花费的时间，并在使用父子流水线时实现更快的合并请求评审。
