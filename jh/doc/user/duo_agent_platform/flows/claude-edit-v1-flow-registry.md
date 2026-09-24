---
stage: AI-powered features
group: Workflow Catalog
title: Flow Registry Framework v1
ignore_in_report: true
---

{{< details >}}

- Tier: [基础版](../../../subscriptions/gitlab_credits.md#for-the-free-tier)，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Status: 测试版

{{< /details >}}

使用 Flow Registry Framework v1，您可以在单个 YAML 文件中定义组件、工具和路由逻辑，从而在极狐GitLab Duo Agent Platform 上构建自定义 AI 驱动的工作流。

<a id="yaml-configuration-structure"></a>

## YAML 配置结构

每个任务流都是一个单独的 YAML 文件。顶层结构如下：

```yaml
version: "v1"
environment: ambient

components:
  # List of components (see Component types)

routers:
  # Routing rules between components (see Routers)

flow:
  entry_point: "component_name"   # First component to run

prompts:                           # Optional - inline prompt definitions
  # Locally defined prompts (see Prompts)
```

<a id="required-fields"></a>

### 必填字段

| 字段 | 描述 |
|---|---|
| `version` | 始终为 `"v1"` |
| `environment` | 任务流交互风格 - 参见 [环境](#environment) |
| `components` | 组成任务流的组件列表 - 参见 [组件类型](#component-types)|
| `routers` | 组件之间的路由规则 - 参见 [路由器](#routers) |
| `flow` | 入口点和可选的上下文输入 - 参见 [`flow` 部分](#flow-section) |

<a id="optional-fields"></a>

### 可选字段

| 字段 | 描述 |
|---|---|
| `name` | 人类可读的任务流名称 |
| `description` | 任务流的描述 |
| `product_group` | 团队归属（例如 `agent_foundations`） |
| `prompts` | 内联提示词定义 - 参见 [本地定义的提示词](#locally-defined-prompts) |
| `response_schemas` | 内联响应模式定义 - 参见 [响应模式](#response-schemas) |

<a id="environment"></a>

### 环境

`environment` 字段声明预期的人机交互级别。

| 值 | 描述 |
|---|---|
| `ambient` | 无需干预的后台执行。人类委派任务，Agent 自主运行。尽量减少人类参与。大多数自定义任务流使用此模式。 |
| `chat` | 通过类似聊天界面进行交互式来回对话。 |
| `chat-partial` | 用于单 Agent 任务流的简化 `chat` 变体。跳过样板代码。要求恰好一个 `AgentComponent`。 |

<a id="quick-start"></a>

## 快速开始

要调用任务流，请在 `StartWorkflowRequest` 中传入您的任务流配置：

```plaintext
flowConfigId: "<your_flow_id>"
flowConfigSchemaVersion: "v1"
flowVersion: "1.0.0"
```

本页其余部分记录了任务流配置的 YAML 结构。有关在代码库中注册新的内置任务流的说明，请参阅[内置任务流开发者指南](foundational_flows/developer.md)。

<a id="session-context-variables"></a>

## 会话上下文变量

每个组件的 `inputs` 块都使用 `from: "context:<key>"` 从会话上下文中获取值。框架会自动填充一组始终可用的变量。您无需声明这些变量，但必须在每个组件的 `inputs` 块中显式引用它们。

<a id="always-available-variables"></a>

### 始终可用的变量

| 变量 | 类型 | 描述 |
|---|---|---|
| `context:goal` | string | 触发工作流的用户目标或消息 |
| `context:project_id` | string | 极狐GitLab 项目 ID（数字，以字符串形式表示） |
| `context:project_http_url_to_repo` | string | 代码仓库的完整 HTTPS 克隆 URL |

> [!note]
> `context:project_id` 不会自动注入到提示词模板中。
> 如果您的 Agent 调用任何极狐GitLab API 工具（例如 `get_merge_request`、`list_issues`
> 或 `create_merge_request`），您必须将其添加到组件的 `inputs`
> 中，并在提示词的 `user:` 块中包含 `Project ID: {{ project_id }}`。遗漏
> 这一点是任务流失败的最常见原因。

<a id="agent-platform-standard-context-variables"></a>

### Agent Platform 标准上下文变量

这些变量仅在您声明 `flow.inputs` 节时可用。它们携带由 CI Runner 注入的分支和会话元数据。

| 变量 | 类型 | 描述 |
|---|---|---|
| `context:inputs.agent_platform_standard_context.primary_branch` | string | 代码仓库的默认分支（例如 `main`） |
| `context:inputs.agent_platform_standard_context.workload_branch` | string | CI 工作负载 Runner 使用的 Git 引用 |
| `context:inputs.agent_platform_standard_context.session_owner_id` | string | 触发任务流的用户的极狐GitLab 用户 ID |

当您的任务流创建分支、打开合并请求或需要知道默认分支时，请声明这些变量。有关更多信息，请参阅 [`flow` 部分](#flow-section)。

<a id="flow-section"></a>

## `flow` 部分

`flow` 部分定义入口点，以及可选地定义要注入哪些外部上下文类别。

<a id="minimal"></a>

### 最小配置

```yaml
flow:
  entry_point: "my_first_component"
```

<a id="with-agent-platform-standard-context"></a>

### 使用 Agent Platform 标准上下文

当您的任务流需要 `primary_branch`、`workload_branch` 或 `session_owner_id` 时必需：

```yaml
flow:
  entry_point: "create_feature_branch"
  inputs:
    - category: agent_platform_standard_context
      input_schema:
        primary_branch:
          type: string
          description: The default/primary branch of the repository (for example, 'main', 'master')
        workload_branch:
          type: string
          description: git ref to workload branch
        session_owner_id:
          type: string
          description: Human user's ID that initiated the flow
```

<a id="component-types"></a>

## 组件类型

| 组件 | 用途 | 是否涉及 AI | 何时使用 |
|---|---|:---:|---|
| [AgentComponent](#agentcomponent) | 使用工具进行多轮 AI 推理 | 是 | 需要迭代决策、对话或多步骤工具使用的复杂任务。 |
| [OneOffComponent](#oneoffcomponent) | 单轮 AI 工具执行 | 是 | 可在一次 LLM 调用中完成且具有内置重试逻辑的有界任务。 |
| [DeterministicStepComponent](#deterministicstepcomponent) | 使用固定参数执行单个工具 | 否 | 工具参数直接来自状态的可预测、可重复操作。 |
| [HumanInputComponent](#humaninputcomponent) | 请求并处理用户输入 | 否 | 审批关卡、交互式聊天或任何需要人工反馈的环节。 |
| [EndComponent / AbortComponent](#endcomponent-and-abortcomponent) | 终止工作流 | 否 | 每个任务流都必须以 `"end"`（成功）或 `"abort"`（错误）终止。 |

<a id="agentcomponent"></a>

## AgentComponent

AgentComponent 是 AI 驱动任务流的主要构建块。它使用 LLM 来：

- 处理输入。
- 根据提示词做出决策。
- 调用工具。
- 维护对话历史。
- 为下游组件生成输出。

<a id="required-parameters"></a>

### 必填参数

| 参数 | 描述 |
|---|---|
| `name` | 唯一标识符。不得包含 `:` 或 `.` 字符。 |
| `type` | 必须为 `"AgentComponent"`。 |
| `prompt_id` | 提示词模板的 ID（本地或基于注册表的）。 |

<a id="optional-parameters"></a>

### 可选参数

| 参数 | 默认值 | 描述 |
|---|---|---|
| `prompt_version` | 省略 | Semver 约束（例如 `"^1.0.0"`）。省略则使用本地定义的提示词。 |
| `inputs` | `["context:goal"]` | 输入数据源列表。 |
| `toolset` | `[]` | Agent 可用的工具。参见 [可用工具](#available-tools)。 |
| `description` | 无 | 在监督者下用作子 Agent 时必需。 |
| `subagents` | 无 | 子 Agent 名称列表。启用 [监督者模式](#supervisor-mode)。 |
| `max_delegations` | 无限制 | 监督者模式下 `delegate_task` 调用的最大次数。 |
| `response_schema_id` | 无 | 结构化输出模式的 ID。 |
| `response_schema_version` | 无 | 基于注册表的模式的 Semver。 |
| `model_size_preference` | `null` | `"small"` 或 `"large"`。 |
| `require_tool_approval` | `false` | 在每次工具调用前暂停以等待人工审批。 |
| `pre_approved_tools` | `[]` | 跳过审批步骤的工具。 |
| `compaction` | 无 | 对话压缩配置。 |
| `ui_log_events` | `[]` | 在 UI 中展示的事件。参见 [UI 日志事件](#agentcomponent-ui-log-events)。 |
| `ui_role_as` | `"agent"` | 在 UI 中的显示角色（`"agent"` 或 `"tool"`）。 |

<a id="outputs"></a>

### 输出

| 输出键 | 描述 |
|---|---|
| `context:{name}.final_answer` | Agent 的最终响应（字符串，或带有自定义模式的字典）。 |
| `context:{name}.final_answer.{field}` | 使用自定义响应模式时的单个字段。 |
| `conversation_history:{name}` | 完整的消息历史。 |

<a id="inputs"></a>

### 输入

组件输入从会话上下文中获取值，并将其作为提示词中的模板变量提供。`as:` 别名必须与提示词模板中的 `{{ variable }}` 占位符完全匹配。

```yaml
# In the component inputs:
inputs:
  - from: "context:goal"
    as: "goal"
  - from: "context:project_id"
    as: "project_id"
  - from: "context:previous_agent.final_answer"
    as: "previous_result"
  - from: "some constant value"
    as: "my_constant"
    literal: true

# In the prompt user block:
user: |
  Project ID: {{ project_id }}
  Goal: {{ goal }}
  Previous result: {{ previous_result }}
```

<a id="prompts"></a>

### 提示词

每个 AgentComponent 都需要一个提示词。您可以在任务流 YAML 中内联定义（推荐用于自定义任务流），或从 AI 网关提示词注册表中引用一个。

<a id="locally-defined-prompts"></a>

#### 本地定义的提示词

省略 `prompt_version` 以使用在顶层 `prompts` 块中定义的内联提示词：

```yaml
components:
  - name: "my_agent"
    type: AgentComponent
    prompt_id: "my_prompt"
    # prompt_version omitted - uses local prompt

prompts:
  - prompt_id: "my_prompt"
    name: "My Prompt"
    unit_primitives: []           # always include, even if empty
    prompt_template:
      system: |
        You are a helpful assistant.

        When your task is complete, your final answer is a plain text summary
        of what you did. No further steps are needed after that.
      user: |
        Project ID: {{ project_id }}
        Goal: {{ goal }}
      placeholder: history        # include explicitly
    params:
      timeout: 180
```

<a id="registry-prompts"></a>

#### 注册表提示词

指定 `prompt_version` 以从 AI 网关提示词注册表的 `ai_gateway/prompts/definitions/` 加载：

```yaml
components:
  - name: "my_agent"
    type: AgentComponent
    prompt_id: "my_flow/my_prompt"
    prompt_version: "^1.0.0"
```

<a id="prompt-writing-best-practices"></a>

#### 提示词编写最佳实践

- 始终告诉 Agent 何时完成。没有明确的停止指令，Agent 会循环执行。在每个 `system:` 提示词末尾加上类似这样的句子：`"When [condition], your final answer is [what to say]. No further steps are needed after that."`
- 对于任何调用极狐GitLab API 工具的 Agent，始终在 `user:` 块中传递 `project_id`。Agent 无法自行发现它。
- 变量名必须完全匹配。`inputs` 中的 `as:` 别名必须与提示词模板中的 `{{ variable }}` 占位符匹配。
- 始终在内联提示词上包含 `unit_primitives: []`，即使为空。
- 始终在内联提示词模板中包含 `placeholder: history`。

<a id="available-tools"></a>

### 可用工具

通过在 `toolset` 中传入工具的 snake_case 名称来配置工具。完整列表位于 `duo_workflow_service/components/tools_registry.py`。常见示例：

- 文件操作：`read_file`、`create_file_with_contents`、`edit_file`、`list_dir`、`find_files`、`grep`
- Git 操作：`run_command`、`create_merge_request`、`create_branch`
- 极狐GitLab API：`get_issue`、`list_issues`、`get_merge_request`、`gitlab_merge_request_search`、`get_work_item`、`get_repository_file`、`list_repository_tree`、`create_issue_note`、`create_merge_request_note`、`create_commit`、`gitlab_api_get`、`get_project`

<a id="tool-options"></a>

### 工具选项

在组件级别覆盖工具的参数，使 LLM 无法更改它们：

```yaml
toolset:
  - "get_merge_request"                    # simple string - no overrides
  - "create_merge_request_note":           # object form - override a parameter
      "internal": true
```

选项在初始化时根据工具的 Pydantic 输入模式进行验证。如果选项键与有效参数不匹配，则会引发 `ValueError`。在执行时，工具选项优先于 LLM 提供的值。

<a id="agentcomponent-ui-log-events"></a>

### AgentComponent UI 日志事件

| 事件 | 描述 |
|---|---|
| `on_agent_final_answer` | Agent 调用其最终响应。这使会话 UI 和 CI 日志中能够显示完整的最终答案。如果输出包含敏感数据，请禁用。 |
| `on_tool_execution_success` | 工具调用成功完成。 |
| `on_tool_execution_failed` | 工具调用失败。 |
| `on_tool_approval_request` | 工具审批等待用户决定。必须包含此事件才能在 UI 中显示审批请求。 |

<a id="tool-approval"></a>

### 工具审批

当 `require_tool_approval: true` 时，工作流在 Agent 生成工具调用后暂停，并等待用户决定后再继续。

支持以下决策类型：

| 决策 | 行为 |
|---|---|
| `APPROVE` | 工具正常执行。 |
| `REJECT` | 拒绝消息添加到历史记录中；Agent 尝试替代方法。 |
| `MODIFY` | 拒绝以及用户反馈添加到历史记录中；Agent 相应调整。 |

如果工具出现在以下任一位置，则该工具已预先批准并跳过审批步骤：

- 组件级别：在组件的 `pre_approved_tools` 参数中列出。由任务流作者在 YAML 中控制。
- 工作流级别：通过工作流 `startRequest` 中的 `pre_approved_agent_privileges` 指定。由工作流调用者在调用时控制。

如果所有工具调用都从任一来源预先批准，则完全跳过审批流程，工具立即执行。

```yaml
components:
  - name: "code_editor"
    type: AgentComponent
    prompt_id: "code_assistant"
    prompt_version: "^1.0.0"
    require_tool_approval: true
    pre_approved_tools: ["read_file", "list_dir", "find_files"]
    toolset: ["read_file", "list_dir", "find_files", "edit_file", "run_command"]
    ui_log_events:
      - "on_agent_final_answer"
      - "on_tool_execution_success"
      - "on_tool_execution_failed"
      - "on_tool_approval_request"
    inputs: ["context:goal"]
```

<a id="usage-modes"></a>

### 使用模式

| 模式 | 何时使用 | `description` 是否必需 |
|---|---|---|
| 独立 | 任务流中的常规组件。 | 否 |
| 受管 | 由监督者委派的子 Agent。 | 是 |
| 监督者 | 通过 `delegate_task` 编排子 Agent。 | 否（监督者本身） |

<a id="supervisor-mode"></a>

### 监督者模式

当提供 `subagents` 时，Agent 成为监督者，并自动获得 `delegate_task` 和 `final_response_tool` 的访问权限。当 LLM 调用 `delegate_task` 时，框架会：

1. 为指定的子 Agent 分配或恢复一个编号的子会话。
1. 用委派提示词初始化子 Agent 的对话历史。
1. 将执行路由到子 Agent 的 ReAct 循环。
1. 子 Agent 完成后，将结果注入回监督者的历史记录，并将控制权返回给监督者。

<a id="constraints"></a>

#### 约束

- `subagents` 必须至少包含一个条目。
- 列出的每个子 Agent 都必须有 `description` 字段。
- 一个 `AgentComponent` 最多只能由一个监督者拥有。
- 监督者提示词必须指示 LLM 何时使用 `delegate_task` 和 `final_response_tool`。

<a id="supervisor-outputs"></a>

#### 监督者输出

| 输出键 | 描述 |
|---|---|
| `context:{supervisor_name}.final_answer` | 监督者的最终响应。 |
| `conversation_history:{supervisor_name}` | 监督者自己的消息历史。 |

<a id="response-schemas"></a>

### 响应模式

响应模式将 AgentComponent 的输出约束为结构化格式。没有响应模式时，Agent 在 `final_answer` 中返回纯字符串。有响应模式时，`final_answer` 是一个字典，每个字段也可以通过 `context:{name}.final_answer.{field}` 访问。

<a id="inline-schema-recommended-for-custom-flows"></a>

#### 内联模式（推荐用于自定义任务流）

```yaml
components:
  - name: "code_reviewer"
    type: AgentComponent
    prompt_id: "code_review_prompt"
    response_schema_id: "code_review"   # no response_schema_version = inline lookup
    toolset: ["read_file"]

response_schemas:
  - schema_id: "code_review"
    definition:
      "$schema": "http://json-schema.org/draft-07/schema#"
      title: "code_review_response"
      type: object
      properties:
        summary:
          type: string
          description: "Brief summary of findings"
        overall_score:
          type: integer
          minimum: 1
          maximum: 10
      required: [summary, overall_score]
```

<a id="registry-schema"></a>

#### 注册表模式

同时提供 `response_schema_id` 和 `response_schema_version`，以从服务器端注册表的 `ai_gateway/response_schemas/definitions/` 加载：

```yaml
components:
  - name: "code_reviewer"
    type: AgentComponent
    prompt_id: "code_review/detailed_analysis"
    prompt_version: "^1.0.0"
    response_schema_id: "analysis/code_review"
    response_schema_version: "^1.0.0"
```

下游组件可以引用单个模式字段：

```yaml
inputs:
  - from: "context:code_reviewer.final_answer.overall_score"
    as: "score"
```

<a id="schema-definition-reference"></a>

#### 模式定义参考

响应模式使用 [JSON Schema](https://json-schema.org/) 格式。重要的顶层字段：

| 字段 | 描述 |
|---|---|
| `$schema` | 模式方言。如果未提供，默认为 `draft-07`。 |
| `title` | 映射到 Agent 为其最终响应调用的工具名称。不得与任何现有工具名称匹配 - 冲突会引发 `ValueError`。 |
| `type` | 必须为 `"object"`。 |
| `properties` | 定义模式字段的嵌套 JSON 对象。支持用于嵌套结构的 `"object"` 类型。 |
| `required` | 输出中必须存在的字段名称列表。 |

AgentComponent 响应模式支持以下 JSON Schema 验证约束。

<a id="numeric-constraints-integernumber"></a>

##### 数值约束（integer/number）

| JSON Schema 约束 | Pydantic 字段参数 | 描述 |
|---|---|---|
| `minimum` | `ge=` | 最小值（含）- 大于或等于。 |
| `maximum` | `le=` | 最大值（含）- 小于或等于。 |
| `exclusiveMinimum` | `gt=` | 最小值（不含）- 大于。 |
| `exclusiveMaximum` | `lt=` | 最大值（不含）- 小于。 |
| `multipleOf` | `multiple_of=` | 值必须是此数字的倍数。 |

<a id="string-constraints"></a>

##### 字符串约束

| JSON Schema 约束 | Pydantic 字段参数 | 描述 |
|---|---|---|
| `minLength` | `min_length=` | 字符串的最小长度（以字符为单位）。 |
| `maxLength` | `max_length=` | 字符串的最大长度（以字符为单位）。 |
| `pattern` | `pattern=` | 字符串必须匹配的正则表达式模式。 |

<a id="array-constraints"></a>

##### 数组约束

| JSON Schema 约束 | Pydantic 字段参数 | 描述 |
|---|---|---|
| `minItems` | `min_length=` | 数组中的最小项目数。 |
| `maxItems` | `max_length=` | 数组中的最大项目数。 |

<a id="enumeration-and-constants"></a>

##### 枚举和常量

| JSON Schema 约束 | Python 类型 | 描述 |
|---|---|---|
| `enum` | `Literal[val1, val2, ...]` | 字段必须是指定值之一。 |
| `const` | `Literal[value]` | 字段必须恰好是此值。 |

<a id="metadata"></a>

##### 元数据

| JSON Schema 字段 | Pydantic 字段参数 | 描述 |
|---|---|---|
| `default` | `default=` | 可选字段的默认值。 |
| `examples` | `examples=` | 作为指导展示给 Agent 的示例值。 |

<a id="full-schema-example"></a>

##### 完整模式示例

```json
{
    "$schema": "http://json-schema.org/draft-07/schema#",
    "title": "code_review_response_tool",
    "type": "object",
    "properties": {
        "summary": {
            "type": "string",
            "description": "Brief summary of the code review findings"
        },
        "issues_found": {
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "severity": {
                        "type": "string",
                        "enum": ["low", "medium", "high", "critical"]
                    },
                    "description": { "type": "string" },
                    "file_path": { "type": "string" },
                    "line_number": { "type": "integer" }
                },
                "required": ["severity", "description"]
            }
        },
        "recommendations": {
            "type": "array",
            "items": { "type": "string" }
        },
        "overall_score": {
            "type": "integer",
            "minimum": 1,
            "maximum": 10
        }
    },
    "required": ["summary", "issues_found", "overall_score"]
}
```

<a id="agentcomponent-example"></a>

### AgentComponent 示例

```yaml
components:
  - name: "code_assistant"
    type: AgentComponent
    prompt_id: "code_review_helper"
    prompt_version: "^1.0.0"
    inputs: ["context:goal"]
    require_tool_approval: true
    pre_approved_tools: ["read_file", "list_dir", "find_files"]
    toolset:
      - "read_file"
      - "list_dir"
      - "find_files"
      - "create_file_with_contents"
      - "create_merge_request_note":
          "internal": true
      - "edit_file"
    ui_log_events:
      - "on_agent_final_answer"
      - "on_tool_execution_success"
      - "on_tool_execution_failed"
    ui_role_as: "agent"
```

<a id="humaninputcomponent"></a>

## HumanInputComponent

HumanInputComponent：

- 暂停工作流执行。
- 向人类展示提示。
- 在人类响应后恢复。

将其用于评审关卡、审批和反馈循环。

<a id="required-parameters-1"></a>

### 必填参数

| 参数 | 描述 |
|---|---|
| `name` | 唯一标识符。不得包含 `:` 或 `.` 字符。 |
| `type` | 必须为 `"HumanInputComponent"`。 |
| `sends_response_to` | 在其对话历史中接收人类响应的 AgentComponent 的名称。[这必须是一个已经运行过的组件](#critical-constraint-sends_response_to-must-point-to-an-already-run-component)。 |
| `message_template` | 展示给人类的 Jinja2 模板。可以通过 `inputs` 引用变量。 |

<a id="optional-parameters-1"></a>

### 可选参数

| 参数 | 默认值 | 描述 |
|---|---|---|
| `interaction_type` | `"approval"` | `"approval"` 渲染批准/拒绝/修改按钮。`"input"` 渲染文本输入框。始终显式设置此项 - 不要依赖默认值。 |
| `inputs` | `[]` | 要渲染到 `message_template` 中的变量。 |
| `ui_log_events` | `[]` | 应始终包含两个 [UI 日志事件](#ui-log-events)。 |

<a id="critical-constraint-sends_response_to-must-point-to-an-already-run-component"></a>

### 关键约束：`sends_response_to` 必须指向已运行的组件

> [!note]
> 这是 `HumanInputComponent` 中最常被误解的字段。

框架将人类反馈注入目标组件现有的对话历史中。如果该组件尚未运行，则它没有对话历史条目，框架会因 `KeyError('<component_name>')` 而崩溃。

> [!note]
> `sends_response_to` 必须指定一个在关卡触发前已经完成执行的组件。

实际上，这几乎总是指向在关卡之前立即运行的那个 Agent。

如果 `modify` 路由目标尚未运行，请改为通过其 `inputs` 向其传递反馈：

```yaml
# Correct pattern - sends_response_to points to the already-run agent
- name: "review_gate"
  type: HumanInputComponent
  sends_response_to: "suggester_agent"    # suggester already ran ✅
  interaction_type: "approval"
  ...

# The modify handler gets feedback through inputs instead:
- name: "modify_handler"
  type: AgentComponent
  inputs:
    - from: "context:review_gate.approval"
      as: "human_feedback"               # feedback passed explicitly ✅
```

```yaml
# Wrong pattern - crashes with KeyError
- name: "review_gate"
  sends_response_to: "modify_handler"    # has not run yet → KeyError ❌
```

<a id="ui-log-events"></a>

### UI 日志事件

必须包含这两个事件。没有它们，关卡在会话 UI 中不可见：

| 事件 | 描述 |
|---|---|
| `on_user_input_prompt` | 显示提示并渲染正确的输入控件（按钮或文本框）。 |
| `on_user_response` | 在 UI 聊天日志中捕获人类的响应。 |

<a id="outputs-1"></a>

### 输出

| 输出键 | 描述 |
|---|---|
| `context:{name}.approval` | 人类的决定：`"approve"`、`"reject"` 或 `"modify"`。 |
| `conversation_history:{sends_response_to}` | 人类的消息，注入到目标 Agent 的历史记录中。 |

<a id="approval-router---three-values-not-two"></a>

### 审批路由 - 三个值，而不是两个

当 `interaction_type: "approval"` 时，人类可以用三个值响应。您的路由器必须处理所有三个值，否则 `modify` 路径会静默落入 `default_route`：

| 值 | 含义 |
|---|---|
| `"approve"` | 人类已接受 - 继续下一步。 |
| `"reject"` | 人类已拒绝 - 路由到结束或错误处理。 |
| `"modify"` | 人类提供了反馈 - 路由回先前的 Agent 进行修改。 |

```yaml
routers:
  - from: "review_gate"
    condition:
      input: "context:review_gate.approval"
      routes:
        "approve": "next_step"
        "modify": "prior_agent"      # loop back - feedback available in history or inputs
        "reject": "end"
        "default_route": "end"       # always include a fallback
```

<a id="humaninputcomponent-checklist"></a>

### HumanInputComponent 检查清单

保存 YAML 之前，请确认：

- `interaction_type` 已显式设置（`"approval"` 或 `"input"`）。
- `ui_log_events` 包含 `"on_user_input_prompt"` 和 `"on_user_response"`。
- 下游路由器使用 `condition:`（而不是 `to:`）。
- 路由器显式处理 `"approve"`、`"modify"` 和 `"reject"`。
- 路由器中存在 `"default_route"`。
- `sends_response_to` 指向在关卡触发前已经运行过的组件。
- 如果 `modify` 目标尚未运行，其 `inputs` 包含 `from: "context:{gate_name}.approval" as: "human_feedback"`。

<a id="usage-patterns"></a>

### 使用模式

<a id="approval-workflow"></a>

#### 审批工作流

```yaml
components:
  - name: "user_approval"
    type: HumanInputComponent
    sends_response_to: "proposal_agent"   # proposal_agent already ran
    interaction_type: "approval"
    message_template: |
      Please review the proposed changes and choose an action:
      - ✅ Approve: Proceed
      - ✏️ Modify: Provide feedback for revision
      - ❌ Reject: Discard
    ui_log_events:
      - "on_user_input_prompt"
      - "on_user_response"

routers:
  - from: "user_approval"
    condition:
      input: "context:user_approval.approval"
      routes:
        "approve": "executor"
        "modify": "proposal_agent"
        "reject": "end"
        "default_route": "end"
```

<a id="interactive-chat"></a>

#### 交互式聊天

```yaml
components:
  - name: "user_input"
    type: HumanInputComponent
    sends_response_to: "chat_agent"
    interaction_type: "input"
    message_template: "How can I help you today?"
    ui_log_events:
      - "on_user_input_prompt"
      - "on_user_response"

routers:
  - from: "user_input"
    to: "chat_agent"
  - from: "chat_agent"
    to: "user_input"  # loop back for continued interaction
```

<a id="deterministicstepcomponent"></a>

## DeterministicStepComponent

直接执行单个工具，无需 LLM 参与。参数从任务流状态中提取。链接多个实例以执行顺序工具操作。

<a id="required-parameters-2"></a>

### 必填参数

| 参数 | 描述 |
|---|---|
| `name` | 唯一标识符。不得包含 `:` 或 `.` 字符。 |
| `type` | 必须为 `"DeterministicStepComponent"`。 |
| `tool_name` | 要执行的单个工具的名称。 |

<a id="optional-parameters-2"></a>

### 可选参数

| 参数 | 默认值 | 描述 |
|---|---|---|
| `toolset` | 自动 | 包含该工具的工具集（如果省略则自动创建）。 |
| `inputs` | `[]` | 映射到工具参数的输入源。 |
| `ui_log_events` | `[]` | 在 UI 中展示的事件。 |
| `ui_role_as` | `"tool"` | 在 UI 中的显示角色。 |

<a id="outputs-2"></a>

### 输出

| 输出键 | 描述 |
|---|---|
| `context:{name}.tool_responses` | 工具执行的结果。 |
| `context:{name}.error` | 发生的任何错误。 |
| `context:{name}.execution_result` | `"success"` 或 `"failed"`。 |

<a id="validation"></a>

### 验证

组件在初始化时验证工具参数：

- 验证指定的工具存在于工具集中。
- 检查所有必需的工具参数是否已在 `inputs` 中配置。
- 验证参数是否与工具的预期模式匹配。

错误在配置时而非运行时捕获。

<a id="example-chain-multiple-tools"></a>

### 示例：链接多个工具

```yaml
components:
  - name: "read_config"
    type: DeterministicStepComponent
    inputs:
      - from: "context:goal"
        as: "config_path"
    tool_name: "read_file"
    ui_log_events:
      - "on_tool_execution_success"
      - "on_tool_execution_failed"

  - name: "backup_config"
    type: DeterministicStepComponent
    inputs:
      - from: "context:read_config.tool_responses"
        as: "contents"
      - from: "config_backup.txt"
        as: "file_path"
        literal: true
    tool_name: "create_file_with_contents"
```

<a id="oneoffcomponent"></a>

## OneOffComponent

介于 `AgentComponent` 和 `DeterministicStepComponent` 之间。使用 LLM 在单轮中生成工具调用，然后在成功后退出。包含针对失败执行的内置重试逻辑。

当任务可以在一次 LLM 调用中完成，但受益于 LLM 推理来确定工具参数时使用。

<a id="required-parameters-3"></a>

### 必填参数

| 参数 | 描述 |
|---|---|
| `name` | 唯一标识符。不得包含 `:` 或 `.` 字符。 |
| `type` | 必须为 `"OneOffComponent"`。 |
| `prompt_id` | 指示工具调用的提示词。 |
| `toolset` | 单轮可用的工具。 |

<a id="optional-parameters-3"></a>

### 可选参数

| 参数 | 默认值 | 描述 |
|---|---|---|
| `prompt_version` | 省略 | 省略则使用本地定义的提示词。 |
| `inputs` | `["context:goal"]` | 输入数据源。 |
| `max_correction_attempts` | `3` | 失败工具执行的重试限制。 |
| `model_size_preference` | `null` | `"small"` 或 `"large"`。 |
| `compaction` | 无 | 对话压缩配置。 |
| `ui_log_events` | `[]` | 在 UI 中展示的事件。 |

<a id="outputs-3"></a>

### 输出

| 输出键 | 描述 |
|---|---|
| `context:{name}.tool_responses` | 工具执行结果。 |
| `context:{name}.tool_calls` | 所进行的工具调用的记录。 |
| `context:{name}.execution_result` | `"success"` 或 `"failed"`。 |

<a id="ui-log-events-1"></a>

### UI 日志事件

| 事件 | 描述 |
|---|---|
| `on_tool_call_input` | 工具即将以其参数被调用。 |
| `on_tool_execution_success` | 工具成功完成。 |
| `on_tool_execution_failed` | 工具执行失败。 |
| `on_agent_reasoning` | Agent 由于限制无法生成工具调用。 |

<a id="internal-architecture"></a>

### 内部架构

OneOffComponent 由三个内部节点组成：

- LLM 节点（`{name}#llm`）：使用 `AgentNode` 生成一个或多个工具调用。
- 工具节点（`{name}#tools`）：通过 `ToolNodeWithErrorCorrection` 执行工具调用并进行错误纠正。
- 退出节点（`{name}#exit`）：处理完成和状态日志记录。

<a id="example"></a>

### 示例

```yaml
components:
  - name: "file_reader"
    type: OneOffComponent
    prompt_id: "read_specific_file"
    prompt_version: "^1.0.0"
    inputs:
      - from: "context:goal"
        as: "target_file"
    toolset:
      - "read_file"
    max_correction_attempts: 2
    ui_log_events:
      - "on_tool_call_input"
      - "on_tool_execution_success"
      - "on_tool_execution_failed"
```

<a id="endcomponent-and-abortcomponent"></a>

## EndComponent 和 AbortComponent

两者在每个任务流中都自动可用。无需定义。

| 名称 | 路由器键 | 设置的状态 | 何时使用 |
|---|---|---|---|
| EndComponent | `"end"` | `COMPLETED` | 工作流成功完成。 |
| AbortComponent | `"abort"` | `ERROR` | 不可恢复的错误；重试已耗尽。 |

```yaml
routers:
  - from: "my_component"
    to: "end"    # successful completion

  - from: "my_component"
    to: "abort"  # error termination
```

<a id="routers"></a>

## 路由器

路由器定义每个组件完成后执行如何在组件之间移动。

<a id="simple-router"></a>

### 简单路由器

无条件路由到下一个组件：

```yaml
routers:
  - from: "component_a"
    to: "component_b"
```

<a id="conditional-router"></a>

### 条件路由器

根据上下文变量的值进行路由：

```yaml
routers:
  - from: "component_a"
    condition:
      input: "context:component_a.final_answer"
      routes:
        "approved": "component_b"
        "rejected": "end"
        "default_route": "end"   # fallback if value matches nothing
```

始终包含 `"default_route"` 以防止静默死胡同。

<a id="common-pitfalls"></a>

## 常见陷阱

| 症状 | 根本原因 | 修复方法 |
|---|---|---|
| Agent 说找不到项目或没有项目上下文 | `project_id` 不在组件的 `inputs` 中 | 将 `- from: "context:project_id" as: "project_id"` 添加到每个调用极狐GitLab API 工具的组件，并在 `user:` 块中包含 `Project ID: {{ project_id }}`。 |
| `primary_branch` 未定义 | 缺少 `flow.inputs` 节 | 添加带有 `agent_platform_standard_context` 模式的完整 `flow.inputs` 块。 |
| HITL 关卡在 UI 中不显示任何内容 | `HumanInputComponent` 上缺少 `ui_log_events` | 将 `on_user_input_prompt` 和 `on_user_response` 添加到 `ui_log_events`。 |
| 修改时出现 `KeyError('<component_name>')` | `sends_response_to` 指向尚未运行的组件。 | 将 `sends_response_to` 指向最近完成的 Agent；通过修改目标的 `inputs` 向其传递反馈。 |
| `modify` 响应意外路由到 `default_route` | 路由器缺少 `"modify"` 路由 | 在 `HumanInputComponent` 之后的每个条件路由器中添加 `"modify": "<target_component>"`。 |
| Agent 无限循环 | 提示词缺少停止指令 | 在每个 `system:` 提示词末尾加上明确的完成指令。 |
| 会话开始时出现 `NoneType: None` 崩溃 | Agent 系统提示词中存在 `{{ }}` Jinja2 语法 | 平台在将系统提示词传递给模型之前会通过 Jinja2 渲染它。提示词文本中的任何 `{{ variable }}` 都会被当作模板变量。请在文档中使用 `<<variable>>` 表示法，或使用 `{% raw %}{{ }}{% endraw %}` 进行转义。 |
| 加载时出现 YAML 解析错误 | 内联提示词上缺少 `unit_primitives: []` | 始终包含 `unit_primitives: []`，即使为空。 |
| Agent 收到空白变量 | `as:` 别名与 `{{ }}` 占位符不匹配 | 验证 `inputs` 中的 `as:` 值与占位符名称完全匹配。 |

<a id="flow-examples"></a>

## 任务流示例

<a id="simple-ambient-flow-with-local-prompt"></a>

### 使用本地提示词的简单 ambient 任务流

```yaml
version: "v1"
environment: ambient

components:
  - name: "code_analyzer"
    type: AgentComponent
    prompt_id: "code_review_prompt"
    inputs:
      - from: "context:goal"
        as: "mr_link"
    toolset: ["read_file", "list_dir"]
    ui_log_events:
      - "on_agent_final_answer"

prompts:
  - prompt_id: "code_review_prompt"
    name: "Code Review"
    unit_primitives: []
    prompt_template:
      system: |
        You are an experienced software developer. Conduct a thorough code review
        and provide actionable feedback. When complete, your final answer is a
        summary of your findings. No further steps are needed after that.
      user: |
        Please conduct a code review for the merge request at: {{ mr_link }}
      placeholder: history
    params:
      timeout: 180

routers:
  - from: "code_analyzer"
    to: "end"

flow:
  entry_point: "code_analyzer"
```

<a id="ambient-flow-with-tool-options-for-controlled-tool-behavior"></a>

### 使用工具选项控制工具行为的 ambient 任务流

```yaml
version: "v1"
environment: ambient

components:
  - name: "security_agent"
    type: AgentComponent
    prompt_id: "security_prompt"
    inputs:
      - from: "context:project_id"
        as: "project_id"
      - from: "context:goal"
        as: "mr_link"
    toolset:
      - "create_merge_request_note":
          "internal": true
      - "get_merge_request"
    ui_log_events:
      - "on_tool_execution_success"
      - "on_tool_execution_failed"
      - "on_agent_final_answer"

  - name: "general_agent"
    type: AgentComponent
    prompt_id: "general_prompt"
    inputs:
      - from: "context:project_id"
        as: "project_id"
      - from: "context:goal"
        as: "mr_link"
    toolset:
      - "create_merge_request_note"
    ui_log_events:
      - "on_tool_execution_success"
      - "on_tool_execution_failed"
      - "on_agent_final_answer"

prompts:
  - prompt_id: "security_prompt"
    name: "Security Analysis Prompt"
    unit_primitives: []
    prompt_template:
      system: |
        You are a security analyst. Review the MR and leave an internal note
        summarizing any security concerns. When complete, your final answer is
        a confirmation that the note was posted. No further steps are needed.
      user: |
        Project ID: {{ project_id }}
        Merge Request: {{ mr_link }}
      placeholder: history
    params:
      timeout: 180

  - prompt_id: "general_prompt"
    name: "General Summary Prompt"
    unit_primitives: []
    prompt_template:
      system: |
        You are a helpful assistant. Leave a public note on the MR summarizing
        the changes. When complete, your final answer is a confirmation that
        the note was posted. No further steps are needed.
      user: |
        Project ID: {{ project_id }}
        Merge Request: {{ mr_link }}
      placeholder: history
    params:
      timeout: 180

routers:
  - from: "security_agent"
    to: "general_agent"
  - from: "general_agent"
    to: "end"

flow:
  entry_point: "security_agent"
```

<a id="hitl-approval-flow"></a>

### HITL 审批任务流

此任务流提出一个操作，将其呈现给人类评审，并在批准后执行。它演示了正确的 `sends_response_to` 模式以及所有三个路由器路由。

```yaml
version: "v1"
environment: ambient

components:
  - name: "proposal_agent"
    type: AgentComponent
    prompt_id: "proposal_prompt"
    inputs:
      - from: "context:goal"
        as: "goal"
      - from: "context:project_id"
        as: "project_id"
    toolset:
      - "get_issue"
      - "list_issues"
    ui_log_events:
      - "on_agent_final_answer"
      - "on_tool_execution_success"
      - "on_tool_execution_failed"

  - name: "review_gate"
    type: HumanInputComponent
    sends_response_to: "proposal_agent"     # proposal_agent has already run ✅
    interaction_type: "approval"
    message_template: |
      The agent has proposed an action. Please review and choose:
      - ✅ Approve: Proceed with the proposed action
      - ✏️ Modify: Provide feedback - the agent will revise
      - ❌ Reject: Discard
    ui_log_events:
      - "on_user_input_prompt"
      - "on_user_response"

  - name: "executor_agent"
    type: AgentComponent
    prompt_id: "executor_prompt"
    inputs:
      - from: "context:goal"
        as: "goal"
      - from: "context:project_id"
        as: "project_id"
      - from: "context:proposal_agent.final_answer"
        as: "approved_proposal"
    toolset:
      - "update_issue"
      - "create_issue_note"
    ui_log_events:
      - "on_agent_final_answer"
      - "on_tool_execution_success"
      - "on_tool_execution_failed"

prompts:
  - prompt_id: "proposal_prompt"
    name: "Proposal Agent"
    unit_primitives: []
    prompt_template:
      system: |
        Review the goal and propose a concrete action. Do not execute anything yet.
        When you have formed your proposal, your final answer is a clear description
        of the proposed action. No further steps are needed after that.
      user: |
        Project ID: {{ project_id }}
        Goal: {{ goal }}
      placeholder: history
    params:
      timeout: 180

  - prompt_id: "executor_prompt"
    name: "Executor Agent"
    unit_primitives: []
    prompt_template:
      system: |
        Execute the approved proposal. If the human provided modification feedback,
        it is in your conversation history - incorporate it before executing.
        When execution is complete, your final answer is a confirmation of what
        was done. No further steps are needed after that.
      user: |
        Project ID: {{ project_id }}
        Goal: {{ goal }}
        Approved proposal: {{ approved_proposal }}
      placeholder: history
    params:
      timeout: 180

routers:
  - from: "proposal_agent"
    to: "review_gate"
  - from: "review_gate"
    condition:
      input: "context:review_gate.approval"
      routes:
        "approve": "executor_agent"
        "modify": "proposal_agent"    # loops back - feedback in proposal_agent history
        "reject": "end"
        "default_route": "end"
  - from: "executor_agent"
    to: "end"

flow:
  entry_point: "proposal_agent"
```

<a id="flow-with-model-size-preference"></a>

### 使用模型大小偏好的任务流

将轻量级任务路由到较小的模型，将复杂任务路由到较大的模型：

```yaml
version: "v1"
environment: ambient

components:
  - name: "explorer"
    type: AgentComponent
    prompt_id: "explorer_agent"
    prompt_version: "^1.0.0"
    model_size_preference: "small"
    inputs: ["context:goal"]
    toolset:
      - "read_file"
      - "list_dir"
      - "find_files"
    ui_log_events:
      - "on_tool_execution_success"

  - name: "implementer"
    type: AgentComponent
    prompt_id: "implementer_agent"
    prompt_version: "^1.0.0"
    model_size_preference: "large"
    inputs:
      - from: "context:goal"
        as: "goal"
      - from: "context:explorer.final_answer"
        as: "codebase_context"
    toolset:
      - "read_file"
      - "edit_file"
      - "create_file_with_contents"
    ui_log_events:
      - "on_agent_final_answer"
      - "on_tool_execution_success"
      - "on_tool_execution_failed"

routers:
  - from: "explorer"
    to: "implementer"
  - from: "implementer"
    to: "end"

flow:
  entry_point: "explorer"
```

<a id="multi-agent-supervisor-flow"></a>

### 多 Agent 监督者任务流

```yaml
version: "v1"
environment: ambient

components:
  - name: "developer"
    type: AgentComponent
    description: "Implements code changes, creates and edits files based on requirements."
    prompt_id: "developer_agent"
    prompt_version: "^1.0.0"
    toolset:
      - "read_file"
      - "edit_file"
      - "create_file_with_contents"
      - "list_dir"
      - "find_files"
    ui_log_events:
      - "on_agent_final_answer"
      - "on_tool_execution_success"

  - name: "tester"
    type: AgentComponent
    description: "Writes and runs automated tests to verify code correctness."
    prompt_id: "tester_agent"
    prompt_version: "^1.0.0"
    toolset:
      - "read_file"
      - "create_file_with_contents"
      - "run_command"
    ui_log_events:
      - "on_agent_final_answer"
      - "on_tool_execution_success"

  - name: "supervisor"
    type: AgentComponent
    prompt_id: "supervisor_agent"
    prompt_version: "^1.0.0"
    inputs: ["context:goal"]
    subagents:
      - name: "developer"
      - name: "tester"
    max_delegations: 20
    toolset:
      - "get_issue"
    ui_log_events:
      - "on_agent_final_answer"
      - "on_tool_execution_success"
      - "on_tool_execution_failed"

routers:
  - from: "supervisor"
    to: "end"

flow:
  entry_point: "supervisor"
```

<a id="chat-partial-flow-for-conversational-code-review"></a>

### 用于对话式代码评审的 chat-partial 任务流

```yaml
version: "v1"
environment: chat-partial

components:  # exactly one AgentComponent when using chat-partial
  - name: "code_analyzer"
    type: AgentComponent
    prompt_id: "code_review_prompt"
    ui_log_events: ["on_agent_final_answer"]
    inputs:
      - from: "context:goal"
        as: "mr_link"
    toolset: ["read_file", "list_dir"]

prompts:
  - prompt_id: "code_review_prompt"
    name: "Code Review Prompt"
    unit_primitives: []
    prompt_template:
      system: |
        You are an experienced software developer. Conduct a thorough code review
        and mentor engineers on best practices.
      user: |
        Please conduct a code review for the merge request at: {{ mr_link }}
      placeholder: history
    params:
      timeout: 180

routers: []
flow: {}
```
