---
stage: Plan
group: Planner Intelligence
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: GitLab Pages 设置
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

GitLab Pages 提供了用于自定义静态站点部署和展示的配置选项。通过 Pages 设置，您可以：

- 为 403 和 404 响应提供自定义错误页面。
- 通过 `_redirects` 文件配置 URL 重定向。
- 使用 CI/CD 规则从任意分支部署 Pages。
- 提供预压缩资源，以加快页面加载速度。
- 自定义站点发布时使用的文件夹。
- 为您的站点生成和管理唯一域名。

有关 Pages 的介绍，请参见 [GitLab Pages](_index.md)。

<a id="gitlab-pages-requirements"></a>

## GitLab Pages 要求

简而言之，要在 GitLab Pages 中上传您的网站，您需要：

1. 实例域名：用于 GitLab Pages 的域名
   （请咨询您的管理员）。
1. 极狐GitLab CI/CD：在代码仓库根目录中有一个包含名为 [`pages`](../../../ci/yaml/_index.md#pages)的特定作业的 `.gitlab-ci.yml` 文件。
1. 为项目启用极狐GitLab Runner。

<a id="gitlab-pages-on-gitlabcom"></a>

## JihuLab.com 上的 GitLab Pages

如果您使用 [JihuLab.com 上的 GitLab Pages](#gitlab-pages-on-gitlabcom) 来托管您的网站，那么：

- JihuLab.com 上 GitLab Pages 的域名是 `gitlab.io`。
- 已启用自定义域名和 TLS 支持。
- 实例 Runner 默认启用、免费提供，可用于构建您的网站。如果您愿意，仍然可以自带 Runner。

<a id="example-projects"></a>

## 示例项目

访问 [GitLab Pages 群组](https://gitlab.com/groups/pages)获取完整的示例项目列表。非常欢迎贡献。

<a id="custom-error-codes-pages"></a>

## 自定义错误代码页面

您可以通过在 `public/` 目录的根目录中创建 `403.html` 和 `404.html` 文件，来提供您自己的 `403` 和 `404` 错误页面。通常这是您项目的根目录，但根据您的静态生成器配置，可能会有所不同。

对于 `404.html`，存在不同的场景。例如：

- 如果您使用项目 Pages（在 `/project-slug/` 下提供服务）并尝试访问 `/project-slug/non/existing_file`，GitLab Pages 会先尝试提供 `/project-slug/404.html`，然后再尝试提供 `/404.html`。
- 如果您使用用户或群组 Pages（在 `/` 下提供服务）并尝试访问 `/non/existing_file`，GitLab Pages 会尝试提供 `/404.html`。
- 如果您使用自定义域名并尝试访问 `/non/existing_file`，GitLab Pages 只会尝试提供 `/404.html`。

<a id="redirects-in-gitlab-pages"></a>

## GitLab Pages 中的重定向

您可以使用 `_redirects` 文件为站点配置重定向。有关更多信息，请参见[为 GitLab Pages 创建重定向](redirects.md)。

<a id="delete-a-pages-site"></a>

## 删除 Pages 站点

永久删除项目的所有 Pages 部署。

> [!warning]
> 此更改无法撤销。

要删除您的 Pages：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**部署** > **站点**。
1. 选择**删除站点**。

您的 Pages 站点将不再部署。要再次部署此 Pages 站点，请运行新的流水线。

<a id="subdomains-of-subdomains"></a>

## 子域名的子域名

在极狐GitLab 实例的顶级域名（`*.example.io`）下使用 Pages 时，您无法对子域名的子域名使用 HTTPS。如果您的命名空间或群组名称包含点号（例如 `foo.bar`），则域名 `https://foo.bar.example.io` 无法正常工作。

此限制是由于 [HTTP Over TLS 协议](https://www.rfc-editor.org/rfc/rfc2818#section-3.1)所致。只要您不将 HTTP 重定向到 HTTPS，HTTP 页面就可以正常工作。

<a id="gitlab-pages-in-projects-and-groups"></a>

## 项目和群组中的 GitLab Pages

您必须在项目中托管您的 GitLab Pages 网站。该项目可以是[私有、内部或公开的](../../public_access.md)，并且可以属于某个[群组](../../group/_index.md)或[子群组](../../group/subgroups/_index.md)。

对于[群组网站](getting_started_part_one.md#user-and-group-website-examples)，群组必须位于顶级，不能是子群组。

对于[项目网站](getting_started_part_one.md#project-website-examples)，您可以先创建项目，然后通过 `http(s)://namespace.example.io/project-path` 访问它。

<a id="specific-configuration-options-for-pages"></a>

## Pages 的特定配置选项

了解如何为特定用例设置极狐GitLab CI/CD。

<a id="gitlab-ciyml-for-plain-html-websites"></a>

### 用于纯 HTML 网站的 `.gitlab-ci.yml`

假设您的代码仓库包含以下文件：

```plaintext
├── index.html
├── css
│   └── main.css
└── js
    └── main.js
```

那么下面的 `.gitlab-ci.yml` 示例会将所有文件从项目根目录移动到 `public/` 目录。`.public` 变通方法是为了避免 `cp` 将 `public/` 也复制到自身，从而陷入无限循环：

```yaml
create-pages:
  script:
    - mkdir .public
    - cp -r * .public
    - mv .public public
  pages: true  # specifies that this is a Pages job and publishes the default public directory
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
```

前面的 YAML 示例使用了[用户自定义作业名称](_index.md#user-defined-job-names)。

<a id="gitlab-ciyml-for-a-static-site-generator"></a>

### 用于静态站点生成器的 `.gitlab-ci.yml`

请参见本文档中的[分步指南](getting_started/pages_from_scratch.md)。

<a id="gitlab-ciyml-for-a-repository-with-code"></a>

### 用于包含代码的代码仓库的 `.gitlab-ci.yml`

请记住，GitLab Pages 默认与分支/标签无关，其部署完全取决于您在 `.gitlab-ci.yml`中指定的内容。每当有新提交推送到专门用于 Pages 的分支时，您都可以使用 [`rules:if`](../../../ci/yaml/_index.md#rulesif) 来限制 `pages` 作业。

这样，您就可以将项目代码放在 `main` 分支中，并使用一个孤立分支（我们将其命名为 `pages`）来托管您的静态生成器站点。

您可以像这样创建一个新的空分支：

```shell
git checkout --orphan pages
```

在这个新分支上进行的第一次提交没有父提交，并且是一个全新历史的根，与所有其他分支和提交完全断开。将静态生成器的源文件推送到 `pages` 分支中。

下面是 `.gitlab-ci.yml`的副本，其中最重要的一行是最后一行，它指定在 `pages` 分支中执行所有内容：

```yaml
create-pages:
  image: ruby:2.6
  script:
    - gem install jekyll
    - jekyll build -d public/
  pages: true  # specifies that this is a Pages job and publishes the default public directory
  rules:
    - if: '$CI_COMMIT_REF_NAME == "pages"'
```

请参见一个示例，该示例在 [`main` 分支](https://gitlab.com/pages/jekyll-branched/tree/main)中有不同的文件，而 Jekyll 的源文件位于 [`pages` 分支](https://gitlab.com/pages/jekyll-branched/tree/pages)中，该分支还包含 `.gitlab-ci.yml`。

前面的 YAML 示例使用了[用户自定义作业名称](_index.md#user-defined-job-names)。

<a id="serving-compressed-assets"></a>

### 提供压缩资源

大多数现代浏览器都支持下载压缩格式的文件。这通过减小文件大小来加快下载速度。

在提供未压缩文件之前，Pages 会检查是否存在具有 `.br` 或 `.gz` 扩展名的同名文件。如果存在，并且浏览器支持接收压缩文件，则会提供该版本而不是未压缩版本。

要利用此功能，您上传到 Pages 的产物应具有以下结构：

```plaintext
public/
├─┬ index.html
│ | index.html.br
│ └ index.html.gz
│
├── css/
│   └─┬ main.css
│     | main.css.br
│     └ main.css.gz
│
└── js/
    └─┬ main.js
      | main.js.br
      └ main.js.gz
```

这可以通过在您的 `.gitlab-ci.yml` Pages 作业中包含如下 `script:` 命令来实现：

```yaml
create-pages:
  # Other directives
  script:
    # Build the public/ directory first
    - find public -type f -regex '.*\.\(htm\|html\|xml\|txt\|text\|js\|css\|svg\)$' -exec gzip -f -k {} \;
    - find public -type f -regex '.*\.\(htm\|html\|xml\|txt\|text\|js\|css\|svg\)$' -exec brotli -f -k {} \;
  pages: true  # specifies that this is a Pages job
```

通过预压缩文件并在产物中包含两个版本，Pages 可以为压缩和未压缩内容的请求提供服务，而无需按需压缩文件。

前面的 YAML 示例使用了[用户自定义作业名称](_index.md#user-defined-job-names)。

<a id="resolving-ambiguous-urls"></a>

### 解析歧义 URL

当收到不包含扩展名的 URL 请求时，GitLab Pages 会假设要提供哪些文件。

考虑一个部署了以下文件的 Pages 站点：

```plaintext
public/
├── index.html
├── data.html
├── info.html
├── data/
│   └── index.html
└── info/
    └── details.html
```

Pages 支持通过多个不同的 URL 访问这些文件中的每一个。特别是，如果 URL 只指定了目录，它总是会查找 `index.html` 文件。如果 URL 引用的文件不存在，但在 URL 后添加 `.html` 会指向一个确实存在的文件，则会改为提供该文件。以下是在上述 Pages 站点中发生的一些示例：

| URL 路径             | HTTP 响应 |
| -------------------- | ------------- |
| `/`                  | `200 OK`：`public/index.html` |
| `/index.html`        | `200 OK`：`public/index.html` |
| `/index`             | `200 OK`：`public/index.html` |
| `/data`              | `302 Found`：重定向到 `/data/` |
| `/data/`             | `200 OK`：`public/data/index.html` |
| `/data.html`         | `200 OK`：`public/data.html` |
| `/info`              | `302 Found`：重定向到 `/info/` |
| `/info/`             | `404 Not Found` 错误页面 |
| `/info.html`         | `200 OK`：`public/info.html` |
| `/info/details`      | `200 OK`：`public/info/details.html` |
| `/info/details.html` | `200 OK`：`public/info/details.html` |

当 `public/data/index.html` 存在时，对于 `/data` 和 `/data/` 这两个 URL 路径，它都优先于 `public/data.html` 文件。

<a id="customize-the-default-folder"></a>

## 自定义默认文件夹

默认情况下，Pages 会在您的构建文件中查找名为 `public`的文件夹并将其发布。

要将该文件夹名称更改为任何其他值，请在 `.gitlab-ci.yml`中的 `deploy-pages` 作业配置中添加 `pages.publish` 属性。

以下示例改为发布名为 `dist`的文件夹：

```yaml
create-pages:
  script:
    - npm run build
  pages:  # specifies that this is a Pages job
    publish: dist
```

前面的 YAML 示例使用了[用户自定义作业名称](_index.md#user-defined-job-names)。

要在 `pages.publish` 字段中使用变量，请参见 [`pages.publish`](../../../ci/yaml/_index.md#pagespublish)。

Pages 使用产物来存储站点的文件，因此 `pages.publish`的值会自动追加到 [`artifacts:paths`](../../../ci/yaml/_index.md#artifactspaths)。
前面的示例等效于：

```yaml
create-pages:
  script:
    - npm run build
  pages:
    publish: dist
  artifacts:
    paths:
      - dist
```

> [!note]
> 顶级 `publish` 关键字已在极狐GitLab 17.9 中[弃用](https://gitlab.com/gitlab-org/gitlab/-/issues/519499)，现在必须嵌套在 `pages` 关键字下。

<a id="regenerate-unique-domain-for-gitlab-pages"></a>

## 为 GitLab Pages 重新生成唯一域名

您可以为您的 GitLab Pages 站点重新生成唯一域名。

域名重新生成后，之前的 URL 将不再有效。如果有人尝试访问旧 URL，他们会收到 `404` 错误。

先决条件

- 您必须拥有项目的维护者或所有者角色。
- 必须在项目的 Pages 设置中[启用](_index.md#unique-domains)**使用唯一域名**设置。

要为您的 GitLab Pages 站点重新生成唯一域名：

1. 在左侧边栏中，选择**部署** > **站点**。
1. 在**访问站点** 旁边，点击**重新生成唯一域名**。
1. 极狐GitLab 会为您的 Pages 站点生成一个新的唯一域名。

<a id="known-issues"></a>

## 已知问题

有关已知问题列表，请参见 GitLab [公共议题跟踪器](https://gitlab.com/gitlab-org/gitlab/-/issues?label_name[]=Category%3APages)。

<a id="troubleshooting"></a>

## 故障排除

<a id="404-error-when-accessing-a-gitlab-pages-site-url"></a>

### 访问 GitLab Pages 站点 URL 时出现 404 错误

此问题很可能是由于公共目录中缺少 `index.html` 文件所致。如果在部署 Pages 站点后遇到 404，请确认公共目录中包含 `index.html` 文件。如果文件包含不同的名称，例如 `test.html`，则 Pages 站点仍然可以访问，但需要完整路径。例如：`https://group-name.pages.example.com/project-slug/test.html`。

可以通过从最新流水线中[浏览产物](../../../ci/jobs/job_artifacts.md#download-job-artifacts)来确认公共目录的内容。

公共目录下列出的文件可以通过项目的 Pages URL 访问。

404 也可能与权限不正确有关。如果启用了 [Pages 访问控制](pages_access_control.md)，并且用户访问 Pages URL 时收到 404 响应，则该用户可能没有查看该站点的权限。要解决此问题，请确认该用户是项目的成员。

<a id="broken-relative-links"></a>

### 相对链接损坏

GitLab Pages 支持无扩展名 URL。但是，由于[议题 #354](https://gitlab.com/gitlab-org/gitlab-pages/-/issues/354)中描述的问题，如果无扩展名 URL 以正斜杠（`/`）结尾，它会破坏页面上的任何相对链接。

要解决此问题：

- 确保指向您的 Pages 站点的任何 URL 都带有扩展名，或者不包含尾部斜杠。
- 如果可能，在您的站点上只使用绝对 URL。

<a id="cannot-play-media-content-on-safari"></a>

### 无法在 Safari 上播放媒体内容

Safari 要求 Web 服务器支持 [Range 请求头](https://developer.apple.com/library/archive/documentation/AppleApplications/Reference/SafariWebContent/CreatingVideoforSafarioniPhone/CreatingVideoforSafarioniPhone.html#//apple_ref/doc/uid/TP40006514-SW6)才能播放您的媒体内容。要让 GitLab Pages 提供 HTTP Range 请求，您应该在 `.gitlab-ci.yml` 文件中使用以下两个变量：

```yaml
create-pages:
  stage: deploy
  variables:
    FF_USE_FASTZIP: "true"
    ARTIFACT_COMPRESSION_LEVEL: "fastest"
  script:
    - echo "Deploying pages"
  pages: true  # specifies that this is a Pages job and publishes the default public directory
  environment: production
```

`FF_USE_FASTZIP` 变量启用了 [`ARTIFACT_COMPRESSION_LEVEL`](../../../ci/runners/configure_runners.md#artifact-and-cache-settings) 所需的[功能标志](https://gitlab.cn/docs/runner/configuration/feature-flags/#available-feature-flags)。

前面的 YAML 示例使用了[用户自定义作业名称](_index.md#user-defined-job-names)。

<a id="401-error-when-accessing-private-gitlab-pages-sites-in-multiple-browser-tabs"></a>

### 在多个浏览器标签页中访问私有 GitLab Pages 站点时出现 `401` 错误

当您在没有事先认证的情况下同时在两个不同的标签页中访问私有 Pages URL 时，两个标签页会分别返回不同的 `state` 值。但是，在 Pages 会话中，对于给定的客户端，只会存储最新的 `state` 值。因此，在提交凭据后，其中一个标签页会返回 `401 Unauthorized` 错误。

要解决 `401` 错误，请刷新页面。

<a id="failing-pagesdeploy-job"></a>

### `pages:deploy` 作业失败

要使用 GitLab Pages 进行部署，根内容目录必须包含非空的 `index.html` 文件，否则 `pages:deploy` 作业会失败。

内容目录默认为 `public/`，或者是在 `.gitlab-ci.yml` 文件中使用 `pages.publish` 关键字指定的目录。
