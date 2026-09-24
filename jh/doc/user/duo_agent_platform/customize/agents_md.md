---
stage: AI-powered
group: Editor Extensions
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: AGENTS.md 自定义文件
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- `AGENTS.md` 在极狐GitLab Duo Chat 中的支持于极狐GitLab 18.7 引入。
- `AGENTS.md` 在 agentic 流中的支持于极狐GitLab 18.8 引入。
- 于极狐GitLab 18.8 GA。
- 极狐GitLab UI 的支持于极狐GitLab 18.11 引入。

{{< /history >}}

极狐GitLab Duo 支持 [`AGENTS.md` 规范](https://agents.md/)，这是一种为 AI 编码助手提供上下文和指令的新兴标准。

使用 `AGENTS.md` 文件来记录你的代码仓结构、编码规范、风格指南、构建和测试说明以及项目上下文。当你指定了 `AGENTS.md` 文件后，这些详情将可用于极狐GitLab Duo Agent Platform 以及任何支持该规范的 AI 工具。

为极狐GitLab Duo 指定 `AGENTS.md` 文件，以便在以下场景中使用：

- 极狐GitLab UI 和本地环境中的极狐GitLab Duo Chat。
- 基础流和自定义流，不包括代码审查流。

<a id="how-gitlab-duo-uses-agents-md-files"></a>

## 极狐GitLab Duo 如何使用 `AGENTS.md` 文件

你可以根据使用极狐GitLab Duo 的方式在不同层级创建 `AGENTS.md` 文件：

| 级别 | 极狐GitLab UI |
|-----------------------------------------------------------------|------------------|
| 用户级：应用于所有项目和工空间 | {{< no >}} |
| 工作空间级：仅应用于特定项目或工作空间 | {{< yes >}} |
| 子目录级：仅应用于单一代码库中的特定项目或包含不同组件的项目中 | {{< no >}} |

极狐GitLab Duo 会综合来自用户级和工作空间级 `AGENTS.md` 文件中的可用指令应用于所有对话。如果某个任务需要处理包含额外 `AGENTS.md` 文件的目录中的文件，Chat 也会应用这些指令。

<a id="use-agents-md-with-gitlab-duo"></a>

## 使用 `AGENTS.md` 与极狐GitLab Duo

> [!note]
> 仅当添加或更新 `AGENTS.md` 文件后创建的新对话和流才会遵循新指令。已有的对话不会。

<a id="prerequisites"></a>

### 先决条件

- 满足 [Agent Platform 先决条件](../_index.md#prerequisites)。
- 对于自定义流，更新流的配置文件以访问从执行器传递的 `user_rule` 上下文：

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

  通过设置 `optional: true`，流会优雅地处理不存在 `AGENTS.md` 文件的情况。Agent 在有无附加上下文的情况下均可工作。

<a id="create-user-level-agents-md-files"></a>

### 创建用户级 `AGENTS.md` 文件

用户级 `AGENTS.md` 文件应用于你的所有项目和工空间。

1. 在你的主目录中创建一个 `AGENTS.md` 文件：
   - 在 Linux 或 macOS 上，在 `~/.gitlab/duo/AGENTS.md` 创建文件。
   - 在 Windows 上，在 `%APPDATA%\GitLab\duo\AGENTS.md` 创建文件。
1. 向文件中添加指令。例如：

   {{< tabs >}}

   {{< tab title="个人偏好" >}}

   ```markdown
   # 我的个人编码偏好

   - 始终用简单易懂的术语为初学者解释代码更改
   - 使用描述性的变量名
   - 为复杂逻辑添加注释
   - 在合适时倾向使用函数式编程模式
   ```

   {{< /tab >}}

   {{< tab title="团队标准" >}}

   ```markdown
   # 团队编码标准

   - 遵循公司风格指南撰写所有代码
   - 使用 TypeScript 严格模式
   - 为所有新函数编写单元测试
   - 使用 JSDoc 为所有公共 API 撰写文档
   ```

   {{< /tab >}}

   {{< tab title="单一代码库上下文" >}}

   ```markdown
   # 单一代码库上下文

   - 这是一个包含多个服务的单一代码库
   - 前端代码位于 /apps/web
   - 后端服务位于 /services
   - 共享库位于 /packages
   - 遵循 /docs/adr 中的架构决策记录
   ```

   {{< /tab >}}

   {{< tab title="安全指南" >}}

   ```markdown
   # 安全审查指南

   - 始终验证用户输入
   - 对数据库操作使用参数化查询
   - 实施适当的身份验证和授权
   - 遵循 OWASP 安全最佳实践
   - 切勿记录敏感信息
   ```

   {{< /tab >}}

   {{< /tabs >}}

1. 保存文件。
1. 要应用这些指令，请启动一次新的对话或流。每次更改 `AGENTS.md` 文件后，你都必须这样做。

如果你设置了特定的环境变量，那么你在不同的位置创建 `AGENTS.md` 文件：

- 如果你设置了 `GLAB_CONFIG_DIR` 环境变量，请在 `$GLAB_CONFIG_DIR/AGENTS.md` 创建文件。
- 如果你设置了 `XDG_CONFIG_HOME` 环境变量，请在 `$XDG_CONFIG_HOME/gitlab/duo/AGENTS.md` 创建文件。

<a id="create-workspace-level-agents-md-files"></a>

### 创建工作空间级 `AGENTS.md` 文件

工作空间级 `AGENTS.md` 文件仅应用于特定项目或工作空间。

1. 在你的项目工作空间根目录中创建一个 `AGENTS.md` 文件。
1. 向文件中添加指令。例如：

   ```markdown
   # 项目特定指南

   - 此项目使用 React 搭配 TypeScript
   - 遵循 /src/components 中的组件结构
   - 使用 /src/hooks 中的自定义钩子
   - 状态管理使用 Redux Toolkit
   ```

1. 保存文件。
1. 要应用这些指令，请启动一次新的对话或流。每次更改 `AGENTS.md` 文件后，你都必须这样做。

<a id="create-agents-md-files-in-monorepos-and-subdirectories"></a>

### 在单一代码库和子目录中创建 `AGENTS.md` 文件

对于单一代码库或包含不同组件的项目，你可以将 `AGENTS.md` 文件放置在子目录中，以便为代码库的不同部分提供特定于上下文的指令。

当极狐GitLab Duo Chat 在子目录中发现额外的 `AGENTS.md` 文件时，它会在编辑该目录中的文件前读取相关文件。例如：

```plaintext
/my-project
  AGENTS.md              # 根目录指令（在所有对话中都会包含）
  /frontend
    AGENTS.md            # 前端专用指令
  /backend
    AGENTS.md            # 后端专用指令
```

在此示例中：

- 根目录的 `AGENTS.md` 始终包含在对话中。
- 当极狐GitLab Duo 编辑 `/frontend` 中的文件时，它会先读取 `/frontend/AGENTS.md`。
- 当极狐GitLab Duo 编辑 `/backend` 中的文件时，它会先读取 `/backend/AGENTS.md`。

这种方法有助于确保极狐GitLab Duo 为项目的每个部分遵循适当的约定。

要在子目录中使用 `AGENTS.md`：

1. 在你项目的某个子目录中创建一个 `AGENTS.md` 文件。
1. 添加特定于该目录的指令。例如，针对后端服务：

   ```markdown
   # 后端服务指南

   - 此服务使用 Node.js 搭配 Express
   - 遵循 RESTful API 约定
   - 使用 async/await 进行异步操作
   - 使用 Joi 模式验证所有输入
   ```

1. 保存文件。
1. 要应用这些指令，请启动一个涉及该目录中文件的新对话。每次更改 `AGENTS.md` 文件后，你都必须这样做。