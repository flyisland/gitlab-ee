---
stage: Release Notes
group: Monthly Release
date: 2023-12-21
title: "极狐GitLab 16.7 发布说明"
description: "极狐GitLab 16.7 发布，极狐GitLab Duo 代码建议正式发布"
---

<!-- markdownlint-disable -->
<!-- vale off -->

2023 年 12 月 21 日，极狐GitLab 16.7 发布了，包含以下功能。

<a id="primary-features"></a>

## 主要功能

<a id="gitlab-duo-code-suggestions-is-generally-available"></a>

### 极狐GitLab Duo 代码建议正式发布

<!-- categories: Code Suggestions -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/repository/code_suggestions/_index.md)

{{< /details >}}

[极狐GitLab Duo 代码建议](https://about.gitlab.com/solutions/code-suggestions/) 现已正式发布！

极狐GitLab Duo 代码建议通过补全代码行以及为函数定义和生成逻辑，帮助团队更快、更高效地创建软件。

代码建议以隐私为重要基础构建。存储在极狐GitLab 中的私有、非公开客户代码不会用作训练数据。了解使用代码建议时的[数据使用情况](../../user/gitlab_duo/data_usage.md)。

在正式发布版本中，我们让[代码建议可在多个 IDE 中使用](../../user/project/repository/code_suggestions/_index.md)。代码建议现在也更加直观、响应更迅速。

在 2024 年 2 月 15 日之前，极狐GitLab Duo 代码建议可[免费试用](../../user/project/repository/code_suggestions/_index.md)，但须遵守 [GitLab 测试协议](https://handbook.gitlab.com/handbook/legal/testing-agreement/)。从今天起，您可以购买代码建议作为极狐GitLab 订阅的附加组件，入门价格为每用户每月 9 美元。请[联系我们](https://gitlab.cn/contact-form)开始使用代码建议。

<a id="use-gitlab-pages-without-a-wildcard-dns"></a>

### 无需通配符 DNS 即可使用 GitLab Pages

<!-- categories: Pages -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../administration/pages/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/17584)

{{< /details >}}

以前，要创建 GitLab Pages 项目，您需要一个格式为 name.example.io 或 name.pages.example.io 的域名。这一要求意味着您必须设置通配符 DNS 记录和 SSL/TLS 证书。在极狐GitLab 16.7 中，您可以在没有 DNS 通配符的情况下设置 GitLab Pages 项目。此功能为实验性功能。

移除对通配符证书的要求，减轻了与 GitLab Pages 相关的管理开销。由于组织对通配符 DNS 记录或证书的限制，一些客户无法使用 GitLab Pages。

欢迎在[议题 434372](https://gitlab.com/gitlab-org/gitlab/-/issues/434372)中提供与此功能相关的反馈。

<a id="new-drill-down-view-from-insights-report-charts"></a>

### 从洞察报告图表新增下钻视图

<!-- categories: Value Stream Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/insights/_index.md#drill-down-on-charts) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/372215)

{{< /details >}}

“按优先级创建的缺陷”和“按严重性创建的缺陷”洞察报告新增的下钻功能，让您可以下钻到[议题分析](../../user/group/issues_analytics/_index.md)报告以进行更深入的分析。

我们计划在后续版本中将此功能作为自定义选项包含在其他洞察报告中。

<a id="sast-results-in-mr-changes-view"></a>

### 合并请求变更视图中的 SAST 结果

<!-- categories: SAST -->

{{< details >}}

- 交付方式: JihuLab.com
- 链接: [文档](../../user/application_security/sast/_index.md#merge-request-changes-view) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/10959) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/432704)

{{< /details >}}

SAST 发现项现在会显示在合并请求变更视图中。这让您可以在代码评审过程中更轻松地查看、理解和修复潜在弱点。

包含 SAST 问题的行会在行号旁用符号标记。选择该符号可查看问题列表，然后选择某个问题以查看其详情。

我们已在 JihuLab.com 上启用此功能。我们计划在极狐GitLab 16.8 中为私有化部署实例默认启用该[功能标志](https://gitlab.com/gitlab-org/gitlab/-/issues/410191)。

<a id="cicd-catalog---beta-release"></a>

### CI/CD Catalog - 测试版发布

<!-- categories: Pipeline Composition -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../ci/components/_index.md#cicd-catalog)

{{< /details >}}

极狐GitLab 16.7 迎来了 CI/CD catalog 的测试版发布！该目录是您可以搜索由您、您的组织或公共社区维护的 [CI/CD 组件](../../ci/components/_index.md)的地方。这里是 DevOps 工程师齐聚一堂，共同创建、贡献和分享可复用流水线配置的地方。

与其他复用 CI/CD 配置的方法不同，发布在目录中的 CI/CD 组件具有更好的体验，并且可以轻松添加到您的流水线中。我们邀请您开始测试这个令人兴奋的新功能！您可以试用他人在目录中创建和分享的组件，也可以创建自己的组件并与所有人分享。

虽然这是该功能的初始测试版发布，但我们会继续努力让体验变得更好。我们的目标是让 CI/CD catalog 成为极狐GitLab CI/CD 体验的基本组成部分。

<a id="scale-and-deployments"></a>

## 规模与部署

<a id="add-a-mastodon-handle-to-your-user-profile"></a>

### 在用户个人资料中添加 Mastodon 账号

<!-- categories: User Profile -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/profile/_index.md#add-external-accounts-to-your-user-profile-page) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/428442)

{{< /details >}}

您现在可以在用户个人资料中列出您的 Mastodon 账号。通过这一增强功能，我们现在支持一个联邦宇宙社交网络，这将有助于推进 [ActivityPub for GitLab](https://gitlab.com/groups/gitlab-org/-/epics/11247)。

<a id="group-descriptions-extended-to-500-characters"></a>

### 群组描述扩展到 500 个字符

<!-- categories: Groups & Projects -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/group/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/416146)

{{< /details >}}

群组描述现在最多可包含 500 个字符。如果您尝试保存超过 500 个字符的群组描述，会出现一条警告消息，提示描述过长。感谢 @freznicek 的这一社区贡献！

<a id="search-bar-more-prominent-on-the-search-results-page"></a>

### 搜索结果页面上的搜索栏更加醒目

<!-- categories: Global Search -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/search/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/424619)

{{< /details >}}

搜索结果页面上的搜索栏现在更加醒目。为提高搜索栏的可见性，群组和项目筛选器已移至左侧边栏。

<a id="issues-with-code-more-discoverable-in-advanced-search"></a>

### 高级搜索中带代码的议题更易被发现

<!-- categories: Global Search -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/search/advanced_search.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/421012)

{{< /details >}}

在极狐GitLab 16.7 中，带代码的议题更易被发现。借助高级搜索，您现在可以找到描述中包含代码片段和日志的议题。

<a id="customize-time-format-for-display"></a>

### 自定义显示的时间格式

<!-- categories: User Profile -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/profile/preferences.md#customize-time-format) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/15206)

{{< /details >}}

在此之前，极狐GitLab 仅以 12 小时格式显示时间，且无法更改。

从本版本开始，得益于社区贡献，您可以自定义在议题列表、概览页面或设置状态等位置显示时间所用的格式。您可以将时间显示为：

- 12 小时格式，例如 `2:34 PM`。
- 24 小时格式，例如 `14:34`。

感谢 [Thorben Westerhuys](https://gitlab.com/n0rdlicht)的这一[社区贡献](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/130789)！

在下一个里程碑中，我们将[审查极狐GitLab 产品中显示的所有时间戳](https://gitlab.com/groups/gitlab-org/-/epics/12215)，使其遵循该设置。

<a id="access-the-admin-area-from-the-left-sidebar"></a>

### 从左侧边栏访问管理区域

<!-- categories: Navigation -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../administration/admin_area.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/415854)

{{< /details >}}

管理员现在可以通过左侧边栏底部的链接一步访问管理区域。以前，您必须先选择**搜索或跳转到**，然后选择**管理区域**。此更改应能节省您访问管理区域的时间。

<a id="remove-hardcoded-time-limit-for-migrations-to-complete"></a>

### 移除迁移完成的硬编码时间限制

<!-- categories: Importers -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/group/import/_index.md#limits) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/429867)

{{< /details >}}

通过直接转移进行的极狐GitLab 群组和项目迁移可能因各种原因而卡住。过去，为避免让这些迁移无限期地处于未完成状态，极狐GitLab 会定期执行一个工作进程来识别未在 8 小时内完成的迁移。极狐GitLab 会将这些迁移标记为超时。

对于大型组织，迁移过程可能需要超过 8 小时，因此这一时长并不总能足以正确判断迁移是否卡住。因此，该工作进程可能会错误地将迁移标记为卡住。

在此里程碑中，极狐GitLab 不再使用 8 小时的时间限制，而仅在子工作进程停止工作 24 小时时才将迁移标记为卡住。

<a id="comprehensive-results-of-imports-by-direct-transfer"></a>

### 通过直接转移进行导入的完整结果

<!-- categories: Importers -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/group/import/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/394727)

{{< /details >}}

深知了解导入过程的结果对用户至关重要，在此里程碑中，我们进一步改进了通过直接转移进行导入所呈现的信息。我们现在会在以下位置的极狐GitLab 群组和项目旁显示导入状态徽章：

- [您可以选择要导入的群组和项目的页面](../../user/group/import/_index.md)。
- [列出已导入群组和项目的页面](../../user/group/import/_index.md)。

导入状态徽章包括：

- **未开始**
- **待处理**
- **导入中**
- **失败**
- **超时**
- **已取消**
- **完成**
- **部分完成**

**部分完成徽章**是在本版本中添加的，用于标识已完成的导入过程中有一些条目（例如合并请求或议题）未导入。

已启动导入过程的群组会有一个**查看详情**链接，显示该特定群组已导入的子群组和项目。在那里，您可以通过点击**查看失败项**链接查看无法导入的条目列表（如果有）。**查看失败项**已在[上一个版本中发布](gitlab-16-6-released.md#comprehensive-list-of-items-that-failed-to-be-imported)。

在此里程碑中，我们还改进了这些页面之间通过面包屑进行的导航。

<a id="reopen-service-desk-issues-when-an-external-participant-comments"></a>

### 当外部参与者发表评论时重新打开服务台议题

<!-- categories: Service Desk -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/project/service_desk/configure.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/8549)

{{< /details >}}

您现在可以配置极狐GitLab，使其在外部参与者通过电子邮件对议题添加新评论时重新打开已关闭的议题。这让您即使议题已解决，也能全面了解正在进行的对话。

它还会添加一条提及该议题指派人的内部评论，并为他们创建待办事项。这样您就可以确保再也不会错过后续电子邮件。

<a id="backups-supports-alternate-compression-libraries"></a>

### 备份支持替代压缩库

<!-- categories: Backup/Restore of GitLab instances -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../administration/backup_restore/backup_gitlab.md#backup-compression)

{{< /details >}}

现在，您可以使用 `COMPRESS_CMD` 和 `DECOMPRESS_CMD` 命令，为备份用您选择的替代压缩库覆盖默认的单线程 gzip 压缩库。这让您可以利用并行压缩库，借助现代多核处理器的能力加快备份的压缩阶段。这些命令支持向压缩库传递选项，让您可以调整压缩级别和速度等参数。

<a id="unified-devops-and-security"></a>

## 统一 DevOps 与安全

<a id="define-a-network-policy-with-egress-rules"></a>

### 使用出站规则定义网络策略

<!-- categories: Workspaces -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/workspace/gitlab_agent_configuration.md)

{{< /details >}}

在极狐GitLab 16.7 中，当您配置极狐GitLab Kubernetes Agent 以支持工作区时，现在可以定义带出站规则的网络策略。在极狐GitLab 实例解析为私有 IP 的自托管安装中，或当工作区必须访问私有 IP 范围内的云资源时，请使用此功能。

<a id="add-custom-emoji-to-groups"></a>

### 为群组添加自定义表情符号

<!-- categories: Code Review Workflow, Team Planning -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/emoji_reactions.md)

