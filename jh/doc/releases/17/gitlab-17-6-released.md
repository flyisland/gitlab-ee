---
stage: Release Notes
group: Monthly Release
date: 2024-11-21
title: "极狐GitLab 17.6 发布说明"
description: "极狐GitLab 17.6 发布，支持为极狐GitLab Duo Chat 使用自部署模型"
---

<!-- markdownlint-disable -->
<!-- vale off -->

2024 年 11 月 21 日，极狐GitLab 17.6 正式发布，带来了以下新功能。

<a id="primary-features"></a>

## 主要功能

<a id="use-self-hosted-model-for-gitlab-duo-chat"></a>

### 为极狐GitLab Duo Chat 使用自部署模型

<!-- categories: Self-Hosted Models -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: 私有化部署
- 附加组件: Duo Enterprise
- 链接: [文档](../../administration/gitlab_duo_self_hosted/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/501267)

{{< /details >}}

您现在可以在自己的基础设施中托管选定的大型语言模型（LLM），并将这些模型配置为极狐GitLab Duo Chat 的来源。此功能处于测试阶段，在私有化部署的极狐GitLab 环境中，需要旗舰版和 Duo Enterprise 订阅才能使用。

借助自部署模型，您可以使用托管在本地或私有云中的模型作为极狐GitLab Duo Chat 或代码建议的来源（该功能在极狐GitLab 17.5 中作为测试功能推出）。对于代码建议，我们目前支持 vLLM 或 AWS Bedrock 上的开源 Mistral 模型、AWS Bedrock 上的 Claude 3.5 Sonnet，以及 Azure OpenAI 上的 OpenAI 模型。对于 Chat，我们目前支持 vLLM 或 AWS Bedrock 上的开源 Mistral 模型，以及 AWS Bedrock 上的 Claude 3.5 Sonnet。通过启用自部署模型，您可以在保持完整数据主权和隐私的同时，充分利用生成式 AI 的能力。

