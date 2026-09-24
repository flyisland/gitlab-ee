---
stage: AI-powered
group: Duo Chat
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab Duo Chat 最佳实践
---

在使用 极狐GitLab Duo Chat 提问时，遵循以下最佳实践可获得具体示例和针对性指导。

<a id="have-a-conversation"></a>

## 对话交流

将聊天视为对话，而非搜索表单。首先提出一个类似搜索的问题，然后通过后续相关问题来细化范围。通过来回交流建立上下文。

例如，你可以问：

```plaintext
c# 项目启动最佳实践
```

然后接着问：

```plaintext
请展示该 C# 项目的结构。
```

使用 极狐GitLab Duo Agentic Chat，你可以进行涉及多个项目的对话。

```plaintext
告诉我项目 A 和项目 B 之间的区别。
```

<a id="refine-the-prompt"></a>

## 优化提示词

要获得更好的回答，请提前提供更多上下文。通盘考虑你需要帮助的全部范围，并将其包含在一条提示词中。

```plaintext
如何开始在 VS Code 中创建一个空的 C# 控制台应用程序？
请展示一个 C# 的 .gitignore 和 .gitlab-ci.yml 配置及其步骤，
并添加极狐GitLab 的安全扫描。
```

或者，使用 Agentic Chat：

```plaintext
创建一个空的 C# 控制台应用程序。
展示一个 C# 的 .gitignore 和 .gitlab-ci.yml 配置及其步骤，
并添加极狐GitLab 的安全扫描。
```

<a id="follow-prompt-patterns"></a>

## 遵循提示词模式

将提示词构建为：问题陈述、请求帮助，再添加具体说明。不必一次性问完所有问题。

```plaintext
我需要满足合规要求。如何开始使用 Codeowners 和审批规则？
```

然后问：

```plaintext
请展示一个包含不同团队（后端、前端、发布经理）的 Codeowners 示例。
```

或者，使用 Agentic Chat：

```plaintext
创建包含不同团队的 Codeowners：后端、前端、发布经理。

组名分别为 “backend-dev”、“frontend-dev” 和 “release-man”。
```

<a id="use-low-context-communication"></a>

## 使用低上下文沟通

即使已选择代码，也应像没有任何上下文可见一样提供上下文。在语言、框架和需求等因素上尽量具体。

```plaintext
在继承的 C++ 类中实现纯虚函数时，
我应该使用 virtual function override，还是只使用 function override？
```

在使用 Agentic Chat 时，这些上下文的重要性较低，因为它会自动从多个来源搜索、检索和组合信息。但为了帮助 Chat 尽可能高效地工作，你仍应表达明确。

<a id="repeat-yourself"></a>

## 重复提问

如果得到意外或奇怪的回答，请尝试重新表述问题。添加更多上下文。

```plaintext
如何开始在 VS Code 中创建一个 C# 应用程序？
```

接着问：

```plaintext
如何开始在 VS Code 中创建一个空的 C# 控制台应用程序？
```

或者，使用 Agentic Chat：

```plaintext
在我的测试项目中创建一个空的 C# 控制台应用程序。
```

<a id="be-patient"></a>

## 保持耐心

避免是非题。从普遍性问题开始，再根据需要提供具体细节。

```plaintext
解释极狐GitLab 中的标签。提供一个在议题看板中高效使用的示例。
```

<a id="reset-when-needed"></a>

## 必要时重置

如果 Chat 陷入错误轨道，可使用 `/reset` 重置。

<a id="refine-slash-command-prompts"></a>

## 优化斜杠命令提示词

超越基本的斜杠命令。使用斜杠命令并附加更具体的建议。

```plaintext
/refactor 成一个多行写入的字符串。展示所有 C++ 标准的不同方法。
```

或者：

```plaintext
/explain 这段代码为什么存在多个漏洞？
```

尽管斜杠命令在 Agentic Chat 中仍然有效，但它们不像在 极狐GitLab Duo Non-Agentic Chat 中那样关键。你可以直接请 Chat 解释或重构代码，它会跨项目搜索、创建和编辑文件，并同时分析来自多个来源的信息。
