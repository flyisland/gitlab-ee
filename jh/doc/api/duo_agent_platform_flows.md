---
stage: Agent Foundations
group: Agent Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 用于创建、启动和管理极狐GitLab Duo Agent Platform 任务流的 REST API。
title: Flows API
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 在
[极狐GitLab Duo Agent Platform](../user/duo_agent_platform/_index.md)中创建和管理[任务流](../user/duo_agent_platform/flows/_index.md)。
任务流是协同完成开发者任务（例如修复缺陷、编写代码或解决漏洞）的 AI Agent 组合。

<a id="trigger-a-flow"></a>

## 触发任务流

> [!flag]
> 对复合身份服务账号的要求由功能标志控制。
> `callback_hook_id` 和 `client_reference` 属性的可用性由
> 单独的功能标志控制。

触发并启动一个新任务流。

先决条件：

- 如果 `enforce_composite_identity_for_api_started_workflows` 功能标志已启用，且 `start_workflow` 为 `true`，
  则该任务流必须具有[复合身份](../user/duo_agent_platform/composite_identity.md)服务账号。
  该服务账号要么是在 AI 目录中为该任务流配置的，要么是请求的复合身份背后的服务账号。
  否则，极狐GitLab 会返回 `403 Forbidden` 并且不会启动该任务流。