{{< /details >}}

谁不喜欢用一个恰到好处的表情符号来真正表达自己呢？在极狐GitLab 中评论条目时，您一直使用我们的默认表情符号集来添加回应，但有时这些表情符号不足以表达您的情感。群组现在可以添加自定义表情符号，以便在其项目中广泛使用。自定义表情符号让您可以表达真实感受，并与团队其他成员更清晰地沟通。我们迫不及待想看到您接下来会如何回应。

<a id="complex-merge-request-dependency-chains-now-supported"></a>

### 现在支持复杂的合并请求依赖链

<!-- categories: Code Review Workflow -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/project/merge_requests/dependencies.md#nested-dependencies)

{{< /details >}}

极狐GitLab 合并请求依赖是确保依赖其他变更的代码变更不会以可能破坏代码库的方式合并的好方法。以前，极狐GitLab 不允许复杂的依赖链，这可能导致循环引用或深层嵌套。

围绕依赖层级以及链中条目的限制已被移除。合并请求依赖现在可以更复杂：单个合并请求最多可被 10 个合并请求阻塞，反过来也可阻塞 10 个其他合并请求。更深的依赖链让您可以通过依赖表示更复杂的工作流。我们很期待看到您如何继续扩展此功能的使用。

<a id="notify-me-when-any-merge-request-needs-approval"></a>

