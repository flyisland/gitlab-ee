---
stage: Tenant Scale
group: Gitaly
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Gitaly TLS 支持
---

Gitaly 支持 TLS 加密。要通信于监听安全连接的 Gitaly 实例，在极狐GitLab 配置中相应存储条目的 `gitaly_address` 中使用 `tls://` URL 方案。

Gitaly 在到极狐GitLab 的 TLS 连接中，提供与客户端证书相同的服务器证书。这可以作为双向 TLS 认证策略的一部分，当与验证客户端证书以授予极狐GitLab 访问权限的反向代理（例如 NGINX）结合使用时。

您必须提供自己的证书，因为这不是自动提供的。每个 Gitaly 服务器对应的证书必须安装在该 Gitaly 服务器上。

此外，证书（或其证书颁发机构）必须安装在所有：

- Gitaly 服务器。
- 与之通信的 Gitaly 客户端。

如果您使用负载均衡器，它必须能够使用 ALPN TLS 扩展协商 HTTP/2。

<a id="certificate-requirements"></a>

## 证书要求

- 证书必须指定您用于访问 Gitaly 服务器的地址。您必须将主机名或 IP 地址作为主题备用名称添加到证书中。
- 您可以同时为 Gitaly 服务器配置未加密的监听地址 `listen_addr` 和加密的监听地址 `tls_listen_addr`。这允许您在必要时逐步从非加密流量过渡到加密流量。
- 证书的通用名称字段将被忽略。

<a id="configure-gitaly-with-tls"></a>

## 使用 TLS 配置 Gitaly

{{< history >}}

- 最低 TLS 版本配置选项在 极狐GitLab 17.11 引入。

{{< /history >}}

在配置 TLS 支持之前，[配置 Gitaly](configure_gitaly.md)。

配置 TLS 支持的过程取决于您的安装类型。

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

1. 为 Gitaly 服务器创建证书。
2. 在 Gitaly 客户端上，将证书（或其证书颁发机构）复制到 `/etc/极狐GitLab/trusted-certs`：

   ```shell
   sudo cp cert.pem /etc/极狐GitLab/trusted-certs/
   ```

3. 在 Gitaly 客户端上，编辑 `/etc/极狐GitLab/gitlab.rb` 中的 `gitlab_rails['repositories_storages']` 如下：

   ```ruby
   gitlab_rails['repositories_storages'] = {
     'default' => { 'gitaly_address' => 'tls://gitaly1.internal:9999' },
     'storage1' => { 'gitaly_address' => 'tls://gitaly1.internal:9999' },
     'storage2' => { 'gitaly_address' => 'tls://gitaly2.internal:9999' },
   }
   ```

4. 保存文件并[重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation)。
5. 在 Gitaly 服务器上，创建 `/etc/极狐GitLab/ssl` 目录并将密钥和证书复制到那里：

   ```shell
   sudo mkdir -p /etc/极狐GitLab/ssl
   sudo chmod 755 /etc/极狐GitLab/ssl
   sudo cp key.pem cert.pem /etc/极狐GitLab/ssl/
   sudo chmod 644 /etc/极狐GitLab/ssl/cert.pem
   sudo chmod 600 /etc/极狐GitLab/ssl/key.pem
   # 对于 Linux 软件包安装，'git' 是默认用户名。如果默认值已更改，请修改以下命令
   sudo chown -R git /etc/极狐GitLab/ssl
   ```

6. 将所有 Gitaly 服务器证书（或其证书颁发机构）复制到所有 Gitaly 服务器和客户端上的 `/etc/极狐GitLab/trusted-certs`，以便 Gitaly 服务器和客户端在调用自身或其他 Gitaly 服务器时信任该证书：

   ```shell
   sudo cp cert1.pem cert2.pem /etc/极狐GitLab/trusted-certs/
   ```

7. 编辑 `/etc/极狐GitLab/gitlab.rb` 并添加：

   <!-- Updates to following example must also be made at <https://gitlab.com/gitlab-org/charts/gitlab/blob/master/doc/advanced/external-gitaly/external-omnibus-gitaly.md#configure-linux-package-installation> -->

   ```ruby
   gitaly['configuration'] = {
      # ...
      tls_listen_addr: '0.0.0.0:9999',
      tls: {
        certificate_path: '/etc/极狐GitLab/ssl/cert.pem',
        key_path: '/etc/极狐GitLab/ssl/key.pem',
        ## 可选配置 Gitaly 提供给客户端的最低 TLS 版本。
        ##
        ## 默认："TLS 1.2"
        ## 选项：["TLS 1.2", "TLS 1.3"]。
        #
        # min_version: "TLS 1.2"
      },
   }
   ```

