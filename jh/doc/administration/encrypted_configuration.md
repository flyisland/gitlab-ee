---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 加密配置
description: 为特定功能启用加密配置设置。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 可以从加密设置文件中读取特定功能的设置。支持的功能包括：

- [接收邮件 `user` 和 `password`](incoming_email.md#use-encrypted-credentials)。
- [LDAP `bind_dn` 和 `password`](auth/ldap/_index.md#use-encrypted-credentials)。
- [服务台电子邮件 `user` 和 `password`](../user/project/service_desk/configure.md#use-encrypted-credentials)。
- [SMTP `user_name` 和 `password`](raketasks/smtp.md#secrets)。

要启用加密配置设置，必须为 `encrypted_settings_key_base` 生成新的基础密钥。可以通过以下方式生成该密钥：

- 对于 Linux 软件包安装，系统会自动为您生成新密钥，但您必须确保所有节点上的
  `/etc/gitlab/gitlab-secrets.json` 包含相同的值。
- 对于 Helm chart 安装，如果启用了 `shared-secrets` chart，系统会自动生成新密钥。
  否则，您需要遵循[添加密钥的指南](https://gitlab.cn/docs/charts/installation/secrets/#gitlab-rails-secret)。
- 对于自行编译安装，可以通过运行以下命令生成新密钥：

  ```shell
  bundle exec rake gitlab:env:info RAILS_ENV=production GITLAB_GENERATE_ENCRYPTED_SETTINGS_KEY_BASE=true
  ```

  这会输出极狐GitLab 实例的一般信息，并在 `<path-to-gitlab-rails>/config/secrets.yml`中生成密钥。
