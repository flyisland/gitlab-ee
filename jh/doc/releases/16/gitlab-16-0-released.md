---
stage: Release Notes
group: Monthly Release
date: 2023-05-22
title: "极狐GitLab 16.0 发布说明"
description: "极狐GitLab 16.0 released with Value Streams Dashboard is now generally available"
---

<!-- markdownlint-disable -->
<!-- vale off -->

2023 年 5 月 22 日，极狐GitLab 16.0 发布，包含以下功能。

<a id="primary-features"></a>

## 主要功能

<a id="value-streams-dashboard-is-now-generally-available"></a>

### 价值流仪表板现已正式发布

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/analytics/value_streams_dashboard.md)

{{< /details >}}

这个新的仪表板提供战略洞察，帮助决策者识别趋势和模式，以优化软件交付。极狐GitLab 价值流仪表板的首次迭代专注于使团队能够通过基准测试价值流生命周期（[价值流分析](../../user/group/value_stream_analytics/_index.md)、[DORA4](../../user/analytics/dora_metrics.md)）和[漏洞](../../user/application_security/vulnerability_report/_index.md)指标，持续改进软件交付工作流。

组织可以使用[价值流仪表板](../../user/analytics/value_streams_dashboard.md)在一段时间内跟踪和比较这些指标，及早发现下降趋势，了解安全暴露情况，并深入到单个项目或指标以采取改进措施。

这种作为单一应用程序构建的统一数据存储的综合视图，使从高管到个人贡献者的所有利益相关者都能了解软件开发生命周期，而无需购买或维护第三方工具。

<a id="upsizing-gitlab-saas-runners-on-linux"></a>

### 扩大 Linux 上极狐GitLab SaaS Runner 的规模

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../ci/runners/hosted_runners/linux.md)

{{< /details >}}

你提需求，我们响应！为了在 CI/CD 构建速度方面成为一流，我们将所有 Linux 上极狐GitLab SaaS Runner 的 vCPU 和 RAM 翻倍，且不增加[成本因子](../../ci/pipelines/compute_minutes.md)。

我们很高兴看到流水线运行更快，生产力得到提升。

<a id="gpu-enabled-saas-runners-on-linux"></a>

### Linux 上启用 GPU 的 SaaS Runner

{{< details >}}

- Tier: 专业版，旗舰版
- Links: [文档](../../ci/runners/hosted_runners/linux.md)

{{< /details >}}

我们旨在通过在极狐GitLab Runner 内提供更强大的计算硬件，将 DevSecOps 的最佳实践引入数据科学。以前，数据科学家可能有计算密集型的工作负载，因此作业在极狐GitLab 中可能无法快速执行。

现在，借助 Linux 上启用 GPU 的 SaaS Runner，这些工作负载可以在 JihuLab.com 上无缝支持。

还等什么？立即试用新的 Runner，并告诉我们你的想法。我们迫不及待地想听到你的反馈！

<a id="apple-silicon-m1-gitlab-saas-runners-on-macos---beta"></a>

### Apple silicon (M1) 极狐GitLab SaaS Runner 在 macOS 上 - 测试版

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../ci/runners/hosted_runners/macos.md#example-gitlab-ciyml-file)

{{< /details >}}

移动 DevOps 团队现在可以在 Apple silicon (M1) 的 [macOS 上的极狐GitLab SaaS Runner](../../ci/runners/hosted_runners/macos.md)上运行其整个 CI/CD 工作流，无缝地为 Apple 生态系统创建、测试和部署应用程序。

与托管的 x86-64 macOS Runner 相比，性能提升高达**三倍**，你将提高开发团队在构建和部署需要 macOS 的应用程序时的速度，这一切都在与极狐GitLab CI/CD 集成的安全、按需的极狐GitLab Runner 构建环境中进行。

<a id="comment-templates"></a>

### 评论模板

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/profile/comment_templates.md)

{{< /details >}}

当你在议题、史诗或合并请求中评论时，你可能会重复自己，需要一遍又一遍地写相同的评论。也许你总是需要询问有关错误报告的更多信息。也许你正在通过快速操作应用标签作为分类过程的一部分。或者你只是喜欢用有趣的 gif 或适当的表情符号结束所有代码审查。🎉

评论模板使你能够创建保存的回复，你可以将其应用到极狐GitLab 各处的评论框中，以加快工作流程。要创建评论模板，请转到 **用户设置 > 评论模板**，然后填写你的模板。保存后，在任何文本区域选择 **插入评论模板** 图标，你保存的回复就会被应用。

这是标准化你的回复并节省时间的好方法！

<a id="update-your-fork-from-the-gitlab-ui"></a>

### 从极狐GitLab UI 更新你的派生

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/repository/forking_workflow.md#update-your-fork)

{{< /details >}}

管理你的派生变得更简单了。当你的派生落后时，在极狐GitLab UI 中选择 **更新派生** 以使其与上游更改同步。当你的派生领先时，选择 **创建合并请求** 将你的更改贡献回上游项目。这两个操作以前都需要你使用命令行。

在你的项目主页和 **代码仓 > 文件** 处，可以查看你的派生领先（或落后）多少提交。如果存在合并冲突，UI 会提供有关如何使用命令行 Git 解决冲突的指导。

<a id="mirror-specific-branches-only"></a>

### 仅镜像特定分支

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/repository/mirror/_index.md#mirror-specific-branches)

{{< /details >}}

你是否需要镜像一个包含许多分支的繁忙仓库，但只需要其中几个？通过创建仅匹配所需分支的正则表达式，限制你镜像的分支数量。

以前，镜像要求你镜像整个仓库或所有受保护的分支。这种新的灵活性可以减少镜像推送或拉取的数据量，并将敏感分支排除在公共镜像之外。

<a id="new-web-ide-experience-now-generally-available"></a>

