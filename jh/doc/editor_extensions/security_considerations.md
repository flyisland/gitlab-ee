---
stage: AI-powered
group: Editor Extensions
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Security considerations for using GitLab editor extensions and CLI tools with local agent execution.
title: 编辑器扩展和 CLI 工具的安全注意事项
---

极狐GitLab 编辑器扩展和 CLI 工具可以在您的本地环境中运行 AI Agent。
了解安全影响并遵循最佳实践以保护您的开发环境。

<a id="local-agent-execution-risks"></a>

## 本地代理执行风险

当编辑器扩展和 CLI 工具在本地执行代理时，代理在没有容器隔离的情况下运行，并可直接访问您的系统资源。

<a id="file-system-access"></a>

### 文件系统访问

代理根据操作类型具有不同的文件访问级别。

<a id="file-operations"></a>

#### 文件操作

代理可以在以下对象上执行文件操作（读取、写入、编辑、搜索和列出）：

- 位于您的极狐GitLab 项目的 Git 仓库中的文件。
- 未被 `.gitignore` 规则排除的文件。
- 指向 Git 仓库内文件的有效或可解析符号链接。

<a id="shell-operations-on-files"></a>

#### 文件上的 Shell 操作

代理执行的 Shell 命令可以访问所有文件，包括 Git 仓库之外的文件以及与 `.gitignore` 模式匹配的文件。

<a id="environment-variable-access"></a>

### 环境变量访问

代理可以访问 Shell 会话中的所有环境变量，但以下除外：

- `CI_JOB_TOKEN`
- `GITLAB_OAUTH_TOKEN`
- `DUO_WORKFLOW_SERVICE_TOKEN`

<a id="system-resources"></a>

### 系统资源

代理可以访问以下系统资源：

- 网络请求：代理可以从您的工作站发起网络请求。
- 进程执行：代理可以在您的 Shell 环境中执行命令。

<a id="security-threats"></a>

### 安全威胁

由于没有隔离，可能出现以下威胁：

- 提示注入：恶意提示操纵代理行为并执行非预期操作。
- 代理泄露：受损代理提供对您工作站资源的访问。
- 数据外泄：工作站上的任何数据（包括敏感数据，如密码、源代码和个人文件）都可能被窃取。
- 横向移动：暴露的凭据可实现对其他系统和服务的访问。

<a id="recommended-security-practices"></a>

## 推荐的安全实践

为保护您的开发环境，请遵循以下安全最佳实践。

<a id="review-tool-calls-before-approval"></a>

### 在批准前审查工具调用

当代理请求您批准执行操作时，请在批准前仔细审查每个工具调用。

验证：

- 命令和文件操作与您的预期任务匹配。
- 文件路径（包括符号链接目标文件）在预期目录内。
- 命令参数不包含意外的标记或参数。
- 敏感文件访问和网络请求对任务是必要的。

您的管理员可以控制您是否可以为会话一次批准工具，而不是每次调用都需要批准。有关更多信息，请参见[工具审批](../user/gitlab_duo_chat/agentic_chat.md#tool-approvals)。

如果您在无头模式下使用极狐GitLab Duo CLI，工具调用将自动批准。谨慎使用无头模式，并在受控沙盒环境（如开发容器）中使用。

<a id="verify-mcp-server-sources-and-permissions"></a>

### 验证 MCP 服务器来源和权限

要通过极狐GitLab Duo 安全地使用模型上下文协议（MCP）服务器：

- 仅启用来自受信任来源的 MCP 服务器。
- 审查每个 MCP 服务器请求的权限和能力。
- 在启用 MCP 服务器之前，审查它们可以访问哪些数据。
- 定期审计您环境中启用了哪些 MCP 服务器。

<a id="use-development-containers-for-isolation"></a>

### 使用开发容器进行隔离

使用开发容器来减轻本地执行风险。

对于极狐GitLab Duo CLI 用户，无头模式绕过了手动工具批准，因此开发容器尤为重要。

开发容器提供：

- 进程隔离：在隔离的容器环境中运行代理，而不是直接在您的主机上。
- 有限的文件系统访问：配置容器以限制仅访问必要文件。
- 凭据隔离：单独管理凭据并根据需要将其注入容器。
- 网络隔离：限制容器网络以限制外部访问。