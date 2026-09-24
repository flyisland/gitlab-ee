---
stage: AI-powered
group: Workflow Catalog
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 自定义流程 YAML 架构
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Status: 测试版

{{< /details >}}

自定义流程使用
[flow registry v1 规范](https://jihulab.com/gitlab-cn/modelops/applied-ml/code-suggestions/ai-assist/-/blob/main/docs/flow_registry/v1.md)
语法。v1 规范定义了完整的 YAML 结构，
包括 `version`、`environment`、`components`、
`prompts`、`routers` 和 `flow` 等字段。

v1 规范中的部分字段在自定义流程中受限。
更多信息，请参阅[受限字段](#restricted-fields)。

<a id="goal-values-by-trigger-type"></a>

## 按触发器类型划分的目标值

当你设计自定义流程时，目标值取决于启动该流程的
触发器类型。一个流程可以配置多个触发器类型，
每个触发器类型会将不同的值作为
`context:goal` 传递。你的流程必须处理你配置的
每个触发器类型的目标格式。

有关触发器类型的更多信息，请参阅
[触发器](../triggers/_index.md)。

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

当用户在评论中提及流程服务账号时，
完整的评论文本和资源上下文会作为
目标传递。

目标使用以下格式：

```plaintext
输入：<comment_text>
上下文：{<resource_type> IID: <iid>}
```

例如，如果用户在 `#2` 议题上写下
`@ai-my-flow 你能处理这个吗？`，则目标为：

```plaintext
输入：@ai-my-flow 你能处理这个吗？
上下文：{议题 IID: 2}
```

<a id="assign-and-assign-reviewer-events"></a>

### 指派和指派审核人事件

当流程服务账号被分配给某个议题或合并请求，
或被指派为审核人时，资源的 IID 将作为
目标传递。

例如，如果流程服务账号被指派为合并请求
`!10` 的审核人，则 `context:goal` 的值为 `10`。

使用 IID 结合 `context:project_id` 读取资源：

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

当流水线事件触发流程时，完整的
[流水线事件 webhook 负载](../../project/integrations/webhook_events.md#pipeline-events)
将作为目标传递。

<a id="restricted-fields"></a>

## 受限字段

v1 规范中的部分字段和功能受限，
以确保自定义流程在 极狐GitLab 中一致运行。

<a id="environment"></a>

### `environment`

在自定义流程中，`environment` 字段仅支持 `ambient` 值。

不支持 `chat` 和 `chat-partial` 值。

<a id="model-in-prompts"></a>

### 提示中的 `model`

不支持在 `prompts` 条目内使用 `model` 字段。

模型由你群组或实例设置中配置的模型提供程序确定。

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

### 顶级字段

不支持 v1 规范中的 `name`、`description` 和 `product_group` 字段。
自定义流程将拒绝这些字段。