### 当任何合并请求需要审批时通知我

<!-- categories: Code Review Workflow -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/profile/notifications.md#edit-notification-settings)

{{< /details >}}

当某个合并请求需要您审批时，您需要收到通知才能采取行动。有些用户只希望在其审批被需要时收到通知，这通常通过按姓名添加用户来评审变更来实现。然而，有些用户希望对其有资格审批的任何合并请求都收到通知，*即使他们并未按姓名被添加为审核人。*

启用**添加为审批人**自定义通知级别，以便为您有资格审批的每个合并请求触发电子邮件和待办事项。这有助于您在流程中更早地了解合并请求，并采取行动使提案得以合并。

<a id="beta-support-for-opentofu"></a>

### 对 OpenTofu 的测试版支持

<!-- categories: Infrastructure as Code -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/infrastructure/iac/_index.md) | [相关议题](https://gitlab.com/gitlab-org/terraform-images/-/issues/114)

{{< /details >}}

如果您正从 Terraform 切换到 OpenTofu，此版本的极狐GitLab 增加了对 OpenTofu 的初步支持。由于 OpenTofu 是 Terraform 的分支，合并请求小组件集成、模块仓库和极狐GitLab 管理的 Terraform 状态默认即可工作。我们在 `gitlab-terraform` 辅助镜像中添加了对 OpenTofu 的支持，以简化极狐GitLab IaC 产品的使用。

极狐GitLab 继续为合并请求小组件、模块仓库和极狐GitLab 管理的 Terraform 状态支持 Terraform。

<a id="custom-time-period-for-access-tokens-rotation"></a>

### 访问令牌轮换的自定义时间段

<!-- categories: System Access -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../api/personal_access_tokens.md#rotate-a-personal-access-token) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/416795)

{{< /details >}}

现在，在轮换访问令牌时，您可以选择输入一个新参数 `expires_at`。这让您可以为令牌创建自定义到期日期。以前，每次轮换都会将到期时间从上一个到期日期延长一周。这个新选项为轮换间隔提供了灵活性。

<a id="use-the-ui-to-assign-users-to-custom-roles"></a>

### 使用 UI 为用户分配自定义角色

<!-- categories: Permissions -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/custom_roles/_index.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/393239)

