---
stage: AI-powered
group: Editor Extensions
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Extend the features of GitLab to Visual Studio Code, JetBrains IDEs, Visual Studio, Eclipse, and Neovim.
title: 极狐 GitLab 编辑器扩展
---

极狐 GitLab 编辑器扩展将极狐 GitLab 和极狐 GitLab Duo 的强大功能直接带入你首选的开发环境中。使用极狐 GitLab 功能和极狐 GitLab Duo AI 能力处理日常任务，无需离开编辑器。例如：

- 管理你的项目。
- 编写和审查代码。
- 跟踪议题。
- 优化流水线。

我们的扩展通过弥合编码环境与极狐 GitLab 之间的差距，提高你的生产力并提升开发流程。

<a id="available-extensions"></a>

## 可用扩展

极狐 GitLab 提供以下 IDE 扩展，可访问极狐 GitLab Duo 和其他用于管理项目和应用程序的极狐 GitLab 功能。

| 扩展                                                       | 极狐 GitLab Duo Chat      | 代码建议 | 软件开发<br> 流程 | Agent      | 其他<br> 极狐 GitLab 功能 |
|-----------------------------------------------------------------|----------------------|------------------|------------------------------|-------------|--------------------------|
| [极狐 GitLab for VS Code](visual_studio_code/_index.md)              | {{< yes >}}          | {{< yes >}}      | {{< yes >}}                  | {{< yes >}} | {{< yes >}}              |
| [极狐 GitLab Duo 插件 for JetBrains IDEs](jetbrains_ide/_index.md) | {{< yes >}}          | {{< yes >}}      | {{< yes >}}                  | {{< yes >}} | {{< no >}}               |
| [极狐 GitLab for Visual Studio](visual_studio/_index.md)   | {{< yes >}}          | {{< yes >}}      | {{< yes >}}                  | {{< no >}}  | {{< no >}}               |
| [极狐 GitLab for Eclipse 插件](eclipse/_index.md)                  | {{< yes >}}(非 Agent) | {{< yes >}}      | {{< no >}}                   | {{< no >}}  | {{< no >}}               |

如果你更喜欢命令行界面，请尝试以下操作：

| 扩展                                                       | 极狐 GitLab Duo Chat      | 代码建议 | 软件开发<br> 流程 | Agent      | 其他<br> 极狐 GitLab 功能 |
|-----------------------------------------------------------------|----------------------|------------------|------------------------------|-------------|--------------------------|
| [极狐 GitLab CLI (`glab`)](gitlab_cli/_index.md)                | {{< yes >}} | {{< no >}}                  | {{< no >}}                | {{< no >}} | {{< yes >}}           |
| [极狐 GitLab Duo CLI (`duo`)](../user/gitlab_duo_cli/_index.md) | {{< yes >}}<br>(Agent) | {{< no >}}                  | {{< no >}}                | {{< no >}} | {{< no >}}            |
| [极狐 GitLab.nvim for Neovim](neovim/_index.md)                     | {{< no >}}            | {{< yes >}}                 | {{< no >}}                | {{< no >}} | {{< no >}}            |

<a id="security-considerations"></a>

## 安全注意事项

要了解在编辑器扩展中本地运行 Agent 的安全风险以及如何保护本地开发环境，请参阅 [编辑器扩展的安全注意事项](security_considerations.md)。
