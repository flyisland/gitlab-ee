---
stage: Tenant Scale
group: Gitaly
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Gitaly TLS 支持
---

Gitaly 支持 TLS 加密。要与侦听安全连接的 Gitaly 实例通信，请在极狐GitLab 配置中相应存储条目的 `gitaly_address`中使用 `tls://` URL 方案。

Gitaly 在与极狐GitLab 的 TLS 连接中提供与客户端证书相同的服务器证书。当与验证客户端证书以授予极狐GitLab 访问权限的反向代理（例如 NGINX）结合使用时，这可以作为双向 TLS 身份验证策略的一部分。

您必须提供自己的证书，因为这些证书不会自动提供。每个 Gitaly 服务器对应的证书必须安装在该 Gitaly 服务器上。

此外，证书（或其证书颁发机构）必须安装在以下所有位置：

- Gitaly 服务器。
- 与其通信的 Gitaly 客户端。

如果您使用负载均衡器，它必须能够使用 ALPN TLS 扩展协商 HTTP/2。

<a id="certificate-requirements"></a>

## 证书要求

- 证书必须指定您用于访问 Gitaly 服务器的地址。您必须将主机名或 IP 地址作为主题备用名称添加到证书中。
- 您可以同时为 Gitaly 服务器配置未加密的侦听地址 `listen_addr` 和加密的侦听地址 `tls_listen_addr`。如有必要，这允许您从未加密流量逐步过渡到加密流量。
- 证书的 Common Name 字段会被忽略。

<a id="configure-gitaly-with-tls"></a>

## 为 Gitaly 配置 TLS

在配置 TLS 支持之前，请先[配置 Gitaly](configure_gitaly.md)。

配置 TLS 支持的过程取决于您的安装类型。

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

1. 为 Gitaly 服务器创建证书。
1. 在 Gitaly 客户端上，将证书（或其证书颁发机构）复制到
   `/etc/gitlab/trusted-certs`：

   ```shell
   sudo cp cert.pem /etc/gitlab/trusted-certs/
   ```

1. 在 Gitaly 客户端上，按如下方式编辑 `/etc/gitlab/gitlab.rb`中的 `gitlab_rails['repositories_storages']`：

   ```ruby
   gitlab_rails['repositories_storages'] = {
     'default' => { 'gitaly_address' => 'tls://gitaly1.internal:9999' },
     'storage1' => { 'gitaly_address' => 'tls://gitaly1.internal:9999' },
     'storage2' => { 'gitaly_address' => 'tls://gitaly2.internal:9999' },
   }
   ```

1. 保存文件并[重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation)。
1. 在 Gitaly 服务器上，创建 `/etc/gitlab/ssl` 目录并将您的密钥和证书复制到该目录：

   ```shell
   sudo mkdir -p /etc/gitlab/ssl
   sudo chmod 755 /etc/gitlab/ssl
   sudo cp key.pem cert.pem /etc/gitlab/ssl/
   sudo chmod 644 /etc/gitlab/ssl/cert.pem
   sudo chmod 600 /etc/gitlab/ssl/key.pem
   # For Linux package installations, 'git' is the default username. Modify the following command if it was changed from the default
   sudo chown -R git /etc/gitlab/ssl
   ```

1. 将所有 Gitaly 服务器证书（或其证书颁发机构）复制到所有 Gitaly 服务器和客户端上的
   `/etc/gitlab/trusted-certs`，
   以便 Gitaly 服务器和客户端在调用自身或其他 Gitaly 服务器时信任该证书：

   ```shell
   sudo cp cert1.pem cert2.pem /etc/gitlab/trusted-certs/
   ```

1. 编辑 `/etc/gitlab/gitlab.rb` 并添加：

   <!-- Updates to following example must also be made at <https://gitlab.com/gitlab-org/charts/gitlab/blob/master/doc/advanced/external-gitaly/external-omnibus-gitaly.md#configure-linux-package-installation> -->

   ```ruby
   gitaly['configuration'] = {
      # ...
      tls_listen_addr: '0.0.0.0:9999',
      tls: {
        certificate_path: '/etc/gitlab/ssl/cert.pem',
        key_path: '/etc/gitlab/ssl/key.pem',
        ## Optionally configure the minimum TLS version Gitaly offers to clients.
        ##
        ## Default: "TLS 1.2"
        ## Options: ["TLS 1.2", "TLS 1.3"].
        #
        # min_version: "TLS 1.2"
      },
   }
   ```

