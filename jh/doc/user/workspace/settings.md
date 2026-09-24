---
stage: Create
group: Remote Development
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Configure the GitLab agent for Kubernetes to support workspaces.
title: 工作空间设置
---

工作空间设置配置了极狐GitLab Kubernetes 代理如何在您的 Kubernetes 集群中管理远程开发环境。这些设置控制：

- 资源分配
- 安全性
- 网络
- 生命周期管理

<a id="set-up-a-basic-workspace-configuration"></a>

## 设置基本的工作空间配置

要设置基本的工作空间配置：

1. 打开您的配置 YAML 文件。
1. 添加以下最低要求设置：

   ```yaml
   remote_development:
     enabled: true
     dns_zone: "<workspaces.example.dev>"
   ```

1. 提交更改。

如果您的工作空间配置无效，请参见[故障排除工作空间](workspaces_troubleshooting.md)。

> [!note]
> 如果某个设置的值无效，那么在修复该值之前，无法更新任何设置。
> 除了 `enabled` 之外，更新这些设置中的任何一个都不会影响现有的工作空间。

<a id="configuration-reference"></a>

## 配置参考

| 设置 | 描述 | 格式 | 默认值 | 必填 |
|------|------|------|--------|------|
| [`enabled`](#enabled) | 指示是否为极狐GitLab Kubernetes 代理启用远程开发。 | 布尔值 | `false` | 是 |
| [`dns_zone`](#dns_zone) | 工作空间可用的 DNS 区域。 | 字符串。有效的 DNS 格式。 | 无 | 是 |
| [`gitlab_workspaces_proxy`](#gitlab_workspaces_proxy) | 安装 [`gitlab-workspaces-proxy`](set_up_gitlab_agent_and_proxies.md) 的命名空间。 | 字符串。有效的 Kubernetes 命名空间名称。 | `gitlab-workspaces` | 否 |
| [`network_policy`](#network_policy) | 工作空间的防火墙规则。 | 包含 `enabled` 和 `egress` 字段的对象。 | 参见 [`network_policy`](#network_policy) | 否 |
| [`default_resources_per_workspace_container`](#default_resources_per_workspace_container) | 每个工作空间容器的 CPU 和内存的默认请求和限制。 | 具有 CPU 和内存的 `requests` 和 `limits` 的对象。 | `{}` | 否 |
| [`max_resources_per_workspace`](#max_resources_per_workspace) | 每个工作空间的 CPU 和内存的最大请求和限制。 | 具有 CPU 和内存的 `requests` 和 `limits` 的对象。 | `{}` | 否 |
| [`workspaces_quota`](#workspaces_quota) | 极狐GitLab Kubernetes 代理的最大工作空间数量。 | 整数 | `-1` | 否 |
| [`workspaces_per_user_quota`](#workspaces_per_user_quota) | 每个用户的最大工作空间数量。 | 整数 | `-1` | 否 |
| [`use_kubernetes_user_namespaces`](#use_kubernetes_user_namespaces) | 指示是否在 Kubernetes 中使用用户命名空间。 | 布尔值：`true` 或 `false` | `false` | 否 |
| [`default_runtime_class`](#default_runtime_class) | 默认的 Kubernetes `RuntimeClass`。 | 字符串。有效的 `RuntimeClass` 名称。 | `""` | 否 |
| [`allow_privilege_escalation`](#allow_privilege_escalation) | 允许特权提升。 | 布尔值 | `false` | 否 |
| [`image_pull_secrets`](#image_pull_secrets) | 用于拉取工作空间私有镜像的现有 Kubernetes 密钥。 | 包含 `name` 和 `namespace` 字段的对象数组。 | `[]` | 否 |
| [`annotations`](#annotations) | 应用于 Kubernetes 对象的注解。 | 键值对映射。有效的 Kubernetes 注解格式。 | `{}` | 否 |
| [`labels`](#labels) | 应用于 Kubernetes 对象的标签。 | 键值对映射。有效的 Kubernetes 标签格式。 | `{}` | 否 |
| [`max_active_hours_before_stop`](#max_active_hours_before_stop) | 工作空间在停止前可以处于活跃状态的最大小时数。 | 整数 | `36` | 否 |
| [`max_stopped_hours_before_termination`](#max_stopped_hours_before_termination) | 工作空间在终止前可以处于停止状态的最大小时数。 | 整数 | `744` | 否 |
| [`shared_namespace`](#shared_namespace) | 指示是否使用共享的 Kubernetes 命名空间。 | 字符串 | `""` | 否 |

<a id="enabled"></a>

### `enabled`

使用此设置来定义是否：

- 极狐GitLab Kubernetes 代理可以与极狐GitLab 实例通信。
- 您可以使用极狐GitLab Kubernetes 代理[创建工作空间](configuration.md#create-a-workspace)。

默认值为 `false`。

要在代理配置中启用远程开发，请将 `enabled` 设置为 `true`：

```yaml
remote_development:
  # NOTE: This is a partial example.
  # Some required fields are not included.
  enabled: true
```

> [!note]
> 如果为具有活动或已停止工作空间的代理将 `enabled` 设置为 `false`，
> 这些工作空间将变为孤立且无法使用。
>
> 在代理上禁用远程开发之前：
>
> - 确保所有关联的工作空间不再需要。
> - 手动删除任何正在运行的工作空间，以将其从 Kubernetes 集群中移除。

<a id="dns_zone"></a>

### `dns_zone`

使用此设置来定义工作空间所在 URL 的 DNS 区域。

示例配置：

```yaml
remote_development:
  # NOTE: This is a partial example.
  # Some required fields are not included.
  dns_zone: "<workspaces.example.dev>"
```

<a id="gitlab_workspaces_proxy"></a>

### `gitlab_workspaces_proxy`

使用此设置来定义安装 [`gitlab-workspaces-proxy`](set_up_gitlab_agent_and_proxies.md) 的命名空间。
`gitlab_workspaces_proxy.namespace` 的默认值为 `gitlab-workspaces`。

示例配置：

```yaml
remote_development:
  # NOTE: This is a partial example.
  # Some required fields are not included.
  gitlab_workspaces_proxy:
    namespace: "<custom-gitlab-workspaces-proxy-namespace>"
```

<a id="network_policy"></a>

### `network_policy`

使用此设置来为每个工作空间定义网络策略。
此设置控制工作空间的网络流量。

默认值为：

```yaml
remote_development:
  # NOTE: This is a partial example.
  # Some required fields are not included.
  network_policy:
    enabled: true
    egress:
      - allow: "0.0.0.0/0"
        except:
          - "10.0.0.0/8"
          - "172.16.0.0/12"
          - "192.168.0.0/16"
```

在此配置中：

- 因为 `enabled` 为 `true`，为每个工作空间生成网络策略。
- 出站规则允许所有到互联网 (`0.0.0.0/0`) 的流量，但排除 IP CIDR 范围 `10.0.0.0/8`、`172.16.0.0/12` 和 `192.168.0.0/16`。

网络策略的行为取决于 Kubernetes 网络插件。
更多信息，请参见[Kubernetes 文档](https://kubernetes.io/docs/concepts/services-networking/network-policies/)。

<a id="network_policy.enabled"></a>

#### `network_policy.enabled`

使用此设置来定义是否为每个工作空间生成网络策略。
`network_policy.enabled` 的默认值为 `true`。

<a id="network_policy.egress"></a>

#### `network_policy.egress`

{{< history >}}

- 于极狐GitLab 16.7 引入。

{{< /history >}}

使用此设置来定义一个允许作为工作空间出站目的地的 IP CIDR 范围列表。

在以下情况下定义出站规则：

- 极狐GitLab 实例位于私有 IP 范围上。
- 工作空间必须访问私有 IP 范围上的云资源。

列表中的每个元素定义一个 `allow` 属性，并带有一个可选的 `except` 属性。`allow` 定义允许流量的 IP 范围。`except` 列出要从 `allow` 范围中排除的 IP 范围。

示例配置：

```yaml
remote_development:
  # NOTE: This is a partial example.
  # Some required fields are not included.
  network_policy:
    egress:
      - allow: "0.0.0.0/0"
        except:
          - "10.0.0.0/8"
          - "172.16.0.0/12"
          - "192.168.0.0/16"
      - allow: "172.16.123.1/32"
```

在这个示例中，允许来自工作空间的流量，如果：

- 目标 IP 是除 `10.0.0.0/8`、`172.16.0.0/12` 或 `192.168.0.0/16` 之外的任何范围。
- 目标 IP 是 `172.16.123.1/32`。

<a id="default_resources_per_workspace_container"></a>

### `default_resources_per_workspace_container`

{{< history >}}

- 于极狐GitLab 16.8 引入。

{{< /history >}}

使用此设置来定义每个工作空间容器的默认 [requests 和 limits](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#requests-and-limits)（针对 CPU 和内存）。您在 [devfile](_index.md#devfile) 中定义的任何资源都会覆盖此设置。

对于 `default_resources_per_workspace_container`，`requests` 和 `limits` 是必需的。有关可能的 CPU 和内存值的更多信息，请参见 [Kubernetes 中的资源单位](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#resource-units-in-kubernetes)。

示例配置：

```yaml
remote_development:
  # NOTE: This is a partial example.
  # Some required fields are not included.
  default_resources_per_workspace_container:
    requests:
      cpu: "0.5"
      memory: "512Mi"
    limits:
      cpu: "1"
      memory: "1Gi"
```

<a id="max_resources_per_workspace"></a>

### `max_resources_per_workspace`

{{< history >}}

- 于极狐GitLab 16.8 引入。

{{< /history >}}

使用此设置来定义每个工作空间的 CPU 和内存的最大 [requests 和 limits](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#requests-and-limits)。

对于 `max_resources_per_workspace`，`requests` 和 `limits` 是必需的。有关可能的 CPU 和内存值的更多信息，请参见：

- [Kubernetes 中的资源单位](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#resource-units-in-kubernetes)
- [资源配额](https://kubernetes.io/docs/concepts/policy/resource-quotas/)

当工作空间超过您为 `requests` 和 `limits` 设置的值时，它们会失败。

> [!note]
> 如果设置了 [`shared_namespace`](#shared_namespace)，则 `max_resources_per_workspace` 必须是一个空哈希。用户可以在 `shared_namespace` 中创建一个 Kubernetes [资源配额](https://kubernetes.io/docs/concepts/policy/resource-quotas/) 来达到与此处指定此值相同的结果。

示例配置：

```yaml
remote_development:
  # NOTE: This is a partial example.
  # Some required fields are not included.
  max_resources_per_workspace:
    requests:
      cpu: "1"
      memory: "1Gi"
    limits:
      cpu: "2"
      memory: "2Gi"
```

您定义的最大资源必须包含 init 容器执行启动操作（例如克隆项目仓库）所需的任何资源。

<a id="workspaces_quota"></a>

### `workspaces_quota`

{{< history >}}

- 于极狐GitLab 16.9 引入。

{{< /history >}}

使用此设置来设置极狐GitLab Kubernetes 代理的最大工作空间数量。

在以下情况下，无法为代理创建新的工作空间：

- 代理的工作空间数量已达到定义的 `workspaces_quota`。
- `workspaces_quota` 设置为 `0`。

如果 `workspaces_quota` 设置为低于代理的非终止工作空间数量的值，则代理的工作空间不会自动终止。

默认值为 `-1`（无限制）。可能的值为大于或等于 `-1`。

示例配置：

```yaml
remote_development:
  # NOTE: This is a partial example.
  # Some required fields are not included.
  workspaces_quota: 10
```

<a id="workspaces_per_user_quota"></a>

### `workspaces_per_user_quota`

{{< history >}}

- 于极狐GitLab 16.9 引入。

{{< /history >}}

使用此设置来设置每个用户的最大工作空间数量。

在以下情况下，无法为用户创建新的工作空间：

- 用户的工作空间数量已达到定义的 `workspaces_per_user_quota`。
- `workspaces_per_user_quota` 设置为 `0`。

如果 `workspaces_per_user_quota` 设置为低于用户的非终止工作空间数量的值，则用户的工作空间不会自动终止。

默认值为 `-1`（无限制）。可能的值为大于或等于 `-1`。

示例配置：

```yaml
remote_development:
  # NOTE: This is a partial example.
  # Some required fields are not included.
  workspaces_per_user_quota: 3
```

<a id="use_kubernetes_user_namespaces"></a>

### `use_kubernetes_user_namespaces`

{{< history >}}

- 于极狐GitLab 17.4 引入。

{{< /history >}}

使用此设置来指定是否在 Kubernetes 中使用用户命名空间功能。

[用户命名空间](https://kubernetes.io/docs/concepts/workloads/pods/user-namespaces/) 将容器内部运行的用户与主机上的用户隔离。

默认值为 `false`。在将值设置为 `true` 之前，请确保您的 Kubernetes 集群支持用户命名空间。

示例配置：

```yaml
remote_development:
  # NOTE: This is a partial example.
  # Some required fields are not included.
  use_kubernetes_user_namespaces: true
```

有关 `use_kubernetes_user_namespaces` 的更多信息，请参见[用户命名空间](https://kubernetes.io/docs/concepts/workloads/pods/user-namespaces/)。

<a id="default_runtime_class"></a>

### `default_runtime_class`

{{< history >}}

- 于极狐GitLab 17.4 引入。

{{< /history >}}

使用此设置来选择用于运行工作空间中容器的容器运行时配置。

默认值为 `""`，表示不存在值。

示例配置：

```yaml
remote_development:
  # NOTE: This is a partial example.
  # Some required fields are not included.
  default_runtime_class: "example-runtime-class-name"
```

一个有效的值：

- 包含不超过 253 个字符。
- 只包含小写字母、数字、`-` 或 `.`。
- 以字母数字字符开头。
- 以字母数字字符结尾。

有关 `default_runtime_class` 的更多信息，请参见[运行时类](https://kubernetes.io/docs/concepts/containers/runtime-class/)。

<a id="allow_privilege_escalation"></a>

### `allow_privilege_escalation`

{{< history >}}

- 于极狐GitLab 17.4 引入。

{{< /history >}}

使用此设置来控制进程是否可以获得比其父进程更多的特权。

此设置直接控制是否在容器进程上设置 [`no_new_privs`](https://www.kernel.org/doc/Documentation/prctl/no_new_privs.txt) 标志。

默认值为 `false`。仅当满足以下任一条件时，才能将该值设置为 `true`：

- [`default_runtime_class`](#default_runtime_class) 设置为非空值。
- [`use_kubernetes_user_namespaces`](#use_kubernetes_user_namespaces) 设置为 `true`。

示例配置：

```yaml
remote_development:
  # NOTE: This is a partial example.
  # Some required fields are not included.
  default_runtime_class: "example-runtime-class-name"
  allow_privilege_escalation: true
```

有关 `allow_privilege_escalation` 的更多信息，请参见[为 Pod 或容器配置安全上下文](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/)。

<a id="image_pull_secrets"></a>

### `image_pull_secrets`

{{< history >}}

- 于极狐GitLab 17.6 引入。

{{< /history >}}

使用此设置来指定类型为 `kubernetes.io/dockercfg` 或 `kubernetes.io/dockerconfigjson` 的现有 Kubernetes 密钥，工作空间拉取私有镜像时需要这些密钥。

默认值为 `[]`。

示例配置：

```yaml
remote_development:
  # NOTE: This is a partial example.
  # Some required fields are not included.
  image_pull_secrets:
    - name: "image-pull-secret-name"
      namespace: "image-pull-secret-namespace"
```

在此示例中，来自命名空间 `image-pull-secret-namespace` 的密钥 `image-pull-secret-name` 会被同步到工作空间的命名空间。

对于 `image_pull_secrets`，`name` 和 `namespace` 属性是必需的。密钥的名称必须是唯一的。如果设置了 [`shared_namespace`](#shared_namespace)，则密钥的命名空间必须与 `shared_namespace` 相同。

如果您指定的密钥在 Kubernetes 集群中不存在，则该密钥将被忽略。当您删除或更新该密钥时，该密钥将在所有引用该密钥的工作空间的命名空间中删除或更新。

<a id="annotations"></a>

### `annotations`

{{< history >}}

- 于极狐GitLab 17.4 引入。

{{< /history >}}

使用此设置将任意的非标识元数据附加到 Kubernetes 对象。

默认值为 `{}`。

示例配置：

```yaml
remote_development:
  # NOTE: This is a partial example.
  # Some required fields are not included.
  annotations:
    "example.com/key": "value"
```

有效的注解键是由两部分组成的字符串：

- 可选。前缀。前缀必须不超过 253 个字符，并且包含由句点分隔的 DNS 标签。前缀必须以斜杠 (`/`) 结尾。
- 名称。名称必须不超过 63 个字符，并且只包含字母数字字符、短划线 (`-`)、下划线 (`_`) 和句点 (`.`)。名称必须以字母数字字符开头和结尾。

您不应使用以 `kubernetes.io` 和 `k8s.io` 结尾的前缀，因为它们保留给 Kubernetes 核心组件。以 `gitlab.com` 结尾的前缀也被保留。

有效的注解值是一个字符串。

有关 `annotations` 的更多信息，请参见[注解](https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/)。

<a id="labels"></a>

### `labels`

{{< history >}}

- 于极狐GitLab 17.4 引入。

{{< /history >}}

使用此设置将任意的标识元数据附加到 Kubernetes 对象。

默认值为 `{}`。

示例配置：

```yaml
remote_development:
  # NOTE: This is a partial example.
  # Some required fields are not included.
  labels:
    "example.com/key": "value"
```

标签键是由两部分组成的字符串：

- 可选。前缀。前缀必须不超过 253 个字符，并且包含由句点分隔的 DNS 标签。前缀必须以斜杠 (`/`) 结尾。
- 名称。名称必须不超过 63 个字符，并且只包含字母数字字符、短划线 (`-`)、下划线 (`_`) 和句点 (`.`)。名称必须以字母数字字符开头和结尾。

您不应使用以 `kubernetes.io` 和 `k8s.io` 结尾的前缀，因为它们保留给 Kubernetes 核心组件。以 `gitlab.com` 结尾的前缀也被保留。

有效的标签值：

- 不超过 63 个字符。值可以为空。
- 以字母数字字符开头和结尾。
- 可以包含短划线 (`-`)、下划线 (`_`) 和句点 (`.`)。

有关 `labels` 的更多信息，请参见[标签](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/)。

<a id="max_active_hours_before_stop"></a>

### `max_active_hours_before_stop`

{{< history >}}

- 于极狐GitLab 17.6 引入。

{{< /history >}}

此设置会在代理的工作空间处于活跃状态达到指定的小时数后自动停止它们。活跃状态是指任何非停止或非终止状态。

此设置的计时器从创建工作空间时开始，并在每次重新启动工作空间时重置。即使工作空间处于错误或失败状态，它也会应用。

默认值为 `36`，即一天半。这样可以避免在用户的典型工作时间内停止工作空间。

示例配置：

```yaml
remote_development:
  # NOTE: This is a partial example.
  # Some required fields are not included.
  max_active_hours_before_stop: 60
```

一个有效的值：

- 是一个整数。
- 大于或等于 `1`。
- 小于或等于 `8760`（一年）。
- `max_active_hours_before_stop` + `max_stopped_hours_before_termination` 必须小于或等于 `8760`。

自动停止仅在完全协调时触发，该协调每小时发生一次。这意味着工作空间可能比配置的值多活跃一个小时。

<a id="max_stopped_hours_before_termination"></a>

### `max_stopped_hours_before_termination`

{{< history >}}

- 于极狐GitLab 17.6 引入。

{{< /history >}}

使用此设置可在代理的工作空间处于停止状态达到指定的小时数后自动终止它们。

默认值为 `722`，即大约一个月。

示例配置：

```yaml
remote_development:
  # NOTE: This is a partial example.
  # Some required fields are not included.
  max_stopped_hours_before_termination: 4332
```

一个有效的值：

- 是一个整数。
- 大于或等于 `1`。
- 小于或等于 `8760`（一年）。
- `max_active_hours_before_stop` + `max_stopped_hours_before_termination` 必须小于或等于 `8760`。

自动终止仅在完全协调时触发，该协调每小时发生一次。这意味着工作空间可能比配置的值多停止一个小时。

<a id="shared_namespace"></a>

### `shared_namespace`

{{< history >}}

- 于极狐GitLab 18.0 引入。

{{< /history >}}

使用此设置来指定所有工作空间的共享 Kubernetes 命名空间。

默认值为 `""`，这将为每个新工作空间创建其自己的单独的 Kubernetes 命名空间。

当您指定一个值时，所有工作空间都位于该 Kubernetes 命名空间中，而不是单独的命名空间。

为 `shared_namespace` 设置值会对 [`image_pull_secrets`](#image_pull_secrets) 和 [`max_resources_per_workspace`](#max_resources_per_workspace) 的可接受值施加限制。

示例配置：

```yaml
remote_development:
  # NOTE: This is a partial example.
  # Some required fields are not included.
  shared_namespace: "example-shared-namespace"
```

一个有效的值：

- 最多包含 63 个字符。
- 只包含小写字母数字字符或 `-`。
- 以字母数字字符开头。
- 以字母数字字符结尾。

有关 Kubernetes 命名空间的更多信息，请参见[命名空间](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)。

<a id="complete-example-configuration"></a>

## 完整示例配置
以下是一个完整的示例配置。
它包含[配置参考](#configuration-reference)中的所有可用设置：

```yaml
remote_development:
  enabled: true
  dns_zone: workspaces.dev.test
  gitlab_workspaces_proxy:
    namespace: "gitlab-workspaces"

  network_policy:
    enabled: true
    egress:
      - allow: "0.0.0.0/0"
        except:
          - "10.0.0.0/8"
          - "172.16.0.0/12"
          - "192.168.0.0/16"

  default_resources_per_workspace_container:
    requests:
      cpu: "0.5"
      memory: "512Mi"
    limits:
      cpu: "1"
      memory: "1Gi"

  max_resources_per_workspace:
    requests:
      cpu: "1"
      memory: "1Gi"
    limits:
      cpu: "2"
      memory: "4Gi"

  workspaces_quota: 10
  workspaces_per_user_quota: 3

  use_kubernetes_user_namespaces: false
  default_runtime_class: "standard"
  allow_privilege_escalation: false

  image_pull_secrets:
    - name: "registry-secret"
      namespace: "default"

  annotations:
    environment: "production"
    team: "engineering"

  labels:
    app: "workspace"
    tier: "development"

  max_active_hours_before_stop: 60
  max_stopped_hours_before_termination: 4332
  shared_namespace: ""
```