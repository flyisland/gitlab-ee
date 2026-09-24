---
stage: Fulfillment
group: Utilization
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: yes
title: 许可证 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

<a id="retrieve-license-information"></a>

## 检索许可证信息

检索当前许可证的信息。

```plaintext
GET /license
```

```json
{
  "id": 2,
  "plan": "ultimate",
  "created_at": "2018-02-27T23:21:58.674Z",
  "starts_at": "2018-01-27",
  "expires_at": "2022-01-27",
  "historical_max": 300,
  "maximum_user_count": 300,
  "expired": false,
  "overage": 200,
  "user_limit": 100,
  "active_users": 300,
  "licensee": {
    "Name": "John Doe1",
    "Email": "johndoe1@gitlab.com",
    "Company": "GitLab"
  },
  "add_ons": {
    "GitLab_FileLocks": 1,
    "GitLab_Auditor_User": 1
  }
}
```

<a id="list-all-licenses"></a>

## 列出所有许可证

列出所有许可证的信息。

```plaintext
GET /licenses
```

```json
[
  {
    "id": 1,
    "plan": "premium",
    "created_at": "2018-02-27T23:21:58.674Z",
    "starts_at": "2018-01-27",
    "expires_at": "2022-01-27",
    "historical_max": 300,
    "maximum_user_count": 300,
    "expired": false,
    "overage": 200,
    "user_limit": 100,
    "licensee": {
      "Name": "John Doe1",
      "Email": "johndoe1@gitlab.com",
      "Company": "GitLab"
    },
    "add_ons": {
      "GitLab_FileLocks": 1,
      "GitLab_Auditor_User": 1
    }
  },
  {
    "id": 2,
    "plan": "ultimate",
    "created_at": "2018-02-27T23:21:58.674Z",
    "starts_at": "2018-01-27",
    "expires_at": "2022-01-27",
    "historical_max": 300,
    "maximum_user_count": 300,
    "expired": false,
    "overage": 200,
    "user_limit": 100,
    "licensee": {
      "Name": "Doe John",
      "Email": "doejohn@gitlab.com",
      "Company": "GitLab"
    },
    "add_ons": {
      "GitLab_FileLocks": 1
    }
  }
]
```

超额是计费用户数与许可用户数之间的差值。  
根据许可证是否过期，计算方式有所不同。

- 如果许可证已过期，则使用历史最大计费用户数（`historical_max`）。
- 如果许可证未过期，则使用当前计费用户数。

返回：

- `200 OK` 响应，以 JSON 格式包含许可证信息。如果没有任何许可证，则是一个空的 JSON 数组。
- `403 Forbidden` 如果当前用户无权读取许可证。

<a id="retrieve-a-license"></a>

## 检索某个许可证

检索指定许可证的信息。

```plaintext
GET /license/:id
```

支持的属性：

| 属性 | 类型    | 是否必需 | 描述               |
|-----------|---------|----------|---------------------------|
| `id`      | integer | 是      | 极狐GitLab 许可证的 ID。 |

返回以下状态码：

- `200 OK`：响应包含 JSON 格式的许可证信息。
- `404 Not Found`：请求的许可证不存在。
- `403 Forbidden`：当前用户无权读取许可证。

请求示例：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/license/:id"
```

响应示例：

```json
{
  "id": 1,
  "plan": "premium",
  "created_at": "2018-02-27T23:21:58.674Z",
  "starts_at": "2018-01-27",
  "expires_at": "2022-01-27",
  "historical_max": 300,
  "maximum_user_count": 300,
  "expired": false,
  "overage": 200,
  "user_limit": 100,
  "active_users": 50,
  "licensee": {
    "Name": "John Doe1",
    "Email": "johndoe1@gitlab.com",
    "Company": "GitLab"
  },
  "add_ons": {
    "GitLab_FileLocks": 1,
    "GitLab_Auditor_User": 1
  }
}
```

<a id="create-a-license"></a>

## 创建许可证

创建新许可证。

```plaintext
POST /license
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `license` | string | 是 | 许可证字符串 |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/license?license=eyJkYXRhIjoiMHM5Q...S01Udz09XG4ifQ=="
```

响应示例：

```json
{
  "id": 1,
  "plan": "ultimate",
  "created_at": "2018-02-27T23:21:58.674Z",
  "starts_at": "2018-01-27",
  "expires_at": "2022-01-27",
  "historical_max": 300,
  "maximum_user_count": 300,
  "expired": false,
  "overage": 200,
  "user_limit": 100,
  "active_users": 300,
  "licensee": {
    "Name": "John Doe1",
    "Email": "johndoe1@gitlab.com",
    "Company": "GitLab"
  },
  "add_ons": {
    "GitLab_FileLocks": 1,
    "GitLab_Auditor_User": 1
  }
}
```

返回：

- `201 Created` 如果许可证添加成功。
- `400 Bad Request` 如果许可证添加失败，并附带解释原因的错误消息。

<a id="delete-a-license"></a>

## 删除许可证

删除指定的许可证。

```plaintext
DELETE /license/:id
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | integer | 是 | 极狐GitLab 许可证的 ID。 |

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/license/:id"
```

返回：

- `204 No Content` 如果许可证删除成功。
- `403 Forbidden` 如果当前用户无权删除许可证。
- `404 Not Found` 如果未找到要删除的许可证。

<a id="trigger-recalculation-of-billable-users"></a>

## 触发计费用户重新计算

为指定的许可证触发计费用户重新计算。

```plaintext
PUT /license/:id/refresh_billable_users
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | integer | 是 | 极狐GitLab 许可证的 ID。 |

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/license/:id/refresh_billable_users"
```

响应示例：

```json
{
  "success": true
}
```

返回：

- `202 Accepted` 如果刷新计费用户的请求已成功启动。
- `403 Forbidden` 如果当前用户无权刷新该许可证的计费用户。
- `404 Not Found` 如果未找到许可证。

| 属性                    | 类型          | 描述                               |
|:-----------------------------|:--------------|:------------------------------------------|
| `success`                    | boolean       | 请求是否成功。     |

<a id="retrieve-license-usage-information"></a>

## 检索许可证使用信息

检索当前许可证的使用情况信息并以 CSV 格式导出。

```plaintext
GET /license/usage_export.csv
```

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/license/usage_export.csv"
```

示例响应：

```plaintext
许可证密钥,"eyJkYXRhIjoib1EwRWZXU3RobDY2Yl="
电子邮件,user@example.com
许可证开始日期,2023-02-22
许可证结束日期,2024-02-22
公司,Example Corp.
生成时间,2023-09-05 06:56:23
"",""
日期,计费用户数
2023-07-11 12:00:05,21
2023-07-13 12:00:06,21
2023-08-16 12:00:02,21
2023-09-04 12:00:12,21
```

返回：

- `200 OK`：响应包含 CSV 格式的许可证使用信息。
- `403 Forbidden` 如果当前用户无权查看许可证使用情况。