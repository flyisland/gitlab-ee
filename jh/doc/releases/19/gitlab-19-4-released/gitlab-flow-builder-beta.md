---
title: 用于自定义任务流的极狐GitLab 任务流构建器（测试版）
tier: [ Free, Premium, Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated ]
stage: ai_clients
documentation_link: "../../../user/duo_agent_platform/flows/custom/#create-a-flow"
work_item: https://gitlab.com/groups/gitlab-org/editor-extensions/-/work_items/236
categories: [ AI Catalog Creation ]
level: secondary
weight: 50
---

使用极狐GitLab 任务流构建器为您的极狐GitLab 项目构建自定义任务流。任务流构建器是一款全新的可视化编辑器，用于在 GitLab for VS Code 扩展中创建 AI 原生工作流。您可以通过组件（Agent、自定义工具和 AI 任务）以可视化方式组合任务流，也可以直接编辑底层的 YAML。

首先，在 VS Code 中打开任务流的 YAML 文件，然后选择**打开极狐GitLab 任务流构建器**。
使用**运行**按钮测试任务流，该按钮会打开执行控制台。任务流准备就绪后，选择**发布**将其发布到 AI 目录。

任务流构建器在 GitLab for VS Code 6.87.0 及更高版本中以测试版功能提供。要开始使用，请在 VS Code 中启用 `gitlab.featureFlags.flowBuilder` 设置。
