---
stage: Async
group: Async
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用 TLS 保护 Redis 和 Sentinel
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

使用 TLS（传输层安全协议）保护 Redis 和 Sentinel 的通信。同时支持标准 TLS（服务器证书验证）和双向 TLS（mTLS，客户端和服务器相互认证）。

如果您为 Redis 或 Sentinel 启用 TLS，则应在部署中为 Redis 和 Sentinel 都启用。在同一环境中混用 TLS 和非 TLS 连接可能导致配置复杂化和潜在的安全问题。

要禁用标准的非 TLS 端口并仅接受 TLS 连接，请在配置中将端口设置为 0。例如：

- 添加 `redis['port'] = 0` 以禁用标准 Redis 端口（6379）。
- 添加 `sentinel['port'] = 0` 以禁用标准 Sentinel 端口（26379）。

<a id="generate-tls-certificate-and-key-files"></a>

## 生成 TLS 证书和密钥文件

在配置 TLS 之前，您必须生成或获取以下证书和密钥。以下示例文件名将在全文中使用：

- **CA 证书**（`ca.crt`）：用于验证服务器证书的证书颁发机构证书。
- **服务器证书**（`redis-server.crt`）：Redis 服务器的证书（由 CA 签名）。
- **服务器密钥**（`redis-server.key`）：Redis 服务器证书的私钥。
- **Sentinel 服务器证书**（`sentinel-server.crt`）：Sentinel 服务器的证书（由 CA 签名）。
- **Sentinel 服务器密钥**（`sentinel-server.key`）：Sentinel 服务器证书的私钥。
- **客户端证书**（`redis-client.crt`，用于 mTLS）：客户端的证书（由 CA 签名）。
- **客户端密钥**（`redis-client.key`，用于 mTLS）：客户端证书的私钥。

这些示例使用 `/etc/gitlab/ssl/` 作为证书目录，但只要为需要读取证书的进程设置了适当的文件权限，您可以将证书存储在任何目录中。

<a id="sample-certificate-generation-script"></a>

### 示例证书生成脚本

以下脚本为 Redis 和 Sentinel 生成一套完整的证书，并带有正确的 SAN。在运行之前，您必须自定义 IP 地址和主机名以匹配您的实际基础设施。

> [!warning]
> CA 私钥（`ca.key`）属于敏感信息。生成证书后，请考虑将 CA 私钥安全地离线存储，并将其从生产服务器中移除。

