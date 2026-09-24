---
stage: AI-powered
group: Duo Chat
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 向极狐GitLab Duo Chat 提问
---

{{< details >}}

- Tier: 专业版，旗舰版
- Add-on: GitLab Duo Core、Pro 或 Enterprise
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< collapsible title="模型信息" >}}

- [默认 LLM](../gitlab_duo/model_selection.md#default-models)

{{< /collapsible >}}

{{< history >}}

- 在极狐GitLab 18.6 中将默认 LLM 更新为国内 SOTA 大模型。

{{< /history >}}

极狐GitLab Duo Chat 可以帮助你完成各种任务，包括：

- 获取代码、错误和极狐GitLab 功能的解释。
- 生成或重构代码、编写测试以及修复问题。
- 创建 CI/CD 配置并排查作业失败。
- 总结议题、史诗和合并请求。
- 解决安全漏洞。

本页面中的示例，包括[斜杠命令](#gitlab-duo-chat-slash-commands)，均为通用示例。
通过提出针对你当前目标的具体问题，你可能会从 Chat 获得更有用的回复。
例如，`data_cleaning.py 中的 clean_missing_data 函数是如何决定要删除哪些行的？`。

更多实际示例，请参见[极狐GitLab Duo 用例](../gitlab_duo/use_cases.md)。

## Chat 功能的积分使用

以下 Chat 功能有一个会消耗
[极狐GitLab 积分](../../subscriptions/gitlab_credits.md)的 Agentic 版本，以及一个不消耗极狐GitLab 积分的非 Agentic 版本：

- 解释选中的代码。
- 使用根因分析排查失败的 CI/CD 作业。
- 解释漏洞。
- 极狐GitLab UI 中的斜杠命令。

如果你同时拥有 Agentic Chat 和非 Agentic Chat 的访问权限，默认的功能版本取决于你使用的工具：

- 在极狐GitLab UI 中，默认的 Chat 版本是你在极狐GitLab Duo 侧边栏中最后选择的版本。
- 在支持的 IDE 中，默认的 Chat 版本由你的设置决定。

如果你没有 Agentic Chat 的访问权限，因此也没有极狐GitLab Duo Agent Platform，功能版本默认为非 Agentic 版本。

## 询问关于极狐GitLab 的问题

{{< collapsible title="编辑器信息" >}}

- 极狐GitLab Duo 非 Agentic Chat：极狐GitLab UI

{{< /collapsible >}}

{{< history >}}

- 在极狐GitLab 16.0 中为 JihuLab.com [引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/117695)。
- 在极狐GitLab 17.0 中为私有化部署[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/451215)了询问文档相关问题的功能，[带有功能标志](../../administration/feature_flags/_index.md)，名称为 `ai_gateway_docs_search`。默认启用。
- 在极狐GitLab 17.1 中[正式发布并移除功能标志](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/154876)。
- 在极狐GitLab 17.6 中更改为需要极狐GitLab Duo 附加组件。
- 在极狐GitLab 17.9 中为[自部署模型配置](../../administration/gitlab_duo_self_hosted/_index.md#self-hosted-ai-gateway-and-llms)以及[默认极狐GitLab 外部 AI 供应商配置](../../administration/gitlab_duo_self_hosted/_index.md#gitlabcom-ai-gateway-with-default-gitlab-external-vendor-llms)[启用](https://gitlab.com/groups/gitlab-org/-/epics/15227)。
- 在极狐GitLab 18.0 中更改为包含 GitLab Duo Core 附加组件。

{{< /history >}}

你可以询问关于极狐GitLab 如何工作的问题。例如：

- `简洁地解释 'fork' 的概念。`
- `提供重置用户密码的逐步说明。`

极狐GitLab Duo Chat 使用来自[极狐GitLab 仓库](https://gitlab.com/gitlab-org/gitlab/-/blob/master/doc)的极狐GitLab 文档作为来源。

为了使 Chat 与文档保持同步，其知识库每天更新。

- 在 JihuLab.com 上，使用最新版本的文档。
- 在私有化部署实例上，使用该实例版本的文档。

## 询问关于特定议题

{{< details >}}

- Add-on: GitLab Duo Enterprise

{{< /details >}}

{{< collapsible title="编辑器信息" >}}

- 极狐GitLab Duo 非 Agentic Chat：极狐GitLab UI

{{< /collapsible >}}

{{< history >}}

- 在极狐GitLab 16.0 中为 JihuLab.com [引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/122235)。
- 在极狐GitLab 16.8 中为私有化部署[引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/122235)。
- 在极狐GitLab 17.6 中更改为需要极狐GitLab Duo 附加组件。
- 在极狐GitLab 17.9 中为[自部署模型配置](../../administration/gitlab_duo_self_hosted/_index.md#self-hosted-ai-gateway-and-llms)以及[默认极狐GitLab 外部 AI 供应商配置](../../administration/gitlab_duo_self_hosted/_index.md#gitlabcom-ai-gateway-with-default-gitlab-external-vendor-llms)[启用](https://gitlab.com/groups/gitlab-org/-/epics/15227)。
- 在极狐GitLab 18.0 中更改为包含专业版。

{{< /history >}}

你可以询问关于特定极狐GitLab 议题的问题。例如：

- `生成此链接所标识议题的摘要：<指向你的议题的链接>`
- 当你在极狐GitLab 中查看某个议题时，你可以问 `生成当前议题的简洁摘要。`
- `我该如何改进 <指向你的议题的链接> 的描述，以便读者理解其价值和要解决的问题？`

> [!note]
> 如果议题包含大量文本（超过 40,000 字），极狐GitLab Duo Chat 可能无法考虑每一个词。AI 模型一次可以处理的输入量有限。

## 询问关于特定史诗

{{< details >}}

- Add-on: GitLab Duo Enterprise

{{< /details >}}

{{< collapsible title="编辑器信息" >}}

- 极狐GitLab Duo 非 Agentic Chat：极狐GitLab UI

{{< /collapsible >}}

{{< history >}}

- 在极狐GitLab 16.3 中为 JihuLab.com [引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/128487)。
- 在极狐GitLab 16.8 中为私有化部署[引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/128487)。
- 在极狐GitLab 17.6 中更改为需要极狐GitLab Duo 附加组件。
- 在极狐GitLab 17.9 中为[自部署模型配置](../../administration/gitlab_duo_self_hosted/_index.md#self-hosted-ai-gateway-and-llms)以及[默认极狐GitLab 外部 AI 供应商配置](../../administration/gitlab_duo_self_hosted/_index.md#gitlabcom-ai-gateway-with-default-gitlab-external-vendor-llms)[启用](https://gitlab.com/groups/gitlab-org/-/epics/15227)。
- 在极狐GitLab 18.0 中更改为包含专业版。

{{< /history >}}

你可以询问关于特定极狐GitLab 史诗的问题。例如：

- `生成此链接所标识史诗的摘要：<指向你的史诗的链接>`
- 当你在极狐GitLab 中查看某个史诗时，你可以问 `生成当前打开史诗的简洁摘要。`
- `评论者在 <指向你的史诗的链接> 中提出了哪些独特的用例？`

> [!note]
> 如果史诗包含大量文本（超过 40,000 字），极狐GitLab Duo Chat 可能无法考虑每一个词。AI 模型一次可以处理的输入量有限。

## 询问关于特定合并请求

{{< details >}}

- Add-on: GitLab Duo Core、Pro 或 Enterprise

{{< /details >}}

{{< collapsible title="编辑器信息" >}}

- 编辑器：极狐GitLab UI

{{< /collapsible >}}

{{< history >}}

- 在极狐GitLab 17.5 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/464587)。
- 在极狐GitLab 17.6 中更改为需要极狐GitLab Duo 附加组件。
- 在极狐GitLab 18.0 中更改为包含专业版。

{{< /history >}}

你可以询问极狐GitLab 关于你正在查看的合并请求。你可以询问：

- 标题或描述。
- 评论和讨论串。
- **变更** 选项卡上的内容。
- 元数据，如标签、源分支、作者、里程碑等。

在合并请求中，打开 Chat 并输入你的问题。例如：

- `为什么 .vue 文件被更改了？`
- `审查者对这个合并请求有什么看法？`
- `如何改进这个合并请求？`
- `我应该首先审查哪些文件和更改？`

## 询问关于特定提交

{{< details >}}

- Add-on: GitLab Duo Enterprise

{{< /details >}}

{{< collapsible title="编辑器信息" >}}

- 编辑器：极狐GitLab UI

{{< /collapsible >}}

{{< history >}}

- 在极狐GitLab 17.6 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/468460)。
- 在极狐GitLab 18.0 中更改为包含专业版。

{{< /history >}}

你可以询问关于特定极狐GitLab 提交的问题。例如：

- `生成此链接所标识提交的摘要：<指向你的提交的链接>`
- `我该如何改进这个提交的描述？`
- 当你在极狐GitLab 中查看某个提交时，你可以问 `生成当前提交的摘要。`

## 询问关于特定流水线作业

{{< details >}}

- Add-on: GitLab Duo Enterprise

{{< /details >}}

{{< collapsible title="编辑器信息" >}}

- 编辑器：极狐GitLab UI

{{< /collapsible >}}

{{< history >}}

- 在极狐GitLab 17.6 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/468461)。
- 在极狐GitLab 18.0 中更改为包含专业版。

{{< /history >}}

你可以询问关于特定极狐GitLab 流水线作业的问题。例如：

- `生成此链接所标识流水线作业的摘要：<指向你的流水线作业的链接>`
- `你能建议修复这个失败的流水线作业的方法吗？`
- `这个流水线作业中执行的主要步骤是什么？`
- 当你在极狐GitLab 中查看某个流水线作业时，你可以问 `生成当前流水线作业的摘要。`

## 询问关于特定工作项

{{< details >}}

- Add-on: GitLab Duo Enterprise

{{< /details >}}

{{< collapsible title="编辑器信息" >}}

- 极狐GitLab Duo 非 Agentic Chat：极狐GitLab UI

{{< /collapsible >}}

{{< history >}}

- 在极狐GitLab 18.2 中[引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/194302)。

{{< /history >}}

你可以询问关于特定极狐GitLab 工作项的问题。例如：

- `生成此链接所标识工作项的摘要：<指向你的工作项的链接>`
- 当你在极狐GitLab 中查看某个工作项时，你可以问 `生成当前工作项的简洁摘要。`
- `我该如何改进 <指向你的工作项的链接> 的描述，以便读者理解其价值和要解决的问题？`

> [!note]
> 如果工作项包含大量文本（超过 40,000 字），极狐GitLab Duo Chat 可能无法考虑每一个词。AI 模型一次可以处理的输入量有限。

## 解释选中的代码

{{< details >}}

- Add-on: GitLab Duo Core、Pro 或 Enterprise

{{< /details >}}

{{< collapsible title="编辑器和模型信息" >}}

- 编辑器 - 极狐GitLab Duo 非 Agentic Chat：极狐GitLab UI
- 可访问 [自部署模型的 极狐GitLab Duo](../../administration/gitlab_duo_self_hosted/_index.md)

{{< /collapsible >}}

{{< history >}}

- 在极狐GitLab 16.7 中为 JihuLab.com [引入](https://gitlab.com/gitlab-org/gitlab/-/issues/429915)。
- 在极狐GitLab 16.8 中为私有化部署[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/429915)。
- 在极狐GitLab 17.6 中更改为需要极狐GitLab Duo 附加组件。
- 在极狐GitLab 17.9 中为[自部署模型配置](../../administration/gitlab_duo_self_hosted/_index.md#self-hosted-ai-gateway-and-llms)以及[默认极狐GitLab 外部 AI 供应商配置](../../administration/gitlab_duo_self_hosted/_index.md#gitlabcom-ai-gateway-with-default-gitlab-external-vendor-llms)[启用](https://gitlab.com/groups/gitlab-org/-/epics/15227)。
- 在极狐GitLab 18.0 中更改为包含 GitLab Duo Core 附加组件。

{{< /history >}}

你可以让极狐GitLab Duo Chat 解释选中的代码：

1. 在你的 IDE 中选择一些代码。
1. 在极狐GitLab Duo Chat 中，输入 `/explain`。

   ![选择代码并使用 /explain 斜杠命令让极狐GitLab Duo Chat 解释](img/code_selection_duo_chat_v17_4.png)

你还可以添加额外的说明以供考虑。例如：

- `/explain 性能`
- `/explain 重点关注算法`
- `/explain 使用此代码的性能增益或损失`
- `/explain 对象继承`（类，面向对象）
- `/explain 这里为什么使用静态变量`（C++）
- `/explain 这个函数如何导致分段错误`（C）
- `/explain 在此上下文中并发是如何工作的`（Go）
- `/explain 请求如何到达客户端`（REST API，数据库）

更多信息，请参见：

- [在 VS Code 中使用极狐GitLab Duo Chat](_index.md#use-gitlab-duo-chat-in-vs-code)。

在极狐GitLab UI 中，你还可以解释以下内容中的代码：

- [文件](../project/repository/code_explain.md)。
- [合并请求](../project/merge_requests/changes.md#explain-code-in-a-merge-request)。

## 询问或生成代码

{{< details >}}

- Add-on: GitLab Duo Core、Pro 或 Enterprise

{{< /details >}}

{{< collapsible title="编辑器信息" >}}

- 极狐GitLab Duo 非 Agentic Chat：极狐GitLab UI

{{< /collapsible >}}

{{< history >}}

- 在极狐GitLab 16.1 中为 JihuLab.com [引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/122235)。
- 在极狐GitLab 16.8 中为私有化部署[引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/122235)。
- 在极狐GitLab 17.6 中更改为需要极狐GitLab Duo 附加组件。
- 在极狐GitLab 17.9 中为[自部署模型配置](../../administration/gitlab_duo_self_hosted/_index.md#self-hosted-ai-gateway-and-llms)以及[默认极狐GitLab 外部 AI 供应商配置](../../administration/gitlab_duo_self_hosted/_index.md#gitlabcom-ai-gateway-with-default-gitlab-external-vendor-llms)[启用](https://gitlab.com/groups/gitlab-org/-/epics/15227)。
- 在极狐GitLab 18.0 中更改为包含 GitLab Duo Core 附加组件。

{{< /history >}}

你可以通过将代码粘贴到 Chat 窗口中来询问极狐GitLab Duo Chat 有关代码的问题。例如：

```plaintext
请清晰解释这段 Ruby 代码：def sum (a, b) a + b end。
描述这段代码的功能及其工作原理。
```

你还可以要求 Chat 生成代码。例如：

- `编写一个 Ruby 函数，在调用时打印 'Hello, World!'。`
- `开发一个模拟双人井字棋游戏的 JavaScript 程序。如果适用，同时提供游戏逻辑和用户界面。`
- `在 Python 中创建一个用于解析 IPv4 和 IPv6 地址的正则表达式。`
- `生成用于在 Java 中解析 syslog 日志文件的代码。尽可能使用正则表达式，并将结果存储在哈希映射中。`
- `在 C++ 中创建一个带有线程和共享内存的生产者-消费者示例。尽可能使用原子锁。`
- `生成用于高性能 gRPC 调用的 Rust 代码。提供服务器和客户端的源代码示例。`

## 提出后续问题

{{< details >}}

- Add-on: GitLab Duo Core、Pro 或 Enterprise

{{< /details >}}

{{< collapsible title="编辑器信息" >}}

- 极狐GitLab Duo 非 Agentic Chat：极狐GitLab UI

{{< /collapsible >}}

{{< history >}}

- 在极狐GitLab 17.9 中为[自部署模型配置](../../administration/gitlab_duo_self_hosted/_index.md#self-hosted-ai-gateway-and-llms)以及[默认极狐GitLab 外部 AI 供应商配置](../../administration/gitlab_duo_self_hosted/_index.md#gitlabcom-ai-gateway-with-default-gitlab-external-vendor-llms)[启用](https://gitlab.com/groups/gitlab-org/-/epics/15227)。
- 在极狐GitLab 18.0 中更改为包含 GitLab Duo Core 附加组件。

{{< /history >}}

你可以提出后续问题，以更深入地探讨手头的主题或任务。
这有助于你获得更详细和精准的回复，以满足你的特定需求，
无论是为了进一步澄清、详细说明还是获得额外帮助。

对于问题 `编写一个 Ruby 函数，在调用时打印 'Hello, World!'` 的后续问题可以是：

- `你能否也解释一下如何在典型的 Ruby 环境（如命令行）中调用和执行这个 Ruby 函数？`

对于问题 `如何启动一个 C# 项目？` 的后续问题可以是：

- `你能否也解释一下如何为 C# 添加 .gitignore 和 .gitlab-ci.yml 文件？`

## 询问错误

{{< details >}}

- Add-on: GitLab Duo Core、Pro 或 Enterprise

{{< /details >}}

{{< collapsible title="编辑器信息" >}}

- 极狐GitLab Duo 非 Agentic Chat：极狐GitLab UI、Web IDE、VS Code、JetBrains IDEs、Visual Studio 和 Eclipse

{{< /collapsible >}}

{{< history >}}

- 在极狐GitLab 17.9 中为[自部署模型配置](../../administration/gitlab_duo_self_hosted/_index.md#self-hosted-ai-gateway-and-llms)以及[默认极狐GitLab 外部 AI 供应商配置](../../administration/gitlab_duo_self_hosted/_index.md#gitlabcom-ai-gateway-with-default-gitlab-external-vendor-llms)[启用](https://gitlab.com/groups/gitlab-org/-/epics/15227)。
- 在极狐GitLab 18.0 中更改为包含 GitLab Duo Core 附加组件。

{{< /history >}}

需要编译源代码的编程语言可能会抛出难以理解的错误消息。同样，脚本或 Web 应用程序可能会抛出堆栈跟踪。你可以通过将复制的错误消息加上前缀来询问极狐GitLab Duo Chat，例如 `解释这个错误消息：`。添加具体的上下文，如编程语言。

- `解释这个 Java 错误消息：Int and system cannot be resolved to a type`
- `解释这个 C 函数何时会导致分段错误：sqlite3_prepare_v2()`
- `解释在 Python 中什么会导致这个错误：ValueError: invalid literal for int()`
- `为什么在 VueJS 中 "this" 是未定义的？提供常见的错误案例，并解释如何避免它们。`
- `如何调试 Ruby on Rails 的堆栈跟踪？分享常见策略和一个异常示例。`

## 在 IDE 中询问特定文件

{{< details >}}

- Add-on: GitLab Duo Core、Pro 或 Enterprise

{{< /details >}}

{{< collapsible title="编辑器信息" >}}

- 极狐GitLab Duo 非 Agentic Chat：VS Code、JetBrains IDEs、Visual Studio 和 Eclipse

{{< /collapsible >}}

{{< history >}}

- 在极狐GitLab 17.7 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/477258)，[带有功能标志](../../administration/feature_flags/_index.md)，名称为 `duo_additional_context` 和 `duo_include_context_file`。默认禁用。
- 在极狐GitLab 17.9 中为[自部署模型配置](../../administration/gitlab_duo_self_hosted/_index.md#self-hosted-ai-gateway-and-llms)以及[默认极狐GitLab 外部 AI 供应商配置](../../administration/gitlab_duo_self_hosted/_index.md#gitlabcom-ai-gateway-with-default-gitlab-external-vendor-llms)[启用](https://gitlab.com/groups/gitlab-org/-/epics/15227)。
- 在极狐GitLab 17.9 中[在 JihuLab.com 和私有化部署上启用](https://gitlab.com/groups/gitlab-org/-/epics/15183)。
- 在极狐GitLab 18.0 中[正式发布](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/188613)。所有功能标志已移除。
- 在极狐GitLab 18.0 中更改为包含 GitLab Duo Core 附加组件。

{{< /history >}}

在你支持的 IDE 中，通过输入 `/include` 并选择文件，将仓库文件添加到你的极狐GitLab Duo Chat 对话中。

先决条件：

- 文件必须是仓库的一部分。
- 文件必须是基于文本的。不支持二进制文件，如 PDF 或图像。

操作步骤：

1. 在你的 IDE 中，在极狐GitLab Duo Chat 中输入 `/include`。
1. 要添加文件，你可以：
   - 从列表中选择文件。
   - 输入文件路径。

例如，如果你正在开发一个电子商务应用，你可以将 `cart_service.py` 和 `checkout_flow.js` 文件添加到 Chat 的上下文中，并询问：

- `checkout_flow.js 如何与 cart_service.py 交互？使用 Mermaid 生成一个序列图。`
- `你能通过展示与用户购物车中商品相关的产品来扩展结账流程吗？我想在继续之前将结账逻辑移至后端。生成 Python 后端代码，并更改前端代码以与新的后端配合使用。`

> [!note]
> 你不能使用 [Quick Chat](_index.md#in-an-editor-window) 来添加文件或询问有关为 Chat 上下文添加的文件的问题。

## 在 IDE 中重构代码

{{< details >}}

- Add-on: GitLab Duo Core、Pro 或 Enterprise

{{< /details >}}

{{< collapsible title="编辑器和模型信息" >}}

- 编辑器 - 极狐GitLab Duo 非 Agentic Chat：Web IDE、VS Code、JetBrains IDEs、Visual Studio 和 Eclipse
- 可访问 [自部署模型的 极狐GitLab Duo](../../administration/gitlab_duo_self_hosted/_index.md)

{{< /collapsible >}}

{{< history >}}

- 在极狐GitLab 16.7 中为 JihuLab.com [引入](https://gitlab.com/gitlab-org/gitlab/-/issues/429915)。
- 在极狐GitLab 16.8 中为私有化部署[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/429915)。
- 在极狐GitLab 17.6 中更改为需要极狐GitLab Duo 附加组件。
- 在极狐GitLab 17.9 中为[自部署模型配置](../../administration/gitlab_duo_self_hosted/_index.md#self-hosted-ai-gateway-and-llms)以及[默认极狐GitLab 外部 AI 供应商配置](../../administration/gitlab_duo_self_hosted/_index.md#gitlabcom-ai-gateway-with-default-gitlab-external-vendor-llms)[启用](https://gitlab.com/groups/gitlab-org/-/epics/15227)。
- 在极狐GitLab 18.0 中更改为包含 GitLab Duo Core 附加组件。

{{< /history >}}

你可以让极狐GitLab Duo Chat 重构选中的代码：

1. 在你的 IDE 中选择一些代码。
1. 在极狐GitLab Duo Chat 中，输入 `/refactor`。

你可以包含额外的说明以供考虑。例如：

- 使用特定的编码模式，例如 `/refactor 使用 ActiveRecord` 或 `/refactor 转换为提供静态函数的类`。
- 使用特定的库，例如 `/refactor 使用 mysql`。
- 使用特定的函数/算法，例如在 C++ 中 `/refactor 转换为多行 stringstream`。
- 重构为不同的编程语言，例如 `/refactor 转换为 TypeScript`。
- 关注性能，例如 `/refactor 提升性能`。
- 关注潜在漏洞，例如 `/refactor 避免内存泄漏和漏洞利用`。

`/refactor` 使用 [Repository X-Ray](../project/repository/code_suggestions/repository_xray.md) 来提供更准确、上下文感知的建议。

## 在 IDE 中修复代码

{{< details >}}

- Add-on: GitLab Duo Core、Pro 或 Enterprise

{{< /details >}}

{{< collapsible title="编辑器和模型信息" >}}

- 编辑器 - 极狐GitLab Duo 非 Agentic Chat：Web IDE、VS Code、JetBrains IDEs、Visual Studio 和 Eclipse
- 可访问 [自部署模型的 极狐GitLab Duo](../../administration/gitlab_duo_self_hosted/_index.md)

{{< /collapsible >}}

{{< history >}}

- 在极狐GitLab 17.3 中为 JihuLab.com 和私有化部署[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/429915)。
- 在极狐GitLab 17.6 中更改为需要极狐GitLab Duo 附加组件。
- 在极狐GitLab 17.9 中为[自部署模型配置](../../administration/gitlab_duo_self_hosted/_index.md#self-hosted-ai-gateway-and-llms)以及[默认极狐GitLab 外部 AI 供应商配置](../../administration/gitlab_duo_self_hosted/_index.md#gitlabcom-ai-gateway-with-default-gitlab-external-vendor-llms)[启用](https://gitlab.com/groups/gitlab-org/-/epics/15227)。
- 在极狐GitLab 18.0 中更改为包含 GitLab Duo Core 附加组件。

{{< /history >}}

你可以让极狐GitLab Duo Chat 修复选中的代码：

1. 在你的 IDE 中选择一些代码。
1. 在极狐GitLab Duo Chat 中，输入 `/fix`。

你可以包含额外的说明以供考虑。例如：
- 关注语法和拼写错误，例如 `/fix 语法错误和拼写错误`。
- 关注具体的算法或问题描述，例如 `/fix 重复数据库插入` 或 `/fix 竞态条件`。
- 关注不直接可见的潜在错误，例如 `/fix 潜在错误`。
- 关注代码性能问题，例如 `/fix 性能问题`。
- 关注当代码编译失败时修复构建，例如 `/fix 构建失败`。

`/fix` 使用 [代码仓 X-Ray](../project/repository/code_suggestions/repository_xray.md) 提供更准确、上下文感知的建议。

<a id="ask-about-cicd"></a>

## 询问 CI/CD

{{< details >}}

- 附加项：极狐GitLab Duo 专业版或旗舰版

{{< /details >}}

{{< collapsible title="编辑器信息" >}}

- 极狐GitLab Duo 非 Agentic Chat：GitLab UI、Web IDE、VS Code、JetBrains IDEs、Visual Studio 和 Eclipse

{{< /collapsible >}}

{{< history >}}

- 引入于 JihuLab.com 在极狐GitLab 16.7。
- 在极狐GitLab 16.8 中为私有化部署引入。
- 在极狐GitLab 17.2 中将 LLM 更新为国内 SOTA 大模型。
- 在极狐GitLab 17.2 中将 LLM 再次更新为国内 SOTA 大模型。
- 在极狐GitLab 17.6 中，改为需要极狐GitLab Duo 附加项。
- 在极狐GitLab 17.9 中，为[自部署模型配置](../../administration/gitlab_duo_self_hosted/_index.md#self-hosted-ai-gateway-and-llms)和[默认极狐GitLab 外部 AI 供应商配置](../../administration/gitlab_duo_self_hosted/_index.md#gitlabcom-ai-gateway-with-default-gitlab-external-vendor-llms)启用。
- 在极狐GitLab 17.10 中将 LLM 更新为国内 SOTA 大模型。

{{< /history >}}

你可以向 极狐GitLab Duo Chat 询问创建 CI/CD 配置：

- `创建一个用于在 GitLab CI/CD 流水线中测试和构建 Ruby on Rails 应用的 .gitlab-ci.yml 配置文件。`
- `创建一个用于构建和 linting Python 应用的 CI/CD 配置。`
- `创建一个用于构建和测试 Rust 代码的 CI/CD 配置。`
- `创建一个用于 C++ 的 CI/CD 配置。使用 gcc 作为编译器，cmake 作为构建工具。`
- `创建一个用于 VueJS 的 CI/CD 配置。使用 npm，并添加 SAST 安全扫描。`
- `生成一个安全扫描流水线配置，为 Java 进行优化。`

你还可以通过复制粘贴错误信息并加上前缀 `在 <language> 上下文中解释此 CI/CD 作业错误信息：` 来要求解释特定的作业错误：

- `在 Go 项目上下文中解释此 CI/CD 作业错误信息：build.sh: line 14: go command not found`

或者，你可以使用 极狐GitLab Duo 根因分析来[排查失败的 CI/CD 作业](#troubleshoot-failed-cicd-jobs-with-root-cause-analysis)。

<a id="troubleshoot-failed-cicd-jobs-with-root-cause-analysis"></a>

## 使用根因分析排查失败的 CI/CD 作业

{{< details >}}

- 附加项：极狐GitLab Duo 旗舰版

{{< /details >}}

{{< collapsible title="编辑器与模型信息" >}}

- 编辑器：极狐GitLab UI
- 默认 LLM：国内 SOTA 大模型
- 适用于 [自部署模型的 极狐GitLab Duo](../../administration/gitlab_duo_self_hosted/_index.md)

{{< /collapsible >}}

{{< history >}}

- 作为 JihuLab.com 上的一个[实验](../../policy/development_stages_support.md#experiment)在极狐GitLab 16.2 中引入。
- 在极狐GitLab 17.3 中正式发布（GA）并移至 极狐GitLab Duo Chat。
- 在极狐GitLab 17.6 中，改为需要极狐GitLab Duo 附加项。
- 在极狐GitLab 17.7 中为合并请求引入了失败作业小部件。
- 在极狐GitLab 18.0 中，改为包含专业版。

{{< /history >}}

你可以在 极狐GitLab Duo Chat 中使用 极狐GitLab Duo 根因分析，快速识别和修复 CI/CD 作业失败。它分析作业日志的最后 100,000 个字符以确定失败原因，并提供示例修复。

你可以从合并请求中的 **流水线** 选项卡或直接从作业日志访问此功能。

根因分析不支持：

- 触发作业
- 下游流水线

前提条件：

- 你必须拥有查看 CI/CD 作业的权限。

<a id="from-a-merge-request"></a>

### 从合并请求

要从合并请求排查失败的 CI/CD 作业：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 转到你的合并请求。
1. 选择 **流水线** 选项卡。
1. 从失败作业小部件中，可以：
   - 选择作业 ID 转到作业日志。
   - 选择 **排查** 直接分析失败原因。

<a id="from-the-job-log"></a>

### 从作业日志

要从作业日志排查失败的 CI/CD 作业：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **构建** > **作业**。
1. 选择失败的 CI/CD 作业。
1. 在作业日志下方，可以：
   - 选择 **排查**。
   - 打开 极狐GitLab Duo Chat 并输入 `/troubleshoot`。

<a id="explain-a-vulnerability"></a>

## 解释漏洞

{{< details >}}

- 等级：旗舰版
- 附加项：极狐GitLab Duo 旗舰版

{{< /details >}}

{{< collapsible title="编辑器与模型信息" >}}

- 编辑器：极狐GitLab UI
- 默认 LLM：国内 SOTA 大模型
- 适用于 [自部署模型的 极狐GitLab Duo](../../administration/gitlab_duo_self_hosted/_index.md)

{{< /collapsible >}}

{{< history >}}

- 在极狐GitLab 17.6 中，改为需要极狐GitLab Duo 附加项。

{{< /history >}}

你可以在查看 SAST 漏洞报告时，要求 极狐GitLab Duo Chat 解释漏洞。

更多信息，请参阅[解释漏洞](../application_security/analyze/duo.md)。

<a id="gitlab-duo-chat-slash-commands"></a>

## 极狐GitLab Duo Chat 斜杠命令

极狐GitLab Duo Chat 提供了一系列通用、极狐GitLab UI 和 IDE 命令，每个命令前都有一个斜杠（`/`）。使用这些命令可以快速完成特定任务。

<a id="universal"></a>

### 通用

{{< details >}}

- 附加项：极狐GitLab Duo 基础版、专业版或旗舰版

{{< /details >}}

{{< collapsible title="编辑器信息" >}}

- 极狐GitLab Duo 非 Agentic Chat：GitLab UI、Web IDE、VS Code、JetBrains IDEs、Visual Studio 和 Eclipse

{{< /collapsible >}}

{{< history >}}

- 在极狐GitLab 17.9 中，为[自部署模型配置](../../administration/gitlab_duo_self_hosted/_index.md#self-hosted-ai-gateway-and-llms)和[默认极狐GitLab 外部 AI 供应商配置](../../administration/gitlab_duo_self_hosted/_index.md#gitlabcom-ai-gateway-with-default-gitlab-external-vendor-llms)启用。
- 在极狐GitLab 18.0 中，改为包含极狐GitLab Duo 基础版附加项。

{{< /history >}}

| 命令    | 目的                                                       |
|---------|------------------------------------------------------------|
| /new    | 开始新对话，但保留之前的对话在聊天历史中                      |
| /reset  | 清除聊天窗口并重置对话                                       |
| /help   | 了解更多关于 极狐GitLab Duo Chat 如何工作的信息                |

> [!note]
> 在 JihuLab.com 上，对于极狐GitLab 17.10 及更高版本，当进行[多个对话](_index.md#have-multiple-conversations)时，`/clear` 和 `/reset` 斜杠命令被替换为 [`/new` 斜杠命令](#gitlab-ui)。

<a id="gitlab-ui"></a>

### 极狐GitLab UI

{{< details >}}

- 附加项：极狐GitLab Duo 旗舰版
- 编辑器：极狐GitLab UI

{{< /details >}}

{{< history >}}

- 在极狐GitLab 18.0 中，改为包含专业版。

{{< /history >}}

| 命令                     | 目的                                                                                                             | 区域 |
| ------------------------ | ---------------------------------------------------------------------------------------------------------------- | ---- |
| /summarize_comments      | 生成当前议题上所有评论的摘要                                                                                        | 议题 |
| /troubleshoot            | [使用根因分析排查失败的 CI/CD 作业](#troubleshoot-failed-cicd-jobs-with-root-cause-analysis)                        | 作业 |
| /vulnerability_explain   | [解释当前漏洞](../application_security/analyze/duo.md)                                                              | 漏洞 |