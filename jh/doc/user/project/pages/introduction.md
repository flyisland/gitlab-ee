---
stage: Plan
group: Knowledge
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab Pages 设置
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

极狐GitLab Pages 提供了配置选项，可自定义静态站点的部署和呈现方式。
通过 Pages 设置，你可以：

- 为 403 和 404 响应提供自定义错误页面。
- 通过 `_redirects` 文件配置 URL 重定向。
- 使用 CI/CD 规则从任意分支部署站点。
- 提供预压缩资源以加快页面加载速度。
- 自定义站点发布的文件夹。
- 生成和管理站点的唯一域名。

本指南介绍极狐GitLab Pages 站点的可用设置和配置选项。
有关 Pages 的介绍，请参阅 [极狐GitLab Pages](_index.md)。

<a id="gitlab-pages-requirements"></a>

## 极狐GitLab Pages 要求

简而言之，在极狐GitLab Pages 中上传网站需要满足以下条件：

1. 实例的域名：用于极狐GitLab Pages 的域名（询问你的管理员）。
1. 极狐GitLab CI/CD：在仓库根目录中配置一个 `.gitlab-ci.yml` 文件，其中包含一个名为 [`pages`](../../../ci/yaml/_index.md#pages) 的特定作业。
1. 为项目启用极狐GitLab Runner。

<a id="gitlab-pages-on-gitlabcom"></a>

## 极狐GitLab.com 上的极狐GitLab Pages

如果你使用 [极狐GitLab.com 上的极狐GitLab Pages](#gitlab-pages-on-gitlabcom) 托管你的网站，那么：

- 极狐GitLab.com 上极狐GitLab Pages 的域名为 `gitlab.io`。
- 自定义域名和 TLS 支持已启用。
- 实例 Runner 默认启用，免费提供并可用于构建你的网站。如果你愿意，仍可使用自有的 Runner。

<a id="example-projects"></a>

## 示例项目

访问 [极狐GitLab Pages 群组](https://gitlab.com/groups/pages) 获取示例项目的完整列表。欢迎贡献。

<a id="custom-error-codes-pages"></a>

## 自定义错误代码页面

你可以通过在 `public/` 目录的根目录下创建 `403.html` 和 `404.html` 文件来提供自己的 `403` 和 `404` 错误页面。通常这是你项目的根目录，但也可能因静态生成器配置而异。

对于 `404.html` 的情况，有以下几种场景。例如：

- 如果你使用项目 Pages（通过 `/project-slug/` 提供）并尝试访问 `/project-slug/non/existing_file`，极狐GitLab Pages 会先尝试提供 `/project-slug/404.html`，然后是 `/404.html`。
- 如果你使用用户或群组 Pages（通过 `/` 提供）并尝试访问 `/non/existing_file`，极狐GitLab Pages 会尝试提供 `/404.html`。
- 如果你使用自定义域名并尝试访问 `/non/existing_file`，极狐GitLab Pages 仅会尝试提供 `/404.html`。

<a id="redirects-in-gitlab-pages"></a>

## 极狐GitLab Pages 中的重定向

你可以使用 `_redirects` 文件为站点配置重定向。有关更多信息，请参阅 [为极狐GitLab Pages 创建重定向](redirects.md)。

<a id="delete-a-pages-site"></a>

## 删除 Pages 站点

永久删除项目的所有 Pages 部署。

> [!warning]
> 此操作无法撤销。

要删除你的站点：

1. 在顶栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **部署** > **站点**。
1. 选择 **删除站点**。

你的 Pages 站点将不再部署。
要重新部署此 Pages 站点，请运行新的流水线。

<a id="subdomains-of-subdomains"></a>

## 子域名的子域名

当在极狐GitLab 实例的顶级域名下（例如 `*.example.io`）使用 Pages 时，你无法对子域名的子域名使用 HTTPS。如果你的命名空间或群组名称包含点号（例如 `foo.bar`），则域名 `https://foo.bar.example.io` **不** 工作。

此限制源于 [HTTP Over TLS 协议](https://www.rfc-editor.org/rfc/rfc2818#section-3.1)。只要你不将 HTTP 重定向到 HTTPS，HTTP 页面就能正常工作。

<a id="gitlab-pages-in-projects-and-groups"></a>

## 项目与群组中的极狐GitLab Pages

你必须在项目中托管你的极狐GitLab Pages 网站。此项目可以是[私有、内部或公开](../../public_access.md)的，并属于[群组](../../group/_index.md)或[子群组](../../group/subgroups/_index.md)。

对于[群组网站](getting_started_part_one.md#user-and-group-website-examples)，群组必须位于顶级而非子群组。

对于[项目网站](getting_started_part_one.md#project-website-examples)，你可以先创建项目，然后通过 `http(s)://namespace.example.io/project-path` 访问它。

<a id="specific-configuration-options-for-pages"></a>

## Pages 特定配置选项

了解如何针对特定用例设置极狐GitLab CI/CD。

<a id="gitlab-ciyml-for-plain-html-websites"></a>

### 适用于普通 HTML 网站的 `.gitlab-ci.yml`

假设你的仓库包含以下文件：

```plaintext
├── index.html
├── css
│   └── main.css
└── js
    └── main.js
```

那么下面的 `.gitlab-ci.yml` 示例将所有文件从项目根目录移动到 `public/` 目录。`.public` 变通方法是为了防止 `cp` 也将 `public/` 复制到自身形成无限循环：

```yaml
create-pages:
  script:
    - mkdir .public
    - cp -r * .public
    - mv .public public
  pages: true  # 指定这是一个 Pages 作业，并发布默认的 public 目录
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
```

上面的 YAML 示例使用了[用户自定义作业名称](_index.md#user-defined-job-names)。

<a id="gitlab-ciyml-for-a-static-site-generator"></a>

### 适用于静态站点生成器的 `.gitlab-ci.yml`

请参阅此文档获取[逐步指南](getting_started/pages_from_scratch.md)。

<a id="gitlab-ciyml-for-a-repository-with-code"></a>

### 适用于包含代码的仓库的 `.gitlab-ci.yml`

记住，极狐GitLab Pages 默认与分支/标签无关，其部署完全依赖于你在 `.gitlab-ci.yml` 中指定的内容。你可以利用 [`rules:if`](../../../ci/yaml/_index.md#rulesif) 限制 `pages` 作业，仅在向专门用于 Pages 的分支推送新提交时执行。

这样，你可以将项目代码放在 `main` 分支，并使用一个孤立分支（我们将其命名为 `pages`）来托管静态站点生成器。

你可以这样创建一个新的空分支：

```shell
git checkout --orphan pages
```

这个新分支上的第一个提交没有父节点，全新历史的根与所有其他分支和提交完全断开。将静态生成器的源文件推送到 `pages` 分支。

下面是一个 `.gitlab-ci.yml` 副本，其中最显著的一行是最后一行，指定在 `pages` 分支上执行所有内容：

```yaml
create-pages:
  image: ruby:2.6
  script:
    - gem install jekyll
    - jekyll build -d public/
  pages: true  # 指定这是一个 Pages 作业，并发布默认的 public 目录
  rules:
    - if: '$CI_COMMIT_REF_NAME == "pages"'
```

查看一个示例，其中 [`main` 分支](https://gitlab.com/pages/jekyll-branched/tree/main) 中包含不同的文件，而 Jekyll 的源文件在 [`pages` 分支](https://gitlab.com/pages/jekyll-branched/tree/pages) 中，该分支也包含了 `.gitlab-ci.yml`。

上面的 YAML 示例使用了[用户自定义作业名称](_index.md#user-defined-job-names)。

<a id="serving-compressed-assets"></a>

### 提供压缩资源

大多数现代浏览器支持下载压缩格式的文件。这通过减少文件大小加快了下载速度。

在提供未压缩文件之前，Pages 会检查是否存在具有 `.br` 或 `.gz` 扩展名的相同文件。如果存在，并且浏览器支持接收压缩文件，则会提供该版本而非未压缩版本。

要利用此功能，你上传到 Pages 的产物应具有以下结构：

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

可以通过在 `.gitlab-ci.yml` 的 pages 作业中包含类似这样的 `script:` 命令来实现：

```yaml
create-pages:
  # 其他指令
  script:
    # 先构建 public/ 目录
    - find public -type f -regex '.*\.\(htm\|html\|xml\|txt\|text\|js\|css\|svg\)$' -exec gzip -f -k {} \;
    - find public -type f -regex '.*\.\(htm\|html\|xml\|txt\|text\|js\|css\|svg\)$' -exec brotli -f -k {} \;
  pages: true  # 指定这是一个 Pages 作业
```

通过预压缩文件并在产物中包含两种版本，Pages 可以同时为压缩和未压缩内容提供服务，而无需按需压缩文件。

上面的 YAML 示例使用了[用户自定义作业名称](_index.md#user-defined-job-names)。

<a id="resolving-ambiguous-urls"></a>

### 解析模糊 URL

当接收到不包含扩展名的 URL 请求时，极狐GitLab Pages 会假设提供哪些文件。

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

Pages 支持通过多个不同的 URL 访问这些文件。特别是，如果 URL 仅指定目录，它总是会寻找 `index.html` 文件。如果 URL 引用的文件不存在，但在 URL 后添加 `.html` 能指向一个存在的文件，则会提供该文件。以下是基于上述 Pages 站点的一些示例：

| URL 路径             | HTTP 响应 |
| -------------------- | ------------- |
| `/`                  | `200 OK`: `public/index.html` |
| `/index.html`        | `200 OK`: `public/index.html` |
| `/index`             | `200 OK`: `public/index.html` |
| `/data`              | `302 Found`: 重定向到 `/data/` |
| `/data/`             | `200 OK`: `public/data/index.html` |
| `/data.html`         | `200 OK`: `public/data.html` |
| `/info`              | `302 Found`: 重定向到 `/info/` |
| `/info/`             | `404 Not Found` 错误页面 |
| `/info.html`         | `200 OK`: `public/info.html` |
| `/info/details`      | `200 OK`: `public/info/details.html` |
| `/info/details.html` | `200 OK`: `public/info/details.html` |

当 `public/data/index.html` 存在时，对于 `/data` 和 `/data/` 这两种 URL 路径，它的优先级高于 `public/data.html` 文件。

<a id="customize-the-default-folder"></a>

## 自定义默认文件夹

{{< history >}}

- 引入于 极狐GitLab 15.4，使用名为 `FF_CONFIGURABLE_ROOT_DIR` 的[功能标志](../../../administration/feature_flags/_index.md)。默认禁用。
- 在 极狐GitLab 15.4 在 JihuLab.com 上启用。
- 在 极狐GitLab 16.2 在私有化部署上启用。
- 在 极狐GitLab 17.9 更改为允许在 `publish` 属性中传入变量。
- 在 极狐GitLab 17.9 将 `publish` 属性移动到 `pages` 关键字下。
- 在 极狐GitLab 17.10 将 `pages.publish` 路径自动追加到 `artifacts:paths`。

{{< /history >}}

默认情况下，Pages 会在构建文件中查找名为 `public` 的文件夹以发布。

要将文件夹名称更改为其他值，请在 `.gitlab-ci.yml` 的 `deploy-pages` 作业配置中添加 `pages.publish` 属性。

以下示例改为发布一个名为 `dist` 的文件夹：

```yaml
create-pages:
  script:
    - npm run build
  pages:  # 指定这是一个 Pages 作业
    publish: dist
```

上面的 YAML 示例使用了[用户自定义作业名称](_index.md#user-defined-job-names)。

欲在 `pages.publish` 字段中使用变量，请参阅 [`pages.publish`](../../../ci/yaml/_index.md#pagespublish)。

Pages 使用产物存储站点文件，因此 `pages.publish` 的值会自动追加到 [`artifacts:paths`](../../../ci/yaml/_index.md#artifactspaths)。前面的示例相当于：

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
> 顶层 `publish` 关键字已在 极狐GitLab 17.9 中被[弃用](https://jihulab.com/gitlab-cn/gitlab/-/issues/519499)，现在必须嵌套在 `pages` 关键字下。

<a id="regenerate-unique-domain-for-gitlab-pages"></a>

## 为极狐GitLab Pages 重新生成唯一域名

{{< history >}}

- 引入于 极狐GitLab 17.7。

{{< /history >}}

你可以为极狐GitLab Pages 站点重新生成唯一域名。

重新生成域后，之前的 URL 将不再有效。如果任何人尝试访问旧的 URL，他们将收到 `404` 错误。

前提条件

- 你必须具有项目的 维护者 或 所有者 角色。
- 在你的项目 Pages 设置中，**使用唯一域名** 设置 [必须已启用](_index.md#unique-domains)。

要重新生成极狐GitLab Pages 站点的唯一域名：

1. 在左侧边栏中，选择 **部署** > **站点**。
1. 在 **访问站点** 旁边，点击 **重新生成唯一域名**。
1. 极狐GitLab 会为你的 Pages 站点生成一个新的唯一域名。

<a id="known-issues"></a>

## 已知问题

有关已知问题列表，请参阅极狐GitLab [公开议题跟踪器](https://jihulab.com/gitlab-cn/gitlab/-/issues?label_name[]=Category%3APages)。

<a id="troubleshooting"></a>

## 故障排除

<a id="404-error-when-accessing-a-gitlab-pages-site-url"></a>

### 访问极狐GitLab Pages 站点 URL 时出现 404 错误

此问题很可能是因为公共目录中缺少 `index.html` 文件。如果在部署 Pages 站点后遇到 404 错误，请确认公共目录中包含 `index.html` 文件。如果文件具有不同的名称（例如 `test.html`），该 Pages 站点仍然可以访问，但需要完整路径。例如：`https//group-name.pages.example.com/project-slug/test.html`。

可以通过[浏览最新流水线中的产物](../../../ci/jobs/job_artifacts.md#download-job-artifacts)来确认公共目录的内容。

列在公共目录下的文件可以通过项目的 Pages URL 访问。

404 错误也可能与权限不正确有关。如果启用了 [Pages 访问控制](pages_access_control.md)，并且用户访问 Pages URL 时收到 404 响应，则该用户可能无权查看该站点。要解决此问题，请验证该用户是否为项目成员。

<a id="broken-relative-links"></a>

### 损坏的相对链接

极狐GitLab Pages 支持无扩展名的 URL。然而，由于 [议题 #354](https://jihulab.com/gitlab-cn/gitlab-pages/-/issues/354) 中描述的问题，如果无扩展名的 URL 以正斜杠 (`/`) 结尾，它会破坏页面上的任何相对链接。

要解决此问题：

- 确保指向你 Pages 站点的任何 URL 具有扩展名，或不包含尾部斜杠。
- 如果可能，仅在站点上使用绝对 URL。

<a id="cannot-play-media-content-on-safari"></a>

### 无法在 Safari 上播放媒体内容

Safari 要求 Web 服务器支持 [Range 请求头](https://developer.apple.com/library/archive/documentation/AppleApplications/Reference/SafariWebContent/CreatingVideoforSafarioniPhone/CreatingVideoforSafarioniPhone.html#//apple_ref/doc/uid/TP40006514-SW6) 才能播放媒体内容。为了让极狐GitLab Pages 提供 HTTP Range 请求，你应在 `.gitlab-ci.yml` 文件中使用以下两个变量：

```yaml
create-pages:
  stage: deploy
  variables:
    FF_USE_FASTZIP: "true"
    ARTIFACT_COMPRESSION_LEVEL: "fastest"
  script:
    - echo "Deploying pages"
  pages: true  # 指定这是一个 Pages 作业，并发布默认的 public 目录
  environment: production
```

`FF_USE_FASTZIP` 变量启用了 [`ARTIFACT_COMPRESSION_LEVEL`](../../../ci/runners/configure_runners.md#artifact-and-cache-settings) 所需的[功能标志](https://gitlab.cn/docs/runner/configuration/feature-flags/#available-feature-flags)。

上面的 YAML 示例使用了[用户自定义作业名称](_index.md#user-defined-job-names)。

<a id="401-error-when-accessing-private-gitlab-pages-sites-in-multiple-browser-tabs"></a>

### 在多个浏览器标签页中访问私有极狐GitLab Pages 站点时出现 `401` 错误

当你尝试在没有事先认证的情况下同时在两个不同的标签页中访问私有的 Pages URL 时，每个标签页会返回不同的 `state` 值。然而，在 Pages 会话中，仅为给定的客户端存储最新的 `state` 值。因此，在提交凭据后，其中一个标签页会返回 `401 Unauthorized` 错误。

要解决 `401` 错误，请刷新页面。

<a id="failing-pagesdeploy-job"></a>

### `pages:deploy` 作业失败

要使用极狐GitLab Pages 进行部署，根内容目录必须包含一个非空的 `index.html` 文件，否则 `pages:deploy` 作业会失败。

内容目录默认为 `public/`，或由 `.gitlab-ci.yml` 文件中的 `pages.publish` 关键字指定的目录。