---
stage: Create
group: Remote Development
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Use the Web IDE to edit multiple files in the 极狐GitLab UI, stage commits, and create merge requests.
title: Web IDE
---

{{< details >}}

- Tier: 基本版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 18.0 中 GA。功能标志 `vscode_web_ide` 被移除。

{{< /history >}}

Web IDE 是一个高级编辑器，你可以直接在其中编辑多个文件、暂存更改，并在极狐GitLab UI 中创建提交。与 [Web Editor](../repository/web_editor.md) 不同，Web IDE 提供了一个具有源代码管理功能的完整开发环境。

极狐GitLab 风格的 Markdown 预览在 Web IDE 中的支持在 [epic 15810](https://gitlab.com/groups/gitlab-org/-/epics/15810) 中提出。

<a id="open-the-web-ide"></a>

## 打开 Web IDE

你可以通过几种方法访问 Web IDE。

<a id="with-a-keyboard-shortcut"></a>

### 通过键盘快捷方式

1. 在顶部栏中，选择 **搜索或跳转到**，然后找到你的项目。
1. 使用 <kbd>.</kbd> 键盘快捷方式。

<a id="from-a-directory"></a>

### 从目录中

1. 在顶部栏中，选择 **搜索或跳转到**，然后找到你的项目。
1. 进入你的目录。
1. 选择 **代码** > **在 Web IDE 中打开**。

<a id="from-a-file"></a>

### 从文件中

1. 在顶部栏中，选择 **搜索或跳转到**，然后找到你的项目。
1. 进入你的文件。
1. 选择 **编辑** > **在 Web IDE 中打开**。

<a id="from-a-merge-request"></a>

### 从合并请求中

1. 在顶部栏中，选择 **搜索或跳转到**，然后找到你的项目。
1. 进入你的合并请求。
1. 在右上角，选择 **代码** > **在 Web IDE 中打开**。

Web IDE 会在单独的标签页中打开新文件和修改过的文件，并并排显示更改。为了减少加载时间，只有更改行数最多的 10 个文件会自动打开。

Web IDE 界面在左侧边栏 **资源管理器** 视图中，会在新文件或修改过的文件旁边显示一个合并请求图标 ({{< icon name="merge-request" >}})。要查看文件的更改，右键点击文件并选择 **与合并请求基线比较**。

<a id="manage-files"></a>

## 管理文件

你可以使用 Web IDE 打开、编辑和上传多个文件。

<a id="open-a-file"></a>

### 打开文件

要在 Web IDE 中按名称打开文件：

1. 按下 <kbd>Command</kbd>+<kbd>P</kbd>。
1. 在搜索框中，输入文件名。

<a id="search-open-files"></a>

### 搜索打开的文件

要在 Web IDE 中跨打开的文件搜索：

1. 按下 <kbd>Shift</kbd>+<kbd>Command</kbd>+<kbd>F</kbd>。
1. 在搜索框中，输入搜索词。

<a id="upload-a-file"></a>

### 上传文件

要在 Web IDE 中上传文件：

1. 在 Web IDE 左侧，选择 **资源管理器** ({{< icon name="documents" >}})，或按下 <kbd>Shift</kbd>+<kbd>Command</kbd>+<kbd>E</kbd>。
1. 进入你想要上传文件的目录。要创建新目录：
   - 在 **资源管理器** 视图的右上角，选择 **新建文件夹** ({{< icon name="folder-new" >}})。
1. 右键点击目录，然后选择 **上传**。
1. 选择要上传的文件。

你可以一次上传多个文件。上传的文件会自动添加到仓库中。

<a id="restore-uncommitted-changes"></a>

### 恢复未提交的更改

在 Web IDE 中编辑的任何文件你都不需要手动保存。Web IDE 会暂存你修改的文件，这样你就可以[提交这些更改](#提交更改)。未提交的更改会保存在浏览器的本地存储中。即使你关闭浏览器标签页或刷新 Web IDE，它们也会保留。

如果你的未提交更改不可用，你可以从本地历史中恢复更改。要在 Web IDE 中恢复未提交的更改：

1. 按下 <kbd>Shift</kbd>+<kbd>Command</kbd>+<kbd>P</kbd>。
1. 在搜索框中输入 `Local History: Find Entry to Restore`。
1. 选择包含未提交更改的文件。

<a id="use-source-control"></a>

## 使用源代码管理

你可以使用源代码管理来查看修改过的文件、创建和切换分支、提交更改以及创建合并请求。

<a id="view-modified-files"></a>

### 查看修改过的文件

要查看在 Web IDE 中修改过的文件列表：

- 在 Web IDE 左侧，选择 **源代码管理** ({{< icon name="branch" >}})，或按下 <kbd>Control</kbd>+<kbd>Shift</kbd>+<kbd>G</kbd>。

你的 `CHANGES`、`STAGED CHANGES` 和 `MERGE CHANGES` 都会显示出来。更多信息，请参阅 [VS Code 文档](https://code.visualstudio.com/docs/sourcecontrol/overview#_commit)。

<a id="switch-branches"></a>

### 切换分支

Web IDE 默认使用当前分支。要在 Web IDE 中切换分支：

1. 在底部状态栏的左侧，选择当前的分支名称。
1. 输入或选择一个已有的分支。

<a id="create-a-branch"></a>

### 创建分支

要从当前分支在 Web IDE 中创建分支：

1. 在底部状态栏的左侧，选择当前的分支名称。
1. 从下拉列表中选择 **创建新分支**。
1. 输入新分支的名称。

Web IDE 会将当前检出的分支作为基线来创建分支。或者，你也可以按照以下步骤从不同的基线创建分支：

1. 在 Web IDE 左侧，选择 **源代码管理** ({{< icon name="branch" >}})，或按下 <kbd>Control</kbd>+<kbd>Shift</kbd>+<kbd>G</kbd>。
1. 选择源代码管理面板右上角的省略号菜单 ({{< icon name="ellipsis_h" >}})。
1. 从下拉列表中选择 **分支** > **从...创建分支**。
1. 从下拉列表中选择你想要用作基线的分支。

如果你没有仓库的写入权限，**创建新分支** 是不可见的。

<a id="delete-a-branch"></a>

### 删除分支

1. 在 Web IDE 左侧，选择 **源代码管理** ({{< icon name="branch" >}})，或按下 <kbd>Control</kbd>+<kbd>Shift</kbd>+<kbd>G</kbd>。
1. 选择源代码管理面板右上角的省略号菜单 ({{< icon name="ellipsis_h" >}})。
1. 从下拉列表中选择 **分支** > **删除分支**。
1. 从下拉列表中选择你想要删除的分支。

你无法从 Web IDE 中删除受保护的分支。

<a id="commit-changes"></a>

### 提交更改

要在 Web IDE 中提交更改：

1. 在 Web IDE 左侧，选择 **源代码管理** ({{< icon name="branch" >}})，或按下 <kbd>Control</kbd>+<kbd>Shift</kbd>+<kbd>G</kbd>。
1. 输入你的提交信息。
1. 选择以下提交选项之一：
   - **提交到当前分支** - 将更改提交到当前分支
   - **[创建新分支](#创建分支)** - 创建一个新分支并提交更改
   - **[提交并强制推送](#提交并强制推送)** - 将更改强制推送到远程分支
   - **[修订提交并强制推送](#修订提交并强制推送)** - 修改最后一次提交并强制推送

<a id="commit-and-force-push"></a>

### 提交并强制推送

要提交并强制推送你的更改：

1. 选择操作按钮菜单或选择省略号 ({{< icon name="ellipsis_h" >}})。
1. 选择 **提交并强制推送**。

> [!warning]
> 此操作会覆盖当前分支的远程历史记录。请谨慎使用。

<a id="amend-commit-and-force-push"></a>

### 修订提交并强制推送

要修订最后一次提交并强制推送：

1. 选择操作按钮菜单或选择省略号 ({{< icon name="ellipsis_h" >}})。
1. 选择 **修订提交并强制推送**。

这会更新最后一次提交并将其强制推送到远程仓库。使用此功能可以在不创建新提交的情况下修复最近的提交。

<a id="create-a-merge-request"></a>

## 创建合并请求

要在 Web IDE 中创建[合并请求](../merge_requests/_index.md)：

1. [提交更改](#提交更改)。
1. 在右下角出现的通知中，选择 **创建 MR**。

更多信息，请参阅[查看错过的通知](#查看错过的通知)。

<a id="customize-the-web-ide"></a>

## 自定义 Web IDE

自定义 Web IDE 以匹配你的键盘快捷方式、主题、设置和同步偏好。

<a id="use-the-command-palette"></a>

### 使用命令面板

你可以使用命令面板来访问许多命令。要在 Web IDE 中打开命令面板并运行命令：

1. 按下 <kbd>Shift</kbd>+<kbd>Command</kbd>+<kbd>P</kbd>。
1. 输入或选择命令。

<a id="edit-settings"></a>

### 编辑设置

你可以使用设置编辑器来查看和编辑你的用户及工作区设置。要在 Web IDE 中打开设置编辑器：

- 在顶部菜单栏中，选择 **文件** > **首选项** > **设置**，或按下 <kbd>Command</kbd>+<kbd>,</kbd>。

在设置编辑器中，你可以搜索你想要更改的设置。

<a id="edit-keyboard-shortcuts"></a>

### 编辑键盘快捷方式

你可以使用键盘快捷方式编辑器来查看和修改所有可用命令的默认键绑定。要在 Web IDE 中打开键盘快捷方式编辑器：

- 在顶部菜单栏中，选择 **文件** > **首选项** > **键盘快捷方式**，或按下 <kbd>Command</kbd>+<kbd>K</kbd> 然后 <kbd>Command</kbd>+<kbd>S</kbd>。

在键盘快捷方式编辑器中，你可以搜索：

- 你想要更改的键绑定
- 你想要添加或删除键绑定的命令

键绑定是基于你的键盘布局的。如果你更改了键盘布局，现有的键绑定会自动更新。

<a id="change-the-color-theme"></a>

### 更改颜色主题

你可以为 Web IDE 选择不同的颜色主题。默认主题是 **极狐GitLab Dark**。

要在 Web IDE 中更改颜色主题：

1. 在顶部菜单栏中，选择 **文件** > **首选项** > **主题** > **颜色主题**，或按下 <kbd>Command</kbd>+<kbd>K</kbd> 然后 <kbd>Command</kbd>+<kbd>T</kbd>。
1. 从下拉列表中，使用方向键预览主题。
1. 选择一个主题。

Web IDE 会将你当前的颜色主题存储在你的[用户设置](#编辑设置)中。

<a id="configure-sync-settings"></a>

### 配置同步设置

要在 Web IDE 中配置同步设置：

1. 按下 <kbd>Shift</kbd>+<kbd>Command</kbd>+<kbd>P</kbd>。
1. 在搜索框中输入 `Settings Sync: Configure`。
1. 选择或清除以下复选框：
   - **设置**
   - **键盘快捷方式**
   - **用户代码片段**
   - **用户任务**
   - **UI 状态**
   - **扩展**
   - **配置文件**

这些设置会在多个 Web IDE 实例之间自动同步。你无法同步用户配置文件，也无法回退到同步设置的早期版本。

<a id="view-missed-notifications"></a>

### 查看错过的通知

当你在 Web IDE 中执行操作时，通知会出现在右下角。要查看你可能错过的任何通知：

1. 在底部状态栏的右侧，选择铃铛图标 ({{< icon name="notifications" >}}) 以查看通知列表。
1. 选择你想要查看的通知。

<a id="manage-extensions"></a>

## 管理扩展

{{< details >}}

- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 17.0 中作为 [测试版](../../../policy/development_stages_support.md#beta) 引入，带有名为 `web_ide_oauth` 和 `web_ide_extensions_marketplace` 的[功能标志](../../../administration/feature_flags/_index.md)。默认禁用。
- 在极狐GitLab 17.4 中，`web_ide_oauth` 在 JihuLab.com 和私有化部署上启用。
- 在极狐GitLab 17.4 中，`web_ide_extensions_marketplace` 在 JihuLab.com 上启用。
- 在极狐GitLab 17.5 中，`web_ide_oauth` 被移除。
- 在极狐GitLab 17.10 中引入了功能标志 `vscode_extension_marketplace_settings`。默认禁用。
- 在极狐GitLab 17.11 中，`web_ide_extensions_marketplace` 在私有化部署上启用，且 `vscode_extension_marketplace_settings` 在 JihuLab.com 和私有化部署上启用。
- 在极狐GitLab 18.1 中 GA。功能标志 `web_ide_extensions_marketplace` 和 `vscode_extension_marketplace_settings` 被移除。

{{< /history >}}

VS Code 扩展市场提供了访问扩展的功能，以增强 Web IDE 的功能。默认情况下，极狐GitLab Web IDE 连接到 [Open VSX Registry](https://open-vsx.org/)。

> [!note]
> 要访问 VS Code 扩展市场，你的浏览器必须能够访问 `.cdn.web-ide.gitlab-static.net` 资产主机。此安全要求确保第三方扩展在隔离环境中运行，无法访问你的账户。这适用于 JihuLab.com 和私有化部署。

先决条件：

- 你必须已在用户偏好设置中[集成扩展市场](../../profile/preferences.md#integrate-with-the-extension-marketplace)。
- 对于私有化部署实例，极狐GitLab 管理员必须[启用扩展注册表](../../../administration/settings/vscode_extension_marketplace.md)。
- 对于企业用户，群组所有者必须[为企业用户启用扩展市场](../../enterprise_user/_index.md#enable-the-extension-marketplace-for-enterprise-users)。

<a id="install-an-extension"></a>

### 安装扩展

要在 Web IDE 中安装扩展：

1. 在顶部菜单栏中，选择 **视图** > **扩展**，或按下 <kbd>Command</kbd>+<kbd>Shift</kbd>+<kbd>X</kbd>。
1. 在搜索框中，输入扩展名称。
1. 选择你想要安装的扩展。
1. 选择 **安装**。

<a id="uninstall-an-extension"></a>

### 卸载扩展

要在 Web IDE 中卸载扩展：

1. 在顶部菜单栏中，选择 **视图** > **扩展**，或按下 <kbd>Command</kbd>+<kbd>Shift</kbd>+<kbd>X</kbd>。
1. 从已安装的扩展列表中，选择你想要卸载的扩展。
1. 选择 **卸载**。

<a id="extension-setup"></a>

### 扩展设置

Web IDE 扩展可能需要进行额外配置才能与你的项目配合使用。

<a id="use-vim-keybindings"></a>

#### 使用 Vim 键绑定

使用 Vim 键绑定可以通过 Vim 文本编辑器的键盘快捷方式来导航和编辑文本。借助扩展市场，你可以向 Web IDE 添加 Vim 键绑定。

要启用 Vim 键绑定，请安装 [Vim](https://open-vsx.org/extension/vscodevim/vim) 扩展。更多信息，请参阅[安装扩展](#安装扩展)。

<a id="asciidoc-support"></a>

#### AsciiDoc 支持

[AsciiDoc](https://open-vsx.org/extension/asciidoctor/asciidoctor-vscode) 扩展为 Web IDE 中的 AsciiDoc 文件提供了实时预览、语法高亮和代码片段。要在 Web IDE 中使用 AsciiDoc 标记预览，你必须安装 AsciiDoc 扩展。更多信息，请参阅[安装扩展](#安装扩展)。

<a id="troubleshooting"></a>

## 故障排除

在使用 Web IDE 时，你可能会遇到以下问题。

<a id="character-offset-when-typing"></a>

### 输入时字符偏移

当你在 Web IDE 中输入时，可能会出现四个字符的偏移。作为变通方法：

1. 在顶部菜单栏中，选择 **文件** > **首选项** > **设置**，或按下 <kbd>Command</kbd>+<kbd>,</kbd>。
1. 在右上角，选择 **打开设置 (JSON)**。
1. 在 `settings.json` 文件中添加 `"editor.disableMonospaceOptimizations": true`，或者更改 `"editor.fontFamily"` 设置。

更多信息，请参阅 [VS Code issue 80170](https://github.com/microsoft/vscode/issues/80170)。

<a id="update-the-oauth-callback-url"></a>

### 更新 OAuth 回调 URL

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

先决条件：

- 你必须拥有实例的管理员访问权限。

Web IDE 使用一个[实例范围的 OAuth 应用程序](../../../integration/oauth_provider.md#create-an-instance-wide-application)进行身份验证。如果 OAuth 回调 URL 配置错误，你可能会遇到一个 `Cannot open Web IDE` 错误页面，并显示以下消息：

```plaintext
你用来访问 Web IDE 的 URL 与配置的 OAuth 回调 URL 不匹配。此问题通常发生在你使用代理时。
```

要解决此问题，你必须更新 OAuth 回调 URL 以匹配用于访问极狐GitLab 实例的 URL。

先决条件：

- 管理员访问权限。

要更新 OAuth 回调 URL：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **应用程序**。
1. 对于 **极狐GitLab Web IDE**，选择 **编辑**。
1. 输入 OAuth 回调 URL。你可以输入多个 URL，用换行符分隔。

<a id="access-token-lifetime-cannot-be-less-than-5-minutes"></a>

### 访问令牌生命周期不能少于 5 分钟

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

你可能会遇到一条错误消息，指出访问令牌的生命周期不能少于 5 分钟。

当你的极狐GitLab 实例配置的访问令牌过期时间少于 5 分钟时，会出现此错误。Web IDE 要求访问令牌至少具有 5 分钟的生命周期才能正常工作。

要解决此问题，请在实例配置中将访问令牌生命周期增加到至少 5 分钟。有关配置访问令牌过期的更多信息，请参阅[访问令牌过期](../../../integration/oauth_provider.md#access-token-expiration)。

<a id="workhorse-dependency"></a>

### Workhorse 依赖

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

在私有化部署中，Workhorse 必须安装并运行在极狐GitLab Rails 服务器之前。如果没有安装，你可能会在打开 Web IDE 或使用某些功能（如 Markdown 预览）时遇到问题。

出于安全考虑，Web IDE 的某些部分必须在一个单独的源中运行。为了支持这种方法，Web IDE 使用 Workhorse 将请求适当地路由到 Web IDE 资产或从其路由。Web IDE 资产是静态前端资产，因此依赖 Rails 来处理这项工作是不必要的开销。

<a id="cors-issues"></a>

### CORS 问题

Web IDE 需要特定的跨域资源共享 (CORS) 配置才能在私有化部署实例上正常工作。极狐GitLab API 端点 (`/api/*`) 必须包含以下 HTTP 响应标头以支持 Web IDE：

| 标头 | 值 | 描述 |
|--------|-------|-------------|
| `Access-Control-Allow-Origin` | `https://[subdomain].cdn.web-ide.gitlab-static.net` | 允许来自 Web IDE 源的请求。`[subdomain]` 是一个动态生成的字母数字字符串（最多 52 个字符）。 |
| `Access-Control-Allow-Headers` | `Authorization` | 允许在跨域请求中使用 Authorization 标头。 |
| `Access-Control-Allow-Methods` | `GET, POST, PUT, DELETE, OPTIONS` | 指定允许的 HTTP 方法（推荐）。 |
| `Access-Control-Allow-Credentials` | `false` | Web IDE 不需要在 HTTP 请求中包含由此 [标头](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Access-Control-Allow-Credentials) 控制的凭据。 |
| `Access-Control-Expose-Headers` | `Link, X-Total, X-Total-Pages, X-Per-Page, X-Page, X-Next-Page, X-Prev-Page, X-Gitlab-Blob-Id, X-Gitlab-Commit-Id, X-Gitlab-Content-Sha256, X-Gitlab-Encoding, X-Gitlab-File-Name, X-Gitlab-File-Path, X-Gitlab-Last-Commit-Id X-Gitlab-Ref, X-Gitlab-Size, X-Request-Id, ETag, X-Streaming-Format` | 极狐GitLab REST 和 GraphQL API 使用的标头。 |
| `Vary` | `Origin` | 确保 CORS 响应的正确缓存行为。 |

Web IDE 会动态生成扩展主机域名的子域名部分。确保 CORS 标头满足以下规则：

- **模式匹配**: 接受与模式 `https://*.cdn.web-ide.gitlab-static.net` 匹配的源。
- **验证**: 确保子域名仅包含字母数字字符且长度不超过 52 个字符。
- **安全**: 永远不要为 Access-Control-Allow-Origin 使用通配符 (*)，这会带来安全风险。

极狐GitLab 实例的默认 CORS 配置能够满足这些要求。当私有化部署实例位于 HTTP 反向代理服务器之后或使用了自定义的 CORS 策略配置时，你可能会发现问题。

<a id="offline-environments"></a>

### 离线环境

当 Web IDE 无法连接到默认的扩展主机域名 (`https://*.cdn.web-ide.gitlab-static.net`) 时，其功能会受到限制。在离线环境中，极狐GitLab 管理员可以设置一个[自定义扩展主机域名](../../../administration/settings/web_ide.md)作为变通方法。