---
stage: Runtime
group: Cells Infrastructure
info: Any user with the Maintainer or Owner role can merge updates to this content. For details, see <https://docs.gitlab.com/development/development_processes/#development-guidelines-review>.
title: Cells
description: 为 JihuLab.com 管理员配置并测试极狐GitLab Cells 功能，作为功能测试的一部分，包括启用 Cell 实例和配置拓扑服务客户端。
---

{{< details >}}

- Offering: JihuLab.com
- Status: 实验

{{< /details >}}

> [!disclaimer]

要测试 Cell 功能，请配置 GitLab Rails 控制台。

> [!note]
> 此功能仅适用于 JihuLab.com 的管理员。此功能不适用于极狐GitLab 私有化部署实例。
>
> Cells 1.0 正在开发中。有关 Cell 开发状态的更多信息，请参见[史诗 12383](https://gitlab.com/groups/gitlab-org/-/work_items/12383)。

<a id="configuration"></a>

## 配置

要将您的极狐GitLab 实例配置为 Cell 实例：

{{< tabs >}}

{{< tab title="自行编译（源代码）" >}}

`config/gitlab.yml`中与 Cells 相关的配置采用以下格式：

```yaml
  cell:
    enabled: true
    id: 1
    database:
      skip_sequence_alteration: false
    topology_service_client:
      address: topology-service.gitlab.example.com:443
      ca_file: /home/git/gitlab/config/topology-service-ca.pem
      certificate_file: /home/git/gitlab/config/topology-service-cert.pem
      private_key_file: /home/git/gitlab/config/topology-service-key.pem
```

{{< /tab >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

1. 编辑 `/etc/gitlab/gitlab.rb` 并添加以下行：

   ```ruby
   gitlab_rails['cell'] = {
     enabled: true,
     id: 1,
     database: {
       skip_sequence_alteration: false
     },
     topology_service_client: {
       enabled: true,
       address: 'topology-service.gitlab.example.com:443',
       ca_file: 'path/to/your/ca/.pem',
       certificate_file: 'path/to/your/cert/.pem',
       private_key_file: 'path/to/your/key/.pem'
     }
   }
   ```

1. 重新配置并重启极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   sudo gitlab-ctl restart
   ```

{{< /tab >}}

{{< tab title="Helm chart" >}}

1. 编辑 `gitlab_values.yaml`：

   ```yaml
   global:
     appConfig:
       cell:
         enabled: true
         id: 1
         database:
           skipSequenceAlteration: false
         topologyServiceClient:
           address: "topology-service.gitlab.example.com:443"
           tls:
             enabled: true
   ```

1. 保存文件并应用新值：

   ```shell
   helm upgrade -f gitlab_values.yaml gitlab gitlab/gitlab
   ```

{{< /tab >}}

{{< /tabs >}}

| 配置                                   | 默认值                                         | 描述                                                                                                                                                                                                                                                                                                                    |
|-------------------------------------------------|-------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `cell.enabled`                                  | `false`                                               | 用于配置该实例是否为 Cell。`false` 表示所有 Cell 功能均已禁用。`session_cookie_prefix_token` 不受影响，可单独设置。                                                                                                                                                    |
| `cell.id`                                       | `nil`                                                 | 当 `cell.enabled` 为 `true` 时，必须为正整数。否则必须为 `nil`。这是该 Cell 在集群中的唯一整数标识符。此 ID 用于可路由令牌内部。当 `cell.id` 为 `nil` 时，可路由令牌内的其他属性（如 `organization_id`）仍会被使用 |
| `cell.database.skip_sequence_alteration`        | `false`                                               | 当为 `true` 时，跳过该 Cell 的数据库序列变更。在单体 Cell 可供使用之前，为旧版 Cell（`cell-1`）启用此选项，相关跟踪见此史诗：[第 6 阶段：单体 Cell](https://gitlab.com/groups/gitlab-org/-/work_items/14513)。                                                                   |
| `cell.topology_service_client.address`          | `"topology-service.gitlab.example.com:443"`           | 当 `cell.enabled` 为 `true` 时必填。拓扑服务服务器的地址和端口。                                                                                                                                                                                                                                       |
| `cell.topology_service_client.tls.enabled`      | `true`                                                | 当为 `true` 时，启用与拓扑服务通信的 mTLS。这要求正确配置 `cell.topology_service_client.tls.secret`。如果设置为 `false`，则连接将在没有 TLS 加密的情况下建立。                                                                                           |
| `cell.topology_service_client.tls.secret`       | `nil`                                                 | 包含 mTLS 凭据的 [Kubernetes TLS 密钥](https://kubernetes.io/docs/reference/kubectl/generated/kubectl_create/kubectl_create_secret_tls/)名称。启用 TLS 时必填。该密钥必须包含 `tls.crt` 和 `tls.key` 键。如果未显式设置，默认为 `<release.name>-topology-tls`。此密钥**必须手动创建**；Helm chart 不会自动创建它。                |

<a id="related-configuration"></a>

## 相关配置

有关如何配置 Cells 架构其他组件的信息，请参见：

1. [拓扑服务配置](https://gitlab.com/gitlab-org/cells/topology-service/-/blob/main/docs/config.md?ref_type=heads)
1. [HTTP 路由器配置](https://gitlab.com/gitlab-org/cells/http-router/-/blob/main/docs/config.md?ref_type=heads)
