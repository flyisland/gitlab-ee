---
stage: Runtime
group: Organizations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 项目成员 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此端点与项目成员进行交互。

有关群组成员的详细信息，请参见[群组成员 API](group_members.md)。

<a id="known-issues"></a>

## 已知问题

- `group_saml_identity` 和 `group_scim_identity` 属性仅对[启用了 SSO 的群组](../user/group/saml_sso/_index.md)的群组所有者可见。
- 当 API 请求发送到群组本身，或该群组的子群组或项目时，`email` 属性仅对该群组的[企业用户](../user/enterprise_user/_index.md)的群组所有者可见。

<a id="list-all-direct-members-of-a-project"></a>

## 列出项目的所有直接成员

列出经认证用户可查看的指定项目的所有直接成员。使用[列出项目的所有成员](#list-all-members-of-a-project)可列出继承的成员。

此函数接受分页参数 `page` 和 `per_page`，用于限制用户列表。

```plaintext
GET /projects/:id/members
```

| 属性        | 类型              | 是否必需 | 描述 |
|------------------|-------------------|----------|-------------|
| `id`             | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `query`          | string            | 否       | 根据给定的姓名、电子邮件或用户名筛选结果。使用部分值可扩大查询范围。 |
| `user_ids`       | array of integers | 否       | 根据给定的用户 ID 筛选结果。 |
| `skip_users`     | array of integers | 否       | 从结果中过滤掉跳过的用户。 |
| `show_seat_info` | boolean           | 否       | 显示用户的席位信息。 |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
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

<a id="list-all-members-of-a-project"></a>

## 列出项目的所有成员

列出经认证用户可查看的所有项目成员，包括继承的成员、受邀用户，以及通过祖先群组获得的权限。

如果某个用户既是此项目的成员，又是一个或多个祖先群组的成员，则只返回其具有最高 `access_level`的成员身份。这表示该用户的有效权限。

如果满足以下任一条件，则返回受邀群组的成员：

- 受邀群组是公开的。
- 请求者也是受邀群组的成员。
- 请求者是共享群组或项目的成员。

> [!note]
> 受邀群组成员在共享群组或项目中具有共享成员身份。
> 这意味着，如果请求者是共享群组或项目的成员，但不是受邀私有群组的成员，
> 那么使用此端点，请求者可以获取所有共享群组或项目成员，包括受邀私有群组的成员。

此函数接受分页参数 `page` 和 `per_page`，用于限制用户列表。

```plaintext
GET /projects/:id/members/all
```

| 属性        | 类型              | 是否必需 | 描述 |
|------------------|-------------------|----------|-------------|
| `id`             | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `query`          | string            | 否       | 根据给定的姓名、电子邮件或用户名筛选结果。使用部分值可扩大查询范围。 |
| `user_ids`       | array of integers | 否       | 根据给定的用户 ID 筛选结果。 |
| `show_seat_info` | boolean           | 否       | 显示用户的席位信息。 |
| `state`          | string            | 否       | 按成员状态筛选结果，取值为 `awaiting` 或 `active` 之一。仅限专业版和旗舰版。 |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
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

<a id="retrieve-a-direct-member-of-a-project"></a>

## 检索项目的直接成员

检索项目的指定直接成员。使用[检索项目的成员](#retrieve-a-member-of-a-project)可检索继承的成员。

```plaintext
GET /projects/:id/members/:user_id
```

| 属性 | 类型              | 是否必需 | 描述 |
|-----------|-------------------|----------|-------------|
| `id`      | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `user_id` | integer           | 是      | 该成员的用户 ID。 |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/:id/members/:user_id"
```

要从群组成员中更新或移除自定义角色，请传入空的 `member_role_id` 值：

```shell
# Updates a project membership
curl --request PUT \
  --header "Content-Type: application/json" \
  --header "Authorization: Bearer <your_access_token>" \
  --data '{"member_role_id": null, "access_level": 10}' \
  --url "https://gitlab.example.com/api/v4/projects/<project_id>/members/<user_id>"
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

<a id="retrieve-a-member-of-a-project"></a>

## 检索项目的成员

检索项目的指定成员，包括通过祖先群组继承或受邀加入的成员。有关更多信息，请参见[列出项目的所有成员](#list-all-members-of-a-project)。

> [!note]
> 受邀群组成员在共享群组或项目中具有共享成员身份。
> 这意味着，如果请求者是共享群组或项目的成员，但不是受邀私有群组的成员，
> 那么使用此端点，请求者可以获取所有共享群组或项目成员，包括受邀私有群组的成员。

```plaintext
GET /projects/:id/members/all/:user_id
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id`      | integer or string | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `user_id` | integer | 是   | 该成员的用户 ID。 |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
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

<a id="add-a-member-to-a-project"></a>

## 向项目添加成员

向指定项目添加直接成员。

要授予群组访问项目的权限，请参见[与群组共享项目](projects.md#share-a-project-with-a-group)。

```plaintext
POST /projects/:id/members
```

| 属性        | 类型              | 是否必需                           | 描述 |
| ---------------- | ----------------- | ---------------------------------- | ----------- |
| `id`             | integer or string | 是                                | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `user_id`        | integer or string | 是（如果未提供 `username`） | 新成员的用户 ID，或多个以逗号分隔的 ID。 |
| `username`       | string            | 是（如果未提供 `user_id`）  | 新成员的用户名，或多个以逗号分隔的用户名。 |
| `access_level`   | integer           | 是                                | 有效的[访问级别](../user/permissions.md#default-roles)。可能的值：`0`（无访问权限）、`5`（最小访问权限）、`10`（访客）、`15`（计划者）、`20`（报告者）、`25`（安全管理员）、`30`（开发者）、`40`（维护者）或 `50`（所有者）。默认值：`30`。 |
| `expires_at`     | string            | 否                                 | 格式为 `YEAR-MONTH-DAY`的日期字符串。 |
| `invite_source`  | string            | 否                                 | 启动成员创建流程的邀请来源。GitLab 团队成员可在此机密议题中查看更多信息：`https://gitlab.com/gitlab-org/gitlab/-/issues/327120`。 |
| `member_role_id` | integer           | 否                                 | 仅限旗舰版。自定义成员角色的 ID。 |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --data "user_id=1&access_level=30" \
  --url "https://gitlab.example.com/api/v4/projects/:id/members"
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
> 如果启用了[角色提升的管理员审批](../administration/settings/sign_up_restrictions.md#turn-on-administrator-approval-for-role-promotions)，则将现有用户提升为计费角色的成员资格请求需要管理员审批。

要启用 **管理非计费晋升**，
您必须先启用 `enable_member_promotion_management` 应用程序设置。

将单个用户加入队列的示例：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --data "user_id=1&access_level=30" \
  --url "https://gitlab.example.com/api/v4/projects/:id/members"
```

```json
{
  "message":{
    "username_1":"Request queued for administrator approval."
  }
}
```

将多个用户加入队列的示例：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --data "user_id=1,2&access_level=30" \
  --url "https://gitlab.example.com/api/v4/projects/:id/members"
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

<a id="update-a-member-of-a-project"></a>

## 更新项目的成员

更新项目的指定成员。

```plaintext
PUT /projects/:id/members/:user_id
```

| 属性        | 类型              | 是否必需 | 描述 |
| ---------------- | ----------------- | -------- | ----------- |
| `id`             | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `user_id`        | integer           | 是      | 该成员的用户 ID。 |
| `access_level`   | integer           | 是       | 有效的[访问级别](../user/permissions.md#default-roles)。可能的值：`0`（无访问权限）、`5`（最小访问权限）、`10`（访客）、`15`（计划者）、`20`（报告者）、`25`（安全管理员）、`30`（开发者）、`40`（维护者）或 `50`（所有者）。默认值：`30`。 |
| `expires_at`     | string            | 否       | 格式为 `YEAR-MONTH-DAY`的日期字符串。 |
| `member_role_id` | integer           | 否       | 仅限旗舰版。自定义成员角色的 ID。如果未指定值，则移除所有角色。 |

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
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

> [!note]
> 如果启用了[角色提升的管理员审批](../administration/settings/sign_up_restrictions.md#turn-on-administrator-approval-for-role-promotions)，则将现有用户提升为计费角色的成员资格请求需要管理员审批。

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

<a id="remove-a-direct-member-of-a-project"></a>

## 移除项目的直接成员

移除项目的指定直接成员。

例如，如果该用户是直接添加到群组中的某个项目，而不是显式添加到此群组，则您无法使用此端点将其移除。有关更多信息，请参见[从群组中移除计费成员](group_members.md#remove-a-billable-group-member)。

```plaintext
DELETE /projects/:id/members/:user_id
```

| 属性            | 类型              | 是否必需 | 描述 |
|----------------------|-------------------|----------|-------------|
| `id`                 | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `user_id`            | integer           | 是      | 该成员的用户 ID。 |
| `skip_subresources`  | boolean           | 否       | 是否应跳过删除被移除成员在子群组和项目中的直接成员身份。默认为 `false`。 |
| `unassign_issuables` | boolean           | 否       | 是否应将被移除的成员从给定项目内的任何议题或合并请求中取消指派。默认为 `false`。 |

示例请求：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/:id/members/:user_id"
```
