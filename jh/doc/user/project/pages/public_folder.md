---
stage: Plan
group: Planner Intelligence
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 了解如何为最常见的静态站点生成器配置构建输出文件夹
title: GitLab Pages public 文件夹
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以在 `.gitlab-ci.yml`中配置发布文件夹。您不再需要更改框架配置。更多信息，请参见[设置要随 Pages 部署的自定义文件夹](introduction.md#customize-the-default-folder)。

请按照以下说明为以下框架配置 `public` 文件夹。

<a id="eleventy"></a>

## Eleventy

对于 Eleventy，您应该执行以下操作之一：

- 在 Eleventy 构建命令中添加 `--output=public` 标志，例如：

  `npx @11ty/eleventy --input=path/to/sourcefiles --output=public`

- 将以下内容添加到您的 `.eleventy.js` 文件中：

  ```javascript
  // .eleventy.js
  module.exports = function(eleventyConfig) {
    return {
      dir: {
        output: "public"
      }
    }
  };
  ```

<a id="astro"></a>

## Astro

默认情况下，Astro 使用 `public` 文件夹存储静态资源。对于 GitLab Pages，请先将该文件夹重命名为无冲突的替代名称：

1. 在您的项目目录中，运行：

   ```shell
   mv public static
   ```

1. 将以下内容添加到您的 `astro.config.mjs`中，以便为已重命名的文件夹配置 Astro：

   ```javascript
   // astro.config.mjs
   import { defineConfig } from 'astro/config';

   export default defineConfig({
     // GitLab Pages requires exposed files to be located in a folder called "public".
     // This instructs Astro to put the static build output in a folder of that name.
     outDir: 'public',

     // The folder name Astro uses for static files (`public`) is already reserved
     // for the build output. This uses a folder called `static` instead.
     publicDir: 'static',
   });
   ```

<a id="sveltekit"></a>

## SvelteKit

> [!note]
> GitLab Pages 仅支持静态站点。对于 SvelteKit，
> 您可以使用 [`adapter-static`](https://kit.svelte.dev/docs/adapters#supported-environments-static-sites)。

使用 `adapter-static` 时，请将以下内容添加到您的 `svelte.config.js`中：

```javascript
// svelte.config.js
import adapter from '@sveltejs/adapter-static';

export default {
  kit: {
    adapter: adapter({
      pages: 'public'
    })
  }
};
```

<a id="nextjs"></a>

## Next.js

> [!note]
> GitLab Pages 仅支持静态站点。对于 Next.js，您可以使用
> Next [静态 HTML 导出功能](https://nextjs.org/docs/pages/guides/static-exports)。

随着 [Next.js 13](https://nextjs.org/blog/next-13)的发布，Next.js 的工作方式发生了很大变化。您应该使用以下 `next.config.js`，以便所有静态资源都能正确导出：

```javascript
/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  images: {
    unoptimized: true,
  },
  assetPrefix: "https://example.gitlab.io/namespace-here/my-gitlab-project/"
}

module.exports = nextConfig
```

一个最简的 `.gitlab-ci.yml` 示例如下：

```yaml
create-pages:
  before_script:
    - npm install
  script:
    - npm run build
    - mv out/* public
  pages: true  # specifies that this is a Pages job and publishes the default public directory
```

上面的 YAML 示例使用了[用户自定义作业名称](_index.md#user-defined-job-names)。

<a id="nuxtjs"></a>

## Nuxt.js

> [!note]
> GitLab Pages 仅支持静态站点。

默认情况下，Nuxt 使用 `public` 文件夹存储静态资源。对于 GitLab Pages，请先将 `public` 文件夹重命名为无冲突的替代名称：

1. 在您的项目目录中，运行：

   ```shell
   mv public static
   ```

1. 将以下内容添加到您的 `nuxt.config.js`中：

   ```javascript
   export default {
     target: 'static',
     generate: {
       dir: 'public'
     },
     dir: {
       // The folder name Nuxt uses for static files (`public`) is already
       // reserved for the build output. This uses a folder called `static` instead.
       public: 'static'
     }
   }
   ```

1. 为[静态站点生成](https://nuxt.com/docs/getting-started/deployment#static-hosting)配置您的 Nuxt.js 应用程序。

<a id="vite"></a>

## Vite

更新您的 `vite.config.js`，使其包含以下内容：

```javascript
// vite.config.js
export default {
  build: {
    outDir: 'public'
  }
}
```

<a id="webpack"></a>

## Webpack

更新您的 `webpack.config.js`，使其包含以下内容：

```javascript
// webpack.config.js
module.exports = {
  output: {
    path: __dirname + '/public'
  }
};
```

<a id="should-you-commit-the-public-folder"></a>

## 您应该提交 `public` 文件夹吗？

不一定。但是，当 GitLab Pages 部署流水线运行时，它会查找该名称的[产物](../../../ci/jobs/job_artifacts.md)。如果您设置了一个在部署前创建 `public` 文件夹的作业，例如通过运行 `npm run build`，则无需提交该文件夹。

如果您更愿意在本地构建站点，则可以提交 `public` 文件夹，并在作业期间省略构建步骤。
