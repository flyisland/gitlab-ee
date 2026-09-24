---
stage: Plan
group: Work Items
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用服务台
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以使用服务台 [创建工单](#as-an-end-user-ticket-creator) 或 [回复工单](#as-a-responder-to-the-ticket)。
在这些工单中，您还可以看到我们友好的 [Support Bot](configure.md#support-bot-user)。

<a id="view-service-desk-email-address"></a>

## 查看服务台邮箱地址

要查看项目的服务台邮箱地址：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **监控** > **服务台**。

邮箱地址位于工单列表的顶部。

<a id="as-an-end-user-ticket-creator"></a>

## 作为最终用户（工单创建者）

要创建服务台工单，最终用户无需了解有关极狐GitLab 实例的任何信息。
他们只需向提供的地址发送电子邮件，便会收到来自极狐GitLab Support Bot 的确认回执邮件：

```plaintext
Thank you for your support request! We are tracking your request as ticket `#%{issue_iid}`, and will respond as soon as we can.
```

这封邮件还为最终用户提供了退订选项。

如果他们不选择退订，则工单上添加的任何新评论都会以邮件形式发送给他们。

他们通过电子邮件发送的任何回复都会显示在工单中。

有关更多信息，请参阅 [外部参与者](external_participants.md) 和
[用于处理电子邮件的标头](../../../administration/incoming_email.md#accepted-headers)。

<a id="create-a-service-desk-ticket-in-gitlab-ui"></a>

### 在极狐GitLab UI 中创建服务台工单

先决条件：

- 必须为项目 [设置服务台](configure.md)。
  在极狐GitLab 私有化部署上，这包括 [配置了电子邮件子地址或捕获全部邮箱的传入电子邮件](../../../administration/incoming_email.md#set-it-up)。
  如果没有传入电子邮件，则 `/convert_to_ticket` 快速操作不可用。

要从 UI 创建服务台工单：

1. [创建议题](../issues/create_issues.md)。
1. 添加一条仅包含快速操作 `/convert_to_ticket user@example.com` 的评论。
   您应该会看到来自 [极狐GitLab Support Bot](configure.md#support-bot-user) 的评论。
1. 重新加载页面，以便 UI 反映类型更改。
1. 可选。在工单上添加评论，以向外部参与者发送初始服务台电子邮件。

<!-- Video published on 2024-03-05 -->

<a id="as-a-responder-to-the-ticket"></a>

## 作为工单的回复者

对于工单的回复者，一切工作方式与极狐GitLab 议题相同。
极狐GitLab 会显示一个熟悉的工单跟踪器，回复者可以在其中查看通过客户支持请求创建的工单，并对其进行筛选或交互。

![服务台工单跟踪器](img/service_desk_issue_tracker_v16_10.png)

来自最终用户的消息显示为来自特殊的
[Support Bot 用户](../../../subscriptions/manage_seats.md#criteria-for-non-billable-users)。
您可以像在极狐GitLab 中通常所做的那样阅读和撰写评论：

- 项目的可见性（私有、内部、公开）不影响服务台。
- 项目的路径（包括其群组或命名空间）会显示在电子邮件中。

<a id="view-service-desk-tickets"></a>

### 查看服务台工单

先决条件：

- 您必须拥有项目的报告者、开发者、维护者或所有者角色。

要查看服务台工单：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **监控** > **服务台**。

<a id="redesigned-ticket-list"></a>

#### 重新设计的工单列表

服务台工单列表更接近常规议题列表。
可用功能包括：

- 与 [议题列表](../issues/sorting_issue_lists.md) 相同的排序和排列选项。
- 相同的筛选器，包括 [OR 运算符](#filter-the-list-of-tickets) 和 [按工单 ID 筛选](#filter-tickets-by-id)。

不再提供从服务台工单列表创建新工单的选项。
此决定更好地反映了服务台的性质，即新工单是通过向专用邮箱地址发送电子邮件来创建的。

<a id="filter-the-list-of-tickets"></a>

##### 筛选工单列表

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **监控** > **服务台**。
1. 在工单列表上方，选择 **搜索或筛选结果**。
1. 在出现的下拉列表中，选择要按其筛选的属性。
1. 选择或输入用于筛选属性的运算符。可用的运算符有：
   - `=`：是
   - `!=`：不是其中之一
1. 输入要按其筛选属性的文本。
   您可以通过 **无** 或 **任意** 筛选某些属性。
1. 重复此过程以按多个属性筛选。多个属性通过逻辑 `AND` 连接。

<a id="filter-with-the-or-operator"></a>

##### 使用 OR 运算符筛选

当 [使用 OR 运算符筛选](../issues/managing_issues.md#filter-the-list-of-issues) 已启用时，
您可以在 [筛选工单列表](#filter-the-list-of-tickets) 时使用 **是以下之一：`||`**，按以下条件筛选：

- 指派人
- 标记

`is one of` 表示包含性 OR。例如，如果您按 `Assignee is one of Sidney Jones` 和
`Assignee is one of Zhang Wei` 筛选，极狐GitLab 会显示 `Sidney`、`Zhang` 或两者均为指派人的工单。

<a id="filter-tickets-by-id"></a>

##### 按 ID 筛选工单

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **监控** > **服务台**。
1. 在 **搜索** 框中，输入工单 ID。例如，输入筛选条件 `#10` 以仅返回工单 10。

<a id="email-contents-and-formatting"></a>

## 电子邮件内容和格式

<a id="special-html-formatting-in-html-emails"></a>

### HTML 电子邮件中的特殊 HTML 格式

从服务台工单发送的 HTML 电子邮件会显示 HTML 格式，例如：

- 表格
- 块引用
- 图片
- 可折叠部分

<a id="files-attached-to-comments"></a>

### 评论中附加的文件

如果评论包含任何附件且其总大小小于或等于 10 MB，则这些附件会作为电子邮件的一部分发送。在其他情况下，电子邮件会包含附件的链接。

<a id="convert-a-regular-issue-to-a-service-desk-ticket"></a>

## 将常规议题转换为服务台工单

先决条件：

- 必须为项目 [设置服务台](configure.md)。

使用快速操作 `/convert_to_ticket external-ticket-author@example.com` 将任何常规议题转换为服务台工单。这会将提供的电子邮件地址指定为工单的外部作者，
并将其添加到外部参与者列表中。他们会收到工单上任何公开评论的服务台电子邮件，并可以回复这些电子邮件。回复会在工单上添加新评论。

极狐GitLab 不会发送默认的 [`thank_you` 电子邮件](configure.md#customize-emails-sent-to-external-participants)。
您可以在工单上添加公开评论，让最终用户知道工单已创建。

<a id="privacy-considerations"></a>

## 隐私注意事项

服务台工单是 [机密](../issues/confidential_issues.md) 的，因此只有项目成员可见。项目所有者可以
[将工单设为公开](../issues/confidential_issues.md#in-an-existing-issue)。
当服务台工单变为公开时，工单创建者和参与者的电子邮件地址将对拥有项目报告者、开发者、维护者或所有者角色的已登录用户可见。

您项目中的任何人都可以使用服务台邮箱地址在此项目中创建工单，**无论其在项目中的角色如何**。

唯一的内部邮箱地址对您的极狐GitLab 实例中至少具有计划者角色的项目成员可见。
外部用户（工单创建者）无法看到信息说明中显示的内部邮箱地址。

<a id="moving-a-service-desk-ticket"></a>

### 移动服务台工单

您可以像在极狐GitLab 中 [移动常规议题](../issues/managing_issues.md#move-an-issue) 一样移动服务台工单。

如果将服务台工单移动到启用了服务台的其他项目，
创建工单的客户将继续收到电子邮件通知。
由于移动的工单首先被关闭，然后被复制，因此客户被视为两个工单的参与者。他们会继续收到旧工单和新工单中的任何通知。
