---
stage: AI-powered
group: AI Coding
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Code Suggestions helps you write code in GitLab more efficiently by using AI to suggest code as you type.
title: 代码建议
---

{{< details >}}

- Tier: [基础版](../../../subscriptions/gitlab_credits.md#for-the-free-tier-on-gitlabcom)，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< collapsible title="模型信息" >}}

- [默认 LLM](../../gitlab_duo/model_selection.md#default-models)
- 可访问 [自部署模型的 极狐GitLab Duo](../../../administration/gitlab_duo_self_hosted/_index.md)

{{< /collapsible >}}

{{< history >}}

- 在极狐GitLab 16.1 中引入了对国内 SOTA 模型的支持。
- 在极狐GitLab 16.2 中移除了对极狐GitLab 原生模型的支持。
- 在极狐GitLab 16.3 中引入了对代码生成的支持。
- 在极狐GitLab 16.7 中 GA。
- 于 2024 年 2 月 15 日变更，要求使用极狐GitLab Duo Pro 附加功能。此前，该功能包含在专业版和旗舰版订阅中。
- 自 2024 年 10 月 17 日起变更，要求所有受支持的极狐GitLab 版本使用极狐GitLab Duo Pro 或极狐GitLab Duo Enterprise 附加功能。
- 在极狐GitLab 17.6 中引入了对 Fireworks AI 托管的 Qwen2.5 代码补全模型的支持，并带有一个名为 `fireworks_qwen_code_completion` 的功能标志。
- 在极狐GitLab 17.11 中移除了对 Qwen2.5 代码补全模型的支持。
- 在极狐GitLab 17.11 中通过功能标志 `use_fireworks_codestral_code_completion` 默认启用了国内 SOTA 大模型。
- 在极狐GitLab 18.0 中变更以包含极狐GitLab Duo Core。
- 在极狐GitLab 18.1 中将国内 SOTA 大模型启用为默认模型。
- 在极狐GitLab 18.2 中将代码生成的默认模型改为国内 SOTA 大模型。
- 在极狐GitLab 18.6 中移除了功能标志 `code_suggestions_context`。
- 在极狐GitLab 18.10 中，在 JihuLab.com 上基础版层可用，需使用极狐GitLab 积分。

{{< /history >}}

> [!note]
> Code Suggestions 可用于：
>
> - 极狐GitLab Duo Agent Platform。计费方式为[基于用量](../../../subscriptions/gitlab_credits.md)。
> - 极狐GitLab Duo Core、Pro 或 Enterprise。计费方式基于你的附加功能。

使用极狐GitLab Duo 代码建议，通过生成式 AI 在你开发时建议代码，从而更高效地编写代码。

<a id="prerequisites"></a>

## 先决条件

要使用代码建议：
- 如果你有极狐GitLab Duo Core，[开启 IDE 功能](../turn_on_off.md#turn-gitlab-duo-core-on-or-off)。
- [设置代码建议](../../project/repository/code_suggestions/set_up.md)。

> [!note]
> 极狐GitLab Duo 要求极狐GitLab 17.2 或更高版本。为了使用极狐GitLab Duo Core 并获得最佳用户体验和效果，请[升级到极狐GitLab 18.0 或更高版本](../../../update/_index.md)。早期版本可能仍可工作，但体验可能会有所下降。

<a id="use-code-suggestions"></a>

## 使用代码建议

要使用代码建议：
1. 在[支持的 IDE](../../project/repository/code_suggestions/supported_extensions.md#supported-editor-extensions) 中打开你的 Git 项目。
1. 使用 [`git remote add`](../../../topics/git/commands.md#git-remote-add) 将项目添加为本地仓库的远程。
1. 将你的项目目录（包括隐藏的 `.git/` 文件夹）添加到 IDE 工作区或项目中。
1. 编写代码。在你输入时，会显示建议。代码建议根据光标位置提供代码片段或补全当前行。
1. 用自然语言描述需求。代码建议根据提供的上下文生成函数和代码片段。
1. 收到建议后，你可以执行以下任一操作：
   - 要接受建议，按 <kbd>Tab</kbd>。
   - 要接受部分建议，按 <kbd>Control</kbd>+<kbd>Right arrow</kbd> 或 <kbd>Command</kbd>+<kbd>Right arrow</kbd>。
   - 要拒绝建议，按 <kbd>Esc</kbd>。在 Neovim 中，按 <kbd>Control</kbd>+<kbd>E</kbd> 退出菜单。
   - 要忽略建议，继续按通常的方式输入。

<a id="view-multiple-code-suggestions"></a>

## 查看多个代码建议

{{< history >}}

- 在极狐GitLab 17.1 中引入。

{{< /history >}}

在 VS Code 中，一个代码补全建议可能会提供多个选项。要查看所有可用建议：

1. 将鼠标悬停在代码补全建议上。
1. 浏览备选方案。可以通过以下方式：
   - 使用键盘快捷键：
     - 在 Mac 上，按 <kbd>Option</kbd>+<kbd>\[</kbd> 查看上一个建议，按 <kbd>Option</kbd>+<kbd>]</kbd> 查看下一个建议。
     - 在 Linux 和 Windows 上，按 <kbd>Alt</kbd>+<kbd>\[</kbd> 查看上一个建议，按 <kbd>Alt</kbd>+<kbd>]</kbd> 查看下一个建议。
   - 在显示的对话框中，选择右箭头或左箭头查看下一个或上一个选项。
1. 按 <kbd>Tab</kbd> 应用你偏好的建议。

<a id="code-completion-and-generation"></a>

## 代码补全与生成

代码建议使用代码补全和代码生成：

|  | 代码补全 | 代码生成 |
| :---- | :---- | :---- |
| 目的 | 提供完成当前代码行的建议。 | 根据自然语言注释生成新代码。 |
| 触发方式 | 在键入时触发，通常有短暂延迟。 | 在编写包含特定关键字的注释后按 <kbd>Enter</kbd> 时触发。 |
| 范围 | 限于当前行或小块代码。 | 可以基于上下文生成整个方法、函数甚至类。 |
| 准确性 | 对于小任务和短代码块更准确。 | 对于复杂任务和大型代码块更准确，因为使用了更大的大语言模型 (LLM)，并在请求中发送了额外的上下文（例如项目使用的库），并且你的指令会传递给 LLM。 |
| 使用方式 | 代码补全自动建议你正在输入的行的补全。 | 你编写注释并按 <kbd>Enter</kbd>，或者输入一个空的函数或方法。 |
| 何时使用 | 使用代码补全快速完成一行或几行代码。 | 对于更复杂的任务、更大的代码库、当你想要从头开始基于自然语言描述编写新代码时，或者当你正在编辑的文件少于五行代码时，使用代码生成。 |

代码建议始终同时使用这两项功能。你不能仅使用代码生成或仅使用代码补全。

<a id="best-practices-for-code-generation"></a>

### 代码生成的最佳实践

要从代码生成中获得最佳结果：
- 在保持简洁的同时尽可能具体。
- 说明你想要生成的结果（例如，一个函数），并提供你想要实现的详细信息。
- 添加额外信息，比如你想要使用的框架或库。
- 在每个注释后添加一个空格或换行。这个空格告诉代码生成器你已经完成了指令。
- 审查并调整[代码建议可用的上下文](../../project/repository/code_suggestions/context.md#change-what-code-suggestions-uses-for-context)。

例如，要创建一个具有特定要求的 Python Web 服务，你可以编写类似这样的内容：

```plaintext
# 创建一个使用 Tornado 的 Web 服务，允许用户登录、运行安全扫描并查看扫描结果。
# 每个操作（登录、运行扫描和查看结果）都应该是 Web 服务中的独立资源。
...
```

AI 是非确定性的，因此每次使用相同的输入可能不会得到相同的建议。要生成高质量的代码，请编写清晰、描述性、具体的任务。

有关用例和最佳实践，请遵循[极狐GitLab Duo 示例文档](../../gitlab_duo/use_cases.md)。

<a id="available-language-models"></a>

## 可用语言模型

不同的语言模型可以作为代码建议的来源。
- 在 JihuLab.com 上：极狐GitLab 托管模型并通过基于云的 AI 网关连接到它们。
- 在私有化部署上，有两种选择：
  - 极狐GitLab 可以[托管模型并通过基于云的 AI 网关连接到它们](../../project/repository/code_suggestions/set_up.md)。
  - 你的组织可以使用[自部署模型](../../../administration/gitlab_duo_self_hosted/_index.md)，这意味着你托管 AI 网关和语言模型。你可以使用极狐GitLab 管理的模型、其他支持的语言模型，或者自带兼容的模型。

<a id="accuracy-of-results"></a>

## 结果的准确性

我们持续努力提高整体生成内容的准确性。
但是，代码建议可能会生成以下建议：
- 无关的。
- 不完整的。
- 可能导致流水线失败。
- 可能存在安全风险。
- 冒犯或不敏感。

在使用代码建议时，代码审查最佳实践仍然适用。