---
title: "极狐GitLab Duo CLI 中的 /goal 命令"
tier: [ Premium, Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated ]
stage: ai_clients
documentation_link: "../../../user/gitlab_duo_cli/use/#slash-commands"
work_item: https://gitlab.com/groups/gitlab-org/ai-powered/-/work_items/10
categories: [ Duo CLI ]
level: secondary
weight: 50
---

极狐GitLab Duo CLI 现在包含 `/goal` 斜杠命令，可将开放式目标委派给一个受管控、以目标为驱动的任务流，该任务流在本地运行。

您描述一个目标，极狐GitLab Duo 负责实施和验证，并使用独立的评判器来决定您何时达成目标或达到迭代上限。整个过程始终由您掌控：您可以随时暂停、更新目标或重定向 Agent。

`/goal` 斜杠命令需要极狐GitLab 19.3 及更高版本，以及极狐GitLab Duo CLI 9.17.0 及更高版本。

要开始使用，请运行 `/goal <task>`。

例如：

```plaintext
/goal Fix the failing tests in spec/models/user_spec.rb
```
