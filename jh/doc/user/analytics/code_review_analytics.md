---
stage: Analytics
group: Optimize
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.jihulab.com/handbook/product/ux/technical-writing/#assignments>
description: Learn how long your open merge requests have spent in code review, and what distinguishes the longest-running.
title: 代码审查分析
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在 13.9 中移至 极狐GitLab 专业版。

{{< /history >}}

代码审查分析展示一个包含至少一条非作者评论的开放合并请求表格。审查时间是指自合并请求中第一条非作者评论以来的时间。

你可以使用代码审查分析查看每个合并请求的审查指标，并改进你的代码审查流程。

- 大量评论或提交可能表明：
  - 代码过于复杂。
  - 作者需要更多培训。
- 较长的审查时间可能表明：
  - 某些类型的工作比其他类型进展慢。
  - 有机会加速你的开发周期。
- 评论和审批者数量少可能表明缺少可用的团队成员。

<a id="view-code-review-analytics"></a>

## 查看代码审查分析

先决条件：

- 你必须具有报告者、开发者、维护者或所有者的角色。

要查看代码审查分析：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **分析** > **代码审查分析**。
1. 可选。筛选结果：
   1. 选择筛选栏。
   1. 选择一个参数。你可以按里程碑和标签筛选合并请求。
   1. 为所选参数选择一个值。

该表格每页最多显示 20 个处于审查中的合并请求，并包含每个合并请求的以下信息：

- 合并请求标题
- 审查时间
- 作者
- 审批者
- 评论
- 提交
- 更改行数