---
stage: GitLab Delivery
group: Build
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 软件包默认值
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

除非在 `/etc/gitlab/gitlab.rb` 文件中指定了配置，否则软件包将采用如下所述的默认值。

<a id="ports"></a>

## 端口

Linux 软件包默认分配的端口列表见下表：

| 组件                 | 默认开启 | 通信方式 | 替代方式   | 连接端口 |
|:-------------------------:|:-------------:|:----------------:|:-------------:|:----------------|
| GitLab Rails              | 是           | 端口             |               | `80` 或 `443`   |
| GitLab Shell              | 是           | 端口             |               | `22`            |
| PostgreSQL                | 是           | 套接字           | 端口（`5432`） |                 |
| Redis                     | 是           | 套接字           | 端口（`6379`） |                 |
| Puma                      | 是           | 套接字           | 端口（`8080`） |                 |
| GitLab Workhorse          | 是           | 套接字           | 端口（`8181`） |                 |
| NGINX 状态              | 是           | 端口             |               | `8060`          |
| Prometheus                | 是           | 端口             |               | `9090`          |
| Node exporter             | 是           | 端口             |               | `9100`          |
| Redis exporter            | 是           | 端口             |               | `9121`          |
| PostgreSQL exporter       | 是           | 端口             |               | `9187`          |
| PgBouncer exporter        | 否            | 端口             |               | `9188`          |
| GitLab Exporter           | 是           | 端口             |               | `9168`          |
| Sidekiq exporter          | 是           | 端口             |               | `8082`          |
| Sidekiq 健康检查      | 是           | 端口             |               | `8092`          |
| Web exporter              | 否            | 端口             |               | `8083`          |
| Geo PostgreSQL            | 否            | 套接字           | 端口（`5431`） |                 |
| Redis Sentinel            | 否            | 端口             |               | `26379`         |
| 接收邮件            | 否            | 端口             |               | `143`           |
| Elastic search            | 否            | 端口             |               | `9200`          |
| GitLab Pages              | 否            | 端口             |               | `80` 或 `443`   |
| GitLab Registry           | 否*           | 端口             |               | `80`、`443` 或 `5050` |
| GitLab Registry           | 否            | 端口             |               | `5000`          |
| LDAP                      | 否            | 端口             |               | 取决于组件配置 |
| Kerberos                  | 否            | 端口             |               | `8443` 或 `8088` |
| OmniAuth                  | 是           | 端口             |               | 取决于组件配置 |
| SMTP                      | 否            | 端口             |               | `465`           |
| 远程 syslog             | 否            | 端口             |               | `514`           |
| Mattermost                | 否            | 端口             |               | `8065`          |
| Mattermost                | 否            | 端口             |               | `80` 或 `443`   |
| PgBouncer                 | 否            | 端口             |               | `6432`          |
| Consul                    | 否            | 端口             |               | `8300`、`8301`（TCP 和 UDP）、`8500`、`8600`[^additional-service-ports] |
| Patroni                   | 否            | 端口             |               | `8008`          |
| GitLab KAS                | 是           | 端口             |               | `8150`          |
| Gitaly                    | 是           | 套接字           | 端口（`8075`） | `8075` 或 `9999`（TLS） |
| Gitaly exporter           | 是           | 端口             |               | `9236`          |
| Praefect                  | 否            | 端口             |               | `2305` 或 `3305`（TLS） |
| GitLab Workhorse exporter | 是           | 端口             |               | `9229`          |
| Registry exporter         | 否            | 端口             |               | `5001`          |

[^additional-service-ports]: 如果使用额外的 Consul 功能，可能需要开放更多端口。端口列表请参见
    [官方文档](https://developer.hashicorp.com/consul/docs/install/ports#ports-table)。

图例：

- `Component` - 组件名称。
- `On by default` - 组件是否默认运行。
- `Communicates via` - 组件与其他组件的通信方式。
- `Alternative` - 是否可以将组件配置为使用其他类型的通信方式。该类型会连同此情况下使用的默认端口一起列出。
- `Connection port` - 组件进行通信所用的端口。

极狐GitLab 还要求准备好文件系统，用于存储 Git 代码仓库及其他各种文件。

如果您使用 NFS（网络文件系统），文件会通过网络传输，根据具体实现，这需要开放端口 `111` 和
`2049`。

> [!note]
> 在某些情况下，GitLab Registry 会默认自动启用。更多信息，请参见 [GitLab 容器镜像仓库管理](../packages/container_registry.md)。
