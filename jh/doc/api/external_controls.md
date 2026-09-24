---
stage: Software Supply Chain Security
group: Compliance
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 外部控制 API
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用外部控制 API 来设置使用外部服务的检查状态。

你可以配置带有定期 ping 功能的外部控制。当 ping 启用时（默认），极狐GitLab 每 12 小时自动将控制状态重置为 `pending`。当 ping 禁用时，控制状态仅通过 API 调用更新。

<a id="set-status-of-an-external-control"></a>

设置外部控制的状态

{{< history >}}

- 在极狐GitLab 17.11 中引入。

{{< /history >}}

设置指定外部控制的状态。通过此操作，可告知极狐GitLab 某个控制已通过或未通过外部服务的检查。

先决条件

- 必须使用 HMAC、Timestamp 和 Nonce 认证以确保安全。

```plaintext
PATCH /api/v4/projects/:id/compliance_external_controls/:external_control_id/status
```

HTTP 请求头：

| 请求头 | 类型 | 必填 | 描述 |
| --------------------- | ------- | -------- | --------------------------------------------------------------------------------------------- |
| `X-Gitlab-Timestamp` | 字符串 | 是 | 当前 Unix 时间戳。 |
| `X-Gitlab-Nonce` | 字符串 | 是 | 随机字符串或令牌以防止重放攻击。 |
| `X-Gitlab-Hmac-Sha256` | 字符串 | 是 | 请求的 HMAC-SHA256 签名。 |

要计算 HMAC-SHA256 签名：

1. 按以下顺序连接以下值：
   - `X-Gitlab-Timestamp`
   - `X-Gitlab-Nonce`
   - 请求的完整路径
   - `status` 属性值，格式为 `status=<status>`
2. 使用你的密钥计算连接字符串的 HMAC-SHA256。

支持的属性：

| 属性 | 类型 | 必填 | 描述 |
| ------------------------ | ------- | -------- |---------------------------------------------------------------------------------------------------|
| `id` | 整数 | 是 | 项目的 ID。 |
| `external_control_id` | 整数 | 是 | 外部控制的 ID。 |
| `status` | 字符串 | 是 | 设置为 `pass` 将控制标记为通过，或设置为 `fail` 标记为失败。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性 | 类型 | 描述 |
|--------------------------|----------|-----------------------------------------------|
| `status` | 字符串 | 已为控制设置的状态。 |

请求示例：

```shell
curl --request PATCH \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "X-Gitlab-Timestamp: <X-Gitlab-Timestamp>" \
  --header "X-Gitlab-Nonce: <X-Gitlab-Nonce>" \
  --header "X-Gitlab-Hmac-Sha256: <X-Gitlab-Hmac-Sha256>" \
  --header "Content-Type: application/json" \
  --data '{"status": "pass"}' \
  --url "https://gitlab.example.com/api/v4/projects/<id>/compliance_external_controls/<external_control_id>/status"
```

响应示例：

```json
{
    "status":"pass"
}
```