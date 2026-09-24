---
stage: Package
group: Package Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 虚拟仓库清理策略 API
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- 状态：实验性

{{< /details >}}

{{< history >}}

- 在极狐GitLab 18.6 中引入，带有一个名为 `maven_virtual_registry` 的功能标志。默认启用。

{{< /history >}}

> [!flag]
> 这些端点的可用性由一个功能标志控制。
> 更多信息请参阅历史记录。
> 使用前请仔细阅读文档。

使用以下端点创建和管理虚拟仓库清理策略。每个群组只能有一个清理策略。

<a id="manage-cleanup-policies"></a>

## 管理清理策略

使用以下端点创建和管理虚拟仓库清理策略。每个群组只能有一个清理策略。

<a id="retrieve-the-cleanup-policy-for-a-group"></a>

### 检索群组的清理策略

{{< history >}}

- 在极狐GitLab 18.6 中引入，带有一个名为 `maven_virtual_registry` 的功能标志。默认启用。

{{< /history >}}

检索指定群组的清理策略。每个群组只能有一个清理策略。

```plaintext
GET /groups/:id/-/virtual_registries/cleanup/policy
```

支持的属性：

| 属性 | 类型 | 必需 | 描述 |
|:----------|:-----|:---------|:------------|
| `id` | 字符串或整数 | 是 | 群组 ID 或完整群组路径。必须是顶级群组。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
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

{{< history >}}

- 在极狐GitLab 18.6 中引入，带有一个名为 `maven_virtual_registry` 的功能标志。默认启用。

{{< /history >}}

为指定群组创建清理策略。每个群组只能有一个清理策略。

```plaintext
POST /groups/:id/-/virtual_registries/cleanup/policy
```

| 属性 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | 字符串或整数 | 是 | 群组 ID 或完整群组路径。必须是顶级群组。 |
| `cadence` | 整数 | 否 | 清理策略运行频率。必须为以下值之一：`1`（每天）、`7`（每周）、`14`（每两周）、`30`（每月）、`90`（每季度）。 |
| `enabled` | 布尔 | 否 | 启用或禁用清理策略。 |
| `keep_n_days_after_download` | 整数 | 否 | 未使用的缓存条目在多少天后被清理。必须在 1 到 365 之间。 |
| `notify_on_success` | 布尔 | 否 | 清理运行成功时通知群组所有者。 |
| `notify_on_failure` | 布尔 | 否 | 清理运行失败时通知群组所有者。 |

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

{{< history >}}

- 在极狐GitLab 18.6 中引入，带有一个名为 `maven_virtual_registry` 的功能标志。默认启用。

{{< /history >}}

更新指定群组的清理策略。

```plaintext
PATCH /groups/:id/-/virtual_registries/cleanup/policy
```

| 属性 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | 字符串或整数 | 是 | 群组 ID 或完整群组路径。必须是顶级群组。 |
| `cadence` | 整数 | 否 | 清理策略运行频率。必须为以下值之一：`1`（每天）、`7`（每周）、`14`（每两周）、`30`（每月）、`90`（每季度）。 |
| `enabled` | 布尔 | 否 | 启用或禁用策略。 |
| `keep_n_days_after_download` | 整数 | 否 | 未使用的缓存条目在多少天后被清理。必须在 1 到 365 之间。 |
| `notify_on_success` | 布尔 | 否 | 清理运行成功时通知群组所有者。 |
| `notify_on_failure` | 布尔 | 否 | 清理运行失败时通知群组所有者。 |

> [!note]
> 你必须在请求中提供至少一个可选参数。

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

{{< history >}}

- 在极狐GitLab 18.6 中引入，带有一个名为 `maven_virtual_registry` 的功能标志。默认启用。

{{< /history >}}

删除指定群组的清理策略。

```plaintext
DELETE /groups/:id/-/virtual_registries/cleanup/policy
```

| 属性 | 类型 | 必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | 字符串或整数 | 是 | 群组 ID 或完整群组路径。必须是顶级群组。 |

示例请求：

```shell
curl --request DELETE --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Accept: application/json" \
     --url "https://gitlab.example.com/api/v4/groups/5/-/virtual_registries/cleanup/policy"
```

如果成功，返回 [`204 无内容`](rest/troubleshooting.md#status-codes) 状态码。
