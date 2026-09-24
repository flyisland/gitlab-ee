---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: 为通过集成认证创建的用户生成密码
---

{{< details >}}

1. Tier: 基础版, 专业版, 旗舰版
1. Offering: JihuLab.com, 私有化部署

{{< /details >}}

<a id="gitlab-allows-users-to-set-up-accounts-through-integration-with-external-authentication-and-authorization-providers"></a>

### 极狐GitLab允许用户通过与外部认证和授权提供者的集成来设置账户

极狐GitLab 允许用户通过与外部[认证和授权提供者](../administration/auth/_index.md)的集成来设置账户。

这些认证方法不要求用户明确为他们的账户创建密码。然而，为了保持数据一致性，极狐GitLab 要求所有用户账户设置密码。

对于此类账户，我们使用 Devise gem 提供的 `friendly_token` 方法来生成随机、唯一且安全的密码，并在注册时将其设置为账户密码。

生成的密码长度为 [128 个字符](password_length_limits.md)。
