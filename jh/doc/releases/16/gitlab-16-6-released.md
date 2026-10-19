---
stage: Release Notes
group: Monthly Release
date: 2023-11-16
title: "极狐GitLab 16.6 发布说明"
description: "极狐GitLab 16.6 发布，极狐GitLab Duo Chat 以测试版形式推出"
---

<!-- markdownlint-disable -->
<!-- vale off -->

2023 年 11 月 16 日，极狐GitLab 16.6 发布，包含以下功能。

<a id="primary-features"></a>

## 主要功能

<a id="gitlab-duo-chat-available-in-beta"></a>

### 极狐GitLab Duo Chat 以测试版形式推出

<!-- categories: Duo Chat -->

{{< details >}}

- 交付方式: JihuLab.com
- 链接: [文档](../../user/gitlab_duo_chat/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/10550)

{{< /details >}}

参与软件开发过程的每个人都会花费大量时间来熟悉代码、史诗、议题和冗长的讨论串。您经常会因为编写摘要、文档、测试甚至代码等日常任务而放慢速度。如果身边有一位专家，能够不带评判地回答 DevSecOps 问题并处理后续问题，就可以帮助您加快软件开发过程。

极狐GitLab Duo Chat 旨在积极解决这些痛点并加速您的工作流。其功能包括：

- 解释或总结议题、史诗和代码。
- 回答关于这些产物的具体问题，例如“收集评论中提出的关于此议题中提出的解决方案的所有论点。”
- 根据这些产物中的信息生成代码或内容。例如，“您能为这段代码编写文档吗？”
- 或者直接让您从头开始，例如“创建一个 .GitLab-ci.yml 配置文件，用于在极狐GitLab CI/CD 流水线中测试和构建 Ruby on Rails 应用程序。”
- 回答您所有与 DevSecOps 相关的问题，无论您是初学者还是专家。例如，“如何为 REST API 设置动态应用程序安全测试？”
- 回答后续问题，以便您可以迭代地完成上述所有场景。

极狐GitLab Duo Chat 作为测试版功能在 JihuLab.com 上提供。它还作为实验性功能集成到我们的 Web IDE 和适用于 VS Code 的 GitLab Workflow 扩展中。

