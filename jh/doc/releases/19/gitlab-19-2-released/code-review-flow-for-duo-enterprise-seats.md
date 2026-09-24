---
title: 极狐GitLab Duo Enterprise 席位的代码审查 Flow
offering: [ gitlab_com, self_managed, gitlab_dedicated ]
tier: [ Premium, Ultimate ]
stage: ai_coding
documentation_link: "../../../user/project/merge_requests/duo_in_merge_requests/#turn-on-code-review-flow-for-gitlab-duo-enterprise-seats"
work_item: https://gitlab.com/groups/gitlab-org/-/work_items/22247
categories: [ DAP Code Review ]
---

在之前的极狐GitLab 版本中，当拥有极狐GitLab Duo Enterprise 席位的用户向极狐GitLab Duo 请求代码审查时，极狐GitLab Duo 代码审查会完成该审查。
即使已为群组开启代码审查 Flow，这种情况也会发生。无法为所有用户启用 Agentic Flow。

现在，顶级群组的所有者可以更改此默认设置，并将所有代码审查配置为改用代码审查 Flow，
无论用户拥有何种席位。

此项更改使拥有极狐GitLab Duo Enterprise 席位的用户能够获得与其他所有人相同的代码仓级上下文感知、多步骤推理和审查会话。
