---
title: 禁用内置项目模板
tier: [ Premium, Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated ]
stage: create
documentation_link: "../../../administration/project_templates#built-in-project-templates"
work_item: https://gitlab.com/groups/gitlab-org/-/work_items/21356
categories: [ Source Code Management ]
level: secondary
weight: 50
---

当组织依赖自定义项目模板时，内置供应商模板可能会给模板选择体验增加干扰，并且在某些情况下会绕过服务器端钩子或其他代码仓控制。

管理员现在可以从 **管理员** 区域全局禁用内置项目模板，也可以在群组级别为子群组禁用。该设置会自动级联，因此您无需为每个群组单独配置。
管理员可以强制执行该设置的值，以确保群组或子群组无法覆盖它。
实例和群组设置均可通过 REST 和 GraphQL API 进行管理。
在 JihuLab.com 上，仅提供群组级别的设置。
