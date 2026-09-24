---
stage: Create
group: Remote Development
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Create a 极狐GitLab workspaces proxy to authenticate and authorize workspaces in your cluster.
title: 故障排查工作空间
---

在使用极狐GitLab 工作空间时，你可能会遇到以下问题。

<a id="error-failed-to-renew-lease"></a>

## 错误：`无法续约租约`

创建工作空间时，你可能会在 agent 日志中看到以下错误消息：

```plaintext
{"level":"info","time":"2023-01-01T00:00:00.000Z","msg":"无法续约租约 gitlab-agent-remote-dev-dev/agent-123XX-lock：等待条件超时\n","agent_id":XXXX}
```

此错误是由于 Kubernetes 的极狐GitLab agent 中的一个已知问题引起的。当 agent 实例无法续约其领导租约时，会导致仅限领导者的模块（如 `remote_development`）关闭。

要解决此问题：

1. 重启 agent 实例。
1. 如果问题仍然存在，请检查 Kubernetes 集群的健康状况和连接性。

<a id="error-workspace-create-failed-expiration-date-must-be-before-date"></a>

## 错误：`工作空间创建失败：到期日期必须在 <date> 之前`

创建工作空间时，你可能会在 UI 中遇到此错误：

```plaintext
工作空间创建失败：到期日期必须在 <date> 之前
```

当为新创建的工作空间[创建用于认证的个人访问令牌](_index.md#personal-access-token)的到期日期超过了实例的令牌到期设置时，会发生此错误。

要解决此问题，请禁用实例的[访问令牌到期限制](../../administration/settings/account_and_limit_settings.md#limit-the-lifetime-of-access-tokens)。[议题 579331](https://jihulab.com/gitlab-cn/gitlab/-/work_items/579331) 提议为工作空间相关令牌设置可配置的限制，以解决此限制。

<a id="error-no-agents-available-to-create-workspaces"></a>

## 错误：`没有可用的 agent 来创建工作空间`

在项目中创建工作空间时，你可能会收到以下错误：

```plaintext
没有可用的 agent 来创建工作空间。请参考工作空间文档进行故障排查。
```

此错误可能由多种原因引起。请按照以下故障排查步骤操作。

<a id="check-permissions"></a>

### 检查权限

1. 确保你在工作空间项目和 agent 项目中拥有开发者、维护者或所有者角色。
1. 验证 agent 是否在工作空间项目的上级群组中被允许。

更多信息，请参阅[允许 agent](gitlab_agent_configuration.md#allow-a-cluster-agent-for-workspaces-in-a-group)。

<a id="check-agent-configuration"></a>

### 检查 agent 配置

验证 agent 配置中是否启用了 `remote_development` 模块：

```yaml
remote_development:
  enabled: true
```

如果 Kubernetes 的极狐GitLab agent 的 `remote_development` 模块被禁用，请将 [`enabled`](settings.md#enabled) 设置为 `true`。

<a id="check-agent-name-mismatch"></a>

### 检查 agent 名称不匹配

确保在[创建 Kubernetes 的极狐GitLab agent 令牌](set_up_infrastructure.md#create-a-gitlab-agent-for-kubernetes-token)步骤中创建的 agent 名称与 `.gitlab/agents/FOLDER_NAME/` 中的文件夹名称匹配。

如果名称不同，请重命名文件夹以完全匹配 agent 名称。

<a id="check-agent-connection-status"></a>

### 检查 agent 连接状态

验证 agent 是否已连接到极狐GitLab：

1. 前往你的群组。
1. 选择 **运维** > **Kubernetes 集群**。
1. 验证 **连接状态** 是否为 **已连接**。如果未连接，请检查 agent 日志：

   ```shell
   kubectl logs -f -l app=gitlab-agent -n gitlab-workspaces
   ```

<a id="error-unsupported-scheme-in-kas-address"></a>

## 错误：`kas 地址中的方案不受支持`

当极狐GitLab Relay (KAS) 地址缺少必需的协议方案时，会发生此错误。

要解决此问题：

1. 在你的 `TF_VAR_kas_address` 变量中添加 `wss://` 前缀。例如：`wss://kas.jihulab.com`。
1. 更新配置并重新部署 agent。

<a id="error-imagepullbackoff-when-starting-workspace-in-offline-environment"></a>

## 错误：离线环境中启动工作空间时出现 `ImagePullBackOff`

在离线环境中创建工作空间时，你可能会看到此错误：

```plaintext
workspace-example-abc123-def456   0/1   Init:ImagePullBackOff   0
```

当工作空间无法从 `registry.jihulab.com` 拉取初始化容器镜像时，会发生此错误。在离线环境中，初始化容器镜像是硬编码的，无法通过 devfile 覆盖。

> [!warning]
> 以下解决方法不受支持且是临时的。请自行承担风险，直到[议题 509983](https://jihulab.com/gitlab-cn/gitlab/-/issues/509983) 提供受支持的解决方案。

解决方法如下：

1. 部署一个 [Kubernetes 变更 webhook](https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/) 来修改初始化容器镜像引用。
1. 确保你拥有集群管理员权限，可以创建、更新或删除 `MutatingWebhookConfiguration`。

有关示例实现，请参阅[一个简单的 Kubernetes 准入 Webhook](https://slack.engineering/simple-kubernetes-webhook/)。

<!--- Other suggested topics:

## DNS configuration

## Workspace stops unexpectedly

## Workspace creation fails due to quotas

## Network connectivity

## SSH connection failures

### Network policy restrictions

-->