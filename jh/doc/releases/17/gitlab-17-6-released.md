---
stage: Release Notes
group: Monthly Release
date: 2024-11-21
title: "极狐GitLab 17.6 发布说明"
description: "极狐GitLab 17.6 发布，支持在极狐GitLab Duo Chat 中使用私有化部署模型"
---

<!-- markdownlint-disable -->
<!-- vale off -->

2024 年 11 月 21 日，极狐GitLab 17.6 正式发布，带来了以下新功能。

此外，我们要感谢所有贡献者，包括本月的杰出贡献者。

<a id="this-months-notable-contributor-joel-gerber"></a>

## 本月的杰出贡献者：Joel Gerber

每个人都可以[提名极狐GitLab 社区贡献者](https://gitlab.com/gitlab-org/developer-relations/contributor-success/team-task/-/issues/490)！为你支持的活跃候选人投票，或添加新的提名！🙌

Joel 因其对我们的 CI 组件做出的宝贵贡献、对合并请求富有洞察力的反馈以及在复杂讨论中深思熟虑的评论而获得认可。他的贡献包括 [CI/CD 目录的 UI 优化](https://gitlab.com/gitlab-org/gitlab/-/issues/464703)、极狐GitLab Terraform Provider 广受需求的文档改进、[任务日志时间戳](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/164595)以及[向 UI/UX 团队提供反馈](https://gitlab.com/gitlab-org/gitlab/-/issues/482524#note_2089551197)。

Joel 是 [HackerOne](https://www.hackerone.com/) 的一名资深软件工程师，并由极狐GitLab 贡献者成功部门资深全栈工程师 [Lee Tickett](https://gitlab.com/leetickett-gitlab) 提名，以表彰他的贡献和提供的宝贵反馈。

极狐GitLab 资深产品设计师 [Gina Doyle](https://gitlab.com/gdoyle) 补充了提名。
Gina 说：“当时内部有很多讨论，使 MR 流程变得更加复杂。”
“但 Joel 在讨论中保持坚强和活跃，并完成了贡献。”

极狐GitLab 资深产品设计师 [Sunjung Park](https://gitlab.com/sunjungp) 表示：
“Joel 还为 CI/CD 目录议题的 UI 优化做出了贡献，”
“这让我们的用户界面变得美观，并与其他区域保持一致。”

我们非常感谢 Joel 的所有贡献，也感谢所有为极狐GitLab 做出贡献的开源社区成员！

<a id="primary-features"></a>

## 主要功能

<a id="use-self-hosted-model-for-gitlab-duo-chat"></a>

### 在极狐GitLab Duo Chat 中使用私有化部署模型

{{< details >}}

- Tier: 旗舰版
- Add-ons: Duo Enterprise
- Links: [文档](../../administration/gitlab_duo_self_hosted/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/501267)

{{< /details >}}

现在，你可以在自己的基础设施中托管选定的大语言模型（LLM），并将这些模型配置为极狐GitLab Duo Chat 的来源。此功能为测试版，在私有化部署的极狐GitLab 环境中需要 旗舰版 和 Duo Enterprise 订阅才能使用。

通过私有化部署模型，你可以使用托管在本地或私有云中的模型作为极狐GitLab Duo Chat 或代码建议（在极狐GitLab 17.5 中作为测试版功能引入）的来源。对于代码建议，我们目前支持在 vLLM 或 AWS Bedrock 上运行的开源 Mistral 模型，以及 AWS Bedrock 上的国内 SOTA 大模型和 Azure OpenAI 上的 OpenAI 模型。对于 Chat，我们目前支持在 vLLM 或 AWS Bedrock 上运行的开源 Mistral 模型，以及 AWS Bedrock 上的国内 SOTA 大模型。通过启用私有化部署模型，你可以在利用生成式 AI 的强大功能的同时，保持完全的数据主权和隐私。

请在[议题 501268](https://gitlab.com/gitlab-org/gitlab/-/issues/501268) 中留下反馈。

<a id="enhanced-merge-request-reviewer-assignments"></a>

### 增强的合并请求审核人分配

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/merge_requests/reviews/_index.md#request-a-review)

{{< /details >}}

在你精心设计变更并准备好合并请求后，下一步是确定可以帮助推进它的审核人。为你的合并请求确定合适的审核人需要了解谁是合适的批准人，以及谁可能是你所提议变更的主题专家（CODEOWNER）。

现在，在分配审核人时，侧边栏会在你的合并请求的批准要求与审核人之间建立联系。查看每条批准规则，然后从能够满足该批准规则并为你推进合并请求的批准人中进行选择。如果你使用[可选的 CODEOWNERS 部分](../../user/project/codeowners/reference.md#optional-sections)，这些规则也会显示在侧边栏中，以帮助你为你的变更确定合适的主题专家。

增强的审核人分配是将智能应用于极狐GitLab 中已分配审核人的下一个演进。此迭代建立在我们从建议的审核人以及如何有效识别推进合并请求的最佳审核人中学到的经验之上。在审核人分配的[后续迭代](https://gitlab.com/groups/gitlab-org/-/epics/14808)中，我们将继续增强用于推荐和排列可能审核人的智能。

<a id="support-for-private-container-registries-in-workspaces"></a>

### 工作区中对私有容器镜像仓库的支持

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/workspace/configuration.md#configure-support-for-private-container-registries)

{{< /details >}}

极狐GitLab 工作区现在支持私有容器镜像仓库。通过此设置，你可以从你选择的任何私有镜像仓库拉取容器镜像。只要你的 Kubernetes 集群拥有有效的镜像拉取密钥，你就可以在你的[极狐GitLab 代理配置](../../user/workspace/gitlab_agent_configuration.md)中引用该密钥。

此功能简化了工作流，特别是对于使用自定义或第三方容器镜像仓库的团队，并提高了容器化开发环境的灵活性和安全性。

<a id="extension-marketplace-now-available-in-workspaces"></a>

### 扩展市场现已在工作区中可用

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/web_ide/_index.md#manage-extensions)

{{< /details >}}

扩展市场现已在工作区中可用。通过扩展市场，你可以发现、安装和管理第三方扩展，以增强你的开发体验。从数千个扩展中进行选择，以提高你的生产力或自定义你的工作流。

扩展市场默认处于禁用状态。要开始使用，请转到你的用户偏好设置并[启用扩展市场](../../user/profile/preferences.md#integrate-with-the-extension-marketplace)。对于企业用户，只有对顶级群组具有所有者角色的用户才能[为企业用户启用扩展市场](../../user/enterprise_user/_index.md#enable-the-extension-marketplace-for-enterprise-users)。

<a id="improved-workspace-lifecycle-with-delayed-termination"></a>

### 通过延迟终止改进工作区生命周期

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/workspace/_index.md#automatic-workspace-stop-and-termination)

{{< /details >}}

在此版本中，工作区在配置的超时过后会停止而不是终止。此功能意味着你可以随时重新启动你的工作区，并从中断的地方继续。

默认情况下，工作区会自动：

- 在工作区上次启动或重新启动 36 小时后停止
- 在工作区上次停止 722 小时后终止

你可以在你的[极狐GitLab 代理配置](../../user/workspace/gitlab_agent_configuration.md)中配置这些设置。

借助此功能，工作区在停止后大约一个月内仍然可用。这样，你可以在优化工作区资源的同时保留你的进度。

<a id="display-release-notes-on-deployment-details-page"></a>

### 在部署详情页显示发布说明

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../ci/environments/deployment_approvals.md#view-blocked-deployments) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/493260)

{{< /details >}}

你是否曾想过，一份要求你批准的部署里可能包含什么内容？在过去的版本中，你可以创建一个包含详细描述（关于其内容和测试说明）的发布，但相关的特定于环境的部署并没有显示这些数据。我们很高兴地宣布，极狐GitLab 现在会在相关部署详情页下显示发布说明。

因为极狐GitLab 发布总是从 Git 标签创建的，所以发布说明只显示在与标签触发的流水线相关的部署中。

此功能由 [Anton Kalmykov](https://gitlab.com/antonkalmykov) 贡献给极狐GitLab。谢谢！

<a id="admin-setting-to-enforce-cicd-job-token-allowlist"></a>

### 用于强制执行 CI/CD 任务令牌允许列表的管理员设置

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署
- Links: [文档](../../administration/settings/continuous_integration.md#access-job-token-permission-settings) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/496647)

{{< /details >}}

此前，我们宣布默认的 CI/CD 任务令牌 (`CI_JOB_TOKEN`) 行为[将在极狐GitLab 18.0 中更改](../../update/deprecations.md#cicd-job-token---authorized-groups-and-projects-allowlist-enforcement)，要求你显式地将各个[项目或群组添加到项目的任务令牌允许列表](../../ci/jobs/ci_job_token.md#add-a-group-or-project-to-the-job-token-allowlist)中，才能让它们继续访问你的项目。

现在，我们让私有化部署实例管理员有能力在实例的所有项目上强制执行这个更安全的设置。启用此设置后，所有项目如果想使用 CI/CD 任务令牌进行认证，都需要使用其允许列表。*注意：我们建议将此设置作为强有力的安全策略的一部分来启用。*

<a id="track-cicd-job-token-authentications"></a>

### 跟踪 CI/CD 任务令牌认证

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../ci/jobs/ci_job_token.md#job-token-authentication-log) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/467292)

{{< /details >}}

以前，很难跟踪哪些其他项目通过 CI/CD 任务令牌认证访问了你的项目。为了让你更容易审计和控制对项目的访问，我们添加了一个认证日志。

通过此认证日志，你可以在 UI 中和作为可下载的 CSV 文件查看使用任务令牌对你的项目进行认证的其他项目列表。此数据可用于审计项目访问权限，并辅助填充任务令牌允许列表，以便更强地[控制哪些项目可以访问你的项目](../../ci/jobs/ci_job_token.md#control-job-token-access-to-your-project)。

<a id="vulnerability-report-grouping"></a>

### 漏洞报告分组

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/vulnerability_report/_index.md#group-vulnerabilities) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/10164)

{{< /details >}}

用户需要能够以分组形式查看漏洞。这将帮助安全分析师通过利用批量操作来优化他们的分类任务。此外，用户可以看到有多少漏洞符合他们的分组；例如，有多少个 OWASP Top 10 漏洞？

<a id="model-registry-now-generally-available"></a>

### 模型仓库现已正式面向公众开放

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/ml/model_registry/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/14998)

{{< /details >}}

极狐GitLab 的模型仓库现已正式面向公众开放，它是你的集中式中心，可用来作为现有极狐GitLab 工作流的一部分管理机器学习模型。你可以跟踪模型版本、存储产物和元数据，并在模型卡中维护全面的文档。

模型仓库专为无缝集成而构建，可与 [MLflow 客户端](../../user/project/ml/experiment_tracking/mlflow_client.md)原生协作，并直接连接到你的 CI/CD 流水线，从而实现自动模型部署和测试。数据科学家可以通过直观的 UI 或现有的 MLflow 工作流管理模型，而 MLOps 团队可以利用语义版本控制和 CI/CD 集成来简化生产部署，所有这些都在[极狐GitLab API](../../api/model_registry.md) 中完成。

请随时在我们的[反馈议题](https://gitlab.com/gitlab-org/gitlab/-/issues/504458)中给我们留言，我们会给你回复！现在就开始吧，在你的极狐GitLab 实例中转到**部署 > 模型仓库**。

<a id="scale-and-deployments"></a>

## 扩展与部署

<a id="project-events-for-group-webhooks"></a>

### 群组 Webhook 的项目事件

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/integrations/webhook_events.md#project-events) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/359044)

{{< /details >}}

在此版本中，我们向群组 Webhook 添加了项目事件。当以下情况发生时，会触发项目事件：

- 在群组中创建了一个项目。
- 在群组中删除了一个项目。

这些事件仅针对[群组 Webhook](../../user/project/integrations/webhooks.md#group-webhooks) 触发。

<a id="filter-gitlab-duo-users-by-assigned-seat"></a>

### 按已分配席位筛选极狐GitLab Duo 用户

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Add-ons: GitLab Duo Pro，GitLab Duo Enterprise
- Links: [文档](../../subscriptions/subscription-add-ons.md#view-assigned-gitlab-duo-users) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/14683)

{{< /details >}}

在极狐GitLab 的先前版本中，极狐GitLab Duo 席位分配页面上显示的用户列表无法筛选，这使得查看哪些用户之前已被分配了极狐GitLab Duo 席位变得困难。现在，你可以通过 `Assigned seat = Yes` 或 `Assigned seat = No` 来筛选你的用户列表，以查看哪些用户当前被分配或未被分配极狐GitLab Duo 席位，从而轻松调整席位分配。

<a id="gitlab-duo-seat-assignment-email-update"></a>

### 极狐GitLab Duo 席位分配邮件更新

{{< details >}}

- Tier: 专业版，旗舰版
- Add-ons: Duo Pro，Duo Enterprise
- Links: [文档](../../subscriptions/subscription-add-ons.md#assign-gitlab-duo-seats) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/170507)

{{< /details >}}

私有化部署实例上的所有用户在分配给极狐GitLab Duo 席位时将收到一封电子邮件。

以前，那些被分配了 Duo Enterprise 席位或通过批量分配获得访问权限的用户不会收到通知。除非有人告诉你，或者你注意到极狐GitLab UI 中的新功能，否则你不会知道你被分配了一个席位。

要禁用此邮件，管理员可以禁用 `duo_seat_assignment_email_for_sm` 功能标志。

<a id="unified-devops-and-security"></a>

## 统一 DevOps 与安全

<a id="efficient-risk-prioritization-with-epss"></a>

### 使用 EPSS 高效地进行风险优先级排序

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../api/graphql/reference/_index.md#cveenrichmenttype) | [相关议题](https://gitlab.com/groups/gitlab-org/-/epics/11544)

{{< /details >}}

在极狐GitLab 17.6 中，我们添加了对漏洞预测评分系统（EPSS）的支持。EPSS 为每个 CVE 提供一个介于 0 到 1 之间的分数，指示该 CVE 在未来 30 天内被利用的可能性。你可以利用 EPSS 更好地确定扫描结果的优先级，并帮助评估漏洞可能对你的环境造成的潜在影响。

此数据可供组合分析用户通过 GraphQL 使用。

<a id="enable-secret-push-protection-in-your-projects-via-api"></a>

### 通过 API 在你的项目中启用密钥推送保护

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../api/projects.md)

{{< /details >}}

现在，通过编程方式启用密钥推送保护更加容易。我们更新了应用设置 REST API，允许你：

1.  在你的私有化部署实例中启用该功能，使其能够在每个项目的基础上启用。
1.  检查该功能是否已在项目上启用。
1.  为指定的项目启用该功能。

<a id="secret-push-protection-audit-events-for-applied-exclusions"></a>

### 针对已应用排除项的密钥推送保护审计事件

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/secret_detection/exclusions.md)

{{< /details >}}

现在，当应用密钥推送保护排除项时，会记录审计事件。这使得安全团队能够审计和跟踪允许推送项目的排除项列表中的密钥的任何情况。

<a id="automated-repository-x-ray"></a>

### 自动化仓库 X-Ray

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Add-ons: Duo Pro，Duo Enterprise
- Links: [文档](../../user/project/repository/code_suggestions/repository_xray.md) | [相关议题](https://gitlab.com/groups/gitlab-org/-/epics/14100)

{{< /details >}}

仓库 X-Ray 通过提供有关项目依赖项的附加上下文，来丰富极狐GitLab Duo 代码建议的代码生成请求，从而提高代码推荐的准确性和相关性。这提高了代码生成的质量。以前，仓库 X-Ray 使用你必须配置和管理的 CI 任务。

现在，当新的提交推送到项目的默认分支时，仓库 X-Ray 会自动触发一个后台任务，该任务会扫描并解析你仓库中的适用配置文件。

<a id="corporate-network-support-for-gitlab-duo"></a>

### 对极狐GitLab Duo 的企业网络支持

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../editor_extensions/language_server/_index.md#enable-proxy-authentication)

{{< /details >}}

对 GitLab Duo 插件的最新更新引入了高级代理认证。这使开发人员能够在具有严格企业防火墙的环境中无缝连接。在我们现有的 HTTP 代理支持基础上，此增强功能允许认证连接。它确保了在极狐GitLab UI 中安全且不间断地访问 Duo 功能。

此更新对于需要在受限网络环境中进行安全、认证连接的开发人员至关重要。它确保所有 Duo 功能在不影响安全性的情况下保持可用。

<a id="merge-at-a-scheduled-date-and-time"></a>

### 在计划的日期和时间合并

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/merge_requests/auto_merge.md#prevent-merge-before-a-specific-date)

{{< /details >}}

某些合并请求可能需要保留到特定日期或时间之后才能合并。当该日期和时间过去后，你需要找到具有合并权限的人，并希望他们有空为你处理此事。如果这是在非工作时间或时间线很关键，你可能需要提前很久为此任务安排人员。

现在，当你创建或编辑合并请求时，你可以指定一个`合并时间不早于`的日期。此日期将用于阻止合并请求在此之前被合并。将这项新功能与我们之前发布的[自动合并改进](https://about.gitlab.com/releases/2024/09/19/gitlab-17-4-released/#auto-merge-when-all-checks-pass)结合使用，可以让你灵活地安排合并请求在未来合并。

非常感谢 [Niklas van Schrick](https://gitlab.com/Taucher2003) 的出色贡献！

<a id="add-support-for-values-to-the-glab-agent-bootstrap-command"></a>

### 为 `glab agent bootstrap` 命令添加对 values 文件的支持

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](https://gitlab.com/gitlab-org/cli/-/blob/main/docs/source/cluster/agent/bootstrap.md#options) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/482844)

{{< /details >}}

在上一个版本中，我们向极狐GitLab CLI 工具引入了对简易代理引导的支持。极狐GitLab 17.6 通过支持自定义 Helm values 文件，进一步改进了 `glab cluster agent bootstrap` 命令。你可以使用 `--helm-release-values` 和 `--helm-release-values-from` 标志来自定义生成的 `HelmRelease` 资源。

<a id="select-a-gitlab-agent-for-an-environment-in-a-cicd-job"></a>

### 在 CI/CD 任务中为环境选择极狐GitLab 代理

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../ci/environments/kubernetes_dashboard.md#configure-a-dashboard-for-a-dynamic-environment) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/467912)

{{< /details >}}

要使用 Kubernetes 仪表板，你需要从环境设置中选择一个用于 Kubernetes 连接的代理。到目前为止，你只能从 UI 或（从极狐GitLab 17.5 起）API 中选择代理，这使得从 CI/CD 配置仪表板变得困难。在极狐GitLab 17.6 中，你可以使用 `environment.kubernetes.agent` 语法配置代理连接。
此外，[议题 500164](https://gitlab.com/gitlab-org/gitlab/-/issues/500164) 提议添加从你的 CI/CD 配置中选择命名空间和 Flux 资源的支持。

<a id="audit-events-for-privileged-actions"></a>

### 特权操作的审计事件

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../user/compliance/audit_event_types.md#groups-and-projects) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/486532)

{{< /details >}}

现在，针对与特权设置相关的管理员操作有了额外的审计事件。记录这些设置何时更改，可以通过提供审计追踪来帮助提高安全性。

<a id="new-audit-event-when-merge-requests-are-merged"></a>

### 合并请求被合并时的新审计事件

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/compliance/audit_event_types.md#compliance-management) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/442279)

{{< /details >}}

在此版本中，当合并请求被合并时，会触发一个名为 `merge_request_merged` 的新审计事件类型，该事件包含有关合并请求的关键信息，包括：

- 合并请求的标题
- 合并请求的描述或摘要
- 合并需要多少次批准
- 合并获得了多少次批准
- 哪些用户批准了合并请求
- 提交者是否批准合并请求
- 作者是否批准合并请求
- 合并的日期/时间
- 来自提交历史的 SHA 列表

<a id="disable-otp-authenticator-and-webauthn-devices-independently"></a>

### 独立禁用 OTP 认证器和 WebAuthn 设备

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/profile/account/two_factor_authentication.md#disable-two-factor-authentication) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/393419)

{{< /details >}}

现在可以单独或同时禁用 OTP 认证器和 WebAuthn 设备。以前，如果你禁用 OTP 认证器，WebAuthn 设备也会被禁用。由于两者现在独立运行，因此对这些认证方法有更精细的控制。

<a id="use-api-to-get-information-about-tokens"></a>

### 使用 API 获取有关令牌的信息

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../api/admin/token.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/443597)

{{< /details >}}
管理员可以使用新的令牌信息 API 获取个人访问令牌、部署令牌和 Feed 令牌的相关信息。与其他暴露令牌信息的 API 端点不同，此端点允许管理员检索令牌信息而无需知晓令牌类型。

感谢 [Nicholas Wittstruck](https://jihulab.com/nwittstruck) 以及西门子的其他团队成员所做的贡献！

<a id="more-information-in-sign-in-emails-from-new-locations"></a>

### 来自新位置的登录邮件包含更多信息

{{< details >}}

- Tier: 基础版、专业版、旗舰版
- Links: [Documentation](../../user/profile/notifications.md#notifications-for-unknown-sign-ins) | 相关议题

{{< /details >}}

当检测到来自新位置的登录时，极狐GitLab 可选择发送一封邮件。此前，这封邮件仅包含 IP 地址，很难与实际位置关联。现在，此邮件还包含城市和国家位置信息。

感谢 [Henry Helm](https://jihulab.com/shangsuru) 所做的贡献！

<a id="prevent-modification-of-group-protected-branches"></a>

### 阻止修改群组受保护分支

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [Documentation](../../user/application_security/policies/merge_request_approval_policies.md#approval_settings) | 相关史诗

{{< /details >}}

当合并请求批准策略配置为防止群组分支修改时，策略现在会考虑为群组配置的受保护分支。此设置可确保在群组级别受保护的分支无法取消保护。受保护的分支会限制某些操作，例如删除分支和强制推送到分支。你可以使用新的 `approval_settings.block_group_branch_modification` 属性覆盖此行为，并为特定的顶级群组声明例外，以便允许群组所有者在必要时临时修改受保护分支。

这个新的项目覆盖设置可确保群组受保护分支设置不会被修改以规避安全和合规要求，从而更稳定地执行受保护分支的规则。

<a id="top-level-group-owners-can-create-service-accounts"></a>

### 顶级群组所有者可以创建服务账号

{{< details >}}

- Tier: 专业版、旗舰版
- Links: [Documentation](../../administration/settings/account_and_limit_settings.md#allow-top-level-group-owners-to-create-service-accounts) | 相关议题

{{< /details >}}

目前，只有管理员可以在极狐GitLab 私有化部署上创建服务账号。现在，新增了一个可选设置，允许顶级群组所有者创建服务账号。这使管理员可以选择是否让范围更广的角色来创建服务账号，或者将其保留为管理员专有任务。

<a id="service-accounts-badge"></a>

### 服务账号标识

{{< details >}}

- Tier: 专业版、旗舰版
- Offering: JihuLab.com
- Links: [Documentation](../../user/profile/service_accounts.md) | 相关议题

{{< /details >}}

服务账号现在拥有专门的标识，并且可以在用户列表中轻松识别。此前，这些账号仅带有 `bot` 标识，难以将其与群组访问令牌和项目访问令牌区分开来。

<a id="deploy-your-pages-site-with-any-cicd-job"></a>

### 使用任意 CI/CD 作业部署 Pages 站点

{{< details >}}

- Tier: 基础版、专业版、旗舰版
- Offering: JihuLab.com
- Links: [Documentation](../../user/project/pages/_index.md#user-defined-job-names)

{{< /details >}}

为了让你在设计流水线时具有更大的灵活性，你不再
需要将 Pages 部署作业命名为 `pages`。现在，你可以直接在任何 CI/CD 作业中使用 `pages` 属性来触发 Pages 部署。

<a id="ai-impact-analytics-api-for-gitlab-duo-pro"></a>

### 用于极狐GitLab Duo Pro 的 AI 影响分析 API

{{< details >}}

- Tier: 专业版、旗舰版
- Offering: JihuLab.com
- Add-ons: Duo Pro, Duo Enterprise
- Links: [Documentation](../../api/graphql/reference/_index.md#aimetrics)

{{< /details >}}

极狐GitLab Duo Pro 客户现在可以通过 `aiMetrics` GraphQL API 以编程方式访问 AI 影响分析指标。这些指标包括已分配的极狐GitLab Duo 席位数量、Duo Chat 用户数量和代码建议用户数量。该 API 还提供了代码建议的显示和采纳的粒度计数。利用这些数据，你可以计算代码建议的采纳率，并更好地了解你的 Duo Pro 用户对 Duo Chat 和代码建议的采用情况。你还可以将 AI 影响分析指标与价值流分析和 DORA 指标结合使用，以更深入地了解采用 Duo Chat 和代码建议如何影响团队的生产力。

<a id="easily-remove-closed-items-from-your-view"></a>

### 轻松从视图中移除已关闭的条目

{{< details >}}

- Tier: 基础版、专业版、旗舰版
- Offering: JihuLab.com
- Links: [Documentation](../../user/group/epics/manage_epics.md) | 相关议题

{{< /details >}}

现在，你可以通过关闭 **显示已关闭条目** 开关来隐藏已关闭的条目，使其从关联条目和子条目列表中消失。通过这一新增功能，你可以更好地控制视图，专注于活跃的工作，同时减少复杂项目中的视觉杂乱。

<a id="query-user-level-gitlab-duo-enterprise-usage-metrics"></a>

### 查询用户级极狐GitLab Duo Enterprise 使用量指标

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Add-ons: Duo Enterprise
- Links: [Documentation](../../api/graphql/reference/_index.md#aiusermetrics) | 相关议题

{{< /details >}}

在此版本之前，无法获取每个 Duo Enterprise 用户的极狐GitLab Duo Chat 和代码建议使用数据。在 17.6 中，我们添加了一个 GraphQL API，以提供每个活跃 Duo Enterprise 用户已采纳代码建议数量和 Duo Chat 交互次数的可见性。该 API 可以帮助你更精细地了解谁在使用哪项 Duo Enterprise 功能以及使用频率。这是我们在极狐GitLab 内[提供更全面的 Duo Enterprise 使用数据](https://gitlab.com/groups/gitlab-org/-/epics/15026)这一目标上的首次迭代。

<a id="support-for-license-data-from-cyclonedx-sboms"></a>

### 支持来自 CycloneDX SBOM 的许可证数据

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [Documentation](../../ci/yaml/artifacts_reports.md#artifactsreportscyclonedx) | 相关议题

{{< /details >}}

许可证扫描器现在能够从包含[受支持软件包类型](../../user/compliance/license_scanning_of_cyclonedx_files/_index.md#supported-languages-and-package-managers)的 CycloneDX SBOM 中获取依赖项的许可证信息。

当 CycloneDX SBOM 的 `licenses` 字段可用时，用户将看到来自其 SBOM 的许可证数据。当 SBOM 缺少许可证信息时，我们将继续从许可证数据库提供这些数据。

<a id="macos-sequoia-15-and-xcode-16-job-image"></a>

### macOS Sequoia 15 和 Xcode 16 作业镜像

{{< details >}}

- Tier: Silver, Gold
- Offering: JihuLab.com
- Links: [Documentation](../../ci/runners/hosted_runners/macos.md) | 相关议题

{{< /details >}}

现在，你可以使用 macOS Sequoia 15 和 Xcode 16 为最新一代 Apple 设备创建、测试和部署应用程序。

极狐GitLab 的 [macOS 上的托管 Runner](../../ci/runners/hosted_runners/macos.md) 可帮助你的开发团队在与 极狐GitLab CI/CD 集成的安全、按需构建环境中更快地构建和部署 macOS 应用程序。

立即在你的 `.gitlab-ci.yml` 文件中使用 `macos-15-xcode-16` 镜像来试用。

<a id="jacoco-test-coverage-visualization-now-generally-available"></a>

### JaCoCo 测试覆盖率可视化现已正式发布

{{< details >}}

- Tier: 基础版、专业版、旗舰版
- Offering: JihuLab.com
- Links: [Documentation](../../ci/testing/code_coverage/jacoco.md) | 相关议题

{{< /details >}}

现在，你可以直接在合并请求的差异视图中查看 JaCoCo 测试覆盖率结果。此可视化可帮助你快速识别哪些行被测试覆盖，哪些行在合并前需要增加覆盖。

<a id="gitlab-runner-176"></a>

### GitLab Runner 17.6

{{< details >}}

- Tier: 基础版、专业版、旗舰版
- Links: [Documentation](https://gitlab.cn/docs/runner)

{{< /details >}}

我们今天还发布了 GitLab Runner 17.6！GitLab Runner 是一个高度可扩展的构建代理，用于运行你的 CI/CD 作业并将结果发送回 极狐GitLab 实例。GitLab Runner 与 极狐GitLab CI/CD 协同工作，后者是 极狐GitLab 中包含的开源持续集成服务。

#### Bug 修复

- 在 GitLab Runner 17.5.0 中，Pod 无法变为可附加
- 安装 fleeting 插件时 Runner 因 `exec format error` 而崩溃
- 启用了 cgroup v2 的 Kubernetes 执行器 Pod 在 OOMKilled 时挂起
- 使用配置模板注册 Runner 时 Runner 默认值未被遵守
- 使用 exec 模式时 GitLab Runner 在轮询期间等待 Kubernetes Pod 变为可附加
- 启用功能标志 `FF_GIT_URLS_WITHOUT_TOKENS` 时出现身份验证问题