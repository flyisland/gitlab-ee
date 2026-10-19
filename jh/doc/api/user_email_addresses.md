---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 用户邮箱地址 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 与用户账户的邮箱地址进行交互。更多信息，请参见[用户账户](../user/profile/_index.md)。

<a id="list-all-email-addresses"></a>

## 列出所有邮箱地址

列出您用户账户下的所有邮箱地址。

前提条件：

- 您必须通过身份验证。

```plaintext
GET /user/emails
```

示例响应：

```json
[
  {
    "id": 1,
    "email": "email@example.com",
    "confirmed_at": "2021-03-26T19:07:56.248Z"
  },
  {
    "id": 3,
    "email": "email2@example.com",
    "confirmed_at": null
  }
]
```

<a id="list-all-email-addresses-for-a-user"></a>

## 列出一个用户的所有邮箱地址

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

列出指定用户账户下的所有邮箱地址。

前提条件：

- 您必须具有实例的管理员访问权限。

```plaintext
GET /users/:id/emails
```

支持的属性：

| 属性 | 类型 | 必需 | 描述 |
|:----------|:--------|:---------|:------------|
| `id` | integer | 是 | 用户账户的 ID |

<a id="retrieve-details-on-an-email-address"></a>

## 检索一个邮箱地址的详细信息

检索您用户账户下指定邮箱地址的详细信息。

```plaintext
GET /user/emails/:email_id
```

支持的属性：

| 属性 | 类型 | 必需 | 描述 |
|:-----------|:--------|:---------|:------------|
| `email_id` | integer | 是 | 邮箱地址的 ID |

示例响应：

```json
{
  "id": 1,
  "email": "email@example.com",
  "confirmed_at": "2021-03-26T19:07:56.248Z"
}
```

<a id="add-an-email-address"></a>

## 添加一个邮箱地址

为您用户账户添加一个邮箱地址。

```plaintext
POST /user/emails
```

支持的属性：

| 属性 | 类型 | 必需 | 描述 |
|:----------|:-------|:---------|:------------|
| `email` | string | 是 | 邮箱地址 |

```json
{
  "id": 4,
  "email": "email@example.com",
  "confirmed_at": "2021-03-26T19:07:56.248Z"
}
```

成功时返回一个已创建的邮箱，状态码为 `201 Created`。如果发生错误，则返回 `400 Bad Request` 以及解释错误的消息：

```json
{
  "message": {
    "email": [
      "已经被使用"
    ]
  }
}
```

<a id="add-an-email-address-for-a-user"></a>

## 为一个用户添加邮箱地址

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

为指定用户账户添加一个邮箱地址。

前提条件：

- 您必须具有实例的管理员访问权限。

```plaintext
POST /users/:id/emails
```

支持的属性：

| 属性 | 类型 | 必需 | 描述 |
|:--------------------|:--------|:---------|:------------|
| `id` | string | 是 | 用户账户的 ID |
| `email` | string | 是 | 邮箱地址 |
| `skip_confirmation` | boolean | 否 | 跳过确认并假定邮箱已验证。可选值：`true`，`false`。默认值：`false`。 |

<a id="delete-an-email-address"></a>

## 删除一个邮箱地址

删除您用户账户下的一个邮箱地址。您不能删除主邮箱地址。

将来发送到已删除邮箱地址的任何邮件都将被发送到主邮箱地址。

前提条件：

- 您必须通过身份验证。

```plaintext
DELETE /user/emails/:email_id
```

支持的属性：

| 属性 | 类型 | 必需 | 描述 |
|:-----------|:--------|:---------|:------------|
| `email_id` | integer | 是 | 邮箱地址的 ID |

返回：

- 如果操作成功，返回 `204 No Content`。
- 如果未找到资源，返回 `404`。

<a id="delete-an-email-address-for-a-user"></a>

## 为一个用户删除邮箱地址

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

删除指定用户账户下的一个邮箱地址。您不能删除主邮箱地址。

前提条件：

- 您必须具有实例的管理员访问权限。

```plaintext
DELETE /users/:id/emails/:email_id
```

支持的属性：

| 属性 | 类型 | 必需 | 描述 |
|:-----------|:--------|:---------|:------------|
| `id` | integer | 是 | 用户账户的 ID |
| `email_id` | integer | 是 | 邮箱地址的 ID |