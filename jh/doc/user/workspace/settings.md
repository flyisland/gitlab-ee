---
stage: Create
group: Remote Development
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 配置极狐GitLab Kubernetes Agent 以支持工作区。
title: 工作区设置
---

工作区设置用于配置极狐GitLab Kubernetes Agent 如何在您的 Kubernetes 集群中管理远程开发环境。这些设置控制：

- 资源分配
- 安全性
- 网络
- 生命周期管理

<a id="set-up-a-basic-workspace-configuration"></a>

## 设置基本工作区配置

要设置基本工作区配置：

1. 打开您的配置 YAML 文件。
1. 添加以下最低必需设置：

   ```yaml
   remote_development:
     enabled: true
     dns_zone: "<workspaces.example.dev>"
   ```

1. 提交更改。

如果您的工作区配置无法正常工作，请参阅[故障排除工作区](workspaces_troubleshooting.md)。

> [!note]
> 如果某个设置的值无效，则在修复该值之前无法更新任何设置。
> 更新这些设置中的任何一项（`enabled` 除外）都不会影响现有工作区。

<a id="configuration-reference"></a>

## 配置参考

| 设置                                                                                   | 描述                                                                                   | 格式                                                      | 默认值                           | 必需 |
|-------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------|-------------------------------------------------------------|-----------------------------------------|----------|
| [`enabled`](#enabled)                                                                     | 指示是否为极狐GitLab Kubernetes Agent 启用远程开发。                         | 布尔值                                                     | `false`                                 | 是      |
| [`dns_zone`](#dns_zone)                                                                   | 工作区可用的 DNS 区域。                                                      | 字符串。有效的 DNS 格式。                                   | 无                                    | 是      |
| [`gitlab_workspaces_proxy`](#gitlab_workspaces_proxy)                                     | 安装 [`gitlab-workspaces-proxy`](set_up_gitlab_agent_and_proxies.md)的命名空间。 | 字符串。有效的 Kubernetes 命名空间名称。                    | `gitlab-workspaces`                     | 否       |
| [`network_policy`](#network_policy)                                                       | 工作区的防火墙规则。                                                                | 包含 `enabled` 和 `egress` 字段的对象。            | 请参阅 [`network_policy`](#network_policy) | 否       |
| [`default_resources_per_workspace_container`](#default_resources_per_workspace_container) | 每个工作区容器的 CPU 和内存的默认请求与限制。                       | 包含 CPU 和内存的 `requests` 和 `limits`的对象。     | `{}`                                    | 否       |
| [`max_resources_per_workspace`](#max_resources_per_workspace)                             | 每个工作区的 CPU 和内存的最大请求与限制。                                 | 包含 CPU 和内存的 `requests` 和 `limits`的对象      | `{}`                                    | 否       |
| [`workspaces_quota`](#workspaces_quota)                                                   | 极狐GitLab Kubernetes Agent 的最大工作区数量。                                            | 整数                                                     | `-1`                                    | 否       |
| [`workspaces_per_user_quota`](#workspaces_per_user_quota)                                 | 每个用户的最大工作区数量。                                                        | 整数                                                     | `-1`                                    | 否       |
| [`use_kubernetes_user_namespaces`](#use_kubernetes_user_namespaces)                       | 指示是否在 Kubernetes 中使用用户命名空间。                                       | 布尔值：`true` 或 `false`                                  | `false`                                 | 否       |
| [`default_runtime_class`](#default_runtime_class)                                         | 默认的 Kubernetes `RuntimeClass`。                                                            | 字符串。有效的 `RuntimeClass` 名称。                          | `""`                                    | 否       |
| [`allow_privilege_escalation`](#allow_privilege_escalation)                               | 允许权限提升。                                                                   | 布尔值                                                     | `false`                                 | 否       |
| [`image_pull_secrets`](#image_pull_secrets)                                               | 用于为工作区拉取私有镜像的现有 Kubernetes 密钥。                            | 包含 `name` 和 `namespace` 字段的对象数组。        | `[]`                                    | 否       |
| [`annotations`](#annotations)                                                             | 要应用于 Kubernetes 对象的注解。                                                   | 键值对映射。有效的 Kubernetes 注解格式。 | `{}`                                    | 否       |
| [`labels`](#labels)                                                                       | 要应用于 Kubernetes 对象的标签。                                                        | 键值对映射。有效的 Kubernetes 标签格式       | `{}`                                    | 否       |
| [`max_active_hours_before_stop`](#max_active_hours_before_stop)                           | 工作区在被停止之前可以处于活动状态的最大小时数。                       | 整数                                                     | `36`                                    | 否       |
| [`max_stopped_hours_before_termination`](#max_stopped_hours_before_termination)           | 工作区在被终止之前可以处于停止状态的最大小时数。                   | 整数                                                     | `744`                                   | 否       |
| [`shared_namespace`](#shared_namespace)                                                   | 指示是否使用共享的 Kubernetes 命名空间。                                    | 字符串                                                      | `""`                                    | 否       |

<a id="enabled"></a>

### `enabled`

使用此设置来定义：

- 极狐GitLab Kubernetes Agent 是否可以与极狐GitLab 实例通信。
- 您是否可以使用极狐GitLab Kubernetes Agent[创建工作区](configuration.md#create-a-workspace)。

默认值为 `false`。

要在代理配置中启用远程开发，请将 `enabled` 设置为 `true`：

```yaml
remote_development:
  # NOTE: This is a partial example.
  # Some required fields are not included.
  enabled: true
```

> [!note]
> 如果为具有活动或已停止工作区的代理将 `enabled` 设置为 `false`，
> 这些工作区将变为孤立且无法使用。
>
> 在禁用代理上的远程开发之前：
>
> - 确保所有关联的工作区都不再需要。
> - 手动删除任何正在运行的工作区，以将其从 Kubernetes 集群中移除。

<a id="dns_zone"></a>

### `dns_zone`

使用此设置来定义工作区可用 URL 的 DNS 区域。

示例配置：

```yaml
remote_development:
  # NOTE: This is a partial example.
  # Some required fields are not included.
  dns_zone: "<workspaces.example.dev>"
```

<a id="gitlab_workspaces_proxy"></a>

### `gitlab_workspaces_proxy`

使用此设置来定义安装 [`gitlab-workspaces-proxy`](set_up_gitlab_agent_and_proxies.md)的命名空间。`gitlab_workspaces_proxy.namespace`的默认值为 `gitlab-workspaces`。

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

使用此设置来定义每个工作区的网络策略。此设置控制工作区的网络流量。

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

- 由于 `enabled` 为 `true`，因此会为每个工作区生成网络策略。
- 出站规则允许所有到互联网的流量（`0.0.0.0/0`），但
  IP CIDR 范围 `10.0.0.0/8`、`172.16.0.0/12` 和 `192.168.0.0/16` 除外。

网络策略的行为取决于 Kubernetes 网络插件。有关更多信息，请参阅 [Kubernetes 文档](https://kubernetes.io/docs/concepts/services-networking/network-policies/)。

<a id="network_policyenabled"></a>

#### `network_policy.enabled`

使用此设置来定义是否为每个工作区生成网络策略。`network_policy.enabled`的默认值为 `true`。

<a id="network_policyegress"></a>

#### `network_policy.egress`

使用此设置来定义允许作为工作区出站目标的 IP CIDR 范围列表。

在以下情况下定义出站规则：

- 极狐GitLab 实例位于私有 IP 范围。
- 工作区必须访问私有 IP 范围上的云资源。

列表中的每个元素定义一个 `allow` 属性以及一个可选的 `except` 属性。`allow` 定义允许流量的 IP 范围。`except` 列出要从 `allow` 范围中排除的 IP 范围。

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

在此示例中，如果满足以下条件，则允许来自工作区的流量：

- 目标 IP 为除 `10.0.0.0/8`、`172.16.0.0/12` 或 `192.168.0.0/16` 之外的任何范围。
- 目标 IP 为 `172.16.123.1/32`。

<a id="default_resources_per_workspace_container"></a>

### `default_resources_per_workspace_container`

使用此设置来定义每个工作区容器的 CPU 和内存的默认[请求与限制](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#requests-and-limits)。您在 [devfile](_index.md#devfile)中定义的任何资源都会覆盖此设置。

对于 `default_resources_per_workspace_container`，`requests` 和 `limits` 是必需的。有关可能的 CPU 和内存值的更多信息，请参阅 [Kubernetes 中的资源单位](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#resource-units-in-kubernetes)。

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

使用此设置来定义每个工作区的 CPU 和内存的最大[请求与限制](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#requests-and-limits)。

对于 `max_resources_per_workspace`，`requests` 和 `limits` 是必需的。有关可能的 CPU 和内存值的更多信息，请参阅：

- [Kubernetes 中的资源单位](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#resource-units-in-kubernetes)
- [资源配额](https://kubernetes.io/docs/concepts/policy/resource-quotas/)

当工作区超过您为 `requests` 和 `limits` 设置的值时，工作区会失败。

> [!note]
> 如果设置了 [`shared_namespace`](#shared_namespace)，则 `max_resources_per_workspace` 必须为
> 空哈希。用户可以在 `shared_namespace`中创建 Kubernetes [资源配额](https://kubernetes.io/docs/concepts/policy/resource-quotas/)
> 以达到与此处指定该值相同的效果。

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

您定义的最大资源必须包含 init 容器执行引导操作（例如克隆项目代码仓库）所需的任何资源。

<a id="workspaces_quota"></a>

### `workspaces_quota`

使用此设置来设置极狐GitLab Kubernetes Agent 的最大工作区数量。

在以下情况下，您无法为代理创建新工作区：

- 代理的工作区数量已达到定义的 `workspaces_quota`。
- `workspaces_quota` 设置为 `0`。

如果 `workspaces_quota` 设置为低于代理未终止工作区数量的值，代理的工作区不会自动终止。

默认值为 `-1`（无限制）。可能的值大于或等于 `-1`。

示例配置：

```yaml
remote_development:
  # NOTE: This is a partial example.
  # Some required fields are not included.
  workspaces_quota: 10
```

<a id="workspaces_per_user_quota"></a>

### `workspaces_per_user_quota`

使用此设置来设置每个用户的最大工作区数量。

在以下情况下，您无法为用户创建新工作区：

- 用户的工作区数量已达到定义的 `workspaces_per_user_quota`。
- `workspaces_per_user_quota` 设置为 `0`。

如果 `workspaces_per_user_quota` 设置为低于用户未终止工作区数量的值，用户的工作区不会自动终止。

默认值为 `-1`（无限制）。可能的值大于或等于 `-1`。

示例配置：

```yaml
remote_development:
  # NOTE: This is a partial example.
  # Some required fields are not included.
  workspaces_per_user_quota: 3
```

<a id="use_kubernetes_user_namespaces"></a>

### `use_kubernetes_user_namespaces`

使用此设置来指定是否使用 Kubernetes 中的用户命名空间功能。

[用户命名空间](https://kubernetes.io/docs/concepts/workloads/pods/user-namespaces/)将容器内运行的用户与主机上的用户隔离。

默认值为 `false`。在将该值设置为 `true` 之前，请确保您的 Kubernetes 集群支持用户命名空间。

示例配置：

```yaml
remote_development:
  # NOTE: This is a partial example.
  # Some required fields are not included.
  use_kubernetes_user_namespaces: true
```

有关 `use_kubernetes_user_namespaces`的更多信息，请参阅[用户命名空间](https://kubernetes.io/docs/concepts/workloads/pods/user-namespaces/)。

<a id="default_runtime_class"></a>

### `default_runtime_class`

使用此设置来选择用于运行工作区中容器的容器运行时配置。

默认值为 `""`，表示没有值。

示例配置：

```yaml
remote_development:
  # NOTE: This is a partial example.
  # Some required fields are not included.
  default_runtime_class: "example-runtime-class-name"
```

有效值：

- 包含 253 个字符或更少。
- 仅包含小写字母、数字、`-` 或 `.`。
- 以字母数字字符开头
- 以字母数字字符结尾。

有关 `default_runtime_class`的更多信息，请参阅[运行时类](https://kubernetes.io/docs/concepts/containers/runtime-class/)。

<a id="allow_privilege_escalation"></a>

### `allow_privilege_escalation`

使用此设置来控制进程是否可以获取比其父进程更多的权限。

此设置直接控制是否在容器进程上设置 [`no_new_privs`](https://www.kernel.org/doc/Documentation/prctl/no_new_privs.txt) 标志。

默认值为 `false`。仅当满足以下任一条件时，该值才能设置为 `true`：

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

有关 `allow_privilege_escalation`的更多信息，请参阅[为 Pod 或容器配置安全上下文](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/)。

<a id="image_pull_secrets"></a>

### `image_pull_secrets`

使用此设置来指定工作区拉取私有镜像所需的、类型为 `kubernetes.io/dockercfg`
或 `kubernetes.io/dockerconfigjson`的现有 Kubernetes 密钥。

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

在此示例中，来自命名空间 `image-pull-secret-namespace`的密钥 `image-pull-secret-name` 会同步到工作区的命名空间。

对于 `image_pull_secrets`，`name` 和 `namespace` 属性是必需的。密钥的名称必须唯一。如果设置了 [`shared_namespace`](#shared_namespace)，则密钥的命名空间必须与 `shared_namespace` 相同。

如果您指定的密钥在 Kubernetes 集群中不存在，则该密钥会被忽略。当您删除或更新密钥时，该密钥会在引用它的所有工作区命名空间中被删除或更新。

<a id="annotations"></a>

### `annotations`

使用此设置来为 Kubernetes 对象附加任意非标识性元数据。

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

- 可选。前缀。前缀必须为 253 个字符或更少，并包含以句点分隔的 DNS 标签。前缀必须以斜杠（`/`）结尾。
- 名称。名称必须为 63 个字符或更少，并且仅包含字母数字字符、短横线（`-`）、下划线（`_`）和句点（`.`）。名称必须以字母数字字符开头和结尾。

您不应使用以 `kubernetes.io` 和 `k8s.io` 结尾的前缀，因为它们保留给 Kubernetes 核心组件。以 `gitlab.com` 结尾的前缀也是保留的。

有效的注解值是一个字符串。

有关 `annotations`的更多信息，请参阅[注解](https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/)。

<a id="labels"></a>

### `labels`

使用此设置来为 Kubernetes 对象附加任意标识性元数据。

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

- 可选。前缀。前缀必须为 253 个字符或更少，并包含以句点分隔的 DNS 标签。前缀必须以斜杠（`/`）结尾。
- 名称。名称必须为 63 个字符或更少，并且仅包含字母数字字符、短横线（`-`）、下划线（`_`）和句点（`.`）。名称必须以字母数字字符开头和结尾。

您不应使用以 `kubernetes.io` 和 `k8s.io` 结尾的前缀，因为它们保留给 Kubernetes 核心组件。以 `gitlab.com` 结尾的前缀也是保留的。

有效的标签值：

- 包含 63 个字符或更少。该值可以为空。
- 以字母数字字符开头和结尾。
- 可以包含短横线（`-`）、下划线（`_`）和句点（`.`）。

有关 `labels`的更多信息，请参阅[标签](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/)。

<a id="max_active_hours_before_stop"></a>

### `max_active_hours_before_stop`

此设置会在代理的工作区处于活动状态达到指定小时数后自动停止它们。活动状态是指任何非停止或非终止状态。

此设置的计时器在您创建工作区时启动，并在您每次重启工作区时重置。即使工作区处于错误或失败状态，它也会生效。

默认值为 `36`，即一天半。这样可以避免在用户的典型工作时间内停止工作区。

示例配置：

```yaml
remote_development:
  # NOTE: This is a partial example.
  # Some required fields are not included.
  max_active_hours_before_stop: 60
```

有效值：

- 是一个整数。
- 大于或等于 `1`。
- 小于或等于 `8760`（一年）。
- `max_active_hours_before_stop` + `max_stopped_hours_before_termination` 必须小于或等于 `8760`。

自动停止仅在完整协调时触发，而完整协调每小时发生一次。这意味着工作区的活动时间可能比配置的值最多长一小时。

<a id="max_stopped_hours_before_termination"></a>

### `max_stopped_hours_before_termination`

使用此设置来在代理的工作区处于停止状态达到指定小时数后自动终止它们。

默认值为 `722`，约一个月。

示例配置：

```yaml
remote_development:
  # NOTE: This is a partial example.
  # Some required fields are not included.
  max_stopped_hours_before_termination: 4332
```

有效值：

- 是一个整数。
- 大于或等于 `1`。
- 小于或等于 `8760`（一年）。
- `max_active_hours_before_stop` + `max_stopped_hours_before_termination` 必须小于或等于 `8760`。

自动终止仅在完整协调时触发，而完整协调每小时发生一次。这意味着工作区的停止时间可能比配置的值最多长一小时。

<a id="shared_namespace"></a>

### `shared_namespace`

使用此设置来为所有工作区指定一个共享的 Kubernetes 命名空间。

默认值为 `""`，这会在各自独立的 Kubernetes 命名空间中创建每个新工作区。

当您指定一个值时，所有工作区都存在于该 Kubernetes 命名空间中，而不是各自的命名空间。

为 `shared_namespace` 设置值会对 [`image_pull_secrets`](#image_pull_secrets) 和 [`max_resources_per_workspace`](#max_resources_per_workspace)的可接受值施加限制。

示例配置：

```yaml
remote_development:
  # NOTE: This is a partial example.
  # Some required fields are not included.
  shared_namespace: "example-shared-namespace"
```

有效值：

- 最多包含 63 个字符。
- 仅包含小写字母数字字符或“-”。
- 以字母数字字符开头。
- 以字母数字字符结尾。

有关 Kubernetes 命名空间的更多信息，请参阅[命名空间](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)。

<a id="complete-example-configuration"></a>

## 完整示例配置

以下配置是一个完整的示例配置。它包含[配置参考](#configuration-reference)中的所有可用设置：

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
