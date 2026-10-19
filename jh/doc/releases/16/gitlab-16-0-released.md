---
stage: Release Notes
group: Monthly Release
date: 2023-05-22
title: "极狐GitLab 16.0 发布说明"
description: "极狐GitLab 16.0 发布，价值流仪表板现已正式发布"
---

<!-- markdownlint-disable -->
<!-- vale off -->

2023 年 5 月 22 日，极狐GitLab 16.0 发布，包含以下功能。

<a id="primary-features"></a>

## 主要功能

<a id="value-streams-dashboard-is-now-generally-available"></a>

### 价值流仪表板现已正式发布

<!-- categories: Value Stream Management, DORA Metrics -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/analytics/value_streams_dashboard.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/403304)

{{< /details >}}

极狐GitLab 价值流仪表板的第一个迭代版本，重点在于让团队能够通过基准化价值流生命周期（[价值流分析](../../user/group/value_stream_analytics/_index.md)、[DORA4](../../user/analytics/dora_metrics.md)）和[漏洞](../../user/application_security/vulnerability_report/_index.md)指标，持续改进软件交付工作流。

组织可以使用[价值流仪表板](../../user/analytics/value_streams_dashboard.md)在一段时间内跟踪和比较这些指标，及早发现下降趋势，了解安全暴露情况，并深入查看单个项目或指标以采取改进措施。

这一综合视图构建为具有统一数据存储的单一应用，使从高管到个人贡献者的所有利益相关者都能了解软件开发生命周期，而无需购买或维护第三方工具。

<a id="upsizing-gitlab-saas-runners-on-linux"></a>

### 扩大 Linux 上极狐GitLab SaaS Runner 的规格

<!-- categories: GitLab Hosted Runners -->

{{< details >}}

- 适用版本: 基础版
- 交付方式: JihuLab.com
- 链接: [文档](../../ci/runners/hosted_runners/linux.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/388162)

{{< /details >}}

您提出了需求，我们倾听了！为了在 CI/CD 构建速度方面做到一流，我们将所有 Linux 上极狐GitLab SaaS Runner 的 vCPU 和 RAM 翻倍，而[成本系数](../../ci/pipelines/compute_minutes.md)保持不变。

我们非常期待看到流水线运行得更快，从而提升生产力。

<a id="gpu-enabled-saas-runners-on-linux"></a>

### Linux 上支持 GPU 的 SaaS Runner

<!-- categories: GitLab Hosted Runners -->

{{< details >}}

- 链接: [文档](../../ci/runners/hosted_runners/linux.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/358026)

{{< /details >}}

我们致力于通过在极狐GitLab Runner 中提供更强大的计算硬件，将 DevSecOps 的最佳实践引入数据科学领域。此前，数据科学家的工作负载可能是计算密集型的，因此在极狐GitLab 中作业可能无法快速执行。

现在，借助 Linux 上支持 GPU 的 SaaS Runner，这些工作负载可以通过 JihuLab.com 无缝支持。

那还等什么？立即试用新的 Runner，并在此[议题](https://gitlab.com/gitlab-org/gitlab/-/issues/403008)中告诉我们您的想法。我们期待听到您的反馈！

<a id="apple-silicon-m1-gitlab-saas-runners-on-macos---beta"></a>

### macOS 上的 Apple silicon (M1) 极狐GitLab SaaS Runner - 测试版

<!-- categories: GitLab Hosted Runners -->

{{< details >}}

- 交付方式: JihuLab.com
- 链接: [文档](../../ci/runners/hosted_runners/macos.md#example-gitlab-ciyml-file) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/342848)

{{< /details >}}

移动 DevOps 团队现在可以在 Apple silicon (M1) [macOS 上的极狐GitLab SaaS Runner](../../ci/runners/hosted_runners/macos.md) 上运行其整个 CI/CD 工作流，为 Apple 生态系统无缝创建、测试和部署应用程序。

其性能最高可达托管 x86-64 macOS Runner 的**三倍**，您将能够加快开发团队构建和部署需要 macOS 的应用程序的速度，并在与极狐GitLab CI/CD 集成的安全、按需的极狐GitLab Runner 构建环境中进行。

<a id="comment-templates"></a>

### 评论模板

<!-- categories: Code Review Workflow, Team Planning -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/profile/comment_templates.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/7565)

{{< /details >}}

当您在议题、史诗或合并请求中发表评论时，可能会重复自己，需要一遍又一遍地写同样的评论。也许您总是需要询问有关缺陷报告的更多信息。也许您在分诊过程中通过快速操作应用标记。或者您只是喜欢用有趣的 gif 或合适的表情符号来结束所有代码评审。🎉

评论模板使您能够创建保存的回复，并可在极狐GitLab 各处的评论框中应用，以加快工作流。要创建评论模板，请转到**用户设置 > 评论模板**，然后填写您的模板。保存后，在任意文本区域选择**插入评论模板**图标，您保存的回复就会被应用。

这是标准化回复并节省时间的好方法！

<a id="update-your-fork-from-the-gitlab-ui"></a>

### 从极狐GitLab UI 更新您的 fork

<!-- categories: Source Code Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/repository/forking_workflow.md#update-your-fork) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/330243)

{{< /details >}}

管理您的 fork 变得更加容易。当您的 fork 落后时，在极狐GitLab UI 中选择**更新 fork**，即可与上游变更保持同步。当您的 fork 领先时，选择**创建合并请求**，将您的变更贡献回上游项目。这两项操作以前都需要使用命令行。

在项目主页和**代码仓库 > 文件**中查看您的 fork 领先（或落后）了多少提交。如果存在合并冲突，UI 会指导您如何使用命令行 Git 解决它们。

<a id="mirror-specific-branches-only"></a>

### 仅镜像特定分支

<!-- categories: Source Code Management -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/repository/mirror/_index.md#mirror-specific-branches) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/1893)

{{< /details >}}

您是否需要镜像一个有很多分支的繁忙代码仓库，但只需要其中几个分支？通过创建仅匹配所需分支的正则表达式，限制您镜像的分支数量。

以前，镜像要求您镜像整个代码仓库或所有受保护分支。这种新的灵活性可以减少镜像推送或拉取的数据量，并使敏感分支远离公共镜像。

<a id="new-web-ide-experience-now-generally-available"></a>

### 新的 Web IDE 体验现已正式发布

<!-- categories: Web IDE -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/web_ide/_index.md)

