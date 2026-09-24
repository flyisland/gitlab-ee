---
stage: AI-powered
group: AI Framework
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: AI-native features and functionality.
title: 极狐GitLab Duo 功能
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 极狐GitLab Duo 首次引入于 GitLab 16.0。
- 在 GitLab 16.6 中移除了第三方 AI 设置。
- 在 GitLab 16.6 中从所有极狐GitLab Duo 功能中移除了对 OpenAI 的支持。

{{< /history >}}

以下功能在 JihuLab.com 和私有化部署上已 GA。
它们需要专业版或旗舰版订阅以及可用的附加组件之一。

| 功能 | 极狐GitLab Duo 核心版 | 极狐GitLab Duo 专业版 | 极狐GitLab Duo 企业版 |
|---------|----------|---------|----------------|
| [代码建议](../project/repository/code_suggestions/_index.md) | {{< yes >}} | {{< yes >}} | {{< yes >}} |
| [极狐GitLab Duo 非 Agentic 聊天](../gitlab_duo_chat/_index.md) | {{< yes >}} | {{< yes >}} | {{< yes >}} |
| [IDE 中的代码解释](../gitlab_duo_chat/examples.md#explain-selected-code) | {{< yes >}} | {{< yes >}} | {{< yes >}} |
| [IDE 中的重构代码](../gitlab_duo_chat/examples.md#refactor-code-in-the-ide) | {{< yes >}} | {{< yes >}} | {{< yes >}} |
| [IDE 中的修复代码](../gitlab_duo_chat/examples.md#fix-code-in-the-ide) | {{< yes >}} | {{< yes >}} | {{< yes >}} |
| [IDE 中的测试生成](../gitlab_duo_chat/examples.md#write-tests-in-the-ide) | {{< yes >}} | {{< yes >}} | {{< yes >}} |
| [极狐GitLab UI 中的代码解释](../project/repository/code_explain.md) | {{< no >}} | {{< yes >}} | {{< yes >}} |
| [讨论摘要](../discussions/_index.md#summarize-issue-discussions-with-gitlab-duo-chat) | {{< no >}} | {{< no >}} | {{< yes >}} |
| [代码审查<br>](code_review.md) <sup>1</sup> | {{< no >}} | {{< no >}} | {{< yes >}} |
| [根因分析](../gitlab_duo_chat/examples.md#troubleshoot-failed-cicd-jobs-with-root-cause-analysis) | {{< no >}} | {{< no >}} | {{< yes >}} |
| [漏洞解释](../application_security/analyze/duo.md) | {{< no >}} | {{< no >}} | {{< yes >}} |
| [漏洞解决](../application_security/remediate/duo.md) | {{< no >}} | {{< no >}} | {{< yes >}} |
| [极狐GitLab Duo 和 SDLC 趋势](../analytics/duo_and_sdlc_trends.md) | {{< no >}} | {{< no >}} | {{< yes >}} |
| [合并提交消息生成](../project/merge_requests/duo_in_merge_requests.md#generate-a-merge-commit-message) | {{< no >}} | {{< no >}} | {{< yes >}} |

<a id="beta-and-experimental-features"></a>

## 测试版和实验性功能

以下功能尚未 GA。
它们需要专业版或旗舰版订阅以及极狐GitLab Duo 企业版附加组件。

| 功能 | 极狐GitLab Duo 核心版 | 极狐GitLab Duo 专业版 | 极狐GitLab Duo 企业版 |
|---------|-----------------|----------------|-----------------------|
| [合并请求摘要](../project/merge_requests/duo_in_merge_requests.md#generate-a-description-by-summarizing-code-changes) | {{< no >}} | {{< no >}} | {{< yes >}} |
| [代码审查摘要](../project/merge_requests/duo_in_merge_requests.md#summarize-a-code-review) | {{< no >}} | {{< no >}} | {{< yes >}} |
| [议题描述生成](../project/issues/managing_issues.md#populate-an-issue-with-issue-description-generation) | {{< no >}} | {{< no >}} | {{< yes >}} |

<a id="features-available-in-gitlab-duo-self-hosted"></a>

## 极狐GitLab Duo 自部署版中可用的功能

您的组织可以自部署语言模型。

要了解极狐GitLab Duo 自部署版中可用的极狐GitLab Duo 功能，请参阅[支持的功能列表](../../administration/gitlab_duo_self_hosted/_index.md#feature-versions-and-status)。