您也可以通过产品内或我们的[反馈议题](https://gitlab.com/gitlab-org/gitlab/-/issues/430124)提供您使用 Duo Chat 的体验反馈，帮助我们完善这些功能。

<a id="automatic-claims-of-enterprise-users"></a>

### 企业用户自动认领

<!-- categories: User Management -->

{{< details >}}

- 交付方式: JihuLab.com
- 链接: [文档](../../user/enterprise_user/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/9675)

{{< /details >}}

当 JihuLab.com 用户的主邮箱地址与已验证的域名匹配时，该用户会被自动认领为企业用户。这为群组所有者提供了更多用户管理控制权，并提高了对用户账号的可见性。用户成为企业用户后，只能将其主邮箱更改为其组织根据已验证域名所拥有的邮箱。

<a id="minimal-forking---only-include-the-default-branch"></a>

### 最小化 forking——仅包含默认分支

<!-- categories: Source Code Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/repository/forking_workflow.md#create-a-fork)

{{< /details >}}

在之前的极狐GitLab 版本中，在 forking 代码仓库时，fork 始终包含代码仓库中的所有分支。现在您可以创建仅包含默认分支的 fork，从而降低复杂性并节省存储空间。如果您不需要其他分支中正在进行的更改，可以创建最小化 forks。

默认的 forking 方式不会改变，仍会包含代码仓库中的所有分支。新选项会显示哪个分支是默认分支，以便您准确了解新 fork 中将包含哪个分支。

<a id="allow-users-to-enforce-mr-approvals-as-a-compliance-policy"></a>

### 允许用户将合并请求审批作为合规策略强制执行

<!-- categories: Security Policy Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/policies/merge_request_approval_policies.md#any_merge_request-rule-type) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/9696)

{{< /details >}}

对于可能进入生产应用程序并使企业面临合规风险和安全漏洞的代码更改，审查力度日益加强。借助扫描结果策略，您可以通过对所有合并请求强制执行双人审批来确保无法进行单方面更改。

扫描结果策略新增了一个选项，可以针对 `Any merge request`，并可结合定义[基于角色的审批人](../../user/application_security/policies/merge_request_approval_policies.md#require_approval-action-type)，确保针对已定义分支的每个合并请求都需要由具有给定角色（所有者、维护者或开发者）的两名（或更多）用户审批。

16.6 版本中在 SaaS 上提供。在私有化部署中，该功能受功能标志 `scan_result_any_merge_request` 控制，并将在 16.7 中默认启用。

<a id="cicd-components-beta-release"></a>

### CI/CD 组件测试版发布

<!-- categories: Pipeline Composition -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../ci/components/_index.md) | [相关议题](https://gitlab.com/groups/gitlab-org/-/epics/9897)

{{< /details >}}

在极狐GitLab 16.1 中，我们[宣布](https://about.gitlab.com/blog/introducing-ci-components/)发布了一项令人兴奋的实验性功能，名为 CI/CD 组件。组件是一个流水线构建块，可以列在即将推出的 CI/CD Catalog 中。

今天，我们很高兴地宣布 CI/CD 组件的测试版可用。在此版本中，我们还改进了组件文件夹结构，与最初的实验版本相比有所提升。如果您已经在测试实验版 CI/CD 组件，则必须迁移到[新的文件夹结构](../../ci/components/_index.md#directory-structure)。您可以在[此处](https://gitlab.com/gitlab-components/)查看一些示例。旧的文件夹结构已弃用，我们计划在接下来的几个版本中将其移除。

如果您试用 CI/CD 组件，也欢迎您试用新的 CI/CD Catalog，该目录目前作为实验性功能提供。您可以在[全球 CI/CD Catalog](../../ci/components/_index.md)中搜索其他人创建并公开发布的组件。此外，如果您创建了自己的组件，也可以选择将其发布到 Catalog 中！

<a id="improved-ui-for-cicd-variable-management"></a>

### 改进的 CI/CD 变量管理 UI

<!-- categories: Secrets Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/variables/_index.md#define-a-cicd-variable-in-the-ui) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/418005)

{{< /details >}}

CI/CD 变量是极狐GitLab CI/CD 的基础组成部分，我们认为可以在设置 UI 中为变量操作提供更好的体验。因此，在此版本中，我们更新了 UI，使用新的抽屉来改进添加和编辑 CI/CD 变量的流程。

例如，以前掩码验证只在您尝试保存 CI/CD 变量时进行，如果验证失败，您必须从头开始。但现在有了新的抽屉，您可以获得实时验证，从而可以即时调整，无需重做任何操作！

我们始终重视并感谢您[对此更改的反馈](https://gitlab.com/gitlab-org/gitlab/-/issues/428807)。

<a id="runner-fleet-dashboard---starter-metrics-beta"></a>

### Runner Fleet Dashboard - 入门指标（测试版）

<!-- categories: Fleet Visibility -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../ci/runners/runner_fleet_dashboard.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/424495)

{{< /details >}}

私有化部署 Runner 机群的运维人员需要可观测性，并能够一目了然地快速回答有关其 Runner 机群基础设施的关键问题。现在，借助 Runner Fleet Dashboard - 管理员视图（测试版），您可以获得可操作的洞察，帮助您快速回答关键的机群管理和开发者体验问题，从实例 Runner 开始。这些问题包括哪些 Runner 存在错误、用于 CI 作业执行的 Runner 队列性能如何，以及哪些 Runner 使用最频繁。旗舰版客户可以独立启用此功能，但鼓励参与[早期采用者计划](https://gitlab.com/groups/gitlab-org/-/epics/11180)。

<a id="scale-and-deployments"></a>

## 扩展与部署

<a id="hide-archived-projects-in-search-results-by-default"></a>

### 默认在搜索结果中隐藏已归档项目

<!-- categories: Global Search -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/search/_index.md#include-archived-projects-in-search-results) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/10957)

{{< /details >}}

以前，用户在项目搜索结果中会看到许多已归档项目。这很成问题，尤其是当已归档项目占据了许多靠前的结果时。我们现在默认过滤掉已归档项目，用户可以选择**包含已归档**来查看所有项目。

<a id="private-group-names-are-hidden-from-unauthorized-users"></a>

### 私有群组名称对未授权用户隐藏

<!-- categories: Groups & Projects -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/group/manage.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/415165)

{{< /details >}}

以前，所有用户在访问项目或群组成员页面的**群组**选项卡时，都可以看到私有群组的名称。为了增强安全性，我们现在对不属于共享群组、共享项目或受邀群组成员的用户隐藏私有群组的名称和来源。相反，这些信息将显示为**私有**。

<a id="comprehensive-list-of-items-that-failed-to-be-imported"></a>

### 导入失败条目的完整列表

<!-- categories: Importers -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/group/import/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/386138)

{{< /details >}}

以前，当通过直接转移迁移极狐GitLab 项目和群组完成，并且某些条目（例如合并请求或议题）未能成功导入时，您可以在[列出已导入群组和项目的页面](../../user/group/import/_index.md)上选择**详情**按钮，并在那里查看相关错误。

然而，错误列表无助于了解总共有多少条目以及具体哪些条目未导入。拥有这些信息对于理解导入过程的结果至关重要。

在此版本中，我们将**详情**按钮替换为**查看失败项**链接。选择**查看失败项**链接会将您带到一个新页面，其中列出了给定群组或项目所有未能导入的条目。对于每个未导入的条目，您可以看到：

- 条目类型。例如，合并请求或议题。
- 发生了哪种错误。
- 关联 ID，这对于调试非常有用。
- 条目在源实例上的 URL（如果可用）（带有 `iid`的条目）。
- 条目在源实例上的标题（如果可用）。例如，合并请求标题或议题标题。

<a id="consistent-navigation-experience-for-all-users"></a>

### 为所有用户提供一致的导航体验

<!-- categories: Navigation -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../tutorials/left_sidebar/_index.md)

{{< /details >}}

16.0 版本引入了新的导航体验，并于 2023 年 6 月 2 日成为所有用户的默认体验。在随后的里程碑中，我们根据大量用户反馈进行了许多改进。回退到旧导航的功能现已移除。导航方面还计划了更多令人兴奋的更改，但目前所有用户都拥有一致的导航体验。

回顾一下，使用新的极狐GitLab 导航，您可以：

- 固定菜单项，将最常用的项目或群组项保存在顶部
- 隐藏和“窥视”导航以显示更宽的屏幕
- 使用键盘快捷键轻松搜索菜单项
- 继续使用之前导航中的所有主题
- 使用与 DevOps 工作流一致的、组织更合理的分区

<a id="gitlab-silent-mode"></a>

### 极狐GitLab 静默模式

<!-- categories: Disaster Recovery -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../administration/silent_mode/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/9826)

{{< /details >}}

启用极狐GitLab 静默模式后，它会阻止极狐GitLab 实例的所有主要出站流量，例如通知邮件、集成、Webhook 和镜像。这样您就可以针对极狐GitLab 站点执行测试，而不会向用户和其他集成产生流量。您可以使用静默模式来测试恢复的备份或提升的 Geo 灾难恢复站点，而不会影响您的主极狐GitLab 站点或最终用户。

<a id="unified-devops-and-security"></a>

## 统一 DevOps 与安全

<a id="real-time-kubernetes-status-updates-in-the-gitlab-ui"></a>

### 极狐GitLab UI 中的实时 Kubernetes 状态更新

<!-- categories: Deployment Management, Environment Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/environments/kubernetes_dashboard.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/422945)

