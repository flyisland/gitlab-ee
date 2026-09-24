---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Sidekiq 队列管理 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

## 从 Sidekiq 队列中删除作业

删除与给定元数据匹配的 Sidekiq 队列中的作业。

响应包含三个字段：

1. `deleted_jobs` - 请求删除的作业数量。
1. `queue_size` - 处理请求后队列的剩余大小。
1. `completed` - 请求是否能够及时处理整个队列。如果不能，使用相同参数重试可能会删除更多作业（包括在第一次请求发出后添加的作业）。

此 API 端点仅对管理员可用。

```plaintext
DELETE /admin/sidekiq/queues/:queue_name
```

| 属性                | 类型   | 是否必需 | 描述 |
|---------------------|--------|----------|-------------|
| `queue_name`        | string | 是      | 要删除作业的队列名称 |
| `user`              | string | 否       | 调度作业的用户的用户名 |
| `project`           | string | 否       | 调度作业的项目的完整路径 |
| `root_namespace`    | string | 否       | 项目的根命名空间 |
| `subscription_plan` | string | 否       | 根命名空间的订阅计划（仅限 JihuLab.com） |
| `caller_id`         | string | 否       | 调度作业的端点或后台作业（例如：`ProjectsController#create`、`/api/:version/projects/:id`、`PostReceive`） |
| `feature_category`  | string | 否       | 后台作业的功能类别（例如：`team_planning` 或 `code_review`） |
| `worker_class`      | string | 否       | 后台作业工作类的类名（例如：`PostReceive` 或 `MergeWorker`） |

除 `queue_name` 外，至少需要一个其他属性。

示例请求：

```shell
curl --request DELETE \
--header "PRIVATE-TOKEN: <your_access_token>" \
--url "https://gitlab.example.com/api/v4/admin/sidekiq/queues/:queue_name"
```

示例响应：

```json
{
  "completed": true,
  "deleted_jobs": 7,
  "queue_size": 14
}
```