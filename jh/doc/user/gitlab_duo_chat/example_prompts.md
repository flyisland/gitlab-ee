---
stage: AI Clients
group: Duo Chat
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab Duo Chat 提示示例
---

极狐GitLab Duo Agentic Chat 可以帮助您回答需要来自多个文件或极狐GitLab 资源的信息的问题。它可以回答有关您代码库的问题，您无需指定确切的文件路径。它还可以理解议题或合并请求的状态，并创建和编辑文件。

<a id="learn-more-about-your-projects"></a>

## 进一步了解您的项目

极狐GitLab Duo Chat 最适合处理自然语言问题。您可以就项目的任何方面提问，从概括到具体。

- `Read the project structure and explain it to me`，或 `Explain the project`。
- `Find the API endpoints that handle user authentication in this codebase`。
- `Please explain the authorization flow for <application name>`。
- `How do I add a GraphQL mutation in this repository?`
- `Show me how error handling is implemented across our application`。
- `Component <component name> has methods for <x> and <y>. Could you split it into two components?`
- `Do merge request <MR URL> and merge request <MR URL> fully address this issue <issue URL>?`

<a id="have-chat-do-the-work-for-you"></a>

## 让 Chat 为您完成工作

如果您已经知道想要做什么，Chat 可以为您完成工作。

- `Add a GraphQL mutation that lets users query my application.`
- `Implement error handling for my application`。
- `Component <component name> has methods for <x> and <y>. Split it into two components.`
- `Add inline documentation for all Java files in <directory>.`
- `Create a merge request to address this issue: <issue URL>.`

<a id="use-chat-to-address-security-vulnerabilities"></a>

## 使用 Chat 处理安全漏洞

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com

{{< /details >}}

使用 Chat 通过自然语言命令对漏洞进行排查、管理和修复。

有关漏洞信息和分析：

- `List all vulnerabilities in a project with filtering by severity and report types.`
- `Get detailed vulnerability information including CVE data, EPSS scores, and reachability analysis.`
- `Show me all critical vulnerabilities in my project.`
- `List vulnerabilities with EPSS scores above 0.7 that are reachable.`

有关漏洞管理：

- `Mark this vulnerability as a genuine security issue.`
- `Revert vulnerability status back to detected for re-assessment.`
- `Dismiss all dependency scanning vulnerabilities marked as false positives with unreachable code.`
- `Show me vulnerabilities dismissed in the past week with their reasoning.`
- `Confirm all container scanning vulnerabilities with known exploits.`
- `Link vulnerability 123 to issue 456 for tracking remediation.`

有关议题管理集成：

- `Create issues for all confirmed high-severity SAST vulnerabilities and assign them to recent committers.`
- `Update severity to HIGH for all vulnerabilities that cross trust boundaries.`

有关安全功能的更多信息，请参阅[史诗 19639](https://gitlab.com/groups/gitlab-org/-/epics/19639)。