{{< /details >}}

在极狐GitLab 16.6 中，您可以在环境页面上使用集群 UI 集成来确定当前正在运行的应用程序的状态，而无需离开极狐GitLab。以前，状态是在 UI 加载时通过一次性请求更新的，这使得跟踪部署进度非常不便。当前版本的极狐GitLab 升级了底层连接，使用 Kubernetes watch API 来获取 Flux 协调和 Pod 状态，并在极狐GitLab UI 中提供近乎实时的集群状态更新。

<a id="connect-to-kubernetes-clusters-with-the-gitlab-cli"></a>

### 使用 GitLab CLI 连接 Kubernetes 集群

<!-- categories: GitLab CLI, Deployment Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/clusters/agent/user_access.md#access-a-cluster-with-the-kubernetes-api) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/11455)

{{< /details >}}

从极狐GitLab 16.4 版本开始，您可以使用极狐GitLab Kubernetes Agent 和个人访问令牌从本地终端连接到 Kubernetes 集群。在初始版本中，设置本地集群配置需要执行多个命令并使用长期有效的访问令牌。在过去的一个月里，我们通过扩展 GitLab CLI 来简化和改进设置过程的安全性。

GitLab CLI 现在可以列出从极狐GitLab 项目检出目录或指定项目可用的 Agent 连接。您可以通过专用命令通过选定的 Agent 设置连接。当 `kubectl` 或任何其他工具需要向集群进行身份验证时，GitLab CLI 会为已登录用户生成一个临时的、受限的令牌。

<a id="allow-compliance-teams-to-prevent-pushing-and-force-pushing-into-protected-branches"></a>

### 允许合规团队阻止向受保护分支推送和强制推送

