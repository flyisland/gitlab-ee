---
stage: AI-powered
group: AI Framework
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Gateway between GitLab and large language models.
title: 安装极狐GitLab AI 网关
---

[AI 网关](../administration/gitlab_duo/gateway.md) 是两个服务的组合，提供对 AI 原生极狐GitLab Duo 功能的访问：

- AI 网关服务
- [极狐GitLab Duo Agent Platform 服务](../user/duo_agent_platform/_index.md)

## 使用 Docker 安装 {#install-by-using-docker}

极狐GitLab AI 网关 Docker 镜像包含单个容器中的所有必要代码和依赖项。

先决条件：

- 安装 Docker 容器引擎，例如 [Docker](https://docs.docker.com/engine/install/#server)。
- 使用网络中可访问的有效主机名。不要使用 `localhost`。
- 确保为 `linux/amd64` 架构提供大约 340 MB（压缩）的空间，以及至少 512 MB 的内存。
- 确保容器至少有两个 CPU 可供 `ai_gateway` 和 `duo-workflow-service` 服务使用。
- 生成 JWT 签名密钥：
  - 对于极狐GitLab Duo Agent Platform：

    ```shell
    openssl genrsa -out duo_workflow_jwt.key 2048
    openssl genrsa -out duo_workflow_validation.key 2048
    ```

  - 对于 AI 网关（Duo Chat 等功能需要）：

    ```shell
    openssl genrsa -out aigw_signing.key 2048
    openssl genrsa -out aigw_validation.key 2048
    ```

  > [!warning]
  > 请妥善保管所有生成的密钥文件，不要公开分享。这些密钥用于签名 JWT，必须视为敏感凭据。

为确保更好的性能，特别是在高负载下，请考虑分配比最低要求更多的磁盘空间、内存和资源。更高的 RAM 和磁盘容量可以在高峰负载期间提高 AI 网关的效率。

极狐GitLab AI 网关不需要 GPU。

### AI 网关镜像 {#ai-gateway-images}

#### 标准镜像 {#standard-images}

标准 AI 网关镜像可从[极狐GitLab AI 网关镜像资源](https://hub.gitlab.cn/model-gateway-self-hosted)获取。

如果您的极狐GitLab 版本是 `vX.Y.*-jh.0`，请使用带有最新 `self-hosted-vX.Y.*-jh` 标签的 AI 网关镜像。例如：

- 如果极狐GitLab 版本为 `v18.11.1-jh.0`，而 AI 网关镜像有 `self-hosted-v18.11.0-jh`、`self-hosted-v18.11.1-jh` 和 `self-hosted-v18.11.2-jh` 版本，请使用 `self-hosted-v18.11.2-jh`。
- 如果极狐GitLab 版本为 `v18.11.1-jh.0`，而 AI 网关镜像只有 `self-hosted-v18.11.0-jh` 版本，请使用 `self-hosted-v18.11.0-jh`。

有关更多信息，请参阅[自托管 AI 网关的发布流程](https://gitlab.com/gitlab-org/modelops/applied-ml/code-suggestions/ai-assist/-/blob/main/docs/delivery/release.md)。

> [!note]
> 夜间构建版本不保证向后兼容性。
> 请始终使用带有明确版本标签的稳定版本。

#### FIPS 验证镜像 {#fips-validated-images}

对于需要 FIPS 140-3 验证加密的环境，请使用 FIPS 验证的 AI 网关镜像。该镜像基于 Red Hat UBI 9 构建，并使用经过 CMVP 验证的 [Red Hat OpenSSL FIPS 提供程序](https://access.redhat.com/compliance/fips)。

FIPS 验证的 AI 网关镜像可在以下位置获取：

- 容器镜像仓库：[稳定版](https://gitlab.com/gitlab-org/modelops/applied-ml/code-suggestions/ai-assist/container_registry/9518478)
- DockerHub：[稳定版](https://hub.docker.com/r/gitlab/model-gateway-self-hosted-fips/tags)

FIPS 验证镜像使用 `self-hosted-vX.Y.Z-ee` 标签格式。

要启动 FIPS 验证的容器，请将 [Docker 运行命令](#start-a-container-from-the-image) 中的镜像引用替换为 FIPS 镜像：

```shell
registry.gitlab.com/gitlab-org/modelops/applied-ml/code-suggestions/ai-assist/model-gateway/self-hosted-fips:<ai-gateway-tag>
```

### 从镜像启动容器 {#start-a-container-from-the-image}

1. 运行以下命令启动容器：

   ```shell
   docker run -d -p 5052:5052 -p 50052:50052 \
    -e AIGW_GITLAB_URL=<your_gitlab_instance> \
    -e AIGW_GITLAB_API_URL=https://<your_gitlab_domain>/api/v4/ \
    -e AIGW_SELF_SIGNED_JWT__SIGNING_KEY="$(cat aigw_signing.key)" \
    -e AIGW_SELF_SIGNED_JWT__VALIDATION_KEY="$(cat aigw_validation.key)" \
    -e DUO_WORKFLOW_AUTH__ENABLED="true" \
    -e DUO_WORKFLOW_SELF_SIGNED_JWT__SIGNING_KEY="$(cat duo_workflow_jwt.key)" \
    -e DUO_WORKFLOW_SELF_SIGNED_JWT__VALIDATION_KEY="$(cat duo_workflow_validation.key)" \
    registry.gitlab.cn/model-gateway/model-gateway-self-hosted:<ai-gateway-tag>
   ```

   替换以下占位符：

   - `<your_gitlab_instance>`：您的极狐GitLab 实例 URL（例如 `https://gitlab.example.com`）。
   - `<your_gitlab_domain>`：您的域名（例如 `gitlab.example.com`）。
   - `<ai-gateway-tag>`：与您的极狐GitLab 实例匹配的版本。如果您的极狐GitLab 版本是 `vX.Y.0-jh.0`，请使用 `self-hosted-vX.Y.0-jh`。

   从容器主机访问 `http://localhost:5052` 应返回 `{"error":"No authorization header presented"}`。

1. 确保端口 `5052` 和 `50052` 从主机转发到容器。端口 `5052` 处理 AI 网关的 HTTP 通信。端口 `50052` 处理极狐GitLab Duo Agent Platform 服务的 gRPC 通信。
1. 对于使用离线许可证的极狐GitLab 实例，在 AIGW 容器中设置 `-e DUO_WORKFLOW_AUTH__OIDC_CUSTOMER_PORTAL_URL=`（空字符串）。此配置：
   - 强制极狐GitLab Duo Workflow Service 仅针对本地极狐GitLab 实例进行身份验证。
   - 消除因无法访问 CustomersDot 调用而导致的 20 秒延迟。
1. 配置 [AI 网关 URL](../administration/gitlab_duo_self_hosted/configure_duo_features.md#configure-access-to-the-local-ai-gateway) 和 [极狐GitLab Duo Agent Platform 服务 URL](../administration/gitlab_duo_self_hosted/configure_duo_features.md#configure-access-to-the-gitlab-duo-agent-platform)。
1. 可选。如果您的本地极狐GitLab Duo Agent Platform 端点使用 TLS：
   1. 在右上角，选择 **Admin**。
   1. 选择 **GitLab Duo** > **Change configuration**。
   1. 选中 **Use TLS for the GitLab Duo Agent Platform service** 复选框。

### 限制网络访问 {#restrict-network-access}

为了加强系统安全，请进行以下网络配置：

- 限制 AI 网关容器的出站网络访问。
- 阻止容器的所有其他出站流量。

AI 网关需要对以下地址的出站访问。请确保将这些地址作为网络限制的例外：

- 您的极狐GitLab 实例 (`AIGW_GITLAB_URL`)。
- 您配置的 AI 模型提供商端点（例如 Anthropic、Google Vertex AI 或 Azure OpenAI）。
- `customers.gitlab.com` 用于许可证验证，除非您使用离线许可证。

> [!warning]
> 在应用防火墙规则之前，先在非生产环境中进行测试。
> 过于严格的规则可能会破坏 AI 网关功能。

要在 Linux 主机上限制出站访问，请在 `DOCKER-USER` 链中使用 `iptables` 规则。有关更多信息，请参阅 [Docker 数据包过滤和防火墙](https://docs.docker.com/engine/network/packet-filtering-firewalls/)。

## 使用 NGINX 和 SSL 设置 Docker {#set-up-docker-with-nginx-and-ssl}

> [!note]
> 这种将 NGINX 或 Caddy 部署为反向代理的方法是一种临时解决方案，用于支持 SSL，直到 [issue 455854](https://gitlab.com/gitlab-org/gitlab/-/issues/455854) 实现。

要为 AI 网关实例使用 SSL，请使用：

- Docker
- NGINX 作为反向代理
- Let's Encrypt 获取 SSL 证书

NGINX 管理与外部客户端的安全连接。它在将传入的 HTTPS 请求传递给 AI 网关之前对其进行解密。

先决条件：

- 已安装 Docker 和 Docker Compose
- 已注册并配置的域名

### 创建配置文件 {#create-configuration-files}

首先在工作目录中创建以下文件。

1. `nginx.conf`：

   ```nginx
   user  nginx;
   worker_processes  auto;
   error_log  /var/log/nginx/error.log warn;
   pid        /var/run/nginx.pid;
   events {
       worker_connections  1024;
   }
   http {
       include       /etc/nginx/mime.types;
       default_type  application/octet-stream;
       log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                         '$status $body_bytes_sent "$http_referer" '
                         '"$http_user_agent" "$http_x_forwarded_for"';
       access_log  /var/log/nginx/access.log  main;
       sendfile        on;
       keepalive_timeout  65;
       include /etc/nginx/conf.d/*.conf;
   }
   ```

1. `default.conf`：

   ```nginx
   # nginx/conf.d/default.conf
   server {
       listen 80;
       server_name _;

       # Forward all requests to the AI Gateway
       location / {
           proxy_pass http://gitlab-ai-gateway:5052;
           proxy_read_timeout 300s;
           proxy_connect_timeout 75s;
           proxy_buffering off;
       }
   }

   server {
       listen 443 ssl;
       server_name _;

       # SSL configuration
       ssl_certificate /etc/nginx/ssl/server.crt;
       ssl_certificate_key /etc/nginx/ssl/server.key;

       # Configuration for self-signed certificates
       ssl_verify_client off;
       ssl_protocols TLSv1.2 TLSv1.3;
       ssl_ciphers HIGH:!aNULL:!MD5;
       ssl_prefer_server_ciphers on;
       ssl_session_cache shared:SSL:10m;
       ssl_session_timeout 10m;

       # Proxy headers
       proxy_set_header Host $host;
       proxy_set_header X-Real-IP $remote_addr;
       proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
       proxy_set_header X-Forwarded-Proto $scheme;

       # WebSocket support (if needed)
       proxy_http_version 1.1;
       proxy_set_header Upgrade $http_upgrade;
       proxy_set_header Connection "upgrade";

       # Forward all requests to the AI Gateway
       location / {
           proxy_pass http://gitlab-ai-gateway:5052;
           proxy_read_timeout 300s;
           proxy_connect_timeout 75s;
           proxy_buffering off;
       }
   }
   ```

1. `grpc-nginx.conf`：

```nginx
# Configuration for Duo Agent Platform with TLS
events {
    worker_connections 1024;
}

http {
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';

    access_log /var/log/nginx/access.log main;
    error_log /var/log/nginx/error.log debug;

    upstream grpcservers {
        server gitlab-ai-gateway:50052;
    }

    server {
        listen 8443 ssl;
        http2 on;

        ssl_certificate /etc/nginx/ssl/server.crt;
        ssl_certificate_key /etc/nginx/ssl/server.key;

        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers HIGH:!aNULL:!MD5;
        ssl_prefer_server_ciphers on;

        location / {
            grpc_pass grpc://grpcservers;
            grpc_set_header Host $host;
        }
    }
}
```

### 使用 Let's Encrypt 设置 SSL 证书 {#set-up-ssl-certificate-by-using-lets-encrypt}

要设置 SSL 证书：

- 对于基于 Docker 的 NGINX 服务器，Certbot [提供了一种自动实现 Let's Encrypt 证书的方法](https://phoenixnap.com/kb/letsencrypt-docker)。
- 或者，您可以使用 [Certbot 手动安装](https://eff-certbot.readthedocs.io/en/stable/using.html#manual)。

### 创建环境文件 {#create-an-environment-file}

创建一个 `.env` 文件来存储 JWT 签名和验证密钥：

```shell
echo "AIGW_SELF_SIGNED_JWT__SIGNING_KEY=\"$(cat aigw_signing.key)\"" > .env
echo "AIGW_SELF_SIGNED_JWT__VALIDATION_KEY=\"$(cat aigw_validation.key)\"" >> .env
echo "DUO_WORKFLOW_SELF_SIGNED_JWT__SIGNING_KEY=\"$(cat duo_workflow_jwt.key)\"" >> .env
echo "DUO_WORKFLOW_SELF_SIGNED_JWT__VALIDATION_KEY=\"$(cat duo_workflow_validation.key)\"" >> .env
```

### 创建 Docker Compose 文件 {#create-a-docker-compose-file}

现在创建一个 `docker-compose.yaml` 文件。

```yaml
services:
  nginx-proxy:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - /path/to/nginx.conf:/etc/nginx/nginx.conf:ro
      - /path/to/default.conf:/etc/nginx/conf.d/default.conf:ro
      - /path/to/fullchain.pem:/etc/nginx/ssl/server.crt:ro
      - /path/to/privkey.pem:/etc/nginx/ssl/server.key:ro
    networks:
      - proxy-network
    depends_on:
      - gitlab-ai-gateway

grpc-proxy:
    image: nginx:alpine
    ports:
      - "8443:8443"
    volumes:
      - /path/to/grpc-nginx.conf:/etc/nginx/nginx.conf:ro
      - /path/to/fullchain.pem:/etc/nginx/ssl/server.crt:ro
      - /path/to/privkey.pem:/etc/nginx/ssl/server.key:ro
    networks:
      - proxy-network
    depends_on:
      - gitlab-ai-gateway
    restart: always

  gitlab-ai-gateway:
    image: registry.gitlab.cn/model-gateway/model-gateway-self-hosted:<ai-gateway-tag>
    ports:
      - "50052:50052" # Agent Platform gRPC exposed to the host
    expose:
      - "5052" # Only exposed internally to the proxy network
    environment:
      - AIGW_GITLAB_URL=<your_gitlab_instance>
      - AIGW_GITLAB_API_URL=https://<your_gitlab_domain>/api/v4/
    env_file:
      - .env
    networks:
      - proxy-network
    restart: always

networks:
  proxy-network:
    driver: bridge
```

### 部署和验证 {#deploy-and-validate}

要部署和验证解决方案：

1. 启动 `nginx` 和 `AIGW` 容器，并验证它们正在运行：

   ```shell
   docker compose up
   docker ps
   ```

1. 配置您的[极狐GitLab 实例以访问 AI 网关](../administration/gitlab_duo_self_hosted/configure_duo_features.md#configure-access-to-the-local-ai-gateway)。
1. 配置您的极狐GitLab 实例以访问 [极狐GitLab Duo Agent Platform 服务](../administration/gitlab_duo_self_hosted/configure_duo_features.md#configure-access-to-the-gitlab-duo-agent-platform) 的 URL。
1. 执行健康检查，确认 AI 网关和 Agent Platform 均可访问。

## 使用 Helm chart 安装 {#install-by-using-helm-chart}

先决条件：

- 您必须具备：
  - 您拥有的域名，可以向其中添加 DNS 记录。
  - Kubernetes 集群。
  - `kubectl` 的正常安装。
  - Helm 的正常安装，版本 v3.11.0 或更高版本。

有关更多信息，请参阅[在 GKE 或 EKS 上测试极狐GitLab chart](https://gitlab.cn/docs/charts/quickstart/)。

### 添加 AI 网关 Helm 仓库 {#add-the-ai-gateway-helm-repository}

将 AI 网关 Helm 仓库添加到 Helm 配置中：

```shell
helm repo add ai-gateway \
https://gitlab.com/api/v4/projects/gitlab-org%2fcharts%2fai-gateway-helm-chart/packages/helm/devel
```

### 安装 AI 网关 {#install-the-ai-gateway}

1. 创建 `ai-gateway` 命名空间：

   ```shell
   kubectl create namespace ai-gateway
   ```

1. 为您计划公开 AI 网关的域名生成证书。
1. 在之前创建的命名空间中创建 TLS secret：

   ```shell
   kubectl -n ai-gateway create secret tls ai-gateway-tls --cert="<path_to_cert>" --key="<path_to_cert_key>"
   ```

1. 在 [chart 的 Package Registry](https://gitlab.com/gitlab-org/charts/ai-gateway-helm-chart/-/packages) 中获取最新包的版本号。
1. 为了让 AI 网关访问 API，它必须知道极狐GitLab 实例的位置。为此，请按如下方式设置 `gitlab.url` 和 `gitlab.apiUrl` 以及 `ingress.hosts` 和 `ingress.tls` 值：

   ```shell
   helm repo add ai-gateway \
     https://gitlab.com/api/v4/projects/gitlab-org%2fcharts%2fai-gateway-helm-chart/packages/helm/devel
   helm repo update

   helm upgrade --install ai-gateway \
     ai-gateway/ai-gateway \
     --version <latest-package-in-registery> \
     --namespace=ai-gateway \
     --set="image.tag=<ai-gateway-image-version>" \
     --set="gitlab.url=https://<your_gitlab_domain>" \
     --set="gitlab.apiUrl=https://<your_gitlab_domain>/api/v4/" \
     --set "ingress.enabled=true" \
     --set "ingress.hosts[0].host=<your_gateway_domain>" \
     --set "ingress.hosts[0].paths[0].path=/" \
     --set "ingress.hosts[0].paths[0].pathType=ImplementationSpecific" \
     --set "ingress.tls[0].secretName=ai-gateway-tls" \
     --set "ingress.tls[0].hosts[0]=<your_gateway_domain>" \
     --set="ingress.className=nginx" \
     --set "extraEnvironmentVariables[0].name=AIGW_SELF_SIGNED_JWT__SIGNING_KEY" \
     --set "extraEnvironmentVariables[0].value=$(cat aigw_signing.key)" \
     --set "extraEnvironmentVariables[1].name=AIGW_SELF_SIGNED_JWT__VALIDATION_KEY" \
     --set "extraEnvironmentVariables[1].value=$(cat aigw_validation.key)" \
     --set "extraEnvironmentVariables[2].name=DUO_WORKFLOW_SELF_SIGNED_JWT__SIGNING_KEY" \
     --set "extraEnvironmentVariables[2].value=$(cat duo_workflow_jwt.key)" \
     --set "extraEnvironmentVariables[3].name=DUO_WORKFLOW_SELF_SIGNED_JWT__VALIDATION_KEY" \
     --set "extraEnvironmentVariables[3].value=$(cat duo_workflow_validation.key)" \
     --set "extraEnvironmentVariables[4].name=DUO_WORKFLOW_AUTH__ENABLED" \
     --set "extraEnvironmentVariables[4].value={{ true | quote }}" \
     --timeout=300s --wait --wait-for-jobs
   ```

您可以在[容器镜像仓库](https://gitlab.com/gitlab-org/modelops/applied-ml/code-suggestions/ai-assist/container_registry/3809284?orderBy=PUBLISHED_AT&search%5B%5D=self-hosted)中找到可用作 `image.tag` 的 AI 网关版本列表。

此步骤可能需要几秒钟，以便分配所有资源并启动 AI 网关。

如果您现有的 `nginx` Ingress 控制器不为不同命名空间中的服务提供服务，您可能需要为 AI 网关设置自己的 **Ingress Controller**。确保为多命名空间部署正确设置了 Ingress。

对于 `ai-gateway` Helm chart 的版本，请使用 `helm search repo ai-gateway --versions` 查找合适的 chart 版本。

等待您的 pod 启动并运行：

```shell
kubectl wait pod \
  --all \
  --for=condition=Ready \
  --namespace=ai-gateway \
  --timeout=300s
```

当您的 pod 启动并运行后，您可以设置 IP 入口和 DNS 记录。

## 使用自签名 SSL 证书连接到极狐GitLab 实例或模型端点 {#connect-to-a-gitlab-instance-or-model-endpoint-with-a-self-signed-ssl-certificate}

如果您的极狐GitLab 实例或模型端点配置了自签名证书，则必须将您的根证书颁发机构 (CA) 证书添加到 AI 网关的证书包中。

为此，您可以：

- 将根 CA 证书传递给 AI 网关，以便身份验证成功。
- 将根 CA 证书添加到 AI 网关容器的 CA 包中。

### 将根 CA 证书传递给 AI 网关 {#pass-the-root-ca-certificate-to-the-ai-gateway}

要将根 CA 证书传递给 AI 网关并确保身份验证成功，请设置 `REQUESTS_CA_BUNDLE` 环境变量。由于极狐GitLab 使用 [Certifi](https://pypi.org/project/certifi/) 作为基础受信任 CA 列表，您可以按如下方式配置自定义 CA 包：

1. 下载 Certifi `cacert.pem` 文件：

   ```shell
   curl "https://raw.githubusercontent.com/certifi/python-certifi/2024.07.04/certifi/cacert.pem" --output cacert.pem
   ```

1. 将您的自签名根 CA 证书附加到该文件。例如，如果您使用 `mkcert` 创建证书：

   ```shell
   cat "$(mkcert -CAROOT)/rootCA.pem" >> path/to/your/cacert.pem
   ```

1. 将 `REQUESTS_CA_BUNDLE` 设置为 `cacert.pem` 文件的路径。例如，在 GDK 中，将以下内容添加到 `$GDK_ROOT/env.runit`：

   ```shell
   export REQUESTS_CA_BUNDLE=/path/to/your/cacert.pem
   ```

### 将根 CA 证书添加到 AI 网关容器的 CA 包中 {#add-the-root-ca-certificate-to-the-ai-gateway-containers-ca-bundle}

要允许 AI 网关信任由自定义 CA 签名的极狐GitLab 自管理实例的证书，请将根 CA 证书添加到 AI 网关容器的 CA 包中。

此方法不允许在 chart 的后续版本中对根 CA 包进行更改。

要对 AI 网关的 Helm chart 部署执行此操作：

1. 将自定义根 CA 证书附加到本地文件：

   ```shell
   cat customCA-root.crt >> ca-certificates.crt
   ```

1. 将 `/etc/ssl/certs/ca-certificates.crt` 包文件从 AI 网关容器复制到本地文件：

   ```shell
   kubectl cp -n gitlab ai-gateway-55d697ff9d-j9pc6:/etc/ssl/certs/ca-certificates.crt ca-certificates.crt.
   ```

1. 从本地文件创建新的 secret：

   ```shell
   kubectl create secret generic ca-certificates -n gitlab --from-file=cacertificates.crt=ca-certificates.crt
   ```

1. 在 chart 的 `values.yml` 中使用该 secret 定义 `volume` 和 `volumeMount`。这将在容器中创建 `/tmp/ca-certificates.crt` 文件：

   ```shell
   volumes:
     - name: cacerts
       secret:
         secretName: ca-certificates
         optional: false

   volumeMounts:
     - name: cacerts
       mountPath: "/tmp"
       readOnly: true
   ```

1. 设置 `REQUESTS_CA_BUNDLE` 和 `SSL_CERT_FILE` 环境变量以指向挂载的文件：

   ```shell
   extraEnvironmentVariables:
     - name: REQUESTS_CA_BUNDLE
       value: /tmp/ca-certificates.crt
     - name: SSL_CERT_FILE
       value: /tmp/ca-certificates.crt
   ```

1. 重新部署 chart。

[Issue 3](https://gitlab.com/gitlab-org/charts/ai-gateway-helm-chart/-/issues/3) 用于在 Helm chart 中原生支持此功能。

#### 对于 Docker 部署 {#for-a-docker-deployment}

对于 Docker 部署，使用相同的方法。唯一的区别是，要在容器中挂载本地文件，请使用 `--volume /root/ca-certificates.crt:/tmp/ca-certificates.crt`。

## 升级 AI 网关 Docker 镜像 {#upgrade-the-ai-gateway-docker-image}

要升级 AI 网关，请下载最新的 Docker 镜像标签。

1. 停止正在运行的容器：

   ```shell
   sudo docker stop gitlab-aigw
   ```

1. 删除现有容器：

   ```shell
   sudo docker rm gitlab-aigw
   ```

1. 拉取并[运行新镜像](#start-a-container-from-the-image)。
1. 确保所有环境变量都设置正确。

## 安全更新和镜像验证 {#security-updates-and-image-verification}

为确保您运行的是最新的安全补丁，请根据您的部署方法遵循以下指南。

### 对于 Kubernetes 或 Helm 部署 {#for-kubernetes-or-helm-deployments}

0.7.0 之前的 [charts 版本](https://gitlab.com/gitlab-org/charts/ai-gateway-helm-chart/-/packages) 和 Kubernetes 默认使用 `imagePullPolicy: IfNotPresent`，如果标签未更改，则不会拉取更新的镜像。这意味着您可能会错过在同一版本标签下发布的安全补丁。

您应该使用以下使用镜像摘要的方法：

```shell
# Find the image digest from the container registry
# Use this digest in your Helm install/upgrade command

helm upgrade --install ai-gateway \
  ai-gateway/ai-gateway \
  --set="image.tag=self-hosted-v18.2.1-ee@sha256:abc123..." \
  # ... other flags
```

或者，您可以使用以下任一方法设置 `imagePullPolicy`：

- 将 `imagePullPolicy` 设置为 always：

  ```shell
  helm upgrade --install ai-gateway \
    ai-gateway/ai-gateway \
    --set="image.pullPolicy=Always" \
    # ... other flags
  ```

- 将 `pullPolicy` 添加到 `values.yaml`：

  ```yaml
  image:
    pullPolicy: Always
  ```

要强制拉取更新：

```shell
kubectl rollout restart deployment/ai-gateway -n ai-gateway
```

### 对于 Docker 部署 {
如果问题持续存在，错误消息可能会建议使用 `AIGW_AUTH__BYPASS_EXTERNAL=true` 绕过身份验证，但仅在故障排除时这样做。

你也可以通过访问 **管理员** > **极狐GitLab Duo** 来运行 [健康检查](../administration/gitlab_duo/configure/_index.md#run-a-health-check-for-gitlab-duo)。

以下测试适用于离线环境：

| 测试 | 描述 |
|-----------------|-------------|
| 网络 | 检测以下内容：<br>- AI Gateway URL 是否已通过 `ai_settings` 表在数据库中正确配置。<br> - 您的实例是否可以连接到配置的 URL。<br><br>如果您的实例无法连接到该 URL，请确保您的防火墙或代理服务器设置 [允许连接](../administration/gitlab_duo/configure/gitlab_self_managed.md)。虽然环境变量 `AI_GATEWAY_URL` 仍然受支持以兼容旧版，但建议通过数据库配置 URL 以获得更好的可管理性。 |
| 许可证 | 检测您的许可证是否具有访问 代码建议 功能的权限。 |
| 系统交换 | 检测 代码建议 是否可以在您的实例中使用。如果系统交换评估失败，用户可能无法使用极狐GitLab Duo 功能。 |

## 监控 AI Gateway

使用 Prometheus 收集有关 AI Gateway 使用情况和性能的指标。

### 为 AI Gateway 设置 Prometheus 指标

设置 Prometheus 指标的方法如下：

1. 设置所需的环境变量并打开端口 `8082`：

   ```shell
   -e AIGW_FASTAPI__METRICS_HOST=0.0.0.0
   -e AIGW_FASTAPI__METRICS_PORT=8082
   ```

### 为极狐GitLab Duo Workflow 服务设置 Prometheus

在极狐GitLab Duo Workflow 服务上设置 Prometheus 指标的方法如下：

1. 设置所需的环境变量并打开端口 `8083`：

   ```shell
   -e PROMETHEUS_METRICS__ADDR=0.0.0.0
   -e PROMETHEUS_METRICS__PORT=8083
   ```

1. 将 `gitlab-ai-gateway` 容器的指标端口暴露给主机：

   - 对于 Docker CLI：

     ```shell
     -p 8082:8082 \
     -p 8083:8083 \
     ```

   - 对于 Docker Compose，添加到 `gitlab-ai-gateway` 服务：

     ```shell
     ports:
       - "8082:8082"
       - "8083:8083"
     ```

   这将在端口 `8082` 上暴露 AI Gateway 指标端点，并在端口 `8083` 上暴露极狐GitLab Duo Workflow 服务指标端点。

1. 重启 AI Gateway 容器

### 配置 Prometheus 以拉取指标

要从 AI Gateway 和极狐GitLab Duo Workflow 服务收集指标，请将以下 `prometheus.yml` 配置添加到您的 Prometheus 实例中。在此配置中，Prometheus 每 15 秒从这两个服务拉取一次指标。

```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'ai-gateway'
    static_configs:
      - targets: ['<your_AIGW_domain>:8082']
    scheme: 'http'
    metrics_path: '/metrics'

  - job_name: 'duo-agent-platform-service'
    static_configs:
      - targets: ['<your_duo_agent_platform_service_domain>:8083']
    scheme: 'http'
    metrics_path: '/metrics'
```

### 验证指标收集

要验证 AI Gateway 和极狐GitLab Duo Workflow 服务的目标是否被收集：

1. 在 Prometheus UI 中，转到 **状态 > 目标**。
1. 转到 **告警** 或 **图表** 选项卡以查询指标。AI Gateway 和极狐GitLab Duo Workflow 服务在以下端点暴露指标：

   - AI Gateway：`http://<your_AIGW_domain>:8082/metrics`
   - 极狐GitLab Duo Workflow 服务：`http://<your_duo_agent_platform_service_domain>:8083/metrics`

## AI Gateway 是否需要自动伸缩？

自动伸缩不是强制性的，但对于具有可变工作负载、高并发需求或不可预测使用模式的环境建议使用。在极狐GitLab 生产环境中：

- 基线设置：单个 AI Gateway 实例配备 2 个 CPU 核心和 8 GB RAM，可以处理大约 40 个并发请求。
- 伸缩指南：对于较大设置，例如 AWS t3.2xlarge 实例（8 vCPUs, 32 GB RAM），网关最多可处理 160 个并发请求，相当于基线设置的 4 倍。
- 请求吞吐量：JihuLab.com 的观察使用情况表明，每 1000 个活跃用户 7 RPS（每秒请求数）是一个合理的规划指标。
- 自动伸缩选项：使用 Kubernetes Horizontal Pod Autoscalers (HPA) 或类似机制，根据 CPU、内存利用率或请求延迟阈值等指标动态调整实例数量。

## 按部署规模划分的配置示例

- 小型部署：
  - 配备 2 个 vCPUs 和 8 GB RAM 的单个实例。
  - 最多处理 40 个并发请求。
  - 适用于最多 50 名用户且工作负载可预测的团队或组织。
  - 固定实例可能足够；可以禁用自动伸缩以节省成本。
- 中型部署：
  - 单个 AWS t3.2xlarge 实例，配备 8 个 vCPUs 和 32 GB RAM。
  - 最多处理 160 个并发请求。
  - 适用于 50-200 名用户且并发需求适中的组织。
  - 实施 Kubernetes HPA，设置 CPU 利用率 50% 或请求延迟超过 500 毫秒的阈值。
- 大型部署：
  - 多个 AWS t3.2xlarge 实例或同等配置的集群。
  - 每个实例处理 160 个并发请求，通过多个实例可扩展至数千名用户。
  - 适用于超过 200 名用户且具有可变、高并发工作负载的企业。
  - 使用 HPA 根据实时需求伸缩 Pod，并结合节点自动伸缩进行集群范围的资源调整。

## AI Gateway 容器可以访问哪些规格？资源分配如何影响性能？

AI Gateway 在以下资源分配下运行有效：

- 每个容器 2 个 CPU 核心和 8 GB RAM。
- 在极狐GitLab 生产环境中，容器通常使用约 7.39% 的 CPU 和相应比例的内存，为增长或处理突发活动留有余地。

## 资源争用的缓解策略

- 使用 Kubernetes 资源请求和限制，确保 AI Gateway 容器获得保证的 CPU 和内存分配。例如：

  ```yaml
  resources:
    requests:
      memory: "16Gi"
      cpu: "4"
    limits:
      memory: "32Gi"
      cpu: "8"
  ```

- 实施 Prometheus 和 Grafana 等工具来跟踪资源利用率（CPU、内存、延迟）并及早发现瓶颈。
- 将节点或实例专用于 AI Gateway，防止与其他服务竞争资源。

## 伸缩策略

- 使用 Kubernetes HPA 根据实时指标（如：）
  - CPU 平均利用率超过 50%。
  - 请求延迟持续超过 500 毫秒。
  - 启用节点自动伸缩，随着 Pod 的增加动态伸缩基础设施资源。

## 伸缩建议

| 部署规模 | 实例类型 | 资源 | 容量（并发请求） | 伸缩建议 |
|------------------|--------------------|------------------------|---------------------------------|---------------------------------------------|
| 小型 | 2 vCPUs, 8 GB RAM | 单个实例 | 40 | 固定部署；无自动伸缩。 |
| 中型 | AWS t3.2xlarge | 单个实例 | 160 | 基于 CPU 或延迟阈值的 HPA。 |
| 大型 | 多个 t3.2xlarge | 集群实例 | 每个实例 160 | HPA + 节点自动伸缩以应对高需求。 |

## 支持多个极狐GitLab 实例

您可以部署单个 AI Gateway 来支持多个极狐GitLab 实例，或者为每个实例或地理区域部署单独的 AI Gateway。为帮助决定哪种方式合适，请考虑：

- 预期的流量：每 1,000 个计费用户大约每秒 7 个请求。
- 基于所有实例的总并发请求的资源需求。
- 每个极狐GitLab 实例的最佳实践身份验证配置。

## 将 AI Gateway 与实例共址部署

AI Gateway 在全球多个区域可用，以确保用户无论身在何处都能获得最佳性能，具体通过以下方式实现：

- 改善极狐GitLab Duo 功能的响应时间。
- 降低地理位置分散用户的延迟。
- 符合数据驻留要求。

您应该将 AI Gateway 与您的极狐GitLab 实例部署在同一地理区域，以提供顺畅的开发者体验，特别是对于 代码建议 等延迟敏感的功能。

## 故障排除

在使用 AI Gateway 时，您可能会遇到以下问题。

### OpenShift 权限问题

在 OpenShift 上部署 AI Gateway 时，可能会因为 OpenShift 安全模型而遇到权限错误。

#### `/tmp` 处的只读文件系统

AI Gateway 需要写入 `/tmp`。然而，基于安全受限的 OpenShift 环境，`/tmp` 可能是只读的。

要解决此问题，请创建一个新的 `EmptyDir` 卷并将其挂载到 `/tmp`。您可以选择以下任一方式：

- 通过命令行：

  ```shell
  oc set volume <object_type>/<name> --add --name=tmpVol --type=emptyDir --mountPoint=/tmp
  ```

- 添加到您的 `values.yaml` 中：

  ```yaml
  volumes:
  - name: tmp-volume
    emptyDir: {}

  volumeMounts:
  - name: tmp-volume
    mountPath: "/tmp"
  ```

#### HuggingFace 模型

默认情况下，AI Gateway 使用 `/home/aigateway/.hf` 缓存 HuggingFace 模型，但在 OpenShift 安全受限的环境中可能无法写入。这可能会导致如下权限错误：

```shell
[Errno 13] Permission denied: '/home/aigateway/.hf/...'
```

要解决此问题，请将 `HF_HOME` 环境变量设置为可写位置。您可以使用 `/var/tmp/huggingface` 或任何容器可写的其他目录。

您可以通过以下任一方式进行配置：

- 添加到 `values.yaml`：

  ```yaml
  extraEnvironmentVariables:
    - name: HF_HOME
      value: /var/tmp/huggingface  # 或任何可写目录
  ```

- 或包含在您的 Helm upgrade 命令中：

  ```shell
  --set "extraEnvironmentVariables[0].name=HF_HOME" \
  --set "extraEnvironmentVariables[0].value=/var/tmp/huggingface"  # 或任何可写目录
  ```

此配置确保 AI Gateway 可以在遵守 OpenShift 安全约束的同时正确缓存 HuggingFace 模型。您选择的具体目录可能取决于您特定的 OpenShift 配置和安全策略。

### Tokenizer 缓存被卷挂载覆盖

AI Gateway 镜像中的预缓存分词器文件可能会被卷挂载覆盖，如果：

- 代码补全请求返回 `500` 错误。
- AI Gateway 日志显示 `transformers/utils/hub.py` 中出现 `OSError`，尝试从 `huggingface.co` 下载 `Salesforce/codegen2-16B`。

私有化部署的 AI Gateway 镜像（`self-hosted-vX.Y.Z-ee`）设置了 `HF_HUB_OFFLINE=true` 并在构建时预缓存了分词器，因此运行时不应发生对 `huggingface.co` 的网络访问。如果发生了网络访问，则可能是 Helm 值中的一个空目录被挂载到了 `/home/aigateway/.hf`，覆盖了缓存文件。

不要试图通过授予对 `huggingface.co` 的出站访问来解决此问题。相反，要诊断问题，请在 AI Gateway Pod 中运行以下命令：

```shell
ls -la /home/aigateway/.hf/hub/ 2>/dev/null || echo "NO_CACHE_DIR"
env | grep -E '^(HF_|TRANSFORMERS_)'
```

如果缓存目录缺失或为空，请执行以下操作：

1. 检查您的 `values.yaml` 中是否有任何 `volumeMounts` 以 `/home/aigateway/.hf` 或由 `HF_HOME` 设置的路径为目标。
1. 移除挂载或将其重新映射到与镜像内置缓存不重叠的目录。

### 自签名证书错误

当 AI Gateway 尝试使用由自定义证书颁发机构 (CA) 签署的证书或自签名证书连接到极狐GitLab 实例或模型端点时，AI Gateway 会记录 `[SSL: CERTIFICATE_VERIFY_FAILED] 证书验证失败：证书链中的自签名证书` 错误。

要解决此问题，请参阅 [使用自签名 SSL 证书连接到极狐GitLab 实例或模型端点](#connect-to-a-gitlab-instance-or-model-endpoint-with-a-self-signed-ssl-certificate)。

### Token 创建失败

如果在使用 Duo Chat 等功能时遇到 `Token 创建失败` 错误，则 AI Gateway 上可能未设置 `AIGW_SELF_SIGNED_JWT__SIGNING_KEY` 和 `AIGW_SELF_SIGNED_JWT__VALIDATION_KEY` 环境变量。

AI Gateway 需要这些密钥来签发短期用户 JWT。如果没有这些密钥，AI Gateway 无法签名令牌，从而导致 JWK 反序列化失败。

要解决此问题：

1. 生成所需的密钥：

   ```shell
   openssl genrsa -out aigw_signing.key 2048
   openssl genrsa -out aigw_validation.key 2048
   ```

1. 通过将它们作为环境变量传递，将密钥添加到 AI Gateway 容器：

   ```shell
   -e AIGW_SELF_SIGNED_JWT__SIGNING_KEY="$(cat aigw_signing.key)" \
   -e AIGW_SELF_SIGNED_JWT__VALIDATION_KEY="$(cat aigw_validation.key)"
   ```

1. 重启 AI Gateway 容器。

> [!note]
> `AIGW_SELF_SIGNED_JWT__SIGNING_KEY` 由 AI Gateway 用于签名用户 JWT。
> `AIGW_SELF_SIGNED_JWT__VALIDATION_KEY` 是一个辅助密钥，用于在密钥轮换期间进行令牌验证，
> 确保之前签发的令牌仍然有效。
> 两个密钥都必须使用 PEM 格式的 RSA 2048 位私钥。
> 这些密钥与 `DUO_WORKFLOW_SELF_SIGNED_JWT__SIGNING_KEY` 不同，
> 后者由极狐GitLab Duo Agent Platform 使用。

### 加载 PEM 文件时的 SSL 证书错误

如果在将 PEM 文件加载到 Docker 容器时收到显示 `JWKError` 的错误，您可能需要解决 SSL 证书错误。

要修复此问题，请使用以下环境变量在 Docker 容器中设置适当的证书包路径：

- `SSL_CERT_FILE=/path/to/ca-bundle.pem`
- `REQUESTS_CA_BUNDLE=/path/to/ca-bundle.pem`

将 `/path/to/ca-bundle.pem` 替换为您的证书包路径。