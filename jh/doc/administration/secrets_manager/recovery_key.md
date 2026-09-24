---
stage: Software Supply Chain Security
group: Pipeline Security
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 恢复密钥管理
---

恢复密钥是 OpenBao 的紧急凭证。当主 JWT 认证方法不可用时，可使用它生成临时根令牌。

恢复密钥不用于标准操作，例如获取密钥或配置命名空间。应将其视为高权限凭证并安全存储。

> [!warning]
> 恢复密钥无法解密存储在 OpenBao 数据库中的数据。所有 OpenBao 数据均由配置的解封机制保护，该机制可以是存储在 `gitlab-openbao-unseal` Kubernetes 密钥中的静态密钥，也可以是外部 KMS。
> 请将解封机制与恢复密钥分开备份。

要运行本页中的命令，您需要知道工具箱 Pod 的名称。要找到它，请运行：

```shell
kubectl get pods -n gitlab -lapp=toolbox
```

在以下命令中，将 `<toolbox-pod-name>` 替换为实际的 Pod 名称。

<a id="store-the-recovery-key"></a>

## 存储恢复密钥

在初始设置期间且未发生故障前，运行此命令一次：

```shell
kubectl exec -n gitlab -it -c toolbox <toolbox-pod-name> -- \
  gitlab-rake "gitlab:secrets_management:openbao:recovery_key:store"
```

此命令在 OpenBao 中生成恢复密钥，并将其加密存储在极狐GitLab 数据库中。

> [!warning]
> 恢复密钥只能生成一次。
> 您不能再次运行 `recovery_key:store`，
> 也不能在运行 `recovery_key:fetch` 之后运行它。

在执行此命令之前，OpenBao 在每次 Pod 重启时都会记录一条警告：
`[WARN]  核心：解封后升级密封密钥失败：错误="未找到恢复密钥"`。
存储密钥后，该警告将停止。

<a id="view-the-stored-recovery-key"></a>

## 查看已存储的恢复密钥

要从极狐GitLab 数据库获取并查看恢复密钥，请运行：

```shell
kubectl exec -n gitlab -it -c toolbox <toolbox-pod-name> -- \
  gitlab-rake "gitlab:secrets_management:openbao:recovery_key:show"
```

> [!warning]
> 该命令在明文显示密钥前会要求确认。
> 请安全存储输出结果。不要将其记录到日志或在非安全渠道共享。

<a id="fetch-the-recovery-key-without-storing-it"></a>

## 获取恢复密钥但不存储

使用 `recovery_key:fetch` 可以在终端中生成并显示恢复密钥，而无需将其存储到极狐GitLab 数据库中。当您将密钥存储在外部系统（例如密码管理器或硬件安全模块）中时，可使用此任务。

> [!warning]
> 恢复密钥只能生成一次。
> 您不能再次运行 `recovery_key:fetch`，
> 也不能在运行 `recovery_key:store` 之后运行它。

```shell
kubectl exec -n gitlab -it -c toolbox <toolbox-pod-name> -- \
  gitlab-rake "gitlab:secrets_management:openbao:recovery_key:fetch"
```

该任务在生成并显示密钥之前会要求确认。密钥将以明文形式显示。

<a id="generate-a-root-token-from-the-recovery-key"></a>

## 从恢复密钥生成根令牌

当您需要执行特权 OpenBao 操作（例如重新配置 JWT 认证或迁移密封）时，可使用恢复密钥生成临时根令牌。例如，当您故障转移到具有不同域名的 Geo 辅助站点时。更多信息，请参见[配置 JWT 认证](../geo/disaster_recovery/_index.md#optional-configure-jwt-authentication)。

> [!warning]
> 完成所需操作后请立即吊销根令牌。
> 根令牌对 OpenBao 的所有操作和命名空间拥有不受限制的访问权限。

OpenBao Pod 内提供了 `bao` 二进制文件。所有命令都通过 `kubectl exec` 运行。无需进行端口转发。

1. 获取您的恢复密钥：

   ```shell
   kubectl exec -n gitlab -it -c toolbox <toolbox-pod-name> -- \
     gitlab-rake "gitlab:secrets_management:openbao:recovery_key:show"
   ```

   如果您使用 `recovery_key:fetch` 并将密钥存储在了外部，请从该位置获取密钥。

1. 获取 OpenBao Pod 名称：

   ```shell
   kubectl get pods -n gitlab -l app.kubernetes.io/name=openbao -o name
   ```

   在以下步骤中，将 `<openbao-pod-name>` 替换为此命令的输出。例如，`pod/gitlab-openbao-0`。

1. 生成 OTP：

   ```shell
   kubectl exec -n gitlab <openbao-pod-name> -- \
     sh -c "BAO_ADDR=http://127.0.0.1:8200 bao operator generate-root -generate-otp"
   ```

   在以下命令中，将 `<otp>` 替换为此输出。

1. 初始化根生成：

   ```shell
   kubectl exec -n gitlab <openbao-pod-name> -- \
     sh -c "BAO_ADDR=http://127.0.0.1:8200 bao operator generate-root -init -otp=<otp>"
   ```

   成功的响应会包含 `Started: true` 和一个 `Nonce` 值。
   在以下步骤中，将 `<nonce>` 替换为此 `Nonce` 值。

1. 提交恢复密钥：

   ```shell
   kubectl exec -n gitlab <openbao-pod-name> -- \
     sh -c "echo '<recovery_key>' | BAO_ADDR=http://127.0.0.1:8200 bao operator generate-root -nonce=<nonce>"
   ```

   OpenBao 配置为单个恢复密钥份额，因此操作会立即完成。成功的响应会包含 `Complete: true` 和一个 `Encoded Token` 值。
   在下一步中，将 `<encoded_token>` 替换为此令牌值。

1. 解码根令牌：

   ```shell
   kubectl exec -n gitlab <openbao-pod-name> -- \
     sh -c "BAO_ADDR=http://127.0.0.1:8200 bao operator generate-root -decode=<encoded_token> -otp=<otp>"
   ```

   在以下步骤中，将 `<root_token>` 替换为解码后的根令牌。

1. 验证根令牌是否有效：

   ```shell
   kubectl exec -n gitlab <openbao-pod-name> -- \
     sh -c "BAO_ADDR=http://127.0.0.1:8200 BAO_TOKEN=<root_token> bao token lookup"
   ```

   成功的响应包含 `policies  [root]`。

1. 执行所需的特权操作。

1. 吊销根令牌：

   ```shell
   kubectl exec -n gitlab <openbao-pod-name> -- \
     sh -c "BAO_ADDR=http://127.0.0.1:8200 BAO_TOKEN=<root_token> bao token revoke -self"
   ```