### 新的 Web IDE 体验现已正式发布

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/web_ide/_index.md)

{{< /details >}}

自推出以来，我们一直在迭代 Web IDE 的可用性、性能和稳定性，这使我们能够在强大的基础上构建远程开发工作区和代码建议等功能。

我们收到了关于 Web IDE 测试版的压倒性积极反馈，从极狐GitLab 16.0 开始，我们将其设为极狐GitLab 中默认的多文件代码编辑器。

<a id="workspaces-available-in-beta-for-public-projects"></a>

### 工作区在公开项目中以测试版形式提供

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/workspace/_index.md)

{{< /details >}}

别再花数小时甚至数天时间排查本地开发环境问题，解读难以理解的软件包安装错误了。现在，你可以在代码中定义一致、稳定且安全的开发环境，并用于按需创建；所有这些都在工作区内完成。

工作区作为云中的个人临时开发环境。通过消除对本地开发环境的需求，你可以更专注于代码，减少对依赖项的担忧。加速新项目的入门过程，几分钟内即可启动并运行，而不是几天。

在为 Kubernetes 配置极狐GitLab Agent 并在你选择的自托管集群或云平台上[安装依赖项](../../user/workspace/_index.md)后，你可以在 `.devfile.yaml` 文件中定义你的开发环境，并将其存储在公开项目中。然后，你和其他任何有权访问代理的开发人员都可以基于 `.devfile.yaml` 文件创建工作区，并直接在嵌入式 Web IDE 中编辑。你将拥有对容器的完全终端访问权限，从而更高效地工作。完成后，或者如果出现问题，你可以关闭工作区，并为下一个开发任务启动一个全新的工作区。

在[文档](../../user/workspace/_index.md)中了解更多关于工作区的信息，并告诉我们你的想法。

<a id="security-training-with-secureflag"></a>

### 使用 SecureFlag 进行安全培训

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/vulnerabilities/_index.md#enable-security-training-for-vulnerabilities)

{{< /details >}}

随着安全左移，在没有指导的情况下修复安全发现可能具有挑战性。开发人员需要可操作的建议，以便他们能够解决漏洞并继续构建功能。极狐GitLab 14.9 中发布了与检测到的特定漏洞相关的上下文培训。

在此版本中，我们基于漏洞的 CWE 添加了与 SecureFlag 的集成。SecureFlag 的培训解决方案的独特之处在于，实验涉及在真实环境中修复漏洞，这可以转移到真实环境中。

<a id="token-rotation-api"></a>

### 令牌轮换 API

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../security/tokens/_index.md)

{{< /details >}}

以前，要轮换令牌，令牌所有者必须手动创建新令牌并替换现有令牌。

现在，令牌所有者可以使用 `:rotate` API 端点以编程方式轮换个人、群组和项目访问令牌。

<a id="ai-powered-workflow-features"></a>

### AI 驱动的工作流功能

{{< details >}}

- Tier: 旗舰版
- Links: [文档](../../development/ai_features/_index.md)

{{< /details >}}

极狐GitLab 正在发展成为一个 AI 驱动的 DevSecOps 平台。在过去的一个月里，我们引入了 10 个新实验，以提高极狐GitLab 各项功能的效率和生产力，所有这些都利用了 AI。

这些 AI 驱动的工作流在软件开发生命周期的每个阶段都能提高效率并缩短周期时间。

了解更多关于 [AI 驱动的工作流](https://gitlab.cn/solutions/ai/) 的信息。

<a id="code-suggestions-improvements"></a>

### 代码建议改进

{{< details >}}

- Tier: 旗舰版，专业版，基础版
- Links: [文档](../../user/project/repository/code_suggestions/_index.md)

{{< /details >}}

代码建议现在在 JihuLab.com 上对所有用户免费提供，而该功能处于测试阶段。团队可以在开发时借助生成式 AI 建议代码来提高效率。

我们已将语言支持从最初的六种语言扩展到现在的 13 种语言：C/C++、C#、Go、Java、JavaScript、Python、PHP、Ruby、Rust、Scala、Kotlin 和 TypeScript。

我们每周都在改进代码建议的底层 AI 模型，以提高建议的质量。请记住，AI 是非确定性的，因此你可能不会每周都得到相同的建议。

阅读更多关于这些[改进和后续计划](https://gitlab.cn/blog/code-suggestions-for-all-during-beta/)的信息。

<a id="error-tracking-is-now-generally-available"></a>

### 错误跟踪现已正式发布

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../operations/error_tracking.md)

{{< /details >}}

极狐GitLab 错误跟踪允许开发人员发现和查看其应用程序生成的错误，现在在 JihuLab.com 上正式发布！极狐GitLab 错误跟踪通过在与代码开发、构建、部署和发布相同的界面中直接显示错误信息，有助于提高效率和意识。

在此版本中，我们同时支持[极狐GitLab 集成错误跟踪](../../operations/error_tracking.md)和[基于 Sentry 的](../../operations/error_tracking.md)后端。

<a id="custom-value-streams-for-project-level-value-stream-analytics"></a>

### 项目级价值流分析的自定义价值流

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/group/value_stream_analytics/_index.md)

{{< /details >}}

为了提高对整个工作流的可见性，我们正在向项目级价值流分析 (VSA) 添加[概览阶段](../../user/group/value_stream_analytics/_index.md)和[创建自定义价值流](../../user/group/value_stream_analytics/_index.md)的选项。

到目前为止，这些功能仅在群组级 VSA 中可用。

<a id="scale-and-deployments"></a>

## 扩展与部署

<a id="rate-limit-for-unauthenticated-users-of-the-projects-list-api"></a>

### 对项目列表 API 的未认证用户进行速率限制

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../administration/settings/rate_limit_on_projects_api.md)

{{< /details >}}

