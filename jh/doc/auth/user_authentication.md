---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 用户认证
description: Passwords, two-factor authentication, SSH keys, access tokens, credentials inventory.
---

极狐GitLab 提供多种认证方法，以保障用户安全访问其账户并与代码仓库交互。对于基于 Web 的访问，使用密码并结合可选的双重认证；对于 Git 操作，使用 SSH 密钥；对于 API 交互和自动化，使用各类访问令牌。

在私有化部署的极狐GitLab 上，管理员可以配置认证的工作方式、监控凭据使用情况并实施安全策略以保护其实例。用户可以管理自己的认证方式、查看活跃会话，并配置额外的安全措施，例如双重认证。

{{< cards >}}

- [用户密码](../user/profile/user_passwords.md)
- [双重认证](../user/profile/account/two_factor_authentication.md)
- [凭据清单](../administration/credentials_inventory.md)
- [SSH 密钥](../user/ssh.md)
- [访问令牌](../security/tokens/_index.md)
- [智能卡认证](../administration/auth/smartcard.md)
- [账户邮箱验证](../security/email_verification.md)

{{< /cards >}}