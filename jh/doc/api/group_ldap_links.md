---
stage: Fulfillment
group: Seat Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: no
title: LDAP 群组链接
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

使用此 API 管理 LDAP 群组链接。有关更多信息，请参阅[使用 LDAP 管理群组成员资格](../user/group/access_and_permissions.md#manage-group-memberships-with-ldap)。

<a id="list-all-ldap-group-links"></a>

## 列出所有 LDAP 群组链接

列出所有 LDAP 群组链接。

```plaintext
GET /groups/:id/ldap_group_links
```

支持的属性：

| 属性 | 类型           | 必需 | 描述 |
| --------- | -------------- | -------- | ----------- |
| `id`      | integer 或 string | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

请求示例：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
     --url "https://gitlab.example.com/api/v4/groups/4/ldap_group_links"
```

响应示例：

```json
[
  {
    "cn": "group1",
    "group_access": 40,
    "provider": "ldapmain",
    "filter": null,
    "member_role_id": null
  },
  {
    "cn": "group2",
    "group_access": 10,
    "provider": "ldapmain",
    "filter": null,
    "member_role_id": null
  }
]
```

<a id="add-an-ldap-group-link-with-cn-or-filter"></a>

## 使用 CN 或过滤器添加 LDAP 群组链接

使用 CN 或过滤器添加 LDAP 群组链接。

```plaintext
POST /groups/:id/ldap_group_links
```

支持的属性：

| 属性 | 类型           | 必需 | 描述 |
| --------- | -------------- | -------- | ----------- |
| `id`      | integer 或 string | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `group_access` | integer   | 是      | LDAP 群组成员的默认访问级别。可能的值：`0`（无访问权限），`5`（最小访问），`10`（访客），`15`（计划者），`20`（报告者），`25`（安全经理），`30`（开发者），`40`（维护者），`50`（所有者）。 |
| `provider` | string        | 是      | LDAP 群组链接的 LDAP 提供程序 ID。 |
| `cn`      | string         | 是/否   | LDAP 群组的 CN。提供 `cn` 或 `filter` 中的一个，但不能同时提供两者。 |
| `filter`  | string         | 是/否   | 群组的 LDAP 过滤器。提供 `cn` 或 `filter` 中的一个，但不能同时提供两者。 |
| `member_role_id` | integer | 否       | [成员角色](member_roles.md)的 ID。仅旗舰版。 |

请求示例：

```shell
curl --request POST \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Content-Type: application/json" \
     --data '{"group_access": 40, "provider": "ldapmain", "cn": "group2"}' \
     --url "https://gitlab.example.com/api/v4/groups/4/ldap_group_links"
```

响应示例：

```json
{
  "cn": "group2",
  "group_access": 40,
  "provider": "main",
  "filter": null,
  "member_role_id": null
}
```

<a id="delete-an-ldap-group-link-with-cn-or-filter"></a>

## 使用 CN 或过滤器删除 LDAP 群组链接

使用 CN 或过滤器删除 LDAP 群组链接。

```plaintext
DELETE /groups/:id/ldap_group_links
```

支持的属性：

| 属性 | 类型           | 必需 | 描述 |
| --------- | -------------- | -------- | ----------- |
| `id`      | integer 或 string | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `provider` | string        | 是      | LDAP 群组链接的 LDAP 提供程序 ID。 |
| `cn`      | string         | 是/否   | LDAP 群组的 CN。提供 `cn` 或 `filter` 中的一个，但不能同时提供两者。 |
| `filter`  | string         | 是/否   | 群组的 LDAP 过滤器。提供 `cn` 或 `filter` 中的一个，但不能同时提供两者。 |

请求示例：

```shell
curl --request DELETE \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Content-Type: application/json" \
     --data '{"provider": "ldapmain", "cn": "group2"}' \
     --url "https://gitlab.example.com/api/v4/groups/4/ldap_group_links"
```

如果成功，则不返回响应。

<a id="delete-an-ldap-group-link-deprecated"></a>

## 删除 LDAP 群组链接（已弃用）

删除 LDAP 群组链接。已弃用。计划在未来的版本中移除。
请改用[使用 CN 或过滤器删除 LDAP 群组链接](#delete-an-ldap-group-link-with-cn-or-filter)。

使用 CN 删除 LDAP 群组链接：

```plaintext
DELETE /groups/:id/ldap_group_links/:cn
```

| 属性 | 类型           | 必需 | 描述 |
| --------- | -------------- | -------- | ----------- |
| `id`      | integer 或 string | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `cn`      | string         | 是      | LDAP 群组的 CN。 |

为特定 LDAP 提供程序删除 LDAP 群组链接：

```plaintext
DELETE /groups/:id/ldap_group_links/:provider/:cn
```

| 属性 | 类型           | 必需 | 描述 |
| --------- | -------------- | -------- | ----------- |
| `id`      | integer 或 string | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `cn`      | string         | 是      | LDAP 群组的 CN。 |
| `provider` | string        | 是      | LDAP 群组链接的 LDAP 提供程序。 |