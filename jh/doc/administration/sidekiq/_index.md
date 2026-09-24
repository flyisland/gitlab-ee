---
stage: Tenant Scale
group: Tenant Services
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 配置外部 Sidekiq 实例
description: Configure an external Sidekiq instance.
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

你可以使用极狐GitLab 软件包中捆绑的 Sidekiq 来配置外部 Sidekiq 实例。Sidekiq 需要连接到 Redis、PostgreSQL 和 Gitaly 实例。

<a id="configure-tcp-access-for-postgresql-gitaly-and-redis-on-the-gitlab-instance"></a>

## 在极狐GitLab 实例上为 PostgreSQL、Gitaly 和 Redis 配置 TCP 访问

默认情况下，极狐GitLab 使用 UNIX 套接字，并未设置为通过 TCP 进行通信。要更改此设置：

1. [配置打包的 PostgreSQL 服务器以监听 TCP/IP](https://gitlab.cn/docs/omnibus/settings/database/#configure-packaged-postgresql-server-to-listen-on-tcpip)，将 Sidekiq 服务器的 IP 地址添加到 `postgresql['md5_auth_cidr_addresses']`
1. [使捆绑的 Redis 可通过 TCP 访问](https://gitlab.cn/docs/omnibus/settings/redis/#making-the-bundled-redis-reachable-via-tcp)
1. 在极狐GitLab 实例上编辑 `/etc/gitlab/gitlab.rb` 文件，并添加以下内容：

   ```ruby
   ## Gitaly
   gitaly['configuration'] = {
      # ...
      #
      # 让 Gitaly 在所有网络接口上接受连接
      listen_addr: '0.0.0.0:8075',
      auth: {
         ## 设置 Gitaly 令牌作为身份验证形式，因为你是通过网络访问 Gitaly
         ## https://gitlab.cn/docs/administration/gitaly/configure_gitaly/#about-the-gitaly-token
         token: 'abc123secret',
      },
   }

   gitlab_rails['gitaly_token'] = 'abc123secret'

   # 用于验证 Redis 的密码
   gitlab_rails['redis_password'] = 'redis-password-goes-here'
   ```

1. 运行 `reconfigure`：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

1. 重启 `PostgreSQL` 服务器：

   ```shell
   sudo gitlab-ctl restart postgresql
   ```

<a id="set-up-sidekiq-instance"></a>

## 设置 Sidekiq 实例

查找[你的参考架构](../reference_architectures/_index.md#available-reference-architectures)，并遵循 Sidekiq 实例设置详情。

<a id="configure-multiple-sidekiq-nodes-with-shared-storage"></a>

## 配置使用共享存储的多个 Sidekiq 节点

如果你运行多个 Sidekiq 节点并使用共享文件存储（例如 NFS），你必须指定 UID 和 GID，以确保它们在服务器之间匹配。指定 UID 和 GID 可以防止文件系统中的权限问题。此建议与[针对 Geo 设置的指南](../geo/replication/multiple_servers.md#step-4-configure-the-frontend-application-nodes-on-the-geo-secondary-site)类似。

要设置多个 Sidekiq 节点：

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   user['uid'] = 9000
   user['gid'] = 9000
   web_server['uid'] = 9001
   web_server['gid'] = 9001
   registry['uid'] = 9002
   registry['gid'] = 9002
   ```

1. 重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

<a id="configure-the-container-registry-when-using-an-external-sidekiq"></a>

## 在使用外部 Sidekiq 时配置容器镜像仓库

如果你正在使用容器镜像仓库，并且它运行在与 Sidekiq 不同的节点上，请按照以下步骤操作。

1. 编辑 `/etc/gitlab/gitlab.rb`，并配置镜像仓库 URL：

   ```ruby
   gitlab_rails['registry_api_url'] = "https://registry.example.com"
   ```

1. 重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

1. 在托管容器镜像仓库的实例中，将 `registry.key` 文件复制到 Sidekiq 节点。

<a id="configure-the-sidekiq-metrics-server"></a>

## 配置 Sidekiq 指标服务器

如果你想收集 Sidekiq 指标，请启用 Sidekiq 指标服务器。
要使其在 `localhost:8082/metrics` 上可用：

配置指标服务器：

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   sidekiq['metrics_enabled'] = true
   sidekiq['listen_address'] = "localhost"
   sidekiq['listen_port'] = 8082

   # 可选择将所有指标服务器日志记录到 log/sidekiq_exporter.log
   sidekiq['exporter_log_enabled'] = true
   ```

1. 重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

<a id="enable-https"></a>

### 启用 HTTPS

{{< history >}}

- 在极狐GitLab 15.2 中引入。

{{< /history >}}

要通过 HTTPS 而非 HTTP 提供指标，请在导出器设置中启用 TLS：

1. 编辑 `/etc/gitlab/gitlab.rb` 以添加（或查找并取消注释）以下行：

   ```ruby
   sidekiq['exporter_tls_enabled'] = true
   sidekiq['exporter_tls_cert_path'] = "/path/to/certificate.pem"
   sidekiq['exporter_tls_key_path'] = "/path/to/private-key.pem"
   ```

1. 保存文件并[重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

启用 TLS 后，会使用与之前所述相同的 `port` 和 `address`。指标服务器无法同时提供 HTTP 和 HTTPS。

<a id="configure-health-checks"></a>

## 配置健康检查

如果你使用健康检查探针来观察 Sidekiq，请启用 Sidekiq 健康检查服务器。
要使其在 `localhost:8092` 上可用：

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   sidekiq['health_checks_enabled'] = true
   sidekiq['health_checks_listen_address'] = "localhost"
   sidekiq['health_checks_listen_port'] = 8092
   ```

1. 重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

有关健康检查的更多信息，请参见 [Sidekiq 健康检查页面](sidekiq_health_check.md)。

<a id="configure-ldap-and-user-or-group-synchronization"></a>

## 配置 LDAP 以及用户或群组同步

如果你使用 LDAP 进行用户和群组管理，则必须将 LDAP 配置以及 LDAP 同步 worker 添加到 Sidekiq 节点。如果 LDAP 配置和 LDAP 同步 worker 没有应用到 Sidekiq 节点，用户和群组将不会自动同步。

有关为极狐GitLab 配置 LDAP 的更多信息，请参阅：

- [极狐GitLab LDAP 配置文档](../auth/ldap/_index.md#configure-ldap)
- [LDAP 同步文档](../auth/ldap/ldap_synchronization.md#adjust-ldap-sync-schedule)

要为 Sidekiq 启用带同步 worker 的 LDAP：

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['ldap_enabled'] = true
   gitlab_rails['prevent_ldap_sign_in'] = false
   gitlab_rails['ldap_servers'] = {
   'main' => {
   'label' => 'LDAP',
   'host' => 'ldap.mydomain.com',
   'port' => 389,
   'uid' => 'sAMAccountName',
   'encryption' => 'simple_tls',
   'verify_certificates' => true,
   'bind_dn' => '_the_full_dn_of_the_user_you_will_bind_with',
   'password' => '_the_password_of_the_bind_user',
   'tls_options' => {
      'ca_file' => '',
      'ssl_version' => '',
      'ciphers' => '',
      'cert' => '',
      'key' => ''
   },
   'timeout' => 10,
   'active_directory' => true,
   'allow_username_or_email_login' => false,
   'block_auto_created_users' => false,
   'base' => 'dc=example,dc=com',
   'user_filter' => '',
   'attributes' => {
      'username' => ['uid', 'userid', 'sAMAccountName'],
      'email' => ['mail', 'email', 'userPrincipalName'],
      'name' => 'cn',
      'first_name' => 'givenName',
      'last_name' => 'sn'
   },
   'lowercase_usernames' => false,

   # 仅限企业版
   # https://gitlab.cn/docs/administration/auth/ldap/ldap_synchronization/
   'group_base' => '',
   'admin_group' => '',
   'external_groups' => [],
   'sync_ssh_keys' => false
   }
   }
   gitlab_rails['ldap_sync_worker_cron'] = "0 */12 * * *"
   ```

1. 重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

<a id="configure-saml-groups-for-saml-group-sync"></a>

## 为 SAML 群组同步配置 SAML 群组

如果你使用 [SAML 群组同步](../../user/group/saml_sso/group_sync.md)，则必须在所有 Sidekiq 节点上配置 [SAML 群组](../../integration/saml.md#configure-users-based-on-saml-group-membership)。

## 相关主题

- [额外 Sidekiq 进程](extra_sidekiq_processes.md)
- [处理特定作业类](processing_specific_job_classes.md)
- [Sidekiq 健康检查](sidekiq_health_check.md)
- [使用极狐GitLab-Sidekiq Chart](https://gitlab.cn/docs/charts/charts/gitlab/sidekiq/)

## 故障排除

请参阅我们的 [Sidekiq 故障排除管理员指南](sidekiq_troubleshooting.md)。