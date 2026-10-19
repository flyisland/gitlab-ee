---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 身份验证方法，例如 LDAP、OmniAuth、SAML、SCIM、OIDC 和 OAuth
title: 用户身份
---

极狐GitLab 可与多种第三方工具和协议集成，以更好地支持身份验证和授权。

将极狐GitLab 连接到您组织现有的身份基础设施，以集中管理用户并实施安全策略。您可以与 LDAP、SAML、OAuth 或 SCIM 身份提供商及目录服务集成，以实现身份验证和授权。

在极狐GitLab 私有化部署上，管理员可以与 Active Directory、Google Workspace 或 Azure AD 等身份提供商集成，以自动预配用户、同步群组成员关系并启用单点登录。JihuLab.com 群组也可以与 SAML 身份提供商集成，以实现集中式身份验证和用户预配。

根据您组织的需求，从多种集成方式中进行选择：

- 使用 LDAP 进行目录同步
- 使用 SAML 实现单点登录
- 使用 OAuth 进行第三方身份验证
- 使用 SCIM 实现自动化的用户预配和取消预配

<a id="core-concepts"></a>

## 核心概念

{{< cards >}}

- [LDAP](ldap/_index.md)
- [OmniAuth](../../integration/omniauth.md)
- [SAML](../../integration/saml.md)
- [SAML 群组同步](../../user/group/saml_sso/group_sync.md)
- [SCIM](../settings/scim_setup.md)

{{< /cards >}}

<a id="gitlabcom-compared-to-gitlab-self-managed"></a>

## JihuLab.com 与极狐GitLab 私有化部署的对比

外部身份验证和授权提供商可能支持以下能力。有关更多信息，请参阅本页中针对每个外部提供商提供的链接。

| 能力                                            | JihuLab.com                              | 极狐GitLab 私有化部署                       |
|-------------------------------------------------|-----------------------------------------|------------------------------------|
| **用户预配**                                    | SCIM<br>SAML[^jit-provisioning] | LDAP[^jit-provisioning]<br>SAML[^jit-provisioning]<br>[OmniAuth 提供商](../../integration/omniauth.md#supported-providers)[^jit-provisioning]<br>SCIM  |
| **用户详情更新**（非群组管理）                  | 不可用                                  | LDAP 同步                          |
| **身份验证**                                    | 顶级群组上的 SAML（1 个提供商）         | LDAP（多个提供商）<br>通用 OAuth 2.0<br>SAML（每个唯一提供商仅允许 1 个）<br>Kerberos<br>JWT<br>智能卡<br>[OmniAuth 提供商](../../integration/omniauth.md#supported-providers)（每个唯一提供商仅允许 1 个） |
| **提供商到极狐GitLab 的角色同步**               | SAML 群组同步                           | LDAP 群组同步<br>SAML 群组同步 |
| **用户移除**                                    | SCIM（从顶级群组中移除用户）            | LDAP（从群组中移除用户，并在实例中阻止该用户）<br>SCIM |

[^jit-provisioning]: 使用即时（JIT）预配时，用户账号会在用户首次登录时创建。
