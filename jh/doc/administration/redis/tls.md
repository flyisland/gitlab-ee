---
stage: Tenant Scale
group: Tenant Services
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 通过 TLS 保护 Redis 和 Sentinel 安全
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- Redis TLS 支持在极狐GitLab 14.7 中引入。
- Sentinel TLS 支持在极狐GitLab 18.10 中引入。
- 双向 TLS 支持在极狐GitLab 18.10 中引入。

{{< /history >}}

使用 TLS（传输层安全性协议）保护 Redis 和 Sentinel 通信。支持标准 TLS（服务器证书验证）和双向 TLS（mTLS，客户端与服务器相互认证）。

如果你为 Redis 或 Sentinel 启用了 TLS，则应为部署中的 Redis 和 Sentinel 都启用。在同一环境中混合使用 TLS 和非 TLS 连接可能导致配置复杂和潜在的安全问题。

要禁用标准非 TLS 端口并仅接受 TLS 连接，请在配置中将端口设置为 0。例如：

- 添加 `redis['port'] = 0` 以禁用标准 Redis 端口 (6379)。
- 添加 `sentinel['port'] = 0` 以禁用标准 Sentinel 端口 (26379)。

<a id="generate-tls-certificate-and-key-files"></a>

## 生成 TLS 证书和密钥文件

在配置 TLS 之前，你必须生成或获取以下证书和密钥。全文使用以下示例文件名：

- **CA 证书** (`ca.crt`)：用于验证服务器证书的证书颁发机构证书。
- **服务器证书** (`redis-server.crt`)：Redis 服务器的证书（由 CA 签名）。
- **服务器密钥** (`redis-server.key`)：Redis 服务器证书的私钥。
- **Sentinel 服务器证书** (`sentinel-server.crt`)：Sentinel 服务器的证书（由 CA 签名）。
- **Sentinel 服务器密钥** (`sentinel-server.key`)：Sentinel 服务器证书的私钥。
- **客户端证书** (`redis-client.crt`，用于 mTLS)：客户端的证书（由 CA 签名）。
- **客户端密钥** (`redis-client.key`，用于 mTLS)：客户端证书的私钥。

这些示例使用 `/etc/gitlab/ssl/` 作为证书目录，但你可以将证书存储在任何目录，只要为需要读取它们的进程设置了适当的文件权限即可。

<a id="sample-certificate-generation-script"></a>

### 证书生成脚本示例

以下脚本生成一套完整的、具有适当 SAN 的 Redis 和 Sentinel 证书。运行前，你必须自定义 IP 地址和主机名以匹配你的实际基础设施。

> [!warning]
> CA 私钥 (`ca.key`) 是敏感的。生成证书后，请考虑将 CA 私钥安全地离线存储，并从生产服务器上移除。

1. 创建一个名为 `generate-redis-certs.sh` 的文件，内容如下：

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

1. 更新脚本中的以下变量以匹配你的基础设施：

   - `REDIS_HOSTNAMES`：所有 Redis 服务器主机名的逗号分隔列表。
   - `REDIS_IPS`：所有 Redis 服务器 IP 地址的逗号分隔列表。
   - `SENTINEL_HOSTNAMES`：所有 Sentinel 服务器主机名的逗号分隔列表。
   - `SENTINEL_IPS`：所有 Sentinel 服务器 IP 地址的逗号分隔列表。
   - `CERT_DAYS`：证书有效天数（默认：365）。

   证书必须包含客户端用于连接 Redis 或 Sentinel 的所有主机名和 IP 地址。例如，如果客户端连接到 `redis.example.com` 和 `10.0.0.1`，则它们都必须包含在 SAN 中。
1. 运行脚本：

   ```shell
   chmod +x generate-redis-certs.sh
   sudo ./generate-redis-certs.sh
   ```

<a id="set-certificate-and-key-file-permissions"></a>

### 设置证书和密钥文件权限

默认情况下，极狐GitLab 进程以不同用户身份运行：

