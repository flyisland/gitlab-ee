---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 认证与授权
description: User identity, authentication, permissions, access controls, and security best practices.
---

极狐GitLab 使用认证与授权来保护您的资源，同时不限制协作。

认证通过密码、双因素认证、SSH 密钥、访问令牌以及 SAML 和 OAuth 等外部身份提供商来验证您的身份。授权则通过角色和细粒度权限来决定您可以执行的操作，从而控制对群组、项目及资源的访问。这两个系统共同构建了一个可扩展的安全框架，适用于从个人用户到企业组织。

了解极狐GitLab 安全模型有助于您实施既能满足安全要求又能兼顾运营效率的访问控制。

{{< cards >}}

- [用户身份](../administration/auth/_index.md)
- [用户认证](user_authentication.md)
- [用户权限](user_permissions.md)
- [认证与授权最佳实践](auth_practices.md)
- [认证与授权术语表](auth_glossary.md)

{{< /cards >}}