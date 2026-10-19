---
stage: Release Notes
group: Monthly Release
date: 2025-06-19
title: "极狐GitLab 18.1 发布说明"
description: "极狐GitLab 18.1 发布，Maven 虚拟仓库现已推出测试版"
---

<!-- markdownlint-disable -->
<!-- vale off -->

2025 年 6 月 19 日，极狐GitLab 18.1 发布，包含以下功能。

<a id="primary-features"></a>

## 主要功能

<a id="maven-virtual-registry-now-available-in-beta"></a>

### Maven 虚拟仓库现已推出测试版

<!-- categories: Virtual Registry -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/packages/virtual_registry/maven/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/14137)

{{< /details >}}

Maven 虚拟仓库简化了极狐GitLab 中的 Maven 依赖管理。如果没有 Maven 虚拟仓库，您必须为每个项目单独配置，才能从 Maven Central、私有仓库或极狐GitLab 软件包仓库访问依赖项。这种方式会因依次查询各个仓库而拖慢构建速度，并使安全审计和合规报告变得复杂。

Maven 虚拟仓库通过将多个上游仓库聚合到单一端点之后来解决这些问题。平台工程师可以通过一个 URL 配置 Maven Central、私有镜像仓库和极狐GitLab 软件包仓库。智能缓存可提升构建性能，并与极狐GitLab 的身份验证系统集成。组织可以受益于更低的配置开销、更快的构建速度，以及集中式访问控制带来的安全性和合规性提升。

Maven 虚拟仓库目前以测试版形式提供给 JihuLab.com 和极狐GitLab 私有化部署上的专业版和旗舰版客户。正式发布版本将包含更多能力，例如用于仓库配置的 Web 用户界面、可共享的上游功能、用于缓存管理的生命周期策略以及增强的分析功能。当前测试版的限制包括：每个顶级群组最多 20 个虚拟仓库，每个虚拟仓库最多 20 个上游，且在测试版期间仅支持通过 API 进行配置。

