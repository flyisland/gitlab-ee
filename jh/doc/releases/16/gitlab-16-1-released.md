---
stage: 发版说明
group: 月度发版
date: 2023-06-22
title: "极狐GitLab 16.1 发版说明"
description: "极狐GitLab 16.1 发布，包含全新导航体验"
---

<!-- markdownlint-disable -->
<!-- vale off -->

2023 年 6 月 22 日，极狐GitLab 16.1 正式发布，带来了以下新功能。

## 主要功能

<a id="all-new-navigation-experience"></a>

### 全新导航体验

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../tutorials/left_sidebar/_index.md)

{{< /details >}}

极狐GitLab 16.1 带来了全新的导航体验！我们已默认为所有用户启用此体验。开始使用，请点击 UI 右上角的头像，然后开启 **新导航** 切换开关。

新导航旨在解决用户反馈的三个关键领域：极狐GitLab 导航过于繁杂，难以从中断处继续，以及无法自定义导航。

新导航包含一个简化和改进的左侧边栏，您可以：

- 将常用项目 📌 置顶。
- 完全隐藏侧边栏，并通过“窥视”功能将其调回。
- 通过新的 **您的工作** 和 **探索** 选项，轻松切换上下文、搜索以及查看数据子集。
- 由于顶级菜单项更少，可以更快地浏览。

我们为新导航感到自豪，并期待看到您的反馈。请查阅[更改内容列表](https://jihulab.com/groups/gitlab-cn/-/epics/9044#whats-different)并阅读我们关于导航[愿景](https://gitlab.cn/blog/gitlab-product-navigation/)和[设计](https://gitlab.cn/blog/overhauling-the-navigation-is-like-building-a-dream-home/)的博客文章。

请尝试新导航，并在此[议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/409005)中分享您的体验。我们已在根据反馈[进行处理](https://jihulab.com/gitlab-cn/gitlab/-/issues/409005#actions-we-are-taking-from-the-feedback)，并最终将移除该切换开关。

<a id="visualize-kubernetes-resources-in-gitlab"></a>

### 在极狐GitLab 中可视化 Kubernetes 资源

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../ci/environments/kubernetes_dashboard.md) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/390769)

{{< /details >}}

如何检查集群中运行的应用状态？流水线状态和环境页面提供了最新部署运行的洞察。然而，极狐GitLab 之前的版本缺乏对部署状态的洞察。在极狐GitLab 16.1 中，您可以查看 Kubernetes 部署中主要资源的概览。