{{< /details >}}

您现在可以使用 UI 为新用户分配自定义角色，或将现有用户的角色更改为自定义角色。您可以在当前可分配或更改用户角色的任何 UI 位置执行此操作。以前，您只能通过 API 执行此操作。

<a id="enforce-variables-in-scan-execution-policies-with-the-highest-precedence"></a>

### 以最高优先级强制执行扫描执行策略中的变量

<!-- categories: Security Policy Management -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/variables/_index.md#cicd-variable-precedence) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/424028)

{{< /details >}}

CI/CD 变量优先级已改进，现在会优先考虑扫描执行策略中定义的变量。

当组织努力满足合规要求时，一个常见需求是确保在业务关键型应用中启用安全扫描器。

扫描执行策略允许团队强制执行扫描器，并定义默认和自定义 CI/CD 变量。通过这一对 CI/CD 变量优先级的增强，团队可以确信无论流水线如何触发，出于合规考虑定义的变量都保持不变。

<a id="saml-attribute-statements-support-microsoft-saml-attribute-format"></a>

### SAML 属性语句支持 Microsoft SAML 属性格式

<!-- categories: User Management -->

{{< details >}}

- 适用版本: 专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../integration/saml.md#configure-assertions) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/420766)

{{< /details >}}

SAML 属性语句现在支持 Microsoft SAML 属性格式，即 URL 形式。以前，私有化部署实例管理员必须手动配置属性语句，而 JihuLab.com 群组所有者必须向其 SAML 响应添加自定义属性。此更改让私有化部署的极狐GitLab 和 JihuLab.com 都能与 Microsoft 配合工作，无需任何手动配置。

