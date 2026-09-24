---
title: 改进 CI/CD 输入对数组的支持
stage: verify
level: secondary
tier: [ Free, Premium, Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated, gitlab_dedicated_for_government ]
documentation_link: "../../../ci/inputs/#access-individual-array-elements"
work_item: "https://gitlab.com/gitlab-org/gitlab/-/issues/587657"
categories: [ Pipeline Composition ]
weight: 60
---

CI/CD 输入现在改进了对数组的支持。
使用数组索引运算符 `[]` 访问数组输入中的特定元素。
此增强功能为您的流水线配置提供了更灵活、更强大的输入插值能力，
使您无需额外的处理步骤即可直接引用单个数组项。
