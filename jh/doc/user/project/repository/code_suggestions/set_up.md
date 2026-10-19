---
stage: AI 驱动
group: AI 编码
info: 如需确定与本页面关联的 Stage/Group 的技术文档作者，请访问 <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 在您的 IDE 中设置代码建议。
title: 设置代码建议
---

您可以在多种不同的 IDE 中使用极狐GitLab Duo 代码建议。

要设置代码建议，请按照您所用 IDE 的说明操作。

## 前提条件<a id="prerequisites"></a>

要使用代码建议，您需要：

- 如果您有极狐GitLab Duo Core，请[开启 IDE 功能](../../../gitlab_duo/turn_on_off.md#turn-gitlab-duo-core-on-or-off)。
- 确认代码建议[支持您的首选语言](supported_extensions.md#supported-languages-by-ide)。
  不同 IDE 支持的语言可能不同。

## 配置编辑器扩展<a id="configure-editor-extension"></a>

代码建议是编辑器扩展的一部分。要使用代码建议：

1. 在您的 IDE 中安装扩展。
1. 从 IDE 向极狐GitLab 进行身份验证。您可以使用 OAuth 或个人访问令牌。
1. 配置扩展。

请为您所用的 IDE 执行以下步骤：

- [Visual Studio Code](../../../../editor_extensions/visual_studio_code/setup.md)
- [Visual Studio](../../../../editor_extensions/visual_studio/setup.md)
- [极狐GitLab Duo 插件 for JetBrains IDEs](../../../../editor_extensions/jetbrains_ide/setup.md)
- [`gitlab.vim` 插件 for Neovim](../../../../editor_extensions/neovim/setup.md)
- [极狐GitLab for Eclipse](../../../../editor_extensions/eclipse/setup.md)

## 开启代码建议<a id="turn-on-code-suggestions"></a>

[如果您满足前提条件](#prerequisites)，代码建议即已开启。
要确认，请打开您的 IDE 并验证代码建议是否正常工作。

### VS Code<a id="vs-code"></a>

要验证代码建议是否在 VS Code 中开启：

1. 在 VS Code 中，打开设置编辑器：
   - 对于 macOS，按下 <kbd>Command</kbd>+<kbd>,</kbd>。
   - 对于 Windows 或 Linux，按下 <kbd>Control</kbd>+<kbd>,</kbd>。
1. 选择 **扩展** > **极狐GitLab** > **极狐GitLab Duo**。
1. 确保选中了 **极狐GitLab › Duo Code Suggestions: Enabled** 下的复选框。
1. 可选。在 **极狐GitLab › Duo Code Suggestions: Enabled Supported Languages** 下，选择您想要为其建议或生成代码的语言。
1. 可选。在 **极狐GitLab › Duo Code Suggestions: Additional Languages** 下，添加您想使用的其他语言。

### Visual Studio<a id="visual-studio"></a>

要验证代码建议是否在 Visual Studio 中开启：

1. 在 Visual Studio 中，将鼠标指向底部状态栏的极狐GitLab 图标。
1. 查看图标的工具提示，确认该功能已启用。
1. 如果代码建议未启用，请在顶部栏中选择 **扩展** > **极狐GitLab** > **切换代码建议** 以启用它。

### JetBrains IDEs<a id="jetbrains-ides"></a>

要验证代码建议是否在 JetBrains IDE 中开启：

1. 在您的 IDE 顶部栏中，选择您所用 IDE 的名称，然后选择 **设置**。
1. 在左侧边栏中，展开 **工具**，然后选择 **极狐GitLab Duo**。
1. 在 **Features** 部分，确保已选中 **Enable Code Suggestions** 和 **Enable GitLab Duo Chat**。
1. 选择 **确定** 或 **保存**。

#### 为代码建议添加自定义证书<a id="add-a-custom-certificate-for-code-suggestions"></a>

{{< history >}}

- 已在极狐GitLab Duo 2.10.0 中引入。

{{< /history >}}

极狐GitLab Duo 会尝试在无需您配置的情况下检测[受信任的根证书](https://www.jetbrains.com/help/idea/ssl-certificates.html)。如果需要，您可以配置 JetBrains IDE，以允许极狐GitLab Duo 插件在连接到您的极狐GitLab 实例时使用自定义 SSL 证书。

要将自定义 SSL 证书用于极狐GitLab Duo：

1. 在您的 IDE 顶部栏中，选择您所用 IDE 的名称，然后选择 **设置**。
1. 在左侧边栏中，展开 **工具**，然后选择 **极狐GitLab Duo**。
1. 在 **Connection** 下，输入 **URL to GitLab instance**。
1. 要验证连接，请选择 **Verify setup**。
1. 选择 **确定** 或 **保存**。

如果您的 IDE 检测到不受信任的 SSL 证书：

1. 极狐GitLab Duo 插件会显示一个确认对话框。
1. 查看显示的 SSL 证书详细信息。
   - 确认证书详细信息与您在浏览器中连接到极狐GitLab 时显示的证书一致。
1. 如果证书符合您的预期，请选择 **接受**。

要查看您已接受的证书：

1. 在您的 IDE 顶部栏中，选择您所用 IDE 的名称，然后选择 **设置**。
1. 在左侧边栏中，选择 **工具** > **Server Certificates**。
1. 选择 [**Server Certificates**](https://www.jetbrains.com/help/idea/settings-tools-server-certificates.html)。
1. 选择证书以查看它。

### Eclipse<a id="eclipse"></a>

> [!note]
> 要启用极狐GitLab Duo 代码建议，请打开一个 Eclipse 项目。如果您只打开单个文件，则代码建议对所有文件类型都将被禁用。

要验证代码建议是否在 Eclipse 中开启：

1. 在 Eclipse 中，打开您的极狐GitLab 项目。
1. 在 Eclipse 底部工具栏中，选择极狐GitLab 图标。

**代码建议** 将显示为“已启用”。

### Neovim<a id="neovim"></a>

代码建议提供了一个 LSP (语言服务器协议) 服务器，以支持内置的
<kbd>Control</kbd>+<kbd>x</kbd>, <kbd>Control</kbd>+<kbd>o</kbd> 全能补全键映射：

| 模式     | 键映射                          | 类型      | 描述 |
|----------|---------------------------------------|-----------|-------------|
| `INSERT` | <kbd>Control</kbd>+<kbd>x</kbd>, <kbd>Control</kbd>+<kbd>o</kbd> | 内置 | 通过语言服务器从极狐GitLab Duo 代码建议请求补全。 |
| `NORMAL` | `<Plug>(GitLabToggleCodeSuggestions)` | `<Plug>`  | 在当前缓冲区中开启或关闭代码建议。需要[配置](../../../../editor_extensions/neovim/setup.md#configure-plug-key-mappings)。 |

## 验证代码建议是否开启<a id="verify-that-code-suggestions-is-on"></a>

除 Neovim 外，所有来自极狐GitLab 的编辑器扩展都会在您的 IDE 状态栏中添加一个图标。
例如，在 Visual Studio 中：

![Visual Studio 中的状态栏。](img/visual_studio_status_bar_v17_4.png)

| 图标 | 状态 | 含义 |
| :--- | :----- | :------ |
| {{< icon name="tanuki-ai" >}} | **就绪** | 您已配置并启用了极狐GitLab Duo，并且您正在使用支持代码建议的语言。 |
| {{< icon name="tanuki-ai-off" >}} | **未配置** | 您尚未输入个人访问令牌，或者您正在使用代码建议不支持的语言。 |
| ![获取代码建议时的状态图标。](img/code_suggestions_loading_v17_4.svg) | **正在加载建议** | 极狐GitLab Duo 正在为您获取代码建议。 |
| ![代码建议出错时的状态图标。](img/code_suggestions_error_v17_4.svg) | **错误** | 极狐GitLab Duo 遇到了一个错误。 |

## 关闭代码建议<a id="turn-off-code-suggestions"></a>

关闭代码建议的过程因 IDE 而异。

> [!note]
> 您不能单独关闭代码生成和代码补全。

### VS Code<a id="vs-code-1"></a>

要在 VS Code 中关闭代码建议：

1. 在 VS Code 中，打开设置编辑器：
   - 对于 macOS，按下 <kbd>Command</kbd>+<kbd>,</kbd>。
   - 对于 Windows 或 Linux，按下 <kbd>Control</kbd>+<kbd>,</kbd>。
1. 选择 **扩展** > **极狐GitLab** > **极狐GitLab Duo**。
1. 在 **极狐GitLab › Duo Code Suggestions: Enabled** 下，清除复选框。

或者，您可以[在 VS Code 的 `settings.json` 文件中将 `gitlab.duoCodeSuggestions.enabled` 设置为 `false`](../../../../editor_extensions/visual_studio_code/settings.md#extension-settings)。

### Visual Studio<a id="visual-studio-1"></a>

要在不卸载扩展的情况下开启或关闭代码建议，
请[为 `GitLab.ToggleCodeSuggestions` 自定义命令分配一个键盘快捷键](../../../../editor_extensions/visual_studio/setup.md#configure-the-extension)。

要禁用或卸载扩展，请参阅
[Microsoft Visual Studio 中关于卸载或禁用扩展的文档](https://learn.microsoft.com/en-us/visualstudio/ide/finding-and-using-visual-studio-extensions?view=vs-2022#uninstall-or-disable-an-extension)。

### JetBrains IDEs<a id="jetbrains-ides-1"></a>

禁用极狐GitLab Duo (包括代码建议) 的过程，无论您使用哪种 JetBrains IDE 都是一样的。

1. 在您的 JetBrains IDE 中，进入设置并选择插件菜单。
1. 在已安装的插件下，找到极狐GitLab Duo 插件。
1. 禁用该插件。

更多信息，请参阅 [JetBrains 产品文档](https://www.jetbrains.com/help/)。

### Eclipse<a id="eclipse-1"></a>

要为一个项目禁用 Eclipse 代码建议：

1. 在 Eclipse 底部工具栏中，选择极狐GitLab 图标。
1. 选择 **禁用代码建议** 以为当前项目禁用代码建议。

要为特定语言禁用 Eclipse 代码建议：

1. 在 Eclipse 底部工具栏中，选择极狐GitLab 图标。
1. 选择 **显示设置**。
1. 向下滚动到 **Code Suggestions Enabled Languages** 部分，并清除您希望禁用的语言的复选框。

### Neovim<a id="neovim-1"></a>

1. 前往 [Neovim `defaults.lua` 设置文件](https://gitlab.com/gitlab-org/editor-extensions/gitlab.vim/-/blob/main/lua/gitlab/config/defaults.lua)。
1. 在 `code_suggestions` 下，将 `enabled =` 标志更改为 `false`：

   ```lua
   code_suggestions = {
   ...
    enabled = false,
   ```

### 关闭极狐GitLab Duo<a id="turn-off-gitlab-duo"></a>

或者，您可以为某个群组、项目或实例完全[关闭极狐GitLab Duo](../../../gitlab_duo/turn_on_off.md) (包括代码建议)。