<a id="improvements-to-rich-text-editor"></a>

### 富文本编辑器的改进

<!-- categories: Team Planning, Portfolio Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/rich_text_editor.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/136437)

{{< /details >}}

在极狐GitLab 16.2 中，我们发布了富文本编辑器，作为现有 Markdown 编辑体验的替代方案。富文本编辑器提供“所见即所得”的编辑体验，以及一个可扩展的基础，我们可以在其上为图表、内容嵌入、媒体管理等构建自定义编辑界面。

在极狐GitLab 16.7 中，我们更改了富文本编辑器，使其行为与我们的 Markdown 编辑体验一致，并修复了已报告的错误。我们[更改了标记自动完成模态框中的排序顺序，使其在 Markdown 和富文本编辑器之间保持一致](https://gitlab.com/gitlab-org/gitlab/-/issues/419097)，[修复了富文本编辑器中取消分配快速操作所返回选项的一个错误](https://gitlab.com/gitlab-org/gitlab/-/issues/420344)，[添加了对自定义表情符号的支持](https://gitlab.com/gitlab-org/gitlab/-/issues/422958)，并[更新了快速操作选择下拉菜单的外观和风格，使其在两种编辑体验中保持一致](https://gitlab.com/gitlab-org/gitlab/-/issues/406714)，以及其他改进。

<a id="list-repository-tags-with-new-container-registry-api"></a>

### 使用新的容器镜像仓库 API 列出容器仓库标签

<!-- categories: Container Registry -->

{{< details >}}

- 适用版本: 基础版
- 交付方式: JihuLab.com
- 链接: [文档](../../api/container_registry.md) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/411387)

{{< /details >}}

