---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
description: Configure instance-level SSH certificate authentication with gitlab-sshd using trusted CA keys.
title: 使用 `gitlab-sshd` 的实例级别 SSH 证书
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- [引入]于极狐GitLab 18.11。

{{< /history >}}

<a id="instance-level-ssh-certificates-with-gitlab-sshd"></a>

## 使用 `gitlab-sshd` 的实例级别 SSH 证书

如果您的私有化部署极狐GitLab 实例使用 `gitlab-sshd`，则可以配置实例级别的 SSH 证书认证。

- 使用证书颁发机构 (CA) 证书来集中管理 SSH 认证。
- 不需要 Rails API 调用或数据库更改。

此方法等同于 OpenSSH 的 `TrustedUserCAKeys` 指令，并且是[基于 OpenSSH 的 SSH 证书设置](ssh_certificates.md)的替代方案。

<a id="gitlab_sshd-authentication-workflow"></a>

## `gitlab_sshd` 认证工作流

`gitlab_sshd` 认证工作流遵循以下流程。

1. 管理员生成 CA 密钥对。
1. 管理员将 CA 公钥文件路径添加到 `config.yml` 中的 `sshd.trusted_user_ca_keys` 下。
1. 管理员使用 CA 私钥签署用户的 SSH 公钥。证书的 `KeyId` 被设置为用户的 GitLab 用户名。
1. 当用户使用证书连接时：
   - `gitlab-sshd` 验证证书签名和有效期。
   - `gitlab-sshd` 提取 `KeyId` 并将其用作 GitLab 用户名。
   - 继续进行标准的 GitLab 访问检查（用户存在性、项目权限）。

`gitlab-sshd` 进程本身不需要 Rails API 或数据库调用来进行证书验证。`/allowed` 端点仍然会被调用用于授权，就像任何 SSH 连接一样。

<a id="comparison-with-other-ssh-certificate-methods"></a>

## 与其他 SSH 证书方法的对比

极狐GitLab 支持多种 SSH 证书认证方法：

| 特性 | 实例级别 (`gitlab-sshd`) | 实例级别 (OpenSSH) | 群组级别 |
|---|---|---|---|
| 配置位置 | `config.yml` | `sshd_config` | GitLab API/UI |
| SSH 服务器 | `gitlab-sshd` | OpenSSH | `gitlab-sshd` |
| Offering | 私有化部署 | 私有化部署 | JihuLab.com |
| Tier | 基础版，专业版，旗舰版 | 基础版，专业版，旗舰版 | 专业版，旗舰版 |
| 范围 | 实例范围（无命名空间限制） | 实例范围（无命名空间限制） | 顶级群组 |
| 用户名映射 | 证书 `KeyId` | 通过 `AuthorizedPrincipalsCommand` 的证书 Key ID | 通过 API 的证书身份 |
| 企业用户要求 | 否 | 否 | 是 |
| 文档 | 本页 | [OpenSSH `AuthorizedPrincipalsCommand`](ssh_certificates.md) | [群组 SSH 证书](../../user/group/ssh_certificates.md) |

<a id="prerequisites"></a>

## 前提条件

在配置实例级别 SSH 证书之前：

