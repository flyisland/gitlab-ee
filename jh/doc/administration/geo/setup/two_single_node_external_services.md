---
stage: GitLab Dedicated
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 为两个单节点站点（使用外部 PostgreSQL 服务）设置 Geo
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

以下指南简要介绍了如何使用两个 Linux 软件包实例和外部 PostgreSQL 数据库（如 RDS、Azure Database 或 Google Cloud SQL），为两个单节点站点安装部署极狐GitLab Geo。

先决条件：

- 您至少有两个独立运行的极狐GitLab 站点。
  要创建站点，请参阅[极狐GitLab 参考架构文档](../../reference_architectures/_index.md)。
  - 一个极狐GitLab 站点用作 **Geo 主站点**。您可以为每个 Geo 站点使用不同的参考架构规模。如果您已有正在运行的极狐GitLab 实例，可以将其用作主站点。
  - 第二个极狐GitLab 站点用作 **Geo 从站点**。Geo 支持多个从站点。
- Geo 主站点至少拥有一个[极狐GitLab 专业版](https://gitlab.cn/pricing)许可证。
  所有站点只需一个许可证。
- 确认所有站点均满足[运行 Geo 的要求](../_index.md#requirements-for-running-geo)。

<a id="set-up-geo-for-linux-package-omnibus"></a>

## 为 Linux 软件包（Omnibus）设置 Geo

先决条件：

- 您使用 PostgreSQL 12 或更高版本，
  其中包含 [`pg_basebackup` 工具](https://www.postgresql.org/docs/16/app-pgbasebackup.html)。

<a id="configure-the-primary-site"></a>

### 配置主站点

1. 通过 SSH 登录到您的极狐GitLab 主站点，并以 root 身份登录：

   ```shell
   sudo -i
   ```

1. 在 `/etc/gitlab/gitlab.rb`中添加唯一的 Geo 站点名称：

   ```ruby
   ##
   ## The unique identifier for the Geo site. See
   ## https://gitlab.cn/docs/jh/administration/geo_sites/#common-settings
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

   此命令使用 `/etc/gitlab/gitlab.rb`中定义的 `external_url`。

有关配置示例，请参阅[使用外部 PostgreSQL 的完整主站点](#complete-primary-site-with-external-postgresql)。

<a id="configure-the-external-database-to-be-replicated"></a>

### 配置要复制的外部数据库

要设置外部数据库，您可以：

- 自行设置[流复制](https://www.postgresql.org/docs/16/warm-standby.html#STREAMING-REPLICATION-SLOTS)（例如 Amazon RDS，或不受 Linux 软件包管理的裸机）。
- 按如下方式手动配置您的 Linux 软件包安装。

<a id="leverage-your-cloud-providers-tools-to-replicate-the-primary-database"></a>

#### 利用云提供商的工具复制主数据库

假设您在 AWS EC2 上设置了使用 RDS 的主站点。现在，您只需在不同区域创建一个只读副本，复制过程即由 AWS 管理。请确保已根据您的需求设置网络 ACL（访问控制列表）、子网和安全组，以便从站点 Rails 节点可以访问数据库。

以下说明详细介绍了如何为常见云提供商创建只读副本：

- Amazon RDS - [创建只读副本](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_ReadRepl.html#USER_ReadRepl.Create)
- Azure Database for PostgreSQL - [在 Azure Database for PostgreSQL 中创建和管理只读副本](https://learn.microsoft.com/en-us/azure/postgresql/single-server/how-to-read-replicas-portal)
- Google Cloud SQL - [创建只读副本](https://docs.cloud.google.com/sql/docs/postgres/replication/create-replica)

只读副本设置完成后，您可以跳到[配置从站点](#configure-the-secondary-site-to-use-the-external-read-replica)。

<a id="configure-the-secondary-site-to-use-the-external-read-replica"></a>

### 配置从站点以使用外部只读副本

使用 Linux 软件包安装时，
[`geo_secondary_role`](https://gitlab.cn/docs/omnibus/roles/#gitlab-geo-roles)
有三个主要功能：

1. 配置副本数据库。
1. 配置跟踪数据库。
1. 启用 [Geo Log Cursor](../_index.md#geo-log-cursor)。

要配置与外部只读副本数据库的连接：

1. 通过 SSH 登录到从站点上的每个 Rails、Sidekiq 和 Geo Log Cursor 节点，并以 root 身份登录：

   ```shell
   sudo -i
   ```

1. 编辑 `/etc/gitlab/gitlab.rb` 并添加以下内容

   ```ruby
   ##
   ## Geo Secondary role
   ## - configure dependent flags automatically to enable Geo
   ##
   roles ['geo_secondary_role']

   # note this is shared between both databases,
   # make sure you define the same password in both
   gitlab_rails['db_password'] = '<your_db_password_here>'

   gitlab_rails['db_username'] = 'gitlab'
   gitlab_rails['db_host'] = '<database_read_replica_host>'

   # Disable the bundled Omnibus PostgreSQL because we are
   # using an external PostgreSQL
   postgresql['enable'] = false
   ```

1. 从[使用外部 PostgreSQL 的完整从站点](#complete-secondary-site-with-external-postgresql)复制配置示例。
   要应用更改，请保存文件并重新配置极狐GitLab：

   ```shell
   gitlab-ctl reconfigure
   ```

如果您与副本数据库之间存在连接问题，请使用以下命令从您的服务器[检查 TCP 连接](../../raketasks/maintenance.md)：

```shell
gitlab-rake gitlab:tcp_check[<replica FQDN>,5432]
```

如果此步骤失败，您可能使用了错误的 IP 地址，或者防火墙可能阻止了对该站点的访问。请检查 IP 地址，特别注意公有地址和私有地址之间的区别。如果存在防火墙，请确保允许从站点在端口 5432 上连接到主站点。

<a id="manually-replicate-secret-gitlab-values"></a>

#### 手动复制极狐GitLab 密钥值

极狐GitLab 在 `/etc/gitlab/gitlab-secrets.json`中存储了多个密钥值。此 JSON 文件在每个站点节点上必须相同。您必须在所有从站点上手动复制该密钥文件，尽管[议题 3789](https://gitlab.com/gitlab-org/gitlab/-/issues/3789) 提议更改此行为。

1. 通过 SSH 登录到主站点上的一个 Rails 节点，并执行以下命令：

   ```shell
   sudo cat /etc/gitlab/gitlab-secrets.json
   ```

   这会以 JSON 格式显示您必须复制的密钥。

1. 通过 SSH 登录到从 Geo 站点上的每个节点，并以 root 身份登录：

   ```shell
   sudo -i
   ```

1. 备份任何现有密钥：

   ```shell
   mv /etc/gitlab/gitlab-secrets.json /etc/gitlab/gitlab-secrets.json.`date +%F`
   ```

1. 将 `/etc/gitlab/gitlab-secrets.json` 从主站点 Rails 节点复制到每个从站点节点。
   您也可以在节点之间复制粘贴文件内容：

   ```shell
   sudo editor /etc/gitlab/gitlab-secrets.json

   # paste the output of the `cat` command you ran on the primary
   # save and exit
   ```

1. 确保文件权限正确：

   ```shell
   chown root:root /etc/gitlab/gitlab-secrets.json
   chmod 0600 /etc/gitlab/gitlab-secrets.json
   ```

1. 要应用更改，请重新配置每个 Rails、Sidekiq 和 Gitaly 从站点节点：

   ```shell
   gitlab-ctl reconfigure
   gitlab-ctl restart
   ```

<a id="manually-replicate-the-primary-site-ssh-host-keys"></a>

#### 手动复制主站点 SSH 主机密钥

1. 通过 SSH 登录到从站点上的每个节点，并以 root 身份登录：

   ```shell
   sudo -i
   ```

1. 备份任何现有 SSH 主机密钥：

   ```shell
   find /etc/ssh -iname 'ssh_host_*' -exec cp {} {}.backup.`date +%F` \;
   ```

1. 从主站点复制 OpenSSH 主机密钥。

   - 如果您能以 root 身份访问主站点中处理 SSH 流量的某个节点（通常是主要的 GitLab Rails 应用节点）：

     ```shell
     # Run this from the secondary site, change `<primary_site_fqdn>` for the IP or FQDN of the server
     scp root@<primary_node_fqdn>:/etc/ssh/ssh_host_*_key* /etc/ssh
     ```

   - 如果您只能通过具有 `sudo` 权限的用户访问：

     ```shell
     # Run this from the node on your primary site:
     sudo tar --transform 's/.*\///g' -zcvf ~/geo-host-key.tar.gz /etc/ssh/ssh_host_*_key*

     # Run this on each node on your secondary site:
     scp <user_with_sudo>@<primary_site_fqdn>:geo-host-key.tar.gz .
     tar zxvf ~/geo-host-key.tar.gz -C /etc/ssh
     ```

1. 对于每个从站点节点，确保文件权限正确：

   ```shell
   chown root:root /etc/ssh/ssh_host_*_key*
   chmod 0600 /etc/ssh/ssh_host_*_key
   ```

1. 要验证密钥指纹是否匹配，请在每个站点的主节点和从节点上执行以下命令：

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

   两个节点上的输出应完全相同。

1. 验证您拥有与现有私钥对应的正确公钥：

   ```shell
   # This will print the fingerprint for private keys:
   for file in /etc/ssh/ssh_host_*_key; do ssh-keygen -lf $file; done

   # This will print the fingerprint for public keys:
   for file in /etc/ssh/ssh_host_*_key.pub; do ssh-keygen -lf $file; done
   ```

   公钥和私钥命令的输出应生成相同的指纹。

1. 对于每个从站点节点，重启 `sshd`：

   ```shell
   # Debian or Ubuntu installations
   sudo service ssh reload

   # CentOS installations
   sudo service sshd reload
   ```

1. 要验证 SSH 是否仍正常工作，请在新终端中通过 SSH 登录到您的极狐GitLab 从服务器。
   如果无法连接，请确保您拥有正确的权限。

<a id="fast-lookup-of-authorized-ssh-keys"></a>

#### 快速查找已授权 SSH 密钥

初始复制过程完成后，请按照步骤[配置已授权 SSH 密钥的快速查找](../../operations/fast_ssh_key_lookup.md)。

快速查找[是 Geo 的必需项](../../operations/fast_ssh_key_lookup.md#fast-lookup-is-required-for-geo)。

> [!note]
> 身份验证由主站点处理。不要为从站点设置自定义身份验证。
> 任何需要访问**管理员**区域的更改都应在主站点中进行，因为
> 从站点是只读副本。

<a id="add-the-secondary-site"></a>

#### 添加从站点

1. 通过 SSH 登录到从站点上的每个 Rails 和 Sidekiq 节点，并以 root 身份登录：

   ```shell
   sudo -i
   ```

1. 编辑 `/etc/gitlab/gitlab.rb` 并为您的站点添加唯一名称。

   ```ruby
   ##
   ## The unique identifier for the Geo site. See
   ## https://gitlab.cn/docs/jh/administration/geo_sites/#common-settings
   ##
   gitlab_rails['geo_node_name'] = '<secondary_site_name_here>'
   ```

   保存该唯一名称以供后续步骤使用。

1. 要应用更改，请重新配置从站点上的每个 Rails 和 Sidekiq 节点。

   ```shell
   gitlab-ctl reconfigure
   ```

1. 转到主节点极狐GitLab 实例：
   1. 在右上角，选择**管理员**。
   1. 选择 **Geo** > **站点**。
   1. 选择**添加站点**。

      ![用于添加新 Geo 从站点的表单](img/adding_a_secondary_v15_8.png)

   1. 在**名称**中，输入
      `/etc/gitlab/gitlab.rb`中 `gitlab_rails['geo_node_name']` 的值。这些值必须完全匹配。
   1. 在**外部 URL**中，输入 `/etc/gitlab/gitlab.rb`中 `external_url`的值。
      一个值以 `/` 结尾而另一个不以它结尾是可以的。除此之外，这些值必须
      完全匹配。
   1. 可选。在**内部 URL（可选）**中，输入主站点的内部 URL。
   1. 可选。选择应由从站点复制的群组或存储分片。要复制全部，请将该字段留空。请参阅[选择性同步](../replication/selective_synchronization.md)。
   1. 选择**保存更改**。
1. 通过 SSH 登录到从站点上的每个 Rails 和 Sidekiq 节点，并重启服务：

   ```shell
   sudo gitlab-ctl restart
   ```

1. 通过运行以下命令检查您的 Geo 设置是否存在任何常见问题：

   ```shell
   sudo gitlab-rake gitlab:geo:check
   ```

   如果任何检查失败，请参阅[故障排除文档](../replication/troubleshooting/_index.md)。

1. 要验证从站点是否可访问，请通过 SSH 登录到主站点上的 Rails 或 Sidekiq 服务器并运行：

   ```shell
   sudo gitlab-rake gitlab:geo:check
   ```

   如果任何检查失败，请查看[故障排除文档](../replication/troubleshooting/_index.md)。

从站点添加到 Geo 管理页面并重启后，该站点会自动开始从主站点复制缺失的数据，此过程称为回填。

同时，主站点开始将任何更改通知每个从站点，以便从站点可以立即对通知采取行动。

请确保从站点正在运行且可访问。您可以使用与主站点相同的凭据登录从站点。

<a id="enable-git-access-over-httphttps-and-ssh"></a>

#### 启用通过 HTTP/HTTPS 和 SSH 的 Git 访问

Geo 通过 HTTP/HTTPS 同步代码仓库（新安装默认启用），因此需要启用此克隆方法。如果您将现有站点转换为 Geo，应检查克隆方法是否已启用。

在主站点上：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**可见性和访问控制**。
1. 如果您使用基于 SSH 的 Git：
   1. 确保**启用的 Git 访问协议**设置为 **SSH 和 HTTP(S) 均可**。
   1. 在主站点和从站点上启用[数据库中已授权 SSH 密钥的快速查找](../../operations/fast_ssh_key_lookup.md)。
1. 如果您不使用基于 SSH 的 Git，请将**启用的 Git 访问协议**设置为**仅 HTTP(S)**。

<a id="verify-proper-functioning-of-the-secondary-site"></a>

#### 验证从站点是否正常运行

您可以使用与主站点相同的凭据登录从站点。

登录后：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择 **Geo** > **站点**。
1. 验证该站点已正确标识为 Geo 从站点，并且
   Geo 已启用。

初始复制可能需要一些时间。您可以在浏览器中通过主站点的 **Geo 站点**仪表板监控每个 Geo 站点上的同步过程。

![显示从站点同步状态的 Geo 管理仪表板。](img/geo_dashboard_v14_0.png)

<a id="configure-the-tracking-database"></a>

## 配置跟踪数据库

> [!note]
> 如果您还想在另一台服务器上外部设置跟踪数据库，则此步骤是可选的。

从站点使用单独的 PostgreSQL 安装作为跟踪数据库，以跟踪复制状态并自动从潜在的复制问题中恢复。当设置 `roles ['geo_secondary_role']` 时，Linux 软件包会自动配置跟踪数据库。如果您想在 Linux 软件包安装之外运行此数据库，请使用以下说明。

<a id="cloud-managed-database-services"></a>

### 云托管数据库服务

如果您使用云托管服务作为跟踪数据库，您可能需要为跟踪数据库用户授予其他角色（默认情况下，该用户为
`gitlab_geo`）：

- Amazon RDS 需要 [`rds_superuser`](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Appendix.PostgreSQL.CommonDBATasks.html#Appendix.PostgreSQL.CommonDBATasks.Roles) 角色。
- Azure Database for PostgreSQL 需要 [`azure_pg_admin`](https://learn.microsoft.com/en-us/azure/postgresql/single-server/how-to-create-users#how-to-create-additional-admin-users-in-azure-database-for-postgresql) 角色。
- Google Cloud SQL 需要 [`cloudsqlsuperuser`](https://cloud.google.com/sql/docs/postgres/users#default-users) 角色。

在安装和升级期间安装扩展需要其他角色。作为替代方案，[手动安装所需的扩展](../../postgresql/extensions.md)。

> [!note]
> 如果您想使用 Amazon RDS 作为跟踪数据库，请确保它可以访问
> 从数据库。遗憾的是，仅分配相同的安全组是不够的，因为
> 出站规则不适用于 RDS PostgreSQL 数据库。因此，您需要显式地向
> 只读副本的安全组添加一条入站规则，允许来自
> 跟踪数据库在端口 5432 上的任何 TCP 流量。

<a id="create-the-tracking-database"></a>

### 创建跟踪数据库

在您的 PostgreSQL 实例中创建并配置跟踪数据库：

1. 根据[数据库要求文档](../../../install/requirements.md#postgresql)设置 PostgreSQL。
1. 设置一个 `gitlab_geo` 用户，使用您选择的密码，创建 `gitlabhq_geo_production` 数据库，并使该用户成为该数据库的所有者。
   您可以在[自编译安装文档](../../../install/self_compiled/_index.md#7-database)中看到此设置的示例。
1. 如果您不使用云托管的 PostgreSQL 数据库，请通过手动更改与
   跟踪数据库关联的 `pg_hba.conf`，确保您的从站点
   可以与跟踪数据库通信。
   请记得之后重启 PostgreSQL 以使更改生效：

   ```plaintext
   ##
   ## Geo Tracking Database Role
   ## - pg_hba.conf
   ##
   host    all         all               <trusted tracking IP>/32      md5
   host    all         all               <trusted secondary IP>/32     md5
   ```

<a id="configure-gitlab"></a>

### 配置极狐GitLab

配置极狐GitLab 以使用此数据库。这些步骤适用于 Linux 软件包和 Docker 部署。

1. 通过 SSH 登录到极狐GitLab 从服务器，并以 root 身份登录：

   ```shell
   sudo -i
   ```

1. 使用 PostgreSQL 实例所在机器的连接参数和凭据
   编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   geo_secondary['db_username'] = 'gitlab_geo'
   geo_secondary['db_password'] = '<your_tracking_db_password_here>'

   geo_secondary['db_host'] = '<tracking_database_host>'
   geo_secondary['db_port'] = <tracking_database_port>      # change to the correct port
   geo_postgresql['enable'] = false     # don't use internal managed instance
   ```

1. 保存文件并重新配置极狐GitLab：

   ```shell
   gitlab-ctl reconfigure
   ```

<a id="manually-set-up-the-database-schema-optional"></a>

#### 手动设置数据库架构（可选）

[前面列出的步骤](#configure-gitlab)中的重新配置命令会自动处理这些步骤。提供这些步骤是为了应对出现问题时的情况。

1. 此任务会创建数据库架构。它要求数据库用户为超级用户。

   ```shell
   sudo gitlab-rake db:create:geo
   ```

1. 应用 Rails 数据库迁移（架构和数据更新）也由重新配置执行。如果设置了 `geo_secondary['auto_migrate'] = false`，或者
   架构是手动创建的，则此步骤是必需的：

   ```shell
   sudo gitlab-rake db:migrate:geo
   ```

<a id="example-configurations"></a>

## 配置示例

<a id="complete-primary-site-with-external-postgresql"></a>

### 使用外部 PostgreSQL 的完整主站点

<!-- If you update this configuration example, also update the example in two_single_node_sites.md -->

此完整的 `gitlab.rb` 配置示例适用于使用外部 PostgreSQL 的 Geo 主站点：

```ruby
# Primary site with external PostgreSQL configuration example

## Geo Primary role
roles(['geo_primary_role'])

## The unique identifier for the Geo site
gitlab_rails['geo_node_name'] = 'headquarters'

## External URL
external_url 'https://gitlab.example.com'

## External PostgreSQL configuration
postgresql['enable'] = false
gitlab_rails['db_adapter'] = 'postgresql'
gitlab_rails['db_encoding'] = 'unicode'
gitlab_rails['db_host'] = 'primary-postgres.example.com'
gitlab_rails['db_port'] = 5432
gitlab_rails['db_database'] = 'gitlabhq_production'
gitlab_rails['db_username'] = 'gitlab'
gitlab_rails['db_password'] = 'your_database_password_here'

## SSL/TLS configuration
nginx['listen_port'] = 80
nginx['listen_https'] = false
letsencrypt['enable'] = false

## Object Storage configuration (recommended for external services)
gitlab_rails['object_store']['enabled'] = true
gitlab_rails['object_store']['connection'] = {
  'provider' => 'AWS',
  'region' => 'us-east-1',
  'aws_access_key_id' => 'your_access_key',
  'aws_secret_access_key' => 'your_secret_key'
}

## Monitoring configuration
node_exporter['listen_address'] = '0.0.0.0:9100'
gitlab_workhorse['prometheus_listen_addr'] = '0.0.0.0:9229'
```

<a id="complete-secondary-site-with-external-postgresql"></a>

### 使用外部 PostgreSQL 的完整从站点

<!-- If you update this configuration example, also update the example in two_single_node_sites.md -->

此完整的 `gitlab.rb` 配置示例适用于使用外部 PostgreSQL 的 Geo 从站点：

```ruby
# Secondary site with external PostgreSQL configuration example

## Geo Secondary role
roles(['geo_secondary_role'])

## The unique identifier for the Geo site
gitlab_rails['geo_node_name'] = 'location-2'

## External URL
external_url 'https://gitlab.example.com'

## External PostgreSQL configuration (read-only replica)
postgresql['enable'] = false
gitlab_rails['db_adapter'] = 'postgresql'
gitlab_rails['db_encoding'] = 'unicode'
gitlab_rails['db_host'] = 'secondary-postgres.example.com'
gitlab_rails['db_port'] = 5432
gitlab_rails['db_database'] = 'gitlabhq_production'
gitlab_rails['db_username'] = 'gitlab'
gitlab_rails['db_password'] = 'your_database_password_here'

## Geo tracking database configuration
geo_secondary['db_username'] = 'gitlab_geo'
geo_secondary['db_password'] = 'your_tracking_db_password_here'
geo_secondary['db_host'] = 'secondary-tracking-db.example.com'
geo_secondary['db_port'] = 5432
geo_postgresql['enable'] = false

## SSL/TLS configuration
nginx['listen_port'] = 80
nginx['listen_https'] = false
letsencrypt['enable'] = false

## Object Storage configuration (must match primary)
gitlab_rails['object_store']['enabled'] = true
gitlab_rails['object_store']['connection'] = {
  'provider' => 'AWS',
  'region' => 'us-east-1',
  'aws_access_key_id' => 'your_access_key',
  'aws_secret_access_key' => 'your_secret_key'
}

## Monitoring configuration
node_exporter['listen_address'] = '0.0.0.0:9100'
gitlab_workhorse['prometheus_listen_addr'] = '0.0.0.0:9229'
```

<a id="troubleshooting"></a>

## 故障排除

请参阅 [Geo 故障排除](../replication/troubleshooting/_index.md)。
