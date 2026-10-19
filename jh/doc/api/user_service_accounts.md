---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: 服务账号用户 API
---

{{< details >}}

- Tier: 专业版, 旗舰版
- Offering: 私有化部署

{{< /details >}}

使用此 API 与服务账户进行交互。有关更多信息，请参见 [Service accounts](../user/profile/service_accounts.md)。

<a id="list-all-service-account-users"></a>

## 列出所有服务账户用户

{{< details >}}

- Tier: Premium, Ultimate
- Offering: GitLab Self-Managed, GitLab Dedicated

{{< /details >}}

{{< history >}}

- 列出所有的服务账号用户引入于极狐GitLab 17.1。

{{< /history >}}

列出所有服务账户用户。

使用 `page` 和 `per_page` [分页参数](rest/_index.md#offset-based-pagination) 来过滤结果。

先决条件：

- 您必须拥有实例的管理员访问权限。

```plaintext
GET /service_accounts
```

支持的属性：

| 属性         | 类型   | 必需   | 描述                                                                 |
|:-------------|:-------|:-------|:---------------------------------------------------------------------|
| `order_by`   | string | 否     | 用于排序结果的属性。可能的值：`id` 或 `username`。默认值：`id`。   |
| `sort`       | string | 否     | 排序结果的方向。可能的值：`desc` 或 `asc`。默认值：`desc`。        |

示例请求：

```shell
curl --request GET --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/service_accounts"
```

示例响应：

```json
[
  {
    "id": 114,
    "username": "service_account_33",
    "name": "Service account user"
  },
  {
    "id": 137,
    "username": "service_account_34",
    "name": "john doe"
  }
]
```

<a id="create-a-service-account-user"></a>

## 创建服务账户用户

{{< history >}}

- 创建服务账号用户引入于极狐GitLab 16.1。
- 用户名和名称属性引入于极狐GitLab 16.10。

{{< /history >}}

创建一个服务账户用户。

先决条件：

- 您必须拥有实例的管理员访问权限。

```plaintext
POST /service_accounts
```

支持的属性：

| 属性       | 类型   | 必需   | 描述                                                                 |
|:-----------|:-------|:-------|:---------------------------------------------------------------------|
| `name`     | string | 否     | 用户的名称。如果未设置，则使用 `Service account user`。              |
| `username` | string | 否     | 用户账户的用户名。如果未设置，则生成一个以 `service_account_` 为前缀的名称。 |
| `email`    | string | 否     | 用户账户的电子邮件。如果未设置，则生成一个不回复的电子邮件地址。     |

示例请求：

```shell
curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" "https://gitlab.example.com/api/v4/service_accounts"
```

示例响应：

```json
{
  "id": 57,
  "username": "service_account_6018816a18e515214e0c34c2b33523fc",
  "name": "Service account user",
  "email": "service_account_6018816a18e515214e0c34c2b33523fc@noreply.gitlab.example.com"
}
```

<a id="specify-a-custom-email-address"></a>

### 指定自定义电子邮件地址

{{< history >}}

- 引入于极狐GitLab 17.9。

{{< /history >}}

您可以在服务账户创建时指定一个自定义电子邮件地址，以接收该服务账户操作的通知。

示例请求：

```shell
curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" --data "email=custom_email@gitlab.example.com" "https://gitlab.example.com/api/v4/service_accounts"
```

示例响应：

```json
{
  "id": 57,
  "username": "service_account_6018816a18e515214e0c34c2b33523fc",
  "name": "Service account user",
  "email": "custom_email@gitlab.example.com"
}
```

如果该电子邮件地址已被其他用户占用，则请求将失败：

```json
{
  "message": "400 Bad request - Email has already been taken"
}
```
