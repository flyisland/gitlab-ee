---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用极狐GitLab 与 Kubernetes 集成的最佳实践
---

通过 GitOps 部署到 Kubernetes 时，极狐GitLab Kubernetes Agent 与 Flux 结合使用可提供最佳体验。
极狐GitLab 建议使用 GitOps（也称为拉取式部署）进行部署。不过，您的公司可能无法过渡到 GitOps，或者您可能有某些（通常是非生产环境的）原因需要使用基于流水线的方式。本页介绍在企业中使用 GitOps 的最佳实践，并针对基于流水线的部署提供一些注意事项。

有关 GitOps 优势的说明，请参阅 [OpenGitOps 倡议](https://opengitops.dev/about/)。

<a id="gitops"></a>

## GitOps

- 尽管[开始将 Kubernetes 集群连接到极狐GitLab](getting_started.md) 介绍了如何使用 Flux CLI 安装 Flux，但要扩展和自动化 Flux 部署，您应执行以下任一操作：
  - 使用 [Flux Operator](https://github.com/controlplaneio-fluxcd/flux-operator)。
  - 使用 [Terraform](https://registry.terraform.io/providers/fluxcd/flux/latest/docs) 或 [OpenTofu](https://search.opentofu.org/provider/fluxcd/flux/latest) 安装。
- 使用[多租户锁定](https://fluxcd.io/flux/installation/configuration/multitenancy/)配置 Flux。
- 为便于扩展，Flux 支持[垂直扩展](https://fluxcd.io/flux/installation/configuration/vertical-scaling/)和[水平分片](https://fluxcd.io/flux/installation/configuration/sharding/)。
- 有关 Flux 专属指导，请参阅 Flux 文档中的 [Flux 指南](https://fluxcd.io/flux/guides/)。
- 为简化维护，您应为每个集群运行单个极狐GitLab Kubernetes Agent 安装。您可以在整个极狐GitLab 域中通过模拟功能共享该代理连接。
- 考虑使用 Flux 的 `OCIRepository` 来存储和检索清单。
  您可以使用极狐GitLab 流水线构建 OCI 镜像并将其推送到容器镜像仓库。
- 为缩短反馈循环，可从相关的极狐GitLab 流水线触发即时 GitOps 协调。
- 您应对生成的 OCI 镜像进行签名，并且仅部署经 Flux 签名和验证的镜像。
- 请务必定期轮换 Flux 用于访问清单的密钥。您还应定期轮换代理注册令牌。

<a id="oci-containers"></a>

### OCI 容器

当您使用 OCI 容器而非 Git 代码仓库时，清单的单一可信来源仍然是 Git 代码仓库。您可以将 OCI 容器视为 Git 代码仓库与集群之间的缓存层。

使用 OCI 容器有以下几个好处：

- OCI 专为可扩展性而设计。尽管极狐GitLab Git 代码仓库扩展性良好，但它们并非为此用例而设计。
- 单个 Git 代码仓库可以作为多个 OCI 容器的来源，每个容器打包一小组清单。
  这样，如果您需要检索一组清单，就无需下载整个 Git 代码仓库。
- OCI 仓库可以遵循广为人知的版本控制方案，并且可以配置 Flux 按照该方案自动更新。
  例如，如果您使用语义化版本控制，Flux 可以自动部署所有次要版本和补丁变更，而主要版本则需要手动更新。
- OCI 镜像可以签名，并且签名可由 Flux 验证。
- OCI 仓库可以由容器镜像仓库扫描，即使在镜像构建完成后也是如此。
- 构建 OCI 容器的作业支持使用常规 GitOps 工具不支持的广为人知的发布管理功能，例如[受保护环境](../../../ci/environments/protected_environments.md)、[部署审批](../../../ci/environments/deployment_approvals.md)和[部署冻结窗口](../../project/releases/_index.md#prevent-unintentional-releases-by-setting-a-deploy-freeze)。

<a id="pipeline-based-deployments"></a>

## 基于流水线的部署

如果您需要使用基于流水线的部署，请遵循以下最佳实践：

- 为减少每个集群部署的代理数量，请在您的群组和项目之间共享代理连接。
  如有可能，每个集群仅使用一个代理部署。
- 使用模拟功能，并通过常规 Kubernetes RBAC 尽量缩小集群中 CI/CD 作业的访问权限。
