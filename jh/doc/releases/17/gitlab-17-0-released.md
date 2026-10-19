---
stage: Release Notes
group: Monthly Release
date: 2024-05-16
title: "极狐GitLab 17.0 发布说明"
description: "极狐GitLab 17.0 发布，CI/CD 目录组件和输入现已正式发布"
---

<!-- markdownlint-disable -->
<!-- vale off -->

2024 年 5 月 16 日，极狐GitLab 17.0 发布了以下功能。

<a id="primary-features"></a>

## 主要功能

<a id="cicd-catalog-with-components-and-inputs-now-generally-available"></a>

### CI/CD 目录组件和输入现已正式发布

<!-- categories: Pipeline Composition -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../ci/components/_index.md#cicd-catalog)

{{< /details >}}

CI/CD 目录现已正式发布。作为本次发布的一部分，[CI/CD 组件](../../ci/components/_index.md)和[输入](../../ci/yaml/_index.md#inputs)也已正式发布。

借助 CI/CD 目录，您可以访问由社区和行业专家创建的大量组件。无论您是在寻找持续集成、部署流水线还是自动化任务的解决方案，都能找到满足您需求的多样化组件。您可以在以下[博客文章](https://about.gitlab.com/blog/ci-cd-catalog-goes-ga-no-more-building-pipelines-from-scratch/)中了解有关目录及其功能的更多信息。

我们诚邀您向目录贡献 CI/CD 组件，帮助扩展 JihuLab.com 上这个全新且不断增长的部分！

<a id="ai-impact-analytics-in-the-value-streams-dashboard"></a>

### 价值流仪表板中的 AI 影响分析

<!-- categories: Value Stream Management, Code Suggestions -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/analytics/duo_and_sdlc_trends.md) | [相关议题](https://gitlab.com/groups/gitlab-org/-/epics/12978)

{{< /details >}}

AI 影响分析是价值流仪表板中提供的一个仪表板，可帮助组织了解[极狐GitLab Duo 对其生产力的影响](https://about.gitlab.com/blog/measuring-ai-effectiveness-beyond-developer-productivity-metrics/)。这个新的月度环比指标视图将 AI 使用趋势与交付周期、周期时间、DORA 和漏洞等 SDLC 指标进行比较。软件负责人可以使用 AI 影响分析仪表板来衡量其端到端工作流节省了多少时间，同时专注于业务成果而非开发者活动。

在此首个版本中，AI 使用情况以每月[代码建议](../../user/project/repository/code_suggestions/_index.md)使用率来衡量，计算方式为每月独立代码建议用户数除以每月独立[贡献者](../../user/group/contribution_analytics/_index.md)总数。

AI 影响分析仪表板在限定时间内向旗舰版用户提供。之后，使用该仪表板将需要极狐GitLab Duo Enterprise 许可证。

<a id="introducing-hosted-runners-on-linux-arm"></a>

### 推出 Linux Arm 托管 Runner

<!-- categories: GitLab Hosted Runners -->

{{< details >}}

- 交付方式: JihuLab.com
- 链接: [文档](../../ci/runners/hosted_runners/linux.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/365300)

{{< /details >}}

我们很高兴为 JihuLab.com 推出 Linux Arm 托管 Runner。
现已可用的 `medium` 和 `large` Arm 机型分别配备 4 个和 8 个 vCPU，并与极狐GitLab CI/CD 完全集成，让您能够比以往更快、更经济高效地构建和测试应用程序。

我们致力于提供业界最快的 CI/CD 构建速度，并期待看到团队实现更短的反馈周期，最终更快地交付软件。

<a id="introducing-deployment-detail-pages"></a>

### 推出部署详情页面

<!-- categories: Release Orchestration, Environment Management -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/environments/deployment_approvals.md#approve-or-reject-a-deployment) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/374538)

{{< /details >}}

现在您可以直接链接到极狐GitLab 中的部署。此前，如果您在协作处理某个部署，必须从部署列表中查找该部署。由于列出的部署数量众多，找到正确的部署既困难又容易出错。

从 17.0 开始，极狐GitLab 提供了可直接链接的部署详情视图。在此首个版本中，部署详情页面提供了部署作业的概览，并支持在持续交付环境中批准、拒绝或评论部署。我们正在探索进一步增强部署详情页面的途径，包括从相关的流水线作业链接到该页面。我们非常希望您在[议题 450700](https://gitlab.com/gitlab-org/gitlab/-/issues/450700)中提供反馈。

<a id="gitlab-duo-chat-now-uses-anthropic-claude-3-sonnet"></a>

### 极狐GitLab Duo Chat 现使用 Anthropic Claude 3 Sonnet

<!-- categories: Duo Chat -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/gitlab_duo_chat/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/13297)

{{< /details >}}

极狐GitLab Duo Chat 变得更好了。它现在使用 Anthropic Claude 3 Sonnet 作为基础模型，取代 Claude 2.1 来回答大多数问题。

在极狐GitLab，我们在为一组任务选择最佳模型和编写表现良好的提示词时采用测试驱动的方法。通过对聊天提示词的最新调整，与基于 Claude 2.1 构建的上一版聊天相比，基于 Claude 3 Sonnet 的聊天回答在正确性、全面性和可读性方面都取得了显著改进。因此，我们现在已切换到这个新的模型版本。

<a id="how-to-questions-in-gitlab-duo-chat-supported-on-self-managed-deployments"></a>

### 私有化部署支持极狐GitLab Duo Chat 操作指南问题

<!-- categories: Duo Chat -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/gitlab_duo_chat/examples.md#ask-about-gitlab) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/451215)

{{< /details >}}

极狐GitLab Duo Chat 的一项热门功能是回答有关如何使用极狐GitLab 的问题。虽然 Chat 提供了各种其他功能，但这项特定功能此前仅在 JihuLab.com 上可用。通过本次发布，我们将其也提供给极狐GitLab 私有化部署，践行我们在所有部署类型中提供愉悦体验的承诺。

无论您是新手还是专家，都可以向 Chat 寻求帮助，例如“如何在极狐GitLab 中更改密码？”或“如何将 Kubernetes 集群连接到极狐GitLab？”。Chat 旨在提供有用的信息，帮助您更高效地解决问题。

<a id="new-usage-overview-panel-in-the-value-streams-dashboard"></a>

### 价值流仪表板新增使用概览面板

<!-- categories: Value Stream Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/analytics/value_streams_dashboard.md#overview) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/438256)

{{< /details >}}

我们为价值流仪表板增强了概览面板。这个新的可视化满足了高管层对软件交付绩效洞察的需求，并清晰展示了极狐GitLab 在软件开发生命周期（SDLC）中的使用情况。

概览面板显示群组级别的指标，例如（子）群组、项目、用户、议题、合并请求和流水线的数量。

<a id="add-a-group-to-the-cicd-job-token-allowlist"></a>

### 将群组添加到 CI/CD 作业令牌允许名单

<!-- categories: Secrets Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/jobs/ci_job_token.md#control-job-token-access-to-your-project) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/415519)

{{< /details >}}

极狐GitLab 15.9 中引入的 CI/CD 作业令牌允许名单可防止其他项目未经授权访问您的项目。此前，您只能在项目级别允许其他特定项目的访问，总项目数上限为 200 个。

在极狐GitLab 17.0 中，您现在可以将群组添加到项目的 CI/CD 作业令牌允许名单。200 的上限现在同时适用于项目和群组，这意味着项目允许名单现在最多可授权 200 个项目和群组进行访问。这项改进使添加与群组关联的大量项目变得更加容易。

<a id="enhanced-context-control-with-the-rulesexists-cicd-keyword"></a>

### 使用 `rules:exists` CI/CD 关键字增强上下文控制

<!-- categories: Pipeline Composition -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../ci/yaml/_index.md#rulesexistsproject) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/386040)

{{< /details >}}

`rules:exists` CI/CD 关键字具有默认行为，这些行为因关键字定义位置而异，这可能使其在更复杂的流水线中更难使用。在作业中定义时，`rules:exists` 会在运行流水线的项目中搜索指定文件。但是，在 `include` 部分中定义时，`rules:exists` 会在托管包含 `include` 部分的配置文件的项目中搜索指定文件。如果配置分散在多个文件和项目中，可能很难知道将在哪个确切项目中搜索定义的文件。

在此版本中，我们为 `rules:exists` 引入了 `project` 和 `ref` 子键，为您提供了一种显式控制此关键字搜索上下文的方法。这些新的子键通过精确指定搜索上下文，帮助您确保规则评估的准确性，减少不一致性，并提高流水线规则定义的清晰度。

<a id="scale-and-deployments"></a>

## 扩展与部署

<a id="gitlab-chart-improvements"></a>

### GitLab chart 改进

<!-- categories: Cloud Native Installation -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](https://gitlab.cn/docs/charts/)

{{< /details >}}

[GitLab Operator](https://docs.gitlab.com/operator/) 现已可用于云原生混合安装的生产环境。在采用 GitLab Operator 之前，请参阅[安装文档](https://docs.gitlab.com/operator/installation/)。

当您指定自定义 BusyBox 值（`global.busybox`）时回退到 BusyBox 镜像的支持已移除。基于 BusyBox 的 init 容器支持在极狐GitLab 16.2（Helm chart 7.2）中已弃用，取而代之的是基于极狐GitLab 的通用 init 镜像。

对 `gitlab.kas.privateApi.tls.enabled` 和 `gitlab.kas.privateApi.tls.secretName`的支持也已移除。您必须改用 `global.kas.tls.enabled` 和 `global.kas.tls.secretName`。

已弃用的队列选择器和否定选项已从 Sidekiq chart 中移除。

<a id="linux-package-improvements"></a>

### Linux 软件包改进

<!-- categories: Omnibus Package -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](https://gitlab.cn/docs/omnibus/)

{{< /details >}}

CentOS Linux 7 将于 2024 年 6 月 30 日[终止生命周期](https://www.redhat.com/en/topics/linux/centos-linux-eol)。这使得极狐GitLab 17.6 成为我们能够为 CentOS 7 提供软件包的最后一个极狐GitLab 版本。

<a id="two-database-mode-is-available-in-beta"></a>

### 双数据库模式以测试版提供

<!-- categories: Cell -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../administration/postgresql/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/432391)

{{< /details >}}

目前，大多数私有化部署客户仅使用单个数据库。为了确保 JihuLab.com 和私有化部署之间的设置一致，我们要求私有化部署客户默认迁移并运行两个数据库。在 16.0 中，两个数据库连接成为私有化部署安装的默认设置。在 17.0 中，我们[以限量测试版形式发布双数据库模式](../../administration/postgresql/_index.md)，目标是在 19.0 之前让分解式数据库运行模式正式发布。在 17.0 中，迁移到两个数据库仍然是可选的，但需要在升级到 19.0 之前执行。

迁移需要停机。私有化部署客户可以使用一个[工具](https://gitlab.com/gitlab-org/gitlab/-/issues/368729)在少量停机的情况下执行此迁移。我们引入了一个新的 `gitlab-ctl` 命令，允许您将单数据库极狐GitLab 实例升级为分解式设置。此设置包含适用于我们 Linux 软件包的命令。[实际迁移](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/135585)（复制数据库）是极狐GitLab 项目中 rake 任务的一部分。

<a id="private-shared-group-members-are-listed-on-members-tab-for-all-members"></a>

### 私有共享群组成员在“成员”选项卡中对所有成员列出

<!-- categories: Groups & Projects -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/members/sharing_projects_groups.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/418888)

{{< /details >}}

此前，当公共群组或项目邀请私有群组时，该私有群组仅列在“成员”页面的“群组”选项卡中，私有成员对公共群组的成员不可见。为了实现这些群组成员之间更好的协作，我们现在也会在“成员”选项卡中列出所有受邀群组成员，包括来自私有受邀群组的成员。成员来源将对无权访问该私有群组的成员隐藏。但是，在项目中至少具有维护者角色或在群组中具有所有者角色的用户可以看到成员来源，以便他们管理其项目或群组中的成员。如果当前查看“成员”选项卡的用户未经过身份验证或不是该群组或项目的成员，他们将看不到私有群组成员。我们希望此更改能让群组和项目成员更轻松地一目了然地了解谁有权访问某个群组或项目。

<a id="members-page-displays-members-from-invited-groups"></a>

### “成员”页面显示来自受邀群组的成员

<!-- categories: Groups & Projects -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/members/_index.md#share-a-project-with-a-group) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/219230)

{{< /details >}}

此前，受邀加入群组或项目的群组成员仅显示在“成员”页面的“群组”选项卡中。这意味着用户必须同时查看“群组”和“成员”选项卡，才能了解谁有权访问某个群组或项目。现在，共享成员也会列在“成员”选项卡中，让您一目了然地完整了解群组或项目的所有成员。

<a id="import-from-bitbucket-cloud-by-using-rest-api"></a>

### 使用 REST API 从 Bitbucket Cloud 导入

<!-- categories: Importers -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../api/import.md#import-repository-from-bitbucket-cloud) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/215036)

{{< /details >}}

在此里程碑中，我们增加了使用 REST API 导入 Bitbucket Cloud 项目的能力。

对于导入大量项目，这可能比使用 UI 导入更好的解决方案。

<a id="re-import-a-chosen-project-relation-by-using-the-api"></a>

### 使用 API 重新导入所选项目关系

<!-- categories: Importers -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../api/project_import_export.md#import-project-resources) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/425798)

{{< /details >}}

从导出文件导入项目时，如果同一类型（例如合并请求或流水线）的条目很多，有时其中一些条目未被导入。

在此版本中，我们添加了一个 API 端点，用于重新导入指定关系，跳过已导入的条目。该 API 需要以下两者：

- 项目导出归档文件。
- 类型（议题、合并请求、流水线或里程碑）。

<a id="view-issues-from-multiple-jira-projects-in-gitlab"></a>

### 在极狐GitLab 中查看多个 Jira 项目的议题

<!-- categories: Settings -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../integration/jira/configure.md#view-jira-issues) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/12609)

{{< /details >}}

对于较大的代码仓库，您现在可以在设置 Jira 议题集成后，在极狐GitLab 中查看多个 Jira 项目的议题。通过此版本，您可以：

- 输入最多 100 个以逗号分隔的 Jira 项目键。
- 将 **Jira 项目键**留空以包含所有可用键。

在极狐GitLab 中查看 Jira 议题时，您可以[按项目筛选议题](../../integration/jira/configure.md#filter-jira-issues)。

要在极狐GitLab 旗舰版中[为漏洞创建 Jira 议题](../../integration/jira/configure.md#create-a-jira-issue-for-a-vulnerability)，您只能指定一个 Jira 项目。

<a id="enable-viewing-jira-issues-in-gitlab-with-the-rest-api"></a>

### 使用 REST API 启用在极狐GitLab 中查看 Jira 议题

<!-- categories: Source Code Management, Settings -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../api/project_integrations.md#jira-issues) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/267015)

{{< /details >}}

通过此版本，您可以使用 REST API 启用[在极狐GitLab 中查看 Jira 议题](../../integration/jira/configure.md#view-jira-issues)。您还可以指定一个或多个要查看其议题的 Jira 项目。

感谢 [Ivan](https://gitlab.com/ivantedja)的[社区贡献](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/150209)！

<a id="multiple-external-participants-for-service-desk"></a>

### 服务台支持多个外部参与者

<!-- categories: Service Desk -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/service_desk/external_participants.md) | [相关议题](https://gitlab.com/groups/gitlab-org/-/epics/3758)

{{< /details >}}

有时，解决支持工单涉及不止一个人，或者请求者希望让同事了解工单的最新状态。

现在，您可以在服务台工单和普通议题上拥有最多 10 个没有极狐GitLab 账号的外部参与者。

外部参与者会收到工单上每条公开评论的服务台通知电子邮件，他们的回复将作为评论显示在极狐GitLab UI 中。

只需使用快速操作 [`/add_email`](../../user/project/service_desk/external_participants.md#add-an-external-participant) 和 [`remove_email`](../../user/project/service_desk/external_participants.md#add-an-external-participant) 即可通过几次按键添加或移除外部参与者。

您还可以配置极狐GitLab，将初始电子邮件 `Cc` 标头中的[所有电子邮件地址添加](../../user/project/service_desk/external_participants.md#add-external-participants-from-the-cc-header)到服务台工单。

您可以使用 Markdown、HTML 和动态占位符[定制所有服务台电子邮件模板](../../user/project/service_desk/configure.md#customize-emails-sent-to-external-participants)。提供了一个[退订链接占位符](../../user/project/service_desk/external_participants.md#add-an-external-participant)，方便外部参与者选择退出对话。

<a id="indicate-that-items-were-imported-using-direct-transfer"></a>

### 标记使用直接迁移导入的条目

<!-- categories: Importers -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/group/import/direct_transfer_migrations.md#review-results-of-the-import) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/443492)

{{< /details >}}

您可以[使用直接迁移](../../user/group/import/_index.md)在极狐GitLab 实例之间迁移极狐GitLab 群组和项目。

到目前为止，导入的条目不易识别。通过此版本，我们为使用直接迁移导入的条目添加了可视化指示器，其中创建者被标识为特定用户：

- 评论（系统评论和用户评论）
- 议题
- 合并请求
- 史诗
- 设计
- 代码片段
- 用户个人资料活动

<a id="unified-devops-and-security"></a>

## 统一 DevOps 与安全

<a id="1password-secrets-integration-in-gitlab-duo-plugin-for-jetbrains-ides"></a>

### JetBrains IDE 极狐GitLab Duo 插件中的 1Password 密钥集成

<!-- categories: Editor Extensions -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../editor_extensions/jetbrains_ide/_index.md#integrate-with-1password-cli) | [相关议题](https://gitlab.com/gitlab-org/editor-extensions/gitlab-jetbrains-plugin/-/issues/291)

{{< /details >}}

您现在可以将 1Password 密钥管理与 JetBrains 的极狐GitLab Duo 插件集成。

开发者可以在其 JetBrains IDE 设置中将个人访问令牌替换为 1Password 密钥引用。这简化了密钥管理，并支持无缝轮换密钥，而无需手动更新令牌。

<a id="access-gitlab-duo-chat-faster-with-customizable-shortcuts"></a>

### 使用可自定义快捷键更快访问极狐GitLab Duo Chat

<!-- categories: Editor Extensions, Duo Chat -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../editor_extensions/jetbrains_ide/_index.md) | [相关议题](https://gitlab.com/gitlab-org/editor-extensions/gitlab-jetbrains-plugin/-/issues/332)

{{< /details >}}

现在，直接从 JetBrains 的编辑器中打开 Duo Chat 更加容易。

使用默认的 Alt+D 键盘快捷键（或设置您自己的快捷键）快速打开 Duo Chat 并输入您的问题。使用相同的键盘快捷键关闭窗口。

<a id="project-comment-templates"></a>

### 项目评论模板

<!-- categories: Code Review Workflow, Team Planning -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/profile/comment_templates.md#for-a-project) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/440818)

{{< /details >}}

在[极狐GitLab 16.11 中的群组评论模板](../16/gitlab-16-11-released.md#group-comment-templates)发布之后，我们在极狐GitLab 17.0 中将这些模板引入项目。

在整个组织中，在议题、史诗和合并请求中使用相同的模板化回复可能会很有帮助。这些回复可能包括需要回答的标准问题、对常见问题的回复，或合并请求评审评论的良好结构。项目级评论模板为您提供了另一种限定模板可用范围的方式，使组织在跨用户共享这些模板时拥有更多控制权和灵活性。

要创建评论模板，请转到极狐GitLab 上的任意评论框，然后选择**插入评论模板 > 管理项目评论模板**。创建评论模板后，所有项目成员都可以使用它。在发表评论时选择**插入评论模板**图标，您保存的回复将被应用。

我们对评论模板的这次迭代感到非常兴奋，如果您有任何反馈，请在[议题 451520](https://gitlab.com/gitlab-org/gitlab/-/issues/451520)中留下。

<a id="commit-signing-for-gitlab-ui-commits"></a>

### 极狐GitLab UI 提交的提交签名

<!-- categories: Source Code Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../administration/gitaly/configure_gitaly.md#configure-commit-signing-for-gitlab-ui-commits) | [相关议题](https://gitlab.com/gitlab-org/gitaly/-/issues/5361)

{{< /details >}}

此前，Web 提交和极狐GitLab 自动执行的提交无法签名。现在，您可以为私有化部署实例配置签名密钥、提交者名称和电子邮件地址，以对 Web 和自动提交进行签名。

<a id="increase-kubernetes-agent-authorization-limit"></a>

### 提高 Kubernetes 代理授权限制

<!-- categories: Continuous Delivery -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/clusters/agent/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/431133)

{{< /details >}}

借助极狐GitLab Kubernetes Agent，您可以与群组共享单个代理连接。我们的目标是在大型多租户集群中支持单个代理。但是，您可能遇到过连接共享数量方面的限制。到目前为止，使用 [CI/CD](../../user/clusters/agent/ci_cd_workflow.md) 时，一个代理只能与 100 个项目和群组共享，使用 [`user_access`](../../user/clusters/agent/user_access.md) 关键字时也只能与 100 个项目和群组共享。在极狐GitLab 17.0 中，您可以共享的项目和群组数量提高到 500 个。

如果您需要在集群中运行多个代理，我们希望在[议题 454110](https://gitlab.com/gitlab-org/gitlab/-/issues/454110)中听到您的反馈。

<a id="support-for-gitlab-agent-for-kubernetes-in-fips-mode"></a>

### 在 FIPS 模式下支持极狐GitLab Kubernetes Agent

<!-- categories: Continuous Delivery -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../administration/clusters/kas.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/375327)

{{< /details >}}

从极狐GitLab 17.0 开始，您可以在启用极狐GitLab Kubernetes Agent 组件的情况下以 FIPS 模式安装极狐GitLab。现在，符合 FIPS 要求的用户可以从所有[极狐GitLab 的 Kubernetes 集成](../../user/clusters/agent/_index.md)中受益。

<a id="track-fast-forward-merge-requests-in-deployments"></a>

### 在部署中跟踪快进合并请求

<!-- categories: Continuous Delivery -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/environments/deployments.md#track-newly-included-merge-requests-per-deployment) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/384104)

{{< /details >}}

在过去的版本中，仅当项目的合并方法为**合并提交**或**合并提交与半线性历史记录**时，才会在部署中跟踪合并请求。从极狐GitLab 17.0 开始，合并请求会在部署中被跟踪，包括合并方法为**快进合并**的项目。

<a id="identify-sessions-initiated-by-admin-mode"></a>

### 识别由管理员模式发起的会话

<!-- categories: User Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../administration/settings/sign_in_restrictions.md#check-if-your-session-has-admin-mode-enabled) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/438674)

{{< /details >}}

作为实例管理员，当您使用多个浏览器或不同计算机时，很难知道哪些会话处于管理员模式，哪些不是。现在，管理员可以前往**用户设置 > 活动会话**来识别哪些会话使用了管理员模式。

感谢 [Roger Meier](https://gitlab.com/bufferoverflow)的贡献！

<a id="customize-avatars-for-users"></a>

### 为用户自定义头像

<!-- categories: User Management -->

{{< details >}}

- 适用版本: 基础版
- 交付方式: JihuLab.com
- 链接: [文档](../../api/users.md#upload-an-avatar-for-yourself) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/356868)

{{< /details >}}

您现在可以使用 API 为任何用户类型（包括机器人用户）上传自定义头像。这对于在 UI 中直观区分机器人用户（例如群组和项目访问令牌或服务账号）与人类用户特别有帮助。
感谢 [Phawin](https://gitlab.com/lifez)的贡献！

<a id="edit-a-custom-role-and-its-permissions"></a>

### 编辑自定义角色及其权限

<!-- categories: Permissions -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/custom_roles/_index.md#edit-a-custom-role) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/437590)

{{< /details >}}

此前，您无法编辑现有的自定义角色及其权限。现在，您可以编辑自定义角色及其权限，而无需重新创建角色即可进行更改。

<a id="new-permissions-for-custom-roles"></a>

### 自定义角色的新权限

<!-- categories: Permissions -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/custom_roles/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/391760)

{{< /details >}}

现在有新的权限可用于创建自定义角色：

- [分配安全策略链接](../../user/custom_roles/abilities.md#security-policy-management)
- [管理和分配合规框架](../../user/custom_roles/abilities.md#compliance-management)
- [管理 Webhook](../../user/custom_roles/abilities.md#webhooks)
- [管理推送规则](../../user/custom_roles/abilities.md#source-code-management)

随着这些自定义权限的发布，您可以通过创建具有这些等同于所有者权限的自定义角色来减少群组中所需的所有者数量。自定义角色允许您定义细粒度角色，仅授予用户完成工作所需的权限，并减少不必要的权限提升。

<a id="manage-custom-roles-at-self-managed-instance-level"></a>

### 在私有化部署实例级别管理自定义角色

<!-- categories: Permissions -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/custom_roles/_index.md) | [相关议题](https://gitlab.com/groups/gitlab-org/-/epics/11851)

{{< /details >}}

在此版本之前，在私有化部署极狐GitLab 上，自定义角色必须在群组级别创建。这意味着管理员无法集中管理实例的自定义角色，导致整个实例中出现重复角色。现在，自定义角色在私有化部署实例级别进行管理。只有管理员可以创建自定义角色，但管理员和群组所有者都可以分配这些自定义角色。

有关迁移现有自定义角色、API 端点和工作流的更多信息，请参阅[史诗 11851](https://gitlab.com/groups/gitlab-org/-/epics/11851)。

此更新不影响 JihuLab.com 上的自定义角色工作流。

<a id="ux-improvements-to-custom-roles"></a>

### 自定义角色的用户体验改进

<!-- categories: Permissions -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/custom_roles/_index.md) | [相关议题](https://gitlab.com/groups/gitlab-org/-/epics/11947)

{{< /details >}}

对自定义角色的用户体验进行了一系列改进，具体包括：

- [创建新自定义角色时会打开一个新页面](https://gitlab.com/gitlab-org/gitlab/-/issues/393238)。
- [改进了自定义角色表格的设计](https://gitlab.com/gitlab-org/gitlab/-/issues/437592)。
- [改进了删除自定义角色对话框的设计](https://gitlab.com/gitlab-org/gitlab/-/issues/434431)。
- [预检查基础角色的权限](https://gitlab.com/gitlab-org/gitlab/-/issues/430915)。

<a id="improved-branch-protection-settings-for-administrators-and-for-groups"></a>

### 为管理员和群组改进分支保护设置

<!-- categories: Compliance Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/repository/branches/default.md#for-all-projects-in-an-instance)

{{< /details >}}

此前，设置默认分支保护选项无法提供与受保护分支设置相同级别的配置。

在此版本中，我们更新了默认分支保护设置，以提供与受保护分支相同的体验。这使您在保护默认分支时拥有更大的灵活性，并简化了流程，使其与受保护分支设置中已有的内容保持一致。

<a id="optional-configuration-for-policy-bot-comment"></a>

### 策略机器人评论的可选配置

<!-- categories: Security Policy Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/policies/scan_execution_policies.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/438272)

{{< /details >}}

当合并请求违反策略时，安全策略机器人会在合并请求上发表评论，帮助用户了解策略何时在其项目上强制执行、评估何时完成，以及是否存在阻止合并请求的违规行为，并提供解决指导。这些评论现在是可选的，可以在每个策略中启用或禁用。这为组织提供了灵活性和控制权，以决定如何向其用户传达这些策略。

<a id="updated-filtering-on-the-vulnerability-report"></a>

### 漏洞报告更新了筛选功能

<!-- categories: Vulnerability Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/vulnerability_report/_index.md#filtering-vulnerabilities) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/13339)

{{< /details >}}

漏洞报告筛选器的旧实现不具备可扩展性。我们受到页面水平空间的限制。您现在可以使用筛选搜索组件，按状态、严重程度、工具或活动的任意组合筛选漏洞报告。此更改使我们能够添加新的筛选器，例如这个提议的[按标识符筛选](https://gitlab.com/groups/gitlab-org/-/epics/13340)。

<a id="toggle-merge-request-approval-policies-to-fail-open-or-fail-closed"></a>

### 切换合并请求审批策略为故障开放或故障关闭

<!-- categories: Security Policy Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/policies/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/10816)

{{< /details >}}

对于许多组织而言，合规是在满足要求和确保开发者速度不受影响之间取得平衡的一个滑动尺度。合并请求审批策略有助于在 DevSecOps 工作流的核心——合并请求——中将安全性和合规性操作化。我们为合并请求审批策略引入了一个新的 `fail open` 选项，为希望在组织中逐步推行控制措施时更平稳过渡到策略执行的团队提供灵活性。

当合并请求审批策略配置为故障开放时，仅当策略规则被违反**且**该项目已正确配置安全分析器时，合并请求才会被阻止。如果项目未启用分析器，或者分析器未能成功产生结果，策略将不再将此视为对给定规则和分析器的违规。这种方法允许团队在努力确保正确执行扫描和强制执行的同时，逐步推行策略。

<a id="automatic-deletion-of-unverified-secondary-email-addresses"></a>

### 自动删除未验证的辅助电子邮件地址

<!-- categories: User Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/profile/_index.md#delete-email-addresses-from-your-user-profile) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/367823)

{{< /details >}}

如果您向用户个人资料添加辅助电子邮件地址但未验证，该电子邮件地址现在会在三天后自动删除。此前，这些电子邮件地址处于保留状态，未经人工干预无法释放。这种自动删除减少了管理员的工作量，并防止用户保留他们不拥有所有权的电子邮件地址。

<a id="filter-package-registry-ui-for-packages-with-errors"></a>

### 筛选软件包仓库 UI 以查看有错误的软件包

<!-- categories: Package Registry -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/packages/package_registry/_index.md#view-packages) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/451054)

{{< /details >}}

您可以使用极狐GitLab 软件包仓库发布和下载软件包。有时，软件包会因错误而上传失败。此前，无法快速查看上传失败的软件包。这使得全面了解组织的软件包仓库变得困难。

现在，您可以筛选软件包仓库 UI，以查看上传失败的软件包。这项改进使调查和解决您遇到的任何问题变得更加容易。

<a id="new-median-time-to-merge-metric-in-value-streams-dashboard"></a>

### 价值流仪表板新增合并时间中位数指标

<!-- categories: Value Stream Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/analytics/value_streams_dashboard.md#dashboard-metrics-and-drill-down-reports) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/435451)

{{< /details >}}

我们向价值流仪表板添加了一个新指标：合并时间中位数。在极狐GitLab 中，此指标表示合并请求创建到合并之间的中位时间。这个新指标通过识别合并请求和代码评审流程的效率和生产力来衡量 DevOps 健康状况。


<a id="design-management-features-extended-to-product-teams"></a>

### 设计管理功能扩展到产品团队

<!-- categories: Design Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/issues/design_management.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/438829)

{{< /details >}}

极狐GitLab 通过更新权限来扩展协作。现在，具有报告者角色的用户可以访问设计管理功能，使产品团队能够更直接地参与设计流程。此更改通过邀请整个组织更广泛的参与来简化工作流并加速创新。

<a id="enhanced-epic-deletion-protection"></a>

### 增强史诗删除保护

<!-- categories: Portfolio Management -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/group/epics/manage_epics.md#delete-an-epic) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/452189)

{{< /details >}}

我们更新了删除史诗时发生的情况，以更好地保护您项目的结构和数据。这一切都是为了在管理项目时为您提供更多控制权和安心感。

现在，当您删除父史诗时，我们不会自动删除其所有子记录，而是先通过解除父关系来保留它们。此更改为您提供了一种更安全的方式来管理史诗，确保意外删除不会导致丢失有价值的信息。

<a id="sort-the-roadmap-by-created-date-last-updated-date-and-title"></a>

### 按创建日期、最后更新日期和标题对路线图排序

<!-- categories: Portfolio Management -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/group/roadmap/_index.md#sort-and-filter-the-roadmap) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/460492)

{{< /details >}}

我们扩展了路线图视图中可用的史诗排序选项，为您在组织和优先排序项目时提供更大的灵活性。您现在可以按**创建日期**、**最后更新日期**和**标题**对史诗进行排序。这项增强为未来更高级的排序功能奠定了基础，帮助您更动态地管理史诗。

<a id="simplified-configuration-file-schema-for-value-streams-dashboard"></a>

### 简化价值流仪表板的配置文件架构

<!-- categories: Value Stream Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/analytics/value_streams_dashboard.md#customize-dashboard-panels) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/432185)

{{< /details >}}

您现在可以使用简化的、由架构驱动的可定制 UI 框架来自定义价值流仪表板面板。在新格式中，这些字段在显示数据和布局仪表板面板方面提供了更大的灵活性。借助新框架，管理员可以跟踪仪表板随时间的变化。此版本历史可以帮助您回滚到以前的版本，并比较仪表板版本之间的更改。

通过这种自定义，决策者可以专注于与其业务最相关的信息，而团队可以更好地组织和显示关键的 DevSecOps 指标。

<a id="guests-in-groups-can-link-issues"></a>

### 群组中的访客可以关联议题

<!-- categories: Portfolio Management -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/permissions.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/10267)

{{< /details >}}

我们将关联议题和任务所需的最低角色从报告者降低到访客，让您在保持[权限](../../user/permissions.md)的同时，更灵活地在极狐GitLab 实例中组织工作。

<a id="milestones-and-iterations-visible-on-issue-boards"></a>

### 里程碑和迭代在议题看板上可见

<!-- categories: Team Planning -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/issue_board.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/25758)

{{< /details >}}

我们改进了议题看板，为您提供更清晰的项目时间线和阶段洞察。现在，里程碑和迭代详情直接显示在议题卡片上，您可以轻松跟踪进度并随时调整团队的工作量。这项增强旨在让您的规划和执行更加高效，让您随时了解情况并提前完成计划。

<a id="api-security-testing-analyzer-updates"></a>

### API 安全测试分析器更新

<!-- categories: API Security -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/api_security_testing/_index.md) | [相关议题](https://gitlab.com/groups/gitlab-org/-/epics/13644)

{{< /details >}}

我们在 17.0 发布里程碑期间发布了以下 API 安全测试分析器更新：

- 系统环境变量现在会从 CI Runner 传递到用于某些高级场景（如请求签名）的自定义 Python 脚本。这将使实现这些场景更加容易。有关更多详细信息，请参阅[议题 457795](https://gitlab.com/gitlab-org/gitlab/-/issues/457795)。
- API 安全容器现在以非 root 用户身份运行，这提高了灵活性和合规性。有关更多详细信息，请参阅[议题 287702](https://gitlab.com/gitlab-org/gitlab/-/issues/287702)。
- 支持仅提供 TLSv1.3 密码算法的服务器，使更多客户能够采用 API 安全测试。有关更多详细信息，请参阅[议题 441470](https://gitlab.com/gitlab-org/gitlab/-/issues/441470)。
- 升级到 Alpine 3.19，解决了安全漏洞。有关更多详细信息，请参阅[议题 456572](https://gitlab.com/gitlab-org/gitlab/-/issues/456572)。

如[先前宣布](../../update/deprecations.md#secure-analyzers-major-version-update)的那样，[我们在极狐GitLab 17.0 中将 API 安全测试的主版本号提高到版本 5](https://gitlab.com/gitlab-org/gitlab/-/issues/456874)。

<a id="dependency-scanning-support-for-android"></a>

### Android 的依赖扫描支持

<!-- categories: Software Composition Analysis -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/dependency_scanning/legacy_dependency_scanning/_index.md#use-cicd-components) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/12968)

{{< /details >}}

依赖扫描用户现在可以扫描 Android 项目。要配置 Android 扫描，请使用 [CI/CD 目录组件](https://gitlab.com/explore/catalog/components/android-dependency-scanning)。[CI/CD 模板](../../user/application_security/dependency_scanning/legacy_dependency_scanning/_index.md#edit-the-gitlab-ciyml-file-manually)用户也支持 Android 扫描。

<a id="dependency-scanning-default-python-image"></a>

### 依赖扫描默认 Python 镜像

<!-- categories: Software Composition Analysis -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/dependency_scanning/legacy_dependency_scanning/_index.md#supported-languages-and-package-managers) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/441491)

{{< /details >}}

在 Python 3.9 作为默认 Python 镜像被弃用之后，Python 3.11 现在是默认镜像。

如[弃用通知](../../update/deprecations.md#deprecate-python-39-in-dependency-scanning-and-license-scanning)中所述，新默认 Python 版本的目标是 3.10。直接迁移到 Python 3.11 是为了确保 FIPS 合规性。

<a id="dast-now-supports-both-arm64-and-amd64-architectures-by-default"></a>

### DAST 现在默认支持 arm64 和 amd64 架构

<!-- categories: DAST -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/dast/_index.md) | [相关议题](https://gitlab.com/groups/gitlab-org/-/epics/13757)

{{< /details >}}

DAST 5 默认支持 arm64 和 amd64 架构。这使客户能够选择 Runner 主机架构并优化成本节约。

<a id="streamlined-sast-analyzer-coverage-for-more-languages"></a>

### 为更多语言精简 SAST 分析器覆盖范围

<!-- categories: SAST -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/application_security/sast/_index.md#supported-languages-and-frameworks) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/412060)

{{< /details >}}

极狐GitLab 静态应用安全测试（SAST）现在使用更少的[分析器](../../user/application_security/sast/analyzers.md)扫描相同的[语言](../../user/application_security/sast/_index.md#supported-languages-and-frameworks)，提供更简单、更可定制的扫描体验。

在极狐GitLab 17.0 中，我们已在[基于 Semgrep 的分析器](https://gitlab.com/gitlab-org/security-products/analyzers/semgrep)中用 [GitLab 管理的规则](../../user/application_security/sast/rules.md)替换了以下语言的特定语言分析器：

- Android
- C 和 C++
- iOS
- Kotlin
- Node.js
- PHP
- Ruby

如[宣布](../../update/deprecations.md#sast-analyzer-coverage-changing-in-gitlab-170)的那样，我们更新了 [SAST CI/CD 模板](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Jobs/SAST.gitlab-ci.yml)，以反映新的扫描覆盖范围，并移除不再使用的特定语言分析器作业。

<a id="secret-detection-now-supports-remote-rulesets-when-overriding-or-disabling-rules"></a>

### 密钥检测现在在覆盖或禁用规则时支持远程规则集

<!-- categories: Secret Detection -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/secret_detection/pipeline/configure.md#with-a-remote-ruleset) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/425251)

{{< /details >}}

我们解决了一个影响远程规则集的密钥检测错误。现在可以通过远程规则集覆盖或禁用规则。远程规则集提供了一种可扩展的方式，可以在一个地方配置规则，并应用于多个项目。

<a id="introducing-advanced-vulnerability-tracking-for-secret-detection"></a>

### 为密钥检测引入高级漏洞跟踪

<!-- categories: Secret Detection -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/secret_detection/pipeline/_index.md#duplicate-vulnerability-tracking) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/434096)

{{< /details >}}

密钥检测现在使用高级漏洞跟踪算法，以更准确地识别同一密钥因重构或无关更改而在文件内移动的情况。在以下情况下不再创建新发现：

- 泄露在文件内移动。
- 同一值的新的泄露出现在同一文件内。

否则，现有工作流（合并请求组件、流水线报告和漏洞报告）将像以前一样处理这些发现。通过确保在密钥位置移动时不报告重复漏洞，团队可以更轻松地管理泄露的密钥。

<a id="semantic-version-ranges-for-published-cicd-components"></a>

### 已发布 CI/CD 组件的语义化版本范围

<!-- categories: Pipeline Composition -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../ci/components/_index.md#semantic-versioning) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/450835)

{{< /details >}}

使用 CI/CD 目录组件时，您可能希望它自动使用最新版本。例如，您不想手动监控您使用的所有组件，并在每次有次要更新或安全补丁时手动切换到下一个版本。但是使用`~latest` 也有点风险，因为次要版本更新可能会带来不希望的行为变化，而主要版本更新发生破坏性变更的风险更高。

通过此版本，您可以选择使用 CI/CD 组件的最新主要或次要版本。例如，为组件版本指定 `2`，您将获得该主要版本的所有更新，例如 `2.1.1`、`2.1.2`、`2.2.0`，但不会获得 `3.0.0`。指定 `2.1`，您将只获得该次要版本的补丁更新，例如 `2.1.1`、`2.1.2`，但不会获得 `2.2.0`。

<a id="standardized-cicd-catalog-component-publishing-process"></a>

### 标准化 CI/CD 目录组件发布流程

<!-- categories: Pipeline Composition -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../ci/components/_index.md#publish-a-new-release) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/442066)

{{< /details >}}

我们一直在努力改进 CI/CD 组件，包括使向 CI/CD 目录发布组件的过程成为一致的体验。作为这项工作的一部分，我们已将使用 [`release` 关键字](../../ci/yaml/_index.md#release)和 `release-cli` 镜像从 CI/CD 作业发布版本设为唯一方法。发布流程的所有改进将仅适用于此方法。为避免此限制引入的破坏性变更，请确保始终使用最新版本的镜像（`release-cli:latest`）或至少使用高于 `v0.17`的版本。CI/CD 组件项目的 [UI 中的**发布**选项](../../user/project/releases/_index.md#create-a-release-in-the-releases-page)现已禁用。

<a id="always-run-after_script-commands-for-canceled-jobs"></a>

### 始终为已取消的作业运行 `after_script` 命令

<!-- categories: Continuous Integration (CI) -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/yaml/script.md#set-a-default-before_script-or-after_script-for-all-jobs) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/10158)

{{< /details >}}

[`after_script`](../../ci/yaml/_index.md#after_script) CI/CD 关键字用于在作业的主 `script` 部分之后运行其他命令。这通常用于清理作业使用的环境或其他资源。但是，如果作业被取消，`after_script` 命令不会运行。

从极狐GitLab 17.0 开始，当作业被取消时，`after_script` 命令将始终运行。要选择退出，请参阅[文档](../../ci/yaml/script.md#skip-after_script-commands-if-a-job-is-canceled)。

<a id="gitlab-runner-170"></a>

### 极狐GitLab Runner 17.0

<!-- categories: GitLab Runner Core -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](https://gitlab.cn/docs/runner/)

{{< /details >}}

我们今天还发布了极狐GitLab Runner 17.0！极狐GitLab Runner 是轻量级、高度可扩展的代理，用于运行您的 CI/CD 作业并将结果发送回极狐GitLab 实例。极狐GitLab Runner 与极狐GitLab CI/CD 协同工作，后者是极狐GitLab 中包含的开源持续集成服务。

<a id="whats-new"></a>

#### 新功能

- [在断开连接的网络环境中安装 Runner Operator 的文档](https://gitlab.com/gitlab-org/gl-openshift/gitlab-runner-operator/-/issues/123)

所有更改的列表在极狐GitLab Runner [CHANGELOG](https://gitlab.com/gitlab-org/gitlab-runner/blob/17-0-stable/CHANGELOG.md)中。
