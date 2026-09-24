---
stage: Fulfillment
group: Seat Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: SCIM API
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

{{< history >}}

- 于极狐GitLab 15.5 引入。

{{< /history >}}

使用此 API 管理群组中的 SCIM 身份。

前提条件：

- 必须启用 [群组 SSO](../user/group/saml_sso/_index.md)。
- 必须启用 [群组 SSO 的 SCIM](../user/group/saml_sso/scim_setup.md)。
- 必须使用具有正确范围的 [个人访问令牌](../user/profile/personal_access_tokens.md) 或 [群组访问令牌](../user/group/settings/group_access_tokens.md) 进行认证。

此 API 与 [内部群组 SCIM API](../development/internal_api/_index.md#group-scim-api) 和 [内部实例 SCIM API](../development/internal_api/_index.md#instance-scim-api) 不同，这两个 API 都需要 SCIM 令牌。

- 此 API：
  - 未实现 [RFC7644 协议](https://www.rfc-editor.org/rfc/rfc7644)。
  - 获取、检查、更新和删除群组内的 SCIM 身份。
- 内部群组和实例 SCIM API：
  - 用于 SCIM 提供商集成的系统用途。
  - 实现 [RFC7644 协议](https://www.rfc-editor.org/rfc/rfc7644)。
  - 获取群组或实例的 SCIM 预配用户列表。
  - 创建、删除和更新群组或实例的 SCIM 预配用户。

<a id="retrieve-scim-identities-for-a-group"></a>

## 获取群组的 SCIM 身份

{{< history >}}

- 于极狐GitLab 15.5 引入。

{{< /history >}}

获取群组的 SCIM 身份。

```plaintext
GET /groups/:id/scim/identities
```

支持的属性：

| 属性 | 类型 | 必需 | 描述 |
|:-----|:-----|:------|:------|
| `id` | integer or string | 是 | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |

如果成功，返回 [`200`](rest/troubleshooting.md#status-codes) 和以下响应属性：

| 属性 | 类型 | 描述 |
|------|------|------|
| `extern_uid` | string | 用户的外部 UID |
| `user_id` | integer | 用户的 ID |
| `active` | boolean | 身份的状态 |

示例响应：

```json
[
    {
        "extern_uid": "be20d8dcc028677c931e04f387",
        "user_id": 48,
        "active": true
    }
]
```

示例请求：

```shell
curl --location --request GET \
  --url "https://gitlab.example.com/api/v4/groups/33/scim/identities" \
  --header "PRIVATE-TOKEN: <PRIVATE-TOKEN>"
```

<a id="retrieve-a-single-scim-identity"></a>

## 获取单个 SCIM 身份

{{< history >}}

- 于极狐GitLab 16.1 引入。

{{< /history >}}

获取单个 SCIM 身份。

```plaintext
GET /groups/:id/scim/:uid
```

支持的属性：

| 属性 | 类型 | 必需 | 描述 |
|------|------|------|------|
| `id` | integer | 是 | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `uid` | string | 是 | 用户的外部 UID。 |

示例请求：

```shell
curl --location --request GET \
  --url "https://gitlab.example.com/api/v4/groups/33/scim/be20d8dcc028677c931e04f387" \
  --header "PRIVATE-TOKEN: <PRIVATE TOKEN>"
```

示例响应：

```json
{
    "extern_uid": "be20d8dcc028677c931e04f387",
    "user_id": 48,
    "active": true
}
```

<a id="update-extern_uid-field-for-a-scim-identity"></a>

## 更新 SCIM 身份的 `extern_uid` 字段

{{< history >}}

- 于极狐GitLab 15.5 引入。

{{< /history >}}

更新 SCIM 身份的 `extern_uid` 字段。

可以更新的字段有：

| SCIM/IdP 字段 | 极狐GitLab 字段 |
| --------------- | ------------ |
| `id/externalId` | `extern_uid` |

```plaintext
PATCH /groups/:groups_id/scim/:uid
```

参数：

| 属性 | 类型 | 必需 | 描述 |
|------|------|------|------|
| `id` | integer or string | 是 | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `uid` | string | 是 | 用户的外部 UID。 |

示例请求：

```shell
curl --location --request PATCH \
  --url "https://gitlab.example.com/api/v4/groups/33/scim/be20d8dcc028677c931e04f387" \
  --header "PRIVATE-TOKEN: <PRIVATE TOKEN>" \
  --form "extern_uid=yrnZW46BrtBFqM7xDzE7dddd"
```

<a id="delete-a-single-scim-identity"></a>

## 删除单个 SCIM 身份

{{< history >}}

- 于极狐GitLab 16.5 引入。

{{< /history >}}

删除单个 SCIM 身份。

```plaintext
DELETE /groups/:id/scim/:uid
```

支持的属性：

| 属性 | 类型 | 必需 | 描述 |
|------|------|------|------|
| `id` | integer | 是 | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `uid` | string | 是 | 用户的外部 UID。 |

示例请求：

```shell
curl --location --request DELETE \
  --url "https://gitlab.example.com/api/v4/groups/33/scim/yrnZW46BrtBFqM7xDzE7dddd" \
  --header "PRIVATE-TOKEN: <your_access_token>"
```

示例响应：

```json
{
    "message" : "204 No Content"
}
```