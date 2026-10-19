---
stage: AI Coding
group: Code Review
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: AI 原生特性和功能。
title: GitLab Duo Non-Agentic 功能
---

{{< details >}}

- Tier: 专业版，旗舰版
- Add-on: 极狐GitLab Duo Pro 或 Enterprise
- Offering: JihuLab.com，私有化部署

{{< /details >}}

以下功能已在 JihuLab.com 和极狐GitLab 私有化部署上正式发布。它们需要专业版或旗舰版订阅以及可用的附加组件之一。

极狐GitLab Duo with Amazon Q 功能作为单独的附加组件提供，
且仅在极狐GitLab 私有化部署上可用。

| 功能 | 极狐GitLab Duo Pro | 极狐GitLab Duo Enterprise | 极狐GitLab Duo with Amazon Q |
|---------|----------------|----------------------|--------------------------|
| [代码建议](../project/repository/code_suggestions/_index.md) <sup>1</sup> | {{< yes >}} | {{< yes >}} | {{< yes >}} |
| [GitLab Duo Non-Agentic Chat](../gitlab_duo_chat/_index.md) | {{< yes >}} | {{< yes >}} | {{< yes >}} |
| IDE 中的[代码解释](../gitlab_duo_chat/examples.md#explain-selected-code) | {{< yes >}} | {{< yes >}} | {{< yes >}} |
| IDE 中的[重构代码](../gitlab_duo_chat/examples.md#refactor-code-in-the-ide) | {{< yes >}} | {{< yes >}} | {{< yes >}} |
| IDE 中的[修复代码](../gitlab_duo_chat/examples.md#fix-code-in-the-ide) | {{< yes >}} | {{< yes >}} | {{< yes >}} |
| IDE 中的[测试生成](../gitlab_duo_chat/examples.md#write-tests-in-the-ide) | {{< yes >}} | {{< yes >}} | {{< yes >}} |
| 极狐GitLab UI 中的[代码解释](../project/repository/code_explain.md) | {{< yes >}} | {{< yes >}} | {{< yes >}} |
| [讨论摘要](../discussions/_index.md#summarize-issue-discussions-with-gitlab-duo-chat) | {{< no >}} | {{< yes >}} | {{< yes >}} |
| [代码评审](code_review.md) <sup>2</sup> | {{< no >}} | {{< yes >}} | {{< yes >}} |
| [根本原因分析](../gitlab_duo_chat/examples.md#troubleshoot-failed-cicd-jobs-with-root-cause-analysis) | {{< no >}} | {{< yes >}} | {{< yes >}} |
| [漏洞解释](../application_security/analyze/duo.md) | {{< no >}} | {{< yes >}} | {{< yes >}} |
| [漏洞解决](../application_security/remediate/duo.md) | {{< no >}} | {{< yes >}} | {{< yes >}} |
| [合并提交消息生成](../project/merge_requests/duo_in_merge_requests.md#generate-a-merge-commit-message) | {{< no >}} | {{< yes >}} | {{< yes >}} |

**脚注**：

1. 代码建议也可作为极狐GitLab Duo Agent Platform 的一部分使用，无需
   额外的附加组件。
1. Amazon Q 支持此功能的不同版本。
   [查看如何使用 Amazon Q 评审代码](../duo_amazon_q/_index.md#review-a-merge-request)。

<a id="beta-and-experimental-features"></a>

## 测试版和实验性功能

以下功能尚未正式发布。

它们需要专业版或旗舰版订阅以及极狐GitLab Duo Enterprise 附加组件。

| 功能 | 极狐GitLab Duo Pro | 极狐GitLab Duo Enterprise | 极狐GitLab Duo with Amazon Q |
|---------|----------------|----------------------|--------------------------|
| [合并请求摘要](../project/merge_requests/duo_in_merge_requests.md#generate-a-description-by-summarizing-code-changes) | {{< no >}} | {{< yes >}} | {{< no >}} |
| [代码评审摘要](../project/merge_requests/duo_in_merge_requests.md#summarize-a-code-review) | {{< no >}} | {{< yes >}} | {{< no >}} |
| [议题描述生成](../project/issues/managing_issues.md#populate-an-issue-with-issue-description-generation) | {{< no >}} | {{< yes >}} | {{< no >}} |

<a id="features-available-in-gitlab-duo-self-hosted"></a>

## 极狐GitLab Duo 自部署版本中可用的功能

您的组织可以自部署语言模型。

要了解极狐GitLab Duo 自部署版本支持哪些极狐GitLab Duo 功能，请参阅[支持的功能列表](../../administration/gitlab_duo_self_hosted/_index.md#feature-versions-and-status)。

<a id="amazon-q-developer-pro-included-with-gitlab-duo-with-amazon-q"></a>

## 极狐GitLab Duo With Amazon Q 中包含的 Amazon Q Developer Pro

[Amazon Q Developer Pro](https://aws.amazon.com/q/developer/)的许可证额度已包含在
极狐GitLab Duo with Amazon Q 订阅中。

此订阅包含对 Agentic Chat 和命令行工具的访问权限，包括：

- [IDE 中的 Amazon Q Developer](https://docs.aws.amazon.com/amazonq/latest/qdeveloper-ug/q-in-IDE.html)，包括 Visual Studio、VS Code、JetBrains 和 Eclipse。
- [命令行中的 Amazon Q Developer](https://docs.aws.amazon.com/amazonq/latest/qdeveloper-ug/command-line.html)。
- [AWS 管理控制台中的 Amazon Q Developer](https://aws.amazon.com/q/developer/operate/)。

有关 Amazon Q Developer 功能的更多信息，请参阅 [AWS 网站](https://aws.amazon.com/q/developer/)。
