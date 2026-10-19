---
stage: GitLab Dedicated
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab 静默模式
description: 静默极狐GitLab 发出的对外通信。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

静默模式允许您静默极狐GitLab 发出的对外通信，例如电子邮件。静默模式不适用于正在使用中的环境。

<a id="when-to-use-silent-mode"></a>

## 何时使用静默模式

静默模式专为特定的测试和验证场景而设计，不应作为生产环境的通用功能使用。

静默模式适用于以下场景：

- 测试 Geo 站点提升：在主站点保持活动状态的同时提升 Geo 从站点，以验证灾难恢复流程。
  - 例如，您将 Geo 从站点作为
    [灾难恢复](../geo/disaster_recovery/_index.md)解决方案的一部分。您希望
    定期测试将其提升为 Geo 主站点，作为最佳实践
    以确保您的灾难恢复计划确实有效。但您并不想
    真正执行完整的故障转移，因为主站点位于能够
    为您的用户提供最低延迟的区域。而且您也不希望在每次定期测试时
    都造成停机。因此，您让主站点保持运行，
    同时提升从站点。您开始对提升后的
    站点进行冒烟测试。但是，提升后的站点开始向用户发送电子邮件，
    推送镜像将变更推送到外部 Git 代码仓库，等等。这正是静默模式发挥作用的地方。
    您可以将其作为站点提升的一部分启用，以避免此问题。
- 验证极狐GitLab 备份：在单独的测试实例上测试备份恢复，以确保备份可用。可以使用静默模式来避免向用户发送无效电子邮件。
- 预发布环境测试：当您需要测试极狐GitLab 功能而不触发可能影响用户或外部系统的对外通信时。特别是当您使用生产数据填充预发布环境时。

静默模式不适用于：

