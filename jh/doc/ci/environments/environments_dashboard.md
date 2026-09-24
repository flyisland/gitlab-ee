---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Monitor environments across multiple projects, including latest commits, pipeline status, and deployment times.
title: 环境仪表盘
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

环境仪表盘提供了一个跨项目的环境视图，让您能够一目了然地了解每个环境的整体状况。在一个集中的位置，您可以跟踪变更从开发到预发布，再到生产（或者您设置的任何自定义环境流程）的进展。通过一目了然地查看多个项目，您可以立即看到哪些流水线是绿色的，哪些是红色的，从而判断问题出在特定环节，还是存在更系统性的问题需要调查。

1. 在顶部栏中，选择 **搜索或跳转到**。
1. 选择 **你的工作**。
1. 选择 **环境**。

![环境仪表盘显示两行项目及其部署环境和流水线状态。](img/environments_dashboard_v18_8.png)

环境仪表盘显示一个分页的项目列表，每个项目最多显示三个环境。

每个项目会显示其已配置的环境。评审应用和其他分组环境不会显示。

<a id="adding-a-project-to-the-dashboard"></a>

### 将项目添加到仪表盘

要将项目添加到仪表盘：

1. 在仪表盘的主界面中选择 **添加项目**。
1. 使用 **搜索您的项目** 字段搜索并添加一个或多个项目。
1. 选择 **添加项目**。

添加后，您可以看到每个项目环境运行状况的摘要，包括最新提交、流水线状态和部署时间。

环境仪表盘和[运维](../../user/operations_dashboard/_index.md)仪表盘共享同一个项目列表。当您在一个仪表盘中添加或删除项目时，极狐GitLab 也会在另一个仪表盘中添加或删除该项目。

您最多可以添加 150 个项目，以便极狐GitLab 在该仪表盘上显示。

<a id="environment-dashboards-on-gitlab.com"></a>

### JihuLab.com 上的环境仪表盘

JihuLab.com 用户可以免费将公开项目添加到环境仪表盘中。如果您的项目是私有的，其所属群组必须拥有[极狐GitLab 专业版](https://gitlab.cn/pricing/)计划。