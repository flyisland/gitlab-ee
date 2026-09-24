---
title: 代码审查 Flow 支持更多国内 SOTA 模型
offering: [ gitlab_com, self_managed, gitlab_dedicated ]
tier: [ Premium, Ultimate ]
stage: ai-powered
documentation_link: "../../../user/duo_agent_platform/model_selection/#supported-models"
work_item: https://gitlab.com/gitlab-org/gitlab/-/work_items/598322
categories: [ Duo Agent Platform, Duo Code Review ]
level: secondary
---

在极狐GitLab 的早期版本中，代码审查 Flow 仅支持
原有模型。因合同、政策或采购限制而无法使用原有模型的团队无法运行代码审查 Flow。

现在，您可以选择国内 SOTA 模型 A 或国内 SOTA 模型 B 作为代码审查 Flow 的模型。顶级群组所有者可以在 **设置** > **极狐GitLab Duo** > **配置功能** 下的 **极狐GitLab Duo Agent Platform** 中切换 **Agentic 代码审查** 的模型。
这些国内 SOTA 模型通过极狐GitLab AI Gateway 托管，因此无需额外配置。

两个模型均通过了针对极狐GitLab Duo 代码审查数据集的基准评估，审查质量与默认模型相当。请参阅
[代码审查基准](https://duo-review-bench-6f7260.gitlab.io/) 了解结果。
