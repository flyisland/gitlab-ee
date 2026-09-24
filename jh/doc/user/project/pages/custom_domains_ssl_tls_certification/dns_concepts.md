---
stage: Plan
group: Planner Intelligence
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: GitLab Pages DNS 记录
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

域名系统（DNS）Web 服务通过将域名（如 `www.example.com`）转换为计算机用于相互连接的 IP 地址（如 `192.0.2.1`），将访问者路由到网站。

创建 DNS 记录是为了将（子）域名指向某个位置，该位置可以是 IP 地址或另一个域名。如果您想将 GitLab Pages 与您自己的（子）域名一起使用，您需要访问您域名的注册商控制面板，添加一条 DNS 记录，将其指向您的 GitLab Pages 站点。

如何添加 DNS 记录取决于您的域名托管在哪个服务器上。每个控制面板都有自己执行此操作的位置。如果您不是您域名的管理员，并且无法访问您的注册商，您必须请求您的托管服务的技术支持为您执行此操作。

有关更多信息，请参阅[为 GitLab Pages 设置 DNS 记录](_index.md#step-3-set-up-dns-records)。

对于最流行的托管服务，请参阅以下说明：

<!-- vale gitlab_base.Spelling = NO -->

- [123-reg](https://www.123-reg.co.uk/support/domains/domain-name-server-dns-management-guide/)
- [Amazon](https://docs.aws.amazon.com/AmazonS3/latest/userguide/website-hosting-custom-domain-walkthrough.html)
- [Bluehost](https://www.bluehost.com/help/article/dns-management-add-edit-or-delete-dns-entries)
- [Cloudflare](https://developers.cloudflare.com/fundamentals/account/)
- [cPanel](https://docs.cpanel.net/cpanel/domains/zone-editor/)
- [DigitalOcean](https://docs.digitalocean.com/products/networking/dns/how-to/manage-records/)
- [DreamHost](https://help.dreamhost.com/hc/en-us/articles/360035516812-Adding-custom-DNS-records)
- [Gandi](https://docs.gandi.net/en/domain_names/faq/dns_records.html)
- [Go Daddy](https://www.godaddy.com/help/add-an-a-record-19238)
- [Hostgator](https://www.hostgator.com/help/article/changing-dns-records)
- [Inmotion hosting](https://www.inmotionhosting.com/support/edu/cpanel/how-do-i-make-custom-dns-records/)
- [Microsoft](https://learn.microsoft.com/en-us/windows-server/networking/dns/manage-resource-records?tabs=powershell)
- [Namecheap](https://www.namecheap.com/support/knowledgebase/subcategory/2237/host-records-setup/)

<!-- vale gitlab_base.Spelling = YES -->

如果您的托管服务未列出，您可以尝试在网络上搜索 `how to add dns record on <my hosting service>`。

<a id="a-record"></a>

## `A` 记录

DNS `A` 记录将主机映射到 IPv4 IP 地址。它将根域名（如 `example.com`）指向主机的 IP 地址（如 `192.0.2.1`）。

示例：

- `example.com` => `A` => `192.0.2.1`

<a id="aaaa-record"></a>

## `AAAA` 记录

DNS `AAAA` 记录将主机映射到 IPv6 IP 地址。它将根域名（如 `example.com`）指向主机的 IP 地址（如 `2001:db8::1`）。

示例：

- `example.com` => `AAAA` => `2001:db8::1`

<a id="cname-record"></a>

## `CNAME` 记录

`CNAME` 记录为您的服务器的规范名称（由 `A` 记录定义）定义别名。它将子域名指向另一个域名。

示例：

- `www` => `CNAME` => `example.com`

这样，访问 `www.example.com` 的访问者将被重定向到 `example.com`。

<a id="mx-record"></a>

## `MX` 记录

MX 记录用于定义用于该域名的邮件交换服务器。这有助于电子邮件消息正确到达您的邮件服务器。

示例：

- `MX` => `mail.example.com`

然后，您可以为 `users@mail.example.com` 注册电子邮件。

<a id="txt-record"></a>

## `TXT` 记录

`TXT` 记录可以将任意文本与主机或其他名称关联。常见用途是用于站点验证。

示例：

- `example.com` => `TXT` => `"google-site-verification=6P08Ow5E-8Q0m6vQ7FMAqAYIDprkVV8fUf_7hZ4Qvc8"`

这样，您就可以验证该域名的所有权。

<a id="all-combined"></a>

## 全部组合

您可以拥有一个 DNS 记录或多个组合：

- `example.com` => `A` => `192.0.2.1`
- `example.com` => `AAAA` => `2001:db8::1`
- `www` => `CNAME` => `example.com`
- `MX` => `mail.example.com`
- `example.com` => `TXT` => `"google-site-verification=6P08Ow5E-8Q0m6vQ7FMAqAYIDprkVV8fUf_7hZ4Qvc8"`
