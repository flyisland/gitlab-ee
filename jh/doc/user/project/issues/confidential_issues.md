---
stage: Plan
group: Work Items
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 机密议题
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

机密议题是仅对具有[足够权限](#who-can-see-confidential-issues)的项目成员可见的[议题](_index.md)。开源项目和公司都可以使用机密议题对安全漏洞保密，或防止意外信息泄露。

<a id="make-an-issue-confidential"></a>

## 将议题设为机密

您可以在创建或编辑议题时将其设为机密。

先决条件：

- 您必须对项目具有计划者、报告者、开发者、维护者或所有者角色，才能将现有议题转换为机密议题。
- 如果要设为机密的议题包含任何[任务](../../tasks.md)子项，您必须先将所有子任务设为机密。机密议题只能包含机密的子项。

<a id="in-a-new-issue"></a>

### 在新议题中

创建新议题时，文本区域下方有一个复选框，可用于将议题标记为机密。选中该复选框，然后选择**创建议题**即可创建议题。

当您在项目中创建机密议题时，该项目会列在您的[个人资料](../../profile/_index.md)的**贡献项目**部分中。**贡献项目**不会显示有关机密议题的信息，仅显示项目名称。

要创建机密议题：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在右上角，选择**新建** ({{< icon name="plus" >}})。
1. 从下拉列表中，选择**新建议题**。
1. 填写[字段](create_issues.md#fields-in-the-new-issue-form)。
   - 选中**启用保密**复选框。
1. 选择**创建议题**。

<a id="in-an-existing-issue"></a>

### 在现有议题中

要更改现有议题的保密性：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**计划** > **工作项**，然后按**类型** = **议题**筛选并选择您的议题。
1. 在右上角，选择**议题操作** ({{< icon name="ellipsis_v" >}})，然后选择**启用保密**（或选择**关闭保密**以使议题非机密）。

或者，您可以使用 [`/confidential` 快速操作](../quick_actions.md#confidential)。

<a id="who-can-see-confidential-issues"></a>

## 谁可以查看机密议题

当议题被设为机密时，只有对项目具有计划者、报告者、开发者、维护者或所有者角色的用户才能访问该议题。具有访客或[最小](../../permissions.md#users-with-minimal-access)角色的用户无法访问该议题，即使他们在更改前曾积极参与。

但是，具有**访客角色**的用户可以创建机密议题，但只能查看自己创建的机密议题。

具有访客角色或非项目成员的用户，如果被指派到该机密议题，则可以阅读该议题。当访客用户或非项目成员被取消指派时，他们将无法再查看该机密议题。

对于没有必要权限的用户，机密议题会隐藏在搜索结果中。

<a id="confidential-issue-indicators"></a>

## 机密议题指示符

机密议题在视觉上与普通议题有几处不同。在**议题**和**议题看板**页面中，您可以看到机密 ({{< icon name="eye-slash" >}}) 图标出现在标记为机密的议题旁边。

如果您没有[足够的权限](#who-can-see-confidential-issues)，则完全无法看到机密议题。

同样，在议题内部，您可以在议题编号旁边看到机密 ({{< icon name="eye-slash" >}}) 图标。评论区域也有一个指示符，表明您正在评论的议题是机密的。

侧边栏中也有一个指示符表示保密状态。

从普通议题变为机密议题，或从机密议题变为普通议题的每次更改，都会在议题评论中通过系统评论进行记录，例如：

- {{< icon name="eye-slash" >}} Jo Garcia 在 5 分钟前将该议题设为机密
- {{< icon name="eye" >}} Jo Garcia 刚刚将该议题设为所有人可见

<a id="merge-requests-for-confidential-issues"></a>

## 机密议题的合并请求

虽然您可以在公共项目中创建机密议题（并将现有议题设为机密），但您无法创建机密合并请求。了解如何创建[机密议题的合并请求](../merge_requests/confidential.md)以防止私有数据泄露。
