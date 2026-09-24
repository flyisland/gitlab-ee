---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用 极狐GitLab 与 Kubernetes 集成的最佳实践
---

适用于 Kubernetes 的代理与 Flux 相结合，通过 GitOps 部署到 Kubernetes 时提供了最佳体验。  
极狐GitLab 建议在部署中使用 GitOps（也称为基于拉取的部署）。  
但是，您的公司可能无法过渡到 GitOps，或者您可能出于某些（通常是非生产）原因使用基于流水线的方法。本页面描述了企业使用 GitOps 的最佳实践，以及对基于流水线的部署的一些考虑。

有关 GitOps 优势的描述，请参见[OpenGitOps 倡议](https://opengitops.dev/about)。

<a id="gitops"></a>

## GitOps

- 虽然[“开始连接 Kubernetes 集群到 极狐GitLab”](getting_started.md) 展示了如何使用 Flux CLI 安装 Flux，但为了扩展和自动化 Flux 部署，您应该执行以下操作之一：
  - 使用 [Flux Operator](https://github.com/controlplaneio-fluxcd/flux-operator)。
  - 使用 [Terraform](https://registry.terraform.io/providers/fluxcd/flux/latest/docs) 或 [OpenTofu](https://search.opentofu.org/provider/fluxcd/flux/latest) 安装。
- 配置 Flux 使用[多租户锁定](https://fluxcd.io/flux/installation/configuration/multitenancy/)。
- 关于扩展，Flux 支持[垂直分片](https://fluxcd.io/flux/installation/configuration/vertical-scaling/)和[水平分片](https://fluxcd.io/flux/installation/configuration/sharding/)。
- 有关 Flux 特定指导，请参阅 Flux 文档中的 [Flux 指南](https://fluxcd.io/flux/guides/)。
- 为了简化维护，每个集群应运行单个 极狐GitLab Kubernetes 代理安装。您可以通过在整个 极狐GitLab 域中使用假冒功能共享代理连接。
- 考虑使用 Flux `OCIRepository` 来存储和获取清单。  
  您可以使用 极狐GitLab 流水线构建 OCI 镜像并将其推送到容器镜像仓库。
- 为了缩短反馈循环，从相关 极狐GitLab 流水线触发即时的 GitOps 协调。
- 您应该对生成的 OCI 镜像进行签名，并且只部署由 Flux 签名并验证的镜像。
- 务必定期轮换 Flux 用于访问清单的密钥。您还应定期轮换代理注册令牌。

<a id="oci-containers"></a>

### OCI 容器

当您使用 OCI 容器而不是 Git 仓库时，清单的真实来源仍然是 Git 仓库。  
您可以将 OCI 容器视为 Git 仓库和集群之间的缓存层。

使用 OCI 容器有几个好处：

- OCI 专为可扩展性而设计。虽然 极狐GitLab Git 仓库扩展性很好，但它们并非为此用例设计。
- 单个 Git 仓库可以作为多个 OCI 容器的来源，每个容器打包一小部分清单。  
  这样，如果您需要获取一组清单，无需下载整个 Git 仓库。
- OCI 仓库可以遵循众所周知的版本方案，并且可以配置 Flux 根据该方案自动更新。  
  例如，如果您使用语义版本控制，Flux 可以自动部署所有次要和补丁更改，而主要版本则需要手动更新。
- OCI 镜像可以进行签名，并且签名可以由 Flux 验证。
- OCI 仓库可以被容器镜像仓库扫描，即使在构建镜像之后。
- 构建 OCI 容器的作业可以使用常规 GitOps 工具不支持的成熟发布管理功能，例如[受保护的环境](../../../ci/environments/protected_environments.md)、[部署审批](../../../ci/environments/deployment_approvals.md)和[部署冻结窗口](../../project/releases/_index.md#防止意外发布)。

<a id="pipeline-based-deployments"></a>

## 基于流水线的部署

如果您需要使用基于流水线的部署，请遵循以下最佳实践：

- 为了减少每个集群部署的代理数量，请在群组和项目之间共享代理连接。  
  如果可能，每个集群只使用一个代理部署。
- 使用假冒，并使用常规 Kubernetes RBAC 尽量减少 CI/CD 作业对集群的访问权限。