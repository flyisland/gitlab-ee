---
stage: Agent Foundations
group: Agent Developer
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: AGENTS.md 自定义文件
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

极狐GitLab Duo 支持 [`AGENTS.md` 规范](https://agents.md/)，这是一项新兴标准，用于向 AI 编码助手提供上下文和指令。

使用 `AGENTS.md` 文件记录您的代码仓库结构、编码约定、风格指南、构建和测试说明以及项目上下文。当您指定 `AGENTS.md` 文件后，这些详细信息可供极狐GitLab Duo Agent Platform 以及任何其他支持该规范的 AI 工具使用。

为极狐GitLab Duo 指定要使用的 `AGENTS.md` 文件，适用于：

- 极狐GitLab UI 和本地环境中的极狐GitLab Duo Chat。
- 内置任务流和自定义任务流，代码评审任务流除外。

<a id="how-gitlab-duo-uses-agentsmd-files"></a>

## 极狐GitLab Duo 如何使用 `AGENTS.md` 文件

您可以根据使用极狐GitLab Duo 的方式，在多个层级创建 `AGENTS.md` 文件：

| 层级                                                           | 极狐GitLab UI | 编辑器扩展 | 极狐GitLab Duo CLI |
|-----------------------------------------------------------------|--------------------------|------------------|--------------|
| 用户级：应用于您的所有项目        | {{< no >}}  |  {{< yes >}}    | {{< yes >}} |
| 项目级：仅应用于特定项目  | {{< yes >}} | {{< yes >}}         | {{< yes >}} |
| 子目录级：仅应用于 monorepo 中的特定项目，或包含不同组件的项目中的特定项目 | {{< no >}} | {{< yes >}} | {{< yes >}} |

如果您在 IDE 中使用多根工作区，可以为工作区中的每个项目创建项目级 `AGENTS.md` 文件。

极狐GitLab Duo 会为所有对话合并用户级和项目级 `AGENTS.md` 文件中可用的指令。如果某项任务需要处理某个目录中的文件，而该目录还包含另一个 `AGENTS.md` 文件，Chat 也会应用这些指令。

<a id="use-agentsmd-with-gitlab-duo"></a>

## 将 `AGENTS.md` 与极狐GitLab Duo 配合使用

> [!note]
> 只有在您添加或更新 `AGENTS.md` 文件后创建的新对话和任务流才会遵循新的
指令。此前已存在的对话不会遵循。

<a id="prerequisites"></a>

### 先决条件

- 满足 [Agent Platform 先决条件](../_index.md#prerequisites)。
- 对于本地环境中的极狐GitLab Duo Chat，请安装并配置以下任一组件：
  - [GitLab for VS Code](../../../editor_extensions/visual_studio_code/setup.md) 6.60 或更高版本。
  - [适用于 JetBrains IDE 的极狐GitLab Duo 插件](../../../editor_extensions/jetbrains_ide/setup.md) 3.26.0
    或更高版本。
  - [极狐GitLab Duo CLI](../../gitlab_duo_cli/set_up.md) 8.47.0 或更高版本。
- 对于自定义任务流，请更新任务流的配置文件，以访问从执行器传递的 `user_rule`
  上下文：

  ```yaml
  components:
  - name: "my_agent"
     type: AgentComponent
     prompt_id: "my_prompt"
     inputs:
     - from: "context:inputs.user_rule"
        as: "agents_dot_md"
      optional: true
  ```

  通过设置 `optional: true`，任务流可以妥善处理不存在 `AGENTS.md` 文件的情况。
  Agent 无论是否有额外上下文都能正常工作。

<a id="create-user-level-agentsmd-files"></a>

### 创建用户级 `AGENTS.md` 文件

用户级 `AGENTS.md` 文件应用于您的所有项目。

1. 在主目录中创建 `AGENTS.md` 文件：
   - 在 Linux 或 macOS 上，在 `~/.gitlab/duo/AGENTS.md` 处创建该文件。
   - 在 Windows 上，在 `%APPDATA%\GitLab\duo\AGENTS.md` 处创建该文件。
1. 向该文件添加指令。例如：

   {{< tabs >}}

   {{< tab title="Personal preferences" >}}

   ```markdown
   # My personal coding preferences

   - Always explain code changes in simple terms for beginners
   - Use descriptive variable names
   - Add comments for complex logic
   - Prefer functional programming patterns when appropriate
   ```

   {{< /tab >}}

   {{< tab title="Team standards" >}}

   ```markdown
   # Team coding standards

   - Follow our company's style guide for all code
   - Use TypeScript strict mode
   - Write unit tests for all new functions
   - Document all public APIs with JSDoc
   ```

   {{< /tab >}}

   {{< tab title="Monorepo context" >}}

   ```markdown
   # Monorepo context

   - This is a monorepo with multiple services
   - Frontend code is in /apps/web
   - Backend services are in /services
   - Shared libraries are in /packages
   - Follow the architecture decision records in /docs/adr
   ```

   {{< /tab >}}

   {{< tab title="Security guidelines" >}}

   ```markdown
   # Security review guidelines

   - Always validate user input
   - Use parameterized queries for database operations
   - Implement proper authentication and authorization
   - Follow OWASP security best practices
   - Never log sensitive information
   ```

   {{< /tab >}}

   {{< /tabs >}}

1. 保存该文件。
1. 要应用这些指令，请启动新的对话或任务流。每次
   更改 `AGENTS.md` 文件时都必须这样做。

如果您设置了特定的环境变量，则需要在其他位置创建 `AGENTS.md` 文件：

- 如果您设置了 `GLAB_CONFIG_DIR` 环境变量，请在
  `$GLAB_CONFIG_DIR/AGENTS.md` 处创建该文件。
- 如果您设置了 `XDG_CONFIG_HOME` 环境变量，请在
  `$XDG_CONFIG_HOME/gitlab/duo/AGENTS.md` 处创建该文件。

<a id="create-project-level-agentsmd-files"></a>

### 创建项目级 `AGENTS.md` 文件

项目级 `AGENTS.md` 文件仅应用于特定项目。

1. 在项目的根目录中创建 `AGENTS.md` 文件。
1. 向该文件添加指令。例如：

   {{< tabs >}}

   {{< tab title="Project guidelines" >}}

   ```markdown
   # Project-specific guidelines

   - This project uses React with TypeScript
   - Follow the component structure in /src/components
   - Use our custom hooks from /src/hooks
   - State management uses Redux Toolkit
   ```

   {{< /tab >}}

   {{< tab title="Database migrations" >}}

   ```markdown
   # Database migrations

   - To run database migrations, use `bin/rails db:migrate` from the project root
   - Do not run `rake db:migrate` directly
   - If a migration fails with a lock timeout, wait and retry once. Do not attempt
     a schema workaround
   ```

   {{< /tab >}}

   {{< /tabs >}}

1. 保存该文件。
1. 要应用这些指令，请启动新的对话或任务流。每次
   更改 `AGENTS.md` 文件时都必须这样做。

<a id="create-agentsmd-files-in-monorepos-and-subdirectories"></a>

### 在 monorepo 和子目录中创建 `AGENTS.md` 文件

对于 monorepo 或包含不同组件的项目，您可以将 `AGENTS.md` 文件放在子目录中，为代码库的不同部分提供特定于上下文的指令。

当极狐GitLab Duo Chat 在子目录中发现其他 `AGENTS.md` 文件时，它会在编辑该目录中的文件之前读取相关文件。例如：

```plaintext
/my-project
  AGENTS.md              # Root instructions (included in all conversations)
  /frontend
    AGENTS.md            # Frontend-specific instructions
  /backend
    AGENTS.md            # Backend-specific instructions
```

在此示例中：

- 根目录中的 `AGENTS.md` 始终包含在对话中。
- 当极狐GitLab Duo 编辑 `/frontend`中的文件时，它会先读取 `/frontend/AGENTS.md`。
- 当极狐GitLab Duo 编辑 `/backend`中的文件时，它会先读取 `/backend/AGENTS.md`。

这种方法有助于确保极狐GitLab Duo 遵循您项目各部分适用的约定。

要在子目录中使用 `AGENTS.md`：

1. 在项目的子目录中创建 `AGENTS.md` 文件。
1. 添加特定于该目录的指令。例如，对于后端服务：

   ```markdown
   # Backend service guidelines

   - This service uses Node.js with Express
   - Follow RESTful API conventions
   - Use async/await for asynchronous operations
   - Validate all inputs with Joi schemas
   ```

1. 保存该文件。
1. 要应用这些指令，请启动涉及该目录中文件的新对话。每次
   更改 `AGENTS.md` 文件时都必须这样做。
