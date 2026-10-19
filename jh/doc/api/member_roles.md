---
stage: Software Supply Chain Security
group: Authorization
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 成员角色 API
description: Use the Member Roles API to manage custom roles for GitLab.com groups or GitLab Self-Managed instances. List, create, and delete custom member roles programmatically.
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 15.4 中引入。在功能标志 `customizable_roles` 后部署，默认禁用。
- 在极狐GitLab 15.9 中默认启用。
- 在极狐GitLab 16.0 中新增了读取漏洞权限。
- 在极狐GitLab 16.1 中新增了管理漏洞权限。
- 在极狐GitLab 16.3 中新增了读取依赖项权限。
- 在极狐GitLab 16.3 中新增了名称和描述字段。
- 在极狐GitLab 16.4 中引入管理合并请求权限，在功能标志 `admin_merge_request` 后部署，默认禁用。
- 在极狐GitLab 16.5 中移除了功能标志 `admin_merge_request`。
- 在极狐GitLab 16.5 中引入管理群组成员权限，在功能标志 `admin_group_member` 后部署，默认禁用。此功能标志已在极狐GitLab 16.6 中移除。
- 在极狐GitLab 16.5 中引入管理项目访问令牌权限，在功能标志 `manage_project_access_tokens` 后部署，默认禁用。
- 在极狐GitLab 16.7 中引入归档项目权限。
- 在极狐GitLab 16.8 中引入删除项目权限。
- 在极狐GitLab 16.8 中引入管理群组访问令牌权限。
- 在极狐GitLab 16.8 中引入管理 Terraform 状态权限。
- 在极狐GitLab 16.9 中引入在私有化部署实例上创建和移除实例范围自定义角色的功能。

{{< /history >}}

使用此 API 管理 JihuLab.com 群组或整个私有化部署实例的成员角色。

## 管理实例成员角色

{{< details >}}

- Tier: 旗舰版
- Offering: 私有化部署

{{< /details >}}

前置条件：

- 以管理员身份进行认证。

<a id="get-all-instance-member-roles"></a>

### 获取所有实例成员角色

获取实例中的所有成员角色。

```plaintext
GET /member_roles
```

请求示例：

```shell
curl --request GET \
  --header "Authorization: Bearer <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/member_roles"
```

响应示例：

```json
[
  {
    "id": 2,
    "name": "实例自定义角色",
    "description": "可以读取代码的自定义访客",
    "group_id": null,
    "base_access_level": 10,
    "admin_cicd_variables": false,
    "admin_compliance_framework": false,
    "admin_group_member": false,
    "admin_merge_request": false,
    "admin_push_rules": false,
    "admin_terraform_state": false,
    "admin_vulnerability": false,
    "admin_web_hook": false,
    "archive_project": false,
    "manage_deploy_tokens": false,
    "manage_group_access_tokens": false,
    "manage_merge_request_settings": false,
    "manage_project_access_tokens": false,
    "manage_security_policy_link": false,
    "read_code": true,
    "read_runners": false,
    "read_dependency": false,
    "read_vulnerability": false,
    "remove_group": false,
    "remove_project": false
  }
]
```

<a id="create-an-instance-member-role"></a>

### 创建实例成员角色

创建一个实例范围的成员角色。

```plaintext
POST /member_roles
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|:----------|:--------|:---------|:-------------------------------------|
| `name`         | string         | 是      | 成员角色的名称。 |
| `description`  | string         | 否       | 成员角色的描述。 |
| `base_access_level` | integer   | 是      | 已配置角色的基础访问级别。有效值为 `10` (访客)，`15` (计划者)，`20` (报告者)，`25` (安全管理经理)，`30` (开发者)，`40` (维护者)，或 `50` (所有者)。|
| `admin_cicd_variables` | boolean | 否       | 创建、读取、更新和删除 CI/CD 变量的权限。 |
| `admin_compliance_framework` | boolean | 否       | 管理合规框架的权限。 |
| `admin_group_member` | boolean | 否       | 在群组中添加、移除和分配成员的权限。 |
| `admin_merge_request` | boolean | 否       | 审批合并请求的权限。 |
| `admin_push_rules` | boolean | 否       | 为群组或项目级别的代码仓库配置推送规则的权限。 |
| `admin_terraform_state` | boolean | 否       | 管理项目 Terraform 状态的权限。 |
| `admin_vulnerability` | boolean | 否       | 编辑漏洞对象的权限，包括状态和关联议题。 |
| `admin_web_hook` | boolean | 否       | 管理 Webhooks 的权限。 |
| `archive_project` | boolean | 否       | 归档项目的权限。 |
| `manage_deploy_tokens` | boolean | 否       | 管理部署令牌的权限。 |
| `manage_group_access_tokens` | boolean | 否       | 管理群组访问令牌的权限。 |
| `manage_merge_request_settings` | boolean | 否       | 配置合并请求设置的权限。 |
| `manage_project_access_tokens` | boolean | 否       | 管理项目访问令牌的权限。 |
| `manage_security_policy_link` | boolean | 否       | 链接安全策略项目的权限。 |
| `read_code`           | boolean | 否       | 读取项目代码的权限。 |
| `read_runners`     | boolean | 否       | 查看项目 Runners 的权限。 |
| `read_dependency`     | boolean | 否       | 读取项目依赖项的权限。 |
| `read_vulnerability`  | boolean | 否       | 读取项目漏洞的权限。 |
| `remove_group` | boolean | 否       | 删除或恢复群组的权限。 |
| `remove_project` | boolean | 否       | 删除项目的权限。 |

关于可用权限的更多信息，请参见[自定义权限](../user/custom_roles/abilities.md)。

请求示例：

```shell
curl --request POST \
  --header "Content-Type: application/json" \
  --header "Authorization: Bearer <your_access_token>" \
  --data '{"name" : "自定义访客（实例）", "base_access_level" : 10, "read_code" : true}' \
  --url "https://gitlab.example.com/api/v4/member_roles"
