---
stage: Runtime
group: Organizations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 群组成员 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此端点与群组成员交互。

有关项目成员的信息，请参阅[项目成员 API](project_members.md)。

<a id="known-issues"></a>

## 已知问题

- `group_saml_identity` 和 `group_scim_identity` 属性仅对[启用了 SSO 的群组](../user/group/saml_sso/_index.md)的群组所有者可见。
- 当 API 请求发送到群组本身，或该群组的子群组或项目时，`email` 属性仅对该群组的[企业用户](../user/enterprise_user/_index.md)的群组所有者可见。
- `two_factor_enabled` 属性仅对群组所有者和管理员可见。

<a id="list-all-group-members"></a>

## 列出所有群组成员

列出指定群组的所有直接成员。仅返回直接成员，不返回通过祖先群组继承的成员，也不返回受邀群组的成员。

此函数接受分页参数 `page` 和 `per_page` 以限制用户列表。

```plaintext
GET /groups/:id/members
```

| 属性        | 类型              | 是否必需 | 描述 |
|------------------|-------------------|----------|-------------|
| `id`             | integer or string | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `query`          | string            | 否       | 根据给定的名称、电子邮件或用户名筛选结果。使用部分值可扩大查询范围。 |
| `user_ids`       | array of integers | 否       | 根据给定的用户 ID 筛选结果。 |
| `skip_users`     | array of integers | 否       | 从结果中过滤掉跳过的用户。 |
| `show_seat_info` | boolean           | 否       | 显示用户的席位信息。 |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/:id/members"
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
    "two_factor_enabled": true,
    "access_level": 30,
    "group_saml_identity": null,
    "is_using_seat": true
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
    "two_factor_enabled": false,
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

<a id="list-all-group-members-including-inherited-and-invited-members"></a>

## 列出所有群组成员，包括继承成员和受邀成员

列出指定群组的所有成员，包括继承成员、受邀用户以及通过祖先群组获得的权限。

如果某个用户既是此群组的成员，又是一个或多个祖先群组的成员，则仅返回其具有最高 `access_level`的成员身份。这表示该用户的有效权限。

在以下任一情况下，会返回受邀群组的成员：

- 受邀群组是公开的。
- 请求者也是受邀群组的成员。
- 请求者是共享群组的成员。

> [!note]
> 受邀群组成员在共享群组中具有共享成员身份。
> 这意味着，如果请求者是共享群组的成员，但不是受邀私有群组的成员，
> 那么使用此端点，请求者可以获取所有共享群组成员，包括受邀私有群组成员。

此函数接受分页参数 `page` 和 `per_page` 以限制用户列表。

```plaintext
GET /groups/:id/members/all
```

| 属性        | 类型              | 是否必需 | 描述 |
|------------------|-------------------|----------|-------------|
| `id`             | integer or string | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `query`          | string            | 否       | 根据给定的名称、电子邮件或用户名筛选结果。使用部分值可扩大查询范围。 |
| `user_ids`       | array of integers | 否       | 根据给定的用户 ID 筛选结果。 |
| `show_seat_info` | boolean           | 否       | 显示用户的席位信息。 |
| `state`          | string            | 否       | 按成员状态筛选结果，取值为 `awaiting` 或 `active` 之一。仅限专业版和旗舰版。 |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/:id/members/all"
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
    "two_factor_enabled": true,
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
    "two_factor_enabled": false,
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
    "two_factor_enabled": false,
    "access_level": 30,
    "group_saml_identity": null
  }
]
```

<a id="retrieve-a-group-member"></a>

## 检索群组成员

检索群组的指定成员。仅返回直接成员，不返回通过祖先群组继承的成员。

```plaintext
GET /groups/:id/members/:user_id
```

| 属性 | 类型              | 是否必需 | 描述 |
|-----------|-------------------|----------|-------------|
| `id`      | integer or string | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `user_id` | integer           | 是      | 成员的 ID。 |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/:id/members/:user_id"
```

要从群组成员中更新或移除自定义角色，请传入空的 `member_role_id` 值：

```shell
# Updates a group membership
curl --request PUT \
  --header "Content-Type: application/json" \
  --header "Authorization: Bearer <your_access_token>" \
  --data '{"member_role_id": null, "access_level": 10}' "https://gitlab.example.com/api/v4/groups/<group_id>/members/<user_id>"
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
  "two_factor_enabled": true,
  "group_saml_identity": null
}
```

<a id="retrieve-a-group-member-including-inherited-and-invited-members"></a>

## 检索群组成员，包括继承成员和受邀成员

