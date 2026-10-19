---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.jihulab.com/handbook/product/ux/technical-writing/#assignments>
title: 应用程序 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

使用该 API 管理实例范围的 OAuth 应用程序，这些应用程序可以：

- [将极狐GitLab 作为身份验证提供者](../integration/oauth_provider.md)。
- [允许代表用户访问极狐GitLab 资源](oauth2.md)。

> [!note]
> 你无法使用此 API 管理群组应用程序或个人用户应用程序。

先决条件：

- 你必须拥有实例的管理员访问权限。

<a id="create-an-application"></a>

## 创建应用程序

创建一个应用程序。

如果请求成功，返回 `200`。

```plaintext
POST /applications
```

支持的属性：

| 属性            | 类型    | 必填 | 描述                                           |
|:---------------|:--------|:-----|:-----------------------------------------------|
| `name`         | string  | 是   | 应用程序的名称。                               |
| `redirect_uri` | string  | 是   | 应用程序的重定向 URI。                         |
| `scopes`       | string  | 是   | 应用程序可用的授权范围。用空格分隔多个范围。   |
| `confidential` | boolean | 否   | 如果为 `true`，应用程序可以安全地存储客户端凭据（如客户端密钥）。不保密的应用程序（如原生移动应用和单页应用）可能会泄露客户端凭据。如果未指定，默认为 `true`。 |

示例请求：

```shell
curl --request POST \
    --header "PRIVATE-TOKEN: <your_access_token>" \
    --data "name=MyApplication&redirect_uri=http://redirect.uri&scopes=api read_user email" \
    --url "https://gitlab.example.com/api/v4/applications"
```

示例响应：

```json
{
    "id":1,
    "application_id": "5832fc6e14300a0d962240a8144466eef4ee93ef0d218477e55f11cf12fc3737",
    "application_name": "MyApplication",
    "secret": "ee1dd64b6adc89cf7e2c23099301ccc2c61b441064e9324d963c46902a85ec34",
    "callback_url": "http://redirect.uri",
    "confidential": true,
    "scopes": ["api", "read_user", "email"]
}
```

<a id="list-all-applications"></a>

## 列出所有应用程序

列出所有应用程序。

```plaintext
GET /applications
```

示例请求：

```shell
curl --request GET \
    --header "PRIVATE-TOKEN: <your_access_token>" \
    --url "https://gitlab.example.com/api/v4/applications"
```

示例响应：

```json
[
    {
        "id":1,
        "application_id": "5832fc6e14300a0d962240a8144466eef4ee93ef0d218477e55f11cf12fc3737",
        "application_name": "MyApplication",
        "callback_url": "http://redirect.uri",
        "confidential": true,
        "scopes": ["api", "read_user"]
    }
]
```

> [!note]
> `secret` 值不在此 API 中公开。

<a id="delete-an-application"></a>

## 删除应用程序

删除指定的应用程序。

如果请求成功，返回 `204`。

```plaintext
DELETE /applications/:id
```

支持的属性：

| 属性 | 类型    | 必填 | 描述                                          |
|:-----|:--------|:-----|:----------------------------------------------|
| `id` | integer | 是   | 应用程序的 ID（非 `application_id`）。 |

示例请求：

```shell
curl --request DELETE \
    --header "PRIVATE-TOKEN: <your_access_token>" \
    --url "https://gitlab.example.com/api/v4/applications/:id"
```

<a id="renew-an-application-secret"></a>

## 更新应用程序密钥

{{< history >}}

- 在极狐GitLab 16.11 引入。

{{< /history >}}

为指定应用程序更新密钥。如果请求成功，返回 `200`。

```plaintext
POST /applications/:id/renew-secret
```

支持的属性：

| 属性 | 类型    | 必填 | 描述                                          |
|:-----|:--------|:-----|:----------------------------------------------|
| `id` | integer | 是   | 应用程序的 ID（非 `application_id`）。 |

示例请求：

```shell
curl --request POST \
    --header "PRIVATE-TOKEN: <your_access_token>" \
    --url "https://gitlab.example.com/api/v4/applications/:id/renew-secret"
```

示例响应：

```json
{
    "id":1,
    "application_id": "5832fc6e14300a0d962240a8144466eef4ee93ef0d218477e55f11cf12fc3737",
    "application_name": "MyApplication",
    "secret": "ee1dd64b6adc89cf7e2c23099301ccc2c61b441064e9324d963c46902a85ec34",
    "callback_url": "http://redirect.uri",
    "confidential": true,
    "scopes": ["api", "read_user"]
}
```