---
stage: Plan
group: Planner Intelligence
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: GitLab Pages 自编译安装的管理
description: 为自编译极狐GitLab 安装配置 GitLab Pages。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

> [!note]
> 在尝试开启 GitLab Pages 之前，请先确认您已成功
> [安装极狐GitLab](../../install/self_compiled/_index.md)。

本文档介绍如何为自编译极狐GitLab 安装配置 GitLab Pages。

有关为 Linux 软件包安装（推荐）配置 GitLab Pages 的更多信息，请参阅 [Linux 软件包文档](_index.md)。Linux 软件包安装包含
受支持的最新版 GitLab Pages。

<a id="gitlab-pages-daemon"></a>

## GitLab Pages 守护进程

GitLab Pages 使用 GitLab Pages 守护进程，这是一个
轻量级 HTTP 服务器，监听外部 IP 地址，并支持自定义域名和证书。它通过 `SNI` 支持动态证书，并默认使用 HTTP2 提供页面服务。更多信息，请参阅
[README](https://gitlab.com/gitlab-org/gitlab-pages/blob/master/README.md)。

对于[自定义域名](#custom-domains)，Pages 守护进程必须监听 `80` 或 `443` 端口。这不适用于[通配符域名](#wildcard-domains)。您可以通过以下方式之一设置 Pages 守护进程：

- 与极狐GitLab 位于同一服务器，监听辅助 IP。
- 位于单独的服务器。该服务器上还必须存在 [Pages 路径](#change-storage-path)，
  因此您必须通过网络共享它。
- 与极狐GitLab 位于同一服务器，监听同一 IP 但使用不同端口。在这种情况下，您
  必须使用负载均衡器代理流量。对于 HTTPS，请使用 TCP 负载均衡。如果您使用 TLS
  终止（HTTPS 负载均衡），则无法使用用户提供的证书提供页面服务。对于
  HTTP，使用 HTTP 或 TCP 负载均衡均可。

以下各节假设采用第一种方式。如果您不支持自定义域名，则不需要辅助
IP。

<a id="prerequisites"></a>

## 先决条件

在继续配置 Pages 之前，请确保：

- 您有一个单独的域名用于提供 GitLab Pages 服务。在本文档中，该域名为
  `example.io`。
- 您已为该域名配置了通配符 DNS 记录。
- 您已在安装极狐GitLab 的同一服务器上安装 `zip` 和 `unzip` 软件包。
  这些软件包是压缩和解压缩 Pages 产物所必需的。
- 可选。如果您决定通过 HTTPS 提供 Pages 服务，则需要一个 Pages 域名的通配符证书（`*.example.io`）。
- 可选但推荐。您已配置并开启
  [实例 Runner](../../ci/runners/_index.md)，这样您的用户就不必自带 Runner。

<a id="dns-configuration"></a>

### DNS 配置

GitLab Pages 必须运行在自己的虚拟主机上。在您的 DNS 服务器或提供商中，添加一条[通配符 DNS `A` 记录](https://en.wikipedia.org/wiki/Wildcard_DNS_record)，指向极狐GitLab 运行所在的主机。例如：

```plaintext
*.example.io. 1800 IN A 192.0.2.1
```

其中 `example.io` 是提供 GitLab Pages 服务的域名，`192.0.2.1` 是您的极狐GitLab 实例的 IP 地址。

> [!note]
> 不要使用极狐GitLab 域名来提供用户页面服务。更多信息，请参阅
> [安全部分](#security)。

<a id="configuration"></a>

## 配置

您可以通过多种方式设置 GitLab Pages。以下选项从最简单的设置到最复杂的设置依次列出。所有配置的最低要求是一条通配符 DNS 记录。

<a id="wildcard-domains"></a>

### 通配符域名

每个站点都有自己的子域名（例如 `<namespace>.example.io/<project_slug>`）。该子域名需要一条通配符 DNS 记录（`*.example.io`），这是大多数实例的推荐设置。

先决条件：

- [通配符 DNS 设置](#dns-configuration)

这是使用 Pages 的最低配置。它是下文所述所有其他设置的基础。NGINX 将所有请求代理到守护进程。Pages 守护进程不监听外部网络。

1. 安装 Pages 守护进程：

   ```shell
   cd /home/git
   sudo -u git -H git clone https://gitlab.com/gitlab-org/gitlab-pages.git
   cd gitlab-pages
   sudo -u git -H git checkout v$(</home/git/gitlab/GITLAB_PAGES_VERSION)
   sudo -u git -H make
   ```

1. 进入极狐GitLab 安装目录：

   ```shell
   cd /home/git/gitlab
   ```

1. 编辑 `gitlab.yml`，在 `pages` 设置下，将 `enabled` 设置为 `true`，并将
   `host` 设置为用于提供 GitLab Pages 服务的 FQDN：

   ```yaml
   ## GitLab Pages
   pages:
     enabled: true
     # The location where pages are stored (default: shared/pages).
     # path: shared/pages

     host: example.io
     access_control: false
     port: 8090
     https: false
     artifacts_server: false
     external_http: ["127.0.0.1:8090"]
     secret_file: /home/git/gitlab/gitlab-pages-secret
   ```

1. 将以下配置文件添加到 `/home/git/gitlab-pages/gitlab-pages.conf`。将
   `example.io` 替换为用于提供 GitLab Pages 服务的 FQDN，将 `gitlab.example.com` 替换为
   您的极狐GitLab 实例的 URL：

   ```ini
   listen-http=:8090
   pages-root=/home/git/gitlab/shared/pages
   api-secret-key=/home/git/gitlab/gitlab-pages-secret
   pages-domain=example.io
   internal-gitlab-server=https://gitlab.example.com
   ```

   当 GitLab Pages 和极狐GitLab 运行在同一主机上时，您可以使用 `http`地址。如果您使用
   带有自签名证书的 `https`，请使您的自定义 CA 对 GitLab Pages 可用，例如
   通过设置 `SSL_CERT_DIR` 环境变量。

1. 添加密钥 API 密钥：

   ```shell
   sudo -u git -H openssl rand -base64 32 > /home/git/gitlab/gitlab-pages-secret
   ```

1. 开启 Pages 守护进程：

   - 如果您的系统使用 systemd init，请运行：

     ```shell
     sudo systemctl edit gitlab.target
     ```

     在编辑器中添加以下内容并保存文件：

     ```plaintext
     [Unit]
     Wants=gitlab-pages.service
     ```

   - 如果您的系统使用 SysV init，请编辑 `/etc/default/gitlab`，将 `gitlab_pages_enabled` 设置为
     `true`：

     ```ini
     gitlab_pages_enabled=true
     ```

1. 复制 `gitlab-pages` NGINX 配置文件：

   ```shell
   sudo cp lib/support/nginx/gitlab-pages /etc/nginx/sites-available/gitlab-pages.conf
   sudo ln -sf /etc/nginx/sites-{available,enabled}/gitlab-pages.conf
   ```

1. 重启 NGINX。
1. [重启极狐GitLab](../restart_gitlab.md#self-compiled-installations)。

<a id="wildcard-domains-with-tls-support"></a>

### 支持 TLS 的通配符域名

先决条件：

- [通配符 DNS 设置](#dns-configuration)
- 通配符 TLS 证书

URL 方案：`https://<namespace>.example.io/<project_slug>`

NGINX 将所有请求代理到守护进程。Pages 守护进程不监听公共互联网。

要配置支持 TLS 的通配符域名：

1. 安装 Pages 守护进程：

   ```shell
   cd /home/git
   sudo -u git -H git clone https://gitlab.com/gitlab-org/gitlab-pages.git
   cd gitlab-pages
   sudo -u git -H git checkout v$(</home/git/gitlab/GITLAB_PAGES_VERSION)
   sudo -u git -H make
   ```

1. 在 `gitlab.yml`中，将 `port` 设置为 `443`，将 `https` 设置为 `true`：

   ```yaml
   ## GitLab Pages
   pages:
     enabled: true
     # The location where pages are stored (default: shared/pages).
     # path: shared/pages

     host: example.io
     port: 443
     https: true
   ```

1. 编辑 `/etc/default/gitlab`，将 `gitlab_pages_enabled` 设置为 `true`。在 `gitlab_pages_options`中，
   `-pages-domain` 必须与 `host` 值匹配。`-root-cert` 和 `-root-key` 设置是
   `example.io` 域名的通配符 TLS 证书：

   ```ini
   gitlab_pages_enabled=true
   gitlab_pages_options="-pages-domain example.io -pages-root $app_root/shared/pages -listen-proxy 127.0.0.1:8090 -root-cert /path/to/example.io.crt -root-key /path/to/example.io.key"
   ```

1. 复制 `gitlab-pages-ssl` NGINX 配置文件：

   ```shell
   sudo cp lib/support/nginx/gitlab-pages-ssl /etc/nginx/sites-available/gitlab-pages-ssl.conf
   sudo ln -sf /etc/nginx/sites-{available,enabled}/gitlab-pages-ssl.conf
   ```

1. 重启 NGINX。
1. [重启极狐GitLab](../restart_gitlab.md#self-compiled-installations)。

<a id="advanced-configuration"></a>

## 高级配置

除了通配符域名之外，您还可以配置 GitLab Pages 以使用自定义域名，无论是否使用 TLS 证书。

<a id="custom-domains"></a>

### 自定义域名

先决条件：

- [通配符 DNS 设置](#dns-configuration)
- 辅助 IP

URL 方案：`http://<namespace>.example.io/<project_slug>` 和 `http://custom-domain.com`

在此配置中，Pages 守护进程正在运行，NGINX 将请求代理到它，但该守护进程也可以接收来自公共互联网的请求。支持不带 TLS 的自定义域名。

要配置自定义域名：

1. 安装 Pages 守护进程：

   ```shell
   cd /home/git
   sudo -u git -H git clone https://gitlab.com/gitlab-org/gitlab-pages.git
   cd gitlab-pages
   sudo -u git -H git checkout v$(</home/git/gitlab/GITLAB_PAGES_VERSION)
   sudo -u git -H make
   ```

1. 编辑 `gitlab.yml`。将 `host` 设置为用于提供 GitLab Pages 服务的 FQDN，并将 `external_http` 设置为
   Pages 守护进程监听的辅助 IP：

   ```yaml
   pages:
     enabled: true
     # The location where pages are stored (default: shared/pages).
     # path: shared/pages

     host: example.io
     port: 80
     https: false

     external_http: 192.0.2.2:80
   ```

1. 编辑 `/etc/default/gitlab`，将 `gitlab_pages_enabled` 设置为 `true`。在 `gitlab_pages_options`中：

   - `-pages-domain` 必须与 `host` 匹配。
   - `-listen-http` 必须与 `external_http` 匹配。
   - `-listen-https` 必须与 `external_https` 匹配。

   ```ini
   gitlab_pages_enabled=true
   gitlab_pages_options="-pages-domain example.io -pages-root $app_root/shared/pages -listen-proxy 127.0.0.1:8090 -listen-http 192.0.2.2:80"
   ```

1. 复制 `gitlab-pages` NGINX 配置文件：

   ```shell
   sudo cp lib/support/nginx/gitlab-pages /etc/nginx/sites-available/gitlab-pages.conf
   sudo ln -sf /etc/nginx/sites-{available,enabled}/gitlab-pages.conf
   ```

1. 编辑 `/etc/nginx/site-available/` 中所有与极狐GitLab 相关的配置，将 `0.0.0.0`
   替换为 `192.0.2.1`，其中 `192.0.2.1` 是极狐GitLab 监听的主 IP。
1. 重启 NGINX。
1. [重启极狐GitLab](../restart_gitlab.md#self-compiled-installations)。

<a id="custom-domains-with-tls-support"></a>

### 支持 TLS 的自定义域名

先决条件：

- [通配符 DNS 设置](#dns-configuration)
- 通配符 TLS 证书
- 辅助 IP

URL 方案：`https://<namespace>.example.io/<project_slug>` 和 `https://custom-domain.com`

在此配置中，Pages 守护进程正在运行，NGINX 将请求代理到它，但该守护进程也可以接收来自公共互联网的请求。支持自定义域名和 TLS。

要配置支持 TLS 的自定义域名：

1. 安装 Pages 守护进程：

   ```shell
   cd /home/git
   sudo -u git -H git clone https://gitlab.com/gitlab-org/gitlab-pages.git
   cd gitlab-pages
   sudo -u git -H git checkout v$(</home/git/gitlab/GITLAB_PAGES_VERSION)
   sudo -u git -H make
   ```

1. 编辑 `gitlab.yml`。将 `host` 设置为用于提供 GitLab Pages 服务的 FQDN，并将 `external_http`
   和 `external_https` 设置为 Pages 守护进程监听的辅助 IP：

   ```yaml
   ## GitLab Pages
   pages:
     enabled: true
     # The location where pages are stored (default: shared/pages).
     # path: shared/pages

     host: example.io
     port: 443
     https: true

     external_http: 192.0.2.2:80
     external_https: 192.0.2.2:443
   ```

1. 编辑 `/etc/default/gitlab`，将 `gitlab_pages_enabled` 设置为 `true`。在 `gitlab_pages_options`中：

   - `-pages-domain` 必须与 `host` 匹配。
   - `-listen-http` 必须与 `external_http` 匹配。
   - `-listen-https` 必须与 `external_https` 匹配。

   `-root-cert` 和 `-root-key` 设置是 `example.io` 域名的通配符 TLS 证书：

   ```ini
   gitlab_pages_enabled=true
   gitlab_pages_options="-pages-domain example.io -pages-root $app_root/shared/pages -listen-proxy 127.0.0.1:8090 -listen-http 192.0.2.2:80 -listen-https 192.0.2.2:443 -root-cert /path/to/example.io.crt -root-key /path/to/example.io.key"
   ```

1. 复制 `gitlab-pages-ssl` NGINX 配置文件：

   ```shell
   sudo cp lib/support/nginx/gitlab-pages-ssl /etc/nginx/sites-available/gitlab-pages-ssl.conf
   sudo ln -sf /etc/nginx/sites-{available,enabled}/gitlab-pages-ssl.conf
   ```

1. 编辑 `/etc/nginx/site-available/` 中所有与极狐GitLab 相关的配置，将 `0.0.0.0`
   替换为 `192.0.2.1`，其中 `192.0.2.1` 是极狐GitLab 监听的主 IP。
1. 重启 NGINX。
1. [重启极狐GitLab](../restart_gitlab.md#self-compiled-installations)。

<a id="nginx-caveats"></a>

## NGINX 注意事项

> [!note]
> 以下信息仅适用于自编译安装。

在 NGINX 配置中设置域名时要小心。您不得移除反斜杠。

如果您的 GitLab Pages 域名是 `example.io`，请将：

```nginx
server_name ~^.*\.YOUR_GITLAB_PAGES\.DOMAIN$;
```

替换为：

```nginx
server_name ~^.*\.example\.io$;
```

如果您使用子域名，请用反斜杠（`\`）转义除第一个点（`.`）之外的所有点。例如，`pages.example.io` 应写为：

```nginx
server_name ~^.*\.pages\.example\.io$;
```

<a id="access-control"></a>

## 访问控制

GitLab Pages 访问控制可以按项目配置。对 Pages 站点的访问可以基于用户对该项目的成员资格进行控制。

访问控制的工作原理是将 Pages 守护进程注册为极狐GitLab 的 OAuth 应用程序。每当未认证用户请求访问私有 Pages 站点时，Pages 守护进程会将用户重定向到极狐GitLab。如果认证成功，用户会带着令牌被重定向回 Pages，该令牌会持久化在 cookie 中。这些 cookie 使用密钥签名，因此可以检测到篡改。

每次查看私有站点中资源的请求都由 Pages 使用该令牌进行认证。对于它接收到的每个请求，Pages 都会向极狐GitLab API 发出请求，以检查该用户是否有权读取该站点。

Pages 的访问控制参数：

- 通过名为
`gitlab-pages-config`的约定在配置文件中设置。
- 使用 `-config` 标志或 `CONFIG` 环境变量传递给 Pages。

Pages 访问控制默认关闭。要开启它：

1. 修改 `config/gitlab.yml`：

   ```yaml
   pages:
     access_control: true
   ```

1. [重启极狐GitLab](../restart_gitlab.md#self-compiled-installations)。
1. 创建一个新的
   [系统 OAuth 应用程序](../../integration/oauth_provider.md#create-a-user-owned-application)。
   将其命名为 `GitLab Pages`，并将 **Redirect URL** 设置为 `https://projects.example.io/auth`。它
   不需要是受信任的应用程序，但需要 `api` 范围。
1. 通过传入带有以下参数的配置文件来启动 Pages 守护进程：

   ```shell
     auth-client-id=<OAuth Application ID generated by GitLab>
     auth-client-secret=<OAuth code generated by GitLab>
     auth-redirect-uri='http://projects.example.io/auth'
     auth-secret=<40 random hex characters>
     auth-server=<URL of the GitLab instance>
   ```

1. 用户现在可以在其
   [项目设置](../../user/project/pages/pages_access_control.md)中进行配置。

<a id="change-storage-path"></a>

## 更改存储路径

要更改 GitLab Pages 内容的默认存储路径：

1. Pages 默认存储在 `/home/git/gitlab/shared/pages`。要使用其他位置，
   请编辑 `gitlab.yml`中的 `pages` 部分：

   ```yaml
   pages:
     enabled: true
     # The location where pages are stored (default: shared/pages).
     path: /mnt/storage/pages
   ```

1. [重启极狐GitLab](../restart_gitlab.md#self-compiled-installations)。

<a id="set-maximum-pages-size"></a>

## 设置 Pages 最大大小

每个项目解压后归档的默认最大大小为 100 MB。

先决条件：

- 管理员访问权限。

要更改此值：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **偏好设置**。
1. 展开 **Pages**。
1. 更新 **页面最大大小（MB）**的值。

<a id="backup"></a>

## 备份

Pages 是[常规备份](../backup_restore/_index.md)的一部分，因此无需配置。

<a id="security"></a>

## 安全

强烈建议您在与极狐GitLab 不同的主机名下运行 GitLab Pages，以防止 XSS 攻击。
