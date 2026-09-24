---
stage: AI-powered
group: Editor Extensions
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Command-line interface tool that brings the GitLab Duo Agent Platform to your terminal.
title: 极狐GitLab Duo CLI (`duo`)
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Status: Beta

{{< /details >}}

{{< collapsible title="Model information" >}}

- [默认 LLM](../duo_agent_platform/model_selection.md#default-models)
- 可访问 [自部署模型的 极狐GitLab Duo](../../administration/gitlab_duo_self_hosted/_index.md)

{{< /collapsible >}}

{{< history >}}

- 在 极狐GitLab 18.9 中作为 [实验](../../policy/development_stages_support.md#experiment) 引入。
- 在 极狐GitLab 18.9 发布期间，作为实验功能 [添加](https://gitlab.com/gitlab-org/cli/-/merge_requests/2838) 到 极狐GitLab CLI 的 `glab` 1.87.0 中。
- 在 极狐GitLab 18.10 发布期间，[引入](https://gitlab.com/gitlab-org/editor-extensions/gitlab-lsp/-/releases/v8.68.0) 模型选择选项和环境变量，对应 极狐GitLab Duo CLI 8.68.0。
- 在 极狐GitLab 18.10 发布期间，[引入](https://gitlab.com/gitlab-org/editor-extensions/gitlab-lsp/-/releases/v8.76.0) 模型选择斜杠命令，对应 极狐GitLab Duo CLI 8.76.0。
- 在 极狐GitLab 18.11 中 [变更](https://gitlab.com/groups/gitlab-org/-/work_items/19716) 为 Beta 状态。
- 在 极狐GitLab 19.0 发布期间，[引入](https://gitlab.com/gitlab-org/editor-extensions/gitlab-lsp/-/releases/v8.83.0) 环境变量和选项以启用用户级 Agent 技能，作为 [实验功能](../../policy/development_stages_support.md#experiment) 在 极狐GitLab Duo CLI 8.83.0 中提供。

{{< /history >}}

极狐GitLab Duo CLI 是一个命令行界面工具，它将 [极狐GitLab Duo Agentic Chat](../gitlab_duo_chat/agentic_chat.md)
带到您的终端。该 CLI 适用于任何操作系统和编辑器，可以用来询问有关代码库的复杂问题，并自主代表您执行操作。

极狐GitLab Duo CLI 可以帮助您：

- 理解代码库结构、跨文件功能以及单独的代码片段。
- 构建、修改、重构和现代化代码。
- 排查错误并修复代码问题。
- 自动化 CI/CD 配置，排查流水线错误并优化流水线。
- 自主执行多步骤开发任务。

极狐GitLab Duo CLI 提供两种模式：

- 交互模式：提供类似于 极狐GitLab UI 或编辑器扩展中 极狐GitLab Duo Chat 的聊天体验。支持构建和计划模式。
- 无头模式：支持在 Runner、脚本和其他自动化工作流中进行非交互式使用。

它还支持为 极狐GitLab Duo Agent Platform 设置的 [自定义指令](../duo_agent_platform/customize/_index.md)，包括 `chat-rules.md`、`AGENTS.md` 和 `SKILL.md` 文件。

## 前提条件

- 极狐GitLab 18.11 或更高版本。
- 满足 [极狐GitLab Duo Agent Platform 的前提条件](../duo_agent_platform/_index.md#prerequisites)。
- 已 [开启测试版和实验性功能](../duo_agent_platform/turn_on_off.md#turn-on-beta-and-experimental-features)。

## 设置 极狐GitLab Duo CLI

您可以通过 [极狐GitLab CLI](https://gitlab.cn/docs/cli/) (`glab`) 使用 极狐GitLab Duo CLI。使用 极狐GitLab CLI，您可以访问其他极狐GitLab 功能，并且只需要使用 OAuth 和个人访问令牌认证一次。

或者，您可以将 极狐GitLab Duo CLI (`duo`) 作为独立的 AI 工具安装并使用，通过个人访问令牌单独认证。

两种设置都支持交互模式和无头模式，以及所有 极狐GitLab Duo CLI 选项、命令和功能。

### 通过 极狐GitLab CLI 使用

前提条件：

- [极狐GitLab CLI](https://gitlab.cn/docs/cli/) 1.87.0 或更高版本。
- 极狐GitLab CLI 已完成 [认证](https://gitlab.cn/docs/cli/#authenticate-with-gitlab)。

要通过 极狐GitLab CLI 设置并使用 极狐GitLab Duo CLI：

1. 运行 极狐GitLab Duo CLI 的 `glab` 命令：

   ```shell
   glab duo cli
   ```

1. 按照提示安装 极狐GitLab Duo CLI 二进制文件。

极狐GitLab CLI 会自动处理认证，因此您可以立即开始使用 极狐GitLab Duo CLI。

### 不通过 极狐GitLab CLI 使用

要将 极狐GitLab Duo CLI 作为独立工具使用，请安装它，然后进行认证。

#### 安装

将 极狐GitLab Duo CLI 安装为 npm 包或编译后的二进制文件。

{{< tabs >}}

{{< tab title="npm package" >}}

前提条件：

- Node.js 22 或更高版本。
- 对于使用自签名证书的私有化部署实例，需要：
  - Node.js LTS 22.20.0 或更高版本
  - 或者 Node.js 23.8.0 或更高版本

要将 极狐GitLab Duo CLI 安装为 npm 包，请运行：

```shell
npm install --global @gitlab/duo-cli
```

{{< /tab >}}

{{< tab title="Compiled binary" >}}

要将 极狐GitLab Duo CLI 安装为编译后的二进制文件，请下载并运行安装脚本。

在 macOS 和 Linux 上：

```shell
bash <(curl --fail --silent --show-error --location "https://jihulab.com/gitlab-cn/editor-extensions/gitlab-lsp/-/raw/main/packages/cli/scripts/install_duo_cli.sh")
```

在 Windows 上：

```shell
irm "https://jihulab.com/gitlab-cn/editor-extensions/gitlab-lsp/-/raw/main/packages/cli/scripts/install_duo_cli.ps1" | iex
```

{{< /tab >}}

{{< /tabs >}}

#### 认证

> [!note]
> 如果您首次运行 `duo` 时系统上已安装并认证了 `glab`，`duo`
> 会自动将 `glab` 作为凭据助手。您不需要单独认证。这需要
> `glab` 1.85.2 或更高版本，以及 `duo` 8.68.0 或更高版本。
>
> 如果您在此功能可用之前已经为 `duo` 进行了认证，并且希望改用 `glab` 作为
> 凭据助手，请从 `~/.gitlab/storage.json` 中删除您的认证设置。

前提条件：

- 拥有 `api` 权限的 [个人访问令牌](../profile/personal_access_tokens.md)。

要进行认证：

1. 在终端中运行 `duo`。首次运行 极狐GitLab Duo CLI 时，会出现一个配置页面。
1. 输入 **极狐GitLab 实例 URL**，然后按 <kbd>Enter</kbd>：
   - 对于 JihuLab.com，请输入 `https://jihulab.com`。
   - 对于私有化部署，请输入您的实例 URL。
1. 对于 **极狐GitLab Token**，请输入您的个人访问令牌。
1. 要保存并退出 CLI，请按 <kbd>Enter</kbd>。
1. 要重新启动 CLI，请在终端中运行 `duo`。

要在初始设置后修改配置，请使用 `duo config edit`。

#### 使用环境变量认证

前提条件：

- 拥有 `api` 权限的 [个人访问令牌](../profile/personal_access_tokens.md)。

要使用环境变量进行认证：

1. 将 `GITLAB_TOKEN` 或 `GITLAB_OAUTH_TOKEN` 设置为您的个人访问令牌。

   ```shell
   export GITLAB_TOKEN="<your-personal-access-token>"
   ```

1. 可选。将 `GITLAB_BASE_URL` 或 `GITLAB_URL` 设置为您的自定义 极狐GitLab 实例 URL，例如 `https://gitlab.example.com`。默认值为 `https://jihulab.com`。

   ```shell
   export GITLAB_BASE_URL="<your-instance-url>"
   ```

此方法适用于无头模式、CI/CD 流水线以及无法进行交互式认证的脚本化工作流。

## 使用 极狐GitLab Duo CLI

前提条件：

- 已设置 [默认的 极狐GitLab Duo 命名空间](../profile/preferences.md#namespace-resolution-in-your-local-environment)，或者已打开一个能访问 极狐GitLab Duo 的项目。

### 交互模式

要在交互模式下使用 极狐GitLab Duo CLI：

1. 根据您的设置，输入命令以启动交互模式：

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

1. 在终端窗口中会出现提示符 `>`。在提示符后输入您的问题或请求，然后按 <kbd>Enter</kbd>。

   例如：

   ```plaintext
   这个代码仓是关于什么的？

   哪些议题需要我关注？

   帮我实现议题 15。

   MR 23 中的流水线失败了。请帮我修复它们。
   ```

要在 极狐GitLab Duo CLI 正在工作时取消响应，请按 <kbd>Escape</kbd>。
极狐GitLab Duo CLI 会停止当前操作并返回提示符。

使用 <kbd>↑</kbd> 键查看提示历史记录，或使用 <kbd>Control</kbd>+<kbd>R</kbd> 进行搜索。

#### 在构建和计划模式之间切换

在交互模式下，您可以在工作时将 极狐GitLab Duo CLI 在两种模式之间切换：

| 模式                   | 权限       | 工作方式                                                                 |
|----------------------|------------|---------------------------------------------------------------------------|
| 构建模式（默认）       | 读写       | 极狐GitLab Duo 可以执行任务并对您的项目进行更改。                          |
| 计划模式              | 只读       | 极狐GitLab Duo 可以分析您的项目并创建计划，而不会进行任何更改。            |

例如，先在计划模式下与 极狐GitLab Duo 讨论问题。当您准备好之后，切换到构建模式，并指示 极狐GitLab Duo 实施计划。

极狐GitLab Duo CLI 会在 `>` 提示符下方显示当前模式。要切换模式，请按 <kbd>Tab</kbd>。

#### 斜杠命令

在交互模式下，使用斜杠命令来配置 极狐GitLab Duo CLI 并执行操作。在提示符处输入斜杠命令，然后按 <kbd>Enter</kbd>。

可用的斜杠命令如下：

| 命令          | 描述                                             |
|--------------|--------------------------------------------------|
| `/copy`      | 将上次 极狐GitLab Duo 的响应复制到剪贴板。          |
| `/feedback`  | 提交错误报告或功能请求。                           |
| `/help`      | 显示可用斜杠命令的列表。                           |
| `/model`     | 切换当前会话的 AI 模型。                           |
| `/new`       | 开始一个新的聊天会话。                             |
| `/sessions`  | 浏览、搜索和切换会话。                             |

### 无头模式

> [!caution]
> 请谨慎使用无头模式，并在受控的 [沙盒环境](../../editor_extensions/security_considerations.md#use-development-containers-for-isolation) 中使用。

要在非交互模式下运行工作流，请根据您的设置使用相应的命令：

{{< tabs >}}

{{< tab title="glab" >}}

使用 `glab duo cli run`：

```shell
glab duo cli run --goal "Your goal or prompt here"
```

例如，您可以运行 ESLint 命令并将错误通过管道传递给 极狐GitLab Duo CLI 来解决：

 ```shell
glab duo cli run --goal "Fix these errors: $eslint_output"
```

{{< /tab >}}

{{< tab title="duo" >}}

使用 `duo run`：

```shell
duo run --goal "Your goal or prompt here"
```

例如，您可以运行 ESLint 命令并将错误通过管道传递给 极狐GitLab Duo CLI 来解决：

 ```shell
duo run --goal "Fix these errors: $eslint_output"
```

{{< /tab >}}

{{< /tabs >}}

当您使用无头模式时，极狐GitLab Duo CLI：

- 会绕过手动工具批准，自动批准所有工具的使用。
- 不会保留之前对话的上下文。
  每次执行 `run` 命令时都会开始一个新的工作流。

## 选择模型

您可以为交互模式或无头模式选择模型。

### 交互模式

您选择的模型会在多个会话间保持，并且您可以在对话中途切换模型，而不会丢失上下文。

前提条件：

- 极狐GitLab Duo CLI 8.76.0 或更高版本。

要为交互模式选择模型：

1. 在交互模式下，输入 `/model` 并按 <kbd>Enter</kbd>。
1. 使用方向键浏览可用模型列表，或者输入模型名称来筛选列表。
1. 选择一个模型并按 <kbd>Enter</kbd> 来切换。

### 无头模式

您选择的模型不会在会话间保持。

前提条件：

- 极狐GitLab Duo CLI 8.68.0 或更高版本。

要为无头模式选择模型：

1. 查找模型的 [`gitlab_identifier`](https://gitlab.com/gitlab-org/modelops/applied-ml/code-suggestions/ai-assist/-/blob/HEAD/ai_gateway/model_selection/models.yml)。
1. 在运行 极狐GitLab Duo CLI 时，将 `--model` 选项或 `GITLAB_DUO_MODEL` 环境变量设置为 `gitlab_identifier` 的值。

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

   例如，使用国内 SOTA 模型：

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

   例如，使用国内 SOTA 模型：

   ```shell
   duo --model gpt_5_codex
   ```

   ```shell
   GITLAB_DUO_MODEL=gpt_5_codex duo
   ```

   {{< /tab >}}

   {{< /tabs >}}

## 切换会话

极狐GitLab Duo Chat 会话会存储您的对话历史和工作流数据，并在 极狐GitLab Duo CLI、极狐GitLab UI 和编辑器扩展之间共享。

例如，您可以在浏览器中开始一个对话，然后在您的终端中继续。

要浏览并切换到一个会话：

1. 在交互模式下，输入 `/sessions` 并按 <kbd>Enter</kbd>。
1. 使用方向键浏览可用会话列表，或者输入文本来筛选列表。
1. 选择一个会话并按 <kbd>Enter</kbd>。

要在无头模式下切换到某个会话，请使用 `--existing-session-id` 选项。

## Model Context Protocol (MCP) 连接

要将 极狐GitLab Duo CLI 连接到本地或远程 MCP 服务器，请使用与 极狐GitLab IDE 扩展相同的 MCP 配置。有关说明，请参阅 [配置 MCP 服务器](../gitlab_duo/model_context_protocol/mcp_clients.md#configure-mcp-servers)。

## 选项

极狐GitLab Duo CLI 支持以下选项：

- `-C, --cwd <path>`: 更改工作目录。
- `-h, --help` : 显示 极狐GitLab Duo CLI 或特定命令的帮助信息。例如 `duo --help` 或
  `duo run --help`。
- `--log-level <level>`: 设置日志级别 (`debug`、`info`、`warn`、`error`)。
- `-v`, `--version`: 显示版本信息。
- `--enable-global-skills`: (实验性) 启用 [用户级 Agent 技能](../duo_agent_platform/customize/agent_skills.md#create-user-level-skills)。
- `--model <model>`: 选择要用于会话的 AI 模型。

无头模式的额外选项：

- `--ai-context-items <contextItems>`: JSON 编码的数组，包含用于参考的额外上下文条目。
- `--existing-session-id <sessionId>`: 要恢复到已有会话的 ID。
- `--gitlab-auth-token <token>`: 极狐GitLab 实例的认证令牌。
- `--gitlab-base-url <url>`: 极狐GitLab 实例的基础 URL（默认值：`https://jihulab.com`）。

## 命令

每种设置可用的命令如下：

{{< tabs >}}

{{< tab title="glab" >}}

- `glab duo cli`: 启动交互模式。
- `glab duo cli log`: 查看和管理日志。
  - `glab duo cli log last`: 打开最后一个日志文件。
  - `glab duo cli log list`: 列出所有日志文件。
  - `glab duo cli log tail <args...>`: 显示最后一个日志文件的尾部内容。
    支持标准的 tail 参数。
  - `glab duo cli log clear`: 清除所有现有的日志文件。
- `glab duo cli run`: 启动无头模式。

{{< /tab >}}

{{< tab title="duo" >}}

- `duo`: 启动交互模式。
- `duo config`: 管理配置和认证设置。
- `duo log`: 查看和管理日志。
  - `duo log last`: 打开最后一个日志文件。
  - `duo log list`: 列出所有日志文件。
  - `duo log tail <args...>`: 显示最后一个日志文件的尾部内容。
    支持标准的 tail 参数。
  - `duo log clear`: 清除所有现有的日志文件。
- `duo run`: 启动无头模式。

{{< /tab >}}

{{< /tabs >}}

## 环境变量

您可以使用环境变量配置 极狐GitLab Duo CLI：

- `DUO_WORKFLOW_GIT_HTTP_PASSWORD`: Git HTTP 认证密码。
- `DUO_WORKFLOW_GIT_HTTP_USER`: Git HTTP 认证用户名。
- `GITLAB_BASE_URL` 或 `GITLAB_URL`: 极狐GitLab 实例 URL。
- `GITLAB_DUO_MODEL`: 用于会话的 AI 模型。
- `GITLAB_ENABLE_GLOBAL_SKILLS`: (实验性) 启用 [用户级 Agent 技能](../duo_agent_platform/customize/agent_skills.md#create-user-level-skills)。
- `GITLAB_OAUTH_TOKEN` 或 `GITLAB_TOKEN`: 认证令牌。
- `LOG_LEVEL`: 日志级别。

## 代理和自定义证书配置

如果您的网络使用 HTTPS 拦截代理或需要自定义 SSL 证书，您可能需要进行额外配置。

### 代理配置

极狐GitLab Duo CLI 遵循标准的代理环境变量：

- `HTTP_PROXY` 或 `http_proxy`: HTTP 请求的代理 URL。
- `HTTPS_PROXY` 或 `https_proxy`: HTTPS 请求的代理 URL。
- `NO_PROXY` 或 `no_proxy`: 逗号分隔的主机列表，这些主机将不通过代理。

### 自定义 SSL 证书

如果您的组织使用了自定义的证书颁发机构 (CA)，用于 HTTPS 拦截代理或类似用途，您可能会遇到证书错误。

```plaintext
错误：无法验证第一个证书
错误：证书链中存在自签名证书
```

要解决证书错误，请使用以下方法之一：

- 使用系统证书存储（推荐）：
  - 如果您的 CA 证书已安装在操作系统证书存储中，请配置
    Node.js 使用它。需要 Node.js 22.15.0、23.9.0 或 24.0.0 及更高版本。
  - 如果您在容器中运行 极狐GitLab Duo CLI，请将 CA 证书安装在容器内的系统存储中，而不是主机系统存储中。

  ```shell
  export NODE_OPTIONS="--use-system-ca"
  ```

- 指定 CA 证书文件：
  - 对于较旧的 Node.js 版本，或者当 CA 证书不在系统存储中时，请直接
    将 Node.js 指向证书文件。该文件必须是 PEM 格式。
  - 如果您在容器中运行 极狐GitLab Duo CLI，请将路径设置为容器内的位置。
    使用卷挂载来提供证书文件。

  ```shell
  export NODE_EXTRA_CA_CERTS=/path/to/custom-ca.pem
  ```

### 忽略证书错误

如果您仍然遇到证书错误，您可以禁用证书验证。

> [!warning]
> 禁用证书验证会带来安全风险。
> 您不应在生产环境中禁用验证。

证书错误会提醒您潜在的安全漏洞，因此只有当您确信这样做是安全的时候，才应禁用证书验证。

前提条件：

- 您已在浏览器中验证了证书链，或者您的管理员已确认可以安全地忽略此错误。

要禁用证书验证：

```shell
export NODE_TLS_REJECT_UNAUTHORIZED=0
```

## 更新 极狐GitLab Duo CLI

要手动将 极狐GitLab Duo CLI 更新到最新版本，请根据您的设置运行相应的命令：

{{< tabs >}}

{{< tab title="glab" >}}

```shell
glab duo cli --update
```

{{< /tab >}}

{{< tab title="duo" >}}

```shell
npm install --global @gitlab/duo-cli@latest
```

{{< /tab >}}

{{< /tabs >}}

## 为 极狐GitLab Duo CLI 做贡献

有关为 极狐GitLab Duo CLI 做贡献的信息，请参阅 [开发指南](https://jihulab.com/gitlab-cn/editor-extensions/gitlab-lsp/-/blob/main/packages/cli/docs/development.md)。

## 相关主题

- [编辑器扩展的安全考虑](../../editor_extensions/security_considerations.md)
- [极狐GitLab CLI](https://gitlab.cn/docs/cli/)
- [自定义 极狐GitLab Duo Agent Platform](../duo_agent_platform/customize/_index.md)
- [极狐GitLab Duo Agent Platform 会话](../duo_agent_platform/sessions/_index.md)