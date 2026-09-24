---
title: 易受攻击依赖项的自动修复（实验）
stage: software_supply_chain_security
level: secondary
tier: [ Ultimate ]
offering: [ gitlab_com ]
documentation_link: "../../../user/application_security/remediate/auto_remediation/"
work_item: "https://gitlab.com/groups/gitlab-org/-/work_items/17403"
categories: [ Software Composition Analysis ]
weight: 10
---

依赖项的自动修复现已在极狐GitLab 19.0 中作为实验功能推出。当依赖扫描检测到存在已知修复的易受攻击的 Ruby 依赖项时，极狐GitLab 会自动打开一个合并请求，将其更新到安全版本，无需人工干预。该实验目前仅支持 Ruby 项目。

每次流水线运行后，极狐GitLab 会识别出具有可用补丁或次要版本升级的最高严重性漏洞。极狐GitLab 会生成清单文件更改，并通过服务账号打开一个合并请求。该合并请求随后会进入您项目的标准评审和审批流程。

在实验期间，每个项目最多可同时打开三个自动修复合并请求。

如需分享反馈或申请试用该实验，请在 [史诗 600511](https://gitlab.com/gitlab-org/gitlab/-/work_items/600511) 上发表评论。
要在您的项目上启用该实验，需要由 GitLab 团队成员为您的项目启用 `dependency_management_auto_remediation` 功能标志。
