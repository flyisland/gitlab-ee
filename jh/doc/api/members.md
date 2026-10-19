---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: 群组和项目成员 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 与群组和项目成员进行交互。

<a id="roles"></a>

## 角色

[角色](../user/permissions.md) 分配给用户或群组在 `Gitlab::Access` 模块中定义为 `access_level`。

- 无访问权限 (`0`)
- 最小访问权限 (`5`)
- 客人 (`10`)
- 计划者 (`15`)
- 报告者 (`20`)
- 开发者 (`30`)
- 维护者 (`40`)
- 所有者 (`50`)
- **管理员** (`60`)

<a id="known-issues"></a>

## 已知问题

- `group_saml_identity` 属性仅对 [启用 SSO 的群组](../user/group/saml_sso/_index.md) 的群组所有者可见。
- 当发送 API 请求到群组本身或该群组的子群组或项目时，`email` 属性仅对群组的 [企业用户](../user/enterprise_user/_index.md) 的群组所有者可见。

<a id="list-all-members-of-a-group-or-project"></a>

## 列出群组或项目的所有成员

获取经过身份验证的用户可查看的群组或项目成员列表。仅返回直接成员，不包括通过祖先群组继承的成员。

此函数接受分页参数 `page` 和 `per_page` 来限制用户列表。

```plaintext
GET /groups/:id/members
GET /projects/:id/members
```

| 属性              | 类型              | 必需 | 描述 |
|------------------|-------------------|----------|-------------|
| `id`             | 整数或字符串 | 是      | 项目或群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `query`          | 字符串            | 否       | 根据给定的名称、电子邮件或用户名过滤结果。使用部分值来扩大查询范围。 |
| `user_ids`       | 整数数组 | 否       | 根据给定的用户 ID 过滤结果。 |
| `skip_users`     | 整数数组 | 否       | 从结果中过滤掉跳过的用户。 |
| `show_seat_info` | 布尔值           | 否       | 显示用户的座位信息。 |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/:id/members"
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/:id/members"
```

示例响应：

```json
[
  {
    "id": 1,
    "username": "raymond_smith",
    "name": "Raymond Smith",
    "state": "active",
    "avatar_url": "https://www.gravatar.com/avatar/c2525a7f58ae3776070e44c106c48e15?s=80&d=identicon",
    "web_url": "http://192.168.1.8:3000/root",
    "created_at": "2012-09-22T14:13:35Z",
    "created_by": {
      "id": 2,
      "username": "john_doe",
      "name": "John Doe",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/c2525a7f58ae3776070e44c106c48e15?s=80&d=identicon",
      "web_url": "http://192.168.1.8:3000/root"
    },
    "expires_at": "2012-10-22",
    "access_level": 30,
    "group_saml_identity": null
  },
  {
    "id": 2,
    "username": "john_doe",
    "name": "John Doe",
    "state": "active",
    "avatar_url": "https://www.gravatar.com/avatar/c2525a7f58ae3776070e44c106c48e15?s=80&d=identicon",
    "web_url": "http://192.168.1.8:3000/root",
    "created_at": "2012-09-22T14:13:35Z",
    "created_by": {
      "id": 1,
      "username": "raymond_smith",
      "name": "Raymond Smith",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/c2525a7f58ae3776070e44c106c48e15?s=80&d=identicon",
      "web_url": "http://192.168.1.8:3000/root"
    },
    "expires_at": "2012-10-22",
    "access_level": 30,
    "email": "john@example.com",
    "group_saml_identity": {
      "extern_uid":"ABC-1234567890",
      "provider": "group_saml",
      "saml_provider_id": 10
    }
  }
]
```

<a id="list-all-members-of-a-group-or-project-including-inherited-and-invited-members"></a>

## 列出群组或项目的所有成员，包括继承和邀请的成员

{{< history >}}

- 在极狐GitLab 16.10 中，如果当前用户是共享群组或项目的成员，更改为返回受邀私有群组的成员。使用名 `webui_members_inherited_users` 的[功能标志](../administration/feature_flags.md)。默认禁用。
- 功能标志 `webui_members_inherited_users` 在极狐GitLab  17.0 中已为 JihuLab.com 和极狐GitLab 私有化部署启用。
- 功能标志 `webui_members_inherited_users` 在极狐GitLab 17.4 中已移除。默认显示受邀群组成员。

{{< /history >}}

获取经过身份验证的用户可查看的群组或项目成员列表，包括继承的成员、邀请的用户，以及通过祖先群组的权限。

如果用户是此群组或项目的成员，并且也是一个或多个祖先群组的成员，则仅返回其具有最高 `access_level` 的成员资格。这代表了用户的有效权限。

如果满足以下条件之一，则返回来自受邀群组的成员：

- 受邀群组是公开的。
- 请求者也是受邀群组的成员。
- 请求者是共享群组或项目的成员。

{{< alert type="note" >}}

受邀群组成员在共享群组或项目中具有共享成员资格。这意味着如果请求者是共享群组或项目的成员，但不是受邀私有群组的成员，那么使用此端点，请求者可以获取所有共享群组或项目成员，包括受邀私有群组成员。

{{< /alert >}}

此函数接受分页参数 `page` 和 `per_page` 来限制用户列表。

```plaintext
GET /groups/:id/members/all
GET /projects/:id/members/all
```

| 属性              | 类型              | 必需 | 描述 |
|------------------|-------------------|----------|-------------|
| `id`             | 整数或字符串 | 是      | 项目或群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `query`          | 字符串            | 否       | 根据给定的名称、电子邮件或用户名过滤结果。使用部分值来扩大查询范围。 |
| `user_ids`       | 整数数组 | 否       | 根据给定的用户 ID 过滤结果。 |
| `show_seat_info` | 布尔值           | 否       | 显示用户的座位信息。 |
| `state`          | 字符串            | 否       | 按成员状态过滤结果，`awaiting` 或 `active` 之一。专业版和旗舰版专用。 |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/:id/members/all"
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/:id/members/all"
```