1. 创建一个名为 `generate-redis-certs.sh`的文件，内容如下：

   ```shell
   #!/bin/bash

   # Configuration: CUSTOMIZE THESE VALUES FOR YOUR INFRASTRUCTURE
   CERT_DIR="/etc/gitlab/ssl"
   CA_CN="redis-ca"
   REDIS_HOSTNAMES="redis-primary,redis-replica-1,redis-replica-2"
   REDIS_IPS="10.0.0.1,10.0.0.2,10.0.0.3"
   SENTINEL_HOSTNAMES="sentinel-1,sentinel-2,sentinel-3"
   SENTINEL_IPS="10.0.0.1,10.0.0.2,10.0.0.3"
   CERT_DAYS=365

   mkdir -p "$CERT_DIR"

   # Create OpenSSL config for SAN extensions
   cat > /tmp/redis-san.conf << EOF
   [redis_server]
   subjectAltName = DNS:${REDIS_HOSTNAMES},IP:${REDIS_IPS}

   [sentinel_server]
   subjectAltName = DNS:${SENTINEL_HOSTNAMES},IP:${SENTINEL_IPS}

   [redis_client]
   subjectAltName = DNS:redis-client
   EOF

   # Generate CA certificate
   echo "Generating CA certificate..."
   openssl genrsa -out "$CERT_DIR/ca.key" 2048
   openssl req -new -x509 -days "$CERT_DAYS" -key "$CERT_DIR/ca.key" \
     -out "$CERT_DIR/ca.crt" -subj "/CN=$CA_CN"

   # Generate Redis server certificate
   echo "Generating Redis server certificate..."
   openssl genrsa -out "$CERT_DIR/redis-server.key" 2048
   openssl req -new -key "$CERT_DIR/redis-server.key" \
     -out "$CERT_DIR/redis-server.csr" -subj "/CN=redis-server"
   openssl x509 -req -days "$CERT_DAYS" -in "$CERT_DIR/redis-server.csr" \
     -CA "$CERT_DIR/ca.crt" -CAkey "$CERT_DIR/ca.key" -CAcreateserial \
     -out "$CERT_DIR/redis-server.crt" \
     -extensions redis_server -extfile /tmp/redis-san.conf

   # Generate Sentinel server certificate
   echo "Generating Sentinel server certificate..."
   openssl genrsa -out "$CERT_DIR/sentinel-server.key" 2048
   openssl req -new -key "$CERT_DIR/sentinel-server.key" \
     -out "$CERT_DIR/sentinel-server.csr" -subj "/CN=sentinel-server"
   openssl x509 -req -days "$CERT_DAYS" -in "$CERT_DIR/sentinel-server.csr" \
     -CA "$CERT_DIR/ca.crt" -CAkey "$CERT_DIR/ca.key" -CAcreateserial \
     -out "$CERT_DIR/sentinel-server.crt" \
     -extensions sentinel_server -extfile /tmp/redis-san.conf

   # Generate client certificate (for mTLS)
   echo "Generating Redis client certificate..."
   openssl genrsa -out "$CERT_DIR/redis-client.key" 2048
   openssl req -new -key "$CERT_DIR/redis-client.key" \
     -out "$CERT_DIR/redis-client.csr" -subj "/CN=redis-client"
   openssl x509 -req -days "$CERT_DAYS" -in "$CERT_DIR/redis-client.csr" \
     -CA "$CERT_DIR/ca.crt" -CAkey "$CERT_DIR/ca.key" -CAcreateserial \
     -out "$CERT_DIR/redis-client.crt" \
     -extensions redis_client -extfile /tmp/redis-san.conf

   # Clean up CSR files and temp config
   rm -f "$CERT_DIR"/*.csr /tmp/redis-san.conf

   # Set basic permissions (will be refined in the next steps)
   chmod 600 "$CERT_DIR"/*.key
   chmod 644 "$CERT_DIR"/*.crt

   echo "Certificates generated in $CERT_DIR"
   echo "Next: Configure file permissions based on your deployment (separate or shared nodes)"
   ```

1. 更新脚本中的以下变量以匹配您的基础设施：

   - `REDIS_HOSTNAMES`：所有 Redis 服务器主机名的逗号分隔列表。
   - `REDIS_IPS`：所有 Redis 服务器 IP 地址的逗号分隔列表。
   - `SENTINEL_HOSTNAMES`：所有 Sentinel 服务器主机名的逗号分隔列表。
   - `SENTINEL_IPS`：所有 Sentinel 服务器 IP 地址的逗号分隔列表。
   - `CERT_DAYS`：证书有效期（以天为单位，默认值：365）。

   证书必须包含客户端用于连接 Redis 或 Sentinel 的所有主机名和 IP 地址。例如，如果客户端连接到 `redis.example.com` 和 `10.0.0.1`，则两者都必须包含在 SAN 中。
1. 运行脚本：

   ```shell
   chmod +x generate-redis-certs.sh
   sudo ./generate-redis-certs.sh
   ```

<a id="set-certificate-and-key-file-permissions"></a>

### 设置证书和密钥文件权限

默认情况下，极狐GitLab 进程以不同的用户身份运行：

- Redis 和 Sentinel 进程以 `gitlab-redis` 用户身份运行。
- Puma（GitLab Rails）、Workhorse 和 KAS 进程以 `git` 用户身份运行。

将证书和密钥放入 `/etc/gitlab/ssl/` 后，请确保文件权限足够，以便所有需要的进程都能读取它们。

<a id="when-running-separate-nodes"></a>

#### 在独立节点上运行时

如果 Redis/Sentinel 与极狐GitLab 应用运行在不同的节点上（Redis 在不同的机器上）：

