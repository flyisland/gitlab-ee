---
stage: Plan
group: Planner Intelligence
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: GitLab Pages 自定义域名
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以使用自定义域名：

- 与 GitLab Pages 一起使用。
- 用于[绕过通过 SAML 或 SCIM 预配的用户的邮箱确认](../../../group/saml_sso/_index.md#bypass-user-email-confirmation-with-verified-domains)。
  以这种方式使用自定义域名时，您使用了 GitLab Pages 功能，但可以跳过[先决条件](#prerequisites)。

要使用一个或多个自定义域名：

- 添加[自定义根域名或子域名](#set-up-a-custom-domain)。
- 添加 [SSL/TLS 证书](#add-an-ssltls-certificate-to-pages)。

> [!warning]
> 您无法验证[最常用的公共邮箱域名](../../../group/access_and_permissions.md#restrict-group-access-by-domain)。

<a id="set-up-a-custom-domain"></a>

## 设置自定义域名

要使用自定义域名设置 Pages，请完成以下步骤。

<a id="prerequisites"></a>

### 先决条件

- 管理员已为 [GitLab Pages 自定义域名](../../../../administration/pages/_index.md#advanced-configuration)配置了服务器。
- 一个已启动并运行的 GitLab Pages 网站，在默认 Pages 域名下提供服务
  （对于 JihuLab.com，为 `*.gitlab.io`）。
- 一个自定义域名 `example.com` 或子域名 `subdomain.example.com`。
- 可以访问您域名的服务器控制面板以设置 DNS 记录：
  - 一条 DNS 记录（`A`、`AAAA`、`ALIAS` 或 `CNAME`），将您的域名指向 GitLab Pages 服务器。如果
    该名称存在多条 DNS 记录，则必须使用 `ALIAS` 记录。
  - 一条 DNS `TXT` 记录，用于验证您对域名的所有权。

有关 DNS 记录的概述，请参阅 [GitLab Pages DNS 记录](dns_concepts.md)。

<a id="step-1-add-a-custom-domain"></a>

### 步骤 1：添加自定义域名

要将您的自定义域名添加到 GitLab Pages：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **部署** > **Pages**。
1. 在右上角，选择 **新建域名**。
1. 在 **域名** 中，输入域名。
1. 可选。在 **证书** 中，关闭 **使用 Let's Encrypt 自动管理证书** 开关，以添加 [SSL/TLS 证书](#add-an-ssltls-certificate-to-pages)。您也可以稍后添加证书和密钥。
1. 选择 **创建新域名**。

<a id="step-2-get-the-verification-code"></a>

### 步骤 2：获取验证码

向 Pages 添加新域名后，极狐GitLab 会显示一个验证码。复制这些值
并在下一步中将其作为 `TXT` 记录粘贴到您域名的控制面板中。

![GitLab Pages 显示新域名的生成验证码。](img/get_domain_verification_code_v18_8.png)

**验证状态** 字段的结构为：

- 名称/主机：
  - 对于根域名：`_gitlab-pages-verification-code.example.com`
  - 对于子域名：`_gitlab-pages-verification-code.subdomain.example.com`
- DNS 记录类型：`TXT`
- 值：`gitlab-pages-verification-code=00112233445566778899aabbccddeeff`
  （使用极狐GitLab 中您的实际代码）

> [!note]
> 某些 DNS 提供商（如 Cloudflare）会自动将您的域名附加到
> 名称或主机字段。如果您的提供商执行此操作，则只需输入
> `_gitlab-pages-verification-code`（对于根域名）或
> `_gitlab-pages-verification-code.subdomain`（对于子域名）。

<a id="step-3-set-up-dns-records"></a>

### 步骤 3：设置 DNS 记录

要根据您希望与 Pages 站点一起使用的域名类型设置 DNS 记录，
请选择以下选项之一：

- [根域名](#root-domains)
- [子域名](#subdomains)
- [根域名和子域名](#both-root-and-subdomains)

<a id="root-domains"></a>

#### 根域名

根域名（`example.com`）需要：

- 至少满足以下一项：
  - 一条 [DNS `A` 记录](dns_concepts.md#a-record)，将您的域名指向 Pages 服务器。
  - 一条 [DNS `AAAA` 记录](dns_concepts.md#aaaa-record)，将您的域名指向 Pages 服务器。
- 一条 [`TXT` 记录](dns_concepts.md#txt-record)，用于验证您对域名的所有权。

| 来源                                          | DNS 记录 | 指向              |
| --------------------------------------------- | ---------- | --------------- |
| `example.com`                                 | `A`        | `35.185.44.232` |
| `example.com`                                 | `AAAA`     | `2600:1901:0:7b8a::` |
| `_gitlab-pages-verification-code.example.com` | `TXT`      | `gitlab-pages-verification-code=00112233445566778899aabbccddeeff` |

对于 JihuLab.com 上的项目，IPv4 地址为 `35.185.44.232`，IPv6 地址
为 `2600:1901:0:7b8a::`。

对于其他极狐GitLab 实例（基础版或企业版）中的项目，请联系您的系统管理员
并请求您实例的 Pages 服务器 IP 地址。

![DNS 配置屏幕，显示为 GitLab Pages 服务器添加的 A 记录。](img/dns_add_new_a_record_v11_2.png)

> [!warning]
> 对于根域名，您不应使用 DNS 顶点 `CNAME` 记录来代替 `A` 或 `AAAA` 记录。
> 如果您为根域名设置了
> [`MX` 记录](dns_concepts.md#mx-record)，此方法很可能不起作用。

<a id="subdomains"></a>

#### 子域名

子域名（`subdomain.example.com`）需要：

- 一条 DNS [`ALIAS` 或 `CNAME` 记录](dns_concepts.md#cname-record)，将您的子域名指向 Pages 服务器。
- 一条 DNS [`TXT` 记录](dns_concepts.md#txt-record)，用于验证您对域名的所有权。

| 来源                                                    | DNS 记录      | 指向 |
|---------------------------------------------------------|-----------------|----|
| `subdomain.example.com`                                 | `ALIAS`/`CNAME` | `namespace.gitlab.io` |
| `_gitlab-pages-verification-code.subdomain.example.com` | `TXT`           | `gitlab-pages-verification-code=00112233445566778899aabbccddeeff` |

无论是用户网站还是项目网站，DNS 记录
都应指向您的 Pages 域名（`namespace.gitlab.io`），
不带任何路径。

<a id="both-root-and-subdomains"></a>

#### 根域名和子域名

要将根域名和子域名都指向同一个网站，例如，
`example.com` 和 `www.example.com`，您需要以下内容：

- 一条用于该域名的 DNS `A` 记录。
- 一条用于该域名的 DNS `AAAA` 记录。
- 一条用于该子域名的 DNS `ALIAS`/`CNAME` 记录。
- 每个域名各一条 DNS `TXT` 记录。

| 来源                                              | DNS 记录 | 指向 |
|---------------------------------------------------|------------|----|
| `example.com`                                     | `A`        | `35.185.44.232` |
| `example.com`                                     | `AAAA`     | `2600:1901:0:7b8a::` |
| `_gitlab-pages-verification-code.example.com`     | `TXT`      | `gitlab-pages-verification-code=00112233445566778899aabbccddeeff` |
| `www.example.com`                                 | `CNAME`    | `namespace.gitlab.io` |
| `_gitlab-pages-verification-code.www.example.com` | `TXT`      | `gitlab-pages-verification-code=00112233445566778899aabbccddeeff` |

如果您使用 Cloudflare，请参阅
[使用 Cloudflare 将 `www.domain.com` 重定向到 `domain.com`](#redirect-wwwdomaincom-to-domaincom-with-cloudflare)。

此外：

- 如果您想将 `domain.com` 指向您的 GitLab Pages 站点，请勿使用 `CNAME` 记录。请改用 `A` 记录。
- 不要在默认 Pages 域名后添加任何特殊字符。例如，不要将 `subdomain.domain.com` 指向
  或 `namespace.gitlab.io/`。某些域名托管提供商可能会要求使用尾随点（`namespace.gitlab.io.`）。
- 2018 年，JihuLab.com 上 GitLab Pages 的 IP 从 `52.167.214.135` [更改](https://about.gitlab.com/blog/gcp-move-update/#gitlab-pages-and-custom-domains)为 `35.185.44.232`。
- 2023 年，[为 JihuLab.com 添加了 IPv6 支持](https://gitlab.com/gitlab-org/gitlab/-/issues/214718)。

<a id="step-4-verify-the-domains-ownership"></a>

### 步骤 4：验证域名所有权

添加所有 DNS 记录后：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **部署** > **Pages**。
1. 在域名旁边，选择 **编辑** ({{< icon name="pencil" >}})。
1. 在 **验证状态** 中，选择 **重试验证** ({{< icon name="retry" >}})。

![GitLab Pages 设置，显示域名的重试验证选项。](img/retry_domain_verification_v18_8.png)

当您的域名变为活动状态时，您的网站即可通过您的域名访问。

> [!warning]
> 在启用了域名验证的极狐GitLab 实例上，
> 极狐GitLab 会在 7 天后从项目中移除未验证的域名。

此外：

- **JihuLab.com 用户必须进行域名验证**。
  对于极狐GitLab 私有化部署，您的极狐GitLab 管理员可以选择
  [禁用自定义域名验证](../../../../administration/pages/_index.md#custom-domain-verification)。
- [DNS 传播可能需要一些时间（最多 24 小时）](https://www.inmotionhosting.com/support/domain-names/dns-nameserver-changes/complete-guide-to-dns-records/)，
  尽管通常只需几分钟即可完成。在传播完成之前，验证
  会失败，并且尝试访问您的域名会返回 404。
- 域名验证通过后，请保留验证记录。
  您的域名会定期重新验证，如果
  该记录被移除，域名可能会被禁用。

<a id="add-more-domain-aliases"></a>

## 添加更多域名别名

您可以向同一项目添加多个别名（自定义域名和子域名）。
别名可以理解为有许多扇门通向同一个房间。

您为站点设置的所有别名都列在 **设置** > **Pages** 中。
在该页面上，您可以查看、添加和移除它们。

<a id="redirect-wwwdomaincom-to-domaincom-with-cloudflare"></a>

## 使用 Cloudflare 将 `www.domain.com` 重定向到 `domain.com`

如果您使用 Cloudflare，则可以使用页面规则将 `www.domain.com` 重定向到 `domain.com`，
而无需将两个域名都添加到极狐GitLab：

1. 在 Cloudflare 中，至少创建以下一项：
   - 一条 DNS `A` 记录，将 `domain.com` 指向 `35.185.44.232`。
   - 一条 DNS `AAAA` 记录，将 `domain.com` 指向 `2600:1901:0:7b8a::`。
1. 在极狐GitLab 中，将域名添加到 GitLab Pages 并获取验证码。
1. 在 Cloudflare 中，创建一条 DNS `TXT` 记录以验证您的域名。
1. 在极狐GitLab 中，验证您的域名。
1. 在 Cloudflare 中，创建一条 DNS `CNAME` 记录，将 `www` 指向 `domain.com`。
1. 在 Cloudflare 中，添加一条页面规则，将 `www.domain.com` 指向 `domain.com`：
   1. 转到您域名的仪表板。在顶部导航中，选择 **页面规则**。
   1. 选择 **创建页面规则**。
   1. 输入域名 `www.domain.com`，然后选择 **+ 添加设置**。
   1. 从下拉列表中，选择 **转发 URL**，然后选择
      状态代码 **301 - 永久重定向**。
   1. 输入目标 URL `https://domain.com`。

<a id="add-an-ssltls-certificate-to-pages"></a>

## 向 Pages 添加 SSL/TLS 证书

要使用 GitLab Pages 保护您的自定义域名，您可以：

- 使用 [Let's Encrypt 集成](lets_encrypt_integration.md)
  自动获取和续订 SSL 证书。
- 手动添加 SSL/TLS 证书。

有关 SSL/TLS 认证的概述，请参阅 [GitLab Pages SSL/TLS 证书](ssl_tls_concepts.md)。

<a id="manually-add-ssltls-certificates"></a>

### 手动添加 SSL/TLS 证书

先决条件：

- 一个已启动并运行的 GitLab Pages 网站，可通过自定义域名访问。
- 以下证书组件：

  - **PEM 证书**：由 CA 生成的证书。
  - **中间证书**：也称为根证书，用于标识 CA。
    通常与 PEM 证书合并，但某些证书（如
    [Cloudflare 证书](https://about.gitlab.com/blog/setting-up-gitlab-pages-with-cloudflare-certificates/)）
    要求您单独添加。
  - **私钥**：用于验证您的 PEM 与您的域名的加密密钥。

要在创建新域名时添加证书：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **部署** > **Pages**。
1. 在右上角，选择 **新建域名**。
1. 在 **域名** 中，输入域名。
1. 在 **证书** 中，关闭 **使用 Let's Encrypt 自动管理证书** 开关。
1. 填写证书字段。
1. 选择 **创建新域名**。

要向现有域名添加证书：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **部署** > **Pages**。
1. 在域名旁边，选择 **编辑** ({{< icon name="pencil" >}})。
1. 在 **证书** 中，关闭 **使用 Let's Encrypt 自动管理证书** 开关。
1. 填写证书字段。
1. 选择 **保存更改**。

填写证书字段时：

- 在 **证书 (PEM)** 中，粘贴 PEM 证书。如果您的证书需要
  单独的中间证书，请将其粘贴在同一字段中，并用空行分隔。
  有关更多信息，请参阅
  [使用 Cloudflare 证书设置 GitLab Pages](https://about.gitlab.com/blog/setting-up-gitlab-pages-with-cloudflare-certificates/)。
- 在私钥字段中，粘贴您的私钥。

> [!note]
> 请勿在普通文本编辑器中打开证书或加密密钥。
> 请使用 Sublime Text、Dreamweaver 或 VS Code 等代码编辑器。

<a id="force-https-for-gitlab-pages-websites"></a>

## 为 GitLab Pages 网站强制启用 HTTPS

您可以为 GitLab Pages 强制启用 HTTPS，以通过 301 重定向自动将 HTTP 请求重定向到 HTTPS。
这适用于默认的 GitLab Pages 域名和具有有效证书的自定义域名。

要强制启用 HTTPS：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **部署** > **Pages**。
1. 选中 **强制 HTTPS（需要有效证书）** 复选框。
1. 选择 **保存更改**。

如果您在 GitLab Pages 前面使用 Cloudflare CDN，请将 SSL 连接设置设置为
`full` 而不是 `flexible`。有关更多信息，请参阅
[Cloudflare CDN 说明](https://developers.cloudflare.com/ssl/origin-configuration/ssl-modes#h_4e0d1a7c-eb71-4204-9e22-9d3ef9ef7fef)。

<a id="edit-a-custom-domain"></a>

## 编辑自定义域名

您可以编辑自定义域名以：

- 查看自定义域名。
- 查看要添加的 DNS 记录。
- 查看 TXT 验证条目。
- 重试验证。
- 编辑证书设置。

要编辑自定义域名：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **部署** > **Pages**。
1. 在域名旁边，选择 **编辑** ({{< icon name="pencil" >}})。

<a id="delete-a-custom-domain"></a>

## 删除自定义域名

删除自定义域名后，该域名将不再在极狐GitLab 中验证，并且无法与 GitLab Pages 一起使用。

要删除并移除自定义域名：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **部署** > **Pages**。
1. 在域名旁边，选择 **移除域名** ({{< icon name="remove" >}})。
1. 出现提示时，选择 **移除域名**。

<a id="troubleshooting"></a>

## 故障排查

<a id="domain-verification"></a>

### 域名验证

要手动验证您是否正确配置了域名验证
`TXT` DNS 条目，您可以在终端中运行以下命令：

```shell
dig _gitlab-pages-verification-code.<YOUR-PAGES-DOMAIN> TXT
```

预期输出：

```plaintext
;; ANSWER SECTION:
_gitlab-pages-verification-code.<YOUR-PAGES-DOMAIN>. 300 IN TXT "gitlab-pages-verification-code=<YOUR-VERIFICATION-CODE>"
```

在某些情况下，使用与您尝试注册的域名相同的域名添加验证码会有所帮助。

对于根域名：

| 来源                                          | DNS 记录 | 指向 |
|-----------------------------------------------|------------|----|
| `example.com`                                 | `TXT`      | `gitlab-pages-verification-code=00112233445566778899aabbccddeeff` |
| `_gitlab-pages-verification-code.example.com` | `TXT`      | `gitlab-pages-verification-code=00112233445566778899aabbccddeeff` |

对于子域名：

| 来源                                              | DNS 记录 | 指向 |
|---------------------------------------------------|------------|----|
| `www.example.com`                                 | `TXT`      | `gitlab-pages-verification-code=00112233445566778899aabbccddeeff` |
| `_gitlab-pages-verification-code.www.example.com` | `TXT`      | `gitlab-pages-verification-code=00112233445566778899aabbccddeeff` |