```

响应示例：

```json
{
  "id": 3,
  "name": "自定义访客（实例）",
  "group_id": null,
  "description": null,
  "base_access_level": 10,
  "admin_cicd_variables": false,
  "admin_compliance_framework": false,
  "admin_group_member": false,
  "admin_merge_request": false,
  "admin_push_rules": false,
  "admin_terraform_state": false,
  "admin_vulnerability": false,
  "admin_web_hook": false,
  "archive_project": false,
  "manage_deploy_tokens": false,
  "manage_group_access_tokens": false,
  "manage_merge_request_settings": false,
  "manage_project_access_tokens": false,
  "manage_security_policy_link": false,
  "read_code": true,
  "read_runners": false,
  "read_dependency": false,
  "read_vulnerability": false,
  "remove_group": false,
  "remove_project": false
}
```

<a id="delete-an-instance-member-role"></a>

### 删除实例成员角色

从实例中删除一个成员角色。

```plaintext
DELETE /member_roles/:member_role_id
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|:----------|:--------|:---------|:-------------------------------------|
| `member_role_id` | integer | 是   | 成员角色的 ID。 |

如果成功，返回 [`204`](rest/troubleshooting.md#status-codes) 和一个空响应。

请求示例：

```shell
curl --request DELETE \
  --header "Content-Type: application/json" \
  --header "Authorization: Bearer <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/member_roles/1"
```

## 管理群组成员角色

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com

{{< /details >}}

前置条件：

- 你必须拥有该群组的所有者角色。

<a id="get-all-group-member-roles"></a>

### 获取所有群组成员角色

```plaintext
GET /groups/:id/member_roles
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|:----------|:--------|:---------|:-------------------------------------|
| `id`      | integer 或 string | 是 | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |

请求示例：

```shell
curl --request GET \
  --header "Authorization: Bearer <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/84/member_roles"
```

响应示例：

```json
[
  {
    "id": 2,
    "name": "访客 + 读取代码",
    "description": "可以读取代码的自定义访客",
    "group_id": 84,
    "base_access_level": 10,
    "admin_cicd_variables": false,
    "admin_compliance_framework": false,
    "admin_group_member": false,
    "admin_merge_request": false,
    "admin_push_rules": false,
    "admin_terraform_state": false,
    "admin_vulnerability": false,
    "admin_web_hook": false,
    "archive_project": false,
    "manage_deploy_tokens": false,
    "manage_group_access_tokens": false,
    "manage_merge_request_settings": false,
    "manage_project_access_tokens": false,
    "manage_security_policy_link": false,
    "read_code": true,
    "read_runners": false,
    "read_dependency": false,
    "read_vulnerability": false,
    "remove_group": false,
    "remove_project": false
  },
  {
    "id": 3,
    "name": "访客 + 安全",
    "description": "可以读取和管理安全实体的自定义访客",
    "group_id": 84,
    "base_access_level": 10,
    "admin_cicd_variables": false,
    "admin_compliance_framework": false,
    "admin_group_member": false,
    "admin_merge_request": false,
    "admin_push_rules": false,
    "admin_terraform_state": false,
    "admin_vulnerability": true,
    "admin_web_hook": false,
    "archive_project": false,
    "manage_deploy_tokens": false,
    "manage_group_access_tokens": false,
    "manage_merge_request_settings": false,
    "manage_project_access_tokens": false,
    "manage_security_policy_link": false,
    "read_code": true,
    "read_runners": false,
    "read_dependency": true,
    "read_vulnerability": true,
    "remove_group": false,
    "remove_project": false
  }
]
```

<a id="add-a-member-role-to-a-group"></a>

### 向群组添加成员角色

{{< history >}}

- 在极狐GitLab 16.3 中引入在创建自定义角色时添加名称和描述的功能。

{{< /history >}}

向群组添加一个成员角色。你只能在群组的根级别添加成员角色。

```plaintext
POST /groups/:id/member_roles
```

参数：

| 属性 | 类型                | 是否必需 | 描述 |
|:----------|:--------|:---------|:-------------------------------------|
| `id`      | integer 或 string      | 是      | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `admin_cicd_variables` | boolean | 否       | 创建、读取、更新和删除 CI/CD 变量的权限。 |
| `admin_compliance_framework` | boolean | 否       | 管理合规框架的权限。 |
| `admin_group_member` | boolean | 否       | 在群组中添加、移除和分配成员的权限。 |
| `admin_merge_request` | boolean | 否       | 审批合并请求的权限。 |
| `admin_push_rules` | boolean | 否       | 为群组或项目级别的代码仓库配置推送规则的权限。 |
| `admin_terraform_state` | boolean | 否       | 管理项目 Terraform 状态的权限。 |
| `admin_vulnerability` | boolean | 否       | 管理项目漏洞的权限。 |
| `admin_web_hook` | boolean | 否       | 管理 Webhooks 的权限。 |
| `archive_project` | boolean | 否       | 归档项目的权限。 |
| `manage_deploy_tokens` | boolean | 否       | 管理部署令牌的权限。 |
| `manage_group_access_tokens` | boolean | 否       | 管理群组访问令牌的权限。 |
| `manage_merge_request_settings` | boolean | 否       | 配置合并请求设置的权限。 |
| `manage_project_access_tokens` | boolean | 否       | 管理项目访问令牌的权限。 |
| `manage_security_policy_link` | boolean | 否       | 链接安全策略项目的权限。 |
| `read_code`           | boolean | 否       | 读取项目代码的权限。 |
| `read_runners`     | boolean | 否       | 查看项目 Runners 的权限。 |
| `read_dependency`     | boolean | 否       | 读取项目依赖项的权限。 |
| `read_vulnerability`  | boolean | 否       | 读取项目漏洞的权限。 |
| `remove_group` | boolean | 否       | 删除或恢复群组的权限。 |
| `remove_project` | boolean | 否       | 删除项目的权限。 |

请求示例：

```shell
curl --request POST \
  --header "Content-Type: application/json" \
  --header "Authorization: Bearer <your_access_token>" \
  --data '{"name" : "自定义访客", "base_access_level" : 10, "read_code" : true}' \
  --url "https://gitlab.example.com/api/v4/groups/84/member_roles"
```

响应示例：

```json
{
  "id": 3,
  "name": "自定义访客",
  "description": null,
  "group_id": 84,
  "base_access_level": 10,
  "admin_cicd_variables": false,
  "admin_compliance_framework": false,
  "admin_group_member": false,
  "admin_merge_request": false,
  "admin_push_rules": false,
  "admin_terraform_state": false,
  "admin_vulnerability": false,
  "admin_web_hook": false,
  "archive_project": false,
  "manage_deploy_tokens": false,
  "manage_group_access_tokens": false,
  "manage_merge_request_settings": false,
  "manage_project_access_tokens": false,
  "manage_security_policy_link": false,
  "read_code": true,
  "read_runners": false,
  "read_dependency": false,
  "read_vulnerability": false,
  "remove_group": false,
  "remove_project": false
}
```

在极狐GitLab 16.3 及更高版本中，你可以使用 API 来：

- 在[创建新的自定义角色](../user/custom_roles/_index.md#create-a-custom-member-role)时添加名称（必填）和描述（可选）。
- 更新现有自定义角色的名称和描述。

<a id="remove-member-role-of-a-group"></a>

### 移除群组的成员角色

删除群组的一个成员角色。

```plaintext
DELETE /groups/:id/member_roles/:member_role_id
```

| 属性 | 类型 | 是否必需 | 描述 |
|:----------|:--------|:---------|:-------------------------------------|
| `id`      | integer 或 string | 是 | 群组的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `member_role_id` | integer | 是   | 成员角色的 ID。 |

如果成功，返回 [`204`](rest/troubleshooting.md#status-codes) 和一个空响应。

请求示例：

```shell
curl --request DELETE \
  --header "Content-Type: application/json" \
  --header "Authorization: Bearer <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/groups/84/member_roles/1"
```