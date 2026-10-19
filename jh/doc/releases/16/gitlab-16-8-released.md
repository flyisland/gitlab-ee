---
stage: Release Notes
group: Monthly Release
date: 2024-01-18
title: "极狐GitLab 16.8 发布说明"
description: "极狐GitLab 16.8 发布，合并请求变更视图中支持静态分析发现"
---

<!-- markdownlint-disable -->
<!-- vale off -->

2024 年 1 月 18 日，极狐GitLab 16.8 发布，包含以下特性。

<a id="primary-features"></a>

## 主要特性

<a id="static-analysis-findings-in-merge-request-changes-view"></a>

### 合并请求变更视图中的静态分析发现

<!-- categories: SAST -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/sast/_index.md#merge-request-changes-view) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/10959)

{{< /details >}}

静态分析现在支持在合并请求变更视图中显示发现。无需跳转到其他位置——所有内容都集中在一处。界面经过优化，操作更加直观。如需了解具体信息，只需打开抽屉即可。请通过链接的文档、演示视频和发布议题了解更多信息。

<a id="google-cloud-secret-manager-support"></a>

### 支持 Google Cloud 密钥管理器

<!-- categories: Secrets Management -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/secrets/gcp_secret_manager.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/11739)

{{< /details >}}

存储在 Google Cloud 密钥管理器中的密钥现在可以轻松检索，并在 CI/CD 作业中使用。我们的新集成简化了通过极狐GitLab CI/CD 与 Google Cloud 密钥管理器交互的过程，帮助您简化构建和部署流程！这只是 [GitLab 与 Google Cloud 强强联合](https://about.gitlab.com/blog/gitlab-google-partnership-s3c/)的众多方式之一！

<a id="workspaces-are-now-generally-available"></a>

### 工作区现已正式发布

<!-- categories: Workspaces -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/workspace/_index.md)

{{< /details >}}

我们很高兴地宣布，工作区现已正式发布，随时可以提升您的开发者效率！

通过创建安全、按需的远程开发环境，您可以减少管理依赖项和引导新开发者所花费的时间，专注于更快地交付价值。借助我们的平台无关方案，您可以使用现有的云基础设施来托管工作区，并确保数据私密且安全。

自极狐GitLab 16.0 引入以来，工作区在错误处理和协调方面得到了改进，支持私有项目和 SSH 连接，增加了更多配置选项，并提供了新的管理员界面。这些改进意味着工作区现在更加灵活、更具韧性，并且更易于大规模管理。

<a id="enforce-2fa-for-gitlab-administrators"></a>

### 对极狐GitLab 管理员强制实施 2FA

<!-- categories: User Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../security/two_factor_authentication.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/427549)

{{< /details >}}

您现在可以强制要求极狐GitLab 管理员在其私有化部署实例中使用双因素认证 (2FA)。对所有账号（尤其是管理员等特权账号）使用 2FA 是一种良好的安全实践。如果启用了此设置，而管理员尚未使用 2FA，则他们必须在下次登录时设置 2FA。

<a id="speed-up-your-builds-with-the-maven-dependency-proxy"></a>

### 使用 Maven 依赖代理加速构建

<!-- categories: Dependency Management, Package Registry -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/packages/package_registry/dependency_proxy/_index.md)

{{< /details >}}

典型的软件项目依赖各种依赖项，我们称之为软件包。软件包可以在内部构建和维护，也可以来自公共代码仓库。根据我们的用户调研，我们了解到大多数项目使用的公共和私有软件包各占一半。软件包安装顺序非常重要，因为使用错误的软件包版本可能会将破坏性变更和安全漏洞引入您的流水线。

现在，您可以向极狐GitLab 项目添加一个外部 Java 代码仓库。添加后，当您使用依赖代理安装软件包时，极狐GitLab 会首先在项目中查找该软件包。如果未找到，极狐GitLab 会尝试从外部代码仓库拉取该软件包。

当软件包从外部代码仓库拉取时，它会被导入到极狐GitLab 项目中。下次拉取该特定软件包时，将从极狐GitLab 而不是外部代码仓库拉取。即使外部代码仓库出现连接问题，只要依赖代理中存在该软件包，拉取仍然可以正常工作，从而使您的流水线更快、更可靠。

如果外部代码仓库中的软件包发生变化（例如，用户删除了某个版本并发布了包含不同文件的新版本），依赖代理会检测到这一变化。它会使该软件包失效，因此极狐GitLab 会拉取较新的版本。这可以确保下载正确的软件包，并有助于减少安全漏洞。

<a id="deeper-insights-into-velocity-in-the-issue-analytics-report"></a>

### 议题分析报告中更深入的速率洞察

<!-- categories: Value Stream Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/group/issues_analytics/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/233905)

{{< /details >}}

