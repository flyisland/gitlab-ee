---
title: 基于模式的工具审批，适用于 Agentic Chat
offering: [ gitlab_com, self_managed, gitlab_dedicated]
tier: [ Premium, Ultimate ]
stage: ai-powered
documentation_link: "../../../user/gitlab_duo_chat/agentic_chat/#approve-tools-in-your-local-environment"
work_item: https://gitlab.com/groups/gitlab-org/-/work_items/21850
categories: [ Duo CLI, Chat Engine ]
weight: 50
---

<!-- categories: Duo CLI, Chat Engine -->

> [!warning]
> 此功能已于 2026 年 7 月 10 日[移除](https://gitlab.com/gitlab-org/editor-extensions/gitlab-lsp/-/merge_requests/3699)。

以前，当 Agentic Chat 要求您批准工具调用时，您可以批准一次，或在当前会话中批准使用这些参数的工具调用。不同的参数需要额外的审批。

重复类似命令的工作流（例如一系列 `git` 操作）会迫使您面对一连串几乎相同的提示。

现在，您可以选择第三种审批选项：**批准此工具在会话中的所有使用**。只要参数与已批准的匹配模式一致，此选项即可批准该工具在当前会话剩余时间内的调用。

基于模式的审批适用于极狐GitLab UI 和极狐GitLab Duo CLI 中的 Agentic Chat。