{{< /details >}}

自推出以来，我们一直在迭代 Web IDE 的可用性、性能和稳定性，这使我们能够在强大的基础上构建远程开发工作区和代码建议等功能。

我们收到了对 Web IDE 测试版的压倒性积极反馈，从极狐GitLab 16.0 开始，我们将其设为极狐GitLab 中默认的多文件代码编辑器。

<a id="workspaces-available-in-beta-for-public-projects"></a>

### 公共项目可用的工作区（测试版）

<!-- categories: Workspaces -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/workspace/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/10122)

{{< /details >}}

不要再花费数小时甚至数天来排查本地开发环境问题，以及解读晦涩难懂的软件包安装错误。现在，您可以在代码中定义一致、稳定且安全的开发环境，并用它来按需创建；这一切都在工作区中完成。

工作区是云端的个人临时开发环境。通过消除对本地开发环境的需求，您可以更多地关注代码，减少对依赖项的担忧。加快加入新项目的流程，在几分钟而不是几天内即可开始工作。

在配置好极狐GitLab Agent for Kubernetes 并在您自托管的集群或所选云平台中[安装依赖项](../../user/workspace/_index.md)后，您可以在`.devfile.yaml` 文件中定义开发环境，并将其存储在公共项目中。然后，您和任何其他有权访问该 Agent 的开发者都可以基于`.devfile.yaml` 文件创建工作区，并直接在嵌入式 Web IDE 中编辑。您将拥有对容器的完整终端访问权限，从而更高效地工作。完成后，或者如果出现问题，您可以关闭工作区，并为下一个开发任务启动一个全新的工作区。

这段短视频将带您了解当前测试版中工作区的生命周期。在[文档](../../user/workspace/_index.md)中详细了解工作区，并在[反馈议题](https://gitlab.com/gitlab-org/gitlab/-/issues/410031)中告诉我们您的想法。

<a id="security-training-with-secureflag"></a>

### 使用 SecureFlag 进行安全培训

<!-- categories: Vulnerability Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/vulnerabilities/_index.md#enable-security-training-for-vulnerabilities) | [相关议题](https://gitlab.com/gitlab-com/alliances/alliances/-/issues/297)

{{< /details >}}

随着安全左移，在没有指导的情况下修复安全发现可能具有挑战性。开发者需要可操作的建议，以便解决漏洞并继续构建功能。与检测到的特定漏洞相关的上下文培训已在极狐GitLab 14.9 中发布。

在此版本中，我们基于漏洞的 CWE 添加了与 SecureFlag 的集成。SecureFlag 的培训解决方案独特之处在于，其实验涉及在实时环境中修复漏洞，这可以迁移到真实环境中。

<a id="token-rotation-api"></a>

### 令牌轮换 API

<!-- categories: System Access -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../security/tokens/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/403042)

{{< /details >}}

以前，要轮换令牌，令牌所有者必须手动创建新令牌并替换现有令牌。

现在，令牌所有者可以使用`:rotate` API 端点以编程方式轮换个人、群组和项目访问令牌。

<a id="ai-powered-workflow-features"></a>

### AI 驱动的工作流功能

<!-- categories: Code Suggestions, Duo Agent Platform, SAST -->

{{< details >}}

