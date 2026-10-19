---
stage: GitLab Dedicated
group: Import
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Webhook 操作速率限制
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

为以下请求配置每分钟速率限制：

- [测试 Webhook](../../user/project/integrations/webhooks.md#test-a-webhook)。
- [重新发送 Webhook 事件](../../user/project/integrations/webhooks.md#inspect-request-and-response-details)。

| 限制 | 默认值 |
|-------|---------|
| Webhook 测试请求 | 每分钟 5 次 |
| Webhook 事件重新发送请求 | 每分钟 5 次 |

每个速率限制按用户、针对特定项目或群组生效，并同时覆盖 UI 和 API。同一项目或群组中的所有 Webhook 共享该限制。

这些限制与 [Webhook 投递速率限制](../instance_limits.md#webhook-rate-limit) 是分开的，后者限制 Webhook 的触发频率。配置 Webhook 投递速率限制取决于实例类型：

- 在极狐GitLab 私有化部署上，管理员使用 [计划限制 API](../../api/plan_limits.md) 进行配置。
- 在 JihuLab.com 上，投递限制 [取决于您的套餐](../../user/jihulab_com/_index.md#webhooks)，且无法更改。

例如，如果您将 Webhook 测试速率限制设置为 5，并尝试在一分钟内测试 Webhook 六次，则最后一次请求将被阻止。一分钟后，您可以再次测试该 Webhook。

<a id="change-the-rate-limit"></a>

## 更改速率限制

前提条件：

- 管理员访问权限。

要更改速率限制：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **网络**。
1. 展开 **Webhook 速率限制**。
1. 为可用的速率限制设置值。输入 `0` 以禁用速率限制。
1. 选择 **保存更改**。

超过速率限制的请求会记录到 `auth.log` 文件中。
