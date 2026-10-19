---
stage: Release Notes
group: Monthly Release
date: 2024-09-19
title: "极狐GitLab 17.4 发布说明"
description: "极狐GitLab 17.4 发布，通过打开的标签页提供更具上下文感知的极狐GitLab Duo 代码建议"
---

<!-- markdownlint-disable -->
<!-- vale off -->

2024 年 9 月 19 日，极狐GitLab 17.4 发布了以下功能。

<a id="primary-features"></a>

## 主要功能

<a id="more-context-aware-gitlab-duo-code-suggestions-using-open-tabs"></a>

### 通过打开的标签页提供更具上下文感知的极狐GitLab Duo 代码建议

<!-- categories: Editor Extensions, Code Suggestions -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 附加组件: Duo Pro, Duo Enterprise
- 链接: [文档](../../user/project/repository/code_suggestions/context.md) | [相关议题](https://gitlab.com/gitlab-org/editor-extensions/gitlab-lsp/-/issues/206)

{{< /details >}}

利用其他打开的标签页内容，提升您的编码工作流，并获得更具上下文感知的代码建议。

代码建议的这一改进现在会使用您打开的编辑器标签页内容，提供更相关、更准确的代码推荐。

<a id="auto-merge-when-all-checks-pass"></a>

### 所有检查通过后自动合并

<!-- categories: Code Review Workflow -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/merge_requests/auto_merge.md)

{{< /details >}}

合并请求有许多必须通过的必需检查才能合并。这些检查可能包括审批、未解决的讨论串、流水线，以及其他需要满足的条目。当您负责合并代码时，可能很难跟踪所有这些事件，也很难知道何时回来检查某个合并请求是否可以合并。

极狐GitLab 现在支持对合并请求中的所有检查使用**自动合并**。自动合并使任何有资格合并的用户都能将合并请求设置为**自动合并**，即使所有必需检查尚未通过。随着合并请求在其生命周期中继续推进，合并请求会在最后一个失败的检查通过后自动合并。

