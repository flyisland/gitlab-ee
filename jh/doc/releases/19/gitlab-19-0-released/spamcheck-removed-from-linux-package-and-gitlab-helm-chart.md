---
title: Spamcheck 已从 Linux 软件包和 GitLab Helm chart 中移除
stage: gitlab_delivery
level: secondary
tier: [ Free, Premium, Ultimate ]
offering: [ self_managed ]
documentation_link: "../../../administration/reporting/spamcheck/"
work_item: "https://gitlab.com/gitlab-org/gitlab/-/work_items/590796"
categories: [ Omnibus Package, Cloud Native Installation ]
weight: 60
---

[Spamcheck](../../../administration/reporting/spamcheck.md) 已从极狐GitLab 19.0 的 Linux 软件包和
GitLab Helm chart 中移除。当前未使用 Spamcheck 的客户不受影响。如果您
使用内置的 Spamcheck，可以使用
[Docker](https://gitlab.com/gitlab-org/gl-security/security-engineering/security-automation/spam/spamcheck) 单独部署。
无需进行数据迁移。
