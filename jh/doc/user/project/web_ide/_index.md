---
stage: AI Clients
group: unassigned
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 使用 Web IDE 在极狐GitLab UI 中编辑多个文件、暂存提交并创建合并请求。
title: Web IDE
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

Web IDE 是一个高级编辑器，您可以在极狐GitLab UI 中直接编辑多个文件、暂存更改并创建提交。与 [Web Editor](../repository/web_editor.md) 不同，Web IDE 提供了带源代码管理功能的完整开发环境。

在 Web IDE 中支持[极狐GitLab 风格 Markdown](../../markdown.md) 预览的提议见 [epic 15810](https://gitlab.com/groups/gitlab-org/-/epics/15810)。

<a id="open-the-web-ide"></a>

## 打开 Web IDE

您可以通过多种方式访问 Web IDE。

<a id="with-a-keyboard-shortcut"></a>

### 使用键盘快捷键

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 使用 <kbd>.</kbd> 键盘快捷键。

<a id="from-a-directory"></a>

### 从目录打开

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 进入您的目录。
1. 选择**代码** > **在 Web IDE 中打开**。

<a id="from-a-file"></a>

### 从文件打开

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 进入您的文件。
1. 选择**编辑** > **在 Web IDE 中打开**。

<a id="from-a-merge-request"></a>

### 从合并请求打开

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 进入您的合并请求。
1. 在右上角，选择**代码** > **在 Web IDE 中打开**。

Web IDE 会在单独的标签页中打开新增和修改过的文件，并排显示更改。为减少加载时间，只有更改行数最多的 10 个文件会自动打开。

Web IDE 界面会在左侧边栏的**资源管理器**视图中，在新增或修改过的文件旁边显示合并请求图标（{{< icon name="merge-request" >}}）。要查看文件的更改，请右键单击该文件并选择**与合并请求基线比较**。

<a id="manage-files"></a>

## 管理文件

您可以使用 Web IDE 打开、编辑和上传多个文件。

<a id="open-a-file"></a>

### 打开文件

要在 Web IDE 中按名称打开文件：

1. 按下 <kbd>Command</kbd>+<kbd>P</kbd>。
1. 在搜索框中，输入文件名。

<a id="search-open-files"></a>

### 搜索已打开的文件

要在 Web IDE 中搜索所有已打开的文件：

1. 按下 <kbd>Shift</kbd>+<kbd>Command</kbd>+<kbd>F</kbd>。
1. 在搜索框中，输入您的搜索词。

<a id="upload-a-file"></a>

### 上传文件

要在 Web IDE 中上传文件：

1. 在 Web IDE 的左侧，选择**资源管理器**（{{< icon name="documents" >}}），或按下 <kbd>Shift</kbd>+<kbd>Command</kbd>+<kbd>E</kbd>。
1. 进入您要上传文件的目标目录。
   要创建新目录：

   - 在**资源管理器**视图的右上角，选择**新建文件夹**（{{< icon name="folder-new" >}}）。

1. 右键单击该目录并选择**上传**。
1. 选择您要上传的文件。

您可以一次上传多个文件。文件上传后会自动添加到代码仓库中。

<a id="restore-uncommitted-changes"></a>

### 恢复未提交的更改

您无需手动保存在 Web IDE 中编辑的任何文件。Web IDE 会暂存您修改的文件，因此您可以[提交更改](#commit-changes)。未提交的更改会保存在浏览器的本地存储中。即使您关闭浏览器标签页或刷新 Web IDE，这些更改也会保留。

如果您的未提交更改不可用，可以从本地历史记录中恢复这些更改。要在 Web IDE 中恢复未提交的更改：

1. 按下 <kbd>Shift</kbd>+<kbd>Command</kbd>+<kbd>P</kbd>。
1. 在搜索框中，输入 `Local History: Find Entry to Restore`。
1. 选择包含未提交更改的文件。

<a id="use-source-control"></a>

## 使用源代码管理

您可以使用源代码管理来查看修改过的文件、创建和切换分支、提交更改以及创建合并请求。

<a id="view-modified-files"></a>

### 查看修改过的文件

要在 Web IDE 中查看您修改过的文件列表：

- 在 Web IDE 的左侧，选择**源代码管理**（{{< icon name="branch" >}}），或按下 <kbd>Control</kbd>+<kbd>Shift</kbd>+<kbd>G</kbd>。

您的 `CHANGES`、`STAGED CHANGES` 和 `MERGE CHANGES` 会显示出来。更多信息，请参阅 [VS Code 文档](https://code.visualstudio.com/docs/sourcecontrol/overview#_commit)。

<a id="switch-branches"></a>

### 切换分支

Web IDE 默认使用当前分支。要在 Web IDE 中切换分支：

1. 在底部状态栏的左侧，选择当前分支名称。
1. 输入或选择一个现有分支。

<a id="create-a-branch"></a>

### 创建分支

要在 Web IDE 中从当前分支创建分支：

1. 在底部状态栏的左侧，选择当前分支名称。
1. 从下拉列表中，选择**创建新分支**。
1. 输入新分支名称。

Web IDE 会以当前检出的分支为基础创建分支。或者，您也可以按照以下步骤从其他基线创建分支：

1. 在 Web IDE 的左侧，选择**源代码管理**（{{< icon name="branch" >}}），或按下 <kbd>Control</kbd>+<kbd>Shift</kbd>+<kbd>G</kbd>。
1. 在源代码管理面板的右上侧，选择省略号菜单（{{< icon name="ellipsis_h" >}}）。
1. 从下拉列表中，选择**分支** > **从...创建分支**。
1. 从下拉列表中，选择您要用作基线的分支。

如果您对代码仓库没有写入权限，则看不到**创建新分支**。

<a id="delete-a-branch"></a>

### 删除分支

1. 在 Web IDE 的左侧，选择**源代码管理**（{{< icon name="branch" >}}），或按下 <kbd>Control</kbd>+<kbd>Shift</kbd>+<kbd>G</kbd>。
1. 在源代码管理面板的右上侧，选择省略号菜单（{{< icon name="ellipsis_h" >}}）。
1. 从下拉列表中，选择**分支** > **删除分支**。
1. 从下拉列表中，选择您要删除的分支。

您无法从 Web IDE 中删除受保护分支。

<a id="commit-changes"></a>

### 提交更改

要在 Web IDE 中提交更改：

1. 在 Web IDE 的左侧，选择**源代码管理**（{{< icon name="branch" >}}），或按下 <kbd>Control</kbd>+<kbd>Shift</kbd>+<kbd>G</kbd>。
1. 输入您的提交信息。
1. 选择以下提交选项之一：
   - **提交到当前分支** - 将更改提交到当前分支
   - **[创建新分支](#create-a-branch)** - 创建新分支并提交更改
   - **[提交并强制推送](#commit-and-force-push)** - 将更改强制推送到远程分支
   - **[修改提交并强制推送](#amend-commit-and-force-push)** - 修改最后一次提交并强制推送

<a id="commit-and-force-push"></a>

### 提交并强制推送

要提交并强制推送您的更改：

1. 选择操作按钮菜单或选择省略号（{{< icon name="ellipsis_h" >}}）。
1. 选择**提交并强制推送**。

> [!warning]
> 此操作会覆盖当前分支的远程历史记录。请谨慎使用。

<a id="amend-commit-and-force-push"></a>

### 修改提交并强制推送

要修改最后一次提交并强制推送：

1. 选择操作按钮菜单或选择省略号（{{< icon name="ellipsis_h" >}}）。
1. 选择**修改提交并强制推送**。

这会更新最后一次提交并将其强制推送到远程代码仓库。使用此功能可以修复最近的提交，而无需创建新提交。

<a id="create-a-merge-request"></a>

## 创建合并请求

要在 Web IDE 中创建[合并请求](../merge_requests/_index.md)：

1. [提交更改](#commit-changes)。
1. 在右下角出现的通知中，选择**创建合并请求**。

更多信息，请参阅[查看错过的通知](#view-missed-notifications)。

<a id="customize-the-web-ide"></a>

## 自定义 Web IDE

您可以自定义 Web IDE，使其符合您对键盘快捷键、主题、设置和同步的偏好。

<a id="use-the-command-palette"></a>

### 使用命令面板

您可以使用命令面板访问许多命令。要在 Web IDE 中打开命令面板并运行命令：

1. 按下 <kbd>Shift</kbd>+<kbd>Command</kbd>+<kbd>P</kbd>。
1. 输入或选择命令。

<a id="edit-settings"></a>

### 编辑设置

您可以使用设置编辑器查看和编辑您的用户设置及 Web IDE 工作区设置。要在 Web IDE 中打开设置编辑器：

- 在顶部菜单栏中，选择**文件** > **首选项** > **设置**，或按下 <kbd>Command</kbd>+<kbd>,</kbd>。

在设置编辑器中，您可以搜索要更改的设置。

<a id="edit-keyboard-shortcuts"></a>

### 编辑键盘快捷键

您可以使用键盘快捷键编辑器查看和更改所有可用命令的默认键绑定。要在 Web IDE 中打开键盘快捷键编辑器：

- 在顶部菜单栏中，选择**文件** > **首选项** > **键盘快捷键**，或按下 <kbd>Command</kbd>+<kbd>K</kbd>，然后按下 <kbd>Command</kbd>+<kbd>S</kbd>。

在键盘快捷键编辑器中，您可以搜索：

- 要更改的键绑定
- 要添加或删除键绑定的命令

键绑定基于您的键盘布局。如果您更改键盘布局，现有键绑定会自动更新。

<a id="change-the-color-theme"></a>

### 更改颜色主题

您可以为 Web IDE 选择不同的颜色主题。默认主题是 **GitLab Dark**。

要在 Web IDE 中更改颜色主题：

1. 在顶部菜单栏中，选择**文件** > **首选项** > **主题** > **颜色主题**，或按下 <kbd>Command</kbd>+<kbd>K</kbd>，然后按下 <kbd>Command</kbd>+<kbd>T</kbd>。
1. 从下拉列表中，使用方向键预览主题。
1. 选择一个主题。

Web IDE 会将您当前使用的颜色主题存储在您的[用户设置](#edit-settings)中。

<a id="configure-sync-settings"></a>

### 配置同步设置

要在 Web IDE 中配置同步设置：

1. 按下 <kbd>Shift</kbd>+<kbd>Command</kbd>+<kbd>P</kbd>。
1. 在搜索框中，输入 `Settings Sync: Configure`。
1. 选中或清除以下复选框：
   - **设置**
   - **键盘快捷键**
   - **用户代码片段**
   - **用户任务**
   - **UI 状态**
   - **扩展**
   - **配置文件**

这些设置会自动在多个 Web IDE 实例之间同步。您无法同步用户配置文件，也无法回退到已同步设置的早期版本。

<a id="view-missed-notifications"></a>

### 查看错过的通知

当您在 Web IDE 中执行操作时，通知会出现在右下角。要查看您可能错过的任何通知：

1. 在底部状态栏的右侧，选择铃铛图标（{{< icon name="notifications" >}}）以查看通知列表。
1. 选择您要查看的通知。

<a id="manage-extensions"></a>

## 管理扩展

{{< details >}}

- Offering: JihuLab.com，私有化部署

{{< /details >}}

VS Code 扩展市场提供了对增强 Web IDE 功能的扩展的访问。默认情况下，极狐GitLab Web IDE 连接到 [Open VSX Registry](https://open-vsx.org/)。

> [!note]
> 要访问 VS Code 扩展市场，您的浏览器必须能够访问 `.cdn.web-ide.gitlab-static.net` 资源主机。
> 这一安全要求可确保第三方扩展在隔离环境中运行，并且无法访问您的账号。
> 这同时适用于 JihuLab.com 和极狐GitLab 私有化部署。

先决条件：

- 您必须在用户偏好设置中[集成扩展市场](../../profile/preferences.md#integrate-with-the-extension-marketplace)。
- 对于极狐GitLab 私有化部署，极狐GitLab 管理员必须[启用扩展仓库](../../../administration/settings/vscode_extension_marketplace.md)。
- 对于企业用户，群组所有者必须[为企业用户启用扩展市场](../../enterprise_user/_index.md#enable-the-extension-marketplace-for-enterprise-users)。

<a id="install-an-extension"></a>

### 安装扩展

要在 Web IDE 中安装扩展：

1. 在顶部菜单栏中，选择**查看** > **扩展**，或按下 <kbd>Command</kbd>+<kbd>Shift</kbd>+<kbd>X</kbd>。
1. 在搜索框中，输入扩展名称。
1. 选择您要安装的扩展。
1. 选择**安装**。

<a id="uninstall-an-extension"></a>

### 卸载扩展

要在 Web IDE 中卸载扩展：

1. 在顶部菜单栏中，选择**查看** > **扩展**，或按下 <kbd>Command</kbd>+<kbd>Shift</kbd>+<kbd>X</kbd>。
1. 从已安装扩展列表中，选择您要卸载的扩展。
1. 选择**卸载**。

<a id="extension-setup"></a>

### 扩展设置

Web IDE 扩展可能需要额外配置才能与您的项目配合使用。

<a id="use-vim-keybindings"></a>

#### 使用 Vim 键绑定

使用 Vim 键绑定可以通过 Vim 文本编辑器的键盘快捷键来导航和编辑文本。借助扩展市场，您可以将 Vim 键绑定添加到 Web IDE。

要启用 Vim 键绑定，请安装 [Vim](https://open-vsx.org/extension/vscodevim/vim) 扩展。更多信息，请参阅[安装扩展](#install-an-extension)。

<a id="asciidoc-support"></a>

#### AsciiDoc 支持

[AsciiDoc](https://open-vsx.org/extension/asciidoctor/asciidoctor-vscode) 扩展为 Web IDE 中的 AsciiDoc 文件提供实时预览、语法高亮和代码片段。要在 Web IDE 中使用 AsciiDoc 标记预览，您必须安装 AsciiDoc 扩展。更多信息，请参阅[安装扩展](#install-an-extension)。

<a id="troubleshooting"></a>

## 故障排除

使用 Web IDE 时，您可能会遇到以下问题。

<a id="character-offset-when-typing"></a>

### 输入时出现字符偏移

在 Web IDE 中输入时，您可能会遇到四个字符的偏移。作为变通方法：

1. 在顶部菜单栏中，选择**文件** > **首选项** > **设置**，或按下 <kbd>Command</kbd>+<kbd>,</kbd>。
1. 在右上角，选择**打开设置 (JSON)**。
1. 在 `settings.json` 文件中，添加 `"editor.disableMonospaceOptimizations": true` 或更改 `"editor.fontFamily"` 设置。

更多信息，请参阅 [VS Code 议题 80170](https://github.com/microsoft/vscode/issues/80170)。

<a id="update-the-oauth-callback-url"></a>

### 更新 OAuth 回调 URL

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

先决条件：

- 您必须拥有实例的管理员访问权限。

Web IDE 使用[实例级 OAuth 应用](../../../integration/oauth_provider.md#create-an-instance-wide-application)进行身份验证。如果 OAuth 回调 URL 配置错误，您可能会遇到 `Cannot open Web IDE` 错误页面，并显示以下消息：

```plaintext
The URL you're using to access the Web IDE and the configured OAuth callback URL do not match. This issue often occurs when you're using a proxy.
```

要解决此问题，您必须更新 OAuth 回调 URL，使其与用于访问极狐GitLab 实例的 URL 一致。

先决条件：

- 管理员访问权限。

要更新 OAuth 回调 URL：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**应用**。
1. 对于 **GitLab Web IDE**，选择**编辑**。
1. 输入 OAuth 回调 URL。您可以输入多个 URL，用换行符分隔。

<a id="access-token-lifetime-cannot-be-less-than-5-minutes"></a>

### 访问令牌生命周期不能少于 5 分钟

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

您可能会遇到一条错误消息，提示访问令牌生命周期不能少于 5 分钟。

当您的极狐GitLab 实例配置的访问令牌过期时间少于 5 分钟时，就会出现此错误。Web IDE 要求访问令牌的最短生命周期为 5 分钟才能正常工作。

要解决此问题，请在实例配置中将访问令牌生命周期增加到至少 5 分钟。有关配置访问令牌过期的更多信息，请参阅[访问令牌过期](../../../integration/oauth_provider.md#access-token-expiration)。

<a id="workhorse-dependency"></a>

### Workhorse 依赖

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

在极狐GitLab 私有化部署上，Workhorse 必须安装并运行在 GitLab Rails 服务器前面。否则，您在打开 Web IDE 或使用 Markdown 预览等某些功能时可能会遇到问题。

出于安全考虑，Web IDE 的某些部分必须在单独的源中运行。为支持这种方式，Web IDE 使用 Workhorse 适当地路由发往 Web IDE 资源及由这些资源返回的请求。Web IDE 资源是静态前端资源，因此依赖 Rails 来完成这项工作是不必要的开销。

<a id="cors-issues"></a>

### CORS 问题

Web IDE 需要特定的跨源资源共享（CORS）配置才能在极狐GitLab 私有化部署实例上正常工作。极狐GitLab API 端点（`/api/*`）必须包含以下 HTTP 响应头以支持 Web IDE：

| 响应头 | 值 | 描述 |
|--------|-------|-------------|
| `Access-Control-Allow-Origin` | `https://[subdomain].cdn.web-ide.gitlab-static.net` | 允许来自 Web IDE 源的请求。`[subdomain]` 是动态生成的字母数字字符串（最多 52 个字符）。 |
| `Access-Control-Allow-Headers` | `Authorization` | 允许跨源请求中的 Authorization 请求头。 |
| `Access-Control-Allow-Methods` | `GET, POST, PUT, DELETE, OPTIONS` | 指定允许的 HTTP 方法（推荐）。 |
| `Access-Control-Allow-Credentials` | `false` | Web IDE 不需要在 HTTP 请求中包含由此[响应头](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Access-Control-Allow-Credentials)控制的凭据。 |
| `Access-Control-Expose-Headers` | `Link, X-Total, X-Total-Pages, X-Per-Page, X-Page, X-Next-Page, X-Prev-Page, X-Gitlab-Blob-Id, X-Gitlab-Commit-Id, X-Gitlab-Content-Sha256, X-Gitlab-Encoding, X-Gitlab-File-Name, X-Gitlab-File-Path, X-Gitlab-Last-Commit-Id X-Gitlab-Ref, X-Gitlab-Size, X-Request-Id, ETag, X-Streaming-Format` | 极狐GitLab Rest 和 GraphQL API 使用的响应头。 |
| `Vary` | `Origin` | 确保 CORS 响应的正确缓存行为。 |

Web IDE 会动态生成扩展主机域的子域部分。请确保 CORS 响应头满足以下规则：

- **模式匹配**：接受与模式 `https://*.cdn.web-ide.gitlab-static.net` 匹配的源。
- **验证**：确保子域仅包含字母数字字符，且长度不超过 52 个字符。
- **安全性**：切勿对 Access-Control-Allow-Origin 使用通配符（`*`），因为这会带来安全风险。

极狐GitLab 实例的默认 CORS 配置满足这些要求。当极狐GitLab 私有化部署实例位于 HTTP 反向代理服务器后面或使用自定义 CORS 策略配置时，您可能会发现问题。

<a id="offline-environments"></a>

### 离线环境

当 Web IDE 无法连接到默认扩展主机域（`https://*.cdn.web-ide.gitlab-static.net`）时，其功能会受到限制。在离线环境中，极狐GitLab 管理员可以设置[自定义扩展主机域](../../../administration/settings/web_ide.md)作为变通方法。

<a id="report-a-problem"></a>

### 报告问题

要报告问题，请[创建新议题](https://gitlab.com/gitlab-org/gitlab-web-ide/-/issues/new)，并提供以下信息：

- 错误消息
- 完整的错误详情
- 问题发生的频率
- 重现问题的步骤

如果您使用的是付费版本，也可以[联系支持](https://gitlab.cn/support)寻求帮助。
