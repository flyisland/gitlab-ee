---
stage: Plan
group: Work Items
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 直接在 Jira 开发面板中查看 Jira 议题对应的极狐GitLab 合并请求、分支和提交。
title: Jira 开发面板
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以使用 Jira 开发面板，直接在 Jira 中查看 Jira 议题对应的极狐GitLab 活动。要设置 Jira 开发面板：

- **对于 Jira Cloud**，请使用由 GitLab 开发和维护的 [GitLab for Jira Cloud 应用](connect-app.md)。
- **对于 Jira Data Center 或 Jira Server**，请使用由 Atlassian 开发和维护的 [Jira DVCS 连接器](dvcs/_index.md)。

<a id="feature-availability"></a>

## 功能可用性

下表显示了 Jira DVCS 连接器 和 GitLab for Jira Cloud 应用可用的功能：

| 功能                                 | Jira DVCS 连接器 | GitLab for Jira Cloud 应用 |
|:-------------------------------------|:--------------------|:--------------------------|
| 智能提交                             | {{< yes >}}         | {{< yes >}}               |
| 同步合并请求                         | {{< yes >}}         | {{< yes >}}               |
| 同步分支                             | {{< yes >}}         | {{< yes >}}               |
| 同步提交                             | {{< yes >}}         | {{< yes >}}               |
| 同步现有数据                         | {{< yes >}}         | {{< yes >}}（请参见[同步到 Jira 的极狐GitLab 数据](connect-app.md#gitlab-data-synced-to-jira)） |
| 同步构建                             | {{< no >}}          | {{< yes >}}               |
| 同步部署                             | {{< no >}}          | {{< yes >}}               |
| 同步功能标志                         | {{< no >}}          | {{< yes >}}               |
| 同步间隔                             | 最长 60 分钟        | 实时                      |
| 删除分支                             | {{< no >}}          | {{< yes >}}               |
| 从分支创建合并请求           | {{< yes >}}         | {{< yes >}}               |
| 从 Jira 议题创建分支                 | {{< no >}}          | {{< yes >}}               |

<a id="connected-projects-in-gitlab"></a>

## 极狐GitLab 中已连接的项目

Jira 开发面板会将一个 Jira 实例及其所有项目连接到以下内容：

- **对于 [GitLab for Jira Cloud 应用](connect-app.md)**，已关联的极狐GitLab 群组或子群组及其项目
- **对于 [Jira DVCS 连接器](dvcs/_index.md)**，已关联的极狐GitLab 群组、子群组或个人命名空间及其项目

<a id="information-displayed-in-the-development-panel"></a>

## 开发面板中显示的信息

您可以在 Jira 开发面板中[查看 Jira 议题对应的极狐GitLab 活动](https://support.atlassian.com/jira-software-cloud/docs/view-development-information-for-an-issue/)，方法是在极狐GitLab 中通过 ID 引用该 Jira 议题。开发面板中显示的信息取决于您在极狐GitLab 中提及 Jira 议题 ID 的位置。

对于 [GitLab for Jira Cloud 应用](connect-app.md)，将显示以下信息。

| 极狐GitLab：提及 Jira 议题 ID 的位置 | Jira 开发面板：显示的信息 |
|---------------------------------------------|-------------------------------------------------------|
| 合并请求标题或描述          | 指向合并请求的链接<br>指向部署的链接<br>通过合并请求标题指向流水线的链接<br>通过合并请求描述指向流水线的链接<br>指向分支的链接<br>审核人信息和审批状态 |
| 分支名称                                 | 指向分支的链接<br>指向部署的链接          |
| 提交消息                              | 指向提交的链接<br>从最后一次成功部署到该环境之后最多 2,000 个提交中指向部署的链接 |
| [Jira 智能提交](#jira-smart-commits)    | 自定义评论、记录时间或工作流状态转换   |

<a id="jira-issue-key-limit"></a>

## Jira 议题键限制

对于单个提交、分支、合并请求、构建、部署或功能标志，Jira 最多接受 500 个 Jira 议题键。如果极狐GitLab 从其中一个实体中提取出超过 500 个不同的 Jira 议题键，则只将前 500 个发送到 Jira。其余议题键不会在开发面板中建立链接。对于部署，极狐GitLab 在截断列表时会优先保留议题键，而不是提交和合并请求关联。此限制由 Jira 设置，而非极狐GitLab。

<a id="jira-smart-commits"></a>

## Jira 智能提交

先决条件：

- 您必须拥有使用相同电子邮件地址或用户名的极狐GitLab 和 Jira 用户账号。
- 命令必须位于提交消息的第一行。
- 提交消息不得超过一行。

Jira 智能提交是用于处理 Jira 议题的特殊命令。使用这些命令，您可以通过极狐GitLab：

- 向 Jira 议题添加自定义评论。
- 针对 Jira 议题记录时间。
- 将 Jira 议题转换为项目工作流中定义的任意状态。

智能提交必须遵循以下语法：

```plaintext
<ISSUE_KEY> <ignored text> #<command> <optional command parameters>
```

您可以在单个提交中执行一个或多个命令。

<a id="smart-commit-syntax"></a>

### 智能提交语法

| 命令                                        | 语法                                                       |
|-------------------------------------------------|--------------------------------------------------------------|
| 添加评论                                   | `KEY-123 #comment Bug is fixed`                              |
| 记录时间                                        | `KEY-123 #time 2w 4d 10h 52m Tracking work time`             |
| 关闭议题                                  | `KEY-123 #close Closing issue`                               |
| 记录时间并关闭议题                     | `KEY-123 #time 2d 5h #close`                                 |
| 添加评论并转换为 **In-progress** | `KEY-123 #comment Started working on the issue #in-progress` |

有关智能提交如何工作以及可使用哪些命令的更多信息，请参见：

- [使用智能提交处理议题](https://support.atlassian.com/jira-software-cloud/docs/process-issues-with-smart-commits/)
- [使用智能提交](https://confluence.atlassian.com/fisheye/using-smart-commits-960155400.html)

<a id="jira-deployments"></a>

## Jira 部署

您可以使用 Jira 部署，直接在 Jira 中跟踪和可视化软件发布进度。

在以下情况下，极狐GitLab 会将您的环境和部署信息发送到 Jira：

- 您项目的 `.gitlab-ci.yml` 文件包含 [`environment`](../../ci/yaml/_index.md#environment) 关键字。
- 在[极狐GitLab 的某些位置提及](#information-displayed-in-the-development-panel)了 Jira 议题 ID，并且触发了流水线。

更多信息，请参见[环境和部署](../../ci/environments/_index.md)。
