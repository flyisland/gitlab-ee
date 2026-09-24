---
stage: AI Clients
group: Developer Clients
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 为极狐GitLab Duo CLI 配置钩子、自定义斜杠命令、插件和网络设置。
title: 自定义极狐GitLab Duo CLI
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

极狐GitLab Duo CLI 支持以下自定义功能：

- 使用钩子在极狐GitLab Duo CLI 生命周期的特定时点运行自定义命令。
- 使用自定义斜杠命令，让 CLI 更好地契合您的工作流程或使用场景。
- 使用插件从市场安装 Agent Skills、自定义斜杠命令和模型上下文协议（MCP）
  服务器。
- 使用为极狐GitLab Duo Agent Platform 设置的[自定义指令](../duo_agent_platform/customize/_index.md)，以匹配您的工作流程、编码标准或
  项目要求。

<a id="hooks"></a>

## 钩子

{{< details >}}

- Status: 实验

{{< /details >}}

使用钩子在极狐GitLab Duo CLI 生命周期的特定时点运行自定义命令。

例如，您可以通过运行一个收集环境信息的脚本，为每个新的聊天会话注入额外的上下文。

极狐GitLab Duo CLI 支持两个级别的钩子：

- 用户级（全局）：适用于您的所有项目。
- 项目级：仅适用于特定项目。项目级钩子默认禁用，以防止运行检出代码仓库中的任意代码。

当用户级和项目级 `hooks.json` 文件同时存在时，CLI 会合并这些钩子，并先运行用户级的钩子。

> [!note]
> 出于安全原因，敏感环境变量（`GITLAB_TOKEN`、`GITLAB_OAUTH_TOKEN`、`CI_JOB_TOKEN`）会从钩子进程中排除。

<a id="hook-execution"></a>

### 钩子执行

当钩子运行时，极狐GitLab Duo CLI 会：

1. 将会话元数据的 JSON 对象发送到命令的标准输入：

   ```json
   {
     "session_id": "abc-123",
     "cwd": "/path/to/project",
     "transcript_path": "",
     "hook_event_name": "SessionStart",
     "source": "startup"
   }
   ```

1. 为钩子进程设置环境变量 `DUO_SESSION_ID` 和 `DUO_PROJECT_DIR`。
1. 收集命令的标准输出，作为会话的额外上下文。

钩子可以在标准输出上返回纯文本或 JSON 对象：

```json
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "Your context string here"
  }
}
```

如果钩子以非零状态退出或超时，会记录为警告，但不会阻止会话启动。

<a id="create-hooks"></a>

### 创建钩子

极狐GitLab Duo CLI 支持 `SessionStart` 事件，该事件在新会话启动或现有会话恢复时运行。

要创建钩子：

1. 创建 `hooks.json` 文件：
   - 对于用户级钩子：
     - 在 Linux 或 macOS 上，在 `~/.gitlab/duo/hooks.json` 创建文件。
     - 在 Windows 上，在 `%APPDATA%\GitLab\duo\hooks.json` 创建文件。
   - 对于项目级钩子，在项目根目录创建文件：`<project>/.gitlab/duo/hooks.json`。
1. 在文件中定义您的钩子。
   - 为每个应触发钩子的 `SessionStart` 事件源（`startup`
     或 `resume`）创建一个匹配器组。
   - 每个匹配器组有一个可选的正则表达式 `matcher` 值和一个命令钩子数组：

     | 字段 | 描述 |
     |-------|-------------|
     | `matcher` | 可选。针对事件源（对于 `SessionStart` 为 `startup` 或 `resume`）测试的正则表达式。省略则匹配所有。 |
     | `hooks[].type` | 必须为 `"command"`。 |
     | `hooks[].command` | 要执行的 shell 命令。 |
     | `hooks[].timeout` | 可选。超时时间（秒）。默认值：30。 |

   - 例如：

     ```json
     {
       "hooks": {
         "SessionStart": [
           {
             "matcher": "startup",
             "hooks": [
               {
                 "type": "command",
                 "command": "cat ~/.my-coding-preferences.md",
                 "timeout": 10
               }
             ]
          }
         ]
       }
     }
     ```

1. 如果您有项目级钩子，请在启动极狐GitLab Duo CLI 时启用它们：

   {{< tabs >}}

   {{< tab title="glab" >}}

   ```shell
   glab duo cli --enable-project-hooks
   ```

   {{< /tab >}}

   {{< tab title="duo" >}}

   ```shell
   duo --enable-project-hooks
   ```

   {{< /tab >}}

   {{< /tabs >}}

   或者，设置环境变量：

   ```shell
   export GITLAB_ENABLE_PROJECT_HOOKS=true
   ```

