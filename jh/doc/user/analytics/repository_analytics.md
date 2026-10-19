---
stage: Analytics
group: Optimize
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 项目的代码仓库分析
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

代码仓库分析是 [GitLab 基础版](https://gitlab.com/gitlab-org/gitlab-foss)的一部分，拥有克隆代码仓库权限的用户均可使用。

使用代码仓库分析可查看项目 Git 代码仓库的相关信息，例如：

- 代码仓库默认分支中使用的编程语言。
- 最近三个月的代码覆盖率统计信息。
- 最近一个月的提交统计信息。
- 按每月日期、星期几和小时统计的提交数量。

<a id="chart-data-processing"></a>

## 图表数据处理

图表中的数据会进入队列。每次向默认分支提交后，后台工作进程会在 10 分钟后更新图表。根据极狐GitLab 安装规模和后台作业队列的情况，数据刷新可能需要更长时间。

<a id="view-repository-analytics"></a>

## 查看代码仓库分析

先决条件：

- 您必须有一个已初始化的 Git 代码仓库。
- 默认分支（默认为 `main`）中必须至少有一次提交，但不包括项目 [wiki](../project/wiki/_index.md#track-wiki-events)中的提交，这些提交不纳入分析。

查看项目的代码仓库分析：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**分析** > **代码仓库分析**。
1. 要查看某个类别的详细信息，请将鼠标悬停在图表中的柱状条上。
1. 要查看特定分支的代码覆盖率和提交统计信息，请从**提交统计信息**旁边的下拉列表中选择一个分支。
