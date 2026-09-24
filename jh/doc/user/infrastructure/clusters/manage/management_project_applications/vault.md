---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用集群管理项目安装 Vault
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

[HashiCorp Vault](https://www.vaultproject.io/) 是一个密钥管理解决方案，可用于安全管理及存储密码、凭据、证书等。Vault 安装实例可以作为应用程序、极狐GitLab CI/CD 作业等所有凭据的单一安全数据存储。它还可以为基础设施中的系统和部署提供 SSL/TLS 证书。将 Vault 作为所有这些凭据的唯一来源，可以实现更高级别的安全性，因为您可以通过单一入口对所有敏感凭据和证书进行访问、控制和审计。此功能需要赋予极狐GitLab 最高级别的访问和控制权限。因此，如果极狐GitLab 遭到入侵，此 Vault 实例的安全性也会受到威胁。为避免此安全风险，极狐GitLab 建议使用您自己的 HashiCorp Vault 来利用 [CI 外部密钥](../../../../../ci/secrets/_index.md)。

假设您已经通过[管理项目模板](../../../../clusters/management_project_template.md)创建了项目，要安装 Vault，您应该在 `helmfile.yaml` 文件中取消注释此行：

```yaml
  - path: applications/vault/helmfile.yaml
```

默认情况下，您会获得一个不包含可扩展存储后端的基础 Vault 设置。这对于简单测试和小规模部署来说已经足够，但其扩展能力有限，并且由于是单实例部署，升级 Vault 应用程序会导致停机。

要在生产环境中最佳地使用 Vault，理想情况下需要深入了解 Vault 的内部机制及其配置方法。这可以通过阅读 [Vault 配置指南](../../../../../ci/secrets/hashicorp_vault.md#configure-your-vault-server)、[Vault 文档](https://developer.hashicorp.com/vault/docs/internals) 以及 Vault Helm Chart 的 [`values.yaml` 文件](https://github.com/hashicorp/vault-helm/blob/v0.3.3/values.yaml) 来实现。

至少，大多数用户会设置：

- 一个[密封](https://developer.hashicorp.com/vault/docs/configuration/seal)，用于对主密钥进行额外加密。
- 一个[存储后端](https://developer.hashicorp.com/vault/docs/configuration/storage)，适合环境和存储安全要求。
- [HA 模式](https://developer.hashicorp.com/vault/docs/concepts/ha)。
- [Vault UI](https://developer.hashicorp.com/vault/docs/configuration/ui)。

以下是一个示例值文件 (`applications/vault/values.yaml`)，它配置了 Google Key Management Service 以实现自动解封，使用 Google Cloud Storage 后端，启用了 Vault UI，并启用了具有 3 个 Pod 副本的 HA 模式。下文的 `storage` 和 `seal` 段落是示例，应替换为特定于您环境的设置。

```yaml
# 启用 Vault WebUI
ui:
  enabled: true
server:
  # 禁用内置数据存储卷，因为它对于高可用性模式不安全
  dataStorage:
    enabled: false
  # 启用高可用性模式
  ha:
    enabled: true
    # 配置 Vault 在 8200 端口监听常规流量，在 8201 端口监听集群间流量
    config: |
      listener "tcp" {
        tls_disable = 1
        address = "[::]:8200"
        cluster_address = "[::]:8201"
      }
      # 配置 Vault 将数据存储在 GCS 存储桶后端
      storage "gcs" {
        path = "gcs://my-vault-storage/vault-bucket"
        ha_enabled = "true"
      }
      # 配置 Vault 使用 GKMS 密钥对存储进行解封
      seal "gcpckms" {
         project     = "vault-helm-dev-246514"
         region      = "global"
         key_ring    = "vault-helm-unseal-kr"
         crypto_key  = "vault-helm-unseal-key"
      }
```

成功安装 Vault 后，您必须[初始化 Vault](https://developer.hashicorp.com/vault/tutorials/getting-started/getting-started-deploy#initializing-the-vault) 并获取初始根令牌。您需要能够访问部署了 Vault 的 Kubernetes 集群，才能完成此操作。要初始化 Vault，请获取 Vault 正在 Kubernetes 中运行的其中一个 Pod 的 shell（通常使用 `kubectl` 命令行工具完成）。进入 Pod 的 shell 后，运行 `vault operator init` 命令：

```shell
kubectl -n gitlab-managed-apps exec -it vault-0 sh
/ $ vault operator init
```

这应该会为您提供解封密钥和初始根令牌。请务必记下这些信息并安全保管，因为它们在 Vault 的整个生命周期中都是解封 Vault 所必需的。