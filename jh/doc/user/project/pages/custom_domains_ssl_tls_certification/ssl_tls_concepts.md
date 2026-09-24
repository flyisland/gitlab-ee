---
stage: Plan
group: Planner Intelligence
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: GitLab Pages SSL/TLS 证书
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

JihuLab.com 上的每个 GitLab Pages 项目都可通过 HTTPS 访问默认的 Pages 域名（`*.gitlab.io`）。为您的 Pages 项目设置自定义（子）域名后，如果您希望其通过 HTTPS 保护，则必须为该（子）域名签发证书并将其安装到项目中。

> [!note]
> 您不必为 GitLab Pages 项目上的自定义（子）域名添加证书，但强烈建议您这样做。

<a id="importance-of-https"></a>

## HTTPS 的重要性

GitLab Pages 站点是静态的。它们不使用服务器端脚本，也不处理信用卡交易。那么，为什么它们需要安全连接呢？

当 HTTPS 在 1990 年问世时，[SSL](https://en.wikipedia.org/wiki/Transport_Layer_Security#SSL_1.0.2C_2.0_and_3.0) 被视为一种“特殊”的安全措施，仅对银行和购物网站等有金融交易的大型公司是必需的。

<!-- vale gitlab_base.Spelling = NO -->

现在情况不同了。[据 Josh Aas](https://letsencrypt.org/2015/10/29/phishing-and-malware.html)（[互联网安全研究组 (ISRG)](https://en.wikipedia.org/wiki/Internet_Security_Research_Group) 执行董事）称：

<!-- vale gitlab_base.rulename = YES -->

> 我们已经认识到，HTTPS 对几乎所有网站都至关重要。它对任何允许用户使用密码登录的网站、任何以任何方式[跟踪其用户](https://www.washingtonpost.com/news/the-switch/wp/2013/12/10/nsa-uses-google-cookies-to-pinpoint-targets-for-hacking/)的网站、任何[不希望其内容被篡改](https://arstechnica.com/tech-policy/2014/09/why-comcasts-javascript-ad-injections-threaten-security-net-neutrality/)的网站，以及任何提供用户可能不希望他人知道自己正在消费的内容的网站都很重要。我们还了解到，任何未受 HTTPS 保护的网站都可能[被用来攻击其他网站](https://krebsonsecurity.com/2015/04/dont-be-fodder-for-chinas-great-cannon/)。

证书之所以重要，是因为它们通过一系列身份验证和校验，加密了**客户端**（您和您的访问者）与**服务器**（您的站点所在位置）之间的连接。

<a id="organizations-supporting-https"></a>

## 支持 HTTPS 的组织

目前有大量支持保护整个网络安全的运动。W3C 完全[支持这一事业](https://w3ctag.github.io/web-https/)，并很好地解释了其原因。Mozilla 安全博客的作者 Richard Barnes 曾建议 [Firefox 弃用 HTTP](https://blog.mozilla.org/security/2015/04/30/deprecating-non-secure-http/)，并且不再接受不安全的连接。最近，Mozilla 发布了一份[公告](https://blog.mozilla.org/security/2016/03/29/march-2016-ca-communication/)，重申了 HTTPS 的重要性。

<a id="issuing-certificates"></a>

## 签发证书

GitLab Pages 接受由[证书颁发机构](https://en.wikipedia.org/wiki/Certificate_authority)签发的 [PEM](https://knowledge.digicert.com/quovadis) 格式证书，也接受[自签名证书](https://en.wikipedia.org/wiki/Self-signed_certificate)。出于安全原因以及确保浏览器信任您站点的证书，[自签名证书通常不用于](https://www.mcafee.com/blogs/other-blogs/mcafee-labs/self-signed-certificates-secure-so-why-ban/)公共网站。

不同的证书具有不同的安全级别。例如，静态个人网站与在线银行 Web 应用所需的安全级别不同。

一些证书颁发机构提供免费证书，旨在让互联网对每个人都更安全。最受欢迎的是 [Let's Encrypt](https://letsencrypt.org/)，它签发的证书受大多数浏览器信任，是开源的，并且免费使用。请参阅 [GitLab Pages 与 Let's Encrypt 的集成](lets_encrypt_integration.md)，为您的自定义域名启用 HTTPS。

同样受欢迎的还有 [Cloudflare 签发的证书](https://www.cloudflare.com/products/ssl/)，它还提供[免费的 CDN 服务](https://blog.cloudflare.com/cloudflares-free-cdn-and-you/)。他们的证书有效期最长可达 15 年。请参阅[如何为您的 GitLab Pages 网站添加 Cloudflare 证书](https://about.gitlab.com/blog/setting-up-gitlab-pages-with-cloudflare-certificates/)的教程。
