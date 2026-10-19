---
stage: Tutorials
group: Tutorials
info: For assistance with this tutorials page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments-to-other-projects-and-subjects>.
description: 部署流程和目标。
title: '教程：部署并发布您的应用程序'
---

<a id="manage-packages-and-containers"></a>

## 管理软件包和容器

了解如何使用软件包仓库和容器镜像仓库来管理您的产物。

| 主题 | 描述 | 适合初学者 |
|-------|-------------|--------------------|
| [使用 CI/CD 自动构建并发布软件包](../user/packages/pypi_repository/auto_publish_tutorial.md) | 了解如何自动构建、测试并将 PyPI 软件包发布到软件包仓库。预计用时：15-20 分钟。 | {{< icon name="star" >}} |
| [为满足企业规模需求构建软件包仓库结构](../user/packages/package_registry/enterprise_structure_tutorial.md) | 设置您的组织，以便大规模上传、管理和使用软件包。预计用时：30-45 分钟。 | |
| [使用极狐GitLab CI/CD 构建并签名 Python 软件包](../user/packages/package_registry/pypi_cosign_tutorial.md)  | 了解如何使用极狐GitLab CI/CD 和 Sigstore Cosign 为 Python 软件包构建安全的流水线。预计用时：30-45 分钟。 | |
| [使用构建来源数据为容器镜像添加注解](../user/packages/container_registry/cosign_tutorial.md) | 了解如何使用 Cosign 自动完成构建、签名和注解容器镜像的过程。预计用时：30-45 分钟。 | |
| [将容器镜像从 Amazon ECR 迁移到极狐GitLab](../user/packages/container_registry/migrate_containers_ecr_tutorial.md) | 自动将容器镜像从 Amazon Elastic Container Registry (ECR) 批量迁移到极狐GitLab 容器镜像仓库。预计用时：30-45 分钟。 | |

<a id="publish-a-static-website"></a>

## 发布静态网站

使用 GitLab Pages 直接从您的项目发布静态网站。

| 主题 | 描述 | 适合初学者 |
|-------|-------------|--------------------|
| [从 CI/CD 模板创建 Pages 网站](../user/project/pages/getting_started/pages_ci_cd_template.md) | 使用适用于常用静态站点生成器 (SSG) 的 CI/CD 模板，快速为您的项目生成 Pages 网站。预计用时：5-10 分钟。 | {{< icon name="star" >}} |
| [从零开始创建 Pages 网站](../user/project/pages/getting_started/pages_from_scratch.md) | 从空白项目创建 Pages 网站的所有组件。预计用时：30-45 分钟。 | |
| [使用极狐GitLab 构建、测试并部署您的 Hugo 站点](hugo/_index.md) | 使用 CI/CD 模板和 GitLab Pages 生成您的 Hugo 站点。预计用时：30-45 分钟。 | {{< icon name="star" >}} |
