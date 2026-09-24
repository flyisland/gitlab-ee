---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: ChatOps
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用极狐GitLab ChatOps 通过 Slack 等聊天服务与 CI/CD 任务交互。

许多组织使用 Slack 或 Mattermost 进行协作、故障排除和工作规划。借助 ChatOps，你可以在同一个应用程序中与团队讨论工作、运行 CI/CD 任务，并查看任务输出。

<a id="slash-command-integrations"></a>

## 斜杠命令集成

你可以使用 [`run` 斜杠命令](../../user/project/integrations/gitlab_slack_application.md#slash-commands) 触发 ChatOps。

以下集成可用：

- [极狐GitLab for Slack 应用](../../user/project/integrations/gitlab_slack_application.md)（推荐用于 Slack）
- [Mattermost 斜杠命令](../../user/project/integrations/mattermost_slash_commands.md)

<a id="chatops-workflow-and-cicd-configuration"></a>

## ChatOps 工作流和 CI/CD 配置

ChatOps 在项目默认分支的 [`.gitlab-ci.yml`](../yaml/_index.md) 中查找指定任务。如果找到该任务，ChatOps 会创建一个仅包含该指定任务的流水线。如果设置了 `when: manual`，ChatOps 会创建流水线，但任务不会自动启动。

通过 ChatOps 运行的任务具有与从极狐GitLab 运行的任务相同的功能。该任务可以使用现有的 [CI/CD 变量](../variables/_index.md#predefined-cicd-variables)，如 `GITLAB_USER_ID`，来进行额外的权限验证，但这些变量可以被[覆盖](../variables/_index.md#cicd-variable-precedence)。

你应该设置 [`rules`](../yaml/_index.md#rules)，以便该任务不作为标准 CI/CD 流水线的一部分运行。

ChatOps 将以下 [CI/CD 变量](../variables/_index.md#predefined-cicd-variables) 传递给任务：

- `CHAT_INPUT` - 传递给 `run` 斜杠命令的参数。
- `CHAT_CHANNEL` - 运行任务的聊天频道名称。
- `CHAT_USER_ID` - 运行任务的用户的聊天服务 ID。

任务运行时：

- 如果任务在 30 分钟内完成，ChatOps 会将任务输出发送到聊天频道。
- 如果任务完成时间超过 30 分钟，你必须使用类似 [Slack API](https://api.slack.com/) 的方法将数据发送到频道。

<a id="exclude-a-job-from-chatops"></a>

### 从 ChatOps 中排除任务

要防止从聊天中运行任务：

- 在 `.gitlab-ci.yml` 中，将任务设置为 `except: [chat]`。

<a id="customize-the-chatops-reply"></a>

### 自定义 ChatOps 回复

ChatOps 将使用单个命令的任务的输出作为回复发送到频道。例如，当以下任务运行时，聊天回复为 `Hello world`：

```yaml
stages:
- chatops

hello-world:
  stage: chatops
  rules:
    - if: $CI_PIPELINE_SOURCE == "chat"
  script:
    - echo "Hello World"
```

如果任务包含多个命令，或者设置了 `before_script`，ChatOps 会将命令及其输出发送到频道。命令会被包装在 ANSI 颜色代码中。

要有选择地回复一个命令的输出，请将输出放在 `chat_reply` 部分。例如，以下任务列出当前目录中的文件：

```yaml
stages:
- chatops

ls:
  stage: chatops
  rules:
    - if: $CI_PIPELINE_SOURCE == "chat"
  script:
    - echo "This command will not be shown."
    - echo -e "section_start:$( date +%s ):chat_reply\r\033[0K\n$( ls -la )\nsection_end:$( date +%s ):chat_reply\r\033[0K"
```

<a id="run-a-cicd-job-using-chatops"></a>

## 使用 ChatOps 运行 CI/CD 任务

先决条件：

- 你必须拥有该项目的开发者、维护者或所有者角色。
- 项目已配置为使用斜杠命令集成。

你可以从 Slack 或 Mattermost 在默认分支上运行 CI/CD 任务。

运行 CI/CD 任务的斜杠命令取决于为项目配置的斜杠命令集成。

- 对于极狐GitLab for Slack 应用，使用 `/gitlab <project-name> run <任务名称> <参数>`。
- 对于 Slack 或 Mattermost 斜杠命令，使用 `/<触发器名称> run <任务名称> <参数>`。

其中：

- `<任务名称>` 是要运行的 CI/CD 任务名称。
- `<参数>` 是传递给 CI/CD 任务的参数。
- `<触发器名称>` 是为 Slack 或 Mattermost 集成配置的触发器名称。

ChatOps 会安排一个仅包含指定任务的流水线。

<a id="related-topics"></a>

## 相关主题

- [通用 ChatOps 脚本仓库](https://gitlab.com/gitlab-com/chatops)，极狐GitLab 用于与 JihuLab.com 交互
- [极狐GitLab for Slack 应用](../../user/project/integrations/gitlab_slack_application.md)
- [Mattermost 斜杠命令](../../user/project/integrations/mattermost_slash_commands.md)