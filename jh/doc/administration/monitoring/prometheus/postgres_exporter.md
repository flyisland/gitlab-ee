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

对于自编译安装，您必须自行安装和配置它。

要启用 PostgreSQL Server Exporter：

1. [启用 Prometheus](_index.md#configuring-prometheus)。
1. 编辑 `/etc/gitlab/gitlab.rb` 并启用 `postgres_exporter`：

   ```ruby
   postgres_exporter['enable'] = true
   ```

   如果 PostgreSQL Server Exporter 配置在单独的节点上，请确保本地地址已列入 `trust_auth_cidr_addresses` 中，否则导出器无法连接到数据库。

1. 保存文件并[重新配置极狐GitLab](../../restart_gitlab.md#reconfigure-a-linux-package-installation)以使更改生效。

Prometheus 开始从通过 `localhost:9187` 公开的 PostgreSQL Server Exporter 收集性能数据。

<a id="advanced-configuration"></a>

## 高级配置

在大多数情况下，PostgreSQL Server Exporter 使用默认设置即可，您无需更改任何内容。要进一步自定义 PostgreSQL Server Exporter，请使用以下配置选项：

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   # 要连接的数据库名称。
   postgres_exporter['dbname'] = 'pgbouncer'
   # 登录用户名。
   postgres_exporter['user'] = 'gitlab-psql'
   # 用户密码。
   postgres_exporter['password'] = ''
   # 要连接的主机。以 '/' 开头的值表示 Unix 域套接字（默认为 'localhost'）。
   postgres_exporter['host'] = 'localhost'
   # 绑定的端口（默认为 '5432'）。
   postgres_exporter['port'] = 5432
   # 是否使用 SSL。有效选项：
   #   'disable'（不使用 SSL），
   #   'require'（始终使用 SSL 并跳过验证，这是默认值），
   #   'verify-ca'（始终使用 SSL 并验证服务器证书是否由受信任的 CA 签名），
   #   'verify-full'（始终使用 SSL，验证服务器证书是否由受信任的 CA 签名，并确认服务器主机名与证书中的名称匹配）。
   postgres_exporter['sslmode'] = 'require'
   # 未提供 application_name 时使用的回退值。
   postgres_exporter['fallback_application_name'] = ''
   # 连接超时等待时间（秒）。0 或不指定表示无限等待。
   postgres_exporter['connect_timeout'] = ''
   # 证书文件位置。文件必须包含 PEM 编码数据。
   postgres_exporter['sslcert'] = 'ssl.crt'
   # 密钥文件位置。文件必须包含 PEM 编码数据。
   postgres_exporter['sslkey'] = 'ssl.key'
   # 根证书文件位置。文件必须包含 PEM 编码数据。
   postgres_exporter['sslrootcert'] = 'ssl-root.crt'
   ```

1. 保存文件并[重新配置极狐GitLab](../../restart_gitlab.md#reconfigure-a-linux-package-installation)以使更改生效。