---
stage: Release Notes
group: Monthly Release
date: 2024-01-18
title: "极狐GitLab 16.8 发布说明"
description: "GitLab 16.8 released with Static Analysis Findings in Merge request changes view"
---

<!-- markdownlint-disable -->
<!-- vale off -->

2024 年 1 月 18 日，极狐GitLab 16.8 发布，包含以下特性。

<a id="primary-features"></a>

## 主要特性

<a id="static-analysis-findings-in-merge-request-changes-view"></a>

### 合并请求变更视图中的静态分析发现

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/sast/_index.md#merge-request-changes-view) | [相关史诗](https://jihulab.com/groups/gitlab-cn/-/epics/10959)

{{< /details >}}

静态分析现在支持在合并请求变更视图中显示发现。无需导航到其他地方——所有内容都整合在一个地方。用户界面经过优化，体验更直观。如需了解详情，只需打开抽屉。请参阅链接的文档和演示视频了解更多信息。

<a id="google-cloud-secret-manager-support"></a>

### Google Cloud Secret Manager 支持

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../ci/secrets/gcp_secret_manager.md) | [相关史诗](https://jihulab.com/groups/gitlab-cn/-/epics/11739)

{{< /details >}}

现在，存储在 Google Cloud Secret Manager 中的密钥可以轻松检索并在 CI/CD 作业中使用。我们的新集成简化了通过极狐GitLab CI/CD 与 Google Cloud Secret Manager 交互的过程，帮助您简化构建和部署流程！这只是[极狐GitLab 和 Google Cloud 更好地协同工作](https://gitlab.cn/blog/gitlab-google-partnership-s3c/)的众多方式之一！

<a id="workspaces-are-now-generally-available"></a>

### 工作空间现已正式发布

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/workspace/_index.md)

{{< /details >}}

我们非常高兴地宣布，工作空间现已正式发布，并准备提升您的开发效率！

通过创建安全、按需的远程开发环境，您可以减少管理依赖项和引导新开发人员所花费的时间，并专注于更快地交付价值。借助我们平台无关的方法，您可以使用现有的云基础设施托管工作空间，并保持数据的私密性和安全性。

自极狐GitLab 16.0 中引入以来，工作空间在错误处理和协调、对私有项目和 SSH 连接的支持、额外的配置选项以及新的管理员界面方面都得到了改进。这些改进意味着工作空间现在更灵活、更具弹性，并且更容易大规模管理。

<a id="enforce-2fa-for-gitlab-administrators"></a>

### 对极狐GitLab 管理员强制启用双重认证

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../security/two_factor_authentication.md)

{{< /details >}}

您现在可以强制要求私有化部署实例中的极狐GitLab 管理员使用双重认证（2FA）。对所有账户使用 2FA 是一种良好的安全实践，尤其是对于管理员等特权账户。如果强制执行此设置，并且管理员尚未使用 2FA，则他们必须在下次登录时设置 2FA。

<a id="speed-up-your-builds-with-the-maven-dependency-proxy"></a>

### 使用 Maven 依赖代理加速构建

{{< details >}}

- Tier: 专业版，旗舰版
- Links: [文档](../../user/packages/package_registry/dependency_proxy/_index.md)

{{< /details >}}

典型的软件项目依赖于各种依赖项，我们称之为包。包可以在内部构建和维护，也可以来自公共仓库。根据我们的用户研究，我们了解到大多数项目使用 50/50 的公共和私有包混合。包的安装顺序非常重要，因为使用不正确的包版本可能会在流水线中引入破坏性更改和安全漏洞。

现在，您可以将一个外部 Java 仓库添加到极狐GitLab 项目中。添加后，当您使用依赖代理安装包时，极狐GitLab 首先在项目中检查该包。如果未找到，极狐GitLab 会尝试从外部仓库拉取该包。

当从外部仓库拉取包时，它会被导入到极狐GitLab 项目中。下次拉取该特定包时，它将从极狐GitLab 拉取，而不是从外部仓库拉取。即使外部仓库存在连接问题，并且该包存在于依赖代理中，拉取该包仍然有效，从而使您的流水线更快、更可靠。

如果外部仓库中的包发生更改（例如，用户删除了某个版本并发布了具有不同文件的新版本），依赖代理会检测到这一点。它会使该包失效，因此极狐GitLab 会拉取较新的包。这确保了下载正确的包，并有助于减少安全漏洞。

<a id="deeper-insights-into-velocity-in-the-issue-analytics-report"></a>

### 议题分析报告中更深入的速度洞察

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/group/issues_analytics/_index.md)

{{< /details >}}

