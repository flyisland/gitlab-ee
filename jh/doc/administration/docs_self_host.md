---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.jihulab.com/handbook/product/ux/technical-writing/#assignments>
title: 托管极狐GitLab 产品文档
description: Host the product documentation yourself.
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

如果您无法在 `gitlab.cn/docs` 访问极狐GitLab 产品文档，您可以自行托管文档。

> [!note]
> 您实例的本地帮助不包含所有文档（例如，不包含极狐GitLab Runner 或极狐GitLab Operator 的文档），并且无法搜索或浏览。它仅用于支持从实例内部直接链接到特定页面。

<a id="container-registry-url"></a>

## 容器镜像仓库 URL

您需要的容器镜像 URL 取决于所需的极狐GitLab 文档版本。
以下表格将指导您在后续部分使用的 URL。

| 极狐GitLab 版本 | 容器镜像仓库 | 容器镜像 URL |
|:---------------|:---------------------------------------------------------------------------|:--------------------|
| 17.8 及更高版本 | <https://jihulab.com/gitlab-cn/technical-writing/docs-gitlab-com/container_registry/8244403> | `registry.jihulab.com/gitlab-cn/technical-writing/docs-gitlab-com/archives:<version>` |
| 15.5 - 17.7    | <https://jihulab.com/gitlab-cn/gitlab-docs/container_registry/3631228>     | `registry.jihulab.com/gitlab-cn/gitlab-docs/archives:<version>` |
| 10.3 - 15.4    | <https://jihulab.com/gitlab-cn/gitlab-docs/container_registry/631635>      | `registry.jihulab.com/gitlab-cn/gitlab-docs:<version>` |

<a id="documentation-self-hosting-options"></a>

## 文档自托管选项

要托管极狐GitLab 产品文档，您可以使用：

- Docker 容器
- 极狐GitLab Pages
- 您自己的 Web 服务器

以下示例使用极狐GitLab 17.8，但请务必使用与您的极狐GitLab 实例对应的版本。

<a id="self-host-the-product-documentation-with-docker"></a>

### 使用 Docker 自托管产品文档

文档网站在容器内的 `4000` 端口提供服务。在以下示例中，我们在主机上的相同端口公开此服务。

确保您执行以下任一操作：

- 在防火墙中允许端口 `4000`。
- 使用其他端口。
  在以下示例中，将最左侧的 `4000` 替换为其他端口号。

要在 Docker 容器中运行极狐GitLab 产品文档网站：

