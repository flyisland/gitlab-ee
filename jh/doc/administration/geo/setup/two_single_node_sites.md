---
stage: Tenant Scale
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Configure GitLab Geo replication between two single-node sites for disaster recovery, supporting Linux package and Docker installations.
title: 为两个单节点站点设置 Geo
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

以下指南提供了关于使用两个 Linux 软件包实例（不设置外部服务）为两个单节点站点部署极狐GitLab Geo 的简明说明。本指南也适用于基于 [Docker](../../../install/docker/_index.md) 的安装。

先决条件：

- 你至少拥有两个独立运行的极狐GitLab 站点。
  要创建站点，请参阅 [极狐GitLab 参考架构文档](../../reference_architectures/_index.md)。
  - 一个极狐GitLab 站点作为 **Geo 主站点**。你可以为每个 Geo 站点使用不同规模的参考架构。如果你已经有一个正在运行的极狐GitLab 实例，你可以将其用作主站点。
  - 第二个极狐GitLab 站点作为 **Geo 次要站点**。Geo 支持多个次要站点。
- Geo 主站点至少拥有 [极狐GitLab 专业版](https://gitlab.cn/pricing/) 许可证。
  你只需要一个许可证用于所有站点。
- 确认所有站点满足 [运行 Geo 的要求](../_index.md#requirements-for-running-geo)。

<a id="set-up-geo-for-linux-package-omnibus"></a>

## 为 Linux 软件包 (Omnibus) 设置 Geo

先决条件：

- 你使用 PostgreSQL 12 或更高版本，其中包含 [`pg_basebackup` 工具](https://www.postgresql.org/docs/16/app-pgbasebackup.html)。

<a id="configure-the-primary-site"></a>

### 配置主站点

> [!note]
> 对于基于 Docker 的安装：
>
> 直接将下面提到的设置应用到极狐GitLab 容器的 `/etc/gitlab/gitlab.rb` 文件，或者将其添加到其 [Docker Compose](../../../install/docker/installation.md#install-gitlab-by-using-docker-compose) 文件中的 `GITLAB_OMNIBUS_CONFIG` 环境变量中。
>
> 当使用 [Docker Compose](../../../install/docker/installation.md#install-gitlab-by-using-docker-compose) 时，使用 `docker-compose -f <docker-compose-file-name>.yml up` 代替 `gitlab-ctl reconfigure` 来应用配置更改。

1. SSH 到你的极狐GitLab 主站点，并以 root 身份登录：

   ```shell
   sudo -i
   ```

1. [退出自动 PostgreSQL 升级](https://gitlab.cn/docs/omnibus/settings/database/#opt-out-of-automatic-postgresql-upgrades) 以避免在升级极狐GitLab 时出现意外停机。注意已知的 [使用 Geo 升级 PostgreSQL 时的注意事项](https://gitlab.cn/docs/omnibus/settings/database/#caveats-when-upgrading-postgresql-with-geo)。特别是对于较大的环境，必须有计划地执行 PostgreSQL 升级。因此，要继续确保 PostgreSQL 升级是常规维护活动的一部分。
1. 向 `/etc/gitlab/gitlab.rb` 添加唯一的 Geo 站点名称：

   ```ruby
   ##
   ## Geo 站点的唯一标识符。请参阅
   ## https://gitlab.cn/docs/administration/geo_sites/#common-settings
   ##
   gitlab_rails['geo_node_name'] = '<site_name_here>'
   ```

1. 要应用更改，重新配置主站点：

   ```shell
   gitlab-ctl reconfigure
   ```

1. 将站点定义为主 Geo 站点：

   ```shell
   gitlab-ctl set-geo-primary-node
   ```

   此命令使用在 `/etc/gitlab/gitlab.rb` 中定义的 `external_url`。

1. 从 [完成主站点配置](#complete-primary-site) 复制配置示例。
1. 为 `gitlab` 数据库用户创建密码，并更新 Rails 以使用新密码。

   > [!note]
   > 为 `gitlab_rails['db_password']` 和 `postgresql['sql_user_password']` 设置配置的值需要匹配。
   > 但是，只有 `postgresql['sql_user_password']` 的值应该是 MD5 加密的密码。
   > 对此的更改正在 [重新思考如何在 cookbook 中处理 PostgreSQL 密码](https://jihulab.com/gitlab-cn/omnibus-gitlab/-/issues/5713) 中讨论。

   1. 为所需密码生成 MD5 哈希值：

      ```shell
      gitlab-ctl pg-password-md5 gitlab
      # Enter password: <your_db_password_here>
      # Confirm password: <your_db_password_here>
      # fca0b89a972d69f00eb3ec98a5838484
      ```

   1. 编辑 `/etc/gitlab/gitlab.rb`：

      ```ruby
      # 用 `gitlab-ctl pg-password-md5 gitlab` 生成的哈希填充
      postgresql['sql_user_password'] = '<md5_hash_of_your_db_password>'

      # 每个运行 Puma 或 Sidekiq 的节点都需要如下指定数据库密码。
      # 如果你是高可用性设置，则所有应用节点都必须如此。
      gitlab_rails['db_password'] = '<your_db_password_here>'
      ```

1. 为数据库 [复制用户](https://www.postgresql.org/docs/16/warm-standby.html#STREAMING-REPLICATION) 定义密码。使用在 `/etc/gitlab/gitlab.rb` 中 `postgresql['sql_replication_user']` 设置下定义的用户名。默认值为 `gitlab_replicator`。

   1. 为所需密码生成 MD5 哈希值：

      ```shell
      gitlab-ctl pg-password-md5 gitlab_replicator

      # Enter password: <your_replication_password_here>
      # Confirm password: <your_replication_password_here>
      # 950233c0dfc2f39c64cf30457c3b7f1e
      ```

   1. 编辑 `/etc/gitlab/gitlab.rb`：

      ```ruby
      # 用 `gitlab-ctl pg-password-md5 gitlab_replicator` 生成的哈希填充
      postgresql['sql_replication_password'] = '<md5_hash_of_your_replication_password>'
      ```

   1. 可选。如果你使用不由 Linux 软件包管理的外部数据库，则必须手动创建 `gitlab_replicator` 用户并为该用户定义密码：

      ```sql
      --- 创建新用户 'gitlab_replicator'
      CREATE USER gitlab_replicator;

      --- 设置/更改密码并授予复制权限
      ALTER USER gitlab_replicator WITH REPLICATION ENCRYPTED PASSWORD '<replication_password>';
      ```

1. 在 `/etc/gitlab/gitlab.rb` 中，将角色设置为 [`geo_primary_role`](https://gitlab.cn/docs/omnibus/roles/#gitlab-geo-roles)：

   ```ruby
   ## Geo 主角色
   roles(['geo_primary_role'])
   ```

1. 配置 PostgreSQL 以侦听网络接口：

   1. 要查找 Geo 站点的地址，请通过 SSH 登录到 Geo 站点并执行：

      ```shell
      ##
      ## 私有地址
      ##
      ip route get 255.255.255.255 | awk '{print "Private address:", $NF; exit}'

      ##
      ## 公网地址
      ##
      echo "External address: $(curl --silent "ipinfo.io/ip")"
      ```

      在大多数情况下，以下地址用于配置极狐GitLab Geo：

      | 配置                                   | 地址                                                               |
      |:----------------------------------------|:----------------------------------------------------------------------|
      | `postgresql['listen_address']`          | 主站点公网或 VPC 私有地址。                                    |
      | `postgresql['md5_auth_cidr_addresses']` | 主站点和辅助站点公网或 VPC 私有地址。                           |

      如果你使用 Google Cloud Platform、SoftLayer 或任何其他提供虚拟私有云 (VPC) 的供应商，你可以使用主站点和辅助站点的私有地址（对于 Google Cloud Platform 对应“内部地址”）来配置 `postgresql['md5_auth_cidr_addresses']` 和 `postgresql['listen_address']`。

      > [!note]
      > 如果你需要使用 `0.0.0.0` 或 `*` 作为 `listen_address`，你还必须将 `127.0.0.1/32` 添加到 `postgresql['md5_auth_cidr_addresses']` 设置中，以允许 Rails 通过 `127.0.0.1` 连接。有关更多信息，请参阅 [议题 5258](https://jihulab.com/gitlab-cn/omnibus-gitlab/-/issues/5258)。

      根据你的网络配置，建议的地址可能不正确。如果你的主站点和辅助站点通过局域网或连接可用区的虚拟网络（例如 [Amazon VPC](https://aws.amazon.com/vpc/) 或 [Google VPC](https://cloud.google.com/vpc/)）连接，则应使用辅助站点的私有地址作为 `postgresql['md5_auth_cidr_addresses']`。

   1. 将以下行添加到 `/etc/gitlab/gitlab.rb`。确保将 IP 地址替换为适合你的网络配置的地址：

      ```ruby
      ##
      ## 主地址
      ## - 将 '<primary_node_ip>' 替换为你的 Geo 主节点的公网或 VPC 地址
      ##
      postgresql['listen_address'] = '<primary_site_ip>'

      ##
      # 允许来自主 IP 和辅助 IP 的 PostgreSQL 客户端认证。这些 IP 可以是
      # CIDR 格式的公网或 VPC 地址，例如 ['198.51.100.1/32', '198.51.100.2/32']
      ##
      postgresql['md5_auth_cidr_addresses'] = ['<primary_site_ip>/32', '<secondary_site_ip>/32']
      ```

1. 暂时禁用自动数据库迁移，直到 PostgreSQL 重启并在私有地址上监听。在 `/etc/gitlab/gitlab.rb` 中，将 `gitlab_rails['auto_migrate']` 设置为 false：

   ```ruby
   ## 禁用自动数据库迁移
   gitlab_rails['auto_migrate'] = false
   ```

1. 要应用这些更改，重新配置极狐GitLab 并重启 PostgreSQL：

   ```shell
   gitlab-ctl reconfigure
   gitlab-ctl restart postgresql
   ```

1. 要重新启用迁移，编辑 `/etc/gitlab/gitlab.rb` 并将 `gitlab_rails['auto_migrate']` 改为 `true`：

   ```ruby
   gitlab_rails['auto_migrate'] = true
   ```

   保存文件并重新配置极狐GitLab：

   ```shell
   gitlab-ctl reconfigure
   ```

   PostgreSQL 服务器已设置为接受远程连接。

1. 运行 `netstat -plnt | grep 5432` 以确保 PostgreSQL 在端口 `5432` 上监听主站点的私有地址。
1. 重新配置极狐GitLab 时自动生成了证书。该证书自动用于保护你的 PostgreSQL 流量免受窃听。为防范主动（“中间人”）攻击，将证书复制到辅助站点：

   1. 在主站点上复制 `server.crt`：

      ```shell
      cat ~gitlab-psql/data/server.crt
      ```

   1. 保存输出，以便配置辅助站点时使用。证书不是敏感数据。

   证书是用通用 `PostgreSQL` 通用名称创建的。要防止主机名不匹配错误，在复制数据库时必须使用 `verify-ca` 模式。

<a id="configure-the-secondary-server"></a>

### 配置辅助服务器

1. SSH 到你的极狐GitLab 辅助站点，并以 root 身份登录：

   ```shell
   sudo -i
   ```

1. [退出自动 PostgreSQL 升级](https://gitlab.cn/docs/omnibus/settings/database/#opt-out-of-automatic-postgresql-upgrades) 以避免在升级极狐GitLab 时出现意外停机。注意已知的 [使用 Geo 升级 PostgreSQL 时的注意事项](https://gitlab.cn/docs/omnibus/settings/database/#caveats-when-upgrading-postgresql-with-geo)。特别是对于较大的环境，必须有计划地执行 PostgreSQL 升级。因此，要继续确保 PostgreSQL 升级是常规维护活动的一部分。
1. 为防止在站点配置之前运行任何命令，停止应用服务器和 Sidekiq：

   ```shell
   gitlab-ctl stop puma
   gitlab-ctl stop sidekiq
   ```

1. [检查 TCP 连接](../../raketasks/maintenance.md) 到主站点的 PostgreSQL 服务器：

   ```shell
   gitlab-rake gitlab:tcp_check[<primary_site_ip>,5432]
   ```

   如果此步骤失败，你可能使用了错误的 IP 地址，或者防火墙可能阻止了对站点的访问。检查 IP 地址，特别注意公网地址和私有地址之间的区别。如果存在防火墙，请确保辅助站点被允许在端口 5432 上连接到主站点。

1. 在辅助站点中，创建一个名为 `server.crt` 的文件，并添加你在配置主站点时制作的证书副本。

   ```shell
   editor server.crt
   ```

1. 要在辅助站点上设置 PostgreSQL TLS 验证，请安装 `server.crt`：

   ```shell
   install \
      -D \
      -o gitlab-psql \
      -g gitlab-psql \
      -m 0400 \
      -T server.crt ~gitlab-psql/.postgresql/root.crt
   ```

   PostgreSQL 现在仅在验证 TLS 连接时识别此确切证书。该证书可以被能够访问私钥的人复制，该私钥仅存在于主站点上。

1. 测试 `gitlab-psql` 用户是否可以连接到主站点数据库。默认 Linux 软件包名称为 `gitlabhq_production`：

    {{< tabs >}}

    {{< tab title="Linux 软件包" >}}

    ```shell
    sudo \
        -u gitlab-psql /opt/gitlab/embedded/bin/psql \
        --list \
        -U gitlab_replicator \
        -d "dbname=gitlabhq_production sslmode=verify-ca" \
        -W \
        -h <primary_site_ip>
    ```

    {{< /tab >}}

    {{< tab title="Docker" >}}

    ```shell
    docker exec -it <container_name> su - gitlab-psql -c '/opt/gitlab/embedded/bin/psql \
        --list \
        -U gitlab_replicator \
        -d "dbname=gitlabhq_production sslmode=verify-ca" \
        -W \
        -h <primary_site_ip>'
    ```

    {{< /tab >}}

    {{< /tabs >}}

   当提示时，输入你为 `gitlab_replicator` 用户设置的明文密码。如果一切正常，你应该看到主站点数据库的列表。

1. 编辑 `/etc/gitlab/gitlab.rb` 并将角色设置为 `geo_secondary_role`：

   ```ruby
   ##
   ## Geo 辅助角色
   ## - 自动配置相关标志以启用 Geo
   ##
   roles(['geo_secondary_role'])
   ```

   有关更多信息，请参阅 [Geo 角色](https://gitlab.cn/docs/omnibus/roles/#gitlab-geo-roles)。

1. 要配置 PostgreSQL，请编辑 `/etc/gitlab/gitlab.rb` 并添加以下内容：

   ```ruby
   ##
   ## 辅助地址
   ## - 将 '<secondary_site_ip>' 替换为你的 Geo 辅助站点的公网或 VPC 地址
   ##
   postgresql['listen_address'] = '<secondary_site_ip>'
   postgresql['md5_auth_cidr_addresses'] = ['<secondary_site_ip>/32']

   ##
   ## 数据库凭据密码（之前在主站点定义）
   ## - 此处复制与主站点相同的值
   ##
   postgresql['sql_replication_password'] = '<md5_hash_of_your_replication_password>'
   postgresql['sql_user_password'] = '<md5_hash_of_your_db_password>'
   gitlab_rails['db_password'] = '<your_db_password_here>'
   ```

   确保将 IP 地址替换为适合你的网络配置的地址。

1. 从 [完成辅助站点配置](#complete-secondary-site) 复制配置示例。
1. 要应用更改，保存文件并重新配置极狐GitLab：

   ```shell
   gitlab-ctl reconfigure
   ```

1. 要应用 IP 地址更改，重启 PostgreSQL：

   ```shell
   gitlab-ctl restart postgresql
   ```

<a id="replicate-the-database"></a>

### 复制数据库

将辅助站点上的数据库连接到主站点上的数据库。你可以使用下面的脚本来复制数据库并创建流式复制所需的文件。

该脚本使用默认的 Linux 软件包目录。如果你更改了默认值，请将以下脚本中的目录和路径名替换为你自己的名称。

> [!warning]
> 仅在辅助站点上运行复制脚本。
> 该脚本在运行 `pg_basebackup` 之前会删除所有 PostgreSQL 数据，
> 这可能导致数据丢失。

要复制数据库：

1. SSH 到你的极狐GitLab 辅助站点，并以 root 身份登录：

   ```shell
   sudo -i
   ```

1. 为你的辅助站点选择一个 [对数据库友好的名称](https://www.postgresql.org/docs/16/warm-standby.html#STREAMING-REPLICATION-SLOTS-MANIPULATION) 作为复制槽名称。例如，如果你的域名是 `secondary.geo.example.com`，则使用 `secondary_example` 作为槽名称。

   复制槽名称必须仅包含小写字母、数字和下划线字符。

1. 执行以下命令来备份和恢复数据库，并开始复制。

   > [!warning]
   > 每个 Geo 辅助站点必须拥有自己唯一的复制槽名称。
   > 两个辅助站点之间使用相同的槽名称会破坏 PostgreSQL 复制。

   ```shell
   gitlab-ctl replicate-geo-database \
      --slot-name=<secondary_slot_name> \
      --host=<primary_site_ip> \
      --sslmode=verify-ca
   ```

   当提示时，输入你为 `gitlab_replicator` 设置的明文密码。

复制过程已完成。

<a id="configure-a-new-secondary-site"></a>

## 配置新的辅助站点

初始复制过程完成后，继续在辅助站点上配置以下项目。

<a id="fast-lookup-of-authorized-ssh-keys"></a>

### 快速查找已授权的 SSH 密钥

按照文档 [配置快速查找已授权的 SSH 密钥](../../operations/fast_ssh_key_lookup.md) 进行操作。

快速查找是 [Geo 所必需的](../../operations/fast_ssh_key_lookup.md#fast-lookup-is-required-for-geo)。

> [!note]
> 身份验证由主站点处理。不要为辅助站点设置自定义身份验证。
> 任何需要访问 **管理员** 区域的更改都应在主站点进行，因为辅助站点是只读副本。

<a id="manually-replicate-secret-gitlab-values"></a>

### 手动复制极狐GitLab 密钥值

极狐GitLab 在 `/etc/gitlab/gitlab-secrets.json` 中存储了许多密钥值。
此 JSON 文件在每个站点节点上必须相同。
你必须手动将该密钥文件复制到所有辅助站点，尽管
[议题 3789](https://jihulab.com/gitlab-cn/gitlab/-/issues/3789) 提出了更改此行为。

1. SSH 到主站点上的 Rails 节点，并执行以下命令：

   ```shell
   sudo cat /etc/gitlab/gitlab-secrets.json
   ```

   这会以 JSON 格式显示你必须复制的密钥。

1. SSH 到辅助 Geo 站点上的每个节点，并以 root 身份登录：

   ```shell
   sudo -i
   ```

1. 备份任何现有的密钥：

   ```shell
   mv /etc/gitlab/gitlab-secrets.json /etc/gitlab/gitlab-secrets.json.`date +%F`
   ```

1. 将 `/etc/gitlab/gitlab-secrets.json` 从主站点的 Rails 节点复制到每个辅助站点节点。
   你也可以在节点之间复制粘贴文件内容：

   ```shell
   sudo editor /etc/gitlab/gitlab-secrets.json

   # 粘贴你在主站点上运行的 `cat` 命令的输出
   # 保存并退出
   ```

1. 确保文件权限正确：

   ```shell
   chown root:root /etc/gitlab/gitlab-secrets.json
   chmod 0600 /etc/gitlab/gitlab-secrets.json
   ```

1. 要应用更改，重新配置每个辅助站点的 Rails、Sidekiq 和 Gitaly 节点：

   ```shell
   gitlab-ctl reconfigure
   gitlab-ctl restart
   ```

<a id="manually-replicate-the-primary-site-ssh-host-keys"></a>

### 手动复制主站点 SSH 主机密钥

1. SSH 到辅助站点上的每个节点，并以 root 身份登录：

   ```shell
   sudo -i
   ```

1. 备份任何现有的 SSH 主机密钥：

   ```shell
   find /etc/ssh -iname 'ssh_host_*' -exec cp {} {}.backup.`date +%F` \;
   ```

1. 从主站点复制 OpenSSH 主机密钥。

   - 如果你可以以 root 身份访问主站点上处理 SSH 流量的某个节点（通常是主要的 GitLab Rails 应用节点）：

     ```shell
     # 从辅助站点运行，将 `<primary_site_fqdn>` 更改为服务器的 IP 或 FQDN
     scp root@<primary_node_fqdn>:/etc/ssh/ssh_host_*_key* /etc/ssh
     ```

   - 如果你只能通过具有 `sudo` 权限的用户访问：

     ```shell
     # 从主站点的节点运行：
     sudo tar --transform 's/.*\///g' -zcvf ~/geo-host-key.tar.gz /etc/ssh/ssh_host_*_key*

     # 在辅助站点的每个节点上运行：
     scp <user_with_sudo>@<primary_site_fqdn>:geo-host-key.tar.gz .
     tar zxvf ~/geo-host-key.tar.gz -C /etc/ssh
     ```

1. 对于每个辅助站点节点，确保文件权限正确：

   ```shell
   chown root:root /etc/ssh/ssh_host_*_key*
   chmod 0600 /etc/ssh/ssh_host_*_key
   ```

1. 要验证密钥指纹是否匹配，在每个站点的主节点和辅助节点上执行以下命令：

   ```shell
   for file in /etc/ssh/ssh_host_*_key; do ssh-keygen -lf $file; done
   ```

   你应该获得类似以下的输出：

   ```shell
   1024 SHA256:FEZX2jQa2bcsd/fn/uxBzxhKdx4Imc4raXrHwsbtP0M root@serverhostname (DSA)
   256 SHA256:uw98R35Uf+fYEQ/UnJD9Br4NXUFPv7JAUln5uHlgSeY root@serverhostname (ECDSA)
   256 SHA256:sqOUWcraZQKd89y/QQv/iynPTOGQxcOTIXU/LsoPmnM root@serverhostname (ED25519)
   2048 SHA256:qwa+rgir2Oy86QI+PZi/QVR+MSmrdrpsuH7YyKknC+s root@serverhostname (RSA)
   ```

   两个节点上的输出应完全相同。

1. 验证现有私钥对应的公钥是否正确：

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

1. 要验证 SSH 仍然可用，请从一个新终端 SSH 到你的极狐GitLab 辅助服务器。如果无法连接，请确保你拥有正确的权限。

<a id="add-the-secondary-site"></a>

### 添加辅助站点

1. SSH 到辅助站点上的每个 Rails 和 Sidekiq 节点，并以 root 身份登录：

   ```shell
   sudo -i
   ```

1. 编辑 `/etc/gitlab/gitlab.rb` 并为你的站点添加一个唯一的名称。

   ```ruby
   ##
   ## Geo 站点的唯一标识符。请参阅
   ## https://gitlab.cn/docs/administration/geo_sites/#common-settings
   ##
   gitlab_rails['geo_node_name'] = '<site_name_here>'
   ```

   保存此唯一名称以供后续步骤使用。

1. 要应用更改，重新配置辅助站点上的每个 Rails 和 Sidekiq 节点。

   ```shell
   gitlab-ctl reconfigure
   ```

1. 转到主节点极狐GitLab 实例：
   1. 在右上角，选择 **管理员**。
   1. 选择 **Geo** > **站点**。
   1. 选择 **添加站点**。

      ![添加新站点的表单，包含三个输入字段：名称、外部 URL 和内部 URL（可选）。](img/adding_a_secondary_v15_8.png)

   1. 在 **名称** 中，输入 `/etc/gitlab/gitlab.rb` 中 `gitlab_rails['geo_node_name']` 的值。这些值必须完全匹配。
   1. 在 **外部 URL** 中，输入 `/etc/gitlab/gitlab.rb` 中 `external_url` 的值。如果一方以 `/` 结尾而另一方没有，这是可以的。否则，值必须完全匹配。
   1. 可选。在 **内部 URL（可选）** 中，为主站点输入一个内部 URL。
   1. 可选。选择辅助站点应复制哪些群组或存储分片。要复制全部，请将字段留空。请参阅 [选择性同步](../replication/selective_synchronization.md)。
   1. 选择 **保存更改**。
1. SSH 到辅助站点上的每个 Rails 和 Sidekiq 节点，并重启服务：

   ```shell
   gitlab-ctl restart
   ```

1. 检查你的 Geo 设置是否有常见问题，运行：

   ```shell
   gitlab-rake gitlab:geo:check
   ```

   如果任何检查失败，请参阅 [故障排除文档](../replication/troubleshooting/_index.md)。

1. 要验证辅助站点是否可访问，请 SSH 到主站点上的 Rails 或 Sidekiq 服务器，并以 root 身份登录：

   ```shell
   gitlab-rake gitlab:geo:check
   ```

   如果任何检查失败，请查看 [故障排除文档](../replication/troubleshooting/_index.md)。

辅助站点添加到 Geo 管理页面并重启后，站点会自动开始从主站点复制丢失的数据，这一过程称为回填。同时，主站点开始向每个辅助站点通知任何更改，以便辅助站点可以立即处理这些通知。

请确保辅助站点正在运行且可访问。你可以使用与主站点相同的凭据登录辅助站点。

<a id="add-primary-and-secondary-urls-as-allowed-actioncable-origins"></a>

### 将主 URL 和辅助 URL 添加为允许的 ActionCable 来源

此步骤允许 websocket 在主站点和辅助站点之间无缝工作。

1. 收集站点的 **外部 URL**（主站点和辅助站点）。你可以在管理区域的站点页面中找到它们，如前所述。
1. SSH 到 **主站点** 上的每个 Rails 和 Sidekiq 节点，并以 root 身份登录：

   ```shell
   sudo -i
   ```

1. 编辑 `/etc/gitlab/gitlab.rb` 将步骤 1 中收集的 URL 添加到 `action_cable_allowed_origins` 设置：
    ```ruby
   gitlab_rails['action_cable_allowed_origins'] = ['https://secondary.example.com', 'https://primary.example.com']
   ```

1. 要使更改生效，请重新配置每个 Rails 和 Sidekiq 节点并重启服务：

   ```shell
   gitlab-ctl reconfigure
   gitlab-ctl restart
   ```

### 启用 HTTP/HTTPS 和 SSH 的 Git 访问

Geo 通过 HTTP/HTTPS 同步仓库，因此需要启用此克隆方式。默认已启用。
如果您要将现有站点转换为 Geo，应检查克隆方式是否已启用。

在主站点上：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **可见性和访问控制**。
1. 如果您通过 SSH 使用 Git：
   1. 确保 **启用的 Git 访问协议** 设置为 **SSH 和 HTTP(S) 均可**。
   1. 在主站点和从站点上，都遵循 [在数据库中快速查找已授权的 SSH 密钥](../../operations/fast_ssh_key_lookup.md)。
1. 如果您不通过 SSH 使用 Git，则将 **启用的 Git 访问协议** 设置为 **仅 HTTP(S)**。

### 验证从站点的正常运行

您可以使用在主站点上使用的相同凭据登录从站点。

登录后：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **Geo** > **站点**。
1. 验证该站点是否正确识别为 Geo 从站点，并且 Geo 已启用。

初始复制可能需要一些时间。
您可以通过浏览器从主站点的 **Geo 站点** 仪表板监控每个 Geo 站点的同步进程。

![Geo 站点仪表板，显示同步状态。](img/geo_dashboard_v14_0.png)

## 配置示例

### 完整的主站点配置

<!-- 如果您更新此配置示例，请同时更新 two_single_node_external_services.md 中的示例 -->

这是用于 Geo 主站点的完整 `gitlab.rb` 配置示例：

```ruby
# 主站点配置示例

## Geo 主站点角色
roles(['geo_primary_role'])

## Geo 站点的唯一标识符
gitlab_rails['geo_node_name'] = 'headquarters'

## 外部 URL
external_url 'https://gitlab.example.com'

## 数据库配置
gitlab_rails['db_password'] = 'your_database_password_here'
postgresql['sql_user_password'] = 'md5_hash_of_your_database_password'
postgresql['sql_replication_password'] = 'md5_hash_of_your_replication_password'

## PostgreSQL 网络配置
postgresql['listen_address'] = '10.0.1.10'  # 主站点 IP
postgresql['md5_auth_cidr_addresses'] = ['10.0.1.10/32', '10.0.2.10/32']  # 主站点和从站点 IP

## 禁用自动迁移（集中管理，避免计划外停机）
gitlab_rails['auto_migrate'] = false

## SSL/TLS 配置
nginx['listen_port'] = 80
nginx['listen_https'] = false
letsencrypt['enable'] = false

## 对象存储配置（可选）
gitlab_rails['object_store']['enabled'] = true
gitlab_rails['object_store']['connection'] = {
  'provider' => 'AWS',
  'region' => 'us-east-1',
  'aws_access_key_id' => 'your_access_key',
  'aws_secret_access_key' => 'your_secret_key'
}

## 监控配置（可选）
node_exporter['listen_address'] = '0.0.0.0:9100'
gitlab_workhorse['prometheus_listen_addr'] = '0.0.0.0:9229'
gitlab_rails['monitoring_whitelist'] = ['127.0.0.0/8', '10.0.0.0/8']

## Gitaly 配置
gitaly['configuration'] = {
  prometheus_listen_addr: '0.0.0.0:9236',
}

## ActionCable 允许的源
gitlab_rails['action_cable_allowed_origins'] = ['https://secondary.example.com', 'https://primary.example.com']
```

### 完整的从站点配置

<!-- 如果您更新此配置示例，请同时更新 two_single_node_external_services.md 中的示例 -->

这是用于 Geo 从站点的完整 `gitlab.rb` 配置示例：

```ruby
# 从站点配置示例

## Geo 从站点角色
roles(['geo_secondary_role'])

## Geo 站点的唯一标识符
gitlab_rails['geo_node_name'] = 'location-2'

## 外部 URL（统一 URL 设置下可与主站点相同）
external_url 'https://gitlab.example.com'

## 数据库配置
gitlab_rails['db_password'] = 'your_database_password_here'
postgresql['sql_user_password'] = 'md5_hash_of_your_database_password'
postgresql['sql_replication_password'] = 'md5_hash_of_your_replication_password'

## PostgreSQL 网络配置
postgresql['listen_address'] = '10.0.2.10'  # 从站点 IP
postgresql['md5_auth_cidr_addresses'] = ['10.0.2.10/32']

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

## 监控配置（可选）
node_exporter['listen_address'] = '0.0.0.0:9100'
gitlab_workhorse['prometheus_listen_addr'] = '0.0.0.0:9229'
gitlab_rails['monitoring_whitelist'] = ['127.0.0.0/8', '10.0.0.0/8']

## Gitaly 配置
gitaly['configuration'] = {
  prometheus_listen_addr: '0.0.0.0:9236',
}
```

## 相关主题

- [Geo 故障排除](../replication/troubleshooting/_index.md)