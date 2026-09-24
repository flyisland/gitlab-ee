---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Authentication methods such as LDAP, OmniAuth, SAML, SCIM, OIDC, and OAuth
title: 用户身份
---

极狐GitLab 与多种第三方工具和协议集成，以更好地支持身份验证和授权。

将极狐GitLab 连接到您组织现有的身份基础设施，以集中管理用户并执行安全策略。您可以集成 LDAP、SAML、OAuth 或 SCIM 身份提供者和目录服务来进行身份验证和授权。

在私有化部署实例上，管理员可以集成诸如 Active Directory、Google Workspace 或 Azure AD 等身份提供者，以自动配置用户、同步群组成员资格并启用单点登录。JihuLab.com 上的群组也可以与 SAML 身份提供者集成，以实现集中身份验证和用户配置。

根据您的组织需求，从多种集成方法中选择：

- 用于目录同步的 LDAP
- 用于单点登录的 SAML
- 用于第三方身份验证的 OAuth
- 用于自动用户配置和取消配置的 SCIM

<a id="core-concepts"></a>

## 核心概念

{{< cards >}}

- [LDAP](ldap/_index.md)
- [OmniAuth](../../integration/omniauth.md)
- [SAML](../../integration/saml.md)
- [SAML 群组同步](../../user/group/saml_sso/group_sync.md)
- [SCIM](../settings/scim_setup.md)

{{< /cards >}}

<a id="gitlab-com-compared-to-gitlab-self-managed"></a>

## JihuLab.com 与私有化部署的对比

外部身份验证和授权提供者可能支持以下功能。有关详细信息，请参阅每个外部提供者在本页中显示的链接。

| 功能                                      | JihuLab.com                              | 私有化部署                       |
|-------------------------------------------------|-----------------------------------------|------------------------------------|
| **用户配置**                           | SCIM<br>SAML <sup>1</sup> | LDAP <sup>1</sup><br>SAML <sup>1</sup><br>[OmniAuth 提供者](../../integration/omniauth.md#supported-providers) <sup>1</sup><br>SCIM  |
| **用户详细信息更新**（不包括群组管理） | 不可用                           | LDAP 同步                          |
| **认证**                              | SAML 在顶级群组（1 个提供者）    | LDAP（多个提供者）<br>通用 OAuth 2.0<br>SAML（每个唯一提供者仅允许 1 个）<br>Kerberos<br>JWT<br>智能卡<br>[OmniAuth 提供者](../../integration/omniauth.md#supported-providers)（每个唯一提供者仅允许 1 个） |
| **提供者到极狐GitLab 角色同步**                | SAML 群组同步                         | LDAP 群组同步<br>SAML 群组同步（[极狐GitLab 15.1](https://jihulab.com/gitlab-cn/gitlab/-/issues/285150) 及更高版本） |
| **用户移除**                                | SCIM（从顶级群组中移除用户） | LDAP（从群组中移除用户并在实例中屏蔽）<br>SCIM |

**脚注**：

1. 使用即时（JIT）配置，用户账户在用户首次登录时创建。