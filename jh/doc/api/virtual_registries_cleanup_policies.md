---
stage: Package
group: Package Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 虚拟仓库清理策略 API
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Status: 实验

{{< /details >}}

> [!flag]
> 这些端点的可用性由功能标志控制。
> 使用前请仔细阅读文档。

使用此 API 可以：

- 创建和管理虚拟仓库清理策略。
- 配置清理计划和保留设置。
- 自动清理未使用的缓存条目。

<a id="manage-cleanup-policies"></a>

## 管理清理策略

使用以下端点创建和管理虚拟仓库清理策略。每个群组只能有一个清理策略。

<a id="retrieve-the-cleanup-policy-for-a-group"></a>

### 检索群组的清理策略

检索指定群组的清理策略。每个群组只能有一个清理策略。

```plaintext
GET /groups/:id/-/virtual_registries/cleanup/policy
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|:----------|:-----|:---------|:------------|
| `id` | string or integer | 是 | 群组 ID 或完整群组路径。必须是顶级群组。 |

示例请求：

```shell
curl --request GET \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Accept: application/json" \
     --url "https://gitlab.example.com/api/v4/groups/5/-/virtual_registries/cleanup/policy"
```

示例响应：

```json
{
  "group_id": 5,
  "next_run_at": "2024-06-06T12:28:27.855Z",
  "last_run_at": "2024-05-30T12:28:27.855Z",
  "last_run_deleted_size": 1048576,
  "last_run_deleted_entries_count": 25,
  "keep_n_days_after_download": 30,
  "status": "scheduled",
  "cadence": 7,
  "enabled": true,
  "notify_on_success": false,
  "notify_on_failure": false,
  "failure_message": null,
  "last_run_detailed_metrics": {
    "maven": {
      "deleted_entries_count": 25,
      "deleted_size": 1048576
    }
  },
  "created_at": "2024-05-30T12:28:27.855Z",
  "updated_at": "2024-05-30T12:28:27.855Z"
}
```

<a id="create-a-cleanup-policy"></a>

### 创建清理策略

为指定群组创建清理策略。每个群组只能有一个清理策略。

```plaintext
POST /groups/:id/-/virtual_registries/cleanup/policy
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | string or integer | 是 | 群组 ID 或完整群组路径。必须是顶级群组。 |
| `cadence` | integer | 否 | 清理策略的运行频率。必须为以下之一：`1`（每天）、`7`（每周）、`14`（每两周）、`30`（每月）、`90`（每季度）。 |
| `enabled` | boolean | 否 | 启用或禁用清理策略。 |
| `keep_n_days_after_download` | integer | 否 | 未使用的缓存条目在多少天后应被清理。必须介于 1 和 365 之间。 |
| `notify_on_success` | boolean | 否 | 清理运行成功时通知群组所有者。 |
| `notify_on_failure` | boolean | 否 | 清理运行失败时通知群组所有者。 |

示例请求：

```shell
curl --request POST \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Content-Type: application/json" \
     --header "Accept: application/json" \
     --data '{"enabled": true, "keep_n_days_after_download": 30, "cadence": 7}' \
     --url "https://gitlab.example.com/api/v4/groups/5/-/virtual_registries/cleanup/policy"
```

示例响应：

```json
{
  "group_id": 5,
  "next_run_at": "2024-06-06T12:28:27.855Z",
  "last_run_at": null,
  "last_run_deleted_size": 0,
  "last_run_deleted_entries_count": 0,
  "keep_n_days_after_download": 30,
  "status": "scheduled",
  "cadence": 7,
  "enabled": true,
  "notify_on_success": false,
  "notify_on_failure": false,
  "failure_message": null,
  "last_run_detailed_metrics": {},
  "created_at": "2024-05-30T12:28:27.855Z",
  "updated_at": "2024-05-30T12:28:27.855Z"
}
```

<a id="update-a-cleanup-policy"></a>

### 更新清理策略

更新指定群组的清理策略。

```plaintext
PATCH /groups/:id/-/virtual_registries/cleanup/policy
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | string or integer | 是 | 群组 ID 或完整群组路径。必须是顶级群组。 |
| `cadence` | integer | 否 | 清理策略的运行频率。必须为以下之一：`1`（每天）、`7`（每周）、`14`（每两周）、`30`（每月）、`90`（每季度）。 |
| `enabled` | boolean | 否 | 用于启用/禁用该策略的布尔值。 |
| `keep_n_days_after_download` | integer | 否 | 未使用的缓存条目在多少天后应被清理。必须介于 1 和 365 之间。 |
| `notify_on_success` | boolean | 否 | 清理运行成功时通知群组所有者。 |
| `notify_on_failure` | boolean | 否 | 清理运行失败时通知群组所有者。 |

> [!note]
> 您必须在请求中至少提供一个可选参数。

示例请求：

```shell
curl --request PATCH \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Content-Type: application/json" \
     --data '{"keep_n_days_after_download": 60}' \
     --url "https://gitlab.example.com/api/v4/groups/5/-/virtual_registries/cleanup/policy"
```

示例响应：

```json
{
  "group_id": 5,
  "next_run_at": "2024-06-06T12:28:27.855Z",
  "last_run_at": "2024-05-30T12:28:27.855Z",
  "last_run_deleted_size": 1048576,
  "last_run_deleted_entries_count": 25,
  "keep_n_days_after_download": 60,
  "status": "scheduled",
  "cadence": 7,
  "enabled": true,
  "notify_on_success": false,
  "notify_on_failure": false,
  "failure_message": null,
  "last_run_detailed_metrics": {
    "maven": {
      "deleted_entries_count": 25,
      "deleted_size": 1048576
    }
  },
  "created_at": "2024-05-30T12:28:27.855Z",
  "updated_at": "2024-05-30T12:28:27.855Z"
}
```

<a id="delete-a-cleanup-policy"></a>

### 删除清理策略

删除指定群组的清理策略。

```plaintext
DELETE /groups/:id/-/virtual_registries/cleanup/policy
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | string or integer | 是 | 群组 ID 或完整群组路径。必须是顶级群组。 |

示例请求：

```shell
curl --request DELETE \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Accept: application/json" \
     --url "https://gitlab.example.com/api/v4/groups/5/-/virtual_registries/cleanup/policy"
```

如果成功，返回 [`204 No Content`](rest/troubleshooting.md#status-codes) 状态码。
