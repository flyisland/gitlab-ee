---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 认证与授权术语表
description: 认证、授权、权限、角色及访问控制术语。
---

本术语表定义了与极狐GitLab 中的认证、授权和访问控制相关的术语。

<a id="identity-and-federation"></a>

## 身份与联合

外部身份提供者和协议，用于在系统之间建立和验证用户身份。这些术语描述了极狐GitLab 如何与企业身份管理系统集成，以实现用户认证的集中化。

<a id="identity-provider-idp"></a>

### 身份提供者 (IdP)

管理用户身份的服务，例如 Okta 或 OneLogin。

<a id="service-provider-sp"></a>

### 服务提供者 (SP)

将认证委托给外部身份提供者的应用程序。当配置为 SAML 或 OIDC 认证时，极狐GitLab 充当服务提供者。

<a id="single-sign-on-sso"></a>

### 单点登录 (SSO)

一种认证方法，允许用户使用单组凭证访问多个应用程序。通过 SSO，用户只需通过身份提供者进行一次认证，即可访问极狐GitLab 和其他关联服务，无需重复输入凭证。

<a id="saml"></a>

### SAML

安全断言标记语言，一种基于 XML 的协议，用于在身份提供者和服务提供者之间交换认证和授权数据。极狐GitLab 支持[SAML 认证](../integration/saml.md)以实现企业单点登录。

<a id="ldap"></a>

### LDAP

轻量级目录访问协议，一种用于访问和维护目录信息服务的标准。极狐GitLab 与[LDAP 服务器](../administration/auth/ldap/_index.md)集成，以认证用户并同步账户信息。

<a id="scim"></a>

### SCIM

跨域身份管理系统，一种用于自动化用户预配和解除预配的标准。极狐GitLab 支持[SCIM](../user/group/saml_sso/scim_setup.md)，以从身份提供者同步用户生命周期事件。

<a id="oidc-openid-connect"></a>

### OIDC (OpenID Connect)

基于 OAuth 2.0 构建的认证层，提供身份验证。极狐GitLab 支持[OIDC](../administration/auth/oidc.md)认证，并可充当外部应用程序的 OIDC 提供者。

<a id="oauth"></a>

### OAuth

一种授权协议，用于代表用户访问极狐GitLab 资源，而无需共享密码。[OAuth](../integration/oauth_provider.md)支持第三方集成以及将极狐GitLab 作为身份提供者使用。

<a id="assertion"></a>

### 断言

关于用户身份的一条信息，例如其名称或角色。也称为声明或属性。

<a id="claim"></a>

### 声明

关于用户身份或包含在认证令牌中的属性的信息。声明在 OAuth、OIDC 和 JWT 令牌中用于传递详细信息，如用户名、电子邮件或群组成员身份。

<a id="provisioning"></a>

### 预配

自动创建和配置用户账户及访问权限的过程。你可以使用 SCIM 或 LDAP 将用户从外部身份系统同步到极狐GitLab 中。

<a id="assertion-consumer-service-url"></a>

### 断言消费服务 URL

极狐GitLab 上的端点，用户在成功通过身份提供者认证后被重定向到此处。

<a id="issuer"></a>

### 颁发者

极狐GitLab 向身份提供者标识自身的方式。也称为信赖方信任标识符。

<a id="certificate-fingerprint"></a>

### 证书指纹

通过验证服务器是否使用正确的证书对通信进行签名，来确认 SAML 通信的安全性。也称为证书拇指指纹。

<a id="authentication"></a>

## 认证

在授予对极狐GitLab 的访问权限之前，用于验证用户身份的方法和凭证。认证在授予系统访问权限之前确认你是谁。[认证方法](user_authentication.md)包括密码、双重认证、SSH 密钥、个人访问令牌以及与外部身份提供者的集成。

<a id="passkey"></a>

### 通行密钥

一种使用存储在设备上的加密凭证的无密码认证方法。[通行密钥](passkeys.md)通过生物识别或设备 PIN 提供防钓鱼的认证。

