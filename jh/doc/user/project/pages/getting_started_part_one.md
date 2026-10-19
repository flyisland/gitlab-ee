---
stage: Plan
group: Planner Intelligence
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: GitLab Pages 默认域名和 URL
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

GitLab Pages 会根据您的命名空间和项目名称提供默认域名。这些域名：

- 为项目站点、用户站点和群组站点生成可预测的 URL。
- 支持反映您极狐GitLab 组织结构的层级路径。
- 在启用时创建带自动重定向的唯一域名。
- 与自定义域名和 SSL/TLS 证书无缝配合。
- 可跨用户、群组和子群组项目扩展。

本指南介绍 GitLab Pages 如何为您的网站分配域名和 URL，以及如何相应地配置您的静态站点生成器。

<a id="gitlab-pages-default-domain-names"></a>

## GitLab Pages 默认域名

如果您使用自己的极狐GitLab 实例通过 GitLab Pages 部署站点，请与您的系统管理员确认您的 Pages 通配符域名。本指南适用于任何极狐GitLab 实例，前提是您将 JihuLab.com 上的 Pages 通配符域名（`*.gitlab.io`）替换为您自己的域名。

如果您在极狐GitLab 上设置了一个 GitLab Pages 项目，
它会自动通过 `namespace.example.io`的子域名访问。
[`namespace`](../../namespace/_index.md)
由您在 JihuLab.com 上的用户名定义，或由您创建此项目时所在的群组名称定义。对于极狐GitLab 私有化部署，请将 `example.io`
替换为您实例的 Pages 域名。对于 JihuLab.com，
Pages 域名为 `*.gitlab.io`。

| GitLab Pages 类型 | 极狐GitLab 中项目的示例路径 | 网站 URL |
| -------------------- | ------------ | ----------- |
| 用户页面  | `username/username.example.io`  | `http(s)://username.example.io`  |
| 群组页面 | `acmecorp/acmecorp.example.io` | `http(s)://acmecorp.example.io` |
| 用户拥有的项目页面  | `username/my-website` | `http(s)://username.example.io/my-website` |
| 群组拥有的项目页面 | `acmecorp/webshop` | `http(s)://acmecorp.example.io/webshop`|
| 子群组拥有的项目页面 | `acmecorp/documentation/product-manual` | `http(s)://acmecorp.example.io/documentation/product-manual`|

启用 **使用唯一域名** 设置后，Pages 会根据扁平化的项目名称和一个六字符唯一 ID 构建唯一域名。用户会收到 `308 Permanent Redirect` 状态重定向，将浏览器重定向到这些唯一域名 URL。浏览器可能会缓存此重定向：

| GitLab Pages 类型              | 极狐GitLab 中项目的示例路径     | 网站 URL |
| --------------------------------- | --------------------------------------- | ----------- |
| 用户页面                        | `username/username.example.io`          | `http(s)://username-example-io-123456.example.io` |
| 群组页面                       | `acmecorp/acmecorp.example.io`          | `http(s)://acmecorp-example-io-123456.example.io` |
| 用户拥有的项目页面     | `username/my-website`                   | `https://my-website-123456.gitlab.io/` |
| 群组拥有的项目页面    | `acmecorp/webshop`                      | `http(s)://webshop-123456.example.io/` |
| 子群组拥有的项目页面 | `acmecorp/documentation/product-manual` | `http(s)://product-manual-123456.example.io/` |

示例 URL 中的 `123456` 是一个六字符唯一 ID。例如，如果唯一 ID 是 `f85695`，则最后一个示例为
`http(s)://product-manual-f85695.example.io/`。