1. 保存文件并[重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation)。
1. 在 Gitaly 客户端（例如 Rails 应用程序）上运行 `sudo gitlab-rake gitlab:gitaly:check`，以确认它可以连接到 Gitaly 服务器。
1. 通过[观察 Gitaly 连接的类型](#observe-type-of-gitaly-connections)来验证 Gitaly 流量是否通过 TLS 提供服务。
1. 可选。通过以下方式提高安全性：
   1. 通过注释掉或删除 `/etc/gitlab/gitlab.rb`中的 `gitaly['configuration'][:listen_addr]` 来禁用非 TLS 连接。
   1. 保存文件。
   1. [重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation)。

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

1. 为 Gitaly 服务器创建证书。
1. 在 Gitaly 客户端上，将证书复制到系统信任的证书中：

   ```shell
   sudo cp cert.pem /usr/local/share/ca-certificates/gitaly.crt
   sudo update-ca-certificates
   ```

1. 在 Gitaly 客户端上，编辑 `/home/git/gitlab/config/gitlab.yml`中的 `storages`，将 `gitaly_address` 改为使用
   TLS 地址。例如：

   ```yaml
   gitlab:
     repositories:
       storages:
         default:
           gitaly_address: tls://gitaly1.internal:9999
           gitaly_token: AUTH_TOKEN_1
         storage1:
           gitaly_address: tls://gitaly1.internal:9999
           gitaly_token: AUTH_TOKEN_1
         storage2:
           gitaly_address: tls://gitaly2.internal:9999
           gitaly_token: AUTH_TOKEN_2
   ```

1. 保存文件并[重启极狐GitLab](../restart_gitlab.md#self-compiled-installations)。
1. 在 Gitaly 服务器上，创建或编辑 `/etc/default/gitlab` 并添加：

   ```shell
   export SSL_CERT_DIR=/etc/gitlab/ssl
   ```

1. 在 Gitaly 服务器上，创建 `/etc/gitlab/ssl` 目录并将您的密钥和证书复制到该目录：

   ```shell
   sudo mkdir -p /etc/gitlab/ssl
   sudo chmod 755 /etc/gitlab/ssl
   sudo cp key.pem cert.pem /etc/gitlab/ssl/
   sudo chmod 644 /etc/gitlab/ssl/cert.pem
   sudo chmod 600 /etc/gitlab/ssl/key.pem
   # Set ownership to the same user that runs Gitaly
   sudo chown -R git /etc/gitlab/ssl
   ```

1. 将所有 Gitaly 服务器证书（或其证书颁发机构）复制到系统信任的证书文件夹，以便 Gitaly 服务器在调用自身或其他 Gitaly
   服务器时信任该证书。

   ```shell
   sudo cp cert.pem /usr/local/share/ca-certificates/gitaly.crt
   sudo update-ca-certificates
   ```

1. 编辑 `/home/git/gitaly/config.toml` 并添加：

   ```toml
   tls_listen_addr = '0.0.0.0:9999'

   [tls]
   certificate_path = '/etc/gitlab/ssl/cert.pem'
   key_path = '/etc/gitlab/ssl/key.pem'
   ```

1. 保存文件并[重启极狐GitLab](../restart_gitlab.md#self-compiled-installations)。
1. 通过[观察 Gitaly 连接的类型](#observe-type-of-gitaly-connections)来验证 Gitaly 流量是否通过 TLS 提供服务。
1. 可选。通过以下方式提高安全性：
   1. 通过注释掉或删除 `/home/git/gitaly/config.toml`中的 `listen_addr` 来禁用非 TLS 连接。
   1. 保存文件。
   1. [重启极狐GitLab](../restart_gitlab.md#self-compiled-installations)。

{{< /tab >}}

{{< /tabs >}}

<a id="update-the-certificates"></a>

### 更新证书

要在初始配置后更新 Gitaly 证书：

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

如果 `/etc/gitlab/ssl` 目录下的 SSL 证书内容已更新，但未对
`/etc/gitlab/gitlab.rb` 进行配置更改，则重新配置极狐GitLab 不会影响 Gitaly。相反，您必须手动重启 Gitaly，以便 Gitaly 进程加载这些证书：

```shell
sudo gitlab-ctl restart gitaly
```

如果您更改或更新了 `/etc/gitlab/trusted-certs`中的证书，但未对 `/etc/gitlab/gitlab.rb` 文件进行更改，则必须：

1. [重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation)，以便更新受信任证书的符号链接。
1. 手动重启 Gitaly，以便 Gitaly 进程加载这些证书：

   ```shell
   sudo gitlab-ctl restart gitaly
   ```

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

如果 `/etc/gitlab/ssl` 目录下的 SSL 证书内容已更新，您必须
[重启极狐GitLab](../restart_gitlab.md#self-compiled-installations)，以便 Gitaly 进程加载这些证书。

如果您更改或更新了 `/usr/local/share/ca-certificates`中的证书，则必须：

1. 运行 `sudo update-ca-certificates` 以更新系统的信任存储。
1. [重启极狐GitLab](../restart_gitlab.md#self-compiled-installations)，以便 Gitaly 进程加载这些证书。

{{< /tab >}}

{{< /tabs >}}

<a id="observe-type-of-gitaly-connections"></a>

## 观察 Gitaly 连接的类型

有关观察所提供 Gitaly 连接类型的信息，请参阅[相关文档](monitoring.md#queries)。
