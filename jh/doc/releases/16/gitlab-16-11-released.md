---

stage: 发行说明
group: 月度发行
date: 2024-04-18
title: "极狐GitLab 16.11 发行说明"
description: "极狐GitLab 16.11 发布，极狐GitLab Duo Chat 现已正式可用"
---

<!-- markdownlint-disable -->
<!-- vale off -->

2024 年 4 月 18 日，极狐GitLab 16.11 发布了以下功能。

## 主要功能

### 极狐GitLab Duo Chat 现正式可用

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/gitlab_duo_chat/_index.md) | [关联史诗](https://gitlab.com/groups/gitlab-org/-/epics/13516)

{{< /details >}}

极狐GitLab Duo Chat 现已正式可用。作为本次发布的一部分，我们也将以下功能设为正式可用：

- 代码解释帮助开发者和技术背景较浅的用户更快理解陌生代码
- 代码重构使开发者能够简化和改进现有代码
- 测试生成自动化重复性任务，帮助团队更早发现错误

用户可以在极狐GitLab UI、Web IDE、VS Code 或 JetBrains IDE 中访问极狐GitLab Duo Chat。

通过这篇 [博文](https://about.gitlab.com/blog/gitlab-duo-chat-now-generally-available/) 了解关于此极狐GitLab Duo Chat 版本的更多信息。

Chat 目前对所有旗舰版和专业版用户免费开放。实例管理员、群组所有者和项目所有者可以选择 [限制 Duo 功能访问和处理其数据](../../user/gitlab_duo/turn_on_off.md)。

极狐GitLab Duo Chat 是 [极狐GitLab Duo Pro](https://about.gitlab.com/gitlab-duo/#pricing) 的一部分。为了便于尚未购买极狐GitLab Duo Pro 的 Chat 测试版用户过渡，Duo Chat 将在短期内继续对现有专业版和旗舰版客户可用（无需附加组件）。我们将在日后宣布何时将访问权限限制为仅 Duo Pro 订阅用户可用。

请随时通过点击聊天中的反馈按钮或创建议题并提及 极狐GitLab Duo Chat 来分享您的想法。我们非常期待您的反馈！

### 极狐GitLab Duo Chat 现可用于 JetBrains IDE

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../editor_extensions/jetbrains_ide/_index.md) | [关联议题](https://gitlab.com/gitlab-org/editor-extensions/gitlab-jetbrains-plugin/-/issues/307)

{{< /details >}}

我们很高兴地宣布，极狐GitLab Duo Chat 现已在 JetBrains IDE 中可用。

作为极狐GitLab AI 产品的一部分，Duo Chat 通过将交互式聊天窗口直接引入任何受支持的 JetBrains IDE，并具备解释代码、编写测试和重构现有代码的能力，进一步简化了开发者体验。

有关功能的完整列表，请参阅我们的 [Duo Chat 文档](../../user/gitlab_duo_chat/_index.md)。

### 安全策略范围

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/policies/scan_execution_policies.md) | [关联史诗](https://gitlab.com/groups/gitlab-org/-/epics/5510)

{{< /details >}}

策略范围界定提供了策略的精细管理和执行。无论是合并请求批准（扫描结果）策略还是扫描执行策略，这项新功能都允许安全和合规团队将策略执行范围限定于一个合规框架，或群组中一组包含/排除的项目。

虽然目前在一个安全策略项目中管理的所有策略，都会对所有关联的群组、子群组和项目强制执行，但策略范围界定将允许您逐个策略地细化该执行策略。这使得安全和合规团队能够：

- 更轻松地在其组织内集中管理策略，同时仍能精细地执行策略。
- 更好地了解他们在极狐GitLab 中实施和执行的控制措施，如何与其定义的合规框架对应。
- 通过合规中心查看和管理哪些策略链接到了某个合规框架。
- 更好地组织并理解其安全与合规状况。

### 通过产品分析更好地了解您的用户

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/analytics/productivity_analytics.md)

{{< /details >}}

了解用户如何与您的应用程序互动至关重要，这样才能基于数据做出有关未来创新和优化的决策。您的首要业务关键 URL 的使用量是否在上升？月活跃用户数是否出现异常下降？您是否看到更多客户在使用 Android 移动设备？通过获得此类问题的答案，并使您的工程团队能够从极狐GitLab 平台访问这些答案，您的团队可以与其开发工作如何影响用户成果保持同步。

借助极狐GitLab 的新产品分析功能，您可以对应用程序进行埋点，收集有关用户的关键使用和采纳数据，然后在极狐GitLab 内部进行展示。您可以在仪表板中可视化数据，进行报告，并以多种不同方式进行筛选，以发现有关用户的洞见。您的团队现在可以快速识别并响应表明存在问题的客户使用量的意外下降或激增，同时也可以庆祝近期版本发布取得的成功。

要使用产品分析，您需要一个 Kubernetes 集群来安装此 [helm chart](https://gitlab.com/gitlab-org/analytics-section/product-analytics/helm-charts)，并对您的应用程序进行埋点以将流量发送给它。极狐GitLab 随后将连接到该集群以检索数据进行可视化。

### 为企业用户禁用个人访问令牌

{{< details >}}

- Tier: Silver, Gold
- Offering: JihuLab.com
- Links: [文档](../../user/profile/personal_access_tokens.md#disable-personal-access-tokens-for-enterprise-users) | [关联议题](https://gitlab.com/gitlab-org/gitlab/-/issues/369504)

{{< /details >}}

JihuLab.com 群组所有者现在可以为其群组中的任何企业用户禁用个人访问令牌的创建和使用。由于个人访问令牌可能关联强大的权限，出于安全原因，一些所有者可能希望禁用这些令牌。

这种精细的控制为在 JihuLab.com 上平衡安全性和可访问性提供了选择。

### 支持自动补全 Wiki 页面链接

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/markdown.md#gitlab-specific-references) | [关联议题](https://gitlab.com/gitlab-org/gitlab/-/issues/442229)

{{< /details >}}

我们激动地宣布，极狐GitLab 16.11 中引入了对 Wiki 页面链接的自动补全支持！有了这项新功能，从史诗和议题中链接到 Wiki 页面从未如此简单——只需敲击几下键盘即可。

再也不用复制粘贴 Wiki 页面 URL 到史诗和议题评论中了。现在，只需导航到任何包含 Wiki 页面的群组或项目，访问史诗或议题，并使用自动补全快捷键，即可从史诗或议题无缝链接到您的 Wiki 页面！

### 项目概览页面的元数据侧边栏

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/working_with_projects.md)

{{< /details >}}

我们重新设计了项目概览页面。现在，您可以在一个侧边栏中找到所有项目信息和链接，而无需在多个区域查找。

### 对使用 Switchboard 所做更改的电子邮件通知

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档] | [关联议题](https://about.gitlab.com/dedicated/)

{{< /details >}}

租户管理员使用 Switchboard 对您的极狐GitLab 实例所做的配置更改，现在将在完成后生成电子邮件通知。

所有有权在 Switchboard 中查看或编辑您租户的用户都将收到有关每次更改的通知。

### 在任一作业失败时立即取消流水线的选项

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../ci/yaml/_index.md#workflowauto_cancelon_job_failure) | [关联议题](https://gitlab.com/gitlab-org/gitlab/-/issues/23605)

{{< /details >}}

有时，在您注意到一个作业失败后，可能会手动取消流水线的其余部分，以在您处理导致失败的议题时节省资源。使用极狐GitLab 16.11，您现在可以配置流水线，使其在任一作业失败时自动取消。对于运行时间长的大型流水线，尤其是包含许多长时间运行的并行作业时，这可能是减少资源使用和成本的有效方法。

您甚至可以配置流水线，使其在 [下游流水线失败时立即取消](../../ci/pipelines/downstream_pipelines.md#auto-cancel-the-parent-pipeline-from-a-downstream-pipeline)，这将取消父流水线及其它下游流水线。

特别感谢 [Marco](https://gitlab.com/zillemarco) 对此功能的贡献！

## 扩展与部署

### Omnibus 改进

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](https://gitlab.cn/docs/omnibus/)

{{< /details >}}

- 在极狐GitLab 17.0 中，PostgreSQL 的最低支持版本将变为 14。为准备此变更，在极狐GitLab 16.11 中，我们已将 `attempt_auto_pg_upgrade?` 设置更改为 `true`，这将尝试自动将 PostgreSQL 版本升级到 14。此过程与我们上次提升 PostgreSQL 最低支持版本时的过程相同。

### 更新了项目归档功能

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/working_with_projects.md#archive-a-project)

{{< /details >}}

现在，在项目列表中识别已归档项目变得更容易了。从 16.11 起，已归档项目会在群组概览的 **已归档** 标签页中显示 **已归档** 徽章。此徽章也作为项目概览页面上项目标题的一部分。

一条警告消息明确说明已归档项目是只读的。此消息在所有项目页面上都可见，以确保即使在已归档项目的子页面上工作时，也不会丢失此上下文信息。

此外，在删除群组时，确认弹窗现在会列出已归档项目的数量，以防止意外删除。

### 自定义 Webhook 标头

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/integrations/webhooks.md#custom-headers) | [关联议题](https://gitlab.com/gitlab-org/gitlab/-/issues/17290)

{{< /details >}}

以前，极狐GitLab webhook 不支持自定义标头。这意味着您不能将它们用于接受特定名称标头中的认证令牌的系统。

在此版本中，您可以在创建或编辑 webhook 时添加最多 20 个自定义标头。您可以使用这些自定义标头来对外部服务进行身份验证。

借助此功能以及 极狐GitLab 16.10 中引入的 [自定义 Webhook 模板](../../user/project/integrations/webhooks.md#custom-webhook-template)，您现在可以完全设计自定义 webhook。您可以配置您的 webhook 来：

- 发送自定义有效负载。
- 添加任何必需的身份验证标头。

与密钥和 URL 变量一样，当目标 URL 更改时，自定义标头将被重置。

感谢 [Niklas](https://gitlab.com/Taucher2003) 做出的 [此社区贡献](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/146702)！

### 使用 REST API 测试项目钩子

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../api/projects.md) | [关联议题](https://gitlab.com/gitlab-org/gitlab/-/issues/25329)

{{< /details >}}

以前，您只能在极狐GitLab UI 中测试项目钩子。在此版本中，您现在可以通过 REST API 为指定项目触发测试钩子。

感谢 [Phawin](https://gitlab.com/lifez) 做出的 [此社区贡献](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/147656)！

### 适用于 Slack 应用的极狐GitLab 可为群组和实例配置

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/integrations/gitlab_slack_application.md#from-the-project-or-group-settings) | [关联议题](https://gitlab.com/gitlab-org/gitlab/-/issues/391526)

{{< /details >}}

以前，您一次只能为一个项目配置适用于 Slack 的极狐GitLab 应用。在此版本中，现在可以为群组或实例配置集成，并一次对许多项目进行更改。

这项改进使适用于 Slack 的极狐GitLab 应用在功能上更接近已弃用的 [Slack 通知集成](../../user/project/integrations/slack.md)。

### 可配置的导入作业限制

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../administration/settings/import_and_export_settings.md#maximum-number-of-simultaneous-import-jobs) | [关联议题](https://gitlab.com/gitlab-org/gitlab/-/issues/439286)

{{< /details >}}

到目前为止，最大导入作业数限制如下：

- GitHub 导入器为 1000。
- Bitbucket Cloud 和 Bitbucket Server 导入器为 100。

这些限制是硬编码的，无法更改。这些限制可能会减慢导入速度，因为它们可能不足以让导入作业以与入队相同的速度被处理。

在此版本中，我们已将硬编码限制移至应用程序设置中。虽然我们不会在 JihuLab.com 上提高这些限制，但私有化部署极狐GitLab 实例的管理员现在可以根据需要配置导入作业的数量。

### 使用极狐GitLab Duo 探索您的产品分析数据

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/analytics/productivity_analytics.md)

{{< /details >}}

[产品分析现已正式可用](https://docs.gitlab.com/#understand-your-users-better-with-product-analytics)，此版本包含一个 [自定义可视化设计器](../../user/analytics/analytics_dashboards.md)。您可以使用它来探索应用程序事件数据，并构建仪表板以帮助您了解客户的使用和采用模式。

在可视化设计器中，您现在可以通过输入纯文本请求，让极狐GitLab Duo 为您构建可视化内容，例如“显示 2024 年的月活跃用户数”或“列出本周的顶级 URL”。

产品分析中的极狐GitLab Duo 作为实验性功能提供。
- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/policies/_index.md)

{{< /details >}}

在 极狐GitLab 16.9 及更早版本中，项目可能既从父群组或子群组继承安全策略，又链接到相同的安全策略项目，导致策略在策略列表中重复出现。

此问题已解决，不再可能链接到已从中继承策略的安全策略项目。

<a id="more-username-options"></a>

### 更多用户名选项

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/profile/_index.md#change-your-username)

{{< /details >}}

用户名只能包含不带重音符号的字母、数字、下划线 (`_`)、连字符 (`-`) 和句点 (`.`)。
用户名不能以连字符 (`-`) 开头，也不能以句点 (`.`)、`.git` 或 `.atom` 结尾。

用户名验证现在更准确地说明了这些标准。这种改进的验证意味着你在选择用户名时可以更清楚地知道自己的选项。

感谢 [Justin Zeng](https://www.linkedin.com/in/jzeng88/) 的贡献！

<a id="improved-gitlab-pages-visibility-in-sidebar"></a>

### 改进侧边栏中的 极狐GitLab Pages 可见性

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/pages/_index.md)

{{< /details >}}

在之前的版本中，对于启用了 极狐GitLab Pages 站点的项目，很难找到站点 URL。

从 极狐GitLab 16.11 开始，右侧边栏有一个指向站点的快捷链接，因此你无需查阅文档即可找到 URL。

<a id="connect-google-artifact-registry-to-your-gitlab-project"></a>

### 将 Google Artifact Registry 连接到你的 极狐GitLab 项目

{{< details >}}

- Tier: 基础版，Silver，Gold
- Links: [文档](../../user/project/integrations/google_artifact_management.md)

{{< /details >}}

你可以使用 极狐GitLab 容器镜像仓库查看、推送和拉取 Docker 和 OCI 镜像，并与源代码和流水线一起管理。对于许多 极狐GitLab 客户来说，在 `测试` 和 `构建` 阶段使用容器镜像效果很好。但组织通常会将生产镜像发布到云提供商，例如 Google。

以前，要将镜像从 极狐GitLab 推送到 Google Artifact Registry，你必须创建和维护自定义脚本来连接并部署到 Artifact Registry。这样做效率低下且容易出错。此外，没有简单的方法来全面查看所有容器镜像。

现在，你可以利用新的 Google Artifact Management 功能，轻松将你的 极狐GitLab 项目连接到 Artifact Registry 仓库。然后，你可以使用 极狐GitLab CI/CD 流水线将镜像发布到 Artifact Registry。你还可以通过转到 **部署 > Google Artifact Registry** 在 极狐GitLab 中查看已发布到 Artifact Registry 的镜像。要查看镜像详细信息，只需选择一个镜像。

此功能处于 Beta 阶段，目前仅在 JihuLab.com 上可用。

<a id="visually-distinguish-epics-using-colors"></a>

### 使用颜色区分史诗

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/group/epics/manage_epics.md#epic-color)

{{< /details >}}

为了进一步提高在整个组织中使用项目组合管理功能的能力，你现在可以在[路线图](../../user/group/roadmap/_index.md)和[史诗看板](../../user/group/epics/epic_boards.md)上使用颜色区分史诗。

通过这一轻量但多功能的功能，你可以快速区分群组所有权、生命周期阶段、向成熟度发展的情况，或许多其他分类。

<a id="value-stream-events-can-now-be-calculated-cumulatively"></a>

### 价值流事件现在可以累积计算

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/group/value_stream_analytics/_index.md#cumulative-label-event-duration)

{{< /details >}}

我们引入了一种更稳健的方法来计算标签事件之间的持续时间。此更改适用于事件多次发生的情况，例如合并请求中的标签在开发和审查状态之间来回更改。以前，持续时间计算为第一个和最后一个标签事件之间经过的总时间。

现在，持续时间计算为累积时间，这意味着它现在正确地仅表示议题或合并请求具有给定标签的时间。

<a id="dependency-graph-support-for-dependency-scanning-sboms"></a>

### 依赖项扫描 SBOM 的依赖关系图支持

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/dependency_list/_index.md)

{{< /details >}}

用户可以访问作为其依赖项扫描报告一部分生成的 CycloneDX SBOM 中的依赖关系图信息。依赖关系图信息适用于以下软件包管理器：

- NuGet
- Yarn 1.x
- sbt
- Conan

<a id="dependency-scanning-support-for-yarn-v4"></a>

### 对 Yarn v4 的依赖项扫描支持

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/dependency_scanning/legacy_dependency_scanning/_index.md#supported-languages-and-package-managers)

{{< /details >}}

依赖项扫描支持 Yarn v4。此增强功能允许我们的分析器解析 Yarn v4 锁文件。

<a id="dast-analyzer-performance-updates"></a>

### DAST 分析器性能更新

{{< details >}}

- Tier: 旗舰版
- Links: [文档](../../user/application_security/dast/browser/_index.md)

{{< /details >}}

在 16.11 版本里程碑期间，我们完成了以下 DAST 改进：

- 截断导航路径以提高爬虫性能，根据我们的基准测试，将扫描时间减少了 20%。
- 优化 DAST 报告以降低内存使用，从而减少 DAST 扫描期间的流水线内存峰值。

<a id="automate-the-creation-of-google-compute-engine-runners-from-gitlab---public-beta"></a>

### 从 极狐GitLab 自动创建 Google Compute Engine Runner - 公开 Beta

{{< details >}}

- Tier: 基础版，Silver，Gold
- Offering: JihuLab.com
- Links: [文档](../../ci/runners/provision_runners_google_cloud.md)

{{< /details >}}

以前，在 Google Compute Engine 中创建 极狐GitLab Runner 需要在 极狐GitLab 和 Google Cloud 之间多次切换上下文。

现在，你可以使用来自 极狐GitLab Runner Infrastructure Toolkit 的 Terraform 模板和 极狐GitLab 轻松在 Google Compute Engine 中配置 极狐GitLab Runner，以部署 极狐GitLab Runner 并配置 Google Cloud 基础设施，而无需在多个系统之间切换。

<a id="improve-automatic-retry-for-failed-ci-jobs-with-specific-exit-codes"></a>

### 改进自动重试根据特定退出代码失败的 CI 作业

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../ci/yaml/_index.md#retry)

{{< /details >}}

以前，你可以使用 `retry:when` 以及 `retry:max` 来配置当发生特定故障（例如脚本失败）时作业重试的次数。

在此版本中，你现在可以使用 [`retry:exit_codes`](../../ci/yaml/_index.md#retryexit_codes) 根据特定脚本退出代码配置自动重试失败的作业。你可以将 `retry:exit_codes` 与 `retry:when` 和 `retry:max` 结合使用，以根据你的特定需求微调流水线的行为并改进流水线执行。

感谢 [Baptiste Lalanne](https://gitlab.com/BaptisteLalanne) 的社区贡献！

<a id="gitlab-runner-16-11"></a>

### 极狐GitLab Runner 16.11

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](https://gitlab.cn/docs/runner)

{{< /details >}}

我们今天还发布了 极狐GitLab Runner 16.11！极狐GitLab Runner 是轻量级、高度可伸缩的代理，它运行你的 CI/CD 作业并将结果发送回 极狐GitLab 实例。极狐GitLab Runner 与 极狐GitLab CI/CD 协同工作，极狐GitLab CI/CD 是 极狐GitLab 随附的开源持续集成服务。

#### 缺陷修复

- [崩溃：fatal error: concurrent map read and map write](https://jihulab.com/gitlab-cn/gitlab-runner/-/issues/31077)
- [FF_KUBERNETES_HONOR_ENTRYPOINT 功能不工作](https://jihulab.com/gitlab-cn/gitlab-runner/-/issues/37243)

所有更改的列表位于 极狐GitLab Runner [CHANGELOG](https://jihulab.com/gitlab-cn/gitlab-runner/blob/16-11-stable/CHANGELOG.md)。

<a id="expanded-hashicorp-vault-secrets-support-including-artifactory-and-aws"></a>

### 扩展的 HashiCorp Vault 密钥支持，包括 Artifactory 和 AWS

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../ci/secrets/_index.md)

{{< /details >}}

极狐GitLab 与 HashiCorp Vault 的集成已扩展，以支持更多类型的密钥。你现在可以选择在 极狐GitLab Runner 16.11 中引入的 `generic` 类型的密钥引擎。此通用引擎支持 HashiCorp Vault [Artifactory Secrets Plugin](https://jfrog.com/help/r/jfrog-integrations-documentation/hashicorp-vault-artifactory-secrets-plugin) 和 [AWS 密钥引擎](https://developer.hashicorp.com/vault/docs/secrets/aws)。使用此选项，可以安全地检索你需要的密钥并在 极狐GitLab CI/CD 流水线中使用它们！

非常感谢 [Ivo Ivanov](https://gitlab.com/urbanwax) 的这一出色贡献！

<a id="control-who-can-download-job-artifacts"></a>

### 控制谁可以下载作业产物

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../ci/yaml/_index.md#artifactsaccess)

{{< /details >}}

默认情况下，公共流水线中 CI/CD 作业生成的所有产物都可供有权访问该流水线的所有用户下载。但是，在某些情况下，产物永远不应被下载，或者只能由具有更高访问级别的团队成员下载。

因此，在此版本中，我们添加了 `artifacts:access` 关键字。现在，用户可以控制产物是可以由有权访问流水线的所有用户下载、仅由具有开发者角色或更高权限的用户下载，还是根本不允许任何用户下载。

<a id="improved-pipeline-details-page"></a>

### 改进的流水线详细信息页面

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../ci/pipelines/_index.md#view-pipelines)

{{< /details >}}

流水线图提供了流水线的全面概述，显示作业状态、运行时更新、多项目流水线以及父子流水线。

今天，我们很高兴宣布重新设计的流水线图已发布，它具有增强的美学效果、分组作业可视化、改进的移动端体验以及在你现有视图中扩展的下游流水线可见性。

我们非常感谢你能试用并分享你的反馈。