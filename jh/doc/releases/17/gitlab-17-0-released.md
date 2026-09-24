---
stage: 发布说明
group: 月度发布
date: 2024-05-16
title: "极狐GitLab 17.0 发布说明"
description: "极狐 GitLab 17.0 发布，CI/CD 目录中的组件和输入功能现已 GA。"
---

<!-- markdownlint-disable -->
<!-- vale off -->

2024 年 5 月 16 日，极狐GitLab 17.0 发布了以下功能。

## 主要功能

### CI/CD 目录中的组件和输入现已 GA

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../ci/components/_index.md#cicd-catalog)

{{< /details >}}

CI/CD 目录现已 GA。作为此版本的一部分，我们也使 [CI/CD 组件](../../ci/components/_index.md) 和 [输入](../../ci/yaml/_index.md#inputs) 成为 GA。

借助 CI/CD 目录，你可以访问由社区和行业专家创建的大量组件。
无论你是在寻求持续集成、部署流水线还是自动化任务的解决方案，你都会找到适合你需求的各种组件。
你可以在以下 [博客文章](https://about.gitlab.com/blog/ci-cd-catalog-goes-ga-no-more-building-pipelines-from-scratch/) 中阅读有关目录及其功能的更多信息。

我们邀请你向目录贡献 CI/CD 组件，帮助扩展极狐GitLab.com 上这个全新且不断发展的版块！

### 价值流仪表板中的 AI 影响力分析

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/analytics/duo_and_sdlc_trends.md) | [相关议题](https://gitlab.com/groups/gitlab-org/-/epics/12978)

{{< /details >}}

AI 影响力是价值流仪表板中可用的一个仪表板，可帮助组织了解 [极狐GitLab Duo 对其生产力的影响](https://about.gitlab.com/blog/measuring-ai-effectiveness-beyond-developer-productivity-metrics/)。
这个新的月度指标视图将 AI 使用趋势与 SDLC 指标（如前置时间、周期时间、DORA 和漏洞）进行比较。软件领导者可以使用 AI 影响力仪表板来衡量其端到端工作流中节省了多少时间，同时专注于业务成果而非开发者活动。

在第一个版本中，AI 使用情况以每月 [代码建议](../../user/project/repository/code_suggestions/_index.md) 使用率来衡量，并计算为每月唯一的代码建议用户数除以每月唯一 [贡献者](../../user/group/contribution_analytics/_index.md) 总数。

AI 影响力仪表板在限定时间内对旗舰版层级用户开放。之后，使用该仪表板将需要极狐GitLab Duo Enterprise 许可证。

### 在 Linux Arm 上推出托管 Runner

{{< details >}}

- Tier: Silver，Gold
- Offering: JihuLab.com
- Links: [文档](../../ci/runners/hosted_runners/linux.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/365300)

{{< /details >}}

我们很高兴为 JihuLab.com 推出 Linux Arm 托管 Runner。
现已可用的 `medium` 和 `large` Arm 机器类型，分别配备 4 个和 8 个 vCPU，并完全集成到极狐GitLab CI/CD 中，将使你能够比以往更快、更具成本效益地构建和测试应用程序。

我们致力于提供业界最快的 CI/CD 构建速度，并期待看到团队实现更短的反馈周期，最终更快地交付软件。

### 引入部署详情页面

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../ci/environments/deployment_approvals.md#approve-or-reject-a-deployment) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/374538)

{{< /details >}}

你现在可以直接链接到极狐GitLab 中的部署。以前，如果你在协作进行部署，必须从部署列表中查找该部署。由于列出的部署数量众多，找到正确的部署很困难且容易出错。

从 17.0 开始，极狐GitLab 提供了一个你可以直接链接到的部署详情视图。在第一个版本中，部署详情页面提供了部署作业的概览，以及持续交付环境中审批、拒绝或评论部署的可能性。我们正在研究进一步增强部署详情页面的途径，包括从相关的流水线作业链接到该页面。我们期待在 [议题 450700](https://gitlab.com/gitlab-org/gitlab/-/issues/450700) 中收到你的反馈。

### 极狐GitLab Duo Chat 现已使用国内 SOTA 大模型

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/gitlab_duo_chat/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/13297)

{{< /details >}}

极狐GitLab Duo Chat 变得好多了。它现在使用国内 SOTA 大模型作为基础模型，取代了 Claude 2.1 来回答大多数问题。

在极狐GitLab，我们在为一组任务选择最佳模型和编写表现良好的提示词时，采用测试驱动的方法。通过对聊天提示词的最新调整，与先前基于 Claude 2.1 构建的聊天版本相比，基于国内 SOTA 大模型的聊天回答在正确性、全面性和可读性方面取得了显著改进。因此，我们现在已切换到这个新模型版本。

### 在私有化部署上支持极狐GitLab Duo Chat 的使用方法问题

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/gitlab_duo_chat/examples.md#ask-about-gitlab) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/451215)

{{< /details >}}

极狐GitLab Duo Chat 一项受欢迎的功能是回答关于如何使用极狐GitLab 的问题。虽然 Chat 提供了各种其他功能，但此特定功能以前仅在 JihuLab.com 上可用。在此版本中，我们将其也提供给极狐GitLab 私有化部署使用，这与我们为所有类型的部署提供愉悦体验的承诺保持一致。

无论你是新手还是专家，你都可以向 Chat 寻求帮助，例如“如何在极狐GitLab 中更改我的密码？”或“如何将 Kubernetes 集群连接到极狐GitLab？”等问题。Chat 旨在提供有用的信息，帮助你更有效地解决问题。

### 价值流仪表板中新增使用概况面板

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/analytics/value_streams_dashboard.md#overview) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/438256)

{{< /details >}}

我们通过一个概况面板增强了价值流仪表板。这个新的可视化图表满足了对软件交付性能的高层洞察需求，并清晰展示了在软件开发生命周期 (SDLC) 背景下极狐GitLab 的使用情况。

概况面板显示了群组级别的指标，例如（子）群组、项目、用户、议题、合并请求和流水线的数量。

### 向 CI/CD 作业令牌允许列表添加群组

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../ci/jobs/ci_job_token.md#control-job-token-access-to-your-project) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/415519)

{{< /details >}}

在极狐GitLab 15.9 中引入的 CI/CD 作业令牌允许列表，可防止其他项目对你的项目进行未经授权的访问。以前，你只能在项目级别允许来自其他特定项目的访问，总项目数上限为 200。

在极狐GitLab 17.0 中，你现在可以将群组添加到项目的 CI/CD 作业令牌允许列表中。200 的最大限制现在同时适用于项目和群组，这意味着一个项目允许列表现在最多可以授权 200 个项目和群组进行访问。此改进使得添加与群组关联的大量项目变得更加容易。

### 通过 `rules:exists` CI/CD 关键字增强上下文控制

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../ci/yaml/_index.md#rulesexistsproject) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/386040)

{{< /details >}}

`rules:exists` CI/CD 关键字具有基于关键字定义位置而变化的默认行为，这使得其在更复杂的流水线中使用更加困难。当在作业中定义时，`rules:exists` 会在运行流水线的项目中搜索指定的文件。但是，当在 `include` 部分中定义时，`rules:exists` 会在包含该 `include` 部分的配置文件所在的项目中搜索指定的文件。如果配置分散在多个文件和项目中，可能很难知道将在哪个确切的项目中搜索定义的文件。

在此版本中，我们为 `rules:exists` 引入了 `project` 和 `ref` 子键，为你提供了一种显式控制此关键字搜索上下文的方法。这些新的子键通过精确指定搜索上下文，帮助你确保规则评估的准确性，减少不一致性，并增强流水线规则定义的清晰度。

## 规模化与部署

### 极狐GitLab Chart 改进

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](https://gitlab.cn/docs/charts/)

{{< /details >}}

[极狐GitLab Operator](https://gitlab.cn/docs/operator/) 现已可用于生产环境的云原生混合安装。在采用极狐GitLab Operator 之前，请参阅 [安装文档](https://gitlab.cn/docs/operator/installation.html)。

当你指定自定义 BusyBox 值 (`global.busybox`) 时，回退到 BusyBox 镜像的支持已移除。对基于 BusyBox 的 init 容器的支持在极狐GitLab 16.2 (Helm chart 7.2) 中已弃用，转而采用通用的基于极狐GitLab 的 init 镜像。

对 `gitlab.kas.privateApi.tls.enabled` 和 `gitlab.kas.privateApi.tls.secretName` 的支持也已移除。你必须改用 `global.kas.tls.enabled` 和 `global.kas.tls.secretName`。

已弃用的队列选择器和否定选项已从 Sidekiq Chart 中移除。

### Linux 软件包改进

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](https://gitlab.cn/docs/omnibus/)

{{< /details >}}

CentOS Linux 7 将于 2024 年 6 月 30 日达到 [生命周期终止](https://www.redhat.com/en/topics/linux/centos-linux-eol)。这使得极狐GitLab 17.6 成为我们可以为 CentOS 7 提供软件包的最后一个极狐GitLab 版本。

### 双数据库模式在 Beta 版中可用

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../administration/postgresql/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/432391)

{{< /details >}}

目前，大多数私有化部署客户仅使用单一数据库。
为了确保 JihuLab.com 和私有化部署之间的设置相同，我们要求私有化部署客户默认迁移并运行两个数据库。
在 16.0 中，双数据库连接成为私有化部署安装的默认设置。
在 17.0 中，我们 [将双数据库模式作为有限 Beta 版发布](../../administration/postgresql/_index.md)，目标是在 19.0 之前使运行分解式数据库成为 GA。
在 17.0 中，迁移到双数据库仍为可选，但需要在升级到 19.0 之前执行。

迁移需要停机。
私有化部署客户可以使用一个 [工具](https://gitlab.com/gitlab-org/gitlab/-/issues/368729) 来执行此迁移，但会有一些停机时间。
我们引入了一个新的 `gitlab-ctl` 命令，允许你将单一数据库的极狐GitLab 实例升级到分解式设置。
此设置包含适用于我们 Linux 软件包的命令。
[实际迁移](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/135585)（复制数据库）是极狐GitLab 项目中 rake 任务的一部分。

### 对所有成员在“成员”选项卡中列出私有共享群组成员

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/members/sharing_projects_groups.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/418888)

{{< /details >}}

以前，当公开群组或项目邀请私有群组时，该私有群组仅列在“成员”页面的“群组”选项卡中，并且私有成员对公开群组的成员不可见。为了促进这些群组成员之间更好的协作，我们现在也在“成员”选项卡中列出所有受邀群组成员，包括来自私有受邀群组的成员。成员来源将对无权访问该私有群组的成员进行屏蔽。但是，成员来源将对在项目中至少具有“维护者”角色或在群组中具有“所有者”角色的用户可见，以便他们可以管理其项目或群组中的成员。如果当前查看“成员”选项卡的用户未经验证或不是群组或项目的成员，他们将看不到私有群组成员。我们希望此更改将使群组和项目成员更容易一目了然地了解谁有权访问群组或项目。

### “成员”页面显示受邀群组的成员

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/members/_index.md#share-a-project-with-a-group) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/219230)

{{< /details >}}

以前，被邀请加入群组或项目的群组的成员仅在“成员”页面的“群组”选项卡中可见。这意味着用户必须同时检查“群组”和“成员”选项卡，才能了解谁有权访问某个群组或项目。现在，共享成员也列在“成员”选项卡中，可一目了然地提供属于群组或项目的所有成员的完整概览。

### 使用 REST API 从 Bitbucket Cloud 导入

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../api/import.md#import-repository-from-bitbucket-cloud) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/215036)

{{< /details >}}

在此里程碑中，我们增加了使用 REST API 导入 Bitbucket Cloud 项目的功能。

对于导入大量项目而言，这可能比通过 UI 导入更好的解决方案。

### 使用 API 重新导入选定的项目关系

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../api/project_import_export.md#import-project-resources) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/425798)

{{< /details >}}

当从包含许多相同类型条目（例如，合并请求或流水线）的导出文件导入项目时，有时部分条目未被导入。

在此版本中，我们添加了一个 API 端点，该端点可重新导入一个命名关系，并跳过已导入的条目。该 API 需要同时满足以下条件：

- 一个项目导出存档文件。
- 一个类型（议题、合并请求、流水线或里程碑）。

### 在极狐GitLab 中查看来自多个 Jira 项目的议题

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../integration/jira/configure.md#view-jira-issues) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/12609)

{{< /details >}}

对于较大的仓库，你现在可以在设置 Jira 议题集成后，在极狐GitLab 中查看来自多个 Jira 项目的议题。在此版本中，你可以：

- 输入最多 100 个 Jira 项目键，以逗号分隔。
- 将 **Jira 项目键** 留空以包含所有可用的键。

在极狐GitLab 中查看 Jira 议题时，你可以 [按项目筛选议题](../../integration/jira/configure.md#filter-jira-issues)。

要在极狐GitLab 旗舰版中 [为漏洞创建 Jira 议题](../../integration/jira/configure.md#create-a-jira-issue-for-a-vulnerability)，你只能指定一个 Jira 项目。

### 通过 REST API 启用在极狐GitLab 中查看 Jira 议题

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../api/project_integrations.md#jira-issues) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/267015)

{{< /details >}}

在此版本中，你可以使用 REST API 启用在极狐GitLab 中 [查看 Jira 议题](../../integration/jira/configure.md#view-jira-issues) 的功能。你还可以指定一个或多个 Jira 项目以从中查看议题。

感谢 [Ivan](https://gitlab.com/ivantedja) 的 [此社区贡献](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/150209)！

### 服务台支持多个外部参与者

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/service_desk/external_participants.md) | [相关议题](https://gitlab.com/groups/gitlab-org/-/epics/3758)

{{< /details >}}

有时，解决一个支持工单会涉及多人，或者请求者希望让同事了解工单状态的最新信息。

现在，你可以在服务台工单和常规议题上添加最多 10 个没有极狐GitLab 账号的外部参与者。

外部参与者会收到工单上每条公开评论的服务台通知邮件，并且他们的回复将作为评论显示在极狐GitLab UI 中。

只需使用快速操作 [`/add_email`](../../user/project/service_desk/external_participants.md#add-an-external-participant)
和 [`remove_email`](../../user/project/service_desk/external_participants.md#add-an-external-participant)
即可通过几次按键添加或移除外部参与者。

你还可以将极狐GitLab 配置为
[将初始邮件 `Cc` 标头中的所有电子邮件地址添加](../../user/project/service_desk/external_participants.md#add-external-participants-from-the-cc-header)
到服务台工单中。

你可以 [根据自己的喜好定制所有服务台电子邮件模板](../../user/project/service_desk/configure.md#customize-emails-sent-to-external-participants)，
使用 Markdown、HTML 和动态占位符。
一个 [退订链接占位符](../../user/project/service_desk/external_participants.md#add-an-external-participant)
可用，使外部参与者可以轻松地选择退出对话。

### 指明条目是使用直接转移导入的

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../user/group/import/direct_transfer_migrations.md#review-results-of-the-import) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/443492)

{{< /details >}}

你可以 [使用直接转移](../../user/group/import/_index.md) 在极狐GitLab 实例之间迁移极狐GitLab 群组和项目。

到目前为止，导入的条目不易识别。在此版本中，我们为使用直接转移导入的条目添加了可视指示器，其中创建者被标识为特定用户：

- 备注（系统备注和用户评论）
- 议题
- 合并请求
- 史诗
- 设计
- 代码片段
- 用户个人资料活动

## 统一 DevOps 与安全

### 在极狐GitLab Duo JetBrains IDE 插件中集成 1Password 密钥

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../editor_extensions/jetbrains_ide/_index.md#integrate-with-1password-cli) | [相关议题](https://gitlab.com/gitlab-org/editor-extensions/gitlab-jetbrains-plugin/-/issues/291)

{{< /details >}}

### 使用可自定义的快捷键更快地访问极狐GitLab Duo Chat

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../editor_extensions/jetbrains_ide/_index.md) | [相关议题](https://gitlab.com/gitlab-org/editor-extensions/gitlab-jetbrains-plugin/-/issues/332)

{{< /details >}}

### 项目评论模板

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/profile/comment_templates.md#for-a-project) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/440818)

{{< /details >}}

继在极狐GitLab 16.11 中发布 [群组评论模板](https://about.gitlab.com/releases/2024/04/18/gitlab-16-11-released/#group-comment-templates) 之后，我们在极狐GitLab 17.0 中将其引入到项目中。

在整个组织中，在议题、史诗和合并请求中使用相同的模板化响应可能会很有帮助。这些响应可能包括需要回答的标准问题、对常见问题的响应，或者用于合并请求审查评论的良好结构。项目级别的评论模板为你提供了另一种限定模板可用范围的方式，为组织在跨用户共享这些模板时带来更多控制和灵活性。


创建评论模板时，请转到极狐GitLab 上的任何评论框，然后选择 **插入评论模板 > 管理项目评论模板**。创建评论模板后，所有项目成员都可以使用。在发表评论时，选择 **插入评论模板** 图标，您保存的回复就会被应用。

我们对此次评论模板的迭代感到非常兴奋，如果您有任何反馈，请將其留在 [issue 451520](https://gitlab.com/gitlab-org/gitlab/-/issues/451520) 中。

### 为极狐GitLab UI 提交进行提交签名

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../administration/gitaly/configure_gitaly.md#configure-commit-signing-for-gitlab-ui-commits) | [相关议题](https://gitlab.com/gitlab-org/gitaly/-/issues/5361)

{{< /details >}}

以前，Web 提交和极狐GitLab 自动生成的提交无法签名。现在，您可以配置私有化部署实例的签名密钥、提交者名称和电子邮件地址，以为 Web 提交和自动提交签名。

### 提高 Kubernetes agent 授权限制

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/clusters/agent/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/431133)

{{< /details >}}

借助极狐GitLab 的 Kubernetes agent，您可以与群组共享单个 agent 连接。我们旨在支持大型多租户集群中的单个 agent。然而，您可能在连接共享的数量上遇到过限制。到目前为止，一个 agent 最多只能与 100 个项目和群组共享，使用 [CI/CD](../../user/clusters/agent/ci_cd_workflow.md)，以及 100 个项目和群组使用 [`user_access`](../../user/clusters/agent/user_access.md) 关键字。在极狐GitLab 17.0 中，您可以共享的项目和群组数量提升到了 500。

如果您需要在集群中运行多个 agent，我们期待在 [issue 454110](https://gitlab.com/gitlab-org/gitlab/-/issues/454110) 中听到您的反馈。

### 在 FIPS 模式下支持极狐GitLab 的 Kubernetes agent

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../administration/clusters/kas.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/375327)

{{< /details >}}

从极狐GitLab 17.0 开始，您可以在 FIPS 模式下安装极狐GitLab，并启用 Kubernetes agent 组件。现在，符合 FIPS 要求的用户可以从所有 [极狐GitLab Kubernetes 集成](../../user/clusters/agent/_index.md) 中受益。

### 在部署中跟踪快进合并请求

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../ci/environments/deployments.md#track-newly-included-merge-requests-per-deployment) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/384104)

{{< /details >}}

在过去的版本中，仅当项目的合并方法为 **合并提交** 或 **合并提交与半线性历史记录** 时，才会在部署中跟踪合并请求。从极狐GitLab 17.0 开始，即使在合并方法为 **快进合并** 的项目中，合并请求也会在部署中被跟踪。

### 识别由管理员模式启动的会话

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../administration/settings/sign_in_restrictions.md#check-if-your-session-has-admin-mode-enabled) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/438674)

{{< /details >}}

作为实例管理员，当您使用多个浏览器或不同计算机时，很难知道哪些会话处于管理员模式，哪些不是。现在，管理员可以转到 **用户设置 > 活跃会话** 来识别哪些会话使用了管理员模式。

感谢 [Roger Meier](https://gitlab.com/bufferoverflow) 的贡献！

### 为用户自定义头像

{{< details >}}

- Tier: 基础版，Silver，Gold
- Offering: JihuLab.com
- Links: [文档](../../api/users.md#upload-an-avatar-for-yourself) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/356868)

{{< /details >}}

您现在可以使用 API 为任何用户类型（包括机器人用户）上传自定义头像。这对于在 UI 中直观地区分机器人用户（例如群组和项目访问令牌或服务帐户）与人类用户特别有帮助。
感谢 [Phawin](https://gitlab.com/lifez) 的贡献！

### 编辑自定义角色及其权限

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/custom_roles/_index.md#edit-a-custom-role) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/437590)

{{< /details >}}

以前，您无法编辑现有的自定义角色及其权限。现在，您可以编辑自定义角色及其权限，而无需重新创建角色来实施更改。

### 自定义角色的新权限

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/custom_roles/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/391760)

{{< /details >}}

现在有了新的权限，可用于创建自定义角色：

- [分配安全策略链接](../../user/custom_roles/abilities.md#security-policy-management)
- [管理和分配合规框架](../../user/custom_roles/abilities.md#compliance-management)
- [管理 Webhooks](../../user/custom_roles/abilities.md#webhooks)
- [管理推送规则](../../user/custom_roles/abilities.md#source-code-management)

随着这些自定义权限的发布，您可以通过创建一个具有这些所有者等效权限的自定义角色来减少群组中所需的所有者数量。自定义角色允许您定义细粒度的角色，只授予用户执行其工作所需的权限，并减少不必要的权限提升。

### 在私有化部署实例级别管理自定义角色

{{< details >}}

- Tier: 旗舰版
- Links: [文档](../../user/custom_roles/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/11851)

{{< /details >}}

在此版本之前，在私有化部署的极狐GitLab 上，自定义角色必须在群组级别创建。这意味着管理员无法集中管理整个实例的自定义角色，导致实例中出现重复角色。现在，自定义角色在私有化部署实例级别进行管理。只有管理员可以创建自定义角色，但管理员和群组所有者都可以分配这些自定义角色。

有关迁移现有自定义角色、API 端点和工作流的更多信息，请参见 [史诗 11851](https://gitlab.com/groups/gitlab-org/-/epics/11851)。

此更新不影响 JihuLab.com 上的自定义角色工作流。

### 自定义角色的用户体验改进

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/custom_roles/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/11947)

{{< /details >}}

对自定义角色的用户体验进行了一系列改进，具体包括：

- [创建新自定义角色时会打开一个新页面](https://gitlab.com/gitlab-org/gitlab/-/issues/393238)。
- [改进了自定义角色表的设计](https://gitlab.com/gitlab-org/gitlab/-/issues/437592)。
- [改进了删除自定义角色对话框的设计](https://gitlab.com/gitlab-org/gitlab/-/issues/434431)。
- [预先检查基础角色的权限](https://gitlab.com/gitlab-org/gitlab/-/issues/430915)。

### 改进了管理员和群组的分支保护设置

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/repository/branches/default.md#for-all-projects-in-an-instance)

{{< /details >}}

以前，设置默认分支保护选项无法提供与受保护分支设置相同级别的配置。

在此版本中，我们更新了默认分支保护设置，以提供与受保护分支相同的体验。
这使得保护默认分支更加灵活，并简化了流程，以匹配受保护分支设置中已存在的内容。

### 策略机器人评论的可选配置

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/policies/scan_execution_policies.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/438272)

{{< /details >}}

安全策略机器人会在合并请求违反策略时发布评论，以帮助用户了解策略何时在其项目上执行、评估何时完成，以及是否存在任何阻止 MR 的违规行为，并提供解决指导。这些评论现在是可选的，可以在每个策略中启用或禁用。这为组织提供了灵活性和控制权，以决定如何向其用户传达这些策略。

### 漏洞报告上的筛选功能更新

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/vulnerability_report/_index.md#filtering-vulnerabilities) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/13339)

{{< /details >}}

旧的漏洞报告筛选实现不具备可扩展性。
我们受到页面上水平空间的限制。现在，您可以使用筛选搜索组件，按状态、严重性、工具或活动的任意组合来筛选漏洞报告。这一更改使我们能够添加新的筛选器，例如建议的 [按标识符筛选](https://gitlab.com/groups/gitlab-org/-/epics/13340)。

### 将合并请求批准策略切换为故障打开或故障关闭

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/policies/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/10816)

{{< /details >}}

对于许多组织而言，合规性是一个滑动标尺，他们需要在满足要求和确保开发人员速度不受影响之间取得平衡。合并请求批准策略有助于在 DevSecOps 工作流的核心（合并请求）中实现安全与合规的运营化。我们为合并请求批准策略引入了一个新的 `fail open` 选项，为希望在组织中推出控制措施时顺利过渡到策略执行的团队提供灵活性。

当合并请求批准策略配置为故障打开时，只有在策略规则被违反**且**项目正确配置了安全分析器时，MR 才会被阻止。如果某个分析器未为项目启用，或者分析器未能成功生成结果，则该策略将不再将其视为针对给定规则和分析器的违规行为。这种方法允许团队在努力确保正确的扫描执行和强制执行时，逐步推出策略。

### 自动删除未经验证的备用电子邮件地址

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/profile/_index.md#delete-email-addresses-from-your-user-profile) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/367823)

{{< /details >}}

如果您将备用电子邮件地址添加到用户配置文件而未进行验证，该电子邮件地址将在三天后自动删除。以前，这些电子邮件地址处于保留状态，无法在没有手动干预的情况下释放。这种自动删除减少了管理开销，并防止用户预留他们没有所有权的电子邮件地址。

### 筛选软件包仓库 UI 以查看有错误的软件包

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../user/packages/package_registry/_index.md#view-packages) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/451054)

{{< /details >}}

您可以使用极狐GitLab 软件包仓库来发布和下载软件包。有时，软件包会因错误而上传失败。以前，没有快速查看上传失败软件包的方法。这使得全面了解您组织的软件包仓库变得困难。

现在，您可以筛选软件包仓库 UI，以查看上传失败的软件包。这一改进使得调查和解决您遇到的任何问题更加容易。

### 价值流仪表板中新增的中位合并时间指标

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/analytics/value_streams_dashboard.md#dashboard-metrics-and-drill-down-reports) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/435451)

{{< /details >}}

我们向价值流仪表板添加了一个新指标：中位合并时间。在极狐GitLab 中，此指标表示从合并请求创建到合并完成之间的中位时间。这一新指标通过识别合并请求和代码审查过程的效率和生产力来衡量 DevOps 健康状况。

通过分析此指标在[其他 SDLC 指标的背景下](https://www.youtube.com/watch?v=yNZRac7gyYo)如何演变，团队可以识别生产力低或高的月份，了解新的 DevOps 实践对开发速度和交付流程的影响，缩短整体前置时间，并提高软件交付的速度。

### 设计管理功能扩展到产品团队

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/issues/design_management.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/438829)

{{< /details >}}

极狐GitLab 通过更新权限来扩展协作。现在，具有报告者角色的用户可以访问设计管理功能，使产品团队能够更直接地参与设计过程。这一更改通过邀请整个组织更广泛的参与，简化了工作流程并加速了创新。

### 增强的史诗删除保护

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/group/epics/manage_epics.md#delete-an-epic) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/452189)

{{< /details >}}

我们更新了删除史诗时发生的情况，以更好地保护您项目的结构和数据。这一切都是为了在管理项目时给您更多的控制和安心。

现在，当您删除父史诗时，我们不会自动删除其所有子记录，而是通过首先分离父关系来保留它们。这一更改为您提供了一种更安全的方式来管理史诗，确保意外删除不会导致丢失宝贵的信息。

### 路线图可按创建日期、最后更新日期和标题排序

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/group/roadmap/_index.md#sort-and-filter-the-roadmap) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/460492)

{{< /details >}}

我们扩展了路线图视图中可用的史诗排序选项，为您在组织和确定项目优先级方面提供了更大的灵活性。您现在可以按 **创建日期**、**最后更新日期** 和 **标题** 对史诗进行排序。此增强为未来更高级的排序功能奠定了基础，帮助您更动态地管理史诗。

### 简化价值流仪表板的配置文件架构

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/analytics/value_streams_dashboard.md#customize-dashboard-panels) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/432185)

{{< /details >}}

您现在可以使用简化的模式驱动可定制 UI 框架来自定义价值流仪表板面板。在新格式中，字段提供了更大的灵活性，用于显示数据和布局仪表板面板。借助新框架，管理员可以跟踪仪表板随时间的变化。此版本历史可以帮助您恢复到以前的版本，并比较仪表板版本之间的差异。

通过这种自定义，决策者可以专注于其业务最相关的信息，而团队可以更好地组织和显示关键的 DevSecOps 指标。

### 群组中的访客可以关联议题

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/permissions.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/10267)

{{< /details >}}

我们将关联议题和任务所需的最低角色从报告者降低到访客，在保持[权限](../../user/permissions.md)的同时，为您提供了更大的灵活性来跨极狐GitLab 实例组织工作。

### 议题板上可见的里程碑和迭代

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/issue_board.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/25758)

{{< /details >}}

我们改进了议题板，为您提供更清晰的项目时间线和阶段洞察。现在，通过直接在议题卡片上显示里程碑和迭代详细信息，您可以轻松跟踪进度并动态调整团队的工作量。此增强旨在使您的规划和执行更加高效，让您随时了解情况并提前完成计划。

### API 安全测试分析器更新

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/api_security_testing/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/13644)

{{< /details >}}

我们在 17.0 版本里程碑期间发布了以下 API 安全测试分析器更新：

- 系统环境变量现在从 CI runner 传递到用于某些高级场景（如请求签名）的自定义 Python 脚本。这将使实现这些场景更加容易。有关更多详细信息，请参见 [issue 457795](https://gitlab.com/gitlab-org/gitlab/-/issues/457795)。
- API 安全容器现在以非 root 用户身份运行，这提高了灵活性和合规性。有关更多详细信息，请参见 [issue 287702](https://gitlab.com/gitlab-org/gitlab/-/issues/287702)。
- 支持仅提供 TLSv1.3 密码的服务器，使更多客户能够采用 API 安全测试。有关更多详细信息，请参见 [issue 441470](https://gitlab.com/gitlab-org/gitlab/-/issues/441470)。
- 升级到 Alpine 3.19，以解决安全漏洞。有关更多详细信息，请参见 [issue 456572](https://gitlab.com/gitlab-org/gitlab/-/issues/456572)。

如[先前公告](../../update/deprecations.md#secure-analyzers-major-version-update)所述，[我们在极狐GitLab 17.0 中将 API 安全测试的主要版本号升级到了版本 5](https://gitlab.com/gitlab-org/gitlab/-/issues/456874)。

### Dependency Scanning 支持 Android

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/dependency_scanning/legacy_dependency_scanning/_index.md#use-cicd-components) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/12968)

{{< /details >}}

Dependency Scanning 的用户现在可以扫描 Android 项目。要配置 Android 扫描，请使用 [CI/CD 目录组件](https://gitlab.com/explore/catalog/components/android-dependency-scanning)。使用 [CI/CD 模板](../../user/application_security/dependency_scanning/legacy_dependency_scanning/_index.md#edit-the-gitlab-ciyml-file-manually) 的用户也支持 Android 扫描。

### Dependency Scanning 默认 Python 镜像

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/dependency_scanning/legacy_dependency_scanning/_index.md#supported-languages-and-package-managers) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/441491)

{{< /details >}}

在弃用 Python 3.9 作为默认 Python 镜像之后，Python 3.11 现在是默认镜像。

如[弃用通知](../../update/deprecations.md#deprecate-python-39-in-dependency-scanning-and-license-scanning)所述，新默认 Python 版本的目标是 3.10。直接迁移到 Python 3.11 是确保 FIPS 合规性所必需的。

### DAST 现在默认同时支持 arm64 和 amd64 架构

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/dast/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/13757)

{{< /details >}}

DAST 5 默认支持 arm64 和 amd64 架构。这使客户可以选择 Runner 主机架构并优化成本节省。

### 简化了 SAST 分析器对更多语言的支持

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../user/application_security/sast/_index.md#supported-languages-and-frameworks) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/412060)

{{< /details >}}

极狐GitLab 静态应用安全测试（SAST）现在使用更少的[分析器](../../user/application_security/sast/analyzers.md)扫描相同的[语言](../../user/application_security/sast/_index.md#supported-languages-and-frameworks)，提供更简单、更可定制的扫描体验。

在极狐GitLab 17.0 中，我们用 [极狐GitLab 管理的规则](../../user/application_security/sast/rules.md) 替换了 [基于 Semgrep 的分析器](https://gitlab.com/gitlab-org/security-products/analyzers/semgrep) 中的特定语言分析器，适用于以下语言：

- Android
- C 和 C++
- iOS
- Kotlin
- Node.js
- PHP
- Ruby

如[公告](../../update/deprecations.md#sast-analyzer-coverage-changing-in-gitlab-170)所述，我们已更新 [SAST CI/CD 模板](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Jobs/SAST.gitlab-ci.yml) 以反映新的扫描覆盖范围，并删除不再使用的特定语言分析器作业。

### Secret Detection 现在在覆盖或禁用规则时支持远程规则集

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/secret_detection/pipeline/configure.md#with-a-remote-ruleset) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/425251)

{{< /details >}}

我们解决了一个影响远程规则集的 Secret Detection 错误。现在可以通过远程规则集覆盖或禁用规则。远程规则集提供了一种可扩展的方式，在单个位置配置规则，并可应用于多个项目。

### 为 Secret Detection 引入高级漏洞跟踪

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/secret_detection/pipeline/_index.md#duplicate-vulnerability-tracking) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/434096)

{{< /details >}}

Secret Detection 现在使用高级漏洞跟踪算法，以更准确地识别同一密钥在因重构或无关更改而移动文件时的情况。当以下情况发生时，不再创建新发现：

- 泄漏在文件内移动。
- 相同值的新泄漏出现在同一文件中。

否则，现有工作流（合并请求部件、流水线报告和漏洞报告）将像以前一样处理这些发现。通过确保在密钥移动时不会报告重复漏洞，团队可以更轻松地管理泄漏的密钥。

### 已发布 CI/CD 组件的语义版本范围

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../ci/components/_index.md#semantic-versioning) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/450835)

{{< /details >}}

使用 CI/CD 目录组件时，您可能希望它自动使用最新版本。例如，您不想手动监控您使用的所有组件，并在每次有次要更新或安全补丁时手动切换到下一个版本。但使用 `~latest` 也有点风险，因为次要版本更新可能会带来意外的行为变化，而主要版本更新则有更高的破坏性变更风险。

在此版本中，您可以选择使用 CI/CD 组件的最新主要或次要版本。例如，为组件版本指定 `2`，您将获得该主要版本的所有更新，如 `2.1.1`、`2.1.2`、`2.2.0`，但不会获得 `3.0.0`。指定 `2.1`，您只会获得该次要版本的补丁更新，如 `2.1.1`、`2.1.2`，但不会获得 `2.2.0`。

### 标准化的 CI/CD 目录组件发布流程

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- 链接：[文档](../../ci/components/_index.md#publish-a-new-release)

{{< /details >}}

我们一直在努力改进 CI/CD 组件，包括让向 CI/CD Catalog 发布组件的流程成为一种一致的体验。作为这项工作的一部分，我们已将使用 [`release` 关键字](../../ci/yaml/_index.md#release) 和 `release-cli` 镜像从 CI/CD 作业中发布版本作为唯一的方法。所有对发布流程的改进都将仅应用于此方法。为避免此限制带来的破坏性变更，请确保始终使用最新版本的镜像 (`release-cli:latest`) 或至少使用大于 `v0.17` 的版本。UI 中的 [**发布** 选项](../../user/project/releases/_index.md#create-a-release-in-the-releases-page) 现已对 CI/CD 组件项目禁用。

<a id="always-run-after_script-commands-for-canceled-jobs"></a>

### 始终为已取消的作业运行 `after_script` 命令

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- 链接：[文档](../../ci/yaml/script.md#set-a-default-before_script-or-after_script-for-all-jobs) | [相关史诗](https://jihulab.com/gitlab-cn/-/epics/10158)

{{< /details >}}

[`after_script`](../../ci/yaml/_index.md#after_script) CI/CD 关键字用于在作业的主 `script` 部分之后运行额外的命令。这通常用于清理环境或作业使用的其他资源。然而，如果作业被取消，`after_script` 命令不会运行。

从极狐GitLab 17.0 开始，当作业被取消时，`after_script` 命令将始终运行。要选择退出，请参阅[文档](../../ci/yaml/script.md#skip-after_script-commands-if-a-job-is-canceled)。

<a id="gitlab-runner-17-0"></a>

### 极狐GitLab Runner 17.0

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- 链接：[文档](https://gitlab.cn/docs/runner)

{{< /details >}}

我们今天还发布了极狐GitLab Runner 17.0！极狐GitLab Runner 是一个轻量级、高度可扩展的代理，用于运行你的 CI/CD 作业并将结果发送回极狐GitLab 实例。极狐GitLab Runner 与极狐GitLab CI/CD 协同工作，后者是极狐GitLab 附带的开源持续集成服务。

<a id="whats-new"></a>

#### 新增内容

所有变更的列表请参见 极狐GitLab Runner [CHANGELOG](https://jihulab.com/gitlab-cn/gitlab-runner/blob/17-0-stable/CHANGELOG.md)。

<a id="related-topics"></a>

## 相关主题

- [弃用和移除](../../update/deprecations.md)
- [升级说明](../../update/versions/_index.md)