---
stage: Release Notes
group: Monthly Release
date: 2023-06-22
title: "极狐GitLab 16.1 发布说明"
description: "极狐GitLab 16.1 发布，带来全新的导航体验"
---

<!-- markdownlint-disable -->
<!-- vale off -->

2023 年 6 月 22 日，极狐GitLab 16.1 正式发布，带来了以下新功能。

<a id="primary-features"></a>

## 主要功能

<a id="all-new-navigation-experience"></a>

### 全新的导航体验

<!-- categories: Navigation -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../tutorials/left_sidebar/_index.md)

{{< /details >}}

极狐GitLab 16.1 带来了全新的导航体验！我们已将这一体验默认对所有用户开启。要开始使用，请转到 UI 右上角的头像，然后打开**新导航**开关。

新导航的设计旨在解决三个关键方面的反馈：在极狐GitLab 中导航可能让人不知所措、很难从上次中断的地方继续，以及无法自定义导航。

新导航包含一个精简且改进的左侧边栏，您可以：

- 固定 📌 经常访问的条目。
- 完全隐藏边栏，并将其“窥视”回视图。
- 通过新的**您的工作**和**探索**选项，轻松切换上下文、搜索和查看数据子集。
- 由于顶级菜单项更少，可以更快地浏览。

我们为新导航感到自豪，迫不及待想听听您的想法。查看[变更列表](https://gitlab.com/groups/gitlab-org/-/epics/9044#whats-different)，并阅读 GitLab 的博客文章中关于导航的[愿景](https://about.gitlab.com/blog/gitlab-product-navigation/)和[设计](https://about.gitlab.com/blog/overhauling-the-navigation-is-like-building-a-dream-home/)。

请试用新导航，并在[此议题](https://gitlab.com/gitlab-org/gitlab/-/issues/409005)中告诉我们您的体验。我们已经在[处理](https://gitlab.com/gitlab-org/gitlab/-/issues/409005#actions-we-are-taking-from-the-feedback)反馈，并最终会移除该开关。

<a id="visualize-kubernetes-resources-in-gitlab"></a>

### 在极狐GitLab 中可视化 Kubernetes 资源

<!-- categories: Deployment Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/environments/kubernetes_dashboard.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/390769)

{{< /details >}}

您如何检查集群中运行的应用程序的状态？流水线状态和环境页面提供了有关最新部署运行的洞察。然而，之前版本的极狐GitLab 缺少有关部署状态的洞察。在极狐GitLab 16.1 中，您可以查看 Kubernetes 部署中主要资源的概览。

此功能适用于每个已连接的 Kubernetes 集群。无论您是通过 CI/CD 集成还是 GitOps 部署工作负载，都没有关系。为了进一步改进面向 Flux 用户的功能，[议题 391581](https://gitlab.com/gitlab-org/gitlab/-/issues/391581)中提议支持显示环境的同步状态。

<a id="authenticate-with-service-accounts"></a>

### 使用服务账号进行身份验证

<!-- categories: System Access -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../api/groups.md) | [相关议题](https://gitlab.com/groups/gitlab-org/-/epics/6777)

{{< /details >}}

在许多使用场景中，非人类用户可能需要进行身份验证。以前，根据所需范围，用户可以使用个人、项目或群组访问令牌来满足此需求。这些令牌并不理想，因为它们要么仍然与人类绑定（对于个人访问令牌），要么具有不必要的特权角色（对于群组和项目访问令牌）。

服务账号不与人类用户绑定，并且范围更细粒度。服务账号的创建和管理仅通过 API 进行。在[议题 9965](https://gitlab.com/groups/gitlab-org/-/epics/9965)中提议支持 UI 选项。

<a id="manage-job-artifacts-through-the-artifacts-page"></a>

### 通过产物页面管理作业产物

<!-- categories: Job Artifacts -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/jobs/job_artifacts.md#view-all-job-artifacts-in-a-project)

{{< /details >}}

以前，如果您想查看或管理作业产物，必须转到每个作业的详情页面，或使用 API。现在，您可以通过**构建 > 产物**访问的**产物**页面查看和管理作业产物。

至少具有维护者角色的用户也可以使用这个新界面删除产物。您可以删除单个产物，也可以通过手动选择或勾选页面顶部的**全选**选项，一次批量删除最多 100 个产物。

请使用产物页面顶部的调查问卷，分享您对此新功能的任何反馈。要查看正在考虑的其他 UI 功能，您可以查看[构建产物页面增强史诗](https://gitlab.com/groups/gitlab-org/-/epics/8311)。

<a id="improved-cicd-variables-list-view"></a>

### 改进的 CI/CD 变量列表视图

<!-- categories: Secrets Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/variables/_index.md#define-a-cicd-variable-in-the-ui) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/410383)

{{< /details >}}

CI/CD 变量是所有流水线的关键组成部分，可以在多个位置定义，包括项目和群组设置中。为了准备进行更大的改进，帮助用户直观地在不同层级的变量之间导航，我们首先改进变量列表的可用性和布局。

在极狐GitLab 16.1 中，您将看到这些改进的第一个迭代。我们已将“类型”和“选项”列合并为一个新的**属性**列，更好地表示这些相关属性。我们感谢您对如何继续改进 CI/CD 变量体验的反馈，欢迎在我们的[变量改进史诗](https://gitlab.com/groups/gitlab-org/-/epics/10506)中发表评论。

<a id="scale-and-deployments"></a>

## 规模和部署

<a id="gitlab-chart-improvements"></a>

### GitLab chart 改进

<!-- categories: Cloud Native Installation -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](https://gitlab.cn/docs/charts/)

{{< /details >}}

- 极狐GitLab 16.1 将 `busybox` Docker 镜像替换为 `gitlab-base` Docker 镜像，以便与其他极狐GitLab Docker 镜像共享层。此实现将 `gitlab-base` 视为辅助镜像（如 `kubectl` 和 `certificates`），
并支持可选的本地覆盖。

<a id="omnibus-improvements"></a>

### Omnibus 改进

<!-- categories: Omnibus Package -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](https://gitlab.cn/docs/omnibus/)

{{< /details >}}

- 极狐GitLab 16.1 增加了在
[Debian 12 `Bookworm`](https://www.debian.org/releases/bookworm/) 上构建和发布软件包的支持，该版本于 2023 年 6 月 10 日发布。

<a id="improved-domain-verification"></a>

### 改进的域名验证

<!-- categories: User Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/enterprise_user/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/375492)

{{< /details >}}

域名验证在极狐GitLab 中有多种用途。以前，为了验证域名，您必须完成 [GitLab Pages](../../user/project/pages/_index.md) 向导，即使您验证域名的目的与 GitLab Pages 无关。

现在，域名验证位于群组级别，并且已经过精简。这使得验证您的域名更加容易。

<a id="view-vulnerability-report-as-customizable-permission"></a>

### 将漏洞报告查看作为可自定义权限

<!-- categories: System Access -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/permissions.md) | [相关议题](https://gitlab.com/groups/gitlab-org/-/epics/10160)

{{< /details >}}

查看漏洞报告的能力现在被拆分为一个单独的权限，使极狐GitLab 管理员和群组所有者能够创建具有此权限的自定义角色。以前，查看漏洞报告仅限于开发者角色及以上。现在，任何用户都可以查看漏洞报告，只要他们被分配了具有该权限的自定义角色。

<a id="password-reset-email-sent-to-any-verified-email-address"></a>

### 密码重置邮件发送到任何已验证的电子邮件地址

<!-- categories: User Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/profile/user_passwords.md#change-your-password) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/16311)

{{< /details >}}

如果您忘记了极狐GitLab 密码，现在可以使用任何已验证的电子邮件地址通过电子邮件重置密码。以前，重置请求只使用主电子邮件地址。如果主电子邮件收件箱无法访问，这会使得完成密码重置过程变得困难。

<a id="scim-identities-included-in-users-api-response"></a>

### 用户 API 响应中包含 SCIM 身份

<!-- categories: System Access, Source Code Management -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../api/users.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/324247)

{{< /details >}}

用户 API 现在会返回用户的 SCIM 身份。以前，此信息包含在 UI 中，但不包含在 API 中。

<a id="reintroduction-of-omniauth-shibboleth-support"></a>

### 重新引入 OmniAuth Shibboleth 支持

<!-- categories: System Access -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../integration/shibboleth.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/393065)

{{< /details >}}

Shibboleth OmniAuth 支持已重新引入极狐GitLab。它之前在极狐GitLab 15.9 中因缺乏上游支持而被[移除](https://gitlab.com/gitlab-org/gitlab/-/issues/388959)。感谢 [lukaskoenen](https://gitlab.com/lukaskoenen)的慷慨社区贡献，他承担了上游支持工作，现在私有化部署的极狐GitLab 中支持 `omniauth-shibboleth-redux`。

<a id="select-administrator-access-for-personal-access-tokens-in-admin-mode"></a>

### 在管理员模式下为个人访问令牌选择管理员访问权限

<!-- categories: System Access -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../security/tokens/access_token_scopes.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/42692)

{{< /details >}}

极狐GitLab 管理员可以使用管理员模式以非管理员用户身份工作，并在需要时开启管理员访问权限。以前，管理员的个人访问令牌 (PAT) 始终具有以管理员身份执行 API 操作的权限。现在，在添加 PAT 时，管理员可以通过选择管理员模式范围来决定该 PAT 是否具有执行 API 操作的管理员访问权限。管理员必须为实例启用管理员模式才能使用此功能。

感谢 [Jonas Wälter](https://gitlab.com/wwwjon)、[Diego Louzán](https://gitlab.com/dlouzan) 和 [Andreas Deicha](https://gitlab.com/TrueKalix)的贡献！

<a id="prevent-user-from-deleting-account"></a>

### 阻止用户删除账号

<!-- categories: User Management -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../administration/settings/account_and_limit_settings.md#prevent-users-from-deleting-their-accounts) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/26053)

{{< /details >}}

管理员可以通过新的用户限制配置设置来阻止用户删除其账号。如果启用此设置，用户将无法再删除其账号，从而保留可审计的账号信息。

<a id="personal-access-token-last_used-value-updated-more-frequently"></a>

### 个人访问令牌 `last_used` 值更新更频繁

<!-- categories: System Access -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/profile/personal_access_tokens.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/410168)

{{< /details >}}

个人访问令牌 (PAT) 的 `last_used` 值以前每 24 小时更新一次。现在每 10 分钟更新一次。这提高了 PAT 使用情况的可见性，并且在 PAT 泄露的情况下降低了风险，因为发现恶意活动所需的时间更短。

感谢 [Jacob Torrey](https://thinkst.com/)的贡献！

<a id="more-detail-in-completed-github-project-import-summary"></a>

### 已完成的 GitHub 项目导入摘要中包含更多详细信息

<!-- categories: Importers -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/import/github.md#check-status-of-imports) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/386748)

{{< /details >}}

当 GitHub 项目完成导入时，极狐GitLab 会显示已导入实体的简单摘要。然而，极狐GitLab 没有显示具体哪些 GitHub 实体导入失败，也没有显示导致导入失败的错误。这使得难以判断导入结果是否令人满意。

在此版本中，我们扩展了导入摘要，以包含未导入的 GitHub 实体列表，并在可能的情况下提供指向 GitHub 上这些实体的直接链接。极狐GitLab 现在还会显示每个失败的错误。这有助于您了解导入的效果并帮助您排查问题。

<a id="show-external-user-as-a-comment-author-in-service-desk-issues"></a>

### 在服务台议题中将外部用户显示为评论作者

<!-- categories: Service Desk -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/project/service_desk/_index.md)

{{< /details >}}

当请求者回复服务台电子邮件时，知道是谁发表了评论有助于服务台坐席处理工单。但由于请求者可能是没有极狐GitLab 账号或无法访问极狐GitLab 项目的外部用户，这些评论以前被归因于 GitLab Support Bot。从现在开始，来自请求者的电子邮件回复将归因于外部用户，从而更清楚地表明是谁在极狐GitLab 议题中发表了评论。

<a id="issue-url-placeholder-in-service-desk-emails"></a>

### 服务台电子邮件中的议题 URL 占位符

<!-- categories: Service Desk -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/project/service_desk/_index.md)

{{< /details >}}

对于服务台请求者来说，直接访问服务台议题，而不是仅通过电子邮件与服务台请求交互，可能会很有帮助。我们引入了一个新的占位符 `%{ISSUE_URL}`，您可以在电子邮件模板（例如“感谢”电子邮件）中使用它，将请求者直接链接到服务台议题。

<a id="backup-adds-the-ability-to-skip-projects"></a>

### 备份增加了跳过项目的能力

<!-- categories: Backup/Restore of GitLab instances -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/18287)

{{< /details >}}

内置的备份和恢复工具增加了跳过特定代码仓库的能力。Rake 任务现在通过新的 `SKIP_REPOSITORIES_PATHS` 环境变量接受一个以逗号分隔的群组或项目路径列表，以便在备份或恢复期间跳过。这将允许您跳过例如不随时间变化的陈旧或已归档项目，从而通过加快备份运行节省时间，并通过不在备份文件中包含这些数据节省空间。
感谢 [Yuri Konotopov](https://gitlab.com/nE0sIghT)的这项[社区贡献](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/121865)！

<a id="geo-adds-filtering-by-replication-status-to-all-components"></a>

### Geo 为所有组件添加按复制状态筛选

<!-- categories: Geo Replication, Disaster Recovery -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../administration/geo/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/411981)

{{< /details >}}

Geo 为[自助服务框架](../../development/geo/framework.md)管理的所有组件添加了按复制状态筛选的功能。现在，您可以按“进行中”、“失败”和“已同步”状态筛选复制详情视图中的条目，从而更轻松、更快速地定位同步失败的数据。

<a id="geo-verifies-design-repositories"></a>

### Geo 验证设计代码仓库

<!-- categories: Geo Replication, Disaster Recovery -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../administration/geo/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/355660)

