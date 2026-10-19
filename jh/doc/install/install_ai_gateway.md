---
stage: AI Platform
group: AI Core Infra
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 极狐GitLab 与大语言模型之间的网关。
title: 安装 AI 网关
---

[AI 网关](../administration/gitlab_duo/gateway.md)由两个服务组成，用于访问 AI 原生的极狐GitLab Duo 功能：

- AI 网关服务
- [极狐GitLab Duo Agent Platform 服务](../user/duo_agent_platform/_index.md)

<a id="authentication-and-json-web-tokens-jwt"></a>

## 身份验证与 JSON Web Token (JWT)

为访问极狐GitLab Duo 功能，AI 网关使用 JWT 确认请求来自您极狐GitLab 实例上已通过身份验证的用户。当您的极狐GitLab 实例请求令牌时，该服务会签发一个短期有效的签名令牌来授权该请求。

当您自行托管 AI 网关时，必须生成签名密钥对，并将密钥作为环境变量传递给该服务。

每个服务使用各自的密钥对：

- AI 网关使用 `AIGW_SELF_SIGNED_JWT__SIGNING_KEY` 和
  `AIGW_SELF_SIGNED_JWT__VALIDATION_KEY`，用于极狐GitLab Duo 代码建议和极狐GitLab Duo Chat 等功能。
- 极狐GitLab Duo Agent Platform 服务使用 `DUO_WORKFLOW_SELF_SIGNED_JWT__SIGNING_KEY` 和
  `DUO_WORKFLOW_SELF_SIGNED_JWT__VALIDATION_KEY`。

每对密钥提供以下作用：

- 签名密钥用于对服务签发的令牌进行签名。
- 验证密钥用于在密钥轮换期间验证令牌，使使用先前密钥签名的令牌在过期前仍然有效。

一对密钥中的两个密钥都必须是 PEM 格式的 RSA 2048 位私钥。如果缺少这些密钥，服务将无法签发令牌，请求会因令牌创建错误而失败。

<a id="install-by-using-docker"></a>

## 使用 Docker 安装

AI 网关 Docker 镜像在单个容器中包含所有必要的代码和依赖项。

先决条件：

