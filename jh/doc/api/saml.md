---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: SAML API
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 15.5 中引入。

{{< /history >}}

使用此 API 与 SAML 功能进行交互。

<a id="jihulabcom-endpoints"></a>

## JihuLab.com 端点

<a id="list-all-saml-identities-for-a-group"></a>

### 列出一个群组的所有 SAML 身份

```plaintext
GET /groups/:id/saml/identities
```

列出一个群组的所有 SAML 身份。

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|:------------------|:--------|:---------|:----------------------|
| `id` | integer or string | 是 | 群组的 ID 或 [URL-编码路径](rest/_index.md#namespaced-paths) |

如果成功，返回 [`200`](rest/troubleshooting.md#status-codes) 状态码以及以下响应属性：

| 属性 | 类型 | 描述 |
| ------------ | ------ | ------------------------- |
| `extern_uid` | string | 用户的外部 UID |
| `user_id` | string | 用户的 ID |

示例请求：

```shell
curl --location --request GET \
  --header "PRIVATE-TOKEN: <PRIVATE-TOKEN>" \
  --url "https://jihulab.com/api/v4/groups/33/saml/identities"
```

示例响应：

```json
[
    {
        "extern_uid": "yrnZW46BrtBFqM7xDzE7dddd",
        "user_id": 48
    }
]
```

<a id="retrieve-a-single-saml-identity"></a>

### 获取单个 SAML 身份

{{< history >}}

- 在极狐GitLab 16.1 中引入。

{{< /history >}}

获取单个 SAML 身份。

```plaintext
GET /groups/:id/saml/:uid
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | -------------- | -------- | ------------------------- |
| `id` | integer or string | 是 | 群组的 ID 或 [URL-编码路径](rest/_index.md#namespaced-paths) |
| `uid` | string | 是 | 用户的外部 UID。 |

示例请求：

```shell
curl --location --request GET \
  --header "PRIVATE-TOKEN: <PRIVATE TOKEN>" \
  --url "https://jihulab.com/api/v4/groups/33/saml/yrnZW46BrtBFqM7xDzE7dddd"
```

示例响应：

```json
{
    "extern_uid": "yrnZW46BrtBFqM7xDzE7dddd",
    "user_id": 48
}
```

<a id="update-externuid-field-for-a-saml-identity"></a>

### 更新 SAML 身份的 `extern_uid` 字段

更新 SAML 身份的 `extern_uid` 字段：

| SAML IdP 属性 | 极狐GitLab 字段 |
| ------------------ | ------------ |
| `id/externalId` | `extern_uid` |

```plaintext
PATCH /groups/:id/saml/:uid
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ------ | -------- | ------------------------- |
| `id` | integer or string | 是 | 群组的 ID 或 [URL-编码路径](rest/_index.md#namespaced-paths) |
| `uid` | string | 是 | 用户的外部 UID。 |

示例请求：

```shell
curl --request PATCH \
  --location \
  --header "PRIVATE-TOKEN: <PRIVATE TOKEN>" \
  --url "https://jihulab.com/api/v4/groups/33/saml/yrnZW46BrtBFqM7xDzE7dddd" \
  --form "extern_uid=be20d8dcc028677c931e04f387"
```

<a id="delete-a-single-saml-identity"></a>

### 删除单个 SAML 身份

{{< history >}}

- 在极狐GitLab 16.5 中引入。

{{< /history >}}

```plaintext
DELETE /groups/:id/saml/:uid
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ------- | -------- | ------------------------- |
| `id` | integer | 是 | 群组的 ID 或 [URL-编码路径](rest/_index.md#namespaced-paths)。 |
| `uid` | string | 是 | 用户的外部 UID。 |

示例请求：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://jihulab.com/api/v4/groups/33/saml/be20d8dcc028677c931e04f387"
```

示例响应：

```json
{
    "message" : "204 No Content"
}
```

<a id="gitlab-self-managed-endpoints"></a>

## 私有化部署端点

<a id="retrieve-a-single-saml-identity"></a>

### 获取单个 SAML 身份

使用 Users API [以管理员身份获取单个 SAML 身份](users.md#as-an-administrator)。

<a id="update-externuid-field-for-a-saml-identity"></a>

### 更新 SAML 身份的 `extern_uid` 字段

使用 Users API [更新用户的 `extern_uid` 字段](users.md#modify-a-user)。

<a id="delete-a-single-saml-identity"></a>

### 删除单个 SAML 身份

使用 Users API [删除用户的单个身份](users.md#delete-authentication-identity-from-a-user)。

<a id="saml-group-links"></a>

## SAML 群组链接

{{< history >}}

- 在极狐GitLab 15.3.0 中引入。
- `access_level` 类型在极狐GitLab 15.3.3 中从 `string` 改为 `integer`。
- `member_role_id` 类型在极狐GitLab 16.7 中引入，[带有功能标志](../administration/feature_flags/_index.md) 名为 `custom_roles_for_saml_group_links`，默认禁用。
- `member_role_id` 类型在极狐GitLab 16.8 中 [GA]，功能标志 `custom_roles_for_saml_group_links` 已移除。
- `provider` 参数在极狐GitLab 18.2 中引入。

{{< /history >}}

使用 REST API 列出、获取、添加和删除 [SAML 群组链接](../user/group/saml_sso/group_sync.md#configure-saml-group-links)。

<a id="list-all-saml-group-links"></a>

### 列出所有 SAML 群组链接

列出一个群组的所有 SAML 群组链接。

```plaintext
GET /groups/:id/saml_group_links
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|:----------|:---------------|:---------|:------------|
| `id` | integer or string | 是 | 群组的 ID 或 [URL-编码路径](rest/_index.md#namespaced-paths)。 |

如果成功，返回 [`200`](rest/troubleshooting.md#status-codes) 状态码以及以下响应属性：

| 属性 | 类型 | 描述 |
|:--------------------|:--------|:------------|
| `[].name` | string | SAML 群组的名称。 |
| `[].access_level` | integer | SAML 群组成员默认的访问级别。可能的值为：`0` (无访问权限)，`5` (最小访问权限)，`10` (访客)，`15` (计划者)，`20` (报告者)，`25` (安全经理)，`30` (开发者)，`40` (维护者)，或 `50` (所有者)。 |
| `[].member_role_id` | integer | SAML 群组成员的 [成员角色 ID (`member_role_id`)](member_roles.md)。 |
| `[].provider` | string | 必须匹配的唯一[提供程序名称](../integration/saml.md#configure-saml-support-in-gitlab)，此群组链接才能应用。 |

示例请求：

```shell
curl \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/1/saml_group_links"
```

示例响应：

```json
[
  {
    "name": "saml-group-1",
    "access_level": 10,
    "member_role_id": 12,
    "provider": null
  },
  {
    "name": "saml-group-2",
    "access_level": 40,
    "member_role_id": 99,
    "provider": "saml_provider_1"
  }
]
```

<a id="retrieve-a-saml-group-link"></a>

### 获取 SAML 群组链接

获取群组的 SAML 群组链接。

```plaintext
GET /groups/:id/saml_group_links/:saml_group_name
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|:------------------|:---------------|:---------|:------------|
| `id` | integer or string | 是 | 群组的 ID 或 [URL-编码路径](rest/_index.md#namespaced-paths)。 |
| `saml_group_name` | string | 是 | SAML 群组的名称。 |
| `provider` | string | 否 | 唯一的[提供程序名称](../integration/saml.md#configure-saml-support-in-gitlab)，当存在多个同名链接时用于消歧义。当存在多个同名 `saml_group_name` 的链接时必填。 |

如果成功，返回 [`200`](rest/troubleshooting.md#status-codes) 状态码以及以下响应属性：

| 属性 | 类型 | 描述 |
|:-----------------|:--------|:------------|
| `name` | string | SAML 群组的名称。 |
| `access_level` | integer | SAML 群组成员默认的访问级别。可能的值为：`0` (无访问权限)，`5` (最小访问权限)，`10` (访客)，`15` (计划者)，`20` (报告者)，`25` (安全经理)，`30` (开发者)，`40` (维护者)，或 `50` (所有者)。 |
| `member_role_id` | integer | SAML 群组成员的 [成员角色 ID (`member_role_id`)](member_roles.md)。 |
| `provider` | string | 必须匹配的唯一[提供程序名称](../integration/saml.md#configure-saml-support-in-gitlab)，此群组链接才能应用。 |

如果存在多个同名但提供程序不同的 SAML 群组链接，且未指定 `provider` 参数，则返回 [`422`](rest/troubleshooting.md#status-codes) 状态码，并附带错误信息，提示需要 `provider` 参数以消歧义。

示例请求：

```shell
curl \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/1/saml_group_links/saml-group-1"
```

带 provider 参数的示例请求：

```shell
curl \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/1/saml_group_links/saml-group-1?provider=saml_provider_1"
```

示例响应：

```json
{
"name": "saml-group-1",
"access_level": 10,
"member_role_id": 12,
"provider": "saml_provider_1"
}
```

<a id="add-a-saml-group-link"></a>

### 添加 SAML 群组链接

为群组添加 SAML 群组链接。

```plaintext
POST /groups/:id/saml_group_links
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|:------------------|:------------------|:---------|:------------|
| `id` | integer or string | 是 | 群组的 ID 或 [URL-编码路径](rest/_index.md#namespaced-paths)。 |
| `saml_group_name` | string | 是 | SAML 群组的名称。 |
| `access_level` | integer | 是 | SAML 群组成员默认的访问级别。可能的值为：`0` (无访问权限)，`5` (最小访问权限)，`10` (访客)，`15` (计划者)，`20` (报告者)，`25` (安全经理)，`30` (开发者)，`40` (维护者)，或 `50` (所有者)。 |
| `member_role_id` | integer | 否 | SAML 群组成员的 [成员角色 ID (`member_role_id`)](member_roles.md)。 |
| `provider` | string | 否 | 必须匹配的唯一[提供程序名称](../integration/saml.md#configure-saml-support-in-gitlab)，此群组链接才能应用。 |

如果成功，返回 [`201`](rest/troubleshooting.md#status-codes) 状态码以及以下响应属性：

| 属性 | 类型 | 描述 |
|:-----------------|:--------|:------------|
| `name` | string | SAML 群组的名称。 |
| `access_level` | integer | SAML 群组成员默认的访问级别。可能的值为：`0` (无访问权限)，`5` (最小访问权限)，`10` (访客)，`15` (计划者)，`20` (报告者)，`25` (安全经理)，`30` (开发者)，`40` (维护者)，或 `50` (所有者)。 |
| `member_role_id` | integer | SAML 群组成员的 [成员角色 ID (`member_role_id`)](member_roles.md)。 |
| `provider` | string | 必须匹配的唯一[提供程序名称](../integration/saml.md#configure-saml-support-in-gitlab)，此群组链接才能应用。 |

示例请求：

```shell
curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" --header "Content-Type: application/json" --data '{ "saml_group_name": "<your_saml_group_name`>", "access_level": <chosen_access_level>, "member_role_id": <chosen_member_role_id>, "provider": "<your_provider>" }' --url  "https://gitlab.example.com/api/v4/groups/1/saml_group_links"
```

示例响应：

```json
{
"name": "saml-group-1",
"access_level": 10,
"member_role_id": 12,
"provider": "saml_provider_1"
}
```

<a id="delete-a-saml-group-link"></a>

### 删除 SAML 群组链接

删除群组的 SAML 群组链接。

```plaintext
DELETE /groups/:id/saml_group_links/:saml_group_name
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|:------------------|:---------------|:---------|:------------|
| `id` | integer or string | 是 | 群组的 ID 或 [URL-编码路径](rest/_index.md#namespaced-paths)。 |
| `saml_group_name` | string | 是 | SAML 群组的名称。 |
| `provider` | string | 否 | 唯一的[提供程序名称](../integration/saml.md#configure-saml-support-in-gitlab)，当存在多个同名链接时用于消歧义。当存在多个同名 `saml_group_name` 的链接时必填。 |

示例请求：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/1/saml_group_links/saml-group-1"
```

带 provider 参数的示例请求：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/1/saml_group_links/saml-group-1?provider=saml_provider_1"
```

如果成功，返回 [`204`](rest/troubleshooting.md#status-codes) 状态码，没有响应体。

如果存在多个同名但提供程序不同的 SAML 群组链接，且未指定 `provider` 参数，则返回 [`422`](rest/troubleshooting.md#status-codes) 状态码，并附带错误信息，提示需要 `provider` 参数以消歧义。