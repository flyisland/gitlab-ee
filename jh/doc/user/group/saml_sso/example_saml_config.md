---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 群组 SAML 和 SCIM 配置示例
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

以下是极狐GitLab 支持团队在故障排除时有时会使用、但不适合放入官方文档的关于群组 SAML 和 SCIM 的笔记和屏幕截图。极狐GitLab 将其公开，以便任何人都能利用支持团队收集的知识。

有关该功能及其设置方法的信息，请参阅极狐GitLab [群组 SAML](_index.md) 文档。

在对 SAML 配置进行故障排除时，GitLab 团队成员通常会从 [SAML 故障排除部分](_index.md#troubleshooting)开始。

然后，他们可能会为所需的身份提供商设置测试配置。我们在本节中提供了示例屏幕截图。

<a id="saml-and-scim-screenshots"></a>

## SAML 和 SCIM 屏幕截图

本节包含以下[群组 SAML](_index.md) 和[群组 SCIM](scim_setup.md) 示例配置的相关屏幕截图：

- [Azure Active Directory](#azure-active-directory)
- [AWS IAM Identity Center](#aws-iam-identity-center)
- [Google Workspace](#google-workspace)
- [Okta](#okta)
- [OneLogin](#onelogin)

> [!warning]
> 这些屏幕截图仅在极狐GitLab 支持团队需要时更新。它们不是官方文档。

如果您当前在使用极狐GitLab 时遇到问题，不妨查看您的[支持选项](https://gitlab.cn/support)。

<a id="azure-active-directory"></a>

## Azure Active Directory

本节包含 Azure Active Directory 配置各元素的屏幕截图。

<a id="basic-saml-app-configuration"></a>

### 基本 SAML 应用配置

![Azure Active Directory 中的基本 SAML 配置设置。](img/AzureAD-basic_SAML_v14_1.png)

<a id="user-claims-and-attributes"></a>

### 用户声明和属性

![Azure Active Directory 中的用户声明和属性配置。](img/AzureAD-claims_v14_1.png)

<a id="scim-mapping"></a>

### SCIM 映射

预配：

![Azure Active Directory 中的 SCIM 预配设置。](img/AzureAD-scim_provisioning_v14_8.png)

<a id="attribute-mapping"></a>

### 属性映射

![Azure Active Directory 中的 SCIM 属性映射配置。](img/AzureAD-scim_attribute_mapping_v12_2.png)

<a id="group-sync"></a>

### 群组同步

![Azure Active Directory 中 SAML 的群组声明配置。](img/azure_configure_group_claim_v14_0.png)

使用 **群组 ID** 源属性要求用户在配置 SAML 群组链接时输入群组 ID 或对象 ID。

如果可用，您可以改为添加用户友好的群组名称。在设置 Azure 群组声明时：

1. 选择 **sAMAccountName** 源属性。
1. 输入群组名称。您可以指定最长 256 个字符的名称。
1. 为确保该属性是断言的一部分，请选择 **仅为云专用群组发出群组名称**。

[Azure AD 限制 SAML 响应中可发送的群组数量为 150 个](https://support.esri.com/en-us/knowledge-base/when-azure-ad-is-the-saml-identify-provider-the-group-a-000022190)。如果用户是超过 150 个群组的成员，Azure 不会在 SAML 响应中包含该用户的群组声明。

<a id="google-workspace"></a>

## Google Workspace

<a id="basic-saml-app-configuration-1"></a>

### 基本 SAML 应用配置

![Google Workspace 中的基本 SAML 应用配置设置。](img/GoogleWorkspace-basic-SAML_v14_10.png)

<a id="user-claims-and-attributes-1"></a>

### 用户声明和属性

![Google Workspace 中的用户声明和属性配置。](img/GoogleWorkspace-claims_v14_10.png)

<a id="idp-links-and-certificate"></a>

### 身份提供商链接和证书

![Google Workspace 中的身份提供商链接和证书设置。](img/GoogleWorkspace-linkscert_v14_10.png)

<a id="okta"></a>

## Okta

<a id="basic-saml-app-configuration-for-gitlabcom-groups"></a>

### JihuLab.com 群组的基本 SAML 应用配置

![Okta 中 JihuLab.com 群组的基本 SAML 应用配置设置。](img/Okta-GroupSAML_v15_3.png)

<a id="basic-saml-app-configuration-for-gitlab-self-managed"></a>

### 极狐GitLab 私有化部署的基本 SAML 应用配置

![Okta 管理面板中极狐GitLab 私有化部署的基本 SAML 应用配置设置。](img/Okta-SM_v15_3.png)

<a id="user-claims-and-attributes-2"></a>

### 用户声明和属性

![Okta 中的用户声明和属性配置。](img/Okta-attributes_v15_3.png)

<a id="group-sync-1"></a>

### 群组同步

![Okta 中用于群组同步的群组属性配置。](img/Okta-GroupAttribute_v15_3.png)

<a id="advanced-saml-app-settings-defaults"></a>

### 高级 SAML 应用设置（默认值）

![Okta 中的高级 SAML 应用设置及其默认值。](img/Okta-advancedsettings_v15_3.png)

<a id="idp-links-and-certificate-1"></a>

### 身份提供商链接和证书

![Okta 中的身份提供商链接和证书设置。](img/Okta-linkscert_v15_3.png)

<a id="saml-sign-on-settings"></a>

### SAML 登录设置

![Okta 配置中的 SAML 登录设置。](img/okta_saml_settings_v15_3.png)

<a id="scim-settings"></a>

### SCIM 设置

在为新建用户分配 SCIM 应用时设置其用户名：

![Okta 中为用户分配 SCIM 应用并设置其用户名的界面。](img/okta_setting_username_v14_6.png)

<a id="onelogin"></a>

## OneLogin

<a id="basic-saml-app-configuration-2"></a>

### 基本 SAML 应用配置

![OneLogin 中的基本应用详情和配置设置。](img/OneLogin-app_details_v12_8.png)

<a id="parameters"></a>

### 参数

![OneLogin 中的应用参数和属性映射设置。](img/OneLogin-parameters_v12_8.png)

<a id="adding-a-user"></a>

### 添加用户

![OneLogin 中向应用添加用户的界面。](img/OneLogin-userAdd_v12_8.png)

<a id="sso-settings"></a>

### SSO 设置

![OneLogin 中的单点登录设置和证书配置。](img/OneLogin-SSOsettings_v12_8.png)

<a id="aws-iam-identity-center"></a>

## AWS IAM Identity Center

使用下表中的值配置 AWS IAM Identity Center。
有关完整的设置说明，请参阅 [AWS IAM Identity Center](_index.md#aws-iam-identity-center)。

<a id="application-properties"></a>

### 应用程序属性

在 AWS IAM Identity Center 中设置您自己的 SAML 2.0 应用程序时，
请配置以下应用程序属性：

| AWS Identity Center 字段       | 值                                                                                         |
| ------------------------------- | --------------------------------------------------------------------------------------------- |
| **应用程序 ACS URL**         | 您群组的 **断言消费者服务 URL**（来自极狐GitLab **SAML SSO** 设置）           |
| **应用程序 SAML 受众**   | 您群组的 **标识符**（来自极狐GitLab **SAML SSO** 设置）                               |
| **应用程序启动 URL**       | 您群组的 **极狐GitLab 单点登录 URL**（来自极狐GitLab **SAML SSO** 设置）                |

为 SP 发起的登录设置 **应用程序启动 URL**。
如果不设置，现有用户将无法关联其账号。

<a id="attribute-mappings"></a>

### 属性映射

| 属性      | 值                | 格式        |
| -------------- | -------------------- | ------------- |
| **主体**    | `${user:email}`      | `unspecified` |
| **email**      | `${user:email}`      | `unspecified` |
| **first_name** | `${user:givenName}`  | `unspecified` |
| **last_name**  | `${user:familyName}` | `unspecified` |

> [!warning]
> 您必须将 **主体**（NameID）格式设置为 `unspecified`。如果将格式设置为
> `persistent` 或 `transient`，现有极狐GitLab 用户在尝试
> 通过 SAML 关联其账号时会收到 `403` 错误。此错误仅在账号关联期间发生，
> 不会影响通过 AWS IAM Identity Center 预配的新用户。

<a id="gitlab-saml-sso-settings"></a>

### 极狐GitLab SAML SSO 设置

| 极狐GitLab 字段                             | 值                                                                           |
| ---------------------------------------- | ------------------------------------------------------------------------------- |
| **身份提供商单点登录 URL** | **IAM Identity Center 登录 URL**（来自应用程序的 **IAM Identity Center SAML 元数据** 部分）|
| **证书指纹**              | 从 AWS Identity Center 下载的证书的 SHA1 指纹         |

<a id="saml-response-example"></a>

## SAML 响应示例

当用户使用 SAML 登录时，极狐GitLab 会收到一个 SAML 响应。该 SAML 响应可在 `production.log` 日志中找到，形式为 base64 编码的消息。通过搜索 `SAMLResponse` 来定位该响应。解码后的 SAML 响应为 XML 格式。例如：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<saml2p:Response xmlns:saml2p="urn:oasis:names:tc:SAML:2.0:protocol" xmlns:xs="http://www.w3.org/2001/XMLSchema" Destination="https://gitlabexample/-/saml/callback" ID="id4898983630840142426821432" InResponseTo="_c65e4c88-9425-4472-b42c-37f4186ac0ee" IssueInstant="2022-05-30T21:30:35.696Z" Version="2.0">
 <saml2:Issuer xmlns:saml2="urn:oasis:names:tc:SAML:2.0:assertion" Format="urn:oasis:names:tc:SAML:2.0:nameid-format:entity">http://www.okta.com/exk2y6j57o1Pdr2lI8qh7</saml2:Issuer>
 <ds:Signature xmlns:ds="http://www.w3.org/2000/09/xmldsig#">
   <ds:SignedInfo>
     <ds:CanonicalizationMethod Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#"/>
     <ds:SignatureMethod Algorithm="http://www.w3.org/2001/04/xmldsig-more#rsa-sha256"/>
     <ds:Reference URI="#id4898983630840142426821432">
       <ds:Transforms>
         <ds:Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"/>
         <ds:Transform Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#">
           <ec:InclusiveNamespaces xmlns:ec="http://www.w3.org/2001/10/xml-exc-c14n#" PrefixList="xs"/>
         </ds:Transform>
       </ds:Transforms>
       <ds:DigestMethod Algorithm="http://www.w3.org/2001/04/xmlenc#sha256"/>
       <ds:DigestValue>neiQvv9d3OgS4GZW8Nptp4JhjpKs3GCefibn+vmRgk4=</ds:DigestValue>
     </ds:Reference>
   </ds:SignedInfo>
   <ds:SignatureValue>dMsQX8ivi...HMuKGhyLRvabGU6CuPrf7==</ds:SignatureValue>
   <ds:KeyInfo>
     <ds:X509Data>
       <ds:X509Certificate>MIIDq...cptGr3vN9TQ==</ds:X509Certificate>
     </ds:X509Data>
   </ds:KeyInfo>
 </ds:Signature>
 <saml2p:Status xmlns:saml2p="urn:oasis:names:tc:SAML:2.0:protocol">
   <saml2p:StatusCode Value="urn:oasis:names:tc:SAML:2.0:status:Success"/>
 </saml2p:Status>
 <saml2:Assertion xmlns:saml2="urn:oasis:names:tc:SAML:2.0:assertion" xmlns:xs="http://www.w3.org/2001/XMLSchema" ID="id489" IssueInstant="2022-05-30T21:30:35.696Z" Version="2.0">
   <saml2:Issuer xmlns:saml2="urn:oasis:names:tc:SAML:2.0:assertion" Format="urn:oasis:names:tc:SAML:2.0:nameid-format:entity">http://www.okta.com/exk2y6j57o1Pdr2lI8qh7</saml2:Issuer>
   <ds:Signature xmlns:ds="http://www.w3.org/2000/09/xmldsig#">
     <ds:SignedInfo>
       <ds:CanonicalizationMethod Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#"/>
       <ds:SignatureMethod Algorithm="http://www.w3.org/2001/04/xmldsig-more#rsa-sha256"/>
       <ds:Reference URI="#id48989836309833801859473359">
         <ds:Transforms>
           <ds:Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"/>
           <ds:Transform Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#">
             <ec:InclusiveNamespaces xmlns:ec="http://www.w3.org/2001/10/xml-exc-c14n#" PrefixList="xs"/>
           </ds:Transform>
         </ds:Transforms>
         <ds:DigestMethod Algorithm="http://www.w3.org/2001/04/xmlenc#sha256"/>
         <ds:DigestValue>MaIsoi8hbT9gsi/mNZsz449mUuAcuEWY0q3bc4asOQs=</ds:DigestValue>
       </ds:Reference>
     </ds:SignedInfo>
     <ds:SignatureValue>dMsQX8ivi...HMuKGhyLRvabGU6CuPrf7==</ds:SignatureValue>
     <ds:KeyInfo>
       <ds:X509Data>
         <ds:X509Certificate>MIIDq...cptGr3vN9TQ==</ds:X509Certificate>
       </ds:X509Data>
     </ds:KeyInfo>
   </ds:Signature>
   <saml2:Subject xmlns:saml2="urn:oasis:names:tc:SAML:2.0:assertion">
     <saml2:NameID Format="urn:oasis:names:tc:SAML:2.0:nameid-format:persistent">useremail@domain.com</saml2:NameID>
     <saml2:SubjectConfirmation Method="urn:oasis:names:tc:SAML:2.0:cm:bearer">
       <saml2:SubjectConfirmationData InResponseTo="_c65e4c88-9425-4472-b42c-37f4186ac0ee" NotOnOrAfter="2022-05-30T21:35:35.696Z" Recipient="https://gitlab.example.com/-/saml/callback"/>
     </saml2:SubjectConfirmation>
   </saml2:Subject>
   <saml2:Conditions xmlns:saml2="urn:oasis:names:tc:SAML:2.0:assertion" NotBefore="2022-05-30T21:25:35.696Z" NotOnOrAfter="2022-05-30T21:35:35.696Z">
     <saml2:AudienceRestriction>
       <saml2:Audience>https://gitlab.example.com/</saml2:Audience>
     </saml2:AudienceRestriction>
   </saml2:Conditions>
   <saml2:AuthnStatement xmlns:saml2="urn:oasis:names:tc:SAML:2.0:assertion" AuthnInstant="2022-05-30T21:30:35.696Z" SessionIndex="_c65e4c88-9425-4472-b42c-37f4186ac0ee">
     <saml2:AuthnContext>
       <saml2:AuthnContextClassRef>urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport</saml2:AuthnContextClassRef>
     </saml2:AuthnContext>
   </saml2:AuthnStatement>
   <saml2:AttributeStatement xmlns:saml2="urn:oasis:names:tc:SAML:2.0:assertion">
     <saml2:Attribute Name="email" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:unspecified">
       <saml2:AttributeValue xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="xs:string">useremail@domain.com</saml2:AttributeValue>
     </saml2:Attribute>
     <saml2:Attribute Name="firstname" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:unspecified">
       <saml2:AttributeValue xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="xs:string">John</saml2:AttributeValue>
     </saml2:Attribute>
     <saml2:Attribute Name="lastname" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:unspecified">
       <saml2:AttributeValue xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="xs:string">Doe</saml2:AttributeValue>
     </saml2:Attribute>
     <saml2:Attribute Name="Groups" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:unspecified">
       <saml2:AttributeValue xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="xs:string">Super-awesome-group</saml2:AttributeValue>
     </saml2:Attribute>
   </saml2:AttributeStatement>
 </saml2:Assertion>
</saml2p:Response>
```
