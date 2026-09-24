---
stage: Tenant Scale
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab Silent Mode
description: Silence outbound communication from GitLab.
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 15.11 引入。此功能曾是[实验](../../policy/development_stages_support.md#experiment)。
- 在极狐GitLab 16.4 通过 Web UI 启用和禁用静默模式。
- 在极狐GitLab 16.6 [GA](../../policy/development_stages_support.md#generally-available)。

{{< /history >}}

静默模式允许您静默极狐GitLab 的对外通信，例如电子邮件。静默模式不适用于正在使用的环境。

<a id="when-to-use-silent-mode"></a>

## 何时使用静默模式

静默模式专为特定的测试和验证场景设计，不应作为生产环境的通用功能。

静默模式适用于以下场景：

- 测试 Geo 站点升级：当验证灾难恢复程序时，通过将辅助 Geo 站点升级，而主站点仍处于活动状态。
  - 例如，您有一个辅助 Geo 站点作为[灾难恢复](../geo/disaster_recovery/_index.md)解决方案的一部分。您想定期测试将其升级为主 Geo 站点，作为确保灾难恢复计划实际有效的最佳实践。但您不希望执行完整的故障转移，因为主站点位于为您的用户提供最低延迟的区域。而且您不想在每次定期测试期间停机。因此，您让主站点保持运行，同时升级辅助站点。您开始对升级后的站点进行冒烟测试。但是，升级后的站点会开始向用户发送电子邮件，推送镜像会将更改推送到外部 Git 代码仓，等等。这就是静默模式发挥作用的地方。您可以在站点升级期间启用它来避免此问题。
- 验证极狐GitLab 备份：当在单独的测试实例上测试备份恢复时，以确保备份功能正常。可以使用静默模式来避免向用户发送无效的电子邮件。
- 过渡环境测试：当您需要测试极狐GitLab 功能而不触发可能影响用户或外部系统的对外通信时。特别是如果您使用生产数据填充了过渡环境。

静默模式不适用于：

- 生产环境：静默模式会有意[破坏许多极狐GitLab 功能](#behavior-of-gitlab-features-in-silent-mode)。静默模式可能导致意外错误，尤其是在新功能中。静默模式必须谨慎行事，默认阻断新的通信。

<a id="turn-on-silent-mode"></a>

## 启用静默模式

先决条件：

- 您必须具有管理员访问权限。

有多种方式可以启用静默模式：

- **Web UI**

  1. 在右上角，选择 **管理员**。
  1. 在左侧边栏中，选择 **设置** > **通用**。
  1. 展开 **静默模式**，然后打开 **启用静默模式** 开关。
  1. 更改会立即保存。

- [**API**](../../api/settings.md)：

  ```shell
  curl --request PUT --header "PRIVATE-TOKEN:$ADMIN_TOKEN" "<gitlab-url>/api/v4/application/settings?silent_mode_enabled=true"
  ```

- [**Rails 控制台**](../operations/rails_console.md#starting-a-rails-console-session)：

  ```ruby
  ::Gitlab::CurrentSettings.update!(silent_mode_enabled: true)
  ```

可能需要长达一分钟才能生效。[Issue 405433](https://jihulab.com/gitlab-cn/gitlab/-/issues/405433) 提议消除此延迟。

<a id="turn-off-silent-mode"></a>

## 关闭静默模式

先决条件：

- 您必须具有管理员访问权限。

有多种方式可以禁用静默模式：

- **Web UI**

  1. 在右上角，选择 **管理员**。
  1. 在左侧边栏中，选择 **设置** > **通用**。
  1. 展开 **静默模式**，然后关闭 **启用静默模式** 开关。
  1. 更改会立即保存。

- [**API**](../../api/settings.md)：

  ```shell
  curl --request PUT --header "PRIVATE-TOKEN:$ADMIN_TOKEN" "<gitlab-url>/api/v4/application/settings?silent_mode_enabled=false"
  ```

- [**Rails 控制台**](../operations/rails_console.md#starting-a-rails-console-session)：

  ```ruby
  ::Gitlab::CurrentSettings.update!(silent_mode_enabled: false)
  ```

可能需要长达一分钟才能生效。[Issue 405433](https://jihulab.com/gitlab-cn/gitlab/-/issues/405433) 提议消除此延迟。

<a id="behavior-of-gitlab-features-in-silent-mode"></a>

## 静默模式下极狐GitLab 功能的行为

本节记录了启用静默模式时极狐GitLab 的当前行为。静默模式的第一阶段工作由[Epic 9826](https://jihulab.com/groups/gitlab-cn/-/epics/9826)跟踪。

当启用静默模式时，所有用户的页面顶部都会显示一条横幅，说明该设置已启用，且**所有对外通信已被阻断**。

<a id="outbound-communications-that-are-silenced"></a>

### 被静默的对外通信

以下功能的对外通信会被静默模式静默。

| 功能                                                                       | 备注                                                                                                                                                                                                                                                   |
| ------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [极狐GitLab Duo](../../user/gitlab_duo/feature_summary.md)                         | 极狐GitLab Duo 功能无法联系外部语言模型提供程序。 |
| [项目和群组 Webhook](../../user/project/integrations/webhooks.md) | 通过 UI 触发 Webhook 测试会导致 HTTP 状态 500 响应。                                                                                                                                                                               |
| [系统钩子](../system_hooks.md)                                        |                                                                                                                                                                                                                                                         |
| [远程镜像](../../user/project/repository/mirror/_index.md)           | 跳过推送到远程镜像。跳过从远程镜像拉取。                                                                                                                                                                             |
| [可执行集成](../../user/project/integrations/_index.md)       | 集成不会被执行。                                                                                                                                                                                                                      |
| [服务台](../../user/project/service_desk/_index.md)                  | 收件邮件仍然会创建议题，但发送电子邮件到服务台的用户不会收到议题创建或议题评论的通知。                                                                                                   |
| 外发电子邮件                                                           | 在极狐GitLab 应该发送电子邮件的那一刻，它将被丢弃，不会在任意位置排队。                                                                                                                                                 |
| 外发 HTTP 请求                                                    | 在许多功能未被明确阻断或跳过的情况下，许多 HTTP 请求被阻断。这可能会产生带有 `SilentModeBlockedError` 类的错误。如果某个特定错误在静默模式测试期间造成问题，请咨询[GitLab 支持](https://gitlab.cn/support/)。通常，在静默模式启用时，调用方应该退出，而不是尝试发出 HTTP 请求。任何例外都必须符合[静默模式的预期用途](#when-to-use-silent-mode)。 |

<a id="outbound-communications-that-are-not-silenced"></a>

### 未被静默的对外通信

以下功能的对外通信不会被静默模式静默。

| 功能                                                                                                     | 备注                                                                                                                                                                                                                                           |
| ----------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [依赖代理](../packages/dependency_proxy.md)                                                         | 拉取未缓存的镜像会照常从源获取。请考虑拉取速率限制。                                                                                                                                              |
| [文件钩子](../file_hooks.md)                                                                              |                                                                                                                                                                                                                                                 |
| [服务器钩子](../server_hooks.md)                                                                          |                                                                                                                                                                                                                                                 |
| [高级搜索](../../integration/advanced_search/elasticsearch.md)                                       | 如果两个极狐GitLab 实例使用相同的高级搜索实例，那么它们都可以修改搜索数据。这是脑裂情景，可能发生在例如升级辅助 Geo 站点而主 Geo 站点仍在运行之后。 |
| [ClickHouse 调用](../../integration/clickhouse.md)                                                         | ClickHouse 请求不会被静默，因为它们被视为站点内部的请求。                                                                                                                                                            |
| Snowplow                                                                                                    | [issue 409661](https://jihulab.com/gitlab-cn/gitlab/-/issues/409661) 中有一个提案建议静默这些请求。                                                                                                                                          |
| [已弃用的 Kubernetes 连接](../../user/clusters/agent/_index.md)                                    | [有一个提案建议静默这些请求](https://jihulab.com/gitlab-cn/gitlab/-/issues/396470)。                                                                                                                                          |
| [容器镜像仓库 Webhook](../packages/container_registry.md#configure-container-registry-notifications) | [有一个提案建议静默这些请求](https://jihulab.com/gitlab-cn/gitlab/-/issues/409682)。                                                                                                                                          |