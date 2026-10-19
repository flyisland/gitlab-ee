---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用 Auto DevOps 部署到 Amazon ECS
---

您可以选择以 AWS ECS 作为部署目标平台，而不使用 Kubernetes。

要开始使用 Auto DevOps 部署到 AWS ECS，您必须添加一个特定的 CI/CD 变量。为此，请按照以下步骤操作：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开 **Auto DevOps**。
1. 通过添加 `AUTO_DEVOPS_PLATFORM_TARGET` 变量并为其指定以下值之一，
   来指定 Auto DevOps 部署期间要以哪个 AWS 平台为目标：
   - 如果您要部署的服务必须为 FARGATE 启动类型，则使用 `FARGATE`。
   - 如果您在部署到 ECS 时不强制进行任何启动类型检查，则使用 `ECS`。

当您触发流水线时，如果您已启用 Auto DevOps，并且已正确[将 AWS 凭证作为变量输入](../../../ci/cloud_deployment/_index.md#authenticate-gitlab-with-aws)，您的应用程序将部署到 AWS ECS。

如果您同时拥有有效的 `AUTO_DEVOPS_PLATFORM_TARGET` 变量和与项目关联的 Kubernetes 集群，
则只有部署到 Kubernetes 的作业会运行。

> [!warning]
> 将 `AUTO_DEVOPS_PLATFORM_TARGET` 变量设置为 `ECS` 会触发
> [`Jobs/Deploy/ECS.gitlab-ci.yml` 模板](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Jobs/Deploy/ECS.gitlab-ci.yml)中定义的作业。
> 但是，不建议单独[包含](../../../ci/yaml/_index.md#includetemplate)
> 该模板。此模板设计为仅与 Auto DevOps 一起使用。如果单独包含，它可能会
> 意外更改，导致您的流水线失败。此外，该模板中的作业
> 名称也可能会更改。请勿在您自己的流水线中覆盖这些作业的名称，
> 因为名称更改后覆盖将不再生效。
