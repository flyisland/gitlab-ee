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

[HashiCorp Vault](https://www.vaultproject.io/) 是一款密钥管理解决方案，可用于安全地管理和存储密码、凭据、证书等。您可以利用 Vault 安装为应用程序、极狐GitLab CI/CD 作业等使用的凭据提供单一的安全数据存储。它还可以作为一种为基础设施中的系统和部署提供 SSL/TLS 证书的方式。将 Vault 用作所有这些凭据的单一来源，可以围绕所有敏感凭据和证书实现单一的访问、控制和可审计性来源，从而提升安全性。此功能需要授予极狐GitLab 最高级别的访问和控制权限。因此，如果极狐GitLab 遭到入侵，此 Vault 实例的安全性也会受到影响。为避免此安全风险，极狐GitLab 建议使用您自己的 HashiCorp Vault，以利用 [CI 的外部密钥](../../../../../ci/secrets/_index.md)。

假设您已经基于[管理项目模板](../../../../clusters/management_project_template.md)创建了项目，要安装 Vault，您应取消注释 `helmfile.yaml`中的以下行：

```yaml
  - path: applications/vault/helmfile.yaml
```

默认情况下，您会获得一个基本的 Vault 设置，没有可扩展的存储后端。这对于简单测试和小规模部署来说已经足够，但其可扩展性有限，而且由于是单实例部署，升级 Vault 应用会导致停机。

要在生产环境中以最佳方式使用 Vault，最好充分了解 Vault 的内部机制及其配置方式。您可以阅读 [Vault 配置指南](../../../../../ci/secrets/hashicorp_vault.md#configure-your-vault-server)、[Vault 文档](https://developer.hashicorp.com/vault/docs/internals)以及 Vault Helm chart 的 [`values.yaml` 文件](https://github.com/hashicorp/vault-helm/blob/v0.3.3/values.yaml)来做到这一点。

大多数用户至少会设置：

- 一个[密封机制](https://developer.hashicorp.com/vault/docs/configuration/seal)，用于对主密钥进行额外加密。
- 一个适合环境与存储安全要求的[存储后端](https://developer.hashicorp.com/vault/docs/configuration/storage)。
- [高可用模式](https://developer.hashicorp.com/vault/docs/concepts/ha)。
- [Vault UI](https://developer.hashicorp.com/vault/docs/configuration/ui)。

以下是一个示例 values 文件（`applications/vault/values.yaml`），它配置 Google Key Management Service 用于自动解封，使用 Google Cloud Storage 后端，启用 Vault UI，并启用具有 3 个 pod 副本的高可用。下面的 `storage` 和 `seal` 配置段仅为示例，应替换为适合您环境的设置。

```yaml
# Enable the Vault WebUI
ui:
  enabled: true
server:
  # Disable the built in data storage volume as it's not safe for High Availability mode
  dataStorage:
    enabled: false
  # Enable High Availability Mode
  ha:
    enabled: true
    # Configure Vault to listen on port 8200 for normal traffic and port 8201 for inter-cluster traffic
    config: |
      listener "tcp" {
        tls_disable = 1
        address = "[::]:8200"
        cluster_address = "[::]:8201"
      }
      # Configure Vault to store its data in a GCS Bucket backend
      storage "gcs" {
        path = "gcs://my-vault-storage/vault-bucket"
        ha_enabled = "true"
      }
      # Configure Vault to unseal storage using a GKMS key
      seal "gcpckms" {
         project     = "vault-helm-dev-246514"
         region      = "global"
         key_ring    = "vault-helm-unseal-kr"
         crypto_key  = "vault-helm-unseal-key"
      }
```

成功安装 Vault 后，您必须[初始化 Vault](https://developer.hashicorp.com/vault/tutorials/getting-started/getting-started-deploy#initializing-the-vault) 并获取初始根令牌。为此，您需要访问 Vault 所部署到的 Kubernetes 集群。要初始化 Vault，请获取一个进入 Kubernetes 中运行的某个 Vault pod 的 shell（通常使用 `kubectl` 命令行工具完成）。进入 pod 的 shell 后，运行 `vault operator init` 命令：

```shell
kubectl -n gitlab-managed-apps exec -it vault-0 sh
/ $ vault operator init
```

这应会为您提供解封密钥和初始根令牌。请务必记录并妥善保管这些内容，因为在 Vault 的整个生命周期中，解封 Vault 都需要用到它们。
