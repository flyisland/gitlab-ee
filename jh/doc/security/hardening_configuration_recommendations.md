---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 加固 - 配置建议
---

通用加固指南已在[主要加固文档](hardening.md)中概述。

针对极狐GitLab 实例的一些加固建议涉及额外服务或通过配置文件进行控制。提醒一下，任何时候修改配置文件，请在编辑前备份它们。此外，如果要进行大量更改，建议不要一次性完成所有更改，并在每次更改后测试以确保一切正常工作。

<a id="nginx"></a>

## NGINX

NGINX 用于提供访问极狐GitLab 实例的 Web 界面。由于 NGINX 由极狐GitLab 控制并集成，因此通过修改 `/etc/gitlab/gitlab.rb` 文件进行调整。以下是一些有助于提高 NGINX 本身安全性的建议：

1. 创建 [Diffie-Hellman 密钥](https://nginx.org/en/docs/http/ngx_http_ssl_module.html#ssl_dhparam)：

   ```shell
   sudo openssl dhparam -out /etc/gitlab/ssl/dhparam.pem 4096
   ```

1. 编辑 `/etc/gitlab/gitlab.rb` 并添加以下内容：

   ```ruby
   #
   # 仅使用强密码套件
   #
   nginx['ssl_ciphers'] = "ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:TLS_AES_256_GCM_SHA384:TLS_AES_128_GCM_SHA256"
   #
   # 遵循首选密码套件并按照偏好顺序列出
   #
   nginx['ssl_prefer_server_ciphers'] = "on"
   #
   # 仅允许 TLSv1.2 和 TLSv1.3
   #
   nginx['ssl_protocols'] = "TLSv1.2 TLSv1.3"

   ##! **推荐参考：https://nginx.org/en/docs/http/ngx_http_ssl_module.html**
   nginx['ssl_session_cache'] = "builtin:1000 shared:SSL:10m"

   ##! **根据 https://nginx.org/en/docs/http/ngx_http_ssl_module.html 的默认值**
   nginx['ssl_session_timeout'] = "5m"

   # 应防止 logjam 攻击等
   nginx['ssl_dhparam'] = "/etc/gitlab/ssl/dhparam.pem" # 从 nil 更改

   # 关闭会话票据重用
   nginx['ssl_session_tickets'] = "off"
   # 选择我们自己的曲线，而不是 openssl 提供的
   nginx['ssl_ecdh_curve'] = "secp384r1"
   ```

1. 重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

<a id="consul"></a>

## Consul

Consul 可以集成到极狐GitLab 环境中，适用于更大规模的部署。通常，对于少于 1000 用户的私有化部署和独立部署，可能不需要 Consul。如果需要，请先查看 [Consul 文档](../administration/consul.md)，但更重要的是确保通信过程中使用加密。有关 Consul 的更多详细信息，请访问 [HashiCorp 网站](https://developer.hashicorp.com/consul/docs) 了解其工作原理，并查看有关 [加密安全](https://developer.hashicorp.com/consul/docs/security/encryption) 的信息。

<a id="environment-variables"></a>

## 环境变量

您可以在私有化部署系统上自定义多个 [环境变量](https://gitlab.cn/docs/omnibus/settings/environment-variables/)。从安全角度来看，在安装过程中要利用的主要环境变量是 `GITLAB_ROOT_PASSWORD`。如果您正在安装具有面向公网 IP 地址的私有化部署系统，请确保将密码设置为强密码。从历史上看，设置任何类型的面向公众的服务（无论是极狐GitLab 还是其他应用程序）都表明，一旦发现这些系统，机会性攻击就会发生，因此加固过程应在安装过程中开始。

如 [操作系统建议](hardening_operating_system_recommendations.md) 中所述，理想情况下，在开始极狐GitLab 安装之前应已设置防火墙规则，但您仍应在安装前通过 `GITLAB_ROOT_PASSWORD` 设置安全密码。

<a id="git-protocols"></a>

## Git 协议

为确保仅授权用户使用 SSH 进行 Git 访问，请将以下内容添加到您的 `/etc/ssh/sshd_config` 文件中：

```shell
# 确保仅授权用户使用 Git
AcceptEnv GIT_PROTOCOL
```

这确保用户无法通过 SSH 拉取项目，除非他们拥有有效的极狐GitLab 帐户，可以通过 SSH 执行 `git` 操作。更多详细信息，请参阅 [配置 Git 协议](../administration/git_protocol.md)。

<a id="incoming-email"></a>

## 接收邮件

您可以配置极狐GitLab 私有化部署，允许注册用户使用接收邮件在极狐GitLab 实例上发表评论或创建议题和合并请求。在加固环境中，您不应配置此功能，因为它涉及外部通信发送信息。

如果需要此功能，请按照 [接收邮件文档](../administration/incoming_email.md) 中的说明进行操作，并遵循以下建议以确保最大安全性：

- 专门为实例的入站邮件分配一个电子邮件地址。
- 使用 [电子邮件子地址](../administration/incoming_email.md)。
- 用户用于发送电子邮件的电子邮件帐户应要求并启用多因素认证（MFA）。
- 对于 Postfix，请遵循 [为接收邮件设置 Postfix 文档](../administration/reply_by_email_postfix_setup.md)。

<a id="redis-replication-and-failover"></a>

## Redis 复制和故障转移

Redis 在 Linux 软件包安装中用于复制和故障转移，可以在扩展需要时进行设置。请记住，这会打开 Redis 的 TCP 端口 `6379` 和 Sentinel 的 `26379`。请遵循 [复制和故障转移文档](../administration/redis/replication_and_failover.md)，但注意所有节点的 IP 地址，并在节点之间设置防火墙规则，仅允许其他节点访问这些特定端口。

<a id="sidekiq-configuration"></a>

## Sidekiq 配置

在 [配置外部 Sidekiq 的说明](../administration/sidekiq/_index.md) 中，多次提到配置 IP 范围。您必须 [配置 HTTPS](../administration/sidekiq/_index.md#enable-https)，并考虑将这些 IP 地址限制为 Sidekiq 与之通信的特定系统。您可能还需要在操作系统级别调整防火墙规则。

<a id="smime-signing-of-email"></a>

## 电子邮件的 S/MIME 签名

如果极狐GitLab 实例配置为向用户发送电子邮件通知，请配置 S/MIME 签名以帮助收件人确保电子邮件是合法的。请遵循 [签名外发电子邮件](../administration/smime_signing_email.md) 的说明。

<a id="container-registry"></a>

## 容器镜像仓库

如果配置了 Let's Encrypt，则默认启用容器镜像仓库。这允许项目存储自己的 Docker 镜像。请遵循配置 [容器镜像仓库](../administration/packages/container_registry.md) 的说明，以便您可以执行诸如限制新项目自动启用以及完全禁用容器镜像仓库等操作。您可能需要调整防火墙规则以允许访问 - 如果是完全独立的系统，您应将容器镜像仓库的访问限制为仅本地主机。文档中还包含了所用端口及其配置的具体示例。