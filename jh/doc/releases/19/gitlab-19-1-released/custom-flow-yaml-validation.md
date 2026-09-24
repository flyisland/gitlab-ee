---
title: 自定义 Flow YAML 验证
tier: [ Premium, Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated ]
documentation_link: "../../../user/duo_agent_platform/flows/custom"
work_item: https://gitlab.com/gitlab-org/gitlab/-/work_items/597224
categories: [ AI Catalog ]
stage: ai-powered
level: secondary
weight: 50
---
AI Catalog 现在会在保存或触发自定义 Flow 之前验证其配置。

以前，自定义 Flow 中的语法错误和配置错误的参数（例如，缺少输入或未知的工具参数）只有在 CI 作业启动后的运行时才会暴露出来。这使得调试变得缓慢且困难。

现在，当您在 AI Catalog 中保存或更新自定义 Flow 时，极狐GitLab 会预先检查配置，并直接在 UI 中显示任何错误。有效的 Flow 不受影响，可以像往常一样保存和触发。