检索群组的指定成员，包括通过祖先群组继承或受邀的成员。更多信息，请参阅[列出所有继承成员](#list-all-group-members-including-inherited-and-invited-members)。

> [!note]
> 受邀群组成员在共享群组中具有共享成员身份。
> 这意味着，如果请求者是共享群组的成员，但不是受邀私有群组的成员，
> 那么使用此端点，请求者可以获取所有共享群组成员，包括受邀私有群组成员。

```plaintext
GET /groups/:id/members/all/:user_id
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id`      | integer or string | 是 | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `user_id` | integer | 是   | 成员的 ID。 |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/:id/members/all/:user_id"
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
  "two_factor_enabled": true,
  "group_saml_identity": null
}
```

<a id="list-all-billable-group-members"></a>

## 列出所有计费群组成员

列出指定群组的所有计费成员。该列表包括子群组和项目中的成员。

先决条件：

- 您必须具有所有者角色才能访问计费权限的 API 端点，如[计费权限](../user/free_user_limit.md)中所示。
- 此 API 端点仅适用于顶级群组。不适用于子群组。

此函数接受[分页](rest/_index.md#pagination)参数 `page` 和 `per_page` 以限制用户列表。

使用 `search` 参数按名称搜索计费群组成员，使用 `sort` 对结果排序。

```plaintext
GET /groups/:id/billable_members
```

| 属性 | 类型              | 是否必需 | 描述 |
|-----------|-------------------|----------|-------------|
| `id`      | integer or string | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `search`  | string            | 否       | 用于按名称、用户名或公开电子邮件搜索群组成员的查询字符串。 |
| `sort`    | string            | 否       | 包含指定排序属性和顺序的参数的查询字符串。请参阅下方支持的值。 |

`sort` 属性支持的值如下：

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
| `last_activity_on_asc`  | 最后活跃日期，升序  |
| `last_activity_on_desc` | 最后活跃日期，降序 |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
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

<a id="list-all-memberships-for-a-billable-group-member"></a>

## 列出计费群组成员的所有成员身份

列出群组指定计费成员的所有成员身份。

先决条件：

- 响应仅表示直接成员身份。不包括继承的成员身份。
- 此 API 端点仅适用于顶级群组。不适用于子群组。
- 此 API 端点需要管理群组成员身份的权限。

列出用户所属的所有项目和群组。仅包括群组层级中的项目和群组。例如，如果请求的群组是 `Top-Level Group`，而请求的用户同时是 `Top-Level Group / Subgroup One` 和 `Other Group / Subgroup Two`的直接成员，则仅返回 `Top-Level Group / Subgroup One`，因为 `Other Group / Subgroup Two` 不在 `Top-Level Group` 层级中。

此 API 端点接受[分页](rest/_index.md#pagination)参数 `page` 和 `per_page` 以限制成员身份列表。

```plaintext
GET /groups/:id/billable_members/:user_id/memberships
```

| 属性 | 类型              | 是否必需 | 描述 |
|-----------|-------------------|----------|-------------|
| `id`      | integer or string | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `user_id` | integer           | 是      | 计费成员的 ID。 |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/:id/billable_members/:user_id/memberships"
```

示例响应：

```json
[
  {
    "id": 168,
    "source_id": 131,
    "source_full_name": "Top-Level Group / Subgroup One",
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
    "source_full_name": "Top-Level Group / Subgroup One / My Project",
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

<a id="list-all-indirect-memberships-for-a-billable-group-member"></a>

## 列出计费群组成员的所有间接成员身份

{{< details >}}

- Status: 实验

{{< /details >}}

获取群组计费成员的间接成员身份列表。

先决条件：

- 此 API 端点仅适用于顶级群组。不适用于子群组。
- 此 API 端点需要管理群组成员身份的权限。

列出用户所属的、已被邀请到所请求顶级群组的所有项目和群组。例如，如果请求的群组是 `Top-Level Group`，而请求的用户是 `Other Group / Subgroup Two`的直接成员，且该群组已被邀请到 `Top-Level Group`，则仅返回 `Other Group / Subgroup Two`。

响应仅列出间接成员身份。不包括直接成员身份。

此 API 端点接受[分页](rest/_index.md#pagination)参数 `page` 和 `per_page` 以限制成员身份列表。

```plaintext
GET /groups/:id/billable_members/:user_id/indirect
```

| 属性 | 类型              | 是否必需 | 描述 |
|-----------|-------------------|----------|-------------|
| `id`      | integer or string | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `user_id` | integer           | 是      | 计费成员的 ID。 |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/:id/billable_members/:user_id/indirect"
```

示例响应：

