---
title: 配置工作项类型
stage: plan
level: primary
tier: [ Premium, Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated ]
documentation_link: "../../../user/work_items/configurable_work_item_types/"
work_item: "https://gitlab.com/groups/gitlab-org/-/work_items/9365"
categories: [ Team Planning ]
weight: 20
---

此前，工作项类型只能是**议题**或**任务**。现在，您可以在项目中配置自定义工作项类型，以匹配团队规划和跟踪工作的方式。

您可以创建或重命名类型为**用户故事**、**缺陷**或**维护**。每个工作项都会显示其类型名称和唯一图标。新类型支持自定义字段和状态生命周期，并会出现在您的已保存视图和议题看板中。顶级群组（JihuLab.com）或组织（极狐GitLab 私有化部署）中的类型配置会级联到所有项目。

您还可以控制每个项目可用的类型。一次启用或禁用所有项目中的某个类型，或让各个项目自行管理其类型可见性。当您在项目中禁用某个类型时，现有工作项不会受到影响。
