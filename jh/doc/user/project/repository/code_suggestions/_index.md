---
stage: AI Coding
group: DAP Repository Flows
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 代码建议通过 AI 在您输入时提供代码建议，帮助您更高效地在极狐GitLab 中编写代码。
title: 代码建议
---

{{< details >}}

- Tier: [基础版](../../../../subscriptions/gitlab_credits.md#for-the-free-tier)，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< collapsible title="模型信息" >}}

- [默认 LLM](../../../gitlab_duo/model_selection.md#default-models)
- Amazon Q 的 LLM：Amazon Q Developer
- 适用于[自部署模型的极狐GitLab Duo](../../../../administration/gitlab_duo_self_hosted/_index.md)

{{< /collapsible >}}

> [!note]
> 代码建议适用于：
>
> - 极狐GitLab Duo Agent Platform。计费采用[基于用量](../../../../subscriptions/gitlab_credits.md)的方式。
> - 极狐GitLab Duo Pro 或 Enterprise、极狐GitLab Duo with Amazon Q。计费基于您的附加组件。

使用极狐GitLab Duo 代码建议，在开发过程中借助生成式 AI 提供代码建议，从而更高效地编写代码。

<a id="prerequisites"></a>

## 先决条件

- 如果您拥有极狐GitLab Duo Core，[IDE 功能已开启](../../../gitlab_duo/turn_on_off.md#turn-gitlab-duo-core-on-or-off)。
- 已在您的 IDE 中[设置代码建议](set_up.md)。
- 您已设置[默认极狐GitLab Duo 命名空间](../../../profile/preferences.md#namespace-resolution-in-your-local-environment)，
  或已打开一个具有极狐GitLab Duo 访问权限的项目。

> [!note]
> 极狐GitLab Duo 需要极狐GitLab 17.2 或更高版本。要获得极狐GitLab Duo Core 访问权限，并享受最佳用户体验和效果，
> 请[升级到极狐GitLab 18.0 或更高版本](../../../../update/_index.md)。更早的版本可能仍可继续使用，但体验可能会有所下降。

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
   - 要接受部分建议，请按 <kbd>Control</kbd>+<kbd>右箭头</kbd> 或 <kbd>Command</kbd>+<kbd>右箭头</kbd>。
   - 要拒绝建议，请按 <kbd>Esc</kbd>。在 Neovim 中，按 <kbd>Control</kbd>+<kbd>E</kbd> 退出菜单。
   - 要忽略建议，请像平常一样继续输入。

<a id="view-multiple-code-suggestions"></a>

## 查看多个代码建议

对于 VS Code 中的代码补全建议，可能会有多个建议选项可供选择。要查看所有可用建议：

1. 将鼠标悬停在代码补全建议上。
1. 滚动浏览各个备选项。您可以：
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
| 准确性 | 对于小任务和短代码块更准确。  | 对于复杂任务和大代码块更准确，因为使用了更大的大语言模型（LLM），请求中会发送额外的上下文（例如项目使用的库），并且您的指令会传递给 LLM。 |
| 使用方法 | 代码补全会自动为您正在输入的行建议补全内容。 | 您编写注释并按 <kbd>Enter</kbd>，或者输入一个空函数或方法。 |
| 使用时机 | 使用代码补全快速完成一行或几行代码。 | 对于更复杂的任务、更大的代码库，当您想根据自然语言描述从头编写新代码时，或者当您正在编辑的文件少于五行代码时，使用代码生成。 |

代码建议始终同时使用这两项功能。您不能只使用代码生成或只使用代码补全。


<a id="best-practices-for-code-generation"></a>

### 代码生成的最佳实践

要从代码生成中获得最佳效果：

- 在保持简洁的同时尽可能具体。
- 说明您想要生成的结果（例如一个函数），
  并提供您想要实现的目标的详细信息。
- 添加额外信息，例如您想使用的框架或库。
- 在每条注释后添加一个空格或换行。
  这个空格告诉代码生成器您已完成指令。
- 查看并调整[代码建议可用的上下文](context.md)。

例如，要创建一个具有某些特定需求的 Python Web 服务，您可以编写类似以下内容：

```plaintext
# Create a web service using Tornado that allows a user to sign in, run a security scan, and review the scan results.
# Each action (sign in, run a scan, and review results) should be its own resource in the web service
...
```

AI 是非确定性的，因此相同的输入每次可能不会得到相同的建议。要生成高质量的代码，请编写清晰、描述性强、具体的任务。

有关用例和最佳实践，请遵循 [极狐GitLab Duo 示例文档](../../../gitlab_duo/use_cases.md)。

<a id="available-language-models"></a>

## 可用的语言模型

不同的语言模型可以作为代码建议的来源。

- 在 JihuLab.com 上：极狐GitLab 托管这些模型，并通过基于云的 AI 网关连接到它们。
- 在极狐GitLab 私有化部署上，有两种选择：
  - 极狐GitLab 可以[托管这些模型，并通过基于云的 AI 网关连接到它们](set_up.md)。
  - 您的组织可以使用[自部署模型](../../../../administration/gitlab_duo_self_hosted/_index.md)，
    这意味着由您托管 AI 网关和语言模型。您可以使用极狐GitLab 托管的模型、
    其他受支持的语言模型，或自带兼容的模型。

<a id="performance"></a>

## 性能

了解代码建议的默认响应时间，以及流式传输、提示词缓存和配置连接的选项。

<a id="response-time"></a>

### 响应时间

代码建议由生成式 AI 模型提供支持。

- 对于代码补全，建议通常延迟较低，耗时不到一秒。
- 对于代码生成，算法或大型代码块可能需要五秒以上才能生成。

您的个人访问令牌可实现与 JihuLab.com 或您的极狐GitLab 实例的安全 API 连接。此 API 连接会安全地将上下文窗口从您的 IDE/编辑器传输到[极狐GitLab AI 网关](https://jihulab.com/gitlab-cn/modelops/ai-assist)，这是一个极狐GitLab 托管的服务。网关会调用大语言模型 API，然后将生成的建议传回您的 IDE/编辑器。

<a id="streaming"></a>

### 流式传输

JetBrains 和 Visual Studio 支持代码生成响应的流式传输，从而
带来更快的响应体验。其他受支持的 IDE 会以单个块的形式返回生成的代码。

代码补全未启用流式传输。

<a id="prompt-caching"></a>

### 提示词缓存

所有 Fireworks 托管的模型默认启用提示词缓存，以改善代码建议的延迟。

启用提示词缓存后，代码补全的提示词数据会由模型供应商临时存储在内存中。

提示词缓存通过避免重新处理已缓存的提示词和输入数据，显著改善延迟。缓存的数据绝不会记录到任何持久化存储中。

您可以[关闭提示词缓存](../../../gitlab_duo/data_usage.md#turn-off-prompt-caching)：

- 在 JihuLab.com 上：针对顶级群组。
- 在极狐GitLab 私有化部署上：针对实例。

此设置适用于所有极狐GitLab Duo Agent Platform 功能。

<a id="direct-and-indirect-connections"></a>

### 直接连接和间接连接

默认情况下，代码补全请求会从 IDE 直接发送到 AI 网关，以尽量降低延迟。要使此直接连接正常工作，IDE 必须能够连接到 `https://cloud.jihulab.com:443`。如果无法做到（例如由于网络限制），您可以为所有用户禁用直接连接。如果这样做，代码补全请求会通过极狐GitLab 私有化部署实例间接发送，该实例再将请求发送到 AI 网关。这可能会导致您的请求延迟更高。

<a id="configure-direct-or-indirect-connections"></a>

#### 配置直接或间接连接

先决条件：

- 您必须是极狐GitLab 私有化部署实例的管理员。

{{< tabs >}}

{{< tab title="在 17.4 及更高版本中" >}}

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**极狐GitLab Duo 功能**。
1. 在**连接方式**下，选择一个选项：
   - 要尽量降低代码补全请求的延迟，请选择**直接连接**。
   - 要为所有用户禁用直接连接，请选择**通过极狐GitLab 私有化部署间接连接**。
1. 选择**保存更改**。

{{< /tab >}}

{{< tab title="在 17.3 及更早版本中" >}}

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开 **AI 原生功能**。
1. 选择一个选项：
   - 要启用直接连接并尽量降低代码补全请求的延迟，请清除**禁用代码建议的直接连接**复选框。
   - 要禁用直接连接，请选中**禁用代码建议的直接连接**复选框。

{{< /tab >}}

{{< /tabs >}}

<a id="limitations"></a>

## 限制

<a id="truncation-of-file-content"></a>

### 文件内容截断

由于 LLM 限制和性能原因，当前打开文件的内容会被截断：

- 对于代码补全：截断为 32,000 个 token（约 128,000 个字符）。
- 对于代码生成：截断为 80,000 个 token（约 320,000 个字符）。

光标上方的内容优先于光标下方的内容。光标上方的内容从左侧截断，光标下方的内容从右侧截断。这些数字代表代码建议的最大输入上下文大小。

[议题 585841](https://gitlab.com/gitlab-org/gitlab/-/issues/585841)中提出了提高代码生成限制的支持。

<a id="output-length"></a>

### 输出长度

由于 LLM 限制和性能原因，代码建议的输出受到限制：

- 对于代码补全：限制为 64 个 token（约 256 个字符）。
- 对于代码生成：限制为 2048 个 token（约 7168 个字符）。

<a id="accuracy-of-results"></a>

### 结果准确性

我们正在持续改进整体生成内容的准确性。但是，代码建议可能会生成以下建议：

- 不相关。
- 不完整。
- 可能导致流水线失败。
- 可能不安全。
- 冒犯性或不够得体。

使用代码建议时，代码评审最佳实践仍然适用。
