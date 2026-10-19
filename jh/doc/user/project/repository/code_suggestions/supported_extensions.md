---
stage: AI-powered
group: AI Coding
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.jihulab.com/handbook/product/ux/technical-writing/#assignments>
description: Code Suggestions supports multiple editors and languages.
title: 支持的扩展和语言
---

代码建议在以下编辑器扩展和语言中可用。

<a id="supported-editor-extensions"></a>

## 支持的编辑器扩展

要使用代码建议，请使用以下编辑器扩展之一：

| IDE                                                             | 扩展 |
|-----------------------------------------------------------------|-----------|
| [极狐 GitLab Web IDE（云中的 VS Code）](../../web_ide/_index.md) | 无需配置。 |

极狐 GitLab 语言服务器用于 VS Code、Visual Studio、Eclipse 和 Neovim。语言服务器支持跨更多平台进行更快的迭代。您也可以配置它以在极狐 GitLab 不提供官方支持的 IDE 中支持代码建议。

您可以在 [此议题](https://jihulab.com/gitlab-cn/editor-extensions/meta/-/issues/78) 中表达对其他 IDE 扩展支持的兴趣。

<a id="supported-languages-by-ide"></a>

## IDE 支持的语言

下表提供了有关代码建议默认支持的语言和 IDE 的更多信息。

代码建议也适用于其他语言，但您必须 [手动添加支持](#add-support-for-more-languages)。

| 语言                            | 极狐 GitLab Web IDE |
|-------------------------------------|-------------|
| C                                   | {{< yes >}} |
| C++                                 | {{< yes >}} |
| C#                                  | {{< yes >}} |
| CSS                                 | {{< yes >}} |
| Go                                  | {{< yes >}} |
| Google SQL                          | {{< yes >}} |
| HAML                                | {{< yes >}} |
| HTML                                | {{< yes >}} |
| Java                                | {{< yes >}} |
| JavaScript                          | {{< yes >}} |
| Kotlin                              | {{< no >}}  |
| Markdown                            | {{< yes >}} |
| PHP                                 | {{< yes >}} |
| Python                              | {{< yes >}} |
| Ruby                                | {{< yes >}} |
| Rust                                | {{< yes >}} |
| Scala                               | {{< no >}}  |
| Shell scripts (`bash` only)         | {{< yes >}} |
| Svelte                              | {{< yes >}} |
| Swift                               | {{< yes >}} |
| TypeScript (`.ts` and `.tsx` files) | {{< yes >}} |
| Terraform                           | {{< no >}}  |
| Vue                                 | {{< yes >}} |

**脚注**：

1. VS Code 需要提供 Kotlin 支持的第三方扩展。
1. VS Code 需要提供 Scala 支持的第三方扩展。
1. VS Code 需要提供 Terraform 支持的第三方扩展。
1. Neovim 需要提供 `terraform` 文件类型的第三方扩展。

> [!note]
> 某些语言并非在所有 JetBrains IDE 中都受支持，或者可能需要额外的
> 插件支持。有关 IDE 的具体信息，请参阅 JetBrains 文档。

<a id="support-for-infrastructure-as-code-iac"></a>

## 基础设施即代码 (IaC) 支持

代码建议适用于基础设施即代码接口，包括：

- Kubernetes 资源模型 (KRM)
- Google Cloud CLI
- Terraform

<a id="manage-languages-for-code-suggestions"></a>

## 管理代码建议的语言

{{< history >}}

- [引入](https://jihulab.com/gitlab-cn/gitlab-vscode-extension/-/blob/main/CHANGELOG.md#4210-2024-07-16) 于 极狐 GitLab for VS Code 4.21.0

{{< /history >}}

您可以通过在 VS Code 中为特定支持的语言启用或禁用代码建议来自定义编码体验。
您可以通过直接编辑 `settings.json` 文件或从 VS Code 用户界面执行此操作：

1. 在 VS Code 中，打开设置编辑器：
   - 对于 macOS，按 <kbd>Command</kbd>+<kbd>,</kbd>。
   - 对于 Windows 或 Linux，按 <kbd>Control</kbd>+<kbd>,</kbd>。
1. 选择 **扩展** > **极狐 GitLab** > **极狐 GitLab Duo**。
1. 找到 **极狐 GitLab › Duo 代码建议：启用支持的语言** 部分。
1. 选择您想要建议或生成代码的语言。
1. 您的更改会自动保存并立即生效。

当您关闭某种语言的代码建议时，极狐 GitLab Duo 图标会更改以表明该语言不可用建议。

<a id="add-support-for-more-languages"></a>

## 添加对更多语言的支持

如果您需要的语言默认没有代码建议可用，
您可以在本地添加对语言的支持。
但是，代码建议可能无法按预期工作。

{{< tabs >}}

{{< tab title="Visual Studio Code" >}}

先决条件：

- 您已安装并启用了
  [极狐 GitLab for VS Code 扩展](../../../../editor_extensions/visual_studio_code/_index.md)。
- 您已完成 [VS Code 扩展设置](https://jihulab.com/gitlab-cn/gitlab-vscode-extension/#setup)
  说明，并授权扩展访问您的极狐 GitLab 账户。

执行此操作：

1. 在
   [语言标识符](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocumentItem) 列表中找到您需要的语言。
   您需要在后续步骤中使用语言的 **标识符**。
1. 在 VS Code 中，打开设置编辑器：
   - 对于 macOS，按 <kbd>Command</kbd>+<kbd>,</kbd>。
   - 对于 Windows 或 Linux，按 <kbd>Control</kbd>+<kbd>,</kbd>。
1. 选择 **扩展** > **极狐 GitLab** > **极狐 GitLab Duo**。
1. 在 **极狐 GitLab › Duo 代码建议：其他语言** 下，选择 **添加项**。
1. 输入您想要支持的每种语言的标识符。标识符应为
   小写，如 `html` 或 `powershell`。不要将文件后缀的前导句点添加到每个标识符。
1. 选择 **确定**。

{{< /tab >}}

{{< tab title="JetBrains IDEs" >}}

先决条件：

- 您已安装并启用了
  [极狐 GitLab Duo 插件 for JetBrains IDEs](../../../../editor_extensions/jetbrains_ide/_index.md)。
- 您已完成 [Jetbrains 扩展设置](https://jihulab.com/gitlab-cn/editor-extensions/gitlab-jetbrains-plugin#setup)
  说明，并授权扩展访问您的极狐 GitLab 账户。

执行此操作：

1. 在
   [语言标识符](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocumentItem) 列表中找到您需要的语言。
   您需要在后续步骤中使用语言的标识符。
1. 在您的 IDE 中，在顶部栏中，选择您的 IDE 名称，然后选择 **设置**。
1. 在左侧边栏中，选择 **工具** > **极狐 GitLab Duo**。
1. 在 **代码建议启用语言** > **其他语言** 下，添加您想要支持的每种语言的标识符。标识符应为小写，如 `html`。用逗号分隔多个标识符，
   如 `html,powershell,latex`，并且不要为每个标识符添加前导句点。
1. 选择 **确定**。

{{< /tab >}}

{{< tab title="Eclipse" >}}

先决条件：

- 您已安装并启用了 [极狐 GitLab for Eclipse 插件](../../../../editor_extensions/eclipse/_index.md)。
- 您已完成 [Eclipse 设置](../../../../editor_extensions/eclipse/setup.md)
  说明，并授权扩展访问您的极狐 GitLab 账户。

执行此操作：

1. 在 Eclipse 底部工具栏中，选择极狐 GitLab 图标。
1. 选择 **显示设置**。
1. 向下滚动到 **代码建议启用语言** 部分。
1. 在 **其他语言** 中，添加逗号分隔的语言标识符列表。不要
   为标识符添加前导句点。例如，使用 `html`、`md` 和 `powershell`。

{{< /tab >}}

{{< /tabs >}}