**议题分析**报告现在包含每月已关闭议题数量的信息，以便进行详细的速率分析。借助这一有价值的补充，极狐GitLab 用户现在可以深入了解与其项目相关的趋势，并改善整体周转时间以及为客户交付的价值。**议题分析**可视化包含一个条形图，显示每个月的议题数量，默认时间跨度为 13 个月。您可以从[价值流仪表板](../../user/analytics/value_streams_dashboard.md#dashboard-metrics-and-drill-down-reports)的下钻中访问此图表。

<a id="new-organization-level-devops-view-with-dora-based-industry-benchmarks"></a>

### 全新的组织级 DevOps 视图，提供基于 DORA 的行业基准

<!-- categories: Value Stream Management, DORA Metrics -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/analytics/value_streams_dashboard.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/426516)

{{< /details >}}

新增的 DORA 表现者评分面板显示了 DORA 评分（高、中或低）的细分，以便高管能够自上而下地了解组织的 DevOps 健康状况。

[四项 DORA 指标](https://about.gitlab.com/solutions/value-stream-management/dora/#overview)在极狐GitLab 中开箱即用，现在借助新的 DORA 评分，组织可以将其 DevOps 表现与[行业基准](https://dora.dev/)或同行进行比较。这种基准对比有助于高管了解自身相对于其他组织的水平，并确定最佳实践或可能落后的领域。

为帮助我们改进价值流仪表板，请在此[调查](https://gitlab.fra1.qualtrics.com/jfe/form/SV_50guMGNU2HhLeT4)中分享您的使用体验。

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

从极狐GitLab 16.8 开始，您可以在 `gitlab.rb` 文件中指定命令来为以下服务生成配置，从而避免暴露明文密码：

- GitLab Kubernetes Agent Server
- GitLab Workhorse
- GitLab Exporter

这意味着 Redis 的明文密码不再需要存储在 `gitlab.rb`中。

<a id="unified-devops-and-security"></a>

## 统一的 DevOps 与安全

<a id="smarter-approval-resets-with-patch-id-support"></a>

### 借助 `patch-id` 支持实现更智能的审批重置

<!-- categories: Code Review Workflow -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/project/merge_requests/approvals/settings.md#remove-all-approvals-when-commits-are-added-to-the-source-branch)

{{< /details >}}

为确保所有变更都经过评审和批准，通常会在向合并请求添加新提交时移除所有审批。然而，变基也会不必要地使现有审批失效，即使变基没有引入任何新变更，也要求作者重新寻求批准。

合并请求审批现在与 [`git-patch-id`](https://git-scm.com/docs/git-patch-id) 保持一致。它是一个相当稳定且相当唯一的标识符，可以更智能地决定是否重置审批。通过比较变基前后的 `patch-id`，我们可以确定是否引入了应重置审批并要求评审的新变更。

如果您对现在的重置体验有反馈，请在[议题 #435870](https://gitlab.com/gitlab-org/gitlab/-/issues/435870)中告诉我们。

<a id="view-blame-information-directly-in-the-file-page"></a>

### 直接在文件页面查看追溯信息

<!-- categories: Source Code Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/project/repository/files/git_blame.md#view-blame-for-a-file)

{{< /details >}}

在之前的极狐GitLab 版本中，查看文件追溯需要您访问另一个页面。现在您可以直接从文件页面查看文件追溯信息。

<a id="set-cpu-and-memory-usage-per-workspace"></a>

### 为每个工作区设置 CPU 和内存用量

<!-- categories: Workspaces -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/workspace/gitlab_agent_configuration.md)

{{< /details >}}

改善的开发者体验、引导和安全性正在推动更多开发转向云 IDE 和按需开发环境。然而，这些环境可能会导致基础设施成本增加。您已经可以在 [devfile](../../user/workspace/_index.md#devfile)中为每个项目配置 CPU 和内存用量。

现在，您还可以为每个工作区设置 CPU 和内存用量。通过在 GitLab agent 级别配置请求和限制，您可以防止单个开发者使用过多的云资源。

<a id="kubernetes-128-support"></a>

### 支持 Kubernetes 1.28

<!-- categories: Deployment Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/clusters/agent/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/432070)

{{< /details >}}

此版本新增对 2023 年 8 月发布的 Kubernetes 1.28 版本的全面支持。如果您将应用部署到 Kubernetes，现在可以将已连接的集群升级到最新版本，并利用其所有特性。

您可以阅读更多关于我们的 Kubernetes 支持政策和其他受支持的 Kubernetes 版本的信息。

<a id="new-customizable-permissions"></a>

### 新的可自定义权限

<!-- categories: Permissions -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/custom_roles/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/391760)

{{< /details >}}

现在有五种新能力可用于创建自定义角色：

- 管理项目访问令牌。
- 管理群组访问令牌。
- 管理群组成员。
- 归档项目的能力。
- 删除项目的能力。

将这些能力与其他已有的自定义能力一起添加到任何基础角色，即可创建自定义角色。自定义角色允许您定义细粒度的角色，仅授予用户完成工作所需的能力，并减少不必要的权限提升。

<a id="assign-a-custom-role-with-saml-sso"></a>

### 使用 SAML SSO 分配自定义角色

<!-- categories: Permissions -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/group/saml_sso/_index.md#configure-gitlab) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/417285)

{{< /details >}}

当用户通过 SAML SSO 预配时，可以为其分配一个自定义角色作为创建时的默认角色。此前，只能选择静态角色作为默认角色。这允许自动预配的用户被分配最符合最小权限原则的角色。

<a id="filter-streaming-audit-events-by-sub-groupproject-at-group-level"></a>

### 在群组级别按子群组/项目筛选流式审计事件

<!-- categories: Compliance Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../administration/compliance/audit_event_reports.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/11384)

{{< /details >}}

流式审计事件已扩展为支持在群组级别按子群组或项目进行筛选，此外还保留了对事件类型筛选的现有支持。

这一额外的筛选器将允许您将流中的事件分离出来发送到不同的目标，或排除不相关的子群组/项目，确保您的团队能够监控到最具可操作性的相关事件。

<a id="compliance-framework-management-improvements"></a>

### 合规框架管理改进

<!-- categories: Compliance Management -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/compliance/compliance_frameworks/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/11240)

