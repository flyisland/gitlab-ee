---
stage: AI Clients
group: Developer Clients
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 极狐GitLab Duo CLI 的选项、命令和环境变量。
title: 极狐GitLab Duo CLI 参考
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

在启动或运行极狐GitLab Duo CLI 时，可以使用这些选项、命令和环境变量。

此列表并不完整。如需完整参考，请参阅
[极狐GitLab Duo CLI 完整参考](https://gitlab.com/gitlab-org/editor-extensions/gitlab-lsp/-/blob/main/packages/cli/docs/cli-reference.md)。

<a id="options"></a>

## 选项

极狐GitLab Duo CLI 支持以下选项：

- `-C, --cwd <path>`：更改工作目录。
- `-h, --help`：显示极狐GitLab Duo CLI 或特定命令的帮助信息。例如，`duo --help` 或
  `duo run --help`。
- `-v`、`--version`：显示版本信息。
- `--model <model>`：选择本次会话使用的 AI 模型。

如需完整的选项列表，请参阅极狐GitLab Duo CLI 完整参考。

<a id="commands"></a>

## 命令

以下命令适用于每种设置：

{{< tabs >}}

{{< tab title="glab" >}}

- `glab duo cli`：启动交互模式。
- `glab duo cli log`：查看和管理日志。
- `glab duo cli run`：启动无头模式。

{{< /tab >}}

{{< tab title="duo" >}}

- `duo`：启动交互模式。
- `duo config`：管理配置和身份验证设置。
- `duo log`：查看和管理日志。
- `duo run`：启动无头模式。

{{< /tab >}}

{{< /tabs >}}

如需完整的命令列表，请参阅极狐GitLab Duo CLI 完整参考。

<a id="environment-variables"></a>

## 环境变量

您可以使用环境变量配置极狐GitLab Duo CLI：

- `DUO_WORKFLOW_GIT_HTTP_PASSWORD`：Git HTTP 身份验证密码。
- `DUO_WORKFLOW_GIT_HTTP_USER`：Git HTTP 身份验证用户名。
- `GITLAB_BASE_URL` 或 `GITLAB_URL`：极狐GitLab 实例 URL。
- `GITLAB_DUO_MODEL`：本次会话使用的 AI 模型。
- `GITLAB_OAUTH_TOKEN` 或 `GITLAB_TOKEN`：身份验证令牌。

当极狐GitLab Duo CLI 代表您运行命令时，它会在该进程中设置 `AI_AGENT` 环境变量。脚本和工具可以读取 `AI_AGENT` 来检测它们是否在 AI 驱动的执行环境中运行。

如需完整的环境变量列表，请参阅极狐GitLab Duo CLI 完整参考。

<a id="terminal-progress-signals"></a>

## 终端进度信号

在交互模式和无头模式下，极狐GitLab Duo CLI 都会通过向 `/dev/tty` 写入操作系统命令（OSC）`9;4` 进度转义序列来报告其状态。支持此序列的终端会在运行极狐GitLab Duo CLI 的标签页或窗口上显示进度指示器。终端复用器和状态工具可以解析相同的序列来检测极狐GitLab Duo CLI 的状态。

极狐GitLab Duo CLI 将每个信号写为 `ESC ] <sequence> ESC \`，其中 `<sequence>` 是以下之一：

| 序列   | 状态         | 描述                                       |
|------------|---------------|---------------------------------------------------|
| `9;4;3`    | 不确定 | 极狐GitLab Duo CLI 正在处理请求。       |
| `9;4;4;50` | 已暂停        | 工具调用正在等待您的批准。         |
| `9;4;0`    | 清除         | 极狐GitLab Duo CLI 处于空闲状态，正在等待输入。 |
| `9;4;2`    | 错误         | 最后一个请求以错误结束。             |

仅当其标准输出连接到终端且 `/dev/tty` 设备可用时，极狐GitLab Duo CLI 才会写入这些信号。由于信号发送到 `/dev/tty` 而不是标准输出，因此它们不会出现在重定向或捕获的输出中。当极狐GitLab Duo CLI 退出时，它会清除进度状态。

当极狐GitLab Duo CLI 在 `tmux` 会话中运行时，它会将这些序列包装在 `tmux` 直通转义序列中。在 `tmux` 3.3 及更高版本中，只有您开启 `allow-passthrough` 选项，这些序列才能到达外部终端。

当会话需要您注意时，极狐GitLab Duo CLI 还可以发送
[系统通知](use.md#system-notifications)。