示例响应：

```json
[
  {
    "id": 1,
    "username": "raymond_smith",
    "name": "Raymond Smith",
    "state": "active",
    "avatar_url": "https://www.gravatar.com/avatar/c2525a7f58ae3776070e44c106c48e15?s=80&d=identicon",
    "web_url": "http://192.168.1.8:3000/root",
    "created_at": "2012-09-22T14:13:35Z",
    "created_by": {
      "id": 2,
      "username": "john_doe",
      "name": "John Doe",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/c2525a7f58ae3776070e44c106c48e15?s=80&d=identicon",
      "web_url": "http://192.168.1.8:3000/root"
    },
    "expires_at": "2012-10-22",
    "access_level": 30,
    "group_saml_identity": null
  },
  {
    "id": 2,
    "username": "john_doe",
    "name": "John Doe",
    "state": "active",
    "avatar_url": "https://www.gravatar.com/avatar/c2525a7f58ae3776070e44c106c48e15?s=80&d=identicon",
    "web_url": "http://192.168.1.8:3000/root",
    "created_at": "2012-09-22T14:13:35Z",
    "created_by": {
      "id": 1,
      "username": "raymond_smith",
      "name": "Raymond Smith",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/c2525a7f58ae3776070e44c106c48e15?s=80&d=identicon",
      "web_url": "http://192.168.1.8:3000/root"
    },
    "expires_at": "2012-10-22",
    "access_level": 30,
    "email": "john@example.com",
    "group_saml_identity": {
      "extern_uid":"ABC-1234567890",
      "provider": "group_saml",
      "saml_provider_id": 10
    }
  },
  {
    "id": 3,
    "username": "foo_bar",
    "name": "Foo bar",
    "state": "active",
    "avatar_url": "https://www.gravatar.com/avatar/c2525a7f58ae3776070e44c106c48e15?s=80&d=identicon",
    "web_url": "http://192.168.1.8:3000/root",
    "created_at": "2012-10-22T14:13:35Z",
    "created_by": {
      "id": 2,
      "username": "john_doe",
      "name": "John Doe",
      "state": "active",
      "avatar_url": "https://www.gravatar.com/avatar/c2525a7f58ae3776070e44c106c48e15?s=80&d=identicon",
      "web_url": "http://192.168.1.8:3000/root"
    },
    "expires_at": "2012-11-22",
    "access_level": 30,
    "group_saml_identity": null
  }
]
```

<a id="get-a-member-of-a-group-or-project"></a>

## 获取群组或项目的成员

获取群组或项目的成员。仅返回直接成员，不包括通过祖先群组继承的成员。

