---
stage: Analytics
group: Optimize
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 项目仓库分析
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

仓库分析是[极狐GitLab 基础版](https://jihulab.com/gitlab-cn)的一部分，对有权限克隆仓库的用户可用。

使用仓库分析查看项目 Git 仓库的信息，例如：

- 仓库默认分支中使用的编程语言。
- 过去三个月的代码覆盖率统计。
- 过去一个月的提交统计。
- 每月每天、每周每天以及每小时的提交数量。

## 图表数据处理

图表中的数据排队处理。
后台工作进程会在每次向默认分支提交后 10 分钟更新图表。
根据极狐GitLab 安装规模和后端作业队列的情况，数据刷新可能需要更长时间。

## 查看仓库分析

前提条件：

- 您必须有一个已初始化的 Git 仓库。
- 默认分支（默认为 `main`）中必须至少有一次提交，不包括项目[Wiki](../project/wiki/_index.md#track-wiki-events)中的提交，这些不包含在分析中。

要查看项目的仓库分析：

1. 在顶部栏，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **分析** > **仓库分析**。
1. 要查看某个类别的详细信息，请将鼠标悬停在图表中的条形上。
1. 要查看特定分支的代码覆盖率和提交统计信息，请从 **提交统计信息** 旁边的下拉列表中选择一个分支。