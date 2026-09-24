---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 如何设置 Consul
description: 配置一个 Consul 集群。
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

一个 Consul 集群由 [server 和 client agents](https://developer.hashicorp.com/consul/docs/agent) 组成。server 运行在自己的节点上，client 运行在其它节点上，并进而与 server 通信。

极狐GitLab 专业版包含了一个捆绑版本的 [Consul](https://www.consul.io/)，这是一个服务网络解决方案，你可以通过使用 `/etc/gitlab/gitlab.rb` 进行管理。

## 先决条件

在配置 Consul 之前：

1. 查看 [参考架构](reference_architectures/_index.md#available-reference-architectures) 文档，以确定你应该拥有的 Consul server 节点数量。
1. 如有必要，确保你的防火墙中 [开放了相应的端口](package_information/defaults.md#ports)。

## 配置 Consul 节点

在每个 Consul server 节点上：

1. 按照 [安装](https://gitlab.cn/install/) 极狐GitLab 的说明，选择你偏好的平台，但在询问时不要提供 `EXTERNAL_URL` 值。
1. 编辑 `/etc/gitlab/gitlab.rb`，并添加以下内容，替换 `retry_join` 部分中标注的值。在下面的示例中，有三个节点，两个用其 IP 表示，一个用其 FQDN 表示，你可以使用任何一种表示法：

   ```ruby
   # 禁用除 Consul 之外的所有组件
   roles ['consul_role']

   # Consul 节点：可以是 FQDN 或 IP，用空格分隔
   consul['configuration'] = {
     server: true,
     retry_join: %w(10.10.10.1 consul1.gitlab.example.com 10.10.10.2)
   }

   # 禁用自动迁移
   gitlab_rails['auto_migrate'] = false
   ```

1. [重新配置极狐GitLab](restart_gitlab.md#reconfigure-a-linux-package-installation) 以使更改生效。
1. 运行以下命令以确保 Consul 已正确配置，并验证所有 server 节点都在通信：

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

   如果结果显示任何节点的状态不是 `alive`，或者三个节点中有任何一个缺失，请参阅 [疑难解答部分](#troubleshooting-consul)。

## 保护 Consul 节点

有两种方法可以保护 Consul 节点之间的通信，使用 TLS 或 Gossip 加密。

### TLS 加密

默认情况下，Consul 集群未启用 TLS，默认配置选项及其默认值为：

```ruby
consul['use_tls'] = false
consul['tls_ca_file'] = nil
consul['tls_certificate_file'] = nil
consul['tls_key_file'] = nil
consul['tls_verify_client'] = nil
```

这些配置选项同时适用于 client 和 server 节点。

要在 Consul 节点上启用 TLS，请从 `consul['use_tls'] = true` 开始。根据节点的角色（server 或 client）和你的 TLS 偏好，你需要提供进一步的配置：

- 在 server 节点上，你必须至少指定 `tls_ca_file`、`tls_certificate_file` 和 `tls_key_file`。
- 在 client 节点上，当 server 上禁用了 client TLS 认证（默认启用）时，你必须至少指定 `tls_ca_file`，否则你必须使用 `tls_certificate_file`、`tls_key_file` 传递 client TLS 证书和密钥。

当 TLS 启用时，默认情况下 server 使用 mTLS 并同时监听 HTTPS 和 HTTP（以及 TLS 和非 TLS RPC）。它期望 client 使用 TLS 认证。你可以通过设置 `consul['tls_verify_client'] = false` 来禁用 client TLS 认证。

另一方面，client 仅对到 server 节点的传出连接使用 TLS，并且仅监听 HTTP（和非 TLS RPC）以处理传入请求。你可以通过将 `consul['https_port']` 设置为一个非负整数（`8501` 是 Consul 的默认 HTTPS 端口）来强制 client Consul agents 对传入连接使用 TLS。你还必须为此传递 `tls_certificate_file` 和 `tls_key_file`。当 server 节点使用 client TLS 认证时，client TLS 证书和密钥将用于 TLS 认证和传入的 HTTPS 连接。

默认情况下，Consul client 节点不使用 client TLS 认证（与 server 相反），你需要通过设置 `consul['tls_verify_client'] = true` 显式指示它们这样做。

以下是一些 TLS 加密的示例。

#### 最小 TLS 支持

在以下示例中，server 对传入连接使用 TLS（不进行 client TLS 认证）。

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

例如，以下内容可以在 Patroni 节点上配置。

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

Patroni 与本地 Consul agent 通信，该 agent 对传入连接不使用 TLS。因此，`patroni['consul']['url']` 使用 HTTP URL。

{{< /tab >}}

{{< /tabs >}}

#### 默认 TLS 支持

在以下示例中，server 使用双向 TLS 认证。

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

例如，以下内容可以在 Patroni 节点上配置。

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

Patroni 与本地 Consul agent 通信，即使它对 Consul server 节点使用了 TLS 认证，该 agent 对传入连接也不使用 TLS。因此，`patroni['consul']['url']` 使用 HTTP URL。

{{< /tab >}}

{{< /tabs >}}

#### 完全 TLS 支持

在以下示例中，client 和 server 都使用双向 TLS 认证。

为了使双向 TLS 认证正常工作，Consul server、client 和 Patroni client 证书必须由同一个 CA 签发。

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

例如，以下内容可以在 Patroni 节点上配置。

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

### Gossip 加密

Gossip 协议可以被加密以保护 Consul agent 之间的通信安全。默认情况下加密未启用，要启用加密，需要一个共享的加密密钥。为了方便，可以使用 `gitlab-ctl consul keygen` 命令生成密钥。密钥必须是 32 字节长，Base 64 编码，并在所有 agent 上共享。

以下选项在 client 和 server 节点上均有效。

要启用 Gossip 协议：

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

要在 [现有数据中心启用加密](https://developer.hashicorp.com/consul/docs/security/encryption#enable-on-an-existing-consul-datacenter)，请为滚动更新手动设置这些选项。

## 升级 Consul 节点

要升级你的 Consul 节点，请升级 GitLab 软件包。

节点应该：

- 在升级 Linux 软件包之前，是健康集群的成员。
- 一次升级一个节点。

通过在每个节点运行以下命令来识别集群中任何现有的健康问题。如果集群健康，该命令返回一个空数组：

```shell
curl "http://127.0.0.1:8500/v1/health/state/critical"
```

如果 Consul 版本已更改，你会在 `gitlab-ctl reconfigure` 结束时看到一条通知，告知你必须重启 Consul 才能使用新版本。

一次重启一个 Consul 节点：

```shell
sudo gitlab-ctl restart consul
```

Consul 节点使用 Raft 协议进行通信。如果当前 Leader 下线，则必须进行 Leader 选举。必须存在一个 Leader 节点以促进跨集群的同步。如果太多节点同时下线，集群将失去仲裁，并由于 [共识被破坏](https://developer.hashicorp.com/consul/docs/architecture/consensus) 而无法选出 Leader。

如果升级后集群无法恢复，请查阅 [疑难解答部分](#troubleshooting-consul)。[宕机恢复](#outage-recovery) 可能特别值得关注。

极狐GitLab 使用 Consul 仅存储易于重新生成的瞬态数据。如果捆绑的 Consul 未被除极狐GitLab 自身之外的任何进程使用，你可以 [从头重建集群](#recreate-from-scratch)。

## 疑难解答

以下是一些你在调试任何问题时应进行的操作。你可以通过运行以下命令查看任何错误日志：

```shell
sudo gitlab-ctl tail consul
```

### 检查集群成员身份

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

理想情况下，所有节点的 `Status` 都是 `alive`。

### 重启 Consul

如果有必要重启 Consul，重要的是以受控的方式进行以维持仲裁。如果仲裁丢失，要恢复集群，你需要遵循 Consul [宕机恢复](#outage-recovery) 流程。

为安全起见，建议你一次只重启一个 Consul 节点，以确保集群保持完整。对于较大的集群，可以一次重启多个节点。请参阅 [Consul 共识文档](https://developer.hashicorp.com/consul/docs/architecture/consensus#deployment-table) 了解其可以容忍的故障数量。这也是它可以承受的同步重启次数。

要重启 Consul：

```shell
sudo gitlab-ctl restart consul
```

### Consul 节点无法通信

默认情况下，Consul 尝试 [绑定](https://developer.hashicorp.com/consul/docs/agent/config/config-files#bind_addr) 到 `0.0.0.0`，但它会通告节点上的第一个私有 IP 地址，供其他 Consul 节点与之通信。如果其他节点无法通过此地址与该节点通信，那么集群状态为失败。

如果你遇到此问题，`gitlab-ctl tail consul` 中会输出类似以下的消息：

```plaintext
2017-09-25_19:53:39.90821     2017/09/25 19:53:39 [WARN] raft: no known peers, aborting election
2017-09-25_19:53:41.74356     2017/09/25 19:53:41 [ERR] agent: failed to sync remote state: No cluster leader
```

要解决此问题：

1. 在每个节点上选择一个所有其他节点都可以通过其访问此节点的地址。
1. 更新你的 `/etc/gitlab/gitlab.rb`

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

如果你仍然看到错误，你可能必须在受影响的节点上 [清除 Consul 数据库并重新初始化](#recreate-from-scratch)。

### Consul 无法启动 - 多个私有 IP

如果一个节点有多个私有 IP，Consul 不知道该通告哪个私有地址，然后它会在启动时立即退出。

`gitlab-ctl tail consul` 中会输出类似以下的消息：

```plaintext
2017-11-09_17:41:45.52876 ==> Starting Consul agent...
2017-11-09_17:41:45.53057 ==> Error creating agent: Failed to get advertise address: Multiple private IPs found. Please configure one.
```

要解决此问题：

1. 在节点上选择一个所有其他节点都可以通过其访问此节点的地址。
1. 更新你的 `/etc/gitlab/gitlab.rb`

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

### 宕机恢复

如果你在集群中丢失了足够多的 Consul 节点以致于打破了仲裁，那么该集群被认为已失败，并且在没有人工干预的情况下无法运行。在这种情况下，你可以从头重新创建节点，或尝试恢复。

#### 从头重建

默认情况下，极狐GitLab 不会在 Consul 节点中存储任何无法重新创建的内容。要清除 Consul 数据库并重新初始化：

```shell
sudo gitlab-ctl stop consul
sudo rm -rf /var/opt/gitlab/consul/data
sudo gitlab-ctl start consul
```

在此之后，节点应重新启动，其余 server agent 会重新加入。此后不久，client agent 也应该重新加入。

如果它们没有加入，你可能还需要清除 client 上的 Consul 数据：

```shell
sudo rm -rf /var/opt/gitlab/consul/data
```

#### 恢复失败的节点

如果你利用 Consul 存储了其他数据并希望恢复失败的节点，请遵循 [Consul 指南](https://developer.hashicorp.com/consul/tutorials/operate-consul/recovery-outage) 来恢复失败的集群。