<!-- categories: Security Policy Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/policies/merge_request_approval_policies.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/9706)

{{< /details >}}

作为添加到扫描结果策略中的几项新设置之一，旨在帮助[安全策略的合规执行](https://gitlab.com/groups/gitlab-org/-/epics/9704)，此控制将限制利用项目级设置来规避策略的能力。

对于每个现有或新的扫描结果策略，您可以启用 `Prevent pushing and force pushing`，使其对策略中定义的分支生效，以防止用户绕过合并请求流程直接将更改推送到分支。

16.6 版本中在 SaaS 上提供。在私有化部署中，该功能受功能标志 `scan_result_policies_block_force_push` 控制，并将在 16.7 中默认启用。

<a id="group-level-audit-event-streaming-to-aws-s3"></a>

### 群组级审计事件流式传输到 AWS S3

<!-- categories: Audit Events -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../administration/compliance/audit_event_reports.md)

{{< /details >}}

基于我们与外部日志记录或数据聚合工具的集成，您现在可以选择 AWS S3 作为顶级群组审计事件流的目标。此功能提供了相关信息，以实现更轻松、更顺畅的集成。

以前，您必须使用自定义 HTTP 请求头来尝试构建 AWS S3 会接受的请求。这种方法容易出错，并且可能难以排查。

<a id="improved-handling-of-unresponsive-external-status-checks"></a>

### 改进对无响应外部状态检查的处理

<!-- categories: Compliance Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/project/merge_requests/status_checks.md#status-checks-widget)

{{< /details >}}

以前，合并请求上的外部状态检查会持续轮询外部 URL，直到收到成功或失败的响应。这可能导致某些状态检查看起来一直处于无响应的挂起状态。

现在，已加入 2 分钟超时，因此如果您在 2 分钟后仍未收到外部系统的任何响应，可以手动重试状态检查。

<a id="changes-to-the-vulnerability-reports-tool-filter"></a>

### 漏洞报告“工具”筛选器的更改

<!-- categories: Vulnerability Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/vulnerability_report/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/11237)

{{< /details >}}

以前，漏洞报告允许您按极狐GitLab 支持的工具类型的静态列表进行筛选，然后是自定义扫描器的动态列表。在此版本中，您现在可以按分析器分组选择工具类型。

<a id="service-accounts-have-optional-expiry-dates"></a>

### 服务账号具有可选的到期日期

<!-- categories: User Management -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/profile/personal_access_tokens.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/421420)

{{< /details >}}

极狐GitLab 管理员和群组所有者可以选择是否要为服务账号强制执行到期日期。以前，服务账号令牌必须在一年内到期，与个人、项目和群组访问令牌的到期限制一致。这使管理员和群组所有者能够在安全性和易用性之间选择最符合其目标的平衡点。

<a id="prevent-duplicate-nuget-packages"></a>

### 防止重复的 NuGet 软件包

<!-- categories: Package Registry -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/packages/nuget_repository/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/293748)

{{< /details >}}

您可以使用极狐GitLab 软件包仓库来发布和下载项目的 NuGet 软件包。默认情况下，您可以多次发布相同的软件包名称和版本。

但是，您可能希望防止重复上传，尤其是对于发布版本。在此版本中，极狐GitLab 扩展了软件包仓库的群组设置，以便您可以允许或拒绝重复的软件包上传。