```plaintext
POST /ai/duo_workflows/workflows
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|-----------|------|----------|-------------|
| `additional_context` | array of objects | 否 | 任务流的附加上下文。每个元素必须是一个对象，至少包含 `Category`（字符串）和 `Content`（字符串，序列化 JSON）键。 |
| `agent_privileges` | integer array | 否 | 允许 Agent 使用的权限 ID。默认为所有权限。请参阅[列出所有 Agent 权限](#list-all-agent-privileges)。 |
| `ai_catalog_item_consumer_id` | integer | 否 | AI 目录条目使用者的 ID，用于配置要执行哪个目录条目。需要 `project_id`。不能与 `workflow_definition` 一起使用；如果同时提供两者，`ai_catalog_item_consumer_id` 优先。请参阅[查找使用者 ID](#look-up-the-consumer-id)。 |
| `ai_catalog_item_version_id` | integer | 否 | 提供该任务流配置的 AI 目录条目版本 ID。 |
| `allow_agent_to_request_user` | boolean | 否 | 当为 `true`（默认值）时，Agent 可以暂停以在继续之前向用户提问。当为 `false` 时，Agent 会在没有用户输入的情况下运行至完成。 |
| `callback_hook_id` | integer | 否 | 已开启 [极狐GitLab Duo 任务流 webhook 回调](../user/duo_agent_platform/flows/webhook_callbacks.md)的 webhook 的 ID。极狐GitLab 会将任务流生命周期事件发送到该 webhook，因此您无需轮询任务流状态。该 webhook 必须属于任务流运行所在的项目或命名空间，或属于其某个上级群组。此属性为[实验](../policy/development_stages_support.md)。 |
| `client_reference` | string | 否 | 在每个回调负载中回传的不透明字符串，用于将回调与触发该任务流的请求关联起来。最多 255 个字符。没有 `callback_hook_id` 时无效。此属性为[实验](../policy/development_stages_support.md)。 |
| `environment` | string | 否 | 执行环境。以下之一：`ide`、`web`、`chat_partial`、`chat`、`ambient`。 |
| `goal` | string | 否 | 供 Agent 完成的任务描述。示例：`Fix the failing pipeline`。 |
| `image` | string | 否 | 用于该任务流的容器镜像。仅当任务流在 CI 流水线中运行时适用。必须满足[自定义镜像要求](../user/duo_agent_platform/flows/execution/images.md#use-a-custom-image)。示例：`registry.gitlab.com/gitlab-org/duo-workflow/custom-image:latest`。 |
| `issue_id` | integer | 否 | 要与该任务流关联的议题的 IID。需要 `project_id`。 |
| `merge_request_id` | integer | 否 | 要与该任务流关联的合并请求的 IID。需要 `project_id`。 |
| `namespace_id` | string | 否 | 要与该任务流关联的命名空间的 ID 或路径。 |
| `pre_approved_agent_privileges` | integer array | 否 | Agent 无需请求用户批准即可使用的权限 ID。必须是 `agent_privileges`的子集。 |
| `project_id` | string | 否 | 要与该任务流关联的项目的 ID 或路径。 |
| `source` | string | 否 | 会话的触发来源。可以是某个极狐GitLab 功能入口点（例如 `merge_request_code_conflict`），也可以是创建该会话的客户端界面（`duo_cli_interactive`、`duo_cli_run`、`duo_cli_acp`、`ide_extension`）。会持久化为会话的 `source_type`。 |
| `source_branch` | string | 否 | 该任务流的源分支。仅当任务流在 CI 流水线中运行时适用。未指定时，目标为流水线或合并请求的任务流（例如 `fix_pipeline/v1` 或 `code_review/v1`）会在该流水线或合并请求的分支上运行。对于 `fix_pipeline/v1`，`additional_context`中的 `merge_request` 和 `pipeline` 条目也会从该流水线中填充。其他任务流会在项目的默认分支上运行。 |
| `start_workflow` | boolean | 否 | 当为 `true` 时，在创建后立即启动该任务流。 |
| `workflow_definition` | string | 否 | 任务流类型标识符。示例：`developer/v1`。不能与 `ai_catalog_item_consumer_id` 一起使用；如果同时提供两者，`ai_catalog_item_consumer_id` 优先。 |

如果成功，返回 [`201 Created`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性 | 类型 | 描述 |
|-----------|------|-------------|
| `agent_privileges` | integer array | 分配给 Agent 的权限 ID。 |
| `agent_privileges_names` | string array | 与 `agent_privileges` 对应的名称。 |
| `ai_catalog_item_version_id` | integer | AI 目录条目版本的 ID。如果未设置则为 `null`。 |
| `allow_agent_to_request_user` | boolean | 当为 `true` 时，Agent 可以暂停以等待用户输入。 |
| `environment` | string | 执行环境。如果未设置则为 `null`。 |
| `gitlab_url` | string | 极狐GitLab 实例的基础 URL。 |
| `id` | integer | 任务流的 ID。 |
| `image` | string | 用于 CI 流水线执行的容器镜像。如果未设置则为 `null`。 |
| `mcp_enabled` | boolean | 是否为该任务流启用 `MCP`（模型上下文协议）工具。 |
| `namespace_id` | integer | 关联命名空间的 ID。如果未设置则为 `null`。 |
| `pre_approved_agent_privileges` | integer array | Agent 无需请求批准即可使用的权限 ID。 |
| `pre_approved_agent_privileges_names` | string array | 与 `pre_approved_agent_privileges` 对应的名称。 |
| `project_id` | integer | 关联项目的 ID。如果未设置则为 `null`。 |
| `status` | string | 当前任务流状态。以下之一：`created`、`running`、`paused`、`finished`、`failed`、`stopped`、`input_required`、`plan_approval_required` 或 `tool_call_approval_required`。极狐GitLab 可能会添加新值。 |
| `summary` | string | 工作流的简短文本摘要。 |
| `title` | string | 会话的标题。 |
| `web_url` | string | 会话在极狐GitLab UI 中的 URL。如果该会话不属于某个项目则为 `null`。 |
| `workflow_definition` | string | 任务流类型标识符。 |
| `workload` | object | 有关工作负载的信息。 |
| `workload.id` | integer | 工作负载的 ID。如果未创建工作负载（例如当 `start_workflow` 不为 `true` 时）则为 `null`。 |
| `workload.message` | string | 工作负载的状态消息。如果未创建工作负载则为 `null`。 |

如果用户必须先完成[身份验证](../security/identity_verification.md)才能使用
极狐GitLab Duo Agent Platform，极狐GitLab 会返回 [`403 Forbidden`](rest/troubleshooting.md#status-codes) 以及
`message`：

```json
{
  "message": "403 Forbidden - Identity verification is required to use GitLab Duo Agent Platform"
}
```

当设置了 `callback_hook_id` 且满足以下任一条件时，极狐GitLab 会返回
[`400 Bad request`](rest/troubleshooting.md#status-codes)：

- 任务流运行所在项目或命名空间的顶级群组未启用 `duo_flow_callback_hooks` 功能标志。
- 该 ID 未引用任务流运行所在项目或命名空间（或其某个上级群组）中已开启极狐GitLab Duo 任务流回调的 webhook。

<a id="look-up-the-consumer-id"></a>

### 查找使用者 ID

在使用 `ai_catalog_item_consumer_id` 之前，您必须使用 GraphQL API 从 [AI 目录](../user/duo_agent_platform/ai_catalog.md)中检索该 ID。该条目必须已为该项目启用。

```graphql
query {
  aiCatalogConfiguredItems(projectId: "gid://gitlab/Project/<project_id>") {
    nodes {
      id
      item { name }
    }
  }
}
```

`id` 字段是格式为 `gid://gitlab/AiCatalogItemConsumer/<numeric_id>` 的全局 ID。请使用其中的数字后缀作为 `ai_catalog_item_consumer_id`的值。