{{< /details >}}

当您向议题添加设计时，会创建或更新一个设计 Git 代码仓库，并创建一个 LFS 对象和一个上传（用于缩略图）。Geo 已经验证 LFS 对象和上传，现在它也验证设计代码仓库。[设计管理](../../user/project/issues/design_management.md)的所有底层数据现在都经过验证，确保您的设计数据在传输或静态存储时不会损坏。如果将 Geo 用作灾难恢复策略的一部分，这可以保护您免受数据丢失。

<a id="unified-devops-and-security"></a>

## 统一的 DevOps 和安全

<a id="comment-on-whole-file-in-merge-requests"></a>

### 在合并请求中对整个文件发表评论

<!-- categories: Code Review Workflow -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/project/merge_requests/changes.md#add-a-comment-to-a-merge-request-file)

{{< /details >}}

合并请求现在支持对整个文件发表评论，因为并非所有合并请求反馈都是针对特定行的。如果文件被删除，您可能想了解更多关于原因的信息。您可能还想提供关于文件名的反馈，或关于结构的总体评论。

<a id="create-a-changelog-from-the-gitlab-cli"></a>

### 从 GitLab CLI 创建变更日志

<!-- categories: GitLab CLI -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/project/changelogs.md#from-the-gitlab-cli)

{{< /details >}}