```plaintext
GET /groups/:id/members/:user_id
GET /projects/:id/members/:user_id
```

| 属性      | 类型              | 必需 | 描述 |
|-----------|-------------------|----------|-------------|
| `id`      | 整数或字符串 | 是      | 项目或群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `user_id` | 整数           | 是      | 成员的用户 ID。 |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/:id/members/:user_id"
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/:id/members/:user_id"
```

示例响应：

```json
{
  "id": 1,
  "username": "raymond_smith",
  "name": "Raymond Smith",
  "state": "active",
  "avatar_url": "https://www.gravatar.com/avatar/c2525a7f58ae3776070e44c106c48e15?s=80&d=identicon",
  "web_url": "http://192.168.1.8:3000/root",
  "access_level": 30,
  "email": "john@example.com",
  "created_at": "2012-10-22T14:13:35Z",
  "created_by": {
    "id": 2,
    "username": "john_doe",
    "name": "John Doe",
    "state": "active",
    "avatar_url": "https://www.gravatar.com/avatar/c2525a7f58ae3776070e44c106c48e15?s=80&d=identicon",
    "web_url": "http://192.168.1.8:3000/root"
  },
  "expires_at": null,
  "group_saml_identity": null
}
```

<a id="get-a-member-of-a-group-or-project-including-inherited-and-invited-members"></a>

## 获取群组或项目的成员，包括继承和邀请的成员

{{< history >}}

- 在极狐GitLab 12.4 中引入。
- 在极狐GitLab 16.10 中，如果当前用户是共享群组或项目的成员，则返回受邀私有群组的成员。使用名为 `webui_members_inherited_users` d的[功能标志](../administration/feature_flags.md)。默认禁用。
- JihuLab.com 和极狐GitLab 私有化部署在 17.0 中启用。
- 功能标志 `webui_members_inherited_users` 在极狐GitLab  17.4 中已移除。默认显示受邀群组成员。

{{< /history >}}

获取群组或项目的成员，包括通过祖先群组继承或邀请的成员。有关详细信息，请参阅对应的 [端点以列出所有继承的成员](#list-all-members-of-a-group-or-project-including-inherited-and-invited-members)。

{{< alert type="note" >}}

受邀群组成员在共享群组或项目中具有共享成员资格。这意味着如果请求者是共享群组或项目的成员，但不是受邀私有群组的成员，那么使用此端点，请求者可以获取所有共享群组或项目成员，包括受邀私有群组成员。

{{< /alert >}}

```plaintext
GET /groups/:id/members/all/:user_id
GET /projects/:id/members/all/:user_id
```

| 属性      | 类型              | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id`      | 整数或字符串 | 是 | 项目或群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `user_id` | 整数 | 是   | 成员的用户 ID。 |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/:id/members/all/:user_id"
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/:id/members/all/:user_id"
```

示例响应：

```json
{
  "id": 1,
  "username": "raymond_smith",
  "name": "Raymond Smith",
  "state": "active",
  "avatar_url": "https://www.gravatar.com/avatar/c2525a7f58ae3776070e44c106c48e15?s=80&d=identicon",
  "web_url": "http://192.168.1.8:3000/root",
  "access_level": 30,
  "created_at": "2012-10-22T14:13:35Z",
  "created_by": {
    "id": 2,
    "username": "john_doe",
    "name": "John Doe",
    "state": "active",
    "avatar_url": "https://www.gravatar.com/avatar/c2525a7f58ae3776070e44c106c48e15?s=80&d=identicon",
    "web_url": "http://192.168.1.8:3000/root"
  },
  "email": "john@example.com",
  "expires_at": null,
  "group_saml_identity": null
}
```

<a id="list-all-billable-members-of-a-group"></a>

## 列出群组的所有计费成员

获取计费成员的群组成员列表。该列表包括子群组和项目中的成员。

前提条件：

- 您必须具有所有者角色才能访问用于计费权限的 API 端点，如 [计费权限](../user/free_user_limit.md) 中所示。
- 此 API 端点仅在顶级群组上工作。它不适用于子群组。

此函数接受 [分页](rest/_index.md#pagination) 参数 `page` 和 `per_page` 来限制用户列表。

使用 `search` 参数按名称搜索计费群组成员，使用 `sort` 参数对结果进行排序。

```plaintext
GET /groups/:id/billable_members
```

| 属性 | 类型              | 必需 | 描述 |
|-----------|-------------------|----------|-------------|
| `id`      | 整数或字符串 | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `search`  | 字符串            | 否       | 一个查询字符串，用于按名称、用户名或公开电子邮件搜索群组成员。 |
| `sort`    | 字符串            | 否       | 包含指定排序属性和顺序的查询字符串。请参阅下面的支持值。 |

`sort` 属性的支持值为：

| 值                   | 描述                  |
| ----------------------- | ---------------------------- |
| `access_level_asc`      | 访问级别，升序      |
| `access_level_desc`     | 访问级别，降序     |
| `last_joined`           | 最近加入                  |
| `name_asc`              | 名称，升序              |
| `name_desc`             | 名称，降序             |
| `oldest_joined`         | 最早加入                |
| `oldest_sign_in`        | 最早登录               |
| `recent_sign_in`        | 最近登录               |
| `last_activity_on_asc`  | 最近活动日期，升序  |
| `last_activity_on_desc` | 最近活动日期，降序 |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/:id/billable_members"
```

