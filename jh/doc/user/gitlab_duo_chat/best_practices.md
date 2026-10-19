---
stage: AI Clients
group: Duo Chat
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab Duo Chat 最佳实践
---

向极狐GitLab Duo Chat 提问时，请遵循以下最佳实践，以获得具体的示例和明确的指导。

<a id="have-a-conversation"></a>

## 进行对话

把聊天当作对话，而不是搜索表单。先提出一个类似搜索的问题，然后追问相关问题以细化范围。通过来回交流逐步建立上下文。

例如，您可以这样问：

```plaintext
c# start project best practices
```

然后追问：

```plaintext
Please show the project structure for the C# project.
```

使用极狐GitLab Duo Agentic Chat，您可以进行涉及多个项目的对话。

```plaintext
Tell me the difference between project A and project B.
```

<a id="refine-the-prompt"></a>

## 优化提示词

为了获得更好的回答，请事先提供更多上下文。想清楚您需要帮助的完整范围，并将其包含在一个提示词中。

```plaintext
How can I get started creating an empty C# console application in VS Code?
Please show a .gitignore and .gitlab-ci.yml configuration with steps for C#,
and add security scanning for GitLab.
```

或者，使用 Agentic Chat：

```plaintext
Create an empty C# console application.
Show a .gitignore and .gitlab-ci.yml configuration with steps for C#,
and add security scanning for GitLab.
```

<a id="follow-prompt-patterns"></a>

## 遵循提示词模式

将提示词组织为问题陈述、请求帮助，然后补充具体细节。不必一开始就把所有问题都问出来。

```plaintext
I need to fulfill compliance requirements. How can I get started with Codeowners and approval rules?
```

然后问：

```plaintext
Please show an example for Codeowners with different teams: backend, frontend, release managers.
```

或者，使用 Agentic Chat：

```plaintext
Create Codeowners with different teams: backend, frontend, release managers.

The group names are "backend-dev," "frontend-dev," and "release-man."
```

<a id="use-low-context-communication"></a>

## 使用低上下文沟通

即使已选中代码，也要像看不到任何内容一样提供上下文。在语言、框架和需求等因素上要具体明确。

```plaintext
When implementing a pure virtual function in an inherited C++ class,
should I use virtual function override, or just function override?
```

当您使用 Agentic Chat 时，这些上下文就没那么重要了，因为它会自主搜索、检索并整合来自多个来源的信息。不过，您仍应明确说明，以帮助 Chat 尽可能高效地工作。

<a id="repeat-yourself"></a>

## 重复提问

如果得到意外或奇怪的回答，请尝试换一种方式提问。补充更多上下文。

```plaintext
How can I get started creating an C# application in VS Code?
```

然后追问：

```plaintext
How can I get started creating an empty C# console application in VS Code?
```

或者，使用 Agentic Chat：

```plaintext
Create an empty C# console application in my test project.
```

<a id="be-patient"></a>

## 保持耐心

避免提出是/否类问题。先笼统提问，然后根据需要提供具体细节。

```plaintext
Explain labels in GitLab. Provide an example for efficient usage with issue boards.
```

<a id="reset-when-needed"></a>

## 必要时重置

如果 Chat 陷入错误的思路，请使用 `/reset`。

<a id="refine-slash-command-prompts"></a>

## 优化斜杠命令提示词

不要局限于基本的斜杠命令。使用斜杠命令时提供更具体的建议。

```plaintext
/refactor into a multi-line written string. Show different approaches for all C++ standards.
```

或者：

```plaintext
/explain why this code has multiple vulnerabilities
```

尽管斜杠命令在 Agentic Chat 中仍然可用，但它们不像在
GitLab Duo Non-Agentic Chat 中那么关键。
您可以要求 Chat 解释或重构代码，它可以跨项目搜索、创建和编辑文件，并同时分析来自多个来源的信息。
