---
stage: none
group: none
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 以编程方式与极狐GitLab 交互。
title: 开始扩展极狐GitLab
---

以编程方式与极狐GitLab 交互。
自动执行任务、与其他工具集成并创建自定义工作流。
极狐GitLab 还支持插件和自定义钩子。

按照以下步骤了解有关扩展极狐GitLab 的更多信息。

<a id="step-1-set-up-integrations"></a>

## 步骤 1：设置集成

极狐GitLab 提供多种主要集成，可帮助简化您的开发工作流。

这些集成涵盖以下多个领域：

- **认证**：OAuth、SAML、LDAP
- **规划**：Jira、Bugzilla、Redmine、Pivotal Tracker
- **通信**：Slack、Microsoft Teams、Mattermost
- **安全**：Checkmarx、Veracode、Fortify

更多信息请参阅：

- [集成列表](../../integration/_index.md)

<a id="step-2-set-up-webhooks"></a>

## 步骤 2：设置 Webhook

使用 Webhook 将极狐GitLab 事件通知外部服务。

Webhook 监听特定事件，如推送、合并和提交。
当发生其中某个事件时，极狐GitLab 会向 Webhook 的配置 URL 发送 HTTP POST 负载。
Webhook 发送的负载提供了事件详情，
例如事件名称、项目 ID、用户及提交详情。
然后外部系统识别并处理该事件。

例如，您可以设置一个 Webhook，每次将代码推送到极狐GitLab 时触发新的 Jenkins 构建。

您可以按项目或为整个极狐GitLab 实例配置 Webhook。
按项目的 Webhook 监听特定项目的事件。

您可以使用 Webhook 将极狐GitLab 与各种外部工具集成，
包括 CI/CD 系统、聊天和消息传递平台以及监控和日志记录工具。

更多信息请参阅：

- [Webhook](../../user/project/integrations/webhooks.md)

<a id="step-3-use-the-apis"></a>

## 步骤 3：使用 API

使用 REST API 或 GraphQL API 以编程方式与极狐GitLab 交互，
并构建自定义集成、检索数据或实现流程自动化。
这些 API 覆盖极狐GitLab 的各个方面，包括项目、议题、
合并请求和仓库。

极狐GitLab REST API 遵循 RESTful 原则，并使用 JSON 作为请求和响应的数据格式。
您可以使用个人访问令牌或 OAuth 2.0 令牌对这些请求和响应进行身份验证。

极狐GitLab 还提供了 GraphQL API，在查询数据时更加灵活高效。

首先使用 cURL 或 REST 客户端探索 API，
以了解请求和响应。
然后使用 API 自动执行任务，例如创建项目和向群组添加成员。

更多信息请参阅：

- [REST API](../api_resources.md)
- [GraphQL API](../graphql/reference/_index.md)

<a id="step-4-use-the-gitlab-cli"></a>

## 步骤 4：使用极狐GitLab CLI

极狐GitLab CLI 可帮助您完成各种极狐GitLab 操作并管理您的极狐GitLab 实例。

您可以使用极狐GitLab CLI 更快地完成各种批量任务，例如：

- 创建新项目、群组和其他极狐GitLab 资源
- 管理用户和权限
- 在极狐GitLab 实例之间导入和导出项目
- 触发 CI/CD 流水线

更多信息请参阅：

- [安装极狐GitLab CLI](https://jihulab.com/gitlab-cn/cli/#installation)