您可以使用[极狐GitLab API](../../api/graphql/reference/_index.md#packagesettings) 或从 UI 调整此设置。

<a id="upload-packages-to-the-maven-repository-with-basic-http-authentication"></a>

### 使用基本 HTTP 身份验证将软件包上传到 Maven 仓库

<!-- categories: Package Registry -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/packages/maven_repository/_index.md#basic-http-authentication) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/277385)

{{< /details >}}

极狐GitLab 软件包仓库现在支持使用基本 HTTP 身份验证上传 Maven 软件包。以前，您只能使用基本 HTTP 身份验证下载 Maven 软件包。这种不一致使开发人员难以为其项目配置和维护身份验证。

不支持使用 `sbt` 发布产物，但[议题 408479](https://gitlab.com/gitlab-org/gitlab/-/issues/408479) 提议添加此功能。

<a id="container-scanning-exclude-findings-which-wont-be-fixed"></a>

### 容器扫描：排除不会被修复的发现项

<!-- categories: Software Composition Analysis -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/container_scanning/_index.md#available-cicd-variables) | [相关议题](https://gitlab.com/groups/gitlab-org/-/epics/6846)

{{< /details >}}

容器扫描结果可能包含供应商已评估并决定不修复的发现项。为了让您专注于可操作的发现项，您现在可以排除此类发现项。有关配置选项，请参阅极狐GitLab 文档。

<a id="include-cvss-vectors-in-the-vulnerability-report-export"></a>

### 在漏洞报告导出中包含 CVSS 向量

<!-- categories: Software Composition Analysis -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/vulnerability_report/_index.md) | [相关议题](https://gitlab.com/groups/gitlab-org/-/epics/11213)

{{< /details >}}

当您从漏洞报告导出信息时，现在会包含 CVSS 向量信息。这些额外数据可帮助您在极狐GitLab 之外分析和排查漏洞。

<a id="added-support-for-sbt-projects-using-java-21"></a>

### 新增对使用 Java 21 的 SBT 项目的支持

<!-- categories: Software Composition Analysis -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/dependency_scanning/legacy_dependency_scanning/_index.md#obtaining-dependency-information-by-parsing-lockfiles) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/421174)

{{< /details >}}

依赖扫描和许可证扫描现在支持使用 Java 21 的 SBT 项目。

<a id="dast-analyzer-updates"></a>

### DAST 分析器更新

<!-- categories: DAST -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/application_security/dast/browser/checks/_index.md#active-checks)

{{< /details >}}

在 16.6 版本里程碑期间，我们默认启用了以下基于浏览器的 DAST 主动检查：

- 检查 94.1 取代 ZAP 检查 90019，用于识别服务器端代码注入（PHP）。
- 检查 94.2 取代 ZAP 检查 90019，用于识别服务器端代码注入（Ruby）。
- 检查 94.3 取代 ZAP 检查 90019，用于识别服务器端代码注入（Python）。
- 检查 943.1 取代 ZAP 检查 40033，用于识别数据查询逻辑中特殊元素的不当中和。
- 检查 74.1 取代 ZAP 检查 90017，用于识别 XSLT 注入。

<a id="macos-14-sonoma-and-xcode-15-image-support"></a>

### macOS 14 (Sonoma) 和 Xcode 15 镜像支持

<!-- categories: GitLab Hosted Runners -->

{{< details >}}

- 交付方式: JihuLab.com
- 链接: [文档](../../ci/runners/hosted_runners/macos.md#supported-macos-images) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/431424)

{{< /details >}}

团队现在可以在 macOS 14 和 Xcode 15 上无缝地创建、测试和部署面向 Apple 生态系统的应用程序。

macOS 上的 SaaS Runner 使您能够在安全、按需的极狐GitLab Runner 构建环境中提高开发团队构建和部署需要 macOS 的应用程序的速度，该环境与极狐GitLab CI/CD 集成。

立即试用，在您的 .GitLab-ci.yml 文件中使用 `macos-14-xcode-15` 作为镜像。

<a id="gitlab-runner-166"></a>

### 极狐GitLab Runner 16.6

<!-- categories: GitLab Runner Core -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](https://gitlab.cn/docs/runner/)

{{< /details >}}

我们今天还发布了极狐GitLab Runner 16.6！极狐GitLab Runner 是轻量级、高度可扩展的代理，用于运行您的 CI/CD 作业并将结果发送回极狐GitLab 实例。极狐GitLab Runner 与极狐GitLab CI/CD 协同工作，后者是极狐GitLab 中包含的开源持续集成服务。

<a id="whats-new"></a>

#### 新功能

- [GitLab Runner 用于 GCP Compute Engine 的 Fleeting 插件 - 测试版](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/29409)
- [为 Docker 执行器实现优雅关闭](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/6359)
- [为 Kubernetes 使用存储类动态创建 PVC 卷](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/27835)
- [在 Kubernetes 执行器中通过 `image.entrypoint` 覆盖容器入口点](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/30713)

<a id="bug-fixes"></a>

#### 缺陷修复

- [升级到 GitLab Runner 16.5.0 后，Pod 因 Liveness 探针失败错误而不断重启](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/36959)
- [调试终端 - 变量包含文件内容而非文件路径](https://gitlab.com/gitlab-org/gitlab/-/issues/399770)
- [Kubernetes 中的作业执行 Pod 不处理信号](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/28162)
- [使用 Podman 的 GitLab Runner Docker 执行器中的服务无法启动](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/29480)

所有更改的列表见极狐GitLab Runner [CHANGELOG](https://gitlab.com/gitlab-org/gitlab-runner/blob/16-6-stable/CHANGELOG.md)。
