---
title: 所有参与者类型的 Git 操作审计事件
stage: create
level: secondary
tier: [ Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated ]
documentation_link: "../../../administration/compliance/audit_event_reports/"
work_item: "https://gitlab.com/groups/gitlab-org/-/work_items/20506"
categories: [ Source Code Management ]
---

在极狐GitLab 18.10 中，审计日志开始捕获人类用户执行的特定 Git 操作（克隆、拉取、获取或推送）。

在极狐GitLab 19.1 中，此功能扩展至所有参与者类型，包括使用部署令牌的 Runner 和 SSH 证书用户。
审计日志现在能够完整反映您所有代码仓中的 Git 活动，无论由谁或由什么实体发起。
