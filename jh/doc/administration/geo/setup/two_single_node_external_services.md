---
stage: Tenant Scale
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 为两个单节点站点设置 Geo（使用外部 PostgreSQL 服务）
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

以下指南简要说明了如何为两个单节点站点部署极狐GitLab Geo，该部署使用两个 Linux 软件包实例和外部 PostgreSQL 数据库（如 RDS、Azure Database 或 Google Cloud SQL）。

前提条件：

- 您至少有两个独立运行的极狐GitLab 站点。
  要创建站点，请参见[极狐GitLab 参考架构文档](../../reference_architectures/_index.md)。
  - 一个极狐GitLab 站点作为 **Geo 主站点**。您可以为每个 Geo 站点使用不同大小的参考架构。如果您已经有一个正常运行的极狐GitLab 实例，可以将其用作主站点。
  - 第二个极狐GitLab 站点作为 **Geo 辅助站点**。Geo 支持多个辅助站点。
- Geo 主站点至少拥有一个[极狐GitLab 专业版](https://about.gitlab.com/pricing/)许可证。
  您只需一个许可证即可用于所有站点。
- 确认所有站点都满足[运行 Geo 的要求](../_index.md#requirements-for-running-geo)。

## 为 Linux 软件包（Omnibus）设置 Geo

前提条件：

- 您使用 PostgreSQL 12 或更高版本，
  其中包含[`pg_basebackup` 工具](https://www.postgresql.org/docs/16/app-pgbasebackup.html)。

### 配置主站点

1. SSH 进入您的极狐GitLab 主站点并以 root 身份登录：

   ```shell
   sudo -i
   ```

1. 在 `/etc/gitlab/gitlab.rb` 中添加唯一的 Geo 站点名称：

   ```ruby
   ##
   ## Geo 站点的唯一标识符。参见
   ## https://gitlab.cn/docs/administration/geo_sites/#common-settings
   ##
   gitlab_rails['geo_node_name'] = '<site_name_here>'
   ```

1. 要应用更改，请重新配置主站点：

   ```shell
   gitlab-ctl reconfigure
   ```

1. 将该站点定义为您的主 Geo 站点：

   ```shell
   gitlab-ctl set-geo-primary-node
   ```

   此命令使用 `/etc/gitlab/gitlab.rb` 中定义的 `external_url`。

有关配置示例，请参见[使用外部 PostgreSQL 的完整主站点](#complete-primary-site-with-external-postgresql)。

### 配置要复制的外部数据库

要设置外部数据库，您可以：

- 自己设置[流复制](https://www.postgresql.org/docs/16/warm-standby.html#STREAMING-REPLICATION-SLOTS)（例如 Amazon RDS，或不由 Linux 软件包管理的裸机）。
- 按如下所示手动执行 Linux 软件包安装的配置。

#### 利用云服务商的工具复制主数据库

假设您在 AWS EC2 上设置了一个使用 RDS 的主站点。
您现在可以在不同区域创建一个只读副本，而复制过程由 AWS 管理。请确保根据您的需要设置好网络 ACL（访问控制列表）、子网和安全组，以便辅助 Rails 节点可以访问数据库。

以下说明详细说明了如何为常见云服务商创建只读副本：

- Amazon RDS - [创建只读副本](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_ReadRepl.html#USER_ReadRepl.Create)
- Azure Database for PostgreSQL - [在 Azure Database for PostgreSQL 中创建和管理只读副本](https://learn.microsoft.com/en-us/azure/postgresql/single-server/how-to-read-replicas-portal)
- Google Cloud SQL - [创建只读副本](https://cloud.google.com/sql/docs/postgres/replication/create-replica)

设置好只读副本后，您可以跳至[配置您的辅助站点](#configure-the-secondary-site-to-use-the-external-read-replica)。

### 配置辅助站点以使用外部只读副本

对于 Linux 软件包安装，
[`geo_secondary_role`](https://gitlab.cn/docs/omnibus/roles/#gitlab-geo-roles)
有三个主要功能：

1. 配置副本数据库。
1. 配置跟踪数据库。
1. 启用 [Geo Log Cursor](../_index.md#geo-log-cursor)。

要配置与外部只读副本数据库的连接：

1. SSH 进入您**辅助**站点上的每个 **Rails、Sidekiq 和 Geo Log Cursor** 节点并以 root 身份登录：

   ```shell
   sudo -i
   ```

1. 编辑 `/etc/gitlab/gitlab.rb` 并添加以下内容

   ```ruby
   ##
   ## Geo Secondary role
   ## - 自动配置依赖的标志以启用 Geo
   ##
   roles ['geo_secondary_role']

   # 请注意，这在两个数据库之间共享，
   # 确保在两个数据库中定义相同的密码
   gitlab_rails['db_password'] = '<your_db_password_here>'

   gitlab_rails['db_username'] = 'gitlab'
   gitlab_rails['db_host'] = '<database_read_replica_host>'

   # 禁用捆绑的 Omnibus PostgreSQL，因为我们
   # 正在使用外部 PostgreSQL
   postgresql['enable'] = false
   ```

1. 从
   [使用外部 PostgreSQL 的完整辅助站点](#complete-secondary-site-with-external-postgresql)复制配置示例。
   要应用更改，请保存文件并重新配置极狐GitLab：

   ```shell
   gitlab-ctl reconfigure
   ```

如果您与副本数据库存在连接问题，
请使用以下命令从您的服务器[检查 TCP 连接](../../raketasks/maintenance.md)：

```shell
gitlab-rake gitlab:tcp_check[<replica FQDN>,5432]
```

如果此步骤失败，您可能使用了错误的 IP 地址，或者防火墙可能
阻止访问该站点。请检查 IP 地址，密切关注
公共地址和私有地址之间的区别。
如果存在防火墙，请确保允许辅助站点连接到
主站点的 5432 端口。

#### 手动复制极狐GitLab 密钥值

极狐GitLab 在 `/etc/gitlab/gitlab-secrets.json` 中存储了许多密钥值。
此 JSON 文件在每个站点节点上必须相同。
您必须手动将此密钥文件复制到所有辅助站点，尽管
[议题 3789](https://jihulab.com/gitlab-cn/gitlab/-/issues/3789) 提议更改此行为。

1. SSH 进入您主站点上的 Rails 节点，并执行以下命令：

   ```shell
   sudo cat /etc/gitlab/gitlab-secrets.json
   ```

   这将显示您必须复制的密钥，格式为 JSON。

1. SSH 进入辅助 Geo 站点上的每个节点并以 root 身份登录：

   ```shell
   sudo -i
   ```

1. 备份所有现有密钥：

   ```shell
   mv /etc/gitlab/gitlab-secrets.json /etc/gitlab/gitlab-secrets.json.`date +%F`
   ```

1. 将 `/etc/gitlab/gitlab-secrets.json` 从主站点 Rails 节点复制到每个辅助站点节点。
   您也可以在节点之间复制并粘贴文件内容：

   ```shell
   sudo editor /etc/gitlab/gitlab-secrets.json

   # 粘贴您在主节点上运行的 `cat` 命令的输出
   # 保存并退出
   ```

1. 确保文件权限正确：

   ```shell
   chown root:root /etc/gitlab/gitlab-secrets.json
   chmod 0600 /etc/gitlab/gitlab-secrets.json
   ```

1. 要应用更改，请重新配置每个 Rails、Sidekiq 和 Gitaly 辅助站点节点：

   ```shell
   gitlab-ctl reconfigure
   gitlab-ctl restart
   ```

#### 手动复制主站点 SSH 主机密钥

1. SSH 进入辅助站点上的每个节点并以 root 身份登录：

   ```shell
   sudo -i
   ```

1. 备份所有现有的 SSH 主机密钥：

   ```shell
   find /etc/ssh -iname 'ssh_host_*' -exec cp {} {}.backup.`date +%F` \;
   ```

1. 从主站点复制 OpenSSH 主机密钥。

   - 如果您可以以 root 身份访问主站点上处理 SSH 流量的节点之一（通常是主要的极狐GitLab Rails 应用节点）：

     ```shell
     # 从辅助站点运行此命令，将 `<primary_site_fqdn>` 更改为服务器的 IP 或 FQDN
     scp root@<primary_node_fqdn>:/etc/ssh/ssh_host_*_key* /etc/ssh
     ```

   - 如果您只能通过具有 `sudo` 权限的用户访问：

     ```shell
     # 从您的主站点节点运行此命令：
     sudo tar --transform 's/.*\///g' -zcvf ~/geo-host-key.tar.gz /etc/ssh/ssh_host_*_key*

     # 在您的辅助站点每个节点上运行此命令：
     scp <user_with_sudo>@<primary_site_fqdn>:geo-host-key.tar.gz .
     tar zxvf ~/geo-host-key.tar.gz -C /etc/ssh
     ```

1. 对于每个辅助站点节点，请确保文件权限正确：

   ```shell
   chown root:root /etc/ssh/ssh_host_*_key*
   chmod 0600 /etc/ssh/ssh_host_*_key
   ```

1. 要验证密钥指纹是否匹配，请在每个站点的主节点和辅助节点上执行以下命令：

   ```shell
   for file in /etc/ssh/ssh_host_*_key; do ssh-keygen -lf $file; done
   ```

   您应该会得到类似以下的输出：

   ```shell
   1024 SHA256:FEZX2jQa2bcsd/fn/uxBzxhKdx4Imc4raXrHwsbtP0M root@serverhostname (DSA)
   256 SHA256:uw98R35Uf+fYEQ/UnJD9Br4NXUFPv7JAUln5uHlgSeY root@serverhostname (ECDSA)
   256 SHA256:sqOUWcraZQKd89y/QQv/iynPTOGQxcOTIXU/LsoPmnM root@serverhostname (ED25519)
   2048 SHA256:qwa+rgir2Oy86QI+PZi/QVR+MSmrdrpsuH7YyKknC+s root@serverhostname (RSA)
   ```

   两个节点上的输出应该相同。

1. 验证您拥有与现有私钥相对应的正确公钥：

   ```shell
   # 这将打印私钥的指纹：
   for file in /etc/ssh/ssh_host_*_key; do ssh-keygen -lf $file; done

   # 这将打印公钥的指纹：
   for file in /etc/ssh/ssh_host_*_key.pub; do ssh-keygen -lf $file; done
   ```

   公钥和私钥命令的输出应生成相同的指纹。

1. 对于每个辅助站点节点，重启 `sshd`：

   ```shell
   # Debian 或 Ubuntu 安装
   sudo service ssh reload

   # CentOS 安装
   sudo service sshd reload
   ```

1. 要验证 SSH 是否仍然正常运行，请从一个新的终端，SSH 进入您的极狐GitLab 辅助服务器。
   如果您无法连接，请确保您拥有正确的权限。

#### 快速查找已授权的 SSH 密钥

初始复制过程完成后，请按照步骤
[配置快速查找已授权的 SSH 密钥](../../operations/fast_ssh_key_lookup.md)。

[Geo 需要快速查找](../../operations/fast_ssh_key_lookup.md#fast-lookup-is-required-for-geo)。

> [!note]
> 身份验证由主站点处理。不要为辅助站点设置自定义身份验证。
> 任何需要访问**管理**区域的更改都应在主站点进行，因为
> 辅助站点是只读副本。

#### 添加辅助站点

1. SSH 进入辅助站点上的每个 Rails 和 Sidekiq 节点并以 root 身份登录：

   ```shell
   sudo -i
   ```

1. 编辑 `/etc/gitlab/gitlab.rb` 并为您的站点添加一个唯一的名称。

   ```ruby
   ##
   ## Geo 站点的唯一标识符。参见
   ## https://gitlab.cn/docs/administration/geo_sites/#common-settings
   ##
   gitlab_rails['geo_node_name'] = '<secondary_site_name_here>'
   ```

   保存此唯一名称以备下一步使用。

1. 要应用更改，请重新配置辅助站点上的每个 Rails 和 Sidekiq 节点。

   ```shell
   gitlab-ctl reconfigure
   ```

1. 转到主节点极狐GitLab 实例：
   1. 在右上角，选择**管理员**。
   1. 选择 **Geo** > **站点**。
   1. 选择**添加站点**。

      ![添加新辅助 Geo 站点的表单](img/adding_a_secondary_v15_8.png)

   1. 在**名称**中，输入 `/etc/gitlab/gitlab.rb` 中 `gitlab_rails['geo_node_name']` 的值。这些值必须完全匹配。
   1. 在**外部 URL** 中，输入 `/etc/gitlab/gitlab.rb` 中 `external_url` 的值。
      如果一个值以 `/` 结尾而另一个没有，这是可以的。否则，值必须
      完全匹配。
   1. 可选。在**内部 URL (可选)** 中，输入主站点的内部 URL。
   1. 可选。选择应被辅助站点复制的群组或存储分片。
      要复制所有内容，请将该字段留空。参见[选择性同步](../replication/selective_synchronization.md)。
   1. 选择**保存更改**。
1. SSH 进入辅助站点上的每个 Rails 和 Sidekiq 节点并重启服务：

   ```shell
   sudo gitlab-ctl restart
   ```

1. 通过运行以下命令检查您的 Geo 设置是否存在任何常见问题：

   ```shell
   sudo gitlab-rake gitlab:geo:check
   ```

   如果任何检查失败，请参见[故障排除文档](../replication/troubleshooting/_index.md)。

1. 要验证辅助站点是否可访问，请 SSH 进入您主站点上的 Rails 或 Sidekiq 服务器并运行：

   ```shell
   sudo gitlab-rake gitlab:geo:check
   ```

   如果任何检查失败，请查看[故障排除文档](../replication/troubleshooting/_index.md)。

辅助站点被添加到 Geo 管理页面并重启后，
该站点会自动开始从主站点复制缺失的数据，
这个过程称为“回填”。

同时，主站点开始将任何更改通知给每个辅助站点，以便
辅助站点可以立即对这些通知做出反应。

请确保辅助站点正在运行且可访问。您可以使用与
主站点相同的凭据登录辅助站点。

#### 启用通过 HTTP/HTTPS 和 SSH 进行 Git 访问

Geo 通过 HTTP/HTTPS（新安装默认启用）同步仓库，
因此需要启用此克隆方法。
如果您将现有站点转换为 Geo，应检查是否启用了克隆方法。

在主站点上：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**可见性和访问控制**。
1. 如果您通过 SSH 使用 Git：
   1. 确保**已启用的 Git 访问协议**设置为 **Both SSH and HTTP(S)**。
   1. 在主站点和辅助站点上都启用[在数据库中快速查找已授权的 SSH 密钥](../../operations/fast_ssh_key_lookup.md)。
1. 如果您不使用 SSH 进行 Git 访问，请将**已启用的 Git 访问协议**设置为 **Only HTTP(S)**。

#### 验证辅助站点是否正常运行

您可以使用与主站点相同的凭据登录辅助站点。

登录后：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择 **Geo** > **站点**。
1. 验证该站点是否被正确标识为辅助 Geo 站点，并且
   Geo 是否已启用。

初始复制可能需要一些时间。
您可以在主站点的 **Geo 站点**仪表盘中，通过浏览器监控每个 Geo 站点的同步过程。

![Geo 管理仪表盘，显示辅助站点的同步状态。](img/geo_dashboard_v14_0.png)

## 配置跟踪数据库

> [!note]
> 如果您还希望在另一台服务器上外部设置跟踪数据库，则此步骤是可选的。

**辅助**站点使用一个单独的 PostgreSQL 安装作为跟踪
数据库来跟踪复制状态并自动恢复
潜在的复制问题。当设置了 `roles ['geo_secondary_role']` 时，Linux 软件包会自动配置一个跟踪数据库。
如果您想在 Linux 软件包安装之外运行此数据库，请使用以下说明。

### 云托管数据库服务

如果您为跟踪数据库使用云托管服务，您可能需要
向您的跟踪数据库用户（默认为 `gitlab_geo`）授予额外的角色：

- Amazon RDS 需要 [`rds_superuser`](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Appendix.PostgreSQL.CommonDBATasks.html#Appendix.PostgreSQL.CommonDBATasks.Roles) 角色。
- Azure Database for PostgreSQL 需要 [`azure_pg_admin`](https://learn.microsoft.com/en-us/azure/postgresql/single-server/how-to-create-users#how-to-create-additional-admin-users-in-azure-database-for-postgresql) 角色。
- Google Cloud SQL 需要 [`cloudsqlsuperuser`](https://cloud.google.com/sql/docs/postgres/users#default-users) 角色。

在安装和升级期间安装扩展需要额外的角色。作为替代方案，
[请确保手动安装扩展，并了解在未来极狐GitLab 升级过程中可能出现的问题](../../../install/postgresql_extensions.md)。

> [!note]
> 如果您想使用 Amazon RDS 作为跟踪数据库，请确保它可以访问
> 辅助数据库。不幸的是，仅分配相同的安全组是不够的，因为
> 出站规则不适用于 RDS PostgreSQL 数据库。因此，您需要明确地向只读副本的安全组添加入站
> 规则，允许来自跟踪数据库的 5432 端口的任何 TCP 流量。

### 创建跟踪数据库

在您的 PostgreSQL 实例中创建并配置跟踪数据库：

1. 根据
   [数据库要求文档](../../../install/requirements.md#postgresql)设置 PostgreSQL。
1. 设置一个 `gitlab_geo` 用户，并选择一个密码，创建 `gitlabhq_geo_production` 数据库，并使该用户成为数据库的所有者。
   您可以在[自我编译安装文档](../../../install/self_compiled/_index.md#7-database)中看到此设置的一个示例。
1. 如果您**未**使用云托管的 PostgreSQL 数据库，请通过手动更改与您的跟踪数据库关联的
   `pg_hba.conf`，确保您的辅助
   站点可以与您的跟踪数据库通信。
   之后请记得重启 PostgreSQL 以使更改生效：

   ```plaintext
   ##
   ## Geo 跟踪数据库角色
   ## - pg_hba.conf
   ##
   host    all         all               <trusted tracking IP>/32      md5
   host    all         all               <trusted secondary IP>/32     md5
   ```

### 配置极狐GitLab

配置极狐GitLab 以使用此数据库。 这些步骤适用于 Linux 软件包和 Docker 部署。

1. SSH 进入极狐GitLab **辅助**服务器并以 root 身份登录：

   ```shell
   sudo -i
   ```

1. 使用具有 PostgreSQL 实例的机器的连接参数和凭据编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   geo_secondary['db_username'] = 'gitlab_geo'
   geo_secondary['db_password'] = '<your_tracking_db_password_here>'

   geo_secondary['db_host'] = '<tracking_database_host>'
   geo_secondary['db_port'] = <tracking_database_port>      # 更改为正确的端口
   geo_postgresql['enable'] = false     # 不使用内部管理的实例
   ```

1. 保存文件并重新配置极狐GitLab：

   ```shell
   gitlab-ctl reconfigure
   ```

#### 手动设置数据库架构（可选）

[前面列出的步骤](#configure-gitlab)中的 `reconfigure` 命令会自动处理这些步骤。这些步骤是为了防止出现问题而提供的。

1. 此任务创建数据库架构。它要求数据库用户是超级用户。

   ```shell
   sudo gitlab-rake db:create:geo
   ```

1. 应用 Rails 数据库迁移（架构和数据更新）也由 `reconfigure` 执行。 如果设置了 `geo_secondary['auto_migrate'] = false`，或者
   架构是手动创建的，则需要此步骤：

   ```shell
   sudo gitlab-rake db:migrate:geo
   ```

## 示例配置

### 使用外部 PostgreSQL 的完整主站点

<!-- 如果您更新此配置示例，请同时更新 two_single_node_sites.md 中的示例 -->

此完整的 `gitlab.rb` 配置示例适用于使用外部 PostgreSQL 的 Geo 主站点：

```ruby
# 使用外部 PostgreSQL 的主站点配置示例

## Geo 主角色
roles(['geo_primary_role'])

## Geo 站点的唯一标识符
gitlab_rails['geo_node_name'] = 'headquarters'

## 外部 URL
external_url 'https://gitlab.example.com'

## 外部 PostgreSQL 配置
postgresql['enable'] = false
gitlab_rails['db_adapter'] = 'postgresql'
gitlab_rails['db_encoding'] = 'unicode'
gitlab_rails['db_host'] = 'primary-postgres.example.com'
gitlab_rails['db_port'] = 5432
gitlab_rails['db_database'] = 'gitlabhq_production'
gitlab_rails['db_username'] = 'gitlab'
gitlab_rails['db_password'] = 'your_database_password_here'

## SSL/TLS 配置
nginx['listen_port'] = 80
nginx['listen_https'] = false
letsencrypt['enable'] = false

## 对象存储配置（推荐用于外部服务）
gitlab_rails['object_store']['enabled'] = true
gitlab_rails['object_store']['connection'] = {
  'provider' => 'AWS',
  'region' => 'us-east-1',
  'aws_access_key_id' => 'your_access_key',
  'aws_secret_access_key' => 'your_secret_key'
}

## 监控配置
node_exporter['listen_address'] = '0.0.0.0:9100'
gitlab_workhorse['prometheus_listen_addr'] = '0.0.0.0:9229'
```

### 使用外部 PostgreSQL 的完整辅助站点

<!-- 如果您更新此配置示例，请同时更新 two_single_node_sites.md 中的示例 -->

此完整的 `gitlab.rb` 配置示例适用于使用外部 PostgreSQL 的 Geo 辅助站点：

```ruby
# 使用外部 PostgreSQL 的辅助站点配置示例

## Geo 辅助角色
roles(['geo_secondary_role'])

## Geo 站点的唯一标识符
gitlab_rails['geo_node_name'] = 'location-2'

## 外部 URL
external_url 'https://gitlab.example.com'

## 外部 PostgreSQL 配置（只读副本）
postgresql['enable'] = false
gitlab_rails['db_adapter'] = 'postgresql'
gitlab_rails['db_encoding'] = 'unicode'
gitlab_rails['db_host'] = 'secondary-postgres.example.com'
gitlab_rails['db_port'] = 5432
gitlab_rails['db_database'] = 'gitlabhq_production'
gitlab_rails['db_username'] = 'gitlab'
gitlab_rails['db_password'] = 'your_database_password_here'

## Geo 跟踪数据库配置
geo_secondary['db_username'] = 'gitlab_geo'
geo_secondary['db_password'] = 'your_tracking_db_password_here'
geo_secondary['db_host'] = 'secondary-tracking-db.example.com'
geo_secondary['db_port'] = 5432
geo_postgresql['enable'] = false

## SSL/TLS 配置
nginx['listen_port'] = 80
nginx['listen_https'] = false
letsencrypt['enable'] = false

## 对象存储配置（必须与主站点匹配）
gitlab_rails['object_store']['enabled'] = true
gitlab_rails['object_store']['connection'] = {
  'provider' => 'AWS',
  'region' => 'us-east-1',
  'aws_access_key_id' => 'your_access_key',
  'aws_secret_access_key' => 'your_secret_key'
}

## 监控配置
node_exporter['listen_address'] = '0.0.0.0:9100'
gitlab_workhorse['prometheus_listen_addr'] = '0.0.0.0:9229'
```

## 故障排除

请参见[Geo 故障排除](../replication/troubleshooting/_index.md)。