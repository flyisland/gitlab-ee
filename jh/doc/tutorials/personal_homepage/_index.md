---
stage: Growth
group: Engagement
info: For assistance with this tutorial, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments-to-other-projects-and-subjects>.
title: 教程：使用个人主页
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 引入于极狐GitLab 18.1 [功能标志](../../administration/feature_flags/_index.md) 名为 `personal_homepage`。默认禁用。
- 在极狐GitLab 18.4 中为部分用户在 JihuLab.com 上启用。
- 在极狐GitLab 18.5 中，在 JihuLab.com 和私有化部署上启用。

{{< /history >}}

<!-- vale gitlab_base.FutureTense = NO -->

个人主页将与你相关的所有信息整合到一个地方。
你可以快速识别需要你关注的新工作项，或从上次中断的地方继续。

按照本教程了解如何浏览主页，并充分利用它。

<a id="before-you-begin"></a>

## 准备工作

将 [个人主页](../../user/profile/preferences.md#choose-your-homepage) 设置为你的偏好设置中的默认主页。

<a id="access-the-homepage"></a>

## 访问主页

你可以从极狐GitLab 的任意位置访问你的个人主页：

- 在左侧边栏顶部，选择 **主页**。
- 在顶部栏，选择 **搜索或跳转到**，然后选择 **你的工作**，再选择 **主页**。

<a id="layout-of-the-homepage"></a>

## 主页布局

在靠近顶部的位置，选择你的头像来设置你的状态。
如果你已经设置了状态，你的头像会显示状态徽章和表情，你可以悬停以查看你的状态文本。

在你的头像下方，查看你参与的合并请求和议题的数量。

**需要你关注的项目** 列表显示极狐GitLab 中所有需要你输入的工作项。

**关注最新动态** 信息流显示你在极狐GitLab 上的活动，以及你感兴趣的特定项目和用户的活动。

转到主页右侧，访问你最近查看过的项目和经常访问的项目的快速链接。

<a id="use-the-homepage-to-start-your-day"></a>

## 使用主页开启你的一天

让我们来了解几种使用主页开始一天工作的方式：

1. 使用 **需要你关注的项目** 列表中的过滤器，查看对你最重要的事件。例如，要查看因流水线失败而被阻塞的合并请求，请从过滤器下拉列表中选择 **构建失败**。
1. 在主页顶部附近，选择 **等待你审核的合并请求**，查看需要你审核的合并请求，以便你解除对其他人的阻塞。

你也可以跟踪你一直在处理的内容，例如：

1. 在 **关注最新动态** 部分，使用 **你的活动** 过滤器查看你最近的工作。选择链接，直接前往议题或合并请求，并从中断处继续。
1. 在右侧的 **快速访问** 小部件中：
   - 选择 **最近查看的** 以查看你最近访问的议题、合并请求和史诗。
   - 选择 **项目** 以查看你经常访问的项目和已加星标的项目。
     - 要按项目类型筛选，请选择 **显示选项** ({{< icon name="preferences" >}})。
   - 选择任意链接，快速返回你正在处理的项目。

<a id="stay-connected-with-team-activity"></a>

## 与团队活动保持联系

如果你在一个项目中协作，为项目加星标以便将来更容易找到。然后，使用主页概览该项目中正在发生的事情。

要为项目加星标并在主页上查看其活动：

1. 在顶部栏，选择 **搜索或跳转到** 并找到你的项目。
1. 在页面右上角，选择 **星标** ({{< icon name="star" >}})。
1. 在左侧边栏顶部，选择 **主页**。
1. 在 **关注最新动态** 部分，从下拉列表中选择 **已加星标的项目**。

为了更有效地与团队协作，你可以关注其他极狐GitLab 用户，查看他们正在做什么：

1. 前往该用户在极狐GitLab 中的个人资料页面，例如 `https://gitlab.example.com/username`，并选择 **关注**。或者，当你在极狐GitLab 中悬停在任何地方的用户名上时，出现的小弹窗中选择 **关注**。
1. 在左侧边栏顶部，选择 **主页**。
1. 在 **关注最新动态** 部分，从下拉列表中选择 **已关注的用户**。

<a id="related-topics"></a>

## 相关主题

了解更多你可以从主页查看和访问的不同工作项。

- [待办事项列表](../../user/todos.md)
- [合并请求](../../user/project/merge_requests/_index.md)
- [议题](../../user/project/issues/_index.md)