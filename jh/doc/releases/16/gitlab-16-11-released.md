---
stage: Release Notes
group: Monthly Release
date: 2024-04-18
title: "极狐GitLab 16.11 发布说明"
description: "极狐GitLab 16.11 发布，极狐GitLab Duo Chat 已正式发布"
---

<!-- markdownlint-disable -->
<!-- vale off -->

2024 年 4 月 18 日，极狐GitLab 16.11 发布了以下功能。

<a id="primary-features"></a>

## 主要功能

<a id="gitlab-duo-chat-now-generally-available"></a>

### 极狐GitLab Duo Chat 已正式发布

<!-- categories: Duo Chat -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/gitlab_duo_chat/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/13516)

{{< /details >}}

极狐GitLab Duo Chat 已正式发布。作为本次发布的一部分，我们还让以下能力已正式发布：

- 代码解释可帮助开发人员和技术背景较少的用户更快地理解不熟悉的代码
- 代码重构使开发人员能够简化和改进现有代码
- 测试生成可自动执行重复性任务，并帮助团队更早地发现缺陷

用户可以在极狐GitLab UI、Web IDE、VS Code 或 JetBrains IDE 中访问极狐GitLab Duo Chat。

您可以通过这篇[博客文章](https://about.gitlab.com/blog/gitlab-duo-chat-now-generally-available/)进一步了解本次极狐GitLab Duo Chat 的发布。

目前，所有旗舰版和专业版用户均可免费使用 Chat。实例管理员、群组所有者和项目所有者可以选择[限制 Duo 功能访问和处理其数据](../../user/gitlab_duo/turn_on_off.md)。

极狐GitLab Duo Chat 是 [极狐GitLab Duo Pro](https://about.gitlab.com/gitlab-duo/#pricing)的一部分。为便于尚未购买极狐GitLab Duo Pro 的 Chat 测试版用户过渡，现有专业版和旗舰版客户（未购买附加组件）可在一段短时间内继续使用 Duo Chat。我们将在稍后公布何时将访问权限限制为仅 Duo Pro 订阅者。

欢迎您通过点击 Chat 中的反馈按钮，或创建议题并提及极狐GitLab Duo Chat 来分享您的想法。我们期待您的反馈！

<a id="gitlab-duo-chat-available-in-jetbrains-ides"></a>

### 极狐GitLab Duo Chat 已在 JetBrains IDE 中可用

<!-- categories: Editor Extensions -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../editor_extensions/jetbrains_ide/_index.md) | [相关议题](https://gitlab.com/gitlab-org/editor-extensions/gitlab-jetbrains-plugin/-/issues/307)

{{< /details >}}

我们很高兴地宣布，极狐GitLab Duo Chat 已在 JetBrains IDE 中可用。

作为极狐GitLab AI 产品的一部分，Duo Chat 通过将交互式聊天窗口直接引入任何受支持的 JetBrains IDE，并提供解释代码、编写测试和重构现有代码的能力，进一步简化了开发人员体验。

有关功能的完整列表，请参阅我们的 [Duo Chat 文档](../../user/gitlab_duo_chat/_index.md)。

<a id="security-policy-scopes"></a>

### 安全策略作用域

<!-- categories: Security Policy Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/policies/scan_execution_policies.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/5510)

{{< /details >}}

策略作用域可对策略进行精细化的管理和强制执行。在合并请求审批（扫描结果）策略和扫描执行策略中，这项新功能使安全和合规团队能够将策略执行范围限定到某个合规框架，或群组中一组包含/排除的项目。

目前，在安全策略项目中管理的所有策略都会对全部关联的群组、子群组和项目强制执行，而策略作用域将允许您逐个策略地细化该强制执行策略。这使安全和合规团队能够：

- 更轻松地在整个组织内集中管理策略，同时仍能精细化地强制执行策略。
- 更好地了解他们在极狐GitLab 中实施和执行的管控措施如何汇总到他们定义的合规框架。
- 通过合规中心查看和管理哪些策略已关联到合规框架。
- 更好地组织并了解其安全和合规状况。

<a id="understand-your-users-better-with-product-analytics"></a>

### 使用产品分析更好地了解您的用户

<!-- categories: Product Analytics -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/analytics/productivity_analytics.md)

{{< /details >}}

