---
stage: Analytics
group: Platform Insights
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 将 Sentry 连接到极狐GitLab，以便在您的项目中进行错误跟踪。
title: Sentry 错误跟踪
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

[Sentry](https://sentry.io/) 是一个开源错误跟踪系统。极狐GitLab 使管理员能够
将 Sentry 连接到极狐GitLab，这样用户就可以在极狐GitLab 中查看 Sentry 错误列表。

极狐GitLab 既可以与云托管的 [Sentry](https://sentry.io) 集成，也可以与部署在[本地实例](https://github.com/getsentry/self-hosted)中的 Sentry 集成。

<a id="enable-sentry-integration-for-a-project"></a>

## 为项目启用 Sentry 集成

极狐GitLab 提供了一种将 Sentry 连接到您项目的方式。

先决条件：

- 您必须拥有该项目的维护者或所有者角色。

要启用 Sentry 集成：

1. 注册 Sentry.io，或部署您自己的[本地 Sentry 实例](https://github.com/getsentry/self-hosted)。
1. [创建新的 Sentry 项目](https://docs.sentry.io/product/sentry-basics/integrate-frontend/create-new-project/)。
   对于您想要集成的每个极狐GitLab 项目，请创建一个新的 Sentry 项目。
1. 查找或生成 [Sentry 认证令牌](https://docs.sentry.io/api/auth/#auth-tokens)。
   对于 SaaS 版本的 Sentry，您可以在 <https://sentry.io/api/> 查找或生成认证令牌。
   请至少为该令牌授予以下范围：`project:read`、`event:read` 和
   `event:write`（用于解决事件）。
1. 在极狐GitLab 中，启用并配置错误跟踪：
   1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
   1. 选择**设置** > **监控**，然后展开**错误跟踪**。
   1. 对于**启用错误跟踪**，选择**活跃**。
   1. 对于**错误跟踪后端**，选择 **Sentry**。
   1. 对于**认证令牌**，输入您之前生成的令牌。
   1. 要测试与 Sentry 的连接并填充**项目**下拉列表，
      选择**连接**。
   1. 从**项目**列表中，选择一个 Sentry 项目以链接到您的极狐GitLab 项目。
   1. 选择**保存更改**。

要查看 Sentry 错误列表，请在项目的边栏中转到**监控** > **错误跟踪**。

<a id="enable-sentrys-integration-with-gitlab"></a>

## 启用 Sentry 与极狐GitLab 的集成

您也可以按照 [Sentry 文档](https://docs.sentry.io/organization/integrations/source-code-mgmt/gitlab/)中的步骤，
启用 Sentry 的极狐GitLab 集成。

<a id="troubleshooting"></a>

## 故障排除

使用错误跟踪时，您可能会遇到以下问题。

<a id="error-connection-failed-check-auth-token-and-try-again"></a>

### 错误 `Connection failed. Check auth token and try again`

如果在[项目设置](../user/project/settings/_index.md#configure-project-features-and-permissions)中禁用了**监控**功能，则当您尝试[为项目启用 Sentry 集成](#enable-sentry-integration-for-a-project)时，可能会看到错误。由此产生的对 `/project/path/-/error_tracking/projects.json?api_host=https:%2F%2Fsentry.example.com%2F&token=<token>` 的请求会返回 404 错误。

要解决此问题，请为该项目启用**监控**功能。

<a id="error-connection-has-failed-re-check-auth-token-and-try-again"></a>

### 错误 `Connection has failed. Re-check Auth Token and try again`

本地 Sentry 集成在尝试连接时可能会遇到此问题。

先决条件：

- 管理员访问权限。

要解决此问题：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **网络**。
1. 展开**出站请求**。
1. 选中**允许来自 Webhook 和集成的请求访问本地网络**和**允许来自系统钩子的请求访问本地网络**复选框。
1. 选择**保存更改**。