1. 在托管极狐GitLab 的服务器上，或与您的极狐GitLab 实例可以进行通信的任何其他服务器上：

   - 如果您使用普通 Docker，请运行：

     ```shell
     docker run --detach --name gitlab_docs -it --rm -p 4000:4000 registry.jihulab.com/gitlab-cn/technical-writing/docs-gitlab-com/archives:17.8
     ```

   - 如果您使用 [Docker Compose](../install/docker/installation.md#install-gitlab-by-using-docker-compose) 托管您的极狐GitLab 实例，请将以下内容添加到现有的 `docker-compose.yaml` 中：

     ```yaml
     version: '3.6'
     services:
       gitlab_docs:
         image: registry.jihulab.com/gitlab-cn/technical-writing/docs-gitlab-com/archives:17.8
         hostname: 'docs.gitlab.example.com'
         ports:
           - '4000:4000'
     ```

     然后，拉取更改：

     ```shell
     docker-compose up -d
     ```

1. 访问 `http://0.0.0.0:4000` 查看文档网站并验证其是否正常工作。
1. [将帮助链接重定向到新的文档站点](#redirect-the-help-links-to-the-new-docs-site)。

<a id="self-host-the-product-documentation-with-gitlab-pages"></a>

### 使用极狐GitLab Pages 自托管产品文档

您可以使用极狐GitLab Pages 来托管极狐GitLab 产品文档。

先决条件：

- 确保 Pages 站点 URL 不使用子文件夹。由于站点预编译的方式，CSS 和 JavaScript 文件相对于主域或子域。因此，不支持类似 `https://example.com/docs/` 的 URL。

要使用极狐GitLab Pages 托管产品文档站点：

1. [创建一个空白项目](../user/project/_index.md#create-a-blank-project)。
1. 创建一个新的或编辑您现有的 `.gitlab-ci.yml` 文件，并添加以下 `pages` 作业，同时确保版本与您的极狐GitLab 安装一致：

   ```yaml
   pages:
     image: registry.jihulab.com/gitlab-cn/technical-writing/docs-gitlab-com/archives:17.8
     script:
       - mkdir public
       - cp -a /usr/share/nginx/html/* public/
     artifacts:
       paths:
       - public
   ```

1. 可选。设置极狐GitLab Pages 域名。根据极狐GitLab Pages 网站的类型，您有两个选项：

   | 网站类型 | [默认域名](../user/project/pages/getting_started_part_one.md#gitlab-pages-default-domain-names) | [自定义域名](../user/project/pages/custom_domains_ssl_tls_certification/_index.md) |
   |-------------------------|----------------|---------------|
   | [项目网站](../user/project/pages/getting_started_part_one.md#project-website-examples) | 不支持 | 支持 |
   | [用户或群组网站](../user/project/pages/getting_started_part_one.md#user-and-group-website-examples) | 支持 | 支持 |

1. [将帮助链接重定向到新的文档站点](#redirect-the-help-links-to-the-new-docs-site)。

<a id="self-host-the-product-documentation-on-your-own-web-server"></a>

### 在您自己的 Web 服务器上自托管产品文档

> [!note]
> 您创建的网站必须托管在与您安装的极狐GitLab 版本匹配的子目录下（例如 `17.8/`）。[Docker 镜像](https://jihulab.com/gitlab-cn/technical-writing/docs-gitlab-com/container_registry/8244403) 默认使用此版本。

由于产品文档站点是静态的，您可以从容器内部获取 `/usr/share/nginx/html` 的内容，并使用自己的 Web 服务器来托管文档，位置随意。

`html` 目录应按原样提供，其结构如下：

```plaintext
├── 17.8/
├── index.html
```

在这个示例中：

- `17.8/` 是托管文档的目录。
- `index.html` 是一个简单的 HTML 文件，它会重定向到包含文档的目录，即 `17.8/`。

要提取文档站点的 HTML 文件：

1. 创建保存文档网站 HTML 文件的容器：

   ```shell
   docker create -it --name gitlab_docs registry.jihulab.com/gitlab-cn/technical-writing/docs-gitlab-com/archives:17.8
   ```

1. 将网站复制到 `/srv/gitlab/` 下：

   ```shell
   docker cp gitlab-docs:/usr/share/nginx/html /srv/gitlab/
   ```

   您将在 `/srv/gitlab/html/` 目录下获得包含文档网站的目录。

1. 删除容器：

   ```shell
   docker rm -f gitlab_docs
   ```

1. 将您的 Web 服务器指向提供 `/srv/gitlab/html/` 目录的内容。
1. [将帮助链接重定向到新的文档站点](#redirect-the-help-links-to-the-new-docs-site)。

<a id="redirect-the-help-links-to-the-new-docs-site"></a>

## 将 `/help` 链接重定向到新的文档站点

在您的本地产品文档站点运行后，通过在极狐GitLab 应用程序中[重定向帮助链接](settings/help_page.md#redirect-help-pages)到您的本地站点，使用完全限定域名作为文档 URL。例如，如果您使用了 [Docker 方法](#self-host-the-product-documentation-with-docker)，请输入 `http://0.0.0.0:4000`。

您无需附加版本。极狐GitLab 会检测版本并针对文档 URL 请求根据需要附加版本。例如，如果您的极狐GitLab 版本是 17.8：

- 极狐GitLab 文档 URL 变为 `http://0.0.0.0:4000/17.8/`。
- 极狐GitLab 中的链接显示为 `<instance_url>/help/administration/settings/help_page#destination-requirements`。
- 当您选择该链接时，您将被重定向到 `http://0.0.0.0:4000/17.8/administration/settings/help_page/#destination-requirements`。

要测试该设置，请在极狐GitLab 中选择一个 **了解更多** 链接。例如：

1. 在右上角，选择您的头像。
2. 选择 **偏好设置**。
3. 在 **语法高亮主题** 部分，选择 **了解更多**。

<a id="upgrade-the-product-documentation-to-a-later-version"></a>

## 将产品文档升级到更高版本

要升级文档站点到更高版本，需要下载较新的 Docker 镜像标签。

<a id="upgrade-using-docker"></a>

### 使用 Docker 升级

要[使用 Docker](#self-host-the-product-documentation-with-docker) 升级到更高版本：

- 如果您使用 Docker：

  1. 停止正在运行的容器：

     ```shell
     sudo docker stop gitlab_docs
     ```

  1. 删除现有容器：

     ```shell
     sudo docker rm gitlab_docs
     ```

  1. 拉取新镜像。例如，17.8：

     ```shell
     docker run --detach --name gitlab_docs -it --rm -p 4000:4000 registry.jihulab.com/gitlab-cn/technical-writing/docs-gitlab-com/archives:17.8
     ```

- 如果您使用 Docker Compose：

  1. 在 `docker-compose.yaml` 中更改版本，例如 17.8：

     ```yaml
     version: '3.6'
     services:
       gitlab_docs:
         image: registry.jihulab.com/gitlab-cn/technical-writing/docs-gitlab-com/archives:17.8
         hostname: 'docs.gitlab.example.com'
         ports:
           - '4000:4000'
     ```

  1. 拉取更改：

     ```shell
     docker-compose up -d
     ```

<a id="upgrade-using-gitlab-pages"></a>

### 使用极狐GitLab Pages 升级

要[使用极狐GitLab Pages](#self-host-the-product-documentation-with-gitlab-pages) 升级到更高版本：

1. 编辑您现有的 `.gitlab-ci.yml` 文件，并替换 `image` 版本号：

   ```yaml
   image: registry.jihulab.com/gitlab-cn/technical-writing/docs-gitlab-com/archives:17.8
   ```

1. 提交更改并推送，极狐GitLab Pages 将拉取新的文档站点版本。

<a id="upgrade-using-your-own-web-server"></a>

### 使用自己的 Web 服务器升级

要[使用自己的 Web 服务器](#self-host-the-product-documentation-on-your-own-web-server) 升级到更高版本：

1. 复制文档站点的 HTML 文件：

   ```shell
   docker create -it --name gitlab_docs registry.jihulab.com/gitlab-cn/technical-writing/docs-gitlab-com/archives:17.8
   docker cp gitlab_docs:/usr/share/nginx/html /srv/gitlab/
   docker rm -f gitlab_docs
   ```

1. 可选。删除旧站点：

   ```shell
   rm -r /srv/gitlab/html/17.8/
   ```

<a id="troubleshooting"></a>

## 故障排除

<a id="search-does-not-work"></a>

### 搜索不起作用

本地搜索包含在 15.6 及更高版本中。如果您使用的是更早的版本，则搜索不起作用。

有关更多信息，请阅读关于[不同类型的搜索](https://jihulab.com/gitlab-cn/technical-writing/docs-gitlab-com/-/blob/main/doc/search.md)极狐GitLab 文档使用的。

<a id="the-docker-image-is-not-found"></a>

### 找不到 Docker 镜像

如果您遇到 Docker 镜像未找到的错误，请检查您是否使用了[正确的容器镜像仓库 URL](#container-registry-url)。

<a id="docker-hosted-documentation-site-fails-to-redirect"></a>

### Docker 托管的文档站点无法重定向

在 macOS 的 Docker 中预览极狐GitLab 文档时，您可能会遇到一个问题，导致无法重定向到文档，并显示消息 `如果您没有被自动重定向，请单击此处。`。

要绕过重定向，您需要将版本号附加到 URL 后面，例如 `http://127.0.0.1:4000/16.8/`。

```