此功能适用于每个已连接的 Kubernetes 集群。无论您是使用 CI/CD 集成还是 GitOps 部署工作负载，都没有关系。为了进一步改进针对 Flux 用户的功能，提议在[议题 391581](https://jihulab.com/gitlab-cn/gitlab/-/issues/391581) 中增加显示环境同步状态的支持。

<a id="authenticate-with-service-accounts"></a>

### 使用服务账号认证

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../api/groups.md) | [相关议题](https://jihulab.com/groups/gitlab-cn/-/epics/6777)

{{< /details >}}

有许多用例需要非人类用户进行认证。以前，根据所需范围，用户可以使用个人、项目或群组访问令牌来满足此需求。这些令牌并非理想，因为它们要么仍然关联到人类（对于个人访问令牌），要么具有不必要的过高权限角色（对于群组和项目访问令牌）。

服务账号不关联人类用户，且范围更细粒度。服务账号的创建和管理仅通过 API 进行。有关 UI 选项的支持在[议题 9965](https://jihulab.com/groups/gitlab-cn/-/epics/9965) 中提出。

<a id="manage-job-artifacts-through-the-artifacts-page"></a>

### 通过产物页面管理作业产物

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../ci/jobs/job_artifacts.md#view-all-job-artifacts-in-a-project)

{{< /details >}}

以前，如果你想查看或管理作业产物，必须前往每个作业的详情页面，或使用 API。现在，你可以通过 **构建 > 产物** 中的 **产物** 页面来查看和管理作业产物。

具有至少维护者角色的用户也可以使用此新界面删除产物。你可以删除单个产物，或通过手动选择或勾选页面顶部的 **全选** 选项，一次性批量删除最多 100 个产物。

请使用产物页面顶部的调查问卷，分享您对此新功能的任何反馈。要查看正在考虑的其他 UI 功能，可以了解[构建产物页面增强史诗](https://jihulab.com/groups/gitlab-cn/-/epics/8311)。

<a id="improved-cicd-variables-list-view"></a>

### 改进的 CI/CD 变量列表视图

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../ci/variables/_index.md#define-a-cicd-variable-in-the-ui) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/410383)

{{< /details >}}

CI/CD 变量是所有流水线的关键组成部分，并可在多个位置定义，包括项目和群组设置。为了为更大的改进做准备，帮助用户在不同层级之间直观地导航变量，我们从改善变量列表的可用性和布局入手。

在极狐GitLab 16.1 中，你将看到这些改进的第一次迭代。我们将“类型”和“选项”列合并为一个新的 **属性** 列，更好地表达了这些相关属性。我们感谢您对我们如何继续改进 CI/CD 变量体验的反馈，欢迎在[变量改进史诗](https://jihulab.com/groups/gitlab-cn/-/epics/10506)中发表评论。

## 扩容与部署

<a id="gitlab-chart-improvements"></a>

### 极狐GitLab chart 改进

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](https://gitlab.cn/docs/charts/)

{{< /details >}}

- 极狐GitLab 16.1 将 `busybox` Docker 镜像替换为 `gitlab-base` Docker 镜像，以与其他极狐GitLab Docker 镜像共享层。此实现将 `gitlab-base` 视为辅助镜像（类似 `kubectl` 和 `certificates`），并支持可选的本地覆盖。

<a id="omnibus-improvements"></a>

### Omnibus 改进

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](https://gitlab.cn/docs/omnibus/)

{{< /details >}}

- 极狐GitLab 16.1 新增了对在 2023 年 6 月 10 日发布的 [Debian 12 `Bookworm`](https://www.debian.org/releases/bookworm/) 上构建和发布软件包的支持。

<a id="improved-domain-verification"></a>

### 改进的域名验证

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/enterprise_user/_index.md) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/375492)

{{< /details >}}

域名验证在极狐GitLab 中具有多种用途。以前，要验证域名，你必须完成[极狐GitLab Pages](../../user/project/pages/_index.md) 向导，即使你为 Pages 以外的目的验证域名也是如此。

现在，域名验证位于群组级别，并已得到精简。这使得验证域名变得更加容易。

<a id="view-vulnerability-report-as-customizable-permission"></a>

### 将查看漏洞报告作为可自定义权限

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/permissions.md) | [相关议题](https://jihulab.com/groups/gitlab-cn/-/epics/10160)

{{< /details >}}

查看漏洞报告的能力现在被拆分为一个单独的权限，使极狐GitLab 管理员和群组所有者可以创建具有此权限的自定义角色。以前，查看漏洞报告仅限于开发者角色及以上。现在，只要用户被分配了具有此权限的自定义角色，任何用户都可以查看漏洞报告。

<a id="password-reset-email-sent-to-any-verified-email-address"></a>

### 密码重置邮件可发送至任何已验证邮箱

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/profile/user_passwords.md#change-your-password) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/16311)

{{< /details >}}

如果你忘记了极狐GitLab 密码，现在可以使用任何已验证的邮箱地址通过电子邮件重置密码。以前，只有主邮箱地址可用于重置请求。这导致在主邮箱收件箱无法访问时，很难完成密码重置流程。

<a id="scim-identities-included-in-users-api-response"></a>

### 用户 API 响应中包含 SCIM 身份信息

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../api/users.md) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/324247)

{{< /details >}}

用户 API 现在会返回用户的 SCIM 身份信息。以前，此信息仅包含在 UI 中，而不在 API 中。

<a id="reintroduction-of-omniauth-shibboleth-support"></a>

### 重新引入 OmniAuth Shibboleth 支持

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../integration/shibboleth.md) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/393065)