8. 保存文件并[重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation)。
9. 在 Gitaly 客户端（例如 Rails 应用程序）上运行 `sudo 极狐GitLab-rake 极狐GitLab:gitaly:check` 以确认它可以连接到 Gitaly 服务器。
10. 通过[观察 Gitaly 连接的类型](#observe-type-of-gitaly-connections)验证 Gitaly 流量是否通过 TLS 提供服务。
11. 可选。通过以下方式提高安全性：
    1. 通过注释掉或删除 `/etc/极狐GitLab/gitlab.rb` 中的 `gitaly['configuration'][:listen_addr]` 来禁用非 TLS 连接。
    2. 保存文件。
    3. [重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation)。

{{< /tab >}}

{{< tab title="自编译（源代码）" >}}

1. 为 Gitaly 服务器创建证书。
2. 在 Gitaly 客户端上，将证书复制到系统受信任的证书中：

   ```shell
   sudo cp cert.pem /usr/local/share/ca-certificates/gitaly.crt
   sudo update-ca-certificates
   ```

3. 在 Gitaly 客户端上，编辑 `/home/git/极狐GitLab/config/极狐GitLab.yml` 中的 `storages`，将 `gitaly_address` 更改为使用 TLS 地址。例如：

   ```yaml
   极狐GitLab:
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

4. 保存文件并[重启极狐GitLab](../restart_gitlab.md#self-compiled-installations)。
5. 在 Gitaly 服务器上，创建或编辑 `/etc/default/极狐GitLab` 并添加：

   ```shell
   export SSL_CERT_DIR=/etc/极狐GitLab/ssl
   ```

6. 在 Gitaly 服务器上，创建 `/etc/极狐GitLab/ssl` 目录并将密钥和证书复制到那里：

   ```shell
   sudo mkdir -p /etc/极狐GitLab/ssl
   sudo chmod 755 /etc/极狐GitLab/ssl
   sudo cp key.pem cert.pem /etc/极狐GitLab/ssl/
   sudo chmod 644 /etc/极狐GitLab/ssl/cert.pem
   sudo chmod 600 /etc/极狐GitLab/ssl/key.pem
   # 将所有权设置为运行 Gitaly 的同一用户
   sudo chown -R git /etc/极狐GitLab/ssl
   ```

7. 将所有 Gitaly 服务器证书（或其证书颁发机构）复制到系统受信任的证书文件夹，以便 Gitaly 服务器在调用自身或其他 Gitaly 服务器时信任该证书。

   ```shell
   sudo cp cert.pem /usr/local/share/ca-certificates/gitaly.crt
   sudo update-ca-certificates
   ```

8. 编辑 `/home/git/gitaly/config.toml` 并添加：

   ```toml
   tls_listen_addr = '0.0.0.0:9999'

   [tls]
   certificate_path = '/etc/极狐GitLab/ssl/cert.pem'
   key_path = '/etc/极狐GitLab/ssl/key.pem'
   ```

9. 保存文件并[重启极狐GitLab](../restart_gitlab.md#self-compiled-installations)。
10. 通过[观察 Gitaly 连接的类型](#observe-type-of-gitaly-connections)验证 Gitaly 流量是否通过 TLS 提供服务。
11. 可选。通过以下方式提高安全性：
    1. 通过注释掉或删除 `/home/git/gitaly/config.toml` 中的 `listen_addr` 来禁用非 TLS 连接。
    2. 保存文件。
    3. [重启极狐GitLab](../restart_gitlab.md#self-compiled-installations)。

{{< /tab >}}

{{< /tabs >}}

<a id="update-the-certificates"></a>

### 更新证书

要在初始配置后更新 Gitaly 证书：

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

如果 `/etc/极狐GitLab/ssl` 目录下的 SSL 证书内容已更新，但未对 `/etc/极狐GitLab/gitlab.rb` 进行任何配置更改，则重新配置极狐GitLab 不会影响 Gitaly。相反，您必须手动重启 Gitaly，以便 Gitaly 进程加载证书：

```shell
sudo 极狐GitLab-ctl restart gitaly
```

如果您更改或更新 `/etc/极狐GitLab/trusted-certs` 中的证书，而未更改 `/etc/极狐GitLab/gitlab.rb` 文件，您必须：

1. [重新配置极狐GitLab](../restart_gitlab.md#reconfigure-a-linux-package-installation)，以便更新受信任证书的符号链接。
2. 手动重启 Gitaly，以便 Gitaly 进程加载证书：

   ```shell
   sudo 极狐GitLab-ctl restart gitaly
   ```

{{< /tab >}}

{{< tab title="自编译（源代码）" >}}

如果 `/etc/极狐GitLab/ssl` 目录下的 SSL 证书内容已更新，您必须[重启极狐GitLab](../restart_gitlab.md#self-compiled-installations)，以便 Gitaly 进程加载证书。

如果您更改或更新 `/usr/local/share/ca-certificates` 中的证书，您必须：

1. 运行 `sudo update-ca-certificates` 以更新系统的受信任存储。
2. [重启极狐GitLab](../restart_gitlab.md#self-compiled-installations)，以便 Gitaly 进程加载证书。

{{< /tab >}}

{{< /tabs >}}

<a id="observe-type-of-gitaly-connections"></a>

## 观察 Gitaly 连接的类型

有关观察所提供 Gitaly 连接类型的信息，请参阅[相关文档](monitoring.md#queries)。

