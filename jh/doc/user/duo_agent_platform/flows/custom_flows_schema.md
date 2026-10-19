---
stage: Agent Foundations
group: AI Catalog
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 自定义任务流 YAML 模式
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
{{< /details >}}

自定义任务流使用[任务流注册表 v1 规范](https://jihulab.com/gitlab-cn/modelops/ai-assist/-/blob/main/docs/flow_registry/v1.md)语法。v1 规范定义了完整的 YAML 结构，包括 `version`、`environment`、`components`、`prompts`、`routers` 和 `flow` 等字段。

v1 规范中的部分字段在自定义任务流中受到限制。更多信息，请参见[受限字段](#restricted-fields)。

YAML 配置还有大小上限。更多信息，请参见[配置大小限制](../ai_catalog.md#configuration-size-limits)。

<a id="goal-values-by-trigger-type"></a>

## 按触发器类型划分的目标值

设计自定义任务流时，目标值取决于启动该任务流的触发器类型。一个任务流可以配置多个触发器类型，每种触发器类型传递不同的值作为 `context:goal`。您的任务流必须处理您配置的每种触发器类型的目标格式。

有关触发器类型的更多信息，请参见[触发器](../triggers/_index.md)。

组件通过 `inputs` 字段访问目标：

```yaml
components:
  - name: "my_agent"
    type: AgentComponent
    prompt_id: "my_prompt"
    inputs:
      - from: "context:project_id"
        as: "project_id"
      - "context:goal"
```

<a id="mention-events"></a>

### 提及事件

当用户在评论中提及任务流服务账号时，完整的评论文本和资源上下文会作为目标传递。

目标使用以下格式：

```plaintext
Input: <comment_text>
Context: {<resource_type> IID: <iid>}
```

例如，如果用户在议题 `#2` 上写入 `@ai-my-flow Can you work on this?`，则目标为：

```plaintext
Input: @ai-my-flow Can you work on this?
Context: {Issue IID: 2}
```

<a id="assign-and-assign-reviewer-events"></a>

### 指派和指派审核人事件

当任务流服务账号被指派到议题或合并请求，或被指派为审核人时，资源的 IID 会作为目标传递。

例如，如果任务流服务账号在合并请求 `!10` 上被指派为审核人，则 `context:goal` 的值为 `10`。

将 IID 与 `context:project_id` 一起使用来读取资源：

```yaml
components:
  - name: "review_mr"
    type: AgentComponent
    prompt_id: "review_mr_prompt"
    inputs:
      - from: "context:project_id"
        as: "project_id"
      - from: "context:goal"
        as: "mr_iid"
```

<a id="pipeline-events"></a>

### 流水线事件

当流水线事件触发任务流时，完整的[流水线事件 webhook 负载](../../project/integrations/webhook_events.md#pipeline-events)会作为目标传递。

<a id="optional-top-level-properties"></a>

## 可选顶层属性

<a id="coding_environment"></a>

### `coding_environment`

可选的 `coding_environment` 属性声明工作负载启动时任务流需要何种编码环境。

| 值 | 描述 |
|-------|-------------|
| `full` | 未提供时的默认值。包含代码仓库克隆、设置脚本、Git hook 和依赖缓存。适用于读取或写入代码仓库文件的任务流。 |
| `none` | 不克隆代码仓库。跳过设置脚本和依赖缓存。仍会安装 Duo 会话 Git hook，因此自行克隆代码仓库的任务流仍会将其提交归属于 Duo。适用于仅与极狐GitLab API 交互且不需要本地代码仓库的纯 API 任务流。读取或写入代码仓库文件的 Agent 工具将没有可操作的对象。`none` 值不会阻止代码仓库访问。具有 `run_command` 工具的任务流仍可自行克隆代码仓库。该属性仅控制极狐GitLab 在任务流启动前准备的内容。 |

当任务流需要检出时，请使用 `full` 值，这样克隆会在运行前一次性完成，而不是在运行期间进行。

如果您添加的值不是 `full` 或 `none`，模式验证会失败，任务流不会运行。

如果您不添加 `coding_environment` 属性，任务流会获得完整环境，并且仍具有代码仓库访问权限。

示例：

```yaml
version: v1
environment: ambient
coding_environment: none
components:
  - name: "api_agent"
    type: AgentComponent
    prompt_id: "my_api_prompt"
    inputs:
      - "context:goal"
routers:
  - from: "api_agent"
    to: end
flow:
  entry_point: "api_agent"
```

<a id="restricted-fields"></a>

## 受限字段

v1 规范中的部分字段和功能受到限制，以确保自定义任务流在极狐GitLab 中一致运行。

<a id="environment"></a>

### `environment`

在自定义任务流中，`environment` 字段仅支持 `ambient` 值。

不支持 `chat` 和 `chat-partial` 值。

<a id="model-in-prompts"></a>

### 提示中的 `model`

不支持 `prompts` 条目内的 `model` 字段。

模型由您的群组或实例设置中配置的模型提供商决定。

<a id="agentcomponent-fields"></a>

### `AgentComponent` 字段

不支持 `response_schema_id` 和 `response_schema_version` 字段。

<a id="oneoffcomponent-fields"></a>

### `OneOffComponent` 字段

不支持 `ui_role_as` 字段。

<a id="stop-in-prompt-parameters"></a>

### 提示参数中的 `stop`

不支持 `params` 条目内的 `stop` 字段。

<a id="top-level-fields"></a>

### 顶层字段

不支持 v1 规范中的 `name`、`description` 和 `product_group` 字段。自定义任务流会拒绝这些字段。