示例响应：

```json
[
  {
    "id": 1,
    "username": "raymond_smith",
    "name": "Raymond Smith",
    "state": "active",
    "avatar_url": "https://www.gravatar.com/avatar/c2525a7f58ae3776070e44c106c48e15?s=80&d=identicon",
    "web_url": "http://192.168.1.8:3000/root",
    "last_activity_on": "2021-01-27",
    "membership_type": "group_member",
    "removable": true,
    "created_at": "2021-01-03T12:16:02.000Z",
    "last_login_at": "2022-10-09T01:33:06.000Z"
  },
  {
    "id": 2,
    "username": "john_doe",
    "name": "John Doe",
    "state": "active",
    "avatar_url": "https://www.gravatar.com/avatar/c2525a7f58ae3776070e44c106c48e15?s=80&d=identicon",
    "web_url": "http://192.168.1.8:3000/root",
    "email": "john@example.com",
    "last_activity_on": "2021-01-25",
    "membership_type": "group_member",
    "removable": true,
    "created_at": "2021-01-04T18:46:42.000Z",
    "last_login_at": "2022-09-29T22:18:46.000Z"
  },
  {
    "id": 3,
    "username": "foo_bar",
    "name": "Foo bar",
    "state": "active",
    "avatar_url": "https://www.gravatar.com/avatar/c2525a7f58ae3776070e44c106c48e15?s=80&d=identicon",
    "web_url": "http://192.168.1.8:3000/root",
    "last_activity_on": "2021-01-20",
    "membership_type": "group_invite",
    "removable": false,
    "created_at": "2021-01-09T07:12:31.000Z",
    "last_login_at": "2022-10-10T07:28:56.000Z"
  }
]
```

<a id="list-memberships-for-a-billable-member-of-a-group"></a>

## 列出群组的计费成员的成员资格

获取群组的计费成员的成员资格列表。

前提条件：

- 响应仅表示直接成员资格。不包括继承成员资格。
- 此 API 端点仅在顶级群组上工作。它不适用于子群组。
- 此 API 端点需要权限来管理群组的成员资格。

列出用户是成员的所有项目和群组。仅包括群组层级中的项目和群组。例如，如果请求的群组是 `顶级群组`，请求的用户是 `顶级群组 / 子群组一` 和 `其他群组 / 子群组二` 的直接成员，则仅返回 `顶级群组 / 子群组一`，因为 `其他群组 / 子群组二` 不在 `顶级群组` 层级中。

