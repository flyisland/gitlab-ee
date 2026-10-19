---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 自定义属性 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

使用此 API 管理用户、群组和项目的自定义属性。

先决条件：

- 您必须是实例的管理员。

<a id="list-all-custom-attributes"></a>

## 列出所有自定义属性

列出指定资源的所有自定义属性。

```plaintext
GET /users/:id/custom_attributes
GET /groups/:id/custom_attributes
GET /projects/:id/custom_attributes
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | 整数 | 是 | 资源的 ID |

```shell
curl --request GET \
   --header "PRIVATE-TOKEN: <your_access_token>" \
   --url "https://gitlab.example.com/api/v4/users/42/custom_attributes"
```

示例响应：

```json
[
   {
      "key": "location",
      "value": "Antarctica"
   },
   {
      "key": "role",
      "value": "开发者"
   }
]
```

<a id="retrieve-a-custom-attribute"></a>

## 检索自定义属性

检索资源的指定自定义属性。

```plaintext
GET /users/:id/custom_attributes/:key
GET /groups/:id/custom_attributes/:key
GET /projects/:id/custom_attributes/:key
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | 整数 | 是 | 资源的 ID |
| `key` | 字符串 | 是 | 自定义属性的键 |

```shell
curl --request GET \
   --header "PRIVATE-TOKEN: <your_access_token>" \
   --url "https://gitlab.example.com/api/v4/users/42/custom_attributes/location"
```

示例响应：

```json
{
   "key": "location",
   "value": "Antarctica"
}
```

<a id="update-a-custom-attribute"></a>

## 更新自定义属性

更新或创建指定资源的自定义属性。如果属性已存在则更新，否则新建。

```plaintext
PUT /users/:id/custom_attributes/:key
PUT /groups/:id/custom_attributes/:key
PUT /projects/:id/custom_attributes/:key
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | 整数 | 是 | 资源的 ID |
| `key` | 字符串 | 是 | 自定义属性的键 |
| `value` | 字符串 | 是 | 自定义属性的值 |

```shell
curl --request PUT \
   --header "PRIVATE-TOKEN: <your_access_token>" \
   --data "value=Greenland" \
   --url "https://gitlab.example.com/api/v4/users/42/custom_attributes/location"
```

示例响应：

```json
{
   "key": "location",
   "value": "Greenland"
}
```

<a id="delete-custom-attribute"></a>

## 删除自定义属性

删除资源的指定自定义属性。

```plaintext
DELETE /users/:id/custom_attributes/:key
DELETE /groups/:id/custom_attributes/:key
DELETE /projects/:id/custom_attributes/:key
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | 整数 | 是 | 资源的 ID |
| `key` | 字符串 | 是 | 自定义属性的键 |

```shell
curl --request DELETE \
   --header "PRIVATE-TOKEN: <your_access_token>" \
   --url "https://gitlab.example.com/api/v4/users/42/custom_attributes/location"
```