使用内置任务流类型的示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --data '{
    "project_id": "5",
    "goal": "Fix the failing pipeline by correcting the syntax error in .gitlab-ci.yml",
    "workflow_definition": "developer/v1",
    "start_workflow": true
  }' \
  --url "https://gitlab.example.com/api/v4/ai/duo_workflows/workflows"
```

使用目录配置的任务流的示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --data '{
    "project_id": "5",
    "goal": "Fix the failing pipeline by correcting the syntax error in .gitlab-ci.yml",
    "ai_catalog_item_consumer_id": 12,
    "start_workflow": true
  }' \
  --url "https://gitlab.example.com/api/v4/ai/duo_workflows/workflows"
```

示例响应：

```json
{
  "id": 1,
  "web_url": "https://gitlab.example.com/group/project/-/automate/agent-sessions/1",
  "project_id": 5,
  "namespace_id": null,
  "agent_privileges": [1, 2, 3, 4, 5, 6],
  "agent_privileges_names": [
    "read_write_files",
    "read_only_gitlab",
    "read_write_gitlab",
    "run_commands",
    "use_git",
    "run_mcp_tools"
  ],
  "pre_approved_agent_privileges": [],
  "pre_approved_agent_privileges_names": [],
  "workflow_definition": "developer/v1",
  "status": "running",
  "allow_agent_to_request_user": true,
  "image": null,
  "environment": null,
  "ai_catalog_item_version_id": null,
  "workload": {
    "id": "abc-123",
    "message": "Workflow started"
  },
  "mcp_enabled": false,
  "gitlab_url": "https://gitlab.example.com"
}
```

<a id="restart-a-flow"></a>

## 重新启动任务流

{{< details >}}

- Status: 实验

{{< /details >}}

通过使用相同的任务流参数启动一个新任务流，重新启动失败或已停止的任务流。新任务流会从头开始运行。原任务流不会被修改，并保持其 `failed` 或 `stopped` 状态。

只有状态为 `failed` 或 `stopped`的项目级任务流才能重新启动。重新启动任何其他状态的任务流或群组级任务流会返回 `403 Forbidden`。在重新启动仍在进行时再次重新启动同一任务流会返回 `409 Conflict`。

```plaintext
POST /ai/duo_workflows/workflows/:workflow_id/restart
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|-----------|------|----------|-------------|
| `workflow_id` | integer | 是 | 要重新启动的任务流的 ID。 |

如果成功，返回 [`201 Created`](rest/troubleshooting.md#status-codes) 以及与[触发任务流](#trigger-a-flow)相同的响应属性。该响应描述的是新任务流，因此 `id` 是新任务流的 ID，而不是您重新启动的那个任务流的 ID。

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/ai/duo_workflows/workflows/42/restart"
```