以前，容器镜像仓库依赖 Docker/OCI [列出镜像标签的镜像仓库 API](https://gitlab.com/gitlab-org/container-registry/-/blob/5208a0ce1600b535e529cd857c842fda6d19ad59/docs/spec/docker/v2/api.md#listing-image-tags) 来在极狐GitLab 中列出和显示标签。此 API 存在显著的性能和可发现性限制。

此 API 执行缓慢，因为针对镜像仓库的网络请求数量会随标签列表中的标签数量而增加。此外，由于该 API 不跟踪发布时间，发布的时间戳常常不正确。在显示基于 Docker manifest 列表或 OCI 索引的镜像（例如多架构镜像）时也存在限制。

为解决这些限制，我们引入了新的镜像仓库[列出容器仓库标签 API](https://gitlab.com/gitlab-org/container-registry/-/blob/5208a0ce1600b535e529cd857c842fda6d19ad59/docs/spec/gitlab/api.md#list-repository-tags)。通过更新用户界面以使用新 API，对容器镜像仓库的请求数量减少到仅一个。发布时间戳也准确了，并且对多架构镜像有更稳健的支持。

此功能仅在 JihuLab.com 上可用。在下一代容器镜像仓库正式发布之前，私有化部署支持会被阻止。要了解更多信息，请参阅[议题 423459](https://gitlab.com/gitlab-org/gitlab/-/issues/423459)。

<a id="rename-projects-with-container-images-in-the-container-registry-on-gitlabcom"></a>

### 在 JihuLab.com 上重命名容器镜像仓库中带有容器镜像的项目

<!-- categories: Container Registry -->

{{< details >}}

- 适用版本: 基础版
- 链接: [文档](../../user/project/working_with_projects.md) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/10433)

{{< /details >}}

在此版本之前，如果某个项目有一个至少包含一个标签的容器仓库，您必须先删除与该项目的所有关联容器镜像，才能重命名该项目。

这是一个真实存在的问题，迫使用户依赖自定义脚本，在使用其他项目名称之前手动删除/移动所有标签，但现在您可以在 JihuLab.com 上重命名项目，即使它们在镜像仓库中有容器镜像！

<a id="filter-by-predefined-date-ranges-in-value-stream-analytics"></a>

### 在价值流分析中按预定义日期范围筛选

<!-- categories: Value Stream Management -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/group/value_stream_analytics/_index.md#data-filters) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/408656)

{{< /details >}}

价值流分析报告现在提供了一组筛选选项，可用于筛选过去 30、60、90 或 180 天的数据。这些新的筛选选项简化了日期选择过程，让您更高效、更友好地了解[开发生命周期中时间花在哪里](https://about.gitlab.com/blog/value-stream-total-time-chart/)。

<a id="support-for-continuous-vulnerability-scanning-for-dependency-scanning"></a>

### 支持依赖扫描的持续漏洞扫描

<!-- categories: Software Composition Analysis -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/continuous_vulnerability_scanning/_index.md) | [相关议题](https://gitlab.com/groups/gitlab-org/-/epics/11474)

{{< /details >}}

持续漏洞扫描现已正式发布。启用 CVS 后，当公告添加到极狐GitLab 公告数据库时，您的项目会自动扫描。如果识别出新的依赖相关漏洞，会自动创建漏洞。

<a id="dast-vulnerability-check-updates"></a>

### DAST 漏洞检查更新

<!-- categories: DAST -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/application_security/dast/browser/checks/_index.md#active-checks)

{{< /details >}}

在 16.7 发布里程碑期间，我们为基于浏览器的 DAST 默认启用了以下主动检查：

- 检查 89.1 取代 ZAP 检查 40018、40019、40020、40021、40022、40024、40027、40033 和 90018，用于识别 SQL 注入。
- 检查 918.1 取代 ZAP 检查 40046，用于识别服务器端请求伪造。
- 检查 98.1 取代 ZAP 检查 7，用于识别 PHP 远程文件包含。
- 检查 917.1 取代 ZAP 检查 90025，用于识别表达式语言注入。
- 检查 1336.1 取代 ZAP 检查 90035，用于识别服务器端模板注入。

<a id="dast-authentication-now-supports-multi-step-login-forms"></a>

### DAST 身份验证现在支持多步登录表单

<!-- categories: DAST -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../user/application_security/dast/browser/configuration/authentication.md#configuration-for-a-multi-step-login-form) | [相关议题](https://gitlab.com/groups/gitlab-org/-/epics/11585)

{{< /details >}}

新的 `DAST_AFTER_LOGIN_ACTIONS` 变量让您可以提供登录后要执行的操作列表。这允许进行多步登录交互，例如 Azure AD 的“使我保持登录状态”工作流。

<a id="updated-sast-rules-to-reduce-false-positive-results"></a>

### 更新 SAST 规则以减少误报结果

<!-- categories: SAST -->

{{< details >}}

- 适用版本: 旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../user/application_security/sast/rules.md#important-rule-changes) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/8170)

{{< /details >}}

我们更新了极狐GitLab SAST 中使用的默认规则集，以提供更高质量的结果。我们分析了此前默认包含的每条规则，然后移除了在大多数代码库中价值不足的规则。

这些规则更改包含在基于 Semgrep 的极狐GitLab SAST [分析器](../../user/application_security/sast/analyzers.md)的更新版本中。除非您[将 SAST 分析器固定到特定版本](../../user/application_security/sast/_index.md)，否则此更新会在极狐GitLab 16.0 或更高版本上自动应用。

在您的流水线使用更新后的分析器运行扫描后，来自已移除规则的现有扫描结果会被[自动解决](../../user/application_security/sast/_index.md#automatic-vulnerability-resolution)。

我们正在[史诗 10907](https://gitlab.com/groups/gitlab-org/-/epics/10907)中开展更多 SAST 规则改进。

<a id="artifactspublic-cicd-keyword-now-generally-available"></a>

### `artifacts:public` CI/CD 关键字现已正式发布

<!-- categories: Job Artifacts -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/yaml/_index.md#artifactspublic) | [相关议题](https://gitlab.com/groups/gitlab-org/-/epics/11667)

{{< /details >}}

以前，`artifacts:public` 关键字仅作为私有化部署实例的默认禁用功能提供。现在在极狐GitLab 16.7 中，我们已为所有用户将 `artifacts:public` 关键字正式发布。您现在可以在 CI/CD 配置文件中使用 `artifacts:public` 关键字来控制作业产物是否应可公开访问。

<a id="improved-ability-to-keep-the-latest-job-artifacts"></a>

### 改进保留最新作业产物的能力

<!-- categories: Job Artifacts -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: JihuLab.com、私有化部署
- 链接: [文档](../../ci/jobs/job_artifacts.md#keep-artifacts-from-most-recent-successful-jobs) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/428408)

{{< /details >}}

在极狐GitLab 13.0 中，我们引入了保留最近成功流水线的作业产物的能力。遗憾的是，该功能还会将所有[失败](https://gitlab.com/gitlab-org/gitlab/-/issues/266958)和[阻塞](https://gitlab.com/gitlab-org/gitlab/-/issues/387087)的流水线标记为最新流水线，无论它们是否是最新的。这导致存储中堆积了产物，必须手动删除。

在极狐GitLab 16.7 中，导致此意外行为的错误已解决。来自失败和阻塞流水线的作业产物仅在它们来自最新流水线时才会保留，否则它们将遵循 `expire_in` 配置。受影响的 JihuLab.com 客户应会看到，被无意保留的产物现在已解锁，并在新的流水线运行后被移除。

**保留最近成功作业的产物**设置会覆盖作业的 `artifacts: expire_in` 配置，并可能导致大量产物在无到期时间的情况下被存储。如果您的流水线创建许多大型产物，它们可能会迅速占满您的项目存储配额。如果不需要此功能，我们建议禁用此设置。

<a id="gitlab-runner-167"></a>

### 极狐GitLab Runner 16.7

<!-- categories: GitLab Runner Core -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](https://gitlab.cn/docs/runner/)

{{< /details >}}

我们今天还发布了极狐GitLab Runner 16.7！极狐GitLab Runner 是轻量级、高度可扩展的代理，用于运行您的 CI/CD 作业并将结果发送回极狐GitLab 实例。极狐GitLab Runner 与极狐GitLab CI/CD 协同工作，后者是极狐GitLab 中包含的开源持续集成服务。

<a id="whats-new"></a>

#### 新增内容

- [为 Docker 执行器实现优雅关闭](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/6359)
- [为 Kubernetes 动态创建带存储类的 PVC 卷](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/27835)

<a id="bug-fixes"></a>

#### 错误修复

- [allow_failure:exit codes 无法与自定义执行器一起使用，因为退出代码始终为 1](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/28658)
- [在 runner 辅助程序和 Kubernetes 执行器的构建容器中更好地处理信号](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/36996)

所有更改的列表见极狐GitLab Runner [CHANGELOG](https://gitlab.com/gitlab-org/gitlab-runner/blob/16-7-stable/CHANGELOG.md)。

<a id="gitlab-runner-supports-slsa-v10-statement"></a>

### 极狐GitLab Runner 支持 SLSA v1.0 声明

<!-- categories: GitLab Runner Core -->

{{< details >}}

- 适用版本: 基础版、专业版、旗舰版
- 交付方式: 私有化部署
- 链接: [文档](../../ci/runners/configure_runners.md#artifact-provenance-metadata) | [相关议题](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/36869)

{{< /details >}}

Runner 现在可以生成符合 [SLSA 1.0](https://slsa.dev/spec/v1.0/)的声明形式的来源元数据。要启用 SLSA 1.0，请在 `.gitlab-ci.yml` 文件中设置 `SLSA_PROVENANCE_SCHEMA_VERSION=v1` 变量。SLSA 1.0 声明计划在极狐GitLab 17.0 中成为默认版本。
