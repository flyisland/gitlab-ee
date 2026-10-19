---
stage: AI Clients
group: Developer Clients
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 将极狐GitLab Duo Agent Platform 带入终端的命令行界面工具。
title: 极狐GitLab Duo CLI（`duo`）
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< collapsible title="模型信息" >}}

- [默认 LLM](../duo_agent_platform/model_selection.md#default-models)
- 适用于[自部署模型的极狐GitLab Duo](../../administration/gitlab_duo_self_hosted/_index.md)

{{< /collapsible >}}

极狐GitLab Duo CLI 是一款命令行界面工具，可将 [极狐GitLab Duo Agentic Chat](../gitlab_duo_chat/agentic_chat.md)
带入您的终端。它适用于任何操作系统和编辑器，您可以使用该 CLI 询问有关代码库的复杂问题，并让它代表您自主执行操作。

极狐GitLab Duo CLI 可以帮助您：

- 理解代码库结构、跨文件功能以及单个代码片段。
- 构建、修改、重构和现代化代码。
- 排查错误并修复代码问题。
- 自动化 CI/CD 配置、排查流水线错误并优化流水线。
- 自主执行多步骤开发任务。

> [!note]
> 极狐GitLab Duo CLI 现已正式发布。请更新至
> 极狐GitLab Duo CLI 9.0.0 或更高版本，以获得完整的正式发布体验。

您可以通过 [GitLab CLI](https://gitlab.cn/docs/cli/)（`glab`）使用极狐GitLab Duo CLI，
也可以将极狐GitLab Duo CLI（`duo`）作为独立的 AI 工具安装和使用。

极狐GitLab Duo CLI 提供两种模式：

- 交互模式：提供类似于极狐GitLab UI 或编辑器扩展中极狐GitLab Duo Chat 的聊天体验。支持构建模式和计划模式。
- 无头模式：支持在 runner、脚本和其他自动化工作流中进行非交互式使用。

它还支持为极狐GitLab Duo Agent Platform 设置的[自定义指令](../duo_agent_platform/customize/_index.md)，
包括 `chat-rules.md`、`AGENTS.md` 和 `SKILL.md` 文件。

<a id="get-started"></a>

## 开始使用

1. [安装并设置](set_up.md)极狐GitLab Duo CLI。
1. 以交互模式或无头模式[使用](use.md)极狐GitLab Duo CLI。
1. [自定义](customize.md)极狐GitLab Duo CLI，以更好地适应您的工作流或用例。
1. 查看[参考文档](reference.md)，了解有关如何使用极狐GitLab Duo CLI 的更多信息。

<a id="manage-gitlab-duo-cli-access"></a>

## 管理极狐GitLab Duo CLI 访问权限

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

默认情况下，极狐GitLab Duo CLI 访问权限处于开启状态。

在极狐GitLab 私有化部署上，您可以为实例开启或关闭极狐GitLab Duo CLI 访问权限。

先决条件：

- 您必须是管理员。

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择 **极狐GitLab Duo**。
1. 选择**更改配置**。
1. 在 **极狐GitLab Duo CLI** 下，选中或清除**开启极狐GitLab Duo CLI 访问权限**复选框。
1. 选择**保存更改**。

<a id="update-the-gitlab-duo-cli"></a>

## 更新极狐GitLab Duo CLI

如需首次安装极狐GitLab Duo CLI，请参阅[设置](set_up.md)。

如需手动将极狐GitLab Duo CLI 更新到最新版本，请根据您的设置运行相应命令：

{{< tabs >}}

{{< tab title="glab" >}}

```shell
glab duo cli --update
```

{{< /tab >}}

{{< tab title="duo" >}}

如需更新编译后的二进制文件，请再次运行安装脚本。

在 macOS 和 Linux 上：

```shell
bash <(curl --fail --silent --show-error --location "https://gitlab.com/gitlab-org/editor-extensions/gitlab-lsp/-/raw/main/packages/cli/app/scripts/install_duo_cli.sh")
```

在 Windows 上：

```shell
irm "https://gitlab.com/gitlab-org/editor-extensions/gitlab-lsp/-/raw/main/packages/cli/app/scripts/install_duo_cli.ps1" | iex
```

如果您之前通过 npm 安装了极狐GitLab Duo CLI，它将不再接收更新。

如需获取 CLI 的最新版本，请使用 `npm uninstall --global @gitlab/duo-cli` 卸载 npm 软件包，
然后运行前面的脚本以改为安装编译后的二进制文件。

{{< /tab >}}

{{< /tabs >}}

<a id="contribute-to-the-gitlab-duo-cli"></a>

## 为极狐GitLab Duo CLI 贡献

有关为极狐GitLab Duo CLI 贡献的信息，请参阅
[开发指南](https://gitlab.com/gitlab-org/editor-extensions/gitlab-lsp/-/blob/main/packages/cli/app/docs/development.md)。
