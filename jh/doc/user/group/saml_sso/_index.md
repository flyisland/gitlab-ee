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
> 对于极狐GitLab 私有化部署，请参阅 [极狐GitLab 私有化部署的 SAML SSO](../../../integration/saml.md)。

用户可以通过其 SAML 身份提供商登录极狐GitLab。

[SCIM](scim_setup.md) 将用户与 JihuLab.com 上的群组同步。

- 当您在 SCIM 应用中添加或移除用户时，SCIM 会相应地将该用户添加到极狐GitLab 群组或从中移除。
- 如果用户还不是群组成员，则会在登录过程中将该用户添加到群组。

您只能为顶级群组配置 SAML SSO。

<a id="set-up-your-identity-provider"></a>

## 设置您的身份提供商

SAML 标准意味着您可以将各种身份提供商与极狐GitLab 配合使用。您的身份提供商可能有相关文档。这些文档可能是通用的 SAML 文档，也可能是专门针对极狐GitLab 的。

设置身份提供商时，请使用以下特定于提供商的文档，以帮助避免常见问题，并作为术语使用指南。

对于未列出的身份提供商，您可以参考[实例 SAML 配置身份提供商的说明](../../../integration/saml.md#configure-saml-on-your-idp)，以进一步了解您的提供商可能需要哪些信息。

极狐GitLab 提供的以下信息仅供参考。
如果您对配置 SAML 应用有任何疑问，请联系提供商的支持部门。

如果您在设置身份提供商时遇到问题，请参阅[故障排除文档](#troubleshooting)。

<a id="azure"></a>

### Azure

要将 Azure 设置为您的身份提供商以进行 SSO：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **设置** > **SAML SSO**。
1. 记下此页面上的信息。
1. 前往 Azure，[创建非库应用程序](https://learn.microsoft.com/en-us/entra/identity/enterprise-apps/overview-application-gallery#create-your-own-application)，并[为应用程序配置 SSO](https://learn.microsoft.com/en-us/entra/identity/enterprise-apps/add-application-portal-setup-sso)。以下极狐GitLab 设置对应 Azure 字段。

   | 极狐GitLab 设置                           | Azure 字段                                    |
   | -----------------------------------------| ---------------------------------------------- |
   | **标识符**                           | **标识符（实体 ID）**                     |
   | **断言使用者服务 URL**       | **回复 URL（断言使用者服务 URL）** |
   | **极狐GitLab 单点登录 URL**            | **登录 URL**                                |
   | **身份提供商单点登录 URL** | **登录 URL**                                  |
   | **证书指纹**              | **指纹**                                  |

1. 您应该设置以下属性：
   - 将 **唯一用户标识符（名称 ID）** 设置为 `user.objectID`。
     - 将 **名称标识符格式** 设置为 `persistent`。有关更多信息，请参阅如何[管理用户 SAML 身份](#manage-user-saml-identity)。
   - 将 **其他声明** 设置为[支持的属性](#configure-assertions)。

1. 确保身份提供商设置为允许提供商发起的调用，以关联现有的极狐GitLab 账户。

1. 可选。如果您使用[群组同步](group_sync.md)，请自定义群组声明的名称以匹配所需属性。

请遵循[为 SCIM 配置 Microsoft Entra ID 的文档](scim_setup.md#configure-microsoft-entra-id)中的说明配置 `objectID` 映射。

有关更多信息，请参阅 [Azure 配置示例](example_saml_config.md#azure-active-directory)。

<a id="google-workspace"></a>

### Google Workspace

要将 Google Workspace 设置为您的身份提供商：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **设置** > **SAML SSO**。
1. 记下此页面上的信息。
1. 按照[使用 Google 作为身份提供商设置 SSO](https://support.google.com/a/answer/6087519?hl=en) 的说明进行操作。以下极狐GitLab 设置对应 Google Workspace 字段。

   | 极狐GitLab 设置                           | Google Workspace 字段 |
   |:-----------------------------------------|:-----------------------|
   | **标识符**                           | **实体 ID**          |
   | **断言使用者服务 URL**       | **ACS URL**            |
   | **极狐GitLab 单点登录 URL**            | **起始 URL**          |
   | **身份提供商单点登录 URL** | **SSO URL**            |

1. Google Workspace 在您检索证书时会显示 SHA256 指纹。如果您之后需要生成 SHA256 指纹，请参阅[计算指纹](troubleshooting.md#calculate-the-fingerprint)。
1. 设置以下值：
   - 对于 **主电子邮件**：`email`。
   - 对于 **名字**：`first_name`。
   - 对于 **姓氏**：`last_name`。
   - 对于 **名称 ID 格式**：`EMAIL`。
   - 对于 **NameID**：`Basic Information > Primary email`。
     有关更多信息，请参阅[支持的属性](#configure-assertions)。

1. 确保身份提供商设置为允许提供商发起的调用，以关联现有的极狐GitLab 账户。

在极狐GitLab SAML SSO 页面上，当您选择 **验证 SAML 配置** 时，请忽略建议将 **NameID** 格式设置为 `persistent` 的警告。

有关更多信息，请参阅 [Google Workspace 配置示例](example_saml_config.md#google-workspace)。


<a id="okta"></a>

### Okta

要将 Okta 设置为您的身份提供商以进行 SSO：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **设置** > **SAML SSO**。
1. 记下此页面上的信息。
1. 按照[在 Okta 中设置 SAML 应用程序](https://developer.okta.com/docs/guides/build-sso-integration/saml2/main/) 的说明进行操作。

   以下极狐GitLab 设置对应 Okta 字段。

   | 极狐GitLab 设置                           | Okta 字段                                                     |
   | ---------------------------------------- | -------------------------------------------------------------- |
   | **标识符**                           | **受众 URI**                                               |
   | **断言使用者服务 URL**       | **单点登录 URL**                                         |
   | **极狐GitLab 单点登录 URL**            | **登录页面 URL**（位于 **应用程序登录页面** 设置下） |
   | **身份提供商单点登录 URL** | **身份提供商单点登录 URL**                       |

1. 在 Okta 的 **单点登录 URL** 字段下，选中 **将此用于接收方 URL 和目标 URL** 复选框。
1. 设置以下值：
   - 对于 **应用程序用户名（NameID）**：**自定义** `user.getInternalProperty("id")`。
   - 对于 **名称 ID 格式**：`Persistent`。有关更多信息，请参阅[管理用户 SAML 身份](#manage-user-saml-identity)。
   - 对于 **email**：`user.email` 或类似值。
   - 对于其他 **属性语句**，请参阅[支持的属性](#configure-assertions)。

1. 确保身份提供商设置为允许提供商发起的调用，以关联现有的极狐GitLab 账户。

应用目录中提供的 Okta GitLab 应用仅支持 [SCIM](scim_setup.md)。对 SAML 的支持在[议题 216173](https://gitlab.com/gitlab-org/gitlab/-/issues/216173) 中提出。


有关更多信息，请参阅 [Okta 配置示例](example_saml_config.md#okta)。

<a id="onelogin"></a>

### OneLogin

OneLogin 支持其自己的 [JihuLab.com 应用程序](https://onelogin.service-now.com/support?id=kb_article&sys_id=08e6b9d9879a6990c44486e5cebb3556&kb_category=50984e84db738300d5505eea4b961913)。

要将 OneLogin 设置为您的身份提供商：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **设置** > **SAML SSO**。
1. 记下此页面上的信息。
1. 如果您使用 OneLogin 通用
   [SAML 测试连接器（高级）](https://onelogin.service-now.com/support?id=kb_article&sys_id=b2c19353dbde7b8024c780c74b9619fb&kb_category=93e869b0db185340d5505eea4b961934)，
   您应该[使用 OneLogin SAML 测试连接器](https://onelogin.service-now.com/support?id=kb_article&sys_id=93f95543db109700d5505eea4b96198f)。以下极狐GitLab 设置对应
   OneLogin 字段：

   | 极狐GitLab 设置                                       | OneLogin 字段                   |
   | ---------------------------------------------------- | -------------------------------- |
   | **标识符**                                       | **受众**                     |
   | **断言使用者服务 URL**                   | **接收方**                    |
   | **断言使用者服务 URL**                   | **ACS（使用者）URL**           |
   | **断言使用者服务 URL（转义版本）** | **ACS（使用者）URL 验证器** |
   | **极狐GitLab 单点登录 URL**                        | **登录 URL**                    |
   | **身份提供商单点登录 URL**             | **SAML 2.0 端点**            |

1. 对于 **NameID**，使用 `OneLogin ID`。有关更多信息，请参阅[管理用户 SAML 身份](#manage-user-saml-identity)。
1. 配置[必需和受支持的属性](#configure-assertions)。
1. 确保身份提供商设置为允许提供商发起的调用，以关联现有的极狐GitLab 账户。

有关更多信息，请参阅 [OneLogin 配置示例](example_saml_config.md#onelogin)。

<a id="keycloak"></a>

### Keycloak

要将 Keycloak 设置为您的身份提供商：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **设置** > **SAML SSO**。
1. 记下此页面上的信息。
1. 按照[在 Keycloak 中创建 SAML 客户端](https://www.keycloak.org/docs/latest/server_admin/index.html#_client-saml-configuration) 的说明进行操作。

以下极狐GitLab 设置对应 Keycloak 字段。

   | 极狐GitLab 设置                           | Keycloak 字段                          |
   |:-----------------------------------------|:------------------------------------------------|
   | **标识符**                           | **客户端 ID**                                   |
   | **断言使用者服务 URL**       | **有效重定向 URI**                         |
   | **断言使用者服务 URL**       | **断言使用者服务 POST 绑定 URL** |
   | **极狐GitLab 单点登录 URL**            | **主页 URL**                                    |

1. 在 Keycloak 中配置您的极狐GitLab 客户端。
   1. 在 Keycloak 中，转到 **客户端** 并选择您的极狐GitLab 客户端配置。
   1. 在 **设置** 选项卡的 **SAML 功能** 部分：
      1. 将 **名称 ID 格式** 设置为 `persistent`。
      1. 开启 **强制名称 ID 格式**。
      1. 开启 **强制 POST 绑定**。
      1. 开启 **包含 AuthnStatement**。
   1. 在 **签名和加密** 部分，开启 **签署文档**。
   1. 在 **密钥** 选项卡上，确保所有部分均已禁用。
   1. 在 **客户端范围** 选项卡上：
      1. 选择极狐GitLab 的客户端范围。范围的名称应类似于 `https://gitlab.com/groups/your-group-name-dedicated`。
      1. 选择 **配置新映射器**，然后在打开的窗口中选择 **用户属性**。
      1. 在 **添加映射器** 页面上，将 **名称**、**用户属性** 和 **SAML 属性名称** 字段设置为 `email`。
      1. 选择 **保存**。
1. 从 Keycloak 检索客户端信息。
   1. 在 **操作** 下拉列表中，选择 **下载适配器配置**。
   1. 在 **下载适配器配置** 对话框中，从下拉列表中选择 **mod-auth-mellon**。
   1. 选择 **下载**。
   1. 解压下载的存档并打开 `idp-metadata.xml`。
   1. 检索身份提供商单点登录 URL。
      1. 找到 `<md:SingleSignOnService>` 标签。
      1. 记下 `Location` 属性的值。
   1. 检索证书指纹。
      1. 记下 `<ds:X509Certificate>` 标签的值。
      1. 将该值复制到单独的文件中，并将其转换为 [PEM 格式](https://www.ssl.com/guide/pem-der-crt-and-cer-x-509-encodings-and-conversions/#ftoc-heading-3)。为此，请在文件开头添加 `-----BEGIN CERTIFICATE-----`，并在文件末尾添加 `-----END CERTIFICATE-----` 作为新行。
      1. [计算指纹](troubleshooting.md#calculate-the-fingerprint)。

<a id="aws-iam-identity-center"></a>

### AWS IAM Identity Center

> [!note]
> AWS IAM Identity Center（前身为 AWS Single Sign-On）不是极狐GitLab 测试过的身份提供商。
> 极狐GitLab 根据客户报告的配置提供以下信息。
> 如果您对在 AWS IAM Identity Center 中配置 SAML 集成有疑问，
> 请联系 [AWS 支持](https://aws.amazon.com/contact-us/)。

AWS IAM Identity Center 默认为 IdP 发起的登录。要关联您现有的极狐GitLab 账户，
您必须配置 SP 发起的登录。有关更多信息，请参阅
[SP 发起的登录](#sp-initiated-login)。

要将 AWS IAM Identity Center 设置为您的身份提供商以进行 SSO：

1. 在顶部栏上，选择 **搜索或跳转到** 并找到您的群组。
1. 选择 **设置** > **SAML SSO**，并记下此页面上的值。
1. 在 AWS IAM Identity Center 控制台中，
   [设置自定义 SAML 2.0 应用程序](https://docs.aws.amazon.com/singlesignon/latest/userguide/customermanagedapps-set-up-your-own-app-saml2.html)。
   当提示输入元数据值时，请输入以下内容：

   | 极狐GitLab 设置                           | AWS IAM Identity Center 字段      |
   | ---------------------------------------- | ---------------------------------- |
   | **断言使用者服务 URL**       | **应用程序 ACS URL**            |
   | **标识符**                           | **应用程序 SAML 受众**      |

1. 要启用 SP 发起的登录，请将 **应用程序起始 URL** 设置为您的
   **极狐GitLab 单点登录 URL**（位于极狐GitLab **SAML SSO** 设置页面上）。

1. 在 **属性映射** 下，配置以下内容：

   | 属性      | 值                | 格式        |
   | -------------- | -------------------- | ------------- |
   | **主题**    | `${user:email}`      | `unspecified` |
   | **email**      | `${user:email}`      | `unspecified` |
   | **first_name** | `${user:givenName}`  | `unspecified` |
   | **last_name**  | `${user:familyName}` | `unspecified` |

   > [!warning]
   > 您必须将 **主题**（NameID）格式设置为 `unspecified`。将格式设置为 `persistent` 或 `transient`
   > 会导致尝试关联其账户的现有极狐GitLab 用户出现身份验证错误。

1. 在 **IAM Identity Center SAML 元数据** 下，复制 **IAM Identity Center 登录 URL**，
   并下载证书。

1. 在您的终端上，从下载的证书生成 SHA1 指纹：

   ```shell
   openssl x509 -noout -fingerprint -sha1 -inform pem -in <path-to-downloaded-cert.pem>
   ```

1. 在极狐GitLab 中，在群组 **SAML SSO** 设置页面上，完成以下字段：
   - **身份提供商单点登录 URL**：输入 **IAM Identity Center 登录 URL**。
   - **证书指纹**：输入 SHA1 指纹值。

1. 在 AWS IAM Identity Center 中，将用户分配到极狐GitLab 应用程序。
   要关联现有的极狐GitLab 账户，用户必须从 **极狐GitLab 单点登录 URL**
   或 **应用程序起始 URL** 登录。

有关更多信息，请参阅
[AWS IAM Identity Center 配置示例](example_saml_config.md#aws-iam-identity-center)。

<a id="sp-initiated-login"></a>

#### SP 发起的登录

当用户通过其身份提供商仪表板（IdP 发起的登录）登录时，SAML
响应不包含 `InResponseTo` 属性。极狐GitLab 需要此属性才能将
SAML 身份关联到现有账户。

AWS IAM Identity Center 默认为 IdP 发起的登录。如果 **应用程序起始 URL** 未配置，现有用户在尝试登录时会看到错误 `Request to link SAML account must be authorized`。

为避免此问题，请将 **应用程序起始 URL** 设置为您的 **极狐GitLab 单点登录 URL**。
这可确保用户从极狐GitLab 开始登录流程，因此 `InResponseTo` 属性会出现在 SAML 响应中。

<a id="configure-assertions"></a>

### 配置断言

> [!note]
> 这些属性不区分大小写。

您至少必须配置以下断言：

1. [NameID](#manage-user-saml-identity)。
1. 电子邮件。

可选地，您可以在 SAML 断言中将用户信息作为属性传递给极狐GitLab。

- 用户的电子邮件地址可以是 **email** 或 **mail** 属性。
- 用户名可以是 **username** 或 **nickname** 属性。您应该只指定其中一个。

有关可用属性的更多信息，请参阅[极狐GitLab 私有化部署的 SAML SSO](../../../integration/saml.md#configure-assertions)。

<a id="use-metadata"></a>

### 使用元数据

要配置某些身份提供商，您需要极狐GitLab 元数据 URL。
要找到此 URL：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **设置** > **SAML SSO**。
1. 复制提供的 **极狐GitLab 元数据 URL**。
1. 按照您的身份提供商的文档，在需要时粘贴元数据 URL。

请查看您的身份提供商的文档，以了解其是否支持极狐GitLab 元数据 URL。

<a id="manage-the-identity-provider"></a>

### 管理身份提供商

设置好身份提供商后，您可以：

- 更改身份提供商。
- 更改电子邮件域名。

<a id="change-the-identity-provider"></a>

#### 更改身份提供商

您可以更改为其他身份提供商。在更改过程中，
用户无法访问任何 SAML 群组。为缓解此问题，您可以禁用
[SSO 强制](#sso-enforcement)。

要更改身份提供商：

1. 使用新的身份提供商[配置](#set-up-your-identity-provider)群组。
1. 可选。如果 **NameID** 不相同，请[更改用户的 **NameID**](#manage-user-saml-identity)。

<a id="change-email-domains"></a>

#### 更改电子邮件域名

要将用户迁移到新的电子邮件域名，请告知用户：

1. [将他们的新电子邮件](../../profile/_index.md#change-your-primary-email) 添加为账户的主电子邮件并验证。
1. 可选。从账户中移除他们的旧电子邮件。

如果 **NameID** 配置为使用电子邮件地址，请[更改用户的 **NameID**](#manage-user-saml-identity)。

<a id="configure-gitlab"></a>

## 配置极狐GitLab

设置好身份提供商以与极狐GitLab 配合使用后，您必须配置极狐GitLab 以将其用于身份验证：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **设置** > **SAML SSO**。
1. 完成字段：
   - 在 **身份提供商单点登录 URL** 字段中，输入来自您的身份提供商的 SSO URL。
   - 在 **证书指纹** 字段中，输入 SAML 令牌签名证书的指纹。
1. 对于 JihuLab.com 上的群组：在 **默认成员角色** 字段中，选择：
   1. 要分配给新用户的角色。
   1. 当为群组配置了 SAML 群组链接时，要分配给
      [不属于映射 SAML 群组成员](group_sync.md#automatic-member-removal)
      的用户的角色。
1. 对于极狐GitLab 私有化部署实例上的群组：在 **默认成员角色** 字段中，
   选择要分配给新用户的角色。
   默认角色是 **访客**。该角色将成为添加到群组的所有用户的起始角色。群组所有者可以设置[自定义角色](../../custom_roles/_index.md)
   作为默认成员角色。
1. 选中 **为此群组启用 SAML 身份验证** 复选框。
1. 推荐。选择：
   - 在极狐GitLab 17.4 及更高版本中，**为企业用户禁用密码和通行密钥身份验证**。
     有关更多信息，请参阅[为企业用户禁用密码和通行密钥身份验证文档](#disable-password-and-passkey-authentication-for-enterprise-users)。
   - **为此群组的 Web 活动强制仅限 SSO 身份验证**。
   - **为此群组的 Git 和依赖代理活动强制仅限 SSO 身份验证**。
     有关更多信息，请参阅 [SSO 强制文档](#sso-enforcement)。
1. 选择 **保存更改**。

如果您在配置极狐GitLab 时遇到问题，请参阅[故障排除文档](#troubleshooting)。

<a id="user-access-and-management"></a>

## 用户访问和管理

配置并启用群组 SSO 后，用户可以通过身份提供商的仪表板访问 JihuLab.com 群组。
如果配置了 [SCIM](scim_setup.md)，请参阅 SCIM 页面上的[用户访问](scim_setup.md#user-access)。

当用户尝试使用群组 SSO 登录时，极狐GitLab 会尝试根据以下内容查找或创建用户：

- 查找具有匹配 SAML 身份的现有用户。这意味着该用户要么是通过 [SCIM](scim_setup.md) 创建账户的，要么之前曾使用群组的 SAML IdP 登录过。
- 如果不存在具有相同电子邮件地址的账户，则自动创建一个新账户。极狐GitLab 会尝试匹配主电子邮件地址和辅助电子邮件地址。
- 如果已存在具有相同电子邮件地址的账户，则将用户重定向到登录页面以：
  - 使用其他电子邮件地址创建新账户。
  - 登录其现有账户以关联 SAML 身份。

<a id="provisioning-behavior-with-restricted-access"></a>

### 受限访问下的预配行为

当启用[受限访问](../../../subscriptions/manage_seats.md#restricted-access)且没有可用席位时，通过 SAML 预配的用户将被分配最低访问权限角色。

有关更多信息，请参阅[使用 SAML、SCIM 和 LDAP 的预配行为](../../../subscriptions/manage_seats.md#provisioning-behavior-with-saml-scim-and-ldap)。

<a id="link-saml-to-your-existing-gitlabcom-account"></a>

### 将 SAML 关联到您现有的 JihuLab.com 账户

> [!note]
> 如果用户是该群组的[企业用户](../../enterprise_user/_index.md)，则以下步骤不适用。企业用户必须改为[使用与极狐GitLab 账户具有相同电子邮件的 SAML 账户登录](#automatic-identity-linking-for-enterprise-users)。这允许极狐GitLab 将 SAML 账户关联到现有账户。

要将 SAML 关联到您现有的 JihuLab.com 账户：

1. 登录您的 JihuLab.com 账户。如有必要，请[重置您的密码](https://gitlab.com/users/password/new)。
1. 找到并访问您要登录的群组的 **极狐GitLab 单点登录 URL**。群组所有者可以在群组的 **设置** > **SAML SSO** 页面上找到此 URL。
   如果配置了登录 URL，用户可以从身份提供商连接到极狐GitLab 应用。
1. 可选。选中 **记住我** 复选框以在 2 周内保持登录极狐GitLab。
   您可能仍会被要求更频繁地通过 SAML 提供商重新进行身份验证。
1. 选择 **授权**。
1. 如果提示，请在身份提供商上输入您的凭据。
1. 然后您将被重定向回 JihuLab.com，并且应该可以访问该群组。
   将来，您可以使用 SAML 登录 JihuLab.com。

如果用户已经是群组成员，关联 SAML 身份不会更改其角色。

在后续访问中，您应该能够[使用 SAML 登录 JihuLab.com](#sign-in-to-gitlabcom-with-saml)
或直接访问链接。如果启用了 **强制 SSO** 选项，您将被重定向到通过身份提供商登录。

<a id="automatic-identity-linking-for-enterprise-users"></a>

#### 企业用户的自动身份关联

如果企业用户被从群组中移除后又返回，他们可以使用其企业 SSO 账户登录。
只要用户在身份提供商中的电子邮件地址与现有极狐GitLab 账户上的电子邮件地址相同，SSO 身份就会自动关联到该账户，用户即可毫无问题地登录。
此功能也适用于已被声明为企业用户但可能尚未登录群组的现有用户。

<a id="sign-in-to-gitlabcom-with-saml"></a>

### 使用 SAML 登录 JihuLab.com

1. 登录您的身份提供商。
1. 在应用列表中，选择“JihuLab.com”应用。（名称由身份提供商的管理员设置。）
1. 然后您将登录 JihuLab.com 并重定向到该群组。

<a id="manage-user-saml-identity"></a>

### 管理用户 SAML 身份

JihuLab.com 使用 SAML **NameID** 来识别用户。**NameID** 是：

- SAML 响应中的必填字段。
- 不区分大小写。

**NameID** 必须：

- 对每个用户唯一。
- 是一个永不变更的持久值，例如随机生成的唯一用户 ID。
- 在后续登录尝试中完全匹配，因此不应依赖于可能在大写和小写之间变化的用户输入。

**NameID** 不应是电子邮件地址或用户名，因为：

- 电子邮件地址和用户名更有可能随时间变化。例如，
  当一个人的姓名发生变化时。
- 电子邮件地址不区分大小写，这可能导致用户无法登录。

**NameID** 格式必须为 `Persistent`，除非您使用的字段（如电子邮件）需要不同的格式。您可以使用除 `Transient` 之外的任何格式。

<a id="change-user-nameid"></a>

#### 更改用户 **NameID**

群组所有者可以使用 [SAML API](../../../api/saml.md#update-extern_uid-field-for-a-saml-identity) 更改其群组成员的 **NameID** 并更新其 SAML 身份。

> [!warning]
> 通过 API 更新 `extern_uid` 会将 SAML 身份标记为不受信任。受影响的用户无法使用 SAML 登录，直到他们[将账户重新关联到新的 SAML 应用](#link-saml-to-your-existing-gitlabcom-account)。

如果配置了 [SCIM](scim_setup.md)，群组所有者可以使用 [SCIM API](../../../api/scim.md#update-extern_uid-field-for-a-scim-identity) 更新 SCIM 身份。

或者，请用户重新关联其 SAML 账户。

1. 请相关用户[取消其账户与群组的关联](#unlink-accounts)。
1. 请相关用户[将其账户关联到新的 SAML 应用](#link-saml-to-your-existing-gitlabcom-account)。

> [!warning]
> 用户使用 SSO SAML 登录极狐GitLab 后，更改 **NameID** 值会破坏配置，并可能将用户锁定在极狐GitLab 群组之外。

有关特定身份提供商的推荐值和格式的更多信息，请参阅[设置您的身份提供商](#set-up-your-identity-provider)。

<a id="configure-enterprise-user-settings-from-saml-response"></a>

### 从 SAML 响应配置企业用户设置

极狐GitLab 允许根据 SAML 响应中的值设置某些用户属性。
如果现有用户是该群组的[企业用户](../../enterprise_user/_index.md)，则会根据 SAML 响应值更新其属性。

<a id="supported-user-attributes"></a>

#### 支持的用户属性

- `can_create_group` - `true` 或 `false`，用于指示企业用户是否可以创建新的顶级群组。默认值为 `true`。
- `projects_limit` - 企业用户可以创建的个人项目总数。
  值为 `0` 表示用户无法在其个人命名空间中创建新项目。默认值为 `100000`。
- `SessionNotOnOrAfter` - 一个 ISO 8601 时间戳值，指示何时结束用户 SAML 会话。

<a id="example-saml-response"></a>

#### 示例 SAML 响应

您可以在浏览器的开发者工具或控制台中找到 SAML 响应，
格式为 base64 编码。使用您选择的 base64 解码工具将信息转换为 XML。此处显示了一个示例 SAML 响应。

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

默认情况下，极狐GitLab 会在 24 小时后结束 SAML 会话。您可以使用
SAML2 AuthnStatement 中的 `SessionNotOnOrAfter` 属性自定义此持续时间。此属性包含一个
ISO 8601 时间戳值，指示何时结束用户会话。指定此值后，它将覆盖默认的 24 小时 SAML 会话超时。

默认情况下，极狐GitLab 会在不活动七天后（10080 分钟）结束会话。如果
`SessionNotOnOrAfter` 时间戳晚于此时间，用户必须在其会话结束时重新进行身份验证。

<a id="example-response"></a>

#### 示例响应

```xml
   <saml:AuthnStatement SessionIndex="WDE5aBYjNEj_9IjCFiK0E1YelZT" SessionNotOnOrAfter="2025-08-25T01:23:45.067Z" AuthnInstant="2025-08-24T13:23:45.067Z">
      <saml:AuthnContext>
         <saml:AuthnContextClassRef>urn:oasis:names:tc:SAML:2.0:ac:classes:unspecified</saml:AuthnContextClassRef>
      </saml:AuthnContext>
   </saml:AuthnStatement>
```

<a id="bypass-user-email-confirmation-with-verified-domains"></a>

### 使用已验证域名绕过用户电子邮件确认

默认情况下，通过 SAML 或 SCIM 预配的用户会收到一封验证电子邮件以验证其身份。您可以改为
[使用自定义域配置极狐GitLab](../../enterprise_user/_index.md#add-group-domains)，极狐GitLab
会自动确认用户账户。用户仍会收到一封
[企业用户](../../enterprise_user/_index.md) 欢迎电子邮件。如果以下两个条件均成立，则绕过确认：

- 用户是通过 SAML 或 SCIM 预配的。
- 用户的电子邮件地址属于已验证域名。

> [!note]
> 电子邮件地址不在已验证域名内的预配用户仍处于未确认状态。
> 如果启用了[自动删除未确认用户](../../../administration/moderate_users.md#automatically-delete-unconfirmed-users)，
> 极狐GitLab 可以删除这些用户。

<a id="disable-password-and-passkey-authentication-for-enterprise-users"></a>

### 为企业用户禁用密码和通行密钥身份验证

先决条件：

- 您必须对企业用户所属的群组具有所有者角色。
- 必须启用群组 SSO。

您可以禁用群组所有[企业用户](../../enterprise_user/_index.md)的密码身份验证。这也适用于作为群组管理员的企业用户。配置此设置后，企业用户将无法更改、重置或使用其密码进行身份验证。相反，这些用户可以使用以下方式进行身份验证：

- 用于极狐GitLab Web UI 的群组 SAML IdP。
- 用于极狐GitLab API 和基于 HTTP 基本身份验证的 Git 的个人访问令牌，除非群组已[为企业用户禁用个人访问令牌](../../profile/personal_access_tokens.md#disable-personal-access-tokens-for-enterprise-users)。

要为企业用户禁用密码和通行密钥身份验证：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **设置** > **SAML SSO**。
1. 在 **配置** 下，选择 **为企业用户禁用密码和通行密钥身份验证**。
1. 选择 **保存更改**。

<a id="block-user-access"></a>

### 阻止用户访问

当仅配置了 SAML SSO 时，要撤销用户对群组的访问权限，您可以：

- 按顺序将用户从以下位置移除：
  1. 身份提供商上的用户数据存储或特定应用的用户列表。
  1. JihuLab.com 群组。
- 在群组顶层使用[群组同步](group_sync.md#automatic-member-removal)，并将默认角色设置为[最低访问权限](../../permissions.md#users-with-minimal-access)
  以自动阻止对群组中所有资源的访问。

当同时使用 SCIM 时，要撤销用户对群组的访问权限，请参阅[移除访问权限](scim_setup.md#remove-access)。

<a id="unlink-accounts"></a>

### 取消账户关联

用户可以从其个人资料页面取消群组的 SAML 关联。这在以下情况下可能很有用：

- 您不再希望某个群组能够让您登录 JihuLab.com。
- 您的 SAML **NameID** 已更改，因此极狐GitLab 无法再找到您的用户。

> [!warning]
> 取消账户关联会移除该用户在群组中被分配的所有角色。
> 如果用户重新关联其账户，则需要重新分配角色。

群组至少需要一个所有者。如果您的账户是群组中唯一的所有者，
则不允许您取消账户关联。在这种情况下，请将另一个用户设置为群组所有者，然后您就可以取消账户关联。

例如，要取消关联 `MyOrg` 账户：

1. 在右上角，选择您的头像。
1. 选择 **编辑个人资料**。
1. 在左侧边栏中，选择 **访问** > **密码和身份验证**。
1. 在 **服务登录** 部分，选择已连接账户旁边的 **断开连接**。

<a id="sso-enforcement"></a>

## SSO 强制

在 JihuLab.com 上，SSO 在以下情况下被强制：

- 当 SAML SSO 启用时。
- 对于在访问组织群组层级中的群组和项目时具有现有 SAML 身份的用户。通过使用其 JihuLab.com 凭据，用户可以在不通过 SAML SSO 登录的情况下查看其组织外部的其他群组和项目，以及其用户设置。

如果满足以下任一条件，则用户具有 SAML 身份：

- 他们使用其极狐GitLab 群组的单点登录 URL 登录了极狐GitLab。
- 他们是由 SCIM 预配的。

用户不会在每次访问时都被提示通过 SSO 登录。极狐GitLab 会检查用户是否已通过 SSO 进行身份验证。如果用户上次登录时间超过
24 小时，极狐GitLab 会提示用户再次通过 SSO 登录。

SSO 强制如下：

| 项目/群组可见性 | 强制 SSO 设置 | 具有身份的成员 | 不具有身份的成员 | 非成员或未登录 |
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
> 一个[议题建议](https://gitlab.com/gitlab-org/gitlab/-/issues/297389)为
> API 活动添加 SSO 强制。

<a id="sso-only-for-web-activity-enforcement"></a>

### 仅限 Web 活动的 SSO 强制

当启用 **为此群组的 Web 活动强制仅限 SSO 身份验证** 选项时：

- 所有成员必须使用其极狐GitLab 群组的单点登录 URL 访问极狐GitLab
  才能访问群组资源，无论他们是否具有现有的 SAML
  身份。
- 当用户访问组织群组层级中的群组和项目时，会强制 SSO。用户可以在不通过 SAML SSO 登录的情况下查看其组织外部的其他群组和项目。
- 无法手动添加新成员。
- 具有所有者角色的用户可以使用标准登录流程对顶级群组设置进行必要的更改。
- 对于非成员或未登录的用户：
  - 访问公共群组资源时不强制 SSO。
  - 访问私有群组资源时强制 SSO。
- 对于组织群组层级中的条目，仪表板可见性如下：
  - 查看您的[待办事项列表](../../todos.md)时强制 SSO。如果您的 SSO 会话已过期，您的待办事项将被隐藏，并会[显示警报](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/115254)。
  - 查看您被分配的议题列表时强制 SSO。如果您的 SSO 会话已过期，您的议题将被隐藏。
    [议题 414475](https://gitlab.com/gitlab-org/gitlab/-/issues/414475) 建议更改此行为，使议题可见。
  - 查看您是指派人或审核人的合并请求时不强制 SSO。即使您的 SSO 会话已过期，您也可以看到合并请求。
  - 查看您具有访客、计划者、报告者、开发者、维护者或所有者角色的私有项目的代码片段时不强制 SSO。

启用后，Web 活动的 SSO 强制具有以下影响：

- 对于群组，用户无法在顶级群组之外共享群组中的项目，即使该项目是派生项目。
- 源自 CI/CD 作业的 Git 活动不强制执行 SSO 检查。
- 与普通用户无关的凭据（例如项目和群组访问令牌、服务账号和部署密钥）不强制执行 SSO 检查。
- 用户必须先通过 SSO 登录，然后才能使用[依赖代理](../../packages/dependency_proxy/_index.md)拉取镜像。
- 当启用 **为此群组的 Git 和依赖代理活动强制仅限 SSO 身份验证** 选项时，任何涉及 Git 活动的 API 端点都受 SSO 强制约束。例如，创建或删除分支、提交或标签。对于通过 SSH 和 HTTPS 进行的 Git 活动，用户必须至少有一个通过 SSO 登录的活动会话，然后才能推送到或从极狐GitLab 代码仓库拉取。活动会话可以在不同的设备上。

当强制 Web 活动的 SSO 时，非 SSO 群组成员不会立即失去访问权限。如果用户：

- 有活动会话，他们可以在最多 24 小时内继续访问群组，直到身份提供商会话超时。
- 已注销，则他们在从身份提供商中移除后无法访问群组。

<a id="repository-mirroring-with-sso-enforcement"></a>

### 启用 SSO 强制的代码仓库镜像

当您启用 **为此群组的 Git 和依赖代理活动强制仅限 SSO 身份验证** 时，
代码仓库镜像受 SSO 会话要求约束。有关更多信息，请参阅
[启用 SSO 强制的拉取镜像](../../project/repository/mirror/pull.md#pull-mirroring-with-sso-enforcement)。

<a id="migrate-to-a-new-identity-provider"></a>

## 迁移到新的身份提供商

要迁移到新的身份提供商，请使用 [SAML API](../../../api/saml.md) 更新所有群组成员的身份。

例如：

1. 设置一个维护窗口，以确保此时没有用户处于活动状态。
1. 使用 SAML API [更新每个用户的身份](../../../api/saml.md#update-extern_uid-field-for-a-saml-identity)。
1. 配置新的身份提供商。
1. 测试登录是否正常。

> [!NOTE]
> 非企业用户必须在其身份更新后重置其 SAML 密码并[将 SAML 重新关联到其账户](#link-saml-to-your-existing-gitlabcom-account)。

<a id="troubleshooting"></a>

## 故障排除

如果您发现难以匹配极狐GitLab 和身份提供商之间的不同 SAML 术语：

1. 查看您的身份提供商的文档。查看他们的示例 SAML
   配置以了解他们使用的术语。
1. 查看[极狐GitLab 私有化部署的 SAML SSO 文档](../../../integration/saml.md)。
   极狐GitLab 私有化部署 SAML 配置文件比 JihuLab.com 文件支持更多选项。您可以在以下位置找到有关极狐GitLab 私有化部署实例文件的信息：
   - 外部 [OmniAuth SAML 文档](https://github.com/omniauth/omniauth-saml/)。
   - [`ruby-saml` 库](https://github.com/SAML-Toolkits/ruby-saml)。
1. 将您提供商返回的 XML 响应与
   [GitLab 用于内部测试的示例 XML](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/spec/fixtures/saml/response.xml) 进行比较。

有关其他故障排除信息，请参阅 [SAML 故障排除指南](troubleshooting.md)。
