---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 跨多个项目监控环境，包括最新提交、流水线状态和部署时间。
title: 环境仪表板
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

环境仪表板提供基于环境的跨项目视图，让您能够纵览每个环境中发生的情况。您可以在同一处跟踪变更从开发到预发布，再到生产（或您设置的任意自定义环境流）的进展。通过一目了然地查看多个项目，您可以立即了解哪些流水线是绿色的、哪些是红色的，从而判断某个环节是否存在阻塞，或者是否有更系统性的问题需要调查。

1. 在顶部栏中，选择**搜索或跳转到**。
1. 选择**您的工作**。
1. 选择**环境**。

![环境仪表板显示两行项目及其部署环境和流水线状态。](img/environments_dashboard_v18_8.png)

环境仪表板显示项目的分页列表，每个项目最多包含三个环境。

每个项目显示其已配置的环境。不显示评审应用和其他分组环境。

<a id="adding-a-project-to-the-dashboard"></a>

## 将项目添加到仪表板

要将项目添加到仪表板：

1. 在仪表板的主界面中，选择**添加项目**。
1. 使用**搜索您的项目**字段搜索并添加一个或多个项目。
1. 选择**添加项目**。

添加后，您可以查看每个项目环境运行状况的摘要，包括最新提交、流水线状态和部署时间。

环境仪表板和[运维](../../user/operations_dashboard/_index.md)仪表板共享同一项目列表。当您从其中一个仪表板添加或移除项目时，极狐GitLab 会相应地从另一个仪表板添加或移除该项目。

您最多可以添加 150 个项目供极狐GitLab 在此仪表板上显示。

<a id="environment-dashboards-on-gitlabcom"></a>

## JihuLab.com 上的环境仪表板

JihuLab.com 用户可以免费将公开项目添加到环境仪表板。如果您的项目是私有的，则其所属群组必须拥有 [极狐GitLab 专业版](https://gitlab.cn/pricing)套餐。