1. 在 Redis/Sentinel 节点上，运行以下命令：

   ```shell
   # Set ownership to the gitlab-redis user (for Redis/Sentinel processes only)
   sudo chown gitlab-redis:gitlab-redis /etc/gitlab/ssl/redis-*.{crt,key}
   sudo chown gitlab-redis:gitlab-redis /etc/gitlab/ssl/sentinel-*.{crt,key}
   sudo chown gitlab-redis:gitlab-redis /etc/gitlab/ssl/ca.crt

   # Set restrictive permissions (readable by owner only)
   sudo chmod 600 /etc/gitlab/ssl/redis-*.key
   sudo chmod 600 /etc/gitlab/ssl/sentinel-*.key
   sudo chmod 644 /etc/gitlab/ssl/redis-*.crt
   sudo chmod 644 /etc/gitlab/ssl/sentinel-*.crt
   sudo chmod 644 /etc/gitlab/ssl/ca.crt
   ```

1. 在极狐GitLab 应用节点上（用于 mTLS 客户端连接），运行以下命令：

   ```shell
   # For GitLab Rails, Workhorse, and KAS processes (running as 'git' user)
   sudo chown root:git /etc/gitlab/ssl/redis-client.{crt,key}
   sudo chown root:git /etc/gitlab/ssl/ca.crt
   sudo chmod 640 /etc/gitlab/ssl/redis-client.crt
   sudo chmod 640 /etc/gitlab/ssl/redis-client.key
   sudo chmod 644 /etc/gitlab/ssl/ca.crt
   ```

<a id="when-running-a-shared-node"></a>

#### 在共享节点上运行时

如果 Redis/Sentinel 和极狐GitLab 应用进程运行在同一节点上，您必须允许 `gitlab-redis` 和 `git` 两个用户都能读取证书。请使用共享组的方式。

1. 在共享节点上，运行以下命令：

   ```shell
   # Create a shared group for certificate access (if it doesn't exist)
   sudo groupadd -f gitlab-certs

   # Add both users to the shared group
   sudo usermod -a -G gitlab-certs gitlab-redis
   sudo usermod -a -G gitlab-certs git

   # Set ownership and permissions for server certificates (Redis/Sentinel)
   sudo chown gitlab-redis:gitlab-certs /etc/gitlab/ssl/redis-server.{crt,key}
   sudo chown gitlab-redis:gitlab-certs /etc/gitlab/ssl/sentinel-server.{crt,key}
   sudo chmod 640 /etc/gitlab/ssl/redis-server.key
   sudo chmod 644 /etc/gitlab/ssl/redis-server.crt
   sudo chmod 644 /etc/gitlab/ssl/sentinel-server.key
   sudo chmod 644 /etc/gitlab/ssl/sentinel-server.crt

   # Set ownership and permissions for client certificates (GitLab processes)
   sudo chown root:gitlab-certs /etc/gitlab/ssl/redis-client.{crt,key}
   sudo chown root:gitlab-certs /etc/gitlab/ssl/ca.crt
   sudo chmod 640 /etc/gitlab/ssl/redis-client.key
   sudo chmod 644 /etc/gitlab/ssl/redis-client.crt
   sudo chmod 644 /etc/gitlab/ssl/ca.crt
   ```

1. 更改权限后，重启极狐GitLab：

   ```shell
   sudo gitlab-ctl restart
   ```

1. 通过检查日志来验证进程能否读取这些文件：

   ```shell
   sudo gitlab-ctl tail
   ```

<a id="enable-standard-tls"></a>

## 启用标准 TLS

标准 TLS 是指客户端验证服务器的证书。服务器不要求也不验证客户端证书。

> [!note]
> 以下示例中显示的证书文件路径（例如 `/etc/gitlab/ssl/redis-server.crt`）为占位符。请使用您的证书生成过程实际生成的文件名。如果您使用了上面的示例脚本，文件名将与这些示例一致。

<a id="configure-redis-with-standard-tls"></a>

### 使用标准 TLS 配置 Redis

使用 TLS 配置 Redis 主节点：

