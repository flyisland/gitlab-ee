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

有关群组成员的信息，请参阅 [群组成员 API](group_members.md)。

<a id="known-issues"></a>

## 已知问题

- `group_saml_identity` 和 `group_scim_identity` 属性仅对 [启用 SSO 的群组](../user/group/saml_sso/_index.md) 的群组所有者可见。
- 当 API 请求发送到群组本身或其子群组或项目时，`email` 属性仅对群组的 [企业用户](../user/enterprise_user/_index.md) 的群组所有者可见。

<a id="list-all-direct-members-of-a-project"></a>

## 列出项目的所有直接成员

列出认证用户可查看的指定项目的所有直接成员。
使用 [列出项目的所有成员](#list-all-members-of-a-project) 来列出继承的成员。

此函数接受分页参数 `page` 和 `per_page` 以限制用户列表。

```plaintext
GET /projects/:id/members
```

| 属性            | 类型              | 是否必需 | 描述                                                         |
|----------------|-------------------|---------|--------------------------------------------------------------|
| `id`           | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `query`        | string            | 否      | 根据给定的姓名、电子邮件或用户名筛选结果。使用部分值可以扩大查询范围。               |
| `user_ids`     | array of integers | 否      | 根据给定的用户 ID 筛选结果。                                      |
| `skip_users`   | array of integers | 否      | 从结果中排除跳过的用户。                                          |
| `show_seat_info` | boolean          | 否      | 显示用户的席位信息。                                            |

```shell
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

{{< history >}}

- [更改] 以返回受邀私有群组的成员，如果当前用户是共享群组或项目的成员，在极狐GitLab 16.10 [使用功能标志](../administration/feature_flags/_index.md) 名为 `webui_members_inherited_users`。默认禁用。
- 功能标志 `webui_members_inherited_users` 于极狐GitLab 17.0 [在 JihuLab.com 和私有化部署上启用]。
- 功能标志 `webui_members_inherited_users` [移除] 于极狐GitLab 17.4。受邀群组的成员默认显示。

{{< /history >}}

列出认证用户可查看的所有项目成员，包括继承的成员、受邀用户以及通过祖先群组获得的权限。

如果用户是此项目以及一个或多个祖先群组的成员，则仅返回具有最高 `access_level` 的成员资格。
这代表了用户的有效权限。

在以下任一情况下，将返回受邀群组的成员：

- 受邀群组是公开的。
- 请求者也是受邀群组的成员。
- 请求者是共享群组或项目的成员。

> [!note]
> 受邀群组的成员在共享群组或项目中具有共享成员资格。
> 这意味着，如果请求者是共享群组或项目的成员，但不是受邀私有群组的成员，
> 那么使用此端点，请求者可以获取所有共享群组或项目的成员，包括受邀私有群组的成员。

此函数接受分页参数 `page` 和 `per_page` 以限制用户列表。

```plaintext
GET /projects/:id/members/all
```

| 属性            | 类型              | 是否必需 | 描述                                                         |
|----------------|-------------------|---------|--------------------------------------------------------------|
| `id`           | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `query`        | string            | 否      | 根据给定的姓名、电子邮件或用户名筛选结果。使用部分值可以扩大查询范围。               |
| `user_ids`     | array of integers | 否      | 根据给定的用户 ID 筛选结果。                                      |
| `show_seat_info` | boolean          | 否      | 显示用户的席位信息。                                            |
| `state`        | string            | 否      | 按成员状态筛选结果，可选 `awaiting` 或 `active`。仅专业版和旗舰版。          |

```shell
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

<a id="retrieve-a-direct-member-of-a-project"></a>

## 检索项目的直接成员

检索指定的项目直接成员。
使用 [检索项目的成员](#retrieve-a-member-of-a-project) 来检索继承的成员。

```plaintext
GET /projects/:id/members/:user_id
```

| 属性      | 类型              | 是否必需 | 描述                                                         |
|----------|-------------------|---------|--------------------------------------------------------------|
| `id`     | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `user_id` | integer           | 是      | 成员的用户 ID。                                               |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/:id/members/:user_id"
```

要更新或移除群组成员的定制角色，需传递一个空 `member_role_id` 值：

```shell
# 更新项目成员资格
curl --request PUT --header "Content-Type: application/json" \
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

{{< history >}}

- [引入] 于极狐GitLab 12.4。
- [更改] 以返回受邀私有群组的成员，如果当前用户是共享群组或项目的成员，在极狐GitLab 16.10 [使用功能标志](../administration/feature_flags/_index.md) 名为 `webui_members_inherited_users`。默认禁用。
- [在 JihuLab.com 和私有化部署上启用] 于极狐GitLab 17.0。
- 功能标志 `webui_members_inherited_users` [移除] 于极狐GitLab 17.4。受邀群组的成员默认显示。

{{< /history >}}

检索指定的项目成员，包括通过祖先群组继承或邀请的成员。
有关更多信息，请参阅 [列出项目的所有成员](#list-all-members-of-a-project)。

> [!note]
> 受邀群组的成员在共享群组或项目中具有共享成员资格。
> 这意味着，如果请求者是共享群组或项目的成员，但不是受邀私有群组的成员，
> 那么使用此端点，请求者可以获取所有共享群组或项目的成员，包括受邀私有群组的成员。

```plaintext
GET /projects/:id/members/all/:user_id
```

| 属性      | 类型              | 是否必需 | 描述                                                         |
|----------|-------------------|---------|--------------------------------------------------------------|
| `id`     | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `user_id` | integer           | 是      | 成员的用户 ID。                                               |

```shell
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

<a id="add-a-member-to-a-project"></a>

## 向项目添加成员

向指定项目添加直接成员。

要授予群组对项目的访问权限，请参阅 [与群组共享项目](projects.md#share-a-project-with-a-group)。

```plaintext
POST /projects/:id/members
```

| 属性            | 类型              | 是否必需                          | 描述                                                         |
|----------------|-------------------|----------------------------------|--------------------------------------------------------------|
| `id`           | integer or string | 是                               | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `user_id`      | integer or string | 是（如果未提供 `username`）          | 新成员的用户 ID，或由逗号分隔的多个 ID。                          |
| `username`     | string            | 是（如果未提供 `user_id`）          | 新成员的用户名，或由逗号分隔的多个用户名。                          |
| `access_level` | integer           | 是                               | 有效的 [访问级别](../user/permissions.md#default-roles) 可选值：`0`（无访问权限）、`5`（最小访问权限）、`10`（访客）、`15`（计划者）、`20`（报告者）、`25`（安全经理）、`30`（开发者）、`40`（维护者）或 `50`（所有者）。默认值：`30`。 |
| `expires_at`   | string            | 否                               | 格式为 `YEAR-MONTH-DAY` 的日期字符串。                            |
| `invite_source` | string           | 否                               | 启动成员创建过程的邀请来源。极狐GitLab 团队成员可以在该机密议题中查看更多信息：`https://gitlab.com/gitlab-org/gitlab/-/issues/327120`。 |
| `member_role_id` | integer         | 否                               | 仅旗舰版。定制成员角色的 ID。                                      |

```shell
curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" \
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
> 如果 [角色晋升的管理员审批](../administration/settings/sign_up_restrictions.md#turn-on-administrator-approval-for-role-promotions) 启用，将现有用户提升到计费角色的成员请求需要管理员审批。

要启用 **管理非计费晋升**，
你必须首先启用 `enable_member_promotion_management` 应用设置。

单个用户排队的示例：

```shell
curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" \
     --data "user_id=1&access_level=30" \
     --url "https://gitlab.example.com/api/v4/projects/:id/members"
```

```json
{
  "message":{
    "username_1":"请求已排队等待管理员审批。"
  }
}
```

多个用户排队的示例：

```shell
curl --request POST --header "PRIVATE-TOKEN: <your_access_token>" \
     --data "user_id=1,2&access_level=30" \
     --url "https://gitlab.example.com/api/v4/projects/:id/members"
```

```json
{
  "queued_users": {
    "username_1": "请求已排队等待管理员审批。",
    "username_2": "请求已排队等待管理员审批。"
  },
  "status": "success"
}
```

<a id="update-a-member-of-a-project"></a>

## 更新项目成员

更新项目的指定成员。

```plaintext
PUT /projects/:id/members/:user_id
```

| 属性            | 类型              | 是否必需 | 描述                                                         |
|----------------|-------------------|---------|--------------------------------------------------------------|
| `id`           | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `user_id`      | integer           | 是      | 成员的用户 ID。                                               |
| `access_level` | integer           | 是      | 有效的 [访问级别](../user/permissions.md#default-roles) 可选值：`0`（无访问权限）、`5`（最小访问权限）、`10`（访客）、`15`（计划者）、`20`（报告者）、`25`（安全经理）、`30`（开发者）、`40`（维护者）或 `50`（所有者）。默认值：`30`。 |
| `expires_at`   | string            | 否      | 格式为 `YEAR-MONTH-DAY` 的日期字符串。                            |
| `member_role_id` | integer         | 否      | 仅旗舰版。定制成员角色的 ID。如果未指定值，则移除所有角色。               |

```shell
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

> [!note]
> 如果 [角色晋升的管理员审批](../administration/settings/sign_up_restrictions.md#turn-on-administrator-approval-for-role-promotions) 启用，将现有用户提升到计费角色的成员请求需要管理员审批。

要启用 **管理非计费晋升**，
你必须首先启用 `enable_member_promotion_management` 应用设置。

示例响应：

```json
{
  "message":{
    "username_1":"请求已排队等待管理员审批。"
  }
}
```

<a id="remove-a-direct-member-of-a-project"></a>

## 移除项目的直接成员

移除指定的项目直接成员。

例如，如果用户被直接添加到群组中的某个项目，但并未明确添加到此群组中，则你无法使用此端点将其移除。有关更多信息，请参阅 [从群组中移除计费成员](group_members.md#remove-a-billable-group-member)。

```plaintext
DELETE /projects/:id/members/:user_id
```

| 属性                  | 类型              | 是否必需 | 描述                                                         |
|----------------------|-------------------|---------|--------------------------------------------------------------|
| `id`                 | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `user_id`            | integer           | 是      | 成员的用户 ID。                                               |
| `skip_subresources`  | boolean           | 否      | 是否应跳过删除被移除成员在子群组和项目中的直接成员资格。默认为 `false`。       |
| `unassign_issuables` | boolean           | 否      | 是否应取消分配被移除成员在给定项目中的任何议题或合并请求。默认为 `false`。          |

示例请求：

```shell
curl --request DELETE --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/:id/members/:user_id"
```