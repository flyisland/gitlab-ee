---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Documentation for the REST API for merge request approval settings in 极狐GitLab.
title: 合并请求审批设置 API
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 管理群组和项目的[合并请求审批设置](../user/project/merge_requests/approvals/settings.md)。
所有端点都需要身份验证。

<a id="group-mr-approval-settings"></a>

## 群组 MR 审批设置

先决条件：

- 您必须在群组中具有 所有者 角色。

<a id="retrieve-mr-approval-settings-for-a-group"></a>

### 检索群组的 MR 审批设置

检索指定群组的合并请求审批设置。

```plaintext
GET /groups/:id/merge_request_approval_setting
```

参数：

| 属性        | 类型           | 是否必需 | 描述 |
|:-----------------|:---------------|:---------|:------------|
| `id`             | 整数或字符串 | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

请求示例：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/:id/merge_request_approval_setting"
```

响应示例：

```json
{
  "allow_author_approval": {
    "value": true,
    "locked": false,
    "inherited_from": null
  },
  "allow_committer_approval": {
    "value": true,
    "locked": false,
    "inherited_from": null
  },
  "allow_overrides_to_approver_list_per_merge_request": {
    "value": true,
    "locked": false,
    "inherited_from": null
  },
  "retain_approvals_on_push": {
    "value": false,
    "locked": false,
    "inherited_from": null
  },
  "selective_code_owner_removals": {
    "value": false,
    "locked": false,
    "inherited_from": null
  },
  "require_password_to_approve": {
    "value": false,
    "locked": false,
    "inherited_from": null
  },
  "require_reauthentication_to_approve": {
    "value": false,
    "locked": false,
    "inherited_from": null
  }
}
```

<a id="update-group-mr-approval-settings"></a>

### 更新群组 MR 审批设置

更新群组的合并请求审批设置。

```plaintext
PUT /groups/:id/merge_request_approval_setting
```

参数：

| 属性                                            | 类型              | 是否必需 | 描述 |
|------------------------------------------------------|-------------------|----------|-------------|
| `id`                                                 | 整数或字符串 | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `allow_author_approval`                              | 布尔值           | 否       | 允许或阻止作者自行审批合并请求；`true` 表示作者可以自行审批。 |
| `allow_committer_approval`                           | 布尔值           | 否       | 允许或阻止提交者自行审批合并请求。 |
| `allow_overrides_to_approver_list_per_merge_request` | 布尔值           | 否       | 允许或阻止针对每个合并请求覆盖审批人列表。 |
| `retain_approvals_on_push`                           | 布尔值           | 否       | 在新推送时保留审批计数。 |
| `require_reauthentication_to_approve`                | 布尔值           | 否       | 要求审批人在添加审批之前进行身份验证。在极狐GitLab 17.1 中引入。 |

请求示例：

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/:id/merge_request_approval_setting?allow_author_approval=false"
```

响应示例：

```json
{
  "allow_author_approval": {
    "value": false,
    "locked": false,
    "inherited_from": null
  },
  "allow_committer_approval": {
    "value": true,
    "locked": false,
    "inherited_from": null
  },
  "allow_overrides_to_approver_list_per_merge_request": {
    "value": true,
    "locked": false,
    "inherited_from": null
  },
  "retain_approvals_on_push": {
    "value": false,
    "locked": false,
    "inherited_from": null
  },
  "selective_code_owner_removals": {
    "value": false,
    "locked": false,
    "inherited_from": null
  },
  "require_password_to_approve": {
    "value": false,
    "locked": false,
    "inherited_from": null
  },
  "require_reauthentication_to_approve": {
    "value": false,
    "locked": false,
    "inherited_from": null
  }
}
```

<a id="project-mr-approval-settings"></a>

## 项目 MR 审批设置

先决条件：

- 您必须在项目中具有 维护者 角色。

<a id="retrieve-mr-approval-settings-for-a-project"></a>

### 检索项目的 MR 审批设置

检索指定项目的合并请求审批设置。

```plaintext
GET /projects/:id/merge_request_approval_setting
```

参数：

| 属性        | 类型           | 是否必需 | 描述 |
|:-----------------|:---------------|:---------|:------------|
| `id`             | 整数或字符串 | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

请求示例：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/:id/merge_request_approval_setting"
```

响应示例：

```json
{
  "allow_author_approval": {
    "value": true,
    "locked": false,
    "inherited_from": null
  },
  "allow_committer_approval": {
    "value": true,
    "locked": false,
    "inherited_from": null
  },
  "allow_overrides_to_approver_list_per_merge_request": {
    "value": true,
    "locked": false,
    "inherited_from": null
  },
  "retain_approvals_on_push": {
    "value": false,
    "locked": true,
    "inherited_from": "group"
  },
  "selective_code_owner_removals": {
    "value": false,
    "locked": false,
    "inherited_from": null
  },
  "require_password_to_approve": {
    "value": false,
    "locked": false,
    "inherited_from": null
  },
  "require_reauthentication_to_approve": {
    "value": false,
    "locked": false,
    "inherited_from": null
  }
}
```

<a id="update-project-mr-approval-settings"></a>

### 更新项目 MR 审批设置

更新项目的合并请求审批设置。

```plaintext
PUT /projects/:id/merge_request_approval_setting
```

参数：

| 属性                                            | 类型              | 是否必需 | 描述 |
|------------------------------------------------------|-------------------|----------|-------------|
| `id`                                                 | 整数或字符串 | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `allow_author_approval`                              | 布尔值           | 否       | 允许或阻止作者自行审批合并请求；`true` 表示作者可以自行审批。 |
| `allow_committer_approval`                           | 布尔值           | 否       | 允许或阻止提交者自行审批合并请求。 |
| `allow_overrides_to_approver_list_per_merge_request` | 布尔值           | 否       | 允许或阻止针对每个合并请求覆盖审批人列表。 |
| `retain_approvals_on_push`                           | 布尔值           | 否       | 在新推送时保留审批计数。 |
| `selective_code_owner_removals`                      | 布尔值           | 否       | 如果代码所有者文件发生更改，则重置来自代码所有者的审批。必须禁用 `retain_approvals_on_push` 字段才能使用此字段。 |
| `require_reauthentication_to_approve`                | 布尔值           | 否       | 要求审批人在添加审批之前进行身份验证。在极狐GitLab 17.1 中引入。 |

请求示例：

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/:id/merge_request_approval_setting?allow_author_approval=false"
```

响应示例：

```json
{
  "allow_author_approval": {
    "value": false,
    "locked": false,
    "inherited_from": null
  },
  "allow_committer_approval": {
    "value": true,
    "locked": false,
    "inherited_from": null
  },
  "allow_overrides_to_approver_list_per_merge_request": {
    "value": true,
    "locked": false,
    "inherited_from": null
  },
  "retain_approvals_on_push": {
    "value": false,
    "locked": false,
    "inherited_from": null
  },
  "selective_code_owner_removals": {
    "value": false,
    "locked": false,
    "inherited_from": null
  },
  "require_password_to_approve": {
    "value": false,
    "locked": false,
    "inherited_from": null
  },
  "require_reauthentication_to_approve": {
    "value": false,
    "locked": false,
    "inherited_from": null
  }
}
```