1. 在主 Redis 服务器上编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   roles ['redis_master_role']

   redis['bind'] = '10.0.0.1'
   redis['port'] = 6379
   redis['password'] = 'redis-password-goes-here'

   # Enable TLS for Redis
   redis['tls_port'] = 6380
   redis['tls_cert_file'] = '/etc/gitlab/ssl/redis-server.crt'
   redis['tls_key_file'] = '/etc/gitlab/ssl/redis-server.key'
   redis['tls_ca_cert_file'] = '/etc/gitlab/ssl/ca.crt'
   redis['tls_replication'] = 'yes'
   ```

1. [重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

使用 TLS 配置 Redis 副本：

1. 在每个副本 Redis 服务器上编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   roles ['redis_replica_role']

   redis['bind'] = '10.0.0.2'
   redis['port'] = 6379
   redis['password'] = 'redis-password-goes-here'
   redis['master_ip'] = '10.0.0.1'
   redis['master_port'] = 6380  # Use TLS port

   # Enable TLS for Redis
   redis['tls_port'] = 6380
   redis['tls_cert_file'] = '/etc/gitlab/ssl/redis-server.crt'
   redis['tls_key_file'] = '/etc/gitlab/ssl/redis-server.key'
   redis['tls_ca_cert_file'] = '/etc/gitlab/ssl/ca.crt'
   redis['tls_replication'] = 'yes'
   ```

