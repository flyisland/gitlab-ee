---
stage: AI-powered
group: Editor Extensions
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Use the GitLab for VS Code extension to handle common GitLab tasks directly in VS Code.
title: 安装并设置极狐GitLab for VS Code 扩展
---

要使用极狐GitLab for VS Code 扩展，请安装扩展、连接到极狐GitLab，然后根据需要配置。

<a id="install-the-extension"></a>

## 安装扩展

选择满足你需求的安装方法：

- 对于标准 VS Code，从 [Visual Studio Marketplace](https://marketplace.visualstudio.com/items?itemName=GitLab.gitlab-workflow) 安装。
- 对于非官方 VS Code 版本，从 [Open VSX Registry](https://open-vsx.org/extension/GitLab/gitlab-workflow) 安装。
- 为了安全的本地开发环境，在 Visual Studio Code Dev Container 中安装。

<a id="install-in-a-visual-studio-code-dev-container"></a>

### 在 Visual Studio Code Dev Container 中安装

为了增强安全性，可以使用 [VS Code Dev Containers](https://code.visualstudio.com/docs/devcontainers/containers) 在容器化开发环境中设置扩展并使用极狐GitLab Duo。

先决条件：

- [Docker](https://www.docker.com/products/docker-desktop/) 已安装并正在运行。
- Visual Studio Code [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) 扩展已在 VS Code 中安装。

要在 VS Code Dev Container 中安装扩展：

1. 从命令面板运行 **Dev Containers: Add Dev Container Configuration Files** 命令。
1. 将极狐GitLab 扩展添加到配置文件中：

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

1. 运行 **Dev Containers: Open Folder in Container** 命令，在 VS Code Dev Container 中打开你的项目。VS Code 会自动在容器内安装扩展。

<a id="connect-to-gitlab"></a>

## 连接到极狐GitLab

安装扩展后，进行认证，然后将你的项目连接到极狐GitLab 上的仓库。

<a id="authenticate-with-gitlab"></a>

### 向极狐GitLab 认证

{{< history >}}

- 在极狐GitLab for VS Code 6.47.0 中，于极狐GitLab 18.3 版本发布期间，为私有化部署实例引入了 OAuth 认证。

{{< /history >}}

{{< tabs >}}

{{< tab title="JihuLab.com" >}}

先决条件：

- 对于使用 PAT 认证，需要一个具有 `api` 权限的[个人访问令牌](../../user/profile/personal_access_tokens.md#create-a-personal-access-token)。

要向极狐GitLab 认证：

1. 打开命令面板：
   - 对于 macOS，按下 <kbd>Command</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd>。
   - 对于 Windows 或 Linux，按下 <kbd>Control</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd>。
1. 输入 `GitLab: Authenticate` 并按下 <kbd>Enter</kbd>。
1. 从选项中选择你的极狐GitLab 实例 URL，或手动输入。
   - 如果手动输入，在 **URL to GitLab instance** 中粘贴完整 URL，包括 `http://` 或 `https://`。按下 <kbd>Enter</kbd> 确认。
1. 选择一种认证方式，**OAuth** 或 **PAT**。
   - 对于 OAuth，按照提示登录并认证。
   - 对于 PAT，按照提示创建令牌或输入已有令牌进行认证。

{{< /tab >}}

{{< tab title="极狐GitLab 私有化部署" >}}

先决条件：

- 对于使用 OAuth 认证，需要[VS Code 的 OAuth 应用程序](../../administration/settings/editor_extensions.md#vs-code)的应用程序 ID。
- 对于使用 PAT 认证，需要一个具有 `api` 权限的[个人访问令牌](../../user/profile/personal_access_tokens.md#create-a-personal-access-token)。

要使用 OAuth，首先配置 OAuth 应用程序登录：

1. 打开命令面板：
   - 对于 macOS，按下 <kbd>Command</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd>。
   - 对于 Windows 或 Linux，按下 <kbd>Control</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd>。
1. 输入 `Preferences: Open User Settings` 并按下 <kbd>Enter</kbd>。
1. 选择 **设置** > **扩展** > **GitLab** > **Authentication**。
1. 在 **OAuth Client IDs** 下，选择 **添加项**。
1. 选择 **Key** 并输入极狐GitLab 实例 URL。
1. 选择 **Value** 并输入 OAuth 应用程序的 ID。

要向极狐GitLab 认证：

1. 打开命令面板：
   - 对于 macOS，按下 <kbd>Command</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd>。
   - 对于 Windows 或 Linux，按下 <kbd>Control</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd>。
1. 输入 `GitLab: Authenticate` 并按下 <kbd>Enter</kbd>。
1. 从选项中选择你的极狐GitLab 实例 URL，或手动输入。
   - 如果手动输入，在 **URL to GitLab instance** 中粘贴完整 URL，包括 `http://` 或 `https://`。按下 <kbd>Enter</kbd> 确认。
1. 选择一种认证方式，**OAuth** 或 **PAT**。
   - 对于 OAuth，按照提示登录并认证。
   - 对于 PAT，按照提示创建令牌或输入已有令牌进行认证。
{{< /tab >}}

{{< /tabs >}}

该扩展会将你的 Git 仓库远程 URL 与你为令牌指定的极狐GitLab 实例 URL 进行匹配。如果你有多个账号或项目，可以选择你想使用的那个。

> [!note]
> 如果您的极狐GitLab 实例或网络使用了自定义 SSL 设置，
> 你可以配置扩展以支持自签名证书。更多信息，请参见
> [在自签名证书环境中使用扩展](ssl.md)。

<a id="connect-to-your-repository"></a>

### 连接到你的仓库

要从 VS Code 连接到你的极狐GitLab 仓库：

1. 在 VS Code 中，在顶部菜单选择 **终端** > **新终端**。
1. 克隆你的仓库：`git clone <repository>`。
1. 切换到仓库克隆所在的目录，并检出你的分支：`git checkout <branch_name>`。
1. 确保你的项目已选中：
   1. 在左侧边栏，选择 **GitLab** ({{< icon name="tanuki" >}})。
   1. 选择项目名称。如果你有多个项目，选择你想使用的那个。
1. 在终端中，确保你的仓库已配置远程：`git remote -v`。结果应类似于：

   ```plaintext
   origin  git@gitlab.com:gitlab-org/gitlab.git (fetch)
   origin  git@gitlab.com:gitlab-org/gitlab.git (push)
   ```

   如果未定义远程，或者你有多个远程：

   1. 在左侧边栏，选择 **源代码管理** ({{< icon name="branch" >}})。
   1. 在 **源代码管理** 标签上，右键单击并选择 **存储库**。
   1. 在你的仓库旁边，选择省略号 ({{< icon name=ellipsis_h >}})，然后选择 **远程** > **添加远程存储库**。
   1. 选择 **从 GitLab 添加远程存储库**。
   1. 选择一个远程。

如果满足以下两个条件，扩展会在 VS Code 状态栏中显示信息：

- 你的项目有针对最后一次提交的流水线。
- 你当前的分支关联了合并请求。

<a id="configure-the-extension"></a>

## 配置扩展

要配置设置，请前往 **设置** > **扩展** > **GitLab**。

<a id="configure-accounts-and-projects"></a>

### 配置账号和项目

在你认证并连接到仓库后，扩展会根据你的 Git 仓库配置自动关联你的极狐GitLab 账号和项目。

在某些环境中，你可能需要额外配置来持久化你的凭据。

<a id="store-tokens-in-environment-variables"></a>

#### 在环境变量中存储令牌

如果你经常删除 VS Code 的存储（例如在 Gitpod 容器中），请将你的认证令牌存储在 [VS Code 环境变量](https://code.visualstudio.com/docs/editor/variables-reference#_environment-variables)中。环境变量在你删除 VS Code 存储时依然会保留。

在启动 VS Code 之前设置这些变量：

- `GITLAB_WORKFLOW_INSTANCE_URL`：你的极狐GitLab 实例 URL。例如，`https://gitlab.com`。
- `GITLAB_WORKFLOW_TOKEN`：你的个人访问令牌。

如果你在扩展中为同一个极狐GitLab 实例配置了令牌，扩展令牌会覆盖环境变量。

<a id="switch-accounts"></a>

#### 切换账号

该扩展为每个 [VS Code 工作区](https://code.visualstudio.com/docs/editor/workspaces)（窗口）使用一个账号。在以下情况下，它会自动选择账号：

- 你在扩展中仅认证了一个极狐GitLab 账号。
- VS Code 窗口中的所有工作区根据 `git remote` 配置使用了相同的极狐GitLab 账号。

如果存在多个极狐GitLab 账号并且扩展无法确定使用哪个账号，它会在状态栏添加 **多个极狐GitLab 账号** ({{< icon name="question-o" >}})。要选择一个极狐GitLab 账号，选择状态栏项目并按照提示进行操作。

或者，你可以使用命令面板：

1. 打开命令面板：
   - 对于 macOS，按下 <kbd>Command</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd>。
   - 对于 Windows 或 Linux，按下 <kbd>Control</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd>。
1. 运行命令 `GitLab: Select Account for this Workspace`。
1. 从列表中选择一个账号。

<a id="select-a-project"></a>

#### 选择项目

该扩展使用你的 Git 仓库远程来确定将哪个极狐GitLab 项目与你的工作区关联。

当你的 Git 仓库有多个指向不同极狐GitLab 项目的远程时，扩展无法确定使用哪个。例如：

- `origin`：`git@gitlab.com:gitlab-org/gitlab-vscode-extension.git`
- `personal-fork`：`git@gitlab.com:myusername/gitlab-vscode-extension.git`

在这些情况下，扩展会在状态栏添加一个 **(多个项目)** 标签。

要选择一个项目：

1. 在左侧边栏，选择 **GitLab** ({{< icon name="tanuki" >}})。
1. 展开 **议题和合并请求**。
1. 选择包含 **(多个项目，点击选择)** 的行。
1. 从列表中选择一个项目。

**议题和合并请求** 列表会更新为你所选项目的信息。

<a id="change-the-project"></a>

#### 更改项目

要更改你的项目选择：

1. 在左侧边栏，选择 **GitLab** ({{< icon name="tanuki" >}})。
1. 展开 **议题和合并请求**。
1. 选择项目。
1. 在项目名称旁边，选择 **清除所选项目** ({{< icon name="close-xs" >}})。

<a id="configure-gitlab-duo"></a>

### 配置极狐GitLab Duo

当你满足先决条件时，极狐GitLab Duo 功能在 VS Code 中默认启用：

- 对于 Agentic 功能，需满足 [极狐GitLab Duo Agent Platform](../../user/duo_agent_platform/_index.md#prerequisites) 的先决条件。
- 你已[开启](../../user/gitlab_duo/turn_on_off.md)极狐GitLab Duo。
- 对于功能流（Flows），你已[开启基础功能流（Flows）](../../user/duo_agent_platform/flows/foundational_flows/_index.md#turn-foundational-flows-on-or-off)。
- 对于 Agent（Agents），你已根据需要[开启内置 Agent（Agents）](../../user/duo_agent_platform/agents/foundational_agents/_index.md#turn-foundational-agents-on-or-off)并[启用自定义 Agent（Agents）](../../user/duo_agent_platform/agents/custom.md#enable-an-agent)。
- 你的项目在[群组命名空间](../../user/namespace/_index.md)中。
- 你已设置[默认的极狐GitLab Duo 命名空间](../../user/profile/preferences.md#namespace-resolution-in-your-local-environment)，或者打开了一个可访问极狐GitLab Duo 的项目。
- 对于极狐GitLab Duo 代码建议，你[满足额外的先决条件](../../user/project/repository/code_suggestions/set_up.md#prerequisites)。

要每会话批准一次 Agentic Chat 工具，而不是逐个批准，请参阅[工具批准](../../user/gitlab_duo_chat/agentic_chat.md#tool-approvals)。

<a id="turn-off-gitlab-duo"></a>

#### 关闭极狐GitLab Duo

要在 VS Code 中关闭极狐GitLab Duo 功能：

1. 在 VS Code 中，打开设置编辑器：
   - 对于 macOS，按下 <kbd>Command</kbd>+<kbd>,</kbd>。
   - 对于 Windows 或 Linux，按下 <kbd>Control</kbd>+<kbd>,</kbd>。
1. 选择 **扩展** > **GitLab** > **GitLab Duo**。
1. 找到你想关闭的功能并清除其复选框。

<a id="configure-telemetry"></a>

### 配置遥测

极狐GitLab for VS Code 使用 Visual Studio Code 中的遥测设置向极狐GitLab 发送使用情况和错误信息。要在 Visual Studio Code 中启用或自定义遥测：

1. 在 VS Code 中，打开设置编辑器：
   - 对于 macOS，按下 <kbd>Command</kbd>+<kbd>,</kbd>。
   - 对于 Windows 或 Linux，按下 <kbd>Control</kbd>+<kbd>,</kbd>。
1. 选择 **应用程序** > **遥测**。
1. 对于 **遥测级别**，选择你要共享的数据：
   - `all`：发送使用情况数据、一般错误遥测和崩溃报告。
   - `error`：发送一般错误遥测和崩溃报告。
   - `crash`：发送操作系统级别的崩溃报告。
   - `off`：禁用 Visual Studio Code 中的所有遥测数据。
1. 保存你的更改。