**议题分析**报告现在包含一个月内已关闭议题数量的信息，以便进行详细的速度分析。有了这一宝贵的补充，极狐GitLab 用户现在可以深入了解与其项目相关的趋势，并改善整体周转时间以及交付给客户的价值。**议题分析**可视化包含一个条形图，显示每个月的议题数量，默认时间跨度为 13 个月。您可以从[价值流仪表盘](../../user/analytics/value_streams_dashboard.md#dashboard-metrics-and-drill-down-reports)的下钻分析中访问此图表。

<a id="new-organization-level-devops-view-with-dora-based-industry-benchmarks"></a>

### 基于 DORA 行业基准的全新组织级 DevOps 视图

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/analytics/value_streams_dashboard.md)

{{< /details >}}

我们在[价值流仪表盘](https://www.youtube.com/watch?v=EA9Sbks27g4)中添加了一个新的 **DORA 表现者分数**面板，以可视化组织在不同项目中的 DevOps 表现状态。这个新的可视化显示了 DORA 分数（高、中、低）的细分，以便高管能够自上而下地了解组织的 DevOps 健康状况。

[四个 DORA 指标](https://about.gitlab.com/solutions/value-stream-management/dora/#overview)在极狐GitLab 中开箱即用，现在借助新的 DORA 分数，组织可以将其 DevOps 表现与[行业基准](https://dora.dev/)或同行进行比较。这种基准测试有助于高管了解他们相对于其他人的位置，并确定最佳实践或可能落后的领域。

为了帮助我们改进价值流仪表盘，请在此[调查](https://gitlab.fra1.qualtrics.com/jfe/form/SV_50guMGNU2HhLeT4)中分享您的体验反馈。

<a id="scale-and-deployments"></a>

## 扩展与部署

<a id="omnibus-improvements"></a>

### Omnibus 改进

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](https://gitlab.cn/docs/omnibus)

{{< /details >}}

从极狐GitLab 16.8 开始，您可以在 `gitlab.rb` 文件中指定命令来为以下服务生成配置，以避免暴露明文密码：

- GitLab Kubernetes Agent Server
- GitLab Workhorse
- GitLab Exporter

这意味着 Redis 的明文密码不再需要存储在 `gitlab.rb` 中。

<a id="unified-devops-and-security"></a>

## 统一 DevOps 与安全

<a id="smarter-approval-resets-with-patch-id-support"></a>

### 通过 `patch-id` 支持实现更智能的审批重置

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../user/project/merge_requests/approvals/settings.md#remove-all-approvals-when-commits-are-added-to-the-source-branch)

{{< /details >}}

为了确保所有更改都经过审查和批准，当新提交添加到合并请求时，通常会移除所有审批。然而，变基操作也会不必要地使现有审批失效，即使变基没有引入任何新更改，这要求作者重新寻求审批。

合并请求审批现在与 [`git-patch-id`](https://git-scm.com/docs/git-patch-id) 对齐。它是一个相当稳定且相当唯一的标识符，可以更智能地决定是否重置审批。通过比较变基前后的 `patch-id`，我们可以确定是否引入了应重置审批并需要审查的新更改。

<a id="view-blame-information-directly-in-the-file-page"></a>

### 直接在文件页面查看 Blame 信息

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../user/project/repository/files/git_blame.md#view-blame-for-a-file)

{{< /details >}}

在极狐GitLab 的早期版本中，查看文件 Blame 需要访问不同的页面。现在，您可以直接从文件页面查看文件 Blame 信息。

<a id="set-cpu-and-memory-usage-per-workspace"></a>

### 按工作空间设置 CPU 和内存使用量

{{< details >}}

- Tier: 专业版，旗舰版
- Links: [文档](../../user/workspace/gitlab_agent_configuration.md)

{{< /details >}}

改善的开发人员体验、引导流程和安全性正在推动更多开发转向云 IDE 和按需开发环境。然而，这些环境可能会导致基础设施成本增加。您已经可以在 [devfile](../../user/workspace/_index.md#devfile) 中按项目配置 CPU 和内存使用量。

现在，您还可以按工作空间设置 CPU 和内存使用量。通过在极狐GitLab 代理级别配置请求和限制，您可以防止单个开发人员使用过多的云资源。

<a id="kubernetes-1-28-support"></a>

### Kubernetes 1.28 支持

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/clusters/agent/_index.md)

{{< /details >}}

此版本增加了对 2023 年 8 月发布的 Kubernetes 1.28 版本的全面支持。如果您将应用程序部署到 Kubernetes，现在可以将连接的集群升级到最新版本，并利用其所有特性。

您可以阅读更多关于我们的 Kubernetes 支持策略和其他受支持的 Kubernetes 版本的信息。

<a id="new-customizable-permissions"></a>

### 新的可自定义权限

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/custom_roles/_index.md)

{{< /details >}}

现在有五种新的能力可用于创建自定义角色：

- 管理项目访问令牌。
- 管理群组访问令牌。
- 管理群组成员。
- 归档项目的能力。
- 删除项目的能力。

将这些能力以及其他预先存在的自定义能力添加到任何基础角色中，即可创建自定义角色。自定义角色允许您定义细粒度的角色，仅授予用户完成工作所需的能力，并减少不必要的权限提升。

<a id="assign-a-custom-role-with-saml-sso"></a>

### 使用 SAML SSO 分配自定义角色

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/group/saml_sso/_index.md#configure-gitlab)

{{< /details >}}

当用户通过 SAML SSO 进行配置时，可以将自定义角色分配为他们创建时的默认角色。以前，只能选择静态角色作为默认角色。这使得自动配置的用户能够被分配一个最符合最小权限原则的角色。

<a id="filter-streaming-audit-events-by-sub-groupproject-at-group-level"></a>

### 在群组级别按子群组/项目过滤流式审计事件

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../administration/compliance/audit_event_reports.md) | [相关史诗](https://jihulab.com/groups/gitlab-cn/-/epics/11384)

{{< /details >}}

流式审计事件已扩展为支持在群组级别按子群组或项目进行过滤，此外还支持现有的事件类型过滤。

这个额外的过滤器将允许您将流中的事件分离出来，发送到不同的目的地，或者排除不相关的子群组/项目，确保您的团队监控到最具可操作性的审计事件。

<a id="compliance-framework-management-improvements"></a>

### 合规框架管理改进

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/compliance/compliance_frameworks/_index.md) | [相关史诗](https://jihulab.com/groups/gitlab-cn/-/epics/11240)

{{< /details >}}

我们的合规中心正在成为了解合规态势和管理合规框架的中心目的地。我们正在将框架管理移至合规中心的新选项卡中，并添加更多令人兴奋的功能：

- 在**框架**选项卡中以列表视图查看框架。
- 搜索和过滤以查找特定框架。
- 使用新的合规框架侧边栏探索每个框架的更多详细信息。
- 编辑您的框架以查看所有设置，包括管理名称、描述、关联项目等。
- 通过导出为 CSV 快速生成框架报告。

<a id="instance-level-audit-event-streaming-to-aws-s3"></a>

### 实例级审计事件流式传输到 AWS S3

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../administration/compliance/audit_event_reports.md)

{{< /details >}}

以前，您只能为 AWS S3 配置顶级群组流式审计事件。

在极狐GitLab 16.8 中，我们已将 AWS S3 的支持扩展到实例级流式传输目的地。

<a id="enforce-policy-to-prevent-branches-being-deleted-or-unprotected"></a>

### 强制执行策略以防止分支被删除或取消保护

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/policies/merge_request_approval_policies.md) | [相关史诗](https://jihulab.com/groups/gitlab-cn/-/epics/9705)

{{< /details >}}

作为添加到扫描结果策略中的几项新设置之一，旨在帮助[安全策略的合规执行](https://gitlab.com/groups/gitlab-org/-/epics/9704)，分支修改控制将限制通过更改项目级设置来规避策略的能力。

对于每个现有或新的扫描结果策略，您可以启用`防止分支修改`，使其对策略中定义的分支生效，从而防止用户删除或取消保护这些分支。

<a id="saml-group-sync-for-custom-roles"></a>

### 自定义角色的 SAML 群组同步

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/group/saml_sso/group_sync.md#configure-saml-group-links)

{{< /details >}}

您现在可以使用 SAML 群组同步将自定义角色映射到用户组。以前，您只能将 SAML 群组映射到极狐GitLab 的静态角色。这为使用 SAML 群组链接管理群组成员资格和成员角色的客户提供了更大的灵活性。

<a id="saml-sso-authentication-for-merge-request-approval"></a>

### 合并请求审批的 SAML SSO 认证

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/merge_requests/approvals/settings.md#require-user-re-authentication-to-approve) | [相关史诗](https://jihulab.com/groups/gitlab-cn/-/epics/11084)

{{< /details >}}

对于在极狐GitLab 中使用 SAML SSO 和 SCIM 进行用户账户管理的用户，您现在可以使用 SSO 来满足合并请求审批的认证要求，而不是基于密码的认证。

这种方法确保只有经过认证的用户才能审批合并请求，以满足安全和合规要求，而无需使用单独的基于密码的解决方案。

<a id="introduce-group-level-landing-page-for-analytics-dashboards"></a>

### 引入群组级分析仪表板着陆页

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/analytics/value_streams_dashboard.md)

{{< /details >}}

我们正在为群组级分析仪表板引入一个新的着陆页。这一增强功能确保了更一致和用户友好的导航体验。在第一阶段，此页面包含[价值流仪表盘](https://www.youtube.com/watch?v=8pLEucNUlWI)，但它也为未来的功能奠定了基础，允许您个性化您的仪表板。这些改进旨在简化您的体验，并在管理和解释数据方面提供更大的灵活性。

<a id="view-all-ancestor-items-of-a-task-or-okr"></a>

### 查看任务或 OKR 的所有祖先项

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/tasks.md) | [相关史诗](https://jihulab.com/groups/gitlab-cn/-/epics/11197)

{{< /details >}}

在此版本中，您现在可以查看工作项的整个层次结构谱系，而不仅仅是直接父项。

工作项包括：

- 所有层级中的任务。
- 在旗舰版中且位于特性标志后的[目标和关键结果](../../user/okrs.md)。

<a id="runner-fleet-dashboard-csv-export-of-compute-minutes-used-by-instance-runners"></a>

### Runner 集群仪表板：导出实例 Runner 使用的计算分钟 CSV 文件

{{< details >}}

- Tier: 旗舰版
- Links: [文档](../../ci/runners/runner_fleet_dashboard.md#export-compute-minutes-used-by-instance-runners)

{{< /details >}}

您可能出于各种原因需要报告项目在实例 Runner 上使用的 CI/CD 计算分钟数。然而，极狐GitLab 中没有一个简单的机制来生成 CI/CD 计算分钟使用报告。借助此功能，您可以将每个项目在共享 Runner 上使用的 CI/CD 计算分钟数导出为 CSV 文件。

<a id="gitlab-runner-16-8"></a>

### 极狐GitLab Runner 16.8

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](https://gitlab.cn/docs/runner)

{{< /details >}}

我们今天还发布了极狐GitLab Runner 16.8！极狐GitLab Runner 是轻量级、高度可扩展的代理，用于运行您的 CI/CD 作业并将结果发送回极狐GitLab 实例。极狐GitLab Runner 与极狐GitLab CI/CD 协同工作，极狐GitLab CI/CD 是极狐GitLab 附带的开源持续集成服务。

#### 新功能

- 覆盖生成的 Kubernetes Pod 规范 - Beta

#### 错误修复

- 极狐GitLab Runner 认证令牌在 Runner 日志文件中暴露
- 注册多个自动扩缩容 Runner 导致 config.toml 文件不完整
- 中断 restore_cache 辅助任务会损坏缓存

所有更改的列表在极狐GitLab Runner [CHANGELOG](https://jihulab.com/gitlab-cn/gitlab-runner/blob/16-8-stable/CHANGELOG.md) 中。

<a id="predefined-variables-for-merge-request-description"></a>

### 合并请求描述的预定义变量

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../ci/variables/predefined_variables.md#predefined-variables-for-merge-request-pipelines)

{{< /details >}}

如果您使用自动化在 CI/CD 流水线中处理合并请求，您可能希望有一种更简单的方法来获取合并请求的描述，而无需进行 API 调用。在极狐GitLab 16.7 中，我们引入了 `CI_MERGE_REQUEST_DESCRIPTION` 预定义变量，使描述在所有作业中易于访问。在极狐GitLab 16.8 中，我们调整了行为，将 `CI_MERGE_REQUEST_DESCRIPTION` 截断为 2700 个字符，因为非常大的描述可能会导致 Runner 错误。您可以使用新引入的 `CI_MERGE_REQUEST_DESCRIPTION_IS_TRUNCATED` 预定义变量检查描述是否被截断，当描述被截断时，该变量设置为 `true`。

<a id="windows-2022-support-for-saas-runners-on-windows"></a>

### Windows 上 SaaS Runner 的 Windows 2022 支持

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../ci/runners/hosted_runners/windows.md)

{{< /details >}}

团队现在可以在 Windows Server 2022 上构建、测试和部署应用程序。

Windows 上的 SaaS Runner 允许您在安全、按需的极狐GitLab Runner 构建环境中，提高开发团队构建和部署需要 Windows 的应用程序的速度，该环境与极狐GitLab CI/CD 集成。

立即试用，在您的 .GitLab-ci.yml 文件中使用 `saas-windows-medium-amd64` 作为标签。

<a id="cicd-components-catalog-section-for-your-internal-components"></a>

### 内部组件的 CI/CD 组件目录部分

{{< details >}}

- Tier: 专业版，旗舰版
- Links: [文档](../../ci/components/_index.md#cicd-catalog)

{{< /details >}}

随着 CI/CD 目录中项目数量的持续增长，您越来越难以找到由您的团队发布且可供您使用的 CI/CD 组件。在此版本中，我们引入了一个专门的**您的群组**选项卡，使您能够轻松过滤和识别与您的组织关联的组件。这种简化的搜索过程提高了效率，因为您可以更快地找到并使用已发布的 CI/CD 组件。