```json
[
  {
    "id": 168,
    "source_id": 132,
    "source_full_name": "Invited Group / Subgroup One",
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

<a id="remove-a-billable-group-member"></a>

## 移除计费群组成员

从群组及其子群组和项目中移除指定的计费成员。

用户无需是群组成员即可被移除。例如，如果用户被直接添加到群组中的某个项目，您仍可使用此 API 端点将其移除。

> [!note]
> 成员移除是异步处理的，因此更改会在几分钟内完成。

```plaintext
DELETE /groups/:id/billable_members/:user_id
```

| 属性 | 类型              | 是否必需 | 描述 |
|-----------|-------------------|----------|-------------|
| `id`      | integer or string | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `user_id` | integer           | 是      | 成员的 ID。 |

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/:id/billable_members/:user_id"
```

<a id="change-group-membership-state-for-a-user"></a>

## 更改用户的群组成员身份状态

更改群组中指定用户的成员身份状态。

当用户超过[免费用户限制](../user/free_user_limit.md)时，将其在群组或项目中的成员身份状态更改为 `awaiting` 或 `active` 可允许他们访问该群组或项目。该更改会应用于所有子群组和项目。

```plaintext
PUT /groups/:id/members/:user_id/state
```

| 属性 | 类型              | 是否必需 | 描述 |
|-----------|-------------------|----------|-------------|
| `id`      | integer or string | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `user_id` | integer           | 是      | 成员的 ID。 |
| `state`   | string            | 是      | 用户的新状态。状态为 `awaiting` 或 `active`。 |

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/:id/members/:user_id/state?state=active"
```

示例响应：

```json
{
  "success":true
}
```

<a id="add-a-group-member"></a>

## 添加群组成员

向指定群组添加成员。

```plaintext
POST /groups/:id/members
```

| 属性        | 类型              | 是否必需                           | 描述 |
| ---------------- | ----------------- | ---------------------------------- | ----------- |
| `id`             | integer or string | 是                                | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `user_id`        | integer or string | 是（未提供 `username` 时） | 新成员的 ID，或多个以逗号分隔的 ID。 |
| `username`       | string            | 是（未提供 `user_id` 时）  | 新成员的用户名，或多个以逗号分隔的用户名。 |
| `access_level`   | integer           | 是                                | 有效的[访问级别](../user/permissions.md#default-roles)。可能的值：`0`（无访问权限）、`5`（最小访问权限）、`10`（访客）、`15`（计划者）、`20`（报告者）、`25`（安全管理员）、`30`（开发者）、`40`（维护者）、`50`（所有者）。默认值：`30`。 |
| `expires_at`     | string            | 否                                 | 格式为 `YEAR-MONTH-DAY`的日期字符串。 |
| `invite_source`  | string            | 否                                 | 启动成员创建流程的邀请来源。GitLab 团队成员可在此机密议题中查看更多信息：`https://gitlab.com/gitlab-org/gitlab/-/issues/327120>`。 |
| `member_role_id` | integer           | 否                                 | 仅限旗舰版。自定义成员角色的 ID。 |

```shell
curl --request POST \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --data "user_id=1&access_level=30" "https://gitlab.example.com/api/v4/groups/:id/members"
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

> [!note]
> 如果启用了[角色提升的管理员审批](../administration/settings/sign_up_restrictions.md#turn-on-administrator-approval-for-role-promotions)，则将现有用户提升为计费角色的成员身份请求需要管理员审批。

要启用 **管理非计费晋升**，
您必须先启用 `enable_member_promotion_management` 应用程序设置。

排队单个用户的示例：

```shell
curl --request POST \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --data "user_id=1&access_level=30" "https://gitlab.example.com/api/v4/groups/:id/members"
```

```json
{
  "message":{
    "username_1":"Request queued for administrator approval."
  }
}
```

排队多个用户的示例：

```shell
curl --request POST \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --data "user_id=1,2&access_level=30" "https://gitlab.example.com/api/v4/groups/:id/members"
curl --request POST \
     --header "PRIVATE-TOKEN: <your_access_token>" \
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

<a id="update-a-group-member"></a>

## 更新群组成员

更新群组的指定成员。

```plaintext
PUT /groups/:id/members/:user_id
```

