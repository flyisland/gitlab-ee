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

## 先决条件

- 项目的维护者或所有者角色。

<a id="configure-project-features-and-permissions"></a>

## 配置项目功能和权限

要为项目配置功能和权限：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**可见性、项目功能、权限**。
1. 要允许用户申请访问项目，请选中**用户可以申请访问**复选框。
1. 要在项目中开启或关闭功能，请使用功能开关。
1. 选择**保存更改**。

<a id="feature-dependencies"></a>

### 功能依赖关系

当您关闭某个功能时，以下附加功能也将不可用：

- 如果您关闭**工作项**功能，项目用户将无法使用：
  - **议题看板**
  - **服务台**
  - 项目用户仍可从合并请求访问**里程碑**。
- 如果您关闭**工作项**和**合并请求**，项目用户将无法使用：
  - **标记**
  - **里程碑**
- 如果您关闭**代码仓库**，项目用户将无法访问：
  - **合并请求**
  - **CI/CD**
  - **Git Large File Storage**
  - **软件包**
- 指标仪表板需要项目环境和部署的读取权限。
  有权访问指标仪表板的用户也可以访问环境和部署。

<a id="toggle-project-features"></a>

## 切换项目功能

可用的项目功能对项目成员可见且可访问。您可以关闭特定的项目功能，使其对项目成员不可见且不可访问，无论其角色如何。

要切换项目中各项功能的可用性：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**可见性、项目功能、权限**。
1. 要更改某项功能的可用性，请开启或关闭该开关。
1. 选择**保存更改**。

<a id="turn-off-project-analytics"></a>

## 关闭项目分析

> [!note]
> 关闭项目分析只会移除**分析**导航项，但数据仍在计算中，并可通过相应的 API 端点获取。

默认情况下，项目分析显示在左侧边栏的**分析**项下。要关闭此功能并从左侧边栏中移除**分析**项：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**可见性、项目功能、权限**。
1. 关闭**分析**开关。
1. 选择**保存更改**。

<a id="turn-off-cve-identifier-request-in-issues"></a>

## 关闭议题中的 CVE 标识符请求

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

此功能仅适用于 JihuLab.com 上的公开项目。

在某些环境中，用户可以在议题中提交 [CVE 标识符请求](../../application_security/cve_id_request.md)。

要关闭项目中议题的 CVE 标识符请求选项：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**可见性、项目功能、权限**。
1. 在**工作项**下，关闭**议题侧边栏中的 CVE ID 请求**开关。
1. 选择**保存更改**。

<a id="turn-off-project-email-notifications"></a>

## 关闭项目电子邮件通知

先决条件：

- 您必须拥有项目的所有者角色。

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**可见性、项目功能、权限**部分。
1. 清除**启用电子邮件通知**复选框。

<a id="turn-off-diff-previews-in-project-email-notifications"></a>

### 关闭项目电子邮件通知中的差异预览

当您在合并请求中评审代码并对某行代码发表评论时，极狐GitLab 会在发送给参与者的电子邮件通知中包含几行差异内容。某些组织政策将电子邮件视为安全性较低的系统，或者可能无法控制自己的电子邮件基础设施。这可能会给源代码的知识产权或访问控制带来风险。

先决条件：

- 您必须拥有项目的所有者角色。

要关闭项目的差异预览：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**可见性、项目功能、权限**部分。
1. 清除**包含差异预览**。
1. 选择**保存更改**。

<a id="configure-merge-request-settings-for-a-project"></a>

## 为项目配置合并请求设置

配置项目的合并请求设置：

- 设置[合并请求方法](../merge_requests/methods/_index.md)（合并提交、快进合并）。
- 添加合并请求[描述模板](../description_templates.md)。
- 开启：
  - [合并请求审批](../merge_requests/approvals/_index.md)。
  - [状态检查](../merge_requests/status_checks.md)。
  - [仅在流水线成功时合并](../merge_requests/auto_merge.md)。
  - [仅在所有讨论串都解决后才合并](../merge_requests/_index.md#prevent-merge-unless-all-threads-are-resolved)。
  - [来自 Jira 的必需关联议题](../../../integration/jira/issues.md#require-associated-jira-issue-for-merge-requests-to-be-merged)。
  - [合并请求标题验证](../merge_requests/title_validation.md)。
  - 针对半线性和快进合并方法的[合并前自动变基](../merge_requests/methods/_index.md#automatic-rebase-before-merge)。
  - [默认选中**接受合并请求时删除源分支**选项](#delete-the-source-branch-on-merge-by-default)。
- 配置：
  - [建议更改的提交消息](../merge_requests/reviews/suggestions.md#configure-the-commit-message-for-applied-suggestions)。
  - [合并和压缩提交消息模板](../merge_requests/commit_templates.md)。
  - [合并请求标题模板](../merge_requests/title_templates.md)。
  - 来自 forks 的合并请求的[默认目标项目](../merge_requests/creating_merge_requests.md#set-the-default-target-project)。

<a id="delete-the-source-branch-on-merge-by-default"></a>

### 默认在合并时删除源分支

在合并请求中，您可以更改默认行为，使**删除源分支**复选框始终处于选中状态。

要设置此默认值：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**设置** > **合并请求**。
1. 选择**默认启用“删除源分支”选项**。
1. 选择**保存更改**。

此设置适用于源分支位于此项目中的合并请求。对于来自 fork 的合并请求，默认值来自 fork 的设置，而不是此项目的设置。Forks 在创建时不会继承此设置。

<a id="add-additional-webhook-triggers-for-project-access-token-expiration"></a>

## 为项目访问令牌过期添加额外的 webhook 触发器

极狐GitLab 会在项目令牌过期前发送多封[过期电子邮件](project_access_tokens.md#project-access-token-expiry-emails)
并触发相关的 [webhook](../integrations/webhook_events.md#project-and-group-access-token-events)。
默认情况下，这些 webhook 会在令牌过期前 7 天触发。

要将这些 webhook 配置为在令牌过期前 60 天和 30 天也触发：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**可见性、项目功能、权限**部分。
1. 选中**为项目访问令牌过期添加额外的 webhook 触发器**复选框。
1. 选择**保存更改**。

<a id="turn-off-cicd-for-a-project"></a>

## 为项目关闭 CI/CD

如果您的项目不使用 CI/CD，您可以将其关闭。这会从合并请求中移除 CI/CD 横幅。

要关闭 CI/CD：

1. 在左侧边栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 选择**设置** > **通用**。
1. 展开**可见性、项目功能、权限**。
1. 关闭 **CI/CD** 开关。
1. 选择**保存更改**。