> [!warning]
> 有关在通用域名和 HTTPS 下提供服务的命名空间的限制，
> 请参阅[子域名的子域名](introduction.md#subdomains-of-subdomains)。

以下示例展示了 Pages 域名的工作方式。

> [!note]
> 以下示例假定您已禁用 **使用唯一域名** 设置。如果未禁用，请参阅前面的表格，将 `example.io` 替换为 `gitlab.io`。

<a id="project-website-examples"></a>

### 项目网站示例

- 您在用户名 `john` 下创建了一个名为 `blog`的项目，
  因此您的项目 URL 为 `https://gitlab.com/john/blog/`。
  在您为此项目启用 GitLab Pages 并构建站点后，
  您可以通过 `https://john.gitlab.io/blog/` 访问它。
- 您为所有网站创建了一个名为 `websites`的群组，
  此群组中的一个项目名为 `blog`。您的项目
  URL 为 `https://gitlab.com/websites/blog/`。在您为此项目启用
  GitLab Pages 后，站点可通过
  `https://websites.gitlab.io/blog/` 访问。
- 您为工程部门创建了一个名为 `engineering`的群组，
  为所有文档网站创建了一个名为 `docs`的子群组，
  此子群组中的一个项目名为 `workflows`。您的项目
  URL 为 `https://gitlab.com/engineering/docs/workflows/`。在您为此项目启用
  GitLab Pages 后，站点可通过
  `https://engineering.gitlab.io/docs/workflows` 访问。

<a id="user-and-group-website-examples"></a>

### 用户和群组网站示例

- 在您的用户名 `john` 下，您创建了一个名为
  `john.gitlab.io`的项目。您的项目 URL 为 `https://gitlab.com/john/john.gitlab.io`。
  在您为项目启用 GitLab Pages 后，您的网站
  发布在 `https://john.gitlab.io` 下。
- 在您的群组 `websites` 下，您创建了一个名为
  `websites.gitlab.io`的项目。您的项目 URL 为 `https://gitlab.com/websites/websites.gitlab.io`。
  在您为项目启用 GitLab Pages 后，
  您的网站发布在 `https://websites.gitlab.io` 下。

**通用示例**：

- 在 JihuLab.com 上，项目站点始终可通过
  `https://namespace.gitlab.io/project-slug` 访问
- 在 JihuLab.com 上，用户或群组网站可通过
  `https://namespace.gitlab.io/` 访问
- 在您的极狐GitLab 实例上，请将 `gitlab.io` 替换为您的
  Pages 服务器域名。请向您的系统管理员询问此信息。

<a id="urls-and-base-urls"></a>

## URL 和基础 URL

> [!note]
> 在某些静态站点生成器中，`baseurl` 选项可能名称不同。

每个静态站点生成器（SSG）的默认配置都期望在（子）域名（`example.com`）下找到您的网站，而不是在该域名的子目录（`example.com/subdir`）中。因此，每当您发布项目网站（例如 `namespace.gitlab.io/project-slug`）时，您必须在静态站点生成器的文档中查找此配置（基础 URL），并将其设置为反映此模式。

例如，对于 Jekyll 站点，`baseurl` 在 Jekyll
配置文件 `_config.yml`中定义。如果您的网站 URL 为
`https://john.gitlab.io/blog/`，您需要将以下行添加到 `_config.yml`：

```yaml
baseurl: "/blog"
```

如果您在 forking 某个
[默认示例](https://gitlab.com/pages)之后部署网站，则 `baseurl` 已按此方式
配置。所有示例都是项目网站。如果您决定将自己的网站设为用户或群组网站，则必须从项目中移除此配置。对于 Jekyll 示例，请将 Jekyll `_config.yml` 修改为：

```yaml
baseurl: ""
```

如果您使用[纯 HTML 示例](https://gitlab.com/pages/plain-html)，
则无需设置 `baseurl`。

<a id="custom-domains"></a>

## 自定义域名

GitLab Pages 支持自定义域名和子域名，通过 HTTP 或 HTTPS 提供服务。
更多信息，请参阅 [GitLab Pages 自定义域名和 SSL/TLS 证书](custom_domains_ssl_tls_certification/_index.md)。
