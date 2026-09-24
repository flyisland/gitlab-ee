---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Jira 开发面板
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以使用 Jira 开发面板直接在 Jira 中查看 Jira 议题的极狐GitLab 活动。
要设置 Jira 开发面板：

- **对于 Jira Cloud**，请使用由极狐GitLab 开发和维护的[极狐GitLab for Jira Cloud 应用](connect-app.md)。
- **对于 Jira Data Center 或 Jira Server**，请使用由 Atlassian 开发和维护的 [Jira DVCS 连接器](dvcs/_index.md)。

<a id="feature-availability"></a>

## 功能可用性

{{< history >}}

- 在极狐GitLab 17.1 中，删除分支的功能引入，伴随名为 `jira_connect_remove_branches` 的功能标志。默认禁用。
- 在极狐GitLab 17.2 中，删除分支的功能 GA。功能标志 `jira_connect_remove_branches` 已移除。

{{< /history >}}

此表显示了 Jira DVCS 连接器和极狐GitLab for Jira Cloud 应用可用的功能：

| 功能                                | Jira DVCS 连接器 | 极狐GitLab for Jira Cloud 应用 |
|:-------------------------------------|:--------------------|:--------------------------|
| 智能提交                            | {{< yes >}}         | {{< yes >}}               |
| 同步合并请求                        | {{< yes >}}         | {{< yes >}}               |
| 同步分支                            | {{< yes >}}         | {{< yes >}}               |
| 同步提交                            | {{< yes >}}         | {{< yes >}}               |
| 同步现有数据                        | {{< yes >}}         | {{< yes >}}（参见[极狐GitLab 数据同步至 Jira](connect-app.md#gitlab-data-synced-to-jira)）|
| 同步构建                            | {{< no >}}          | {{< yes >}}               |
| 同步部署                            | {{< no >}}          | {{< yes >}}               |
| 同步功能标志                        | {{< no >}}          | {{< yes >}}               |
| 同步间隔                            | 最多 60 分钟        | 实时                      |
| 删除分支                            | {{< no >}}          | {{< yes >}}               |
| 从分支创建合并请求                  | {{< yes >}}         | {{< yes >}}               |
| 从 Jira 议题创建分支                | {{< no >}}          | {{< yes >}}               |

<a id="connected-projects-in-gitlab"></a>

## 极狐GitLab 中的连接项目

Jira 开发面板将一个 Jira 实例及其所有项目连接到以下内容：

- **对于[极狐GitLab for Jira Cloud 应用](connect-app.md)**，关联的极狐GitLab 群组或子群组及其项目
- **对于 [Jira DVCS 连接器](dvcs/_index.md)**，关联的极狐GitLab 群组、子群组或个人命名空间及其项目

<a id="information-displayed-in-the-development-panel"></a>

## 开发面板中显示的信息

您可以通过在极狐GitLab 中引用 Jira 议题 ID，在 Jira 开发面板中[查看 Jira 议题的极狐GitLab 活动](https://support.atlassian.com/jira-software-cloud/docs/view-development-information-for-an-issue/)。开发面板中显示的信息取决于您在极狐GitLab 中提及 Jira 议题 ID 的位置。

对于[极狐GitLab for Jira Cloud 应用](connect-app.md)，将显示以下信息。

| 极狐GitLab：您在何处提及 Jira 议题 ID | Jira 开发面板：显示哪些信息 |
|---------------------------------------------|-------------------------------------------------------|
| 合并请求标题或描述                          | 合并请求链接<br>部署链接<br>通过合并请求标题的流水线链接<br>通过合并请求描述的流水线链接（在极狐GitLab 15.10 中引入）<br>分支链接（在极狐GitLab 15.11 中引入）<br>审查者信息和批准状态（在极狐GitLab 16.5 中引入） |
| 分支名称                                   | 分支链接<br>部署链接          |
| 提交消息                                   | 提交链接<br>部署链接（自上次成功部署到环境后的最多 2,000 个提交）<sup>1</sup> <sup>2</sup> |
| [Jira 智能提交](#jira-smart-commits)      | 自定义评论、已记录时间或工作流过渡   |

**脚注**：

1. 在极狐GitLab 16.2 中引入，伴随名为 `jira_deployment_issue_keys` 的功能标志。默认启用。
1. 在极狐GitLab 16.3 中 GA。功能标志 `jira_deployment_issue_keys` 已移除。

<a id="jira-smart-commits"></a>

## Jira 智能提交

先决条件：

- 您必须拥有相同电子邮件地址或用户名的极狐GitLab 和 Jira 用户帐户。
- 命令必须位于提交消息的第一行。
- 提交消息不能跨越多行。

Jira 智能提交是用于处理 Jira 议题的特殊命令。借助这些命令，您可以使用极狐GitLab：

- 向 Jira 议题添加自定义评论。
- 记录 Jira 议题的工作时间。
- 将 Jira 议题转换为项目工作流中定义的任何状态。

智能提交必须遵循以下语法：

```plaintext
<ISSUE_KEY> <忽略的文本> #<command> <可选命令参数>
```

您可以在单个提交中执行一个或多个命令。

### 智能提交语法

| 命令                              | 语法                                                       |
|-------------------------------------------------|--------------------------------------------------------------|
| 添加评论                          | `KEY-123 #comment 错误已修复`                                |
| 记录时间                          | `KEY-123 #time 2w 4d 10h 52m 追踪工作时间`                  |
| 关闭议题                          | `KEY-123 #close 关闭议题`                                   |
| 记录时间并关闭议题                | `KEY-123 #time 2d 5h #close`                                 |
| 添加评论并转换为 **进行中**       | `KEY-123 #comment 开始处理该议题 #in-progress`               |

有关智能提交如何工作以及可使用哪些命令的更多信息，请参见：

- [使用智能提交处理议题](https://support.atlassian.com/jira-software-cloud/docs/process-issues-with-smart-commits/)
- [使用智能提交](https://confluence.atlassian.com/fisheye/using-smart-commits-960155400.html)

<a id="jira-deployments"></a>

## Jira 部署

您可以使用 Jira 部署直接在 Jira 中跟踪和可视化软件发布的进展。

如果满足以下条件，极狐GitLab 会向 Jira 发送有关您的环境和部署的信息：

- 您项目的 `.gitlab-ci.yml` 文件包含 [`environment`](../../ci/yaml/_index.md#environment) 关键字。
- Jira 议题 ID 在[极狐GitLab 的某些部分中被提及](#information-displayed-in-the-development-panel)并且触发了流水线。

有关更多信息，请参见[环境与部署](../../ci/environments/_index.md)。