{{< /details >}}

Shibboleth OmniAuth 支持已重新引入极狐GitLab。此前由于缺乏上游支持，它在极狐GitLab 15.9 中被[移除](https://jihulab.com/gitlab-cn/gitlab/-/issues/388959)。感谢社区贡献者 [lukaskoenen](https://gitlab.com/lukaskoenen) 慷慨地承担了上游支持工作，`omniauth-shibboleth-redux` 现已在自管理极狐GitLab 中得到支持。

<a id="select-administrator-access-for-personal-access-tokens-in-admin-mode"></a>

### 在管理员模式中为个人访问令牌选择管理员权限

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../user/profile/personal_access_tokens.md#personal-access-token-scopes) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/42692)

{{< /details >}}

极狐GitLab 管理员可以使用管理员模式作为非管理员用户操作，并在需要时开启管理员权限。以前，管理员的个人访问令牌（PAT）始终具有以管理员身份执行 API 操作的权限。现在，在添加 PAT 时，管理员可以通过选择管理员模式范围，决定该 PAT 是否具有管理员权限来执行 API 操作。管理员必须为实例启用管理员模式才能使用此功能。

感谢 [Jonas Wälter](https://gitlab.com/wwwjon)、[Diego Louzán](https://gitlab.com/dlouzan) 和 [Andreas Deicha](https://gitlab.com/TrueKalix) 的贡献！

<a id="prevent-user-from-deleting-account"></a>

### 阻止用户删除帐户

{{< details >}}

- Tier: 专业版，旗舰版
- Links: [文档](../../administration/settings/account_and_limit_settings.md#prevent-users-from-deleting-their-accounts) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/26053)

{{< /details >}}

管理员可以通过新的用户限制配置设置，阻止用户删除其帐户。如果启用此设置，用户将无法删除其帐户，从而保留可审计的帐户信息。

<a id="personal-access-token-last_used-value-updated-more-frequently"></a>

### 个人访问令牌 `last_used` 值更新更频繁

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/profile/personal_access_tokens.md) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/410168)

{{< /details >}}

个人访问令牌（PAT）的 `last_used` 值以前每 24 小时更新一次。现在每 10 分钟更新一次。这增加了 PAT 使用的可见性，并在 PAT 被泄露时，减少了发现恶意活动所需的时间，从而降低风险。

感谢 [Jacob Torrey](https://thinkst.com/) 的贡献！

<a id="more-detail-in-completed-github-project-import-summary"></a>

### 已完成 GitHub 项目导入摘要中的更多详细信息

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/import/github.md#check-status-of-imports) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/386748)

{{< /details >}}

当 GitHub 项目导入完成时，极狐GitLab 会显示一个简单的导入实体摘要。然而，极狐GitLab 没有准确显示哪些 GitHub 实体导入失败，也没有显示导致导入失败的错误。这使得很难判断导入结果是否令人满意。

在此版本中，我们扩展了导入摘要，以包含未导入的 GitHub 实体列表，并在可能的情况下提供这些实体在 GitHub 上的直接链接。极狐GitLab 现在还会为每个失败显示一个错误。这有助于你了解导入的执行情况，并帮助你排查问题。

<a id="show-external-user-as-a-comment-author-in-service-desk-issues"></a>

### 在 Service Desk 议题中将外部用户显示为评论作者

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../user/project/service_desk/_index.md)

{{< /details >}}

当请求者回复 Service Desk 邮件时，Service Desk 坐席知道是谁发表的评论是很有用的。但由于请求者可能是外部用户，没有极狐GitLab 帐户或无法访问极狐GitLab 项目，这些评论以前被归于极狐GitLab 支持机器人。从现在起，来自请求者的电子邮件回复将归属于外部用户，从而更清楚地显示极狐GitLab 议题中的评论者是谁。

<a id="issue-url-placeholder-in-service-desk-emails"></a>

### Service Desk 邮件中的议题 URL 占位符

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../user/project/service_desk/_index.md)

