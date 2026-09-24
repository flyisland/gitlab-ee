---
stage: AI-powered
group: AI Framework
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 代码建议上下文感知
---

不同的信息可用于帮助 极狐GitLab Duo 做出决策并提供建议。

信息可以：

- 始终可用。
- 基于您的位置（当您导航时上下文会发生变化）。

以下上下文可供代码建议使用。

<a id="always-available"></a>

## 始终可用

- 通用编程知识、最佳实践和语言特性。
- 您正在查看或编辑的文件的名称、扩展名和内容，
  包括光标前后的内容。

<a id="based-on-location"></a>

## 基于位置

- 您在 IDE 的选项卡中打开的文件。可选，但默认开启。
  - 先决条件：
    - 极狐GitLab 17.2 或更高版本，以获得最佳的上下文权重。
    - 支持的 IDE 扩展。有关版本要求，请参阅
      [使用打开的文件作为上下文](#using-open-files-as-context)。
  - 这些文件为 极狐GitLab Duo 提供了有关项目中标准和实践的信息。
  - 如果您不希望它们用于上下文，请关闭文件。
  - 最近打开或更改的文件优先用于上下文。
  - 代码补全了解代码建议支持的所有语言。
  - 代码生成仅了解以下语言的文件：
    Go、Java、JavaScript、Kotlin、Python、Ruby、Rust、TypeScript（`.ts` 和 `.tsx` 文件）、Vue 和 YAML。
- 您正在查看或编辑的文件中导入的文件。可选，默认关闭。
  - 这些文件为 极狐GitLab Duo 提供了有关文件中类和方法的的信息。
  - 支持 JavaScript 和 TypeScript 文件，包括 `.js`、`.jsx`、`.ts`、`.tsx` 和 `.vue` 文件类型。
- 编辑器中选中的代码。
- 来自代码建议的仓库 X-Ray 文件。

> [!note]
> 匹配已知格式的密钥和敏感值在用于生成代码之前会被编辑。
> 这适用于通过 `/include` 添加的文件。

有关代码建议如何在 IDE 中使用上下文的更多信息，请参阅
[极狐GitLab Language Server 文档](https://jihulab.com/gitlab-cn/editor-extensions/gitlab-lsp#use-open-tabs-as-context)。

<a id="change-what-code-suggestions-uses-for-context"></a>

### 更改代码建议用于上下文的内容

您可以更改代码建议是否使用其他文件作为上下文。

<a id="using-open-files-as-context"></a>

#### 使用打开的文件作为上下文

{{< history >}}

- 在极狐GitLab 17.1 中引入，带有一个名为 `advanced_context_resolver` 的功能标志。默认禁用。
- 在极狐GitLab 17.1 中引入，带有一个名为 `code_suggestions_context` 的功能标志。默认禁用。
- 在极狐GitLab for VS Code 4.20.0 中引入。
- 在极狐GitLab Duo for JetBrains 2.7.0 中引入。
- 于 2024 年 7 月 16 日添加到极狐GitLab Neovim 插件中。
- 功能标志 `advanced_context_resolver` 和 `code_suggestions_context` 在 JihuLab.com 上于极狐GitLab 17.2 启用，在私有化部署上于极狐GitLab 17.4 启用。
- 在极狐GitLab 18.6 中 GA。功能标志 `code_suggestions_context` 已移除。

{{< /history >}}

默认情况下，代码建议在提出建议时使用 IDE 中打开的文件作为上下文。
但是，您可以关闭此设置。

先决条件：

- 极狐GitLab 17.2 或更高版本。支持代码建议的早期极狐GitLab 版本
  无法将打开选项卡的内容权重高于项目中的其他文件。
- 受支持的扩展：
  - 极狐GitLab for VS Code 扩展 6.2.2 或更高版本。
  - 极狐GitLab Duo plugin for JetBrains IDEs 3.6.5 或更高版本。
  - 极狐GitLab plugin for Neovim 1.1.0 或更高版本。
  - 极狐GitLab for Visual Studio 扩展 0.51.0 或更高版本。

要更改使用打开的文件作为上下文：

{{< tabs >}}

{{< tab title="Visual Studio Code" >}}

1. 在 VS Code 中，打开设置编辑器：
   - 对于 macOS，按 <kbd>Command</kbd>+<kbd>,</kbd>。
   - 对于 Windows 或 Linux，按 <kbd>Control</kbd>+<kbd>,</kbd>。
1. 选择 **扩展** > **极狐GitLab** > **极狐GitLab Duo**。
1. 在 **极狐GitLab › Duo 代码建议：打开选项卡上下文** 下，
   选择或清除 **使用打开的选项卡内容作为上下文**。

{{< /tab >}}

{{< tab title="JetBrains IDEs" >}}

1. 转到 IDE 的顶部菜单栏，然后选择 **设置**。
1. 在左侧边栏中，展开 **工具**，然后选择 **极狐GitLab Duo**。
1. 在 **其他语言** 下方，选择或清除 **将打开的选项卡作为上下文发送**。
1. 选择 **应用** 或 **保存**。

{{< /tab >}}

{{< /tabs >}}

<a id="using-imported-files-as-context"></a>

#### 使用导入的文件作为上下文

{{< history >}}

- 在极狐GitLab 17.9 中引入，带有一个名为 `code_suggestions_include_context_imports` 的功能标志。默认禁用。
- 在极狐GitLab 17.11 中于 JihuLab.com 和私有化部署上启用。
- 功能标志 `code_suggestions_include_context_imports` 在极狐GitLab 18.0 中已移除。

{{< /history >}}

使用 IDE 中导入的文件为您的代码项目提供上下文。导入文件上下文支持 JavaScript 和 TypeScript 文件，包括 `.js`、`.jsx`、`.ts`、`.tsx` 和 `.vue` 文件类型。