---
stage: AI-powered
group: AI Coding
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab Duo 代码审查（非 Agentic）
---

{{< details >}}

- Tier: 专业版，旗舰版
- Add-on: GitLab Duo Enterprise
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< collapsible title="模型信息" >}}

- [默认 LLM](model_selection.md#default-models)
- 在 [自部署模型的 极狐GitLab Duo](../../administration/gitlab_duo_self_hosted/_index.md) 上可用：是

{{< /collapsible >}}

{{< history >}}

- 在极狐GitLab 17.5 中作为[实验](../../policy/development_stages_support.md#experiment)引入，受两个功能标志控制：`ai_review_merge_request` 和 `duo_code_review_chat`，默认均禁用。
- 功能标志 `ai_review_merge_request` 和 `duo_code_review_chat` 在 17.10 中于 JihuLab.com 和私有化部署上默认启用。
- 在极狐GitLab 17.10 中[更改为](https://gitlab.com/gitlab-org/gitlab/-/issues/516234)测试版。
- 在极狐GitLab 18.0 中更改为包含专业版。
- 功能标志 `ai_review_merge_request` 在极狐GitLab 18.1 中[移除](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/190639)。
- 功能标志 `duo_code_review_chat` 在极狐GitLab 18.1 中[移除](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/190640)。
- 在极狐GitLab 18.1 中 GA。
- 在极狐GitLab 18.3 中[更改为](https://gitlab.com/gitlab-org/gitlab/-/issues/524929)在自部署模型的极狐GitLab Duo 上以测试版提供。
- 在极狐GitLab 18.4 中[更改为](https://gitlab.com/gitlab-org/gitlab/-/issues/548975)在自部署模型的极狐GitLab Duo 上 GA。

{{< /history >}}

> [!note]
> 根据您的插件，极狐GitLab 运行两种代码审查功能之一：
>
> - Code Review Flow：Agentic 版本，属于极狐GitLab Duo Agent Platform。
> - 极狐GitLab Duo 代码审查：非 Agentic 版本，仅适用于拥有 GitLab Duo Enterprise 插件的用户。
>
> 本页面介绍非 Agentic 版本。
> 了解[两种功能的对比](../project/merge_requests/duo_in_merge_requests.md#use-gitlab-duo-to-review-your-code)。

极狐GitLab Duo 代码审查可帮助您简化项目中的代码审查。

<a id="use-gitlab-duo-code-review"></a>

## 使用极狐GitLab Duo 代码审查

当您的合并请求准备好接受审查时，可使用极狐GitLab Duo 代码审查进行初步审查：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **代码** > **合并请求** 并找到您的合并请求。
1. 在评论框中，输入快速操作 `/assign_reviewer @GitLabDuo`，或将极狐GitLab Duo 指定为审查者。

<a id="contextual-awareness"></a>

### 上下文感知

当您使用极狐GitLab Duo 代码审查时，以下数据会发送给大语言模型：

- 合并请求标题
- 合并请求描述
- 更改前的文件内容（用于上下文）
- 合并请求差异
- 文件名
- 自定义指令

要指定排除的内容，请参阅[从代码审查中排除上下文](context.md#exclude-context-from-code-review)。

<a id="interact-with-gitlab-duo-in-reviews"></a>

## 在审查中与极狐GitLab Duo 交互

您可以在评论中提及 `@GitLabDuo`，以在合并请求中与极狐GitLab Duo 交互。您可以
就其审查评论提出后续问题，或在合并请求的任何讨论主题中提问。

与极狐GitLab Duo 的交互有助于在您改进合并请求的过程中优化建议和反馈。

提供给极狐GitLab Duo 的反馈不会影响后续对其他合并请求的审查。

<a id="custom-code-review-instructions"></a>

## 自定义代码审查指令

您可以创建自定义的合并请求审查指令，以确保项目中一致且特定的代码审查标准。

更多信息，请参阅[为极狐GitLab Duo 自定义审查指令](customize_duo/review_instructions.md)。

<a id="automatic-reviews-from-gitlab-duo-for-a-project"></a>

## 项目的极狐GitLab Duo 自动审查

{{< history >}}

- 在极狐GitLab 18.0 中[更改为](https://gitlab.com/gitlab-org/gitlab/-/issues/506537) UI 设置。

{{< /history >}}

极狐GitLab Duo 的自动审查可确保项目中所有合并请求都获得初步审查。
合并请求创建后，极狐GitLab Duo 会对其进行审查，除非：

- 它被标记为草稿。要让极狐GitLab Duo 审查合并请求，请将其标记为就绪。
- 它不包含任何更改。要让极狐GitLab Duo 审查合并请求，请向其添加更改。

前提条件：

- 您必须在项目中至少拥有[维护者角色](../permissions.md)。

要启用 `@GitLabDuo` 自动审查合并请求：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **合并请求**。
1. 在 **极狐GitLab Duo 代码审查** 部分，选择 **启用极狐GitLab Duo 自动审查**。
1. 选择 **保存更改**。

<a id="automatic-reviews-from-gitlab-duo-for-groups-and-applications"></a>

## 群组和应用程序的极狐GitLab Duo 自动审查

{{< history >}}

- 在极狐GitLab 18.4 中作为[测试版](../../policy/development_stages_support.md#beta)引入，受功能标志 `cascading_auto_duo_code_review_settings` 控制，默认禁用。
- 功能标志 `cascading_auto_duo_code_review_settings` 在极狐GitLab 18.7 中[移除](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/213240)。

{{< /history >}}

使用群组或应用程序设置为多个项目启用自动审查。

前提条件：

- 要为群组开启自动审查，需拥有该群组的所有者角色。
- 要为所有项目开启自动审查，需成为管理员。

要为群组启用自动审查：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **合并请求** 部分。
1. 在 **极狐GitLab Duo 代码审查** 部分，选择 **启用极狐GitLab Duo 自动审查**。
1. 选择 **保存更改**。

要为所有项目启用自动审查：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 在 **极狐GitLab Duo 代码审查** 部分，选择 **启用极狐GitLab Duo 自动审查**。
1. 选择 **保存更改**。

设置从应用程序级联到群组再到项目。更具体的设置会覆盖更广泛的设置。

