---
stage: Release Notes
group: Monthly Release
date: 2025-06-19
title: "极狐GitLab 18.1 发行说明"
description: "GitLab 18.1 released with Maven virtual registry now available in beta"
---

<!-- markdownlint-disable -->
<!-- vale off -->

2025 年 6 月 19 日，极狐GitLab 18.1 发布，包含以下功能。

<a id="primary-features"></a>

## 主要功能

<a id="maven-virtual-registry-now-available-in-beta"></a>

### Maven 虚拟仓库现已在测试版中可用

{{< details >}}

- Tier：专业版，旗舰版
- Links：[文档](../../user/packages/virtual_registry/maven/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/14137)

{{< /details >}}

Maven 虚拟仓库简化了极狐GitLab 中的 Maven 依赖管理。没有 Maven 虚拟仓库，你必须配置每个项目以从 Maven Central、私有仓库或极狐GitLab 软件包仓库访问依赖项。这种方法通过顺序查询仓库而减慢构建速度，并使安全审计和合规报告变得更加复杂。

Maven 虚拟仓库通过在单一端点之后聚合多个上游仓库来解决这些问题。平台工程师可以通过一个 URL 配置 Maven Central、私有仓库和极狐GitLab 软件包仓库。智能缓存提高了构建性能，并与极狐GitLab 的认证系统集成。组织可以受益于减少的配置开销、更快的构建以及集中的访问控制，从而提高安全性和合规性。

Maven 虚拟仓库当前在极狐GitLab 专业版和旗舰版的极狐GitLab.com 和私有化部署环境中提供测试版。GA 版本将包括更多功能，例如用于仓库配置的基于 Web 的用户界面、可共享上游功能、缓存管理的生命周期策略以及增强的分析功能。当前的测试版限制包括每个顶级群组最多 20 个虚拟仓库，每个虚拟仓库最多 20 个上游，并且在测试期间仅提供 API 配置。

我们邀请企业客户参与 Maven 虚拟仓库测试版计划，以帮助塑造最终版本。测试版参与者将获得这些功能的早期访问权、与极狐GitLab 产品团队的直接接触以及在评估期间的优先支持。

<a id="duo-code-review-is-now-generally-available"></a>

### Duo Code Review 现已全面可用

{{< details >}}

- Tier：专业版，旗舰版
- Offering：JihuLab.com
- Add-ons：Duo Enterprise
- Links：[文档](../../user/project/merge_requests/duo_in_merge_requests.md)

{{< /details >}}

Duo Code Review 现已全面可用并可用于生产环境。这款 AI 驱动的代码审查助手通过为你的合并请求提供智能、自动化的反馈，改变了传统的代码审查过程。它能在人工审查人员介入之前帮助识别潜在的 bug、安全漏洞和代码质量问题，使整个审查过程更加高效和彻底。它包括：

- **自动化初始审查**：Duo Code Review 分析你的代码变更，并就潜在问题、改进和最佳实践提供全面反馈。
- **交互式细化**：在合并请求评论中提及 `@GitLabDuo` 以获得对特定更改或问题的针对性反馈。
- **可操作的建议**：许多建议可直接从浏览器应用，简化了改进过程。
- **上下文感知分析**：利用对已更改文件的理解，提供相关的、特定于项目的建议。

要请求代码审查：

- 在你的合并请求中，使用 `/assign_reviewer @GitLabDuo` 快速操作将 `@GitLabDuo` 添加为审核者，或者直接将极狐GitLab Duo 指派为审核者。
- 在评论中提及 `@GitLabDuo`，以就任何讨论线程提出具体问题或请求针对性反馈。
- 在项目设置中启用自动审查，让极狐GitLab Duo 自动审查所有新的合并请求。

Duo Code Review 帮助团队保持更高的代码质量标准，同时减少手动审查周期所花费的时间。通过在早期发现问题并提供有教育意义的反馈，它既是质量关卡，也是开发团队的学习工具。

<a id="compromised-password-detection-for-native-gitlab-credentials"></a>

### 针对原生极狐GitLab 凭证的泄漏密码检测

{{< details >}}

