---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab for Slack app 管理
description: "在私有化部署实例上管理、配置和排查极狐GitLab for Slack app。"
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 16.2 中为私有化部署引入。

{{< /history >}}

> [!note]
> 本页面包含极狐GitLab for Slack app 的管理员文档。用户文档请参见[极狐GitLab for Slack app](../../user/project/integrations/gitlab_slack_application.md)。

通过 Slack 应用目录分发的极狐GitLab for Slack app 仅适用于 JihuLab.com。
在私有化部署实例上，你可以从[清单文件](https://api.slack.com/reference/manifests#creating_apps)创建自己的极狐GitLab for Slack app 副本，并配置你的实例。

该应用是一个私密的一次性副本，仅安装在你的 Slack 工作区中，不会通过 Slack 应用目录分发。要在你的私有化部署实例上使用[极狐GitLab for Slack app](../../user/project/integrations/gitlab_slack_application.md)，你必须启用集成。

<a id="create-a-gitlab-for-slack-app"></a>

## 创建极狐GitLab for Slack app

先决条件：

- 你必须至少是 [Slack 工作区管理员](https://slack.com/help/articles/360018112273-Types-of-roles-in-Slack)。

要创建极狐GitLab for Slack app：

- **在极狐GitLab 中**：

  1. 在右上角，选择 **管理员**。
  1. 在左侧边栏中，选择 **设置** > **通用**。
  1. 展开 **极狐GitLab for Slack app**。
  1. 选择 **创建 Slack app**。

随后你将被重定向到 Slack 以进行后续步骤。

- **在 Slack 中**：

  1. 选择要在其中创建应用的工作区，然后选择 **下一步**。
  1. Slack 会显示应用摘要以供审查。要查看完整的清单，请选择 **编辑配置**。要返回审查摘要，请选择 **下一步**。
  1. 选择 **创建**。
  1. 选择 **知道了** 关闭对话框。
  1. 选择 **安装到工作区**。

<a id="configure-the-settings"></a>

## 配置设置

在[创建极狐GitLab for Slack app](#create-a-gitlab-for-slack-app)之后，你可以在极狐GitLab 中配置设置：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **极狐GitLab for Slack app**。
1. 选中 **启用极狐GitLab for Slack app** 复选框。
1. 输入你的极狐GitLab for Slack app 的详细信息：
   1. 前往 [Slack API](https://api.slack.com/apps)。
   1. 搜索并选择 **极狐GitLab（`<your host name>`）**。
   1. 滚动到 **应用凭据**。
1. 选择 **保存更改**。

<a id="install-the-gitlab-for-slack-app"></a>

## 安装极狐GitLab for Slack app

{{< history >}}

- 在极狐GitLab 16.10 中为特定实例[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/391526)，并带有名为 `gitlab_for_slack_app_instance_and_group_level` 的[功能标志](../feature_flags/_index.md)。默认禁用。
- 在极狐GitLab 16.11 中[在 JihuLab.com 和私有化部署上启用](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/147820)。
- 在极狐GitLab 17.8 中[正式发布](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/175803)。功能标志 `gitlab_for_slack_app_instance_and_group_level` 已移除。

{{< /history >}}

先决条件：

- 你必须拥有[向 Slack 工作区添加应用的适当权限](https://slack.com/help/articles/202035138-Add-apps-to-your-Slack-workspace)。
- 你必须[创建极狐GitLab for Slack app](#create-a-gitlab-for-slack-app)并[配置应用设置](#configure-the-settings)。

要从实例设置安装极狐GitLab for Slack app：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **集成**。
1. 选择 **极狐GitLab for Slack app**。
1. 选择 **安装极狐GitLab for Slack app**。
1. 在 Slack 确认页面上，选择 **允许**。

<a id="test-your-configuration"></a>

### 测试你的配置

要测试你的极狐GitLab for Slack app 配置：

1. 在你的 Slack 工作区的频道中输入 `/gitlab help` 斜杠命令。
1. 按下 <kbd>Enter</kbd>。

你应该会看到可用的斜杠命令列表。

要对项目使用斜杠命令，请为该项目配置[极狐GitLab for Slack app](../../user/project/integrations/gitlab_slack_application.md)。

<a id="update-the-gitlab-for-slack-app"></a>

## 更新极狐GitLab for Slack app

先决条件：

- 你必须至少是 [Slack 工作区管理员](https://slack.com/help/articles/360018112273-Types-of-roles-in-Slack)。

当极狐GitLab 为极狐GitLab for Slack app 发布新功能时，你可能需要手动更新你的副本以使用新功能。

要更新你的极狐GitLab for Slack app 副本：

- **在极狐GitLab 中**：
  1. 在右上角，选择 **管理员**。
  1. 在左侧边栏中，选择 **设置** > **通用**。
  1. 展开 **极狐GitLab for Slack app**。
  1. 选择 **下载最新清单文件** 以下载 `slack_manifest.json`。
- **在 Slack 中**：
  1. 前往 [Slack API](https://api.slack.com/apps)。
  1. 搜索并选择 **极狐GitLab（`<your host name>`）**。
  1. 在左侧边栏中，选择 **应用清单**。
  1. 选择 **JSON** 选项卡切换到清单的 JSON 视图。
  1. 复制你从极狐GitLab 下载的 `slack_manifest.json` 文件的内容。
  1. 将内容粘贴到 JSON 查看器中，替换所有现有内容。
  1. 选择 **保存更改**。

<a id="connectivity-requirements"></a>

## 连接要求

要启用极狐GitLab for Slack app 功能，你的网络必须允许极狐GitLab 和 Slack 之间的入站和出站连接。

- 对于 [Slack 通知](../../user/project/integrations/gitlab_slack_application.md#slack-notifications)，极狐GitLab 实例必须能够向 `https://slack.com` 发送请求。
- 对于[斜杠命令](../../user/project/integrations/gitlab_slack_application.md#slash-commands)和其他功能，极狐GitLab 实例必须能够接收来自 `https://slack.com` 的请求。

<a id="enable-support-for-multiple-workspaces"></a>

## 启用多工作区支持

默认情况下，你只能在单个 Slack 工作区中[安装极狐GitLab for Slack app](../../user/project/integrations/gitlab_slack_application.md#install-the-gitlab-for-slack-app)。
管理员在[创建极狐GitLab for Slack app](#create-a-gitlab-for-slack-app)时选择该工作区。

要启用对多个 Slack 工作区的支持，你必须将极狐GitLab for Slack app 配置为[未列出的分布式应用](https://api.slack.com/distribution#unlisted-distributed-apps)。
未列出的分布式应用：

- 不会发布到 Slack 应用目录。
- 只能与你的极狐GitLab 实例一起使用，而不能被其他站点使用。

要将极狐GitLab for Slack app 配置为未列出的分布式应用：

1. 前往 Slack 上的 [**你的应用**](https://api.slack.com/apps) 页面，选择你的极狐GitLab for Slack app。
1. 选择 **管理分发**。
1. 在 **与其他工作区共享你的应用** 部分，展开 **移除硬编码信息**。
1. 选中 **我已检查并移除了所有硬编码信息** 复选框。
1. 选择 **激活公开分发**。

<a id="troubleshooting"></a>

## 故障排查

在管理极狐GitLab for Slack app 时，你可能会遇到以下问题。

用户文档请参见[极狐GitLab for Slack app](../../user/project/integrations/gitlab_slack_app_troubleshooting.md)。

<a id="slash-commands-return-dispatch_failed-in-slack"></a>

### Slash 命令在 Slack 中返回 `dispatch_failed`

斜杠命令可能在 Slack 中返回 `/gitlab failed with the error "dispatch_failed"`。

要解决此问题，请确保：

- 极狐GitLab for Slack app 已正确[配置](#configure-the-settings)并且 **启用极狐GitLab for Slack app** 复选框已选中。
- 你的极狐GitLab 实例[允许与 Slack 之间的请求](#connectivity-requirements)。