---
stage: none
group: unassigned
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 通过对极狐GitLab 的请求设置速率限制，保护实例的稳定性和安全性。
title: 速率限制
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

> [!note]
> 关于 JihuLab.com，请参阅
> [JihuLab.com 专属速率限制](../user/jihulab_com/_index.md#jihulabcom-specific-rate-limits)。
>

速率限制是一种常用技术，用于提升 Web 应用的安全性和持久性。

例如，一个简单的脚本每秒可以发出数千个 Web 请求。这些请求可能是：

- 恶意的。
- 无意的。
- 仅仅是一个缺陷。

您的应用和基础设施可能无法承受这样的负载。更多详情，请参阅[拒绝服务攻击](https://en.wikipedia.org/wiki/Denial-of-service_attack)。大多数情况可以通过限制来自单个 IP 地址的请求速率来缓解。

大多数[暴力破解攻击](https://en.wikipedia.org/wiki/Brute-force_attack)同样可以通过速率限制来缓解。

> [!note]
> API 请求的速率限制不会影响前端发出的请求，因为这些请求始终计为 Web 流量。

<a id="configuration-options"></a>

## 配置选项

您可以在**管理**区域中设置大多数速率限制。有些只能通过 API 或 Rails 控制台设置，而 GitLab Pages 的速率限制则在配置文件中设置。

<a id="admin-area"></a>

### 管理区域

您可以在实例的**管理**区域中设置以下速率限制：

- [API 速率限制](api/_index.md)
- [内容创建速率限制](content_creation.md)
- [Git 操作速率限制](git.md)
- [导入和导出速率限制](../administration/settings/import_export_rate_limits.md)
- [事件管理速率限制](../administration/settings/incident_management_rate_limits.md)
- [流水线创建速率限制](../administration/cicd/limits.md#pipeline-creation-rate-limits)
- [受保护路径](../administration/settings/protected_paths.md)
- [原始端点速率限制](../administration/settings/rate_limits_on_raw_endpoints.md)
- [用户和 IP 速率限制](../administration/settings/user_and_ip_rate_limits.md)
- [Webhook 操作速率限制](../administration/settings/rate-limit-on-webhook-operations.md)

<a id="api-and-rails-console"></a>

### API 和 Rails 控制台

您可以通过[应用设置 API](../api/settings.md) 设置以下速率限制：

- [自动补全用户速率限制](../administration/instance_limits.md#autocomplete-users-rate-limit)
- [AI 操作](../api/settings.md#available-settings)（`ai_action_api_rate_limit`）：每个已认证用户每
  8 小时 160 次调用。适用于 GraphQL `aiAction` mutation。
- [创建标签速率限制](../api/settings.md#available-settings)（`tags_create_limit`）：每个项目每
  30 分钟 100 个请求。适用于创建标签的 REST API 端点、
  GraphQL `tagCreate` mutation、UI 中的标签创建以及 `/tag` 快速操作。

您可以通过[计划限制 API](../api/plan_limits.md) 或 [Rails 控制台](../administration/operations/rails_console.md#starting-a-rails-console-session)设置此速率限制：

- [Webhook 速率限制](../administration/instance_limits.md#webhook-rate-limit)

<a id="configuration-file"></a>

### 配置文件

您只能在安装的配置文件中设置以下速率限制，例如 Linux 软件包安装中的 `/etc/gitlab/gitlab.rb`：

- [GitLab Pages 速率限制](../administration/pages/rate-limits.md)

<a id="non-configurable-limits"></a>

## 不可配置的限制

有些速率限制无法配置。有关这些限制的列表，请参阅[不可配置的速率限制](non_configurable.md)。

<a id="bans-and-blocks"></a>

## 封禁和阻止

有些保护措施会在一段时间内阻止客户端，而不是降低请求速率。更多信息，请参阅[滥用和认证失败封禁](abuse_bans.md)。