今后，项目列表 API 的未认证用户将受到速率限制。

在 JihuLab.com 上，限制设置为每个唯一 IP 地址每 10 分钟 400 个请求。

私有化部署的极狐GitLab 实例的用户默认具有相同的速率限制，但管理员可以根据需要更改速率限制。我们鼓励需要每 10 分钟向项目列表 API 发出超过 400 个请求的用户[注册极狐GitLab 账户](https://gitlab.cn/pricing/)。

<a id="self-managed-gitlab-uses-two-database-connections"></a>

### 私有化部署的极狐GitLab 使用两个数据库连接

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](https://gitlab.cn/docs/omnibus/settings/database.html#configuring-multiple-database-connections)

{{< /details >}}

从 16.0 开始，私有化部署的极狐GitLab 安装将默认具有两个数据库连接，而不是一个。此更改使私有化部署版本的极狐GitLab 的行为类似于 JihuLab.com，并且是朝着为私有化部署版本的极狐GitLab 启用[独立的 CI 功能数据库](https://gitlab.com/groups/gitlab-org/-/epics/7509)迈出的一步。

此更改适用于使用 Omnibus GitLab、GitLab Helm chart、GitLab Operator、GitLab Docker 镜像和从源代码安装的安装方法。

<a id="option-to-disable-followers"></a>

### 禁用关注者的选项

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/profile/_index.md#disable-following-and-being-followed-by-other-users)

{{< /details >}}

我们收到了用户的反馈，他们希望防止自己的用户资料被不想要的关注者关注。我们听取了你的担忧，因此现在，在你的用户资料设置的偏好设置中，你可以禁用关注。

当你禁用此功能时，没有人可以关注你，你也不能关注任何人。所有现有的关注和被关注关系都将被删除，计数设置为零。

<a id="delayed-group-and-project-deletion-set-as-default"></a>

### 延迟群组和项目删除设为默认

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/jihulab_com/_index.md#delayed-project-deletion)

{{< /details >}}

为了防止意外删除项目和群组，从极狐GitLab 16.0 开始，延迟删除功能将默认对所有极狐GitLab 旗舰版和专业版客户开启。

私有化部署用户仍然可以选择定义 1 到 90 天的删除延迟期，而 SaaS 用户具有不可调整的默认保留期 7 天。

旗舰版和专业版群组的用户仍然可以通过两步删除过程从群组或项目设置中立即删除群组或项目。

我们相信，这一更改将有助于实现更安全的删除过程，并有利于防止意外删除。我们很乐意听取你的反馈。

<a id="gitlab-chart-improvements"></a>

### 极狐GitLab chart 改进

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](https://gitlab.cn/docs/charts/)

{{< /details >}}

- 更新到极狐GitLab 16.0 也会将 cert-manager 更新到版本 1.11.x。此 cert-manager 更新包含重大更改，你必须[在升级前阅读](https://cert-manager.io/docs/release-notes/release-notes-1.10/#breaking-changes-you-must-read-this-before-you-upgrade)。这些更改包括容器名称的更改，最好在极狐GitLab 的主要版本中进行。要查看更新功能的详细信息，请参阅 [cert-manager 1.11 的发行说明](https://cert-manager.io/docs/release-notes/release-notes-1.11)。
- 不再支持 PostgreSQL 12。最低要求版本是 PostgreSQL 13，并添加了对 PostgreSQL 14 的支持。极狐GitLab 的新 chart 安装默认包含 PostgreSQL 14，升级必须遵循[升级捆绑的 PostgreSQL 版本](https://gitlab.cn/docs/charts/installation/database_upgrade.html)的步骤。
- 更新到极狐GitLab 16.0 包括将 Redis 子 chart 更新到版本 16.13.2，其中包括 Redis 6.2.7。
- 我们已移除捆绑的 Grafana chart。如果你使用捆绑的 Grafana，则必须切换到 [Grafana Labs 的较新 chart 版本](https://artifacthub.io/packages/helm/grafana/grafana)或来自受信任提供商的 Grafana Operator。
- 极狐GitLab 16.0 在 `global.registry.*` 配置中包含了 [webservice 和 Sidekiq 的注册表服务详细信息](https://gitlab.cn/docs/charts/charts/globals.html#configure-registry-settings)，以简化，因为这些值同时存在于两者中。你可以通过覆盖保留旧行为。
- [最低支持的 Helm 版本](https://gitlab.cn/docs/charts/installation/tools.html#helm)是 3.5.2。
- 极狐GitLab Runner 的默认版本现在是 Ubuntu 22.04。

<a id="omnibus-improvements"></a>

### Omnibus 改进

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](https://gitlab.cn/docs/omnibus/)

{{< /details >}}

- 不再支持 PostgreSQL 12。最低要求版本是 PostgreSQL 13。使用打包的 PostgreSQL 12 的用户必须在安装极狐GitLab 16.0 之前[执行数据库升级](https://gitlab.cn/docs/omnibus/settings/database.html#upgrade-packaged-postgresql-server)。
- Omnibus GitLab Docker 镜像的新基础操作系统是 Ubuntu 22.04。
- 极狐GitLab 16.0 禁用了 Consul 的旧遥测端点，这些端点在 Consul 1.9 中已弃用。这使我们能够[将 Consul 更新到较新版本](https://developer.hashicorp.com/consul/docs/v1.12.x/agent/config/config-files#telemetry-parameters)。
- 极狐GitLab 16.0 包含适用于 Red Hat Enterprise Linux (RHEL) 9 和兼容发行版的软件包。
- 极狐GitLab 16.0 包含 [Mattermost 7.10](https://mattermost.com/)，并带有[安全更新](https://mattermost.com/security-updates/)。建议从早期版本升级。

<a id="additional-registration-features-available-to-free-users"></a>

### 面向基础版用户的额外注册功能

{{< details >}}

- Tier: 基础版
- Links: [文档](../../administration/settings/usage_statistics.md#registration-features-program)

{{< /details >}}

运行极狐GitLab 企业版的私有化部署实例的极狐GitLab 基础版客户现在可以通过[注册功能](../../administration/settings/usage_statistics.md#registration-features-program)计划访问另外五个付费功能：

- [密码复杂度策略](../../administration/settings/sign_up_restrictions.md)
- [描述更改历史](../../user/discussions/_index.md#view-description-change-history)
- [议题看板配置](../../user/project/issue_board.md#configurable-issue-boards)
- [维护模式](../../administration/maintenance_mode/_index.md)
- [覆盖率引导的模糊测试](../../user/application_security/coverage_fuzzing/_index.md)

要访问这些功能，请注册极狐GitLab 并通过 [Service Ping](../../administration/settings/usage_statistics.md#enable-registration-features) 向我们发送活动数据。

<a id="import-collaborators-as-an-additional-item-to-import"></a>

### 将协作者作为额外项目导入

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/import/github.md#select-additional-items-to-import)

{{< /details >}}

在极狐GitLab 15.10 中，我们开始在 GitHub 项目导入期间将 GitHub 仓库协作者映射为极狐GitLab 项目成员。我们收到了反馈，这导致了混淆，并且一些 GitHub 协作者被意外添加并占用了席位。

在极狐GitLab 16.0 中，我们进行了迭代，并将 GitHub 仓库协作者添加到[要导入的额外项目](../../user/project/import/github.md#select-additional-items-to-import)列表中。这使用户可以选择避免导入这些用户，并了解导入它们可能带来的影响。

默认情况下选择此选项。保持选中状态可能会导致新用户占用群组或命名空间中的一个席位，并被授予[最高为项目所有者](../../user/project/import/github.md#collaborators-members)的权限。仅导入直接协作者。外部协作者永远不会被导入。

<a id="filter-github-repositories-to-import"></a>

### 筛选要导入的 GitHub 仓库

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/project/import/github.md#filter-repositories-list)

{{< /details >}}

如果你在 GitHub 中拥有或协作大量仓库，你可能会发现使用当前的筛选选项很难找到要导入到极狐GitLab 的仓库。

为了更容易找到合适的仓库，我们添加了额外的筛选器。现在，你可以使用三个选项卡列出可导入仓库的子集：

- **所有者**，列出你拥有的仓库。
- **协作者**，列出你协作的仓库。
- **GitHub 组织**，列出属于 GitHub 组织的仓库。

在 **组织** 选项卡上，你可以进一步缩小搜索范围，选择一个特定的组织，并仅列出属于该组织的仓库。

<a id="mark-to-do-items-completed-by-other-group-or-project-owners-done"></a>

### 将其他群组或项目所有者完成的待办事项标记为已完成

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/todos.md#actions-that-mark-a-to-do-item-as-done)

{{< /details >}}

当用户提出对群组或项目的访问请求时，该请求会出现在群组或项目所有者的待办事项列表中。对于具有多个所有者的群组和项目，该请求会出现在每个所有者的待办事项列表中。
有了这个新功能，被其他负责人完成的待办事项会在其他人的待办事项列表中标记为已完成。

<a id="opt-in-to-a-new-navigation-experience"></a>

### 选择使用新的导航体验

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](https://gitlab.cn/docs/tutorials/left_sidebar/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/9044)

{{< /details >}}

极狐GitLab 16.0 提供了全新的导航体验！要开始使用，请点击界面右上角的头像，然后开启 **New navigation** 开关。左侧边栏将变为全新设计，该设计基于我们在过去一年中收集的用户反馈进行了改进。

请通过此议题向我们反馈您的使用体验。我们会根据反馈，在用户群体中逐步启用新的导航，最终将移除旧的导航方式。

### 限制用户的会话时长

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](https://gitlab.cn/docs/user/profile/_index.md#session-duration) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/30819)

{{< /details >}}

管理员可以移除用户登录时的“记住我”选项，这样会话就无法被延长，用户必须重新认证。限制会话时长可以提高实例的安全性。

### 使用 Jira 个人访问令牌进行认证

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](https://gitlab.cn/docs/integration/jira/configure.md#configure-the-integration) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/8222)

{{< /details >}}

以前，只能使用 Jira 用户名和密码对 [Jira 议题集成](../../integration/jira/configure.md) 进行认证。

现在，如果使用 Jira Data Center 和 Jira Server 8.14 及更高版本，可以使用 [Jira 个人访问令牌](https://confluence.atlassian.com/enterprise/using-personal-access-tokens-1026032365.html) 进行认证。与用户名和密码相比，Jira 个人访问令牌是一种更安全的替代方案。

### 在 Service Desk 自动回复中包含议题描述的占位符

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](https://gitlab.cn/docs/user/project/service_desk/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/223751)

{{< /details >}}

对于 Service Desk 请求者来说，在自动发送的感谢邮件中看到他们的原始请求非常有用。

在此版本中，我们添加了一个 `%{ISSUE_DESCRIPTION}` 占位符，以便 Service Desk 管理员可以在感谢邮件中包含原始请求。

## 统一的 DevOps 与安全

### 实时显示合并请求更新

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](https://gitlab.cn/docs/user/project/merge_requests/_index.md)

{{< /details >}}

在处理合并请求时，确保看到的是最新的审批、流水线或其他可能影响合并变更的信息至关重要。以前，这通常意味着需要刷新合并请求或等待轮询更新推送。

我们改进了合并请求中合并按钮和审批组件的体验，使其现在能在合并请求中实时更新。这是一项重大改进，可以加快交付变更的速度，并且在确认看到最新信息后，能更有信心地推进合并请求。

我们正在关注合并请求中更多可进行 [实时改进](https://gitlab.com/groups/gitlab-org/-/epics/1812) 的领域，敬请关注后续更新。

### 批量关闭漏洞时提供原因

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](https://gitlab.cn/docs/user/application_security/vulnerability_report/_index.md#change-status-of-vulnerabilities) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/408366)

{{< /details >}}

在漏洞报告中选中一个或多个漏洞时，可以批量更改它们的状态。

在此版本中，现在可以在选择关闭状态时选择关闭原因，并在更改漏洞状态时添加评论。

### 无需通过批量操作即可添加和移除合规框架

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](https://gitlab.cn/docs/user/compliance/compliance_center/compliance_projects_report.md#apply-a-compliance-framework-to-projects-in-a-group)

{{< /details >}}

在极狐GitLab 15.11 中，我们向合规框架报告添加了批量 [添加](../../user/compliance/compliance_center/compliance_projects_report.md#apply-a-compliance-framework-to-projects-in-a-group) 和 [移除](../../user/compliance/compliance_center/compliance_projects_report.md#remove-a-compliance-framework-from-projects-in-a-group) 合规框架的功能。

现在，在极狐GitLab 16.0 中，可以直接从报告表格的行中为项目添加和移除合规框架。

在极狐GitLab 16.0 之前，必须在群组设置中创建和编辑框架。

现在，在极狐GitLab 16.0 中，也可以在合规框架报告中创建或编辑合规框架。这简化了框架创建工作流程，并减少了管理框架时切换场景的需要。

### 按目标分支名称筛选合规违规行为

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](https://gitlab.cn/docs/user/compliance/compliance_center/compliance_projects_report.md)

{{< /details >}}

在极狐GitLab 16.0 之前，合规违规报告会显示所有分支上的所有违规行为。

现在，可以使用新的 **搜索目标分支** 字段来筛选违规行为，从而可以专注于最关心的分支。

### 为扫描结果策略支持基于角色的审批操作

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](https://gitlab.cn/docs/user/application_security/policies/merge_request_approval_policies.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/8018)

{{< /details >}}

通过基于角色的审批操作，您可以配置扫描结果策略，要求极狐GitLab 支持的角色（包括所有者、维护者和开发者）进行审批。

这比要求个人审批者或指定的用户组更灵活，可以更轻松地基于已在极狐GitLab 中使用的角色大规模地执行策略，特别是在大型组织中。

### 通过基于浏览器的 DAST 引入带外应用安全测试

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](https://gitlab.cn/docs/user/application_security/dast/browser/_index.md)

{{< /details >}}

以前，极狐GitLab 的 DAST 分析器在执行主动检查时不支持回调攻击。这意味着带外应用安全测试 (OAST) 需要独立于 DAST 扫描进行配置。

现在，可以通过 [扩展基于浏览器的 DAST 分析器](../../user/application_security/dast/browser/_index.md) 配置来启用回调攻击，从而运行 OAST。

在此版本中，我们引入了 [BAS.latest.GitLab-ci.yml](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Security/BAS.latest.gitlab-ci.yml) 模板。Breach and Attack Simulation CI/CD 模板包含基于浏览器的 DAST 分析器的作业配置，并启用容器到容器网络，以将扩展的 DAST 扫描添加到 CI/CD 流水线中的服务容器。

我们正在持续迭代开发新的 Breach and Attack Simulation 功能。我们很乐意 [听取您的反馈](https://gitlab.com/gitlab-org/gitlab/-/issues/404809)，了解基于浏览器的 DAST 增加回调攻击功能的情况。

### 使用 CI/CD 流水线导入 Maven/Gradle 软件包

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](https://gitlab.cn/docs/user/packages/package_registry/_index.md#to-import-packages) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/389338)

{{< /details >}}

您是否一直考虑将 Maven 或 Gradle 仓库迁移到极狐GitLab，但一直没能投入时间来规划迁移？极狐GitLab 很自豪地宣布推出 Maven/Gradle 软件包导入工具的 MVC 版本。

现在，可以使用软件包导入工具从任何符合 Maven/Gradle 规范的仓库（如 Artifactory）导入软件包。

要使用该工具，只需创建一个 `config.yml` 文件，其中包含要导入到极狐GitLab 的软件包的详细信息。然后将导入器添加到 `.gitlab-ci.yml` 流水线配置文件中，导入器会完成剩下的工作。它在流水线中运行，动态生成一个子流水线，其中包含将所有软件包导入极狐GitLab 软件包仓库的作业。

### 使用 Scala 从 Maven 仓库下载软件包

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](https://gitlab.cn/docs/user/packages/maven_repository/_index.md#install-a-package) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/212854)

{{< /details >}}

极狐GitLab 软件包仓库现在支持使用 Scala 构建工具 (`sbt`) 下载 Maven 软件包。以前，Scala 用户无法从仓库下载 Maven 软件包，因为不支持基本认证。因此，Scala 用户要么无法使用该仓库，要么必须使用 Maven (`mvn`) 或 Gradle 作为替代方案。

通过添加对 Scala 的支持，我们希望能帮助您将软件包仓库用于数据更密集的项目。

请注意，目前尚不支持使用 `sbt` 发布制品，但如果您对添加发布支持感兴趣，可以关注此议题。

### 在任务、目标和关键结果上添加或解决待办事项

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](https://gitlab.cn/docs/user/todos.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/9750)

{{< /details >}}

我们知道极狐GitLab [待办事项列表](../../user/todos.md) 是一个广泛使用的功能，但它不支持任务、目标和关键结果。

在此版本中，我们引入了在工作项记录上切换待办事项开关的功能。

### 极狐GitLab Pages 独立子域名

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](https://gitlab.cn/docs/user/project/pages/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/9347)

{{< /details >}}

在极狐GitLab 的早期版本中，由于极狐GitLab Pages 默认的 URL 格式，同一顶级群组下的不同极狐GitLab Pages 站点的 cookie 对于同一顶级群组下的其他项目是可见的。

现在，您可以通过为每个极狐GitLab Pages 项目分配一个独立的子域名来保护您的站点。

### 在任务、目标和关键结果上添加表情反应

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](https://gitlab.cn/docs/user/emoji_reactions.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/9987)

{{< /details >}}

现在，随着为工作项添加了表情反应功能，您可以参与到任务、目标和关键结果中。

在此版本之前，只能对议题、合并请求、代码片段和史诗添加反应。

### 通过快速操作更改工作项类型

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](https://gitlab.cn/docs/user/project/quick_actions.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/385227)

{{< /details >}}

借助这个新增的快速操作，您现在可以将关键结果转换为目标。

### 为标签选择自定义颜色

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](https://gitlab.cn/docs/user/project/labels.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/361846)

{{< /details >}}

到目前为止，您只能为标签指定固定数量的颜色。

此版本在标签管理中引入了颜色选择器，允许您为标签选择任意范围的颜色。

### 对任务、目标和关键结果的子记录重新排序

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](https://gitlab.cn/docs/user/okrs.md#reorder-objective-and-key-result-children) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/9548)

{{< /details >}}

如果您是 [任务](../../user/tasks.md) 或 OKR 的用户，您可能不止一次希望能够对组件内的子记录进行重新排序！

通过这项工作，用户现在可以在工作项组件内对子记录进行重新排序，从而指示相对优先级或表明下一步要处理的事项。

### 自定义价值流分析的新阶段事件

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](https://gitlab.cn/docs/user/group/value_stream_analytics/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/361983)

{{< /details >}}

价值流分析扩展了两个新的阶段事件：议题首次分配和合并请求首次分配。
这些事件可用于衡量事项首次分配给用户所需的时间。

为了实现此功能，极狐GitLab 从 16.0 开始存储分配事件的历史记录。这意味着极狐GitLab 16.0 之前的议题和 MR 分配事件不可用。

### 部署冻结激活时显示消息

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](https://gitlab.cn/docs/user/project/releases/_index.md#prevent-unintentional-releases-by-setting-a-deploy-freeze) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/212460)

{{< /details >}}

极狐GitLab 现在会在部署冻结生效时，在环境页面上显示一条消息。这有助于确保您的团队了解何时发生冻结，以及何时不允许进行部署。

### SAST 分析器更新

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](https://gitlab.cn/docs/user/application_security/sast/analyzers.md) | [相关议题](https://gitlab.cn/docs/user/application_security/_index.md)

{{< /details >}}

极狐GitLab SAST 包含 [许多安全分析器](../../user/application_security/sast/_index.md#supported-languages-and-frameworks)，由极狐GitLab 静态分析团队积极维护、更新和支持。我们在 16.0 版本里程碑中发布了以下更新：

- 基于 Semgrep 的分析器包含了更新的 [极狐GitLab 管理的扫描规则](https://gitlab.com/gitlab-org/security-products/sast-rules)。详情请参阅 [变更日志](https://gitlab.com/gitlab-org/security-products/analyzers/semgrep/-/blob/main/CHANGELOG.md#v423)。我们更新了规则以：
  - 更新 OWASP 映射，以表明它们基于 2017 年 OWASP 十大安全风险。感谢 `@artem-fedorov` 的 [社区贡献](https://gitlab.com/gitlab-org/security-products/analyzers/semgrep/-/merge_requests/196)。
  - 处理 `PyYAML.load` 规则中的其他情况。感谢 `@stevep-arm` 的 [社区贡献](https://gitlab.com/gitlab-org/security-products/analyzers/semgrep/-/merge_requests/237)。
  - 根据极狐GitLab 漏洞研究团队的修订，显著改进了 C 规则的描述和指导。
  - 添加了对 [扫描 Scala 代码](https://gitlab.cn/docs/#faster-easier-scala-scanning-in-sast) 的支持。
- 基于 Flawfinder 的分析器现在支持 [传递 `--neverignore` 标志](../../user/application_security/sast/_index.md#security-scanner-configuration) 来忽略注释中的“忽略”指令。详情请参阅 [变更日志](https://gitlab.com/gitlab-org/security-products/analyzers/flawfinder/-/blob/master/CHANGELOG.md#v401)。
- 基于 KICS 的分析器已更新至 KICS 1.7.0 版本。详情请参阅 [变更日志](https://gitlab.com/gitlab-org/security-products/analyzers/kics/-/blob/main/CHANGELOG.md#v401)。
- 基于 MobSF 的分析器现在支持多个模块和项目，解决了几个错误报告。详情请参阅 [变更日志](https://gitlab.com/gitlab-org/security-products/analyzers/kics/-/blob/main/CHANGELOG.md#v401)。

此外，[正如之前宣布的](../../update/deprecations.md#secure-analyzers-major-version-update)，我们在极狐GitLab 16.0 中增加了每个分析器的主版本号。

如果您 [包含极狐GitLab 管理的 SAST 模板](../../user/application_security/sast/_index.md) ([`SAST.gitlab-ci.yml`](https://gitlab.com/gitlab-org/gitlab/blob/master/lib/gitlab/ci/templates/Security/SAST.gitlab-ci.yml)) 并运行极狐GitLab 16.0 或更高版本，您将自动收到这些更新。
要保留特定版本的分析器并防止自动更新，可以 [固定其版本](../../user/application_security/sast/_index.md)。

有关之前的更改，请参阅 [上个月的更新](https://gitlab.cn/releases/2023/04/22/gitlab-15-11-released/#static-analysis-analyzer-updates)。

### 密钥检测更新

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](https://gitlab.cn/docs/user/application_security/secret_detection/_index.md) | [相关议题](https://gitlab.cn/docs/user/application_security/_index.md)

{{< /details >}}

我们定期发布极狐GitLab 密钥检测分析器的更新。在极狐GitLab 16.0 里程碑期间，我们：

- 为以下内容添加了 [极狐GitLab 管理的检测规则](../../user/application_security/secret_detection/_index.md)：
  - Meta、Oculus 和 Instagram API 的访问令牌。
  - Segment Public API 的令牌。
- 将 Gitleaks 扫描引擎更新至 8.16.3 版本。
- [修复了一个错误](https://gitlab.com/gitlab-org/security-products/analyzers/secrets/-/merge_requests/212)，该错误导致在仓库只有一个提交时无法进行扫描。
- [正如之前宣布的](../../update/deprecations.md#secure-analyzers-major-version-update)，将分析器主版本号增加到 `5`。

详情请参阅 [变更日志](https://gitlab.com/gitlab-org/security-products/analyzers/secrets/-/blob/master/CHANGELOG.md#v501)。

如果您 [使用极狐GitLab 管理的密钥检测模板](../../user/application_security/secret_detection/_index.md) ([`Secret-Detection.gitlab-ci.yml`](https://gitlab.com/gitlab-org/gitlab/blob/master/lib/gitlab/ci/templates/Jobs/Secret-Detection.gitlab-ci.yml)) 并运行极狐GitLab 16.0 或更高版本，您将自动收到这些更新。
要保留特定版本的分析器并防止自动更新，可以 [固定其版本](../../user/application_security/secret_detection/_index.md)。

有关之前的更改，请参阅 [上个月的更新](https://gitlab.cn/releases/2023/04/22/gitlab-15-11-released/#static-analysis-analyzer-updates)。

### 基于浏览器的 DAST 性能改进

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](https://gitlab.cn/docs/user/application_security/dast/browser/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/9945)

{{< /details >}}

我们优化了基于浏览器的 DAST 分析器执行扫描的方式。这些改进显著减少了使用基于浏览器的分析器运行 DAST 扫描所需的时间。已完成以下改进：

- 添加了日志摘要统计信息，以帮助确定扫描期间的时间消耗情况。这可以通过包含环境变量 `DAST_BROWSER_LOG="stat:debug"` 来启用。
- 通过并行运行被动检查来优化性能。
- 通过缓存匹配 HTTP 响应正文内容时使用的正则表达式来优化被动检查。
- 优化了 DAST 确定页面是否加载完毕的方式。现在，我们不再等待被排除的文档类型或超出范围的 URL。
- 减少了页面加载后 DOM 快速稳定的页面的等待时间。

通过这些改进，我们观察到基于浏览器的 DAST 扫描时间减少了 50%-80%，具体取决于被扫描应用程序的复杂性和规模。虽然并非所有扫描都能达到这种百分比的降幅，但您的基于浏览器的 DAST 扫描完成所需的时间将显著减少。

### 在 SAST 中更快、更轻松地扫描 Scala

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](https://gitlab.cn/docs/user/application_security/sast/_index.md#supported-languages-and-frameworks) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/362958)

{{< /details >}}

极狐GitLab 静态应用安全测试 (SAST) 现在为 Scala 代码提供基于 Semgrep 的扫描。
这项工作构建在 [极狐GitLab 14.10 中](https://gitlab.cn/releases/2022/04/22/gitlab-14-10-released/#faster-easier-java-scanning-in-sast) 我们之前引入的基于 Semgrep 的 Java 扫描之上。
与我们已经 [过渡到基于 Semgrep 扫描](../../user/application_security/sast/analyzers.md#transition-to-semgrep-based-scanning) 的其他语言一样，Scala 扫描覆盖范围使用极狐GitLab 管理的检测规则来检测各种安全问题。

新的基于 Semgrep 的扫描比现有的基于 SpotBugs 的分析器运行速度快得多。
它在扫描前也不需要编译代码，因此更易于使用。

极狐GitLab 的静态分析和漏洞研究团队共同努力，将规则转换为 Semgrep 格式，保留了大多数现有规则。
我们还在转换过程中对这些规则进行了更新、优化和测试。

如果您使用 [极狐GitLab 管理的 SAST 模板](../../user/application_security/sast/_index.md) ([`SAST.gitlab-ci.yml`](https://gitlab.com/gitlab-org/gitlab/blob/master/lib/gitlab/ci/templates/Security/SAST.gitlab-ci.yml))，那么每当发现 Scala 代码时，基于 Semgrep 和基于 SpotBugs 的分析器都会运行。
在极狐GitLab 旗舰版中，安全仪表盘会合并两个分析器的发现结果，因此您不会看到重复的漏洞报告。

在未来的版本中，我们将更改 [极狐GitLab 管理的 SAST 模板](../../user/application_security/sast/_index.md) ([`SAST.gitlab-ci.yml`](https://gitlab.com/gitlab-org/gitlab/blob/master/lib/gitlab/ci/templates/Security/SAST.gitlab-ci.yml))，使其仅针对 Scala 代码运行基于 Semgrep 的分析器。
基于 SpotBugs 的分析器仍会扫描其他语言的代码，包括 Groovy 和 Kotlin。
如果您希望仅使用基于 Semgrep 的扫描，可以 [提前禁用 SpotBugs](https://gitlab.com/gitlab-org/gitlab/-/issues/412060)。

如果您对新的基于 Semgrep 的 Scala 扫描有任何疑问、反馈或问题，请 [提交议题](https://gitlab.com/gitlab-org/gitlab/-/issues/new?issuable_template=Bug&add_related_issue=362958&issue[title]=Feedback%20on%20SAST%20Semgrep%20Scala%20support&issue[description]=%2Flabel%20~%22group%3A%3Astatic%20analysis%22)，我们将很乐意提供帮助。

### 以用户身份在管理中心创建实例 Runner

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](https://gitlab.cn/docs/runner/register/) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/383139/)

{{< /details >}}

在这个新工作流程中，向极狐GitLab 实例添加新 Runner 需要授权用户在极狐GitLab UI 中创建 Runner 并包含必要的配置元数据。通过这种方法，Runner 现在可以轻松追溯到用户，这将帮助管理员排查构建问题或响应安全事件。

### 当下游流水线被取消时，镜像其状态的触发作业状态

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](https://gitlab.cn/docs/ci/yaml/_index.md#triggerstrategy) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/220794)

{{< /details >}}

以前，配置了 `strategy: depends` 的触发作业会镜像下游流水线的作业状态。如果下游流水线处于 `running` 状态，触发作业也会被标记为 `running`。但不幸的是，如果下游作业未完成且状态为 `canceled`，触发作业的状态会不准确地显示为 `failed`。

在此版本中，我们已经更新了带有 `strategy: depend` 的触发作业，以准确反映下游流水线的状态。当下游流水线被取消时，触发作业也会显示为已取消。

此更改可能会影响您现有的流水线，特别是当您有依赖于触发作业状态被标记为失败的作业时。我们建议您检查流水线配置，并进行必要的调整以适应此行为变更。

### CI/CD 组件

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](https://gitlab.cn/docs/ci/components/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/9945)

{{< /details >}}
在此版本中，我们很高兴地宣布 CI/CD 组件作为实验性功能可用。CI/CD 组件是一个可复用的单一功能构建块，用于组合项目的部分 CI/CD 配置甚至整个流水线。

当与 [`inputs`](../../ci/yaml/includes.md) 关键字结合使用时，CI/CD 组件会变得更加灵活。你可以通过输入值来配置组件以满足确切需求，这些值可用于任务名称、变量、凭据等。

<a id="rest-api-endpoint-to-create-a-runner"></a>

### 创建 Runner 的 REST API 端点

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../api/users.md)

{{< /details >}}

用户现在可以使用新的 REST API 端点 `POST /user/runners` 自动创建与用户关联的 Runner。创建 Runner 时，会生成一个认证令牌。此新端点支持新的极狐GitLab Runner 令牌架构工作流。

<a id="per-cache-fallback-cache-keys-in-cicd-pipelines"></a>

### CI/CD 流水线中每个缓存的备用缓存键

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../ci/caching/_index.md#per-cache-fallback-keys)

{{< /details >}}

使用缓存是加速流水线的好方法，通过重用先前任务或流水线中已获取的依赖项。但尚无缓存时，缓存的优势就会丧失，因为任务必须从头开始获取每个依赖项。

我们之前引入了一个全局定义的备用缓存，当找不到缓存时使用。这对于所有任务使用类似缓存的项目非常有用。现在在 16.0 中，我们通过每个缓存的备用键改进了该功能。你可以为每个任务的缓存定义最多 5 个备用键，大大降低了任务运行时没有可用缓存的风险。如果你有多种不同的缓存，现在可以根据需要使用适当的备用缓存。

<a id="create-a-group-runner-as-a-user"></a>

### 以用户身份创建群组 Runner

{{< details >}}

- Tier: 基础版，专业版，旗舰版

{{< /details >}}

在此新工作流中，向极狐GitLab 群组添加新 Runner 需要授权用户在极狐GitLab UI 中创建 Runner 并包含必要的配置元数据。采用此方法后，Runner 现在可以轻松追溯到用户，这将帮助管理员排查构建问题或响应安全事件。

<a id="configurable-maximum-number-of-included-cicd-configuration-files"></a>

### 可配置的包含 CI/CD 配置文件的最大数量

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../administration/settings/continuous_integration.md)

{{< /details >}}

`include` 关键字让你可以从多个文件组合 CI/CD 配置。例如，你可以将一个冗长的 `.gitlab-ci.yml` 文件拆分成多个文件以提高可读性，或者在多个项目中复用同一个 CI/CD 配置文件。

此前，单个 CI/CD 配置最多可包含 150 个文件，但在极狐GitLab 16.0 中，管理员可以在实例设置中将此限制修改为其他值。

<a id="create-project-runners-as-a-user"></a>

### 以用户身份创建项目 Runner

{{< details >}}

- Tier: 基础版，专业版，旗舰版

{{< /details >}}

在此新工作流中，向项目添加新 Runner 需要授权用户在极狐GitLab UI 中创建 Runner 并包含必要的配置元数据。采用此方法后，Runner 现在可以轻松追溯到用户，这将帮助管理员排查构建问题或响应安全事件。

<a id="rate-limit-for-the-projectsidjobs-api-endpoint-reduced"></a>

### `projects/:id/jobs` API 端点的速率限制降低

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../security/rate_limits.md#project-jobs-api-endpoint)

{{< /details >}}

此前，`GET /api/:version/projects/:id/jobs` 的速率限制为每分钟 2000 次已认证请求。

为了使其与其他速率限制保持一致，并提高效率和可靠性，我们已将限制降低为每分钟 600 次已认证请求。

<a id="gitlab-runner-160"></a>

### 极狐GitLab Runner 16.0

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](https://gitlab.cn/docs/runner)

{{< /details >}}

我们今天还发布了极狐GitLab Runner 16.0！极狐GitLab Runner 是一个轻量级、高度可扩展的代理，用于运行 CI/CD 任务并将结果发送回极狐GitLab 实例。极狐GitLab Runner 与极狐GitLab CI/CD 协同工作，后者是极狐GitLab 附带的开源持续集成服务。

所有变更的列表见极狐GitLab Runner [CHANGELOG](https://jihulab.com/gitlab-cn/gitlab-runner/blob/16-0-stable/CHANGELOG.md)。