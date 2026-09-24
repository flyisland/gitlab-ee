---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 用户应用程序 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

使用此 API 管理用户级 OAuth 应用程序，这些应用程序可以：

- [使用极狐GitLab 作为身份验证提供程序](../integration/oauth_provider.md)。
- [允许代表用户访问极狐GitLab 资源](oauth2.md)。

> [!note]
> 要管理实例级应用程序，请使用 [应用程序 API](applications.md)。

先决条件：

- 管理员访问权限，或已通过拥有该应用程序的用户身份验证。

<a id="create-an-application"></a>

## 创建应用程序

为已通过身份验证的用户创建新的 OAuth 应用程序。

如果请求成功，则返回 `201`。

```plaintext
POST /user/applications
```

支持的属性：

| 属性      | 类型    | 必填 | 描述                      |
|:---------------|:--------|:---------|:---------------------------------|
| `name`         | string  | 是      | 应用程序的名称。         |
| `redirect_uri` | string  | 是      | 应用程序的重定向 URI。 |
| `scopes`       | string  | 是      | 应用程序可用的作用域。多个作用域之间用空格分隔。 |
| `confidential` | boolean | 否       | 如果为 `true`，则应用程序可以安全地存储客户端凭据，例如客户端密钥。非机密应用程序（例如原生移动应用和单页应用）可能会暴露客户端凭据。如果未指定，则默认为 `true`。 |

示例请求：

```shell
curl --request POST \
    --header "PRIVATE-TOKEN: <your_access_token>" \
    --data "name=MyApplication&redirect_uri=http://redirect.uri&scopes=api read_user email" \
    --url "https://gitlab.example.com/api/v4/user/applications"
```

示例响应：

```json
{
    "id":1,
    "application_id": "5832fc6e14300a0d962240a8144466eef4ee93ef0d218477e55f11cf12fc3737",
    "application_name": "MyApplication",
    "secret": "ee1dd64b6adc89cf7e2c23099301ccc2c61b441064e9324d963c46902a85ec34",
    "callback_url": "http://redirect.uri",
    "confidential": true
}
```

<a id="list-all-applications"></a>

## 列出所有应用程序

列出已通过身份验证的用户拥有的所有应用程序。

```plaintext
GET /user/applications
```

示例请求：

```shell
curl --request GET \
    --header "PRIVATE-TOKEN: <your_access_token>" \
    --url "https://gitlab.example.com/api/v4/user/applications"
```

示例响应：

```json
[
    {
        "id":1,
        "application_id": "5832fc6e14300a0d962240a8144466eef4ee93ef0d218477e55f11cf12fc3737",
        "application_name": "MyApplication",
        "callback_url": "http://redirect.uri",
        "confidential": true
    }
]
```

<a id="retrieve-a-specific-application"></a>

## 检索特定应用程序

检索已通过身份验证的用户拥有的特定应用程序的详细信息。

如果请求成功，则返回 `200`。

```plaintext
GET /user/applications/:id
```

支持的属性：

| 属性 | 类型    | 必填 | 描述                                         |
|:----------|:--------|:---------|:----------------------------------------------------|
| `id`      | integer | 是      | 应用程序的 ID。与 `application_id` 不同。 |

示例请求：

```shell
curl --request GET \
    --header "PRIVATE-TOKEN: <your_access_token>" \
    --url "https://gitlab.example.com/api/v4/user/applications/:id"
```

示例响应：

```json
{
    "id":1,
    "application_id": "5832fc6e14300a0d962240a8144466eef4ee93ef0d218477e55f11cf12fc3737",
    "application_name": "MyApplication",
    "callback_url": "http://redirect.uri",
    "confidential": true
}
```

<a id="update-an-application"></a>

## 更新应用程序

更新已通过身份验证的用户拥有的现有应用程序。

如果请求成功，则返回 `200`。

```plaintext
PUT /user/applications/:id
```

支持的属性：

| 属性      | 类型    | 必填 | 描述                      |
|:---------------|:--------|:---------|:---------------------------------|
| `id`           | integer | 是      | 应用程序的 ID。与 `application_id` 不同。 |
| `name`         | string  | 否       | 应用程序的名称。         |
| `scopes`       | string  | 否       | 应用程序可用的作用域。多个作用域之间用空格分隔。 |

示例请求：

```shell
curl --request PUT \
    --header "PRIVATE-TOKEN: <your_access_token>" \
    --data "name=UpdatedApplication" \
    --url "https://gitlab.example.com/api/v4/user/applications/:id"
```

示例响应：

```json
{
    "id":1,
    "application_id": "5832fc6e14300a0d962240a8144466eef4ee93ef0d218477e55f11cf12fc3737",
    "application_name": "UpdatedApplication",
    "callback_url": "http://redirect.uri",
    "confidential": true
}
```

<a id="delete-an-application"></a>

## 删除应用程序

删除已通过身份验证的用户拥有的指定应用程序。

如果请求成功，则返回 `204`。

```plaintext
DELETE /user/applications/:id
```

支持的属性：

| 属性 | 类型    | 必填 | 描述                                         |
|:----------|:--------|:---------|:----------------------------------------------------|
| `id`      | integer | 是      | 应用程序的 ID。与 `application_id` 不同。 |

示例请求：

```shell
curl --request DELETE \
    --header "PRIVATE-TOKEN: <your_access_token>" \
    --url "https://gitlab.example.com/api/v4/user/applications/:id"
```
