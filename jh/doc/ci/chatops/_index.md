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

使用极狐GitLab ChatOps 通过 Slack 等聊天服务与 CI/CD 作业交互。

许多组织使用 Slack 或 Mattermost 进行协作、排查问题和规划工作。借助 ChatOps，您可以在同一个应用中与团队讨论工作、运行 CI/CD 作业并查看作业输出。

<a id="slash-command-integrations"></a>

## 斜杠命令集成

您可以使用 [`run` 斜杠命令](../../user/project/integrations/gitlab_slack_application.md#slash-commands) 触发 ChatOps。

可用的集成如下：

- [GitLab for Slack 应用](../../user/project/integrations/gitlab_slack_application.md)（推荐用于 Slack）
- [Mattermost 斜杠命令](../../user/project/integrations/mattermost_slash_commands.md)

<a id="chatops-workflow-and-cicd-configuration"></a>

## ChatOps 工作流和 CI/CD 配置

ChatOps 会在项目默认分支的 [`.gitlab-ci.yml`](../yaml/_index.md)中查找指定的作业。如果找到该作业，ChatOps 会创建一个仅包含该指定作业的流水线。如果您设置了 `when: manual`，ChatOps 会创建流水线，但该作业不会自动启动。

使用 ChatOps 运行的作业与从极狐GitLab 运行的作业具有相同的功能。该作业可以使用现有的
[CI/CD 变量](../variables/_index.md#predefined-cicd-variables)（如
`GITLAB_USER_ID`）来执行额外的权限验证，但这些变量可以被[覆盖](../variables/_index.md#cicd-variable-precedence)。

您应设置 [`rules`](../yaml/_index.md#rules)，使该作业不会作为标准 CI/CD 流水线的一部分运行。

ChatOps 会将以下 [CI/CD 变量](../variables/_index.md#predefined-cicd-variables)
传递给该作业：

- `CHAT_INPUT` - 传递给 `run` 斜杠命令的参数。
- `CHAT_CHANNEL` - 运行该作业的聊天频道名称。
- `CHAT_USER_ID` - 运行该作业的用户的聊天服务 ID。

当作业运行时：

- 如果作业在 30 分钟内完成，ChatOps 会将作业输出发送到聊天频道。
- 如果作业完成时间超过 30 分钟，您必须使用
  [Slack API](https://api.slack.com/) 等方法将数据发送到频道。

<a id="exclude-a-job-from-chatops"></a>

### 从 ChatOps 中排除作业

要防止某个作业从聊天中运行：

- 在 `.gitlab-ci.yml`中，将该作业设置为 `except: [chat]`。

<a id="customize-the-chatops-reply"></a>

### 自定义 ChatOps 回复

对于只包含单条命令的作业，ChatOps 会将其输出作为回复发送到频道。例如，当以下作业运行时，聊天回复为 `Hello world`：

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

如果作业包含多条命令，或者设置了 `before_script`，ChatOps 会将这些命令及其输出发送到频道。这些命令会包裹在 ANSI 颜色代码中。

要选择性地只回复某一条命令的输出，请将该输出放在 `chat_reply` 部分中。例如，以下作业会列出当前目录中的文件：

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

## 使用 ChatOps 运行 CI/CD 作业

先决条件：

- 您必须拥有该项目的开发者、维护者或所有者角色。
- 该项目已配置为使用斜杠命令集成。

您可以从 Slack 或 Mattermost 在默认分支上运行 CI/CD 作业。

用于运行 CI/CD 作业的斜杠命令取决于该项目
配置了哪种斜杠命令集成。

- 对于 GitLab for Slack 应用，请使用 `/gitlab <project-name> run <job name> <arguments>`。
- 对于 Slack 或 Mattermost 斜杠命令，请使用 `/<trigger-name> run <job name> <arguments>`。

其中：

- `<job name>` 是要运行的 CI/CD 作业的名称。
- `<arguments>` 是要传递给该 CI/CD 作业的参数。
- `<trigger-name>` 是为 Slack 或 Mattermost 集成配置的触发器名称。

ChatOps 会调度一个仅包含该指定作业的流水线。
