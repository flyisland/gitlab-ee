---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 项目里程碑 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 管理 [项目里程碑](../user/project/milestones/_index.md)。

对于群组里程碑，请使用 [群组里程碑 API](group_milestones.md)。

<a id="list-all-project-milestones"></a>

## 列出所有项目里程碑

列出项目的所有里程碑。

```plaintext
GET /projects/:id/milestones
GET /projects/:id/milestones?iids[]=42
GET /projects/:id/milestones?iids[]=42&iids[]=43
GET /projects/:id/milestones?state=active
GET /projects/:id/milestones?state=closed
GET /projects/:id/milestones?title=1.0
GET /projects/:id/milestones?search=version
GET /projects/:id/milestones?updated_before=2013-10-02T09%3A24%3A18Z
GET /projects/:id/milestones?updated_after=2013-10-02T09%3A24%3A18Z
```

参数：

| 属性                         | 类型   | 是否必需 | 描述 |
| ----------------------------      | ------ | -------- | ----------- |
| `id`                              | 整数或字符串 | 是 | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `iids[]`                          | 整数数组 | 否 | 仅返回具有给定 `iid` 的里程碑。如果 `include_ancestors` 为 `true`，则忽略此参数。 |
| `state`                           | 字符串 | 否 | 仅返回 `active` 或 `closed` 状态的里程碑 |
| `title`                           | 字符串 | 否 | 仅返回具有给定 `title` 的里程碑 |
| `search`                          | 字符串 | 否 | 仅返回标题或描述与提供的字符串匹配的里程碑 |
| `include_parent_milestones`       | 布尔值 | 否 | [已弃用](https://gitlab.com/gitlab-org/gitlab/-/issues/433298) 于极狐GitLab 16.7。请改用 `include_ancestors`。 |
| `include_ancestors`               | 布尔值 | 否 | 包含所有父群组的里程碑。 |
| `updated_before`                  | 日期时间 | 否 | 仅返回在给定日期时间之前更新的里程碑。需符合 ISO 8601 格式 (`2019-03-15T08:00:00Z`)。引入于极狐GitLab 15.10 |
| `updated_after`                   | 日期时间 | 否 | 仅返回在给定日期时间之后更新的里程碑。需符合 ISO 8601 格式 (`2019-03-15T08:00:00Z`)。引入于极狐GitLab 15.10 |

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/5/milestones"
```

示例响应：

```json
[
  {
    "id": 12,
    "iid": 3,
    "project_id": 16,
    "title": "10.0",
    "description": "Version",
    "due_date": "2013-11-29",
    "start_date": "2013-11-10",
    "state": "active",
    "updated_at": "2013-10-02T09:24:18Z",
    "created_at": "2013-10-02T09:24:18Z",
    "expired": false
  }
]
```

<a id="retrieve-a-milestone"></a>

## 获取单个里程碑

获取指定的项目里程碑。

```plaintext
GET /projects/:id/milestones/:milestone_id
```

参数：

| 属性      | 类型           | 是否必需 | 描述                                                                                                     |
|----------------|----------------|----------|-----------------------------------------------------------------------------------------------------------------|
| `id`           | 整数或字符串 | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `milestone_id` | 整数        | 是      | 项目里程碑的 ID                                                                               |

<a id="create-a-milestone"></a>

## 创建里程碑

创建项目里程碑。

```plaintext
POST /projects/:id/milestones
```

参数：

| 属性     | 类型           | 是否必需 | 描述                                                                                                     |
|---------------|----------------|----------|-----------------------------------------------------------------------------------------------------------------|
| `id`          | 整数或字符串 | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `title`       | 字符串         | 是      | 里程碑的标题                                                                                        |
| `description` | 字符串         | 否       | 里程碑的描述                                                                                |
| `due_date`    | 字符串         | 否       | 里程碑的截止日期 (`YYYY-MM-DD`)                                                                    |
| `start_date`  | 字符串         | 否       | 里程碑的开始日期 (`YYYY-MM-DD`)                                                                  |

<a id="update-a-milestone"></a>

## 更新里程碑

更新指定的项目里程碑。

```plaintext
PUT /projects/:id/milestones/:milestone_id
```

参数：

| 属性      | 类型           | 是否必需 | 描述                                                                                                     |
|----------------|----------------|----------|-----------------------------------------------------------------------------------------------------------------|
| `id`           | 整数或字符串 | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `milestone_id` | 整数        | 是      | 项目里程碑的 ID                                                                               |
| `title`        | 字符串         | 否       | 里程碑的标题                                                                                        |
| `description`  | 字符串         | 否       | 里程碑的描述                                                                                |
| `due_date`     | 字符串         | 否       | 里程碑的截止日期 (`YYYY-MM-DD`)                                                                    |
| `start_date`   | 字符串         | 否       | 里程碑的开始日期 (`YYYY-MM-DD`)                                                                  |
| `state_event`  | 字符串         | 否       | 里程碑的状态事件（`close` 或 `activate`）                                                            |

<a id="delete-a-milestone"></a>

## 删除里程碑

{{< history >}}

- 在极狐GitLab 15.0 中，所需的最低角色从开发者改为报告者。
- 在极狐GitLab 17.7 中，所需的最低角色从报告者改为计划者。

{{< /history >}}

删除指定的项目里程碑。

仅适用于具有项目计划者、报告者、开发者、维护者或所有者角色的用户。

```plaintext
DELETE /projects/:id/milestones/:milestone_id
```

参数：

| 属性      | 类型           | 是否必需 | 描述                                                                                                     |
|----------------|----------------|----------|-----------------------------------------------------------------------------------------------------------------|
| `id`           | 整数或字符串 | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `milestone_id` | 整数        | 是      | 项目里程碑的 ID                                                                               |

<a id="list-all-issues-for-a-milestone"></a>

## 列出里程碑的所有议题

列出分配给指定项目里程碑的所有议题。

```plaintext
GET /projects/:id/milestones/:milestone_id/issues
```

参数：

| 属性      | 类型           | 是否必需 | 描述                                                                                                     |
|----------------|----------------|----------|-----------------------------------------------------------------------------------------------------------------|
| `id`           | 整数或字符串 | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `milestone_id` | 整数        | 是      | 项目里程碑的 ID                                                                               |

<a id="list-all-merge-requests-for-a-milestone"></a>

## 列出里程碑的所有合并请求

列出分配给指定项目里程碑的所有合并请求。

```plaintext
GET /projects/:id/milestones/:milestone_id/merge_requests
```

参数：

| 属性      | 类型           | 是否必需 | 描述                                                                                                     |
|----------------|----------------|----------|-----------------------------------------------------------------------------------------------------------------|
| `id`           | 整数或字符串 | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `milestone_id` | 整数        | 是      | 项目里程碑的 ID                                                                               |

<a id="promote-a-milestone-to-group-milestone"></a>

## 将项目里程碑提升为群组里程碑

{{< history >}}

- 在极狐GitLab 15.0 中，所需的最低角色从开发者改为报告者。
- 在极狐GitLab 17.7 中，所需的最低角色从报告者改为计划者。

{{< /history >}}

将项目里程碑提升为群组里程碑。

仅适用于具有群组计划者、报告者、开发者、维护者或所有者角色的用户。

```plaintext
POST /projects/:id/milestones/:milestone_id/promote
```

参数：

| 属性      | 类型           | 是否必需 | 描述                                                                                                     |
|----------------|----------------|----------|-----------------------------------------------------------------------------------------------------------------|
| `id`           | 整数或字符串 | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `milestone_id` | 整数        | 是      | 项目里程碑的 ID                                                                               |

<a id="list-all-burndown-chart-events-for-a-milestone"></a>

## 列出里程碑的所有燃尽图事件

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

列出指定里程碑的所有燃尽图事件。

```plaintext
GET /projects/:id/milestones/:milestone_id/burndown_events
```

参数：

| 属性      | 类型           | 是否必需 | 描述                                                                                                     |
|----------------|----------------|----------|-----------------------------------------------------------------------------------------------------------------|
| `id`           | 整数或字符串 | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths) |
| `milestone_id` | 整数        | 是      | 项目里程碑的 ID                                                                               |