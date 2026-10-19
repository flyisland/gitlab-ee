---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 如何设置 Consul
description: 配置 Consul 集群。
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

Consul 集群由
[服务器和客户端代理](https://developer.hashicorp.com/consul/docs/fundamentals/agent)组成。服务器运行在自己的节点上，客户端运行在其他节点上，这些客户端节点又与服务器通信。

极狐GitLab 专业版包含 [Consul](https://developer.hashicorp.com/consul)的捆绑版本，这是一种服务网络解决方案，您可以使用 `/etc/gitlab/gitlab.rb` 进行管理。

<a id="prerequisites"></a>

## 先决条件

在配置 Consul 之前：

1. 查看[参考架构](reference_architectures/_index.md#available-reference-architectures)
   文档，以确定您应拥有的 Consul 服务器节点数量。
1. 如有必要，请确保防火墙中已开放[相应的端口](package_information/defaults.md#ports)。

<a id="configure-the-consul-nodes"></a>

## 配置 Consul 节点

在每个 Consul 服务器节点上：

1. 按照说明选择您偏好的平台来[安装](https://gitlab.cn/install)
   极狐GitLab，但在询问时不要提供
   `EXTERNAL_URL` 值。
1. 编辑 `/etc/gitlab/gitlab.rb`，并替换 `retry_join` 部分中标注的值，
   添加以下内容。在下面的示例中，有三个节点，两个用其 IP 表示，一个用其 FQDN 表示。
   您可以使用任意一种表示法：

   ```ruby
   # Disable all components except Consul
   roles ['consul_role']

   # Consul nodes: can be FQDN or IP, separated by a whitespace
   consul['configuration'] = {
     server: true,
     retry_join: %w(10.10.10.1 consul1.gitlab.example.com 10.10.10.2)
   }

   # Disable auto migrations
   gitlab_rails['auto_migrate'] = false
   ```

1. [重新配置极狐GitLab](restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改
   生效。
1. 运行以下命令，以确保 Consul 配置正确，
   并验证所有服务器节点都在通信：

   ```shell
   sudo /opt/gitlab/embedded/bin/consul members
   ```

   输出应类似于：

   ```plaintext
   Node                 Address               Status  Type    Build  Protocol  DC
   CONSUL_NODE_ONE      XXX.XXX.XXX.YYY:8301  alive   server  0.9.2  2         gitlab_consul
   CONSUL_NODE_TWO      XXX.XXX.XXX.YYY:8301  alive   server  0.9.2  2         gitlab_consul
   CONSUL_NODE_THREE    XXX.XXX.XXX.YYY:8301  alive   server  0.9.2  2         gitlab_consul
   ```

   如果结果中显示任何节点的状态不是 `alive`，或者三个节点中有任何一个缺失，
   请参阅[故障排除部分](#troubleshooting-consul)。

<a id="securing-the-consul-nodes"></a>

## 保护 Consul 节点安全

您可以通过两种方式保护 Consul 节点之间的通信：使用 TLS 或 gossip 加密。

<a id="tls-encryption"></a>

### TLS 加密

默认情况下，Consul 集群未启用 TLS。默认配置选项及其默认值如下：

```ruby
consul['use_tls'] = false
consul['tls_ca_file'] = nil
consul['tls_certificate_file'] = nil
consul['tls_key_file'] = nil
consul['tls_verify_client'] = nil
```

这些配置选项同时适用于客户端和服务器节点。

要在 Consul 节点上启用 TLS，请从 `consul['use_tls'] = true` 开始。根据节点的角色（服务器或客户端）以及您的 TLS 偏好，您需要提供进一步的配置：

- 在服务器节点上，您至少必须指定 `tls_ca_file`、
  `tls_certificate_file` 和 `tls_key_file`。
- 在客户端节点上，当服务器上禁用了客户端 TLS 身份验证
  （默认启用）时，您至少必须指定 `tls_ca_file`，否则您必须
  使用 `tls_certificate_file`、
  `tls_key_file` 传递客户端 TLS 证书和密钥。

启用 TLS 后，默认情况下服务器使用 mTLS，并同时监听 HTTPS
和 HTTP（以及 TLS 和非 TLS RPC）。它期望客户端使用 TLS
身份验证。您可以通过设置 `consul['tls_verify_client'] = false` 来禁用客户端 TLS 身份验证。

另一方面，客户端仅对到服务器节点的出站连接使用 TLS，并且仅对传入请求监听 HTTP（和非 TLS RPC）。您可以通过将 `consul['https_port']` 设置为非负整数（`8501` 是 Consul 的默认 HTTPS 端口），强制客户端 Consul 代理对传入连接使用 TLS。您还必须传递 `tls_certificate_file` 和 `tls_key_file`，才能使其生效。当服务器节点使用客户端 TLS 身份验证时，客户端 TLS 证书和密钥将同时用于 TLS 身份验证和传入的 HTTPS 连接。

Consul 客户端节点默认不使用 TLS 客户端身份验证（与服务器相反），您需要通过设置 `consul['tls_verify_client'] = true` 明确指示它们这样做。

以下是一些 TLS 加密示例。

<a id="minimal-tls-support"></a>

#### 最小 TLS 支持

在以下示例中，服务器对传入连接使用 TLS（不使用客户端 TLS 身份验证）。

{{< tabs >}}

{{< tab title="Consul server 节点" >}}

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   consul['enable'] = true
   consul['configuration'] = {
     'server' => true
   }

   consul['use_tls'] = true
   consul['tls_ca_file'] = '/path/to/ca.crt.pem'
   consul['tls_certificate_file'] = '/path/to/server.crt.pem'
   consul['tls_key_file'] = '/path/to/server.key.pem'
   consul['tls_verify_client'] = false
   ```

1. 重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

{{< /tab >}}

{{< tab title="Consul client 节点" >}}

例如，可以在 Patroni 节点上配置以下内容。

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   consul['enable'] = true
   consul['use_tls'] = true
   consul['tls_ca_file'] = '/path/to/ca.crt.pem'
   patroni['consul']['url'] = 'http://localhost:8500'
   ```

1. 重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

Patroni 与本地 Consul 代理通信，而该代理对传入
连接不使用 TLS。因此 `patroni['consul']['url']` 使用 HTTP URL。

{{< /tab >}}

{{< /tabs >}}

<a id="default-tls-support"></a>

#### 默认 TLS 支持

在以下示例中，服务器使用双向 TLS 身份验证。

{{< tabs >}}

{{< tab title="Consul server 节点" >}}

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   consul['enable'] = true
   consul['configuration'] = {
     'server' => true
   }

   consul['use_tls'] = true
   consul['tls_ca_file'] = '/path/to/ca.crt.pem'
   consul['tls_certificate_file'] = '/path/to/server.crt.pem'
   consul['tls_key_file'] = '/path/to/server.key.pem'
   ```

1. 重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

{{< /tab >}}

{{< tab title="Consul client 节点" >}}

例如，可以在 Patroni 节点上配置以下内容。

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   consul['enable'] = true
   consul['use_tls'] = true
   consul['tls_ca_file'] = '/path/to/ca.crt.pem'
   consul['tls_certificate_file'] = '/path/to/client.crt.pem'
   consul['tls_key_file'] = '/path/to/client.key.pem'
   patroni['consul']['url'] = 'http://localhost:8500'
   ```

1. 重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

Patroni 与本地 Consul 代理通信，而该代理对传入
连接不使用 TLS，即使它对 Consul 服务器节点使用 TLS 身份验证。
因此 `patroni['consul']['url']` 使用 HTTP URL。

{{< /tab >}}

{{< /tabs >}}

<a id="full-tls-support"></a>

#### 完整 TLS 支持

在以下示例中，客户端和服务器都使用双向 TLS 身份验证。

Consul 服务器、客户端和 Patroni 客户端证书必须由同一个 CA 签发，双向 TLS 身份验证才能正常工作。

{{< tabs >}}

{{< tab title="Consul server 节点" >}}

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   consul['enable'] = true
   consul['configuration'] = {
     'server' => true
   }

   consul['use_tls'] = true
   consul['tls_ca_file'] = '/path/to/ca.crt.pem'
   consul['tls_certificate_file'] = '/path/to/server.crt.pem'
   consul['tls_key_file'] = '/path/to/server.key.pem'
   ```

1. 重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

{{< /tab >}}

{{< tab title="Consul client 节点" >}}

例如，可以在 Patroni 节点上配置以下内容。

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   consul['enable'] = true
   consul['use_tls'] = true
   consul['tls_verify_client'] = true
   consul['tls_ca_file'] = '/path/to/ca.crt.pem'
   consul['tls_certificate_file'] = '/path/to/client.crt.pem'
   consul['tls_key_file'] = '/path/to/client.key.pem'
   consul['https_port'] = 8501

   patroni['consul']['url'] = 'https://localhost:8501'
   patroni['consul']['cacert'] = '/path/to/ca.crt.pem'
   patroni['consul']['cert'] = '/opt/tls/patroni.crt.pem'
   patroni['consul']['key'] = '/opt/tls/patroni.key.pem'
   patroni['consul']['verify'] = true
   ```

1. 重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

{{< /tab >}}

{{< /tabs >}}

<a id="gossip-encryption"></a>

### Gossip 加密

可以加密 Gossip 协议，以保护 Consul 代理之间的通信。默认情况下未启用加密，要启用加密，需要一个共享加密密钥。为方便起见，可以使用 `gitlab-ctl consul keygen` 命令生成该密钥。密钥必须为 32 字节长、采用 Base 64 编码，并在所有代理之间共享。

以下选项在客户端和服务器节点上都有效。

要启用 gossip 协议：

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   consul['encryption_key'] = <base-64-key>
   consul['encryption_verify_incoming'] = true
   consul['encryption_verify_outgoing'] = true
   ```

1. 重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

要[在现有数据中心中启用加密](https://developer.hashicorp.com/consul/docs/security/encryption#enable-on-an-existing-consul-datacenter)，请手动设置这些选项以进行滚动更新。

<a id="upgrade-the-consul-nodes"></a>

## 升级 Consul 节点

要升级 Consul 节点，请升级极狐GitLab 软件包。

节点应满足：

- 在升级 Linux 软件包之前，是健康集群的成员。
- 一次升级一个节点。

在每个节点上运行以下命令，以识别集群中任何现有的健康问题。如果集群健康，该命令会返回一个空数组：

```shell
curl "http://127.0.0.1:8500/v1/health/state/critical"
```

如果 Consul 版本已更改，您会在 `gitlab-ctl reconfigure` 末尾看到一条通知，告知您必须重启 Consul 才能使用新版本。

一次重启一个节点的 Consul：

```shell
sudo gitlab-ctl restart consul
```

Consul 节点使用 raft 协议进行通信。如果当前领导者离线，就必须进行领导者选举。必须有一个领导者节点来促进集群内各节点的同步。如果同时有太多节点离线，集群将失去法定人数，并且由于[共识机制被破坏](https://developer.hashicorp.com/consul/docs/concept/consensus)而无法选举出领导者。

如果集群在升级后无法恢复，请查阅[故障排除部分](#troubleshooting-consul)。[中断恢复](#outage-recovery)可能特别有用。

极狐GitLab 使用 Consul 仅存储易于重新生成的临时数据。如果捆绑的 Consul 未被极狐GitLab 本身以外的任何进程使用，您可以[从头重建集群](#recreate-from-scratch)。

<a id="troubleshooting-consul"></a>

## 故障排除 Consul

以下是您在调试任何问题时可以执行的一些操作。您可以通过运行以下命令查看任何错误日志：

```shell
sudo gitlab-ctl tail consul
```

<a id="check-the-cluster-membership"></a>

### 检查集群成员资格

要确定哪些节点是集群的一部分，请在集群中的任何成员上运行以下命令：

```shell
sudo /opt/gitlab/embedded/bin/consul members
```

输出应类似于：

```plaintext
Node            Address               Status  Type    Build  Protocol  DC
consul-b        XX.XX.X.Y:8301        alive   server  0.9.0  2         gitlab_consul
consul-c        XX.XX.X.Y:8301        alive   server  0.9.0  2         gitlab_consul
consul-c        XX.XX.X.Y:8301        alive   server  0.9.0  2         gitlab_consul
db-a            XX.XX.X.Y:8301        alive   client  0.9.0  2         gitlab_consul
db-b            XX.XX.X.Y:8301        alive   client  0.9.0  2         gitlab_consul
```

理想情况下，所有节点的 `Status` 都为 `alive`。

<a id="restart-consul"></a>

### 重启 Consul

如果需要重启 Consul，重要的是以受控方式进行，以维持法定人数。如果失去法定人数，要恢复集群，请遵循 Consul 的[中断恢复](#outage-recovery)流程。

为安全起见，建议您一次只在一个节点上重启 Consul，以确保集群保持完整。对于较大的集群，可以一次重启多个节点。有关可容忍的故障数量，请参阅 [Consul 共识文档](https://developer.hashicorp.com/consul/docs/concept/consensus#quorum)。该数量即为其可承受的同时重启数。

要重启 Consul：

```shell
sudo gitlab-ctl restart consul
```

<a id="consul-nodes-unable-to-communicate"></a>

### Consul 节点无法通信

默认情况下，Consul 尝试[绑定](https://developer.hashicorp.com/consul/docs/agent/config/config-files#bind_addr)到 `0.0.0.0`，但它会通告节点上的第一个私有 IP 地址，供其他 Consul 节点与其通信。如果其他节点无法通过此地址与某个节点通信，则集群将处于失败状态。

如果遇到此问题，则 `gitlab-ctl tail consul`中会输出类似以下内容的消息：

```plaintext
2017-09-25_19:53:39.90821     2017/09/25 19:53:39 [WARN] raft: no known peers, aborting election
2017-09-25_19:53:41.74356     2017/09/25 19:53:41 [ERR] agent: failed to sync remote state: No cluster leader
```

要解决此问题：

1. 在每个节点上选择一个所有其他节点都能通过其访问该节点的地址。
1. 更新您的 `/etc/gitlab/gitlab.rb`

   ```ruby
   consul['configuration'] = {
     ...
     bind_addr: 'IP ADDRESS'
   }
   ```

1. 重新配置极狐GitLab；

   ```shell
   gitlab-ctl reconfigure
   ```

如果仍然看到这些错误，您可能需要在受影响的节点上[清除 Consul 数据库并重新初始化](#recreate-from-scratch)。

<a id="consul-does-not-start---multiple-private-ips"></a>

### Consul 无法启动 - 多个私有 IP

如果某个节点有多个私有 IP，Consul 不知道要通告哪个私有地址，然后它会在启动时立即退出。

`gitlab-ctl tail consul`中会输出类似以下内容的消息：

```plaintext
2017-11-09_17:41:45.52876 ==> Starting Consul agent...
2017-11-09_17:41:45.53057 ==> Error creating agent: Failed to get advertise address: Multiple private IPs found. Please configure one.
```

要解决此问题：

1. 在该节点上选择一个所有其他节点都能通过其访问该节点的地址。
1. 更新您的 `/etc/gitlab/gitlab.rb`

   ```ruby
   consul['configuration'] = {
     ...
     bind_addr: 'IP ADDRESS'
   }
   ```

1. 重新配置极狐GitLab；

   ```shell
   gitlab-ctl reconfigure
   ```

<a id="outage-recovery"></a>

### 中断恢复

如果集群中丢失了足够多的 Consul 节点以致法定人数被破坏，则该集群被视为已失败，没有人工干预就无法运行。在这种情况下，您可以从头重新创建节点，或尝试恢复。

<a id="recreate-from-scratch"></a>

#### 从头重新创建

默认情况下，极狐GitLab 不会在 Consul 节点中存储任何无法重新创建的内容。要清除 Consul 数据库并重新初始化：

```shell
sudo gitlab-ctl stop consul
sudo rm -rf /var/opt/gitlab/consul/data
sudo gitlab-ctl start consul
```

此后，该节点应重新启动，其余服务器代理会重新加入。不久之后，客户端代理也应重新加入。

如果它们没有加入，您可能还需要清除客户端上的 Consul 数据：

```shell
sudo rm -rf /var/opt/gitlab/consul/data
```

<a id="recover-a-failed-node"></a>

#### 恢复失败的节点

如果您利用 Consul 存储了其他数据，并希望恢复失败的节点，请遵循
[Consul 指南](https://developer.hashicorp.com/consul/tutorials/operate-consul/recovery-outage)
来恢复失败的集群。
