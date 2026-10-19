---
stage: Plan
group: Knowledge
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用项目模板创建极狐GitLab Pages 网站
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

极狐GitLab 提供了针对最流行的静态站点生成器 (SSG) 的模板。
您可以基于模板创建一个新项目，并运行 CI/CD 流水线来生成 Pages 网站。

当您想要测试极狐GitLab Pages，或者启动一个已配置为生成 Pages 站点的项目时，可以使用模板。

1. 在右上角，选择 **新建**（{{< icon name="plus" >}}）和 **新建项目/仓库**。
1. 选择 **基于模板创建**。
1. 在任意以 **Pages** 开头的模板旁边，选择 **使用模板**。
1. 填写表单并选择 **创建项目**。
1. 在左侧边栏中，选择 **构建** > **流水线**，然后选择 **新建流水线**，以触发极狐GitLab CI/CD 构建并部署您的站点。

当流水线完成后，前往 **部署** > **Pages**，找到您的 Pages 网站的链接。

每次您将更改推送到仓库时，极狐GitLab CI/CD 会运行一个新的流水线，并立即将您的更改发布到 Pages 站点。

要查看为站点创建的 HTML 和其他资产，请[下载作业产物](../../../../ci/jobs/job_artifacts.md#download-job-artifacts)。

<a id="project-templates"></a>

## 项目模板

{{< history >}}

- 在极狐GitLab 18.0 中，从项目模板中移除了以下模板：
  [`Bridgetown`](https://gitlab.com/pages/bridgetown), [`Gatsby`](https://gitlab.com/pages/gatsby),
  [`Hexo`](https://gitlab.com/pages/hexo), [`Middleman`](https://gitlab.com/pages/middleman),
  `Netlify/GitBook`, [`Netlify/Hexo`](https://gitlab.com/pages/nfhexo),
  [`Netlify/Hugo`](https://gitlab.com/pages/nfhugo), [`Netlify/Jekyll`](https://gitlab.com/pages/nfjekyll),
  [`Netlify/Plain HTML`](https://gitlab.com/pages/nfplain-html), 以及 [`Pelican`](https://gitlab.com/pages/pelican)。

{{< /history >}}

极狐GitLab 为以下框架维护了模板项目：

| 领域           | 框架                                                 | 可用的项目模板              |
|----------------|------------------------------------------------------|-----------------------------|
| **Go**         | [`hugo`](https://gitlab.com/pages/hugo)              | Pages/Hugo                  |
| **Markdown**   | [`astro`](https://gitlab.com/pages/astro)            | Pages/Astro                 |
| **Markdown**   | [`docusaurus`](https://gitlab.com/pages/docusaurus)  | Pages/Docusaurus            |
| **Plain HTML** | [`plain-html`](https://gitlab.com/pages/plain-html)  | Pages/Plain HTML            |
| **React**      | [`next.js`](https://gitlab.com/pages/nextjs)         | Pages/Next.js               |
| **Ruby**       | [`jekyll`](https://gitlab.com/pages/jekyll)          | Pages/Jekyll                |
| **Vue.js**     | [`nuxt`](https://gitlab.com/pages/nuxt)              | Pages/Nuxt                  |

```