我们诚邀企业客户参与 Maven 虚拟仓库测试版计划，共同塑造最终版本。测试版参与者将获得这些能力的早期访问权限、与 GitLab 产品团队的直接交流，以及评估期间的优先支持。如需加入测试版计划，请在[议题 498139](https://gitlab.com/gitlab-org/gitlab/-/issues/498139)中表达意向并提供您的用例详情，并在[议题 543045](https://gitlab.com/gitlab-org/gitlab/-/issues/543045)中分享反馈和建议。

<a id="duo-code-review-is-now-generally-available"></a>

### Duo 代码评审现已正式发布

<!-- categories: Code Review Workflow -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 附加组件: Duo Enterprise
- 链接: [文档](../../user/project/merge_requests/duo_in_merge_requests.md)

{{< /details >}}

Duo 代码评审现已正式发布，可用于生产环境。这款 AI 驱动的代码评审助手通过对您的合并请求提供智能、自动化的反馈，改变了传统的代码评审流程。它有助于在人工审核人介入之前识别潜在缺陷、安全漏洞和代码质量问题，使整个评审流程更高效、更全面。它包括：

- **自动化初步评审**：Duo 代码评审会分析您的代码变更，并就潜在问题、改进点和最佳实践提供全面反馈。
- **交互式完善**：在合并请求评论中提及`@GitLabDuo`，即可针对特定变更或问题获得有针对性的反馈。
- **可操作的改进建议**：许多建议可直接在浏览器中应用，从而简化改进流程。
- **上下文感知分析**：利用对已变更文件的理解，提供相关的、针对具体项目的建议。

如需请求代码评审：

- 在您的合并请求中，使用`/assign_reviewer @GitLabDuo` 快速操作将`@GitLabDuo` 添加为审核人，或直接将极狐GitLab Duo 指定为审核人。
- 在评论中提及`@GitLabDuo`，以提出具体问题或请求针对任一讨论串的集中反馈。
- 在项目设置中启用自动评审，让极狐GitLab Duo 自动评审所有新的合并请求。

Duo 代码评审可帮助团队维持更高的代码质量标准，同时减少花在人工评审循环上的时间。通过尽早发现问题并提供有教育意义的反馈，它既是质量关卡，也是开发团队的学习工具。

请在[议题 517386](https://gitlab.com/gitlab-org/gitlab/-/issues/517386)中分享您的体验和反馈，帮助我们持续改进此功能。

<a id="compromised-password-detection-for-native-gitlab-credentials"></a>

### 针对极狐GitLab 原生凭据的已泄露密码检测

<!-- categories: System Access -->

{{< details >}}

- 适用版本: 基础版
- 交付方式: JihuLab.com
- 链接: [文档](../../user/profile/user_passwords.md#compromised-password-detection) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/549865)

{{< /details >}}

当您登录 JihuLab.com 时，JihuLab.com 现在会对您的账号凭据执行安全检查。如果您的密码属于已知泄露数据的一部分，极狐GitLab 会显示横幅并向您发送电子邮件通知。这些通知包含如何更新凭据的说明。

为了获得最高安全性，极狐GitLab 建议为极狐GitLab 使用唯一且强度高的密码，启用双因素认证，并定期检查您的账号活动。

注意：此功能仅适用于极狐GitLab 原生用户名和密码。SSO 凭据不会被检查。

<a id="achieve-slsa-level-1-compliance-with-cicd-components"></a>

### 使用 CI/CD 组件实现 [SLSA](https://slsa.dev/) 第 1 级合规

<!-- categories: Artifact Security -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/pipeline_security/slsa/_index.md#sign-and-verify-slsa-provenance-with-a-cicd-component) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/15859)

{{< /details >}}

您现在可以使用极狐GitLab 新增的 CI/CD 组件来实现 SLSA 第 1 级合规，这些组件用于对极狐GitLab Runner 生成的符合 SLSA 的[产物来源元数据](../../ci/runners/configure_runners.md#artifact-provenance-metadata)进行签名和验证。这些组件将 [Sigstore Cosign 功能](../../ci/yaml/signing_examples.md)封装为可复用的模块，便于轻松集成到 CI/CD 工作流中。

<a id="scale-and-deployments"></a>

## 规模与部署

<a id="multiple-matches-per-file-in-code-search"></a>

### 代码搜索中每个文件支持多个匹配项

<!-- categories: Code Search -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../integration/zoekt/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/13127)

{{< /details >}}

精确代码搜索（测试版）现在会将同一文件中的多个搜索结果合并到单个视图中。此改进：

- 保留相邻匹配项之间的上下文，而不是显示孤立的行。
- 当匹配项彼此靠近时，通过消除重复内容来减少视觉杂乱。
- 通过清晰显示每个文件的匹配项数量来增强导航。
- 以您在编辑器中看到代码的方式显示代码，从而提升可读性。

通过此变更，在您的代码仓库中查找和理解代码模式现在更加高效。

<a id="new-accesslevels-argument-for-projectmembers-in-graphql-api"></a>

### GraphQL API 中 `projectMembers` 新增 `accessLevels` 参数

<!-- categories: Groups & Projects -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../api/graphql/reference/_index.md#projectprojectmembers) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/541386)

{{< /details >}}

我们很高兴地宣布，GraphQL API 中的 `projectMembers` 字段新增了 `accessLevels` 参数。使用此参数，您可以直接通过 API 调用按访问级别筛选项目成员。此前，您必须获取完整的项目成员列表并在本地应用筛选，这会带来大量计算开销。现在，分析项目权限和生成所有权图谱的速度更快，资源利用效率也更高。对于管理具有复杂权限结构的大规模部署的组织而言，此增强功能尤其有价值。

<a id="unified-devops-and-security"></a>

## 统一的 DevOps 与安全

<a id="dast-detection-parity-with-secret-detection-default-rules"></a>

### DAST 检测与密钥检测默认规则保持一致

<!-- categories: DAST -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/dast/browser/checks/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/549990)

{{< /details >}}

DAST 分析器现在会自动采用极狐GitLab 密钥检测分析器所使用的相同默认密钥检测规则。此改进确保两者检测到的密钥类型保持一致。

<a id="define-a-name-for-external-custom-controls"></a>

### 为外部自定义控制项定义 `Name`

<!-- categories: Compliance Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/compliance/compliance_frameworks/_index.md#external-controls) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/527007)

{{< /details >}}

此前，在创建自定义合规框架时，您无法为外部自定义控制项定义名称，这使得外部控制项与极狐GitLab 控制项一起列出时难以识别。

现在，我们在定义外部自定义控制项的工作流中新增了 `Name` 字段，因此您可以创建多个外部自定义控制项，并为每个控制项清晰地定义其唯一名称。

<a id="pagination-for-requirements-in-compliance-frameworks-ui"></a>

### 合规框架 UI 中要求的翻页功能

<!-- categories: Compliance Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/compliance/compliance_frameworks/_index.md#add-requirements) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/531039)

{{< /details >}}

创建合规框架时，您最多可以指定 50 项要求。

然而，当合规框架包含这么多要求时，浏览起来会变得非常困难，因为它们在用户界面中占用大量空间。

在此版本中，我们为要求引入了翻页功能，以便在合规框架关联大量要求时，让用户更轻松地浏览、查找和选择要求。

<a id="ui-performance-and-filtering-improvements-for-compliance-center"></a>

### 合规中心的 UI 性能和筛选改进

<!-- categories: Compliance Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/compliance/compliance_center/_index.md)

{{< /details >}}

我们持续改进合规中心提供的 UI 性能和筛选选项。在此版本中，我们：

- 提升了**编辑框架**页面的 UI 速度和性能，尤其是在页面上有许多要求和项目时。
- 引入了新的筛选选项，以便您可以在合规中心的**合规状态报告**选项卡中按要求、项目或框架进行分组。

通过交付这些改进，我们继续确保合规中心及相关功能能够为经常使用合规中心的客户持续提供大规模支持。

<a id="control-status-pop-up-in-the-compliance-status-report"></a>

### 合规状态报告中的控制项状态弹出窗口

<!-- categories: Compliance Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/compliance/compliance_center/compliance_status_report.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/521757)

