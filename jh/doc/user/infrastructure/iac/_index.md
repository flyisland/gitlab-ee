---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用 OpenTofu 和极狐GitLab 实现基础设施即代码
description: 基础设施管理、版本控制、自动化、状态存储和模块。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

要使用极狐GitLab 管理您的基础设施，您可以使用与 OpenTofu 的集成来定义资源，并对其进行版本控制、复用和共享：

- 管理计算、存储和网络等底层组件。
- 管理 DNS 记录和 SaaS 功能等高层组件。
- 将极狐GitLab 用作 OpenTofu 状态存储。
- 存储并使用 OpenTofu 模块，以简化常见和复杂的基础设施模式。
- 纳入 GitOps 部署和基础设施即代码（IaC）工作流。

以下示例主要使用 OpenTofu，但它们同样适用于 Terraform。

<a id="terraform-and-opentofu-support"></a>

## Terraform 和 OpenTofu 支持

极狐GitLab 同时与 Terraform 和 OpenTofu 集成。
大多数功能完全兼容，包括：

- [极狐GitLab 管理的 Terraform/OpenTofu 状态](terraform_state.md)
- [合并请求中的 Terraform/OpenTofu 集成](mr_integration.md)
- [Terraform/OpenTofu 模块仓库](../../packages/terraform_module_registry/_index.md)

为简单起见，极狐GitLab 文档主要提及 OpenTofu。
不过，Terraform 与 OpenTofu 集成之间的差异
均有文档说明。

<a id="quickstart-an-opentofu-project-in-pipelines"></a>

## 在流水线中快速开始 OpenTofu 项目

通过极狐GitLab OpenTofu CI/CD 组件，OpenTofu 可以与所有 Terraform 专属的极狐GitLab 功能集成。

您可以通过包含该组件，为您的流水线添加 *validate*、*plan* 和 *apply* 工作流：

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

## 构建并托管您自己的 Terraform CI/CD 模板

尽管极狐GitLab 不再分发 Terraform CI/CD 模板
和 `terraform-images`（底层作业镜像，包括 `terraform`），
您仍然可以在极狐GitLab 流水线中使用 Terraform。

要了解如何构建并托管您自己的模板和镜像，请参阅 [Terraform Images](https://gitlab.com/gitlab-org/terraform-images) 项目。