我们非常期待这一改进能加速您的合并请求工作流。您可以在[议题 438395](https://gitlab.com/gitlab-org/gitlab/-/issues/438395)中留下关于此功能的反馈。

<a id="extension-marketplace-now-available-in-the-web-ide"></a>

### Web IDE 中现已提供扩展市场

<!-- categories: Web IDE -->

{{< details >}}

- 适用版本: 基础版
- 交付方式: JihuLab.com
- 链接: [文档](../../user/project/web_ide/_index.md#manage-extensions)

{{< /details >}}

我们很高兴地宣布，JihuLab.com 上的 Web IDE 中推出了扩展市场。借助扩展市场，您可以发现、安装和管理第三方扩展，并增强您的开发体验。部分扩展与仅 Web 版本不兼容，因为它们需要本地运行时环境。不过，您仍然可以从数千个扩展中进行选择，以提升工作效率或自定义工作流。

扩展市场默认处于禁用状态。要开始使用，您可以在[用户偏好设置](https://gitlab.com/-/profile/preferences)的 **集成** 部分启用扩展市场。对于[企业用户](../../user/enterprise_user/_index.md)，只有顶级群组中具有所有者角色的用户才能启用扩展市场。

<a id="secure-sudo-access-for-workspaces"></a>

### 为工作区提供安全的 sudo 访问权限

<!-- categories: Workspaces -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/workspace/configuration.md#configure-sudo-access-for-a-workspace)

{{< /details >}}

您现在可以为工作区配置 sudo 访问权限，从而比以往更轻松地直接在开发环境中安装、配置和运行依赖项。我们实现了三种安全方法，以确保无缝的开发体验：

- Sysbox
- Kata Containers
- 用户命名空间

借助此功能，您可以完全自定义环境，以匹配您的工作流和项目需求。

<a id="list-kubernetes-resource-events"></a>

### 列出 Kubernetes 资源事件

<!-- categories: Deployment Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/environments/kubernetes_dashboard.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/470041)

{{< /details >}}

极狐GitLab 提供对 pod 的实时视图以及流式 pod 日志。然而，在此之前，我们并未在 UI 中向您展示特定资源的事件信息，因此您仍然必须使用第三方工具来调试 Kubernetes 部署。此版本为 [Kubernetes 仪表板](../../ci/environments/kubernetes_dashboard.md)的资源详情视图添加了事件。

这是我们首次在 UI 中添加事件。目前，每次打开资源详情视图时都会刷新事件。您可以在[议题 470042](https://gitlab.com/gitlab-org/gitlab/-/issues/470042)中跟踪实时事件流式传输的开发进展。

<a id="gitlab-pages-without-wildcard-dns-is-generally-available"></a>

### 无需通配符 DNS 的 GitLab Pages 已正式发布

<!-- categories: Pages -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../administration/pages/_index.md#dns-configuration-for-single-domain-sites) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/13404)

{{< /details >}}

此前，要创建 GitLab Pages 项目，您需要一个格式为 `name.example.io` 或 `name.pages.example.io`的域名。这一要求意味着您必须设置通配符 DNS 记录和 TLS 证书。在此版本中，无需 DNS 通配符即可设置 GitLab Pages 项目这一功能已从测试版转为正式发布。

移除对通配符证书的要求，减轻了与 GitLab Pages 相关的管理开销。部分客户由于组织对通配符 DNS 记录或证书的限制而无法使用 GitLab Pages。

<a id="gitlab-pages-parallel-deployments-in-beta"></a>

### GitLab Pages 并行部署（测试版）

<!-- categories: Pages -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/pages/_index.md#parallel-deployments) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/10914)

{{< /details >}}

此版本引入了测试版的 Pages 并行部署。您现在可以轻松预览更改并管理 GitLab Pages 站点的并行部署。这一增强功能支持无缝试验新想法，让您可以放心地测试和完善您的站点。通过及早发现任何问题，您可以确保线上站点保持稳定和精致，在 GitLab Pages 已有的出色基础上更进一步。

此外，当您部署应用程序或网站的不同语言版本时，并行部署对于本地化也很有用。

<a id="summarize-issue-discussions-with-gitlab-duo-chat"></a>

### 使用极狐GitLab Duo Chat 总结议题讨论

<!-- categories: Team Planning -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 附加组件: Duo Enterprise
- 链接: [文档](../../user/discussions/_index.md#summarize-issue-discussions-with-gitlab-duo-chat)

{{< /details >}}

了解冗长的议题讨论可能需要投入大量时间。在此版本中，AI 生成的议题讨论摘要已与 Duo Chat 集成，现已面向 JihuLab.com 和私有化部署客户正式发布。

<a id="advanced-sast-is-generally-available"></a>

### 高级 SAST 已正式发布

<!-- categories: SAST -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/sast/gitlab_advanced_sast.md)

{{< /details >}}

我们很高兴地宣布，我们的高级静态应用程序安全测试（SAST）扫描器现已面向所有极狐GitLab 旗舰版客户正式发布。

高级 SAST 是一款新扫描器，由我们今年早些时候[从 Oxeye 收购](https://about.gitlab.com/blog/oxeye-joins-gitlab-to-advance-application-security-capabilities/)的技术提供支持。它使用专有检测引擎，其规则由内部安全研究提供依据，以识别第一方代码中可利用的漏洞。它提供更准确的结果，因此开发人员和安全团队无需在误报结果的噪声中进行筛选。

除了新的扫描引擎外，极狐GitLab 17.4 还包括：

- 新的[代码流视图](../../user/application_security/vulnerabilities/_index.md#vulnerability-code-flow)，可追踪漏洞跨文件和函数的路径。
- 自动迁移，允许高级 SAST“接管”之前极狐GitLab SAST 扫描器的现有结果。

要了解更多信息，请参阅[公告博客](https://about.gitlab.com/blog/gitlab-advanced-sast-is-now-generally-available/)。

<a id="hide-cicd-variable-values-in-the-ui"></a>

### 在 UI 中隐藏 CI/CD 变量值

<!-- categories: Pipeline Composition -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](https://gitlab.cn/docs/jh/ci/variables/#define-a-cicd-variable-in-the-ui) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/29674)

{{< /details >}}

您可能不希望任何人在变量保存到项目设置后看到其值。现在，在创建 CI/CD 变量时，您可以选择新的 **掩码并隐藏** 可见性选项。选择此选项将永久屏蔽 CI/CD 设置 UI 中该变量的值，从而限制该值今后向任何人显示，并降低您数据的可见性。

<a id="scale-and-deployments"></a>

## 规模与部署

<a id="omnibus-improvements"></a>

### Omnibus 改进

<!-- categories: Omnibus Package -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](https://gitlab.cn/docs/omnibus/)

{{< /details >}}

极狐GitLab 17.4 在全新安装极狐GitLab 时默认包含 PostgreSQL 16。

极狐GitLab 17.7 将包含 OpenSSL V3。这会影响那些设置了外部集成、但不满足出站连接最低要求（TLS 1.2 或更高版本，以及 TLS 证书至少 112 位加密）的 Omnibus 实例。请查看我们的 [OpenSSL 升级文档](https://gitlab.cn/docs/omnibus/settings/ssl/openssl_3/)以了解更多信息，或者如果您不确定您的实例是否会受到影响。

<a id="list-groups-invited-to-a-group-or-project-using-the-groups-or-projects-api"></a>

### 使用群组或项目 API 列出被邀请到群组或项目的群组

<!-- categories: Groups & Projects -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../api/groups.md#list-invited-groups) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/465207)

{{< /details >}}

我们在群组 API 和项目 API 中添加了新端点，用于检索已被邀请到某个群组或项目的群组。此功能仅在群组或项目的成员页面上可用。我们希望这一新增功能能让您更轻松地自动化管理群组和项目的成员关系。这些端点按每用户每分钟 60 个请求进行速率限制。

<a id="restrict-group-access-by-domain-with-the-groups-api"></a>

### 使用群组 API 按域名限制群组访问

<!-- categories: Source Code Management, Groups & Projects -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../api/groups.md#update-group-attributes) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/351494)

{{< /details >}}

此前，您只能在 UI 中于群组级别添加域名限制。现在，您还可以使用群组 API 中新增的 `allowed_email_domains_list` 属性来实现这一点。

<a id="improved-source-display-for-group-and-project-members"></a>

### 改进群组和项目成员的来源显示

<!-- categories: Groups & Projects -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/members/_index.md#membership-types) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/431066)

{{< /details >}}

我们简化了群组和项目成员页面上来源列的显示。直接成员仍显示为 `Direct member`。继承成员现在显示为 `Inherited from` 后跟群组名称。通过邀请群组加入群组或项目而添加的成员显示为 `Invited group` 后跟群组名称。对于从被添加到父群组的受邀群组继承而来的成员，我们现在显示最后一步，以便为管理成员关系的用户保持显示的可操作性。

<a id="gitlab-duo-seat-assignment-email"></a>

### 极狐GitLab Duo 席位分配邮件

<!-- categories: Seat Cost Management -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: 私有化部署
- 附加组件: Duo Pro
- 链接: [文档](../../subscriptions/subscription-add-ons.md#assign-gitlab-duo-seats) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/164104)

{{< /details >}}

私有化部署实例上的用户现在在被分配极狐GitLab Duo 席位时会收到一封电子邮件。此前，除非有人告诉您，或者您注意到极狐GitLab UI 中的新功能，否则您不会知道自己被分配了席位。

要禁用此电子邮件，管理员可以禁用 `duo_seat_assignment_email_for_sm` 功能标志。

<a id="resend-failed-webhook-requests-with-the-api"></a>

### 使用 API 重新发送失败的 webhook 请求

<!-- categories: Notifications -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../api/project_webhooks.md#resend-a-project-webhook-event) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/372826)

{{< /details >}}

此前，极狐GitLab 仅在 UI 中提供重新发送 webhook 请求的能力，如果许多请求失败，这种方式效率低下。

为了让您能够以编程方式处理失败的 webhook 请求，在此版本中，得益于一项社区贡献，我们添加了用于重新发送它们的 API 端点：

- [项目 webhook 请求](../../api/project_webhooks.md#resend-a-project-webhook-event)
- [群组 webhook 请求](../../api/group_webhooks.md#resend-group-hook-event)（仅限专业版和旗舰版）

您现在可以：

1. 获取[项目钩子](../../api/project_webhooks.md#list-project-webhook-events)或[群组钩子](../../api/group_webhooks.md#list-all-group-hook-events)事件列表。
1. 筛选列表以查看失败项。
1. 使用任何事件的 `id` 重新发送它。

感谢 [Phawin](https://gitlab.com/lifez)的[这项社区贡献](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/151130)！

<a id="idempotency-keys-for-webhook-requests"></a>

### webhook 请求的幂等键

<!-- categories: Notifications -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/integrations/webhooks.md#delivery-headers) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/388692)

{{< /details >}}

从此版本开始，我们在 webhook 请求的请求头中支持幂等键。幂等键是一个唯一 ID，在 webhook 重试期间保持一致，使 webhook 客户端能够检测重试。使用 `Idempotency-Key` 请求头来确保 webhook 对集成效果的幂等性。

感谢 [Van](https://gitlab.com/van.m.anderson)的[这项社区贡献](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/160952)！

<a id="unified-devops-and-security"></a>

## 统一 DevOps 与安全

<a id="cicd-component-for-code-intelligence"></a>

### 用于代码智能的 CI/CD 组件

<!-- categories: Code Review Workflow -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/code_intelligence.md#with-the-cicd-component)

{{< /details >}}

极狐GitLab 中的代码智能在浏览代码仓库时提供代码导航功能。开始使用代码导航通常很复杂，因为您必须配置一个 CI/CD 作业。此作业可能需要自定义脚本才能提供正确的输出和产物。

极狐GitLab 现在支持官方的[代码智能 CI/CD 组件](https://gitlab.com/explore/catalog/components/code-intelligence)，以便更轻松地设置。按照[使用组件](../../ci/components/_index.md#use-a-component)的说明将此组件添加到您的项目。这极大地简化了在极狐GitLab 中采用代码智能的过程。

目前，该组件支持以下语言：

- Go 1.21 或更高版本。
- TypeScript 或 JavaScript。

在我们寻求扩大新组件语言支持的过程中，我们将继续评估[可用的 SCIP 索引器](https://github.com/sourcegraph/scip?tab=readme-ov-file#tools-using-scip)。如果您有兴趣添加对某种语言的支持，请在[代码智能组件](https://gitlab.com/components/code-intelligence)项目中提交一个合并请求。

<a id="linked-files-in-merge-request-show-first"></a>

### 合并请求中的链接文件优先显示

<!-- categories: Code Review Workflow -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/merge_requests/changes.md#show-a-linked-file-first)

{{< /details >}}

当您分享指向合并请求中特定文件的链接时，通常是因为您希望对方查看该文件中的某些内容。合并请求此前需要加载所有文件，然后才能滚动到您引用的特定位置。直接链接到文件是提高合并请求协作速度的好方法：

1. 找到您想优先显示的文件。右键单击文件名以复制指向它的链接。
1. 当您访问该链接时，您选择的文件会显示在列表顶部。文件浏览器会在文件名旁边显示一个链接图标。

关于链接文件的反馈可以留在[议题 439582](https://gitlab.com/gitlab-org/gitlab/-/issues/439582)中。

<a id="authenticate-with-oauth-for-gitlab-duo-in-jetbrains-ides"></a>

### 在 JetBrains IDE 中使用 OAuth 对极狐GitLab Duo 进行身份验证

<!-- categories: Editor Extensions -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../editor_extensions/jetbrains_ide/setup.md#configure-gitlab-duo) | [相关史诗](https://gitlab.com/groups/gitlab-org/editor-extensions/-/epics/70)

{{< /details >}}

我们的 JetBrains 极狐GitLab Duo 插件现在提供更安全、更简化的入门流程。使用 OAuth 快速、安全地登录。它与您现有的工作流无缝集成，无需个人访问令牌！

<a id="non-deployment-jobs-to-protected-environments-arent-turned-into-manual-jobs"></a>

### 面向受保护环境的非部署作业不会变为手动作业

<!-- categories: Environment Management -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/jobs/job_control.md#types-of-manual-jobs) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/390025)

{{< /details >}}

由于一个实现问题，`action: prepare`、`action: verify` 和 `action: access` 作业在针对受保护环境运行时，会变为手动作业。这些作业需要手动交互才能运行，尽管它们不需要任何额外的审批。

[议题 390025](https://gitlab.com/gitlab-org/gitlab/-/issues/390025) 提议修复该实现，使这些作业不会变为手动作业。在此提议的更改之后，要保持当前行为，您将需要[显式将作业设置为手动](../../ci/jobs/job_control.md#types-of-manual-jobs)。

目前，您可以通过启用 `prevent_blocking_non_deployment_jobs` 功能标志来立即切换到新实现。

任何提议的破坏性更改都旨在区分 `environment.action: prepare | verify | access` 值的行为。`environment.action: access` 关键字将保持最接近其当前行为。

为防止未来的兼容性问题，您应立即审查您对这些关键字的使用。您可以在以下议题中了解有关这些提议更改的更多信息：

- [议题 437132](https://gitlab.com/gitlab-org/gitlab/-/issues/437132)
- [议题 437133](https://gitlab.com/gitlab-org/gitlab/-/issues/437133)
- [议题 437142](https://gitlab.com/gitlab-org/gitlab/-/issues/437142)

<a id="trigger-a-flux-reconciliation-from-the-cluster-ui"></a>

### 从集群 UI 触发 Flux 协调

<!-- categories: Deployment Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/environments/kubernetes_dashboard.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/434248)

{{< /details >}}

尽管您可以配置 Flux 在指定间隔触发协调，但在某些情况下，您可能希望立即进行协调。在过去的版本中，您可以从 CI/CD 流水线或命令行触发协调。在极狐GitLab 17.4 中，您现在可以从 Kubernetes 仪表板触发协调，无需任何额外配置。

要触发协调，请转到已配置的仪表板，然后选择 Flux 状态徽章。

<a id="optional-token-expiration"></a>

### 可选的令牌过期时间

<!-- categories: System Access -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../administration/settings/account_and_limit_settings.md#require-expiration-dates-for-new-access-tokens) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/470192)

{{< /details >}}

管理员现在可以决定是否要对个人、项目和群组访问令牌强制实施到期日期。如果管理员禁用此设置，则生成的任何新访问令牌都不再要求具有到期日期。默认情况下，此设置处于启用状态，并要求到期时间短于允许的最长生命周期。此设置适用于极狐GitLab 16.11 及更高版本。

<a id="search-by-multiple-compliance-frameworks"></a>

### 按多个合规框架搜索

<!-- categories: Compliance Management -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/compliance/compliance_center/compliance_projects_report.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/462943)

{{< /details >}}

在极狐GitLab 17.3 中，我们为用户提供了向项目添加多个合规框架的能力。

现在您可以按多个合规框架进行搜索，这使得搜索附加了多个合规框架的项目更加容易。

<a id="grant-read-access-to-pipeline-execution-yaml-files-in-projects-linked-to-security-policies"></a>

### 授予对链接到安全策略的项目中流水线执行 YAML 文件的读取访问权限

<!-- categories: Security Policy Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/policies/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/469439)

{{< /details >}}

在极狐GitLab 17.4 中，我们为安全策略添加了一项设置，您可以使用它为所有链接的项目授予对 `pipeline-execution.yml` 文件的读取访问权限。此设置让您更灵活地启用用户、机器人或令牌，以跨项目全局强制执行流水线执行。例如，您可以确保群组或项目访问令牌能够读取安全策略配置，以便在流水线执行期间触发流水线。您仍然无法直接查看安全策略项目代码仓库或 YAML。该配置仅在流水线创建期间使用。

要配置此设置，请转到您想要共享的安全策略项目。选择 **设置 > 通用 > 可见性、项目功能、权限**，滚动到**流水线执行策略**，然后启用 **允许将此项目关联为安全策略来源的项目访问此代码仓库** 开关。

<a id="support-suffix-for-jobs-with-name-collisions-in-pipeline-execution-policy-pipelines"></a>

### 支持流水线执行策略流水线中名称冲突的作业使用后缀

<!-- categories: Security Policy Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/policies/pipeline_execution_policies.md#pipeline_execution_policy-schema) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/473189)

{{< /details >}}

作为对 [17.2 版本流水线执行策略](gitlab-17-2-released.md#pipeline-execution-policy-type)的增强，策略创建者现在可以配置流水线执行策略，以优雅地处理作业名称冲突。借助流水线执行策略的 `policy.yml`，您现在可以配置以下选项：

- `suffix: on_conflict` 通过重命名策略作业来优雅地处理冲突，这是新的默认行为
- `suffix: never` 强制所有作业名称唯一，如果发生冲突将导致流水线失败，这是自 17.2 以来的默认行为

通过这一改进，您可以确保在流水线执行策略中执行的安全和合规作业始终运行，同时防止对下游开发人员造成不必要的影响。

在后续增强中，我们将在策略编辑器中引入该配置选项。

<a id="resizable-wiki-sidebar"></a>

### 可调整大小的 Wiki 边栏

<!-- categories: Wiki -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/wiki/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/154167)

{{< /details >}}

您现在可以调整 Wiki 边栏以查看更长的页面标题，从而改善内容的整体可发现性。随着 Wiki 内容的增长，拥有可调整大小的边栏有助于更高效地管理和浏览复杂的层级结构或大量的页面列表。

<a id="support-for-ingesting-cyclonedx-16-sboms"></a>

### 支持摄取 CycloneDX 1.6 SBOM

<!-- categories: Software Composition Analysis -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/yaml/artifacts_reports.md#artifactsreportscyclonedx) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/472837)

{{< /details >}}

极狐GitLab 15.3 添加了对[摄取 CycloneDX SBOM](../../ci/yaml/artifacts_reports.md#artifactsreportscyclonedx)的支持。

在极狐GitLab 17.4 中，我们添加了对摄取 CycloneDX 1.6 版本 SBOM 的支持。

目前不支持与硬件（HBOM）、服务（SaaSBOM）和 AI/ML 模型（AI/ML-BOM）相关的字段。包含与这些 BOM 相关数据的 SBOM 将被处理，但数据不会被分析或呈现给用户。对这些其他 BOM 类型的支持正在此[史诗](https://gitlab.com/groups/gitlab-org/-/epics/14989)中跟踪。

<a id="automatic-cleanup-for-removed-sast-analyzers"></a>

### 自动清理已移除的 SAST 分析器

<!-- categories: SAST -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/sast/analyzers.md#analyzers-that-have-reached-end-of-support)

{{< /details >}}

在[极狐GitLab 17.0](../../update/deprecations.md#sast-analyzer-coverage-changing-in-gitlab-170)、[16.0](../../update/deprecations.md#sast-analyzer-coverage-changing-in-gitlab-160) 和 [15.4](../../update/deprecations.md#sast-analyzer-consolidation-and-cicd-template-changes)中，我们精简了极狐GitLab SAST，使其使用更少的独立分析器来扫描您的代码以查找漏洞。

现在，在您升级到极狐GitLab 17.3.1 或更高版本后，一次性数据迁移将自动解决来自[已达到支持终止的分析器](../../user/application_security/sast/analyzers.md#analyzers-that-have-reached-end-of-support)的遗留漏洞。这有助于清理您的漏洞报告，以便您可以专注于仍由最新分析器检测到的漏洞。

该迁移仅解决您尚未确认或忽略的漏洞，并且不会影响已[自动转换为基于 Semgrep 的扫描](../../user/application_security/sast/analyzers.md#transition-to-semgrep-based-scanning)的漏洞。

<a id="secret-detection-support-for-anthropic-api-keys"></a>

### 密钥检测支持 Anthropic API 密钥

<!-- categories: Secret Detection -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/secret_detection/detected_secrets.md)

{{< /details >}}

流水线和客户端密钥检测现在都支持检测 Anthropic API 密钥。

<a id="jacoco-support-for-test-coverage-visualization-available-in-beta"></a>

### 测试覆盖率可视化的 JaCoCo 支持已推出测试版

<!-- categories: Code Testing and Coverage -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/testing/code_coverage/jacoco.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/227345)

{{< /details >}}

您现在可以在合并请求中使用 JaCoCo 覆盖率报告，这是一种流行的覆盖率计算标准。该功能以测试版形式提供，但已准备好供任何希望立即使用 JaCoCo 覆盖率报告的人进行测试。如果您有任何反馈，欢迎为[反馈议题](https://gitlab.com/gitlab-org/gitlab/-/issues/479804)做出贡献。

<a id="gitlab-runner-174"></a>

### 极狐GitLab Runner 17.4

<!-- categories: GitLab Runner Core -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](https://gitlab.cn/docs/runner/)

{{< /details >}}

我们今天还发布了极狐GitLab Runner 17.4！极狐GitLab Runner 是高度可扩展的构建代理，负责运行您的 CI/CD 作业并将结果发送回极狐GitLab 实例。极狐GitLab Runner 与极狐GitLab CI/CD 协同工作，后者是极狐GitLab 中包含的开源持续集成服务。

<a id="whats-new"></a>

#### 新增内容

- [GitLab Runner 用于 Azure 计算的 fleeting 插件（正式发布）](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/29223)

<a id="bug-fixes"></a>

#### 缺陷修复

- [当 Kubernetes 执行器作业在完成前被取消时，整个 `step_script` 内容会出现在作业日志的 `after_script` 部分](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/37952)

所有更改的列表位于极狐GitLab Runner [CHANGELOG](https://gitlab.com/gitlab-org/gitlab-runner/blob/17-4-stable/CHANGELOG.md)中。
