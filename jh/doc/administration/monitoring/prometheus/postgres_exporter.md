---
stage: Data Access
group: Database Operations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: PostgreSQL 服务器导出器
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

[PostgreSQL Server Exporter](https://github.com/prometheus-community/postgres_exporter) 允许您导出各种 PostgreSQL 指标。

对于自行编译的安装，您必须自行安装并配置它。

要启用 PostgreSQL Server Exporter：

1. [启用 Prometheus](_index.md#configuring-prometheus)。
1. 编辑 `/etc/gitlab/gitlab.rb` 并启用 `postgres_exporter`：

   ```ruby
   postgres_exporter['enable'] = true
   ```

   如果 PostgreSQL Server Exporter 配置在单独的节点上，请确保本地地址已[列入 `trust_auth_cidr_addresses`](../../postgresql/replication_and_failover.md#network-information)，否则该导出器将无法连接到数据库。

1. 保存文件并[重新配置极狐GitLab](../../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

Prometheus 开始从 `localhost:9187` 下公开的 PostgreSQL Server Exporter 收集性能数据。

<a id="advanced-configuration"></a>

## 高级配置

在大多数情况下，PostgreSQL Server Exporter 使用默认值即可正常工作，您无需更改任何内容。要进一步自定义 PostgreSQL Server Exporter，请使用以下配置选项：

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   # The name of the database to connect to.
   postgres_exporter['dbname'] = 'pgbouncer'
   # The user to sign in as.
   postgres_exporter['user'] = 'gitlab-psql'
   # The user's password.
   postgres_exporter['password'] = ''
   # The host to connect to. Values that start with '/' are for unix domain sockets
   # (default is 'localhost').
   postgres_exporter['host'] = 'localhost'
   # The port to bind to (default is '5432').
   postgres_exporter['port'] = 5432
   # Whether or not to use SSL. Valid options are:
   #   'disable' (no SSL),
   #   'require' (always use SSL and skip verification, this is the default value),
   #   'verify-ca' (always use SSL and verify that the certificate presented by
   #   the server was signed by a trusted CA),
   #   'verify-full' (always use SSL and verify that the certification presented
   #   by the server was signed by a trusted CA and the server host name matches
   #   the one in the certificate).
   postgres_exporter['sslmode'] = 'require'
   # An application_name to fall back to if one isn't provided.
   postgres_exporter['fallback_application_name'] = ''
   # Maximum wait for connection, in seconds. Zero or not specified means wait indefinitely.
   postgres_exporter['connect_timeout'] = ''
   # Cert file location. The file must contain PEM encoded data.
   postgres_exporter['sslcert'] = 'ssl.crt'
   # Key file location. The file must contain PEM encoded data.
   postgres_exporter['sslkey'] = 'ssl.key'
   # The location of the root certificate file. The file must contain PEM encoded data.
   postgres_exporter['sslrootcert'] = 'ssl-root.crt'
   ```

1. 保存文件并[重新配置极狐GitLab](../../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。
