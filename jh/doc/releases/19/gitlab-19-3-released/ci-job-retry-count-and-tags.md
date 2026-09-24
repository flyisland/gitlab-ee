---
title: "两个新的 CI/CD 变量：重试次数和作业标签"
tier: [ Free, Premium, Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated, gitlab_dedicated_for_government ]
stage: verify
co_create: true
documentation_link: "../../../ci/variables/predefined_variables/"
work_item: https://gitlab.com/gitlab-org/gitlab/-/merge_requests/?sort=created_date&state=merged&milestone_title=19.3&label_name%5B%5D=Community%20contribution&label_name%5B%5D=release%20post%20item&label_name%5B%5D=group%3A%3Apipeline%20authoring
categories: [ Pipeline Composition ]
level: secondary
---

您的流水线脚本现在可以判断它们是否首次运行。
`CI_JOB_RETRY_COUNT` 保存当前作业已被重试的次数，在首次运行时为 `0`，
因此感知重试的逻辑不再需要您自行跟踪状态。另外，
`CI_JOB_TAGS` 会公开作业自身配置的标签，而此前只能通过 `CI_RUNNER_TAGS` 查看 Runner 的标签。两者均无需配置即可使用。

感谢 [Giannis Kepas](https://gitlab.com/gkepas) 和
[Dwight Blake](https://gitlab.com/lunivilen) 的贡献！
