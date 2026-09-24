---
stage: Runtime
group: Cells Infrastructure
info: Any user with the Maintainer or Owner role can merge updates to this content. For details, see <https://gitlab.cn/docs/development/development_processes/#development-guidelines-review>.
title: 单元
description: Configure and test 极狐GitLab Cells functionality for JihuLab.com administrators as part of functionality testing, including enabling Cell instances and configuring topology service clients.
---

{{< details >}}

- Offering: JihuLab.com
- Status: 实验性

{{< /details >}}

> [!disclaimer]

要测试单元功能，可以配置极狐GitLab Rails 控制台。

> [!note]
> 此功能仅适用于 JihuLab.com 的管理员。此功能不适用于私有化部署实例。
>
> Cells 1.0 正在开发中。有关 cell 开发状态的更多信息，请参见[史诗 12383](https://gitlab.com/groups/gitlab-org/-/epics/12383)。

<a id="configuration"></a>

## 配置

要将你的极狐GitLab 实例配置为单元实例：

{{< tabs >}}

{{< tab title="自编译（源代码）" >}}

`config/gitlab.yml` 中与单元相关的配置采用以下格式：

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

{{< tab title="Linux 软件包 (Omnibus)" >}}

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
| `cell.enabled`                                  | `false`                                               | 配置实例是否为单元。`false` 表示所有单元功能均禁用。`session_cookie_prefix_token` 不受影响，可单独设置。                                                                                                                                                    |
| `cell.id`                                       | `nil`                                                 | 当 `cell.enabled` 为 `true` 时，必须为正整数。否则必须为 `nil`。这是集群中单元的唯一整数标识符。此 ID 用于路由令牌内部。当 `cell.id` 为 `nil` 时，路由令牌中的其他属性（如 `organization_id` ）仍会被使用。 |
| `cell.database.skip_sequence_alteration`        | `false`                                               | 当为 `true` 时，跳过单元的数据库序列变更。在单体单元可用之前，为旧版单元（`cell-1`）启用此功能，此功能的跟踪情况见史诗：[阶段 6：单体单元](https://gitlab.com/groups/gitlab-org/-/epics/14513)。                                                                   |
| `cell.topology_service_client.address`          | `"topology-service.gitlab.example.com:443"`           | 当 `cell.enabled` 为 `true` 时必需。拓扑服务服务器的地址和端口。                                                                                                                                                                                                                                       |
| `cell.topology_service_client.tls.enabled`      | `true`                                                | 当为 `true` 时，启用 mTLS 与拓扑服务通信。这需要正确配置 `cell.topology_service_client.tls.secret`。如果设置为 `false`，连接将在没有 TLS 加密的情况下进行。                                                                                           |
| `cell.topology_service_client.tls.secret`       | `nil`                                                 | [Kubernetes TLS 密钥](https://kubernetes.io/docs/reference/kubectl/generated/kubectl_create/kubectl_create_secret_tls/) 名称，包含 mTLS 凭证。启用 TLS 时必需。该密钥必须包含 `tls.crt` 和 `tls.key` 键。如果未明确设置，默认为 `<release.name>-topology-tls`。此密钥 **必须手动创建**；Helm chart 不会自动创建它。                |

<a id="related-configuration"></a>

## 相关配置

有关如何配置单元架构其他组件的信息，请参见：

1. [拓扑服务配置](https://jihulab.com/gitlab-cn/cells/topology-service/-/blob/main/docs/config.md?ref_type=heads)
1. [HTTP 路由器配置](https://jihulab.com/gitlab-cn/cells/http-router/-/blob/main/docs/config.md?ref_type=heads)