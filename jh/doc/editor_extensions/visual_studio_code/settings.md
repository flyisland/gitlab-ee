---
stage: AI-powered
group: Editor Extensions
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Settings and commands in the GitLab for VS Code extension.
title: GitLab for VS Code extension settings and commands
---

极狐GitLab VS Code 扩展集成于 VS Code 命令面板，扩展现有 VS Code 与 Git 的集成，并提供配置选项。

<a id="command-palette-commands"></a>

## 命令面板命令

此扩展提供了几组命令，你可以在[命令面板](https://code.visualstudio.com/docs/getstarted/userinterface#_command-palette)中触发：

### 管理项目与代码

- `极狐GitLab：认证`
- [`极狐GitLab：将当前分支与默认分支进行比较`](projects.md#compare-with-default-branch)：
  将你的分支与仓库默认分支进行比较，并在极狐GitLab 上查看变更。
- `极狐GitLab：在极狐GitLab 中打开当前项目`
- [`极狐GitLab：打开远程仓库`](remote_urls.md)：浏览远程极狐GitLab 仓库。
- `极狐GitLab：流水线操作 - 查看、创建、重试或取消`
- `极狐GitLab：从 VS Code 中移除账户`
- `极狐GitLab：验证极狐GitLab 账户`

### 管理议题与合并请求

- [`极狐GitLab：高级搜索（议题、合并请求、提交、评论...）`](projects.md#search-issues-and-merge-requests)
- `极狐GitLab：复制当前文件在极狐GitLab 上的链接`
- `极狐GitLab：在当前项目中创建新议题`
- `极狐GitLab：在当前项目中创建新合并请求`：打开合并请求页面以创建合并请求。
- [`极狐GitLab：在极狐GitLab 上打开活动文件`](projects.md#open-current-file-in-gitlab-ui)：在极狐GitLab 上查看活动文件，并高亮活动行号和选中文本块。
- `极狐GitLab：打开当前分支的合并请求`
- [`极狐GitLab：搜索项目议题（支持过滤器）`](projects.md#search-issues-and-merge-requests)。
- [`极狐GitLab：搜索项目合并请求（支持过滤器）`](projects.md#search-issues-and-merge-requests)。
- `极狐GitLab：显示分配给我的议题`：在极狐GitLab 上打开分配给你的议题。
- `极狐GitLab：显示分配给我的合并请求`：在极狐GitLab 上打开分配给你的合并请求。

### 管理 CI/CD 流水线

- [`极狐GitLab：显示合并后的极狐GitLab CI/CD 配置`](cicd.md#show-merged-configuration-file)：
  显示解析了所有 include 的极狐GitLab CI/CD 配置文件 `.gitlab-ci.yml` 的预览。
- [`极狐GitLab：验证极狐GitLab CI/CD 配置`](cicd.md#test-gitlab-cicd-configuration)：
  测试极狐GitLab CI/CD 配置文件 `.gitlab-ci.yml`。

### AI 辅助功能

- `极狐GitLab：重启极狐GitLab 语言服务器`
- `极狐GitLab：显示 Duo Workflow`
- `极狐GitLab：切换代码建议`
- `极狐GitLab：切换当前语言的代码建议`

### 其他功能

- `极狐GitLab：应用代码片段补丁`
- `极狐GitLab：克隆 Wiki`
- [`极狐GitLab：创建代码片段`](projects.md#create-a-snippet)：从整个文件或选中内容创建公开、内部或私有的代码片段。
- [`极狐GitLab：创建代码片段补丁`](projects.md#create-a-patch-file)：从整个文件或选中内容创建 `.patch` 文件。
- [`极狐GitLab：插入代码片段`](projects.md#insert-a-snippet)：插入单文件或多文件项目代码片段。
- `极狐GitLab：将工作区发布到极狐GitLab`
- `极狐GitLab：刷新侧边栏`
- `极狐GitLab：显示扩展日志`
- `极狐GitLab：查看安全发现详情`
- `极狐GitLab：聚焦当前分支视图`
- `极狐GitLab：聚焦议题与合并请求视图`
- `极狐GitLab：诊断`：打开极狐GitLab VS Code 扩展的详细设置页面。

<a id="command-integrations"></a>

## 命令集成

此扩展还与 VS Code 提供的一些命令集成：

- `Git: Clone`：为你设置的每个极狐GitLab 实例搜索并克隆项目。更多信息，请参阅：
  - 扩展文档中的[克隆极狐GitLab 项目](remote_urls.md#clone-a-git-project)。
  - VS Code 文档中的[克隆仓库](https://code.visualstudio.com/docs/sourcecontrol/overview#_cloning-a-repository)。
- `Git: Add Remote...`：从你设置的每个极狐GitLab 实例中添加现有项目作为远程仓库。

<a id="extension-settings"></a>

## 扩展设置

要了解如何在 VS Code 中更改设置，请参阅 VS Code 文档中的[用户与工作区设置](https://code.visualstudio.com/docs/configure/settings)。

如果你使用自签名证书连接到极狐GitLab 实例，请参阅[为自定义证书颁发机构配置扩展](https://jihulab.com/gitlab-cn/gitlab-vscode-extension/-/blob/main/docs/user/custom-certificates.md)。

| 设置 | 默认值 | 信息 |
| ------- | ------- | ----------- |
| `gitlab.customQueries` | 不适用 | 定义检索极狐GitLab 面板上显示项的搜索查询。更多信息，请参阅[自定义查询文档](custom_queries.md)。 |
| `gitlab.authentication.oauthClientIds` | 不适用 | 在[设置](setup.md#authenticate-with-gitlab)过程中使用的 OAuth 客户端 ID（按极狐GitLab 实例 URL）。 |
| `gitlab.debug` | false | 当为 `true` 时，启用调试模式。调试模式会改善错误堆栈跟踪，因为扩展使用源映射来理解压缩代码。调试模式还会在[扩展日志](troubleshooting.md#view-debug-logs)中显示调试日志消息。 |
| `gitlab.duo.enabledWithoutGitlabProject` | true | 当为 `true` 时，如果扩展无法获取项目的 `duoFeaturesEnabledForProject` 设置，会保持极狐GitLab Duo 功能启用。当为 `false` 时，如果扩展无法获取项目的 `duoFeaturesEnabledForProject` 设置，则禁用所有极狐GitLab Duo 功能。请参阅[`duoFeaturesEnabledForProject` 设置](#duofeaturesenabledforproject)。 |
| `gitlab.duoAgentPlatform.defaultNamespace` | 不适用 | 当扩展无法获取极狐GitLab 项目详情时，极狐GitLab Duo Agent Platform 的默认群组或命名空间路径。 |
| `gitlab.duoCodeSuggestions.additionalLanguages` | 不适用 | （实验性。）要扩展极狐GitLab Duo 代码建议官方支持的语言列表，请提供一个[语言标识符](https://code.visualstudio.com/docs/languages/identifiers#_known-language-identifiers)数组。为添加的语言提供的代码建议质量可能并非最佳。 |
| `gitlab.duoCodeSuggestions.enabled` | true | 当为 `true` 时，启用代码建议以提供 AI 辅助建议。 |
| `gitlab.duoCodeSuggestions.enabledSupportedLanguages` | 不适用 | 要启用代码建议的支持语言。默认情况下，所有支持的语言都已启用。 |
| `gitlab.duoCodeSuggestions.openTabsContext` | true | 当为 `true` 时，允许跨打开的标签页发送上下文以改进代码建议。 |
| `gitlab.keybindingHints.enabled` | true | 为极狐GitLab Duo 启用快捷键提示。 |
| `gitlab.pipelineGitRemoteName` | null | 与包含你流水线的极狐GitLab 仓库对应的 Git 远程名称。当为 `null` 或空时，扩展使用与非流水线功能相同的远程。 |
| `gitlab.showPipelineUpdateNotifications` | false | 当为 `true` 时，在流水线完成时显示提醒。 |

<a id="duofeaturesenabledforproject"></a>

### `duoFeaturesEnabledForProject`

`duoFeaturesEnabledForProject` 设置在以下情况不可用：

- 项目未在扩展中设置。
- 项目位于与你当前账户不同的极狐GitLab 实例上。
- 你正在使用的文件或文件夹不属于你有权访问的任何极狐GitLab 项目。