此 API 端点接受 [分页](rest/_index.md#pagination) 参数 `page` 和 `per_page` 来限制成员资格列表。

```plaintext
GET /groups/:id/billable_members/:user_id/memberships
```

| 属性 | 类型              | 必需 | 描述 |
|-----------|-------------------|----------|-------------|
| `id`      | 整数或字符串 | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `user_id` | 整数           | 是      | 计费成员的用户 ID。 |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/:id/billable_members/:user_id/memberships"
```

示例响应：

```json
[
  {
    "id": 168,
    "source_id": 131,
    "source_full_name": "顶级群组 / 子群组一",
    "source_members_url": "https://gitlab.example.com/groups/root-group/sub-group-one/-/group_members",
    "created_at": "2021-03-31T17:28:44.812Z",
    "expires_at": "2022-03-21",
    "access_level": {
      "string_value": "Developer",
      "integer_value": 30
    }
  },
  {
    "id": 169,
    "source_id": 63,
    "source_full_name": "顶级群组 / 子群组一 / 我的项目",
    "source_members_url": "https://gitlab.example.com/root-group/sub-group-one/my-project/-/project_members",
    "created_at": "2021-03-31T17:29:14.934Z",
    "expires_at": null,
    "access_level": {
      "string_value": "Maintainer",
      "integer_value": 40
    }
  }
]
```

<a id="list-indirect-memberships-for-a-billable-member-of-a-group"></a>

## 列出群组的计费成员的间接成员资格

{{< details >}}

- 状态：实验

{{< /details >}}

{{< history >}}

- 在极狐GitLab  16.11 中引入。

{{< /history >}}

获取群组的计费成员的间接成员资格列表。

前提条件：

- 此 API 端点仅在顶级群组上工作。它不适用于子群组。
- 此 API 端点需要权限来管理群组的成员资格。

列出用户是成员的所有项目和群组，这些项目和群组已被邀请到请求的顶级群组。例如，如果请求的群组是 `顶级群组`，请求的用户是 `其他群组 / 子群组二` 的直接成员，该群组被邀请到 `顶级群组`，则仅返回 `其他群组 / 子群组二`。

响应仅列出间接成员资格。不包括直接成员资格。

此 API 端点接受 [分页](rest/_index.md#pagination) 参数 `page` 和 `per_page` 来限制成员资格列表。

```plaintext
GET /groups/:id/billable_members/:user_id/indirect
```

| 属性 | 类型              | 必需 | 描述 |
|-----------|-------------------|----------|-------------|
| `id`      | 整数或字符串 | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `user_id` | 整数           | 是      | 计费成员的用户 ID。 |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/:id/billable_members/:user_id/indirect"
```

示例响应：

```json
[
  {
    "id": 168,
    "source_id": 132,
    "source_full_name": "受邀群组 / 子群组一",
    "source_members_url": "https://gitlab.example.com/groups/invited-group/sub-group-one/-/group_members",
    "created_at": "2021-03-31T17:28:44.812Z",
    "expires_at": "2022-03-21",
    "access_level": {
      "string_value": "Developer",
      "integer_value": 30
    }
  }
]
```

<a id="remove-a-billable-member-from-a-group"></a>

## 从群组中移除计费成员

{{< history >}}

- 在极狐GitLab  13.10 中引入。

{{< /history >}}

从群组及其子群组和项目中移除计费成员。

用户不需要是群组成员即可符合移除条件。例如，如果用户直接添加到群组中的某个项目，您仍然可以使用此 API 将其移除。

{{< alert type="note" >}}

成员移除是异步处理的，因此更改在几分钟内完成。

{{< /alert >}}

```plaintext
DELETE /groups/:id/billable_members/:user_id
```

| 属性 | 类型              | 必需 | 描述 |
|-----------|-------------------|----------|-------------|
| `id`      | 整数或字符串 | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `user_id` | 整数           | 是      | 成员的用户 ID。 |

```shell
curl --request DELETE --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/:id/billable_members/:user_id"
```

<a id="change-membership-state-of-a-user-in-a-group"></a>

## 更改群组中用户的成员状态

{{< history >}}

- 在极狐GitLab  15.0 中引入。

{{< /history >}}

更改群组中用户的成员状态。

当用户超过[基础版用户限制](../user/free_user_limit.md)时，更改其群组或项目的成员状态为 `awaiting` 或 `active` 可以允许他们访问该群组或项目。更改适用于所有子群组和项目。

```plaintext
PUT /groups/:id/members/:user_id/state
```

| 属性 | 类型              | 必需 | 描述 |
|-----------|-------------------|----------|-------------|
| `id`      | 整数或字符串 | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `user_id` | 整数           | 是      | 成员的用户 ID。 |
| `state`   | 字符串            | 是      | 用户的新状态。状态为 `awaiting` 或 `active`。 |

```shell
curl --request PUT --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/:id/members/:user_id/state?state=active"
```

示例响应：

```json
{
  "success":true
}
```

<a id="add-a-member-to-a-group-or-project"></a>

## 添加成员到群组或项目

向群组或项目添加成员。

```plaintext
POST /groups/:id/members
POST /projects/:id/members
```

| 属性              | 类型              | 必需                           | 描述 |
|------------------|-------------------|------------------------------------|-------------|
| `id`             | 整数或字符串 | 是                                | 项目或群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `user_id`        | 整数或字符串 | 是，如果未提供 `username` | 新成员的用户 ID 或多个用逗号分隔的 ID。 |
| `username`       | 字符串            | 是，如果未提供 `user_id`  | 新成员的用户名或多个用逗号分隔的用户名。 |
| `access_level`   | 整数           | 是                                | [有效的访问级别](access_requests.md#valid-access-levels)。 |
| `expires_at`     | 字符串            | 否                                 | 格式为 `YEAR-MONTH-DAY` 的日期字符串。 |
| `invite_source`  | 字符串            | 否                                 | 启动成员创建过程的邀请来源。极狐GitLab  团队成员可以在此机密议题中查看更多信息：`https://gitlab.com/gitlab-org/gitlab/-/issues/327120>`。 |
| `member_role_id` | 整数           | 否                                 | 成员角色的 ID。旗舰版专用。 |

```shell
curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" \
     --data "user_id=1&access_level=30" "https://gitlab.example.com/api/v4/groups/:id/members"
curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" \
     --data "user_id=1&access_level=30" "https://gitlab.example.com/api/v4/projects/:id/members"
```

示例响应：

```json
{
  "id": 1,
  "username": "raymond_smith",
  "name": "Raymond Smith",
  "state": "active",
  "avatar_url": "https://www.gravatar.com/avatar/c2525a7f58ae3776070e44c106c48e15?s=80&d=identicon",
  "web_url": "http://192.168.1.8:3000/root",
  "created_at": "2012-10-22T14:13:35Z",
  "created_by": {
    "id": 2,
    "username": "john_doe",
    "name": "John Doe",
    "state": "active",
    "avatar_url": "https://www.gravatar.com/avatar/c2525a7f58ae3776070e44c106c48e15?s=80&d=identicon",
    "web_url": "http://192.168.1.8:3000/root"
  },
  "expires_at": "2012-10-22",
  "access_level": 30,
  "email": "john@example.com",
  "group_saml_identity": null
}
```

{{< alert type="note" >}}

如果[管理员批准角色提升](../administration/settings/sign_up_restrictions.md#turn-on-administrator-approval-for-role-promotions)已开启，提升现有用户到计费角色的成员请求需要管理员批准。

{{< /alert >}}

要启用 **管理非计费角色提升**，
您必须首先启用 `enable_member_promotion_management` 应用设置。

队列单个用户的示例：

```shell
curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" \
     --data "user_id=1&access_level=30" "https://gitlab.example.com/api/v4/groups/:id/members"
curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" \
     --data "user_id=1&access_level=30" "https://gitlab.example.com/api/v4/projects/:id/members"
```

```json
{
  "message":{
    "username_1":"Request queued for administrator approval."
  }
}
```

队列多个用户的示例：

```shell
curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" \
     --data "user_id=1,2&access_level=30" "https://gitlab.example.com/api/v4/groups/:id/members"
curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" \
     --data "user_id=1,2&access_level=30" "https://gitlab.example.com/api/v4/projects/:id/members"
```

```json
{
  "queued_users": {
    "username_1": "Request queued for administrator approval.",
    "username_2": "Request queued for administrator approval."
  },
  "status": "success"
}
```

<a id="edit-a-member-of-a-group-or-project"></a>

## 编辑群组或项目的成员

更新群组或项目的成员。

```plaintext
PUT /groups/:id/members/:user_id
PUT /projects/:id/members/:user_id
```

| 属性              | 类型              | 必需 | 描述 |
|------------------|-------------------|----------|-------------|
| `id`             | 整数或字符串 | 是      | 项目或群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `user_id`        | 整数           | 是      | 成员的用户 ID。 |
| `access_level`   | 整数           | 是      | [有效的访问级别](access_requests.md#valid-access-levels)。 |
| `expires_at`     | 字符串            | 否       | 格式为 `YEAR-MONTH-DAY` 的日期字符串。 |
| `member_role_id` | 整数           | 否       | 成员角色的 ID。旗舰版专用。 |

```shell
curl --request PUT --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/:id/members/:user_id?access_level=40"
curl --request PUT --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/:id/members/:user_id?access_level=40"
```

示例响应：

```json
{
  "id": 1,
  "username": "raymond_smith",
  "name": "Raymond Smith",
  "state": "active",
  "avatar_url": "https://www.gravatar.com/avatar/c2525a7f58ae3776070e44c106c48e15?s=80&d=identicon",
  "web_url": "http://192.168.1.8:3000/root",
  "created_at": "2012-10-22T14:13:35Z",
  "created_by": {
    "id": 2,
    "username": "john_doe",
    "name": "John Doe",
    "state": "active",
    "avatar_url": "https://www.gravatar.com/avatar/c2525a7f58ae3776070e44c106c48e15?s=80&d=identicon",
    "web_url": "http://192.168.1.8:3000/root"
  },
  "expires_at": "2012-10-22",
  "access_level": 40,
  "email": "john@example.com",
  "group_saml_identity": null
}
```

{{< alert type="note" >}}

如果[管理员批准角色提升](../administration/settings/sign_up_restrictions.md#turn-on-administrator-approval-for-role-promotions)已开启，提升现有用户到计费角色的成员请求需要管理员批准。

{{< /alert >}}

要启用 **管理非计费角色提升**，
您必须首先启用 `enable_member_promotion_management` 应用设置。

示例响应：

```json
{
  "message":{
    "username_1":"Request queued for administrator approval."
  }
}
```

<a id="set-override-flag-for-a-member-of-a-group"></a>

### 设置群组成员的覆盖标志

默认情况下，LDAP 群组成员的访问级别设置为 LDAP 通过群组同步指定的值。您可以通过调用此端点允许访问级别覆盖。

```plaintext
POST /groups/:id/members/:user_id/override
```

| 属性 | 类型              | 必需 | 描述 |
|-----------|-------------------|----------|-------------|
| `id`      | 整数或字符串 | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `user_id` | 整数           | 是      | 成员的用户 ID。 |

```shell
curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/:id/members/:user_id/override"
```

示例响应：

```json
{
  "id": 1,
  "username": "raymond_smith",
  "name": "Raymond Smith",
  "state": "active",
  "avatar_url": "https://www.gravatar.com/avatar/c2525a7f58ae3776070e44c106c48e15?s=80&d=identicon",
  "web_url": "http://192.168.1.8:3000/root",
  "created_at": "2012-10-22T14:13:35Z",
  "created_by": {
    "id": 2,
    "username": "john_doe",
    "name": "John Doe",
    "state": "active",
    "avatar_url": "https://www.gravatar.com/avatar/c2525a7f58ae3776070e44c106c48e15?s=80&d=identicon",
    "web_url": "http://192.168.1.8:3000/root"
  },
  "expires_at": "2012-10-22",
  "access_level": 40,
  "email": "john@example.com",
  "override": true
}
```

<a id="remove-override-for-a-member-of-a-group"></a>

### 移除群组成员的覆盖标志

将覆盖标志设置为 false，并允许 LDAP 群组同步重置访问级别为 LDAP 规定的值。

```plaintext
DELETE /groups/:id/members/:user_id/override
```

| 属性 | 类型              | 必需 | 描述 |
|-----------|-------------------|----------|-------------|
| `id`      | 整数或字符串 | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `user_id` | 整数           | 是      | 成员的用户 ID。 |

```shell
curl --request PUT --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/:id/members/:user_id/override"
```

示例响应：

```json
{
  "id": 1,
  "username": "raymond_smith",
  "name": "Raymond Smith",
  "state": "active",
  "avatar_url": "https://www.gravatar.com/avatar/c2525a7f58ae3776070e44c106c48e15?s=80&d=identicon",
  "web_url": "http://192.168.1.8:3000/root",
  "created_at": "2012-10-22T14:13:35Z",
  "created_by": {
    "id": 2,
    "username": "john_doe",
    "name": "John Doe",
    "state": "active",
    "avatar_url": "https://www.gravatar.com/avatar/c2525a7f58ae3776070e44c106c48e15?s=80&d=identicon",
    "web_url": "http://192.168.1.8:3000/root"
  },
  "expires_at": "2012-10-22",
  "access_level": 40,
  "email": "john@example.com",
  "override": false
}
```

<a id="remove-a-member-from-a-group-or-project"></a>

## 从群组或项目中移除成员

从用户被显式分配角色的群组或项目中移除用户。

用户需要是群组成员才能符合移除条件。例如，如果用户直接添加到群组中的某个项目，但不是此群组的成员，您不能使用此 API 将其移除。请参阅 [从群组中移除计费成员](#remove-a-billable-member-from-a-group) 以获取替代方法。

```plaintext
DELETE /groups/:id/members/:user_id
DELETE /projects/:id/members/:user_id
```

| 属性                 | 类型              | 是否必需 | 描述 |
|---------------------|-------------------|----------|-------------|
| `id`                | 整数或字符串       | 是      | 项目或群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `user_id`           | 整数              | 是      | 成员的用户 ID。 |
| `skip_subresources` | 布尔值            | 否      | 是否跳过删除被移除成员在子群组和项目中的直接成员资格。默认为 `false`。 |
| `unassign_issuables`| 布尔值            | 否      | 是否将被移除成员从给定群组或项目中的任何议题或合并请求中取消分配。默认为 `false`。 |

示例请求：

```shell
curl --request DELETE --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/:id/members/:user_id"
curl --request DELETE --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/:id/members/:user_id"
```

<a id="approve-a-member-for-a-group"></a>

## 批准群组成员

批准一个群组及其子群组和项目的待定用户。

```plaintext
PUT /groups/:id/members/:member_id/approve
```

| 属性        | 类型              | 是否必需 | 描述                |
|------------|-------------------|----------|---------------------|
| `id`       | 整数或字符串       | 是       | ID 或 [顶级群组的 URL 编码路径](rest/_index.md#namespaced-paths) |
| `member_id`| 整数              | 是       | 成员的 ID           |

示例请求：

```shell
curl --request PUT --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/:id/members/:member_id/approve"
```

<a id="approve-all-pending-members-for-a-group"></a>

## 批准群组的所有待定成员

批准一个群组及其子群组和项目的所有待定用户。

```plaintext
POST /groups/:id/members/approve_all
```

| 属性       | 类型              | 是否必需   | 描述        |
|-----------|-------------------|----------|-------------|
| `id`      | 整数或字符串        | 是       | ID 或 [顶级群组的 URL 编码路径](rest/_index.md#namespaced-paths). |

示例请求：

```shell
curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/:id/members/approve_all"
```

<a id="list-pending-members-of-a-group-and-its-subgroups-and-projects"></a>

## 列出群组及其子群组和项目的待定成员

对于一个群组及其子群组和项目，获取所有处于 `等待` 状态的成员列表以及那些被邀请但没有极狐GitLab账号的成员。

先决条件：

- 此 API 端点仅适用于顶级群组。不适用于子群组。
- 此 API 端点需要有权限管理群组的成员。

此请求返回顶级群组层次结构中所有群组和项目的所有匹配群组和项目成员。

当成员是尚未注册极狐GitLab账号的受邀用户时，返回受邀的电子邮件地址。

此 API 端点接受 [分页](rest/_index.md#pagination) 参数 `page` 和 `per_page` 以限制成员列表。

```plaintext
GET /groups/:id/pending_members
```

| 属性       | 类型              | 是否必需   | 描述        |
|-----------|-------------------|----------|-------------|
| `id`      | 整数或字符串 | 是      | ID 或[群组的 URL 编码路径](rest/_index.md#namespaced-paths)。|

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/:id/pending_members"
```

示例响应：

```json
[
  {
    "id": 168,
    "name": "Alex Garcia",
    "username": "alex_garcia",
    "email": "alex@example.com",
    "avatar_url": "http://example.com/uploads/user/avatar/1/cd8.jpeg",
    "web_url": "http://example.com/alex_garcia",
    "approved": false,
    "invited": false
  },
  {
    "id": 169,
    "email": "sidney@example.com",
    "avatar_url": "http://gravatar.com/../e346561cd8.jpeg",
    "approved": false,
    "invited": true
  },
  {
    "id": 170,
    "email": "zhang@example.com",
    "avatar_url": "http://gravatar.com/../e32131cd8.jpeg",
    "approved": true,
    "invited": true
  }
]
```

<a id="give-a-group-access-to-a-project"></a>

## 授予群组项目访问权限

请参阅[和群组共享项目](projects.md#share-a-project-with-a-group)