<a id="two-factor-authentication-2fa"></a>

### 双重认证 (2FA)

一种额外的安全层，要求用户提供除密码以外的第二种认证形式。极狐GitLab 支持多种[双重认证方法](../user/profile/account/two_factor_authentication.md)，包括身份验证器应用和恢复代码。

<a id="session"></a>

### 会话

用户登录极狐GitLab 后保持的临时认证状态。会话在失效或被终止之前会跨请求持续存在。

<a id="ssh-keys"></a>

### SSH 密钥

用于访问 Git 仓库时进行安全认证的加密密钥。[SSH 密钥](../user/ssh.md)为 Git 操作提供了基于密码认证的安全替代方案。

<a id="personal-access-token"></a>

### 个人访问令牌

当使用极狐GitLab API 或基于 HTTPS 的 Git 时，用作密码替代方案以进行认证的令牌。[个人访问令牌](../user/profile/personal_access_tokens.md)具有定义的权限范围，以限制它们可以执行的操作。

<a id="group-access-token"></a>

### 群组访问令牌

限定在一个特定群组下，用于在该群组及其所有子群组中执行自动化任务的令牌。[群组访问令牌](../user/group/settings/group_access_tokens.md)继承群组权限，并支持 API 访问和 Git 操作。

<a id="project-access-token"></a>

### 项目访问令牌

限定在一个特定项目下，用于在该项目中执行自动化任务的令牌。[项目访问令牌](../user/project/settings/project_access_tokens.md)通常用于需要项目特定访问权限的 CI/CD 流水线和集成。

<a id="deploy-token"></a>

### 部署令牌

具有有限权限范围的令牌，用于部署自动化。[部署令牌](../user/project/deploy_tokens/_index.md)提供对代码仓库和软件包仓库的只读或写入访问权限，无需用户账户。

<a id="jwt-json-web-token"></a>

### JWT (JSON Web Token)

一种紧凑的令牌格式，用于在各方之间安全地传输信息。极狐GitLab 在 CI/CD 作业认证、OAuth 流程以及服务间通信中使用 JWT。

<a id="impersonation"></a>

### 模拟

