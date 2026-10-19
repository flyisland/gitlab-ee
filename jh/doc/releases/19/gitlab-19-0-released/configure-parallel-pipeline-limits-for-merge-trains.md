---
title: 为合并列车配置并行流水线限制
stage: verify
level: secondary
tier: [ Premium, Ultimate ]
offering: [ self_managed, gitlab_dedicated ]
documentation_link: "../../../administration/cicd/limits/#merge-train-parallel-pipeline-limit"
work_item: "https://gitlab.com/gitlab-org/gitlab/-/work_items/374188"
categories: [ Continuous Integration (CI) ]
weight: 90
---

在之前的极狐GitLab 版本中，您无法更改合并列车中最多 20 条并行流水线的限制，
这迫使您要么让 Runner 过载，要么完全跳过合并列车。
现在，您可以按合并列车配置并行流水线限制，以平衡 Runner 负载和合并吞吐量。
您可以在项目级别或实例范围内设置该限制。
将限制设置为 1 意味着每个合并请求一次运行一个，并针对干净的目标分支运行。

感谢 [Norman Debald (@Modjo85)](https://gitlab.com/Modjo85) 的这一社区贡献。
