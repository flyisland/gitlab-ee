---
stage: Plan
group: Work Items
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: GitLab for Slack 应用管理
description: "在极狐GitLab 私有化部署实例上管理、配置 GitLab for Slack 应用并对其进行故障排除。"
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

> [!note]
> 有关用户文档，请参阅 [GitLab for Slack 应用](../../user/project/integrations/gitlab_slack_application.md)。

通过 Slack App Directory 分发的 GitLab for Slack 应用仅适用于 JihuLab.com。
在极狐GitLab 私有化部署上，您可以从[清单文件](https://api.slack.com/reference/manifests#creating_apps)创建自己的 GitLab for Slack 应用副本，并配置您的实例。

该应用是仅在您的 Slack 工作区中安装的私有一次性副本，不通过 Slack App Directory 分发。要在您的极狐GitLab 私有化部署实例上使用 [GitLab for Slack 应用](../../user/project/integrations/gitlab_slack_application.md)，您必须开启该集成。

<a id="create-a-gitlab-for-slack-app"></a>

## 创建 GitLab for Slack 应用

先决条件：

- 您必须至少是 [Slack 工作区管理员](https://slack.com/help/articles/360018112273-Types-of-roles-in-Slack)。

要创建 GitLab for Slack 应用：

- **在极狐GitLab 中**：

  1. 在右上角，选择**管理员**。
  1. 在左侧边栏中，选择**设置** > **通用**。
  1. 展开 **GitLab for Slack 应用**。
  1. 选择**创建 Slack 应用**。

随后您将被重定向到 Slack 以进行后续步骤。

- **在 Slack 中**：

  1. 选择要在其中创建应用的 Slack 工作区，然后选择**下一步**。
  1. Slack 会显示应用摘要供您审阅。要查看完整清单，请选择**编辑配置**。要返回审阅摘要，请选择**下一步**。
  1. 选择**创建**。
  1. 选择**知道了**以关闭对话框。
  1. 选择**安装到工作区**。

<a id="configure-the-settings"></a>

## 配置设置

在您[创建 GitLab for Slack 应用](#create-a-gitlab-for-slack-app)后，您可以在极狐GitLab 中配置设置：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开 **GitLab for Slack 应用**。
1. 选中**启用 GitLab for Slack 应用**复选框。
1. 输入您的 GitLab for Slack 应用的详细信息：
   1. 转到 [Slack API](https://api.slack.com/apps)。
   1. 搜索并选择 **GitLab (`<your host name>`)**。
   1. 滚动到**应用凭证**。
1. 选择**保存更改**。

<a id="install-the-gitlab-for-slack-app"></a>

## 安装 GitLab for Slack 应用

先决条件：

- 您必须拥有[向 Slack 工作区添加应用的相应权限](https://slack.com/help/articles/202035138-Add-apps-to-your-Slack-workspace)。
- 您必须[创建 GitLab for Slack 应用](#create-a-gitlab-for-slack-app)并[配置应用设置](#configure-the-settings)。

要从实例设置中安装 GitLab for Slack 应用：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **集成**。
1. 选择 **GitLab for Slack 应用**。
1. 选择**安装 GitLab for Slack 应用**。
1. 在 Slack 确认页面上，选择**允许**。

<a id="test-your-configuration"></a>

### 测试您的配置

要测试您的 GitLab for Slack 应用配置：

1. 在您的 Slack 工作区的频道中输入 `/gitlab help` 斜杠命令。
1. 按 <kbd>Enter</kbd>。

您应该会看到可用斜杠命令的列表。

要针对项目使用斜杠命令，请为该项目配置 [GitLab for Slack 应用](../../user/project/integrations/gitlab_slack_application.md)。

<a id="update-the-gitlab-for-slack-app"></a>

## 更新 GitLab for Slack 应用

先决条件：

- 您必须至少是 [Slack 工作区管理员](https://slack.com/help/articles/360018112273-Types-of-roles-in-Slack)。

当极狐GitLab 为 GitLab for Slack 应用发布新功能时，您可能需要手动更新您的副本才能使用这些新功能。

要更新您的 GitLab for Slack 应用副本：

- **在极狐GitLab 中**：
  1. 在右上角，选择**管理员**。
  1. 在左侧边栏中，选择**设置** > **通用**。
  1. 展开 **GitLab for Slack 应用**。
  1. 选择**下载最新清单文件**以下载 `slack_manifest.json`。
- **在 Slack 中**：
  1. 转到 [Slack API](https://api.slack.com/apps)。
  1. 搜索并选择 **GitLab (`<your host name>`)**。
  1. 在左侧边栏中，选择**应用清单**。
  1. 选择 **JSON** 标签页以切换到清单的 JSON 视图。
  1. 复制您从极狐GitLab 下载的 `slack_manifest.json` 文件的内容。
  1. 将内容粘贴到 JSON 查看器中，以替换任何现有内容。
  1. 选择**保存更改**。

<a id="connectivity-requirements"></a>

## 连接要求

要开启 GitLab for Slack 应用功能，您的网络必须允许极狐GitLab 与 Slack 之间的入站和出站连接。

- 对于 [Slack 通知](../../user/project/integrations/gitlab_slack_application.md#slack-notifications)，必须允许极狐GitLab 实例向 `https://slack.com` 发送请求。
- 对于[斜杠命令](../../user/project/integrations/gitlab_slack_application.md#slash-commands)和其他功能，必须允许极狐GitLab 实例接收来自 `https://slack.com`的请求。

<a id="enable-support-for-multiple-workspaces"></a>

## 启用对多个工作区的支持

默认情况下，您只能在一个 Slack 工作区中[安装 GitLab for Slack 应用](../../user/project/integrations/gitlab_slack_application.md#install-the-gitlab-for-slack-app)。管理员在[创建 GitLab for Slack 应用](#create-a-gitlab-for-slack-app)时选择该工作区。

要开启对多个 Slack 工作区的支持，您必须将 GitLab for Slack 应用配置为[未列出的分发应用](https://api.slack.com/distribution#unlisted-distributed-apps)。未列出的分发应用：

- 不会发布在 Slack App Directory 中。
- 只能与您的极狐GitLab 实例一起使用，其他站点无法使用。

要将 GitLab for Slack 应用配置为未列出的分发应用：

1. 转到 Slack 上的[**您的应用**](https://api.slack.com/apps)页面，并选择您的 GitLab for Slack 应用。
1. 选择**管理分发**。
1. 在**与其他工作区共享您的应用**部分，展开**移除硬编码信息**。
1. 选中**我已审阅并移除了任何硬编码信息**复选框。
1. 选择**激活公开分发**。

<a id="troubleshooting"></a>

## 故障排除

在管理 GitLab for Slack 应用时，您可能会遇到以下问题。

<a id="slash-commands-return-dispatch_failed-in-slack"></a>

### 斜杠命令在 Slack 中返回 `dispatch_failed`

斜杠命令可能会在 Slack 中返回 `/gitlab failed with the error "dispatch_failed"`。

要解决此问题，请确保：

- GitLab for Slack 应用已正确[配置](#configure-the-settings)，并且已选中**启用 GitLab for Slack 应用**复选框。
- 您的极狐GitLab 实例[允许与 Slack 之间的请求](#connectivity-requirements)。