变更日志根据项目的提交生成全面的变更列表。它们可能难以自动化或查看，并且需要与极狐GitLab API 交互。

随着 [GitLab CLI v1.30.0](https://gitlab.com/gitlab-org/cli/-/releases/v1.30.0)的发布，您现在可以直接从 shell 为项目生成变更日志。`glab changelog generate` 命令使审阅、自动化和发布变更日志更加容易。

感谢 [Michael Mead](https://gitlab.com/michael-mead)的贡献！

<a id="fail-closed-for-invalid-security-policy-approval-checks"></a>

### 对无效的安全策略审批检查执行故障关闭

<!-- categories: Security Policy Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/merge_requests/approvals/_index.md#invalid-rules) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/389905)

{{< /details >}}

安全和合规策略允许组织跨多个项目强制执行检查和平衡，以与其安全和治理计划保持一致。对于我们的客户来说，确保影响策略的变更不会导致防护措施失效至关重要。通过此更新，无效规则将“故障关闭”，阻止合并请求，直到任何扫描结果策略中的无效规则得到处理。

<a id="install-npm-packages-from-your-group-or-subgroup"></a>

### 从您的群组或子群组安装 npm 软件包

<!-- categories: Package Registry -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/packages/npm_registry/_index.md#install-from-a-group) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/299834)

{{< /details >}}

您可以使用项目的软件包仓库来发布和安装 npm 软件包。您只需使用访问令牌（个人、作业、部署或项目）进行身份验证，然后开始将软件包发布到您的极狐GitLab 项目。

如果您只有少量项目，这非常有效。遗憾的是，如果您有多个项目，您可能会很快发现自己添加了数十甚至数百个不同的源。大型组织中的团队通常会将软件包与源代码和流水线一起发布到其项目的软件包仓库。同时，他们需要能够轻松地从其组织中的群组和子群组内的其他项目安装依赖项。

为了更轻松地在项目之间共享软件包，您现在可以从群组安装软件包，这样就不必记住哪个软件包位于哪个项目中。使用您选择的身份验证令牌，在将群组添加为 npm 软件包的源后，您可以安装任何群组 npm 软件包。

<a id="add-a-description-to-design-uploads"></a>

### 为设计上传添加描述

<!-- categories: Portfolio Management, Design Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/issues/design_management.md#add-a-design-to-an-issue) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/9694)

{{< /details >}}

目前，[设计上传](../../user/project/issues/design_management.md#add-a-design-to-an-issue)没有元数据来解释其用途或上传原因。我们添加了一个文本框作为描述，以便您帮助用户更好地理解图像。

<a id="configure-the-static-file-directory-in-gitlab-pages"></a>

### 在 GitLab Pages 中配置静态文件目录

<!-- categories: Pages -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/pages/introduction.md#customize-the-default-folder) | [相关议题](https://gitlab.com/groups/gitlab-org/-/epics/10126)

{{< /details >}}

您现在可以将 GitLab Pages 的静态文件目录配置为任何名称（默认为 `public`）。这使得将 Pages 与流行的静态站点框架（如 Next.js、Astro 或 Eleventy）一起使用更加容易，而无需更改其配置中的输出文件夹。

<a id="code-quality-analyzer-updates"></a>

### 代码质量分析器更新

<!-- categories: Code Quality -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../ci/testing/code_quality.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/412459)

{{< /details >}}

极狐GitLab 代码质量支持[集成您已经运行的工具](../../ci/testing/code_quality.md)，还提供[一个 CI/CD 模板](../../ci/testing/code_quality.md)来运行 CodeClimate 扫描系统。在 16.1 发布里程碑期间，我们发布了以下针对基于 CodeClimate 的分析器的更新：

- 将 CodeClimate 更新到 0.96.0 版本。此版本包括：
  - 一个用于 `golangci-lint`的新插件。
  - `bundler-audit` 插件的一个新的可用版本。
- 增加了对 Docker API Socket 可配置路径的支持。
  - 感谢 [`@tsjnsn`](https://gitlab.com/tsjnsn)的这项[社区贡献](https://gitlab.com/gitlab-org/ci-cd/codequality/-/merge_requests/73)。在 CI/CD 模板中包含此变量的更新在[一个议题](https://gitlab.com/gitlab-org/gitlab/-/issues/409738)中跟踪。

有关更多详细信息，请参阅 [CHANGELOG](https://gitlab.com/gitlab-org/ci-cd/codequality/-/blob/master/CHANGELOG.md?ref_type=heads#anchor-0960)。

如果您[包含极狐GitLab 管理的代码质量模板](../../ci/testing/code_quality.md)（[`Code-Quality.gitlab-ci.yml`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Jobs/Code-Quality.gitlab-ci.yml)），您将自动收到这些更新。

有关之前版本中的代码质量变更，请参阅[最近的更新](https://about.gitlab.com/releases/2023/04/22/gitlab-15-11-released/#static-analysis-analyzer-updates)。

<a id="sast-analyzer-updates"></a>

### SAST 分析器更新

<!-- categories: SAST -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/application_security/sast/analyzers.md) | [相关议题](../../user/application_security/_index.md)

{{< /details >}}

极狐GitLab SAST 包含[许多安全分析器](../../user/application_security/sast/_index.md#supported-languages-and-frameworks)，由 GitLab 静态分析团队积极维护、更新和支持。在 16.1 发布里程碑期间，我们发布了以下更新：

- 基于 Semgrep 的分析器已更新为使用 1.23.0 版本的 Semgrep 引擎。对于用于扫描 C、C#、Go 和 Java 的极狐GitLab 管理规则，我们还[明确了指导说明并提高了有效性](https://gitlab.cn/docs/#clearer-guidance-and-better-coverage-for-sast-rules)。有关更多详细信息，请参阅 [CHANGELOG](https://gitlab.com/gitlab-org/security-products/analyzers/semgrep/-/blob/main/CHANGELOG.md#v434)。
- 基于 SpotBugs 的分析器现在支持通过[设置 `SAST_SCANNER_ALLOWED_CLI_OPTS` CI/CD 变量](../../user/application_security/sast/_index.md#security-scanner-configuration)来更改“工作级别”。这允许您通过降低扫描的精度及其检测漏洞的能力来提高性能。有关更多详细信息，请参阅 [CHANGELOG](https://gitlab.com/gitlab-org/security-products/analyzers/spotbugs/-/blob/master/CHANGELOG.md#v420)。

如果您[包含极狐GitLab 管理的 SAST 模板](../../user/application_security/sast/_index.md)（[`SAST.gitlab-ci.yml`](https://gitlab.com/gitlab-org/gitlab/blob/master/lib/gitlab/ci/templates/Security/SAST.gitlab-ci.yml)）并运行极狐GitLab 16.0 或更高版本，您将自动收到这些更新。要保留任何分析器的特定版本并防止自动更新，您可以[固定其版本](../../user/application_security/sast/_index.md)。

有关之前的变更，请参阅[上个月的更新](gitlab-16-0-released.md#sast-analyzer-updates)。

<a id="automatic-response-to-leaked-google-cloud-secrets"></a>

### 对泄露的 Google Cloud 密钥自动响应

<!-- categories: Secret Detection -->

{{< details >}}

- 链接: [文档](../../user/application_security/secret_detection/automatic_response.md) | [相关议题](https://gitlab.com/groups/gitlab-org/-/epics/8835)

{{< /details >}}

我们已将密钥检测与 Google Cloud 集成，以更好地保护使用极狐GitLab 在 Google Cloud 上开发应用程序的客户。现在，如果组织将 Google Cloud 凭证泄露到 JihuLab.com 上的公共项目，极狐GitLab 可以通过与 Google Cloud 合作来保护账号，从而自动保护该组织。

密钥检测会搜索 Google Cloud 签发的三种类型的密钥：

- [服务账号密钥](https://docs.cloud.google.com/iam/docs/best-practices-for-managing-service-account-keys)
- [API 密钥](https://docs.cloud.google.com/docs/authentication/api-keys)
- [OAuth 客户端密钥](https://support.google.com/cloud/answer/6158849#rotate-client-secret)

公开泄露的密钥在被发现后会发送到 Google Cloud。Google Cloud 会验证泄露情况，然后努力保护客户账号免受滥用。

对于在 JihuLab.com 上[启用了密钥检测](../../user/application_security/secret_detection/_index.md)的项目，此集成默认开启。密钥检测扫描在所有极狐GitLab 版本中可用，但对泄露密钥的自动响应目前仅在旗舰版项目中可用。

有关更多详细信息，请参阅[关于此集成的博客文章](https://about.gitlab.com/blog/how-secret-detection-can-proactively-revoke-leaked-credentials/)。

<a id="clearer-guidance-and-better-coverage-for-sast-rules"></a>

### 更清晰的指导和更好的 SAST 规则覆盖

<!-- categories: SAST -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/application_security/sast/analyzers.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/382119)

{{< /details >}}

我们更新了极狐GitLab SAST 规则，以：

- 更清楚地解释每条规则针对的弱点类型以及如何修复它。到目前为止，我们已经更新了 C、C#、Go 和 Java 规则的描述和指导文本。其余语言在[议题 382119](https://gitlab.com/gitlab-org/gitlab/-/issues/382119)中跟踪。
- 在现有 Java 规则中捕获更多漏洞。

这些改进是 GitLab 静态分析和漏洞研究团队之间合作的一部分，旨在[改进默认的静态分析规则集](https://gitlab.com/groups/gitlab-org/-/epics/8170)。我们欢迎在[史诗 8170](https://gitlab.com/groups/gitlab-org/-/epics/8170)中对 SAST、密钥检测和 IaC 扫描的默认规则提出任何反馈。

有关极狐GitLab SAST 规则变更的更多详细信息，请参阅 [CHANGELOG](https://gitlab.com/gitlab-org/security-products/sast-rules/-/blob/main/CHANGELOG.md)。
从极狐GitLab 16.1 开始，[`sast-rules` 项目](https://gitlab.com/gitlab-org/security-products/sast-rules)是基于 Semgrep 的 SAST 分析器中使用的所有极狐GitLab 管理默认规则的唯一来源。

<a id="shared-ruleset-customizations-in-sast-iac-scanning-and-secret-detection"></a>

### SAST、IaC 扫描和密钥检测中的共享规则集自定义

<!-- categories: SAST, Secret Detection -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/application_security/sast/customize_rulesets.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/362958)

{{< /details >}}

您现在可以设置一个 CI/CD 变量，以在多个项目之间共享 [SAST](../../user/application_security/sast/customize_rulesets.md)、[IaC 扫描](../../user/application_security/iac_scanning/_index.md)或[密钥检测](../../user/application_security/secret_detection/pipeline/_index.md)的规则集自定义。

共享规则集可以帮助您：

- [禁用预定义规则](../../user/application_security/sast/customize_rulesets.md)，这些规则是您不想在项目中关注的。
- [更改预定义规则中的字段](../../user/application_security/sast/customize_rulesets.md)，包括描述、消息、名称或严重性，以反映组织偏好。例如，您可以调整规则的默认严重性，或添加有关如何修复发现的信息。
- 通过添加或替换规则来[构建自定义规则集](../../user/application_security/sast/customize_rulesets.md)。此选项仅适用于某些分析器。

此领域的进一步改进在[一个议题](https://gitlab.com/gitlab-org/gitlab/-/issues/257928)中讨论。

<a id="cicd-use-needs-in-rules"></a>

### CI/CD：在 `rules`中使用 `needs`

<!-- categories: Pipeline Composition -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../ci/yaml/_index.md#rulesneeds) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/31581)

{{< /details >}}

[needs:](../../ci/yaml/_index.md#needs) 关键字定义了作业之间的依赖关系，您可以使用它来设置作业按阶段顺序之外运行。在此版本中，我们增加了为特定 `rules` 条件定义此关系的能力。当条件匹配规则时，作业的 `needs` 配置将完全替换为规则中的 `needs`。当作业可以比正常情况更早开始时，这可以帮助根据您定义的条件加速流水线。您还可以使用它来强制作业等待较早的作业完成后再开始，您现在拥有更灵活的 `needs` 选项！

<a id="beautify-the-ui-of-cicd-pipelines-and-jobs"></a>

### 美化 CI/CD 流水线和作业的 UI

<!-- categories: Continuous Integration (CI) -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/pipelines/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/394768)

{{< /details >}}

极狐GitLab 最常用的功能之一是 CI/CD。在 16.1 中，我们专注于改进 CI/CD 流水线和作业列表视图以及流水线详情页面的可用性和体验。现在更容易找到您要查找的信息！如果您对变更有任何意见，我们很乐意在我们的[反馈议题](https://gitlab.com/gitlab-org/gitlab/-/issues/414756)中听到您的想法。

<a id="increased-storage-for-gitlab-saas-runners-on-linux"></a>

### 增加 Linux 上 JihuLab.com SaaS runner 的存储空间

<!-- categories: GitLab Hosted Runners -->

{{< details >}}

- 交付方式: JihuLab.com
- 链接: [文档](../../ci/runners/hosted_runners/linux.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/384223)

{{< /details >}}

在最近将我们的 [Linux 上的 JihuLab.com SaaS runner](../../ci/runners/hosted_runners/linux.md)的 vCPU 和 RAM 升级后，我们现在还增加了 `medium` 和 `large` 机器类型的存储。

您现在可以无缝地构建、测试和部署需要安全、按需的极狐GitLab Runner Linux 环境并与极狐GitLab CI/CD 完全集成的更大应用程序。

<a id="cicd-job-token-scope-api-endpoint"></a>

### CI/CD 作业令牌范围 API 端点

<!-- categories: Secrets Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/jobs/ci_job_token.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/351740)

{{< /details >}}

从极狐GitLab 16.0 开始，所有新项目的[默认 CI/CD 作业令牌（`CI_JOB_TOKEN`）范围已更改](../../ci/jobs/ci_job_token.md)。这提高了新项目的安全性，但为使用自动化创建项目的用户增加了一个额外步骤。自动化有时还必须配置作业令牌范围，而这只能通过 GraphQL（或在 UI 中手动）完成，而不能通过 REST API 完成。

为了也通过 REST API 配置此设置，[Gerardo Navarro](https://gitlab.com/gerardo-navarro) 在 16.1 中添加了一个新端点来控制作业令牌范围。项目中的维护者或更高角色的用户可以使用它。感谢 Gerardo 的这项出色贡献！

<a id="runner-details---consolidate-runners-sharing-a-configuration"></a>

### Runner 详情 - 合并共享配置的 runner

<!-- categories: Fleet Visibility -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](https://gitlab.cn/docs/runner/fleet_scaling/#reusing-a-runner-configuration) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/409388/)

{{< /details >}}

新的 runner 创建方法使您能够为可能需要注册多个具有相同能力的 runner 的场景重用 runner 配置。使用相同认证令牌注册的 runner 共享一个配置，并在新的详细视图中分组。

<a id="gitlab-runner-161"></a>

### 极狐GitLab Runner 16.1

<!-- categories: GitLab Runner Core -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](https://gitlab.cn/docs/runner/)

{{< /details >}}

我们今天还发布了极狐GitLab Runner 16.1！极狐GitLab Runner 是轻量级、高度可扩展的代理，用于运行您的 CI/CD 作业并将结果发送回极狐GitLab 实例。极狐GitLab Runner 与极狐GitLab CI/CD 协同工作，后者是极狐GitLab 中包含的开源持续集成服务。

<a id="whats-new"></a>

#### 新功能

- [GitLab Runner Fleeting 插件（适用于 Azure 虚拟机）（实验）](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/29410)。感谢 [vincent_stchu](https://gitlab.com/vincent_stchu)的贡献！

所有变更的列表在极狐GitLab Runner [CHANGELOG](https://gitlab.com/gitlab-org/gitlab-runner/-/blob/16-1-stable/CHANGELOG.md)中。
