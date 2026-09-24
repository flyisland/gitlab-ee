---
stage: Plan
group: Knowledge
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab Pages 默认域名和 URL
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

极狐GitLab Pages 根据您的命名空间和项目名称提供默认域名。
这些域名：

- 为项目站点、用户站点和群组站点生成可预测的 URL。
- 支持反映极狐GitLab 组织结构的层级路径。
- 启用后通过自动重定向创建唯一域名。
- 与自定义域名和 SSL/TLS 证书无缝协作。
- 可跨用户、群组和子群组项目扩展。

本指南解释了极狐GitLab Pages 如何为您的网站分配域名和 URL，以及如何相应地配置您的静态站点生成器。

<a id="gitlab-pages-default-domain-names"></a>

## 极狐GitLab Pages 默认域名

{{< history >}}

- 在极狐GitLab 17.4 中，更改了唯一域名 URL 以使其更短。

{{< /history >}}

如果您使用自己的极狐GitLab 实例通过极狐GitLab Pages 部署站点，请与您的系统管理员确认您的 Pages 通配符域。本指南适用于任何极狐GitLab 实例，前提是您将 JihuLab.com 上的 Pages 通配符域 (`*.gitlab.io`) 替换为您自己的域。

如果您在极狐GitLab 上设置了一个极狐GitLab Pages 项目，
它将自动可通过 `namespace.example.io` 的子域访问。
[`namespace`](../../namespace/_index.md)
由您在 JihuLab.com 上的用户名或您创建此项目所在的群组名称定义。
对于私有化部署，将 `example.io`
替换为您实例的 Pages 域。对于 JihuLab.com，
Pages 域为 `*.gitlab.io`。

| 极狐GitLab Pages 类型 | 极狐GitLab 中项目的示例路径 | 网站 URL |
| -------------------- | ------------ | ----------- |
| 用户页面  | `username/username.example.io`  | `http(s)://username.example.io`  |
| 群组页面 | `acmecorp/acmecorp.example.io` | `http(s)://acmecorp.example.io` |
| 用户拥有的项目页面  | `username/my-website` | `http(s)://username.example.io/my-website` |
| 群组拥有的项目页面 | `acmecorp/webshop` | `http(s)://acmecorp.example.io/webshop`|
| 子群组拥有的项目页面 | `acmecorp/documentation/product-manual` | `http(s)://acmecorp.example.io/documentation/product-manual`|

当 **使用唯一域名** 设置启用时，Pages 会根据扁平化的项目名称和一个六字符的唯一 ID 构建唯一域名。用户会收到 `308 永久重定向` 状态，浏览器会重定向到这些唯一域名 URL。浏览器可能会缓存此重定向：

| 极狐GitLab Pages 类型              | 极狐GitLab 中项目的示例路径     | 网站 URL |
| --------------------------------- | --------------------------------------- | ----------- |
| 用户页面                        | `username/username.example.io`          | `http(s)://username-example-io-123456.example.io` |
| 群组页面                       | `acmecorp/acmecorp.example.io`          | `http(s)://acmecorp-example-io-123456.example.io` |
| 用户拥有的项目页面     | `username/my-website`                   | `https://my-website-123456.gitlab.io/` |
| 群组拥有的项目页面    | `acmecorp/webshop`                      | `http(s)://webshop-123456.example.io/` |
| 子群组拥有的项目页面 | `acmecorp/documentation/product-manual` | `http(s)://product-manual-123456.example.io/` |

示例 URL 中的 `123456` 是一个六字符的唯一 ID。
例如，如果唯一 ID 是 `f85695`，最后一个示例为
`http(s)://product-manual-f85695.example.io/`。

