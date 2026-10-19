---
stage: AI Clients
group: Developer Clients
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 在交互式和无头模式下使用极狐GitLab Duo CLI。
title: 使用极狐GitLab Duo CLI
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以在两种模式下使用极狐GitLab Duo CLI：

- 交互式模式：提供类似于极狐GitLab UI 或编辑器扩展中极狐GitLab Duo Chat 的聊天体验。支持构建和计划模式。
- 无头模式：支持在 Runner、脚本和其他自动化工作流中进行非交互式使用。

<a id="prerequisites"></a>

## 先决条件

- 已安装并[设置](set_up.md)极狐GitLab Duo CLI。
- 已设置[默认极狐GitLab Duo 命名空间](../profile/preferences.md#namespace-resolution-in-your-local-environment)，或有一个可访问极狐GitLab Duo 的已打开的项目。

<a id="interactive-mode"></a>

## 交互式模式

要以交互式模式使用极狐GitLab Duo CLI：

1. 根据您的设置，输入启动交互式模式的命令：

   {{< tabs >}}

   {{< tab title="glab" >}}

   ```shell
   glab duo cli
   ```

   {{< /tab >}}

   {{< tab title="duo" >}}

   ```shell
   duo
   ```

   {{< /tab >}}

   {{< /tabs >}}

1. 终端窗口中出现提示符 `>`。在提示符后输入您的问题或请求，然后按 <kbd>Enter</kbd>。

   例如：

   ```plaintext
   What is this repository about?

   Which issues need my attention?

   Help me implement issue 15.

   The pipelines in MR 23 are failing. Please help me fix them.
   ```

要在极狐GitLab Duo CLI 工作时取消响应，请按 <kbd>Escape</kbd>。
极狐GitLab Duo CLI 会停止当前操作并返回到提示符。

使用 <kbd>↑</kbd> 键查看您的提示历史，或使用 <kbd>Control</kbd>+<kbd>R</kbd> 搜索。

<a id="switch-between-build-and-plan-modes"></a>

### 在构建和计划模式之间切换

在交互式模式下，您可以在工作时在两种模式之间切换极狐GitLab Duo CLI：

| 模式                 | 权限 | 工作方式                                                                  |
|----------------------|-------------|-------------------------------------------------------------------------------|
| 构建模式（默认） | 读写  | 极狐GitLab Duo 可以执行任务并对您的项目进行更改。               |
| 计划模式            | 只读   | 极狐GitLab Duo 可以分析您的项目并创建计划，而无需进行更改。 |

例如，先在计划模式下与极狐GitLab Duo 讨论问题。当您准备好后，切换到构建模式并指示极狐GitLab Duo 实施该计划。

极狐GitLab Duo CLI 会在 `>` 提示符下显示当前模式。要切换模式，请按
<kbd>Tab</kbd>。

<a id="slash-commands"></a>

### 斜杠命令

在交互式模式下，使用斜杠命令配置极狐GitLab Duo CLI 并执行操作。在提示符处输入斜杠命令并按 <kbd>Enter</kbd>。

以下斜杠命令可用：

| 命令     | 描述                                          |
|-------------|------------------------------------------------------|
| `/copy`     | 将最后一条极狐GitLab Duo 响应复制到剪贴板。  |
| `/doctor`   | 显示极狐GitLab Duo CLI 环境的诊断信息。 |
| `/exit`     | 退出极狐GitLab Duo CLI。                             |
| `/feedback` | 提交错误报告或功能请求。              |
| `/goal`     | 启动一个朝着目标工作的会话。            |
| `/help`     | 显示可用斜杠命令的列表。          |
| `/mcp`      | 查看已配置的 MCP 服务器及其状态。        |
| `/model`    | 切换当前会话的 AI 模型。         |
| `/new`      | 开始新的聊天会话。                            |
| `/sessions` | 浏览、搜索和切换会话。                 |
| `/settings` | 打开设置面板。                             |
| `/skills`   | 列出当前项目中可用的 Agent Skills。  |

您还可以创建自己的斜杠命令。
有关更多信息，请参阅[自定义斜杠命令](customize.md#custom-slash-commands)。

<a id="settings"></a>

### 设置

要更改设置：

1. 在交互式模式下，输入 `/settings` 并按 <kbd>Enter</kbd>。
1. 使用箭头键浏览设置列表。
1. 要更改所选设置，请按 <kbd>Enter</kbd> 或 <kbd>Space</kbd>。
1. 要关闭面板，请按 <kbd>Escape</kbd>。

更改会在会话之间保留。

以下设置可用：

| 设置                  | 描述                                                                                       |
|--------------------------|---------------------------------------------------------------------------------------------------|
| **遥测**            | 发送匿名使用数据以改进极狐GitLab Duo。                                                  |
| **启用全局 skills** | （实验性）从 `~/.agents/skills/` 和 `~/.gitlab/duo/skills/` 发现[用户级 Agent Skills](../duo_agent_platform/customize/agent_skills.md#create-user-level-skills)。更改生效需要重启。 |
| **通知**        | 控制[系统通知](#system-notifications)（`auto` 或 `disabled`）。                     |

<a id="system-notifications"></a>

### 系统通知

在终端窗口未聚焦时，如果会话需要您关注（例如，当它完成任务或需要工具审批时），极狐GitLab Duo CLI 可以发送系统通知。

通知由[设置面板](#settings)中的**通知**设置控制：

- `auto`（默认）：当终端未聚焦时发送系统通知。
- `disabled`：从不发送系统通知。

<a id="tool-approvals"></a>

### 工具审批

当极狐GitLab Duo 需要使用工具时，它会在开始前提示您批准。例如，当它需要读取文件或运行命令时。

您的选项是：

- **批准**：极狐GitLab Duo 可以使用该工具一次。
- **为会话批准**：极狐GitLab Duo 可以在本次会话的剩余时间内使用具有这些参数的工具。不同的参数需要额外的批准。
- **拒绝**：极狐GitLab Duo 不能使用该工具。

> [!note]
> 要使用**为会话批准**选项，
> 您的管理员必须为您的群组或实例启用它。
> 有关更多信息，请参阅[工具审批](../gitlab_duo_chat/agentic_chat.md#tool-approvals)。

<a id="headless-mode"></a>

## 无头模式

> [!caution]
> 请谨慎使用无头模式，并在受控的[沙箱环境](../../editor_extensions/security_considerations.md#use-development-containers-for-isolation)中使用。

要以非交互模式运行工作流，请使用适合您设置的命令：

{{< tabs >}}

{{< tab title="glab" >}}

使用 `glab duo cli run`：

```shell
glab duo cli run --goal "Your goal or prompt here"
```

例如，您可以运行 ESLint 命令并将错误通过管道传递给极狐GitLab Duo CLI 来解决：

```shell
glab duo cli run --goal "Fix these errors: $eslint_output"
```

{{< /tab >}}

{{< tab title="duo" >}}

使用 `duo run`：

```shell
duo run --goal "Your goal or prompt here"
```

例如，您可以运行 ESLint 命令并将错误通过管道传递给极狐GitLab Duo CLI 来解决：

```shell
duo run --goal "Fix these errors: $eslint_output"
```

{{< /tab >}}

{{< /tabs >}}

当您使用无头模式时，极狐GitLab Duo CLI：

- 绕过手动工具审批并自动批准所有工具的使用。
- 不保留之前对话的上下文。
  每次执行 `run` 命令时都会开始一个新的工作流。

<a id="select-a-model"></a>

## 选择模型

您可以为交互式模式或无头模式选择模型。

<a id="for-interactive-mode"></a>

### 对于交互式模式

您选择的模型会在会话之间保留，并且您可以在对话中途切换模型而不会丢失上下文。

先决条件：

- 极狐GitLab Duo CLI 8.76.0 或更高版本。

要为交互式模式选择模型：

1. 在交互式模式下，输入 `/model` 并按 <kbd>Enter</kbd>。
1. 使用箭头键滚动浏览可用模型列表，或输入模型名称以筛选列表。
1. 选择一个模型并按 <kbd>Enter</kbd> 切换到该模型。

<a id="for-headless-mode"></a>

### 对于无头模式

您选择的模型不会在会话之间保留。

先决条件：

- 极狐GitLab Duo CLI 8.68.0 或更高版本。

要为无头模式选择模型：

1. 查找模型的 [`gitlab_identifier`](https://gitlab.com/gitlab-org/modelops/applied-ml/code-suggestions/ai-assist/-/blob/HEAD/ai_gateway/model_selection/models.yml)。
1. 当您运行极狐GitLab Duo CLI 时，将 `--model` 选项或 `GITLAB_DUO_MODEL` 环境变量设置为 `gitlab_identifier` 值。

   {{< tabs >}}

   {{< tab title="glab" >}}

   使用 `--model` 选项：

   ```shell
   glab duo cli --model <gitlab_identifier_for_the_model>
   ```

   使用 `GITLAB_DUO_MODEL` 环境变量：

   ```shell
   GITLAB_DUO_MODEL=<gitlab_identifier_for_the_model> glab duo cli
   ```

   例如，要使用 `GPT-5-Codex - OpenAI`：

   ```shell
   glab duo cli --model gpt_5_codex
   ```

   ```shell
   GITLAB_DUO_MODEL=gpt_5_codex glab duo cli
   ```

   {{< /tab >}}

   {{< tab title="duo" >}}

   使用 `--model` 选项：

   ```shell
   duo --model <gitlab_identifier_for_the_model>
   ```

   使用 `GITLAB_DUO_MODEL` 环境变量：

   ```shell
   GITLAB_DUO_MODEL=<gitlab_identifier_for_the_model> duo
   ```

   例如，要使用 `GPT-5-Codex - OpenAI`：

   ```shell
   duo --model gpt_5_codex
   ```

   ```shell
   GITLAB_DUO_MODEL=gpt_5_codex duo
   ```

   {{< /tab >}}

   {{< /tabs >}}

<a id="switch-sessions"></a>

## 切换会话

极狐GitLab Duo Chat 会话存储您的对话历史和工作流数据，并在极狐GitLab Duo CLI、极狐GitLab UI 和编辑器扩展之间共享。

例如，您可以在浏览器中开始对话，然后在终端中继续。

要浏览和切换到会话：

1. 在交互式模式下，输入 `/sessions` 并按 <kbd>Enter</kbd>。
1. 使用箭头键滚动浏览可用会话列表，或输入文本以筛选列表。
1. 选择一个会话并按 <kbd>Enter</kbd>。

要在无头模式下切换到会话，请使用 `--existing-session-id` 选项。

<a id="model-context-protocol-mcp-connections"></a>

## 模型上下文协议（MCP）连接

要将极狐GitLab Duo CLI 连接到本地或远程 MCP 服务器，请使用与极狐GitLab IDE 扩展相同的 MCP 配置。有关说明，请参阅[配置 MCP 服务器](../gitlab_duo/model_context_protocol/mcp_clients.md#configure-mcp-servers)。

<a id="troubleshooting"></a>

## 故障排除

使用极狐GitLab Duo CLI 时，您可能会遇到以下问题。

<a id="certificate-errors"></a>

### 证书错误

您可能会遇到证书错误：

```plaintext
Error: unable to verify the first certificate
Error: self-signed certificate in certificate chain
```

如果您的组织为 HTTPS 拦截代理或类似情况使用自定义证书颁发机构（CA），则会出现这些错误。

要解决证书错误，请使用以下方法之一：

- 使用系统证书存储（推荐）：
  1. 如果您的 CA 证书已安装在操作系统的证书存储中，请配置 Node.js 使用它。需要 Node.js 22.15.0、23.9.0 或 24.0.0 及更高版本。
  1. 如果您在容器中运行极狐GitLab Duo CLI，请将 CA 证书安装到容器的系统存储中，而不是主机系统存储中。

     ```shell
     export NODE_OPTIONS="--use-system-ca"
     ```

- 指定 CA 证书文件：
  1. 对于较旧的 Node.js 版本，或当 CA 证书不在系统存储中时，直接将 Node.js 指向证书文件。该文件必须为 PEM 格式。
  1. 如果您在容器中运行极狐GitLab Duo CLI，请将路径设置为容器中的位置。使用卷挂载提供证书文件。

     ```shell
     export NODE_EXTRA_CA_CERTS=/path/to/custom-ca.pem
     ```

<a id="ignore-certificate-errors"></a>

### 忽略证书错误

如果您仍然遇到证书错误，可以禁用证书验证。

> [!warning]
> 禁用证书验证存在安全风险。
> 您不应在生产环境中禁用验证。

证书错误会提醒您潜在的安全风险，因此只有在您确信禁用验证是安全的情况下，才应禁用证书验证。

先决条件：

- 您已在浏览器中验证了证书链，或者您的管理员确认可以安全地忽略此错误。

要禁用证书验证：

```shell
export NODE_TLS_REJECT_UNAUTHORIZED=0
```
