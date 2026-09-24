---
stage: Tenant Scale
group: Tenant Services
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 配置 Redis 以实现扩展
description: 配置 Redis 以实现扩展。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

根据您的基础设施设置和极狐GitLab 的安装方式，有多种方式可以配置 Redis。

您可以选择自行安装和管理 Redis 和 Sentinel，使用托管的云解决方案，或者使用 Linux 软件包中自带的方案，这样您只需关注配置。选择最适合您需求的方式。

<a id="use-valkey-instead-of-redis"></a>

## 使用 Valkey 替代 Redis

{{< history >}}

- 在 极狐GitLab 18.9 中作为 [测试版](../../policy/development_stages_support.md#beta) 引入。
- 在 极狐GitLab 19.0 中 GA。

{{< /history >}}

[Valkey](https://valkey.io/) 是一个完全兼容 Redis 的开源高性能键/值数据存储。极狐GitLab 支持将 Valkey 作为 Redis 的替代方案。

启用后，Valkey 默认使用与 Redis 相同的用户、群组、数据目录和日志目录约定。

要在 Redis 节点上切换到 Valkey，请将以下内容添加到 `/etc/gitlab/gitlab.rb` 中：

```ruby
redis['backend'] = 'valkey'
```

<a id="known-issues"></a>

### 已知问题

- 由于已知 [issue 589642](https://gitlab.com/gitlab-org/gitlab/-/issues/589642)，管理区域报告 Valkey 版本有误。该 issue 不影响已安装的 Valkey 的版本或其功能。

<a id="redis-replication-and-failover-using-the-linux-package"></a>

## 使用 Linux 软件包的 Redis 复制和故障转移

此设置适用于使用 [Linux **企业版** (EE) 软件包](https://gitlab.cn/install/?version=ee) 安装极狐GitLab 的情况。

Redis 和 Sentinel 都包含在软件包中，因此您可以使用它来设置整个 Redis 基础设施（主节点、副本和 Sentinel）。

更多信息，请参见 [使用 Linux 软件包的 Redis 复制和故障转移](replication_and_failover.md)。

<a id="secure-redis-and-sentinel-with-tls"></a>

### 使用 TLS 保护 Redis 和 Sentinel

使用 TLS（传输层安全）保护 Redis 和 Sentinel 通信的安全。有关启用标准 TLS 和双向 TLS (mTLS) 的详细说明，请参见 [使用 TLS 保护 Redis 和 Sentinel](tls.md)。

<a id="redis-replication-and-failover-using-the-non-bundled-redis"></a>

## 使用非捆绑 Redis 的 Redis 复制和故障转移

此设置适用于您使用 [Linux 软件包](https://gitlab.cn/install/) 安装或 [自行编译安装](../../install/self_compiled/_index.md) 的情况，但您想要使用自己的外部 Redis 和 Sentinel 服务器。

更多信息，请参见 [使用外部实例的 Redis 复制和故障转移](replication_and_failover_external.md)。

<a id="standalone-redis-using-the-linux-package"></a>

## 使用 Linux 软件包的独立 Redis

此设置适用于您安装了 [Linux **基础版** (CE) 软件包](https://gitlab.cn/install/?version=ce) 并使用自带的 Redis，这样您就可以仅启用 Redis 服务来使用该软件包。

更多信息，请参见 [使用 Linux 软件包的独立 Redis](standalone.md)。