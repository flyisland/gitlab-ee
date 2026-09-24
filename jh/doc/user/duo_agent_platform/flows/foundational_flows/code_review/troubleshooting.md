---
stage: AI Coding
group: Code Review
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 代码评审任务流故障排查
---

在使用代码评审任务流时，您可能会遇到以下问题。

<a id="error-dcr4000"></a>

## `Error DCR4000`

您可能会收到一条错误信息：
`Code Review Flow is not enabled. Contact your group administrator to enable the foundational flow in the top-level group. Error code: DCR4000`。

当[内置任务流](../_index.md)或代码评审任务流被关闭时，会出现此错误。

请联系您的管理员，请他们为您的顶级群组启用代码评审任务流。

<a id="error-dcr4001"></a>

## `Error DCR4001`

您可能会收到一条错误信息：
`Code Review Flow is enabled but the service account needs to be verified. Contact your administrator. Error code: DCR4001`。

当代码评审任务流已启用，但顶级群组的服务账号不存在或未就绪时，会出现此错误。

请让您的管理员[确认服务账号存在](../../../troubleshooting.md#foundational-flow-service-account-not-created)，并按照步骤解决任何问题。

<a id="error-dcr4002"></a>

## `Error DCR4002`

您可能会收到一条错误信息：
`No GitLab Credits remain for this billing period. To continue using Code Review Flow, contact your administrator. Error code: DCR4002`。

当您在当前计费周期内已用完所有分配的极狐GitLab Credits 时，会出现此错误。

请联系您的管理员购买更多 Credits，或等待您的 Credits 在下一个计费周期开始时重置。

<a id="error-dcr4003"></a>

## `Error DCR4003`

您可能会收到一条错误信息：
`<User>, you don't have permission to create a pipeline for Code Review Flow in this project. Contact your administrator to update your permissions. Error code: DCR4003`。

出现此错误是因为代码评审任务流在 CI/CD 流水线上运行，而您没有在此项目中创建流水线的权限。

请联系您的管理员，请他们授予您所需的[执行流水线的权限](../../../../permissions.md)。

<a id="error-dcr4004"></a>

## `Error DCR4004`

您可能会收到一条错误信息：
`<User>, you need to set a default GitLab Duo namespace to use Code Review Flow in this project. Please set a default GitLab Duo namespace in your preferences. Error code: DCR4004`。

当极狐GitLab Duo 无法为发起评审的用户识别默认的极狐GitLab Duo 命名空间时，会出现此错误。

请在您的[偏好设置](../../../../profile/preferences.md#set-a-default-gitlab-duo-namespace)中设置默认的极狐GitLab Duo 命名空间，然后重新请求评审。

<a id="error-dcr4005"></a>

## `Error DCR4005`

您可能会收到一条错误信息：
`Code Review Flow could not obtain the required authentication tokens to connect to the GitLab AI Gateway and the GitLab API. Please request a new review. If the issue persists, contact your administrator. Error code: DCR4005`。

代码评审任务流需要身份验证令牌才能连接到极狐GitLab AI 网关和极狐GitLab API。当这些令牌无法生成时（通常是由于极狐GitLab Duo 配置不正确或基础设施临时故障），会出现此错误。

对于私有化部署实例，请让您的管理员验证[极狐GitLab Duo 配置](../../../../../administration/gitlab_duo/configure/_index.md)。

<a id="error-dcr4006"></a>

## `Error DCR4006`

您可能会收到一条错误信息：
`Code Review Flow could not add the service account to this project. Contact your administrator to verify that the service account has the required project access. Error code: DCR4006`。

当服务账号无法作为项目成员添加时，会出现此错误。这可能是由于启用了群组成员锁定，或服务账号没有所需的访问权限。

请联系您的管理员，请他们确认服务账号可以作为开发者添加到项目中。

<a id="error-dcr4007"></a>

## `Error DCR4007`

您可能会收到一条错误信息：
`Code Review Flow is not available for this project. Contact your administrator to verify that the flow is enabled and the required configuration is in place. Error code: DCR4007`。

当任务流被禁用或项目缺少所需配置时，会出现此错误。

请联系您的管理员，请他们确认该项目已[启用任务流](../_index.md#turn-foundational-flows-on-or-off)。

<a id="error-dcr4008"></a>

## `Error DCR4008`

您可能会收到一条错误信息：
`Code Review Flow could not create the required CI/CD pipeline. Please request a new review. If the problem persists, contact your administrator. Error code: DCR4008`。

当代码评审任务流因 Runner 可用性问题或内部配置问题而无法创建或配置 CI/CD 流水线来运行评审时，会出现此错误。

请尝试重新启动评审。如果错误仍然存在，请联系您的管理员。

<a id="error-dcr4009"></a>

## `Error DCR4009`

您可能会收到一条错误信息：
`Code Review Flow could not retrieve the source branch for this merge request. Please request a new review. Error code: DCR4009`。

当代码评审任务流无法检索此合并请求的源分支时，会出现此错误。

请尝试重新启动评审。

<a id="error-dcr5000"></a>

## `Error DCR5000`

您可能会收到一条错误信息：
`Something went wrong while starting Code Review Flow. Please try again later. Error code: DCR5000`。

当极狐GitLab Duo Agent Platform 因内部错误而无法启动代码评审任务流时，会出现此错误。

请尝试重新启动评审。如果错误仍然存在，请联系您的管理员。

<a id="error-dcr5001"></a>

## `Error DCR5001`

您可能会收到一条错误信息：
`Code Review Flow completed the review but could not post the review comments. Please request a new review to try again. Error code: DCR5001`。

当代码评审任务流完成评审，但经过多次尝试仍无法发布评审评论时，会出现此错误。这通常是由于基础设施临时故障导致的。

请重新请求评审。如果错误仍然存在，请联系您的管理员。

<a id="missing-context-in-large-merge-request-reviews"></a>

## 大型合并请求评审中缺少上下文

当合并请求包含许多大型变更文件时，代码评审任务流可能会遗漏上下文。

当预扫描结果超过[文件和上下文限制](_index.md#file-and-context-limits)且数据在评审前被截断时，可能会发生这种情况。

为改进评审：

- 将合并请求拆分为更小的合并请求。
- 为与评审无关的文件[排除上下文](../../../context.md#exclude-context-from-gitlab-duo)。
- 请群组所有者或实例管理员为 [JihuLab.com](../../../model_selection.md#select-a-model-for-a-feature) 或 [极狐GitLab 私有化部署](../../../../../administration/gitlab_duo/model_selection.md#select-a-model-for-code-review-flow) 选择不同的模型。

<a id="configuration-diagnostic-script"></a>

## 配置诊断脚本

如果您无法根据文档中的错误代码确定代码评审任务流问题的原因，可以运行诊断脚本来检查您的极狐GitLab Duo 配置。

该脚本会检查代码评审任务流所需的完整配置链，包括适用于所有极狐GitLab Duo Agent Platform 功能的检查。

有关更多信息，请参阅[运行配置诊断脚本](../../../troubleshooting.md#run-the-configuration-diagnostic-script)。
