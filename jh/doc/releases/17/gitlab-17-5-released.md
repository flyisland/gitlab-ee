---
stage: Release Notes
group: Monthly Release
date: 2024-10-17
title: "极狐GitLab 17.5 发布说明"
description: "极狐GitLab 17.5 发布，推出 Duo Quick Chat"
---

2024 年 10 月 17 日，极狐GitLab 17.5 发布，带来了以下功能。

此外，我们要感谢所有贡献者，包括本月的杰出贡献者。

<a id="this-months-notable-contributor-jim-ender"></a>

## 本月的杰出贡献者：Jim Ender

每个人都可以[提名极狐GitLab 社区贡献者](https://jihulab.com/gitlab-cn/developer-relations/contributor-success/team-task/-/issues/490)！
为您支持的活跃候选人加油助威，或者添加新的提名！🙌

Jim 因为主导了[关闭近 100 个积压议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/?sort=updated_desc&state=closed&assignee_username%5B%5D=Jimender2&first_page_size=100)在极狐GitLab 上的工作而获得认可。
他活跃于我们每周的社区结对会议中，深入参与一些有趣的讨论。
Jim 还在 [极狐GitLab 社区 Discord](https://discord.gg/gitlab) 中帮助他人，解决极狐GitLab 支持请求并指导新贡献者。
Jim 在一家工业技术公司工作，为关键基础设施和 ERP 系统编写软件。

“即使是很小的贡献累积起来也能让项目变得更好，”Jim 说。“像文档贡献这样的小事也能帮助他人。你不一定要为整个新功能摇旗呐喊。”

Jim 由 [Lee Tickett](https://gitlab.com/leetickett-gitlab)（极狐GitLab 员工 FullStack 工程师，贡献者成功）提名。
“议题分类/筛选一直是我优先考虑让广泛社区参与的事情，而 Jim 在这方面正在开辟道路，”Lee 说。

[Daniel Murphy](https://gitlab.com/daniel-murphy)（极狐GitLab 贡献者成功高级项目经理）也补充了提名：
“Jim 对新贡献者的出色支持和指导他们入门，帮助我们作为一个社区共同创建极狐GitLab。”

“我审查的[合并请求](https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/163849)令人印象深刻！”极狐GitLab 高级前端工程师 [Vanessa Otto](https://gitlab.com/vanessaotto) 说。
“Jim 响应迅速，立刻理解了建议并顺畅实施了它们。看到 Jim 的方法如此高效和清晰，真是太好了。”

我们非常感谢 Jim 以及我们所有的开源社区对极狐GitLab 的贡献！

## 主要特性

<a id="introducing-duo-quick-chat"></a>

### 推出 Duo Quick Chat

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Add-ons: Duo Pro, Duo Enterprise
- Links: [文档](../../user/gitlab_duo_chat/_index.md#in-an-editor-window) | [相关史诗](https://jihulab.com/groups/gitlab-cn/-/epics/15218)

{{< /details >}}

推出 Duo Quick Chat，一款 AI 赋能的聊天工具，专为在你的代码所在之处工作而设计。Duo Quick Chat 直接在你正在编辑的行上运行，提供实时辅助，让你不必离开代码。无论你是在重构、修复错误还是编写测试，Duo Quick Chat 都会当场提供建议和解释，确保你完全专注，无需切换上下文。

<a id="use-self-hosted-model-for-gitlab-duo-code-suggestions"></a>

### 使用私有化部署模型实现极狐GitLab Duo 代码建议

{{< details >}}

- Tier: 旗舰版
- Add-ons: Duo Enterprise
- Links: [文档](../../administration/gitlab_duo_self_hosted/_index.md)

{{< /details >}}

您现在可以在自己的基础设施中托管选定的 LLM，并配置它们作为代码建议的来源。此功能处于 Beta 阶段，在私有化部署极狐GitLab 环境中，适用于旗舰版和 Duo Enterprise 订阅。

借助私有化部署模型，您可以使用本地或私有云中的模型来启用极狐GitLab Duo 代码建议。我们目前支持在 vLLM 上使用开源 Mistral 模型。通过启用私有化部署模型，您可以利用生成式 AI 的强大功能，同时保持完整的数据主权和隐私。

<a id="export-code-suggestion-usage-events"></a>

### 导出代码建议使用事件

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Add-ons: Duo Enterprise
- Links: [文档](../../api/graphql/reference/_index.md#codesuggestionevent)

{{< /details >}}

以前，AI 影响力分析仅在 JihuLab.com 上对极狐GitLab Duo Enterprise 客户可用，在私有化部署极狐GitLab 上则需要集成 ClickHouse。此外，默认指标是聚合的。

现在，您可以从 GraphQL API 导出原始代码建议事件。这样您可以将数据导入数据分析工具，从而深入了解更多维度（如建议大小、语言和用户）的接受率。原始事件不存储在 ClickHouse 中，因此一些 AI 影响力分析指标对所有极狐GitLab 部署（包括私有化部署）都可用。

<a id="have-a-conversation-with-gitlab-duo-chat-about-your-merge-request"></a>

### 与极狐GitLab Duo Chat 对话讨论合并请求

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Add-ons: Duo Enterprise
- Links: [文档](../../user/gitlab_duo_chat/examples.md#ask-about-a-specific-merge-request)

{{< /details >}}

响应您的反馈，极狐GitLab Duo Chat 现在可以感知合并请求。无论是审查者还是作者，您现在都可以与 Chat 对话，以快速了解合并请求，或知晓下一步该做什么。只需打开您的合并请求并启动 Duo Chat，然后开始对话即可。

这个新功能补充了我们现有的功能，即您可以通过要求极狐GitLab Duo [总结代码变更](../../user/project/merge_requests/duo_in_merge_requests.md#generate-a-description-by-summarizing-code-changes)来快速填充合并请求的描述，以便审查者能够大致了解合并请求的内容。

<a id="enhanced-branch-rules-editing-capabilities"></a>

### 增强的分支规则编辑功能

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/repository/branches/branch_rules.md#create-a-branch-rule)

{{< /details >}}

在极狐GitLab 15.10 中，我们引入了[与分支相关的设置和规则的整合视图](https://about.gitlab.com/releases/2023/03/22/gitlab-15-10-released/#see-all-branch-related-settings-together)。该视图让您能够轻松了解项目在多项设置上的配置。

基于此功能，您现在可以直接在此视图中修改特定分支规则，包括分支保护、审批规则和外部状态检查配置。这些新功能为[持续改进](https://jihulab.com/groups/gitlab-cn/-/epics/12546)分支配置奠定了基础，将在未来实现更大的灵活性。

我们鼓励您探索这些新功能并提供反馈。

<a id="secret-push-protection-is-generally-available"></a>

### Secret Push Protection 达到 GA

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/secret_detection/secret_push_protection/_index.md)

{{< /details >}}

我们很高兴地宣布，Secret Push Protection 现已在所有极狐GitLab 旗舰版客户中达到 GA。

如果密钥、API 令牌之类的凭据被意外提交到 Git 仓库，任何可以访问该仓库的人都可能冒充该凭据的用户进行恶意操作。泄露的凭据不仅耗费时间和金钱，还可能损害公司声誉。Secret push protection 有助于缩短修复时间，并通过从一开始就阻止凭据被推送来降低风险。

自 Beta 版本以来，Secret push protection 已得到改进。当通过 Git CLI 推送提交时，现在仅对变更（diff）进行凭据扫描。我们还添加了实验性支持，可以排除路径、规则或特定值，以减少误报。

要了解更多，请参阅[博客](https://gitlab.cn/blog/prevent-secret-leaks-in-source-code-with-gitlab-secret-push-protection/)。

<a id="credentials-inventory-available-on-gitlabcom"></a>

### 凭据清单在 JihuLab.com 上可用

{{< details >}}

- Tier: Gold
- Offering: JihuLab.com
- Links: [文档](../../administration/credentials_inventory.md)

{{< /details >}}

凭据清单现在在 JihuLab.com 上对顶级群组所有者可用。在凭据清单中，您可以在群组内查看[企业用户](../../user/enterprise_user/_index.md)的个人访问令牌和 SSH 密钥。您还可以对凭据进行吊销、删除及查看更多信息。此前，此功能仅适用于私有化部署极狐GitLab 中的管理员。

群组所有者可以通过凭据清单了解其管理范围内的凭据情况，并获得更好的可见性和控制力。

<a id="component-filter-on-the-dependency-list"></a>

### 依赖列表中的组件过滤器

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/dependency_list/_index.md#filter-dependency-list) | [相关史诗](https://jihulab.com/groups/gitlab-cn/-/epics/12652)

{{< /details >}}

现在，在极狐GitLab 中，您可以快速筛选特定的依赖组件，以便确认您的群组或项目是否使用了它们。
过去，手动浏览整个列表来确认某个软件包和版本是否存在，不仅耗时而且不便。
通过依赖列表新增的 **按组件筛选** 功能，您可以隔离存在漏洞的依赖项，从而评估应用程序中的开放风险。

## 扩缩和部署

<a id="gitlab-chart-improvements"></a>

### GitLab Chart 改进

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](https://gitlab.cn/docs/charts/)

{{< /details >}}

极狐GitLab 17.5 包含了对 NGINX Ingress Controller 版本的更新。`nginx-controller` 容器镜像现为 1.11.2 版本。请注意，这包含了新的 RBAC 要求，因为新的控制器现在使用 endpointslices，并需要 RBAC 规则来访问它们。

<a id="omnibus-improvements"></a>

### Omnibus 改进

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](https://gitlab.cn/docs/omnibus/)

{{< /details >}}

极狐GitLab 17.5 包含对单节点安装从 PostgreSQL 14.x 升级到 16.x 的支持。自动升级未启用，因此必须手动触发 PostgreSQL 升级。

## 统一 DevOps 与安全

<a id="configure-agent-and-gitops-environment-settings-with-the-rest-api"></a>

### 使用 REST API 配置代理和 GitOps 环境设置

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../api/environments.md)

{{< /details >}}

您可以从极狐GitLab 环境 UI 检查 Pod 和 Flux 调谐的状态。
然而，这种方式难以扩展，因为所需的设置只能通过 GraphQL 或 UI 暴露。
现在，极狐GitLab 提供了用于配置 Kubernetes 代理的 REST API 支持，以及为每个环境设置命名空间和 Flux 资源的功能。

<a id="easy-bootstrapping-of-gitlab-kubernetes-integration"></a>

### 轻松引导极狐GitLab Kubernetes 集成

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/clusters/agent/install/_index.md#bootstrap-the-agent-with-flux-support-recommended)

{{< /details >}}

极狐GitLab 通过 [Kubernetes 代理](../../user/clusters/agent/_index.md)及其 [Flux 集成](../../user/clusters/agent/gitops.md)提供灵活、可靠且安全的 GitOps 支持。
尽管如此，在 GitLab 中引导 Flux 并设置 Kubernetes 代理过去通常需要查阅大量文档，并在极狐GitLab UI 和终端之间来回切换。
极狐GitLab CLI 现在提供 [`glab cluster agent bootstrap` 命令](https://gitlab.com/gitlab-org/cli/-/blob/main/docs/source/cluster/agent/bootstrap.md)，以简化在现有 Flux 安装之上安装代理的过程。
现在，您只需两条简单的命令即可配置 Flux 和代理。

<a id="kubernetes-integration-support-for-firewalled-gitlab-installations"></a>

### 防火墙环境下的极狐GitLab 安装的 Kubernetes 集成支持

{{< details >}}

- Tier: 旗舰版
- Links: [文档](../../user/clusters/agent/_index.md#receptive-agents)

{{< /details >}}

到目前为止，Kubernetes 代理只能在 Kubernetes 集群能够连接到极狐GitLab 实例时使用。
这意味着一些客户如果在私有网络中或防火墙后运行极狐GitLab，就无法使用代理。
从极狐GitLab 17.5 开始，只要一个配置正确的 `agentk` 实例已在等待连接初始化，您就可以从极狐GitLab 端发起集群与极狐GitLab 的连接。

一旦初始连接建立，代理的所有功能都可以使用。从集群端发起连接的方式在此开发中保持不变。

<a id="stream-kubernetes-resource-events"></a>

### 流式传输 Kubernetes 资源事件

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../ci/environments/kubernetes_dashboard.md)

{{< /details >}}

极狐GitLab 通过 Kubernetes 仪表板提供了 Pod 的实时视图以及 Pod 日志流传输。
在极狐GitLab 17.4 中，我们在 UI 中提供了特定于资源的事件信息的静态列表。
此版本进一步改进了 Kubernetes 仪表板，允许您流式传输集群中新出现的事件。

<a id="suspend-or-resume-gitops-reconciliation-from-the-gitlab-ui"></a>

### 在极狐GitLab UI 中暂停或恢复 GitOps 调和

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../ci/environments/kubernetes_dashboard.md#suspend-or-resume-flux-reconciliation)

{{< /details >}}

作为 Flux 用户，您是否曾需要快速停止自动调和或漂移修复？您是否曾想触发 `HelmRelease` 以同步手动删除的资源？这些操作最好通过 Flux 的暂停和恢复功能实现。在此之前，您最好的选择是使用 Flux CLI，但这需要切换上下文并使用多个命令来确保影响正确的资源。在极狐GitLab 17.5 中，您可以直接从内置的 Kubernetes 仪表板暂停或恢复调和。

<a id="improved-user-management-summary"></a>

### 改进的用户管理摘要

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../user/profile/account/create_accounts.md#create-a-user-in-the-admin-area)

{{< /details >}}

管理员现在可以增强、汇总查看其实例上用户以下关键信息：

- 待审批。
- 未启用双因素身份认证。
- 管理员。

这提高了用户管理效率，因为管理员可以从摘要视图中快速了解处于这些状态的用户数量，并进行筛选。

<a id="add-groups-to-security-policy-scope"></a>

### 将群组添加到安全策略范围

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/policies/_index.md) | [相关史诗](https://jihulab.com/groups/gitlab-cn/-/epics/14149)

{{< /details >}}

您现在可以将群组/子群组作为安全策略范围的目标。这扩展了现有选项，允许您定位群组/子群组中的所有项目、基于定义项目列表的项目，以及匹配合规性框架标签列表的项目。

这为您在群组中启用策略提供了更大的灵活性，同时也允许在必要时应用例外情况，将项目排除在强制执行范围之外。

此改进也是多项[增强](https://jihulab.com/groups/gitlab-cn/-/epics/5446)的前奏，这些增强将简化关联安全策略项目和精细限定策略执行范围的过程。

<a id="disable-password-authentication-for-enterprise-users"></a>

### 为企业用户禁用密码身份验证

{{< details >}}

- Tier: Silver, Gold
- Offering: JihuLab.com
- Links: [文档](../../user/group/saml_sso/_index.md#disable-password-and-passkey-authentication-for-enterprise-users)

{{< /details >}}

企业用户可以使用带有用户名和密码的本地账户进行身份验证。现在，群组所有者可以为其群组的企业用户禁用密码身份验证。如果密码身份验证被禁用，企业用户可以使用群组的 SAML 身份提供商通过极狐GitLab Web UI 进行身份验证，或者使用个人访问令牌通过 HTTP Basic Authentication 对极狐GitLab API 和 Git 进行身份验证。

<a id="access-compliance-center-on-projects"></a>

### 访问项目合规中心

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/compliance/compliance_center/_index.md)

{{< /details >}}

此前，合规中心仅适用于顶级群组和子群组。

在此版本中，我们为项目添加了合规中心。在此层面，合规中心为特定项目的检查和违规行为提供了只读功能。

要添加或编辑框架，您仍然应该使用顶级群组的合规中心。

<a id="migration-process-for-compliance-pipelines-to-security-policies"></a>

### 合规流水线迁移到安全策略的过程

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/compliance/compliance_pipelines.md#pipeline-execution-policies-migration) | [相关史诗](https://jihulab.com/groups/gitlab-cn/-/epics/11275)

{{< /details >}}

在极狐GitLab 17.3 中，我们宣布了合规流水线的弃用及其在 18.0 版本中的最终移除。
取而代之的是，您应使用极狐GitLab 17.2 中发布的流水线执行策略类型。

为了帮助您将现有的合规流水线迁移到流水线执行策略类型，此版本包含一个警告横幅，该横幅：

- 通知用户合规流水线的弃用。
- 提供一个引导式的工作流，将现有合规流水线迁移到流水线执行策略类型。

<a id="view-token-associations-using-api"></a>

### 使用 API 查看令牌关联

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../api/personal_access_tokens.md#list-all-token-associations)

{{< /details >}}

您现在可以查看令牌关联了哪些群组、子群组和项目。这使得确定令牌过期或吊销的影响，以及了解令牌在何处可用变得更加容易。

<a id="selective-saml-single-sign-on-enforcement"></a>

### 选择性 SAML 单点登录强制实施

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../administration/settings/sign_in_restrictions.md#disable-password-and-passkey-authentication-for-users-with-an-sso-identity)

{{< /details >}}

以前，当启用 SAML SSO 时，群组可以选择强制实施 SSO，这要求所有成员都使用 SSO 身份验证来访问群组。然而，某些群组希望为员工或群组成员提供 SSO 强制实施的安全性，同时仍允许外部协作者或承包商无需 SSO 即可访问其群组。

现在，启用了 SAML SSO 的群组将自动对所有拥有 SAML 身份的成员强制实施 SSO。没有 SAML 身份的群组成员则不需要使用 SSO，除非显式启用了 SSO 强制实施。

如果满足以下任一条件，成员便拥有 SAML 身份：

- 他们使用极狐GitLab 群组的单点登录 URL 登录了极狐GitLab。
- 他们是通过 SCIM 配置的。

为确保选择性 SSO 强制实施功能的顺利运行，在选中 **为此群组启用 SAML 身份验证** 复选框前，请确保您的 SAML 配置正常工作。

<a id="enhance-api-performance-when-working-with-container-registry-tags"></a>

### 提升处理容器镜像仓库标签时的 API 性能

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../api/container_registry.md#list-all-registry-repository-tags)

{{< /details >}}

我们很高兴地宣布，我们对私有化部署极狐GitLab 实例的容器镜像仓库 API 进行了重大改进。随着极狐GitLab 17.5 的发布，我们为 `:id/registry/repositories/:repository_id/tags` 端点实现了键集分页，使其与 JihuLab.com 上已有的功能保持一致。此增强是我们持续努力提升 API 性能并在所有极狐GitLab 部署中提供一致体验的一部分。

键集分页提供了一种更高效地处理大型数据集的方法，从而提升了性能并改善了用户体验。此更新在处理大型容器镜像仓库时尤其有用，因为它允许更流畅地浏览仓库标签。要使用此功能，私有化部署实例必须升级到[下一代容器镜像仓库](../../administration/packages/container_registry_metadata_database.md)。

<a id="safeguard-your-dependencies-with-protected-packages"></a>

### 使用受保护软件包保护依赖项

{{< details >}}

- Tier: 基础版, Silver, Gold
- Offering: JihuLab.com
- Links: [文档](../../user/packages/package_registry/package_protection_rules.md)

{{< /details >}}

我们很高兴推出受保护 npm 软件包支持，这是一项旨在增强极狐GitLab 软件包仓库安全性和稳定性的新功能。在快节奏的软件开发世界中，意外修改或删除软件包可能会打乱整个开发流程。受保护软件包通过允许您保护最重要的依赖项免受意外更改来解决此问题。

从极狐GitLab 17.5 开始，您可以通过创建保护规则来保护 npm 软件包。如果某个软件包与某个保护规则匹配，则只有指定的用户才能更新或删除该软件包。有了此功能，您可以防止意外更改，改善对监管要求的合规性，并通过减少人工监督来简化工作流程。

<a id="ruby-support-and-rule-updates-for-advanced-sast"></a>

### 高级 SAST 的 Ruby 支持和规则更新

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/sast/gitlab_advanced_sast.md)

{{< /details >}}

我们为极狐GitLab 高级 SAST 添加了 Ruby 支持。
要使用这种新的跨文件、跨函数扫描支持，请[启用高级 SAST](../../user/application_security/sast/gitlab_advanced_sast.md#turn-on-gitlab-advanced-sast)。
如果您已经启用了高级 SAST，Ruby 支持将自动激活。