> [!warning]
> 有关在通用域名和 HTTPS 下提供命名空间的限制，
> 请参见[子域的子域](introduction.md#subdomains-of-subdomains)。

要清楚地理解 Pages 域名，请阅读以下示例。

> [!note]
> 以下示例假定您禁用了 **使用唯一域名** 设置。如果您没有禁用，请参考前面的表格，将 `example.io` 替换为 `gitlab.io`。

<a id="project-website-examples"></a>

### 项目网站示例

- 您在用户名 `john` 下创建了一个名为 `blog` 的项目，
  因此您的项目 URL 为 `https://gitlab.com/john/blog/`。
  在为此项目启用极狐GitLab Pages 并构建您的站点后，
  您可以通过 `https://john.gitlab.io/blog/` 访问它。
- 您为所有网站创建了一个名为 `websites` 的群组，
  并且该群组中有一个名为 `blog` 的项目。您的项目
  URL 为 `https://gitlab.com/websites/blog/`。在为此项目启用
  极狐GitLab Pages 后，该站点可通过
  `https://websites.gitlab.io/blog/` 访问。
- 您为工程部门创建了一个名为 `engineering` 的群组，
  为所有文档网站创建了一个名为 `docs` 的子群组，
  并且该子群组中有一个名为 `workflows` 的项目。您的项目
  URL 为 `https://gitlab.com/engineering/docs/workflows/`。在为此项目启用
  极狐GitLab Pages 后，该站点可通过
  `https://engineering.gitlab.io/docs/workflows` 访问。

<a id="user-and-group-website-examples"></a>

### 用户和群组网站示例

- 在您的用户名 `john` 下，您创建了一个名为
  `john.gitlab.io` 的项目。您的项目 URL 为 `https://gitlab.com/john/john.gitlab.io`。
  在为您的项目启用极狐GitLab Pages 后，您的网站
  将发布在 `https://john.gitlab.io` 下。
- 在您的群组 `websites` 下，您创建了一个名为
  `websites.gitlab.io` 的项目。您的项目 URL 为 `https://gitlab.com/websites/websites.gitlab.io`。
  在为您的项目启用极狐GitLab Pages 后，
  您的网站将发布在 `https://websites.gitlab.io` 下。

**通用示例**：

- 在 JihuLab.com 上，项目站点始终可通过
  `https://namespace.gitlab.io/project-slug` 访问
- 在 JihuLab.com 上，用户或群组网站可通过
  `https://namespace.gitlab.io/` 访问
- 在您的极狐GitLab 实例上，将 `gitlab.io` 替换为您的
  Pages 服务器域。请向您的系统管理员询问此信息。

<a id="urls-and-base-urls"></a>

## URL 和基础 URL

> [!note]
> 在某些静态站点生成器中，`baseurl` 选项的名称可能不同。

每个静态站点生成器 (SSG) 的默认配置都期望
在（子）域 (`example.com`) 下找到您的网站，而不是
在该域的子目录 (`example.com/subdir`) 中。因此，
每当您发布项目网站（例如，`namespace.gitlab.io/project-slug`）时，
您必须在静态站点生成器的文档中查找此配置（基础 URL），
并对其进行设置以反映此模式。

例如，对于 Jekyll 站点，`baseurl` 在 Jekyll
配置文件 `_config.yml` 中定义。如果您的网站 URL 是
`https://john.gitlab.io/blog/`，您需要在 `_config.yml` 中添加此行：

```yaml
baseurl: "/blog"
```

如果您在派生某个[默认示例](https://gitlab.com/pages)后部署网站，则 `baseurl` 已经以此方式配置。
所有示例都是项目网站。如果您决定将您的网站设为用户或
群组网站，则必须从项目中移除此配置。对于 Jekyll
示例，请将 Jekyll 的 `_config.yml` 更改为：

```yaml
baseurl: ""
```

如果您使用的是[纯 HTML 示例](https://gitlab.com/pages/plain-html)，
则无需设置 `baseurl`。

<a id="custom-domains"></a>

## 自定义域名

极狐GitLab Pages 支持自定义域名和子域名，可通过 HTTP 或 HTTPS 提供服务。
有关更多信息，请参见[极狐GitLab Pages 自定义域名和 SSL/TLS 证书](custom_domains_ssl_tls_certification/_index.md)。