- 生产环境：静默模式会故意[破坏许多极狐GitLab 功能](#behavior-of-gitlab-features-in-silent-mode)。静默模式可能导致意外错误，尤其是在新功能中。静默模式必须谨慎行事，默认阻止新的通信。

<a id="turn-on-silent-mode"></a>

## 开启静默模式

先决条件：

- 您必须具有管理员访问权限。

有多种方式可以开启静默模式：

- **Web UI**

  1. 在右上角，选择**管理员**。
  1. 在左侧边栏中，选择**设置** > **通用**。
  1. 展开**静默模式**，然后打开**启用静默模式**开关。
  1. 更改会立即保存。

- [**API**](../../api/settings.md):

  ```shell
  curl --request PUT --header "PRIVATE-TOKEN:$ADMIN_TOKEN" "<gitlab-url>/api/v4/application/settings?silent_mode_enabled=true"
  ```

- [**Rails 控制台**](../operations/rails_console.md#starting-a-rails-console-session):

  ```ruby
  ::Gitlab::CurrentSettings.update!(silent_mode_enabled: true)
  ```

最多可能需要一分钟才能生效。[议题 405433](https://gitlab.com/gitlab-org/gitlab/-/issues/405433) 提议移除该延迟。

<a id="turn-off-silent-mode"></a>

## 关闭静默模式

先决条件：

- 您必须具有管理员访问权限。

有多种方式可以禁用静默模式：

- **Web UI**

  1. 在右上角，选择**管理员**。
  1. 在左侧边栏中，选择**设置** > **通用**。
  1. 展开**静默模式**，然后关闭**启用静默模式**开关。
  1. 更改会立即保存。

- [**API**](../../api/settings.md):

  ```shell
  curl --request PUT --header "PRIVATE-TOKEN:$ADMIN_TOKEN" "<gitlab-url>/api/v4/application/settings?silent_mode_enabled=false"
  ```

- [**Rails 控制台**](../operations/rails_console.md#starting-a-rails-console-session):

  ```ruby
  ::Gitlab::CurrentSettings.update!(silent_mode_enabled: false)
  ```

最多可能需要一分钟才能生效。[议题 405433](https://gitlab.com/gitlab-org/gitlab/-/issues/405433) 提议移除该延迟。

<a id="behavior-of-gitlab-features-in-silent-mode"></a>

## 静默模式下极狐GitLab 功能的行为

本节记录了启用静默模式时极狐GitLab 的当前行为。静默模式第一轮迭代的工作由[史诗 9826](https://gitlab.com/groups/gitlab-org/-/epics/9826) 跟踪。

启用静默模式后，页面顶部会向所有用户显示一条横幅，说明该设置已启用，并且**所有对外通信均被阻止**。

<a id="outbound-communications-that-are-silenced"></a>

### 被静默的对外通信

以下功能的对外通信会被静默模式静默。

| 功能                                                                   | 说明                                                                                                                                                                                                                                                   |
| ------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [极狐GitLab Duo](../../user/gitlab_duo/feature_summary.md)                         | 极狐GitLab Duo 功能无法联系外部语言模型提供商。 |
| [项目和群组 webhook](../../user/project/integrations/webhooks.md) | 通过 UI 触发 webhook 测试会返回 HTTP 状态码 500 响应。                                                                                                                                                                               |
| [系统钩子](../system_hooks.md)                                        |                                                                                                                                                                                                                                                         |
| [远程镜像](../../user/project/repository/mirror/_index.md)           | 会跳过向远程镜像的推送。会跳过从远程镜像的拉取。                                                                                                                                                                             |
| [可执行集成](../../user/project/integrations/_index.md)       | 不会执行这些集成。                                                                                                                                                                                                                      |
| [服务台](../../user/project/service_desk/_index.md)                  | 收到的电子邮件仍会创建议题，但向服务台发送电子邮件的用户不会收到议题创建或其议题上评论的通知。                                                                                                   |
| 对外电子邮件                                                           | 在极狐GitLab 应发送电子邮件时，该邮件会被丢弃。它不会被排队到任何地方。                                                                                                                                                 |
| 对外 HTTP 请求                                                    | 在功能未被阻止或显式跳过的情况下，许多 HTTP 请求会被阻止。这些请求可能会产生类为 `SilentModeBlockedError`的错误。如果某个特定错误在静默模式测试期间造成问题，请咨询[极狐GitLab 支持](https://gitlab.cn/support)。通常，调用方应在启用静默模式时退出，而不是尝试发出 HTTP 请求。任何例外都必须符合[静默模式的预期用途](#when-to-use-silent-mode)。 |

<a id="outbound-communications-that-are-not-silenced"></a>

### 未被静默的对外通信

以下功能的对外通信不会被静默模式静默。

| 功能                                                                                                     | 说明                                                                                                                                                                                                                                           |
| ----------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [依赖代理](../packages/dependency_proxy.md)                                                         | 拉取未缓存的镜像时，会照常从源获取。请考虑拉取速率限制。                                                                                                                                              |
| [文件钩子](../file_hooks.md)                                                                              |                                                                                                                                                                                                                                                 |
| [服务器钩子](../server_hooks.md)                                                                          |                                                                                                                                                                                                                                                 |
| [高级搜索](../../integration/advanced_search/elasticsearch.md)                                       | 如果两个极狐GitLab 实例使用同一个高级搜索实例，那么它们都可以修改搜索数据。这是一种脑裂场景，例如在 Geo 主站点处于活动状态时提升 Geo 从站点后可能发生。 |
| [ClickHouse 调用](../../integration/clickhouse.md)                                                         | ClickHouse 请求不会被静默，因为它们被视为站点内部请求。                                                                                                                                                            |
| Snowplow                                                                                                    | [议题 409661](https://gitlab.com/gitlab-org/gitlab/-/issues/409661)中有一项提议，要求静默这些请求。                                                                                                                                          |
| [已弃用的 Kubernetes 连接](../../user/clusters/agent/_index.md)                                    | [有一项提议要求静默这些请求](https://gitlab.com/gitlab-org/gitlab/-/issues/396470)。                                                                                                                                          |
| [容器镜像仓库 webhook](../packages/container_registry.md#configure-container-registry-notifications) | [有一项提议要求静默这些请求](https://gitlab.com/gitlab-org/gitlab/-/issues/409682)。                                                                                                                                          |
