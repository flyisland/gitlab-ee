---
title: 其他功能增强
tier: [ Free, Premium, Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated ]
stage: verify
co_create: true
documentation_link: "../../../api/job_artifacts/#download-job-artifacts-by-job-id"
work_item: https://gitlab.com/gitlab-org/gitlab/-/merge_requests/252518
categories: [ Job Artifacts ]
level: secondary
---

本版本中的其他改进包括：

- 从 API 获取特定报告产物，仅限可下载类型，并受每个产物的授权检查控制。例如，使用
  `GET /projects/:id/jobs/:job_id/artifacts?file_type=junit` 获取 JUnit 文件。
- 管理员可以让客户端在作业产物和软件包下载时，选择直接 302 重定向或代理传输。
- 流水线编辑器现在会校验后端已支持的 CI/CD 关键字。
- 主题为空的电子邮件现在会创建服务台工单，而不是被退回。
- 通过 `Dependency-Scanning.v2` 模板上的两个新超时输入，自行提高依赖解析限制。
- 管理员可以设置成就显示在个人资料上，而无需每个人接受电子邮件链接。

感谢以下用户做出的这些贡献！

- [Andreas Kunze](https://gitlab.com/and2345)（[合并请求](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/252518)）
- [André Düwel](https://gitlab.com/duewel1982)（[合并请求](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/252350)）
- [Paweł Farys](https://gitlab.com/vertisan)（[合并请求](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/250636)）
- [Praveen Arimbrathodiyil](https://gitlab.com/pravi)（[合并请求](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/248600)）
- [Niklas van Schrick](https://gitlab.com/Taucher2003)（[合并请求](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/249426)）
- [BoxBoxJason](https://gitlab.com/BoxBoxJason)（[合并请求](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/249893)）
