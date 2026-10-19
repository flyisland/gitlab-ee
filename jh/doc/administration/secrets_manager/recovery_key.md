---
stage: Security Platform
group: Secrets Manager OpenBao
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 恢复密钥管理
---

恢复密钥是 OpenBao 的应急凭证。使用它可以为需要特权的 OpenBao 操作生成根令牌。

恢复密钥不用于密钥获取或命名空间预配等标准操作。请将其视为高权限凭证并妥善存储。

> [!warning]
> 恢复密钥无法解密存储在 OpenBao 数据库中的数据。所有 OpenBao 数据都受所配置的解封机制保护，该机制可以是存储在 `gitlab-openbao-unseal` Kubernetes 密钥中的静态密钥，也可以是外部 KMS。
> 请将解封机制与恢复密钥分开备份。

要运行本页中的命令，您需要知道 toolbox pod 的名称。要查找该名称，请运行：

```shell
kubectl get pods -n gitlab -lapp=toolbox
```

在以下命令中，请使用该 pod 名称替换 `<toolbox-pod-name>`。

<a id="store-the-recovery-key"></a>

## 存储恢复密钥

在初始设置期间、发生事件之前，运行一次此命令：

```shell
kubectl exec -n gitlab -it -c toolbox <toolbox-pod-name> -- \
  gitlab-rake "gitlab:secrets_management:openbao:recovery_key:store"
```

该命令会在 OpenBao 中生成恢复密钥，并将其加密存储在极狐GitLab 数据库中。

> [!warning]
> 恢复密钥只能生成一次。
> 您无法第二次运行 `recovery_key:store`，
> 也无法在运行 `recovery_key:fetch` 之后再运行它。

在您运行此命令之前，OpenBao 会在每次 pod 重启时记录一条警告：
`[WARN]  core: post-unseal upgrade seal keys failed: error="no recovery key found"`。
存储密钥后，该警告将停止。

<a id="view-the-stored-recovery-key"></a>

## 查看已存储的恢复密钥

要从极狐GitLab 数据库中获取并查看恢复密钥，请运行：

```shell
kubectl exec -n gitlab -it -c toolbox <toolbox-pod-name> -- \
  gitlab-rake "gitlab:secrets_management:openbao:recovery_key:show"
```

> [!warning]
> 该命令在以明文显示密钥之前会要求确认。
> 请妥善存储输出内容。不要记录该输出，也不要在安全通道之外分享它。

<a id="fetch-the-recovery-key-without-storing-it"></a>

## 在不存储的情况下获取恢复密钥

使用 `recovery_key:fetch` 在终端中生成并显示恢复密钥，而不将其存储在极狐GitLab 数据库中。当您将密钥存储在外部系统（例如密码管理器或硬件安全模块）中时，请使用此任务。

> [!warning]
> 恢复密钥只能生成一次。
> 您无法第二次运行 `recovery_key:fetch`，
> 也无法在运行 `recovery_key:store` 之后再运行它。

```shell
kubectl exec -n gitlab -it -c toolbox <toolbox-pod-name> -- \
  gitlab-rake "gitlab:secrets_management:openbao:recovery_key:fetch"
```

该任务在生成并显示密钥之前会要求确认。密钥将以明文显示。

<a id="generate-a-root-token-from-the-recovery-key"></a>

## 从恢复密钥生成根令牌

当您需要执行极狐GitLab 无法代您执行的特权 OpenBao 操作时，请生成根令牌。根令牌对所有 OpenBao 操作和命名空间拥有不受限制的访问权限。

先决条件：

- 有权在 toolbox pod 和 OpenBao pod 中运行 `kubectl exec`。
- 一个您通过 `recovery_key:store` 存储的恢复密钥，或在运行
  `recovery_key:fetch` 后保存的恢复密钥。
- 从极狐GitLab 到 OpenBao 的正常认证。如果认证失败，请参阅
  [JWT 认证失败](troubleshooting.md#jwt-authentication-fails)。

要生成根令牌：

1. 运行 Rake 任务：

   ```shell
   kubectl exec -n gitlab -it -c toolbox <toolbox-pod-name> -- \
     gitlab-rake "gitlab:secrets_management:openbao:root_token:generate"
   ```

1. 当任务要求确认时，输入 `y`。如果您通过
   `recovery_key:store` 存储了恢复密钥，该任务将使用已存储的密钥。否则，请输入恢复密钥。该任务在您输入密钥时不会显示密钥。

   如果另一个根令牌生成操作已在进行中，该任务会询问是否取消现有的生成操作并开始新的生成操作。要继续，请输入 `y`。

   该任务会显示根令牌。在以下步骤中，请用此值替换 `<root_token>`。

1. 获取 OpenBao pod 名称：

   ```shell
   kubectl get pods -n gitlab -l app.kubernetes.io/name=openbao -o name | head -1
   ```

   在以下步骤中，请用此命令的输出替换 `<openbao-pod-name>`。
   例如，`pod/gitlab-openbao-5c6dfc987d-b2wtb`。

1. 验证根令牌是否可用：

   ```shell
   kubectl exec -n gitlab <openbao-pod-name> -- \
     sh -c "BAO_ADDR=http://127.0.0.1:8200 BAO_TOKEN=<root_token> bao token lookup"
   ```

   成功的响应会包含 `policies  [root]`。

1. 执行所需的特权操作。
   例如，要更改 ACL 策略，请将该策略保存到文件，编辑该文件，然后将该文件写回 OpenBao：

   ```shell
   kubectl exec -n gitlab <openbao-pod-name> -- \
     sh -c "BAO_ADDR=http://127.0.0.1:8200 BAO_TOKEN=<root_token> bao policy read <policy-name>" \
     > <policy-name>.hcl
   kubectl exec -i -n gitlab <openbao-pod-name> -- \
     sh -c "BAO_ADDR=http://127.0.0.1:8200 BAO_TOKEN=<root_token> bao policy write <policy-name> -" \
     < <policy-name>.hcl
   ```

   `-i` 标志通过标准输入将编辑后的文件传递给 `bao policy write`。

1. 撤销根令牌，因为根令牌不会过期：

   ```shell
   kubectl exec -n gitlab <openbao-pod-name> -- \
     sh -c "BAO_ADDR=http://127.0.0.1:8200 BAO_TOKEN=<root_token> bao token revoke -self"
   ```
