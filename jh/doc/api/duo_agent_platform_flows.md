---
stage: Agent Foundations
group: Agent Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 用于创建、启动和管理极狐GitLab Duo Agent Platform 任务流的 REST API。
title: 任务流 API
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 在 [极狐GitLab Duo Agent Platform](../user/duo_agent_platform/_index.md) 中创建和管理[任务流](../user/duo_agent_platform/flows/_index.md)。
任务流是多个 AI Agent 的组合，它们协同工作以完成开发者任务，例如修复错误、编写代码或解决漏洞。

<a id="trigger-a-flow"></a>

## 触发任务流

{{< details >}}

- Status: 实验

{{< /details >}}

触发并启动一个新的任务流。

```plaintext
POST /ai/duo_workflows/workflows
```

支持的属性：

| 属性 | 类型 | 必填 | 描述 |
|-----------|------|----------|-------------|
| `additional_context` | 对象数组 | 否 | 任务流的附加上下文。每个元素必须是一个对象，至少包含一个 `Category`（字符串）和一个 `Content`（字符串，序列化 JSON）键。 |
| `agent_privileges` | 整数数组 | 否 | 允许 Agent 使用的权限 ID。默认为所有权限。请参阅[列出所有 Agent 权限](#list-all-agent-privileges)。 |
| `ai_catalog_item_consumer_id` | 整数 | 否 | 配置要执行的目录项的 AI 目录项使用方 ID。需要 `project_id`。不能与 `workflow_definition` 一起使用；如果同时提供，则 `ai_catalog_item_consumer_id` 优先。请参阅[查找使用方 ID](#look-up-the-consumer-id)。 |
| `ai_catalog_item_version_id` | 整数 | 否 | 提供任务流配置的 AI 目录项版本 ID。 |
| `allow_agent_to_request_user` | 布尔值 | 否 | 当为 `true`（默认）时，Agent 可以在继续之前暂停并向用户提问。当为 `false` 时，Agent 将运行至完成，无需用户输入。 |
| `environment` | 字符串 | 否 | 执行环境。可选值：`ide`、`web`、`chat_partial`、`chat`、`ambient`。 |
| `goal` | 字符串 | 否 | 要由 Agent 完成的任务描述。示例：`Fix the failing pipeline`。 |
| `image` | 字符串 | 否 | 在 CI 流水线中运行任务流时要使用的容器镜像。必须满足[自定义镜像要求](../user/duo_agent_platform/flows/execution/images.md#use-a-custom-image)。示例：`registry.gitlab.com/gitlab-org/duo-workflow/custom-image:latest`。 |
| `issue_id` | 整数 | 否 | 要与任务流关联的议题的 IID。需要 `project_id`。 |
| `merge_request_id` | 整数 | 否 | 要与任务流关联的合并请求的 IID。需要 `project_id`。 |
| `namespace_id` | 字符串 | 否 | 要与任务流关联的命名空间的 ID 或路径。 |
| `pre_approved_agent_privileges` | 整数数组 | 否 | Agent 无需请求用户批准即可使用的权限 ID。必须是 `agent_privileges` 的子集。 |
| `project_id` | 字符串 | 否 | 要与任务流关联的项目的 ID 或路径。 |
| `source_branch` | 字符串 | 否 | CI 流水线的源分支。默认为项目的默认分支。 |
| `start_workflow` | 布尔值 | 否 | 当为 `true` 时，创建后立即启动任务流。 |
| `workflow_definition` | 字符串 | 否 | 任务流类型标识符。示例：`developer/v1`。不能与 `ai_catalog_item_consumer_id` 一起使用；如果同时提供，则 `ai_catalog_item_consumer_id` 优先。 |
| `source`                        | 字符串 | 否 | 在 UI 中触发会话的位置。 |

如果成功，返回 [`201 Created`](rest/troubleshooting.md#status-codes) 及以下响应
属性：

| 属性 | 类型 | 描述 |
|-----------|------|-------------|
| `agent_privileges` | 整数数组 | 分配给 Agent 的权限 ID。 |
| `agent_privileges_names` | 字符串数组 | 与 `agent_privileges` 对应的名称。 |
| `ai_catalog_item_version_id` | 整数 | AI 目录项版本 ID。如果未设置则为 `null`。 |
| `allow_agent_to_request_user` | 布尔值 | 当为 `true` 时，Agent 可以暂停以等待用户输入。 |
| `environment` | 字符串 | 执行环境。如果未设置则为 `null`。 |
| `gitlab_url` | 字符串 | 极狐GitLab 实例的基础 URL。 |
| `id` | 整数 | 任务流的 ID。 |
| `image` | 字符串 | 用于 CI 流水线执行的容器镜像。如果未设置则为 `null`。 |
| `mcp_enabled` | 布尔值 | 是否为此任务流启用 `MCP`（模型上下文协议）工具。 |
| `namespace_id` | 整数 | 关联命名空间的 ID。如果未设置则为 `null`。 |
| `pre_approved_agent_privileges` | 整数数组 | Agent 无需请求批准即可使用的权限 ID。 |
| `pre_approved_agent_privileges_names` | 字符串数组 | 与 `pre_approved_agent_privileges` 对应的名称。 |
| `project_id` | 整数 | 关联项目的 ID。如果未设置则为 `null`。 |
| `status` | 字符串 | 当前任务流状态。可选值：`created`、`running`、`paused`、`finished`、`failed`、`stopped`、`input_required`、`plan_approval_required` 或 `tool_call_approval_required`。 |
| `summary` | 字符串 | 工作流的简短文本摘要。 |
| `title` | 字符串 | 会话的标题。 |
| `workflow_definition` | 字符串 | 任务流类型标识符。 |
| `workload` | 对象 | 有关工作负载的信息。 |
| `workload.id` | 字符串 | 工作负载的 ID。 |
| `workload.message` | 字符串 | 工作负载的状态消息。 |

如果用户必须先完成[身份验证](../security/identity_verification.md)才能使用
极狐GitLab Duo Agent Platform，则极狐GitLab 返回 [`403 Forbidden`](rest/troubleshooting.md#status-codes) 及
`message`：

```json
{
  "message": "403 Forbidden - Identity verification is required to use GitLab Duo Agent Platform"
}
```

<a id="look-up-the-consumer-id"></a>

### 查找使用方 ID

在您可以使用 `ai_catalog_item_consumer_id` 之前，必须使用 GraphQL API 从 [AI 目录](../user/duo_agent_platform/ai_catalog.md) 检索该 ID。
该项目必须已启用该目录项。

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

`id` 字段是格式为 `gid://gitlab/AiCatalogItemConsumer/<numeric_id>` 的全局 ID。
使用数字后缀作为 `ai_catalog_item_consumer_id` 的值。

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

<a id="register-a-flow-callback-endpoint"></a>

## 注册任务流回调端点

注册一个接收任务流生命周期事件（`flow.started`、`flow.completed` 和 `flow.failed`）的 HTTPS 端点。在[触发任务流](#trigger-a-flow)时，将返回的 `id` 作为 `callback_hook_id` 属性引用，以接收生命周期通知，而不是轮询状态。

URL 和密钥在静态时加密，注册后 API 永远不会返回它们。

先决条件：

- 您必须拥有该组织的所有者角色。

```plaintext
POST /ai/duo_workflows/flow_callbacks
```

支持的属性：

| 属性        | 类型   | 必填 | 描述 |
|------------------|--------|----------|-------------|
| `url`            | 字符串 | 是      | 接收回调的 HTTPS URL。 |
| `name`           | 字符串 | 否       | 此端点的标签。 |
| `signing_token`  | 字符串 | 否       | `HMAC` 签名密钥，格式为 `whsec_<base64-of-32-bytes>`，用于计算 `webhook-signature` 标头，以便您验证负载。不返回。 |
| `token`          | 字符串 | 否       | 作为 `X-Gitlab-Token` 标头原样发送的共享密钥。不返回。 |

如果成功，返回 [`201 Created`](rest/troubleshooting.md#status-codes) 及以下响应
属性：

| 属性            | 类型    | 描述 |
|----------------------|---------|-------------|
| `created_at`         | 字符串  | 端点注册的日期和时间。 |
| `id`                 | 整数 | 任务流回调端点的 ID。 |
| `name`               | 字符串  | 此端点的标签。 |
| `signing_token_set`  | 布尔值 | 是否设置了 `signing_token`。 |
| `token_set`          | 布尔值 | 是否设置了 `token`。 |
| `url`                | 字符串  | 接收回调的 HTTPS URL。 |

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --header "Content-Type: application/json" \
  --data '{
    "url": "https://autoflow.example.com/duo/callbacks",
    "name": "AutoFlow",
    "signing_token": "whsec_<base64_encoded_32_byte_secret>"
  }' \
  --url "https://gitlab.example.com/api/v4/ai/duo_workflows/flow_callbacks"
```

示例响应：

```json
{
  "id": 1,
  "url": "https://autoflow.example.com/duo/callbacks",
  "name": "AutoFlow",
  "signing_token_set": true,
  "token_set": false,
  "created_at": "2026-07-22T11:37:00.000Z"
}
```

<a id="list-flow-callback-endpoints"></a>

## 列出任务流回调端点

列出为您的组织注册的任务流回调端点。不返回密钥。

先决条件：

- 您必须拥有该组织的所有者角色。

```plaintext
GET /ai/duo_workflows/flow_callbacks
```

使用 `page` 和 `per_page` [分页](rest/_index.md#offset-based-pagination)参数来控制结果的分页。

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 及一个
[任务流回调端点](#register-a-flow-callback-endpoint)对象数组。

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/ai/duo_workflows/flow_callbacks"
```

<a id="get-a-flow-callback-endpoint"></a>

## 获取任务流回调端点

返回单个已注册的任务流回调端点。不返回密钥。

先决条件：

- 您必须拥有该组织的所有者角色。

```plaintext
GET /ai/duo_workflows/flow_callbacks/:id
```

支持的属性：

| 属性 | 类型    | 必填 | 描述 |
|-----------|---------|----------|-------------|
| `id`      | 整数 | 是      | 任务流回调端点的 ID。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 及一个
[任务流回调端点](#register-a-flow-callback-endpoint)对象。

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/ai/duo_workflows/flow_callbacks/1"
```

<a id="delete-a-flow-callback-endpoint"></a>

## 删除任务流回调端点

删除已注册的任务流回调端点，使其不再接收投递。

先决条件：

- 您必须拥有该组织的所有者角色。

```plaintext
DELETE /ai/duo_workflows/flow_callbacks/:id
```

支持的属性：

| 属性 | 类型    | 必填 | 描述 |
|-----------|---------|----------|-------------|
| `id`      | 整数 | 是      | 任务流回调端点的 ID。 |

如果成功，返回 [`204 No Content`](rest/troubleshooting.md#status-codes)。

示例请求：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/ai/duo_workflows/flow_callbacks/1"
```

<a id="get-workflow-trace-as-jsonl"></a>

## 以 JSONL 格式获取工作流跟踪

{{< details >}}

- Status: 实验

{{< /details >}}

以 [JSON Lines](https://jsonlines.org/)（JSONL）格式返回工作流会话的 `ui_chat_log` 条目。
每行是一个有效的 JSON 对象，代表 `ui_chat_log` 数组中的一个条目。使用此端点将跟踪解析或通过管道传输到诸如 `jq` 之类的工具中。

默认情况下，该端点返回会话所有线程中的完整对话，包括任何上下文压缩之前的消息。改用 `thread` 属性以仅返回单个线程。

```plaintext
GET /ai/duo_workflows/workflows/:workflow_id/trace.jsonl
```

支持的属性：

| 属性 | 类型 | 必填 | 描述 |
|-----------|------|----------|-------------|
| `workflow_id` | 整数 | 是      | 工作流的 ID。 |
| `thread` | 字符串 | 否       | 要返回的线程。省略以获取所有线程的完整跟踪。使用 `latest` 仅获取最近的线程，或使用线程 ID 获取特定线程。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 及：

- **Content-Type**：`application/x-ndjson`
- **Body**：每行一个 JSON 对象，每个对象代表一个 `ui_chat_log` 条目。
  如果工作流没有检查点或没有 `ui_chat_log` 条目，则返回空主体。

如果用户必须先完成[身份验证](../security/identity_verification.md)才能使用
极狐GitLab Duo Agent Platform，则极狐GitLab 返回 [`403 Forbidden`](rest/troubleshooting.md#status-codes) 及
`message`：

```json
{
  "message": "403 Forbidden - Identity verification is required to use GitLab Duo Agent Platform"
}
```

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/ai/duo_workflows/workflows/1/trace.jsonl"
```

示例响应（每行是一个单独的 JSON 对象）：

```jsonl
{"status":"success","content":"Analyze the issue","message_type":"human"}
{"status":"success","content":"I'll start by reading the codebase.","message_type":"ai"}
```

您可以将输出通过管道传输到 `jq` 中，以按类型过滤条目：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
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

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 及以下响应
属性：

| 属性 | 类型 | 描述 |
|-----------|------|-------------|
| `all_privileges` | 对象数组 | 所有可用的 Agent 权限。 |
| `all_privileges[].default_enabled` | 布尔值 | 该权限是否默认启用。 |
| `all_privileges[].description` | 字符串 | 该权限所允许内容的人类可读描述。 |
| `all_privileges[].id` | 整数 | 权限 ID。 |
| `all_privileges[].name` | 字符串 | 机器可读的权限名称。 |

示例请求：

```shell
curl --header "PRIVATE-TOKEN: <your_access_token>" \
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