{{< /details >}}

合规状态报告中的控制项有三种不同状态：

- 通过
- 失败
- 待处理

无论要求关联了多少个控制项，只要至少有一个控制项为“待处理”，整个要求行也会显示为“待处理”。这偏离了用于可视化失败控制项的既定 UX 模式，在该模式中，要求会显示与该要求关联的控制项数量，即使至少有一个控制项失败也是如此。

为了给“待处理”控制项提供更多上下文和信息，我们现在在要求行状态上提供悬停弹出窗口，列出每个控制项的状态。您现在可以了解哪些控制项处于待处理状态，哪些可能成功、哪些可能失败，而不只是看到单一的“待处理”状态。

<a id="enhanced-merge-request-review-experience-with-review-panel"></a>

### 通过评审面板增强合并请求评审体验

<!-- categories: Code Review Workflow -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 链接: [文档](../../user/project/merge_requests/reviews/_index.md#submit-a-review) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/525841)

{{< /details >}}

当您评审合并请求时，在提交评审之前查看您提供的所有评论和反馈可能很有价值。此前，这一体验分散在最终评论和用于查看待处理评论的额外弹出窗口之间，难以获得完整概览。

在进行代码评审时，您现在可以访问一个专用抽屉，它将您所有待处理的草稿评论整合到一个有序视图中。增强的评审面板将评审提交界面移至更易访问的位置，并提供显示待处理评论数量的编号徽章。当您打开该面板时，您会看到所有草稿评论以可滚动列表的形式组织，从而更轻松地在提交前查看和管理您的反馈。

<a id="enhanced-codeowners-file-validation-with-permission-checks"></a>

### 通过权限检查增强 CODEOWNERS 文件验证

<!-- categories: Source Code Management -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 链接: [文档](../../user/project/codeowners/troubleshooting.md#validate-your-codeowners-file) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/15598)

{{< /details >}}

极狐GitLab 现在为 CODEOWNERS 文件提供超越基本语法检查的增强验证。查看 CODEOWNERS 文件时，极狐GitLab 会自动运行全面验证，帮助您在语法和权限问题影响合并请求工作流之前识别它们。

增强验证会检查 CODEOWNERS 文件中的前 200 个唯一用户和群组引用，并验证：

- 所有引用的用户和群组都有权访问该项目。
- 用户具有批准合并请求所需的权限。
- 群组至少具有开发者级别或更高的访问权限。
- 群组中至少有一名具有合并请求审批权限的用户。

这种主动验证通过尽早发现配置问题，帮助防止审批工作流中断，确保您的代码所有者能够在创建合并请求时真正履行其评审职责。

<a id="custom-workspace-initialization-with-poststart-events"></a>

### 使用 `postStart` 事件自定义工作区初始化

<!-- categories: Workspaces -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/workspace/_index.md#user-defined-poststart-events)

{{< /details >}}

极狐GitLab 工作区现在支持 devfile 中的自定义 `postStart` 事件，允许您定义在工作区启动后自动执行的命令。使用这些事件可以：

- 设置开发依赖项。
- 配置您的环境。
- 运行初始化脚本，让您的项目无需人工干预即可立即投入生产。

<a id="view-downstream-pipeline-job-logs-in-vs-code"></a>

### 在 VS Code 中查看下游流水线作业日志

<!-- categories: Editor Extensions -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](https://gitlab.cn/docs/jh/editor_extensions/visual_studio_code/cicd/) | [相关议题](https://gitlab.com/gitlab-org/gitlab-vscode-extension/-/issues/1895)

{{< /details >}}

适用于 VS Code 的 GitLab Workflow 扩展现在可以直接在编辑器中显示下游流水线的作业日志。此前，查看子流水线的日志需要切换到极狐GitLab Web 界面。

此功能通过 [GitLab Co-create 计划](https://about.gitlab.com/community/co-create/)开发。特别感谢 Tim Ryan 的贡献！

<a id="view-inactive-personal-access-tokens"></a>

### 查看未激活的个人访问令牌

<!-- categories: System Access -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/profile/personal_access_tokens.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/425053)

{{< /details >}}

极狐GitLab 会在访问令牌过期或被撤销后自动将其停用。您现在可以查看这些未激活的令牌。此前，访问令牌在变为未激活后便不再可见。此变更增强了这些令牌类型的可追溯性和安全性。

<a id="epic-support-for-gitlab-query-language-views-beta"></a>

### 极狐GitLab 查询语言视图测试版支持史诗

<!-- categories: Wiki, Team Planning -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/glql/fields.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab-query-language/glql-rust/-/issues/30)

{{< /details >}}

我们对极狐GitLab 查询语言（GLQL）视图进行了重大改进。您现在可以在查询中使用 epic 作为类型，以跨群组搜索史诗，并按父史诗进行查询！

这对我们的计划和跟踪能力而言是巨大的一步，使在史诗层级进行查询和组织比以往任何时候都更容易。

<a id="php-support-for-advanced-sast"></a>

### 高级 SAST 支持 PHP

<!-- categories: SAST -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/sast/gitlab_advanced_sast.md#supported-languages) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/14273)

{{< /details >}}

我们为极狐GitLab 高级 SAST 添加了 PHP 支持。
要使用这一新的跨文件、跨函数扫描支持，请[启用高级 SAST](../../user/application_security/sast/gitlab_advanced_sast.md#turn-on-gitlab-advanced-sast)。如果您已启用高级 SAST，PHP 支持会自动激活。

要了解高级 SAST 在每种语言中检测哪些类型的漏洞，请参阅[高级 SAST 覆盖范围页面](../../user/application_security/sast/advanced_sast_coverage.md)。

<a id="filter-by-component-version-in-the-dependency-list"></a>

### 在依赖项列表中按组件版本筛选

<!-- categories: Dependency Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/dependency_list/_index.md#filter-dependency-list) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/16431)

{{< /details >}}

依赖项列表现在支持按组件版本号进行筛选。您可以选择多个版本（例如 `version=1.1,1.2,1.4`），但不支持范围。此功能在群组和项目中均可用。

<a id="variable-precedence-controls-in-pipeline-execution-policies"></a>

### 流水线执行策略中的变量优先级控制

<!-- categories: Security Policy Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/policies/pipeline_execution_policies.md#variables_override-type) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/16430)

{{< /details >}}

安全团队常常需要在安全保障和开发者体验之间取得微妙的平衡。确保安全扫描得到正确执行至关重要，但安全分析器可能需要开发团队提供特定输入才能正确执行。借助变量优先级控制，安全团队现在可以通过新的 `variables_override` 配置选项，对流水线执行策略中变量的处理方式进行精细控制。

使用这一新配置，您现在可以：

- 强制执行容器扫描策略，同时允许项目特定的容器镜像路径（`CS_IMAGE`）。
- 允许 `SAST_EXCLUDED_PATHS` 等较低风险的变量，同时阻止 `SAST_DISABLED` 等高风险变量。
- 使用全局 CI/CD 变量定义受保护（掩码或隐藏）的全局共享凭据，例如 `AWS_CREDENTIALS`，同时在适当情况下允许通过项目级 CI/CD 变量进行项目特定的覆盖。

这一强大功能支持两种方式：

- **默认锁定变量**（`allow: false`）：锁定所有变量，您列为例外的特定变量除外。
- **默认允许变量**（`allow: true`）：允许自定义变量，但通过将其列为例外来限制关键风险。

为了在流水线执行策略是某个 CI/CD 作业的来源时提升可追溯性和故障排除能力，我们还引入了作业日志，帮助开发者和安全团队识别由策略执行的作业。作业日志提供有关变量覆盖影响的详细信息，帮助您了解变量是被策略覆盖还是锁定。

**实际影响**

此增强功能弥合了安全要求与开发者灵活性之间的差距：

- 安全团队可以强制执行标准化扫描，同时允许项目特定的自定义。
- 开发者可以保持对项目特定变量的控制，而无需请求策略例外。
- 组织可以实施一致的安全策略，而不会中断开发工作流。

通过解决这一关键的变量控制难题，极狐GitLab 使组织能够实施稳健的安全策略，而无需牺牲团队高效交付软件所需的灵活性。

<a id="filter-for-bot-and-human-users"></a>

### 按机器人和人类用户筛选

<!-- categories: System Access -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 链接: [文档](../../administration/moderate_users.md#view-users-by-type) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/541186)

{{< /details >}}

已运行较长时间的极狐GitLab 实例往往会有大量人类用户和机器人用户。您现在可以在管理区域中按用户类型筛选用户列表。筛选用户可以帮助您：

- 快速识别并单独管理人类用户与自动化账号。
- 对特定用户类型执行有针对性的管理操作。
- 简化用户审计和管理工作流。

<a id="orcid-identifier-in-user-profile"></a>

### 用户个人资料中的 [ORCID](https://orcid.org/) 标识符

<!-- categories: User Profile -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/profile/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/23543)

{{< /details >}}

极狐GitLab 现在支持用户个人资料中的 ORCID 标识符，使极狐GitLab 对研究人员和学术界更具可访问性和价值。[ORCID](https://orcid.org/)（开放研究者与贡献者身份识别码）为研究人员提供持久的数字标识符，将其与其他研究人员区分开来，并支持研究人员与其专业活动之间的自动关联，确保他们的工作得到正确认可。

<a id="subscribe-to-service-account-pipeline-notifications"></a>

### 订阅服务账号流水线通知

<!-- categories: System Access -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/profile/notifications.md#notifications-about-failed-pipeline-that-doesnt-exist) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/515629)

{{< /details >}}

您现在可以订阅由服务账号触发的流水线事件通知。当流水线通过、失败或被修复时会发送通知。此前，只有当服务账号具有有效的自定义电子邮件地址时，这些通知才会发送到该服务账号的电子邮件地址。

感谢 [Densett](https://gitlab.com/[Densett](https://gitlab.com/Densett))、[Gilles Dehaudt](https://gitlab.com/tonton1728)、[Lenain](https://gitlab.com/lenaing)、[Geoffrey McQuat](https://gitlab.com/gmcquat) 和 [Raphaël Bihoré](https://gitlab.com/rbihore) 的贡献！

<a id="increased-sast-coverage-for-duo-vulnerability-resolution"></a>

### 扩大 Duo 漏洞修复的 SAST 覆盖范围

<!-- categories: Vulnerability Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/vulnerabilities/_index.md#supported-vulnerabilities-for-vulnerability-resolution) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/534307)

{{< /details >}}

此前，您必须手动修复检测到的具有以下通用弱点枚举（CWE）标识符的漏洞：

- CWE-78（命令注入）
- CWE-89（SQL 注入）

现在，Duo 漏洞修复可以自动修复这些漏洞。

<a id="gitlab-runner-181"></a>

### 极狐GitLab Runner 18.1

<!-- categories: GitLab Runner Core -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 链接: [文档](https://gitlab.cn/docs/runner/)

{{< /details >}}

我们今天还发布了极狐GitLab Runner 18.1！极狐GitLab Runner 是高度可扩展的构建代理，负责运行您的 CI/CD 作业并将结果发送回极狐GitLab 实例。极狐GitLab Runner 与极狐GitLab CI/CD 协同工作，后者是极狐GitLab 中包含的开源持续集成服务。

<a id="bug-fixes"></a>

#### 缺陷修复

- [如果您升级到GitLab 17.10 或 17.11，Runner 在请求作业时可能会收到 `404` 响应](https://gitlab.com/gitlab-org/gitlab/-/issues/543351)。

所有变更的列表见极狐GitLab Runner [CHANGELOG](https://gitlab.com/gitlab-org/gitlab-runner/blob/18-1-stable/[CHANGELOG](https://gitlab.com/gitlab-org/gitlab-runner/blob/18-1-stable/CHANGELOG.md).md)。
