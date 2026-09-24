---
stage: Tenant Scale
group: Organizations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 项目设置
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

<a id="prerequisites"></a>

## 前提条件

- 具有项目的维护者或所有者角色。

<a id="configure-project-features-and-permissions"></a>

## 配置项目功能与权限

要配置项目的功能与权限：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **可见性、项目功能、权限**。
1. 要允许用户请求访问项目，请选择 **用户可请求访问** 复选框。
1. 要在项目中开启或关闭功能，请使用功能开关。
1. 选择 **保存更改**。

<a id="feature-dependencies"></a>

### 功能依赖关系

当你关闭某项功能时，以下附加功能也将不可用：

- 如果你关闭 **工作项** 功能，项目用户将无法使用：
  - **议题看板**
  - **服务台**
  - 项目用户仍可从合并请求中访问 **里程碑**。
- 如果你关闭 **工作项** 和 **合并请求**，项目用户将无法使用：
  - **标记**
  - **里程碑**
- 如果你关闭 **代码仓**，项目用户将无法访问：
  - **合并请求**
  - **CI/CD**
  - **Git 大文件存储**
  - **软件包**
- 指标仪表盘需要项目环境和部署的读取权限。
  拥有指标仪表盘访问权限的用户也可以访问环境和部署。

<a id="toggle-project-features"></a>

## 切换项目功能

可用的项目功能对项目成员可见且可访问。
你可以关闭特定的项目功能，使其对项目成员不可见
且不可访问，无论其角色如何。

要切换项目中各个功能的可用性：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **可见性、项目功能、权限**。
1. 要更改功能的可用性，请将开关打开或关闭。
1. 选择 **保存更改**。

<a id="turn-off-project-analytics"></a>

## 关闭项目分析

> [!note]
> 关闭项目分析只会移除 **分析** 导航项，但数据仍会计算，并可通过相应的 API 端点访问。

默认情况下，项目分析显示在左侧边栏的 **分析** 项下。
要关闭此功能并从左侧边栏移除 **分析** 项：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **可见性、项目功能、权限**。
1. 关闭 **分析** 开关。
1. 选择 **保存更改**。

<a id="turn-off-cve-identifier-request-in-issues"></a>

## 在议题中关闭 CVE 标识符请求

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

{{< history >}}

- 在极狐GitLab 13.4 中引入，仅适用于 JihuLab.com 上的公开项目。

{{< /history >}}

在某些环境中，用户可以在议题中提交 [CVE 标识符请求](../../application_security/cve_id_request.md)。

要在你的项目中关闭议题里的 CVE 标识符请求选项：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **可见性、项目功能、权限**。
1. 在 **工作项** 下，关闭 **议题侧边栏中的 CVE ID 请求** 开关。
1. 选择 **保存更改**。

<a id="turn-off-project-email-notifications"></a>

## 关闭项目邮件通知

前提条件：

- 你必须具有项目的所有者角色。

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **可见性、项目功能、权限** 部分。
1. 清除 **启用邮件通知** 复选框。

<a id="turn-off-diff-previews-in-project-email-notifications"></a>

### 在项目邮件通知中关闭差异预览

{{< history >}}

- 在极狐GitLab 15.6 中引入，使用名为 `diff_preview_in_email` 的功能标志。默认禁用。
- 在极狐GitLab 17.1 中正式发布。功能标志 `diff_preview_in_email` 已移除。

{{< /history >}}

当你在合并请求中审查代码并在某行代码上评论时，极狐GitLab
会在发送给参与者的邮件通知中包含几行差异内容。
一些组织的安全策略将邮件视为安全性较低的系统，或者可能无法
控制其邮件基础设施，这可能给知识产权或源代码的访问控制带来风险。

前提条件：

- 你必须具有项目的所有者角色。

要关闭项目的差异预览：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **可见性、项目功能、权限** 部分。
1. 清除 **包含差异预览**。
1. 选择 **保存更改**。

<a id="configure-merge-request-settings-for-a-project"></a>

## 配置项目的合并请求设置

配置你项目的合并请求设置：

- 设置 [合并请求方法](../merge_requests/methods/_index.md)（合并提交、快进式合并）。
- 添加合并请求 [描述模板](../description_templates.md)。
- 开启：
  - [合并请求批准](../merge_requests/approvals/_index.md)。
  - [状态检查](../merge_requests/status_checks.md)。
  - [仅在流水线成功时合并](../merge_requests/auto_merge.md)。
  - [仅在所有讨论都已解决时合并](../merge_requests/_index.md#prevent-merge-unless-all-threads-are-resolved)。
  - [要求关联 Jira 议题](../../../integration/jira/issues.md#require-associated-jira-issue-for-merge-requests-to-be-merged)。
  - [合并请求标题验证](../merge_requests/title_validation.md)。
  - 针对半线性和快进式合并方法的 [合并前自动变基](../merge_requests/methods/_index.md#automatic-rebase-before-merge)。
  - [默认 **在合并请求被接受后删除源分支** 选项](#delete-the-source-branch-on-merge-by-default)。
- 配置：
  - [建议更改的提交消息](../merge_requests/reviews/suggestions.md#configure-the-commit-message-for-applied-suggestions)。
  - [合并和压缩提交消息模板](../merge_requests/commit_templates.md)。
  - [合并请求标题模板](../merge_requests/title_templates.md)。
  - 针对来自派生的合并请求的 [默认目标项目](../merge_requests/creating_merge_requests.md#set-the-default-target-project)。

<a id="delete-the-source-branch-on-merge-by-default"></a>

### 默认在合并时删除源分支

在合并请求中，你可以更改默认行为，使
**删除源分支** 复选框始终被选中。

要设置此默认值：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **设置** > **合并请求**。
1. 选择 **默认启用“删除源分支”选项**。
1. 选择 **保存更改**。

<a id="add-additional-webhook-triggers-for-project-access-token-expiration"></a>

## 添加项目访问令牌过期的额外 Webhook 触发器

{{< history >}}

- 在极狐GitLab 17.9 中，为项目和群组访问令牌 Webhook 引入了 60 天和 30 天触发器，使用名为 `extended_expiry_webhook_execution_setting` 的功能标志。默认禁用。
- 在极狐GitLab 17.10 中正式发布。功能标志 `extended_expiry_webhook_execution_setting` 已移除。

{{< /history >}}

极狐GitLab 在项目令牌过期前会发送多封 [过期邮件](project_access_tokens.md#project-access-token-expiry-emails)
并触发相关的 [Webhook](../integrations/webhook_events.md#project-and-group-access-token-events)。
默认情况下，这些 Webhook 会在令牌过期前 7 天触发。

要将这些 Webhook 配置为也在令牌过期前 60 天和 30 天触发：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **可见性、项目功能、权限** 部分。
1. 选择 **添加项目访问令牌过期的额外 Webhook 触发器** 复选框。
1. 选择 **保存更改**。

<a id="turn-off-cicd-for-a-project"></a>

## 关闭项目的 CI/CD

如果你的项目不使用 CI/CD，你可以将其关闭。
这将从合并请求中移除 CI/CD 横幅。

要关闭 CI/CD：

1. 在左侧边栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 选择 **设置** > **通用**。
1. 展开 **可见性、项目功能、权限**。
1. 关闭 **CI/CD** 开关。
1. 选择 **保存更改**。