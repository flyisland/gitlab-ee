---
stage: Plan
group: Work Items
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 比较 Jira 议题集成和 Jira 开发面板，以选择极狐GitLab 连接 Jira 的方式。
title: Jira
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

将您的极狐GitLab 项目与 Jira 连接，以在两个平台上保持精简的开发工作流。当您的团队使用 Jira 进行议题跟踪、使用极狐GitLab 进行开发时，Jira 集成可打通规划与执行之间的连接。

借助 Jira 集成：

- 开发团队无需切换上下文，即可直接在极狐GitLab 中访问 Jira 议题。
- 项目经理可在团队使用极狐GitLab 开发时，在 Jira 中跟踪开发进度。
- 当开发者在提交和合并请求中引用 Jira 议题时，Jira 议题会自动更新。
- 团队成员可以发现代码更改与 Jira 议题中跟踪的需求之间的关联。
- 来自极狐GitLab 的漏洞发现结果会在 Jira 中创建议题，以便进行适当的跟踪和解决。

您可以[将 Jira 议题导入极狐GitLab](../../user/import/third_party_systems/jira.md)，或
将 Jira 与极狐GitLab 集成，并继续同时使用这两个平台。

<a id="jira-integrations"></a>

## Jira 集成

极狐GitLab 提供两种 Jira 集成。您可以根据[所需功能](#feature-availability)使用其中一种或同时使用两种集成。

<a id="jira-issues-integration"></a>

### Jira 议题集成

您可以使用由极狐GitLab 开发的 [Jira 议题集成](configure.md)，适用于
Jira Cloud、Jira Data Center 或 Jira Server。借助此集成，您可以：

- 直接在极狐GitLab 中查看和搜索 Jira 议题。
- 在极狐GitLab 提交和合并请求中按 ID 引用 Jira 议题。
- 为漏洞创建 Jira 议题。

<a id="jira-development-panel"></a>

### Jira 开发面板

您可以使用 [Jira 开发面板](development_panel.md)来
[查看议题的极狐GitLab 活动](https://support.atlassian.com/jira-software-cloud/docs/view-development-information-for-an-issue/)，
包括相关的分支、提交和合并请求。要配置 Jira 开发面板：

- **对于 Jira Cloud**，请使用由极狐GitLab 开发和维护的 [GitLab for Jira Cloud 应用](connect-app.md)。
- **对于 Jira Data Center 或 Jira Server**，请使用由 Atlassian 开发和维护的 [Jira DVCS 连接器](dvcs/_index.md)。

<a id="feature-availability"></a>

## 功能可用性

此表显示了 Jira 议题集成和 Jira 开发面板可用的功能：

| 功能                                                                                                                                                                                                             | Jira 议题集成                                                                                                                                       | Jira 开发面板 |
|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------|
| 在极狐GitLab 提交或合并请求中提及 Jira 议题 ID，系统会创建指向该 Jira 议题的链接。                                                                                                               | {{< yes >}}                                                                                                                                                   | {{< no >}}             |
| 在极狐GitLab 中提及 Jira 议题 ID，Jira 议题会显示对应的极狐GitLab 议题或合并请求。                                                                                                                      | {{< yes >}}，一条包含极狐GitLab 议题或合并请求标题的 Jira 评论会链接到极狐GitLab。首次提及也会添加到 Jira 议题的 **Web 链接** 中。 | {{< yes >}}，极狐GitLab 合并请求会显示在 Jira 议题的[开发面板](https://support.atlassian.com/jira-software-cloud/docs/view-development-information-for-an-issue/)中。极狐GitLab 议题不会显示在开发面板中。 |
| 在极狐GitLab 提交中提及 Jira 议题 ID，Jira 议题会显示该提交消息。                                                                                                                            | {{< yes >}}，完整的提交消息会作为评论显示在 Jira 议题中，并显示在 **Web 链接** 中。每条消息都会链接回极狐GitLab 中的对应提交。     | {{< yes >}}，显示在 Jira 议题的开发面板中。使用 [Jira Smart Commits](https://confluence.atlassian.com/fisheye/using-smart-commits-960155400.html) 可以添加自定义评论。 |
| 在极狐GitLab 分支名称中提及 Jira 议题 ID，Jira 议题会显示该分支名称。                                                                                                                          | {{< no >}}                                                                                                                                                    | {{< yes >}}，显示在 Jira 议题的开发面板中。 |
| 为 Jira 议题添加时间跟踪。                                                                                                                                                                                  | {{< no >}}                                                                                                                                                    | {{< yes >}}，使用 Jira Smart Commits。 |
| 使用极狐GitLab 提交或合并请求来转换 Jira 议题。                                                                                                                                                    | {{< yes >}}，仅支持单一转换。通常用于关闭 Jira 议题。                                                                                | {{< yes >}}，使用 Jira Smart Commits 将 Jira 议题转换到任何状态。 |
| [查看 Jira 议题列表](configure.md#view-jira-issues)。                                                                                                                                                        | {{< yes >}}                                                                                                                                                   | {{< no >}}             |
| [为漏洞创建 Jira 议题](configure.md#create-a-jira-issue-for-a-vulnerability)。                                                                                                                    | {{< yes >}}                                                                                                                                                   | {{< no >}}             |
| 从 Jira 议题创建极狐GitLab 分支。                                                                                                                                                                           | {{< no >}}                                                                                                                                                    | {{< yes >}}，显示在 Jira 议题的开发面板中。 |
| 在极狐GitLab 合并请求、分支名称或分支最近一次成功部署到环境后的最近 2,000 个提交中提及 Jira 议题 ID，以将极狐GitLab 部署同步到 Jira 议题。 | {{< no >}}                                                                                                                                                    | {{< yes >}}，显示在 Jira 议题的开发面板中。 |

<a id="privacy-considerations"></a>

## 隐私注意事项

所有 Jira 议题集成都会在极狐GitLab 之外共享数据。如果您将私有极狐GitLab 项目与 Jira 集成，则私有数据会与有权访问您 Jira 项目的用户共享。

[Jira 议题集成](configure.md)会将极狐GitLab 数据作为评论发布到 Jira 议题上。
[GitLab for Jira Cloud 应用](connect-app.md)和 [Jira DVCS 连接器](dvcs/_index.md)
通过 [Jira 开发面板](development_panel.md)共享极狐GitLab 数据。
使用 Jira 开发面板时，您可以限制某些用户组或角色的访问权限。