1. [重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

配置极狐GitLab 应用以使用 TLS 连接到 Redis：

1. 在极狐GitLab 应用服务器上编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   # Configure Redis with TLS
   gitlab_rails['redis_host'] = '10.0.0.1'
   gitlab_rails['redis_port'] = 6380
   gitlab_rails['redis_password'] = 'redis-password-goes-here'

   # Enable TLS for Redis
   gitlab_rails['redis_ssl'] = true

   # Provide CA certificate for validation
   gitlab_rails['redis_tls_ca_cert_file'] = '/etc/gitlab/ssl/ca.crt'
   ```

1. [重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

<a id="configure-sentinel-with-standard-tls"></a>

### 使用标准 TLS 配置 Sentinel

使用 TLS 配置 Sentinel 服务器：

1. 在每个 Sentinel 服务器上编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   roles ['redis_sentinel_role']

   redis['master_name'] = 'gitlab-redis'
   redis['master_password'] = 'redis-password-goes-here'
   redis['master_ip'] = '10.0.0.1'
   redis['port'] = 6379

   # Enable TLS for Sentinel
   sentinel['bind'] = '10.0.0.1'
   sentinel['port'] = 26379
   sentinel['tls_port'] = 26380
   sentinel['tls_cert_file'] = '/etc/gitlab/ssl/sentinel-server.crt'
   sentinel['tls_key_file'] = '/etc/gitlab/ssl/sentinel-server.key'
   sentinel['tls_ca_cert_file'] = '/etc/gitlab/ssl/ca.crt'
   sentinel['tls_replication'] = 'yes'
   ```

1. [重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

配置极狐GitLab 应用以使用 TLS 连接到 Sentinel：

1. 在极狐GitLab 应用服务器上编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   redis['master_name'] = 'gitlab-redis'
   redis['master_password'] = 'redis-password-goes-here'

   # Configure Sentinels with TLS
   gitlab_rails['redis_sentinels'] = [
     { 'host' => '10.0.0.1', 'port' => 26380 },
     { 'host' => '10.0.0.2', 'port' => 26380 },
     { 'host' => '10.0.0.3', 'port' => 26380 }
   ]

   # Enable TLS for Sentinel
   gitlab_rails['redis_sentinels_ssl'] = true

   # Provide CA certificate for validation
   gitlab_rails['redis_sentinels_tls_ca_cert_file'] = '/etc/gitlab/ssl/ca.crt'
   ```

1. [重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

<a id="enable-mutual-tls-mtls"></a>

## 启用双向 TLS（mTLS）

双向 TLS 要求客户端和服务器使用证书相互认证。

<a id="configure-redis-with-mutual-tls"></a>

### 使用双向 TLS 配置 Redis

使用 mTLS 配置 Redis 主节点：

1. 在主 Redis 服务器上编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   roles ['redis_master_role']

   redis['bind'] = '10.0.0.1'
   redis['port'] = 6379
   redis['password'] = 'redis-password-goes-here'

   # Enable mTLS for Redis
   redis['tls_port'] = 6380
   redis['tls_cert_file'] = '/etc/gitlab/ssl/redis-server.crt'
   redis['tls_key_file'] = '/etc/gitlab/ssl/redis-server.key'
   redis['tls_ca_cert_file'] = '/etc/gitlab/ssl/ca.crt'
   redis['tls_replication'] = 'yes'

   # Require client certificate validation
   redis['tls_auth_clients'] = 'yes'
   ```

1. [重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

使用 mTLS 配置 Redis 副本：

1. 在每个副本 Redis 服务器上编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   roles ['redis_replica_role']

   redis['bind'] = '10.0.0.2'
   redis['port'] = 6379
   redis['password'] = 'redis-password-goes-here'
   redis['master_ip'] = '10.0.0.1'
   redis['master_port'] = 6380  # Use TLS port

   # Enable mTLS for Redis
   redis['tls_port'] = 6380
   redis['tls_cert_file'] = '/etc/gitlab/ssl/redis-server.crt'
   redis['tls_key_file'] = '/etc/gitlab/ssl/redis-server.key'
   redis['tls_ca_cert_file'] = '/etc/gitlab/ssl/ca.crt'
   redis['tls_replication'] = 'yes'

   # Require client certificate validation
   redis['tls_auth_clients'] = 'yes'
   ```

1. [重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

配置极狐GitLab 应用以使用 mTLS 连接到 Redis：

1. 在极狐GitLab 应用服务器上编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   # Configure Redis with mTLS
   gitlab_rails['redis_host'] = '10.0.0.1'
   gitlab_rails['redis_port'] = 6380
   gitlab_rails['redis_password'] = 'redis-password-goes-here'

   # Enable TLS for Redis
   gitlab_rails['redis_ssl'] = true

   # Provide CA certificate for validation
   gitlab_rails['redis_tls_ca_cert_file'] = '/etc/gitlab/ssl/ca.crt'

   # Provide client certificate and key for mTLS
   gitlab_rails['redis_tls_client_cert_file'] = '/etc/gitlab/ssl/redis-client.crt'
   gitlab_rails['redis_tls_client_key_file'] = '/etc/gitlab/ssl/redis-client.key'
   ```

1. [重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

<a id="configure-sentinel-with-mutual-tls"></a>

### 使用双向 TLS 配置 Sentinel

使用 mTLS 配置 Sentinel 服务器：

1. 在每个 Sentinel 服务器上编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   roles ['redis_sentinel_role']

   redis['master_name'] = 'gitlab-redis'
   redis['master_password'] = 'redis-password-goes-here'
   redis['master_ip'] = '10.0.0.1'
   redis['port'] = 6379

   # Enable mTLS for Sentinel
   sentinel['bind'] = '10.0.0.1'
   sentinel['port'] = 26379
   sentinel['tls_port'] = 26380
   sentinel['tls_cert_file'] = '/etc/gitlab/ssl/sentinel-server.crt'
   sentinel['tls_key_file'] = '/etc/gitlab/ssl/sentinel-server.key'
   sentinel['tls_ca_cert_file'] = '/etc/gitlab/ssl/ca.crt'
   sentinel['tls_replication'] = 'yes'

   # Require client certificate validation
   sentinel['tls_auth_clients'] = 'yes'
   ```

1. [重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

配置极狐GitLab 应用以使用 mTLS 连接到 Sentinel：

1. 在极狐GitLab 应用服务器上编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   redis['master_name'] = 'gitlab-redis'
   redis['master_password'] = 'redis-password-goes-here'

   # Configure Sentinels with mTLS
   gitlab_rails['redis_sentinels'] = [
     { 'host' => '10.0.0.1', 'port' => 26380 },
     { 'host' => '10.0.0.2', 'port' => 26380 },
     { 'host' => '10.0.0.3', 'port' => 26380 }
   ]

   # Enable TLS for Sentinel
   gitlab_rails['redis_sentinels_ssl'] = true

   # Provide CA certificate for validation
   gitlab_rails['redis_sentinels_tls_ca_cert_file'] = '/etc/gitlab/ssl/ca.crt'

   # Provide client certificate and key for mTLS
   gitlab_rails['redis_sentinels_tls_client_cert_file'] = '/etc/gitlab/ssl/redis-client.crt'
   gitlab_rails['redis_sentinels_tls_client_key_file'] = '/etc/gitlab/ssl/redis-client.key'
   ```

1. [重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

<a id="secure-sentinel-with-a-password"></a>

## 使用密码保护 Sentinel

除了 TLS 之外，您还可以为 Sentinel 添加密码认证。密码认证是可选的，但建议启用以提高安全性。

<a id="configure-sentinel-password"></a>

### 配置 Sentinel 密码

在 Sentinel 服务器上设置密码：

1. 在每个 Sentinel 服务器上编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   roles ['redis_sentinel_role']

   redis['master_name'] = 'gitlab-redis'
   redis['master_password'] = 'redis-password-goes-here'
   redis['master_ip'] = '10.0.0.1'
   redis['port'] = 6379

   # Set Sentinel password
   sentinel['password'] = 'sentinel-password-goes-here'

   # TLS configuration (if enabled)
   sentinel['bind'] = '10.0.0.1'
   sentinel['port'] = 26379
   sentinel['tls_port'] = 26380
   sentinel['tls_cert_file'] = '/etc/gitlab/ssl/sentinel-server.crt'
   sentinel['tls_key_file'] = '/etc/gitlab/ssl/sentinel-server.key'
   sentinel['tls_ca_cert_file'] = '/etc/gitlab/ssl/ca.crt'
   sentinel['tls_replication'] = 'yes'
   ```

1. [重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

配置极狐GitLab 应用以通过 Sentinel 进行认证：

1. 在极狐GitLab 应用服务器上编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   redis['master_name'] = 'gitlab-redis'
   redis['master_password'] = 'redis-password-goes-here'

   # Configure Sentinels with password authentication
   gitlab_rails['redis_sentinels'] = [
     { 'host' => '10.0.0.1', 'port' => 26380 },
     { 'host' => '10.0.0.2', 'port' => 26380 },
     { 'host' => '10.0.0.3', 'port' => 26380 }
   ]

   # Set Sentinel password
   gitlab_rails['redis_sentinels_password'] = 'sentinel-password-goes-here'

   # Enable TLS for Sentinel (if configured)
   gitlab_rails['redis_sentinels_ssl'] = true
   gitlab_rails['redis_sentinels_tls_ca_cert_file'] = '/etc/gitlab/ssl/ca.crt'
   ```

1. [重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。

<a id="verify-tls-configuration"></a>

## 验证 TLS 配置

配置 TLS 后，请验证连接是否正常工作：

1. 验证 Redis 是否在 TLS 端口（默认为 6380）上监听：

   ```shell
   sudo netstat -tlnp | grep redis
   ```

   您应该看到 Redis 同时监听标准端口（6379）和 TLS 端口（6380）。
1. 验证 Sentinel 是否在 TLS 端口（默认为 26380）上监听：

   ```shell
   sudo netstat -tlnp | grep sentinel
   ```

   您应该看到 Sentinel 同时监听标准端口（26379）和 TLS 端口（26380）。
1. 使用 `redis-cli` 测试到 Redis 的 TLS 连接：

   ```shell
   redis-cli --tls --cacert /etc/gitlab/ssl/ca.crt --cert /etc/gitlab/ssl/redis-client.crt --key /etc/gitlab/ssl/redis-client.key -h 10.0.0.1 -p 6380 ping
   ```

   对于标准 TLS（不使用客户端证书），请省略 `--cert` 和 `--key` 选项。
1. 监控日志中是否有任何与 TLS 相关的错误：

   ```shell
   sudo gitlab-ctl tail redis
   sudo gitlab-ctl tail sentinel
   sudo gitlab-ctl tail gitlab-rails
   sudo gitlab-ctl tail gitlab-workhorse
   ```

1. 在运行 GitLab Rails 的节点上，检查生成的配置文件以确保 TLS 设置已存在：

   ```shell
   cat /var/opt/gitlab/gitlab-rails/etc/resque.yml
   cat /var/opt/gitlab/gitlab-rails/etc/cable.yml
   ```

   您应该看到 `ssl: true` 和带有证书路径的 `ssl_params`。

<a id="tls-configuration-reference"></a>

## TLS 配置参考

Redis、Sentinel 和极狐GitLab 应用（Rails）设置参考。

<a id="redis-tls-settings"></a>

### Redis TLS 设置

| 设置                     | 描述 |
|:----------------------------|:------------|
| `redis['port']`             | 标准 Redis 端口（设置为 0 可禁用非 TLS 端口） |
| `redis['tls_port']`         | TLS 连接端口（默认值：6380） |
| `redis['tls_cert_file']`    | 服务器证书文件的路径 |
| `redis['tls_key_file']`     | 服务器私钥文件的路径 |
| `redis['tls_ca_cert_file']` | CA 证书文件的路径 |
| `redis['tls_replication']`  | 为复制启用 TLS（默认值：`no`） |
| `redis['tls_auth_clients']` | 要求客户端证书验证（默认值：`no`） |
| `redis['master_name']`      | Redis 主节点的名称（Sentinel 必需） |
| `redis['master_password']`  | Redis 主节点的密码（仅当 Redis 主节点启用了认证时，Sentinel 才需要） |
| `redis['master_port']`      | Redis 主节点的端口（如果为复制启用了 TLS，则必需） |

<a id="sentinel-tls-settings"></a>

### Sentinel TLS 设置

| 设置                        | 描述 |
|:-------------------------------|:------------|
| `sentinel['port']`             | 标准 Sentinel 端口（设置为 0 可禁用非 TLS 端口） |
| `sentinel['tls_port']`         | TLS 连接端口（默认值：26380） |
| `sentinel['tls_cert_file']`    | 服务器证书文件的路径 |
| `sentinel['tls_key_file']`     | 服务器私钥文件的路径 |
| `sentinel['tls_ca_cert_file']` | CA 证书文件的路径 |
| `sentinel['tls_replication']`  | 为复制启用 TLS（默认值：`no`） |
| `sentinel['tls_auth_clients']` | 要求客户端证书验证（默认值：`no`） |
| `sentinel['password']`         | Sentinel 认证的密码（可选） |

<a id="gitlab-rails-tls-settings"></a>

### GitLab Rails TLS 设置

| 设置                                                | 描述 |
|:-------------------------------------------------------|:------------|
| `gitlab_rails['redis_ssl']`                            | 为 Redis 连接启用 TLS（默认值：false） |
| `gitlab_rails['redis_sentinels_ssl']`                  | 为 Sentinel 连接启用 TLS（默认值：false） |
| `gitlab_rails['redis_tls_ca_cert_file']`               | 用于 Redis 验证的 CA 证书路径 |
| `gitlab_rails['redis_tls_client_cert_file']`           | 用于 Redis mTLS 的客户端证书路径 |
| `gitlab_rails['redis_tls_client_key_file']`            | 用于 Redis mTLS 的客户端私钥路径 |
| `gitlab_rails['redis_sentinels_password']`             | Sentinel 认证的密码（可选） |
| `gitlab_rails['redis_sentinels_tls_ca_cert_file']`     | 用于 Sentinel 验证的 CA 证书路径 |
| `gitlab_rails['redis_sentinels_tls_client_cert_file']` | 用于 Sentinel mTLS 的客户端证书路径 |
| `gitlab_rails['redis_sentinels_tls_client_key_file']`  | 用于 Sentinel mTLS 的客户端私钥路径 |
| `redis_exporter['enable']`                             | 为多节点 Redis 实例禁用 Redis exporter（设置为 false） |

<a id="troubleshooting"></a>

## 故障排除

您可能会看到以下错误：

```plaintext
x509: certificate relies on legacy Common Name field, use SANs instead
```

为避免此错误，在生成证书时，请确保它们包含**主题备用名称（SANs）**，而不是依赖旧版的 Common Name 字段。
