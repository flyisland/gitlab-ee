---
title: 重新设计的代码仓提交列表
stage: create
level: secondary
tier: [ Free, Premium, Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated ]
documentation_link: "../../../user/project/repository/commits/"
work_item: "https://gitlab.com/groups/gitlab-org/-/work_items/17482"
categories: [ Source Code Management ]
---

此前，代码仓提交列表的筛选功能有限，导致在较长的历史记录中难以找到特定提交。

重新设计的提交列表包含以下功能：

- 按作者、提交消息或日期范围筛选和搜索提交。
- 按 Git 修订版本（例如分支、标签或提交 SHA）筛选列表。
- 提交按日分组，便于快速浏览。
- 针对大型代码仓改进了性能和分页。
