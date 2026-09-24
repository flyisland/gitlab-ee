---
stage: AI-powered
group: AI Coding
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 代码审查流程
---

{{< details >}}

- Tier: [基础版](../../../../subscriptions/gitlab_credits.md#for-the-free-tier-on-gitlabcom)，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< collapsible title="模型信息" >}}

- LLM：国内 SOTA 模型
- 可用于 [自部署模型的极狐GitLab Duo](../../../../administration/gitlab_duo_self_hosted/_index.md)

{{< /collapsible >}}

{{< history >}}

- 在极狐GitLab 18.7 中作为[测试版](../../../../policy/development_stages_support.md)引入，对应名为 `duo_code_review_on_agent_platform` 的[功能标志](../../../../administration/feature_flags/_index.md)，默认禁用。
- 在极狐GitLab 18.8 中正式发布（GA）。功能标志 `duo_code_review_on_agent_platform` 已移除。
- 在极狐GitLab 18.10 中，基础版的 JihuLab.com 可通过极狐GitLab Credits 使用。

{{< /history >}}

> [!note]
> 根据你的附加组件，极狐GitLab 运行两种代码审查功能之一：
>
> - Code Review Flow：Agentic 版本，属于 GitLab Duo Agent Platform。
> - GitLab Duo Code Review：非 Agentic 版本，仅适用于具有 GitLab Duo Enterprise 附加组件的用户。
>
> 本页面描述 Agentic 版本。
> 了解[两种功能的对比](../../../project/merge_requests/duo_in_merge_requests.md#use-gitlab-duo-to-review-your-code)。

Code Review Flow 可帮助你利用 Agentic AI 简化代码审查。

这个流程：

- 分析代码变更。
- 提供对代码仓结构和跨文件依赖的增强上下文理解。
- 提供包含可操作反馈的详细审查评论。
- 支持为你的项目定制的自定义审查指令。

该流程仅在极狐GitLab UI 中可用。

<a id="use-the-flow"></a>

使用流程

前提条件：

- 确保满足 [Agent Platform 前提条件](../../_index.md#prerequisites)。
- 确保为顶级群组[开启](_index.md#turn-foundational-flows-on-or-off) **允许基础流** 和 **代码审查**。
- 确保你对该项目具有 开发者、维护者或所有者 [角色](../../../permissions.md)。

要在合并请求上使用 Code Review Flow：

1. 在左侧边栏中，选择 **代码** > **合并请求** 并找到你的合并请求。
1. 使用以下方法之一来请求审查：
   - 将 `@GitLabDuo` 分配为审查者。
   - 在评注中添加快速操作 `/assign_reviewer @GitLabDuo`。

请求审查后，Code Review Flow 将启动一个[会话](../../sessions/_index.md)，你可以监控该会话直到审查完成。

<a id="interact-with-gitlab-duo-in-reviews"></a>

在审查中与极狐GitLab Duo 交互

除了将极狐GitLab Duo 分配为审查者外，你还可以通过以下方式与极狐GitLab Duo 交互：

- 回复其审查评论以请求澄清或替代方法。
- 在任何讨论线程中提及 `@GitLabDuo` 以询问后续问题。

与极狐GitLab Duo 的交互有助于改进建议和反馈，以帮助你改进合并请求。

提供给极狐GitLab Duo 的反馈不会影响对其他合并请求的后续审查。
有一个功能请求要求添加此功能。

<a id="custom-code-review-instructions"></a>

自定义代码审查指令

使用 `mr-review-instructions.yaml` 文件自定义 Code Review Flow 的行为。

你可以使用代码仓特定的审查指令来引导极狐GitLab Duo：

- 关注特定的代码质量方面（如安全性、性能和可维护性）。
- 强制执行项目独有的编码标准和最佳实践。
- 针对特定文件模式应用定制的审查条件。
- 为某些类型的更改提供更详细的解释。

Code Review Flow 不会引用 `AGENTS.md` 和 `SKILL.md` 文件。

要配置自定义指令，请参阅[为极狐GitLab Duo 自定义审查指令](../../customize/review_instructions.md)。

<a id="automatic-reviews-from-gitlab-duo-for-a-project"></a>

项目的极狐GitLab Duo 自动审查

{{< history >}}

- 在极狐GitLab 18.0 中改为 UI 设置。

{{< /history >}}

极狐GitLab Duo 的自动审查可确保项目中的所有合并请求都收到初始审查。
创建合并请求后，极狐GitLab Duo 会对其进行审查，除非：

- 它被标记为草稿。要让极狐GitLab Duo 审查合并请求，请将其标记为就绪。
- 它不包含更改。要让极狐GitLab Duo 审查合并请求，请向其中添加更改。

前提条件：

- 你必须在项目中至少具有[维护者角色](../../../permissions.md)。

要启用 `@GitLabDuo` 自动审查合并请求：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **设置** > **合并请求**。
1. 在 **极狐GitLab Duo 代码审查** 部分，选择 **启用极狐GitLab Duo 自动审查**。
1. 选择 **保存更改**。

有关自动审查的 Credits 使用如何归因的信息，请参阅[确定运行的代码审查功能](../../../project/merge_requests/duo_in_merge_requests.md#determine-which-review-feature-runs)。

<a id="automatic-reviews-from-gitlab-duo-for-groups-and-applications"></a>

群组和应用的极狐GitLab Duo 自动审查

{{< history >}}

- 在极狐GitLab 18.4 中作为[测试版](../../../../policy/development_stages_support.md#beta)引入，对应名为 `cascading_auto_duo_code_review_settings` 的[功能标志](../../../../administration/feature_flags/_index.md)，默认禁用。
- 功能标志 `cascading_auto_duo_code_review_settings` 在极狐GitLab 18.7 中[已移除](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/213240)。

{{< /history >}}

使用群组或应用设置为多个项目启用自动审查。

前提条件：

- 要为群组开启自动审查，需具有该群组的所有者角色。
- 要为所有项目开启自动审查，需成为管理员。

要为群组启用自动审查：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的群组。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **合并请求** 部分。
1. 在 **极狐GitLab Duo 代码审查** 部分，选择 **启用极狐GitLab Duo 自动审查**。
1. 选择 **保存更改**。

要为所有项目启用自动审查：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 在 **极狐GitLab Duo 代码审查** 部分，选择 **启用极狐GitLab Duo 自动审查**。
1. 选择 **保存更改**。

设置从应用级联到群组再到项目。更具体的设置会覆盖更宽泛的设置。

有关自动审查的 Credits 使用如何归因的信息，请参阅[确定运行的代码审查功能](../../../project/merge_requests/duo_in_merge_requests.md#determine-which-review-feature-runs)。

<a id="troubleshooting"></a>

故障排除

<a id="error-dcr4000"></a>

`Error DCR4000`

你可能会遇到一个错误，提示：
`Code Review Flow is not enabled. Contact your group administrator to enable the foundational flow in the top-level group. Error code: DCR4000`。

该错误发生在[基础流](_index.md)或 Code Review Flow 未开启时。

请联系你的管理员，让他们为顶级群组开启 Code Review Flow。

<a id="error-dcr4001"></a>

`Error DCR4001`

你可能会遇到一个错误，提示：
`Code Review Flow is enabled but the service account needs to be verified. Contact your administrator. Error code: DCR4001`。

该错误发生在 Code Review Flow 已开启，但顶级群组的服务账号未就绪或仍在创建中时。

请等待几分钟让服务账号激活，然后重试。如果错误仍然存在，请联系你的管理员，让他们验证已在顶级群组中创建了一个具有开发者角色的服务账号。

<a id="error-dcr4002"></a>

`Error DCR4002`

你可能会遇到一个错误，提示：
`No GitLab Credits remain for this billing period. To continue using Code Review Flow, contact your administrator. Error code: DCR4002`。

该错误发生在当前计费周期内你已用完所有分配的极狐GitLab Credits 时。

请联系你的管理员购买更多 Credits，或等待下一个计费周期开始时 Credits 重置。

<a id="error-dcr4003"></a>

`Error DCR4003`

你可能会遇到一个错误，提示：
`<User>, you don't have permission to create a pipeline for Code Review Flow in this project. Contact your administrator to update your permissions. Error code: DCR4003`。

该错误是因为 Code Review Flow 在 CI/CD 流水线上运行，而你没有权限在该项目中创建流水线。

请联系你的管理员，让他们授予你所需的[执行流水线的权限](../../../permissions.md)。

<a id="error-dcr4004"></a>

`Error DCR4004`

你可能会遇到一个错误，提示：
`<User>, you need to set a default GitLab Duo namespace to use Code Review Flow in this project. Please set a default GitLab Duo namespace in your preferences. Error code: DCR4004`。

该错误发生在极狐GitLab Duo 无法识别启动审查的用户的默认极狐GitLab Duo 命名空间时。

在[设置](../../../profile/preferences.md#set-a-default-gitlab-duo-namespace)中设置一个默认的极狐GitLab Duo 命名空间，然后重新请求审查。

<a id="error-dcr4005"></a>

`Error DCR4005`

你可能会遇到一个错误，提示：
`Code Review Flow could not obtain the required authentication tokens to connect to the GitLab AI Gateway and the GitLab API. Please request a new review. If the issue persists, contact your administrator. Error code: DCR4005`。

Code Review Flow 需要认证令牌才能连接到 GitLab AI Gateway 和 GitLab API。当这些令牌无法生成时会出现该错误，通常是由于极狐GitLab Duo 设置不正确或瞬时基础架构问题。

对于私有化部署实例，请让你的管理员验证[极狐GitLab Duo 配置](../../../../administration/gitlab_duo/configure/gitlab_self_managed.md)。

<a id="error-dcr4006"></a>

`Error DCR4006`

你可能会遇到一个错误，提示：
`Code Review Flow could not add the service account to this project. Contact your administrator to verify that the service account has the required project access. Error code: DCR4006`。

该错误发生在无法将服务账号添加为项目成员时。可能原因包括群组成员锁定已启用，或服务账号没有所需的访问权限。

请联系你的管理员，让他们验证服务账号能否作为开发者添加到项目中。

<a id="error-dcr4007"></a>

`Error DCR4007`

你可能会遇到一个错误，提示：
`Code Review Flow is not available for this project. Contact your administrator to verify that the flow is enabled and the required configuration is in place. Error code: DCR4007`。

该错误发生在流程被禁用或项目缺少必要配置时。

请联系你的管理员，让他们验证[该流程已开启](_index.md#turn-foundational-flows-on-or-off)。

<a id="error-dcr4008"></a>

`Error DCR4008`

你可能会遇到一个错误，提示：
`Code Review Flow could not create the required CI/CD pipeline. Please request a new review. If the problem persists, contact your administrator. Error code: DCR4008`。

该错误发生在 Code Review Flow 无法创建或配置 CI/CD 流水线以运行审查时，可能由 Runner 可用性问题或内部配置问题引起。

尝试重新开始审查。如果错误仍然存在，请联系你的管理员。

<a id="error-dcr4009"></a>

`Error DCR4009`

你可能会遇到一个错误，提示：
`Code Review Flow could not retrieve the source branch for this merge request. Please request a new review. Error code: DCR4009`。

该错误发生在 Code Review Flow 无法检索合并请求的源分支时。

尝试重新开始审查。

<a id="error-dcr5000"></a>

`Error DCR5000`

你可能会遇到一个错误，提示：
`Something went wrong while starting Code Review Flow. Please try again later. Error code: DCR5000`。

该错误发生在 GitLab Duo Agent Platform 因内部错误无法启动 Code Review Flow 时。

尝试重新开始审查。如果错误仍然存在，请联系你的管理员。

<a id="configuration-diagnostic-script"></a>

配置诊断脚本

如果你无法从记录的错误代码中确定 Code Review Flow 问题的原因，可以运行诊断脚本来检查你的极狐GitLab Duo 配置。

该脚本会检查 Code Review Flow 所需的完整配置链，包括适用于所有 GitLab Duo Agent Platform 功能的检查。

更多信息，请参阅[运行配置诊断脚本](../../troubleshooting.md#run-the-configuration-diagnostic-script)。

<a id="related-topics"></a>

相关主题

- [合并请求中的极狐GitLab Duo](../../../project/merge_requests/duo_in_merge_requests.md)
- [Agent Platform AI 模型](../../model_selection.md)