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

使用此 API 与 SAML 功能进行交互。

<a id="gitlabcom-endpoints"></a>

## JihuLab.com 端点

<a id="list-all-saml-identities-for-a-group"></a>

### 列出群组的所有 SAML 身份

```plaintext
GET /groups/:id/saml/identities
```

列出群组的所有 SAML 身份。

支持的属性：

| 属性         | 类型    | 是否必需 | 描述           |
|:------------------|:--------|:---------|:----------------------|
| `id`              | integer or string | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |

如果成功，返回 [`200`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性    | 类型   | 描述               |
| ------------ | ------ | ------------------------- |
| `extern_uid` | string | 用户的外部 UID |
| `user_id`    | string | 用户的 ID           |

示例请求：

```shell
curl --location --request GET \
  --header "PRIVATE-TOKEN: <PRIVATE-TOKEN>" \
  --url "https://gitlab.com/api/v4/groups/33/saml/identities"
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

### 检索单个 SAML 身份

检索单个 SAML 身份。

```plaintext
GET /groups/:id/saml/:uid
```

支持的属性：

| 属性 | 类型           | 是否必需 | 描述               |
| --------- | -------------- | -------- | ------------------------- |
| `id`      | integer or string | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `uid`     | string         | 是      | 用户的外部 UID。 |

示例请求：

```shell
curl --location --request GET \
  --header "PRIVATE-TOKEN: <PRIVATE TOKEN>" \
  --url "https://gitlab.com/api/v4/groups/33/saml/yrnZW46BrtBFqM7xDzE7dddd"
```

示例响应：

```json
{
    "extern_uid": "yrnZW46BrtBFqM7xDzE7dddd",
    "user_id": 48
}
```

<a id="update-extern_uid-field-for-a-saml-identity"></a>

### 更新 SAML 身份的 `extern_uid` 字段

更新 SAML 身份的 `extern_uid` 字段：

| SAML IdP 属性 | 极狐GitLab 字段 |
| ------------------ | ------------ |
| `id/externalId`    | `extern_uid` |

```plaintext
PATCH /groups/:id/saml/:uid
```

支持的属性：

| 属性 | 类型   | 是否必需 | 描述               |
| --------- | ------ | -------- | ------------------------- |
| `id`      | integer or string | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `uid`     | string | 是      | 用户的外部 UID。 |

示例请求：

```shell
curl --request PATCH \
  --location \
  --header "PRIVATE-TOKEN: <PRIVATE TOKEN>" \
  --url "https://gitlab.com/api/v4/groups/33/saml/yrnZW46BrtBFqM7xDzE7dddd" \
  --form "extern_uid=be20d8dcc028677c931e04f387"
```

<a id="delete-a-single-saml-identity"></a>

### 删除单个 SAML 身份

```plaintext
DELETE /groups/:id/saml/:uid
```

支持的属性：

| 属性 | 类型    | 是否必需 | 描述               |
| --------- | ------- | -------- | ------------------------- |
| `id`      | integer | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `uid`     | string  | 是      | 用户的外部 UID。 |

示例请求：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.com/api/v4/groups/33/saml/be20d8dcc028677c931e04f387"
```

示例响应：

```json
{
    "message" : "204 No Content"
}
```

<a id="gitlab-self-managed-endpoints"></a>

## 极狐GitLab 私有化部署端点

<a id="retrieve-a-single-saml-identity-1"></a>

### 检索单个 SAML 身份

使用 Users API [获取单个 SAML 身份](users.md#as-an-administrator)。

<a id="update-extern_uid-field-for-a-saml-identity-1"></a>

### 更新 SAML 身份的 `extern_uid` 字段

使用 Users API [更新用户的 `extern_uid` 字段](users.md#modify-a-user)。

<a id="delete-a-single-saml-identity-1"></a>

### 删除单个 SAML 身份

使用 Users API [删除用户的单个身份](users.md#delete-authentication-identity-from-a-user)。

<a id="saml-group-links"></a>

## SAML 群组链接

使用 REST API 列出、获取、添加和删除 [SAML 群组链接](../user/group/saml_sso/group_sync.md#configure-saml-group-links)。

<a id="list-all-saml-group-links"></a>

### 列出所有 SAML 群组链接

列出群组的所有 SAML 群组链接。

```plaintext
GET /groups/:id/saml_group_links
```

支持的属性：

| 属性 | 类型           | 是否必需 | 描述 |
|:----------|:---------------|:---------|:------------|
| `id`      | integer or string | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

如果成功，返回 [`200`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性           | 类型    | 描述 |
|:--------------------|:--------|:------------|
| `[].name`           | string  | SAML 群组的名称。 |
| `[].access_level`   | integer | SAML 群组成员的默认访问级别。可能的值：`0`（无访问权限）、`5`（最低访问权限）、`10`（访客）、`15`（计划者）、`20`（报告者）、`25`（安全管理员）、`30`（开发者）、`40`（维护者）或 `50`（所有者）。 |
| `[].member_role_id` | integer | SAML 群组成员的[成员角色 ID（`member_role_id`）](member_roles.md)。 |
| `[].provider`       | string  | 唯一的[提供商名称](../integration/saml.md#configure-saml-support-in-gitlab)，必须匹配才能应用此群组链接。 |

示例请求：

```shell
curl --request GET \
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

### 检索 SAML 群组链接

检索群组的 SAML 群组链接。

```plaintext
GET /groups/:id/saml_group_links/:saml_group_name
```

支持的属性：

| 属性         | 类型           | 是否必需 | 描述 |
|:------------------|:---------------|:---------|:------------|
| `id`              | integer or string | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `saml_group_name` | string         | 是      | SAML 群组的名称。 |
| `provider`        | string         | 否       | 唯一的[提供商名称](../integration/saml.md#configure-saml-support-in-gitlab)，用于在存在多个同名链接时进行区分。当存在多个具有相同 `saml_group_name` 的链接时，此属性为必需。 |

如果成功，返回 [`200`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性        | 类型    | 描述 |
|:-----------------|:--------|:------------|
| `name`           | string  | SAML 群组的名称。 |
| `access_level`   | integer | SAML 群组成员的默认访问级别。可能的值：`0`（无访问权限）、`5`（最低访问权限）、`10`（访客）、`15`（计划者）、`20`（报告者）、`25`（安全管理员）、`30`（开发者）、`40`（维护者）或 `50`（所有者）。 |
| `member_role_id` | integer | SAML 群组成员的[成员角色 ID（`member_role_id`）](member_roles.md)。 |
| `provider`       | string  | 唯一的[提供商名称](../integration/saml.md#configure-saml-support-in-gitlab)，必须匹配才能应用此群组链接。 |

如果存在多个同名但提供商不同的 SAML 群组链接，且未指定 `provider` 参数，则返回 [`422`](rest/troubleshooting.md#status-codes)，并附带错误消息，指出需要 `provider` 参数来进行区分。

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/1/saml_group_links/saml-group-1"
```

带 provider 参数的示例请求：

```shell
curl --request GET \
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

| 属性         | 类型              | 是否必需 | 描述 |
|:------------------|:------------------|:---------|:------------|
| `id`              | integer or string | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `saml_group_name` | string            | 是      | SAML 群组的名称。 |
| `access_level`    | integer           | 是      | SAML 群组成员的默认访问级别。可能的值：`0`（无访问权限）、`5`（最低访问权限）、`10`（访客）、`15`（计划者）、`20`（报告者）、`25`（安全管理员）、`30`（开发者）、`40`（维护者）或 `50`（所有者）。 |
| `member_role_id`  | integer           | 否       | SAML 群组成员的[成员角色 ID（`member_role_id`）](member_roles.md)。 |
| `provider`        | string            | 否       | 唯一的[提供商名称](../integration/saml.md#configure-saml-support-in-gitlab)，必须匹配才能应用此群组链接。 |

如果成功，返回 [`201`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性        | 类型    | 描述 |
|:-----------------|:--------|:------------|
| `name`           | string  | SAML 群组的名称。 |
| `access_level`   | integer | SAML 群组成员的默认访问级别。可能的值：`0`（无访问权限）、`5`（最低访问权限）、`10`（访客）、`15`（计划者）、`20`（报告者）、`25`（安全管理员）、`30`（开发者）、`40`（维护者）或 `50`（所有者）。 |
| `member_role_id` | integer | SAML 群组成员的[成员角色 ID（`member_role_id`）](member_roles.md)。 |
| `provider`       | string  | 唯一的[提供商名称](../integration/saml.md#configure-saml-support-in-gitlab)，必须匹配才能应用此群组链接。 |

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --data '{ "saml_group_name": "<your_saml_group_name>", "access_level": <chosen_access_level>, "member_role_id": <chosen_member_role_id>, "provider": "<your_provider>" }' \
  --url "https://gitlab.example.com/api/v4/groups/1/saml_group_links"
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

| 属性         | 类型           | 是否必需 | 描述 |
|:------------------|:---------------|:---------|:------------|
| `id`              | integer or string | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `saml_group_name` | string         | 是      | SAML 群组的名称。 |
| `provider`        | string         | 否       | 唯一的[提供商名称](../integration/saml.md#configure-saml-support-in-gitlab)，用于在存在多个同名链接时进行区分。当存在多个具有相同 `saml_group_name` 的链接时，此属性为必需。 |

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

如果成功，返回 [`204`](rest/troubleshooting.md#status-codes) 状态码，且没有任何响应正文。

如果失败，返回 [`400`](rest/troubleshooting.md#status-codes) 状态码，并在响应正文中附带错误消息。

如果存在多个同名但提供商不同的 SAML 群组链接，且未指定 `provider` 参数，则返回 [`422`](rest/troubleshooting.md#status-codes)，并附带错误消息，指出需要 `provider` 参数来进行区分。
