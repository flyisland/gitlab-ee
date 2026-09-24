---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Sidekiq 指标 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

此 API 端点允许您检索有关 Sidekiq、其作业、队列和进程的当前状态的一些信息。

<a id="list-all-job-queue-metrics"></a>

## 列出所有作业队列指标

列出所有 Sidekiq 作业队列的详细信息，包括积压大小和延迟。

```plaintext
GET /sidekiq/queue_metrics
```

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/sidekiq/queue_metrics"
```

示例响应：

```json
{
  "queues": {
    "default": {
      "backlog": 0,
      "latency": 0
    }
  }
}
```

<a id="list-all-sidekiq-processes"></a>

## 列出所有 Sidekiq 进程

列出所有已注册的 Sidekiq 工作进程的详细信息，包括主机名、进程 ID、队列和并发设置。

```plaintext
GET /sidekiq/process_metrics
```

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/sidekiq/process_metrics"
```

示例响应：

```json
{
  "processes": [
    {
      "hostname": "gitlab.example.com",
      "pid": 5649,
      "tag": "gitlab",
      "started_at": "2016-06-14T10:45:07.159-05:00",
      "queues": [
        "post_receive",
        "mailers",
        "archive_repo",
        "system_hook",
        "project_web_hook",
        "gitlab_shell",
        "incoming_email",
        "runner",
        "common",
        "default"
      ],
      "labels": [],
      "concurrency": 25,
      "busy": 0
    }
  ]
}
```

<a id="retrieve-job-completion-metrics"></a>

## 检索作业完成指标

检索所有 Sidekiq 作业完成状态的统计信息。

```plaintext
GET /sidekiq/job_stats
```

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/sidekiq/job_stats"
```

示例响应：

```json
{
  "jobs": {
    "processed": 2,
    "failed": 0,
    "enqueued": 0,
    "dead": 0
  }
}
```

<a id="list-all-sidekiq-metrics"></a>

## 列出所有 Sidekiq 指标

在单个响应中列出所有 Sidekiq 指标，包括队列、进程和作业完成指标。

```plaintext
GET /sidekiq/compound_metrics
```

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/sidekiq/compound_metrics"
```

示例响应：

```json
{
  "queues": {
    "default": {
      "backlog": 0,
      "latency": 0
    }
  },
  "processes": [
    {
      "hostname": "gitlab.example.com",
      "pid": 5649,
      "tag": "gitlab",
      "started_at": "2016-06-14T10:45:07.159-05:00",
      "queues": [
        "post_receive",
        "mailers",
        "archive_repo",
        "system_hook",
        "project_web_hook",
        "gitlab_shell",
        "incoming_email",
        "runner",
        "common",
        "default"
      ],
      "labels": [],
      "concurrency": 25,
      "busy": 0
    }
  ],
  "jobs": {
    "processed": 2,
    "failed": 0,
    "enqueued": 0,
    "dead": 0
  }
}
```