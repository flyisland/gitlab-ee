---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用 OpenTofu 和极狐GitLab 实现基础架构即代码
description: 基础架构管理、版本控制、自动化、状态存储和模块。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

要使用极狐GitLab 管理你的基础架构，你可以使用与 OpenTofu 的集成来定义可以版本化、重用和共享的资源：

- 管理计算、存储和网络资源等低层组件。
- 管理 DNS 条目和 SaaS 功能等高层组件。
- 使用极狐GitLab 作为 OpenTofu 状态存储。
- 存储和使用 OpenTofu 模块，以简化常见和复杂的基础架构模式。
- 整合 GitOps 部署和基础架构即代码 (IaC) 工作流。

以下示例主要使用 OpenTofu，但它们同样适用于 Terraform。

<a id="terraform-and-opentofu-support"></a>

## Terraform 和 OpenTofu 支持

极狐GitLab 集成了 Terraform 和 OpenTofu。
大多数功能完全兼容，包括：

- [极狐GitLab 托管的 Terraform/OpenTofu 状态](terraform_state.md)
- [合并请求中的 Terraform/OpenTofu 集成](mr_integration.md)
- [Terraform/OpenTofu 模块仓库](../../packages/terraform_module_registry/_index.md)

为简便起见，极狐GitLab 文档主要提及 OpenTofu。
但是，Terraform 和 OpenTofu 集成之间的差异
会单独记录。

<a id="quickstart-an-opentofu-project-in-pipelines"></a>

## 在流水线中快速启动 OpenTofu 项目

通过极狐GitLab OpenTofu CI/CD 组件，OpenTofu 可以与所有 Terraform 特定的极狐GitLab 功能集成。

你可以通过包含以下组件，将*验证*、*计划*和*应用*工作流添加到你的流水线：

```yaml
include:
  - component: gitlab.com/components/opentofu/validate-plan-apply@<VERSION>
    inputs:
      version: <VERSION>
      opentofu_version: <OPENTOFU_VERSION>
      root_dir: terraform/
      state_name: production

stages: [validate, build, deploy]
```

有关模板、输入以及如何使用 OpenTofu CI/CD 组件的更多信息，请参阅 [OpenTofu CI/CD 组件 README](https://gitlab.com/components/opentofu)。

<a id="build-and-host-your-own-terraform-cicd-templates"></a>

## 构建和托管你自己的 Terraform CI/CD 模板

尽管极狐GitLab 不再分发 Terraform CI/CD 模板
和 `terraform-images`（底层任务镜像，包括 `terraform`），
你仍然可以在极狐GitLab 流水线中使用 Terraform。

要了解如何构建和托管你自己的模板和镜像，请参阅 [Terraform Images](https://gitlab.com/gitlab-org/terraform-images)
项目。

<a id="related-topics"></a>

## 相关主题

- 使用极狐GitLab 作为 [Terraform/OpenTofu 模块仓库](../../packages/terraform_module_registry/_index.md)。
- 要将状态文件存储在本地或远程存储中，请使用 [极狐GitLab 托管的 Terraform/OpenTofu 状态](terraform_state.md)。
- 要协作处理 Terraform 代码更改和 IaC 工作流，请使用
  [合并请求中的 Terraform 集成](mr_integration.md)。
- 要管理用户、群组和项目等极狐GitLab 资源，请使用
  [极狐GitLab Terraform 提供商](https://gitlab.com/gitlab-org/terraform-provider-gitlab)。
  极狐GitLab Terraform 提供商文档可在 [Terraform 文档站](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs) 上找到。
- [在 Amazon Elastic Kubernetes Service (EKS) 上创建一个新集群](../clusters/connect/new_eks_cluster.md)。
- [排查](troubleshooting.md) 极狐GitLab 和 Terraform 相关的问题。
- 查看 [包含 `gitlab-terraform` shell 脚本的镜像](https://gitlab.com/gitlab-org/terraform-images)。