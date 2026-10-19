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

使用此 API 管理邀请，并将用户添加到[群组](../user/group/_index.md#add-users-to-a-group)或[项目](../user/project/members/_index.md)。

<a id="add-a-member-to-a-group-or-project"></a>

## 将成员添加到群组或项目

添加新成员。您可以指定用户 ID，或通过电子邮件邀请用户。

先决条件：

- 对于群组，您必须拥有该群组的所有者角色。
- 对于项目：
  - 您必须拥有该项目的维护者或所有者角色。
  - 必须禁用[群组成员关系锁定](../user/group/access_and_permissions.md#prevent-members-from-being-added-to-projects-in-a-group)。
- 对于极狐GitLab 私有化部署实例：
  - 如果[不允许创建新用户账号](../administration/settings/sign_up_restrictions.md#disable-new-user-account-creation)，则必须由管理员添加用户。
  - 如果[不允许用户邀请](../administration/settings/visibility_and_access_controls.md#prevent-invitations-to-groups-and-projects)，则必须由管理员添加用户。
  - 如果[已启用角色提升的管理员审批](../administration/settings/sign_up_restrictions.md#turn-on-administrator-approval-for-role-promotions)，则必须由管理员批准该邀请。

```plaintext
POST /groups/:id/invitations
POST /projects/:id/invitations
```

| 属性        | 类型              | 是否必需                          | 描述 |
| ---------------- | ----------------- | --------------------------------- | ----------- |
| `id`             | integer or string | 是                               | 项目或群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `email`          | string            | 是（如果未提供 `user_id`） | 新成员的电子邮件地址，或多个电子邮件地址（以逗号分隔）。 |
| `user_id`        | integer or string | 是（如果未提供 `email`）   | 新成员的 ID，或多个 ID（以逗号分隔）。 |
| `access_level`   | integer           | 是                               | 有效的[访问级别](../user/permissions.md#default-roles)。可能的值：`0`（无访问权限）、`5`（最小访问权限）、`10`（访客）、`15`（计划者）、`20`（报告者）、`25`（安全管理员）、`30`（开发者）、`40`（维护者）或 `50`（所有者）。默认值：`30`。 |
| `expires_at`     | string            | 否                                | 格式为 `YEAR-MONTH-DAY`的日期字符串 |
| `invite_source`  | string            | 否                                | 启动成员创建流程的邀请来源。 |
| `member_role_id` | integer           | 否                                | 将新成员分配到提供的自定义角色。仅限旗舰版。 |

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

示例响应：

当所有电子邮件均成功发送时：

```json
{  "status":  "success"  }
```

当发送电子邮件出现任何错误时：

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

要启用 **管理非付费用户晋升**，
您必须先启用 `enable_member_promotion_management` 应用设置。

示例响应：

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

列出经过身份验证的用户可查看的所有待处理邀请。仅返回直接成员的邀请，不包含通过继承的上级群组获得的邀请。

此函数接受分页参数 `page` 和 `per_page`，以限制成员列表。

```plaintext
GET /groups/:id/invitations
GET /projects/:id/invitations
```

| 属性  | 类型           | 是否必需 | 描述 |
|------------|----------------|----------|-------------|
| `id`       | integer or string | 是      | 项目或群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `page`     | integer        | 否       | 要检索的页码 |
| `per_page` | integer        | 否       | 每页返回的成员邀请数量 |
| `query`    | string         | 否       | 用于按邀请电子邮件搜索受邀成员的查询字符串。查询文本必须与电子邮件地址完全匹配。为空时，返回所有邀请。 |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/:id/invitations?query=member@example.org"
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/:id/invitations?query=member@example.org"
```

示例响应：

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

| 属性      | 类型              | 是否必需 | 描述 |
| -------------- | ----------------- | -------- | ----------- |
| `id`           | integer or string | 是      | 项目或群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `email`        | string            | 是      | 之前发送邀请时使用的电子邮件地址。 |
| `access_level` | integer           | 否       | 有效的[访问级别](../user/permissions.md#default-roles)。可能的值：`0`（无访问权限）、`5`（最小访问权限）、`10`（访客）、`15`（计划者）、`20`（报告者）、`25`（安全管理员）、`30`（开发者）、`40`（维护者）或 `50`（所有者）。默认值：`30`。 |
| `expires_at`   | string            | 否       | ISO 8601 格式的日期字符串（`YYYY-MM-DDTHH:MM:SSZ`）。 |

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/55/invitations/email@example.org?access_level=40"
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/55/invitations/email@example.org?access_level=40"
```

示例响应：

```json
{
  "expires_at": "2012-10-22T14:13:35Z",
  "access_level": 40,
}
```

<a id="delete-an-invitation-to-a-group-or-project"></a>

## 删除群组或项目的邀请

删除发送到指定电子邮件地址的待处理邀请。

```plaintext
DELETE /groups/:id/invitations/:email
DELETE /projects/:id/invitations/:email
```

| 属性 | 类型           | 是否必需 | 描述 |
|-----------|----------------|----------|-------------|
| `id`      | integer or string | 是      | 项目或群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `email`   | string         | 是      | 之前发送邀请时使用的电子邮件地址 |

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/55/invitations/email@example.org"
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/55/invitations/email@example.org"
```

- 成功时返回 `204` 且无内容。
- 如果无权删除该邀请，则返回 `403` 禁止访问。
- 如果有权限但未找到该电子邮件地址对应的邀请，则返回 `404` 未找到。
- 如果请求有效但无法删除该邀请，则返回 `409`。
