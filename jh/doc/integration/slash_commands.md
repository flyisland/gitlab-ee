---
stage: Ecosystem
group: Integrations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Mattermost 和 Slack 中的指令 **(BASIC ALL)**

如果您想在使用 Slack 和 Mattermost 时控制和查看极狐GitLab 内容，可以使用指令。
在您的聊天客户端中键入指令作为消息可以激活它。
对于 Slack，需要[集成配置](../user/project/integrations/slack_slash_commands.md)。

指令的范围是一个项目，并且需要在配置期间指定触发命令。

我们建议您使用项目名称作为触发命令。

假设 `project-name` 是触发命令，指令为：

| 命令 | 效果 |
| ------- | ------ |
| `/project-name help` | 显示所有可用的指令。 |
| `/project-name issue new <title> <shift+return> <description>` | 使用标题 `<title>` 和描述 `<description>` 创建一个新议题。 |
| `/project-name issue show <id>` | 使用 ID `<id>` 显示指定议题。 |
| `/project-name issue close <id>` | 使用 ID `<id>` 关闭指定议题。 |
| `/project-name issue search <query>` | 最多显示 5 个匹配 `<query>` 的议题。 |
| `/project-name issue move <id> to <project>` | 使用 ID `<id>` 移动议题到 `<project>`。 |
| `/project-name issue comment <id> <shift+return> <comment>` | 向 ID 为 `<id>` 的议题，添加评论正文为 `<comment>` 的新评论。 |
| `/project-name deploy <from> to <to>` | 从 `<from>` 环境[部署](#deploy-command)到 `<to>` 环境。 |
| `/project-name run <job name> <arguments>` | 在默认分支上执行 ChatOps<!--[ChatOps](../ci/chatops/index.md)--> 作业`<job name>`。 |

<!--
If you are using the [GitLab Slack application](../user/project/integrations/gitlab_slack_application.md) for
your GitLab.com projects, [add the `gitlab` keyword at the beginning of the command](../user/project/integrations/gitlab_slack_application.md#usage).
-->

## 议题命令

您可以创建新议题、显示议题详细信息并搜索最多 5 个议题。

<a id="deploy-command"></a>

## 部署命令

为了部署到环境中，系统尝试在流水线中查找部署手动操作。

如果对于指定环境只有一个操作，则会触发它。
如果定义了多个操作，系统会找到一个与要部署到的环境名称相同的操作名称。

如果未找到匹配的操作，该命令将返回错误。
