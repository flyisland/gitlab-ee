---
stage: Analytics
group: Platform Insights
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Connect Sentry to GitLab for error tracking in your projects.
title: Sentry 错误跟踪
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

[Sentry](https://sentry.io/) 是一个开源错误跟踪系统。极狐GitLab 允许管理员将 Sentry 连接到极狐GitLab，以便用户可以在极狐GitLab 中查看 Sentry 错误列表。

极狐GitLab 同时支持云托管 [Sentry](https://sentry.io) 和在您的 [本地部署实例](https://github.com/getsentry/self-hosted) 上部署的 Sentry。

<a id="enable-sentry-integration-for-a-project"></a>

## 为项目启用 Sentry 集成

极狐GitLab 提供了一种将 Sentry 连接到项目的方法。

先决条件：

- 您必须拥有该项目的维护者或所有者角色。

要启用 Sentry 集成：

1. 注册 Sentry.io，或部署您自己的 [本地 Sentry 实例](https://github.com/getsentry/self-hosted)。
1. [创建新的 Sentry 项目](https://docs.sentry.io/product/sentry-basics/integrate-frontend/create-new-project/)。
   对于每个您想要集成的极狐GitLab 项目，创建一个新的 Sentry 项目。
1. 查找或生成一个 [Sentry 认证令牌](https://docs.sentry.io/api/auth/#auth-tokens)。
   对于 Sentry 的 SaaS 版本，您可以在 <https://sentry.io/api/> 找到或生成认证令牌。
   为令牌至少授予以下范围：`project:read`、`event:read` 和
   `event:write`（用于解决事件）。
1. 在极狐GitLab 中，启用并配置错误跟踪：
   1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
   1. 选择 **设置** > **监控**，然后展开 **错误跟踪**。
   1. 对于 **启用错误跟踪**，选择 **已启用**。
   1. 对于 **错误跟踪后端**，选择 **Sentry**。
   1. 对于 **Sentry API URL**，输入您的 Sentry 主机名。例如，
      输入 `https://sentry.example.com`。
      对于 Sentry 的 SaaS 版本，主机名为 `https://sentry.io`。
      对于在欧盟托管的 Sentry SaaS 版本，主机名为 `https://de.sentry.io`。
   1. 对于 **认证令牌**，输入您之前生成的令牌。
   1. 要测试与 Sentry 的连接并填充 **项目** 下拉列表，
      选择 **连接**。
   1. 从 **项目** 列表中选择一个 Sentry 项目，以关联到您的极狐GitLab 项目。
   1. 选择 **保存更改**。

要查看 Sentry 错误列表，请在项目侧边栏中，转到 **监控** > **错误跟踪**。

<a id="enable-sentrys-integration-with-gitlab"></a>

## 启用 Sentry 与极狐GitLab 的集成

您可能还需要按照 [Sentry 文档](https://docs.sentry.io/organization/integrations/source-code-mgmt/gitlab/) 中的步骤来启用 Sentry 的极狐GitLab 集成。

<a id="troubleshooting"></a>

## 故障排除

在使用错误跟踪时，您可能会遇到以下问题。

<a id="error-connection-failed-check-auth-token-and-try-again"></a>

### 错误 `连接失败。请检查认证令牌并重试`

如果在 [项目设置](../user/project/settings/_index.md#configure-project-features-and-permissions) 中禁用了 **监控** 功能，
当您尝试 [为项目启用 Sentry 集成](#enable-sentry-integration-for-a-project) 时，可能会看到错误。
发往 `/project/path/-/error_tracking/projects.json?api_host=https:%2F%2Fsentry.example.com%2F&token=<token>` 的请求返回 404 错误。

要解决此问题，请为项目启用 **监控** 功能。

<a id="error-connection-has-failed-re-check-auth-token-and-try-again"></a>

### 错误 `连接失败。请重新检查认证令牌并重试`

在尝试连接时，本地部署的 Sentry 集成可能会遇到此问题。

先决条件：

- 管理员权限。

要解决此问题：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **网络**。
1. 展开 **对外请求**。
1. 勾选 **允许来自 webhook 和集成的本地网络请求** 和 **允许来自系统钩子的本地网络请求** 复选框。
1. 选择 **保存更改**。