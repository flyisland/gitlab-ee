---
stage: Analytics
group: Optimize
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 了解您未关闭的合并请求在代码评审中花费了多长时间，以及耗时最长的请求有何不同。
title: 代码评审分析
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

代码评审分析会显示一个表格，其中包含至少有一条非作者评论的未关闭合并请求。评审时间是指自非作者在合并请求中发表第一条评论以来经过的时间。

您可以使用代码评审分析查看每个合并请求的评审指标，并改进您的代码评审流程。

- 评论或提交数量较多可能表明：
  - 代码过于复杂。
  - 作者需要更多培训。
- 评审时间较长可能表明：
  - 某些类型的工作比其他类型进展更慢。
  - 有机会加速您的开发周期。
- 评论和审批人较少可能表明团队中可用成员不足。

<a id="view-code-review-analytics"></a>

## 查看代码评审分析

先决条件：

- 您必须具有报告者、开发者、维护者或所有者角色。

要查看代码评审分析：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**分析** > **代码评审分析**。
1. 可选。筛选结果：
   1. 选择筛选栏。
   1. 选择一个参数。您可以按里程碑和标记筛选合并请求。
   1. 为所选参数选择一个值。

表格每页最多显示 20 个处于评审中的合并请求，并包含每个合并请求的以下信息：

- 合并请求标题
- 评审时间
- 作者
- 审批人
- 评论
- 提交
- 行变更