| 属性        | 类型              | 是否必需 | 描述 |
| ---------------- | ----------------- | -------- | ----------- |
| `id`             | integer or string | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `user_id`        | integer           | 是      | 成员的 ID。 |
| `access_level`   | integer           | 是       | 有效的[访问级别](../user/permissions.md#default-roles)。可能的值：`0`（无访问权限）、`5`（最小访问权限）、`10`（访客）、`15`（计划者）、`20`（报告者）、`25`（安全管理员）、`30`（开发者）、`40`（维护者）、`50`（所有者）、`60`（管理员）。默认值：`30`。 |
| `expires_at`     | string            | 否       | 格式为 `YEAR-MONTH-DAY`的日期字符串。 |
| `member_role_id` | integer           | 否       | 仅限旗舰版。自定义成员角色的 ID。如果未指定值，则移除所有角色。 |

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/:id/members/:user_id?access_level=40"
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

> [!note]
> 如果启用了[角色提升的管理员审批](../administration/settings/sign_up_restrictions.md#turn-on-administrator-approval-for-role-promotions)，则将现有用户提升为计费角色的成员身份请求需要管理员审批。

要启用 **管理非计费晋升**，
您必须先启用 `enable_member_promotion_management` 应用程序设置。

示例响应：

```json
{
  "message":{
    "username_1":"Request queued for administrator approval."
  }
}
```

<a id="set-override-flag-for-a-member-of-a-group"></a>

### 为群组成员设置覆盖标志

默认情况下，LDAP 群组成员的访问级别设置为 LDAP 通过群组同步指定的值。您可以通过调用此端点来允许覆盖访问级别。

```plaintext
POST /groups/:id/members/:user_id/override
```

| 属性 | 类型              | 是否必需 | 描述 |
|-----------|-------------------|----------|-------------|
| `id`      | integer or string | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `user_id` | integer           | 是      | 成员的 ID。 |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
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

### 移除群组成员的覆盖

将覆盖标志设置为 false，并允许 LDAP 群组同步将访问级别重置为 LDAP 规定的值。

```plaintext
DELETE /groups/:id/members/:user_id/override
```

| 属性 | 类型              | 是否必需 | 描述 |
|-----------|-------------------|----------|-------------|
| `id`      | integer or string | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `user_id` | integer           | 是      | 成员的 ID。 |

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
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

<a id="remove-a-group-member"></a>

## 移除群组成员

从已为用户明确分配角色的群组中移除指定用户。

用户需要是群组成员才能被移除。例如，如果用户被直接添加到群组中的某个项目，但未明确添加到该群组，则您无法使用此 API 端点将其移除。有关替代方法，请参阅[从群组中移除计费成员](#remove-a-billable-group-member)。

```plaintext
DELETE /groups/:id/members/:user_id
```

| 属性            | 类型              | 是否必需 | 描述 |
|----------------------|-------------------|----------|-------------|
| `id`                 | integer or string | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `user_id`            | integer           | 是      | 成员的 ID。 |
| `skip_subresources`  | boolean           | false    | 是否应跳过删除被移除成员在子群组和项目中的直接成员身份。默认为 `false`。 |
| `unassign_issuables` | boolean           | false    | 是否应将被移除成员从给定群组或项目内的任何议题或合并请求中取消指派。默认为 `false`。 |

示例请求：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/:id/members/:user_id"
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/:id/members/:user_id"
```

<a id="approve-a-group-member"></a>

## 批准群组成员

批准指定群组及其子群组和项目中的指定待处理用户。

```plaintext
PUT /groups/:id/members/:member_id/approve
```

| 属性   | 类型              | 是否必需 | 描述 |
|-------------|-------------------|----------|-------------|
| `id`        | integer or string | 是      | 顶级群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `member_id` | integer           | 是      | 成员的 ID。 |

示例请求：

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/:id/members/:member_id/approve"
```

<a id="approve-all-pending-group-members"></a>

## 批准所有待处理的群组成员

批准指定群组及其子群组和项目中的所有待处理用户。

```plaintext
POST /groups/:id/members/approve_all
```

| 属性 | 类型              | 是否必需 | 描述 |
|-----------|-------------------|----------|-------------|
| `id`      | integer or string | 是      | 顶级群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/:id/members/approve_all"
```

<a id="list-all-pending-group-members-in-a-group-and-its-subgroups-and-projects"></a>

## 列出群组及其子群组和项目中的所有待处理群组成员

列出指定群组及其子群组和项目中处于 `awaiting` 状态的所有成员，以及已受邀但尚无极狐GitLab 账号的成员。

先决条件：

- 此 API 端点仅适用于顶级群组。不适用于子群组。
- 此 API 端点需要管理群组成员的权限。

此请求返回顶级群组层级中所有群组和项目的所有匹配群组成员和项目成员。

当成员是尚未注册极狐GitLab 账号的受邀用户时，会返回受邀的电子邮件地址。

此 API 端点接受[分页](rest/_index.md#pagination)参数 `page` 和 `per_page` 以限制成员列表。

```plaintext
GET /groups/:id/pending_members
```

| 属性 | 类型              | 是否必需 | 描述 |
|-----------|-------------------|----------|-------------|
| `id`      | integer or string | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
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
