---
stage: Plan
group: Knowledge
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab Pages 自编译安装管理
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

> [!note]
> 在尝试启用极狐GitLab Pages 之前，请先确认您已[成功安装极狐GitLab](../../install/self_compiled/_index.md)。

本文档介绍如何为自编译的极狐GitLab 安装配置极狐GitLab Pages。

有关为 Linux 软件包安装（推荐）配置极狐GitLab Pages 的更多信息，请参见 [Linux 软件包文档](_index.md)。Linux 软件包安装包含最新支持的极狐GitLab Pages 版本。

<a id="how-gitlab-pages-works"></a>

## 极狐GitLab Pages 工作原理

极狐GitLab Pages 使用极狐GitLab Pages 守护进程，这是一个轻量级 HTTP 服务器，监听外部 IP 地址，并支持自定义域和证书。它通过 `SNI` 支持动态证书，并默认使用 HTTP2 提供页面服务。更多信息请参见 [README](https://jihulab.com/gitlab-cn/gitlab-pages/blob/master/README.md)。

对于[自定义域](#custom-domains)，Pages 守护进程必须监听 `80` 或 `443` 端口。
这不适用于[通配符域](#wildcard-domains)。
您可以通过以下方式之一进行设置：

- 与极狐GitLab 运行在同一服务器上，监听辅助 IP。
- 运行在单独的服务器上。此时 [Pages 路径](#change-storage-path)也必须在该服务器上存在，因此必须通过网络共享。
- 与极狐GitLab 运行在同一服务器上，使用相同 IP 但不同端口。此时必须使用负载均衡器代理流量。对于 HTTPS，请使用 TCP 负载均衡。如果使用 TLS 终止（HTTPS 负载均衡），则无法使用用户提供的证书提供页面服务。对于 HTTP，HTTP 或 TCP 负载均衡均可。

以下章节假设采用第一种方式。如果您不支持自定义域，则不需要辅助 IP。

<a id="prerequisites"></a>

## 准备工作

在继续 Pages 配置之前，请确保：

- 您有一个单独的域来提供极狐GitLab Pages 服务。在本文档中，此域为 `example.io`。
- 您已为该域配置了**通配符 DNS 记录**。
- 您已在安装极狐GitLab 的同一服务器上安装了 `zip` 和 `unzip` 软件包。这些软件包用于压缩和解压 Pages 产物。
- 可选。如果您决定通过 HTTPS 提供 Pages 服务，请准备好 Pages 域的**通配符证书**（`*.example.io`）。
- 可选但推荐。您已配置并启用[实例 Runner](../../ci/runners/_index.md)，这样用户无需自带 Runner。

<a id="dns-configuration"></a>

### DNS 配置

极狐GitLab Pages 必须运行在自己的虚拟主机上。在您的 DNS 服务器或提供商中，添加一条指向极狐GitLab 运行主机的[通配符 DNS `A` 记录](https://en.wikipedia.org/wiki/Wildcard_DNS_record)。例如：

```plaintext
*.example.io. 1800 IN A 192.0.2.1
```

其中 `example.io` 是提供极狐GitLab Pages 服务的域，`192.0.2.1` 是您的极狐GitLab 实例的 IP 地址。

> [!note]
> 不要使用极狐GitLab 域来提供用户页面。更多信息请参见[安全章节](#security)。

<a id="configuration"></a>

## 配置

您可以通过多种方式设置极狐GitLab Pages。以下选项从最简单的设置到最高级的设置依次列出。所有配置的最低要求是一条通配符 DNS 记录。

<a id="wildcard-domains"></a>

### 通配符域

每个站点都会分配到自己的子域（例如 `<namespace>.example.io/<project_slug>`）。
该子域需要一条通配符 DNS 记录（`*.example.io`），这也是大多数实例推荐使用的设置。

准备工作：

- [通配符 DNS 设置](#dns-configuration)

这是使用 Pages 所需的最简设置，也是下述其他所有设置的基础。NGINX 将所有请求代理到守护进程。
Pages 守护进程不直接监听外部网络。

1. 安装 Pages 守护进程：

   ```shell
   cd /home/git
   sudo -u git -H git clone https://jihulab.com/gitlab-cn/gitlab-pages.git
   cd gitlab-pages
   sudo -u git -H git checkout v$(</home/git/gitlab/GITLAB_PAGES_VERSION)
   sudo -u git -H make
   ```

1. 进入极狐GitLab 安装目录：

   ```shell
   cd /home/git/gitlab
   ```

1. 编辑 `gitlab.yml`，在 `pages` 设置下，将 `enabled` 设为 `true`，并将 `host` 设为提供极狐GitLab Pages 服务的完整域名：

   ```yaml
   ## GitLab Pages
   pages:
     enabled: true
     # 存储页面的位置（默认：shared/pages）。
     # path: shared/pages

     host: example.io
     access_control: false
     port: 8090
     https: false
     artifacts_server: false
     external_http: ["127.0.0.1:8090"]
     secret_file: /home/git/gitlab/gitlab-pages-secret
   ```

1. 将以下配置文件添加到 `/home/git/gitlab-pages/gitlab-pages.conf`。将 `example.io` 替换为提供极狐GitLab Pages 服务的完整域名，将 `gitlab.example.com` 替换为您的极狐GitLab 实例的 URL：

   ```ini
   listen-http=:8090
   pages-root=/home/git/gitlab/shared/pages
   api-secret-key=/home/git/gitlab/gitlab-pages-secret
   pages-domain=example.io
   internal-gitlab-server=https://gitlab.example.com
   ```

   当极狐GitLab Pages 和极狐GitLab 运行在同一主机上时，您可以使用 `http` 地址。如果您使用自签名证书的 `https`，请确保极狐GitLab Pages 可以访问您的自定义 CA，例如通过设置 `SSL_CERT_DIR` 环境变量。

1. 添加密钥 API 密钥：

   ```shell
   sudo -u git -H openssl rand -base64 32 > /home/git/gitlab/gitlab-pages-secret
   ```

1. 启用 Pages 守护进程：

   - 如果您的系统使用 systemd init，请运行：

     ```shell
     sudo systemctl edit gitlab.target
     ```

     在编辑器中添加以下内容并保存文件：

     ```plaintext
     [Unit]
     Wants=gitlab-pages.service
     ```

   - 如果您的系统使用 SysV init，请编辑 `/etc/default/gitlab`，将 `gitlab_pages_enabled` 设置为 `true`：

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

### 支持 TLS 的通配符域

准备工作：

- [通配符 DNS 设置](#dns-configuration)
- 通配符 TLS 证书

URL 模式：`https://<namespace>.example.io/<project_slug>`

NGINX 将所有请求代理到守护进程。Pages 守护进程不直接监听公共网络。

要配置支持 TLS 的通配符域：

1. 安装 Pages 守护进程：

   ```shell
   cd /home/git
   sudo -u git -H git clone https://jihulab.com/gitlab-cn/gitlab-pages.git
   cd gitlab-pages
   sudo -u git -H git checkout v$(</home/git/gitlab/GITLAB_PAGES_VERSION)
   sudo -u git -H make
   ```

1. 在 `gitlab.yml` 中，将 `port` 设置为 `443`，`https` 设置为 `true`：

   ```yaml
   ## GitLab Pages
   pages:
     enabled: true
     # 存储页面的位置（默认：shared/pages）。
     # path: shared/pages

     host: example.io
     port: 443
     https: true
   ```

1. 编辑 `/etc/default/gitlab`，将 `gitlab_pages_enabled` 设置为 `true`。在 `gitlab_pages_options` 中，`-pages-domain` 必须与 `host` 值匹配。`-root-cert` 和 `-root-key` 设置是 `example.io` 域的通配符 TLS 证书：

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

除了通配符域，您还可以配置极狐GitLab Pages 以支持带有或不带 TLS 证书的自定义域。

<a id="custom-domains"></a>

### 自定义域

准备工作：

- [通配符 DNS 设置](#dns-configuration)
- 辅助 IP

URL 模式：`http://<namespace>.example.io/<project_slug>` 和 `http://custom-domain.com`

在此配置中，Pages 守护进程正在运行，NGINX 将请求代理给它，但守护进程也可以接收来自公共网络的请求。支持自定义域，但不包含 TLS。

要配置自定义域：

1. 安装 Pages 守护进程：

   ```shell
   cd /home/git
   sudo -u git -H git clone https://jihulab.com/gitlab-cn/gitlab-pages.git
   cd gitlab-pages
   sudo -u git -H git checkout v$(</home/git/gitlab/GITLAB_PAGES_VERSION)
   sudo -u git -H make
   ```

1. 编辑 `gitlab.yml`。将 `host` 设置为提供极狐GitLab Pages 服务的完整域名，并将 `external_http` 设置为 Pages 守护进程监听的辅助 IP：

   ```yaml
   pages:
     enabled: true
     # 存储页面的位置（默认：shared/pages）。
     # path: shared/pages

     host: example.io
     port: 80
     https: false

     external_http: 192.0.2.2:80
   ```

1. 编辑 `/etc/default/gitlab`，将 `gitlab_pages_enabled` 设置为 `true`。在 `gitlab_pages_options` 中：

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

1. 编辑 `/etc/nginx/site-available/` 中所有与极狐GitLab 相关的配置，将 `0.0.0.0` 替换为 `192.0.2.1`，其中 `192.0.2.1` 是极狐GitLab 监听的主 IP。
1. 重启 NGINX。
1. [重启极狐GitLab](../restart_gitlab.md#self-compiled-installations)。

<a id="custom-domains-with-tls-support"></a>

### 支持 TLS 的自定义域

准备工作：

- [通配符 DNS 设置](#dns-configuration)
- 通配符 TLS 证书
- 辅助 IP

URL 模式：`https://<namespace>.example.io/<project_slug>` 和 `https://custom-domain.com`

在此配置中，Pages 守护进程正在运行，NGINX 将请求代理给它，但守护进程也可以接收来自公共网络的请求。支持自定义域和 TLS。

要配置支持 TLS 的自定义域：

1. 安装 Pages 守护进程：

   ```shell
   cd /home/git
   sudo -u git -H git clone https://jihulab.com/gitlab-cn/gitlab-pages.git
   cd gitlab-pages
   sudo -u git -H git checkout v$(</home/git/gitlab/GITLAB_PAGES_VERSION)
   sudo -u git -H make
   ```

1. 编辑 `gitlab.yml`。将 `host` 设置为提供极狐GitLab Pages 服务的完整域名，并将 `external_http` 和 `external_https` 设置为 Pages 守护进程监听的辅助 IP：

   ```yaml
   ## GitLab Pages
   pages:
     enabled: true
     # 存储页面的位置（默认：shared/pages）。
     # path: shared/pages

     host: example.io
     port: 443
     https: true

     external_http: 192.0.2.2:80
     external_https: 192.0.2.2:443
   ```

1. 编辑 `/etc/default/gitlab`，将 `gitlab_pages_enabled` 设置为 `true`。在 `gitlab_pages_options` 中：

   - `-pages-domain` 必须与 `host` 匹配。
   - `-listen-http` 必须与 `external_http` 匹配。
   - `-listen-https` 必须与 `external_https` 匹配。

   `-root-cert` 和 `-root-key` 设置是 `example.io` 域的通配符 TLS 证书：

   ```ini
   gitlab_pages_enabled=true
   gitlab_pages_options="-pages-domain example.io -pages-root $app_root/shared/pages -listen-proxy 127.0.0.1:8090 -listen-http 192.0.2.2:80 -listen-https 192.0.2.2:443 -root-cert /path/to/example.io.crt -root-key /path/to/example.io.key"
   ```

1. 复制 `gitlab-pages-ssl` NGINX 配置文件：

   ```shell
   sudo cp lib/support/nginx/gitlab-pages-ssl /etc/nginx/sites-available/gitlab-pages-ssl.conf
   sudo ln -sf /etc/nginx/sites-{available,enabled}/gitlab-pages-ssl.conf
   ```

1. 编辑 `/etc/nginx/site-available/` 中所有与极狐GitLab 相关的配置，将 `0.0.0.0` 替换为 `192.0.2.1`，其中 `192.0.2.1` 是极狐GitLab 监听的主 IP。
1. 重启 NGINX。
1. [重启极狐GitLab](../restart_gitlab.md#self-compiled-installations)。

<a id="nginx-caveats"></a>

## NGINX 注意事项

> [!note]
> 以下信息仅适用于自编译安装。

在 NGINX 配置中设置域名时请务必小心。请勿移除反斜杠。

如果您的极狐GitLab Pages 域为 `example.io`，请将：

```nginx
server_name ~^.*\.YOUR_GITLAB_PAGES\.DOMAIN$;
```

替换为：

```nginx
server_name ~^.*\.example\.io$;
```

如果使用子域，请用反斜杠（`\`）转义除第一个点之外的所有点（`.`）。例如 `pages.example.io` 应为：

```nginx
server_name ~^.*\.pages\.example\.io$;
```

<a id="access-control"></a>

## 访问控制

极狐GitLab Pages 访问控制可以按项目配置。对 Pages 站点的访问可以基于用户对该项目的成员资格进行控制。

访问控制的原理是将 Pages 守护进程注册为极狐GitLab 的 OAuth 应用程序。当未认证的用户请求访问私有 Pages 站点时，Pages 守护进程会将用户重定向至极狐GitLab。如果认证成功，用户会带着一个令牌被重定向回 Pages，该令牌会持久保存在 Cookie 中。Cookie 使用密钥进行签名，因此可以检测篡改。

每个查看私有站点资源的请求都会由 Pages 使用该令牌进行认证。对于收到的每个请求，Pages 都会向极狐GitLab API 发起请求，以检查用户是否有权读取该站点。

Pages 的访问控制参数：

- 通过约定命名为 `gitlab-pages-config` 的配置文件进行设置。
- 使用 `-config` 标志或 `CONFIG` 环境变量传递给 Pages。

Pages 访问控制默认禁用。要启用它：

1. 修改 `config/gitlab.yml`：

   ```yaml
   pages:
     access_control: true
   ```

1. [重启极狐GitLab](../restart_gitlab.md#self-compiled-installations)。
1. 创建一个新的[系统 OAuth 应用程序](../../integration/oauth_provider.md#create-a-user-owned-application)。将其命名为 `GitLab Pages`，并将 **Redirect URL** 设置为 `https://projects.example.io/auth`。它不需要是可信应用程序，但需要 `api` 作用域。
1. 通过传递包含以下参数的配置文件来启动 Pages 守护进程：

   ```shell
     auth-client-id=<极狐GitLab 生成的 OAuth 应用程序 ID>
     auth-client-secret=<极狐GitLab 生成的 OAuth 代码>
     auth-redirect-uri='http://projects.example.io/auth'
     auth-secret=<40 个随机十六进制字符>
     auth-server=<极狐GitLab 实例的 URL>
   ```

1. 用户现在可以在其[项目设置](../../user/project/pages/pages_access_control.md)中进行配置。

<a id="change-storage-path"></a>

## 更改存储路径

要更改极狐GitLab Pages 内容的默认存储路径：

1. Pages 默认存储在 `/home/git/gitlab/shared/pages`。要使用其他位置，请编辑 `gitlab.yml` 中 `pages` 部分：

   ```yaml
   pages:
     enabled: true
     # 存储页面的位置（默认：shared/pages）。
     path: /mnt/storage/pages
   ```

1. [重启极狐GitLab](../restart_gitlab.md#self-compiled-installations)。

<a id="set-maximum-pages-size"></a>

## 设置最大 Pages 大小

每个项目解压后的归档文件的默认最大大小为 100 MB。

准备工作：

- 管理员访问权限。

要更改此值：

1. 在右上角选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **偏好设置**。
1. 展开 **Pages**。
1. 更新 **页面最大大小（MB）** 的值。

<a id="backup"></a>

## 备份

Pages 包含在[常规备份](../backup_restore/_index.md)中，因此无需额外配置。

<a id="security"></a>

## 安全

您应强烈考虑将极狐GitLab Pages 运行在与极狐GitLab 不同的主机名下，以防止 XSS 攻击。