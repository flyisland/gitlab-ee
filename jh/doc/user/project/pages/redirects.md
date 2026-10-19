---
stage: Plan
group: Knowledge
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab Pages 重定向
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

在极狐GitLab Pages 中，你可以配置规则，使用 [Netlify 风格](https://docs.netlify.com/routing/redirects/#syntax-for-the-redirects-file) 的 HTTP 重定向将一个 URL 转发到另一个 URL。

并非所有 [Netlify 提供的特殊选项](https://docs.netlify.com/routing/redirects/redirect-options/) 都受支持。

| 功能                                           | 是否支持              | 示例 |
|---------------------------------------------------|------------------------|---------|
| [重定向（`301`、`302`）](#重定向)            | {{< yes >}} | `/wardrobe.html /narnia.html 302` |
| [重写（`200`）](#重写)                     | {{< yes >}} | `/* / 200` |
| [Splat](#splat)                                 | {{< yes >}} | `/news/*  /blog/:splat` |
| [占位符](#占位符)                     | {{< yes >}} | `/news/:year/:month/:date /blog-:year-:month-:date.html` |
| 重写（`200` 除外）                       | {{< no >}} | `/en/* /en/404.html 404` |
| 查询参数                                  | {{< no >}} | `/store id=:id  /blog/:id  301` |
| 强制（[影藏](https://docs.netlify.com/routing/redirects/rewrites-proxies/#shadowing)） | {{< no >}} | `/app/  /app/index.html  200!` |
| [域名级重定向](#域名级重定向) | {{< yes >}} | `http://blog.example.com/* https://www.example.com/blog/:splat 301` |
| 按国家/语言重定向                   | {{< no >}} | `/  /anz     302  Country=au,nz` |
| 按角色重定向                                  | {{< no >}} | `/admin/*  200!  Role=admin` |

> [!note]
> [匹配行为测试用例](https://jihulab.com/gitlab-cn/gitlab-pages/-/blob/master/internal/redirects/matching_test.go) 是详细了解极狐GitLab 如何实现规则匹配的良好资源。欢迎社区为未包含在此测试套件中的任何极端情况做出贡献！

<a id="create-redirects"></a>

## 创建重定向

要创建重定向，请在极狐GitLab Pages 站点的 `public/` 目录中创建一个名为 `_redirects` 的配置文件。

- 所有路径必须以正斜杠 `/` 开头。
- 如果未提供 [HTTP 状态码](#http-状态码)，默认为 `301`。
- 实例级配置了 `_redirects` 文件的文件大小限制和每个项目的最大规则数。仅处理配置的最大数量中最先匹配的规则。默认文件大小限制为 64 KB，默认最大规则数为 1,000。
- 如果你的极狐GitLab Pages 站点使用默认域名（如 `namespace.gitlab.io/project-slug`），你必须在每条规则前加上路径前缀：

  ```plaintext
  /project-slug/wardrobe.html /project-slug/narnia.html 302
  ```

- 如果你的极狐GitLab Pages 站点使用 [自定义域名](custom_domains_ssl_tls_certification/_index.md)，则不需要项目路径前缀。例如，如果你的自定义域名是 `example.com`，你的 `_redirects` 文件将如下所示：

  ```plaintext
  /wardrobe.html /narnia.html 302
  ```

<a id="files-override-redirects"></a>

## 文件会覆盖重定向

文件的优先级高于重定向。如果磁盘上存在某个文件，极狐GitLab Pages 将提供该文件，而不是执行重定向。例如，如果存在 `hello.html` 和 `world.html` 文件，并且 `_redirects` 文件包含以下行，则由于 `hello.html` 存在，该重定向将被忽略：

```plaintext
/project-slug/hello.html /project-slug/world.html 302
```

极狐GitLab 不支持 Netlify 的 [强制选项](https://docs.netlify.com/routing/redirects/rewrites-proxies/#shadowing) 来改变此行为。

<a id="http-status-codes"></a>

## HTTP 状态码

如果未提供状态码，默认为 `301`，但你可以显式设置自己的状态码。支持以下 HTTP 状态码：

- **301**：永久重定向。
- **302**：临时重定向。
- **200**：成功的 HTTP 请求标准响应。如果 `to` 规则中的内容存在，Pages 将提供该内容，而不更改地址栏中的 URL。

<a id="redirects"></a>

## 重定向

要创建重定向，请添加一条规则，包含 `from` 路径、`to` 路径和一个 [HTTP 状态码](#http-状态码)：

```plaintext
# 301 永久重定向
/old/file.html /new/file.html 301

# 302 临时重定向
/old/another_file.html /new/another_file.html 302
```

<a id="rewrites"></a>

## 重写

提供状态码 `200`，以便在请求匹配 `from` 路径时，提供 `to` 路径中的内容：

```plaintext
/old/file.html /new/file.html 200
```

此状态码可与 [splat 规则](#splat) 结合使用，以动态重写 URL。

<a id="domain-level-redirects"></a>

## 域名级重定向

{{< history >}}

- 于极狐GitLab 16.8 引入，[功能标志](../../../administration/feature_flags/_index.md) 命名为 `FF_ENABLE_DOMAIN_REDIRECT`，默认禁用。
- 于极狐GitLab 16.9 在 JihuLab.com 启用。
- 于极狐GitLab 16.10 在私有化部署中启用。
- GA 于极狐GitLab 17.4，功能标志 `FF_ENABLE_DOMAIN_REDIRECT` 已删除。

{{< /history >}}

要创建域名级重定向，请将域名级路径（以 `http://` 或 `https://` 开头）添加到以下任一位置：

- 仅 `to` 路径。
- `from` 和 `to` 路径。

支持的 [HTTP 状态码](#http-状态码) 为 `301` 和 `302`：

```plaintext
# 301 永久重定向
http://blog.example.com/file_1.html https://www.example.com/blog/file_1.html 301
/file_2.html https://www.example.com/blog/file_2.html 301

# 302 临时重定向
http://blog.example.com/file_3.html https://www.example.com/blog/file_3.html 302
/file_4.html https://www.example.com/blog/file_4.html 302
```

域名级重定向可与 [splat 规则](#splat)（包括 splat 占位符）结合使用，以动态重写 URL 路径。

<a id="splats"></a>

## Splat

在 `from` 路径中包含星号（`*`）的规则，称为 splat，可匹配请求路径的开头、中间或结尾的任何内容。以下示例匹配 `/old/` 之后的任何内容，并将其重写为 `/new/file.html`：

```plaintext
/old/* /new/file.html 200
```

### Splat 占位符

规则 `from` 路径中由 `*` 匹配的内容，可以使用 `:splat` 占位符注入到 `to` 路径中：

```plaintext
/old/* /new/:splat 200
```

在此示例中，对 `/old/file.html` 的请求将提供 `/new/file.html` 的内容，并返回 `200` 状态码。

如果规则的 `from` 路径包含多个 splat，则第一个 splat 匹配的值将替换 `to` 路径中的所有 `:splat`。

### Splat 匹配行为

Splat 是“贪婪的”，会匹配尽可能多的字符：

```plaintext
/old/*/file /new/:splat/file 301
```

在此示例中，该规则将 `/old/a/b/c/file` 重定向到 `/new/a/b/c/file`。

Splat 也会匹配空字符串，因此上述规则会将 `/old/file` 重定向到 `/new/file`。

### 将所有请求重写为根 `index.html`

单页应用程序（SPA）通常使用客户端路由自行处理路由。对于这些应用程序，请将所有请求重写为根 `index.html`，以便路由逻辑可由 JavaScript 应用程序处理。

要将请求重写为 `index.html`：

1. 添加此 `_redirects` 规则：

   ```plaintext
   /* /index.html 200
   ```

1. 要使单页应用程序与并行部署配合使用，请编辑重定向规则以包含路径前缀：

   ```plaintext
   /project/base/<prefix>/* /project/base/<prefix>/index.html 200
   ```

   将 `<prefix>` 替换为你的路径前缀值。

<a id="placeholders"></a>

## 占位符

使用规则中的占位符来匹配所请求 URL 的部分内容，并在重写或重定向到新 URL 时使用这些匹配项。

占位符的格式为 `:` 字符后跟一串字母（`[a-zA-Z]+`），同时出现在 `from` 和 `to` 路径中：

```plaintext
/news/:year/:month/:date/:slug /blog/:year-:month-:date-:slug 200
```

此规则指示 Pages 响应 `/news/2021/08/12/file.html` 的请求，提供 `/blog/2021-08-12-file.html` 的内容并返回 `200`。

### 占位符匹配行为

与 [splat](#splat) 相比，占位符在匹配内容方面更有限。占位符匹配正斜杠（`/`）之间的文本，因此请使用占位符匹配单段路径。

此外，占位符不匹配空字符串。像下面这样的规则**不会**匹配 `/old/file` 这样的请求 URL：

```plaintext
/old/:path /new/:path
```

<a id="debug-redirect-rules"></a>

## 调试重定向规则

如果重定向未按预期工作，或者想检查重定向语法，请访问 `[你的 pages 网址]/_redirects`。`_redirects` 文件不会直接提供，但你的浏览器会显示一个编号列表，列出你的重定向规则以及规则是否有效或无效：

```plaintext
11 条规则
rule 1: 有效
rule 2: 有效
rule 3: 错误：splat 不受支持
rule 4: 有效
rule 5: 错误：占位符不受支持
rule 6: 有效
rule 7: 错误：不允许将域名级重定向指向外部站点
rule 8: 错误：URL 路径必须以正斜杠 / 开头
rule 9: 错误：不允许将域名级重定向指向外部站点
rule 10: 有效
rule 11: 有效
```

<a id="differences-from-netlify-implementation"></a>

## 与 Netlify 实现的差异

大多数受支持的 `_redirects` 规则在极狐GitLab 和 Netlify 中的行为相同。不过，也存在一些细微的差异：

- **所有规则 URL 必须以斜杠开头**：

  Netlify 不要求 URL 以正斜杠开头：

  ```plaintext
  # 在 Netlify 中有效，在极狐GitLab 中无效
  */path /new/path 200
  ```

  极狐GitLab 验证所有 URL 必须以正斜杠开头。上一个示例的有效等效项：

  ```plaintext
  # 在 Netlify 和极狐GitLab 中均有效
  /old/path /new/path 200
  ```

- **所有占位符值均被填充**：

  Netlify 仅填充出现在 `to` 路径中的占位符值：

  ```plaintext
  /old /new/:placeholder
  ```

  给定对 `/old` 的请求：

  - Netlify 重定向到 `/new/:placeholder`（带有文字 `:placeholder`）。
  - 极狐GitLab 重定向到 `/new/`。

