---
stage: Plan
group: Work Items
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 用于注册和注销移动设备以接收推送通知的 REST API。
title: 移动推送订阅 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

注册移动设备，以接收已认证用户的[待办事项](todos.md)推送通知。每条推送通知对应一个待办事项。

<a id="register-a-device"></a>

## 注册设备

为已认证用户注册设备令牌。此端点是一个幂等的 upsert 操作：再次注册现有令牌会刷新其属性和 `last_seen_at` 时间戳，因此客户端会在每次应用启动时重新注册。如果令牌已注册，请求中省略的属性将保留其存储值。注册属于其他用户的令牌会将其重新分配给已认证用户。

每个用户最多可以注册 20 台设备。超过 90 天未使用的订阅会被自动移除。

```plaintext
POST /user/push_subscriptions
```

支持的属性：

| 属性          | 类型   | 必填 | 描述 |
|--------------------|--------|----------|-------------|
| `device_token`     | string | 是      | 十六进制 APNs 设备令牌。 |
| `platform`         | string | 否       | 设备平台。仅支持 `ios`。新注册默认使用 `ios`。 |
| `apns_environment` | string | 否       | 签发该令牌所针对的 APNs 环境：`production` 或 `sandbox`。默认值：`production`。 |
| `bundle_id`        | string | 否       | 应用程序包标识符。 |
| `device_name`      | string | 否       | 人类可读的设备名称。 |
| `app_version`      | string | 否       | 已安装的应用程序版本。 |
| `locale`           | string | 否       | 设备区域设置。 |
| `payload_mode`     | string | 否       | `full` 在推送负载中发送通知内容。`id_only` 仅发送记录标识符，用于无内容的负载。新注册默认使用 `full`。 |

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --data "device_token=abcdef0123456789abcdef0123456789" \
  --data "apns_environment=sandbox" \
  --url "https://gitlab.example.com/api/v4/user/push_subscriptions"
```

如果成功，返回 [`201`](rest/troubleshooting.md#status-codes) 及以下响应属性：

| 属性    | 类型    | 描述 |
|--------------|---------|-------------|
| `id`         | integer | 订阅的 ID。 |
| `created_at` | string  | 订阅创建的日期和时间，采用 ISO 8601 格式。 |

示例响应：

```json
{
  "id": 1,
  "created_at": "2026-07-30T18:15:31.189Z"
}
```

<a id="unregister-a-device"></a>

## 注销设备

删除已认证用户针对某个设备令牌的订阅，例如在退出登录时。令牌在请求体中传递，而不是在 URL 中传递，这样它就不会出现在访问日志中。成功时返回 `204 No Content`，当不存在匹配的订阅时返回 `404 Not Found`。

```plaintext
DELETE /user/push_subscriptions
```

支持的属性：

| 属性      | 类型   | 必填 | 描述 |
|----------------|--------|----------|-------------|
| `device_token` | string | 是      | 十六进制 APNs 设备令牌。 |

示例请求：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --data "device_token=abcdef0123456789abcdef0123456789" \
  --url "https://gitlab.example.com/api/v4/user/push_subscriptions"
```
