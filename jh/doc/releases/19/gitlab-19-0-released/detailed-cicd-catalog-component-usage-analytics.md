---
title: 详细的 CI/CD Catalog 组件使用情况分析
stage: verify
level: secondary
tier: [ Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated ]
documentation_link: "../../../ci/components/#view-component-usage-details"
work_item: "https://gitlab.com/gitlab-org/gitlab/-/work_items/579460"
categories: [ Component Catalog ]
weight: 80
---

当您在 CI/CD Catalog 中管理 CI/CD 组件时，使用详情对于管理升级、执行合规要求以及传达破坏性变更至关重要。您需要了解哪些项目使用了您的组件，以及它们使用的是哪些版本。此前，这些信息无法获取，因此很难通知正确的维护者、安全地规划弃用，或确保项目始终使用最新的安全补丁。

目录资源页面中的组件使用详情视图现在会显示每个组件具体被哪些项目使用、它们运行的版本，以及它们使用的是最新版本还是过时版本。使用较旧版本的项目会显示在顶部，因此您可以优先开展沟通、推动安全修复的采用，并确保整个组织顺利升级。