- Redis 和 Sentinel 进程以 `gitlab-redis` 用户身份运行。
- Puma (极狐GitLab Rails)、Workhorse 和 KAS 进程以 `git` 用户身份运行。

将证书和密钥放置在 `/etc/gitlab/ssl/` 后，请确保有足够的文件权限，以便所有必需的进程都能读取它们。

<a id="when-running-separate-nodes"></a>

#### 当在不同节点上运行时

如果 Redis/Sentinel 在与极狐GitLab 应用不同的节点（不同的机器）上运行：

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

#### 当在共享节点上运行时

如果 Redis/Sentinel 和极狐GitLab 应用进程在同一节点上运行，你必须允许 `gitlab-redis` 和 `git` 用户都能读取证书。请使用共享组的方法。

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

1. 验证进程是否可以通过查看日志来读取文件：

   ```shell
   sudo gitlab-ctl tail
   ```

<a id="enable-standard-tls"></a>

## 启用标准 TLS

标准 TLS 意味着客户端验证服务器的证书。服务器不需要也不验证客户端证书。

> [!note]
> 以下示例中显示的证书文件路径（例如 `/etc/gitlab/ssl/redis-server.crt`）是占位符。请使用你的证书生成过程生成的实际文件名。如果你使用了上面的示例脚本，文件名将与这些示例匹配。

<a id="configure-redis-with-standard-tls"></a>

### 为标准 TLS 配置 Redis

为 Redis 主节点配置 TLS：

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

为 Redis 副本节点配置 TLS：

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

配置极狐GitLab 应用以通过 TLS 连接到 Redis：

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

### 为标准 TLS 配置 Sentinel

为 Sentinel 服务器配置 TLS：

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

配置极狐GitLab 应用以通过 TLS 连接到 Sentinel：

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

## 启用双向 TLS (mTLS)

双向 TLS 要求客户端和服务器使用证书相互认证。

<a id="configure-redis-with-mutual-tls"></a>

### 为双向 TLS 配置 Redis

为 Redis 主节点配置 mTLS：

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

为 Redis 副本节点配置 mTLS：

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

配置极狐GitLab 应用以通过 mTLS 连接到 Redis：

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

### 为双向 TLS 配置 Sentinel

为 Sentinel 服务器配置 mTLS：

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

配置极狐GitLab 应用以通过 mTLS 连接到 Sentinel：

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

除了 TLS，你还可以为 Sentinel 添加密码认证。密码认证是可选的，但建议用于增强安全性。

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

配置极狐GitLab 应用以向 Sentinel 进行认证：

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

配置 TLS 后，验证连接是否正常工作：

1. 验证 Redis 是否正在监听 TLS 端口（默认为 6380）：

   ```shell
   sudo netstat -tlnp | grep redis
   ```

   你应该会看到 Redis 同时监听标准端口 (6379) 和 TLS 端口 (6380)。
1. 验证 Sentinel 是否正在监听 TLS 端口（默认为 26380）：

   ```shell
   sudo netstat -tlnp | grep sentinel
   ```

   你应该会看到 Sentinel 同时监听标准端口 (26379) 和 TLS 端口 (26380)。
1. 使用 `redis-cli` 测试到 Redis 的 TLS 连接：

   ```shell
   redis-cli --tls --cacert /etc/gitlab/ssl/ca.crt --cert /etc/gitlab/ssl/redis-client.crt --key /etc/gitlab/ssl/redis-client.key -h 10.0.0.1 -p 6380 ping
   ```

   对于标准 TLS（无客户端证书），请省略 `--cert` 和 `--key` 选项。
1. 监控日志中是否有任何与 TLS 相关的错误：

   ```shell
   sudo gitlab-ctl tail redis
   sudo gitlab-ctl tail sentinel
   sudo gitlab-ctl tail gitlab-rails
   sudo gitlab-ctl tail gitlab-workhorse
   ```

1. 在运行极狐GitLab Rails 的节点上，检查生成的配置文件以确保 TLS 设置存在：

   ```shell
   cat /var/opt/gitlab/gitlab-rails/etc/resque.yml
   cat /var/opt/gitlab/gitlab-rails/etc/cable.yml
   ```

   你应该会看到 `ssl: true` 和带有证书路径的 `ssl_params`。

