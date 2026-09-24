---
stage: AI-powered
group: AI Coding
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Code Suggestions helps you write code in GitLab more efficiently by using AI to suggest code as you type.
title: 代码建议
---

{{< details >}}

- Tier: [基础版](../../../../subscriptions/gitlab_credits.md#for-the-free-tier-on-gitlabcom)，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< collapsible title="模型信息" >}}

- [默认 LLM](../../../gitlab_duo/model_selection.md#default-models)
- 可在 [自部署模型的 极狐GitLab Duo](../../../../administration/gitlab_duo_self_hosted/_index.md) 上使用

{{< /collapsible >}}

{{< history >}}

- 在 极狐GitLab 16.1 中引入了对 Google Vertex AI Codey API 的支持。
- 在 极狐GitLab 16.2 中移除了对 极狐GitLab 原生模型的支持。
- 在 极狐GitLab 16.3 中引入了对代码生成的支持。
- 在 极狐GitLab 16.7 中 GA。
- 于 2024 年 2 月 15 日更改，要求使用 极狐GitLab Duo 专业版附加组件。此前，此功能包含在专业版和旗舰版订阅中。
- 自 2024 年 10 月 17 日起，对于所有受支持的 极狐GitLab 版本，要求使用 极狐GitLab Duo 专业版或 极狐GitLab Duo 企业版附加组件。
- 在 极狐GitLab 17.6 中引入了对 Fireworks AI 托管的 Qwen2.5 代码补全模型的支持，并带有一个名为 `fireworks_qwen_code_completion` 的功能标志。
- 在 极狐GitLab 17.11 中移除了对 Qwen2.5 代码补全模型的支持。
- 在 极狐GitLab 17.11 中，通过功能标志 `use_fireworks_codestral_code_completion` 默认启用了 Fireworks 托管的 `Codestral`。
- 在 极狐GitLab 18.0 中改为包含 极狐GitLab Duo Core。
- 在 极狐GitLab 18.1 中默认启用了 Fireworks 托管的 `Codestral` 作为默认模型。
- 在 极狐GitLab 18.2 中，将代码生成的默认模型更改为国内 SOTA 模型。
- 在 极狐GitLab 18.6 中移除了功能标志 `code_suggestions_context`。
- 在 极狐GitLab 18.10 中，JihuLab.com 上的基础版搭配 极狐GitLab 积分可以使用此功能。

{{< /history >}}

> [!note]
> 代码建议可用于：
>
> - 极狐GitLab Duo Agent Platform。计费是[基于用量的](../../../../subscriptions/gitlab_credits.md)。
> - 极狐GitLab Duo Core、专业版或企业版。计费基于您的附加组件。

使用 极狐GitLab Duo Code Suggestions 在您开发时通过生成式 AI 提供代码建议，从而更高效地编写代码。

- <i class="fa-youtube-play" aria-hidden="true"></i>
  [查看点击演示](https://gitlab.navattic.com/code-suggestions)
  <!-- 视频发布于 2023-12-09 --> <!-- 演示发布于 2024-02-01 -->

<a id="prerequisites"></a>

## 前提条件

要使用代码建议：

- 如果您有 极狐GitLab Duo Core，请[开启 IDE 功能](../../../gitlab_duo/turn_on_off.md#turn-gitlab-duo-core-on-or-off)。
- [设置代码建议](set_up.md)。

> [!note]
> 极狐GitLab Duo 要求 极狐GitLab 17.2 或更高版本。为了获得 极狐GitLab Duo Core 访问权限，并获取最佳用户体验和结果，
> [升级到 极狐GitLab 18.0 或更高版本](../../../../update/_index.md)。早期版本可能继续工作，但体验可能会降低。

<a id="use-code-suggestions"></a>

## 使用代码建议

要使用代码建议：

1. 在[支持的 IDE](supported_extensions.md#supported-editor-extensions) 中打开您的 Git 项目。
1. 使用 [`git remote add`](../../../../topics/git/commands.md#git-remote-add) 将项目作为本地仓库的远程添加。
1. 将您的项目目录（包括隐藏的 `.git/` 文件夹）添加到您的 IDE 工作区或项目中。
1. 编写您的代码。
   当您键入时，会显示建议。代码建议会根据光标位置提供代码片段或完成当前行。
1. 用自然语言描述需求。
   代码建议基于提供的上下文生成函数和代码片段。
1. 当您收到建议时，您可以执行以下任一操作：
   - 要接受建议，请按 <kbd>Tab</kbd>。
   - 要接受部分建议，请按 <kbd>Control</kbd>+<kbd>右箭头</kbd> 或 <kbd>Command</kbd>+<kbd>右箭头</kbd>。
   - 要拒绝建议，请按 <kbd>Esc</kbd>。在 Neovim 中，按 <kbd>Control</kbd>+<kbd>E</kbd> 退出菜单。
   - 要忽略建议，继续正常打字即可。

<a id="code-completion-and-generation"></a>

## 代码补全与代码生成

代码建议同时使用代码补全和代码生成：

|  | 代码补全 | 代码生成 |
| :---- | :---- | :---- |
| 目的 | 为完成当前代码行提供建议。 | 基于自然语言注释生成新代码。 |
| 触发方式 | 在键入时触发，通常有短暂延迟。 | 在编写包含特定关键字的注释后按 <kbd>Enter</kbd> 触发。 |
| 范围 | 限于当前行或小块代码。 | 可以生成整个方法、函数甚至类，具体取决于上下文。 |
| 准确性 | 对于小型任务和短代码块更准确。 | 对于复杂任务和大型代码块更准确，因为使用了更大的大语言模型 (LLM)，请求中发送了额外的上下文（例如项目使用的库），并且您的指令会传递给 LLM。 |
| 如何使用 | 代码补全自动为正在键入的行提供补全。 | 您编写注释并按 <kbd>Enter</kbd>，或输入一个空函数或方法。 |
| 何时使用 | 使用代码补全快速完成一行或几行代码。 | 对于更复杂的任务、更大的代码库、当您想根据自然语言描述从零编写新代码时，或者当您正在编辑的文件少于五行代码时，使用代码生成。 |

代码建议总是同时使用这两种功能。您不能仅使用代码生成或仅使用代码补全。

<a id="best-practices-for-code-generation"></a>

### 代码生成的最佳实践

为获得代码生成的最佳结果：

- 尽可能具体，同时保持简洁。
- 说明您想要生成的结果（例如，一个函数），并提供有关您想实现的细节。
- 添加额外信息，比如您想使用的框架或库。
- 每个注释后添加一个空格或新行。
  此空格告诉代码生成器您已完成指令。
- 审查并调整[可供代码建议使用的上下文](context.md)。

例如，要创建一个具有特定要求的 Python Web 服务，您可以编写类似以下内容：

```plaintext
# 使用 Tornado 创建一个 Web 服务，允许用户登录、运行安全扫描并查看扫描结果。
# 每个操作（登录、运行扫描和查看结果）都应该是 Web 服务中自己的资源。
...
```

AI 是非确定性的，因此即使输入相同，您可能每次都不会获得相同的建议。
要生成高质量代码，请编写清晰、描述性、具体的任务。

有关用例和最佳实践，请遵循[极狐GitLab Duo 示例文档](../../../gitlab_duo/use_cases.md)。

<a id="available-language-models"></a>

## 可用语言模型

不同的语言模型可以作为代码建议的来源。

- 在 JihuLab.com 上：极狐GitLab 托管模型并通过基于云的 AI 网关连接它们。
- 在 极狐GitLab 私有化部署 上，存在两种选项：
  - 极狐GitLab 可以[托管模型并通过基于云的 AI 网关连接它们](set_up.md)。
  - 您的组织可以使用[自部署模型](../../../../administration/gitlab_duo_self_hosted/_index.md)，这意味着您托管 AI 网关和语言模型。您可以使用 极狐GitLab 管理的模型、其他支持的语言模型，或自带兼容的模型。

<a id="performance"></a>

## 性能

了解代码建议的默认响应时间，以及流式传输、提示缓存和连接配置的选项。

<a id="response-time"></a>

### 响应时间

代码建议由生成式 AI 模型提供支持。

- 对于代码补全，建议通常具有低延迟，时间不超过一秒。
- 对于代码生成，算法或大型代码块可能需要超过五秒钟才能生成。

您的个人访问令牌可确保与 JihuLab.com 或您的 极狐GitLab 实例的安全 API 连接。
此 API 连接将上下文窗口从您的 IDE/编辑器安全地传输到 [极狐GitLab AI 网关](https://jihulab.com/gitlab-cn/modelops/applied-ml/code-suggestions/ai-assist)，这是一个 极狐GitLab 托管服务。网关调用大语言模型 API，然后将生成的建议传输回您的 IDE/编辑器。

<a id="prompt-caching"></a>

### 提示缓存

{{< history >}}

- 在 极狐GitLab 18.0 中引入。

{{< /history >}}

提示缓存默认在所有 Fireworks 托管的模型上启用，以改善代码建议的延迟。

启用提示缓存时，代码补全提示数据会临时存储在模型供应商的内存中。

提示缓存通过避免重复处理已缓存的提示和输入数据，显著改善了延迟。缓存的数据永远不会记录到任何持久性存储中。

<a id="turn-off-prompt-caching"></a>

#### 关闭提示缓存

您可以在 极狐GitLab Duo 设置中为顶级群组关闭提示缓存。
这也会关闭[极狐GitLab Duo Agentic Chat](../../../gitlab_duo_chat/agentic_chat.md#prompt-caching) 的提示缓存。

前提条件：

- 对于 极狐GitLab 私有化部署，需要管理员访问权限。

在 JihuLab.com 上：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **设置** > **极狐GitLab Duo**。
1. 选择 **更改配置**。
1. 禁用 **提示缓存** 切换开关。
1. 选择 **保存更改**。

在 极狐GitLab 私有化部署上：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **极狐GitLab Duo**。
1. 选择 **更改配置**。
1. 在 **提示缓存** 下，清除 **开启提示缓存** 复选框。
1. 选择 **保存更改**。

<a id="direct-and-indirect-connections"></a>

### 直接和间接连接

{{< history >}}

- 在 极狐GitLab 17.2 中引入，并带有一个名为 `code_suggestions_direct_access` 的功能标志，默认禁用。

{{< /history >}}

默认情况下，代码补全请求直接从 IDE 发送到 AI 网关，以最小化延迟。
要使此直接连接正常工作，IDE 必须能够连接到 `https://cloud.jihulab.com:443`。如果无法做到（例如由于网络限制），您可以为所有用户禁用直接连接。如果这样做，
代码补全请求将通过 极狐GitLab 私有化部署实例间接发送，该实例再将请求转发到 AI 网关。这可能会导致您的请求具有更高的延迟。

<a id="configure-direct-or-indirect-connections"></a>

#### 配置直接或间接连接

前提条件：

- 您必须是 极狐GitLab 私有化部署实例的管理员。

{{< tabs >}}

{{< tab title="在 17.4 及更高版本中" >}}

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **常规**。
1. 展开 **极狐GitLab Duo 功能**。
1. 在 **连接方式** 下，选择一个选项：
   - 要最小化代码补全请求的延迟，请选择 **直接连接**。
   - 要为所有用户禁用直接连接，请选择 **通过 极狐GitLab 私有化部署的间接连接**。
1. 选择 **保存更改**。

{{< /tab >}}

{{< tab title="在 17.3 及更早版本中" >}}

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **常规**。
1. 展开 **AI 原生功能**。
1. 选择一个选项：
   - 要启用直接连接并最小化代码补全请求的延迟，请清除 **禁用代码建议的直接连接** 复选框。
   - 要禁用直接连接，请选中 **禁用代码建议的直接连接** 复选框。

{{< /tab >}}

{{< /tabs >}}

<a id="limitations"></a>

## 限制

<a id="truncation-of-file-content"></a>

### 文件内容截断

由于 LLM 限制和性能原因，当前打开的文件内容会被截断：

- 对于代码补全：截断至 32,000 个 token（约 128,000 个字符）。
- 对于代码生成：截断至 80,000 个 token（约 320,000 个字符）。

光标上方的内容优先于光标下方的内容。光标上方的内容从左侧截断，光标下方的内容从右侧截断。这些数字代表代码建议的最大输入上下文大小。

关于增加代码生成限制的支持在[议题 585841](https://gitlab.com/gitlab-org/gitlab/-/issues/585841) 中提出。

<a id="output-length"></a>

### 输出长度

由于 LLM 限制和性能原因，代码建议的输出受到限制：

- 对于代码补全：限制为 64 个 token（约 256 个字符）。
- 对于代码生成：限制为 2048 个 token（约 7168 个字符）。

<a id="accuracy-of-results"></a>

### 结果准确性

我们持续致力于提高生成内容的整体准确性。
然而，代码建议可能会生成以下建议：

- 无关的。
- 不完整的。
- 可能导致流水线失败的。
- 存在潜在安全风险的。
- 冒犯性或不当的。

使用代码建议时，代码审查最佳实践仍然适用。

```