一种管理功能，允许授权用户暂时以另一个用户的身份操作。[模拟](../api/rest/authentication.md#impersonation-tokens)有时用于排查用户特定的问题。

<a id="user-and-account-management"></a>

## 用户与账户管理

在极狐GitLab 中定义不同访问级别和功能的账户类型和用户类别。这些术语描述了可以与该系统交互的各种账户类型。

<a id="user-account"></a>

### 用户账户

代表访问极狐GitLab 的个人的单独账户。用户账户可以在不同的群组和项目中被分配各种角色。

<a id="user-types"></a>

### 用户类型

分配给用户账户的类型，隐式授予一组允许的操作。类型包括普通用户、审计员和管理员。用户类型与角色和权限不同。

<a id="administrator-users"></a>

### 管理员用户

一种具有最高级别系统访问权限的用户类型。拥有管理员访问权限的用户可以配置实例范围的设置、管理其他用户，并在所有群组和项目中执行管理任务。

<a id="auditor-users"></a>

### 审计员用户

一种特殊用户类型，对所有群组、项目和管理功能具有只读访问权限。[审计员用户](../administration/auditor_users.md)不能进行更改，但可以查看内容以达到合规性和安全性目的。

<a id="external-users"></a>

### 外部用户

被标记为组织外部的用户，其对内部项目和群组的访问受到限制。[外部用户](../administration/external_users.md)只能访问他们具有直接成员资格的项目。

<a id="service-accounts"></a>

### 服务账户

非人类用户账户，旨在执行自动化操作、访问数据或运行计划流程。[服务账户](../user/profile/service_accounts.md)通常在流水线或第三方集成中使用。

<a id="authorization-and-access-control"></a>

## 授权与访问控制

确定经过认证的用户在极狐GitLab 中可以执行哪些操作的框架和流程。授权基于用户身份、角色和资源所有权来评估权限。

<a id="access-control"></a>

### 访问控制

基于认证（验证用户是谁）和授权（确定用户可以做什么）来限制对资源访问的实践。

<a id="authorization"></a>

### 授权

确定经过认证的用户在极狐GitLab 中可以执行哪些操作的过程。授权基于分配的用户角色、权限以及在群组和项目中的成员资格。

<a id="rbac-role-based-access-control"></a>

### RBAC (基于角色的访问控制)

一种访问控制模型，其中通过角色而不是直接向用户分配权限。在极狐GitLab 中，用户根据其在群组或项目中被分配的角色获得权限。

<a id="policy"></a>

### 策略

一组授权规则，确定主体可以对资源执行哪些操作。极狐GitLab 使用[声明式策略框架](../development/policies.md)强制执行访问控制决策。

<a id="permissions-and-roles"></a>

## 权限与角色

定义用户可以在资源上执行哪些操作的基本构建块。权限组合成角色，角色被分配给用户以授予特定功能。

<a id="permission"></a>

### 权限

用户可以在极狐GitLab 资源上执行的[具体操作](../user/permissions.md)，如创建议题、推送代码或管理项目设置。

<a id="roles"></a>

### 角色

分配给用户的一组或多组权限，定义了他们在群组和项目中可以执行的操作。角色包括默认角色和自定义角色。

<a id="default-roles"></a>

### 默认角色

在每个极狐GitLab 实例中都可用的[预定义角色](../user/permissions.md)。每个角色包含一组特定的权限。以下默认角色可用：

- 最小访问权限
- 访客
- 计划者
- 报告者
- 安全经理
- 开发者
- 维护者
- 所有者

<a id="custom-roles"></a>

### 自定义角色

你为极狐GitLab 实例创建以满足组织需求的角色。每个[自定义角色](../user/custom_roles/_index.md)通过附加权限扩展了一个默认角色。

<a id="scopes"></a>

### 权限范围

令牌或 OAuth 应用程序在特定组织级别可用的权限。极狐GitLab 使用权限范围来确定授予个人访问令牌、群组访问令牌、项目访问令牌和 OAuth 应用程序的访问权限。

<a id="organizational-structure"></a>

## 组织结构

用于组织资源和控制访问的层次化容器和关系。这些结构决定了权限如何在群组、项目以及命名空间中传递。

<a id="namespace"></a>

### 命名空间

以层次结构组织群组和项目的容器。命名空间决定了资源路径和权限继承。每个用户都有一个个人命名空间，群组为团队提供共享命名空间。

<a id="group"></a>

### 群组

一组相关项目和用户，允许高效的组织和权限管理。群组可以包含子群组并继承来自父群组的权限。

<a id="member"></a>

### 成员

被授予对特定群组或项目的访问权限的用户。成员具有一个分配的角色，该角色确定他们对该资源的权限。

<a id="membership"></a>

### 成员资格

用户与特定群组或项目之间的关联，定义了他们在该资源中的访问权限。用户可以在多个群组和项目中拥有不同的成员资格和角色。

<a id="boundaries"></a>

### 边界

可以应用权限和策略的组织级别：

- 实例：适用于整个极狐GitLab 实例。
- 群组：适用于特定群组以及其下的任何子群组或项目。
- 项目：仅适用于单个项目。
- 用户：适用于特定用户执行或代表特定用户执行的操作。

<a id="inheritance"></a>

### 继承

权限从父群组到子群组和项目的自动传递。继承通过将授权在更高级别上授予的权限应用于所有嵌套的子群组和项目，简化了访问管理。

<a id="visibility"></a>

### 可见性

控制谁可以查看和访问你的内容的[设置](../user/public_access.md)：

- 公开：对所有人可见，包括没有极狐GitLab 账户的用户。
- 内部：对所有经过认证的极狐GitLab 用户可见。
- 私有：仅对成员可见。