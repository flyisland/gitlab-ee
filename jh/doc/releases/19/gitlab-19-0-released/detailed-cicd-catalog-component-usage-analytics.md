---
title: 详细的 CI/CD 目录组件使用情况分析
stage: verify
level: secondary
tier: [ Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated ]
documentation_link: "../../../ci/components/#view-component-usage-details"
work_item: "https://gitlab.com/gitlab-org/gitlab/-/work_items/579460"
categories: [ Component Catalog ]
weight: 80
---

当您在 CI/CD 目录中管理 CI/CD 组件时，使用详情对于管理升级、执行合规性以及沟通破坏性变更至关重要。您需要知道哪些项目使用了您的组件，以及它们正在使用哪些版本。此前，这些信息不可用，导致难以通知正确的维护者、安全地规划弃用，或确保项目始终使用最新的安全补丁。

目录资源页面中的组件使用详情视图现在会准确显示哪些项目使用了每个组件、它们运行的版本，以及它们是否处于最新版本或已过时。使用旧版本的项目会显示在顶部，以便您优先进行沟通、推动安全修复的采用，并确保整个组织内实现顺畅的升级路径。
