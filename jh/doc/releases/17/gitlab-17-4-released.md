---
stage: Release Notes
group: Monthly Release
date: 2024-09-19
title: "极狐GitLab 17.4 发行说明"
description: "GitLab 17.4 released with More context-aware GitLab Duo Code Suggestions using open tabs"
---

<!-- markdownlint-disable -->
<!-- vale off -->

2024 年 9 月 19 日，极狐GitLab 17.4 发布了以下功能。

此外，我们要感谢所有贡献者，包括本月的杰出贡献者。

<a id="this-months-notable-contributor-archish-thakkar"></a>

## 本月的杰出贡献者：Archish Thakkar

大家都可以 [提名极狐GitLab 社区贡献者](https://jihulab.com/gitlab-cn/developer-relations/contributor-success/team-task/-/issues/490)！为活跃候选人提供支持或添加新的提名！🙌

Archish Thakkar 是今年以来极狐GitLab 的顶级贡献者之一，拥有 [46 个已关闭议题](https://jihulab.com/groups/gitlab-cn/-/issues/?sort=created_date&state=closed&assignee_username%5B%5D=archish27&first_page_size=100) 和 [119 个已合并 MR](https://jihulab.com/groups/gitlab-cn/-/merge_requests?assignee_username%5B%5D=archish27&first_page_size=100&sort=created_date&state=merged)。这些贡献帮助 Archish 在最近两次 [极狐GitLab 黑客马拉松](https://gitlab-community.gitlab.io/community-projects/merge-request-leaderboard/?&createdAfter=2024-08-26&createdBefore=2024-09-02&mergedBefore=2024-10-03&label=Hackathon) 中取得了领先位置。他是 [Middleware](https://middleware.io/) 的高级软件工程师，也是一位热情的开源贡献者。

Archish 由极狐GitLab 工程生产力团队的后端工程师 [Peter Leitzen](https://gitlab.com/splattael) 提名。该提名得到了极狐GitLab 后端工程师 [Max Woolf](https://gitlab.com/mwoolf) 和高级后端工程师 [James Nutt](https://gitlab.com/jnutt) 的支持。过去两个月，Archish 的贡献持续增加，他始终如一地展现了对改进极狐GitLab 代码库的卓越承诺，贡献了多项 QoL（质量生活）修复并减少了技术债务。

非常感谢 Archish 以及极狐GitLab 所有开源贡献者共同打造极狐GitLab！

<a id="primary-features"></a>

## 主要功能

<a id="more-context-aware-gitlab-duo-code-suggestions-using-open-tabs"></a>

### 利用打开标签页获得更具上下文感知的极狐GitLab Duo 代码建议

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Add-ons: Duo Pro, Duo Enterprise
- Links: [文档](https://gitlab.cn/docs/user/project/repository/code_suggestions/context.md)

{{< /details >}}

利用其他打开标签页的内容，提升编码工作流并获得更具上下文感知的代码建议。

这项对代码建议的改进现在使用您已打开编辑器标签页的内容，以提供更相关、更准确的代码推荐。

<a id="auto-merge-when-all-checks-pass"></a>

### 所有检查通过时自动合并

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](https://gitlab.cn/docs/user/project/merge_requests/auto_merge.md)

{{< /details >}}

合并请求有许多必须通过才能合并的必检项。这些检查包括审批、未解决的讨论、流水线以及需要满足的其他项目。当您负责合并代码时，可能难以跟踪所有这些事件，并知道何时返回检查合并请求是否可以合并。

极狐GitLab 现在支持合并请求中所有检查的 **自动合并**。自动合并在所有必检项通过之前，允许任何有资格合并的用户将合并请求设置为 **自动合并**。随着合并请求在其生命周期中继续推进，最后一个失败的检查通过后，合并请求会自动合并。

我们对这一改进感到非常兴奋，它将加速您的合并请求工作流程。

<a id="extension-marketplace-now-available-in-the-web-ide"></a>

### Web IDE 中现可使用扩展市场

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](https://gitlab.cn/docs/user/project/web_ide/_index.md#manage-extensions)

{{< /details >}}

我们非常激动地宣布，JihuLab.com 上的 Web IDE 中推出了扩展市场。通过扩展市场，您可以发现、安装和管理第三方扩展，并提升您的开发体验。有些扩展需要本地运行时环境，因此不兼容纯 Web 版本。不过，您仍然可以从成千上万的扩展中选择，以提高生产力或自定义您的工作流程。

扩展市场默认是禁用的。要开始使用，您可以在 [用户偏好设置](https://gitlab.cn/-/profile/preferences) 的 **集成** 部分启用扩展市场。对于 [企业用户](../../user/enterprise_user/_index.md)，只有顶级群组的所有者角色才能启用扩展市场。

<a id="secure-sudo-access-for-workspaces"></a>

### 工作空间的安全 sudo 访问

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](https://gitlab.cn/docs/user/workspace/configuration.md#configure-sudo-access-for-a-workspace)

{{< /details >}}

您现在可以为工作空间配置 sudo 访问权限，从而更轻松地在开发环境中直接安装、配置和运行依赖项。我们实现了三种安全方法，确保无缝的开发体验：

- Sysbox
- Kata Containers
- 用户命名空间

借助此功能，您可以完全自定义环境，以匹配您的工作流和项目需求。

<a id="list-kubernetes-resource-events"></a>

### 列出 Kubernetes 资源事件

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](https://gitlab.cn/docs/ci/environments/kubernetes_dashboard.md)

{{< /details >}}

极狐GitLab 提供对 Pod 和流式 Pod 日志的实时视图。但之前，我们未在界面中显示特定资源的事件信息，因此您仍需使用第三方工具来调试 Kubernetes 部署。本版本将事件添加到了 [Kubernetes 仪表板](../../ci/environments/kubernetes_dashboard.md) 的资源详情视图中。

这是事件首次添加到界面。目前，每次打开资源详情视图时，事件都会刷新。您可以跟踪实时事件流的发展动态。

<a id="gitlab-pages-without-wildcard-dns-is-generally-available"></a>

### 极狐GitLab Pages 无需通配符 DNS 现已正式可用

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](https://gitlab.cn/docs/administration/pages/_index.md#dns-configuration-for-single-domain-sites) | [相关史诗](https://jihulab.com/groups/gitlab-cn/-/epics/13404)

{{< /details >}}

此前，创建极狐GitLab Pages 项目需要像 `name.example.io` 或 `name.pages.example.io` 这样的域名格式。这一要求意味着您必须设置通配符 DNS 记录和 TLS 证书。在本版本中，无需 DNS 通配符即可设置极狐GitLab Pages 项目已从 Beta 转为正式可用。

取消通配符证书的要求减轻了极狐GitLab Pages 的管理负担。一些客户由于组织对通配符 DNS 记录或证书的限制，无法使用极狐GitLab Pages。

<a id="gitlab-pages-parallel-deployments-in-beta"></a>

### 极狐GitLab Pages 并行部署（Beta）

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](https://gitlab.cn/docs/user/project/pages/_index.md#parallel-deployments) | [相关史诗](https://jihulab.com/groups/gitlab-cn/-/epics/10914)

{{< /details >}}

本版本引入了 Pages 并行部署的 Beta 功能。您现在可以轻松预览更改并管理极狐GitLab Pages 站点的并行部署。这一增强功能让您可以无缝实验新想法，从而自信地测试和完善您的站点。通过及早发现问题，您可以确保线上站点保持稳定和精致，并在极狐GitLab Pages 已有的优秀基础上进一步拓展。

此外，当您部署应用或网站的不同语言版本时，并行部署还可用于本地化。

<a id="summarize-issue-discussions-with-gitlab-duo-chat"></a>

### 使用极狐GitLab Duo Chat 总结议题讨论

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Add-ons: Duo Enterprise
- Links: [文档](https://gitlab.cn/docs/user/discussions/_index.md#summarize-issue-discussions-with-gitlab-duo-chat)

{{< /details >}}

要深入了解冗长的议题讨论可能是一项耗时巨大的工作。在此版本中，AI 生成的议题讨论摘要现已集成到 Duo Chat 中，并对 JihuLab.com 和私有化部署客户正式可用。

<a id="advanced-sast-is-generally-available"></a>

### 高级 SAST 正式可用

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](https://gitlab.cn/docs/user/application_security/sast/gitlab_advanced_sast.md)

{{< /details >}}

我们非常激动地宣布，高级静态应用安全测试（SAST）扫描器现已对所有极狐GitLab 旗舰版客户正式可用。

高级 SAST 是一款全新扫描器，其技术源于我们 [今年早些时候收购的 Oxeye](https://gitlab.cn/blog/oxeye-joins-gitlab-to-advance-application-security-capabilities/)。它使用专有的检测引擎，规则由内部安全研究提供信息，能够识别第一方代码中可被利用的漏洞。它可提供更准确的结果，让开发者和安全团队无需从大量误报结果中筛选噪音。

除了新的扫描引擎，极狐GitLab 17.4 还包含：

- 全新的 [代码流视图](../../user/application_security/vulnerabilities/_index.md#vulnerability-code-flow)，可跟踪漏洞在文件和函数间的路径。
- 一项自动迁移功能，允许高级 SAST “接管” 之前极狐GitLab SAST 扫描器的现有结果。

要了解更多信息，请参阅 [公告博客](https://gitlab.cn/blog/gitlab-advanced-sast-is-now-generally-available/)。

<a id="hide-cicd-variable-values-in-the-ui"></a>

### 在 UI 中隐藏 CI/CD 变量值

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](https://gitlab.cn/docs/ci/variables/#define-a-cicd-variable-in-the-ui)

{{< /details >}}

您可能不希望任何人在变量保存到项目设置后看到其值。现在，在创建 CI/CD 变量时，您可以选择新的 **遮罩并隐藏** 可见性选项。选择此选项将永久遮罩 CI/CD 设置界面中的变量值，从而限制未来任何人查看该值，并降低数据可见性。

<a id="scale-and-deployments"></a>

## 规模化与部署

<a id="omnibus-improvements"></a>

### Omnibus 改进

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](https://gitlab.cn/docs/omnibus/)

{{< /details >}}

极狐GitLab 17.4 在全新安装的极狐GitLab 中默认包含 PostgreSQL 16。

极狐GitLab 17.7 将包含 OpenSSL V3。这将影响那些外部集成设置不满足出站连接最低要求 TLS 1.2 或以上，以及至少 112 位加密的 TLS 证书的 Omnibus 实例。如果您的实例可能受到影响，请查看我们的 [OpenSSL 升级文档](https://gitlab.cn/docs/omnibus/settings/ssl/openssl_3.html) 以获取更多信息。

<a id="list-groups-invited-to-a-group-or-project-using-the-groups-or-projects-api"></a>

### 使用群组或项目 API 列出受邀加入群组或项目的群组

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](https://gitlab.cn/docs/api/groups.md#list-invited-groups)

{{< /details >}}

我们为群组 API 和项目 API 添加了新的端点，用于获取已受邀加入群组或项目的群组。此功能此前仅在群组或项目的成员页面提供。我们希望这一补充能让您更轻松地自动化管理群组和项目的成员关系。这些端点的速率限制为每个用户每分钟 60 个请求。

<a id="restrict-group-access-by-domain-with-the-groups-api"></a>

### 使用群组 API 按域限制群组访问

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](https://gitlab.cn/docs/api/groups.md#update-group-attributes)

{{< /details >}}

此前，您只能在 UI 中为群组添加域限制。现在，您还可以通过群组 API 中的新 `allowed_email_domains_list` 属性来实现。

<a id="improved-source-display-for-group-and-project-members"></a>

### 改进群组和项目成员的来源显示

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](https://gitlab.cn/docs/user/project/members/_index.md#membership-types)

{{< /details >}}

我们简化了群组和项目成员页面中来源列的显示方式。直接成员仍然显示为 `直接成员`。继承的成员现在显示为 `继承自`，后跟群组名称。通过邀请群组加入群组或项目而添加的成员显示为 `被邀请的群组`，后跟群组名称。对于从被邀请到父群组的群组中继承的成员，我们只显示最后一步，以使管理成员的用户能清晰操作。

<a id="gitlab-duo-seat-assignment-email"></a>

### 极狐GitLab Duo 席位分配邮件

{{< details >}}

- Tier: 专业版，旗舰版
- Add-ons: Duo Pro
- Links: [文档](https://gitlab.cn/docs/subscriptions/subscription-add-ons.md#assign-gitlab-duo-seats)

{{< /details >}}

私有化部署实例上的用户在获得极狐GitLab Duo 席位分配时将收到一封邮件。此前，除非有人告知或您在极狐GitLab UI 中注意到新功能，否则您并不知道自己被分配了席位。

要禁用此邮件，管理员可以禁用 `duo_seat_assignment_email_for_sm` 功能标志。

<a id="resend-failed-webhook-requests-with-the-api"></a>

### 使用 API 重新发送失败的 Webhook 请求

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](https://gitlab.cn/docs/api/project_webhooks.md#resend-a-project-webhook-event)

{{< /details >}}

此前，极狐GitLab 仅支持在 UI 中重新发送 Webhook 请求，当大量请求失败时效率很低。

为了能够让您以编程方式处理失败的 Webhook 请求，本版本中，得益于社区贡献，我们添加了相应的 API 端点：

- [项目 Webhook 请求](https://gitlab.cn/docs/api/project_webhooks.md#resend-a-project-webhook-event)
- [群组 Webhook 请求](https://gitlab.cn/docs/api/group_webhooks.md#resend-group-hook-event)（仅限专业版和旗舰版）

您现在可以：

1. 获取 [项目钩子](https://gitlab.cn/docs/api/project_webhooks.md#list-project-webhook-events) 或 [群组钩子](https://gitlab.cn/docs/api/group_webhooks.md#list-all-group-hook-events) 事件列表。
1. 筛选列表查看失败情况。
1. 使用任一事件的 `id` 来重新发送它。

感谢 [Phawin](https://gitlab.com/lifez) 的 [社区贡献](https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/151130)！

<a id="idempotency-keys-for-webhook-requests"></a>

### Webhook 请求的幂等键

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](https://gitlab.cn/docs/user/project/integrations/webhooks.md#delivery-headers)

{{< /details >}}

从本版本开始，我们在 Webhook 请求头中支持幂等键。幂等键是一个在 Webhook 重试中保持一致的唯一 ID，允许 Webhook 客户端检测重试。使用 `Idempotency-Key` 头来确保集成中 Webhook 效果的幂等性。

感谢 [Van](https://gitlab.com/van.m.anderson) 的 [社区贡献](https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/160952)！

<a id="unified-devops-and-security"></a>

## 统一的 DevOps 与安全

<a id="cicd-component-for-code-intelligence"></a>

### 代码智能的 CI/CD 组件

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](https://gitlab.cn/docs/user/project/code_intelligence.md#with-the-cicd-component)

{{< /details >}}

极狐GitLab 中的代码智能可在浏览仓库时提供代码导航功能。开始使用代码导航通常很复杂，因为您必须配置一个 CI/CD 作业。该作业可能需要自定义脚本来提供正确的输出和产物。

极狐GitLab 现在支持官方的 [代码智能 CI/CD 组件](https://jihulab.com/explore/catalog/components/code-intelligence)，以便于设置。按照 [使用组件](../../ci/components/_index.md#use-a-component) 的说明将此组件添加到您的项目中。这大大简化了在极狐GitLab 中采用代码智能的过程。

目前，该组件支持以下语言：

- Go 1.21 及以上版本。
- TypeScript 或 JavaScript。

我们将继续评估 [可用的 SCIP 索引器](https://github.com/sourcegraph/scip?tab=readme-ov-file#tools-using-scip)，以寻求为新组件扩展更广泛的语言支持。如果您有兴趣添加对某种语言的支持，请在 [代码智能组件](https://jihulab.com/components/code-intelligence) 项目中发起合并请求。

<a id="linked-files-in-merge-request-show-first"></a>

### 合并请求中链接文件首先显示

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](https://gitlab.cn/docs/user/project/merge_requests/changes.md#show-a-linked-file-first)

{{< /details >}}

当您分享指向合并请求中特定文件的链接时，通常是因为您希望对方查看文件内的内容。合并请求以前需要先加载所有文件，然后才能滚动到您引用的特定位置。直接链接到文件是提高合并请求协作速度的绝佳方式：

1. 找到您想首先显示的文件。右键单击文件名以复制其链接。
1. 当您访问该链接时，所选文件会显示在列表顶部。文件浏览器会在文件名旁边显示一个链接图标。

<a id="non-deployment-jobs-to-protected-environments-arent-turned-into-manual-jobs"></a>

### 针对受保护环境的非部署作业不会变成手动作业

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](https://gitlab.cn/docs/ci/jobs/job_control.md#types-of-manual-jobs)

{{< /details >}}

由于一个实现问题，`action: prepare`、`action: verify` 和 `action: access` 作业在针对受保护环境运行时变成了手动作业。这些作业需要手动交互才能运行，尽管它们不需要任何额外的审批。

极狐GitLab 计划修复该实现，使这些作业不再变为手动作业。在此提议的变更之后，为保持当前行为，您需要显式地将作业设置为手动作业。现在，您可以通过启用 `prevent_blocking_non_deployment_jobs` 功能标志来切换到新实现。

任何提议的破坏性变更旨在区分 `environment.action: prepare | verify | access` 值的行为。`environment.action: access` 关键词将继续保持最接近当前行为的状态。为防止未来的兼容性问题，您现在应检查对这些关键词的使用。

<a id="trigger-a-flux-reconciliation-from-the-cluster-ui"></a>

### 从集群 UI 触发 Flux 调谐

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](https://gitlab.cn/docs/ci/environments/kubernetes_dashboard.md)

{{< /details >}}

尽管您可以配置 Flux 按指定时间间隔触发调谐，但在某些情况下您可能希望立即进行调谐。在此前的版本中，您可以从 CI/CD 流水线或命令行触发调谐。在极狐GitLab 17.4 中，您现在无需额外配置即可从 Kubernetes 仪表板触发调谐。

要触发调谐，请前往已配置的仪表板并选择 Flux 状态徽章。

<a id="optional-token-expiration"></a>

### 可选的令牌过期

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](https://gitlab.cn/docs/administration/settings/account_and_limit_settings.md#require-expiration-dates-for-new-access-tokens)

{{< /details >}}

管理员现在可以决定是否强制要求个人、项目和群组访问令牌设置过期日期。如果管理员禁用此设置，则新生成的任何访问令牌将不需要设置过期日期。默认情况下，此设置为启用状态，要求过期日期小于最大允许生命周期。此设置适用于极狐GitLab 16.11 及更高版本。

<a id="search-by-multiple-compliance-frameworks"></a>

### 按多个合规框架搜索

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](https://gitlab.cn/docs/user/compliance/compliance_center/compliance_projects_report.md)

{{< /details >}}

在极狐GitLab 17.3 中，我们为用户提供了向项目添加多个合规框架的功能。

现在，您可以按多个合规框架进行搜索，这使搜索附加了多个合规框架的项目更加容易。

<a id="grant-read-access-to-pipeline-execution-yaml-files-in-projects-linked-to-security-policies"></a>

### 授予对链接至安全策略项目的流水线执行 YAML 文件的读取权限

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](https://gitlab.cn/docs/user/application_security/policies/_index.md)

{{< /details >}}

在极狐GitLab 17.4 中，我们为安全策略添加了一个设置，可用于授予所有链接项目对 `pipeline-execution.yml` 文件的读取权限。此设置让您能更灵活地让需要跨项目全局执行流水线的用户、机器人或令牌进行操作。例如，您可以确保群组或项目访问令牌能够读取安全策略配置，以便在流水线执行期间触发流水线。您仍然无法直接查看安全策略项目的仓库或 YAML 文件。该配置仅在创建流水线时使用。

要配置此设置，请前往您想共享的安全策略项目。选择 **设置 > 通用 > 可见性、项目功能、权限**，滚动到 **流水线执行策略**，然后启用 **向以其作为安全策略项目源进行安全策略链接的项目授予对此仓库的访问权限** 切换开关。

<a id="support-suffix-for-jobs-with-name-collisions-in-pipeline-execution-policy-pipelines"></a>

### 在流水线执行策略流水线中为名称冲突的作业提供后缀支持

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](https://gitlab.cn/docs/user/application_security/policies/pipeline_execution_policies.md#pipeline_execution_policy-schema)

{{< /details >}}

作为对 [17.2 版本流水线执行策略](https://gitlab.cn/releases/2024/07/18/gitlab-17-2-released/#pipeline-execution-policy-type) 的增强，策略创建者现在可以配置流水线执行策略，以优雅地处理作业名称冲突。通过流水线执行策略的 `policy.yml`，您现在可以配置以下选项：

- `suffix: on_conflict` 配置策略以通过重命名策略作业来优雅地处理冲突，这是新的默认行为
- `suffix: never` 强制所有作业名称保持唯一，如果发生冲突则会使流水线失败，这是自 17.2 以来的默认行为
通过这一改进，你可以确保流水线执行策略中执行的安全性和合规性作业始终运行，同时防止对下游开发人员造成不必要的影响。

在后续增强中，我们将在策略编辑器中引入该配置选项。

### 可调整大小的 Wiki 侧边栏

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/wiki/_index.md)

{{< /details >}}

<a id="resizable-wiki-sidebar"></a>

### 可调整大小的 Wiki 侧边栏

你现在可以调整 Wiki 侧边栏以查看更多页面标题，从而提高内容的整体可发现性。随着 Wiki 内容的增长，拥有可调整大小的侧边栏有助于更高效地管理和浏览复杂层次结构或广泛的页面列表。

### 支持导入 CycloneDX 1.6 SBOM

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../ci/yaml/artifacts_reports.md#artifactsreportscyclonedx)

{{< /details >}}

<a id="support-for-ingesting-cyclonedx-1-6-sboms"></a>

### 支持导入 CycloneDX 1.6 SBOM

极狐GitLab 15.3 添加了对[导入 CycloneDX SBOM](../../ci/yaml/artifacts_reports.md#artifactsreportscyclonedx) 的支持。

在极狐GitLab 17.4 中，我们添加了对导入 CycloneDX 1.6 版本 SBOM 的支持。

目前不支持与硬件 (HBOM)、服务 (SaaSBOM) 和 AI/ML 模型 (AI/ML-BOM) 相关的字段。包含这些 BOM 数据的 SBOM 将被处理，但不会分析或向用户展示这些数据。对这些其他 BOM 类型的支持正在此[史诗](https://jihulab.com/groups/gitlab-cn/-/epics/14989)中跟踪。

### 自动清理已移除的 SAST 分析器

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/sast/analyzers.md#analyzers-that-have-reached-end-of-support)

{{< /details >}}

<a id="automatic-cleanup-for-removed-sast-analyzers"></a>

### 自动清理已移除的 SAST 分析器

在[极狐GitLab 17.0](../../update/deprecations.md#sast-analyzer-coverage-changing-in-gitlab-170)、[16.0](../../update/deprecations.md#sast-analyzer-coverage-changing-in-gitlab-160) 和 [15.4](../../update/deprecations.md#sast-analyzer-consolidation-and-cicd-template-changes) 中，我们精简了极狐GitLab SAST，使其使用更少的独立分析器来扫描代码中的漏洞。

现在，当你升级到极狐GitLab 17.3.1 或更高版本后，一次数据迁移将自动解决[已终止支持的分析器](../../user/application_security/sast/analyzers.md#analyzers-that-have-reached-end-of-support)遗留的漏洞。这有助于清理你的漏洞报告，让你专注于由最新分析器仍然检测到的漏洞。

该迁移仅解决你尚未确认或关闭的漏洞，并且不会影响之前已[自动转换为基于 Semgrep 的扫描](../../user/application_security/sast/analyzers.md#transition-to-semgrep-based-scanning)的漏洞。

### 密钥检测支持 Anthropic API 密钥

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/secret_detection/detected_secrets.md)

{{< /details >}}

<a id="secret-detection-support-for-anthropic-api-keys"></a>

### 密钥检测支持 Anthropic API 密钥

流水线和客户端密钥检测现在均支持检测 Anthropic API 密钥。

### JaCoCo 测试覆盖率可视化支持（测试版）

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../ci/testing/code_coverage/jacoco.md)

{{< /details >}}

<a id="jacoco-support-for-test-coverage-visualization-available-in-beta"></a>

### JaCoCo 测试覆盖率可视化支持（测试版）

你现在可以在合并请求中使用 JaCoCo 覆盖率报告，这是一种流行的覆盖率计算标准。该功能以测试版形式提供，但对于任何想要立即使用 JaCoCo 覆盖率报告的人来说都可以进行测试。如果你有任何反馈，欢迎提供。

### 极狐GitLab Runner 17.4

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](https://gitlab.cn/docs/runner)

{{< /details >}}

<a id="gitlab-runner-17-4"></a>

### 极狐GitLab Runner 17.4

我们今天还发布了极狐GitLab Runner 17.4！极狐GitLab Runner 是一个高度可扩展的构建代理，用于运行你的 CI/CD 作业并将结果发送回极狐GitLab 实例。极狐GitLab Runner 与极狐GitLab CI/CD 一起工作，后者是极狐GitLab 附带的开源持续集成服务。

#### 新增功能

- [用于 Azure 计算的极狐GitLab Runner fleeting 插件（GA）](https://jihulab.com/gitlab-cn/gitlab-runner/-/issues/29223)

#### 错误修复

- [当 Kubernetes 执行器作业在完成前被取消时，整个 `step_script` 内容会出现在作业日志的 `after_script` 部分](https://jihulab.com/gitlab-cn/gitlab-runner/-/issues/37952)

所有变更列表在极狐GitLab Runner [CHANGELOG](https://jihulab.com/gitlab-cn/gitlab-runner/blob/17-4-stable/CHANGELOG.md) 中。