- 安装 Docker 容器引擎，例如 [Docker](https://docs.docker.com/engine/install/)。
- 使用网络中可访问的有效主机名。不要使用 `localhost`。
- 确保为 `linux/amd64` 架构预留约 340 MB（压缩后）的空间，并至少拥有 512 MB 内存。
- 确保容器至少可访问两个 CPU，以供
  `ai_gateway` 和 `duo-workflow-service` 服务使用。
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
  > 请妥善保管所有生成的密钥文件，不要公开分享。这些密钥用于对 JWT 进行签名，必须作为敏感凭据对待。

为确保更好的性能，尤其是在高负载情况下，请考虑分配比最低要求更多的磁盘空间、内存和资源。更高的内存和磁盘容量可以提升 AI 网关在峰值负载下的效率。

AI 网关不需要 GPU。

<a id="ai-gateway-images"></a>

### AI 网关镜像

<a id="standard-images"></a>

#### 标准镜像

标准 AI 网关镜像可在以下位置获取：

- 容器镜像仓库：[稳定版](https://hub.gitlab.cn/model-gateway-self-hosted)
- DockerHub：[稳定版](https://hub.gitlab.cn/model-gateway-self-hosted)

如果您的极狐GitLab 版本为 `vX.Y.*-jh.0`，请使用带有最新 `self-hosted-vX.Y.*-jh` 标签的 AI 网关镜像。例如：

- 如果极狐GitLab 为 `v18.2.1-jh.0`，而 AI 网关镜像有
  版本 `self-hosted-v18.2.0-jh`、`self-hosted-v18.2.1-jh` 和 `self-hosted-v18.2.2-jh`，请使用 `self-hosted-v18.2.2-jh`。
- 如果极狐GitLab 为 `v18.2.1-jh.0`，而 AI 网关镜像
  只有版本 `self-hosted-v18.2.0-jh`，请使用 `self-hosted-v18.2.0-jh`。

更多信息，请参阅[自托管 AI 网关的发布流程](https://jihulab.com/gitlab-cn/modelops/ai-assist/-/blob/main/docs/delivery/release.md)。

> [!note]
> 不保证 nightly 构建的向后兼容性。
> 请始终使用带有明确版本标签的稳定版本。

<a id="start-a-container-from-the-image"></a>

### 从镜像启动容器

1. 运行以下命令启动容器：

   ```shell
   docker run -d -p 5052:5052 -p 50052:50052 \
    -e AIGW_GITLAB_URL=<your_gitlab_instance> \
    -e AIGW_GITLAB_API_URL=<your_gitlab_instance>/api/v4/ \
    -e AIGW_SELF_SIGNED_JWT__SIGNING_KEY="$(cat aigw_signing.key)" \
    -e AIGW_SELF_SIGNED_JWT__VALIDATION_KEY="$(cat aigw_validation.key)" \
    -e DUO_WORKFLOW_AUTH__ENABLED="true" \
    -e DUO_WORKFLOW_SELF_SIGNED_JWT__SIGNING_KEY="$(cat duo_workflow_jwt.key)" \
    -e DUO_WORKFLOW_SELF_SIGNED_JWT__VALIDATION_KEY="$(cat duo_workflow_validation.key)" \
    registry.gitlab.cn/model-gateway/model-gateway-self-hosted:<ai-gateway-tag>
   ```

   替换以下占位符：

   - `<your_gitlab_instance>`：您的极狐GitLab 实例 URL（例如 `https://gitlab.example.com`）。
   - `<ai-gateway-tag>`：与您的极狐GitLab 实例匹配的版本。如果您的极狐GitLab 版本为 `vX.Y.0-jh.0`，请使用 `self-hosted-vX.Y.0-jh`。

   从容器主机访问 `http://localhost:5052` 应返回 `{"error":"No authorization header presented"}`。

1. 确保端口 `5052` 和 `50052` 已从主机转发到容器。
   端口 `5052` 处理 AI 网关的 HTTP 通信。端口 `50052` 处理
   极狐GitLab Duo Agent Platform 服务的 gRPC 通信。
1. 对于使用离线许可证的极狐GitLab 实例，在 AIGW 容器中
   设置 `-e DUO_WORKFLOW_AUTH__OIDC_CUSTOMER_PORTAL_URL=<your_gitlab_instance>` 和 `-e AIGW_CUSTOMER_PORTAL_URL=<your_gitlab_instance>`。
   此配置：
   - 强制极狐GitLab Duo Workflow 服务仅针对本地极狐GitLab 实例进行身份验证。
   - 消除因无法访问 CustomersDot 调用而导致的 20 秒延迟。
1. 配置 [AI 网关 URL](../administration/gitlab_duo_self_hosted/configure_duo_features.md#configure-access-to-the-local-ai-gateway) 和[极狐GitLab Duo Agent Platform 服务 URL](../administration/gitlab_duo_self_hosted/configure_duo_features.md#configure-access-to-the-gitlab-duo-agent-platform)。
1. 可选。如果您的本地极狐GitLab Duo Agent Platform 端点使用 TLS：
   1. 在右上角，选择**管理员**。
   1. 选择 **极狐GitLab Duo** > **更改配置**。
   1. 选中**为极狐GitLab Duo Agent Platform 服务使用 TLS** 复选框。

<a id="restrict-network-access"></a>

### 限制网络访问

为加固系统，请进行以下网络配置：

- 限制 AI 网关容器的出站网络访问。
- 阻止来自容器的所有其他出站流量。

AI 网关需要出站访问以下内容。请确保将这些内容作为网络限制的例外：

- 您的极狐GitLab 实例（`AIGW_GITLAB_URL`）。
- 您配置的 AI 模型提供商端点（例如 Anthropic、Gemini Enterprise Agent Platform
  或 Azure OpenAI）。
- `customers.gitlab.com`，用于许可证验证，除非您使用离线许可证。

> [!warning]
> 在应用防火墙规则之前，请先在非生产环境中测试。
> 过于严格的规则可能会破坏 AI 网关功能。

要在 Linux 主机上限制出站访问，请在 `DOCKER-USER` 链中使用 `iptables` 规则。更多信息，请参阅 [Docker 数据包过滤和防火墙](https://docs.docker.com/engine/network/packet-filtering-firewalls/)。

<a id="set-up-docker-with-nginx-and-ssl"></a>

## 使用 NGINX 和 SSL 设置 Docker

> [!note]
> 这种将 NGINX 或 Caddy 部署为反向代理的方法是一种临时变通方法，用于支持 SSL，
> 直到[议题 455854](https://gitlab.com/gitlab-org/gitlab/-/issues/455854)
> 实现为止。

要为 AI 网关实例使用 SSL，请使用：

- Docker
- NGINX 作为反向代理
- Let's Encrypt 提供 SSL 证书

NGINX 管理与外部客户端的安全连接。它先解密传入的 HTTPS 请求，再将其传递给 AI 网关。

先决条件：

- 已安装 Docker 和 Docker Compose
- 已注册并配置的域名

<a id="create-configuration-files"></a>

### 创建配置文件

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
           # proxy_read_timeout is the longest allowed idle gap between response chunks,
           # not the total response time. Reasoning models can pause for minutes before responding.
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
           # proxy_read_timeout is the longest allowed idle gap between response chunks,
           # not the total response time. Reasoning models can pause for minutes before responding.
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

<a id="set-up-ssl-certificate-by-using-lets-encrypt"></a>

### 使用 Let's Encrypt 设置 SSL 证书

要设置 SSL 证书：

- 对于基于 Docker 的 NGINX 服务器，Certbot
  [提供了实现 Let's Encrypt 证书的自动化方式](https://phoenixnap.com/kb/letsencrypt-docker)。
- 或者，您可以使用 [Certbot 手动安装](https://eff-certbot.readthedocs.io/en/stable/using.html#manual)。

<a id="create-an-environment-file"></a>

### 创建环境文件

创建一个 `.env` 文件来存储 JWT 签名和验证密钥：

```shell
echo "AIGW_SELF_SIGNED_JWT__SIGNING_KEY=\"$(cat aigw_signing.key)\"" > .env
echo "AIGW_SELF_SIGNED_JWT__VALIDATION_KEY=\"$(cat aigw_validation.key)\"" >> .env
echo "DUO_WORKFLOW_SELF_SIGNED_JWT__SIGNING_KEY=\"$(cat duo_workflow_jwt.key)\"" >> .env
echo "DUO_WORKFLOW_SELF_SIGNED_JWT__VALIDATION_KEY=\"$(cat duo_workflow_validation.key)\"" >> .env
```

<a id="create-a-docker-compose-file"></a>

### 创建 Docker Compose 文件

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

<a id="deploy-and-validate"></a>

### 部署并验证

要部署并验证该解决方案：

1. 启动 `nginx` 和 `AIGW` 容器，并确认它们正在运行：

   ```shell
   docker compose up
   docker ps
   ```

1. 配置您的[极狐GitLab 实例以访问 AI 网关](../administration/gitlab_duo_self_hosted/configure_duo_features.md#configure-access-to-the-local-ai-gateway)。
1. 配置您的极狐GitLab 实例以访问[极狐GitLab Duo Agent Platform 服务](../administration/gitlab_duo_self_hosted/configure_duo_features.md#configure-access-to-the-gitlab-duo-agent-platform)的 URL。
1. 执行健康检查，确认 AI 网关和 Agent Platform 均可访问。

<a id="install-by-using-helm-chart"></a>

## 使用 Helm chart 安装

先决条件：

- 您必须拥有：
  - 您拥有的域名，可以向其添加 DNS 记录。
  - Kubernetes 集群。
  - 可正常使用的 `kubectl`。
  - 可正常使用的 Helm，版本 v3.11.0 或更高。

更多信息，请参阅[在 GKE 或 EKS 上测试 GitLab chart](https://gitlab.cn/docs/charts/quickstart/)。

<a id="add-the-ai-gateway-helm-repository"></a>

### 添加 AI 网关 Helm 仓库

将 AI 网关 Helm 仓库添加到 Helm 配置中：

```shell
helm repo add ai-gateway \
https://gitlab.com/api/v4/projects/gitlab-org%2fcharts%2fai-gateway-helm-chart/packages/helm/devel
```

<a id="install-the-ai-gateway"></a>

### 安装 AI 网关

1. 创建 `ai-gateway` 命名空间：

   ```shell
   kubectl create namespace ai-gateway
   ```

1. 为您计划公开 AI 网关
   和极狐GitLab Duo Agent Platform 服务的域名生成证书。
1. 在先前创建的命名空间中创建 TLS 密钥：

   ```shell
   kubectl -n ai-gateway create secret tls ai-gateway-tls --cert="<path_to_cert>" --key="<path_to_cert_key>"
   ```

1. 生成 JWT 签名密钥，并将其存储在同一命名空间的密钥中：

   ```shell
   openssl genrsa -out aigw_signing.key 2048
   openssl genrsa -out aigw_validation.key 2048
   openssl genrsa -out duo_workflow_jwt.key 2048
   openssl genrsa -out duo_workflow_validation.key 2048

   kubectl -n ai-gateway create secret generic ai-gateway-jwt \
     --from-file=aigw_signing.key \
     --from-file=aigw_validation.key \
     --from-file=duo_workflow_jwt.key \
     --from-file=duo_workflow_validation.key
   ```

1. 获取 [chart 的软件包仓库](https://gitlab.com/gitlab-org/charts/ai-gateway-helm-chart/-/packages)中最新软件包的版本号。
1. 为使 AI 网关能够访问 API，它必须知道极狐GitLab 实例
   所在的位置。将 `gitlab.url` 和 `gitlab.apiUrl` 与
   Ingress、gRPC Ingress 和 JWT 密钥值一起设置如下：

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
     --set "ingress.gitlabIngressEnabled=false" \
     --set "grpcIngress.hosts[0].host=<your_gateway_grpc_domain>" \
     --set "grpcIngress.hosts[0].paths[0].path=/" \
     --set "grpcIngress.hosts[0].paths[0].pathType=Prefix" \
     --set "grpcIngress.tls[0].secretName=ai-gateway-tls" \
     --set "grpcIngress.tls[0].hosts[0]=<your_gateway_grpc_domain>" \
     --set "grpc-tls-proxy.enabled=true" \
     --set "grpc-tls-proxy.tlsSecretName=ai-gateway-tls" \
     --set "grpc-tls-proxy.upstream.host=ai-gateway" \
     --set "aigwSigningKey.secret=ai-gateway-jwt" \
     --set "aigwSigningKey.key=aigw_signing.key" \
     --set "aigwValidationKey.secret=ai-gateway-jwt" \
     --set "aigwValidationKey.key=aigw_validation.key" \
     --set "duoWorkflowSigningKey.secret=ai-gateway-jwt" \
     --set "duoWorkflowSigningKey.key=duo_workflow_jwt.key" \
     --set "duoWorkflowValidationKey.secret=ai-gateway-jwt" \
     --set "duoWorkflowValidationKey.key=duo_workflow_validation.key" \
     --timeout=300s --wait --wait-for-jobs
   ```

   仅当 `ingress.gitlabIngressEnabled` 为 `false` 时，chart 才会渲染 Ingress。
   gRPC Ingress 通过 chart 的 TLS 代理为极狐GitLab Duo Agent Platform 服务提供服务。
   `grpc-tls-proxy.upstream.host` 必须是 AI 网关服务的名称，
   对于此命令中使用的发布名称，服务名称为 `ai-gateway`。

   对于具有离线许可证且无互联网访问的离线环境，
   在 `--timeout=300s` 之前，还要将以下值添加到命令中：

   ```shell
     --set "extraEnvironmentVariables[0].name=AIGW_CUSTOMER_PORTAL_URL" \
     --set "extraEnvironmentVariables[0].value=https://<your_gitlab_domain>" \
     --set "extraEnvironmentVariables[1].name=LITELLM_LOCAL_MODEL_COST_MAP" \
     --set-string "extraEnvironmentVariables[1].value=True" \
     --set "grpc-tls-proxy.image.repository=<your_internal_registry>/nginx" \
   ```

   chart 已将 `DUO_WORKFLOW_AUTH__OIDC_CUSTOMER_PORTAL_URL` 设置为 `gitlab.url`。
   在没有互联网访问的情况下，`LITELLM_LOCAL_MODEL_COST_MAP` 必须为 `True`。
   否则，LiteLLM 会在启动时重试从 `raw.githubusercontent.com` 下载，
   并且存活探针会在 AI 网关接受连接之前重启 pod。

   在运行该命令之前，请将 TLS 代理的 `nginx:alpine` 镜像
   推送到 `<your_internal_registry>/nginx`。

您可以在[容器镜像仓库](https://hub.gitlab.cn/model-gateway-self-hosted)中找到可用作 `image.tag`的 AI 网关版本列表。

此步骤可能需要几秒钟，以便分配所有资源并启动 AI 网关。

如果现有的 `nginx` Ingress 控制器无法为其他命名空间中的服务提供服务，您可能需要为 AI 网关设置自己的 Ingress 控制器。请确保为多命名空间部署正确设置 Ingress。

对于 `ai-gateway` Helm chart 的版本，请使用 `helm search repo ai-gateway --versions` 查找合适的 chart 版本。

等待您的 pod 启动并运行：

```shell
kubectl wait pod \
  --all \
  --for=condition=Ready \
  --namespace=ai-gateway \
  --timeout=300s
```

当您的 pod 启动并运行后，您可以设置 IP ingress 和 DNS 记录。

<a id="connect-to-a-gitlab-instance-or-model-endpoint-with-a-self-signed-ssl-certificate"></a>

## 使用自签名 SSL 证书连接到极狐GitLab 实例或模型端点

如果您的极狐GitLab 实例或模型端点配置了自签名证书，您必须将根证书颁发机构 (CA) 证书添加到 AI 网关的证书包中。

为此，您可以：

- 将根 CA 证书传递给 AI 网关，使身份验证成功。
- 将根 CA 证书添加到 AI 网关容器的 CA 包中。

<a id="pass-the-root-ca-certificate-to-the-ai-gateway"></a>

### 将根 CA 证书传递给 AI 网关

要将根 CA 证书传递给 AI 网关并确保身份验证成功，请设置 `REQUESTS_CA_BUNDLE` 环境变量。由于极狐GitLab 使用 [Certifi](https://pypi.org/project/certifi/) 作为基础受信任 CA 列表，您可以按如下方式配置自定义 CA 包：

1. 下载 Certifi `cacert.pem` 文件：

   ```shell
   curl "https://raw.githubusercontent.com/certifi/python-certifi/2024.07.04/certifi/cacert.pem" --output cacert.pem
   ```

1. 将您的自签名根 CA 证书追加到该文件。例如，如果您使用 `mkcert` 创建证书：

   ```shell
   cat "$(mkcert -CAROOT)/rootCA.pem" >> path/to/your/cacert.pem
   ```

1. 将 `REQUESTS_CA_BUNDLE` 设置为您的 `cacert.pem` 文件的路径。例如，在 GDK 中，将以下内容添加到您的 `$GDK_ROOT/env.runit`：

   ```shell
   export REQUESTS_CA_BUNDLE=/path/to/your/cacert.pem
   ```

<a id="add-the-root-ca-certificate-to-the-ai-gateway-containers-ca-bundle"></a>

### 将根 CA 证书添加到 AI 网关容器的 CA 包

要允许 AI 网关信任由自定义 CA 签名的极狐GitLab 私有化部署实例证书，请将根 CA 证书添加到 AI 网关容器的 CA 包中。

此方法不允许在 chart 的后续版本中更改根 CA 包。

要为 AI 网关的 Helm chart 部署执行此操作：

1. 将自定义根 CA 证书追加到本地文件：

   ```shell
   cat customCA-root.crt >> ca-certificates.crt
   ```

1. 将 `/etc/ssl/certs/ca-certificates.crt` 包文件从 AI 网关容器复制到本地文件：

   ```shell
   kubectl cp -n gitlab ai-gateway-55d697ff9d-j9pc6:/etc/ssl/certs/ca-certificates.crt ca-certificates.crt.
   ```

1. 从本地文件创建新密钥：

   ```shell
   kubectl create secret generic ca-certificates -n gitlab --from-file=cacertificates.crt=ca-certificates.crt
   ```

1. 在 chart 的 `values.yml`中使用该密钥来定义 `volume` 和 `volumeMount`。这会在容器中创建 `/tmp/ca-certificates.crt` 文件：

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

1. 设置 `REQUESTS_CA_BUNDLE` 和 `SSL_CERT_FILE` 环境变量，使其指向挂载的文件：

   ```shell
   extraEnvironmentVariables:
     - name: REQUESTS_CA_BUNDLE
       value: /tmp/ca-certificates.crt
     - name: SSL_CERT_FILE
       value: /tmp/ca-certificates.crt
   ```

1. 重新部署 chart。

[议题 3](https://gitlab.com/gitlab-org/charts/ai-gateway-helm-chart/-/issues/3) 用于在 Helm chart 中原生支持此功能。

<a id="for-a-docker-deployment"></a>

#### 对于 Docker 部署

对于 Docker 部署，使用相同的方法。唯一的区别是，要在容器中挂载本地文件，请使用 `--volume /root/ca-certificates.crt:/tmp/ca-certificates.crt`。

<a id="connect-to-a-model-endpoint-that-requires-mutual-tls-mtls"></a>

## 连接到需要双向 TLS (mTLS) 的模型端点

如果您的模型端点或其前面的代理要求调用方使用客户端证书进行身份验证，请配置 AI 网关以提供证书。此方法等同于 `curl --cert` 选项。

要连接到需要 mTLS 的模型端点，请在 AI 网关上设置以下环境变量：

| 变量                  | 必需 | 描述 |
|---------------------------|----------|-------------|
| `AIGW_MTLS__ENABLED`      | 是      | 设置为 `true` 以向上游模型端点提供客户端证书。 |
| `AIGW_MTLS__CERT_FILE`    | 是      | 客户端证书 PEM 文件的路径。可以包含合并的证书和私钥，或使用 `AIGW_MTLS__KEY_FILE` 指定单独的密钥。 |
| `AIGW_MTLS__KEY_FILE`     | 否       | 客户端私钥的路径（如果未捆绑在 `AIGW_MTLS__CERT_FILE`中）。 |
| `AIGW_MTLS__KEY_PASSWORD` | 否       | 加密私钥的密码。需要 `AIGW_MTLS__KEY_FILE`。 |
| `AIGW_MTLS__VERIFY`       | 否       | 设置为 `false` 以禁用上游服务器证书验证。默认为 `true`。 |
| `AIGW_MTLS__CA_BUNDLE`    | 否       | 用于验证上游服务器证书的 CA 包路径（例如企业 CA）。未设置此变量时，AI 网关会依据 `SSL_CERT_FILE`（如果已设置）或其内置 CA 包进行验证。 |

对于 GitLab Helm chart 部署，挂载客户端证书并设置变量：

```yaml
volumes:
  - name: mtls-client-cert
    secret:
      secretName: aigw-mtls-client-cert
      optional: false

volumeMounts:
  - name: mtls-client-cert
    mountPath: /certs
    readOnly: true

extraEnvironmentVariables:
  - name: AIGW_MTLS__ENABLED
    value: "true"
  - name: AIGW_MTLS__CERT_FILE
    value: /certs/client.pem
```

对于 Docker 部署，使用相同的环境变量，并使用 `--volume /path/to/client.pem:/certs/client.pem` 挂载证书。

AI 网关仅在上游服务器在 TLS 握手期间请求证书时才提供客户端证书。此配置不会影响不需要客户端证书的模型端点。

<a id="upgrade-the-ai-gateway-docker-image"></a>

## 升级 AI 网关 Docker 镜像

要升级 AI 网关，请下载最新的 Docker 镜像标签。

1. 停止正在运行的容器：

   ```shell
   sudo docker stop gitlab-aigw
   ```

1. 移除现有容器：

   ```shell
   sudo docker rm gitlab-aigw
   ```

1. 拉取并[运行新镜像](#start-a-container-from-the-image)。
1. 确保所有环境变量均已正确设置。

<a id="security-updates-and-image-verification"></a>

## 安全更新与镜像验证

为确保您运行的是最新的安全补丁，请根据您的部署方式遵循以下准则。

<a id="for-kubernetes-or-helm-deployments"></a>

### 对于 Kubernetes 或 Helm 部署

0.7.0 之前的 [chart 版本](https://gitlab.com/gitlab-org/charts/ai-gateway-helm-chart/-/packages)和 Kubernetes 默认使用 `imagePullPolicy: IfNotPresent`，如果标签未更改，则不会拉取更新的镜像。这意味着您可能会错过在同一版本标签下发布的安全补丁。

您应使用以下基于镜像摘要的方法：

```shell
# Find the image digest from the container registry
# Use this digest in your Helm install/upgrade command

helm upgrade --install ai-gateway \
  ai-gateway/ai-gateway \
  --set="image.tag=self-hosted-v18.2.1-jh@sha256:abc123..." \
  # ... other flags
```

或者，您可以将 `imagePullPolicy` 与以下任一方法结合使用：

- 将 `imagePullPolicy` 设置为 always：

  ```shell
  helm upgrade --install ai-gateway \
    ai-gateway/ai-gateway \
    --set="image.pullPolicy=Always" \
    # ... other flags
  ```

- 将 `pullPolicy` 添加到您的 `values.yaml`：

  ```yaml
  image:
    pullPolicy: Always
  ```

要强制拉取更新：

```shell
kubectl rollout restart deployment/ai-gateway -n ai-gateway
```

<a id="for-docker-deployments"></a>

### 对于 Docker 部署

升级时，请确认您拉取的是最新镜像：

```shell
# Check current image digest
docker images --digests | grep ai-assist

# Pull latest version explicitly
docker pull registry.gitlab.cn/model-gateway/model-gateway-self-hosted:<ai-gateway-tag>

# Verify digest changed
docker images --digests | grep ai-assist
```

要使用镜像摘要进行不可变部署：

```shell
docker run -d -p 5052:5052 -p 50052:50052 \
 -e AIGW_GITLAB_URL=<your_gitlab_instance> \
 -e AIGW_GITLAB_API_URL=https://<your_gitlab_domain>/api/v4/ \
 -e DUO_WORKFLOW_SELF_SIGNED_JWT__SIGNING_KEY="$(cat duo_workflow_jwt.key)" \
 -e DUO_WORKFLOW_SELF_SIGNED_JWT__VALIDATION_KEY="$(cat duo_workflow_validation.key)" \
 -e AIGW_SELF_SIGNED_JWT__SIGNING_KEY="$(cat aigw_signing.key)" \
 -e AIGW_SELF_SIGNED_JWT__VALIDATION_KEY="$(cat aigw_validation.key)" \
 registry.gitlab.cn/model-gateway/model-gateway-self-hosted:self-hosted-v18.2.1-jh@sha256:abc123...
```

<a id="alternative-installation-methods"></a>

## 其他安装方法

有关安装 AI 网关的其他方式的信息，请参阅[议题 463773](https://gitlab.com/gitlab-org/gitlab/-/issues/463773)。

<a id="health-check-and-debugging"></a>

## 健康检查与调试

要调试极狐GitLab Duo 自部署版本安装的问题，请运行以下命令：

```shell
sudo gitlab-rake gitlab:duo:verify_self_hosted_setup
```

确保：

- AI 网关 URL 已正确配置（通过 `ApplicationSetting.current.ai_gateway_url`）。
- 已通过 `/admin/code_suggestions` 为 root 用户显式启用极狐GitLab Duo 访问权限。

如果访问问题仍然存在，请检查身份验证是否已正确配置，以及健康检查是否通过。

如果问题持续存在，错误消息可能会建议使用 `AIGW_AUTH__BYPASS_EXTERNAL=true` 绕过身份验证，但仅应在故障排除时这样做。

您还可以通过转到**管理员** > **极狐GitLab Duo** 来运行[健康检查](../administration/gitlab_duo/configure/_index.md#run-a-health-check-for-gitlab-duo)。

这些测试针对离线环境执行：

| 测试 | 描述 |
|-----------------|-------------|
| 网络 | 测试：<br>- AI 网关 URL 是否已通过 `application_settings` 表在数据库中正确配置。<br> - 您的实例是否可以连接到配置的 URL。<br><br>如果您的实例无法连接到该 URL，请确保您的防火墙或代理服务器设置[允许连接](../administration/gitlab_duo/configure/_index.md)。尽管出于旧版兼容性仍支持环境变量 `AI_GATEWAY_URL`，但建议通过数据库配置 URL，以便更好地管理。 |
| 许可证 | 测试您的许可证是否有权访问代码建议功能。 |
| 系统交换 | 测试您的实例中是否可以使用代码建议。如果系统交换评估失败，用户可能无法使用极狐GitLab Duo 功能。 |

<a id="monitor-the-ai-gateway"></a>

## 监控 AI 网关

使用 Prometheus 收集有关 AI 网关使用情况和性能的指标。

<a id="set-up-prometheus-metrics-for-the-ai-gateway"></a>

### 为 AI 网关设置 Prometheus 指标

要设置 Prometheus 指标：

1. 设置所需的环境变量并开放端口 `8082`：

   ```shell
   -e AIGW_FASTAPI__METRICS_HOST=0.0.0.0
   -e AIGW_FASTAPI__METRICS_PORT=8082
   ```

<a id="set-up-prometheus-for-the-gitlab-duo-workflow-service"></a>

### 为极狐GitLab Duo Workflow 服务设置 Prometheus

要在极狐GitLab Duo Workflow 服务上设置 Prometheus 指标：

1. 设置所需的环境变量并开放端口 `8083`：

   ```shell
   -e PROMETHEUS_METRICS__ADDR=0.0.0.0
   -e PROMETHEUS_METRICS__PORT=8083
   ```

1. 将指标端口从 `gitlab-ai-gateway` 容器公开到主机：

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

   这会在端口 `8082` 上公开 AI 网关指标端点，并在端口 `8083` 上公开极狐GitLab Duo Workflow 服务指标端点。

1. 重启 AI 网关容器

<a id="configure-prometheus-to-scrape-metrics"></a>

### 配置 Prometheus 抓取指标

要从 AI 网关和极狐GitLab Duo Workflow 服务收集指标，请将以下
`prometheus.yml` 配置添加到您的 Prometheus 实例。在此配置中，Prometheus
每 15 秒从两个服务抓取一次指标。

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

<a id="verify-metrics-collection"></a>

### 验证指标收集

要验证是否正在收集 AI 网关和极狐GitLab Duo Workflow 服务的目标：

1. 在 Prometheus UI 中，转到 **状态 > 目标**。
1. 转到 **告警** 或 **图表** 标签页以查询指标。AI 网关和极狐GitLab Duo Workflow 服务
   在以下端点公开指标：

   - AI 网关：`http://<your_AIGW_domain>:8082/metrics`
   - 极狐GitLab Duo Workflow 服务：`http://<your_duo_agent_platform_service_domain>:8083/metrics`

<a id="does-the-ai-gateway-need-to-autoscale"></a>

## AI 网关需要自动扩缩吗？

自动扩缩不是强制性的，但建议用于工作负载可变、并发要求高或使用模式不可预测的环境。在极狐GitLab 生产环境中：

- 基准设置：单个 AI 网关实例，配备 2 个 CPU 核心和 8 GB 内存，可处理约 40 个并发请求。
- 扩缩准则：对于更大的设置，例如 AWS t3.2xlarge 实例（8 个 vCPU，32 GB 内存），网关可处理多达 160 个并发请求，相当于基准设置的 4 倍。
- 请求吞吐量：JihuLab.com 的观测使用情况表明，每 1000 名活跃用户 7 RPS（每秒请求数）是用于规划的合理指标。
- 自动扩缩选项：使用 Kubernetes 水平 Pod 自动扩缩器 (HPA) 或类似机制，根据 CPU、内存利用率或请求延迟阈值等指标动态调整实例数量。

<a id="configuration-examples-by-deployment-size"></a>

## 按部署规模划分的配置示例

- 小型部署：
  - 单个实例，配备 2 个 vCPU 和 8 GB 内存。
  - 可处理多达 40 个并发请求。
  - 适用于用户数不超过 50 且工作负载可预测的团队或组织。
  - 固定实例可能就足够；为节省成本可以禁用自动扩缩。
- 中型部署：
  - 单个 AWS t3.2xlarge 实例，配备 8 个 vCPU 和 32 GB 内存。
  - 可处理多达 160 个并发请求。
  - 适用于用户数为 50-200 且并发要求中等的组织。
  - 实施 Kubernetes HPA，阈值为 CPU 利用率 50% 或请求延迟超过 500ms。
- 大型部署：
  - 由多个 AWS t3.2xlarge 实例或同等实例组成的集群。
  - 每个实例可处理 160 个并发请求，通过多个实例可扩展到数千名用户。
  - 适用于用户数超过 200 且工作负载可变、并发量高的企业。
  - 使用 HPA 根据实时需求扩缩 pod，并结合节点自动扩缩进行集群范围的资源调整。

<a id="ai-gateway-container-specs-and-resource-allocation"></a>

## AI 网关容器规格与资源分配

AI 网关在以下资源分配下可有效运行：

- 每个容器 2 个 CPU 核心和 8 GB 内存。
- 在极狐GitLab 生产环境中，容器通常使用约 7.39% 的 CPU 和相应比例的内存，为增长或处理突发活动留有余地。

<a id="mitigation-strategies-for-resource-contention"></a>

## 资源争用的缓解策略

- 使用 Kubernetes 资源请求和限制，确保 AI 网关容器获得有保证的 CPU 和内存分配。例如：

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
- 将节点或实例专用于 AI 网关，以防止与其他服务争用资源。

<a id="scaling-strategies"></a>

## 扩缩策略

- 使用 Kubernetes HPA 根据以下实时指标扩缩 pod：
  - 平均 CPU 利用率超过 50%。
  - 请求延迟持续高于 500ms。
  - 启用节点自动扩缩，以便随着 pod 增加动态扩缩基础设施资源。

<a id="scaling-recommendations"></a>

## 扩缩建议

| 部署规模 | 实例类型      | 资源             | 容量（并发请求数） | 扩缩建议                     |
|------------------|--------------------|------------------------|---------------------------------|---------------------------------------------|
| 小型            | 2 个 vCPU，8 GB 内存 | 单个实例        | 40                              | 固定部署；不自动扩缩。           |
| 中型           | AWS t3.2xlarge    | 单个实例     | 160                             | 基于 CPU 或延迟阈值的 HPA。     |
| 大型            | 多个 t3.2xlarge | 集群实例   | 每个实例 160               | 针对高需求的 HPA + 节点自动扩缩。     |

<a id="support-multiple-gitlab-instances"></a>

## 支持多个极狐GitLab 实例

您可以部署单个 AI 网关来支持多个极狐GitLab 实例，也可以为每个实例或地理区域部署单独的 AI 网关。为帮助决定哪种方式合适，请考虑：

- 预期流量约为每 1,000 名计费用户每秒 7 个请求。
- 基于所有实例的总并发请求数的资源需求。
- 每个极狐GitLab 实例的最佳实践身份验证配置。

<a id="co-locate-your-ai-gateway-and-instance"></a>

## 将 AI 网关与实例部署在同一位置

AI 网关在全球多个区域提供，通过以下方式确保无论用户身处何地都能获得最佳性能：

- 改善极狐GitLab Duo 功能的响应时间。
- 降低地理分布用户的延迟。
- 满足数据主权要求。

您应将 AI 网关部署在与极狐GitLab 实例相同的地理区域，以帮助提供顺畅的开发者体验，尤其是对于代码建议等延迟敏感的功能。
