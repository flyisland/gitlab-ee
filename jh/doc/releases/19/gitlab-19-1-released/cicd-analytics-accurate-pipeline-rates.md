---
title: CI/CD 分析现在显示准确的流水线率
tier: [ Premium, Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated ]
stage: verify
documentation_link: "../../../user/analytics/ci_cd_analytics"
work_item: https://gitlab.com/gitlab-org/gitlab/-/work_items/599923
categories: [ Continuous Integration (CI) ]
level: secondary
---

在之前的极狐GitLab 版本中，CI/CD 分析页面（`<project>/-/pipelines/charts`）上的失败率和成功率指标在计算中包含了已取消和已跳过的流水线。这导致这两个比率看起来都低于预期。例如，在 `gitlab-org/gitlab` 上，两个比率之和仅为 98%，而不是接近 100%。

现在，极狐GitLab 仅使用已完成的流水线来计算失败率和成功率，因此结果能准确反映您的流水线健康状况。
