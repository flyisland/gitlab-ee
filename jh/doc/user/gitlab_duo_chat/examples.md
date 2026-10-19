---
stage: AI Clients
group: Duo Chat
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 向极狐GitLab Duo Chat 提问
---

{{< details >}}

- Tier: 专业版，旗舰版
- Add-on: 极狐GitLab Duo Pro 或 Enterprise
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< collapsible title="模型信息" >}}

- [默认 LLM](../gitlab_duo/model_selection.md#default-models)

{{< /collapsible >}}

极狐GitLab Duo Chat 可以帮助您完成各种任务，包括：

- 获取代码、错误和极狐GitLab 功能的解释。
- 生成或重构代码、编写测试并修复问题。
- 创建 CI/CD 配置并排查作业失败。
- 汇总议题、史诗和合并请求。
- 解决安全漏洞。

本页中的示例（包括[斜杠命令](#gitlab-duo-chat-slash-commands)）有意保持通用。如果您提出与当前目标具体相关的问题，可能会从 Chat 获得更有用的回答。例如，`How does the clean_missing_data function in data_cleaning.py decide which rows to drop?`。

更多实用示例，请参见 [极狐GitLab Duo 用例](../gitlab_duo/use_cases.md)。

<a id="use-of-credits-with-chat-features"></a>

## Chat 功能对极狐GitLab Credits 的使用

以下 Chat 功能有一个会消耗
[极狐GitLab Credits](../../subscriptions/gitlab_credits.md)的 Agentic 版本，以及一个不消耗
极狐GitLab Credits 的非 Agentic 版本：

- 解释所选代码。
- 使用根因分析排查失败的 CI/CD 作业。
- 解释漏洞。
- 极狐GitLab UI 中的斜杠命令。

如果您同时可以使用 Agentic Chat 和 Non-Agentic Chat，默认的功能版本取决于您使用的工具：

- 在极狐GitLab UI 中，默认的 Chat 版本是您在极狐GitLab Duo 侧边栏中最后选择的版本。
- 在受支持的 IDE 中，默认的 Chat 版本由您的设置决定。

如果您无法使用 Agentic Chat，因而也无法使用极狐GitLab Duo Agent Platform，则功能版本默认为非 Agentic 版本。

<a id="ask-about-gitlab"></a>

## 询问极狐GitLab 相关问题

{{< collapsible title="编辑器信息" >}}

- GitLab Duo Non-Agentic Chat：极狐GitLab UI、Web IDE、VS Code、JetBrains IDE、Visual Studio 和 Eclipse

{{< /collapsible >}}

您可以询问极狐GitLab 的工作方式相关问题。例如：

- `Explain the concept of a 'fork' in a concise manner.`
- `Provide step-by-step instructions on how to reset a user's password.`

极狐GitLab Duo Chat 使用 [GitLab 仓库](https://gitlab.com/gitlab-org/gitlab/-/tree/master/doc)中的极狐GitLab 文档作为来源。

为了让 Chat 与文档保持同步，其知识库每天都会更新。

- 在 JihuLab.com 上，使用最新版本的文档。
- 在极狐GitLab 私有化部署上，使用该实例版本的文档。

<a id="ask-about-a-specific-issue"></a>

## 询问特定议题

{{< details >}}

- Add-on: 极狐GitLab Duo Enterprise

{{< /details >}}

{{< collapsible title="编辑器信息" >}}

- GitLab Duo Non-Agentic Chat：极狐GitLab UI、Web IDE、VS Code、JetBrains IDE、Visual Studio 和 Eclipse

{{< /collapsible >}}

您可以询问特定的极狐GitLab 议题。例如：

- `Generate a summary for the issue identified via this link: <link to your issue>`
- 当您在极狐GitLab 中查看某个议题时，可以询问 `Generate a concise summary of the current issue.`
- `How can I improve the description of <link to your issue> so that readers understand the value and problems to be solved?`

> [!note]
> 如果议题包含大量文本（超过 40,000 个单词），极狐GitLab Duo Chat 可能无法考虑每一个单词。AI 模型一次可处理的输入量是有限的。


<a id="ask-about-a-specific-epic"></a>

## 询问特定史诗

{{< details >}}

- Add-on: 极狐GitLab Duo Enterprise

{{< /details >}}

{{< collapsible title="编辑器信息" >}}

- GitLab Duo Non-Agentic Chat：极狐GitLab UI、Web IDE、VS Code、JetBrains IDE、Visual Studio 和 Eclipse

{{< /collapsible >}}

您可以询问特定的极狐GitLab 史诗。例如：

- `Generate a summary for the epic identified via this link: <link to your epic>`
- 当您在极狐GitLab 中查看某个史诗时，可以询问 `Generate a concise summary of the opened epic.`
- `What are the unique use cases raised by commenters in <link to your epic>?`

> [!note]
> 如果史诗包含大量文本（超过 40,000 个单词），极狐GitLab Duo Chat 可能无法考虑每一个单词。AI 模型一次可处理的输入量是有限的。

<a id="ask-about-a-specific-merge-request"></a>

## 询问特定合并请求

{{< details >}}

- Add-on: 极狐GitLab Duo Core、Pro 或 Enterprise

{{< /details >}}

{{< collapsible title="编辑器信息" >}}

- Editors: 极狐GitLab UI

{{< /collapsible >}}

您可以就正在查看的合并请求向极狐GitLab 提问。您可以询问：

- 标题或描述。
- 评论和讨论串。
- **变更**标签页上的内容。
- 元数据，例如标记、源分支、作者、里程碑等。

在合并请求中，打开 Chat 并输入您的问题。例如：

- `Why was the .vue file changed?`
- `What do the reviewers say about this merge request?`
- `How can this merge request be improved?`
- `Which files and changes should I review first?`

<a id="ask-about-a-specific-commit"></a>

## 询问特定提交

{{< details >}}

- Add-on: 极狐GitLab Duo Enterprise

{{< /details >}}

{{< collapsible title="编辑器信息" >}}

- Editors: 极狐GitLab UI

{{< /collapsible >}}

您可以询问特定的极狐GitLab 提交。例如：

- `Generate a summary for the commit identified with this link: <link to your commit>`
- `How can I improve the description of this commit?`
- 当您在极狐GitLab 中查看某个提交时，可以询问 `Generate a summary of the current commit.`

<a id="ask-about-a-specific-pipeline-job"></a>

## 询问特定流水线作业

{{< details >}}

- Add-on: 极狐GitLab Duo Enterprise

{{< /details >}}

{{< collapsible title="编辑器信息" >}}

- Editors: 极狐GitLab UI

{{< /collapsible >}}

您可以询问特定的极狐GitLab 流水线作业。例如：

- `Generate a summary for the pipeline job identified via this link: <link to your pipeline job>`
- `Can you suggest ways to fix this failed pipeline job?`
- `What are the main steps executed in this pipeline job?`
- 当您在极狐GitLab 中查看某个流水线作业时，可以询问 `Generate a summary of the current pipeline job.`

<a id="ask-about-a-specific-work-item"></a>

## 询问特定工作项

{{< details >}}

- Add-on: 极狐GitLab Duo Enterprise

{{< /details >}}

{{< collapsible title="编辑器信息" >}}

- GitLab Duo Non-Agentic Chat：极狐GitLab UI、Web IDE、VS Code、JetBrains IDE、Visual Studio 和 Eclipse

{{< /collapsible >}}

您可以询问特定的极狐GitLab 工作项。例如：

- `Generate a summary for the work item identified via this link: <link to your work item>`
- 当您在极狐GitLab 中查看某个工作项时，可以询问 `Generate a concise summary of the current work item.`
- `How can I improve the description of <link to your work item> so that readers understand the value and problems to be solved?`

> [!note]
> 如果工作项包含大量文本（超过 40,000 个单词），极狐GitLab Duo Chat 可能无法考虑每一个单词。AI 模型一次可处理的输入量是有限的。

<a id="explain-selected-code"></a>

## 解释所选代码

{{< details >}}

- Add-on: 极狐GitLab Duo Core、Pro 或 Enterprise、极狐GitLab Duo with Amazon Q

{{< /details >}}

{{< collapsible title="编辑器和模型信息" >}}

- Editors - GitLab Duo Non-Agentic Chat：极狐GitLab UI、Web IDE、VS Code、JetBrains IDE、Visual Studio 和 Eclipse
- Amazon Q 的 LLM：Amazon Q Developer
- 可在[自部署模型的极狐GitLab Duo](../../administration/gitlab_duo_self_hosted/_index.md) 上使用

{{< /collapsible >}}

您可以要求极狐GitLab Duo Chat 解释所选代码：

1. 在您的 IDE 中选择一些代码。
1. 在极狐GitLab Duo Chat 中，输入 `/explain`。

   ![选择代码并使用 /explain 斜杠命令要求极狐GitLab Duo Chat 进行解释。](img/code_selection_duo_chat_v17_4.png)

您还可以添加其他需要考虑的指令。例如：

- `/explain the performance`
- `/explain focus on the algorithm`
- `/explain the performance gains or losses using this code`
- `/explain the object inheritance`（类、面向对象）
- `/explain why a static variable is used here`（C++）
- `/explain how this function would cause a segmentation fault`（C）
- `/explain how concurrency works in this context`（Go）
- `/explain how the request reaches the client`（REST API、数据库）

更多信息，请参见：

- [在 VS Code 中使用极狐GitLab Duo Chat](_index.md#use-gitlab-duo-chat-in-vs-code)。
在极狐GitLab UI 中，您还可以解释以下内容中的代码：

- [文件](../project/repository/code_explain.md)。
- [合并请求](../project/merge_requests/changes.md#explain-code-in-a-merge-request)。

<a id="ask-about-or-generate-code"></a>

## 询问或生成代码

{{< details >}}

- Add-on: 极狐GitLab Duo Core、Pro 或 Enterprise

{{< /details >}}

{{< collapsible title="编辑器信息" >}}

- GitLab Duo Non-Agentic Chat：极狐GitLab UI、Web IDE、VS Code、JetBrains IDE、Visual Studio 和 Eclipse

{{< /collapsible >}}

您可以将代码粘贴到 Chat 窗口中，向极狐GitLab Duo Chat 询问有关该代码的问题。例如：

```plaintext
Provide a clear explanation of this Ruby code: def sum(a, b) a + b end.
Describe what this code does and how it works.
```

您还可以要求 Chat 生成代码。例如：

- `Write a Ruby function that prints 'Hello, World!' when called.`
- `Develop a JavaScript program that simulates a two-player Tic-Tac-Toe game. Provide both game logic and user interface, if applicable.`
- `Create a regular expression for parsing IPv4 and IPv6 addresses in Python.`
- `Generate code for parsing a syslog log file in Java. Use regular expressions when possible, and store the results in a hash map.`
- `Create a product-consumer example with threads and shared memory in C++. Use atomic locks when possible.`
- `Generate Rust code for high performance gRPC calls. Provide a source code example for a server and client.`

<a id="ask-follow-up-questions"></a>

## 提出后续问题

{{< details >}}

- Add-on: 极狐GitLab Duo Core、Pro 或 Enterprise

{{< /details >}}

{{< collapsible title="编辑器信息" >}}

- GitLab Duo Non-Agentic Chat：极狐GitLab UI、Web IDE、VS Code、JetBrains IDE、Visual Studio 和 Eclipse

{{< /collapsible >}}

您可以提出后续问题，以更深入地探讨当前的主题或任务。这有助于您获得更详细、更精确且针对您具体需求的回答，无论是为了进一步澄清、详细说明还是获得额外帮助。

对问题 `Write a Ruby function that prints 'Hello, World!' when called`的后续提问可以是：

- `Can you also explain how I can call and execute this Ruby function in a typical Ruby environment, such as the command line?`

对问题 `How to start a C# project?` 的后续提问可以是：

- `Can you also explain how to add a .gitignore and .gitlab-ci.yml file for C#?`

<a id="ask-about-errors"></a>

## 询问错误相关问题

{{< details >}}

- Add-on: 极狐GitLab Duo Core、Pro 或 Enterprise

{{< /details >}}

{{< collapsible title="编辑器信息" >}}

- GitLab Duo Non-Agentic Chat：极狐GitLab UI、Web IDE、VS Code、JetBrains IDE、Visual Studio 和 Eclipse

{{< /collapsible >}}

需要编译源代码的编程语言可能会抛出难以理解的错误消息。同样，脚本或 Web 应用程序可能会抛出堆栈跟踪。您可以在复制的错误消息前加上例如 `Explain this error message:` 来询问极狐GitLab Duo Chat。请添加具体的上下文，例如编程语言。

- `Explain this error message in Java: Int and system cannot be resolved to a type`
- `Explain when this C function would cause a segmentation fault: sqlite3_prepare_v2()`
- `Explain what would cause this error in Python: ValueError: invalid literal for int()`
- `Why is "this" undefined in VueJS? Provide common error cases, and explain how to avoid them.`
- `How to debug a Ruby on Rails stacktrace? Share common strategies and an example exception.`

<a id="ask-about-specific-files-in-the-ide"></a>

## 询问 IDE 中的特定文件

{{< details >}}

- Add-on: 极狐GitLab Duo Core、Pro 或 Enterprise

{{< /details >}}

{{< collapsible title="编辑器信息" >}}

- GitLab Duo Non-Agentic Chat：VS Code、JetBrains IDE、Visual Studio 和 Eclipse

{{< /collapsible >}}

在受支持的 IDE 中，输入 `/include` 并选择文件，即可将代码仓库文件添加到极狐GitLab Duo Chat 对话中。

先决条件：

- 文件必须是代码仓库的一部分。
- 文件必须基于文本。不支持 PDF 或图像等二进制文件。

操作步骤：

1. 在您的 IDE 中，在极狐GitLab Duo Chat 中，输入 `/include`。
1. 要添加文件，您可以：
   - 从列表中选择文件。
   - 输入文件路径。

例如，如果您正在开发一个电子商务应用，可以将 `cart_service.py` 和 `checkout_flow.js` 文件添加到 Chat 的上下文中，然后询问：

- `How does checkout_flow.js interact with cart_service.py? Generate a sequence diagram using Mermaid.`
- `Can you extend the checkout process by showing products related to the ones in the user's cart? I want to move the checkout logic to the backend before proceeding. Generate the Python backend code and change the frontend code to work with the new backend.`

> [!note]
> 您不能使用 [Quick Chat](_index.md#in-an-editor-window) 添加文件，也不能就为 Chat 上下文添加的文件提问。

<a id="refactor-code-in-the-ide"></a>

## 在 IDE 中重构代码

{{< details >}}

- Add-on: 极狐GitLab Duo Core、Pro 或 Enterprise、极狐GitLab Duo with Amazon Q

{{< /details >}}

{{< collapsible title="编辑器和模型信息" >}}

- Editors - GitLab Duo Non-Agentic Chat：Web IDE、VS Code、JetBrains IDE、Visual Studio 和 Eclipse
- Amazon Q 的 LLM：Amazon Q Developer
- 可在[自部署模型的极狐GitLab Duo](../../administration/gitlab_duo_self_hosted/_index.md) 上使用

{{< /collapsible >}}

您可以要求极狐GitLab Duo Chat 重构所选代码：

1. 在您的 IDE 中选择一些代码。
1. 在极狐GitLab Duo Chat 中，输入 `/refactor`。

您可以添加其他需要考虑的指令。例如：

- 使用特定的编码模式，例如 `/refactor with ActiveRecord` 或 `/refactor into a class providing static functions`。
- 使用特定的库，例如 `/refactor using mysql`。
- 使用特定的函数/算法，例如 C++ 中的 `/refactor into a stringstream with multiple lines`。
- 重构为另一种编程语言，例如 `/refactor to TypeScript`。
- 关注性能，例如 `/refactor improving performance`。
- 关注潜在漏洞，例如 `/refactor avoiding memory leaks and exploits`。

`/refactor` 使用 [Repository X-Ray](../project/repository/code_suggestions/repository_xray.md) 提供更准确、更具上下文感知的建议。

更多信息，请参见：

<a id="fix-code-in-the-ide"></a>

## 在 IDE 中修复代码

{{< details >}}

- Add-on: 极狐GitLab Duo Core、Pro 或 Enterprise、极狐GitLab Duo with Amazon Q

{{< /details >}}

{{< collapsible title="编辑器和模型信息" >}}

- Editors - GitLab Duo Non-Agentic Chat：Web IDE、VS Code、JetBrains IDE、Visual Studio 和 Eclipse
- Amazon Q 的 LLM：Amazon Q Developer
- 可在[自部署模型的极狐GitLab Duo](../../administration/gitlab_duo_self_hosted/_index.md) 上使用

{{< /collapsible >}}

您可以要求极狐GitLab Duo Chat 修复所选代码：

1. 在您的 IDE 中选择一些代码。
1. 在极狐GitLab Duo Chat 中，输入 `/fix`。

您可以添加其他需要考虑的指令。例如：

- 关注语法和拼写错误，例如 `/fix grammar mistakes and typos`。
- 关注具体的算法或问题描述，例如 `/fix duplicate database inserts` 或 `/fix race conditions`。
- 关注不直接可见的潜在缺陷，例如 `/fix potential bugs`。
- 关注代码性能问题，例如 `/fix performance problems`。
- 关注在代码无法编译时修复构建，例如 `/fix the build`。

`/fix` 使用 [Repository X-Ray](../project/repository/code_suggestions/repository_xray.md) 提供更准确、更具上下文感知的建议。

<a id="write-tests-in-the-ide"></a>

## 在 IDE 中编写测试

{{< details >}}

- Add-on: 极狐GitLab Duo Core、Pro 或 Enterprise、极狐GitLab Duo with Amazon Q

{{< /details >}}

{{< collapsible title="编辑器和模型信息" >}}

- Editors - GitLab Duo Non-Agentic Chat：Web IDE、VS Code、JetBrains IDE、Visual Studio 和 Eclipse
- Amazon Q 的 LLM：Amazon Q Developer
- 可在[自部署模型的极狐GitLab Duo](../../administration/gitlab_duo_self_hosted/_index.md) 上使用

{{< /collapsible >}}

您可以要求极狐GitLab Duo Chat 为所选代码创建测试：

1. 在您的 IDE 中选择一些代码。
1. 在极狐GitLab Duo Chat 中，输入 `/tests`。

您可以添加其他需要考虑的指令。例如：

- 使用特定的测试框架，例如 `/tests using the Boost.test framework`（C++）或 `/tests using Jest`（JavaScript）。
- 关注极端测试用例，例如 `/tests focus on extreme cases, force regression testing`。
- 关注性能，例如 `/tests focus on performance`。
- 关注回归和潜在漏洞利用，例如 `/tests focus on regressions and potential exploits`。

`/tests` 使用 [Repository X-Ray](../project/repository/code_suggestions/repository_xray.md) 提供更准确、更具上下文感知的建议。

更多信息，请参见[在 VS Code 中使用极狐GitLab Duo Chat](_index.md#use-gitlab-duo-chat-in-vs-code)。


<a id="ask-about-cicd"></a>

## 询问 CI/CD 相关问题

{{< details >}}

- Add-on: 极狐GitLab Duo Pro 或 Enterprise

{{< /details >}}

{{< collapsible title="编辑器信息" >}}

- GitLab Duo Non-Agentic Chat：极狐GitLab UI、Web IDE、VS Code、JetBrains IDE、Visual Studio 和 Eclipse

{{< /collapsible >}}

您可以要求极狐GitLab Duo Chat 创建 CI/CD 配置：

- `Create a .gitlab-ci.yml configuration file for testing and building a Ruby on Rails application in a GitLab CI/CD pipeline.`
- `Create a CI/CD configuration for building and linting a Python application.`
- `Create a CI/CD configuration to build and test Rust code.`
- `Create a CI/CD configuration for C++. Use gcc as compiler, and cmake as build tool.`
- `Create a CI/CD configuration for VueJS. Use npm, and add SAST security scanning.`
- `Generate a security scanning pipeline configuration, optimized for Java.`

您还可以通过粘贴错误消息并要求解释特定作业错误，错误消息前加上 `Explain this CI/CD job error message, in the context of <language>:`：

- `Explain this CI/CD job error message in the context of a Go project: build.sh: line 14: go command not found`

或者，您可以使用极狐GitLab Duo 根因分析来[排查失败的 CI/CD 作业](#troubleshoot-failed-cicd-jobs-with-root-cause-analysis)。

<a id="troubleshoot-failed-cicd-jobs-with-root-cause-analysis"></a>

## 使用根因分析排查失败的 CI/CD 作业

{{< details >}}

- Add-on: 极狐GitLab Duo Enterprise、极狐GitLab Duo with Amazon Q

{{< /details >}}

{{< collapsible title="编辑器和模型信息" >}}

- Editors: 极狐GitLab UI
- 默认 LLM：Anthropic Claude Sonnet 4.0
- Amazon Q 的 LLM：Amazon Q Developer
- 可在[自部署模型的极狐GitLab Duo](../../administration/gitlab_duo_self_hosted/_index.md) 上使用

{{< /collapsible >}}

您可以在极狐GitLab Duo Chat 中使用极狐GitLab Duo 根因分析，快速识别并修复 CI/CD 作业失败。它会分析作业日志的最后 100,000 个字符，以确定失败原因并提供修复示例。

您可以从合并请求中的**流水线**标签页访问此功能，也可以直接从作业日志访问。


根因分析不支持：

- 触发作业
- 下游流水线

根因分析是与极狐GitLab Duo Agent Platform 不同的极狐GitLab Duo Chat 体验。
如果您的实例关闭了极狐GitLab Duo Chat，即使 Agent Platform 可用，也不会显示排查选项。
如果您想自动修复流水线，请参见[修复 CI/CD 流水线任务流](../duo_agent_platform/flows/foundational_flows/fix_pipeline.md)。

请在[史诗 13872](https://gitlab.com/groups/gitlab-org/-/epics/13872)中提供有关此功能的反馈。

先决条件：

- 您必须拥有查看该 CI/CD 作业的权限。

<a id="from-a-merge-request"></a>

### 从合并请求中

要从合并请求中排查失败的 CI/CD 作业：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 转到您的合并请求。
1. 选择**流水线**标签页。
1. 在失败作业小组件中，您可以：
   - 选择作业 ID 以转到作业日志。
   - 选择**排查**以直接分析失败。

<a id="from-the-job-log"></a>

### 从作业日志中

要从作业日志中排查失败的 CI/CD 作业：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**构建** > **作业**。
1. 选择失败的 CI/CD 作业。
1. 在作业日志下方，您可以：
   - 选择**排查**。
   - 打开极狐GitLab Duo Chat 并输入 `/troubleshoot`。

<a id="from-the-security-configuration-page"></a>

### 从安全配置页面

要从安全配置页面排查失败的扫描器作业：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**安全** > **安全配置**。
1. 在**扫描配置文件**部分，找到状态为失败的扫描器。
1. 通过完成以下任一操作打开作业详情抽屉：
   - 将鼠标悬停在**上次扫描**列上以打开作业详情弹出框，然后选择**排查失败**。
   - 选择扫描器旁边的垂直省略号 ({{< icon name="ellipsis_v" >}})，然后选择**排查失败**。
1. 在抽屉页脚中，选择**排查失败** ({{< icon name="tanuki-ai" >}})。

<a id="explain-a-vulnerability"></a>

## 解释漏洞

{{< details >}}

- Tier: 旗舰版
- Add-on: 极狐GitLab Duo Enterprise、极狐GitLab Duo with Amazon Q

{{< /details >}}

{{< collapsible title="编辑器和模型信息" >}}

- Editors: 极狐GitLab UI
- 默认 LLM：MiniMax-M3
- Amazon Q 的 LLM：Amazon Q Developer
- 可在[自部署模型的极狐GitLab Duo](../../administration/gitlab_duo_self_hosted/_index.md) 上使用

{{< /collapsible >}}

当您查看 SAST 漏洞报告时，可以要求极狐GitLab Duo Chat 解释漏洞。

更多信息，请参见[解释漏洞](../application_security/analyze/duo.md)。

<a id="gitlab-duo-chat-slash-commands"></a>

## 极狐GitLab Duo Chat 斜杠命令

极狐GitLab Duo Chat 有一系列通用、极狐GitLab UI 和 IDE 命令，每个命令都以斜杠（`/`）开头。

使用这些命令可以快速完成特定任务。

<a id="universal"></a>

### 通用

{{< details >}}

- Add-on: 极狐GitLab Duo Core、Pro 或 Enterprise

{{< /details >}}

{{< collapsible title="编辑器信息" >}}

- GitLab Duo Non-Agentic Chat：极狐GitLab UI、Web IDE、VS Code、JetBrains IDE、Visual Studio 和 Eclipse

{{< /collapsible >}}

| 命令 | 用途                                                                                                                       |
|---------|-------------------------------------------------------------------------------------------------------------------------------|
| /new    | 开始新对话，但将之前的对话保留在聊天历史中      |
| /reset  | 清空聊天窗口并重置对话                                       |
| /help   | 了解有关极狐GitLab Duo Chat 工作方式的更多信息。在极狐GitLab Duo Agentic Chat 中不可用。                                                                    |

> [!note]
> 在 JihuLab.com 上，从极狐GitLab 17.10 及更高版本开始，当有[多个对话](_index.md#have-multiple-conversations)时，`/clear` 和 `/reset` 斜杠命令会被 [`/new` 斜杠命令](#gitlab-ui)取代。

<a id="gitlab-ui"></a>

### 极狐GitLab UI

{{< details >}}

- Add-on: 极狐GitLab Duo Enterprise
- Editors: 极狐GitLab UI

{{< /details >}}

这些命令是动态的，仅在使用极狐GitLab Duo Chat 时在极狐GitLab UI 中可用。
它们在极狐GitLab Duo Agentic Chat 中不可用。

| 命令                | 用途                                                                                                            | 区域 |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------ | ---- |
| /summarize_comments    | 生成当前议题上所有评论的摘要。                                               | 议题 |
| /troubleshoot          | [使用根因分析排查失败的 CI/CD 作业](#troubleshoot-failed-cicd-jobs-with-root-cause-analysis)。 | 作业 |
| /vulnerability_explain | [解释当前漏洞](../application_security/analyze/duo.md)。                               | 漏洞 |

<a id="ide"></a>

### IDE

{{< details >}}

- Add-on: 极狐GitLab Duo Core、Pro 或 Enterprise

{{< /details >}}

{{< collapsible title="编辑器信息" >}}

- GitLab Duo Non-Agentic Chat：Web IDE、VS Code、JetBrains IDE、Visual Studio 和 Eclipse

{{< /collapsible >}}

这些命令仅在受支持的 IDE 中使用极狐GitLab Duo Chat 时有效：

| 命令   | 用途                                           |
|-----------|---------------------------------------------------|
| /tests    | [编写测试](#write-tests-in-the-ide)            |
| /explain  | [解释代码](#explain-selected-code)            |
| /refactor | [重构代码](#refactor-code-in-the-ide)    |
| /fix      | [修复代码](#fix-code-in-the-ide)              |
| /include  | [包含文件上下文](#ask-about-specific-files-in-the-ide) <sup>1</sup> |

**脚注**：

1. 在 Web IDE 中使用 GitLab Duo Non-Agentic Chat 时不可用。
