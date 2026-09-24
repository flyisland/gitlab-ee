---
stage: none
group: Tutorials
info: For assistance with this tutorials page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments-to-other-projects-and-subjects>.
description: CI/CD fundamentals and examples.
title: '教程：构建你的应用程序'
---

<a id="learn-about-ci-cd-pipelines"></a>

## 了解 CI/CD 流水线

使用 CI/CD 流水线自动构建、测试和部署你的代码。

| 主题 | 描述 | 适合初学者 |
|-------|-------------|--------------------|
| [创建并运行你的第一个 极狐GitLab CI/CD 流水线](../ci/quick_start/_index.md) | 创建一个 `.gitlab-ci.yml` 文件并启动流水线。 | {{< icon name="star" >}} |
| [创建复杂流水线](../ci/quick_start/tutorial.md) | 通过构建一个逐渐复杂的流水线来学习最常用的 极狐GitLab CI/CD 关键词。 |  |
| [极狐GitLab CI 基础](https://university.gitlab.com/learn/learning-path/gitlab-ci-fundamentals) | 在这个自定进度的课程中学习 极狐GitLab CI/CD 并构建流水线。 | {{< icon name="star" >}} |
| [查找 CI/CD 示例](../ci/examples/_index.md)  | 使用这些示例为你的用例设置 CI/CD。 | |
| [在 OpenShift 上使用 Buildah 和 极狐GitLab Runner Operator 构建无根容器](../ci/docker/buildah_rootless_tutorial.md)  | 学习如何在 OpenShift 上设置 极狐GitLab Runner Operator，使用 Buildah 在无根容器中构建 Docker 镜像 | |

<a id="configure-gitlab-runner"></a>

## 配置 极狐GitLab Runner

设置 Runner 以在流水线中运行作业。

| 主题 | 描述 | 适合初学者 |
|-------|-------------|--------------------|
| [创建、注册并运行你自己的项目 Runner](create_register_first_runner/_index.md) | 学习如何创建和注册一个为你的项目运行作业的项目 Runner 的基础知识。 | {{< icon name="star" >}} |
| [自动创建和注册 Runner](automate_runner_creation/_index.md) | 学习如何作为经过身份验证的用户自动创建 Runner，以优化你的 Runner 机群。  | |

<a id="use-mobile-devops-tools"></a>

## 使用 Mobile DevOps 工具

为 Android 和 iOS 构建、签名并发布移动应用。

| 主题 | 描述 | 适合初学者 |
|-------|-------------|--------------------|
| [使用 极狐GitLab Mobile DevOps 构建 Android 应用](../ci/mobile_devops/mobile_devops_tutorial_android.md) | 学习如何使用 CI/CD 流水线构建你的 Android 移动应用。 | |
| [使用 极狐GitLab Mobile DevOps 构建 iOS 应用](../ci/mobile_devops/mobile_devops_tutorial_ios.md) | 学习如何使用 CI/CD 流水线构建你的 iOS 移动应用。 | |