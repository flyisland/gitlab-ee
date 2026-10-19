---
stage: Security Platform
group: Secrets Manager OpenBao
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 为极狐GitLab 的 Linux 软件包部署安装 OpenBao
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署
- Status: 测试版

{{< /details >}}

使用 Kubernetes 集群，在通过 Linux 软件包安装的极狐GitLab 实例旁运行 OpenBao。OpenBao 在集群中运行，并连接到一个 PostgreSQL 数据库。GitLab Rails 和 Sidekiq 通过 HTTPS 连接到 OpenBao。

> [!note]
> 此信息适用于极狐GitLab 19.2 及更高版本。
> 对于极狐GitLab 19.0 和 19.1，请参阅[文档归档](https://archives.docs.gitlab.com)中对应您极狐GitLab 版本的页面。

可通过以下两种方式之一运行 OpenBao：

- **同主机集群**：本地 Kubernetes 发行版（例如 k3s）与您的 Linux 软件包实例运行在同一主机上。Linux 软件包内置的 NGINX 充当 OpenBao 外部 URL 的 TLS 终止反向代理。极狐GitLab 应用通过 Kubernetes 在共享网络上暴露的端点连接到 OpenBao。
- **外部 Kubernetes 集群**：OpenBao 在单独的 Kubernetes 集群中运行。由您设计集群 Ingress 和 TLS 终止。GitLab Rails 和 Sidekiq 连接到您暴露的 OpenBao URL。如果您采用多节点 Linux 软件包部署，或者希望使用云提供商提供的托管 Kubernetes 服务，可考虑此方式。

> [!note]
> 在此安装过程中，请为 OpenBao 预配一个专用 PostgreSQL 实例。
> 请使用与极狐GitLab 所用 PostgreSQL 实例相互独立的 PostgreSQL 服务。
> 更多信息，请参见[议题 7292](https://gitlab.com/gitlab-org/omnibus-gitlab/-/work_items/7292)。

<a id="prerequisites"></a>

## 先决条件

{{< tabs >}}

{{< tab title="Colocated cluster" >}}

- 已通过 Linux 软件包安装极狐GitLab 19.2 或更高版本，并具有管理员访问权限。
- 在同一主机上安装了本地 Kubernetes 发行版。
- 主机上可使用 `helm` 和 `kubectl`。
- 一条将 OpenBao 域名指向该主机公网 IP 地址的 DNS 记录。

{{< /tab >}}

{{< tab title="External cluster" >}}

- 已通过 Linux 软件包安装极狐GitLab 实例，并具有管理员访问权限。
- 一个可从您的 Linux 软件包实例节点访问的外部 Kubernetes 集群。
- 已配置 `helm` 和 `kubectl` 以访问该集群。
- 一条将 OpenBao 域名指向集群 Ingress IP 地址的 DNS 记录。

{{< /tab >}}

{{< /tabs >}}

<a id="requirements"></a>

## 要求

{{< tabs >}}

{{< tab title="Colocated cluster" >}}

在安装 OpenBao 之前，请确认您的 Kubernetes 发行版满足以下要求：

- 除 Linux 软件包实例的要求和 Kubernetes 集群的要求外，还必须满足 [OpenBao 容量建议](_index.md#sizing-recommendations)。
- 同主机 Kubernetes 中的任何组件都不应尝试占用极狐GitLab 已使用的端口。许多小型 Kubernetes 发行版默认会安装绑定到 80 和 443 端口的负载均衡器。请禁用此类组件，因为 Linux 软件包管理的 NGINX 已在这些端口上监听。
- 您的同主机 Kubernetes 必须与 Linux 软件包实例共享网络，以便 Linux 软件包管理的 NGINX 能将外部 OpenBao 流量路由到 OpenBao 服务，并监听来自该服务的请求。您的 Linux 软件包实例不关心该服务是通过 Kubernetes `LoadBalancer` 还是 `NodePort` 暴露，只要两者在共享网络内均可访问即可。

{{< /tab >}}

{{< tab title="External cluster" >}}

在安装 OpenBao 之前，请确认您的环境满足以下要求：

- 您的 Kubernetes 集群必须满足 [OpenBao 容量建议](_index.md#sizing-recommendations)。
- 集群中的 OpenBao pod 与您的 Linux 软件包实例节点之间必须存在网络连接。如何建立此连接取决于您的基础设施。例如，您可以使用 VPC 对等连接、共享 VPC 或防火墙规则。GitLab Rails 和 Sidekiq 必须能够访问您从集群暴露的 OpenBao URL。
- 您的 PostgreSQL 实例必须接受来自集群 pod CIDR 的 TCP 连接。请配置防火墙或安全组规则，以允许该流量访问数据库端口。

{{< /tab >}}

{{< /tabs >}}

在投入生产之前，请查看[安全加固](#security-hardening)，了解针对部署的更多建议，尤其是当组件跨多台主机时。

<a id="before-you-begin"></a>

## 开始之前

{{< tabs >}}

{{< tab title="Colocated cluster" >}}

开始之前：

1. 收集 Kubernetes CNI（pod 网络）的 CIDR。稍后配置 PostgreSQL 身份验证时需要用到。
1. 收集您的 Linux 软件包实例与 Kubernetes 之间共享网络接口的 IP 地址（`<SHARED_NETWORK_IP>`）。稍后配置多个配置值时会用到。
1. 在尝试安装 OpenBao 之前，确认您的 Kubernetes 发行版已完全运行。
1. 确认您的 `kubectl` 上下文已设置为该集群（`KUBECONFIG` 已正确配置）。

{{< /tab >}}

{{< tab title="External cluster" >}}

开始之前：

1. 收集 Kubernetes pod 网络的 CIDR。稍后配置 PostgreSQL 身份验证时需要用到。
1. 收集 OpenBao 所用 PostgreSQL 实例的地址（`<POSTGRES_ADDRESS>`）。
1. 在尝试安装 OpenBao 之前，确认您的 Kubernetes 集群已完全运行。
1. 确认您的 `kubectl` 上下文已设置为该集群（`KUBECONFIG` 已正确配置）。

{{< /tab >}}

{{< /tabs >}}

<a id="provision-the-openbao-postgresql-database"></a>

## 预配 OpenBao PostgreSQL 数据库

OpenBao 需要自己的 PostgreSQL 数据库。请在配置极狐GitLab 之前，在您的外部或托管 PostgreSQL 实例上预配此数据库。

要预配 OpenBao PostgreSQL 数据库：

1. 为 OpenBao 数据库用户选择一个强密码。
   您将在本节最后一步的 Kubernetes 密钥中使用同一密码。

1. 创建 OpenBao 数据库用户：

   ```shell
   psql -h <POSTGRES_ADDRESS> -U <admin_user> \
     -c "CREATE USER openbao WITH PASSWORD '<strong-password>';"
   ```

1. 创建 OpenBao 数据库：

   ```shell
   psql -h <POSTGRES_ADDRESS> -U <admin_user> \
     -c "CREATE DATABASE openbao OWNER openbao;"
   ```

1. 创建 Kubernetes 命名空间以及将数据库密码传递给 Helm chart 的密钥。密钥名称和键必须与生成的 Helm values 文件匹配：

   ```shell
   kubectl create namespace openbao

   kubectl create secret generic openbao-db-password \
     --namespace openbao \
     --from-literal=password='<strong-password>'
   ```

<a id="configure-gitlab"></a>

## 配置极狐GitLab

{{< tabs >}}

{{< tab title="Colocated cluster" >}}

在极狐GitLab 主机的 `/etc/gitlab/gitlab.rb`中添加以下内容，并将占位符值替换为您的实际 IP 地址和域名：

```ruby
# PostgreSQL: accept TCP connections from Kubernetes pods.
# Use the shared network IP to restrict exposure to the shared network.
# Using '0.0.0.0' makes PostgreSQL listen on all interfaces, including public ones.
postgresql['listen_address'] = '<SHARED_NETWORK_IP>'

# Local GitLab services (Rails, container registry) connect to the shared
# network IP address over TCP instead of the Unix socket, so include it in
# the trusted CIDR blocks.
postgresql['trust_auth_cidr_addresses'] = %w[127.0.0.1/32 ::1/128 <SHARED_NETWORK_IP>/32]

# Kubernetes pods authenticate with a password.
# Replace 10.42.0.0/16 with the CIDR of your Kubernetes CNI (pod network).
postgresql['md5_auth_cidr_addresses'] = %w[10.42.0.0/16]

# Without this setting, NGINX routes all traffic on the shared IP to the
# OpenBao virtual host. Both virtual hosts must listen on the same addresses
# so NGINX can route by server name instead.
nginx['listen_addresses'] = ['*', '<SHARED_NETWORK_IP>']

# OAK: OpenBao reverse proxy via GitLab NGINX.
oak['enable'] = true
oak['network_address'] = '<SHARED_NETWORK_IP>'

oak['components']['openbao']['enable'] = true

# Replace 'https://openbao.example.com' with the URL of the DNS record
# you configured for OpenBao, which resolves to your host's public IP address.
oak['components']['openbao']['external_url'] = 'https://openbao.example.com'

# The internal URL that GitLab NGINX uses to reach the OpenBao service.
# If you use the service clusterIP, set a temporary value now and replace it after
# you install OpenBao. See the Helm installation step.
oak['components']['openbao']['internal_url'] = 'http://127.0.0.1:8200'

# The URL that the GitLab application uses to connect to OpenBao.
gitlab_rails['openbao'] = {
  'url' => 'https://openbao.example.com'
}
```

在此配置中：

- `postgresql['listen_address']` 是共享网络 IP。来自未列入 `trust_auth_cidr_addresses` 或 `md5_auth_cidr_addresses`的 CIDR 的连接会被 PostgreSQL 拒绝。
- `postgresql['trust_auth_cidr_addresses']` 是包含 localhost 和共享网络 IP 的 CIDR 块列表。来自这些块的连接不需要密码。需要共享网络 IP，是因为本地极狐GitLab 服务通过 TCP 而非 Unix 套接字连接到它。
- `postgresql['md5_auth_cidr_addresses']` 是来自 pod CIDR 的 CIDR 块列表。来自这些块的连接需要密码。这些地址由 OpenBao pod 使用。
- `nginx['listen_addresses']` 指定极狐GitLab 和 OpenBao NGINX 虚拟主机监听的地址。两个虚拟主机必须监听相同的地址，这样 NGINX 才能按服务器名称路由请求，而不是优先选择最具体的监听地址。
- `oak['network_address']` 是共享网络 IP。由 NGINX listen 指令使用。
- `oak['components']['openbao']['internal_url']` 是极狐GitLab 应用用于与 OpenBao 通信的 URL。
- `gitlab_rails['openbao']['url']` 是极狐GitLab 应用使用的 OpenBao URL。

根据 OpenBao 在集群中的暴露方式选择内部 URL：

- 负载均衡器或 `nodePort`。该 URL 在安装 OpenBao 之前就已确定，因此您可以现在设置它，并在一次重新配置中完成。对于负载均衡器，请配置 DNS，使内部 URL 解析到负载均衡器 IP 地址。
- 服务 `clusterIP`。`clusterIP` 仅在 Helm 创建服务后才会分配。请先设置一个临时的 `internal_url`，然后在安装 OpenBao 后更新它。

主机必须能够从 Kubernetes 集群外部访问内部 URL 的 IP。请配置您的集群，从您选择的 `<SHARED_NETWORK_IP>` 中分配 IP。

如果您的极狐GitLab `external_url` 设置使用 `https://`，则 Let's Encrypt 已启用。将 OpenBao `external_url`的协议设置为 `https://` 即可。极狐GitLab 会自动将 OpenBao 域名作为主题备用名称（SAN）添加到现有的 Let's Encrypt 证书中。

若要改用自定义证书，请添加：

```ruby
oak['components']['openbao']['ssl_certificate']     = '/etc/gitlab/ssl/openbao.example.com.crt'
oak['components']['openbao']['ssl_certificate_key'] = '/etc/gitlab/ssl/openbao.example.com.key'
```

{{< /tab >}}

{{< tab title="External cluster" >}}

在每个极狐GitLab 应用节点的 `/etc/gitlab/gitlab.rb`中添加以下内容，并将占位符值替换为您的实际地址和域名：

```ruby
# The URL GitLab Rails uses to connect to OpenBao.
gitlab_rails['openbao'] = {
  'url' => 'https://openbao.example.com'
}
```

如果您有单独的 Sidekiq 节点，请在每个 Sidekiq 节点的 `/etc/gitlab/gitlab.rb`中添加相同的 `gitlab_rails['openbao']` 设置。预配密钥的 Sidekiq 工作进程也需要访问 OpenBao。

您已按照[预配 OpenBao PostgreSQL 数据库](#provision-the-openbao-postgresql-database)所述，在外部或托管 PostgreSQL 实例上创建了 OpenBao 数据库和角色。请按照[要求](#requirements)所述，配置该实例以接受来自集群 pod CIDR 的 TCP 连接。

{{< /tab >}}

{{< /tabs >}}

<a id="apply-configuration-changes"></a>

## 应用配置更改

{{< tabs >}}

{{< tab title="Colocated cluster" >}}

应用配置更改：

```shell
sudo gitlab-ctl reconfigure
```

此命令一次性应用所有配置：

- PostgreSQL 开始接受来自 Kubernetes pod 的 TCP 连接。
- NGINX 配置了 OpenBao 虚拟主机，包括 TLS 终止和 HTTP 到 HTTPS 重定向。
- 如适用，签发或续订 Let's Encrypt 证书。
- Helm values 文件生成于 `/etc/gitlab/openbao-helm-values.yaml`。

如果未设置 `oak['components']['openbao']['external_url']` 或 `oak['components']['openbao']['internal_url']`，重新配置会失败。

{{< /tab >}}

{{< tab title="External cluster" >}}

在您更新了 `gitlab.rb`的每个 Rails 和 Sidekiq 节点上应用配置更改：

```shell
sudo gitlab-ctl reconfigure
```

这会应用 OpenBao URL 配置。

{{< /tab >}}

{{< /tabs >}}

<a id="install-openbao-by-using-helm"></a>

## 使用 Helm 安装 OpenBao

{{< tabs >}}

{{< tab title="Colocated cluster" >}}

要使用 Helm 安装 OpenBao：

1. 添加极狐GitLab Helm 仓库：

   ```shell
   helm repo add gitlab https://charts.gitlab.io
   helm repo update
   ```

1. 使用生成的 values 文件安装 OpenBao：

   ```shell
   helm upgrade --install openbao gitlab/openbao \
     --namespace openbao \
     --values /etc/gitlab/openbao-helm-values.yaml
   ```

   生成的文件会配置 PostgreSQL 存储、高可用性和 JWT 初始化。
   它不会配置 `ingress`、`ui` 或 `gatewayRoute`，因为同主机集群通过 Linux 软件包管理的 NGINX 访问 OpenBao。

   有关所有可用的 chart 选项，请参阅
   [OpenBao Helm chart 文档](https://gitlab.cn/docs/charts/charts/openbao/)。

1. 可选。如果您使用服务 `clusterIP` 作为内部 URL，请现在将其最终确定。读取分配的 `clusterIP`：

   ```shell
   kubectl -n openbao get svc openbao-active \
     -o jsonpath='{.spec.clusterIP}'
   ```

   在 `/etc/gitlab/gitlab.rb`中设置内部 URL：

   ```ruby
   oak['components']['openbao']['internal_url'] = 'http://<CLUSTER_IP>:8200'
   ```

   然后再次重新配置：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

   如果您使用负载均衡器或 `nodePort` 内部 URL，则不需要此步骤，因为在配置极狐GitLab 时该 URL 已确定。

{{< /tab >}}

{{< tab title="External cluster" >}}

要使用 Helm 安装 OpenBao：

1. 添加极狐GitLab Helm 仓库：

   ```shell
   helm repo add gitlab https://charts.gitlab.io
   helm repo update
   ```

1. 创建一个 `openbao-values.yaml` 文件，内容如下，并将占位符值替换为您的实际域名和 PostgreSQL 地址。密码来自 `openbao-db-password` 密钥：

   ```yaml
   config:
     ui: false
     storage:
       postgresql:
         haEnabled: true
         connection:
           host: "<POSTGRES_ADDRESS>"
           port: 5432
           database: openbao
           username: openbao
           password:
             secret: openbao-db-password
             key: password
     initialize:
       enabled: true
       oidcDiscoveryUrl: "https://<GITLAB_DOMAIN>"
       boundIssuer: "https://<GITLAB_DOMAIN>"
       boundAudiences: '"https://<OPENBAO_DOMAIN>"'

   # The chart deploys a Kubernetes Ingress resource by default, which you need to provide the hostname to be reachable for GitLab Rails and Sidekiq
   # Alternatively, you could configure it to deploy an HTTPRoute resource, if you prefer to deploy a Gateway API controller.
   #
   # For available network ingress and TLS configuration options, see:
   # https://docs.gitlab.com/charts/charts/openbao/#ingress-and-tls-configuration-options
   ingress:
     enabled: true
     hostname: "<OPENBAO_DOMAIN>"
   ```

1. 安装 OpenBao：

   ```shell
   helm upgrade --install openbao gitlab/openbao \
     --namespace openbao \
     --values openbao-values.yaml
   ```

有关所有可用的 chart 选项，请参阅
[OpenBao Helm chart 文档](https://gitlab.cn/docs/charts/charts/openbao/)。

{{< /tab >}}

{{< /tabs >}}

<a id="wait-for-openbao-to-become-ready"></a>

## 等待 OpenBao 就绪

等待滚动更新完成：

```shell
kubectl -n openbao rollout status deployment openbao
```

<a id="verify-the-installation"></a>

## 验证安装

要验证安装：

1. 验证 OpenBao 可访问：

   ```shell
   curl "https://openbao.example.com/v1/sys/health"
   ```

   成功的响应类似如下：

   ```json
   {
     "initialized": true,
     "sealed": false,
     "standby": false,
     "version": "2.0.0"
   }
   ```

1. [启用极狐GitLab 密钥管理器](../../ci/secrets/secrets_manager/_index.md#enable-gitlab-secrets-manager)。

<a id="security-hardening"></a>

## 安全加固

以下建议可帮助您在生产环境中使用 Linux 软件包运行 OpenBao 时降低风险。大多数底层控制措施取决于您的 Kubernetes 发行版及周边基础设施的选择，这些不由极狐GitLab 管理。

有关极狐GitLab 的一般加固建议，请参阅[极狐GitLab 加固建议](../../security/hardening.md)。

<a id="encrypt-traffic-between-components"></a>

### 加密组件之间的流量

在单主机的同主机集群安装中，Rails、Sidekiq、OpenBao 和 PostgreSQL 之间的流量保留在主机的共享网络上，不会暴露到主机之外。一旦拓扑跨越多台主机（例如外部集群或外部 PostgreSQL 实例），组件之间的未加密流量就会在网络上传输，并暴露给任何有权访问该网络的人。

请使用以下任一方式加密组件之间的流量，包括 OpenBao 到 PostgreSQL 的连接：

- 应用层 mTLS。
- 带负载均衡器卸载的 TLS。
- 专用的网络层。

在多节点拓扑中，加密适用于 Kubernetes pod、节点和 Linux 软件包节点之间的流量。请参阅您的 Kubernetes 发行版、CNI 和数据库文档，了解适用于您环境的配置步骤。

<a id="encrypt-the-kubernetes-datastore"></a>

### 加密 Kubernetes 数据存储

Kubernetes 数据存储（大多数发行版为 `etcd`）默认以未加密方式存储 Kubernetes `Secret` 对象。OpenBao Helm chart 将解封密钥存储为 Kubernetes `Secret`，因此数据存储一旦被攻破，就会暴露可访问整个 OpenBao 保管库的密钥。

请在您的发行版中为 Kubernetes 密钥启用静态加密。或者，使用密钥管理服务（KMS）配置 OpenBao 自动解封，使解封密钥不存储在 Kubernetes 密钥中。有关 chart 选项，请参阅
[OpenBao Helm chart 文档](https://gitlab.cn/docs/charts/charts/openbao/)。

<a id="restrict-pod-to-host-network-access"></a>

### 限制 pod 到主机的网络访问

Linux 软件包 PostgreSQL 会接受来自您在 `postgresql['md5_auth_cidr_addresses']` 中设置的整个 Kubernetes pod CIDR 的 TCP 连接。在该集群中调度的任何 pod（包括与 OpenBao 无关的工作负载）都可以访问共享网络上的 PostgreSQL 和 NGINX。只有应用层控制措施（例如 PostgreSQL 密码和 JWT 验证）才能保护这些服务不被其他 pod 访问。

要限制这种暴露：

- 如果集群与其他工作负载共享，请使用强制实施 Kubernetes `NetworkPolicy`的 CNI。某些发行版默认不强制实施 `NetworkPolicy`，包括使用默认 CNI 的 k3s。
- 将 `postgresql['md5_auth_cidr_addresses']` 缩小到覆盖 OpenBao pod 的最小 CIDR。

<a id="limit-kubernetes-api-server-exposure"></a>

### 限制 Kubernetes API 服务器的暴露

多个 Kubernetes 发行版默认将 API 服务器绑定到 `0.0.0.0`。暴露的 API 服务器提供了进入集群的直接路径，进而可访问 OpenBao。请将 API 服务器绑定到本地接口或共享网络 IP，并使用防火墙或安全组规则限制其可达性。
