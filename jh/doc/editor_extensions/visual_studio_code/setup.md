---
stage: AI Clients
group: Developer Clients
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 使用 GitLab for VS Code 扩展直接在 VS Code 中处理常见的极狐GitLab 任务。
title: 安装并设置 GitLab for VS Code 扩展
---

要使用 GitLab for VS Code 扩展，请安装该扩展、连接到极狐GitLab，然后根据需要进行配置。

<a id="install-the-extension"></a>

## 安装扩展

选择满足您需求的安装方式：

- 对于标准 VS Code，请从 [Visual Studio Marketplace](https://marketplace.visualstudio.com/items?itemName=GitLab.gitlab-workflow) 安装。
- 对于非官方 VS Code 版本，请从 [Open VSX Registry](https://open-vsx.org/extension/GitLab/gitlab-workflow) 安装。
- 对于安全的本地开发，请在 Visual Studio Code Dev Container 中安装。

<a id="install-in-a-visual-studio-code-dev-container"></a>

### 在 Visual Studio Code Dev Container 中安装

为了增强安全性，请使用 [VS Code Dev Containers](https://code.visualstudio.com/docs/devcontainers/containers) 在容器化开发环境中设置该扩展并使用极狐GitLab Duo。

先决条件：

- 已安装并运行 [Docker](https://www.docker.com/products/docker-desktop/)。
- 已在 VS Code 中安装 Visual Studio Code [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) 扩展。

要在 VS Code Dev Container 中安装该扩展：

1. 从命令面板运行 **开发容器：添加开发容器配置文件** 命令。
1. 将 GitLab 扩展添加到配置文件中：

   ```json
   // .devcontainer/devcontainer.json
   {
   "name": "My Project",
   "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
   "customizations": {
      "vscode": {
         "extensions": [
         "GitLab.gitlab-workflow"
         ]
      }
   }
   }
   ```

1. 运行 **开发容器：在容器中打开文件夹** 命令，在 VS Code Dev Container 中打开您的项目。VS Code 会自动在容器内安装该扩展。

<a id="connect-to-gitlab"></a>

## 连接到极狐GitLab

安装扩展后，请进行身份验证，然后将您的项目连接到极狐GitLab 上的代码仓库。

<a id="authenticate-with-gitlab"></a>

### 通过极狐GitLab 进行身份验证

{{< tabs >}}

{{< tab title="JihuLab.com" >}}

先决条件：

- 使用 PAT 进行身份验证时，需要一个具有 `api` 作用域的[个人访问令牌](../../user/profile/personal_access_tokens.md#create-a-personal-access-token)。

要通过极狐GitLab 进行身份验证：

1. 在 VS Code 中，选择 **查看** > **命令面板**。
1. 输入 `GitLab: Authenticate` 并按 <kbd>Enter</kbd>。
1. 从选项中选择您的极狐GitLab 实例 URL，或手动输入一个。
   - 如果手动输入，请在 **极狐GitLab 实例的 URL**中粘贴完整 URL，包括 `http://` 或 `https://`。按 <kbd>Enter</kbd> 确认。
1. 选择身份验证方法：**OAuth** 或 **PAT**。
   - 对于 OAuth，请按照提示登录并进行身份验证。
   - 对于 PAT，请按照提示创建令牌或输入现有令牌进行身份验证。

{{< /tab >}}

{{< tab title="极狐GitLab 私有化部署" >}}

先决条件：

- 使用 OAuth 进行身份验证时，需要 [VS Code 的 OAuth 应用程序](../../administration/settings/editor_extensions.md#vs-code)的应用程序 ID。
- 使用 PAT 进行身份验证时，需要一个具有 `api` 作用域的[个人访问令牌](../../user/profile/personal_access_tokens.md#create-a-personal-access-token)。

要使用 OAuth，请先配置 OAuth 应用程序登录：

1. 在 VS Code 中，选择 **查看** > **命令面板**。
1. 输入 `Preferences: Open User Settings` 并按 <kbd>Enter</kbd>。
1. 选择 **设置** > **扩展** > **GitLab** > **身份验证**。
1. 在 **OAuth 客户端 ID** 下，选择 **添加条目**。
1. 选择 **键** 并输入极狐GitLab 实例 URL。
1. 选择 **值** 并输入 OAuth 应用程序的 ID。

要通过极狐GitLab 进行身份验证：

1. 在 VS Code 中，选择 **查看** > **命令面板**。
1. 输入 `GitLab: Authenticate` 并按 <kbd>Enter</kbd>。
1. 从选项中选择您的极狐GitLab 实例 URL，或手动输入一个。
   - 如果手动输入，请在 **极狐GitLab 实例的 URL**中粘贴完整 URL，包括 `http://` 或 `https://`。按 <kbd>Enter</kbd> 确认。
1. 选择身份验证方法：**OAuth** 或 **PAT**。
   - 对于 OAuth，请按照提示登录并进行身份验证。
   - 对于 PAT，请按照提示创建令牌或输入现有令牌进行身份验证。
{{< /tab >}}

{{< /tabs >}}

该扩展会将您的 Git 代码仓库远程 URL 与您为令牌指定的极狐GitLab 实例 URL 进行匹配。如果您有多个账号或项目，可以选择要使用的那个。

> [!note]
> 如果您的极狐GitLab 实例或网络使用自定义 SSL 设置，
> 您可以配置该扩展以支持自签名证书。更多信息，请参阅
> [将扩展与自签名证书配合使用](ssl.md#use-a-self-signed-ssl-certificate)。

<a id="connect-to-your-repository"></a>

### 连接到您的代码仓库

要从 VS Code 连接到您的极狐GitLab 代码仓库：

1. 在 VS Code 中，从顶部菜单选择 **终端** > **新终端**。
1. 克隆您的代码仓库：`git clone <repository>`。
1. 切换到克隆代码仓库的目录并检出您的分支：
   `git checkout <branch_name>`。
1. 确保已选择您的项目：
   1. 在左侧边栏中，选择 **GitLab**（{{< icon name="tanuki" >}}）。
   1. 选择项目名称。如果您有多个项目，请选择要使用的那个。
1. 在终端中，确保您的代码仓库已配置远程：`git remote -v`。结果应类似于：

   ```plaintext
   origin  git@gitlab.com:gitlab-org/gitlab.git (fetch)
   origin  git@gitlab.com:gitlab-org/gitlab.git (push)
   ```

   如果未定义远程，或者您有多个远程：

   1. 在左侧边栏中，选择 **源代码管理**（{{< icon name="branch" >}}）。
   1. 在 **源代码管理** 标签上，右键单击并选择 **代码仓库**。
   1. 在您的代码仓库旁边，选择省略号（{{< icon name=ellipsis_h >}}），然后选择
      **远程** > **添加远程**。
   1. 选择 **从极狐GitLab 添加远程**。
   1. 选择一个远程。

如果以下两个条件都满足，该扩展会在 VS Code 状态栏中显示信息：

- 您的项目针对最后一次提交有一个流水线。
- 您的当前分支与一个合并请求关联。

<a id="configure-the-extension"></a>

## 配置扩展

要配置设置，请转到 **设置** > **扩展** > **GitLab**。

<a id="configure-accounts-and-projects"></a>

### 配置账号和项目

在您完成身份验证并连接到代码仓库后，该扩展会根据您的 Git 代码仓库配置自动关联您的极狐GitLab 账号和项目。

在某些环境中，您可能需要额外配置才能保留您的凭据。

<a id="store-tokens-in-environment-variables"></a>

#### 将令牌存储在环境变量中

如果您经常删除 VS Code 存储（例如在 Gitpod 容器中），请将身份验证令牌存储在 [VS Code 环境变量](https://code.visualstudio.com/docs/editor/variables-reference#_environment-variables)中。删除 VS Code 存储后，环境变量仍会保留。

在启动 VS Code 之前设置这些变量：

- `GITLAB_WORKFLOW_INSTANCE_URL`：您的极狐GitLab 实例 URL。例如，`https://gitlab.com`。
- `GITLAB_WORKFLOW_TOKEN`：您的个人访问令牌。

如果您在扩展中为同一个极狐GitLab 实例配置了令牌，则扩展令牌会覆盖环境变量。

<a id="switch-accounts"></a>

#### 切换账号

该扩展为每个 [VS Code 工作区](https://code.visualstudio.com/docs/editing/workspaces/workspaces)（窗口）使用一个账号。在以下情况下，它会自动选择账号：

- 您在扩展中只使用一个极狐GitLab 账号进行身份验证。
- 根据 `git remote` 配置，您的 VS Code 窗口中的所有工作区都使用同一个极狐GitLab 账号。

如果存在多个极狐GitLab 账号，且该扩展无法确定要使用哪个账号，它会在状态栏中添加 **多个极狐GitLab 账号**（{{< icon name="question-o" >}}）。要选择极狐GitLab 账号，请选择该状态栏项并按照提示操作。

或者，您可以使用命令面板：

1. 在 VS Code 中，选择 **查看** > **命令面板**。
1. 运行命令 `GitLab: Select Account for this Workspace`。
1. 从列表中选择一个账号。

<a id="select-a-project"></a>

#### 选择项目

该扩展使用您的 Git 代码仓库远程来确定要与您的 VS Code 工作区关联的极狐GitLab 项目。

当您的 Git 代码仓库有多个指向不同极狐GitLab 项目的远程时，该扩展无法确定要使用哪一个。例如：

- `origin`：`git@gitlab.com:gitlab-org/gitlab-vscode-extension.git`
- `personal-fork`：`git@gitlab.com:myusername/gitlab-vscode-extension.git`

在这些情况下，该扩展会在状态栏中添加 **（多个项目）** 标签。

要选择项目：

1. 在左侧边栏中，选择 **GitLab**（{{< icon name="tanuki" >}}）。
1. 展开 **议题和合并请求**。
1. 选择包含 **（多个项目，单击以选择）**的行。
1. 从列表中选择一个项目。

**议题和合并请求** 列表会更新为您所选项目的信息。

<a id="change-the-project"></a>

#### 更改项目

要更改您选择的项目：

1. 在左侧边栏中，选择 **GitLab**（{{< icon name="tanuki" >}}）。
1. 展开 **议题和合并请求**。
1. 选择该项目。
1. 在项目名称旁边，选择 **清除所选项目**
   （{{< icon name="close-xs" >}}）。

<a id="configure-gitlab-duo"></a>

### 配置极狐GitLab Duo

当您满足先决条件时，VS Code 中默认启用极狐GitLab Duo 功能：

- 对于 Agent 功能，您满足[极狐GitLab Duo Agent Platform](../../user/duo_agent_platform/_index.md#prerequisites)的先决条件。
- 您已[开启](../../user/gitlab_duo/turn_on_off.md)极狐GitLab Duo。
- 对于任务流，您已[开启内置任务流](../../user/duo_agent_platform/flows/foundational_flows/_index.md#turn-foundational-flows-on-or-off)。
- 对于 Agent，您已根据需要[开启内置 Agent](../../user/duo_agent_platform/agents/foundational_agents/_index.md#turn-foundational-agents-on-or-off)
  并[启用自定义 Agent](../../user/duo_agent_platform/agents/custom.md#enable-an-agent)。
- 对于代码建议，您满足[其他先决条件](../../user/project/repository/code_suggestions/set_up.md#prerequisites)。
- 您的项目位于[群组命名空间](../../user/namespace/_index.md)中。
- 您已设置[默认极狐GitLab Duo 命名空间](../../user/profile/preferences.md#namespace-resolution-in-your-local-environment)，
  或已打开一个具有极狐GitLab Duo 访问权限的项目。

要每个会话批准一次 Agentic Chat 工具，而不是逐个批准，请参阅[工具审批](../../user/gitlab_duo_chat/agentic_chat.md#tool-approvals)。

<a id="turn-code-suggestions-on-or-off"></a>

#### 开启或关闭代码建议

当您满足上述先决条件时，代码建议默认开启。

要在 VS Code 中开启或关闭代码建议：

1. 在 VS Code 中，打开设置编辑器：
   - 对于 macOS，按 <kbd>Command</kbd>+<kbd>,</kbd>。
   - 对于 Windows 或 Linux，按 <kbd>Control</kbd>+<kbd>,</kbd>。
1. 选择 **扩展** > **GitLab** > **极狐GitLab Duo**。
1. 在 **GitLab › Duo 代码建议：已启用** 下，选中或清除该复选框。
1. 可选。要关闭特定语言的代码建议，请参阅
   [管理代码建议的语言](../../user/project/repository/code_suggestions/supported_extensions.md#manage-languages-for-code-suggestions)。

或者，您可以在 VS Code 的 `settings.json` 文件中[设置 `gitlab.duoCodeSuggestions.enabled`](settings.md#extension-settings)。

要在极狐GitLab 项目之外使用代码建议：

1. 在 VS Code 中，打开设置编辑器：
   - 对于 macOS，按 <kbd>Command</kbd>+<kbd>,</kbd>。
   - 对于 Windows 或 Linux，按 <kbd>Control</kbd>+<kbd>,</kbd>。
1. 选择 **扩展** > **GitLab** > **极狐GitLab Duo** > **GitLab › Duo：无极狐GitLab 项目时启用**。

<a id="turn-off-gitlab-duo"></a>

#### 关闭极狐GitLab Duo

要关闭 VS Code 中的极狐GitLab Duo 功能：

1. 在 VS Code 中，打开设置编辑器：
   - 对于 macOS，选择 **Code** > **首选项** > **设置**。
   - 对于 Windows 或 Linux，选择 **文件** > **首选项** > **设置**。
1. 选择 **扩展** > **GitLab** > **极狐GitLab Duo**。
1. 找到您要关闭的功能并清除该复选框。

<a id="configure-telemetry"></a>

### 配置遥测

GitLab for VS Code 使用 Visual Studio Code 中的遥测设置向极狐GitLab 发送使用情况和错误信息。要在 Visual Studio Code 中开启或自定义遥测：

1. 在 VS Code 中，打开设置编辑器：
   - 对于 macOS，选择 **Code** > **首选项** > **设置**。
   - 对于 Windows 或 Linux，选择 **文件** > **首选项** > **设置**。
1. 选择 **应用程序** > **遥测**。
1. 对于 **遥测级别**，选择您要共享的数据：
   - `all`：发送使用数据、一般错误遥测和崩溃报告。
   - `error`：发送一般错误遥测和崩溃报告。
   - `crash`：发送操作系统级崩溃报告。
   - `off`：禁用 Visual Studio Code 中的所有遥测数据。
1. 保存您的更改。