<a id="tls-configuration-reference"></a>

## TLS 配置参考

Redis、Sentinel 和极狐GitLab 应用 (Rails) 设置参考。

<a id="redis-tls-settings"></a>

### Redis TLS 设置

| 设置                         | 描述                                                     |
|:-----------------------------|:---------------------------------------------------------|
| `redis['port']`              | 标准 Redis 端口（设置为 0 以禁用非 TLS 端口）             |
| `redis['tls_port']`          | TLS 连接端口（默认：6380）                               |
| `redis['tls_cert_file']`     | 服务器证书文件路径                                       |
| `redis['tls_key_file']`      | 服务器私钥文件路径                                       |
| `redis['tls_ca_cert_file']`  | CA 证书文件路径                                          |
| `redis['tls_replication']`   | 为复制启用 TLS（默认：`no`）                             |
| `redis['tls_auth_clients']`  | 要求客户端证书验证（默认：`no`）                         |
| `redis['master_name']`       | Redis 主库名称（Sentinel 必需）                          |
| `redis['master_password']`   | Redis 主库密码（仅当 Redis 主库启用认证时，Sentinel 才需要） |
| `redis['master_port']`       | Redis 主库端口（如果为复制启用了 TLS，则为必需）         |

<a id="sentinel-tls-settings"></a>

### Sentinel TLS 设置

| 设置                            | 描述                                                     |
|:--------------------------------|:---------------------------------------------------------|
| `sentinel['port']`              | 标准 Sentinel 端口（设置为 0 以禁用非 TLS 端口）           |
| `sentinel['tls_port']`          | TLS 连接端口（默认：26380）                              |
| `sentinel['tls_cert_file']`     | 服务器证书文件路径                                       |
| `sentinel['tls_key_file']`      | 服务器私钥文件路径                                       |
| `sentinel['tls_ca_cert_file']`  | CA 证书文件路径                                          |
| `sentinel['tls_replication']`   | 为复制启用 TLS（默认：`no`）                             |
| `sentinel['tls_auth_clients']`  | 要求客户端证书验证（默认：`no`）                         |
| `sentinel['password']`          | Sentinel 认证密码（可选）                                |

<a id="gitlab-rails-tls-settings"></a>

### 极狐GitLab Rails TLS 设置

| 设置                                                    | 描述                                           |
|:--------------------------------------------------------|:-----------------------------------------------|
| `gitlab_rails['redis_ssl']`                             | 为 Redis 连接启用 TLS（默认：false）           |
| `gitlab_rails['redis_sentinels_ssl']`                   | 为 Sentinel 连接启用 TLS（默认：false）        |
| `gitlab_rails['redis_tls_ca_cert_file']`                | 用于 Redis 验证的 CA 证书路径                  |
| `gitlab_rails['redis_tls_client_cert_file']`            | 用于 Redis mTLS 的客户端证书路径               |
| `gitlab_rails['redis_tls_client_key_file']`             | 用于 Redis mTLS 的客户端私钥路径               |
| `gitlab_rails['redis_sentinels_password']`              | Sentinel 认证密码（可选）                      |
| `gitlab_rails['redis_sentinels_tls_ca_cert_file']`      | 用于 Sentinel 验证的 CA 证书路径               |
| `gitlab_rails['redis_sentinels_tls_client_cert_file']`  | 用于 Sentinel mTLS 的客户端证书路径            |
| `gitlab_rails['redis_sentinels_tls_client_key_file']`   | 用于 Sentinel mTLS 的客户端私钥路径            |
| `redis_exporter['enable']`                              | 为多节点 Redis 实例禁用 Redis 导出器（设置为 false） |

<a id="troubleshooting"></a>

## Troubleshooting

你可能会看到以下错误：


```plaintext
x509: 证书依赖于旧版通用名称字段，请改用 SANs
```

为了避免此错误，在生成证书时，请确保包含 **主题备用名称（SANs）**，而不是依赖于旧版通用名称字段。