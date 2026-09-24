```markdown
---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用 Auto DevOps 部署到 Amazon ECS
---

您可以选择将 AWS ECS 作为部署平台，而不是使用 Kubernetes。

要开始使用 Auto DevOps 部署到 AWS ECS，您必须添加一个特定的 CI/CD 变量。
请按照以下步骤操作：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **CI/CD**。
1. 展开 **自动 DevOps**。
1. 通过添加 `AUTO_DEVOPS_PLATFORM_TARGET` 变量，并赋予以下值之一，来指定 Auto DevOps 部署期间要定位的 AWS 平台：
   - `FARGATE`：如果您目标服务必须是 FARGATE 启动类型。
   - `ECS`：如果您部署到 ECS 时不强制执行任何启动类型检查。

当您触发流水线时，如果您已启用 Auto DevOps，并且已正确[将 AWS 凭证作为变量输入](../../../ci/cloud_deployment/_index.md#authenticate-gitlab-with-aws)，您的应用程序将被部署到 AWS ECS。

如果您同时拥有有效的 `AUTO_DEVOPS_PLATFORM_TARGET` 变量和绑定到您项目的 Kubernetes 集群，则仅有部署到 Kubernetes 的作业会运行。

> [!warning]
> 将 `AUTO_DEVOPS_PLATFORM_TARGET` 变量设置为 `ECS` 会触发在 [`Jobs/Deploy/ECS.gitlab-ci.yml` 模板](https://jihulab.com/gitlab-cn/gitlab/-/blob/master/lib/gitlab/ci/templates/Jobs/Deploy/ECS.gitlab-ci.yml) 中定义的作业。
> 然而，不建议单独[引入](../../../ci/yaml/_index.md#includetemplate)此模板。此模板仅设计用于 Auto DevOps。如果单独引入，它可能会意外更改，导致您的流水线失败。此外，该模板中的作业名称也可能发生变更。请不要在您自己的流水线中覆盖这些作业的名称，因为当名称更改时，覆盖将停止生效。
```