{{< /details >}}

对于 Service Desk 请求者而言，直接访问 Service Desk 议题可能比仅通过电子邮件与 Service Desk 请求交互更有帮助。我们引入了一个新的占位符 `%{ISSUE_URL}`，你可以在电子邮件模板（例如“感谢”邮件）中使用它，将请求者直接链接到 Service Desk 议题。

<a id="backup-adds-the-ability-to-skip-projects"></a>

### 备份增加了跳过项目的功能

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/18287)

{{< /details >}}

内置的备份和恢复工具增加了跳过特定仓库的功能。Rake 任务现在通过新的 `SKIP_REPOSITORIES_PATHS` 环境变量，接受一个逗号分隔的群组或项目路径列表，以便在备份或恢复期间跳过这些路径。这将允许你跳过例如从不改变的陈旧或已归档项目，从而通过加快备份运行速度节省时间，并通过不在备份文件中包含这些数据节省空间。
感谢 [Yuri Konotopov](https://gitlab.com/nE0sIghT) 的[社区贡献](https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/121865)！

<a id="geo-adds-filtering-by-replication-status-to-all-components"></a>

### Geo 为所有组件增加按复制状态筛选

{{< details >}}

- Tier: 专业版，旗舰版
- Links: [文档](../../administration/geo/_index.md) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/411981)

{{< /details >}}

Geo 为所有由[自服务框架](../../development/geo/framework.md)管理的组件增加了按复制状态筛选的功能。现在，你可以在复制详情视图中按“进行中”、“失败”和“已同步”状态筛选项目，从而更容易、更快地定位同步失败的数据。

<a id="geo-verifies-design-repositories"></a>

### Geo 验证设计仓库

{{< details >}}

- Tier: 专业版，旗舰版
- Links: [文档](../../administration/geo/_index.md) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/355660)

{{< /details >}}

当你向议题添加设计时，会创建或更新一个设计 Git 仓库，并创建一个 LFS 对象和一个上传（用于缩略图）。Geo 已经验证了 LFS 对象和上传，现在也验证设计仓库。既然[设计管理](../../user/project/issues/design_management.md)的所有底层数据都得到了验证，你的设计数据在传输或静止时都不会受损。如果 Geo 被用作灾难恢复策略的一部分，这将保护你免受数据丢失。

## 统一 DevOps 与安全

<a id="comment-on-whole-file-in-merge-requests"></a>

### 在合并请求中对整个文件发表评论

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../user/project/merge_requests/changes.md#add-a-comment-to-a-merge-request-file)

{{< /details >}}

合并请求现在支持对整个文件进行评论，因为并非所有合并请求的反馈都针对特定行。如果文件被删除，你可能需要更多关于原因的信息。你可能还想就文件名或整体结构提供反馈。

<a id="create-a-changelog-from-the-gitlab-cli"></a>

### 从 极狐GitLab CLI 创建变更日志

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../user/project/changelogs.md#from-the-gitlab-cli)

{{< /details >}}

变更日志根据项目的提交生成全面的变更列表。它们可能难以自动化或查看，并需要与 极狐GitLab API 交互。

