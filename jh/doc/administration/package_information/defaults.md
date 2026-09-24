---
stage: GitLab Delivery
group: Build
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 软件包默认设置
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

除非在 `/etc/gitlab/gitlab.rb` 文件中指定了配置，否则该软件包会采用如下所述的默认设置。

<a id="ports"></a>

## 端口

请参见下表，了解 Linux 软件包默认分配的端口列表：

| 组件                        | 默认开启 | 通信方式   | 替代方式               | 连接端口                                      |
|:---------------------------:|:--------:|:----------:|:----------------------:|:----------------------------------------------|
| 极狐GitLab Rails           | 是       | 端口       |                        | `80` 或 `443`                                 |
| 极狐GitLab Shell           | 是       | 端口       |                        | `22`                                          |
| PostgreSQL                  | 是       | 套接字     | 端口 (`5432`)          |                                               |
| Redis                       | 是       | 套接字     | 端口 (`6379`)          |                                               |
| Puma                        | 是       | 套接字     | 端口 (`8080`)          |                                               |
| 极狐GitLab Workhorse       | 是       | 套接字     | 端口 (`8181`)          |                                               |
| NGINX 状态                  | 是       | 端口       |                        | `8060`                                        |
| Prometheus                  | 是       | 端口       |                        | `9090`                                        |
| Node 导出器                 | 是       | 端口       |                        | `9100`                                        |
| Redis 导出器                | 是       | 端口       |                        | `9121`                                        |
| PostgreSQL 导出器           | 是       | 端口       |                        | `9187`                                        |
| PgBouncer 导出器            | 否       | 端口       |                        | `9188`                                        |
| 极狐GitLab 导出器          | 是       | 端口       |                        | `9168`                                        |
| Sidekiq 导出器              | 是       | 端口       |                        | `8082`                                        |
| Sidekiq 健康检查            | 是       | 端口       |                        | `8092` <sup>1</sup>                           |
| Web 导出器                  | 否       | 端口       |                        | `8083`                                        |
| Geo PostgreSQL              | 否       | 套接字     | 端口 (`5431`)          |                                               |
| Redis Sentinel              | 否       | 端口       |                        | `26379`                                       |
| 接收邮件                    | 否       | 端口       |                        | `143`                                         |
| Elasticsearch               | 否       | 端口       |                        | `9200`                                        |
| 极狐GitLab Pages           | 否       | 端口       |                        | `80` 或 `443`                                 |
| 极狐GitLab 镜像仓库        | 否*      | 端口       |                        | `80`、`443` 或 `5050`                         |
| 极狐GitLab 镜像仓库        | 否       | 端口       |                        | `5000`                                        |
| LDAP                        | 否       | 端口       |                        | 取决于组件配置                                |
| Kerberos                    | 否       | 端口       |                        | `8443` 或 `8088`                              |
| OmniAuth                    | 是       | 端口       |                        | 取决于组件配置                                |
| SMTP                        | 否       | 端口       |                        | `465`                                         |
| 远程 syslog                 | 否       | 端口       |                        | `514`                                         |
| Mattermost                  | 否       | 端口       |                        | `8065`                                        |
| Mattermost                  | 否       | 端口       |                        | `80` 或 `443`                                 |
| PgBouncer                   | 否       | 端口       |                        | `6432`                                        |
| Consul                      | 否       | 端口       |                        | `8300`、`8301`(TCP 和 UDP)、`8500`、`8600` <sup>2</sup> |
| Patroni                     | 否       | 端口       |                        | `8008`                                        |
| 极狐GitLab KAS             | 是       | 端口       |                        | `8150`                                        |
| Gitaly                      | 是       | 套接字     | 端口 (`8075`)          | `8075` 或 `9999` (TLS)                        |
| Gitaly 导出器               | 是       | 端口       |                        | `9236`                                        |
| Praefect                    | 否       | 端口       |                        | `2305` 或 `3305` (TLS)                        |
| 极狐GitLab Workhorse 导出器 | 是       | 端口       |                        | `9229`                                        |
| 镜像仓库导出器              | 否       | 端口       |                        | `5001`                                        |

**脚注**：

1. 如果未设置 Sidekiq 健康检查设置，则它们会默认为 Sidekiq 指标导出器设置。此默认项已被弃用，并计划在极狐GitLab 15.0 中移除。
2. 如果使用额外的 Consul 功能，可能需要开放更多端口。请参阅[官方文档](https://developer.hashicorp.com/consul/docs/install/ports#ports-table)获取列表。

图例：

- `组件` - 组件的名称。
- `默认开启` - 组件是否默认运行。
- `通信方式` - 组件如何与其他组件通信。
- `替代方式` - 是否可以配置组件使用不同类型的通信。其中列出了该情况下使用的默认端口类型。
- `连接端口` - 组件进行通信的端口。

极狐GitLab 还需要一个文件系统来存储 Git 仓库和各种其他文件。

如果您使用 NFS（网络文件系统），文件通过网络传输，根据实现的不同，需要开放端口 `111` 和 `2049`。

> [!note]
> 在某些情况下，默认会自动启用极狐GitLab 镜像仓库。更多信息，请参见[极狐GitLab 容器镜像仓库管理](../packages/container_registry.md)。

