---
stage: Software Supply Chain Security
group: Compliance
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 为极狐GitLab Duo Agent 配置工具级审批策略，在执行时通过人工审批来管控敏感操作。
title: Agent 工具治理
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

> [!warning]
> 此功能处于[测试版](../../../policy/development_stages_support.md)。
> 如有变更，恕不另行通知。
> 更多信息，请参阅 [GitLab 测试协议](https://handbook.gitlab.com/handbook/legal/testing-agreement/)。

工具治理位于执行边界。在 Agent 被允许进入项目之后、工具被调用之前，治理层会根据用户角色和工具的操作类别查询已配置的规则，然后强制执行相应的模式。

> [!flag]
> 后台任务流的强制执行由功能标志控制。

工具分为三个操作类别：

- **读取**：仅检索或显示信息的工具。
- **写入**：创建或修改资源的工具。
- **删除**：删除或不可逆地移除资源的工具。

Agent 工具治理（人工介入护栏）允许管理员定义每个 Agent 工具在执行时的强制方式。与其允许 Agent 在未经审查的情况下调用任何工具，不如将每个工具配置为以下三种模式之一：

- **始终允许**：工具静默执行，不提示用户。
- **始终询问**：向用户显示内联审批卡片，用户必须批准或拒绝该操作后才能继续。
- **始终拒绝**：工具被完全阻止，对 Agent 不可见。Agent 永远看不到该工具，用户也永远不会收到提示。

此功能适用于 Agentic Chat 和 IDE 扩展。对于任务流，治理强制执行取决于任务流的运行位置：

- 对于在 IDE 扩展中运行的任务流，极狐GitLab 强制执行治理规则。
- 对于后台任务流，例如 Duo Developer 内置任务流，极狐GitLab 强制执行治理规则。

<a id="default-governance-matrix"></a>

## 默认治理矩阵

| 分类 | 模式 |
|------|------|
| 读取（极狐GitLab 资源） | 始终允许 |
| 读取（本地文件） | 始终询问 |
| 写入 | 始终询问 |
| 删除 | 始终询问 |

<a id="gitlab-mcp-server-tools"></a>

### 极狐GitLab MCP 服务器工具

> [!flag]
> 此功能的可用性由功能标志控制。

极狐GitLab MCP 服务器暴露的工具会出现在 **工具管理** 标签页中，来源为 `mcp`，与极狐GitLab Duo Agent Platform 工具并列。您可以按照[为群组配置工具治理](#configure-tool-governance-for-a-group)中描述的方式，为它们设置模式。

每个工具根据其声明的注解被归类到相应的操作类别。无需维护列表，因此新添加的 MCP 工具会自动受到治理：

| 工具声明 | 类别 |
|---|---|
| `destructiveHint: true` | 删除 |
| `readOnlyHint: true` | 读取 |
| `readOnlyHint: false` | 写入 |
| 无任何注解 | 删除 |

同时声明 `destructiveHint: true` 和 `readOnlyHint: true` 的工具归类为删除。类别按所示顺序解析，因此最严格的声明优先。标签页上的工具也会因极狐GitLab 版本、许可证和已启用的功能而异，因为这些决定了 MCP 服务器暴露哪些工具。

许多功能既以极狐GitLab Duo Agent Platform 工具形式存在，也以 MCP 服务器工具形式存在。一个模式即可管理两者，即使两个工具名称不同。例如，为 `get_work_item_notes` 设置模式也适用于 MCP 服务器工具 `get_workitem_notes`。请在极狐GitLab Duo Agent Platform 工具上设置模式。您无需单独查找和设置 MCP 服务器工具。

如果您未设置模式，则行为保持不变。只读 MCP 工具仍为预批准状态。写入和删除 MCP 工具仍会提示审批。

<a id="approval-prompt-always-ask"></a>

### 审批提示（始终询问）

当 Agent 调用配置为 **始终询问** 的工具时，执行会暂停并显示内联审批卡片。卡片显示：

- 正在调用的工具名称。
- 该工具将执行的操作的描述。
- **批准** 和 **拒绝** 按钮。

如果您批准，工具将执行，Agent 继续。如果您拒绝，工具不会执行。Agent 会收到拒绝信号，并可能尝试替代方法或停止。

<a id="denial-message-always-deny"></a>

### 拒绝消息（始终拒绝）

当 Agent 尝试调用针对您的角色配置为 **始终拒绝** 的工具时，该工具不会呈现给 Agent。如果 Agent 的计划需要被拒绝的工具，它会收到一个错误，指示该工具因治理策略而不可用。

<a id="rule-resolution-and-cascading"></a>

## 规则解析与级联

规则按以下顺序解析，从最具体到最不具体：

1. 项目级规则（如果已配置）。
1. 群组级规则（如果已配置）。
1. 默认矩阵值。

对于同一工具，项目级规则会覆盖群组级规则，但只能等于或严于群组级规则。群组级规则会覆盖默认值。如果任何级别均未配置规则，则该工具使用默认治理矩阵值。

此功能遵循故障关闭原则。如果治理服务在解析规则时遇到持续错误，Agent 将不会收到任何工具，而不是静默允许执行。

<a id="configure-tool-governance-for-a-group"></a>

## 为群组配置工具治理

群组级规则适用于群组中的所有项目，除非在项目级被覆盖。

先决条件：

- 您对顶级群组具有所有者角色。

要为群组配置工具治理规则：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的顶级群组。
1. 选择 **设置** > **极狐GitLab Duo**。
1. 选择 **更改治理**。
1. 对于每个工具，从 **模式** 下拉列表中选择一种模式：**始终允许**、**始终询问** 或 **始终拒绝**。
1. 选择 **保存更改**。

更改适用于所有没有项目级覆盖的子群组和项目。

<a id="configure-tool-governance-for-a-project"></a>

## 为项目配置工具治理

项目级规则会覆盖该项目内同一工具的群组级规则。

先决条件：

- 您对该项目具有维护者或所有者角色。

要为项目配置工具治理规则：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **极狐GitLab Duo**。
1. 选择 **更改治理**。
1. 对于每个工具，从下拉列表中选择一种模式：**始终允许**、**始终询问** 或 **始终拒绝**。
1. 选择 **保存更改**。

<a id="block-model-context-protocol-mcp-servers"></a>

## 阻止模型上下文协议（MCP）服务器

> [!warning]
> 此功能处于[测试版](../../../policy/development_stages_support.md)。
> 如有变更，恕不另行通知。
> 更多信息，请参阅 [GitLab 测试协议](https://handbook.gitlab.com/handbook/legal/testing-agreement/)。

除了[按工具治理](#default-governance-matrix)之外，群组所有者还可以阻止来自特定外部 MCP 服务器的所有工具。当 MCP 服务器被阻止时，无论单个工具治理设置或用户批准如何，都无法调用该服务器的任何工具。

此阻止在每次工具调用时强制执行，包括会话中途。如果管理员在工作流运行期间阻止了 MCP 服务器，则随后对该服务器工具的调用会立即被拒绝。

当调用来自被阻止的 MCP 服务器的工具时，Agent 会收到策略消息而不是工具结果。Agent 无法使用该服务器的任何工具。

这与 **始终拒绝** 工具治理模式不同：

- **始终拒绝** 适用于单个工具，并在项目或群组级别配置。
- 阻止 MCP 服务器适用于该服务器的所有工具，并在 MCP 注册表中配置。它会覆盖任何用户批准或工具治理设置。

> [!note]
> 阻止 MCP 服务器需要极狐GitLab 19.3 或更高版本。在较旧的极狐GitLab 私有化部署和 Dedicated 实例上，阻止不会强制执行，并且默认允许来自该服务器的工具。在极狐GitLab 19.3 中，强制执行阻止需要每次 MCP 工具调用额外发出一个请求。

<a id="block-an-mcp-server"></a>

### 阻止 MCP 服务器

您可以在群组或项目级别阻止 MCP 服务器：

- **群组级别**：阻止该服务器对群组内所有项目及其子群组生效。如果服务器在群组级别被阻止，则项目级设置无法解除阻止。
- **项目级别**：仅阻止该服务器对该项目生效。

<a id="block-an-mcp-server-for-a-group"></a>

#### 为群组阻止 MCP 服务器

先决条件：

- 您对顶级群组具有所有者角色。

要为群组阻止 MCP 服务器：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的顶级群组。
1. 在左侧边栏中，选择 **设置** > **极狐GitLab Duo**。
1. 选择 **更改治理**。
1. 选择 **MCP 注册表** 标签页。
1. 找到要阻止的 MCP 服务器，然后选择 **阻止**。

阻止会立即生效。对于群组及其子群组和项目中的所有用户，来自被阻止服务器的所有工具都会被拒绝。

<a id="block-an-mcp-server-for-a-project"></a>

#### 为项目阻止 MCP 服务器

先决条件：

- 您对该项目具有所有者角色。

要为项目阻止 MCP 服务器：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **通用** > **极狐GitLab Duo**。
1. 选择 **更改治理**。
1. 选择 **MCP 注册表** 标签页。
1. 找到要阻止的 MCP 服务器，然后选择 **阻止**。

阻止会立即生效。对于项目中的所有用户，来自被阻止服务器的所有工具都会被拒绝。

<a id="known-issues"></a>

## 已知问题

- 治理 UI 有三个访问类别：Web（基于浏览器的会话）、本地（IDE 和 CLI）和 Runner（在 CI/CD Runner 中运行的后台任务流）。Runner 访问仅支持始终允许和始终拒绝。始终询问不适用，因为后台任务流中没有用户在场响应审批提示。没有配置 Runner 规则的工具默认为始终允许。
- 极狐GitLab MCP 服务器提供的 `search` 工具聚合了极狐GitLab Duo Agent Platform 作为独立、更窄的搜索工具暴露的功能。在这些更窄工具上配置的规则不会扩展到 `search`。要限制 MCP 搜索，请直接在 `search` 上配置规则。