<a id="custom-slash-commands"></a>

## 自定义斜杠命令

为您经常使用的提示创建自定义斜杠命令。

极狐GitLab Duo CLI 支持两个级别的自定义斜杠命令：

- 用户级：适用于您的所有项目。
- 项目级：仅适用于特定项目。

如果用户级命令和项目级命令同名，则项目级命令
优先。自定义斜杠命令不能覆盖内置斜杠命令或
[Agent Skills 斜杠命令](../duo_agent_platform/customize/agent_skills.md#expose-skills-as-slash-commands)。

<a id="create-a-custom-slash-command"></a>

### 创建自定义斜杠命令

要创建自定义斜杠命令，您需要创建一个 Markdown 文件。

文件名是命令名称，文件内容是提示。

例如，名为 `daily.md` 的文件会创建 `/daily` 命令：

1. 创建 `commands` 目录：
   - 对于项目级命令，在项目根目录创建目录：
     `<project>/.agents/commands/`。
   - 对于用户级命令，使用以下位置之一：
     - 要将您的命令与其他极狐GitLab Duo 自定义文件放在一起：
       - 在 Linux 或 macOS 上，在 `~/.gitlab/duo/commands/` 创建目录。
       - 在 Windows 上，在 `%APPDATA%\GitLab\duo\commands\` 创建目录。
       - 如果您已设置 `GLAB_CONFIG_DIR` 或 `XDG_CONFIG_HOME`，请使用 `$GLAB_CONFIG_DIR/commands/`
         或 `$XDG_CONFIG_HOME/gitlab/duo/commands/`。如果两者都设置了，`GLAB_CONFIG_DIR` 优先。
     - 要与其他 AI 工具共享命令：
       - 在 Linux 或 macOS 上，在 `~/.agents/commands/` 创建目录。
       - 在 Windows 上，在 `%USERPROFILE%\.agents\commands\` 创建目录。
1. 在该目录中，创建一个 Markdown 文件。
   使用命令名称作为文件名。
   命令名称必须以字母或数字开头，并且只能包含字母、数字、
   连字符和下划线。
1. 将提示添加到文件中。
1. 可选。在文件顶部的 YAML front matter 中添加 `description` 字段。
   该描述会显示在斜杠命令菜单中命令的旁边。

   例如，在 `daily.md` 中定义的 `/daily` 命令：

   ```markdown
   ---
   description: Prepare a daily report
   ---

   Use `glab todo list` to fetch my open TODO items. Give me a concise morning report ranked by priority.
   ```

1. 重启极狐GitLab Duo CLI。CLI 会在启动时发现自定义斜杠命令。

<a id="use-a-custom-slash-command"></a>

### 使用自定义斜杠命令

在交互模式下，在提示符处输入斜杠命令并按 <kbd>Enter</kbd>。
极狐GitLab Duo CLI 会将文件内容作为提示发送。

您在命令名称后输入的任何文本都会附加到提示的末尾。

使用附加文本来定制该自定义斜杠命令的行为。

例如，`/daily prioritize my milestone deliverables`。

<a id="plugins"></a>

## 插件

{{< details >}}

- Status: 实验

{{< /details >}}

使用插件扩展极狐GitLab Duo CLI 的附加功能。

插件是一个目录，捆绑了极狐GitLab Duo CLI 的扩展。插件可以捆绑
[Agent Skills](../duo_agent_platform/customize/agent_skills.md)、
[自定义斜杠命令](#custom-slash-commands)和
[MCP 服务器](../gitlab_duo/model_context_protocol/mcp_clients.md)。

市场是位于 Git 仓库或本地目录中的可用插件清单。`marketplace.json` 文件列出可用的插件及其
查找位置。

要使用插件，您需要先注册包含该插件的市场，然后从该市场安装插件。插件标识为 `<plugin>@<marketplace>`。

为了与现有社区插件生态系统兼容，极狐GitLab Duo CLI 也会读取
`.claude-plugin/marketplace.json` 文件。现有的插件市场无需修改即可与极狐GitLab Duo CLI 配合使用。

极狐GitLab Duo CLI 还支持遵循
[Agent Plugins 规范](https://agent-plugins.org)的插件，这是一个开放、供应商中立的
AI Agent 组件打包标准。

先决条件：

- [设置极狐GitLab Duo CLI](set_up.md)。
- Git，如果您想从 Git 仓库添加市场。

<a id="register-a-marketplace"></a>

### 注册市场

在安装插件之前，您必须注册包含该插件的市场。

首次使用插件时，极狐GitLab Duo CLI 会自动注册官方 GitLab
市场，[`gitlab-duo-plugins`](https://gitlab.com/gitlab-org/ai/gitlab-duo-plugins)。
如果您移除了此市场，极狐GitLab Duo CLI 不会再次注册它。

要注册市场：

{{< tabs >}}

{{< tab title="glab" >}}

```shell
glab duo plugin marketplace add <source>
```

{{< /tab >}}

{{< tab title="duo" >}}

```shell
duo plugin marketplace add <source>
```

{{< /tab >}}

{{< /tabs >}}

`<source>` 是以下之一：

| 源类型      | 格式                                                                                     | 示例                                          |
|-------------------|---------------------------------------------------------------------------------------------|---------------------------------------------------|
| Git 仓库    | `git clone` 接受的 URL。可选地附加 `#<ref>` 以固定分支或标签。          | `https://gitlab.com/group/marketplace.git#stable` |
| 本地目录   | 绝对或相对路径。`~` 会展开为您的主目录。                       | `~/marketplaces/internal`                        |

例如：

{{< tabs >}}

{{< tab title="glab" >}}

```shell
glab duo plugin marketplace add https://gitlab.com/example-group/example-marketplace.git
```

```shell
glab duo plugin marketplace add ~/marketplaces/internal
```

{{< /tab >}}

{{< tab title="duo" >}}

```shell
duo plugin marketplace add https://gitlab.com/example-group/example-marketplace.git
```

```shell
duo plugin marketplace add ~/marketplaces/internal
```

{{< /tab >}}

{{< /tabs >}}

极狐GitLab Duo CLI 通过其 `marketplace.json` 文件中的 `name` 字段来识别市场。

<a id="automatically-update-plugins-from-a-marketplace"></a>

#### 从市场自动更新插件

要自动更新您从市场安装的插件，请使用
`--auto-update` 选项注册市场：

{{< tabs >}}

{{< tab title="glab" >}}

```shell
glab duo plugin marketplace add <source> --auto-update
```

{{< /tab >}}

{{< tab title="duo" >}}

```shell
duo plugin marketplace add <source> --auto-update
```

{{< /tab >}}

{{< /tabs >}}

当极狐GitLab Duo CLI 启动时，它会在后台更新您从此市场安装的插件，无需确认。当插件更新时，极狐GitLab Duo CLI 会提示您
重启以加载新版本。

<a id="list-registered-marketplaces"></a>

#### 列出已注册的市场

要列出您已注册的市场：

{{< tabs >}}

{{< tab title="glab" >}}

```shell
glab duo plugin marketplace list
```

{{< /tab >}}

{{< tab title="duo" >}}

```shell
duo plugin marketplace list
```

{{< /tab >}}

{{< /tabs >}}

对于每个市场，极狐GitLab Duo CLI 会显示：

- 市场来源。
- 市场上次更新时间。
- 市场拥有的插件数量。
- 是否为市场启用了自动更新。

<a id="list-available-marketplace-plugins"></a>

#### 列出可用的市场插件

要列出市场提供的插件：

{{< tabs >}}

{{< tab title="glab" >}}

```shell
glab duo plugin marketplace show <name>
```

{{< /tab >}}

{{< tab title="duo" >}}

```shell
duo plugin marketplace show <name>
```

{{< /tab >}}

{{< /tabs >}}

对于每个插件，极狐GitLab Duo CLI 会显示版本、描述以及插件的安装位置（如果已安装）。

<a id="update-a-marketplace"></a>

#### 更新市场

要从其来源刷新市场的插件清单：

{{< tabs >}}

{{< tab title="glab" >}}

```shell
glab duo plugin marketplace update <name>
```

{{< /tab >}}

{{< tab title="duo" >}}

```shell
duo plugin marketplace update <name>
```

{{< /tab >}}

{{< /tabs >}}

<a id="remove-a-marketplace"></a>

#### 移除市场

要移除已注册的市场：

{{< tabs >}}

{{< tab title="glab" >}}

```shell
glab duo plugin marketplace remove <name>
```

{{< /tab >}}

{{< tab title="duo" >}}

```shell
duo plugin marketplace remove <name>
```

{{< /tab >}}

{{< /tabs >}}

> [!warning]
> 移除市场也会卸载您从中安装的所有插件。

<a id="install-and-manage-plugins"></a>

### 安装和管理插件

安装插件时，您需要选择作用域。作用域决定极狐GitLab Duo CLI 更新哪个配置文件，以及安装适用于谁。

| 作用域               | 配置文件                          | 用途                                                            |
|----------------------|----------------------------------------------|------------------------------------------------------------------------|
| `user`（默认）     | `<config dir>/plugins.json`                 | 适用于您所有项目的插件。                                       |
| `project`            | 项目中的 `.gitlab/duo/plugins.json`   | 团队共享的插件。将此文件提交到您的代码仓库。           |
| `local`              | 项目中的 `.gitlab/duo/plugins.local.json` | 个人、按项目划分的插件。将此文件添加到您的 `.gitignore`。 |

`<config dir>` 在 Linux 和 macOS 上是 `~/.gitlab/duo`，在 Windows 上是 `%APPDATA%\GitLab\duo`。

要从已注册的市场安装插件：

{{< tabs >}}

{{< tab title="glab" >}}

```shell
glab duo plugin install <plugin>@<marketplace> [--scope user|project|local]
```

{{< /tab >}}

{{< tab title="duo" >}}

```shell
duo plugin install <plugin>@<marketplace> [--scope user|project|local]
```

{{< /tab >}}

{{< /tabs >}}

如果您未指定 `--scope`，极狐GitLab Duo CLI 会使用 `user` 作用域。

例如：

{{< tabs >}}

{{< tab title="glab" >}}

```shell
glab duo plugin install my-plugin@my-marketplace
```

```shell
glab duo plugin install my-plugin@my-marketplace --scope project
```

{{< /tab >}}

{{< tab title="duo" >}}

```shell
duo plugin install my-plugin@my-marketplace
```

```shell
duo plugin install my-plugin@my-marketplace --scope project
```

{{< /tab >}}

{{< /tabs >}}

<a id="enabled-state-after-installation"></a>

#### 安装后的启用状态

安装插件时，极狐GitLab Duo CLI 会在作用域的配置文件中记录该插件是否启用。为确定初始状态，极狐GitLab Duo CLI 按优先级顺序使用：

1. 您之前为目标作用域或更广泛作用域中的插件记录的任何启用或禁用设置。例如，如果您禁用了插件，卸载了它，然后重新安装，该插件将保持禁用状态。
1. 插件在市场清单条目中的 `defaultEnabled` 值。
1. 插件 `plugin.json` 清单中的 `defaultEnabled` 值。

如果这些均未设置，则插件为启用状态。

<a id="list-installed-plugins"></a>

#### 列出已安装的插件

要列出您已安装的插件：

{{< tabs >}}

{{< tab title="glab" >}}

```shell
glab duo plugin list
```

{{< /tab >}}

{{< tab title="duo" >}}

```shell
duo plugin list
```

{{< /tab >}}

{{< /tabs >}}

已安装的插件按作用域分组，列表会显示每个插件是否已启用。

<a id="enable-or-disable-a-plugin"></a>

#### 启用或禁用插件

当您启用、禁用或卸载插件时，您可以仅凭其名称来标识它。如果
同一插件名称从多个市场安装，请使用完整的 `<plugin>@<marketplace>`
标识符。

要启用或禁用已安装的插件：

{{< tabs >}}

{{< tab title="glab" >}}

```shell
glab duo plugin enable <plugin> [--scope user|project|local]
glab duo plugin disable <plugin> [--scope user|project|local]
```

{{< /tab >}}

{{< tab title="duo" >}}

```shell
duo plugin enable <plugin> [--scope user|project|local]
duo plugin disable <plugin> [--scope user|project|local]
```

{{< /tab >}}

{{< /tabs >}}

如果您在多个作用域启用或禁用插件，最具体的作用域优先：
`local`，然后是 `project`，然后是 `user`。

<a id="update-a-plugin"></a>

#### 更新插件

要将插件更新到其市场提供的最新版本：

{{< tabs >}}

{{< tab title="glab" >}}

```shell
glab duo plugin update <plugin>@<marketplace>
```

{{< /tab >}}

{{< tab title="duo" >}}

```shell
duo plugin update <plugin>@<marketplace>
```

{{< /tab >}}

{{< /tabs >}}

更新适用于安装该插件的所有作用域。

<a id="uninstall-a-plugin"></a>

#### 卸载插件

要卸载插件：

{{< tabs >}}

{{< tab title="glab" >}}

```shell
glab duo plugin uninstall <plugin> [--scope user|project|local]
```

{{< /tab >}}

{{< tab title="duo" >}}

```shell
duo plugin uninstall <plugin> [--scope user|project|local]
```

{{< /tab >}}

{{< /tabs >}}

卸载会从您的配置中移除该插件。

<a id="use-an-installed-plugin"></a>

### 使用已安装的插件

安装并启用插件后，极狐GitLab Duo CLI 会在下次启动时发现插件捆绑的所有内容：

- Skills 的可用方式与其他 Agent Skills 相同。
- 自定义斜杠命令会出现在斜杠命令菜单中。内置斜杠命令、Agent Skills
  斜杠命令以及您自己的自定义斜杠命令优先于同名的插件命令。
- MCP 服务器会与您已配置的 MCP 服务器一起加载，并且需要
  [工具审批](../gitlab_duo/model_context_protocol/mcp_clients.md#configure-tool-approval)，方式相同。为标识服务器来源，极狐GitLab Duo CLI 会在服务器名称前加上插件名称。

<a id="create-a-marketplace"></a>

### 创建市场

要创建市场，请在 Git 仓库或本地目录的根目录添加 `marketplace.json` 文件。例如：

```json
{
  "name": "my-marketplace",
  "owner": {
    "name": "Your Name"
  },
  "plugins": [
    {
      "name": "my-plugin",
      "source": "./plugins/my-plugin",
      "description": "A short description of the plugin."
    }
  ]
}
```

`plugins` 中的每个条目必须将 `source` 设置为相对于市场根目录的路径，并以
`./` 开头。

<a id="create-a-plugin"></a>

### 创建插件

插件是一个目录，包含可选的 `plugin.json` 清单以及插件捆绑的扩展：skills、自定义斜杠命令和 MCP 服务器。

`plugin.json` 清单支持以下字段：

| 字段             | 必填 | 描述                                              |
|--------------------|----------|--------------------------------------------------------------|
| `name`             | 是      | 插件名称。                                            |
| `version`          | 否       | 插件版本。                                         |
| `description`      | 否       | 插件的简短描述。                            |
| `defaultEnabled`   | 否       | 安装时插件是否默认启用。      |

例如：

```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "description": "A short description of the plugin.",
  "defaultEnabled": true
}
```

为了与现有社区插件兼容，极狐GitLab Duo CLI 也会从
`.claude-plugin/plugin.json` 读取清单。

要为您的插件捆绑扩展：

- Skills：在插件的 `skills/<skill-name>/` 目录中添加 `SKILL.md` 文件。有关
  `SKILL.md` 文件格式，请参阅[创建 skills](../duo_agent_platform/customize/agent_skills.md#create-skills)。
- 自定义斜杠命令：在插件的 `commands/` 目录中添加一个 Markdown 文件。文件名
  是命令名称，文件格式与
  [自定义斜杠命令](#create-a-custom-slash-command)相同。
- MCP 服务器：
  - 推荐：在插件根目录添加 `mcp.json` 文件，格式由
    [Agent Plugins 规范](https://agent-plugins.org/specification#72-mcp-servers)定义。使用
    `${PLUGIN_ROOT}` 变量引用插件内的文件，并使用 `${PLUGIN_DATA}`
    变量引用一个持久的、可写的目录，该目录在插件更新后仍然存在。
  - 为了与现有社区插件兼容，您也可以添加 `.mcp.json` 文件，格式与
    [MCP 配置格式](../gitlab_duo/model_context_protocol/mcp_clients.md#configuration-format)相同。
    使用 `${DUO_PLUGIN_ROOT}` 变量引用插件内的文件。

  如果插件同时具有 `mcp.json` 和 `.mcp.json`，极狐GitLab Duo CLI 仅使用 `mcp.json`。

例如，一个市场仓库包含一个捆绑了 skill、自定义斜杠命令
和 MCP 服务器的插件：

```plaintext
my-marketplace/
├── marketplace.json
└── plugins/
    └── my-plugin/
        ├── plugin.json
        ├── mcp.json
        ├── commands/
        │   └── my-command.md
        └── skills/
            └── my-skill/
                └── SKILL.md
```

极狐GitLab Duo CLI 按优先级顺序确定插件的版本：

1. 插件 `plugin.json` 中的 `version` 字段。
1. 市场 `marketplace.json` 中插件条目的 `version` 字段。

如果两个字段均未设置，则插件版本为 `unknown`。