随着 [极狐GitLab CLI v1.30.0](https://gitlab.com/gitlab-org/cli/-/releases/v1.30.0) 的发布，你现在可以直接从 shell 中为项目生成变更日志。`glab changelog generate` 命令使得审查、自动化和发布变更日志变得更加容易。

感谢 [Michael Mead](https://gitlab.com/michael-mead) 的贡献！

<a id="fail-closed-for-invalid-security-policy-approval-checks"></a>

### 无效安全策略审批检查时采取 Fail Closed 策略

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/merge_requests/approvals/_index.md#invalid-rules) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/389905)

{{< /details >}}

安全和合规策略允许组织在多个项目间强制实施检查与平衡，以符合其安全和治理计划。确保影响策略的变更不会导致护栏失效对我们客户至关重要。通过此更新，无效规则将“fail closed”，在扫描结果策略中的无效规则得到解决之前，阻止合并请求。

<a id="install-npm-packages-from-your-group-or-subgroup"></a>

### 从你的群组或子群组安装 npm 软件包

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../user/packages/npm_registry/_index.md#install-from-a-group) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/299834)

{{< /details >}}

你可以使用项目的软件包仓库来发布和安装 npm 软件包。只需使用访问令牌（个人、作业、部署或项目）进行认证，然后开始将软件包发布到你的极狐GitLab 项目。

如果你的项目数量不多，这种方法非常有效。但如果你有多个项目，你可能很快就会发现自己需要添加数十甚至数百个不同的来源。对于大型组织中的团队来说，将软件包与源代码和流水线一起发布到所在项目的软件包仓库是很常见的。同时，他们还需要能够从组织内群组和子群组中的其他项目轻松安装依赖项。

为了使项目间的软件包共享更容易，你现在可以从群组安装软件包，这样就不必记住哪个软件包在哪个项目中。使用你选择的认证令牌，在将你的群组添加为 npm 软件包的来源后，你可以安装该群组中的任何 npm 软件包。

<a id="add-a-description-to-design-uploads"></a>

### 为设计上传添加描述

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/issues/design_management.md#add-a-design-to-an-issue) | [相关史诗](https://jihulab.com/groups/gitlab-cn/-/epics/9694)

{{< /details >}}

目前[设计上传](../../user/project/issues/design_management.md#add-a-design-to-an-issue)没有用于解释其目的或为何上传的元数据。我们添加了一个文本框作为描述，以帮助用户更好地理解图像。

<a id="configure-the-static-file-directory-in-gitlab-pages"></a>

### 在极狐GitLab Pages 中配置静态文件目录

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/pages/introduction.md#customize-the-default-folder) | [相关议题](https://jihulab.com/groups/gitlab-cn/-/epics/10126)

{{< /details >}}

你现在可以将极狐GitLab Pages 的静态文件目录配置为任意名称（默认为 `public`）。
这使得将 Pages 与流行的静态站点框架（如 Next.js、Astro 或 Eleventy）一起使用时更加容易，
无需修改其配置中的输出文件夹。

<a id="code-quality-analyzer-updates"></a>

### 代码质量分析器更新

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../ci/testing/code_quality.md) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/412459)

{{< /details >}}

极狐GitLab 代码质量支持[集成你已在运行的工具](../../ci/testing/code_quality.md)，还提供了[一个 CI/CD 模板](../../ci/testing/code_quality.md)，用于运行 CodeClimate 扫描系统。我们在 16.1 版本里程碑期间发布了以下基于 CodeClimate 的分析器更新：

- 将 CodeClimate 更新至 0.96.0 版本。此版本包括：
  - 为 `golangci-lint` 新增插件。
  - 为 `bundler-audit` 插件新增可用版本。
- 添加了对可配置 Docker API 套接字路径的支持。
  - 感谢 [`@tsjnsn`](https://gitlab.com/tsjnsn) 的[社区贡献](https://gitlab.com/gitlab-org/ci-cd/codequality/-/merge_requests/73)。将此变量包含到 CI/CD 模板中的更新在[一个议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/409738)中进行跟踪。

请参阅[变更日志](https://gitlab.com/gitlab-org/ci-cd/codequality/-/blob/master/CHANGELOG.md?ref_type=heads#anchor-0960)以了解更多详细信息。

如果你[包含由极狐GitLab 管理的代码质量模板](../../ci/testing/code_quality.md)（[`Code-Quality.gitlab-ci.yml`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Jobs/Code-Quality.gitlab-ci.yml)），你将自动获得这些更新。

有关之前版本的代码质量变更，请参阅[最新更新](https://gitlab.cn/releases/2023/04/22/gitlab-15-11-released/#static-analysis-analyzer-updates)。

<a id="sast-analyzer-updates"></a>

### SAST 分析器更新

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../user/application_security/sast/analyzers.md) | [相关议题](../../user/application_security/_index.md)

{{< /details >}}

（内容未完，待下页）
极狐GitLab SAST 包含[众多安全分析器](../../user/application_security/sast/_index.md#supported-languages-and-frameworks)，由极狐GitLab 静态分析团队积极维护、更新和支持。在 16.1 发布里程碑中，我们发布了以下更新：

- 基于 Semgrep 的分析器已更新至 Semgrep 引擎 1.23.0 版本。我们还[明确了指导并提高了有效性](https://gitlab.cn/docs/#clearer-guidance-and-better-coverage-for-sast-rules)，针对用于扫描 C、C#、Go 和 Java 的极狐GitLab 管理规则。详情请参见 [CHANGELOG](https://jihulab.com/gitlab-cn/security-products/analyzers/semgrep/-/blob/main/CHANGELOG.md#v434)。
- 基于 SpotBugs 的分析器现在支持通过[设置 `SAST_SCANNER_ALLOWED_CLI_OPTS` CI/CD 变量](../../user/application_security/sast/_index.md#security-scanner-configuration)来更改“努力级别”。这允许你通过降低扫描精度和漏洞检测能力来提高性能。详情请参见 [CHANGELOG](https://jihulab.com/gitlab-cn/security-products/analyzers/spotbugs/-/blob/master/CHANGELOG.md#v420)。

如果你[包含了极狐GitLab 管理的 SAST 模板](../../user/application_security/sast/_index.md)（[`SAST.gitlab-ci.yml`](https://jihulab.com/gitlab-cn/gitlab/blob/master/lib/gitlab/ci/templates/Security/SAST.gitlab-ci.yml)）并运行极狐GitLab 16.0 或更高版本，你将自动获得这些更新。
若要保留特定版本的分析器并阻止自动更新，你可以[锁定其版本](../../user/application_security/sast/_index.md)。

有关之前的更改，请参见[上个月的更新](https://gitlab.cn/releases/2023/05/22/gitlab-16-0-released/#sast-analyzer-updates)。

### 更清晰的 SAST 规则指导和更好的覆盖率

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../user/application_security/sast/analyzers.md)

{{< /details >}}

我们更新了极狐GitLab SAST 规则，以：

- 更清晰地解释每条规则针对的弱点类型以及如何修复。到目前为止，我们已经更新了 C、C#、Go 和 Java 规则的描述和指导文本。其余语言的相关工作正在进行中。
- 在现有 Java 规则中捕获更多漏洞。

这些改进是极狐GitLab 静态分析和漏洞研究团队合作的一部分，旨在[改进默认的静态分析规则集](https://jihulab.com/gitlab-cn/gitlab/-/epics/8170)。
我们欢迎您对 SAST、密钥检测和 IaC 扫描的默认规则提出反馈。

有关极狐GitLab SAST 规则更改的更多详细信息，请参见 [CHANGELOG](https://jihulab.com/gitlab-cn/security-products/sast-rules/-/blob/main/CHANGELOG.md)。
从极狐GitLab 16.1 开始，[`sast-rules` 项目](https://jihulab.com/gitlab-cn/security-products/sast-rules)是基于 Semgrep 的 SAST 分析器中使用的所有极狐GitLab 管理默认规则的单一来源。

### SAST、IaC 扫描和密钥检测中的共享规则集自定义

{{< details >}}

- Tier: 旗舰版
- Links: [文档](../../user/application_security/sast/customize_rulesets.md)

{{< /details >}}

你现在可以设置一个 CI/CD 变量，以在多个项目之间共享 [SAST](../../user/application_security/sast/customize_rulesets.md)、[IaC 扫描](../../user/application_security/iac_scanning/_index.md)或[密钥检测](../../user/application_security/secret_detection/pipeline/_index.md)的规则集自定义。

共享规则集可以帮助你：

- [禁用预定义规则](../../user/application_security/sast/customize_rulesets.md)，以便你不希望在项目中关注这些规则。
- [更改预定义规则中的字段](../../user/application_security/sast/customize_rulesets.md)，包括描述、消息、名称或严重性，以反映组织偏好。例如，你可以调整规则的默认严重性或添加有关如何修复发现的信息。
- 通过添加或替换规则来[构建自定义规则集](../../user/application_security/sast/customize_rulesets.md)。此选项仅适用于某些分析器。

此领域的进一步改进正在讨论中。

### CI/CD：在 `rules` 中使用 `needs`

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../ci/yaml/_index.md#rulesneeds)

{{< /details >}}

[`needs:`](../../ci/yaml/_index.md#needs) 关键字定义了作业之间的依赖关系，你可以使用它来设置作业在阶段顺序之外运行。在此版本中，我们增加了为特定 `rules` 条件定义此关系的能力。当条件与规则匹配时，作业的 `needs` 配置将完全替换为规则中的 `needs`。这可以根据你定义的条件加快流水线速度，当作业可以比正常情况更早开始时。你也可以使用它来强制作业等待较早的作业完成后再开始，你现在拥有更灵活的 `needs` 选项！

### 美化 CI/CD 流水线和作业的 UI

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../ci/pipelines/_index.md)

{{< /details >}}

极狐GitLab 最常用的功能之一是 CI/CD。在 16.1 中，我们专注于改进 CI/CD 流水线和作业列表视图以及流水线详情页面的可用性和体验。现在更容易找到你要查找的信息！如果你对这些更改有任何意见，我们很乐意在我们的反馈中听到你的声音。

### 增加 Linux 上极狐GitLab SaaS Runner 的存储空间

{{< details >}}

- Tier: Silver, Gold
- Offering: JihuLab.com
- Links: [文档](../../ci/runners/hosted_runners/linux.md)

{{< /details >}}

在最近增加了 [Linux 上极狐GitLab.com SaaS Runner](../../ci/runners/hosted_runners/linux.md)的 vCPU 和 RAM 之后，我们现在还增加了 `medium` 和 `large` 机器类型的存储空间。

你现在可以无缝地构建、测试和部署需要安全、按需的极狐GitLab Runner Linux 环境且与极狐GitLab CI/CD 完全集成的大型应用程序。

### CI/CD 作业令牌范围 API 端点

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../ci/jobs/ci_job_token.md)

{{< /details >}}

从极狐GitLab 16.0 开始，所有新项目的[默认 CI/CD 作业令牌 (`CI_JOB_TOKEN`) 范围发生了变化](../../ci/jobs/ci_job_token.md)。这提高了新项目的安全性，但为使用自动化创建项目的用户增加了一个额外步骤。自动化有时也必须配置作业令牌范围，而这只能通过 GraphQL（或手动在 UI 中）完成，不能通过 REST API 完成。

为了使此设置也可以通过 REST API 进行配置，[Gerardo Navarro](https://gitlab.com/gerardo-navarro) 在 16.1 中添加了一个新端点来控制作业令牌范围。它可供项目中具有维护者或更高角色的用户使用。感谢 Gerardo 的这一伟大贡献！

### Runner 详情 - 整合共享配置的 Runner

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](https://gitlab.cn/docs/runner/fleet_scaling/#reusing-a-runner-configuration)

{{< /details >}}

新的 Runner 创建方法使你能够在需要注册多个具有相同功能的 Runner 的场景中重用 Runner 配置。使用相同认证令牌注册的 Runner 共享一个配置，并在新的详细视图中进行分组。

### 极狐GitLab Runner 16.1

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](https://gitlab.cn/docs/runner)

{{< /details >}}

我们今天还发布了极狐GitLab Runner 16.1！极狐GitLab Runner 是轻量级、高度可扩展的代理，用于运行你的 CI/CD 作业并将结果发送回极狐GitLab 实例。极狐GitLab Runner 与极狐GitLab CI/CD 配合使用，极狐GitLab CI/CD 是极狐GitLab 附带的开源持续集成服务。

所有更改的列表在极狐GitLab Runner [CHANGELOG](https://jihulab.com/gitlab-cn/gitlab-runner/-/blob/16-1-stable/CHANGELOG.md) 中。