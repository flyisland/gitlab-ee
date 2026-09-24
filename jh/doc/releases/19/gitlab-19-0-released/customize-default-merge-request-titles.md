---
title: 自定义默认合并请求标题
stage: create
level: secondary
tier: [ Free, Premium, Ultimate ]
offering: [ gitlab_com, self_managed ]
documentation_link: "../../../user/project/merge_requests/title_templates/"
work_item: "https://gitlab.com/gitlab-org/gitlab/-/work_items/16080"
categories: [ Code Review Workflow ]
weight: 100
---

在之前的极狐GitLab 版本中，新合并请求的默认标题来自源分支或首次提交，您无法在项目中强制执行一致的命名约定。

现在，您可以为每个项目配置默认的合并请求标题模板。模板支持源分支、目标分支、首次提交主题、关联议题 ID、议题标题以及源分支名称的人类可读版本等变量。例如，模板
`Resolve %{issue_id} "%{issue_title}"` 生成的标题类似于 `Resolve 123 "Fix login bug"`。
在创建合并请求之前，您仍然可以编辑标题。
