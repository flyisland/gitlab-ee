---
stage: AI Clients
group: Developer Clients
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: GitLab for VS Code 扩展中的设置和命令。
title: GitLab for VS Code 扩展的设置和命令
---

GitLab for VS Code 扩展与 VS Code 命令面板集成，扩展了 VS Code 现有的 Git 集成功能，并提供配置选项。

<a id="command-palette-commands"></a>

## 命令面板命令

此扩展提供了多组命令，您可以在[命令面板](https://code.visualstudio.com/docs/getstarted/userinterface#_command-palette)中触发这些命令：

<a id="manage-projects-and-code"></a>

### 管理项目和代码

- `GitLab: Authenticate`
- [`GitLab: Compare Current Branch with Default Branch`](projects.md#compare-with-default-branch)：
  将您的分支与代码仓库的默认分支进行比较，并在极狐GitLab 上查看变更。
- `GitLab: Open Current Project on GitLab`
- [`GitLab: Open Remote Repository`](remote_urls.md)：浏览远程极狐GitLab 代码仓库。
- `GitLab: Pipeline Actions - View, Create, Retry, or Cancel`
- `GitLab: Remove Account from VS Code`
- `GitLab: Validate GitLab Accounts`

<a id="manage-issues-and-merge-requests"></a>

### 管理议题和合并请求

- [`GitLab: Advanced Search (Issues, Merge Requests, Commits, Comments...)`](projects.md#search-issues-and-merge-requests)
- `GitLab: Copy Link to Active File on GitLab`
- `GitLab: Create New Issue on Current Project`
- `GitLab: Create New Merge Request on Current Project`：打开合并请求页面以创建合并请求。
- [`GitLab: Open Active File on GitLab`](projects.md#open-current-file-in-gitlab-ui)：在极狐GitLab 上查看当前活动文件，
  并高亮显示活动行号和选中的文本块。
- `GitLab: Open Merge Request for Current Branch`
- [`GitLab: Search Project Issues (Supports Filters)`](projects.md#search-issues-and-merge-requests)。
- [`GitLab: Search Project Merge Requests (Supports Filters)`](projects.md#search-issues-and-merge-requests)。
- `GitLab: Show Issues Assigned to Me`：在极狐GitLab 上打开指派给您的议题。
- `GitLab: Show Merge Requests Assigned to Me`：在极狐GitLab 上打开指派给您的合并请求。

<a id="manage-cicd-pipelines"></a>

### 管理 CI/CD 流水线

- [`GitLab: Show Merged GitLab CI/CD Configuration`](cicd.md#show-merged-configuration-file)：
  显示已解析所有 include 的极狐GitLab CI/CD 配置文件 `.gitlab-ci.yml` 预览。
- [`GitLab: Validate GitLab CI/CD Configuration`](cicd.md#test-gitlab-cicd-configuration)：
  测试极狐GitLab CI/CD 配置文件 `.gitlab-ci.yml`。

<a id="ai-assisted-features"></a>

### AI 辅助功能

- `GitLab: Restart GitLab Language Server`
- `GitLab: Toggle Code Suggestions`
- `GitLab: Toggle Code Suggestions for current language`

<a id="other-features"></a>

### 其他功能

- `GitLab: Apply Snippet Patch`
- `GitLab: Clone Wiki`
- [`GitLab: Create Snippet`](projects.md#create-a-snippet)：从整个文件或所选内容创建公开、内部或私有代码片段。
- [`GitLab: Create Snippet Patch`](projects.md#create-a-patch-file)：从整个文件或所选内容创建 `.patch` 文件。
- [`GitLab: Insert Snippet`](projects.md#insert-a-snippet)：插入单文件或多文件项目代码片段。
- `GitLab: Publish Workspace to GitLab`
- `GitLab: Refresh Sidebar`
- `GitLab: Show Extension Logs`
- `GitLab: Focus on For current branch View`
- `GitLab: Focus on Issues and Merge Requests View`
- `GitLab: Diagnostics`：打开 GitLab for VS Code 扩展的详细设置页面。

<a id="command-integrations"></a>

## 命令集成

此扩展还与 VS Code 提供的一些命令集成：

- `Git: Clone`：为您设置的每个极狐GitLab 实例搜索并克隆项目。更多信息，请参见：
  - 扩展文档中的[克隆极狐GitLab 项目](remote_urls.md#clone-a-git-project)。
  - VS Code 文档中的[克隆代码仓库](https://code.visualstudio.com/docs/sourcecontrol/overview#_cloning-a-repository)。
- `Git: Add Remote...`：将您设置的每个极狐GitLab 实例中的现有项目添加为远程仓库。

<a id="extension-settings"></a>

## 扩展设置

要了解如何在 VS Code 中更改设置，请参阅 VS Code 文档中的[用户和工作区设置](https://code.visualstudio.com/docs/configure/settings)。

如果您使用自签名证书连接到极狐GitLab 实例，请参阅[为自定义证书颁发机构配置扩展](https://gitlab.com/gitlab-org/gitlab-vscode-extension/-/blob/main/docs/user/custom-certificates.md)。

| 设置 | 默认值 | 说明 |
| ------- | ------- | ----------- |
| `gitlab.customQueries` | 不适用 | 定义用于检索极狐GitLab 面板中所显示条目的搜索查询。更多信息，请参见[自定义查询文档](custom_queries.md)。 |
| `gitlab.authentication.oauthClientIds` | 不适用 | 在[设置](setup.md#authenticate-with-gitlab)期间要使用的 OAuth 客户端 ID（按极狐GitLab 实例 URL）。 |
| `gitlab.debug` | false | 当为 `true` 时，启用调试模式。调试模式会改进错误堆栈跟踪，因为扩展使用源映射来理解压缩后的代码。调试模式还会在[扩展日志](troubleshooting.md#view-debug-logs)中显示调试日志消息。 |
| `gitlab.duo.enabledWithoutGitlabProject` | true | 当为 `true` 时，如果扩展无法检索项目的 `duoFeaturesEnabledForProject` 设置，则保持极狐GitLab Duo 功能启用。当为 `false` 时，如果扩展无法检索项目的 `duoFeaturesEnabledForProject` 设置，则禁用所有极狐GitLab Duo 功能。请参见 [`duoFeaturesEnabledForProject` 设置](#duofeaturesenabledforproject)。 |
| `gitlab.duo.proxy.directConnection` | false | 当为 `true` 时，由 GitLab Language Server 处理的极狐GitLab Duo 及其他极狐GitLab 功能的流量将直接连接，而不使用 VS Code 或系统代理设置。 |
| `gitlab.duoCodeSuggestions.disabledLanguages` | `[]` | 要关闭代码建议的[语言标识符](https://code.visualstudio.com/docs/languages/identifiers#_known-language-identifiers)，例如 `python` 或 `markdown`。代码建议适用于除纯文本以外的所有其他语言。 |
| `gitlab.duoCodeSuggestions.enabled` | true | 当为 `true` 时，启用代码建议以提供 AI 辅助建议。 |
| `gitlab.duoCodeSuggestions.openTabsContext` | true | 当为 `true` 时，启用跨打开的标签页发送上下文，以改进代码建议。 |
| `gitlab.keybindingHints.enabled` | true | 为极狐GitLab Duo 启用快捷键提示。 |
| `gitlab.pipelineGitRemoteName` | null | 与包含您流水线的极狐GitLab 代码仓库相对应的 Git 远程仓库名称。当为 `null` 或空时，扩展将使用与非流水线功能相同的远程仓库。 |
| `gitlab.showPipelineUpdateNotifications` | false | 当为 `true` 时，在流水线完成时显示提醒。 |

<a id="duofeaturesenabledforproject"></a>

### `duoFeaturesEnabledForProject`

在以下情况下，`duoFeaturesEnabledForProject` 设置不可用：

- 该项目未在扩展中设置。
- 该项目所在的极狐GitLab 实例与您当前账号不同。
- 您正在处理的文件或文件夹不属于您有权访问的任何极狐GitLab 项目。
