---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: 密码和 OAuth 令牌存储
---

{{< details >}}

1. Tier: 基础版, 专业版, 旗舰版
1. Offering: JihuLab.com, 私有化部署

{{< /details >}}

极狐GitLab 管理员可以配置密码和 OAuth 令牌的存储方式。

<a id="password-storage"></a>

## 密码存储

{{< history >}}

- PBKDF2+SHA512 引入于极狐GitLab 15.2，使用名为 `pbkdf2_password_encryption` and `pbkdf2_password_encryption_write` 的[功能标志](../administration/feature_flags.md)。默认禁用。
- 功能标志在极狐GitLab 15.6 中被移除，而且运行在 [FIPS 模式](../development/fips_gitlab.md)下的所有极狐GitLab 实例都可使用 PBKDF2+SHA512。

{{< /history >}}

极狐GitLab 以哈希格式存储用户密码，以防止密码以明文形式存储。

极狐GitLab 使用 Devise 身份验证库对用户密码进行哈希处理。创建的密码哈希具有以下属性：

- **哈希处理**:
  - **bcrypt**: 默认情况下，使用 `bcrypt` 哈希函数生成提供密码的哈希。此加密哈希函数强大且符合行业标准。
  - **PBKDF2+SHA512**: 支持 PBKDF2+SHA512：
    - 在 极狐GitLab 15.2 到 极狐GitLab 15.5 中，当启用了 `pbkdf2_password_encryption` 和 `pbkdf2_password_encryption_write` [feature flags](../administration/feature_flags.md) 时。
    - 在 极狐GitLab 15.6 及更高版本中，当启用 [FIPS mode](../development/fips_gitlab.md) 时（不需要 feature flags）。
- **扩展**: 密码哈希被扩展以增强对抗暴力攻击的能力。默认情况下，极狐GitLab 使用 bcrypt 的扩展因子为 10，PBKDF2+SHA512 为 20,000。
- **加盐**: 每个密码都添加了一个加密盐，以增强对抗预计算哈希和字典攻击的能力。为了提高安全性，每个盐都是为每个密码随机生成的，没有两个密码共享同一个盐。

<a id="oauth-access-token-storage"></a>

## OAuth 访问令牌存储

{{< history >}}

1. PBKDF2+SHA512 引入于极狐GitLab 15.3，使用名为 `hash_oauth_tokens` 的[功能标志](../administration/feature_flags.md)。
1. 在极狐GitLab 15.5 中默认启用。
1. 在极狐GitLab 15.6 中功能标志被移除。

{{< /history >}}

OAuth 访问令牌以 PBKDF2+SHA512 格式存储在数据库中。与 PBKDF2+SHA512 密码存储一样，访问令牌值被扩展 20,000 次以增强对抗暴力攻击的能力。