- 您的私有化部署极狐GitLab 实例必须已启用 `gitlab-sshd`。有关更多信息，请参阅[启用 `gitlab-sshd`](gitlab_sshd.md#enable-gitlab-sshd)。
- 您必须拥有服务器文件系统的访问权限，以创建 CA 密钥并编辑 `config.yml`。
- SSH 证书的 `KeyId` 字段必须与准确的极狐GitLab 用户名匹配。

<a id="configure-trusted-ca-keys"></a>

## 配置受信任的 CA 密钥

要配置实例级别 SSH 证书认证：

1. 生成 CA 密钥对：

   ```shell
   ssh-keygen -t ed25519 -f ssh_user_ca -C "极狐GitLab SSH User CA"
   ```

   出现提示时，输入一个强密码短语以保护 CA 私钥。

   此命令会创建两个文件：

   - `ssh_user_ca`：CA 私钥。
   - `ssh_user_ca.pub`：CA 公钥。

   仅将公钥复制到极狐GitLab 服务器：

   ```shell
   sudo cp ssh_user_ca.pub /etc/gitlab/ssh_user_ca.pub
   ```

   将 CA 私钥保存在安全的位置，理想情况下应保存在非极狐GitLab 服务器的离线系统上。私钥仅用于签署用户证书。

1. 将 CA 公钥文件路径添加到 `gitlab-sshd` 配置中。

   {{< tabs >}}

   {{< tab title="Linux package (Omnibus)" >}}

   1. 编辑 `/etc/gitlab/gitlab.rb`：

      ```ruby
      gitlab_sshd['trusted_user_ca_keys'] = ['/etc/gitlab/ssh_user_ca.pub']
      ```

   1. 保存文件并重新配置极狐GitLab：

      ```shell
      sudo gitlab-ctl reconfigure
      ```

   {{< /tab >}}

   {{< tab title="Helm chart (Kubernetes)" >}}

   1. 创建包含 CA 公钥的 Kubernetes 密钥：

      ```shell
      kubectl create secret generic my-ssh-ca-keys \
        --from-file=ca.pub=ssh_user_ca.pub
      ```

   1. 导出 Helm 值：

      ```shell
      helm get values gitlab > gitlab_values.yaml
      ```

   1. 编辑 `gitlab_values.yaml` 以引用该密钥：

      ```yaml
      gitlab:
        gitlab-shell:
          sshDaemon: gitlab-sshd
          config:
            trustedUserCAKeys:
              secret: my-ssh-ca-keys
              keys:
                - ca.pub
      ```

   1. 保存文件并应用新值：

   ```shell
   helm upgrade -f gitlab_values.yaml gitlab gitlab/gitlab
   ```

   有关 Helm chart 配置的更多信息，请参阅[极狐GitLab Shell chart 文档](https://gitlab.cn/docs/charts/charts/gitlab/gitlab-shell/#instance-level-ssh-certificates-gitlab-sshd)。

   {{< /tab >}}

   {{< /tabs >}}

1. 通过检查日志来验证 `gitlab-sshd` 是否成功启动：

   ```plaintext
   已加载实例级别 SSH 证书的受信任用户 CA 密钥，计数=1
   ```

<a id="issue-ssh-certificates-for-users"></a>

## 为用户颁发 SSH 证书

配置受信任的 CA 密钥后，为您的用户颁发证书：

1. 获取用户的 SSH 公钥（例如，`id_ed25519.pub`）。

1. 使用 CA 签署用户的公钥，将 `-I`（身份/KeyId）标志设置为用户的确切极狐GitLab 用户名：

   ```shell
   ssh-keygen -s ssh_user_ca -I <gitlab-用户名> -V +1d user-key.pub
   ```

   此命令创建一个证书文件（例如，`user-key-cert.pub`），有效期为一天。

   要设置更长的有效期，请调整 `-V` 标志。例如，`-V +30d` 表示 30 天，`-V +52w` 表示一年。

1. 将证书文件分发给用户。

1. 用户使用其证书连接：

   ```shell
   ssh git@gitlab.example.com
   ```

   如果证书文件遵循默认命名约定（`<key>-cert.pub` 与 `<key>` 并存），SSH 会自动使用它。否则，请明确指定证书：

   ```shell
   ssh -o CertificateFile=~/.ssh/id_ed25519-cert.pub git@gitlab.example.com
   ```

<a id="use-multiple-certificate-authorities"></a>

## 使用多个证书颁发机构

您可以为 CA 轮换或多 CA 设置指定多个 CA 公钥文件。

{{< tabs >}}

{{< tab title="Linux package (Omnibus)" >}}

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_sshd['trusted_user_ca_keys'] = [
     '/etc/gitlab/ssh_user_ca_current.pub',
     '/etc/gitlab/ssh_user_ca_next.pub'
   ]
   ```

1. 保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

{{< /tab >}}

{{< tab title="Helm chart (Kubernetes)" >}}

1. 创建包含两个 CA 公钥的 Kubernetes 密钥：

   ```shell
   kubectl create secret generic my-ssh-ca-keys \
     --from-file=ca_current.pub=ssh_user_ca_current.pub \
     --from-file=ca_next.pub=ssh_user_ca_next.pub
   ```

1. 导出 Helm 值：

   ```shell
   helm get values gitlab > gitlab_values.yaml
   ```

1. 编辑 `gitlab_values.yaml` 以引用该密钥：

   ```yaml
   gitlab:
     gitlab-shell:
       sshDaemon: gitlab-sshd
       config:
         trustedUserCAKeys:
           secret: my-ssh-ca-keys
           keys:
             - ca_current.pub
             - ca_next.pub
   ```

1. 保存文件并应用新值：

   ```shell
   helm upgrade -f gitlab_values.yaml gitlab gitlab/gitlab
   ```

{{< /tab >}}

{{< /tabs >}}

单个文件也可以包含多个 CA 公钥，每行一个。`gitlab-sshd` 会自动跨文件去重密钥。

<a id="security-considerations"></a>

## 安全考虑

实例级别 SSH 证书将认证权限授予持有 CA 私钥的任何人。在部署之前，请审查以下安全注意事项。

> [!warning]
> 任何有权访问 CA 私钥的人员都可以为该实例上的**任何**极狐GitLab 用户签署证书。使用适当的访问控制保护 CA 私钥，例如限制性文件权限、硬件安全模块 (HSM) 或离线环境。

<a id="no-certificate-revocation"></a>

### 无证书吊销机制

`gitlab-sshd` 不包含内置的证书吊销机制。如果证书或 CA 密钥遭到泄露，请从 `trusted_user_ca_keys` 配置中移除该 CA，并使用新 CA 重新颁发证书。使用短期证书（例如 24 小时）以最小化暴露窗口。

<a id="no-audit-events-for-ca-configuration-changes"></a>

### CA 配置更改无审计事件

极狐GitLab 不会将 `config.yml` 中 `trusted_user_ca_keys` 的更改记录为审计事件。使用您的基础设施监控工具来监控此配置文件的更改。

`gitlab-sshd` 会记录成功和失败的 SSH 证书认证尝试，字段包括 `ssh_user`、`public_key_fingerprint`、`signing_ca_fingerprint`、`certificate_identity` 和 `certificate_username`。

<a id="clustered-deployments"></a>

### 集群部署

在具有多个 `gitlab-sshd` 节点的环境中，请在所有节点之间同步配置和 CA 公钥文件。不一致的配置可能导致间歇性认证失败。对于 Helm chart 部署，Kubernetes 密钥会在各个 Pod 之间自动共享。

<a id="troubleshooting"></a>

## 故障排除

<a id="gitlab-sshd-fails-to-start-after-adding-ca-keys"></a>

### 添加 CA 密钥后 `gitlab-sshd` 无法启动

如果无法读取 CA 密钥文件或包含无效内容，`gitlab-sshd` 将无法启动。检查日志输出中是否有以下错误消息：

- `failed to load trusted user CA keys`：无法读取文件。验证文件是否存在且具有正确的权限（`git` 用户可读）。
- `failed to parse trusted user CA key in file`：文件内容不是有效的 SSH 公钥。验证文件是否包含 OpenSSH 格式的有效公钥。
- `trusted_user_ca_keys configured but no valid CA keys were loaded`：配置列出了 CA 密钥文件，但没有一个包含有效密钥。

<a id="certificate-rejected-not-a-user-certificate"></a>

### `certificate rejected: not a user certificate`

证书是作为主机证书而不是用户证书生成的。在使用 `ssh-keygen` 签署时，请勿使用 `-h` 标志。

<a id="certificate-keyid-does-not-match-gitlab-username-format"></a>

### `certificate KeyId does not match GitLab username format`

证书中的 `KeyId` 不符合极狐GitLab 用户名规则。验证签署时使用的 `-I` 值是否与确切的极狐GitLab 用户名匹配。

<a id="ssh-cert-has-expired"></a>

### `ssh: cert has expired`

证书有效期已过。使用 `-V` 标志颁发具有适当有效期的新证书。

```plaintext
# 使用 `-V` 标志颁发具有适当有效期的新证书。
```