- 链接: [文档](../../development/ai_features/_index.md) | [相关议题](https://gitlab.com/groups/gitlab-org/-/epics/10524)

{{< /details >}}

极狐GitLab 正在演变为一个 AI 驱动的 DevSecOps 平台。在过去一个月中，我们推出了 10 个新实验，以提升各种极狐GitLab 功能的效率和生产力，所有这些都利用了 AI。

这些 AI 驱动的工作流在软件开发生命周期的每个阶段都提高了效率并缩短了周期时间。

详细了解 [AI 驱动的工作流](https://about.gitlab.com/gitlab-duo-agent-platform/)

<a id="code-suggestions-improvements"></a>

### 代码建议改进

<!-- categories: Code Suggestions -->

{{< details >}}

- 适用版本: 基础版
- 链接: [文档](../../user/project/repository/code_suggestions/_index.md) | [相关议题](https://gitlab.com/groups/gitlab-org/-/epics/9814)

{{< /details >}}

代码建议现已在 JihuLab.com 上向所有用户免费提供，该功能处于测试版。团队可以借助生成式 AI 提高效率，在您开发时提供代码建议。

我们已将语言支持从最初的六种语言扩展到现在的 13 种语言：C/C++、C#、Go、Java、JavaScript、Python、PHP、Ruby、Rust、Scala、Kotlin 和 TypeScript。

我们每周都在改进代码建议底层 AI 模型，以提高建议质量。请记住，AI 是非确定性的，因此您每周可能不会得到相同的建议。

阅读更多关于这些[改进和后续计划](https://about.gitlab.com/blog/code-suggestions-for-all-during-beta/)的内容。

<a id="error-tracking-is-now-generally-available"></a>

### 错误跟踪现已正式发布

<!-- categories: Observability -->

{{< details >}}

- 适用版本: 基础版
- 交付方式: JihuLab.com
- 链接: [文档](../../operations/error_tracking.md)

{{< /details >}}

极狐GitLab 错误跟踪允许开发者发现和查看其应用程序生成的错误，现已在 JihuLab.com 上正式发布！极狐GitLab 错误跟踪通过在与代码开发、构建、部署和发布相同的界面中直接呈现错误信息，帮助提高效率和意识。

在此版本中，我们同时支持[极狐GitLab 集成错误跟踪](../../operations/error_tracking.md)和[基于 Sentry](../../operations/error_tracking.md)的后端。

<a id="custom-value-streams-for-project-level-value-stream-analytics"></a>

### 项目级价值流分析的自定义价值流

<!-- categories: Value Stream Management -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/group/value_stream_analytics/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/382496)

{{< /details >}}

为了提高对整个工作流的可见性，我们在项目级价值流分析 (VSA) 中添加了[概览阶段](../../user/group/value_stream_analytics/_index.md)和[创建自定义价值流](../../user/group/value_stream_analytics/_index.md)的选项。

在此之前，这些功能仅在群组级 VSA 中可用。

<a id="scale-and-deployments"></a>

## 规模与部署

<a id="rate-limit-for-unauthenticated-users-of-the-projects-list-api"></a>

### 项目列表 API 未认证用户的速率限制

<!-- categories: Groups & Projects -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../administration/settings/rate_limit_on_projects_api.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/388435)

{{< /details >}}

今后，项目列表 API 的未认证用户将受到速率限制。

在 JihuLab.com 上，限制设置为每个唯一 IP 地址每 10 分钟 400 个请求。

私有化部署极狐GitLab 实例的用户默认具有相同的速率限制，但管理员可以根据需要更改速率限制。我们鼓励需要每 10 分钟向项目列表 API 发出超过 400 个请求的用户[注册极狐GitLab 账号](https://gitlab.cn/pricing)。

<a id="self-managed-gitlab-uses-two-database-connections"></a>

### 私有化部署极狐GitLab 使用两个数据库连接

<!-- categories: Cell -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](https://gitlab.cn/docs/omnibus/settings/database/#configuring-multiple-database-connections) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/9627)

{{< /details >}}

从 16.0 开始，私有化部署的极狐GitLab 安装将默认具有两个数据库连接，而不是一个。此更改使私有化部署版本的极狐GitLab 行为与 JihuLab.com 类似，并且是朝着为私有化部署版本的极狐GitLab 启用[用于 CI 功能的独立数据库](https://gitlab.com/groups/gitlab-org/-/epics/7509)迈出的一步。

此更改适用于使用 Omnibus GitLab、GitLab Helm chart、GitLab Operator、极狐GitLab Docker 镜像的安装方法，以及从源代码安装。

<a id="option-to-disable-followers"></a>

### 禁用关注者的选项

<!-- categories: System Access, User Profile -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/profile/_index.md#disable-following-and-being-followed-by-other-users) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/325558)

{{< /details >}}

我们收到了用户的反馈，他们希望防止用户个人资料被不想要的关注者关注。我们倾听了您的顾虑，因此现在，在您的用户个人资料设置中的偏好设置下，您可以禁用关注功能。

当您禁用此功能时，没有人可以关注您，您也无法关注任何人。所有现有的关注和关注者关系都会被移除，计数设置为零。

<a id="delayed-group-and-project-deletion-set-as-default"></a>

### 群组和项目延迟删除设为默认

<!-- categories: Groups & Projects -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/jihulab_com/_index.md#delayed-project-deletion) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/389557)

{{< /details >}}

为防止意外删除项目和群组，从极狐GitLab 16.0 开始，延迟删除功能将默认对所有极狐GitLab 旗舰版和专业版客户开启。

私有化部署用户仍然可以选择定义 1 到 90 天之间的删除延迟期，而 SaaS 用户具有不可调整的默认保留期 7 天。

旗舰版和专业版群组的用户仍然可以通过两步删除流程从群组或项目设置中立即删除群组或项目。

我们相信这一更改将有助于实现更安全的删除流程，并有利于防止意外删除。我们期待您在议题 [#396996](https://gitlab.com/gitlab-org/gitlab/-/issues/396996)中提供反馈。

<a id="gitlab-chart-improvements"></a>

### GitLab chart 改进

<!-- categories: Cloud Native Installation -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](https://gitlab.cn/docs/charts/)

{{< /details >}}

- 更新到极狐GitLab 16.0 也会将 cert-manager 更新到 1.11.x 版本。此 cert-manager 更新包含破坏性变更，您必须[在升级前阅读](https://cert-manager.io/docs/release-notes/release-notes-1.10/#breaking-changes-you-must-read-this-before-you-upgrade)。这些变更包括容器名称的更改，最好在极狐GitLab 的主要版本发布期间进行。要查看更新功能的详细信息，请参阅 [cert-manager 1.11 的发布说明](https://cert-manager.io/docs/releases/release-notes/release-notes-1.11/)。
- 不再支持 PostgreSQL 12。最低要求版本为 PostgreSQL 13，并添加了对 PostgreSQL 14 的支持。极狐GitLab 的新 chart 安装默认包含 PostgreSQL 14，升级必须遵循[升级捆绑的 PostgreSQL 版本](https://gitlab.cn/docs/charts/installation/database_upgrade/)的步骤。
- 更新到极狐GitLab 16.0 包括将 Redis 子 chart 更新到 16.13.2 版本，包括 Redis 6.2.7。
- 我们移除了捆绑的 Grafana chart。如果您使用捆绑的 Grafana，必须切换到 [Grafana Labs 的较新 chart 版本](https://artifacthub.io/packages/helm/grafana/grafana)或来自可信提供商的 Grafana Operator。
- 极狐GitLab 16.0 在 `global.registry.*`配置中包含了 [ webservice 和 Sidekiq 的 registry 服务详细信息](https://gitlab.cn/docs/charts/charts/globals/#configure-registry-settings)以简化配置，因为这些值在两者中都存在。您可以通过覆盖来保留旧行为。
- [最低支持的 Helm 版本](https://gitlab.cn/docs/charts/installation/tools/#helm)为 3.5.2。
- 极狐GitLab Runner 默认版本现在为 Ubuntu 22.04。

<a id="omnibus-improvements"></a>

### Omnibus 改进

<!-- categories: Omnibus Package -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](https://gitlab.cn/docs/omnibus/)

{{< /details >}}

- 不再支持 PostgreSQL 12。最低要求版本为 PostgreSQL 13。使用打包的 PostgreSQL 12 的用户必须在安装极狐GitLab 16.0 之前[执行数据库升级](https://gitlab.cn/docs/omnibus/settings/database/#upgrade-packaged-postgresql-server)。
- Omnibus GitLab docker 镜像的新基础操作系统是 Ubuntu 22.04。
- 极狐GitLab 16.0 禁用了 Consul 的旧遥测端点，这些端点在 Consul 1.9 中已弃用。这使我们能够[将 Consul 更新到较新版本](https://developer.hashicorp.com/consul/docs/v1.12.x/agent/config/config-files#telemetry-parameters)。
- 极狐GitLab 16.0 包含适用于 Red Hat Enterprise Linux (RHEL) 9 及兼容发行版的软件包。
- 极狐GitLab 16.0 包含 [Mattermost 7.10](https://mattermost.com/) 及[安全更新](https://mattermost.com/security-updates/)。建议从早期版本升级。

<a id="additional-registration-features-available-to-free-users"></a>

### 基础版用户可用的其他注册功能

<!-- categories: Product Analytics -->

{{< details >}}

- 适用版本: 基础版
- 交付方式: 私有化部署
- 链接: [文档](../../administration/settings/usage_statistics.md#registration-features-program) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/10508)

{{< /details >}}

运行极狐GitLab 企业版的私有化部署实例的极狐GitLab 基础版客户现在可以在[注册功能](../../administration/settings/usage_statistics.md#registration-features-program)计划下访问另外五项付费功能：

- [密码复杂度策略](../../administration/settings/sign_up_restrictions.md)
- [描述变更历史](../../user/discussions/_index.md#view-description-change-history)
- [议题看板配置](../../user/project/issue_board.md#configurable-issue-boards)
- [维护模式](../../administration/maintenance_mode/_index.md)
- [覆盖率引导的模糊测试](../../user/application_security/coverage_fuzzing/_index.md)

要访问这些功能，请注册极狐GitLab 并通过 [Service Ping](../../administration/settings/usage_statistics.md#enable-registration-features) 向我们发送活动数据。

<a id="import-collaborators-as-an-additional-item-to-import"></a>

### 将协作者作为附加导入条目导入

<!-- categories: Importers -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/import/github.md#select-additional-items-to-import) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/398154)

{{< /details >}}

在极狐GitLab 15.10 中，我们开始在 GitHub 项目导入期间将 GitHub 代码仓库协作者映射为极狐GitLab 项目成员。我们收到了[反馈](https://gitlab.com/gitlab-org/gitlab/-/issues/398154)，称这导致了混淆，一些 GitHub 协作者被意外添加并占用了席位。

在极狐GitLab 16.0 中，我们进行了迭代，并将 GitHub 代码仓库协作者添加到[附加导入条目](../../user/project/import/github.md#select-additional-items-to-import)列表中。这使用户可以选择避免导入这些用户，并了解导入他们可能产生的影响。

此选项默认被选中。保持选中可能会导致新用户在群组或命名空间中占用席位，并被授予[高达项目所有者的权限](../../user/project/import/github.md#collaborators-members)。仅导入直接协作者。外部协作者永远不会被导入。

<a id="filter-github-repositories-to-import"></a>

### 筛选要导入的 GitHub 代码仓库

<!-- categories: Importers -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/import/github.md#filter-repositories-list) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/385113)

{{< /details >}}

如果您在 GitHub 中拥有或协作很多代码仓库，使用当前的筛选选项可能难以找到您想要导入到极狐GitLab 的代码仓库。

为了更容易找到正确的代码仓库，我们添加了额外的筛选器。您现在可以使用三个选项卡列出可导入的代码仓库子集：

- **所有者**，列出您拥有的代码仓库。
- **协作者**，列出您协作的代码仓库。
- **GitHub 组织**，列出属于 GitHub 组织的代码仓库。

在**组织**选项卡上，您可以进一步缩小搜索范围，选择特定组织并仅列出属于该组织的代码仓库。

<a id="mark-to-do-items-completed-by-other-group-or-project-owners-done"></a>

### 将其他群组或项目所有者已完成的待办事项标记为完成

<!-- categories: Groups & Projects, User Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/todos.md#actions-that-mark-a-to-do-item-as-done) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/374726)

{{< /details >}}

当用户为群组或项目提出访问请求时，该请求会出现在群组或项目所有者的待办事项列表中。对于有多个所有者的群组和项目，该请求会出现在每个所有者的待办事项列表中。

通过这项新功能，已由另一位所有者完成的待办事项会在其他所有者的待办事项列表中标记为完成。

<a id="opt-in-to-a-new-navigation-experience"></a>

### 选择启用新的导航体验

<!-- categories: Navigation -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../tutorials/left_sidebar/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/9044)

{{< /details >}}

极狐GitLab 16.0 具有全新的导航体验！要开始使用，请转到 UI 右上角的头像，然后打开**新导航**开关。根据我们过去一年收到的用户反馈，左侧边栏将变为全新改进的设计。

请在[此议题](https://gitlab.com/gitlab-org/gitlab/-/issues/409005)中告诉我们您的体验。根据反馈，我们将逐步在用户群中启用新导航，最后一步是移除旧导航。

<a id="limit-session-length-for-users"></a>

### 限制用户的会话时长

<!-- categories: System Access -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/profile/_index.md#session-duration) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/30819)

{{< /details >}}

管理员可以在用户登录时移除“记住我”选项，这样会话就无法延长，用户被迫重新认证。限制会话时长可以提高实例安全性。

<a id="authenticate-with-jira-personal-access-tokens"></a>

### 使用 Jira 个人访问令牌进行认证

<!-- categories: Settings -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../integration/jira/configure.md#configure-the-integration) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/8222)

{{< /details >}}

以前，您只能使用 Jira 用户名和密码来认证 [Jira 议题集成](../../integration/jira/configure.md)。

现在，如果您使用 Jira Data Center 和 Jira Server 8.14 及更高版本，可以使用 [Jira 个人访问令牌](https://confluence.atlassian.com/enterprise/using-personal-access-tokens-1026032365.html)进行认证。Jira 个人访问令牌是比用户名和密码更安全的替代方案。

<a id="placeholder-for-issue-description-in-service-desk-automated-replies"></a>

### 服务台自动回复中议题描述的占位符

<!-- categories: Service Desk -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/service_desk/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/223751)

{{< /details >}}

服务台请求者在自动感谢邮件回复中看到其原始请求是很有用的。

在此版本中，我们添加了`%{ISSUE_DESCRIPTION}`占位符，以便服务台管理员可以在感谢邮件中包含原始请求。

<a id="unified-devops-and-security"></a>

## 统一 DevOps 与安全

<a id="real-time-merge-request-updates"></a>

### 实时合并请求更新

<!-- categories: Web IDE -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/project/merge_requests/_index.md)

{{< /details >}}

在处理合并请求时，确保您看到的是审批、流水线或其他可能影响您合并变更能力的信息的最新状态非常重要。过去，这意味着刷新合并请求或等待轮询更新。

我们改进了合并请求中合并按钮组件和审批组件的体验，使它们现在可以在合并请求中实时更新。这是一项重大改进，可以提高您交付变更的速度，以及在知道您看到的是最新信息的情况下推进合并请求的信心。

我们正在研究合并请求中更多[实时改进](https://gitlab.com/groups/gitlab-org/-/epics/1812)的领域，请持续关注更新。

<a id="provide-a-reason-when-dismissing-vulnerabilities-in-bulk"></a>

### 批量忽略漏洞时提供原因

<!-- categories: Vulnerability Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/vulnerability_report/_index.md#change-status-of-vulnerabilities) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/408366)

{{< /details >}}

在漏洞报告中选择一个或多个漏洞时，可以批量更改其状态。

通过此版本，您现在可以在选择忽略状态时选择忽略原因，并在更改漏洞状态时添加评论。"

<a id="add-and-remove-compliance-frameworks-without-using-bulk-actions"></a>

### 不使用批量操作添加和移除合规框架

<!-- categories: Compliance Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/compliance/compliance_center/compliance_projects_report.md#apply-a-compliance-framework-to-projects-in-a-group)

{{< /details >}}

在极狐GitLab 15.11 中，我们向合规框架报告添加了批量[添加](../../user/compliance/compliance_center/compliance_projects_report.md#apply-a-compliance-framework-to-projects-in-a-group)和[移除](../../user/compliance/compliance_center/compliance_projects_report.md#remove-a-compliance-framework-from-projects-in-a-group)合规框架的功能。

现在在极狐GitLab 16.0 中，您还可以直接从报告表格行向项目添加和移除合规框架。

在极狐GitLab 16.0 之前，您必须在群组设置中创建和编辑框架。

现在在极狐GitLab 16.0 中，您也可以在合规框架报告中创建或编辑合规框架。这简化了框架创建工作流，并减少了管理框架时切换上下文的需求。

<a id="filter-compliance-violations-by-target-branch-name"></a>

### 按目标分支名称筛选合规违规

<!-- categories: Compliance Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/compliance/compliance_center/compliance_projects_report.md)

{{< /details >}}

在极狐GitLab 16.0 之前，合规违规报告显示所有分支上的所有违规。

现在您可以使用新的**搜索目标分支**字段筛选违规，让您专注于最关心的分支。

<a id="support-role-based-approval-action-for-scan-result-policies"></a>

### 支持扫描结果策略的基于角色的审批操作

<!-- categories: Security Policy Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/policies/merge_request_approval_policies.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/8018)

{{< /details >}}

通过基于角色的审批操作，您可以配置扫描结果策略，要求极狐GitLab 支持的角色（包括所有者、维护者和开发者）进行审批。

这为您提供了额外的灵活性，无需指定单个审批人或定义的用户组，使您更容易基于已在极狐GitLab 中使用的角色大规模执行策略，尤其是在大型组织中。

<a id="introducing-out-of-band-application-security-testing-through-browser-based-dast"></a>

### 通过基于浏览器的 DAST 引入带外应用程序安全测试

<!-- categories: DAST -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/dast/browser/_index.md)

{{< /details >}}

以前，极狐GitLab 的 DAST 分析器在执行主动检查时不支持回调攻击。这意味着带外应用程序安全测试 (OAST) 需要与 DAST 扫描分开配置。

现在，您可以通过[扩展基于浏览器的 DAST 分析器](../../user/application_security/dast/browser/_index.md)配置来运行 OAST，以启用回调攻击。

在此版本中，我们引入了 [BAS.latest.GitLab-ci.yml](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Security/BAS.latest.gitlab-ci.yml) 模板。违规和攻击模拟 CI/CD 模板具有基于浏览器的 DAST 分析器的作业配置，并启用容器到容器网络，以将针对服务容器的扩展 DAST 扫描添加到您的 CI/CD 流水线。

我们正在持续迭代以开发新的违规和攻击模拟功能。我们很乐意[听取您的反馈](https://gitlab.com/gitlab-org/gitlab/-/issues/404809)，了解将回调攻击添加到基于浏览器的 DAST 的情况。

<a id="import-mavengradle-packages-by-using-cicd-pipelines"></a>

### 使用 CI/CD 流水线导入 Maven/Gradle 软件包

<!-- categories: Package Registry -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/packages/package_registry/_index.md#to-import-packages) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/389338)

{{< /details >}}

您是否一直在考虑将 Maven 或 Gradle 代码仓库迁移到极狐GitLab，但一直无法投入时间规划迁移？极狐GitLab 自豪地宣布 Maven/Gradle 软件包导入器的 MVC 版本发布。

您现在可以使用软件包导入器工具从任何符合 Maven/Gradle 规范的仓库（如 Artifactory）导入软件包。

要使用该工具，只需创建一个包含要导入极狐GitLab 的软件包详细信息的 `config.yml` 文件。然后将导入器添加到`.gitlab-ci.yml` 流水线配置文件中，导入器会完成其余工作。它在流水线中运行，动态生成一个子流水线，其中的作业将所有软件包导入到您的极狐GitLab 软件包仓库。

<a id="download-packages-from-the-maven-registry-with-scala"></a>

### 使用 Scala 从 Maven 仓库下载软件包

<!-- categories: Package Registry -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/packages/maven_repository/_index.md#install-a-package) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/212854)

{{< /details >}}

极狐GitLab 软件包仓库现在支持使用 Scala 构建工具（`sbt`）下载 Maven 软件包。以前，Scala 用户无法从仓库下载 Maven 软件包，因为不支持基本认证。因此，Scala 用户要么无法使用该仓库，要么不得不使用 Maven（`mvn`）或 Gradle 作为替代方案。

通过添加对 Scala 的支持，我们希望帮助您在数据密集型项目中使用软件包仓库。

请注意，尚不支持使用 `sbt` 发布产物，但如果您有兴趣添加发布支持，可以关注[议题 408479](https://gitlab.com/gitlab-org/gitlab/-/issues/408479)。

<a id="add-or-resolve-to-do-items-on-tasks-objectives-and-key-results"></a>

### 在任务、目标和关键结果上添加或解决待办事项

<!-- categories: Team Planning -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/todos.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/9750)

{{< /details >}}

我们知道极狐GitLab [待办事项列表](../../user/todos.md)是一项被广泛采用的功能，但它不适用于任务、目标和关键结果。

在此版本中，我们引入了从工作项记录打开或关闭待办事项的功能。

<a id="gitlab-pages-unique-subdomains"></a>

### GitLab Pages 唯一子域名

<!-- categories: Pages -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/pages/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/9347)

{{< /details >}}

在之前的极狐GitLab 版本中，由于 GitLab Pages 默认 URL 格式，同一顶级群组下不同 GitLab Pages 站点的 cookie 对同一顶级群组下的其他项目可见。

现在，您可以通过为每个 GitLab Pages 项目分配唯一子域名来保护您的站点。

<a id="add-emoji-reactions-on-tasks-objectives-and-key-results"></a>

### 在任务、目标和关键结果上添加表情符号回应

<!-- categories: Team Planning -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/emoji_reactions.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/9987)

{{< /details >}}

您现在可以通过为工作项添加表情符号回应来参与任务、目标和关键结果。

在此版本之前，您只能在议题、合并请求、代码片段和史诗上添加回应。

<a id="change-work-item-type-from-quick-action"></a>

### 通过快速操作更改工作项类型

<!-- categories: Portfolio Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/quick_actions.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/385227)

{{< /details >}}

通过这个额外的快速操作，您现在可以将关键结果转换为目标。

<a id="pick-custom-colors-for-labels"></a>

### 为标记选择自定义颜色

<!-- categories: Team Planning -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/project/labels.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/361846)

{{< /details >}}

到目前为止，您只能为标记指定固定数量的颜色。

此版本为标记管理引入了颜色选择器，允许您为标记选择任意范围的颜色。

<a id="reorder-child-records-for-tasks-objectives-and-key-results"></a>

### 重新排序任务、目标和关键结果的子记录

<!-- categories: Portfolio Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/okrs.md#reorder-objective-and-key-result-children) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/9548)

{{< /details >}}

如果您是[任务](../../user/tasks.md)或 OKR 的用户，您很可能不止一次希望我们能够重新排序组件内的子记录！

通过这项工作，用户现在可以在工作项组件内重新排序子记录，从而指示相对优先级或表明下一步要做什么。

<a id="new-stage-events-for-custom-value-stream-analytics"></a>

### 自定义价值流分析的新阶段事件

<!-- categories: Value Stream Management -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/group/value_stream_analytics/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/361983)

{{< /details >}}

价值流分析已扩展了两个新的阶段事件：议题首次指派和合并请求首次指派。这些事件可用于衡量条目首次指派给用户所需的时间。

为实现此功能，极狐GitLab 从 16.0 开始存储指派事件的历史记录。这意味着极狐GitLab 16.0 之前的议题和合并请求指派事件不可用。

<a id="display-message-when-deploy-freeze-is-active"></a>

### 部署冻结生效时显示消息

<!-- categories: Environment Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/releases/_index.md#prevent-unintentional-releases-by-setting-a-deploy-freeze) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/212460)

{{< /details >}}

极狐GitLab 现在会在部署冻结生效时在环境页面上向您显示消息。这有助于确保您的团队了解冻结何时发生，以及何时不允许部署。

<a id="sast-analyzer-updates"></a>

### SAST 分析器更新

<!-- categories: SAST -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/application_security/sast/analyzers.md) | [相关议题](../../user/application_security/_index.md)

{{< /details >}}

极狐GitLab SAST 包含[许多安全分析器](../../user/application_security/sast/_index.md#supported-languages-and-frameworks)，由 GitLab 静态分析团队积极维护、更新和支持。我们在 16.0 发布里程碑期间发布了以下更新：

- 基于 Semgrep 的分析器包含更新的[GitLab 管理的扫描规则](https://gitlab.com/gitlab-org/security-products/sast-rules)。有关更多详细信息，请参阅 [CHANGELOG](https://gitlab.com/gitlab-org/security-products/analyzers/semgrep/-/blob/main/CHANGELOG.md#v423)。我们更新了规则以：
  - 更新 OWASP 映射，以表明它们基于 2017 年 OWASP Top Ten。感谢 [`@artem-fedorov`](https://gitlab.com/artem-fedorov)的这项[社区贡献](https://gitlab.com/gitlab-org/security-products/analyzers/semgrep/-/merge_requests/196)。
  - 处理 `PyYAML.load` 规则中的其他情况。感谢 [`@stevep-arm`](https://gitlab.com/stevep-arm)的这项[社区贡献](https://gitlab.com/gitlab-org/security-products/analyzers/semgrep/-/merge_requests/237)。
  - 根据 GitLab 漏洞研究团队的修订，显著改进 C 规则的描述和指导。
  - 添加对[扫描 Scala 代码](https://gitlab.cn/docs/#faster-easier-scala-scanning-in-sast)的支持。
- 基于 Flawfinder 的分析器现在支持[传递`--neverignore` 标志](../../user/application_security/sast/_index.md#security-scanner-configuration)以忽略注释中的“ignore”指令。有关更多详细信息，请参阅 [CHANGELOG](https://gitlab.com/gitlab-org/security-products/analyzers/flawfinder/-/blob/master/CHANGELOG.md#v401)。
- 基于 KICS 的分析器已更新到 KICS 1.7.0 版本。有关更多详细信息，请参阅 [CHANGELOG](https://gitlab.com/gitlab-org/security-products/analyzers/kics/-/blob/main/CHANGELOG.md#v401)。
- 基于 MobSF 的分析器现在支持多个模块和项目，这解决了多个缺陷报告。有关更多详细信息，请参阅 [CHANGELOG](https://gitlab.com/gitlab-org/security-products/analyzers/kics/-/blob/main/CHANGELOG.md#v401)。

此外，[如之前所宣布](../../update/deprecations.md#secure-analyzers-major-version-update)，作为极狐GitLab 16.0 的一部分，我们提高了每个分析器的主要版本号。

如果您[包含 GitLab 管理的 SAST 模板](../../user/application_security/sast/_index.md)（[`SAST.gitlab-ci.yml`](https://gitlab.com/gitlab-org/gitlab/blob/master/lib/gitlab/ci/templates/Security/SAST.gitlab-ci.yml)）并运行极狐GitLab 16.0 或更高版本，您将自动收到这些更新。要保持在任何分析器的特定版本上并防止自动更新，您可以[固定其版本](../../user/application_security/sast/_index.md)。

有关以前的更改，请参阅[上个月的更新](https://about.gitlab.com/releases/2023/04/22/gitlab-15-11-released/#static-analysis-analyzer-updates)。

<a id="secret-detection-updates"></a>

### 密钥检测更新

<!-- categories: Secret Detection -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/application_security/secret_detection/_index.md) | [相关议题](../../user/application_security/_index.md)

{{< /details >}}

我们定期发布极狐GitLab 密钥检测分析器的更新。在极狐GitLab 16.0 里程碑期间，我们：

- 为以下内容添加了 [GitLab 管理的检测规则](../../user/application_security/secret_detection/_index.md)：
  - Meta、Oculus 和 Instagram API 的访问令牌。
  - Segment Public API 的令牌。
- 将 Gitleaks 扫描引擎更新到 8.16.3 版本。
- [修复了一个缺陷](https://gitlab.com/gitlab-org/security-products/analyzers/secrets/-/merge_requests/212)，该缺陷导致代码仓库只有一个提交时无法扫描。
- 将分析器主要版本增加到 `5`，[如之前所宣布](../../update/deprecations.md#secure-analyzers-major-version-update)。

有关更多详细信息，请参阅 [CHANGELOG](https://gitlab.com/gitlab-org/security-products/analyzers/secrets/-/blob/master/CHANGELOG.md#v501)。

如果您[使用 GitLab 管理的密钥检测模板](../../user/application_security/secret_detection/_index.md)（[`Secret-Detection.gitlab-ci.yml`](https://gitlab.com/gitlab-org/gitlab/blob/master/lib/gitlab/ci/templates/Jobs/Secret-Detection.gitlab-ci.yml)）并运行极狐GitLab 16.0 或更高版本，您将自动收到这些更新。要保持在任何分析器的特定版本上并防止自动更新，您可以[固定其版本](../../user/application_security/secret_detection/_index.md)。

有关以前的更改，请参阅[上个月的更新](https://about.gitlab.com/releases/2023/04/22/gitlab-15-11-released/#static-analysis-analyzer-updates)。

<a id="browser-based-dast-performance-improvements"></a>

### 基于浏览器的 DAST 性能改进

<!-- categories: DAST -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/dast/browser/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/9945)

{{< /details >}}

我们优化了基于浏览器的 DAST 分析器执行扫描的方式。这些改进显著减少了使用基于浏览器的分析器运行 DAST 扫描所需的时间。进行了以下改进：

- 添加了日志摘要统计信息，以帮助确定扫描期间时间花在哪里。可以通过包含环境变量 `DAST_BROWSER_LOG="stat:debug"`来启用。
- 通过并行运行被动检查来优化被动检查。
- 通过缓存匹配 HTTP 响应正文内容时使用的正则表达式来优化被动检查。
- 优化了 DAST 确定页面是否完成加载的方式。现在，我们不再等待被排除的文档类型或范围外的 URL。
- 减少了页面加载后 DOM 快速稳定时的等待时间。

通过这些改进，我们看到基于浏览器的 DAST 扫描时间减少了 50%-80%，具体取决于被扫描应用程序的复杂性和大小。虽然并非所有扫描都能看到这一百分比下降，但您的基于浏览器的 DAST 扫描现在应该需要显著更少的时间来完成。

<a id="faster-easier-scala-scanning-in-sast"></a>

### 更快、更简单的 SAST Scala 扫描

<!-- categories: SAST -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/application_security/sast/_index.md#supported-languages-and-frameworks) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/362958)

{{< /details >}}

极狐GitLab 静态应用程序安全测试 (SAST) 现在为 Scala 代码提供基于 Semgrep 的扫描。这项工作建立在我们[在极狐GitLab 14.10 中](https://about.gitlab.com/releases/2022/04/22/gitlab-14-10-released/#faster-easier-java-scanning-in-sast)之前引入的基于 Semgrep 的 Java 扫描的基础上。与我们[已过渡到基于 Semgrep 扫描](../../user/application_security/sast/analyzers.md#transition-to-semgrep-based-scanning)的其他语言一样，Scala 扫描覆盖范围使用 GitLab 管理的检测规则来检测各种安全问题。

新的基于 Semgrep 的扫描比现有的基于 SpotBugs 的分析器运行速度快得多。它也不需要您在扫描前编译代码，因此使用起来更简单。

GitLab 静态分析和漏洞研究团队合作将规则转换为 Semgrep 格式，保留了大多数现有规则。我们在转换规则时还更新、完善并测试了这些规则。

如果您使用 [GitLab 管理的 SAST 模板](../../user/application_security/sast/_index.md)（[`SAST.gitlab-ci.yml`](https://gitlab.com/gitlab-org/gitlab/blob/master/lib/gitlab/ci/templates/Security/SAST.gitlab-ci.yml)），现在只要发现 Scala 代码，基于 Semgrep 和基于 SpotBugs 的分析器都会运行。在极狐GitLab 旗舰版中，安全仪表板会合并两个分析器的发现，因此您不会看到重复的漏洞报告。

在未来的版本中，我们将更改 [GitLab 管理的 SAST 模板](../../user/application_security/sast/_index.md)（[`SAST.gitlab-ci.yml`](https://gitlab.com/gitlab-org/gitlab/blob/master/lib/gitlab/ci/templates/Security/SAST.gitlab-ci.yml)），使其仅对 Scala 代码运行基于 Semgrep 的分析器。基于 SpotBugs 的分析器仍将扫描其他语言的代码，包括 Groovy 和 Kotlin。如果您希望仅使用基于 Semgrep 的扫描，可以[提前禁用 SpotBugs](https://gitlab.com/gitlab-org/gitlab/-/issues/412060)。

如果您对新的基于 Semgrep 的 Scala 扫描有任何疑问、反馈或问题，请[提交议题](https://gitlab.com/gitlab-org/gitlab/-/issues/new?issuable_template=Bug&add_related_issue=362958&issue[title]=Feedback%20on%20SAST%20Semgrep%20Scala%20support&issue[description]=%2Flabel%20~%22group%3A%3Astatic%20analysis%22)，我们将很乐意提供帮助。

<a id="create-an-instance-runner-in-the-admin-area-as-a-user"></a>

### 以用户身份在管理区域中创建实例 Runner

<!-- categories: Fleet Visibility -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](https://gitlab.cn/docs/runner/register/) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/383139/)

{{< /details >}}

在这个新工作流中，向极狐GitLab 实例添加新 Runner 需要授权用户在极狐GitLab UI 中创建 Runner 并包含必要的配置元数据。通过此方法，Runner 现在可以轻松追溯到用户，这将帮助管理员排查构建问题或响应安全事件。

<a id="trigger-job-mirror-status-of-downstream-pipeline-when-cancelled"></a>

### 取消时触发下游流水线的作业镜像状态

<!-- categories: Pipeline Composition -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../ci/yaml/_index.md#triggerstrategy) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/220794)

{{< /details >}}

以前，使用 `strategy: depends` 配置的触发作业会镜像下游流水线的作业状态。如果下游流水线处于 `running` 状态，触发作业也会被标记为 `running`。遗憾的是，如果下游作业未完成且状态为 `canceled`，触发作业的状态会被错误地标记为 `failed`。

在此版本中，我们更新了使用 `strategy: depend`的触发作业，以准确反映下游流水线的状态。当下游流水线被取消时，触发作业也显示为已取消。

此更改可能会影响您现有的流水线，特别是如果您有依赖触发作业状态被标记为失败的作业。我们建议您审查流水线配置，并进行任何必要的调整以适应此行为变化。

<a id="cicd-components"></a>

### CI/CD 组件

<!-- categories: Pipeline Composition -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../ci/components/_index.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/9945)

{{< /details >}}

在此版本中，我们很高兴地宣布 CI/CD 组件作为实验功能可用。CI/CD 组件是可重用的单一用途构建块，可用于组合项目 CI/CD 配置的一部分，甚至整个流水线。

当与 [`inputs`](../../ci/yaml/includes.md) 关键字结合使用时，CI/CD 组件可以变得更加灵活。您可以通过输入可用于作业名称、变量、凭据等的值，将组件配置为您的确切需求。

<a id="rest-api-endpoint-to-create-a-runner"></a>

### 创建 Runner 的 REST API 端点

<!-- categories: Fleet Visibility -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../api/users.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/390427)

{{< /details >}}

用户现在可以使用新的 REST API 端点 `POST /user/runners` 来自动创建与用户关联的 Runner。创建 Runner 时，会生成认证令牌。此新端点支持新一代极狐GitLab Runner 令牌架构工作流。

<a id="per-cache-fallback-cache-keys-in-cicd-pipelines"></a>

### CI/CD 流水线中按缓存回退缓存键

<!-- categories: Pipeline Composition -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../ci/caching/_index.md#per-cache-fallback-keys) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/22213)

{{< /details >}}

使用缓存是通过重用先前作业或流水线中已获取的依赖项来加速流水线的好方法。但是当还没有缓存时，缓存的好处就失去了，因为作业必须从头开始，获取每个依赖项。

我们之前引入了一个在未找到缓存时使用的单一回退缓存，您可以全局定义。这对于所有作业使用类似缓存的项目很有用。现在在 16.0 中，我们通过按缓存回退键改进了该功能。您可以为每个作业的缓存定义最多 5 个回退键，大大降低了作业在没有有用缓存的情况下运行的风险。如果您有各种各样的缓存，现在可以根据需要使用适当的回退缓存。

<a id="create-a-group-runner-as-a-user"></a>

### 以用户身份创建群组 Runner

<!-- categories: Fleet Visibility -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/383143/)

{{< /details >}}

在这个新工作流中，向极狐GitLab 群组添加新 Runner 需要授权用户在极狐GitLab UI 中创建 Runner 并包含必要的配置元数据。通过此方法，Runner 现在可以轻松追溯到用户，这将帮助管理员排查构建问题或响应安全事件。

<a id="configurable-maximum-number-of-included-cicd-configuration-files"></a>

### 可配置的包含 CI/CD 配置文件最大数量

<!-- categories: Pipeline Composition -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../administration/settings/continuous_integration.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/207270)

{{< /details >}}

`include` 关键字允许您从多个文件组合 CI/CD 配置。例如，您可以将一个很长的`.gitlab-ci.yml` 文件拆分为多个文件以提高可读性，或者在多个项目中重用同一个 CI/CD 配置文件。

以前，单个 CI/CD 配置最多可以包含 150 个文件，但在极狐GitLab 16.0 中，管理员可以在实例设置中修改此限制为不同的值。

<a id="create-project-runners-as-a-user"></a>

### 以用户身份创建项目 Runner

<!-- categories: Fleet Visibility -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/383144)

{{< /details >}}

在这个新工作流中，向项目添加新 Runner 需要授权用户在极狐GitLab UI 中创建 Runner 并包含必要的配置元数据。

通过此方法，Runner 现在可以轻松追溯到用户，这将帮助管理员排查构建问题或响应安全事件。

<a id="rate-limit-for-the-projectsidjobs-api-endpoint-reduced"></a>

### `projects/:id/jobs` API 端点的速率限制降低

<!-- categories: Continuous Integration (CI) -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../rate_limits/non_configurable.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/382985)

{{< /details >}}

以前，`GET /api/:version/projects/:id/jobs`的速率限制为每分钟 2000 个已认证请求。

为了与其他速率限制保持一致并提高效率和可靠性，我们将限制降低到每分钟 600 个已认证请求。

<a id="gitlab-runner-160"></a>

### 极狐GitLab Runner 16.0

<!-- categories: GitLab Runner Core -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](https://gitlab.cn/docs/runner/)

{{< /details >}}

我们今天也发布了极狐GitLab Runner 16.0！极狐GitLab Runner 是运行您的 CI/CD 作业并将结果发送回极狐GitLab 实例的轻量级、高度可扩展的代理。极狐GitLab Runner 与极狐GitLab CI/CD 协同工作，后者是极狐GitLab 中包含的开源持续集成服务。

<a id="whats-new"></a>

#### 新增内容

- [GitLab Runner 用于 Google Compute Engine 的自动扩缩插件 - 实验](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/29217)

所有更改的列表在极狐GitLab Runner [CHANGELOG](https://gitlab.com/gitlab-org/gitlab-runner/blob/16-0-stable/CHANGELOG.md)中