<a id="get-workflow-trace-as-jsonl"></a>

## 以 JSONL 格式获取工作流跟踪

{{< details >}}

- Status: 实验

{{< /details >}}

以 [JSON Lines](https://jsonlines.org/)（JSONL）格式返回工作流会话的
`ui_chat_log` 条目。每一行都是一个有效的 JSON 对象，表示 `ui_chat_log` 数组中的一个条目。使用此端点可将跟踪解析或通过管道传递给 `jq` 等工具。

默认情况下，该端点返回会话所有讨论串中的完整对话，包括任何上下文压缩之前的消息。使用 `thread` 属性可仅返回单个讨论串。

```plaintext
GET /ai/duo_workflows/workflows/:workflow_id/trace.jsonl
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
|-----------|------|----------|-------------|
| `workflow_id` | integer | 是 | 工作流的 ID。 |
| `thread` | string | 否 | 要返回哪个讨论串。省略则返回所有讨论串的完整跟踪。使用 `latest` 仅返回最近的讨论串，或使用讨论串 ID 返回特定讨论串。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及：

- **Content-Type**：`application/x-ndjson`
- **Body**：每行一个 JSON 对象，每个对象表示一个 `ui_chat_log` 条目。
  如果工作流没有检查点或没有 `ui_chat_log` 条目，则返回空正文。

如果用户必须先完成[身份验证](../security/identity_verification.md)才能使用
极狐GitLab Duo Agent Platform，极狐GitLab 会返回 [`403 Forbidden`](rest/troubleshooting.md#status-codes) 以及
`message`：

```json
{
  "message": "403 Forbidden - Identity verification is required to use GitLab Duo Agent Platform"
}
```

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/ai/duo_workflows/workflows/1/trace.jsonl"
```

示例响应（每行都是一个单独的 JSON 对象）：

```jsonl
{"status":"success","content":"Analyze the issue","message_type":"human"}
{"status":"success","content":"I'll start by reading the codebase.","message_type":"ai"}
```

您可以将输出通过管道传递给 `jq`，以按类型筛选条目：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/ai/duo_workflows/workflows/1/trace.jsonl" \
  | jq 'select(.message_type == "ai")'
```

<a id="list-all-agent-privileges"></a>

## 列出所有 Agent 权限

列出所有可用的 Agent 权限及其 ID、名称、描述，以及每个权限是否默认启用。

```plaintext
GET /ai/duo_workflows/workflows/agent_privileges
```

此端点没有支持的属性。

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性 | 类型 | 描述 |
|-----------|------|-------------|
| `all_privileges` | array of objects | 所有可用的 Agent 权限。 |
| `all_privileges[].default_enabled` | boolean | 该权限是否默认启用。 |
| `all_privileges[].description` | string | 该权限所允许操作的人类可读描述。 |
| `all_privileges[].id` | integer | 权限 ID。 |
| `all_privileges[].name` | string | 机器可读的权限名称。 |

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/ai/duo_workflows/workflows/agent_privileges"
```

示例响应：

```json
{
  "all_privileges": [
    {
      "id": 1,
      "name": "read_write_files",
      "description": "Allow local filesystem read/write access",
      "default_enabled": true
    },
    {
      "id": 2,
      "name": "read_only_gitlab",
      "description": "Allow read only access to GitLab APIs",
      "default_enabled": true
    },
    {
      "id": 3,
      "name": "read_write_gitlab",
      "description": "Allow write access to GitLab APIs",
      "default_enabled": true
    },
    {
      "id": 4,
      "name": "run_commands",
      "description": "Allow running any commands",
      "default_enabled": true
    },
    {
      "id": 5,
      "name": "use_git",
      "description": "Allow git commits, push and other git commands",
      "default_enabled": true
    },
    {
      "id": 6,
      "name": "run_mcp_tools",
      "description": "Allow running MCP tools",
      "default_enabled": true
    }
  ]
}
```