- Tier：基础版，Silver，Gold
- Offering：JihuLab.com
- Links：[文档](../../user/profile/user_passwords.md#compromised-password-detection) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/549865)

{{< /details >}}

极狐GitLab.com 现在在你登录极狐GitLab.com 时对你的账户凭证执行安全检测。
如果你的密码属于已知泄漏，极狐GitLab 将显示一个横幅并向你发送电子邮件通知。
这些通知包括如何更新你的凭证的说明。

为了最大程度地确保安全，极狐GitLab 建议为极狐GitLab 使用唯一且强度高的密码，启用双因素认证，并定期检查你的账户活动。

注意：此功能仅适用于原生极狐GitLab 用户名和密码。不检查 SSO 凭证。

<a id="achieve-slsa-level-1-compliance-with-cicd-components"></a>

### 使用 CI/CD 组件达成 [SLSA](https://slsa.dev/) 1 级合规性

{{< details >}}

- Tier：基础版，专业版，旗舰版
- Offering：JihuLab.com
- Links：[文档](../../ci/pipeline_security/slsa/_index.md#sign-and-verify-slsa-provenance-with-a-cicd-component) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/15859)

{{< /details >}}

你现在可以使用极狐GitLab 新的 CI/CD 组件来签署和验证由极狐GitLab Runner 生成的符合 SLSA 的[产物来源元数据](../../ci/runners/configure_runners.md#artifact-provenance-metadata)，从而达成 SLSA 1 级合规性。这些组件将 [Sigstore Cosign 功能](../../ci/yaml/signing_examples.md)包装在可复用的模块中，可以轻松集成到 CI/CD 工作流中。

<a id="scale-and-deployments"></a>

## 伸缩与部署

<a id="multiple-matches-per-file-in-code-search"></a>

### 代码搜索中的每个文件多个匹配项

{{< details >}}

- Tier：专业版，旗舰版
- Offering：JihuLab.com
- Links：[文档](../../integration/zoekt/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/13127)

{{< /details >}}

精确代码搜索（测试版）现在将同一文件的多个搜索结果合并到单一视图中。此改进：

- 保留相邻匹配项之间的上下文，而不是显示孤立的行。
- 当匹配项接近时，通过消除重复内容减少视觉混乱。
- 通过清晰显示每个文件的匹配项数量增强导航。
- 通过像编辑器中看到的那样显示代码来提高可读性。

通过此更改，现在在你的仓库中查找和理解代码模式更加高效。

<a id="new-accesslevels-argument-for-projectmembers-in-graphql-api"></a>

### GraphQL API 中针对 `projectMembers` 的新 `accessLevels` 参数

{{< details >}}

- Tier：基础版，专业版，旗舰版
- Offering：JihuLab.com
- Links：[文档](../../api/graphql/reference/_index.md#projectprojectmembers) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/541386)

{{< /details >}}

我们很高兴地宣布为 GraphQL API 中的 `projectMembers` 字段添加 `accessLevels` 参数。
使用此参数可直接从 API 调用按访问级别过滤项目成员。
以前，你必须获取整个项目成员列表并在本地应用过滤器，这增加了大量的计算开销。
现在，分析项目权限和生成所有权图谱更快、更节省资源。
此增强功能对于管理具有复杂权限结构的大规模部署的组织尤其有价值。

<a id="unified-devops-and-security"></a>

## 统一 DevOps 与安全

<a id="dast-detection-parity-with-secret-detection-default-rules"></a>

### DAST 检测与默认密钥检测规则对等

{{< details >}}

- Tier：旗舰版
- Offering：JihuLab.com
- Links：[文档](../../user/application_security/dast/browser/checks/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/549990)

{{< /details >}}

DAST 分析器现在自动接收与极狐GitLab 密钥检测分析器使用的相同的默认密钥检测规则。此改进确保了两者在检测到的密钥类型上保持一致。

<a id="define-a-name-for-external-custom-controls"></a>

### 为外部自定义控制定义 `名称`

{{< details >}}

- Tier：旗舰版
- Offering：JihuLab.com
- Links：[文档](../../user/compliance/compliance_frameworks/_index.md#external-controls) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/527007)

{{< /details >}}

以前，在创建自定义合规框架时你无法为外部自定义控制定义名称，
这使得在与极狐GitLab 控制一并列出时难以识别外部控制。

我们现在添加了一个 `名称` 字段，作为定义外部自定义控制工作流的一部分，这样你就可以
创建多个外部自定义控制并为每个控制清晰地定义其唯一名称。

<a id="pagination-for-requirements-in-compliance-frameworks-ui"></a>

### 合规框架界面中需求的分页

{{< details >}}

- Tier：旗舰版
- Offering：JihuLab.com
- Links：[文档](../../user/compliance/compliance_frameworks/_index.md#add-requirements) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/531039)

{{< /details >}}

创建合规框架时，你最多可以指定 50 个需求。

但是，当需求数量很多时，浏览带有这么多需求的合规框架变得非常困难，因为它们
在用户界面中占用了大量空间。

在本次发布中，我们为需求引入了分页功能，使得用户在合规框架附带了大量需求时更容易导航、查找和
选择需求。

<a id="ui-performance-and-filtering-improvements-for-compliance-center"></a>

### 合规中心的 UI 性能和过滤改进

{{< details >}}

- Tier：旗舰版
- Offering：JihuLab.com
- Links：[文档](../../user/compliance/compliance_center/_index.md)

{{< /details >}}

我们持续改进合规中心提供的 UI 性能和过滤选项。在本次
发布中，我们：

- 提高了 **编辑框架** 页面的 UI 速度和性能，尤其是在页面上有许多需求和项目时。
- 引入了新的过滤选项，以便在合规中心的 **合规状态报告** 选项卡中按需求、项目或框架进行分组。

通过提供这些改进，我们持续确保合规中心和相关功能对于经常使用合规中心的客户继续保持规模化性能。

<a id="control-status-pop-up-in-the-compliance-status-report"></a>

### 合规状态报告中的控制状态弹出窗口

{{< details >}}

- Tier：旗舰版
- Offering：JihuLab.com
- Links：[文档](../../user/compliance/compliance_center/compliance_status_report.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/521757)

{{< /details >}}

合规状态报告中的控制有三种不同的状态：

- 通过
- 失败
- 待处理

无论附加到需求的控制数量如何，如果至少有一个控制是“待处理”的，
整个需求行也会显示为“待处理”。这偏离了为可视化失败控制而建立的 UX 模式，在该模式下，即使至少有一个控制失败，需求也会显示与该需求关联的控制数量。

为了为“待处理”控制提供更多上下文和信息，我们现在在需求行状态上提供了一个悬停弹出窗口，
其中列出了每个控制的状态。你现在可以了解哪些控制是待处理的，哪些可能正在通过或失败，而不再仅仅看到“待处理”的单一状态。

<a id="enhanced-merge-request-review-experience-with-review-panel"></a>

### 通过审查面板增强合并请求审查体验

{{< details >}}

- Tier：基础版，专业版，旗舰版
- Offering：JihuLab.com
- Links：[文档](../../user/project/merge_requests/reviews/_index.md#submit-a-review) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/525841)

{{< /details >}}

当你审查合并请求时，在提交审查之前查看你提供的所有评论和反馈会很有价值。以前，这种体验被分散在最终评论和一个用于查看待处理评论的额外弹出窗口之间，使得难以获得完整的概览。

在进行代码审查时，你现在可以访问一个专用的抽屉式面板，该面板在一个有组织的视图中整合了所有待处理的草稿评论。增强的审查面板将审查提交界面移到了更易于访问的位置，并提供了一个编号徽章，显示你的待处理评论数量。当你打开面板时，你将看到所有草稿评论在一个可滚动的列表中组织呈现，使你在提交前更容易审查和管理你的反馈。

<a id="enhanced-codeowners-file-validation-with-permission-checks"></a>

### 通过权限检查增强的 CODEOWNERS 文件验证

{{< details >}}

- Tier：专业版，旗舰版
- Offering：JihuLab.com
- Links：[文档](../../user/project/codeowners/troubleshooting.md#validate-your-codeowners-file) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/15598)

{{< /details >}}

极狐GitLab 现在为 CODEOWNERS 文件提供增强的验证，超越了基本的语法检查。在查看 CODEOWNERS 文件时，极狐GitLab 自动运行全面的验证，以帮助你在配置问题影响合并请求工作流之前发现语法和权限问题。

增强的验证检查 CODEOWNERS 文件中的前 200 个唯一用户和群组引用，并验证：

- 所有引用的用户和群组都有该项目的访问权限。
- 用户有批准合并请求的必要权限。
- 群组至少具有开发者级别或更高的访问权限。
- 群组中至少有一位用户具备合并请求批准权限。

这种主动性验证通过及早发现配置问题，确保你的代码所有者在创建合并请求时能够实际履行其审查职责，从而有助于防止批准工作流中断。

<a id="custom-workspace-initialization-with-poststart-events"></a>

### 通过 `postStart` 事件自定义工作区初始化

{{< details >}}

- Tier：专业版，旗舰版
- Offering：JihuLab.com
- Links：[文档](../../user/workspace/_index.md#user-defined-poststart-events)

{{< /details >}}

极狐GitLab 工作区现在支持在 devfile 中使用自定义 `postStart` 事件，允许你定义工作区启动后自动执行的命令。使用这些事件可以：

- 设置开发依赖项。
- 配置你的环境。
- 运行初始化脚本，为你的项目做好准备，以便无需手动干预即可立即投入生产。

<a id="view-inactive-personal-access-tokens"></a>

### 查看未激活的个人访问令牌

{{< details >}}

- Tier：基础版，专业版，旗舰版
- Offering：JihuLab.com
- Links：[文档](../../user/profile/personal_access_tokens.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/425053)

{{< /details >}}

极狐GitLab 会在访问令牌过期或被撤销后自动将其停用。你现在可以查看这些未激活的令牌。以前，访问令牌在变为未激活状态后就不再可见。此更改增强了这些令牌类型的可追溯性和安全性。

<a id="epic-support-for-gitlab-query-language-views-beta"></a>

### GitLab 查询语言视图测试版支持史诗

{{< details >}}

- Tier：专业版，旗舰版
- Offering：JihuLab.com
- Links：[文档](../../user/glql/fields.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab-query-language/glql-rust/-/issues/30)

{{< /details >}}

我们对 GitLab 查询语言（GLQL）视图进行了重大改进。你现在可以在查询中使用 `epic` 作为类型来搜索群组中的史诗，并按父史诗进行查询！

这对于我们的计划和跟踪能力是一个巨大的进步，使得在史诗层面进行查询和组织变得前所未有的容易。

<a id="php-support-for-advanced-sast"></a>

### 高级 SAST 的 PHP 支持

{{< details >}}

- Tier：旗舰版
- Offering：JihuLab.com
- Links：[文档](../../user/application_security/sast/gitlab_advanced_sast.md#supported-languages) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/14273)

{{< /details >}}

我们为极狐GitLab 高级 SAST 添加了 PHP 支持。
要使用这种跨文件、跨函数扫描支持，请[启用高级 SAST](../../user/application_security/sast/gitlab_advanced_sast.md#turn-on-gitlab-advanced-sast)。
如果你已启用高级 SAST，PHP 支持会自动激活。

要查看高级 SAST 在每种语言中检测到的漏洞类型，请参见[高级 SAST 覆盖页面](../../user/application_security/sast/advanced_sast_coverage.md)。

<a id="filter-by-component-version-in-the-dependency-list"></a>

### 在依赖项列表中按组件版本过滤

{{< details >}}

- Tier：旗舰版
- Offering：JihuLab.com
- Links：[文档](../../user/application_security/dependency_list/_index.md#filter-dependency-list) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/16431)

{{< /details >}}

依赖项列表现在支持按组件的版本号进行过滤。你可以选择多个版本
（例如 `version=1.1,1.2,1.4`），但不支持范围。此功能在群组和项目中均可用。

<a id="variable-precedence-controls-in-pipeline-execution-policies"></a>

### 流水线执行策略中的变量优先级控制

{{< details >}}

- Tier：旗舰版
- Offering：JihuLab.com
- Links：[文档](../../user/application_security/policies/pipeline_execution_policies.md#variables_override-type) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/16430)

{{< /details >}}

安全团队通常在安全保障和开发者体验之间取得微妙的平衡。确保安全扫描得以正确执行至关重要，但安全分析器可能需要来自开发团队的具体输入才能正常运行。借助变量优先级控制，安全团队现在可以通过新的 `variables_override` 配置选项，精细控制流水线执行策略中变量的处理方式。

使用此新配置，你现在可以：

- 强制执行容器扫描策略，允许特定于项目的容器镜像路径 (`CS_IMAGE`)。
- 允许低风险变量如 `SAST_EXCLUDED_PATHS`，同时阻止高风险变量如 `SAST_DISABLED`。
- 定义通过全局 CI/CD 变量安全保护的（掩码或隐藏的）共享凭证，如 `AWS_CREDENTIALS`，同时在适当情况下通过项目级 CI/CD 变量允许项目特定的覆盖。

这一强大功能支持两种方式：

- **默认锁定变量** (`allow: false`)：锁定除你列为例外的特定变量之外的所有变量。
- **默认允许变量** (`allow: true`)：允许自定义变量，但通过将关键风险列为例外来加以限制。

为了提高流水线执行策略作为 CI/CD 作业来源时的可追溯性和故障排除能力，我们还引入了作业日志，以帮助开发者和安全团队识别由策略执行的作业。作业日志提供了变量覆盖影响的详细信息，帮助你了解变量是被策略覆盖还是锁定。

**实际影响**

此增强弥合了安全要求与开发者灵活性之间的差距：

- 安全团队可以强制执行标准化扫描，同时允许特定于项目的自定义。
- 开发人员可以保持对项目特定变量的控制，而无需申请策略例外。
- 组织可以在不中断开发工作流的情况下实施一致的安全策略。

通过解决这一关键的变量控制挑战，极狐GitLab 使组织能够实施强大的安全策略，而无需牺牲团队高效交付软件所需的灵活性。

<a id="filter-for-bot-and-human-users"></a>

### 筛选机器人用户和人类用户

{{< details >}}

- Tier：基础版，专业版，旗舰版
- Offering：JihuLab.com
- Links：[文档](../../administration/moderate_users.md#view-users-by-type) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/541186)

{{< /details >}}

已建立的极狐GitLab 实例通常会有大量的人类用户和机器人用户。你现在可以在管理员区域的用户列表中按用户类型进行筛选。筛选用户可以帮助你：

- 快速识别人类用户并将其与自动化账户区分管理。
- 对特定用户类型执行针对性的管理操作。
- 简化用户审计和管理工作流。

<a id="orcid-identifier-in-user-profile"></a>

### 用户资料中的 [ORCID](https://orcid.org/) 标识符

{{< details >}}

- Tier：基础版，专业版，旗舰版
- Offering：JihuLab.com
- Links：[文档](../../user/profile/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/23543)

{{< /details >}}

极狐GitLab 现在在用户资料中支持 ORCID 标识符，使极狐GitLab 对研究人员和学术界更有价值且更易访问。[ORCID](https://orcid.org/)（开放研究者与贡献者身份识别码）为研究人员提供了一个持久的数字标识符，将他们与其他研究人员区分开来，并支持研究人员与其专业活动之间的自动化关联，确保他们的工作得到恰当认可。

该功能由阿尔图瓦大学硕士研究生 Thomas Labalette 和 Erwan Hivin 在 [Daniel Le Berre](https://www.ouvrirlascience.fr/appointment-of-daniel-le-berre-as-the-national-coordinator-for-higher-education-and-research-software-forges-in-france/) 指导下，作为社区贡献开发，满足了学术界长期以来的需求。

### 订阅服务账号流水线通知

<a id="subscribe-to-service-account-pipeline-notifications"></a>

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

现在你可以订阅由服务账号触发的流水线事件通知。当流水线通过、失败或修复时，通知都会被发送。此前，这些通知仅当服务账号拥有有效自定义邮箱地址时才会发送至该服务账号的邮箱。

感谢 [Densett](https://gitlab.com/Densett)、[Gilles Dehaudt](https://gitlab.com/tonton1728)、[Lenain](https://gitlab.com/lenaing)、[Geoffrey McQuat](https://gitlab.com/gmcquat) 和 [Raphaël Bihoré](https://gitlab.com/rbihore) 的贡献！

### 扩展了 SAST 覆盖范围以支持 Duo 漏洞修复

<a id="increased-sast-coverage-for-duo-vulnerability-resolution"></a>

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com

{{< /details >}}

此前，你必须手动解决带有以下通用弱点枚举（CWE）标识符的漏洞：

- CWE-78（命令注入）
- CWE-89（SQL 注入）

现在，Duo 漏洞修复可自动修复这些漏洞。

### 极狐GitLab Runner 18.1

<a id="gitlab-runner-181"></a>

{{< details >}}

- Tier: 基础版，专业版，旗舰版

{{< /details >}}

我们今天也发布了极狐GitLab Runner 18.1！极狐GitLab Runner 是一个高度可扩展的构建代理，用于运行你的 CI/CD 作业并将结果发送回极狐GitLab 实例。极狐GitLab Runner 与极狐GitLab CI/CD 协同工作，后者是极狐GitLab 中包含的开源持续集成服务。

#### Bug 修复

- 如果你升级到极狐GitLab 17.10 或 17.11，Runner 在请求作业时可能会收到 `404` 响应。

所有变更的列表请参见极狐GitLab Runner [CHANGELOG](https://jihulab.com/gitlab-cn/gitlab-runner/blob/18-1-stable/CHANGELOG.md)。

