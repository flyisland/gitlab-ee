---
title: 安全审查 Flow（测试版）
stage: ai-powered
level: primary
tier: [ Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated ]
documentation_link: "../../../user/duo_agent_platform/flows/foundational_flows/security_review/"
work_item: "https://gitlab.com/gitlab-org/gitlab/-/work_items/600477"
categories: [ DAP Code Review ]
---

<!-- DAP Code Review -->

安全审查 Flow 直接在合并请求中检测业务逻辑漏洞。与扫描已知模式的静态分析工具不同，
安全审查 Flow 会推理代码的意图，识别出基于模式的扫描器通常会遗漏的授权绕过、数据泄露和逻辑错误。

如需请求审查，请将 **Duo Security Review** 服务账号指定为合并请求的审查者。该 Flow 分析差异，并将发现结果以线程评论的形式发布在漏洞发生的精确代码行上，每条评论都包含通用弱点枚举（CWE）分类、严重性评级，并在可能的情况下提供内联建议修复，您无需离开合并请求即可应用。
