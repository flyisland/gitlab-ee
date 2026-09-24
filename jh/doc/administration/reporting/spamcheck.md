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
> Spamcheck 适用于所有层级，但仅在运行极狐GitLab 企业版（EE）的实例上可用。由于[许可原因](https://jihulab.com/gitlab-cn/omnibus-gitlab/-/issues/6259#note_726605397)，极狐GitLab 基础版（CE）软件包不包含此功能。你可以[从基础版迁移到企业版](../../update/convert_to_ee/package.md)。

[Spamcheck](https://jihulab.com/gitlab-cn/gl-security/security-engineering/security-automation/spam/spamcheck) 是一个反垃圾信息引擎，由极狐GitLab 最初开发用于应对 JihuLab.com 上日益增多的垃圾信息，后来公开以供私有化部署的极狐GitLab 实例使用。

<a id="enable-spamcheck"></a>

## 启用 Spamcheck

Spamcheck 仅适用于基于包安装的方式：

1. 编辑 `/etc/gitlab/gitlab.rb` 并启用 Spamcheck：

   ```ruby
   spamcheck['enable'] = true
   ```

2. 重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

3. 验证新服务 `spamcheck` 和 `spam-classifier` 是否已启动并运行：

   ```shell
   sudo gitlab-ctl status
   ```

<a id="configure-gitlab-to-use-spamcheck"></a>

## 配置极狐GitLab 使用 Spamcheck

先决条件：

- 管理员访问权限。

1. 在右上角，选择 **管理员**。
1. 在左侧边栏，选择 **设置** > **报告**。
1. 展开 **垃圾信息和反机器人保护**。
1. 更新垃圾信息检查设置：
   1. 选中“通过外部 API 端点启用垃圾信息检查”复选框。
   1. 对于**外部垃圾信息检查端点的 URL**，使用 `grpc://localhost:8001`。
   1. 将**垃圾信息检查 API 密钥**留空。
1. 选择 **保存更改**。

> [!note]
> 在单节点实例中，Spamcheck 通过 `localhost` 运行，因此处于未认证模式。如果在多节点实例中，极狐GitLab 在一台服务器上运行，而 Spamcheck 在另一台服务器上监听公共端点，则建议通过 Spamcheck 服务前面的反向代理实施某种认证，并配合 API 密钥使用。例如，可以使用 `JWT` 认证，并指定 bearer token 作为 API 密钥。
> [Spamcheck 的原生认证支持正在开发中](https://jihulab.com/gitlab-com/gl-security/engineering-and-research/automation-team/spam/spamcheck/-/issues/171)。

<a id="running-spamcheck-over-tls"></a>

## 通过 TLS 运行 Spamcheck

Spamcheck 服务本身无法直接通过 TLS 与极狐GitLab 通信。但是，可以将 Spamcheck 部署在完成 TLS 终止的反向代理后面。在这种情况下，可以在 **管理员** 区域设置中将外部 Spamcheck URL 的方案指定为 `tls://`（而非 `grpc://`），使极狐GitLab 通过 TLS 与 Spamcheck 通信。