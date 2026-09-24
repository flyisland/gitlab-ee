---
stage: AI-powered
group: Duo Chat
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: 控制 GitLab Duo Chat 的可用性
---

 GitLab Duo Chat 可以随时开启或关闭，也可以改变可用性。

<a id="for-gitlab-com"></a>

## 针对 JihuLab.com

在极狐GitLab 16.11 及之后的版本， GitLab Duo Chat：

- 已经 GA。
- 任何被分配了 GitLab Duo 席位的用户都可以使用。

如果你[开启或关闭 GitLab Duo](../gitlab_duo/turn_on_off.md)， Chat 也会一同开启或关闭。

<a id="for-gitlab-self-managed"></a>

## 针对私有化部署的极狐GitLab

要在私有化部署的极狐GitLab 实例上使用 GitLab Duo Chat，可以选择以下方式之一：

- 使用极狐GitLab AI 供应商模型和由极狐GitLab 托管的基于云的 AI Gateway（默认选项）。
- [使用 GitLab Duo 私有化部署，自主托管 AI Gateway，并支持私有化部署的 LLM](../../administration/gitlab_duo_self_hosted/_index.md#set-up-a-gitlab-duo-self-hosted-infrastructure)。

前置条件：

-  GitLab Duo 需要极狐GitLab 17.2 或更高版本，以确保最佳用户体验及效果。更早的版本可能还能继续工作，但体验会有所下降。
- 关于订阅：
  - 如果你采用极狐GitLab AI 供应商模型和云端 AI Gateway，则必须拥有与极狐GitLab [同步的](https://gitlab.cn/pricing/licensing-faq/cloud-licensing/)专业版或旗舰版订阅。为确保 GitLab Duo Chat 能立即生效，管理员可以[手动同步你的订阅](#manually-synchronize-your-subscription)。
  - 如果采用 GitLab Duo 私有化部署，需要有旗舰版订阅和 GitLab Duo 企业版附加包。
- 必须[已开启网络连通性](../gitlab_duo/setup.md)。
- [静默模式](../../administration/silent_mode/_index.md)不能被开启。
- 实例中的所有用户都必须安装 IDE 扩展的最新版本。

然后，根据你所使用的极狐GitLab 版本，可以开启 GitLab Duo Chat。

<a id="in-gitlab-16-11-and-later"></a>

### 在极狐GitLab 16.11 及更新版本

在极狐GitLab 16.11 及之后的版本， GitLab Duo Chat：

- 已经 GA。
- 任何被分配了 GitLab Duo 席位的用户都可以使用。

<a id="in-earlier-gitlab-versions"></a>

### 早期极狐GitLab 版本

在极狐GitLab 16.8、16.9 和 16.10 版本中， GitLab Duo Chat 以 beta 形式提供。要在私有化部署的极狐GitLab 中启用 GitLab Duo Chat，**管理员**需要开启实验和 Beta 功能：

1. 在左侧侧边栏底部，选择 **管理员**。
1. 选择 **设置** > **通用**。
1. 展开 **AI 原生功能**，勾选 **启用实验和 Beta AI 原生功能**。
1. 选择 **保存修改**。
1. 为确保 GitLab Duo Chat 能立即生效，你需要[手动同步你的订阅](#manually-synchronize-your-subscription)。

{{< alert type="note" >}}

使用 GitLab Duo Chat beta 受 [极狐GitLab 测试协议](https://handbook.gitlab.com/handbook/legal/testing-agreement/)约束。了解[使用 GitLab Duo Chat 时的数据使用情况](../gitlab_duo/data_usage.md)。

{{< /alert >}}

<a id="manually-synchronize-your-subscription"></a>

### 手动同步你的订阅

你可以在以下情况下[手动同步你的订阅](../../subscriptions/manage_subscription.md#manually-synchronize-subscription-data)：

- 你刚刚购买了专业版或旗舰版层级的订阅，或最近为 GitLab Duo Pro 分配了席位，并升级到了极狐GitLab 16.8。
- 你已拥有专业版或旗舰版层级的订阅，或最近为 GitLab Duo Pro 分配了席位，并升级到了极狐GitLab 16.8。

如果未进行手动同步，可能需要最多 24 小时才能在你的实例上激活 GitLab Duo Chat。

## 关闭 GitLab Duo Chat

为了限制 GitLab Duo Chat 可以访问的数据，请按照[关闭 GitLab Duo 功能的说明](../gitlab_duo/turn_on_off.md)操作。

<a id="turn-off-chat-in-vs-code"></a>

## 在 VS Code 中关闭 Chat

要在 VS Code 中关闭 GitLab Duo Chat：

1. 前往 **设置** > **扩展** > **极狐GitLab Workflow**。
1. 去掉 **启用 GitLab Duo Chat 助手** 的勾选框。


