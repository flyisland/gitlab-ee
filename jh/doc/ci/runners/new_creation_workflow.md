---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 了解新的极狐GitLab Runner 创建流程，该流程使用 Runner 认证令牌而非旧版注册令牌，以提高 CI/CD Runner 的安全性。
title: 迁移到新的 Runner 注册流程
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

Runner 创建流程使用 Runner 认证令牌来注册 Runner。不推荐使用基于注册令牌的旧版流程。请改用 [Runner 创建流程](https://gitlab.cn/docs/runner/register/#register-with-a-runner-authentication-token)。

<a id="the-new-runner-registration-workflow"></a>

## 新的 Runner 注册流程

对于新的 Runner 注册流程，您需要：

1. 直接在极狐GitLab UI 中[创建 Runner](runners_scope.md)，或以[编程方式](#creating-runners-programmatically)创建。
1. 获取 Runner 认证令牌。
1. 使用该配置注册 Runner 时，使用 Runner 认证令牌而非注册令牌。在多个主机上注册的 Runner 管理器会显示在极狐GitLab UI 中的同一个 Runner 下，但带有用于标识的系统 ID。

新的 Runner 注册流程具有以下优势：

- 保留 Runner 的所有权记录，并尽量减少对用户的影响。
- 新增唯一系统 ID，确保您可以在多个 Runner 之间复用同一个认证令牌。更多信息，请参见[复用极狐GitLab Runner 配置](https://gitlab.cn/docs/runner/fleet_scaling/#reusing-a-gitlab-runner-configuration)。

<a id="prevent-your-runner-registration-workflow-from-breaking"></a>

## 防止您的 Runner 注册流程中断

在极狐GitLab 17.0 及更高版本中，实例管理员或群组所有者可以禁用旧版 Runner 注册流程。更多信息，请参见[在极狐GitLab 17.0 之后使用注册令牌](#using-registration-tokens-after-gitlab-170)。

如果您在未迁移到新流程的情况下注册 Runner，Runner 注册会中断，`gitlab-runner register` 命令会返回 `410 Gone - runner registration disallowed` 错误。

为避免流程中断，您必须：

1. [创建 Runner](runners_scope.md) 并获取认证令牌。
1. 将 Runner 注册流程中的注册令牌替换为认证令牌。

<a id="using-registration-tokens-after-gitlab-170"></a>

## 在极狐GitLab 17.0 之后使用注册令牌

要在极狐GitLab 17.0 之后继续使用注册令牌：

- 在 JihuLab.com 上，您可以在顶级群组设置中手动[启用旧版 Runner 注册流程](runners_scope.md#enable-use-of-runner-registration-tokens-in-projects-and-groups)。
- 在极狐GitLab 私有化部署上，您可以在**管理**区域设置中手动[启用旧版 Runner 注册流程](../../administration/settings/continuous_integration.md#control-runner-registration)。

<a id="impact-on-existing-runners"></a>

## 对现有 Runner 的影响

升级到极狐GitLab 17.0 后，现有 Runner 会照常工作。此变更仅影响新 Runner 的注册。

[极狐GitLab Runner Helm chart](https://gitlab.cn/docs/runner/install/kubernetes/) 会在每次执行作业时生成新的 Runner pod。
对于这些 Runner，请[启用旧版 Runner 注册](#using-registration-tokens-after-gitlab-170)以使用注册令牌。

<a id="changes-to-the-gitlab-runner-register-command-syntax"></a>

## `gitlab-runner register` 命令语法的变更

`gitlab-runner register` 命令接受 Runner 认证令牌而非注册令牌。您可以在**管理**区域的 **Runners** 页面生成令牌。Runner 认证令牌可通过其 `glrt-` 前缀识别。

在极狐GitLab UI 中创建 Runner 时，您需要指定以前由 `gitlab-runner register` 命令提示输入的配置值。

如果您通过以下方式指定 Runner 认证令牌：

- `--token` 命令行选项，则 `gitlab-runner register` 命令不接受这些配置值。
- `--registration-token` 命令行选项，则 `gitlab-runner register` 命令会忽略这些配置值。

| 令牌                                  | 注册命令 |
|----------------------------------------|----------------------|
| Runner 认证令牌            | `gitlab-runner register --token $RUNNER_AUTHENTICATION_TOKEN` |
| Runner 注册令牌（旧版）     | `gitlab-runner register --registration-token $RUNNER_REGISTRATION_TOKEN <runner configuration arguments>` |

认证令牌带有前缀 `glrt-`。

为确保对您的自动化流程影响最小，如果在旧版参数 `--registration-token`中指定了 Runner 认证令牌，会触发[旧版兼容的注册处理](https://gitlab.cn/docs/runner/register/#legacy-compatible-registration-process)。

以前，注册命令需要额外的配置参数：

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

使用 Runner 认证令牌时，您可以在 UI 中创建 Runner 时设置这些属性，注册命令只需要该令牌：

```shell
gitlab-runner register \
    --non-interactive \
    --executor "shell" \
    --url "https://gitlab.com/" \
    --token "REDACTED"
```

<a id="impact-on-autoscaling"></a>

## 对自动扩缩的影响

在 GitLab Runner Operator 或极狐GitLab Runner Helm Chart 等自动扩缩场景中，从 UI 生成的 Runner 认证令牌会取代注册令牌。
这意味着同一个 Runner 配置会在多个作业之间复用，而不是为每个作业创建一个 Runner。该特定 Runner 可以通过 Runner 进程启动时生成的唯一系统 ID 来识别。

<a id="creating-runners-programmatically"></a>

## 以编程方式创建 Runner

您可以使用 [POST /user/runners REST API](../../api/users.md#create-a-runner-linked-to-a-user) 以已认证用户的身份创建 Runner。仅当 Runner 配置是动态的或不可复用时，才应使用此方式。如果 Runner 配置是静态的，您应复用现有 Runner 的认证令牌。

有关如何自动创建和注册 Runner 的说明，请参见教程[自动创建和注册 Runner](../../tutorials/automate_runner_creation/_index.md)。

<a id="installing-gitlab-runner-with-helm-chart"></a>

## 使用 Helm chart 安装极狐GitLab Runner

如果禁用了 Runner 注册令牌，则某些 Runner 配置选项无法在 Runner 注册期间设置。这些选项只能通过以下方式配置：

- 在 UI 中创建 Runner 时。
- 使用 `user/runners` REST API 端点。

在该场景下，[`values.yaml`](https://gitlab.com/gitlab-org/charts/gitlab-runner/-/blob/main/values.yaml)中不支持以下配置选项：

```yaml
## If a runner authentication token is specified in runnerRegistrationToken, the registration will succeed, however the
## other values will be ignored.
runnerRegistrationToken: ""
locked: true
tags: ""
maximumTimeout: ""
runUntagged: true
protected: true
```

对于 Kubernetes 上的极狐GitLab Runner，Helm 部署会将 Runner 认证令牌传递给 Runner 工作 pod 并创建 Runner 配置。
在极狐GitLab 17.0 及更高版本中，如果您在连接到 JihuLab.com 的 Kubernetes 托管 Runner 上使用 `runnerRegistrationToken` 令牌字段，Runner 工作 pod 会在创建期间尝试使用旧版 Registration API 方法。

将无效的 `runnerRegistrationToken` 字段替换为 `runnerToken` 字段。您还必须修改存储在 `secrets`中的 Runner 认证令牌。

在旧版 Runner 注册流程中，字段通过以下方式指定：

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: gitlab-runner-secret
type: Opaque
data:
  runner-registration-token: "REDACTED" # DEPRECATED, set to ""
  runner-token: ""
```

在新的 Runner 注册流程中，您必须改用 `runner-token`：

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: gitlab-runner-secret
type: Opaque
data:
  runner-registration-token: "" # need to leave as an empty string for compatibility reasons
  runner-token: "REDACTED"
```

> [!note]
> 如果您的密钥管理解决方案不允许将 `runner-registration-token` 设置为空字符串，
> 您可以将其设置为任意字符串。当存在 `runner-token` 时，此值会被忽略。

<a id="known-issues"></a>

## 已知问题

<a id="pod-name-is-not-visible-in-runner-details-page"></a>

### Runner 详情页面中不显示 pod 名称

当您使用新注册流程通过 Helm chart 注册 Runner 时，pod 名称不会显示在 Runner 详情页面上。更多信息，请参见[议题 423523](https://gitlab.com/gitlab-org/gitlab/-/issues/423523)。

<a id="runner-authentication-token-does-not-update-when-rotated"></a>

### 轮换时 Runner 认证令牌不会更新

<a id="token-rotation-with-the-same-runner-registered-in-multiple-runner-managers"></a>

#### 在多个 Runner 管理器中注册同一 Runner 时的令牌轮换

当您通过新流程在多个主机上注册 Runner 并启用自动令牌轮换时，只有第一个 Runner 管理器会收到新令牌。其余 Runner 管理器会继续使用无效令牌并断开连接。您必须手动更新这些管理器以使用新令牌。

<a id="token-rotation-in-gitlab-operator"></a>

#### GitLab Operator 中的令牌轮换

通过新流程使用 GitLab Operator 注册 Runner 期间，自定义资源定义中的 Runner 认证令牌在令牌轮换时不会更新。以下情况会发生此问题：

- 您在[由自定义资源定义引用的](https://gitlab.cn/docs/runner/install/operator/#install-gitlab-runner)密钥中使用 Runner 认证令牌（前缀为 `glrt-`）。
- Runner 认证令牌即将过期。
  有关 Runner 认证令牌过期的更多信息，请参见[认证令牌安全](configure_runners.md#authentication-token-security)。

更多信息，请参见[议题 186](https://gitlab.com/gitlab-org/gl-openshift/gitlab-runner-operator/-/issues/186)。
