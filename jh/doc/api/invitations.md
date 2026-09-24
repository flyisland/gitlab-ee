---
stage: Tenant Scale
group: Organizations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 邀请 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 管理邀请并添加用户到[群组](../user/group/_index.md#add-users-to-a-group) 或 [项目](../user/project/members/_index.md)。

<a id="add-a-member-to-a-group-or-project"></a>

## 向群组或项目添加成员

添加新成员。你可以指定用户 ID 或通过电子邮件邀请用户。

先决条件：

- 对于群组，你必须拥有该群组的 所有者 角色。
- 对于项目：
  - 你必须拥有该项目的 所有者 或 维护者 角色。
  - 必须禁用[群组成员锁定](../user/group/access_and_permissions.md#prevent-members-from-being-added-to-projects-in-a-group)。
- 对于 极狐GitLab 私有化部署 实例：
  - 如果[禁止新建用户帐户](../administration/settings/sign_up_restrictions.md#disable-new-user-account-creation)，管理员必须添加用户。
  - 如果[禁止用户邀请](../administration/settings/visibility_and_access_controls.md#prevent-invitations-to-groups-and-projects)，管理员必须添加用户。
  - 如果[启用了角色晋升的管理员审批](../administration/settings/sign_up_restrictions.md#turn-on-administrator-approval-for-role-promotions)，管理员必须批准邀请。

```plaintext
POST /groups/:id/invitations
POST /projects/:id/invitations
```

| 属性            | 类型              | 是否必需                         | 描述 |
| --------------- | ----------------- | -------------------------------- | ---- |
| `id`            | 整数或字符串      | 是                               | ID 或[项目或群组的 URL 编码路径](rest/_index.md#namespaced-paths) |
| `email`         | 字符串            | 是（如果未提供 `user_id`）       | 新成员的电子邮件，或多个以逗号分隔的电子邮件。 |
| `user_id`       | 整数或字符串      | 是（如果未提供 `email`）         | 新成员的 ID，或多个以逗号分隔的 ID。 |
| `access_level`  | 整数              | 是                               | 有效的[访问级别](../user/permissions.md#default-roles)。可能的值：`0`（无访问权限）、`5`（最小访问权限）、`10`（访客）、`15`（计划者）、`20`（报告者）、`25`（安全经理）、`30`（开发者）、`40`（维护者）或 `50`（所有者）。默认值：`30`。 |
| `expires_at`    | 字符串            | 否                               | 格式为 `YEAR-MONTH-DAY` 的日期字符串 |
| `invite_source` | 字符串            | 否                               | 启动成员创建过程的邀请来源。 |
| `member_role_id`| 整数              | 否                               | 将新成员分配至提供的自定义角色。（引入于 极狐GitLab 16.6，仅旗舰版）。 |

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/:id/invitations" \
  --data "email=test@example.com&user_id=1&access_level=30"
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/:id/invitations" \
  --data "email=test@example.com&user_id=1&access_level=30"
```

响应示例：

当所有电子邮件都发送成功时：

```json
{  "status":  "success"  }
```

发送电子邮件时遇到任何错误时：

```json
{
  "status": "error",
  "message": {
               "test@example.com": "Invite email has already been taken",
               "test2@example.com": "User already exists in source",
               "test_username": "Access level is not included in the list"
             }
}
```

要启用 **管理非付费用户晋升**，您必须首先启用 `enable_member_promotion_management` 应用程序设置。

响应示例：

```json
{
  "queued_users": {
    "username_1": "Request queued for administrator approval."
  },
  "status": "success"
}
```

<a id="list-all-pending-invitations-for-a-group-or-project"></a>

## 列出群组或项目的所有待处理邀请

列出经认证用户可查看的所有待处理邀请。
仅返回直接成员的邀请，不包括通过继承祖先群组的邀请。

此函数接受分页参数 `page` 和 `per_page` 以限制成员列表。

```plaintext
GET /groups/:id/invitations
GET /projects/:id/invitations
```

| 属性     | 类型           | 是否必需 | 描述 |
|----------|----------------|----------|------|
| `id`      | 整数或字符串   | 是       | ID 或[项目或群组的 URL 编码路径](rest/_index.md#namespaced-paths) |
| `page`    | 整数           | 否       | 要检索的页面 |
| `per_page`| 整数           | 否       | 每页返回的成员邀请数 |
| `query`   | 字符串         | 否       | 用于按邀请电子邮件搜索被邀请成员的查询字符串。查询文本必须与电子邮件地址完全匹配。为空时，返回所有邀请。 |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/:id/invitations?query=member@example.org"
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/:id/invitations?query=member@example.org"
```

响应示例：

```json
 [
   {
     "id": 1,
     "invite_email": "member@example.org",
     "created_at": "2020-10-22T14:13:35Z",
     "access_level": 30,
     "expires_at": "2020-11-22T14:13:35Z",
     "user_name": "Raymond Smith",
     "created_by_name": "Administrator"
   },
]
```

<a id="update-an-invitation-to-a-group-or-project"></a>

## 更新群组或项目的邀请

更新群组或项目的待处理邀请。

```plaintext
PUT /groups/:id/invitations/:email
PUT /projects/:id/invitations/:email
```

| 属性         | 类型           | 是否必需 | 描述 |
|--------------|----------------|----------|------|
| `id`         | 整数或字符串   | 是       | ID 或[项目或群组的 URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `email`      | 字符串         | 是       | 之前发送邀请的电子邮件地址。 |
| `access_level`| 整数           | 否       | 有效的[访问级别](../user/permissions.md#default-roles)。可能的值：`0`（无访问权限）、`5`（最小访问权限）、`10`（访客）、`15`（计划者）、`20`（报告者）、`25`（安全经理）、`30`（开发者）、`40`（维护者）或 `50`（所有者）。默认值：`30`。 |
| `expires_at`  | 字符串         | 否       | ISO 8601 格式 (`YYYY-MM-DDTHH:MM:SSZ`) 的日期字符串。 |

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/55/invitations/email@example.org?access_level=40"
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/55/invitations/email@example.org?access_level=40"
```

响应示例：

```json
{
  "expires_at": "2012-10-22T14:13:35Z",
  "access_level": 40,
}
```

<a id="delete-an-invitation-to-a-group-or-project"></a>

## 删除群组或项目的邀请

删除对指定电子邮件地址的待处理邀请。

```plaintext
DELETE /groups/:id/invitations/:email
DELETE /projects/:id/invitations/:email
```

| 属性   | 类型           | 是否必需 | 描述 |
|--------|----------------|----------|------|
| `id`   | 整数或字符串   | 是       | ID 或[项目或群组的 URL 编码路径](rest/_index.md#namespaced-paths) |
| `email`| 字符串         | 是       | 之前发送邀请的电子邮件地址 |

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/55/invitations/email@example.org"
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/55/invitations/email@example.org"
```

- 成功时返回 `204` 且无内容。
- 无权限删除邀请时返回 `403` 禁止访问。
- 经授权但未找到该电子邮件地址的邀请时返回 `404` 未找到。
- 请求有效但无法删除邀请时返回 `409`。