---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 加密配置
description: Enable encrypted configuration settings for certain features.
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 可以从加密设置文件中读取某些功能的设置。支持的功能包括：

- [接收邮件 `user` 和 `password`](incoming_email.md#use-encrypted-credentials)。
- [LDAP `bind_dn` 和 `password`](auth/ldap/_index.md#use-encrypted-credentials)。
- [服务台邮件 `user` 和 `password`](../user/project/service_desk/configure.md#use-encrypted-credentials)。
- [SMTP `user_name` 和 `password`](raketasks/smtp.md#secrets)。

要启用加密配置设置，必须为 `encrypted_settings_key_base` 生成一个新的基础密钥。可以通过以下方式生成该密钥：

- 对于 Linux 软件包安装，新密钥会自动生成，但您必须确保 `/etc/gitlab/gitlab-secrets.json` 在所有节点上包含相同的值。
- 对于 Helm Chart 安装，如果您启用了 `shared-secrets` Chart，则会自动生成新密钥。否则，您需要按照 [添加密钥的 secrets 指南](https://gitlab.cn/docs/charts/installation/secrets/#gitlab-rails-secret) 操作。
- 对于自编译安装，可以通过运行以下命令生成新密钥：

  ```shell
  bundle exec rake gitlab:env:info RAILS_ENV=production GITLAB_GENERATE_ENCRYPTED_SETTINGS_KEY_BASE=true
  ```

  这会打印 极狐GitLab 实例的一般信息，并在 `<path-to-gitlab-rails>/config/secrets.yml` 中生成密钥。