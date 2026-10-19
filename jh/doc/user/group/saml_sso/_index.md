---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: JihuLab.com 群组的 SAML SSO
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

> [!note]
> 关于极狐GitLab 私有化部署，请参见[极狐GitLab 私有化部署的 SAML SSO](../../../integration/saml.md)。

用户可以通过其 SAML 身份提供商登录极狐GitLab。

[SCIM](scim_setup.md) 会将用户与 JihuLab.com 上的群组同步。

- 当您在 SCIM 应用中添加或移除用户时，SCIM 会在极狐GitLab 群组中添加或移除该用户。
- 如果该用户还不是群组成员，则在登录过程中会将该用户添加到群组中。

您只能为顶级群组配置 SAML SSO。

<a id="set-up-your-identity-provider"></a>

## 设置您的身份提供商

SAML 标准意味着您可以将多种身份提供商与极狐GitLab 配合使用。您的身份提供商可能有相关文档。这些文档可能是通用的 SAML 文档，也可能是专门针对极狐GitLab 的文档。

在设置您的身份提供商时，请使用以下特定于提供商的文档，以帮助避免常见问题，并作为术语使用的指南。

对于未列出的身份提供商，您可以参考[关于配置身份提供商的实例 SAML 说明](../../../integration/saml.md#configure-saml-on-your-idp)，以获取有关您的提供商可能要求的信息的更多指导。

极狐GitLab 提供以下信息仅供参考。如果您对配置 SAML 应用有任何疑问，请联系您的提供商的支持团队。

如果您在设置身份提供商时遇到问题，请参阅[故障排除文档](#troubleshooting)。

<a id="azure"></a>

### Azure

要使用 Azure 作为您的身份提供商设置 SSO：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的群组。
1. 在左侧边栏中，选择**设置** > **SAML SSO**。
1. 记下此页面上的信息。
1. 转到 Azure，[创建非库应用程序](https://learn.microsoft.com/en-us/entra/identity/enterprise-apps/overview-application-gallery#create-your-own-application)，并[为应用程序配置 SSO](https://learn.microsoft.com/en-us/entra/identity/enterprise-apps/add-application-portal-setup-sso)。以下极狐GitLab 设置对应 Azure 字段。

   | 极狐GitLab 设置                           | Azure 字段                                    |
   | -----------------------------------------| ---------------------------------------------- |
   | **标识符**                           | **标识符（实体 ID）**                     |
   | **断言消费者服务 URL**       | **回复 URL（断言消费者服务 URL）** |
   | **极狐GitLab 单点登录 URL**            | **登录 URL**                                |
   | **身份提供商单点登录 URL** | **登录 URL**                                  |
   | **证书指纹**              | **指纹**                                 |

1. 您应设置以下属性：
   - **唯一用户标识符（Name ID）** 设置为 `user.objectID`。
     - **名称标识符格式** 设置为 `persistent`。有关更多信息，请参阅如何[管理用户 SAML 身份](#manage-user-saml-identity)。
   - **附加声明** 设置为[支持的属性](#configure-assertions)。

1. 确保将身份提供商设置为允许提供商发起的调用，以关联现有的极狐GitLab 账号。

1. 可选。如果您使用[群组同步](group_sync.md)，请自定义群组声明的名称，以匹配所需的属性。

旧演示中的 `objectID` 映射已过时。请改为遵循[为 SCIM 配置 Microsoft Entra ID 文档](scim_setup.md#configure-microsoft-entra-id)中的说明。

有关更多信息，请参阅 [Azure 配置示例](example_saml_config.md#azure-active-directory)。

<a id="google-workspace"></a>

### Google Workspace

要将 Google Workspace 设置为您的身份提供商：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的群组。
1. 在左侧边栏中，选择**设置** > **SAML SSO**。
1. 记下此页面上的信息。
1. 遵循[将 Google 设置为您的身份提供商来设置 SSO](https://support.google.com/a/answer/6087519?hl=en)的说明。以下极狐GitLab 设置对应 Google Workspace 字段。

   | 极狐GitLab 设置                           | Google Workspace 字段 |
   |:-----------------------------------------|:-----------------------|
   | **标识符**                           | **实体 ID**          |
   | **断言消费者服务 URL**       | **ACS URL**            |
   | **极狐GitLab 单点登录 URL**            | **起始 URL**          |
   | **身份提供商单点登录 URL** | **SSO URL**            |

1. 当您获取证书时，Google Workspace 会显示 SHA256 指纹。如果您之后需要生成 SHA256 指纹，请参阅[计算指纹](troubleshooting.md#calculate-the-fingerprint)。
1. 设置以下值：
   - **主电子邮件**：`email`。
   - **名**：`first_name`。
   - **姓**：`last_name`。
   - **Name ID 格式**：`EMAIL`。
   - **NameID**：`Basic Information > Primary email`。
     有关更多信息，请参阅[支持的属性](#configure-assertions)。

1. 确保将身份提供商设置为允许提供商发起的调用，以关联现有的极狐GitLab 账号。

在极狐GitLab SAML SSO 页面上，当您选择 **验证 SAML 配置** 时，请忽略建议将 **NameID** 格式设置为 `persistent`的警告。

有关更多信息，请参阅 [Google Workspace 配置示例](example_saml_config.md#google-workspace)。


<a id="okta"></a>

### Okta

要使用 Okta 作为您的身份提供商设置 SSO：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的群组。
1. 在左侧边栏中，选择**设置** > **SAML SSO**。
1. 记下此页面上的信息。
1. 遵循[在 Okta 中设置 SAML 应用程序](https://developer.okta.com/docs/guides/build-sso-integration/saml2/main/)的说明。

   以下极狐GitLab 设置对应 Okta 字段。

   | 极狐GitLab 设置                           | Okta 字段                                                     |
   | ---------------------------------------- | -------------------------------------------------------------- |
   | **标识符**                           | **受众 URI**                                               |
   | **断言消费者服务 URL**       | **单点登录 URL**                                         |
   | **极狐GitLab 单点登录 URL**            | **登录页面 URL**（在 **应用登录页面** 设置下） |
   | **身份提供商单点登录 URL** | **身份提供商单点登录 URL**                       |

1. 在 Okta 的 **单点登录 URL** 字段下，选中 **将此值用于接收方 URL 和目标 URL** 复选框。
1. 设置以下值：
   - **应用用户名（NameID）**：**自定义** `user.getInternalProperty("id")`。
   - **Name ID 格式**：`Persistent`。有关更多信息，请参阅[管理用户 SAML 身份](#manage-user-saml-identity)。
   - **email**：`user.email` 或类似值。
   - 有关其他 **属性语句**，请参阅[支持的属性](#configure-assertions)。

1. 确保将身份提供商设置为允许提供商发起的调用，以关联现有的极狐GitLab 账号。

App Catalog 中提供的 Okta GitLab 应用程序仅支持 [SCIM](scim_setup.md)。对 SAML 的支持已在[议题 216173](https://gitlab.com/gitlab-org/gitlab/-/issues/216173)中提出。


有关更多信息，请参阅 [Okta 配置示例](example_saml_config.md#okta)。

<a id="onelogin"></a>

### OneLogin

OneLogin 支持其自己的 [GitLab.com 应用程序](https://onelogin.service-now.com/support?id=kb_article&sys_id=08e6b9d9879a6990c44486e5cebb3556&kb_category=50984e84db738300d5505eea4b961913)。

要将 OneLogin 设置为您的身份提供商：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的群组。
1. 在左侧边栏中，选择**设置** > **SAML SSO**。
1. 记下此页面上的信息。
1. 如果您使用 OneLogin 通用的
   [SAML Test Connector (Advanced)](https://onelogin.service-now.com/support?id=kb_article&sys_id=b2c19353dbde7b8024c780c74b9619fb&kb_category=93e869b0db185340d5505eea4b961934)，
   您应[使用 OneLogin SAML Test Connector](https://onelogin.service-now.com/support?id=kb_article&sys_id=93f95543db109700d5505eea4b96198f)。以下极狐GitLab 设置对应
   OneLogin 字段：

   | 极狐GitLab 设置                                       | OneLogin 字段                   |
   | ---------------------------------------------------- | -------------------------------- |
   | **标识符**                                       | **受众**                     |
   | **断言消费者服务 URL**                   | **接收方**                    |
   | **断言消费者服务 URL**                   | **ACS（消费者）URL**           |
   | **断言消费者服务 URL（转义版本）** | **ACS（消费者）URL 验证器** |
   | **极狐GitLab 单点登录 URL**                        | **登录 URL**                    |
   | **身份提供商单点登录 URL**             | **SAML 2.0 端点**            |

1. 对于 **NameID**，使用 `OneLogin ID`。有关更多信息，请参阅[管理用户 SAML 身份](#manage-user-saml-identity)。
1. 配置[必需和受支持的属性](#configure-assertions)。
1. 确保将身份提供商设置为允许提供商发起的调用，以关联现有的极狐GitLab 账号。

有关更多信息，请参阅 [OneLogin 配置示例](example_saml_config.md#onelogin)。

<a id="keycloak"></a>

### Keycloak

要将 Keycloak 设置为您的身份提供商：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的群组。
1. 在左侧边栏中，选择**设置** > **SAML SSO**。
1. 记下此页面上的信息。
1. 遵循[在 Keycloak 中创建 SAML 客户端](https://www.keycloak.org/docs/latest/server_admin/index.html#_client-saml-configuration)的说明。

以下极狐GitLab 设置对应 Keycloak 字段。

   | 极狐GitLab 设置                           | Keycloak 字段                          |
   |:-----------------------------------------|:------------------------------------------------|
   | **标识符**                           | **客户端 ID**                                   |
   | **断言消费者服务 URL**       | **有效重定向 URI**                         |
   | **断言消费者服务 URL**       | **断言消费者服务 POST 绑定 URL** |
   | **极狐GitLab 单点登录 URL**            | **主页 URL**                                    |

1. 在 Keycloak 中配置您的极狐GitLab 客户端。
   1. 在 Keycloak 中，转到 **客户端** 并选择您的极狐GitLab 客户端配置。
   1. 在 **设置** 标签页的 **SAML 功能** 部分：
      1. 将 **Name ID 格式** 设置为 `persistent`。
      1. 开启 **强制 Name ID 格式**。
      1. 开启 **强制 POST 绑定**。
      1. 开启 **包含 AuthnStatement**。
   1. 在 **签名和加密** 部分，开启 **签署文档**。
   1. 在 **密钥** 标签页，确保所有部分均已禁用。
   1. 在 **客户端范围** 标签页：
      1. 选择极狐GitLab 的客户端范围。该范围的名称应类似于 `https://gitlab.com/groups/your-group-name-dedicated`。
      1. 选择 **配置新映射器**，然后在打开的窗口中选择 **用户属性**。
      1. 在 **添加映射器** 页面上，将 **名称**、**用户属性** 和 **SAML 属性名称** 字段设置为 `email`。
      1. 选择 **保存**。
1. 从 Keycloak 获取客户端信息。
   1. 在 **操作** 下拉列表中，选择 **下载适配器配置**。
   1. 在 **下载适配器配置** 对话框中，从下拉列表中选择 **mod-auth-mellon**。
   1. 选择 **下载**。
   1. 解压下载的归档文件并打开 `idp-metadata.xml`。
   1. 获取身份提供商单点登录 URL。
      1. 找到 `<md:SingleSignOnService>` 标签。
      1. 记下 `Location` 属性的值。
   1. 获取证书指纹。
      1. 记下 `<ds:X509Certificate>` 标签的值。
      1. 将该值复制到单独的文件中，并将该值转换为 [PEM 格式](https://www.ssl.com/guide/pem-der-crt-and-cer-x-509-encodings-and-conversions/#ftoc-heading-3)。为此，请在文件开头添加 `-----BEGIN CERTIFICATE-----`，并在文件末尾添加 `-----END CERTIFICATE-----` 作为新行。
      1. [计算指纹](troubleshooting.md#calculate-the-fingerprint)。

<a id="aws-iam-identity-center"></a>

### AWS IAM Identity Center

> [!note]
> AWS IAM Identity Center（原 AWS Single Sign-On）不是经过 GitLab 测试的身份提供商。
> GitLab 提供以下信息，这些信息基于客户报告的配置。
> 如果您对在 AWS IAM Identity Center 中配置 SAML 集成有疑问，
> 请联系 [AWS Support](https://aws.amazon.com/contact-us/)。

AWS IAM Identity Center 默认使用 IdP 发起的登录。要关联您现有的极狐GitLab 账号，
您必须配置 SP 发起的登录。有关更多信息，请参阅
[SP 发起的登录](#sp-initiated-login)。

要使用 AWS IAM Identity Center 作为您的身份提供商设置 SSO：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的群组。
1. 选择**设置** > **SAML SSO**，并记下此页面上的值。
1. 在 AWS IAM Identity Center 控制台中，
   [设置自定义 SAML 2.0 应用程序](https://docs.aws.amazon.com/singlesignon/latest/userguide/customermanagedapps-set-up-your-own-app-saml2.html)。
   当提示输入元数据值时，请输入以下内容：

   | 极狐GitLab 设置                           | AWS IAM Identity Center 字段      |
   | ---------------------------------------- | ---------------------------------- |
   | **断言消费者服务 URL**       | **应用 ACS URL**            |
   | **标识符**                           | **应用 SAML 受众**      |

1. 要启用 SP 发起的登录，请将 **应用起始 URL** 设置为您的
   **极狐GitLab 单点登录 URL**（在极狐GitLab **SAML SSO** 设置页面上）。

1. 在 **属性映射** 下，配置以下内容：

   | 属性      | 值                | 格式        |
   | -------------- | -------------------- | ------------- |
   | **Subject**    | `${user:email}`      | `unspecified` |
   | **email**      | `${user:email}`      | `unspecified` |
   | **first_name** | `${user:givenName}`  | `unspecified` |
   | **last_name**  | `${user:familyName}` | `unspecified` |

   > [!warning]
   > 您必须将 **Subject** (NameID) 格式设置为 `unspecified`。将格式设置为 `persistent` 或 `transient`
   > 会导致尝试关联账号的现有极狐GitLab 用户出现身份验证错误。

1. 在 **IAM Identity Center SAML 元数据** 下，复制 **IAM Identity Center 登录 URL**
   并下载证书。

1. 在您的终端上，从下载的证书生成 SHA1 指纹：

   ```shell
   openssl x509 -noout -fingerprint -sha1 -inform pem -in <path-to-downloaded-cert.pem>
   ```

1. 在极狐GitLab 中，在群组 **SAML SSO** 设置页面上，填写以下字段：
   - **身份提供商单点登录 URL**：输入 **IAM Identity Center 登录 URL**。
   - **证书指纹**：输入 SHA1 指纹值。

1. 在 AWS IAM Identity Center 中，将用户分配到极狐GitLab 应用程序。
   要关联现有的极狐GitLab 账号，用户必须从 **极狐GitLab 单点登录 URL**
   或 **应用起始 URL** 登录。

有关更多信息，请参阅
[AWS IAM Identity Center 配置示例](example_saml_config.md#aws-iam-identity-center)。

<a id="sp-initiated-login"></a>

#### SP 发起的登录

当用户通过其身份提供商仪表板登录（IdP 发起的登录）时，SAML 响应不包含 `InResponseTo` 属性。极狐GitLab 需要此属性才能将 SAML 身份关联到现有账号。

AWS IAM Identity Center 默认使用 IdP 发起的登录。如果未配置 **应用起始 URL**，
现有用户在尝试登录时会看到错误 `Request to link SAML account must be authorized`。

为避免此问题，请将 **应用起始 URL** 设置为您的 **极狐GitLab 单点登录 URL**。
这可确保用户从极狐GitLab 开始登录流程，因此 SAML 响应中会包含 `InResponseTo` 属性。

<a id="configure-assertions"></a>

### 配置断言

> [!note]
> 这些属性不区分大小写。

至少，您必须配置以下断言：

1. [NameID](#manage-user-saml-identity)。
1. Email。

可选地，您可以在 SAML 断言中将用户信息作为属性传递给极狐GitLab。

- 用户的电子邮件地址可以是 **email** 或 **mail** 属性。
- 用户名可以是 **username** 或 **nickname** 属性。您应只指定
  其中之一。

有关可用属性的更多信息，请参阅[极狐GitLab 私有化部署的 SAML SSO](../../../integration/saml.md#configure-assertions)。

<a id="use-metadata"></a>

### 使用元数据

要配置某些身份提供商，您需要极狐GitLab 元数据 URL。要找到此 URL：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的群组。
1. 在左侧边栏中，选择**设置** > **SAML SSO**。
1. 复制提供的 **极狐GitLab 元数据 URL**。
1. 遵循您的身份提供商的文档，并在要求时粘贴元数据 URL。

查看您的身份提供商的文档，了解其是否支持极狐GitLab 元数据 URL。

<a id="manage-the-identity-provider"></a>

### 管理身份提供商

设置好您的身份提供商后，您可以：

- 更改身份提供商。
- 更改电子邮件域。

<a id="change-the-identity-provider"></a>

#### 更改身份提供商

您可以更改为其他身份提供商。在更改过程中，用户无法访问任何 SAML 群组。为缓解此问题，您可以禁用
[SSO 强制](#sso-enforcement)。

要更改身份提供商：

1. 使用新的身份提供商[配置](#set-up-your-identity-provider)群组。
1. 可选。如果 **NameID** 不相同，请[更改用户的 **NameID**](#manage-user-saml-identity)。

<a id="change-email-domains"></a>

#### 更改电子邮件域

要将用户迁移到新的电子邮件域，请告知用户：

1. [将其新电子邮件](../../profile/_index.md#change-your-primary-email)添加为其账号的主电子邮件并进行验证。
1. 可选。从账号中移除其旧电子邮件。

如果 **NameID** 配置为电子邮件地址，请[更改用户的 **NameID**](#manage-user-saml-identity)。

<a id="configure-gitlab"></a>

## 配置极狐GitLab

在您设置好身份提供商以与极狐GitLab 配合使用后，您必须配置极狐GitLab 以将其用于身份验证：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的群组。
1. 在左侧边栏中，选择**设置** > **SAML SSO**。
1. 填写字段：
   - 在 **身份提供商单点登录 URL** 字段中，输入来自您的身份提供商的 SSO URL。
   - 在 **证书指纹** 字段中，输入 SAML 令牌签名证书的指纹。
1. 对于 JihuLab.com 上的群组：在 **默认成员角色** 字段中，选择：
   1. 要分配给新用户的角色。
   1. 当为群组配置了 SAML 群组链接时，要分配给
      [不是映射的 SAML 群组成员的用户](group_sync.md#automatic-member-removal)
      的角色。
1. 对于极狐GitLab 私有化部署实例上的群组：在 **默认成员角色** 字段中，
   选择要分配给新用户的角色。
   默认角色是 **Guest**。该角色会成为添加到群组的所有用户的起始角色。
   群组所有者可以将[自定义角色](../../custom_roles/_index.md)
   设置为默认成员角色。
1. 选中 **为此群组启用 SAML 身份验证** 复选框。
1. 推荐。选择：
   - 在极狐GitLab 17.4 及更高版本中，**为企业用户禁用密码和通行密钥身份验证**。
     有关更多信息，请参阅[为企业用户禁用密码和通行密钥身份验证文档](#disable-password-and-passkey-authentication-for-enterprise-users)。
   - **对此群组的 Web 活动强制实施仅 SSO 身份验证**。
   - **对此群组的 Git 和依赖代理活动强制实施仅 SSO 身份验证**。
     有关更多信息，请参阅 [SSO 强制文档](#sso-enforcement)。
1. 选择 **保存更改**。

如果您在配置极狐GitLab 时遇到问题，请参阅[故障排除文档](#troubleshooting)。

<a id="user-access-and-management"></a>

## 用户访问和管理

配置并启用群组 SSO 后，用户可以通过身份提供商的仪表板访问 JihuLab.com 群组。
如果配置了 [SCIM](scim_setup.md)，请参阅 SCIM 页面上的[用户访问](scim_setup.md#user-access)。

当用户尝试使用群组 SSO 登录时，极狐GitLab 会尝试根据以下内容查找或创建用户：

- 查找具有匹配 SAML 身份的现有用户。这意味着该用户的账号要么是由 [SCIM](scim_setup.md) 创建的，要么之前已使用群组的 SAML IdP 登录过。
- 如果尚不存在具有相同电子邮件地址的账号，则自动创建新账号。极狐GitLab 会尝试同时匹配主电子邮件地址和辅助电子邮件地址。
- 如果已存在具有相同电子邮件地址的账号，则将用户重定向到登录页面，以便：
  - 使用其他电子邮件地址创建新账号。
  - 登录其现有账号以关联 SAML 身份。

<a id="provisioning-behavior-with-restricted-access"></a>

### 受限访问下的预配行为

当启用[受限访问](../../../subscriptions/manage_seats.md#restricted-access)且没有可用席位时，通过 SAML 预配的用户会被分配最小访问角色。

有关更多信息，请参阅[使用 SAML、SCIM 和 LDAP 的预配行为](../../../subscriptions/manage_seats.md#provisioning-behavior-with-saml-scim-and-ldap)。

<a id="link-saml-to-your-existing-gitlabcom-account"></a>

### 将 SAML 关联到您现有的 JihuLab.com 账号

> [!note]
> 如果用户是该群组的[企业用户](../../enterprise_user/_index.md)，则以下步骤不适用。企业用户必须改为[使用与极狐GitLab 账号具有相同电子邮件的 SAML 账号登录](#automatic-identity-linking-for-enterprise-users)。这允许极狐GitLab 将 SAML 账号关联到现有账号。

要将 SAML 关联到您现有的 JihuLab.com 账号：

1. 登录您的 JihuLab.com 账号。如有必要，请[重置您的密码](https://gitlab.com/users/password/new)。
1. 找到并访问您要登录的群组的 **极狐GitLab 单点登录 URL**。群组所有者可以在群组的**设置** > **SAML SSO** 页面上找到此 URL。
   如果配置了登录 URL，用户可以从身份提供商连接到极狐GitLab 应用。
1. 可选。选中 **记住我** 复选框，以在 2 周内保持登录极狐GitLab。
   您可能仍会被要求更频繁地使用 SAML 提供商重新进行身份验证。
1. 选择 **Authorize**。
1. 如果提示，请在身份提供商上输入您的凭据。
1. 然后您会被重定向回 JihuLab.com，并且现在应该可以访问该群组。
   以后，您可以使用 SAML 登录 JihuLab.com。

如果用户已经是群组成员，则关联 SAML 身份不会更改其角色。

在后续访问中，您应该能够[使用 SAML 登录 JihuLab.com](#sign-in-to-gitlabcom-with-saml)
或直接访问链接。如果开启了 **强制实施 SSO** 选项，您会被重定向以通过身份提供商登录。

<a id="automatic-identity-linking-for-enterprise-users"></a>

#### 企业用户的自动身份关联

如果企业用户被移出群组后又返回，他们可以使用其企业 SSO 账号登录。只要用户在身份提供商中的电子邮件地址与现有极狐GitLab 账号上的电子邮件地址保持一致，SSO 身份就会自动关联到该账号，用户即可顺利登录。此功能也适用于已被声明为企业用户但可能尚未登录该群组的现有用户。

<a id="sign-in-to-gitlabcom-with-saml"></a>

### 使用 SAML 登录 JihuLab.com

1. 登录您的身份提供商。
1. 从应用列表中，选择 "JihuLab.com" 应用。（该名称由身份提供商的管理员设置。）
1. 然后您会登录到 JihuLab.com 并被重定向到该群组。

<a id="manage-user-saml-identity"></a>

### 管理用户 SAML 身份

JihuLab.com 使用 SAML **NameID** 来识别用户。**NameID** 是：

- SAML 响应中的必填字段。
- 不区分大小写。

**NameID** 必须：

- 对每个用户唯一。
- 是一个永不更改的持久值，例如随机生成的唯一用户 ID。
- 在后续登录尝试中完全匹配，因此它不应依赖可能在大小写之间变化的用户输入。

**NameID** 不应是电子邮件地址或用户名，因为：

- 电子邮件地址和用户名更可能随时间变化。例如，
  当一个人的姓名发生变化时。
- 电子邮件地址不区分大小写，这可能导致用户无法
  登录。

**NameID** 格式必须为 `Persistent`，除非您使用的字段（如电子邮件）需要不同的格式。您可以使用除 `Transient` 之外的任何格式。

<a id="change-user-nameid"></a>

#### 更改用户 **NameID**

群组所有者可以使用 [SAML API](../../../api/saml.md#update-extern_uid-field-for-a-saml-identity) 更改其群组成员的 **NameID** 并更新其 SAML 身份。

> [!warning]
> 通过 API 更新 `extern_uid` 会将 SAML 身份标记为不受信任。受影响的用户在他们[将其账号重新关联到新的 SAML 应用](#link-saml-to-your-existing-gitlabcom-account)之前无法使用 SAML 登录。

如果配置了 [SCIM](scim_setup.md)，群组所有者可以使用 [SCIM API](../../../api/scim.md#update-extern_uid-field-for-a-scim-identity) 更新 SCIM 身份。

或者，请用户重新连接其 SAML 账号。

1. 请相关用户[将其账号从群组取消关联](#unlink-accounts)。
1. 请相关用户[将其账号关联到新的 SAML 应用](#link-saml-to-your-existing-gitlabcom-account)。

> [!warning]
> 在用户使用 SSO SAML 登录极狐GitLab 后，更改 **NameID** 值
> 会破坏配置，并可能将用户锁定在极狐GitLab 群组之外。

有关特定身份提供商的推荐值和格式的更多信息，请参阅[设置您的身份提供商](#set-up-your-identity-provider)。

<a id="configure-enterprise-user-settings-from-saml-response"></a>

### 从 SAML 响应配置企业用户设置

极狐GitLab 允许根据 SAML 响应中的值设置某些用户属性。如果该用户是群组的[企业用户](../../enterprise_user/_index.md)，则现有用户的属性会根据 SAML 响应值进行更新。

<a id="supported-user-attributes"></a>

#### 支持的用户属性

- `can_create_group` - `true` 或 `false`，表示企业用户是否可以创建
  新的顶级群组。默认值为 `true`。
- `projects_limit` - 企业用户可以创建的个人项目总数。
  值为 `0` 表示用户无法在其个人
  命名空间中创建新项目。默认值为 `100000`。
- `SessionNotOnOrAfter` - 一个 ISO 8601 时间戳值，表示何时结束用户 SAML 会话。

<a id="example-saml-response"></a>

#### SAML 响应示例

您可以在浏览器的开发者工具或控制台中找到 SAML 响应，格式为 base64 编码。使用您选择的 base64 解码工具将信息转换为 XML。此处显示了一个 SAML 响应示例。

```xml
   <saml2:AttributeStatement>
      <saml2:Attribute Name="email" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:basic">
         <saml2:AttributeValue xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="xs:string">user.email</saml2:AttributeValue>
      </saml2:Attribute>
      <saml2:Attribute Name="username" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:basic">
        <saml2:AttributeValue xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="xs:string">user.nickName</saml2:AttributeValue>
      </saml2:Attribute>
      <saml2:Attribute Name="first_name" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:unspecified">
         <saml2:AttributeValue xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="xs:string">user.firstName</saml2:AttributeValue>
      </saml2:Attribute>
      <saml2:Attribute Name="last_name" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:unspecified">
         <saml2:AttributeValue xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="xs:string">user.lastName</saml2:AttributeValue>
      </saml2:Attribute>
      <saml2:Attribute Name="can_create_group" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:unspecified">
         <saml2:AttributeValue xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="xs:string">true</saml2:AttributeValue>
      </saml2:Attribute>
      <saml2:Attribute Name="projects_limit" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:unspecified">
         <saml2:AttributeValue xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="xs:string">10</saml2:AttributeValue>
      </saml2:Attribute>
   </saml2:AttributeStatement>
```

<a id="customize-saml-session-timeout"></a>

### 自定义 SAML 会话超时

默认情况下，极狐GitLab 在 24 小时后结束 SAML 会话。您可以使用 SAML2 AuthnStatement 中的 `SessionNotOnOrAfter` 属性自定义此持续时间。此属性包含一个 ISO 8601 时间戳值，表示何时结束用户会话。指定后，此值会覆盖默认的 24 小时 SAML 会话超时。

默认情况下，极狐GitLab 在闲置七天后（10080 分钟）结束会话。如果
`SessionNotOnOrAfter` 时间戳晚于此时间，用户必须在其
会话结束时重新进行身份验证。

<a id="example-response"></a>

#### 响应示例

```xml
   <saml:AuthnStatement SessionIndex="WDE5aBYjNEj_9IjCFiK0E1YelZT" SessionNotOnOrAfter="2025-08-25T01:23:45.067Z" AuthnInstant="2025-08-24T13:23:45.067Z">
      <saml:AuthnContext>
         <saml:AuthnContextClassRef>urn:oasis:names:tc:SAML:2.0:ac:classes:unspecified</saml:AuthnContextClassRef>
      </saml:AuthnContext>
   </saml:AuthnStatement>
```

<a id="bypass-user-email-confirmation-with-verified-domains"></a>

### 使用已验证域绕过用户电子邮件确认

默认情况下，通过 SAML 或 SCIM 预配的用户会收到一封验证电子邮件以验证其身份。您可以改为
[使用自定义域配置极狐GitLab](../../enterprise_user/_index.md#add-group-domains)，极狐GitLab
会自动确认用户账号。用户仍会收到一封[企业用户](../../enterprise_user/_index.md)欢迎电子邮件。如果以下两个条件均满足，则绕过确认：

- 用户通过 SAML 或 SCIM 预配。
- 用户拥有属于已验证域的电子邮件地址。

> [!note]
> 电子邮件地址在已验证域之外的已预配用户仍处于未确认状态。
> 如果启用了[自动删除未确认用户](../../../administration/moderate_users.md#automatically-delete-unconfirmed-users)，
> 极狐GitLab 可以删除这些用户。

<a id="disable-password-and-passkey-authentication-for-enterprise-users"></a>

### 为企业用户禁用密码和通行密钥身份验证

先决条件：

- 您必须拥有企业用户所属群组的所有者角色。
- 必须启用群组 SSO。

您可以为该群组的所有[企业用户](../../enterprise_user/_index.md)禁用密码身份验证。这也适用于作为群组管理员的企业用户。配置此设置会阻止企业用户更改、重置或使用其密码进行身份验证。相反，这些用户可以使用以下方式进行身份验证：

- 用于极狐GitLab Web UI 的群组 SAML IdP。
- 用于极狐GitLab API 和使用 HTTP 基本身份验证的 Git 的个人访问令牌，除非该群组已[为企业用户禁用个人访问令牌](../../profile/personal_access_tokens.md#disable-personal-access-tokens-for-enterprise-users)。

要为企业用户禁用密码和通行密钥身份验证：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的群组。
1. 在左侧边栏中，选择**设置** > **SAML SSO**。
1. 在 **配置** 下，选择 **为企业用户禁用密码和通行密钥身份验证**。
1. 选择 **保存更改**。

<a id="block-user-access"></a>

### 阻止用户访问

要在仅配置了 SAML SSO 时撤销用户对群组的访问权限，可以：

- 按顺序将用户从以下位置移除：
  1. 身份提供商上的用户数据存储或特定应用上的用户列表。
  1. JihuLab.com 群组。
- 在群组的顶级使用[群组同步](group_sync.md#automatic-member-removal)，
  并将默认角色设置为[最小访问](../../permissions.md#users-with-minimal-access)，
  以自动阻止对群组中所有资源的访问。

要在同时使用 SCIM 时撤销用户对群组的访问权限，请参阅[移除访问权限](scim_setup.md#remove-access)。

<a id="unlink-accounts"></a>

### 取消关联账号

用户可以从其个人资料页面取消关联群组的 SAML。这在以下情况下可能有用：

- 您不再希望某个群组能够将您登录到 JihuLab.com。
- 您的 SAML **NameID** 已更改，因此极狐GitLab 无法再找到您的用户。

> [!warning]
> 取消关联账号会移除分配给该用户在群组中的所有角色。
> 如果用户重新关联其账号，则需要重新分配角色。

群组至少需要一个所有者。如果您的账号是群组中唯一的所有者，则不允许取消关联该账号。在这种情况下，请将另一个用户设置为群组所有者，然后您就可以取消关联该账号。

例如，要取消关联 `MyOrg` 账号：

1. 在右上角，选择您的头像。
1. 选择 **编辑个人资料**。
1. 在左侧边栏中，选择 **访问** > **密码和身份验证**。
1. 在 **服务登录** 部分，选择已连接账号旁边的 **断开连接**。

<a id="sso-enforcement"></a>

## SSO 强制

在 JihuLab.com 上，SSO 在以下情况下强制执行：

- 启用 SAML SSO 时。
- 对于在访问组织群组层级中的群组和项目时拥有现有 SAML 身份的用户。通过使用其 JihuLab.com 凭据，用户可以在不通过 SAML SSO 登录的情况下查看其组织之外的其他群组和项目，以及其用户设置。

如果满足以下一个或两个条件，则用户拥有 SAML 身份：

- 他们已使用其极狐GitLab 群组的单点登录 URL 登录极狐GitLab。
- 他们是由 SCIM 预配的。

用户不会在每次访问时都被提示通过 SSO 登录。极狐GitLab 会检查用户是否已通过 SSO 进行身份验证。如果用户上次登录时间超过 24 小时，极狐GitLab 会提示用户再次通过 SSO 登录。

SSO 强制执行如下：

| 项目/群组可见性 | 强制 SSO 设置 | 拥有身份的成员 | 没有身份的成员 | 非成员或未登录 |
|--------------------------|---------------------|----------------------|-------------------------|-----------------------------|
| 私有                  | 关闭                 | 强制             | 不强制            | 不强制                |
| 私有                  | 开启                  | 强制             | 强制                | 强制                    |
| 公开                   | 关闭                 | 强制             | 不强制            | 不强制                |
| 公开                   | 开启                  | 强制             | 强制                | 不强制                |

> [!note]
> SSO 强制不适用于 API 请求。但是，您可以
> [为企业用户禁用密码和通行密钥身份验证](#disable-password-and-passkey-authentication-for-enterprise-users)
> 以防止基于密码的 API 访问。
>
> 有一个[议题提议](https://gitlab.com/gitlab-org/gitlab/-/issues/297389)为 API 活动添加
> SSO 强制。

<a id="sso-only-for-web-activity-enforcement"></a>

### Web 活动仅限 SSO 的强制

当启用 **对此群组的 Web 活动强制实施仅 SSO 身份验证** 选项时：

- 所有成员都必须使用其极狐GitLab 群组的单点登录 URL 访问极狐GitLab
  才能访问群组资源，无论他们是否拥有现有的 SAML
  身份。
- 当用户访问组织群组层级中的群组和项目时，会强制执行 SSO。用户可以在不通过 SAML SSO 登录的情况下查看其组织之外的其他群组和项目。
- 无法手动将用户添加为新成员。
- 拥有所有者角色的用户可以使用标准登录流程对顶级群组设置进行
  必要的更改。
- 对于非成员或未登录的用户：
  - 当他们访问公开群组资源时，不强制执行 SSO。
  - 当他们访问私有群组资源时，强制执行 SSO。
- 对于组织群组层级中的条目，仪表板可见性
  如下：
  - 查看您的[待办事项列表](../../todos.md)时会强制执行 SSO。如果您的 SSO 会话已过期，您的
    待办事项会被隐藏，并会[显示警报](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/115254)。
  - 查看分配给您的议题列表时会强制执行 SSO。如果您的 SSO 会话已过期，您的议题会被
    隐藏。
    [议题 414475](https://gitlab.com/gitlab-org/gitlab/-/issues/414475) 提议更改此
    行为，以便议题可见。
  - 查看您是所指派人或审核人的合并请求时不强制执行 SSO。即使
    您的 SSO 会话已过期，您也可以看到合并请求。
  - 查看您拥有访客、计划者、报告者、开发者、维护者或所有者角色的私有项目的代码片段时不强制执行 SSO。

启用后，Web 活动的 SSO 强制会产生以下影响：

- 对于群组，用户无法在顶级群组之外共享该群组中的项目，
  即使该项目已 forked。
- 源自 CI/CD 作业的 Git 活动不强制执行 SSO 检查。
- 未绑定到常规用户的凭据（例如，项目和群组
  访问令牌、服务账号和部署密钥）不强制执行 SSO 检查。
- 用户必须先通过 SSO 登录，然后才能使用
  [依赖代理](../../packages/dependency_proxy/_index.md)拉取镜像。
- 当启用 **对此群组的 Git 和依赖代理
  活动强制实施仅 SSO 身份验证** 选项时，任何涉及
  Git 活动的 API 端点都受 SSO 强制约束。例如，创建或删除
  分支、提交或标签。对于通过 SSH 和 HTTPS 进行的 Git 活动，用户必须
  至少有一个通过 SSO 登录的活动会话，然后才能推送到或
  从极狐GitLab 代码仓库拉取。活动会话可以在其他设备上。

当强制执行 Web 活动的 SSO 时，非 SSO 群组成员不会立即失去访问权限。如果用户：

- 拥有活动会话，他们可以继续访问该群组最多 24
  小时，直到身份提供商会话超时。
- 已退出登录，则在他们从
  身份提供商中被移除后无法访问该群组。

<a id="repository-mirroring-with-sso-enforcement"></a>

### 带 SSO 强制的代码仓库镜像

当您启用 **对此群组的 Git 和依赖代理活动强制实施仅 SSO 身份验证** 时，
代码仓库镜像受 SSO 会话要求约束。有关更多信息，请参阅
[带 SSO 强制的拉取镜像](../../project/repository/mirror/pull.md#pull-mirroring-with-sso-enforcement)。

<a id="migrate-to-a-new-identity-provider"></a>

## 迁移到新的身份提供商

要迁移到新的身份提供商，请使用 [SAML API](../../../api/saml.md) 更新您所有群组成员的身份。

例如：

1. 设置维护窗口，以确保当时没有用户处于活动状态。
1. 使用 SAML API [更新每个用户的身份](../../../api/saml.md#update-extern_uid-field-for-a-saml-identity)。
1. 配置新的身份提供商。
1. 测试登录是否正常。

> [!NOTE]
> 非企业用户必须在其身份更新后重置其 SAML 密码并[将 SAML 重新关联到其账号](#link-saml-to-your-existing-gitlabcom-account)。

<a id="troubleshooting"></a>

## 故障排除

如果您发现难以匹配极狐GitLab 与身份提供商之间的不同 SAML 术语：

1. 查看您的身份提供商的文档。查看他们的示例 SAML
   配置，以了解他们使用的术语。
1. 查看[极狐GitLab 私有化部署的 SAML SSO 文档](../../../integration/saml.md)。
   极狐GitLab 私有化部署 SAML 配置文件支持的选项
   比 JihuLab.com 文件更多。您可以在以下位置找到有关极狐GitLab 私有化部署实例
   文件的信息：
   - 外部 [OmniAuth SAML 文档](https://github.com/omniauth/omniauth-saml/)。
   - [`ruby-saml` 库](https://github.com/SAML-Toolkits/ruby-saml)。
1. 将来自您的提供商的 XML 响应与 GitLab
   [用于内部测试的示例 XML](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/spec/fixtures/saml/response.xml) 进行比较。

有关其他故障排除信息，请参阅[故障排除 SAML 指南](troubleshooting.md)。