{{< /details >}}

我们的合规中心正在成为了解合规状况和管理合规框架的核心目的地。我们正在将框架管理移入合规中心的新标签页，并添加更多令人兴奋的能力：

- 在**框架**标签页中以列表视图查看框架。
- 搜索和筛选以查找特定框架。
- 使用新的合规框架侧边栏探索每个框架的更多详细信息。
- 编辑您的框架以查看所有设置，包括管理名称、描述、关联项目等。
- 通过导出为 CSV 快速生成框架报告。

<a id="instance-level-audit-event-streaming-to-aws-s3"></a>

### 实例级审计事件流式传输到 AWS S3

<!-- categories: Audit Events -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../administration/compliance/audit_event_reports.md)

{{< /details >}}

此前，您只能为 AWS S3 配置顶级群组流式审计事件。

在极狐GitLab 16.8 中，我们将 AWS S3 的支持扩展到了实例级流式传输目标。

<a id="enforce-policy-to-prevent-branches-being-deleted-or-unprotected"></a>

### 强制实施策略以防止分支被删除或取消保护

<!-- categories: Security Policy Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/policies/merge_request_approval_policies.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/9705)

{{< /details >}}

扫描结果策略新增了多项设置，以协助[安全策略的合规强制执行](https://gitlab.com/groups/gitlab-org/-/epics/9704)，其中分支修改控制将限制通过更改项目级设置来规避策略的能力。

对于每个现有或新的扫描结果策略，您可以启用 `Prevent branch modification`，使其对策略中定义的分支生效，以防止用户删除或取消保护这些分支。

<a id="saml-group-sync-for-custom-roles"></a>

### 自定义角色的 SAML 群组同步

<!-- categories: Permissions -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/group/saml_sso/group_sync.md#configure-saml-group-links) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/417201)

{{< /details >}}

您现在可以使用 SAML 群组同步将自定义角色映射到用户群组。此前，您只能将 SAML 群组映射到极狐GitLab 的静态角色。这为使用 SAML 群组链接来管理群组成员关系和成员角色的客户提供了更大的灵活性。

<a id="saml-sso-authentication-for-merge-request-approval"></a>

### 用于合并请求审批的 SAML SSO 认证

<!-- categories: Code Review Workflow -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/merge_requests/approvals/settings.md#require-user-re-authentication-to-approve) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/11084)

{{< /details >}}

对于在极狐GitLab 中使用 SAML SSO 和 SCIM 进行用户账号管理的用户，您现在可以使用 SSO 来满足合并请求认证要求，而无需使用基于密码的认证来批准合并请求。

此方法可确保只有经过认证的用户才能批准合并请求，以满足安全和合规要求，而无需使用单独的基于密码的解决方案。

<a id="introduce-group-level-landing-page-for-analytics-dashboards"></a>

### 为分析仪表板引入群组级落地页

<!-- categories: Value Stream Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/analytics/value_streams_dashboard.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/433420)

{{< /details >}}

我们正在为群组级分析仪表板引入一个新的落地页。这一增强功能可确保更一致、更友好的导航体验。这些改进旨在简化您的体验，并在管理和解读数据方面提供更大的灵活性。

<a id="view-all-ancestor-items-of-a-task-or-okr"></a>

