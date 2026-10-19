---
stage: AI Coding
group: DAP Repository Flows
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 代码建议使用 AI 在您输入时提供代码建议，帮助您在极狐GitLab 中更高效地编写代码。
title: 代码建议
---

{{< details >}}

- Tier: [基础版](../../../subscriptions/gitlab_credits.md#for-the-free-tier)，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< collapsible title="模型信息" >}}

- [默认 LLM](../../gitlab_duo/model_selection.md#default-models)
- Amazon Q 的 LLM：Amazon Q Developer
- 可在[自部署模型的极狐GitLab Duo](../../../administration/gitlab_duo_self_hosted/_index.md) 上使用

{{< /collapsible >}}

> [!note]
> 代码建议适用于：
>
> - 极狐GitLab Duo Agent Platform。计费方式为[基于用量](../../../subscriptions/gitlab_credits.md)。
> - 极狐GitLab Duo Pro 或 Enterprise、极狐GitLab Duo with Amazon Q。计费方式基于您的附加组件。

使用极狐GitLab Duo 代码建议，在开发过程中借助生成式 AI 提供代码建议，从而更高效地编写代码。

<a id="prerequisites"></a>

## 先决条件

- 如果您使用极狐GitLab Duo Core，请确保[已开启 IDE 功能](../turn_on_off.md#turn-gitlab-duo-core-on-or-off)。
- 已在您的 IDE 中[设置代码建议](../../project/repository/code_suggestions/set_up.md)。
- 您已设置[默认的极狐GitLab Duo 命名空间](../../profile/preferences.md#namespace-resolution-in-your-local-environment)，
  或已打开一个具有极狐GitLab Duo 访问权限的项目。

> [!note]
> 极狐GitLab Duo 需要极狐GitLab 17.2 或更高版本。要获得极狐GitLab Duo Core 访问权限，并获得最佳用户体验和结果，
> 请[升级到极狐GitLab 18.0 或更高版本](../../../update/_index.md)。更早的版本可能仍可继续使用，但体验可能会有所下降。

<a id="use-code-suggestions"></a>

## 使用代码建议

要使用代码建议：

1. 在您的 IDE 中打开一个项目。
1. 编写您的代码。
   在您输入时，会显示建议。代码建议会根据光标位置提供代码片段
   或补全当前行。
1. 用自然语言描述需求。
   代码建议会根据提供的上下文生成函数和代码片段。
1. 收到建议后，您可以执行以下任一操作：
   - 要接受建议，请按 <kbd>Tab</kbd>。
   - 要接受部分建议，请按 <kbd>Control</kbd>+<kbd>Right arrow</kbd> 或 <kbd>Command</kbd>+<kbd>Right arrow</kbd>。
   - 要拒绝建议，请按 <kbd>Esc</kbd>。在 Neovim 中，按 <kbd>Control</kbd>+<kbd>E</kbd> 退出菜单。
   - 要忽略建议，请像平常一样继续输入。

<a id="view-multiple-code-suggestions"></a>

## 查看多个代码建议

对于 VS Code 中的代码补全建议，可能会有多个建议选项可供选择。要查看所有可用建议：

1. 将鼠标悬停在代码补全建议上。
1. 浏览各个备选项。您可以：
   - 使用键盘快捷键：
     - 在 Mac 上，按 <kbd>Option</kbd>+<kbd>\[</kbd> 查看上一个建议，
       按 <kbd>Option</kbd>+<kbd>]</kbd> 查看下一个建议。
     - 在 Linux 和 Windows 上，按 <kbd>Alt</kbd>+<kbd>\[</kbd> 查看上一个建议，
       按 <kbd>Alt</kbd>+<kbd>]</kbd> 查看下一个建议。
   - 在显示的对话框中，选择右箭头或左箭头以查看下一个或上一个选项。
1. 按 <kbd>Tab</kbd> 应用您偏好的建议。

<a id="code-completion-and-generation"></a>

## 代码补全和代码生成

代码建议使用代码补全和代码生成：

|  | 代码补全 | 代码生成 |
| :---- | :---- | :---- |
| 用途 | 为补全当前代码行提供建议。  | 根据自然语言注释生成新代码。 |
| 触发方式 | 在输入时触发，通常有短暂延迟。  | 在编写包含特定关键字的注释后按 <kbd>Enter</kbd> 时触发。 |
| 范围 | 限于当前行或小段代码。  | 可根据上下文生成整个方法、函数甚至类。 |
| 准确性 | 对于小任务和短代码块更准确。  | 对于复杂任务和大代码块更准确，因为使用了更大的大语言模型（LLM），请求中会发送额外的上下文（例如项目使用的库），并且您的指令会传递给该 LLM。 |
| 使用方法 | 代码补全会自动为您正在输入的行建议补全内容。 | 您编写注释并按 <kbd>Enter</kbd>，或者输入一个空函数或方法。 |
| 使用时机 | 使用代码补全快速补全一行或几行代码。 | 对于更复杂的任务、更大的代码库，当您想根据自然语言描述从头编写新代码时，或者当您正在编辑的文件少于五行代码时，使用代码生成。 |

代码建议始终同时使用这两项功能。您不能只使用代码生成或只使用代码补全。


<a id="best-practices-for-code-generation"></a>

### 代码生成的最佳实践

要从代码生成中获得最佳结果：

- 尽可能具体，同时保持简洁。
- 说明您想要生成的结果（例如一个函数），
  并提供您想要实现的目标的详细信息。
- 添加额外信息，例如您想使用的框架或库。
- 在每条注释后添加一个空格或换行。
  这个空格会告知代码生成器您已完成指令。
- 检查并调整[代码建议可用的上下文](../../project/repository/code_suggestions/context.md#change-what-code-suggestions-uses-for-context)。

例如，要创建一个具有某些特定要求的 Python Web 服务，您可以编写类似以下内容：

```plaintext
# Create a web service using Tornado that allows a user to sign in, run a security scan, and review the scan results.
# Each action (sign in, run a scan, and review results) should be its own resource in the web service
...
```

AI 是非确定性的，因此相同的输入每次可能不会得到相同的建议。要生成高质量的代码，请编写清晰、描述性强、具体的任务。

有关用例和最佳实践，请遵循 [极狐GitLab Duo 示例文档](../../gitlab_duo/use_cases.md)。

<a id="available-language-models"></a>

## 可用的语言模型

不同的语言模型都可以作为代码建议的来源。

- 在 JihuLab.com 上：极狐GitLab 托管这些模型，并通过基于云的 AI 网关连接到它们。
- 在极狐GitLab 私有化部署上，有两种选择：
  - 极狐GitLab 可以[托管这些模型，并通过基于云的 AI 网关连接到它们](../../project/repository/code_suggestions/set_up.md)。
  - 您的组织可以使用[自部署模型](../../../administration/gitlab_duo_self_hosted/_index.md)，
    这意味着由您托管 AI 网关和语言模型。您可以使用极狐GitLab 管理的模型、
    其他受支持的语言模型，或自带兼容的模型。

<a id="accuracy-of-results"></a>

## 结果的准确性

我们正在持续改进整体生成内容的准确性。但是，代码建议可能会生成以下类型的建议：

- 不相关。
- 不完整。
- 可能导致流水线失败。
- 可能存在安全风险。
- 具有冒犯性或不够敏感。

使用代码建议时，代码评审最佳实践仍然适用。
