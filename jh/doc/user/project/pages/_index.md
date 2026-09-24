---
stage: Plan
group: Planner Intelligence
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: GitLab Pages
description: 使用自动 CI/CD 部署从您的代码仓库发布静态网站。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

GitLab Pages 直接从极狐GitLab 中的代码仓库发布静态网站。

这些网站：

- 使用极狐GitLab CI/CD 流水线自动部署。
- 支持任何静态站点生成器（如 Hugo、Jekyll 或 Gatsby）或纯 HTML、CSS、JavaScript 和 Wasm。
- 在极狐GitLab 提供的基础设施上运行，无需额外费用。
- 可连接自定义域名和 SSL/TLS 证书。
- 通过内置身份验证控制访问。
- 可靠地扩展，适用于个人、企业或项目文档网站。

要使用 Pages 发布网站，可以使用任何静态站点生成器，如 Gatsby、Jekyll、Hugo、Middleman、Harp、Hexo 或 Brunch。
Pages 还支持直接使用纯 HTML、CSS、JavaScript 和 Wasm 编写的网站。
不支持动态服务器端处理（如 `.php` 和 `.asp`）。
有关更多信息，请参阅[静态网站与动态网站](https://about.gitlab.com/blog/ssg-overview-gitlab-pages-part-1-dynamic-x-static/)。

<a id="getting-started"></a>

## 入门

要创建 GitLab Pages 网站：

| 文档                                                                             | 描述                                                                                  |
|--------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------|
| [使用极狐GitLab UI 创建简单的 `.gitlab-ci.yml`](getting_started/pages_ui.md) | 向现有项目添加 Pages 站点。使用 UI 设置简单的 `.gitlab-ci.yml`。     |
| [从头开始创建 `.gitlab-ci.yml` 文件](getting_started/pages_from_scratch.md) | 向现有项目添加 Pages 站点。了解如何创建和配置您自己的 CI 文件。 |
| [使用 `.gitlab-ci.yml` 模板](getting_started/pages_ci_cd_template.md)           | 向现有项目添加 Pages 站点。使用预填充的 CI 模板文件。               |
| [Fork 示例项目](getting_started/pages_forked_sample_project.md)              | 通过 Fork 示例项目创建已配置 Pages 的新项目。              |
| [使用项目模板](getting_started/pages_new_project_template.md)              | 通过使用模板创建已配置 Pages 的新项目。                      |

要更新 GitLab Pages 网站：

| 文档 | 描述 |
|----------|-------------|
| [GitLab Pages 域名、URL 和基础 URL](getting_started_part_one.md) | 了解 GitLab Pages 默认域名。 |
| [探索 GitLab Pages](introduction.md) | 要求、技术细节、特定的极狐GitLab CI/CD 配置选项、访问控制、自定义 404 页面、限制和常见问题解答。 |
| [自定义域名和 SSL/TLS 证书](custom_domains_ssl_tls_certification/_index.md) | 自定义域名和子域名、DNS 记录以及 SSL/TLS 证书。 |
| [Let's Encrypt 集成](custom_domains_ssl_tls_certification/lets_encrypt_integration.md) | 使用 Let's Encrypt 证书保护您的 Pages 站点，这些证书由极狐GitLab 自动获取和续期。 |
| [重定向](redirects.md) | 设置 HTTP 重定向以将一个页面转发到另一个页面。 |

有关更多信息，请参阅：

| 文档 | 描述 |
|----------|-------------|
| [静态网站与动态网站](https://about.gitlab.com/blog/ssg-overview-gitlab-pages-part-1-dynamic-x-static/) | 静态与动态站点概述。 |
| [现代静态站点生成器](https://about.gitlab.com/blog/ssg-overview-gitlab-pages-part-2/) | SSG 概述。 |
| [使用 GitLab Pages 构建任何 SSG 站点](https://about.gitlab.com/blog/ssg-overview-gitlab-pages-part-3-examples-ci/) | 将 SSG 用于 GitLab Pages。 |

<a id="using-gitlab-pages"></a>

## 使用 GitLab Pages

要使用 GitLab Pages，您必须在极狐GitLab 中创建一个项目来上传您网站的文件。这些项目可以是公开、内部或私有。

默认情况下，极狐GitLab 从您代码仓库中名为 `public` 的特定文件夹部署您的网站。
您还可以[设置要使用 Pages 部署的自定义文件夹](introduction.md#customize-the-default-folder)。
当您在极狐GitLab 中创建新项目时，[代码仓库](../repository/_index.md)会自动可用。

要部署您的站点，极狐GitLab 使用其内置工具 [极狐GitLab CI/CD](../../../ci/_index.md) 来构建您的站点并将其发布到 GitLab Pages 服务器。极狐GitLab CI/CD 为完成此任务而运行的脚本序列由名为 `.gitlab-ci.yml` 的文件创建，您可以[创建和修改](getting_started/pages_from_scratch.md)该文件。配置文件中具有 `pages: true` 属性的用户定义 `job` 使极狐GitLab 知道您正在部署 GitLab Pages 网站。

您可以使用极狐GitLab 的 [GitLab Pages 网站默认域名](getting_started_part_one.md#gitlab-pages-default-domain-names) `*.gitlab.io`，也可以使用您自己的域名（`example.com`）。在这种情况下，您必须是域名注册商（或控制面板）的管理员才能使用 Pages 进行设置。

<a id="access-to-your-pages-site"></a>

## 访问您的 Pages 站点

如果您使用 GitLab Pages 默认域名（`.gitlab.io`），您的网站将自动安全并可通过 HTTPS 访问。如果您使用自己的自定义域名，您可以选择使用 SSL/TLS 证书对其进行保护。

如果您使用 JihuLab.com，您的网站会公开发布在互联网上。
要限制对您网站的访问，请启用 [GitLab Pages 访问控制](pages_access_control.md)。

如果您使用极狐GitLab 私有化部署实例，您的网站将根据您的系统管理员选择的 [Pages 设置](../../../administration/pages/_index.md) 发布在您自己的服务器上，系统管理员可以将其设为公开或内部。

<a id="pages-examples"></a>

## Pages 示例

这些 GitLab Pages 网站示例可以教您一些高级技术，供您使用并根据自己的需求进行调整：

- [从 iOS 发布到您的 GitLab Pages 博客](https://about.gitlab.com/blog/posting-to-your-gitlab-pages-blog-from-ios/)。
- [极狐GitLab CI：顺序、并行运行作业，或构建自定义流水线](https://about.gitlab.com/blog/basics-of-gitlab-ci-updated/)。
- [极狐GitLab CI：部署与环境](https://about.gitlab.com/blog/ci-deployment-and-environments/)。
- [使用 Nanoc、极狐GitLab CI 和 GitLab Pages 构建新的 GitLab 文档站点](https://about.gitlab.com/blog/building-a-new-gitlab-docs-site-with-nanoc-gitlab-ci-and-gitlab-pages/)。
- [使用 GitLab Pages 发布代码覆盖率报告](https://about.gitlab.com/blog/publish-code-coverage-report-with-gitlab-pages/)。

<a id="administer-gitlab-pages-for-gitlab-self-managed-instances"></a>

## 为极狐GitLab 私有化部署实例管理 GitLab Pages

如果您正在运行极狐GitLab 私有化部署实例，
请[按照管理步骤](../../../administration/pages/_index.md)配置 Pages。


<a id="configure-gitlab-pages-in-a-helm-chart-kubernetes-instance"></a>

### 在 Helm Chart (Kubernetes) 实例中配置 GitLab Pages

要在使用 Helm chart (Kubernetes) 部署的实例上配置 GitLab Pages，请使用以下任一方式：

- [`gitlab-pages` 子 chart](https://gitlab.cn/docs/charts/charts/gitlab/gitlab-pages/)。
- [外部 GitLab Pages 实例](https://gitlab.cn/docs/charts/advanced/external-gitlab-pages/)。

<a id="security-for-gitlab-pages"></a>

## GitLab Pages 的安全性

<a id="namespaces-that-contain-"></a>

### 包含 `.` 的命名空间

如果您的用户名是 `example`，您的 GitLab Pages 网站位于 `example.gitlab.io`。
极狐GitLab 允许用户名包含 `.`，因此名为 `bar.example` 的用户可以创建 GitLab Pages 网站 `bar.example.gitlab.io`，这实际上是您 `example.gitlab.io` 网站的子域。如果您使用 JavaScript 为您的网站设置 cookie，请务必小心。
使用 JavaScript 手动设置 cookie 的安全方法是完全不指定 `domain`：

```javascript
// Safe: This cookie is only visible to example.gitlab.io
document.cookie = "key=value";

// Unsafe: This cookie is visible to example.gitlab.io and its subdomains,
// regardless of the presence of the leading dot.
document.cookie = "key=value;domain=.example.gitlab.io";
document.cookie = "key=value;domain=example.gitlab.io";
```

此问题不影响使用自定义域名的用户，也不影响不使用 JavaScript 手动设置任何 cookie 的用户。

<a id="shared-cookies"></a>

### 共享 cookie

默认情况下，群组中的每个项目共享同一个域，例如 `group.gitlab.io`。这意味着群组中所有项目的 cookie 也是共享的。

为确保每个项目使用不同的 cookie，请为您的项目启用 Pages [唯一域名](#unique-domains) 功能。

<a id="unique-domains"></a>

## 唯一域名

默认情况下，每个新项目都使用 Pages 唯一域名，以防止同一群组中的项目共享 cookie。

项目维护者可以禁用此功能：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **部署** > **Pages**。
1. 清除 **使用唯一域名** 复选框。
1. 选择 **保存更改**。

有关示例 URL，请参阅 [GitLab Pages 默认域名](getting_started_part_one.md#gitlab-pages-default-domain-names)。

<a id="primary-domain"></a>

## 主域名

当您将 GitLab Pages 与自定义域名一起使用时，您可以将所有对 GitLab Pages 的请求重定向到主域名。
选择主域名后，用户会收到 `308 Permanent Redirect` 状态，该状态会将浏览器重定向到所选的主域名。浏览器可能会缓存此重定向。

先决条件：

- 您必须具有项目的维护者或所有者角色。
- 必须已设置[自定义域名](custom_domains_ssl_tls_certification/_index.md#set-up-a-custom-domain)。

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **部署** > **Pages**。
1. 从 **主域名** 下拉列表中，选择要重定向到的域名。
1. 选择 **保存更改**。

<a id="expiring-deployments"></a>

## 过期部署

您可以通过在 [`pages.expire_in`](../../../ci/yaml/_index.md#pagesexpire_in) 中指定持续时间，将 Pages 部署配置为在一段时间后自动删除：

```yaml
create-pages:
  stage: deploy
  script:
    - ...
  pages:  # specifies that this is a Pages job and publishes the default public directory
    expire_in: 1 week
```

过期的部署由每 10 分钟运行一次的 cron 作业停止。
已停止的部署随后由另一个同样每 10 分钟运行一次的 cron 作业删除。要恢复它，请按照[恢复已停止的部署](#recover-a-stopped-deployment)中描述的步骤操作。

已停止或已删除的部署不再在网络上可用。您会在其 URL 处看到 404 Not found 错误页面，直到使用相同的 URL 配置创建另一个部署。

前面的 YAML 示例使用[用户定义的作业名称](#user-defined-job-names)。

<a id="recover-a-stopped-deployment"></a>

### 恢复已停止的部署

先决条件：

- 您必须具有项目的维护者或所有者角色。

要恢复尚未删除的已停止部署：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **部署** > **Pages**。
1. 在 **部署** 附近，打开 **包含已停止的部署** 开关。
   如果您的部署尚未被删除，它应该包含在列表中。
1. 展开要恢复的部署，然后选择 **恢复**。

<a id="delete-a-deployment"></a>

### 删除部署

要删除部署：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **部署** > **Pages**。
1. 在 **部署** 下，选择您要删除的部署上的任意区域。
   部署详细信息会展开。
1. 选择 **删除**。

当您选择 **删除** 时，您的部署会立即停止。
已停止的部署由每 10 分钟运行一次的 cron 作业删除。

要恢复尚未删除的已停止部署，请参阅[恢复已停止的部署](#recover-a-stopped-deployment)。

<a id="user-defined-job-names"></a>

## 用户定义的作业名称

要从任何作业触发 Pages 部署，请在作业定义中包含 `pages` 属性。它可以是设置为 `true` 的布尔值，也可以是哈希。

例如，使用 `true`：

```yaml
deploy-my-pages-site:
  stage: deploy
  script:
    - npm run build
  pages: true  # specifies that this is a Pages job and publishes the default public directory
```

例如，使用哈希：

```yaml
deploy-pages-review-app:
  stage: deploy
  script:
    - npm run build
  pages:  # specifies that this is a Pages job and publishes the default public directory
    path_prefix: '_staging'
```

如果名为 `pages` 的作业的 `pages` 属性设置为 `false`，则不会触发部署：

```yaml
pages:
  pages: false
```

> [!warning]
> 如果您的流水线中有多个 Pages 作业具有相同的 `path_prefix` 值，则最后完成的作业将使用 Pages 部署。

<a id="parallel-deployments"></a>

## 并行部署

要同时为您的项目创建多个部署，例如创建评审应用，请查看[并行部署](parallel_deployments.md)的文档。
