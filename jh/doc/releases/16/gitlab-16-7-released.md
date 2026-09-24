---
stage: Release Notes
group: Monthly Release
date: 2023-12-21
title: "极狐GitLab 16.7 发布说明"
description: "极狐GitLab 16.7 发布，极狐GitLab Duo 代码建议功能正式 GA"
---

<!-- markdownlint-disable -->
<!-- vale off -->

2023 年 12 月 21 日，极狐GitLab 16.7 发布了，包含以下功能。

<a id="primary-features"></a>

## 主要功能

<a id="gitLab-duo-code-suggestions-is-generally-available"></a>

### 极狐GitLab Duo 代码建议已正式 GA

{{< details >}}

- Tier：专业版，旗舰版
- Offering：JihuLab.com
- Links：[文档](../../user/project/repository/code_suggestions/_index.md)

{{< /details >}}

[极狐GitLab Duo 代码建议](https://gitlab.cn/solutions/code-suggestions/)现已正式 GA！

极狐GitLab Duo 代码建议通过补全代码行和定义并生成函数逻辑，帮助团队更快、更高效地创建软件。

代码建议将隐私作为关键基础构建。存储在极狐GitLab 中的私有、非公开客户代码不会被用作训练数据。详细了解使用代码建议时的[数据使用情况](../../user/gitlab_duo/data_usage.md)。

在正式发布版中，我们已使[代码建议在多个 IDE 中可用](../../user/project/repository/code_suggestions/_index.md)。代码建议现在也更加直观、响应迅速。

在 2024 年 2 月 15 日之前，可根据[《极狐GitLab 测试协议》](https://handbook.gitlab.com/handbook/legal/testing-agreement/)免费试用极狐GitLab Duo 代码建议。从今天起，你可以以每位用户每月 9 美元的入门价格购买代码建议，作为极狐GitLab 订阅的附加组件。请[联系我们](https://gitlab.cn/solutions/gitlab-duo-pro/sales/)开始使用代码建议。

<a id="use-gitLab-pages-without-a-wildcard-dns"></a>

### 无需泛域名 DNS 即可使用极狐GitLab Pages

{{< details >}}

- Tier：基础版，专业版，旗舰版
- Links：[文档](../../administration/pages/_index.md) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/17584)

{{< /details >}}

以前，要创建极狐GitLab Pages 项目，你需要一个类似 name.example.io 或 name.pages.example.io 格式的域名。这意味着你必须设置泛域名 DNS 记录和 SSL/TLS 证书。在极狐GitLab 16.7 中，你可以在没有 DNS 泛域名的情况下设置极狐GitLab Pages 项目。此功能为实验性功能。

取消对泛域名证书的要求减轻了与极狐GitLab Pages 相关的管理开销。一些客户由于组织对泛域名 DNS 记录或证书的限制而无法使用极狐GitLab Pages。

欢迎就此功能提供反馈。

<a id="new-drill-down-view-from-insights-report-charts"></a>

### 从 Insights 报告图表进行新的下钻视图

{{< details >}}

- Tier：旗舰版
- Offering：JihuLab.com
- Links：[文档](../../user/project/insights/_index.md#drill-down-on-charts) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/372215)

{{< /details >}}

借助 Insights 报告，你可以使用可自定义的图表分析随时间变化的模式。在“按优先级创建的 Bug”和“按严重程度创建的 Bug” Insights 报告中新增的下钻功能，允许你下钻到[议题分析](../../user/group/issues_analytics/_index.md)报告进行更深入的分析。

我们计划在后续版本中将此功能作为自定义选项包含在其他 Insights 报告中。

<a id="sast-results-in-mr-changes-view"></a>

### 合并请求变更视图中的 SAST 结果

{{< details >}}

- Tier：旗舰版
- Offering：JihuLab.com
- Links：[文档](../../user/application_security/sast/_index.md#merge-request-changes-view) | [相关史诗](https://jihulab.com/groups/gitlab-cn/-/epics/10959) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/432704)

{{< /details >}}

SAST 发现现在显示在合并请求的变更视图中。这使得在代码审查过程中更容易查看、理解和修复潜在的弱点。

包含 SAST 问题的行在行号旁标记有一个符号。选择该符号可查看问题列表，然后选择一个问题可查看其详细信息。

我们已在 JihuLab.com 上启用了此功能。我们计划在极狐GitLab 16.8 中默认启用此[功能标志](https://jihulab.com/gitlab-cn/gitlab/-/issues/410191)于私有化部署实例。

<a id="cicd-catalog---beta-release"></a>

### CI/CD Catalog - Beta 发布

{{< details >}}

- Tier：基础版，专业版，旗舰版
- Links：[文档](../../ci/components/_index.md#cicd-catalog)

{{< /details >}}

极狐GitLab 16.7 迎来了 CI/CD catalog 的 Beta 发布！在 catalog 中，你可以搜索由你、你的组织或公共社区维护的 [CI/CD 组件](../../ci/components/_index.md)。这是 DevOps 工程师们共同创建、贡献和分享可重用流水线配置的地方。

与重用 CI/CD 配置的其他方法不同，发布在 catalog 中的 CI/CD 组件体验更佳，并且能轻松添加到你的流水线中。我们邀请你开始测试这个令人兴奋的新功能！你可以试用他人在 catalog 中创建和分享的组件，或者创建自己的组件并与所有人分享。

虽然这是该功能的初始 Beta 版本，我们仍会继续努力让体验变得更好。我们的目标是使 CI/CD catalog 成为极狐GitLab CI/CD 体验的基础部分。

## 扩展与部署

<a id="add-a-mastodon-handle-to-your-user-profile"></a>

### 在用户个人资料中添加 Mastodon 账号

{{< details >}}

- Tier：基础版，专业版，旗舰版
- Offering：JihuLab.com
- Links：[文档](../../user/profile/_index.md#add-external-accounts-to-your-user-profile-page) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/428442)

{{< /details >}}

你现在可以在用户个人资料中列出你的 Mastodon 账号。通过此增强功能，我们现在支持联邦宇宙社交网络，这将有助于推进[极狐GitLab 的 ActivityPub](https://jihulab.com/groups/gitlab-cn/-/epics/11247)。

<a id="group-descriptions-extended-to-500-characters"></a>

### 群组描述扩展至 500 个字符

{{< details >}}

- Tier：基础版，专业版，旗舰版
- Offering：JihuLab.com
- Links：[文档](../../user/group/_index.md) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/416146)

{{< /details >}}

群组描述现在最多可包含 500 个字符。如果你尝试保存超过 500 个字符的群组描述，将出现一条警告消息，提示描述太长。感谢 @freznicek 的社区贡献！

<a id="search-bar-more-prominent-on-the-search-results-page"></a>

### 搜索结果页面上的搜索栏更加突出

{{< details >}}

- Tier：基础版，专业版，旗舰版
- Offering：JihuLab.com
- Links：[文档](../../user/search/_index.md) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/424619)

{{< /details >}}

搜索结果页面上的搜索栏现在更加突出。为了提高搜索栏的可见性，群组和项目过滤器已移至左侧边栏。

<a id="issues-with-code-more-discoverable-in-advanced-search"></a>

### 高级搜索中包含代码的议题更易发现

{{< details >}}

- Tier：专业版，旗舰版
- Offering：JihuLab.com
- Links：[文档](../../user/search/advanced_search.md) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/421012)

{{< /details >}}

在极狐GitLab 16.7 中，包含代码的议题变得更易发现。借助高级搜索，你现在可以找到描述中包含代码片段和日志的议题。

<a id="customize-time-format-for-display"></a>

### 自定义显示时间格式

{{< details >}}

- Tier：基础版，专业版，旗舰版
- Offering：JihuLab.com
- Links：[文档](../../user/profile/preferences.md#customize-time-format) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/15206)

{{< /details >}}

在此之前，极狐GitLab 仅以 12 小时制显示时间，且无法更改。

从本版本开始，感谢社区贡献，你可以自定义在议题列表、概览页面或设置状态时显示时间的格式。你可以将时间显示为：

- 12 小时制，例如 `2:34 PM`。
- 24 小时制，例如 `14:34`。

感谢 [Thorben Westerhuys](https://gitlab.com/n0rdlicht) 的[社区贡献](https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/130789)！

在下一个里程碑中，我们将[审计整个极狐GitLab 产品中显示的所有时间戳](https://jihulab.com/groups/gitlab-cn/-/epics/12215)，使其遵循此设置。

<a id="access-the-admin-area-from-the-left-sidebar"></a>

### 从左侧边栏访问管理区域

{{< details >}}

- Tier：基础版，专业版，旗舰版
- Offering：JihuLab.com
- Links：[文档](../../administration/admin_area.md) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/415854)

{{< /details >}}

管理员现在可以通过左侧边栏底部的链接一步访问管理区域。以前，你必须选择 **搜索或跳转到**，然后再选择 **管理区域**。此更改可节省你访问管理区域的时间。

<a id="remove-hardcoded-time-limit-for-migrations-to-complete"></a>

### 移除迁移完成的硬编码时间限制

{{< details >}}

- Tier：基础版，专业版，旗舰版
- Offering：JihuLab.com
- Links：[文档](../../user/group/import/_index.md#limits) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/429867)

{{< /details >}}

通过直接转移进行的极狐GitLab 群组和项目迁移可能因各种原因卡住。过去，为了避免使这些迁移无限期地处于未完成状态，极狐GitLab 会定期执行一个 worker 来识别在 8 小时内未完成的迁移，并将其标记为超时。

对于大型组织，迁移过程可能需要超过 8 小时，因此这个时间长度并不总是足以正确判定迁移是否卡住。因此，这个 worker 可能错误地将迁移标记为卡住。

在此里程碑中，极狐GitLab 不再使用 8 小时的时间限制，而是仅当子 worker 停止工作超过 24 小时时才将迁移标记为卡住。

<a id="comprehensive-results-of-imports-by-direct-transfer"></a>

### 直接转移导入的全面结果

{{< details >}}

- Tier：基础版，专业版，旗舰版
- Offering：JihuLab.com
- Links：[文档](../../user/group/import/_index.md) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/394727)

{{< /details >}}

了解到导入过程的结果对用户至关重要，在此里程碑中，我们进一步改进了直接转移导入所呈现的信息。现在，我们在以下位置显示紧邻极狐GitLab 群组和项目的导入状态徽章：

- [你可以选择要导入的群组和项目的页面](../../user/group/import/_index.md)。
- [列出已导入群组和项目的页面](../../user/group/import/_index.md)。

导入状态徽章包括：

- **未开始**
- **等待中**
- **导入中**
- **失败**
- **超时**
- **已取消**
- **完成**
- **部分完成**

**部分完成** 徽章是在本版本中添加的，用于标识已完成但某些条目（如合并请求或议题）未导入的导入过程。

启动了导入过程的群组有一个 **查看详情** 链接，可以显示该特定群组的已导入子群组和项目。从那里，你可以点击 **查看失败** 链接查看未能导入的条目列表（如果有）。**查看失败** 已在[上次发布](https://about.gitlab.com/releases/2023/11/16/gitlab-16-6-released/#comprehensive-list-of-items-that-failed-to-be-imported)中推出。

在此里程碑中，我们还改进了这些页面之间通过面包屑导航的功能。

<a id="reopen-service-desk-issues-when-an-external-participant-comments"></a>

### 当外部参与者评论时重新打开 Service Desk 议题

{{< details >}}

- Tier：基础版，专业版，旗舰版
- Offering：JihuLab.com
- Links：[文档](../../user/project/service_desk/configure.md) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/8549)

{{< /details >}}

你现在可以配置极狐GitLab，使其在外部参与者通过电子邮件对议题添加新评论时，重新打开已关闭的议题。这让你即使在议题已解决后，也能全面了解仍在进行的对话。

同时，它还会添加一条内部评论，提及议题的指派人并为他们创建待办事项。这样，你就可以确保再也不会错过后续的电子邮件。

<a id="backups-supports-alternate-compression-libraries"></a>

### 备份支持备选压缩库

{{< details >}}

- Tier：基础版，专业版，旗舰版
- Links：[文档](../../administration/backup_restore/backup_gitlab.md#backup-compression)

{{< /details >}}

你现在可以使用 `COMPRESS_CMD` 和 `DECOMPRESS_CMD` 命令，用你选择的备选压缩库覆盖默认的单线程 gzip 压缩库。这使你能够利用并行压缩库，借助现代多核处理器的性能来加速备份的压缩阶段。这些命令支持向压缩库传递选项，允许你调整压缩级别和速度等参数。

## 统一 DevOps 与安全

<a id="define-a-network-policy-with-egress-rules"></a>

### 使用出口规则定义网络策略

{{< details >}}

- Tier：专业版，旗舰版
- Links：[文档](../../user/workspace/gitlab_agent_configuration.md)

{{< /details >}}

在极狐GitLab 16.7 中，你现在可以在为 Kubernetes 配置极狐GitLab Agent 以支持 Workspaces 时，使用出口规则定义网络策略。当你的私有化部署安装中极狐GitLab 实例解析为私有 IP，或者工作区需要访问私有 IP 范围内的云资源时，可以使用此功能。

<a id="add-custom-emoji-to-groups"></a>

### 向群组添加自定义 emoji

{{< details >}}

- Tier：基础版，专业版，旗舰版
- Links：[文档](../../user/emoji_reactions.md)

{{< /details >}}

谁不喜欢用好的 emoji 来真正表达自己呢？在极狐GitLab 中评论各种事项时，你已使用我们默认的 emoji 集来添加反应，但有时候这些 emoji 不足以表达你的情感。现在，群组可以添加自定义 emoji 以在其所有项目中使用。自定义 emoji 让你能够表达真实感受，并与团队其他成员更清晰地沟通。我们迫不及待想看到你接下来的反应。

<a id="complex-merge-request-dependency-chains-now-supported"></a>

### 现支持复杂的合并请求依赖链

{{< details >}}

- Tier：专业版，旗舰版
- Links：[文档](../../user/project/merge_requests/dependencies.md#nested-dependencies)

{{< /details >}}

极狐GitLab 的合并请求依赖关系是确保依赖于其他更改的代码变更不会以可能破坏代码库的方式合并的绝佳方式。以前，极狐GitLab 不允许复杂的依赖链，这可能导致循环引用或深度嵌套。

围绕依赖层次结构和链中项的限制已被移除。现在，合并请求依赖关系可以更加复杂：一个合并请求最多可被 10 个合并请求阻塞，反过来也可以阻塞最多 10 个其他合并请求。更深的依赖链使得通过依赖关系表示更复杂的工作流成为可能。我们很高兴看到你如何使用此功能进行扩展。

<a id="notify-me-when-any-merge-request-needs-approval"></a>

### 当任何合并请求需要审批时通知我

{{< details >}}

- Tier：基础版，专业版，旗舰版
- Links：[文档](../../user/profile/notifications.md#edit-notification-settings)

{{< /details >}}

当合并请求需要你的审批时，你需要收到通知以采取行动。有些用户只希望在需要他们审批时才收到通知，这通常是通过按姓名添加审阅者来完成的。然而，有些用户希望对他们有资格审批的任何合并请求都收到通知，即使他们没有按姓名被添加为审阅者。

启用 **添加为审批人** 自定义通知级别，可以针对你有资格审批的每个合并请求触发邮件和待办事项。这有助于你在流程早期了解合并请求，并采取行动促使提案合并。

<a id="beta-support-for-opentofu"></a>

### 对 OpenTofu 的 Beta 支持

{{< details >}}

- Tier：基础版，专业版，旗舰版
- Offering：JihuLab.com
- Links：[文档](../../user/infrastructure/iac/_index.md) | [相关议题](https://jihulab.com/gitlab-cn/terraform-images/-/issues/114)

{{< /details >}}

如果你正在从 Terraform 切换到 OpenTofu，此极狐GitLab 版本增加了对 OpenTofu 的初步支持。由于 OpenTofu 是 Terraform 的一个分支，MR 小部件集成、模块仓库和极狐GitLab 管理的 Terraform 状态默认可以工作。我们在 `gitlab-terraform` 辅助镜像中添加了对 OpenTofu 的支持，以简化极狐GitLab IaC 产品的使用。

极狐GitLab 继续支持用于 MR 小部件、模块仓库和极狐GitLab 管理的 Terraform 状态的 Terraform。

<a id="custom-time-period-for-access-tokens-rotation"></a>

### 访问令牌轮换的自定义时间周期

{{< details >}}

- Tier：基础版，专业版，旗舰版
- Offering：JihuLab.com
- Links：[文档](../../api/personal_access_tokens.md#rotate-a-personal-access-token) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/416795)

{{< /details >}}

现在，在轮换访问令牌时，你可以选择性地输入一个新参数 `expires_at`。这允许你为令牌创建自定义过期日期。以前，每次轮换都会在上次到期日的基础上将过期时间延长一周。此新选项提供了轮换间隔的灵活性。

<a id="use-the-ui-to-assign-users-to-custom-roles"></a>

### 使用 UI 将用户分配给自定义角色

{{< details >}}

- Tier：旗舰版
- Offering：JihuLab.com
- Links：[文档](../../user/custom_roles/_index.md) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/393239)

{{< /details >}}

你现在可以使用 UI 将自定义角色分配给新用户，或将现有用户的角色更改为自定义角色。你可以在 UI 中当前可以分配或更改用户角色的任何部分执行此操作。以前，你只能通过 API 来完成此操作。

<a id="enforce-variables-in-scan-execution-policies-with-the-highest-precedence"></a>

### 以最高优先级强制执行扫描执行策略中的变量

{{< details >}}

- Tier：旗舰版
- Offering：JihuLab.com
- Links：[文档](../../ci/variables/_index.md#cicd-variable-precedence) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/424028)

{{< /details >}}

CI/CD 变量优先级已得到改进，首先优先考虑在扫描执行策略中定义的变量。

随着各组织致力于满足合规要求，一个常见需求是确保在关键业务应用中启用安全扫描器。

扫描执行策略允许团队强制执行扫描器，并定义默认和自定义 CI/CD 变量。凭借对 CI/CD 变量优先级的这一增强，团队可以确信，无论流水线如何触发，为合规性而定义的变量都保持不变。

<a id="saml-attribute-statements-support-microsoft-saml-attribute-format"></a>

### SAML 属性语句支持 Microsoft SAML 属性格式

{{< details >}}

- Tier：专业版，旗舰版
- Offering：JihuLab.com
- Links：[文档](../../integration/saml.md#configure-assertions) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/420766)

{{< /details >}}

SAML 属性语句现在支持 Microsoft SAML 属性格式，该格式为 URL 形式。以前，私有化部署实例的管理员必须手动配置属性语句，JihuLab.com 群组所有者必须向其 SAML 响应添加自定义属性。此变更使私有化部署的极狐GitLab 和 JihuLab.com 都能与 Microsoft 配合使用，无需任何手动配置。

<a id="improvements-to-rich-text-editor"></a>

### 富文本编辑器改进

{{< details >}}

- Tier：基础版，专业版，旗舰版
- Offering：JihuLab.com
- Links：[文档](../../user/rich_text_editor.md) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/136437)

{{< /details >}}

在极狐GitLab 16.2 中，我们发布了富文本编辑器，作为现有 Markdown 编辑体验的替代。富文本编辑器提供“所见即所得”的编辑体验和一个可扩展的基础，我们可以在此基础上为图表、内容嵌入、媒体管理等构建自定义编辑界面。

在极狐GitLab 16.7 中，我们更改了富文本编辑器，使其行为与我们的 Markdown 编辑体验一致，并修复了已报告的错误。我们[更改了标签自动完成模态中的排序顺序，使其在 Markdown 和富文本编辑器之间保持一致](https://jihulab.com/gitlab-cn/gitlab/-/issues/419097)，[解决了富文本编辑器中取消分配快速操作返回选项的一个错误](https://jihulab.com/gitlab-cn/gitlab/-/issues/420344)，[添加了对自定义 emoji 的支持](https://jihulab.com/gitlab-cn/gitlab/-/issues/422958)，并[更新了快速操作选择下拉菜单的外观和感觉，使其在两种编辑体验中保持一致](https://jihulab.com/gitlab-cn/gitlab/-/issues/406714)，以及其他改进。

<a id="list-repository-tags-with-new-container-registry-api"></a>

### 使用新的容器镜像仓库 API 列出仓库标签

{{< details >}}

- Tier：基础版，专业版，旗舰版
- Links：[文档](../../api/container_registry.md) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/411387)

{{< /details >}}

以前，容器镜像仓库依赖 Docker/OCI [列出镜像标签的仓库 API](https://gitlab.com/gitlab-org/container-registry/-/blob/5208a0ce1600b535e529cd857c842fda6d19ad59/docs/spec/docker/v2/api.md#listing-image-tags) 来在极狐GitLab 中列出和显示标签。此 API 存在显著的性能和可发现性限制。

该 API 性能较慢，因为向仓库发出的网络请求数量随标签列表中标签的数量而增加。此外，由于该 API 不跟踪发布时间，发布的日期戳经常不正确。在根据 Docker manifest list 或 OCI 索引（例如多架构镜像）显示镜像时也存在限制。

为了解决这些限制，我们引入了一个新的仓库[列出仓库标签 API](https://gitlab.com/gitlab-org/container-registry/-/blob/5208a0ce1600b535e529cd857c842fda6d19ad59/docs/spec/gitlab/api.md#list-repository-tags)。通过更新用户界面以使用新的 API，对容器镜像仓库的请求次数减少到仅一次。发布日期戳也准确了，并且对多架构镜像的支持更加健壮。

此功能仅在 JihuLab.com 上可用。私有化部署的支持被阻止，直到下一代容器镜像仓库正式 GA。要了解更多信息，请参阅[议题 423459](https://jihulab.com/gitlab-cn/gitlab/-/issues/423459)。

<a id="rename-projects-with-container-images-in-the-container-registry-on-gitLabcom"></a>

### 在 JihuLab.com 上重命名容器镜像仓库中有容器镜像的项目

{{< details >}}

- Tier：基础版，专业版，旗舰版
- Links：[文档](../../user/project/working_with_projects.md) | [相关史诗](https://jihulab.com/groups/gitlab-cn/-/epics/10433)

{{< /details >}}

在此版本发布之前，你无法重命名至少带有一个标签的容器仓库的项目，除非先删除与该项目关联的所有容器镜像。

这是一个真实存在的问题，迫使用户依赖自定义脚本来手动删除/移动所有标签，然后才能使用不同的项目名称，但现在你可以在 JihuLab.com 上重命名项目，即使它们在注册表中包含容器镜像！

<a id="filter-by-predefined-date-ranges-in-value-stream-analytics"></a>

### 在价值流分析中按预定义日期范围筛选

{{< details >}}

- Tier：基础版，专业版，旗舰版
- Offering：JihuLab.com
- Links：[文档](../../user/group/value_stream_analytics/_index.md#data-filters) | [相关议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/408656)

{{< /details >}}
价值流分析报告现在提供了一组过滤选项，可查看过去 30、60、90 或 180 天的数据。这些新的过滤选项简化了日期选择过程，使其更高效、更用户友好，便于理解[开发生命周期中时间花费在何处](https://about.gitlab.com/blog/value-stream-total-time-chart/)。

<a id="support-for-continuous-vulnerability-scanning-for-dependency-scanning"></a>

### 支持依赖扫描的持续漏洞扫描

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/continuous_vulnerability_scanning/_index.md) | [相关议题](https://gitlab.com/groups/gitlab-org/-/epics/11474)

{{< /details >}}

持续漏洞扫描现已正式发布。启用 CVS 后，当新漏洞添加到极狐GitLab 漏洞数据库时，您的项目会自动进行扫描。如果识别出与依赖项相关的新漏洞，将自动创建漏洞记录。

<a id="dast-vulnerability-check-updates"></a>

### DAST 漏洞检查更新

{{< details >}}

- Tier: 旗舰版
- Links: [文档](../../user/application_security/dast/browser/checks/_index.md#active-checks)

{{< /details >}}

在 16.7 版本发布里程碑中，我们默认启用了以下基于浏览器的 DAST 主动检查：

- 检查 89.1 替代了 ZAP 检查 40018、40019、40020、40021、40022、40024、40027、40033 和 90018，用于识别 SQL 注入。
- 检查 918.1 替代了 ZAP 检查 40046，用于识别服务端请求伪造。
- 检查 98.1 替代了 ZAP 检查 7，用于识别 PHP 远程文件包含。
- 检查 917.1 替代了 ZAP 检查 90025，用于识别表达式语言注入。
- 检查 1336.1 替代了 ZAP 检查 90035，用于服务端模板注入。

<a id="dast-authentication-now-supports-multi-step-login-forms"></a>

### DAST 认证现在支持多步骤登录表单

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Links: [文档](../../user/application_security/dast/browser/configuration/authentication.md#configuration-for-a-multi-step-login-form) | [相关议题](https://gitlab.com/groups/gitlab-org/-/epics/11585)

{{< /details >}}

新增的 `DAST_AFTER_LOGIN_ACTIONS` 变量允许您提供登录后要执行的操作列表。这支持多步骤登录交互，例如 Azure AD 的"保持登录"工作流。

<a id="updated-sast-rules-to-reduce-false-positive-results"></a>

### 更新了 SAST 规则以减少误报结果

{{< details >}}

- Tier: 旗舰版
- Links: [文档](../../user/application_security/sast/rules.md#important-rule-changes) | [相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/8170)

{{< /details >}}

我们更新了极狐GitLab SAST 中使用的默认规则集，以提供更高质量的结果。我们分析了之前默认包含的每条规则，然后移除了在大多数代码库中价值不高的规则。

这些规则变更包含在基于 Semgrep 的极狐GitLab SAST [分析器](../../user/application_security/sast/analyzers.md)的更新版本中。除非您[将 SAST 分析器固定至特定版本](../../user/application_security/sast/_index.md)，否则此更新将在极狐GitLab 16.0 或更新版本中自动应用。

在流水线使用更新后的分析器运行扫描后，被移除规则所对应的现有扫描结果将[自动解决](../../user/application_security/sast/_index.md#automatic-vulnerability-resolution)。

我们正在[史诗 10907](https://gitlab.com/groups/gitlab-org/-/epics/10907) 中努力进行更多 SAST 规则改进。

<a id="artifacts-public-cicd-keyword-now-generally-available"></a>

### `artifacts:public` CI/CD 关键字现已正式发布

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../ci/yaml/_index.md#artifactspublic) | [相关议题](https://gitlab.com/groups/gitlab-org/-/epics/11667)

{{< /details >}}

以前，`artifacts:public` 关键字仅作为私有化部署实例的默认禁用功能提供。现在在极狐GitLab 16.7 中，我们已使 `artifacts:public` 关键字对所有用户正式可用。您现在可以在 CI/CD 配置文件中使用 `artifacts:public` 关键字来控制作业产物是否可公开访问。

<a id="improved-ability-to-keep-the-latest-job-artifacts"></a>

### 增强保留最新作业产物的能力

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Links: [文档](../../ci/jobs/job_artifacts.md#keep-artifacts-from-most-recent-successful-jobs) | [相关议题](https://gitlab.com/gitlab-org/gitlab/-/issues/428408)

{{< /details >}}

在极狐GitLab 13.0 中，我们引入了一项功能，可以保留来自最近成功流水线的作业产物。遗憾的是，该功能也将所有[失败的](https://gitlab.com/gitlab-org/gitlab/-/issues/266958)和[阻塞的](https://gitlab.com/gitlab-org/gitlab/-/issues/387087)流水线标记为最新流水线，无论它们是否真的是最新的。这导致存储中产物堆积，必须手动删除。

在极狐GitLab 16.7 中，导致此意外行为的错误已得到解决。来自失败和阻塞流水线的作业产物仅在它们来自最新流水线时才被保留，否则将遵循 `expire_in` 配置。受影响的 JihuLab.com 客户应会看到，无意中保留的产物现在已解锁，并在新的流水线运行后被移除。

**保留最近成功作业的产物**设置会覆盖作业的 `artifacts: expire_in` 配置，并可能导致大量无过期时间的产物被存储。如果您的流水线创建了许多大型产物，它们会迅速占满您的项目存储配额。如果不需要此功能，我们建议禁用此设置。

<a id="gitlab-runner-167"></a>

### 极狐GitLab Runner 16.7

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](https://gitlab.cn/docs/runner)

{{< /details >}}

今天，我们还发布了极狐GitLab Runner 16.7！极狐GitLab Runner 是轻量级、高度可扩展的代理，负责运行您的 CI/CD 作业并将结果发送回极狐GitLab 实例。极狐GitLab Runner 与极狐GitLab CI/CD（极狐GitLab 内置的开源持续集成服务）协同工作。

#### 新功能

- [为 Docker 执行器实现优雅关闭](https://jihulab.com/gitlab-cn/gitlab-runner/-/issues/6359)
- [为 Kubernetes 使用存储类动态创建 PVC 卷](https://jihulab.com/gitlab-cn/gitlab-runner/-/issues/27835)

#### 错误修复

- [allow_failure:exit codes 无法与自定义执行器一起使用，因为退出代码始终为 1](https://jihulab.com/gitlab-cn/gitlab-runner/-/issues/28658)
- [为 Kubernetes 执行器在 runner helper 和构建容器中添加更好的信号处理](https://jihulab.com/gitlab-cn/gitlab-runner/-/issues/36996)

所有变更列表请参见极狐GitLab Runner [变更日志](https://jihulab.com/gitlab-cn/gitlab-runner/blob/16-7-stable/CHANGELOG.md)。

<a id="gitlab-runner-supports-slsa-v10-statement"></a>

### 极狐GitLab Runner 支持 SLSA v1.0 声明

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Links: [文档](../../ci/runners/configure_runners.md#artifact-provenance-metadata) | [相关议题](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/36869)

{{< /details >}}

Runner 现在可以生成符合 [SLSA 1.0](https://slsa.dev/spec/v1.0/) 的声明，其中包含出处元数据。要启用 SLSA 1.0，请在 `.gitlab-ci.yml` 文件中设置 `SLSA_PROVENANCE_SCHEMA_VERSION=v1` 变量。SLSA 版本 1.0 声明计划在极狐GitLab 17.0 中成为默认版本。

## 相关主题

- [UI 改进](https://papercuts.gitlab.com/?milestone=16.7)
- [弃用和移除](../../update/deprecations.md)
- [升级说明](../../update/versions/_index.md)