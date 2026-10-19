---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Spamcheck 反垃圾信息服务
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

> [!warning]
> Spamcheck 适用于所有订阅层级，但仅限使用极狐GitLab 企业版的实例。出于[许可原因](https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/6259#note_726605397)，它未包含在极狐GitLab 基础版软件包中。

[Spamcheck](https://gitlab.com/gitlab-org/gl-security/security-engineering/security-automation/spam/spamcheck) 是一款反垃圾信息引擎，最初由 GitLab 开发，用于应对 JihuLab.com 上不断增多的垃圾信息，后来公开以供极狐GitLab 私有化部署实例使用。

<a id="enable-spamcheck"></a>

## 启用 Spamcheck

Spamcheck 仅适用于基于软件包的安装方式：

1. 编辑 `/etc/gitlab/gitlab.rb` 并启用 Spamcheck：

   ```ruby
   spamcheck['enable'] = true
   ```

1. 重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

1. 验证新服务 `spamcheck` 和 `spam-classifier`
   已启动并正在运行：

   ```shell
   sudo gitlab-ctl status
   ```

<a id="configure-gitlab-to-use-spamcheck"></a>

## 配置极狐GitLab 以使用 Spamcheck

先决条件：

- 管理员访问权限。

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **报告**。
1. 展开**垃圾信息和反机器人保护**。
1. 更新垃圾信息检查设置：
   1. 勾选“通过外部 API 端点启用垃圾信息检查”复选框。
   1. 对于**外部垃圾信息检查端点的 URL**，使用 `grpc://localhost:8001`。
   1. 将**垃圾信息检查 API 密钥**留空。
1. 选择**保存更改**。

> [!note]
> 在单节点实例中，Spamcheck 通过 `localhost` 运行，因此以未认证模式运行。如果在多节点实例中，极狐GitLab 运行在一台服务器上，而 Spamcheck 运行在另一台通过公共端点监听的服务器上，建议在 Spamcheck 服务前面使用反向代理实施某种形式的认证，并可配合 API 密钥使用。一个示例是使用 `JWT` 认证，并指定一个 bearer 令牌作为 API 密钥。
> [Spamcheck 的原生认证功能正在开发中](https://gitlab.com/gitlab-com/gl-security/engineering-and-research/automation-team/spam/spamcheck/-/issues/171)。

<a id="running-spamcheck-over-tls"></a>

## 通过 TLS 运行 Spamcheck

Spamcheck 服务本身无法直接通过 TLS 与极狐GitLab 通信。
但是，Spamcheck 可以部署在执行 TLS
终止的反向代理后面。在这种情况下，可以通过在**管理员**区域设置中为外部 Spamcheck URL 指定 `tls://` 方案（而不是 `grpc://`），让极狐GitLab 通过 TLS 与
Spamcheck 通信。
