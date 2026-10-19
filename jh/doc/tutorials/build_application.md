---
stage: Tutorials
group: Tutorials
info: For assistance with this tutorials page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments-to-other-projects-and-subjects>.
description: CI/CD 基础知识和示例。
title: '教程：构建您的应用程序'
---

<a id="learn-about-cicd-pipelines"></a>

## 了解 CI/CD 流水线

使用 CI/CD 流水线自动构建、测试和部署您的代码。

| 主题 | 描述 | 适合初学者 |
|-------|-------------|--------------------|
| [创建并运行您的第一个极狐GitLab CI/CD 流水线](../ci/quick_start/_index.md) | 创建 `.gitlab-ci.yml` 文件并启动流水线。预计用时：15-20 分钟。 | {{< icon name="star" >}} |
| [创建复杂的流水线](../ci/quick_start/tutorial.md) | 通过构建一个日益复杂的流水线，了解最常用的极狐GitLab CI/CD 关键字。预计用时：30-45 分钟。 |  |
| [创建极狐GitLab 流水线以推送到 Google 制品仓库](create_gitlab_pipeline_push_to_google_artifact_registry/_index.md) | 了解如何将极狐GitLab 连接到 Google Cloud，并创建流水线以将镜像推送到制品仓库。预计用时：30-45 分钟。 | |
| [查找 CI/CD 示例](../ci/examples/_index.md)  | 使用这些示例为您的用例设置 CI/CD。 | |
| [使用 Auto DevOps 部署应用程序](../topics/autodevops/cloud_deployments/auto_devops_with_gke.md)  | 将应用程序部署到 Google Kubernetes Engine (GKE)。预计用时：1 小时。 | |
| [在 OpenShift 上使用 GitLab Runner Operator 在无根容器中使用 Buildah](../ci/docker/buildah_rootless_tutorial.md)  | 了解如何在 OpenShift 上设置 GitLab Runner Operator，以在无根容器中使用 Buildah 构建 Docker 镜像。预计用时：30-45 分钟。 | |

<a id="configure-gitlab-runner"></a>

## 配置极狐GitLab Runner

设置 Runner 以在流水线中运行作业。

| 主题 | 描述 | 适合初学者 |
|-------|-------------|--------------------|
| [创建、注册并运行您自己的项目 Runner](create_register_first_runner/_index.md) | 了解如何创建和注册为您的项目运行作业的项目 Runner 的基础知识。预计用时：15-20 分钟。 | {{< icon name="star" >}} |
| [配置极狐GitLab Runner 以使用 Google Kubernetes Engine](configure_gitlab_runner_to_use_gke/_index.md) | 了解如何配置极狐GitLab Runner 以使用 GKE 运行作业。预计用时：30-45 分钟。 | |
| [自动创建和注册 Runner](automate_runner_creation/_index.md) | 了解如何以已认证用户身份自动创建 Runner，以优化您的 Runner 集群。预计用时：15-20 分钟。 | |
| [设置 Google Cloud 集成](set_up_gitlab_google_integration/_index.md) | 了解如何将 Google Cloud 与极狐GitLab 集成，并设置极狐GitLab Runner 以在 Google Cloud 上运行作业。预计用时：30-45 分钟。 | |

<a id="use-mobile-devops-tools"></a>

## 使用 Mobile DevOps 工具

为 Android 和 iOS 构建、签名并发布移动应用。

| 主题 | 描述 | 适合初学者 |
|-------|-------------|--------------------|
| [使用极狐GitLab Mobile DevOps 构建 Android 应用](../ci/mobile_devops/mobile_devops_tutorial_android.md) | 了解如何使用 CI/CD 流水线构建您的 Android 移动应用。预计用时：30-45 分钟。 | |
| [使用极狐GitLab Mobile DevOps 构建 iOS 应用](../ci/mobile_devops/mobile_devops_tutorial_ios.md) | 了解如何使用 CI/CD 流水线构建您的 iOS 移动应用。预计用时：30-45 分钟。 | |