### 查看任务或 OKR 的所有祖先项

<!-- categories: Portfolio Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/tasks.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/11197)

{{< /details >}}

在此版本中，您现在可以查看工作项的整个层级谱系，而不仅仅是直接父项。

工作项包括：

- 任务，适用于所有版本。
- [目标和关键结果](../../user/okrs.md)，适用于旗舰版，且受功能标志控制。

<a id="runner-fleet-dashboard-csv-export-of-compute-minutes-used-by-instance-runners"></a>

### Runner Fleet 仪表板：导出实例 Runner 使用的计算分钟 CSV

<!-- categories: Fleet Visibility -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../ci/runners/runner_fleet_dashboard.md#export-compute-minutes-used-by-instance-runners) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/425853)

{{< /details >}}

出于各种原因，您可能需要生成一份项目在实例 Runner 上使用的 CI/CD 计算分钟报告。然而，极狐GitLab 中并没有一个简单易用的机制来让您生成 CI/CD 计算分钟使用报告。借助此功能，您可以将每个项目在共享 Runner 上使用的 CI/CD 计算分钟报告导出为 CSV 文件。

<a id="gitlab-runner-168"></a>

### 极狐GitLab Runner 16.8

<!-- categories: GitLab Runner Core -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](https://gitlab.cn/docs/runner/)

{{< /details >}}

我们今天还发布了极狐GitLab Runner 16.8！极狐GitLab Runner 是轻量级、高度可扩展的代理，用于运行您的 CI/CD 作业并将结果发送回极狐GitLab 实例。极狐GitLab Runner 与极狐GitLab CI/CD 协同工作，后者是极狐GitLab 中包含的开源持续集成服务。

<a id="whats-new"></a>

#### 新增内容

- [覆盖生成的 Kubernetes pod 规范 - 测试版](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/29659)

<a id="bug-fixes"></a>

#### 缺陷修复

- [GitLab Runner 认证令牌在 Runner 日志文件中暴露](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/37224)
- [注册多个自动扩缩 Runner 会导致 config.toml 文件不完整](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/37197)
- [中断 restore_cache 辅助任务会损坏缓存](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/36988)

所有变更的列表见极狐GitLab Runner [CHANGELOG](https://gitlab.com/gitlab-org/gitlab-runner/blob/16-8-stable/CHANGELOG.md)。

<a id="predefined-variables-for-merge-request-description"></a>

### 用于合并请求描述的预定义变量

<!-- categories: Secrets Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/variables/predefined_variables.md#predefined-variables-for-merge-request-pipelines) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/432846)

{{< /details >}}

如果您使用自动化在 CI/CD 流水线中处理合并请求，您可能希望有一种更简单的方法来获取合并请求的描述，而无需调用 API。在极狐GitLab 16.7 中，我们引入了 `CI_MERGE_REQUEST_DESCRIPTION` 预定义变量，使描述在所有作业中都能轻松访问。在极狐GitLab 16.8 中，我们调整了行为，将 `CI_MERGE_REQUEST_DESCRIPTION` 截断为 2700 个字符，因为过大的描述可能会导致 Runner 错误。您可以使用新引入的 `CI_MERGE_REQUEST_DESCRIPTION_IS_TRUNCATED` 预定义变量检查描述是否被截断，当描述被截断时该变量设置为 `true`。

<a id="windows-2022-support-for-saas-runners-on-windows"></a>

### Windows SaaS Runner 支持 Windows 2022

<!-- categories: GitLab Hosted Runners -->

{{< details >}}

- 适用版本: 基础版
- 交付方式: JihuLab.com
- 链接: [文档](../../ci/runners/hosted_runners/windows.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/438554)

{{< /details >}}

团队现在可以在 Windows Server 2022 上构建、测试和部署应用程序。

Windows 上的 SaaS Runner 允许您在与极狐GitLab CI/CD 集成的安全、按需的极狐GitLab Runner 构建环境中，提高开发团队构建和部署需要 Windows 的应用程序的速度。

立即在您的 .GitLab-ci.yml 文件中使用 `saas-windows-medium-amd64` 作为标签来试用吧。

<a id="cicd-components-catalog-section-for-your-internal-components"></a>

### 用于内部组件的 CI/CD Catalog 部分

<!-- categories: Pipeline Composition -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../ci/components/_index.md#cicd-catalog) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/437768)

{{< /details >}}

随着 CI/CD catalog 中的条目数量持续增长，您越来越难以找到团队发布并可供您使用的 CI/CD 组件。在此版本中，我们引入了专门的**您的群组**标签页，让您能够轻松筛选和识别与您的组织相关的组件。这一简化的搜索过程提高了效率，因为您可以更快速地找到并使用已发布的 CI/CD 组件。
