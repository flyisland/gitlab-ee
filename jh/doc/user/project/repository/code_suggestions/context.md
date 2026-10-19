---
stage: AI Coding
group: DAP Repository Flows
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 代码建议的上下文感知
---

有多种信息可帮助极狐GitLab Duo 做出决策并提供建议。

信息可在以下情况下可用：

- 始终可用。
- 根据您所在的位置（当您导航时上下文会发生变化）。

代码建议可使用以下上下文。

<a id="always-available"></a>

## 始终可用

- 通用编程知识、最佳实践和语言特性。
- 您正在查看或编辑的文件的名称、扩展名和内容，
  包括光标前后的内容。

<a id="based-on-location"></a>

## 基于位置

- 您在 IDE 标签页中打开的文件。可选，但默认开启。
  - 先决条件：
    - 极狐GitLab 17.2 或更高版本，以获得最佳的上下文权重。
    - 受支持的 IDE 扩展。有关版本要求，请参阅
      [使用打开的文件作为上下文](#using-open-files-as-context)。
  - 这些文件为极狐GitLab Duo 提供有关您项目中标准和实践的信息。
  - 如果您不希望这些文件用于上下文，请关闭它们。
  - 最近打开或更改的文件会优先用于上下文。
  - 代码补全可识别代码建议支持的所有语言。
  - 代码生成仅可识别以下语言的文件：
    Go、Java、JavaScript、Kotlin、Python、Ruby、Rust、TypeScript（`.ts` 和 `.tsx` 文件）、Vue 和 YAML。
- 在您正在查看或编辑的文件中导入的文件。可选，默认关闭。
  - 这些文件为极狐GitLab Duo 提供有关您文件中类和方法的信息。
  - 支持 JavaScript 和 TypeScript 文件，包括 `.js`、`.jsx`、`.ts`、`.tsx` 和 `.vue` 文件类型。
- 您在编辑器中选中的代码。
- 来自代码建议的 Repository X-Ray 文件。

> [!note]
> 与已知格式匹配的密钥和敏感值在用于生成代码之前
> 会被遮盖。
> 这适用于通过 `/include` 添加的文件。

有关代码建议如何在 IDE 中使用上下文的更多信息，请参阅
[GitLab Language Server 文档](https://gitlab.com/gitlab-org/editor-extensions/gitlab-lsp#use-open-tabs-as-context)。

<a id="change-what-code-suggestions-uses-for-context"></a>

### 更改代码建议用于上下文的内容

您可以更改代码建议是否使用其他文件作为上下文。

<a id="using-open-files-as-context"></a>

#### 使用打开的文件作为上下文

默认情况下，代码建议在提供建议时会使用 IDE 中打开的文件作为上下文。不过，您可以关闭此设置。

先决条件：

- 极狐GitLab 17.2 或更高版本。支持代码建议的早期极狐GitLab 版本
  无法为打开的标签页内容赋予比项目中其他文件更高的权重。
- 受支持的扩展：
  - GitLab for VS Code 扩展 6.2.2 或更高版本。
  - 适用于 JetBrains IDE 的极狐GitLab Duo 插件 3.6.5 或更高版本。
  - 适用于 Neovim 的 GitLab 插件 1.1.0 或更高版本。
  - 适用于 Visual Studio 的 GitLab 扩展 0.51.0 或更高版本。

要更改用作上下文的打开文件：

{{< tabs >}}

{{< tab title="Visual Studio Code" >}}

1. 在 VS Code 中，打开设置编辑器：
   - 对于 macOS，按 <kbd>Command</kbd>+<kbd>,</kbd>。
   - 对于 Windows 或 Linux，按 <kbd>Control</kbd>+<kbd>,</kbd>。
1. 选择**扩展** > **GitLab** > **极狐GitLab Duo**。
1. 在 **GitLab › Duo 代码建议：打开标签页上下文** 下，
   选中或清除 **使用打开的标签页内容作为上下文**。

{{< /tab >}}

{{< tab title="JetBrains IDEs" >}}

1. 转到 IDE 的顶部菜单栏，选择**设置**。
1. 在左侧边栏中，展开**工具**，然后选择 **极狐GitLab Duo**。
1. 在 **其他语言** 下，选中或清除 **将打开的标签页作为上下文发送**。
1. 选择**应用**或**保存**。

{{< /tab >}}

{{< /tabs >}}

<a id="using-imported-files-as-context"></a>

#### 使用导入的文件作为上下文

使用 IDE 中导入的文件来提供有关您代码项目的信息。导入文件上下文支持 JavaScript 和 TypeScript 文件，包括 `.js`、`.jsx`、`.ts`、`.tsx` 和 `.vue` 文件类型。