了解您的用户如何与您的应用程序互动，对于就未来的创新和优化做出数据驱动的决策至关重要。您是否发现关键业务 URL 的使用量有所上升，月活跃用户是否出现异常下降，是否有更多客户使用 Android 移动设备？通过获得此类问题的答案，并让您的工程团队能够从极狐GitLab 平台访问这些答案，您的团队就能随时了解其开发工作如何影响用户成果。

借助极狐GitLab 全新的产品分析功能，您可以对应用程序进行埋点，收集有关用户的关键使用和采用数据，然后在极狐GitLab 中展示这些数据。您可以在仪表板中可视化数据、生成报告，并以各种不同方式筛选数据，从而发现有关用户的洞察。您的团队现在可以快速识别并响应表明存在问题的客户使用量异常下降或激增，同时也能庆祝近期发布的成功。

要使用产品分析，您需要一个 Kubernetes 集群来安装此 [helm chart](https://gitlab.com/gitlab-org/analytics-section/product-analytics/helm-charts)，并对您的应用程序进行埋点以向其发送流量。随后，极狐GitLab 将连接到该集群以检索数据用于可视化。

<a id="disable-personal-access-tokens-for-enterprise-users"></a>

### 为企业用户禁用个人访问令牌

<!-- categories: User Management -->

{{< details >}}

- 交付方式: JihuLab.com
- 链接: [文档](../../user/profile/personal_access_tokens.md#disable-personal-access-tokens-for-enterprise-users) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/369504)

{{< /details >}}

JihuLab.com 的群组所有者现在可以为其群组中的任何企业用户禁用个人访问令牌的创建和使用。由于个人访问令牌可能关联强大的权限，一些所有者可能出于安全原因希望禁用这些令牌。

这种精细化控制为在 JihuLab.com 上平衡安全性和可访问性提供了选择。

<a id="autocomplete-support-for-links-to-wiki-pages"></a>

### 支持自动补全指向 Wiki 页面的链接

<!-- categories: Wiki -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/markdown.md#gitlab-specific-references) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/442229)

{{< /details >}}

我们非常高兴在极狐GitLab 16.11 中引入对指向 Wiki 页面链接的自动补全支持！借助这项新功能，从您的史诗和议题链接到 Wiki 页面从未如此简单——只需敲几下键盘即可。

将 Wiki 页面 URL 复制粘贴到史诗和议题评论中的日子已经一去不复返了。现在，只需导航到任何带有 Wiki 页面的群组或项目，访问某个史诗或议题，然后使用自动补全快捷键，即可从该史诗或议题无缝链接到您的 Wiki 页面！

<a id="sidebar-for-metadata-on-the-project-overview-page"></a>

### 项目概览页面上的元数据侧边栏

<!-- categories: Groups & Projects -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/working_with_projects.md)

{{< /details >}}

我们重新设计了项目概览页面。现在，您可以在一个侧边栏中找到所有项目信息和链接，而无需在多个区域中查找。

<a id="option-to-cancel-a-pipeline-immediately-if-any-jobs-fails"></a>

### 任一作业失败时可立即取消流水线的选项

<!-- categories: Continuous Integration (CI) -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/yaml/_index.md#workflowauto_cancelon_job_failure) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/23605)

{{< /details >}}

有时在您发现某个作业失败后，您可能会手动取消流水线的其余部分，以便在处理导致失败的问题时节省资源。在极狐GitLab 16.11 中，您现在可以将流水线配置为在任一作业失败时自动取消。对于运行时间较长的大型流水线，尤其是当许多长时间运行的作业并行运行时，这可以成为减少资源使用和成本的有效方式。

您甚至可以将流水线配置为在[下游流水线失败时立即取消](../../ci/pipelines/downstream_pipelines.md#auto-cancel-the-parent-pipeline-from-a-downstream-pipeline)，这会取消父流水线以及所有其他下游流水线。

特别感谢 [Marco](https://gitlab.com/zillemarco) 对该功能的贡献！

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

- 在极狐GitLab 17.0 中，最低支持的 PostgreSQL 版本将变为 14。为准备这一变更，在极狐GitLab 16.11 中，我们将
`attempt_auto_pg_upgrade?` 设置更改为 `true`，这将尝试自动将 PostgreSQL 版本升级到 14。此过程与我们上次提升最低支持的 PostgreSQL 版本时相同。

<a id="updated-project-archiving-functionality"></a>

### 更新后的项目归档功能

<!-- categories: Groups & Projects -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/working_with_projects.md#archive-a-project)

{{< /details >}}

现在，在项目列表中识别已归档项目更加容易。从 16.11 起，已归档项目会在群组概览的**已归档**标签页中显示**已归档**徽章。该徽章也会出现在项目概览页面的项目标题中。

一条提醒消息会说明已归档项目是只读的。该消息在所有项目页面上都可见，以确保即使在已归档项目的子页面上工作时也不会丢失这一上下文。

此外，在删除群组时，确认模态框现在会列出已归档项目的数量，以防止意外删除。

<a id="custom-webhook-headers"></a>

### 自定义 Webhook 请求头

<!-- categories: Notifications -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/integrations/webhooks.md#custom-headers) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/17290)

{{< /details >}}

此前，极狐GitLab Webhook 不支持自定义请求头。这意味着您无法将它们与那些从具有特定名称的请求头中接受身份验证令牌的系统一起使用。

在本次发布中，您可以在创建或编辑 Webhook 时添加最多 20 个自定义请求头。您可以使用这些自定义请求头向外部服务进行身份验证。

借助此功能以及极狐GitLab 16.10 中引入的[自定义 Webhook 模板](../../user/project/integrations/webhooks.md#custom-webhook-template)，您现在可以完整地设计自定义 Webhook。您可以将 Webhook 配置为：

- 发送自定义负载。
- 添加任何必需的身份验证请求头。

与密钥令牌和 URL 变量一样，当目标 URL 发生变化时，自定义请求头会被重置。

感谢 [Niklas](https://gitlab.com/Taucher2003)的[这项社区贡献](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/146702)！

<a id="test-project-hooks-with-the-rest-api"></a>

### 使用 REST API 测试项目钩子

<!-- categories: Notifications -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../api/projects.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/25329)

{{< /details >}}

此前，您只能在极狐GitLab UI 中测试项目钩子。在本次发布中，您现在可以使用 REST API 为指定项目触发测试钩子。

感谢 [Phawin](https://gitlab.com/lifez)的[这项社区贡献](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/147656)！

<a id="gitlab-for-slack-app-configurable-for-groups-and-instances"></a>

### GitLab for Slack 应用可为群组和实例配置

<!-- categories: Settings -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/integrations/gitlab_slack_application.md#from-the-project-or-group-settings) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/391526)

{{< /details >}}

此前，您一次只能为一个项目配置 GitLab for Slack 应用。在本次发布中，现在可以为群组或实例配置该集成，并一次性对多个项目进行更改。

这一改进使 GitLab for Slack 应用更接近已弃用的 [Slack 通知集成](../../user/project/integrations/slack.md)的功能对等。

<a id="configurable-import-jobs-limit"></a>

### 可配置的导入作业限制

<!-- categories: Importers -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../administration/settings/import_and_export_settings.md#maximum-number-of-simultaneous-import-jobs) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/439286)

{{< /details >}}

到目前为止，以下导入器的最大导入作业数：

- GitHub 导入器为 1000。
- Bitbucket Cloud 和 Bitbucket Server 导入器为 100。

这些限制是硬编码的，无法更改。这些限制可能会拖慢导入速度，因为它们可能不足以让导入作业以入队时的相同速率得到处理。

在本次发布中，我们将硬编码的限制移到了应用程序设置中。尽管我们不会提高 JihuLab.com 上的这些限制，但私有化部署极狐GitLab 实例的管理员现在可以根据需要配置导入作业的数量。

<a id="explore-your-product-analytics-data-with-gitlab-duo"></a>

### 使用极狐GitLab Duo 探索您的产品分析数据

<!-- categories: Product Analytics -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/analytics/productivity_analytics.md)

{{< /details >}}

[产品分析已正式发布](https://gitlab.cn/docs/#understand-your-users-better-with-product-analytics)，本次发布包含一个[自定义可视化设计器](../../user/analytics/analytics_dashboards.md)。您可以使用它来探索应用程序事件数据，并构建仪表板，以帮助您了解客户的使用和采用模式。

在可视化设计器中，您现在可以通过输入纯文本请求来让极狐GitLab Duo 为您构建可视化，例如“显示 2024 年月活跃用户的数量”或“列出本周排名靠前的 URL”。

产品分析中的极狐GitLab Duo 作为实验功能提供。

您可以通过在此[反馈议题](https://gitlab.com/gitlab-org/gitlab/-/issues/455363)中提供您对自定义可视化设计器中极狐GitLab Duo 的使用体验反馈，帮助我们完善此功能。

<a id="unified-devops-and-security"></a>

## 统一 DevOps 与安全

<a id="group-comment-templates"></a>

### 群组评论模板

<!-- categories: Code Review Workflow, Team Planning -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/profile/comment_templates.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/440817)

{{< /details >}}

在整个组织中，在议题、史诗或合并请求中使用相同的模板化回复可能会很有帮助。这些回复可能包括需要回答的标准问题、对常见问题的回复，或者合并请求评审评论的结构。

群组评论模板使您能够创建可保存的回复，并将其应用于极狐GitLab 各处的评论框，从而加快您的工作流程。这一评论模板的新增功能使组织能够集中创建和管理模板，从而让所有用户都能受益于相同的模板。

要创建评论模板，请转到极狐GitLab 上的任意评论框，然后选择**插入评论模板 > 管理群组评论模板**。创建评论模板后，该模板将对所有群组成员可用。在发表评论时选择**插入评论模板**图标，您保存的回复就会被应用。

我们对评论模板的这一新迭代感到非常兴奋，并且很快还会添加[项目级评论模板](https://gitlab.com/gitlab-org/gitlab/-/issues/440818)。如果您有任何反馈，请留在[议题 45120](https://gitlab.com/gitlab-org/gitlab/-/issues/451520)中。

<a id="build-step-of-auto-devops-upgraded"></a>

### Auto DevOps 的构建步骤已升级

<!-- categories: Auto DevOps -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../topics/autodevops/troubleshooting.md#builder-sunset-error) | [相关议题](https://gitlab.com/gitlab-org/cluster-integration/auto-build-image/-/issues/73)

{{< /details >}}

由于 Auto DevOps 的 Auto Build 组件所使用的 `heroku/buildpacks:20` 镜像已在上游弃用，我们将改用 `heroku/builder:20` 镜像。

这一破坏性变更在极狐GitLab 大版本发布之外推出，以适应上游的破坏性变更。此次升级不太可能破坏您的流水线。作为临时变通方法，您也可以手动配置 `heroku/builder:20` 镜像，并[跳过 builder 停用错误](../../topics/autodevops/troubleshooting.md#skipping-errors)。

此外，我们计划在极狐GitLab 17.0 中进行另一次重大升级，从 `heroku/builder:20` 升级到 `heroku/builder:22`。

<a id="users-list-search-and-filter-improvements"></a>

### 用户列表搜索和筛选改进

<!-- categories: System Access -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../administration/admin_area.md#administering-users) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/238183)

{{< /details >}}

管理区域的用户页面已得到改进。

此前，标签页横向分布在用户列表顶部，导致难以导航到所需的筛选条件。

现在，筛选条件已合并到搜索框中，使搜索和筛选用户变得更加容易。

感谢 [Ivan Shtyrliaiev](https://www.linkedin.com/in/bahek2462774/)的贡献！

<a id="webhook-notifications-for-expiring-group-and-project-access-tokens"></a>

### 群组和项目访问令牌即将过期时的 Webhook 通知

<!-- categories: System Access -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/integrations/webhook_events.md#project-and-group-access-token-events) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/426147)

{{< /details >}}

项目访问令牌和群组访问令牌的 Webhook 事件现已可用。

此前，电子邮件是获取令牌即将过期通知的唯一方式。Webhook 事件如果被触发，将在访问令牌过期前七天触发。

<a id="display-linked-security-policies-in-compliance-frameworks"></a>

### 在合规框架中显示已关联的安全策略

<!-- categories: Compliance Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/compliance/compliance_frameworks/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/11480)

{{< /details >}}

随着合规中心成为合规管理人员的指挥中心，您现在可以管理合规框架，还可以深入了解通过安全策略创建并关联到合规框架的管控措施。

通过这些丰富的管控措施，强制在您的合规范围内的项目中运行安全扫描器、强制双人审批，或启用漏洞管理工作流，然后将它们汇总到合规框架，确保该框架内的相关项目受到该管控措施的正确强制执行。

<a id="renew-application-secret-with-api"></a>

### 使用 API 续订应用程序密钥

<!-- categories: System Access -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../api/applications.md#renew-an-application-secret) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/422420)

{{< /details >}}

您现在可以使用 Applications API 续订应用程序密钥。此前，您必须使用 UI 才能执行此操作。现在，您可以使用 API 以编程方式轮换密钥。

感谢 [Phawin](https://gitlab.com/lifez)的贡献！

<a id="extend-policy-bot-comment-with-violation-data"></a>

### 使用违规数据扩展策略机器人评论

<!-- categories: Security Policy Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/policies/merge_request_approval_policies.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/433403)

{{< /details >}}

安全策略机器人会为用户提供上下文，帮助他们了解策略何时在其项目上强制执行、评估何时完成，以及是否存在阻止合并请求的违规情况，并提供解决这些问题的指导。我们现在扩展了机器人评论中的支持，以提供更多关于合并请求可能被策略阻止的原因的洞察，并给出更细粒度的解决反馈。评论提供的详细信息包括：

- 专门阻止合并请求的安全发现
- 不符合策略的许可证
- 可能默认导致“故障关闭”和阻止行为的策略错误
- 有关在安全发现评估中被考虑的流水线的详细信息

借助这些额外详细信息，您现在可以更快地了解合并请求的状态，并自助排查任何问题。

<a id="authenticate-to-google-cloud-with-workload-identity-federation"></a>

### 使用工作负载身份联合向 Google Cloud 进行身份验证

<!-- categories: System Access -->

{{< details >}}

- 适用版本: 基础版
- 交付方式: JihuLab.com
- 链接: [文档](../../integration/google_cloud_iam.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/12758)

{{< /details >}}

工作负载身份联合允许您在不使用服务账号密钥的情况下，安全地在极狐GitLab 和 Google Cloud 之间连接工作负载。这提高了安全性，因为密钥可能是长期有效的凭据，会暴露攻击途径。密钥还会带来创建、保护和轮换方面的管理开销。

工作负载身份联合允许您在极狐GitLab 和 Google Cloud 之间映射 IAM 角色。

此功能处于测试版，目前仅在 JihuLab.com 上可用。

<a id="issue-with-duplicate-security-policies-resolved"></a>

### 重复安全策略的问题已解决

<!-- categories: Security Policy Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/policies/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/416903)

{{< /details >}}

在极狐GitLab 16.9 及更早版本中，项目可能既从父群组或子群组继承安全策略，又链接到同一个安全策略项目。结果是策略在策略列表中重复出现。

此问题已解决，现在无法再链接到已从中继承策略的安全策略项目。

<a id="more-username-options"></a>

### 更多用户名选项

<!-- categories: User Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/profile/_index.md#change-your-username) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/429283)

{{< /details >}}

用户名只能包含非重音字母、数字、下划线（`_`）、连字符（`-`）和句点（`.`）。用户名不得以连字符（`-`）开头，也不得以句点（`.`）、`.git` 或 `.atom` 结尾。

用户名验证现在更准确地说明了这一标准。这一改进后的验证意味着您在选择用户名时能更清楚地了解可用的选项。

感谢 [Justin Zeng](https://www.linkedin.com/in/jzeng88/)的贡献！

<a id="improved-gitlab-pages-visibility-in-sidebar"></a>

### 改进侧边栏中 GitLab Pages 的可见性

<!-- categories: Pages -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/pages/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/18027)

{{< /details >}}

在之前的版本中，对于拥有 GitLab Pages 站点的项目，很难找到站点 URL。

从极狐GitLab 16.11 起，右侧边栏中有一个指向该站点的快捷链接，因此您无需查阅文档即可找到该 URL。

<a id="connect-google-artifact-registry-to-your-gitlab-project"></a>

### 将 Google 制品仓库连接到您的极狐GitLab 项目

<!-- categories: Container Registry -->

{{< details >}}

- 适用版本: 基础版
- 链接: [文档](../../user/project/integrations/google_artifact_management.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/12365)

{{< /details >}}

您可以使用极狐GitLab 容器镜像仓库，在源代码和流水线旁边查看、推送和拉取 Docker 和 OCI 镜像。对于许多极狐GitLab 客户来说，这在 `test` 和 `build` 阶段的容器镜像方面效果很好。但是，组织通常会将其生产镜像发布到云提供商，例如 Google。

此前，要将镜像从极狐GitLab 推送到 Google 制品仓库，您必须创建和维护自定义脚本以连接并部署到制品仓库。这种方式效率低下且容易出错。此外，也没有简便的方法来全面查看您的所有容器镜像。

现在，您可以利用新的 Google Artifact Management 功能，轻松地将您的极狐GitLab 项目连接到制品仓库。然后，您可以使用极狐GitLab CI/CD 流水线将镜像发布到制品仓库。您还可以通过转到**部署 > Google 制品仓库**，在极狐GitLab 中查看已发布到制品仓库的镜像。要查看镜像的详细信息，只需选择一个镜像即可。

此功能处于测试版，目前仅在 JihuLab.com 上可用。

<a id="visually-distinguish-epics-using-colors"></a>

### 使用颜色在视觉上区分史诗

<!-- categories: Portfolio Management -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/group/epics/manage_epics.md#epic-color) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/9033)

{{< /details >}}

为了进一步提升在整个组织中使用项目组合管理功能的能力，您现在可以在[路线图](../../user/group/roadmap/_index.md)和[史诗看板](../../user/group/epics/epic_boards.md)上使用颜色来区分史诗。

借助这一轻量但多用途的功能，您可以快速区分群组归属、生命周期阶段、成熟度进展或其他多种分类。

<a id="value-stream-events-can-now-be-calculated-cumulatively"></a>

### 价值流事件现在可以累计计算

<!-- categories: Value Stream Management -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/group/value_stream_analytics/_index.md#cumulative-label-event-duration) | [相关议题](https://gitlab.com/groups/gitlab-org/-/epics/12088)

{{< /details >}}

我们引入了一种更稳健的方法来计算标记事件之间的持续时间。这一变更适应了事件多次发生的情况，例如合并请求中的标记在开发状态和评审状态之间来回变化。此前，持续时间按第一个和最后一个标记事件之间经过的总时间计算。

现在，持续时间按累计时间计算，这意味着它现在能正确表示议题或合并请求仅具有给定标记的时间。

<a id="dependency-graph-support-for-dependency-scanning-sboms"></a>

### 依赖扫描 SBOM 支持依赖关系图

<!-- categories: Software Composition Analysis -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/dependency_list/_index.md) | [相关史诗](https://gitlab.com/gitlab-org/gitlab/-/issues/366168)

{{< /details >}}

用户可以在作为依赖扫描报告一部分生成的 CycloneDX SBOM 中访问依赖关系图信息。依赖关系图信息适用于以下包管理器：

- NuGet
- Yarn 1.x
- sbt
- Conan

<a id="dependency-scanning-support-for-yarn-v4"></a>

### 依赖扫描支持 Yarn v4

<!-- categories: Software Composition Analysis -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/dependency_scanning/legacy_dependency_scanning/_index.md#supported-languages-and-package-managers) | [相关史诗](https://gitlab.com/gitlab-org/gitlab/-/issues/431752)

{{< /details >}}

依赖扫描支持 Yarn v4。这一增强使我们的分析器能够解析 Yarn v4 锁定文件。

<a id="dast-analyzer-performance-updates"></a>

### DAST 分析器性能更新

<!-- categories: DAST -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/application_security/dast/browser/_index.md) | [相关议题](https://gitlab.com/groups/gitlab-org/-/epics/12194)

{{< /details >}}

在 16.11 发布里程碑期间，我们完成了以下 DAST 改进：

- 截断导航路径以提升爬虫性能，根据我们的基准测试，这将扫描时间缩短了 20%。有关更多详细信息，[请参阅该议题](https://gitlab.com/gitlab-org/gitlab/-/issues/430815)。
- 优化 DAST 报告以减少内存使用，这减少了 DAST 扫描期间 Runner 内存的峰值。有关更多详细信息，[请参阅该议题](https://gitlab.com/gitlab-org/gitlab/-/issues/444180)。

<a id="automate-the-creation-of-google-compute-engine-runners-from-gitlab---public-beta"></a>

### 从极狐GitLab 自动创建 Google Compute Engine Runner - 公开测试版

<!-- categories: GitLab Runner Core -->

{{< details >}}

- 适用版本: 基础版
- 交付方式: JihuLab.com
- 链接: [文档](../../ci/runners/provision_runners_google_cloud.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/13494)

{{< /details >}}

此前，在 Google Compute Engine 中创建极狐GitLab Runner 需要在极狐GitLab 和 Google Cloud 之间多次切换上下文。

现在，您可以使用极狐GitLab Runner Infrastructure Toolkit 中的 terraform 模板，轻松地在 Google Compute Engine 中预配极狐GitLab Runner，并通过极狐GitLab 部署极狐GitLab Runner 并预配 Google Cloud 基础设施——无需在多个系统之间切换。

<a id="improve-automatic-retry-for-failed-ci-jobs-with-specific-exit-codes"></a>

### 改进具有特定退出代码的失败 CI 作业的自动重试

<!-- categories: Pipeline Composition -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/yaml/_index.md#retry) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/262674)

{{< /details >}}

此前，您可以在 `retry:max` 之外使用 `retry:when` 来配置当发生特定失败（例如脚本失败）时作业重试的次数。

在本次发布中，您现在可以使用 [`retry:exit_codes`](../../ci/yaml/_index.md#retryexit_codes) 来根据特定的脚本退出代码配置失败作业的自动重试。您可以将 `retry:exit_codes` 与 `retry:when` 和 `retry:max` 结合使用，以根据您的具体需求微调流水线的行为，并改进流水线的执行。

感谢 [Baptiste Lalanne](https://gitlab.com/BaptisteLalanne)的这项社区贡献！

<a id="gitlab-runner-1611"></a>

### 极狐GitLab Runner 16.11

<!-- categories: GitLab Runner Core -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](https://gitlab.cn/docs/runner/)

{{< /details >}}

我们今天还发布了极狐GitLab Runner 16.11！极狐GitLab Runner 是轻量级、高度可扩展的代理，用于运行您的 CI/CD 作业并将结果发送回极狐GitLab 实例。极狐GitLab Runner 与极狐GitLab CI/CD 协同工作，后者是极狐GitLab 中包含的开源持续集成服务。

<a id="bug-fixes"></a>

#### 缺陷修复

- [崩溃：致命错误：并发 map 读取和 map 写入](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/31077)
- [FF_KUBERNETES_HONOR_ENTRYPOINT 功能不工作](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/37243)

所有变更的列表位于极狐GitLab Runner [CHANGELOG](https://gitlab.com/gitlab-org/gitlab-runner/blob/16-11-stable/CHANGELOG.md)中。

<a id="expanded-hashicorp-vault-secrets-support-including-artifactory-and-aws"></a>

### 扩展 Hashicorp Vault 密钥支持，包括 Artifactory 和 AWS

<!-- categories: Secrets Management -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/secrets/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/366492)

{{< /details >}}

极狐GitLab 与 HashiCorp Vault 的集成已扩展，以支持更多类型的密钥。您现在可以选择 `generic` 类型的密钥引擎，该引擎在极狐GitLab Runner 16.11 中引入。此通用引擎支持 HashiCorp Vault [Artifactory Secrets Plugin](https://jfrog.com/help/r/jfrog-integrations-documentation/hashicorp-vault-artifactory-secrets-plugin) 和 [AWS 密钥引擎](https://developer.hashicorp.com/vault/docs/secrets/aws)。使用此选项可以安全地检索您需要的密钥，并在极狐GitLab CI/CD 流水线中使用它们！

非常感谢 [Ivo Ivanov](https://gitlab.com/urbanwax)的这项出色贡献！

<a id="control-who-can-download-job-artifacts"></a>

### 控制谁可以下载作业产物

<!-- categories: Pipeline Composition -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../ci/yaml/_index.md#artifactsaccess) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/428677)

{{< /details >}}

默认情况下，公共流水线中 CI/CD 作业生成的所有产物均可由有权访问该流水线的所有用户下载。但是，在某些情况下，产物不应被下载，或只能由具有更高访问级别的团队成员下载。

因此，在本次发布中，我们添加了 `artifacts:access` 关键字。现在，用户可以控制产物是可由有权访问该流水线的所有用户下载、仅可由具有开发者角色或更高角色的用户下载，还是任何用户都不能下载。

<a id="improved-pipeline-details-page"></a>

### 改进的流水线详情页面

<!-- categories: Pipeline Composition -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../ci/pipelines/_index.md#view-pipelines)

{{< /details >}}

流水线图提供了对您流水线的全面概览，显示作业状态、运行时更新、多项目流水线以及父子流水线。

今天，我们很高兴地宣布发布重新设计的流水线图，它具有增强的美观性、分组作业可视化、改进的移动端体验，并在您现有的视图中扩展了下游流水线的可见性。

如果您能试用它并通过这个专门的[议题](https://gitlab.com/gitlab-org/gitlab/-/issues/450676)分享您的反馈，我们将不胜感激。
