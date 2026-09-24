---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 迁移至新的 Runner 注册工作流
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

> [!disclaimer]
> 极狐GitLab 16.0 引入了新的 Runner 创建工作流，该工作流使用 Runner 认证令牌来注册 Runner。不推荐使用传统工作流（即使用注册令牌）。请改用 [Runner 创建工作流](https://gitlab.cn/docs/runner/register/#register-with-a-runner-authentication-token)。

关于新工作流当前开发状态的信息，请参阅[史诗 7663](https://jihulab.com/groups/gitlab-cn/-/epics/7663)。

关于新架构的技术设计和原因，请参阅[极狐GitLab Runner 令牌架构](https://handbook.gitlab.com/handbook/engineering/architecture/design-documents/runner_tokens/)。

<a id="the-new-runner-registration-workflow"></a>

## 新的 Runner 注册工作流

在新的 Runner 注册工作流中，你需要：

1. 直接在极狐GitLab UI 中[创建 Runner](runners_scope.md)，或[通过编程方式创建](#creating-runners-programmatically)。
1. 接收一个 Runner 认证令牌。
1. 在注册 Runner 时使用该 Runner 认证令牌代替注册令牌。在多个主机上注册的 Runner 管理器会显示在极狐GitLab UI 中的同一个 Runner 下，但会带有唯一的系统 ID。

新的 Runner 注册工作流具有以下优势：

- 保留 Runner 的所有权记录，并最大程度地减少对用户的影响。
- 通过添加唯一的系统 ID，确保你可以在多个 Runner 之间复用同一个认证令牌。更多信息，请参阅[复用极狐GitLab Runner 配置](https://gitlab.cn/docs/runner/fleet_scaling/#reusing-a-gitlab-runner-configuration)。

<a id="estimated-time-frame-for-planned-changes"></a>

## 计划变更的预计时间框架

- 在极狐GitLab 15.10 及更高版本中，你可以使用新的 Runner 注册工作流。

<a id="prevent-your-runner-registration-workflow-from-breaking"></a>

## 防止 Runner 注册工作流中断

在极狐GitLab 16.11 及更早版本中，你可以使用传统的 Runner 注册工作流。

在极狐GitLab 17.0 及更高版本中，实例管理员或群组所有者可以禁用传统的 Runner 注册工作流。更多信息，请参阅[在极狐GitLab 17.0 之后使用注册令牌](#using-registration-tokens-after-gitlab-170)。

如果你在未迁移到新工作流的情况下注册 Runner，Runner 注册将失败，并且 `gitlab-runner register` 命令会返回 `410 Gone - runner registration disallowed` 错误。

为避免工作流中断，你必须：

1. [创建 Runner](runners_scope.md) 并获取认证令牌。
1. 将 Runner 注册工作流中的注册令牌替换为认证令牌。

<a id="using-registration-tokens-after-gitlab-170"></a>

## 在极狐GitLab 17.0 之后使用注册令牌

要在极狐GitLab 17.0 之后继续使用注册令牌：

- 在 JihuLab.com 上，你可以在顶级群组设置中手动[启用传统的 Runner 注册流程](runners_scope.md#enable-use-of-runner-registration-tokens-in-projects-and-groups)。
- 在私有化部署的极狐GitLab 上，你可以在**管理员**区域设置中手动[启用传统的 Runner 注册流程](../../administration/settings/continuous_integration.md#control-runner-registration)。

<a id="impact-on-existing-runners"></a>

## 对现有 Runner 的影响

升级到极狐GitLab 17.0 后，现有的 Runner 将继续正常工作。此更改仅影响新 Runner 的注册。

[极狐GitLab Runner Helm Chart](https://gitlab.cn/docs/runner/install/kubernetes/) 在每次执行作业时都会生成新的 Runner Pod。对于这些 Runner，请[启用传统的 Runner 注册](#using-registration-tokens-after-gitlab-170)以使用注册令牌。

<a id="changes-to-the-gitlab-runner-register-command-syntax"></a>

## `gitlab-runner register` 命令语法变更

`gitlab-runner register` 命令接受的是 Runner 认证令牌，而不是注册令牌。你可以从**管理员**区域的 **Runners** 页面生成令牌。Runner 认证令牌的前缀为 `glrt-`。

在极狐GitLab UI 中创建 Runner 时，你可以指定配置值，这些配置值以前是由 `gitlab-runner register` 命令提示的命令行选项。

如果你通过以下方式指定 Runner 认证令牌：

- 使用 `--token` 命令行选项，则 `gitlab-runner register` 命令将不接受配置值。
- 使用 `--registration-token` 命令行选项，则 `gitlab-runner register` 命令将忽略配置值。

| 令牌 | 注册命令 |
|----------------------------------------|----------------------|
| Runner 认证令牌 | `gitlab-runner register --token $RUNNER_AUTHENTICATION_TOKEN` |
| Runner 注册令牌（传统） | `gitlab-runner register --registration-token $RUNNER_REGISTRATION_TOKEN <runner configuration arguments>` |

认证令牌的前缀为 `glrt-`。

为了最大程度地减少对自动化工作流的干扰，如果在传统参数 `--registration-token` 中指定了 Runner 认证令牌，则会触发[传统兼容注册处理](https://gitlab.cn/docs/runner/register/#legacy-compatible-registration-process)。

极狐GitLab 15.9 的示例命令：

```shell
gitlab-runner register \
    --non-interactive \
    --executor "shell" \
    --url "https://gitlab.com/" \
    --tag-list "shell,mac,gdk,test" \
    --run-untagged "false" \
    --locked "false" \
    --access-level "not_protected" \
    --registration-token "REDACTED"
```

在极狐GitLab 15.10 及更高版本中，你可以在 UI 中创建 Runner 并设置标签列表、锁定状态和访问级别等属性。在极狐GitLab 15.11 及更高版本中，当指定了带有 `glrt-` 前缀的 Runner 认证令牌时，这些属性不再被 `register` 命令接受为参数。

以下示例显示了新的命令：

```shell
gitlab-runner register \
    --non-interactive \
    --executor "shell" \
    --url "https://gitlab.com/" \
    --token "REDACTED"
```

<a id="impact-on-autoscaling"></a>

## 对自动扩缩容的影响

在自动扩缩容场景中，例如极狐GitLab Runner Operator 或极狐GitLab Runner Helm Chart，从 UI 生成的 Runner 认证令牌将取代注册令牌。这意味着同一 Runner 配置会在作业之间复用，而不再为每个作业创建 Runner。该 Runner 可通过 Runner 进程启动时生成的唯一系统 ID 进行标识。

<a id="creating-runners-programmatically"></a>

## 以编程方式创建 Runner

在极狐GitLab 15.11 及更高版本中，你可以使用 [POST /user/runners REST API](../../api/users.md#create-a-runner-linked-to-a-user) 以认证用户的身份创建 Runner。仅当 Runner 配置是动态或不可复用时，才应使用此方法。如果 Runner 配置是静态的，你应该复用现有 Runner 的 Runner 认证令牌。

有关如何自动化 Runner 创建和注册的说明，请参阅教程[自动化 Runner 创建和注册](../../tutorials/automate_runner_creation/_index.md)。

<a id="installing-gitlab-runner-with-helm-chart"></a>

## 使用 Helm Chart 安装极狐GitLab Runner

当 Runner 注册令牌被禁用时，某些 Runner 配置选项无法在 Runner 注册过程中设置。这些选项只能在以下情况下配置：

- 在 UI 中创建 Runner 时。
- 通过 `user/runners` REST API 端点。

在这种场景下，[`values.yaml`](https://jihulab.com/gitlab-cn/charts/gitlab-runner/-/blob/main/values.yaml) 中不支持以下配置选项：

```yaml
## 如果 runnerRegistrationToken 中指定了 Runner 认证令牌，注册将会成功，但其他值将被忽略。
runnerRegistrationToken: ""
locked: true
tags: ""
maximumTimeout: ""
runUntagged: true
protected: true
```

对于 Kubernetes 上的极狐GitLab Runner，Helm 部署会将 Runner 认证令牌传递给 Runner 工作 Pod，并创建 Runner 配置。在极狐GitLab 17.0 及更高版本中，如果你在挂载到 JihuLab.com 的 Kubernetes 托管 Runner 上使用 `runnerRegistrationToken` 令牌字段，Runner 工作 Pod 在创建过程中会尝试使用传统的注册 API 方法。

请用 `runnerToken` 字段替换无效的 `runnerRegistrationToken` 字段。你还必须修改存储在 `secrets` 中的 Runner 认证令牌。

在传统的 Runner 注册工作流中，字段如下指定：

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: gitlab-runner-secret
type: Opaque
data:
  runner-registration-token: "REDACTED" # 已弃用，设置为 ""
  runner-token: ""
```

在新的 Runner 注册工作流中，你必须改用 `runner-token`：

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: gitlab-runner-secret
type: Opaque
data:
  runner-registration-token: "" # 出于兼容性原因，需要保留为空字符串
  runner-token: "REDACTED"
```

> [!note]
> 如果你的密钥管理解决方案不允许你将 `runner-registration-token` 设置为空字符串，可以将其设置为任意字符串。当 `runner-token` 存在时，此值将被忽略。

<a id="known-issues"></a>

## 已知问题

<a id="pod-name-is-not-visible-in-runner-details-page"></a>

### Pod 名称在 Runner 详情页面中不可见

当你使用新的注册工作流通过 Helm Chart 注册 Runner 时，Pod 名称不会出现在 Runner 详情页面上。

<a id="runner-authentication-token-does-not-update-when-rotated"></a>

### Runner 认证令牌轮换时不更新

<a id="token-rotation-with-the-same-runner-registered-in-multiple-runner-managers"></a>

#### 在同一 Runner 注册到多个 Runner 管理器时的令牌轮换

当你通过新工作流在多个主机上注册 Runner 并启用自动令牌轮换时，只有第一个 Runner 管理器会收到新令牌。其余 Runner 管理器将继续使用无效令牌并断开连接。你必须手动更新这些管理器以使用新令牌。

<a id="token-rotation-in-gitlab-operator"></a>

#### GitLab Operator 中的令牌轮换

通过新工作流使用 GitLab Operator 注册 Runner 时，在令牌轮换期间，自定义资源定义中的 Runner 认证令牌不会更新。这发生在以下情况：

- 你在[自定义资源定义引用的密钥](https://gitlab.cn/docs/runner/install/operator/#install-gitlab-runner)中使用了 Runner 认证令牌（前缀为 `glrt-`）。
- Runner 认证令牌即将过期。有关 Runner 认证令牌过期的更多信息，请参阅[认证令牌安全性](configure_runners.md#authentication-token-security)。