请在[议题 501268](https://gitlab.com/gitlab-org/gitlab/-/issues/501268)中留下反馈。

<a id="enhanced-merge-request-reviewer-assignments"></a>

### 增强的合并请求审核人分配

<!-- categories: Code Review Workflow -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/merge_requests/reviews/_index.md#request-a-review)

{{< /details >}}

在精心完成更改并准备好合并请求后，下一步是确定能够帮助推进它的审核人。为您的合并请求确定合适的审核人，需要了解谁是合适的审批人，以及谁可能是您所提议更改的主题专家（CODEOWNER）。

现在，在分配审核人时，侧边栏会在您的合并请求审批要求与审核人之间建立关联。查看每条审批规则，然后从能够满足该审批规则并为您推进合并请求的审批人中进行选择。如果您使用[可选的 CODEOWNER 部分](../../user/project/codeowners/reference.md#optional-sections)，这些规则也会显示在侧边栏中，帮助您为更改确定合适的主题专家。

增强的审核人分配是极狐GitLab 中为分配的审核人应用智能的下一次演进。此迭代基于我们从建议的审核人中学到的经验，以及如何有效确定推进合并请求的最佳审核人。在审核人分配的[后续迭代](https://gitlab.com/groups/gitlab-org/-/epics/14808)中，我们将继续增强用于推荐和排序可能审核人的智能。

<a id="support-for-private-container-registries-in-workspaces"></a>

### 工作区支持私有容器镜像仓库

<!-- categories: Workspaces -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/workspace/configuration.md#configure-support-for-private-container-registries)

{{< /details >}}

极狐GitLab 工作区现在支持私有容器镜像仓库。通过此设置，您可以从您选择的任何私有仓库拉取容器镜像。只要您的 Kubernetes 集群拥有有效的镜像拉取密钥，您就可以在[极狐GitLab Agent 配置](../../user/workspace/gitlab_agent_configuration.md)中引用该密钥。

此功能简化了工作流，尤其是对于使用自定义或第三方容器镜像仓库的团队，并提高了容器化开发环境的灵活性和安全性。

<a id="extension-marketplace-now-available-in-workspaces"></a>

### 工作区现可使用扩展市场

<!-- categories: Workspaces -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/web_ide/_index.md#manage-extensions)

{{< /details >}}

扩展市场现已在工作区中可用。借助扩展市场，您可以发现、安装和管理第三方扩展，以增强您的开发体验。从数千个扩展中进行选择，以提高您的生产力或自定义您的工作流。

扩展市场默认处于禁用状态。要开始使用，请前往您的用户偏好设置并[启用扩展市场](../../user/profile/preferences.md#integrate-with-the-extension-marketplace)。对于企业用户，只有拥有顶级群组所有者角色的用户才能[为企业用户启用扩展市场](../../user/enterprise_user/_index.md#enable-the-extension-marketplace-for-enterprise-users)。

<a id="improved-workspace-lifecycle-with-delayed-termination"></a>

### 通过延迟终止改进工作区生命周期

<!-- categories: Workspaces -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/workspace/_index.md#automatic-workspace-stop-and-termination)

{{< /details >}}

在此版本中，工作区在配置的超时时间过后现在会停止而不是终止。此功能意味着您可以随时重新启动工作区，并从上次中断的地方继续。

默认情况下，工作区会自动：

- 在工作区上次启动或重新启动后 36 小时停止
- 在工作区上次停止后 722 小时终止

您可以在[极狐GitLab Agent 配置](../../user/workspace/gitlab_agent_configuration.md)中配置这些设置。

借助此功能，工作区在停止后大约一个月内仍然可用。这样，您可以在优化工作区资源的同时保留您的进度。

<a id="display-release-notes-on-deployment-details-page"></a>

### 在部署详情页显示发布说明

<!-- categories: Continuous Delivery -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/environments/deployment_approvals.md#view-blocked-deployments) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/493260)

{{< /details >}}

您是否曾想知道您被要求批准的部署中可能包含什么内容？在过去的版本中，您可以创建一个包含详细内容描述和测试说明的发布，但相关的环境特定部署并未显示这些数据。我们很高兴地宣布，极狐GitLab 现在会在相关部署详情页下显示发布说明。

由于极狐GitLab 发布始终从 Git 标签创建，因此发布说明仅显示在与标签触发的流水线相关的部署上。

此功能由 [Anton Kalmykov](https://gitlab.com/antonkalmykov) 贡献给 GitLab。谢谢！

<a id="admin-setting-to-enforce-cicd-job-token-allowlist"></a>

### 强制执行 CI/CD 作业令牌允许名单的管理员设置

<!-- categories: Secrets Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../administration/settings/continuous_integration.md#access-job-token-permission-settings) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/496647)

{{< /details >}}

此前，我们宣布默认的 CI/CD 作业令牌（`CI_JOB_TOKEN`）行为[将在极狐GitLab 18.0 中更改](../../update/deprecations.md#cicd-job-token---authorized-groups-and-projects-allowlist-enforcement)，如果您希望其他项目或群组继续能够访问您的项目，则需要明确地将它们[添加到您项目的作业令牌允许名单中](../../ci/jobs/ci_job_token.md#add-a-group-or-project-to-the-job-token-allowlist)。

现在，我们为私有化部署实例管理员提供了在实例的所有项目上强制执行此更安全设置的能力。启用此设置后，所有项目如果希望使用 CI/CD 作业令牌进行身份验证，都需要使用其允许名单。*注意：我们建议将此设置作为强安全策略的一部分启用。*

<a id="track-cicd-job-token-authentications"></a>

### 跟踪 CI/CD 作业令牌身份验证

<!-- categories: Secrets Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/jobs/ci_job_token.md#job-token-authentication-log) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/467292)

{{< /details >}}

此前，很难跟踪哪些其他项目正在通过 CI/CD 作业令牌进行身份验证来访问您的项目。为了让您更轻松地审计和控制对项目的访问，我们添加了身份验证日志。

借助此身份验证日志，您可以在 UI 中以及以可下载的 CSV 文件形式查看已使用作业令牌对您的项目进行身份验证的其他项目列表。此数据可用于审计项目访问，并帮助填充作业令牌允许名单，以实现对[哪些项目可以访问您的项目](../../ci/jobs/ci_job_token.md#control-job-token-access-to-your-project)的更强控制。

<a id="vulnerability-report-grouping"></a>

### 漏洞报告分组

<!-- categories: Vulnerability Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/vulnerability_report/_index.md#group-vulnerabilities) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/10164)

{{< /details >}}

用户需要能够按组查看漏洞。这将帮助安全分析师通过利用批量操作来优化其排查任务。此外，用户可以看到有多少漏洞与其分组匹配；例如，有多少 OWASP Top 10 漏洞？

<a id="model-registry-now-generally-available"></a>

### 模型仓库现已正式发布

<!-- categories: MLOps -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/ml/model_registry/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/14998)

{{< /details >}}

极狐GitLab 的模型仓库现已正式发布，它是您作为现有极狐GitLab 工作流的一部分来管理机器学习模型的集中式枢纽。您可以跟踪模型版本、存储产物和元数据，并在模型卡片中维护全面的文档。

模型仓库专为无缝集成而构建，可与 [MLflow 客户端](../../user/project/ml/experiment_tracking/mlflow_client.md)原生协作，并直接连接到您的 CI/CD 流水线，从而实现自动化的模型部署和测试。数据科学家可以通过直观的 UI 或现有的 MLflow 工作流管理模型，而 MLOps 团队可以利用语义版本控制和 CI/CD 集成来简化生产部署，所有这些都可以在[极狐GitLab API](../../api/model_registry.md)中完成。

欢迎随时在我们的[反馈议题](https://gitlab.com/gitlab-org/gitlab/-/issues/504458)中给我们留言，我们会尽快回复！立即开始使用，请前往极狐GitLab 实例中的**部署 > 模型仓库**。

<a id="new-adherence-checks-for-sast-and-dast-security-scanners"></a>

### 针对 SAST 和 DAST 安全扫描器的新合规性检查

<!-- categories: Compliance Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/compliance/compliance_center/compliance_status_report.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/12661)

{{< /details >}}

极狐GitLab 提供广泛的安全扫描器，例如 SAST、密钥检测、依赖扫描、容器扫描等，以便您可以检查应用程序是否存在安全漏洞。

您需要一种方式向审计员和相关合规机构证明您的应用程序已遵守要求您为代码仓库设置安全扫描器的监管标准。

为了帮助您证明对这些标准的遵守情况，此版本在合规中心的合规状态报告中包含了两项新检查。这些新检查会检查组内项目是否已启用 SAST 和 DAST。这些检查会确认 SAST 和 DAST 安全扫描器已在项目中正确运行，并且流水线结果包含正确的产物。

<a id="scale-and-deployments"></a>

## 规模化与部署

<a id="project-events-for-group-webhooks"></a>

### 群组 Webhook 的项目事件

<!-- categories: Notifications -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/integrations/webhook_events.md#project-events) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/359044)

{{< /details >}}

在此版本中，我们为群组 Webhook 添加了项目事件。项目事件在以下情况下触发：

- 在群组中创建项目时。
- 在群组中删除项目时。

这些事件仅针对[群组 Webhook](../../user/project/integrations/webhooks.md#group-webhooks) 触发。

<a id="filter-gitlab-duo-users-by-assigned-seat"></a>

### 按已分配席位筛选极狐GitLab Duo 用户

<!-- categories: Add-on Provisioning -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 附加组件: 极狐GitLab Duo Pro, 极狐GitLab Duo Enterprise
- 链接: [文档](../../subscriptions/subscription-add-ons.md#view-assigned-gitlab-duo-users) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/14683)

{{< /details >}}

在之前的极狐GitLab 版本中，极狐GitLab Duo 席位分配页面上显示的用户列表无法筛选，因此很难查看哪些用户之前已被分配了极狐GitLab Duo 席位。现在，您可以按“已分配席位 = 是”或“已分配席位 = 否”筛选用户列表，以查看哪些用户当前已分配或未分配极狐GitLab Duo 席位，从而轻松调整席位分配。

<a id="gitlab-duo-seat-assignment-email-update"></a>

### 极狐GitLab Duo 席位分配邮件更新

<!-- categories: Seat Cost Management -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: 私有化部署
- 附加组件: Duo Pro, Duo Enterprise
- 链接: [文档](../../subscriptions/subscription-add-ons.md#assign-gitlab-duo-seats) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/170507)

{{< /details >}}

私有化部署实例上的所有用户在分配极狐GitLab Duo 席位时都会收到一封邮件。

此前，分配了 Duo Enterprise 席位的用户或通过批量分配获得访问权限的用户不会收到通知。除非有人告诉您，或者您注意到极狐GitLab UI 中的新功能，否则您不会知道自己已被分配了席位。

要禁用此邮件，管理员可以禁用 `duo_seat_assignment_email_for_sm` 功能标志。

<a id="unified-devops-and-security"></a>

## 统一 DevOps 与安全

<a id="efficient-risk-prioritization-with-epss"></a>

### 使用 EPSS 高效确定风险优先级

<!-- categories: Software Composition Analysis -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../api/graphql/reference/_index.md#cveenrichmenttype) | [相关议题](https://gitlab.com/groups/gitlab-org/-/epics/11544)

{{< /details >}}

在极狐GitLab 17.6 中，我们添加了对漏洞利用预测评分系统（EPSS）的支持。EPSS 为每个 CVE 给出一个介于 0 到 1 之间的分数，表示该 CVE 在未来 30 天内被利用的概率。您可以利用 EPSS 更好地确定扫描结果的优先级，并帮助评估漏洞可能对您的环境产生的潜在影响。

此数据可通过 GraphQL 提供给组件分析用户。

<a id="enable-secret-push-protection-in-your-projects-via-api"></a>

### 通过 API 在项目中启用密钥推送保护

<!-- categories: Secret Detection -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../api/projects.md)

{{< /details >}}

现在可以更轻松地以编程方式启用密钥推送保护。我们更新了应用设置 REST API，允许您：

1. 在私有化部署实例中启用该功能，以便可以按项目启用。
1. 检查项目上是否已启用该功能。
1. 为指定项目启用该功能。

<a id="secret-push-protection-audit-events-for-applied-exclusions"></a>

### 针对已应用排除项的密钥推送保护审计事件

<!-- categories: Secret Detection -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/secret_detection/exclusions.md)

{{< /details >}}

现在，当应用密钥推送保护排除项时，会记录审计事件。这使安全团队能够审计和跟踪项目排除名单上的密钥被允许推送的任何情况。

<a id="automated-repository-x-ray"></a>

### 自动化代码仓库 X-Ray

<!-- categories: Code Suggestions -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 附加组件: Duo Pro, Duo Enterprise
- 链接: [文档](../../user/project/repository/code_suggestions/repository_xray.md) | [相关议题](https://gitlab.com/groups/gitlab-org/-/epics/14100)

{{< /details >}}

代码仓库 X-Ray 通过提供有关项目依赖项的额外上下文来丰富极狐GitLab Duo 代码建议的代码生成请求，从而提高代码建议的准确性和相关性。这提高了代码生成的质量。此前，代码仓库 X-Ray 使用您必须配置和管理的 CI 作业。

现在，当新提交推送到项目默认分支时，代码仓库 X-Ray 会自动触发一个后台作业，扫描并解析代码仓库中适用的配置文件。

<a id="corporate-network-support-for-gitlab-duo"></a>

### 极狐GitLab Duo 的企业网络支持

<!-- categories: Editor Extensions -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../editor_extensions/language_server/_index.md#enable-proxy-authentication) | [相关议题](https://gitlab.com/gitlab-org/editor-extensions/gitlab-lsp/-/issues/159)

{{< /details >}}

极狐GitLab Duo 插件的最新更新引入了高级代理身份验证。这使开发人员能够在具有严格企业防火墙的环境中无缝连接。基于我们现有的 HTTP 代理支持，此增强功能允许经过身份验证的连接。它确保在 VS Code 和 JetBrains IDE 中安全、不间断地访问 Duo 功能。

此更新对于需要在受限网络环境中进行安全、经过身份验证的连接的开发人员至关重要。它确保所有 Duo 功能保持可用，而不会影响安全性。

<a id="merge-at-a-scheduled-date-and-time"></a>

### 在计划的日期和时间合并

<!-- categories: Code Review Workflow -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/merge_requests/auto_merge.md#prevent-merge-before-a-specific-date)

{{< /details >}}

某些合并请求可能需要保留到特定日期或时间之后才能合并。当该日期和时间过去后，您需要找到有合并权限的人，并希望他们有空为您处理。如果这是在非工作时间或时间线很关键，您可能需要提前为这项任务做好准备。

现在，当您创建或编辑合并请求时，可以指定一个 `merge after` 日期。此日期将用于阻止合并请求在该日期过去之前被合并。将此新功能与我们之前发布的[自动合并改进](gitlab-17-4-released.md#auto-merge-when-all-checks-pass)结合使用，您可以灵活地安排合并请求在未来合并。

非常感谢 [Niklas van Schrick](https://gitlab.com/Taucher2003)的出色贡献！

<a id="add-support-for-values-to-the-glab-agent-bootstrap-command"></a>

### 为 `glab agent bootstrap` 命令添加值支持

<!-- categories: Deployment Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](https://gitlab.com/gitlab-org/cli/-/blob/main/docs/source/cluster/agent/bootstrap.md#options) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/482844)

{{< /details >}}

在上一个版本中，我们为 GitLab CLI 工具引入了便捷的 Agent 引导支持。极狐GitLab 17.6 进一步改进了 `glab cluster agent bootstrap` 命令，支持自定义 Helm 值。您可以使用 `--helm-release-values` 和 `--helm-release-values-from` 标志来自定义生成的 `HelmRelease` 资源。

<a id="select-a-gitlab-agent-for-an-environment-in-a-cicd-job"></a>

### 在 CI/CD 作业中为环境选择极狐GitLab Agent

<!-- categories: Environment Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/environments/kubernetes_dashboard.md#configure-a-dashboard-for-a-dynamic-environment) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/467912)

{{< /details >}}

要使用 Kubernetes 仪表板，您需要从环境设置中选择一个极狐GitLab Kubernetes Agent 连接。到目前为止，您只能从 UI 或（从极狐GitLab 17.5 开始）API 中选择 Agent，这使得从 CI/CD 配置仪表板变得困难。在极狐GitLab 17.6 中，您可以使用 `environment.kubernetes.agent` 语法配置 Agent 连接。此外，[议题 500164](https://gitlab.com/gitlab-org/gitlab/-/issues/500164) 提议添加对从 CI/CD 配置中选择命名空间和 Flux 资源的支持。

<a id="audit-events-for-privileged-actions"></a>

### 特权操作的审计事件

<!-- categories: Audit Events -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/compliance/audit_event_types.md#groups-and-projects) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/486532)

{{< /details >}}

现在，针对与特权设置相关的管理员操作增加了额外的审计事件。记录这些设置何时更改，可以通过提供审计事件记录来帮助提高安全性。

<a id="new-audit-event-when-merge-requests-are-merged"></a>

### 合并请求合并时的新审计事件

<!-- categories: Audit Events -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/compliance/audit_event_types.md#compliance-management) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/442279)

{{< /details >}}

在此版本中，当合并请求被合并时，会触发一个名为 `merge_request_merged`的新审计事件类型，其中包含有关合并请求的关键信息，包括：

- 合并请求的标题
- 合并请求的描述或摘要
- 合并需要多少审批
- 合并获得了多少审批
- 哪些用户批准了合并请求
- 提交者是否批准了合并请求
- 作者是否批准了合并请求
- 合并的日期/时间
- 提交历史中的 SHA 列表

<a id="disable-otp-authenticator-and-webauthn-devices-independently"></a>

### 独立禁用 OTP 身份验证器和 WebAuthn 设备

<!-- categories: System Access -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/profile/account/two_factor_authentication.md#disable-two-factor-authentication) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/393419)

{{< /details >}}

现在可以单独或同时禁用 OTP 身份验证器和 WebAuthn 设备。此前，如果您禁用了 OTP 身份验证器，WebAuthn 设备也会被禁用。由于两者现在独立运行，因此可以对这些身份验证方法进行更精细的控制。

<a id="use-api-to-get-information-about-tokens"></a>

### 使用 API 获取令牌信息

<!-- categories: System Access -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../api/admin/token.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/443597)

{{< /details >}}

管理员可以使用新的令牌信息 API 获取有关个人访问令牌、部署令牌和 Feed 令牌的信息。与其他公开令牌信息的 API 端点不同，此端点允许管理员在不知道令牌类型的情况下检索令牌信息。

感谢 [Nicholas Wittstruck](https://gitlab.com/nwittstruck) 以及西门子团队的其他成员做出的贡献！

<a id="more-information-in-sign-in-emails-from-new-locations"></a>

### 来自新位置的登录邮件中包含更多信息

<!-- categories: System Access -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/profile/notifications.md#notifications-for-unknown-sign-ins) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/296128)

{{< /details >}}

极狐GitLab 可选择在检测到来自新位置的登录时发送邮件。此前，此邮件仅包含 IP 地址，很难将其与位置关联起来。现在，此邮件还包含城市和国家/地区位置信息。

感谢 [Henry Helm](https://gitlab.com/shangsuru)的贡献！

<a id="prevent-modification-of-group-protected-branches"></a>

### 防止修改群组受保护分支

<!-- categories: Security Policy Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/policies/merge_request_approval_policies.md#approval_settings) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/13776)

{{< /details >}}

当合并请求审批策略配置为防止群组分支修改时，策略现在会考虑为群组配置的受保护分支。此设置确保在群组级别受保护的分支无法被取消保护。受保护分支会限制某些操作，例如删除分支和强制推送到分支。您可以使用新的 `approval_settings.block_group_branch_modification` 属性覆盖此行为并为特定顶级群组声明例外，以允许群组所有者在必要时临时修改受保护分支。

这个新的项目覆盖设置确保群组受保护分支设置无法被修改以规避安全和合规要求，从而确保更稳定地执行受保护分支。

<a id="top-level-group-owners-can-create-service-accounts"></a>

### 顶级群组所有者可以创建服务账号

<!-- categories: System Access -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../administration/settings/account_and_limit_settings.md#allow-top-level-group-owners-to-create-service-accounts) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/468806)

{{< /details >}}

目前，只有管理员可以在极狐GitLab 私有化部署上创建服务账号。现在，有一个可选设置允许顶级群组所有者创建服务账号。这使管理员可以选择是否允许更广泛的角色创建服务账号，或者将其保留为仅限管理员的任务。

<a id="service-accounts-badge"></a>

### 服务账号徽章

<!-- categories: System Access -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/profile/service_accounts.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/439768)

{{< /details >}}

服务账号现在拥有指定的徽章，并且可以在用户列表中轻松识别。此前，这些账号只有 `bot` 徽章，因此很难将它们与群组和项目访问令牌区分开来。

<a id="deploy-your-pages-site-with-any-cicd-job"></a>

### 使用任何 CI/CD 作业部署 Pages 站点

<!-- categories: Pages -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/pages/_index.md#user-defined-job-names)

{{< /details >}}

为了让您在设计流水线时拥有更大的灵活性，您不再需要将 Pages 部署作业命名为 `pages`。现在，您只需在任何 CI/CD 作业中使用 `pages` 属性即可触发 Pages 部署。

<a id="ai-impact-analytics-api-for-gitlab-duo-pro"></a>

### 极狐GitLab Duo Pro 的 AI 影响分析 API

<!-- categories: Value Stream Management -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 附加组件: Duo Pro, Duo Enterprise
- 链接: [文档](../../api/graphql/reference/_index.md#aimetrics)

{{< /details >}}

极狐GitLab Duo Pro 客户现在可以使用 `aiMetrics` GraphQL API 以编程方式访问 AI 影响分析指标。指标包括已分配的极狐GitLab Duo 席位数、Duo Chat 用户数和代码建议用户数。该 API 还提供已显示和已接受的代码建议的精细计数。借助这些数据，您可以计算代码建议的接受率，并更好地了解您的 Duo Pro 用户对 Duo Chat 和代码建议的采用情况。您还可以将 AI 影响分析指标与价值流分析和 DORA 指标结合使用，以更深入地了解采用 Duo Chat 和代码建议如何影响您团队的生产力。

<a id="easily-remove-closed-items-from-your-view"></a>

### 轻松从视图中移除已关闭的条目

<!-- categories: Portfolio Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/group/epics/manage_epics.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/456941)

{{< /details >}}

现在，您可以通过关闭**显示已关闭条目**开关，从关联条目和子项列表中隐藏已关闭的条目。通过此新增功能，您可以更好地控制视图，专注于进行中的工作，同时减少复杂项目中的视觉杂乱。

<a id="query-user-level-gitlab-duo-enterprise-usage-metrics"></a>

### 查询用户级极狐GitLab Duo Enterprise 使用指标

<!-- categories: Value Stream Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 附加组件: Duo Enterprise
- 链接: [文档](../../api/graphql/reference/_index.md#aiusermetrics) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/483049)

{{< /details >}}

在此版本之前，无法获取每个 Duo Enterprise 用户的极狐GitLab Duo Chat 和代码建议使用数据。在 17.6 中，我们添加了一个 GraphQL API，以提供对每个活跃 Duo Enterprise 用户已接受的代码建议数量和 Duo Chat 交互次数的可见性。该 API 可以帮助您更精细地了解谁在使用哪些 Duo Enterprise 功能以及使用频率。这是我们在极狐GitLab 中[提供更全面的 Duo Enterprise 使用数据](https://gitlab.com/groups/gitlab-org/-/epics/15026)这一目标的第一步。

<a id="support-for-license-data-from-cyclonedx-sboms"></a>

### 支持来自 CycloneDX SBOM 的许可证数据

<!-- categories: Software Composition Analysis -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/yaml/artifacts_reports.md#artifactsreportscyclonedx) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/415935)

{{< /details >}}

许可证扫描器现在能够从包含[受支持的软件包类型](../../user/compliance/license_scanning_of_cyclonedx_files/_index.md#supported-languages-and-package-managers)的 CycloneDX SBOM 中获取依赖项的许可证。

在 CycloneDX SBOM 的 `licenses` 字段可用的情况下，用户将看到来自其 SBOM 的许可证数据。在 SBOM 缺少许可证信息的情况下，我们将继续从我们的许可证数据库提供此数据。

<a id="macos-sequoia-15-and-xcode-16-job-image"></a>

### macOS Sequoia 15 和 Xcode 16 作业镜像

<!-- categories: GitLab Hosted Runners -->

{{< details >}}

- 交付方式: JihuLab.com
- 链接: [文档](../../ci/runners/hosted_runners/macos.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/502852)

{{< /details >}}

您现在可以使用 macOS Sequoia 15 和 Xcode 16 为最新一代 Apple 设备创建、测试和部署应用程序。

极狐GitLab 的 [macOS 托管 Runner](../../ci/runners/hosted_runners/macos.md) 可帮助您的开发团队在与极狐GitLab CI/CD 集成的安全、按需构建环境中更快地构建和部署 macOS 应用程序。

立即在您的 `.gitlab-ci.yml` 文件中使用 `macos-15-xcode-16` 镜像进行尝试。

<a id="jacoco-test-coverage-visualization-now-generally-available"></a>

### JaCoCo 测试覆盖率可视化现已正式发布

<!-- categories: Code Testing and Coverage -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/testing/code_coverage/jacoco.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/227345)

{{< /details >}}

您现在可以直接在合并请求差异视图中查看 JaCoCo 测试覆盖率结果。此可视化使您能够快速识别哪些行已被测试覆盖，哪些行在合并前需要额外的覆盖率。

<a id="gitlab-runner-176"></a>

### 极狐GitLab Runner 17.6

<!-- categories: GitLab Runner Core -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](https://gitlab.cn/docs/runner/)

{{< /details >}}

我们今天还发布了极狐GitLab Runner 17.6！极狐GitLab Runner 是高度可扩展的构建代理，负责运行您的 CI/CD 作业并将结果发送回极狐GitLab 实例。极狐GitLab Runner 与极狐GitLab CI/CD 协同工作，后者是极狐GitLab 中包含的开源持续集成服务。

<a id="bug-fixes"></a>

#### 缺陷修复

- [在极狐GitLab Runner 17.5.0 中，Pod 无法变为可附加状态](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/38260)
- [安装 fleeting 插件时，Runner 因 `exec format error` 崩溃](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/38247)
- [启用 cgroup v2 的 Kubernetes 执行器 Pod 在 OOMKilled 时挂起](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/38244)
- [使用配置模板注册 Runner 时，Runner 默认值未被遵循](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/38231)
- [使用 exec 模式时，极狐GitLab Runner 在轮询期间等待 Kubernetes Pod 变为可附加状态](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/37244)
- [启用功能标志 `FF_GIT_URLS_WITHOUT_TOKENS` 时出现身份验证问题](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/38268)
