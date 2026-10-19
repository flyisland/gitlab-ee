---
stage: Async
group: Async
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 为扩缩容配置 Redis
description: 为扩缩容配置 Redis。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

根据您的基础设施设置以及安装极狐GitLab 的方式，有多种配置 Redis 的方法。

您可以选择自行安装和管理 Redis 与 Sentinel，使用托管的云解决方案，或者使用 Linux 软件包中自带的方案，这样您只需专注于配置。请选择适合您需求的方式。

<a id="supported-versions"></a>

## 支持的版本

推荐使用 Redis 7.2 或 Valkey 7.2。有关推荐版本和最低版本（包括托管服务的相关指南），请参阅 [Redis 要求](../../install/requirements.md#redis-or-valkey)。

最低版本预计将在未来版本中提高。要迁移现有的 Redis 6 部署，请参阅[对 Redis 6 的支持](../../update/deprecations.md#support-for-redis-6)。

<a id="use-valkey-instead-of-redis"></a>

## 使用 Valkey 代替 Redis

[Valkey](https://valkey.io/) 是一个开源的高性能键值数据存储，与 Redis 完全兼容。极狐GitLab 支持使用 Valkey 作为 Redis 的替代方案。

启用后，Valkey 默认使用与 Redis 相同的用户、组、数据目录和日志目录约定。

要在 Redis 节点上切换到 Valkey，请将以下内容添加到 `/etc/gitlab/gitlab.rb`：

```ruby
redis['backend'] = 'valkey'
```

<a id="known-issues"></a>

### 已知问题

- 由于已知的[议题 589642](https://gitlab.com/gitlab-org/gitlab/-/issues/589642)，管理区域会错误地报告 Valkey 版本。此问题不会影响所安装的 Valkey 版本或其运行方式。

<a id="redis-replication-and-failover-using-the-linux-package"></a>

## 使用 Linux 软件包实现 Redis 复制和故障转移

此设置适用于您使用 [Linux **企业版** 软件包](https://gitlab.cn/install?version=ee)安装极狐GitLab 的情况。

Redis 和 Sentinel 都包含在该软件包中，因此您可以使用它来搭建整个 Redis 基础设施（主节点、副本和 Sentinel）。

有关更多信息，请参阅[使用 Linux 软件包实现 Redis 复制和故障转移](replication_and_failover.md)。

<a id="secure-redis-and-sentinel-with-tls"></a>

### 使用 TLS 保护 Redis 和 Sentinel

使用 TLS（传输层安全）保护 Redis 和 Sentinel 通信。有关启用标准 TLS 和双向 TLS (mTLS) 的详细说明，请参阅[使用 TLS 保护 Redis 和 Sentinel](tls.md)。

<a id="redis-replication-and-failover-using-the-non-bundled-redis"></a>

## 使用非捆绑 Redis 实现 Redis 复制和故障转移

此设置适用于您已通过 [Linux 软件包](https://gitlab.cn/install)安装或[自行编译安装](../../install/self_compiled/_index.md)，但希望使用自己的外部 Redis 和 Sentinel 服务器的情况。

有关更多信息，请参阅[提供自有实例的 Redis 复制和故障转移](replication_and_failover_external.md)。

<a id="standalone-redis-using-the-linux-package"></a>

## 使用 Linux 软件包的独立 Redis

此设置适用于您已安装 [Linux **基础版** 软件包](https://gitlab.cn/install?version=ce)以使用捆绑的 Redis，因此您可以仅启用 Redis 服务来使用该软件包。

有关更多信息，请参阅[使用 Linux 软件包的独立 Redis](standalone.md)。
