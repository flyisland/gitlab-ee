---
title: 强制使用合并列车
tier: [ Premium, Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated, gitlab_dedicated_for_government ]
stage: verify
documentation_link: "../../../ci/pipelines/merge_trains/#enforce-merge-trains"
work_item: https://gitlab.com/gitlab-org/gitlab/-/work_items/597962
categories: [ Merge Trains ]
level: secondary
weight: 10
---

在之前的极狐GitLab 版本中，您无法阻止合并绕过合并列车。立即合并的选项和 REST API 都可以不受限制地跳过合并列车保护。对于运行高速 monorepo 的团队来说，一次合并跳过合并列车就可能取消并重新启动所有进行中的流水线，从而成倍增加 CI 成本并给基础设施带来压力。

现在，您可以通过一个项目级设置，在 UI 和 API 中强制使用合并列车，防止绕过该设置而取消并重新启动进行中的流水线。所有者和管理员在需要时仍可覆盖此设置。
