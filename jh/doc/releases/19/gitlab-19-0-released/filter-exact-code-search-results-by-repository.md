---
title: 按代码仓库筛选精确代码搜索结果
stage: ai-powered
level: secondary
tier: [ Premium, Ultimate ]
offering: [ gitlab_com, self_managed ]
documentation_link: "../../../user/search/exact_code_search/#syntax"
work_item: "https://gitlab.com/gitlab-org/gitlab/-/work_items/488467"
categories: [ Global Search ]
weight: 20
---

您现在可以按代码仓库筛选精确代码搜索结果。使用 `repo:` 语法，
您可以直接将搜索查询范围限定到特定代码仓库或代码仓库模式，
无需进入单个项目。

例如，搜索 `def authenticate repo:my-group/my-project` 只会返回
来自该代码仓库的结果。您还可以使用部分路径或模式来匹配多个代码仓库。
