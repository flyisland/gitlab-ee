---
stage: Plan
group: Knowledge
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Learn how to configure the build output folder for the most common static site generators
title: 极狐GitLab Pages 公共文件夹
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 极狐GitLab 16.1 引入了对在 `.gitlab-ci.yml` 中配置发布文件夹的支持。你不再需要更改框架配置。更多信息，请参阅[设置要使用 Pages 部署的自定义文件夹](introduction.md#customize-the-default-folder)。

{{< /history >}}

按照以下说明为下列框架配置 `public` 文件夹。

<a id="eleventy"></a>

## Eleventy

对于 Eleventy，你应该执行以下操作之一：

- 在 Eleventy 构建命令中添加 `--output=public` 标志，例如：

  `npx @11ty/eleventy --input=path/to/sourcefiles --output=public`

- 将以下内容添加到你的 `.eleventy.js` 文件中：

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

默认情况下，Astro 使用 `public` 文件夹存储静态资源。对于极狐GitLab Pages，首先将该文件夹重命名为一个无冲突的替代名称：

1. 在你的项目目录中，运行：

   ```shell
   mv public static
   ```

1. 将以下内容添加到你的 `astro.config.mjs` 中，以为重命名的文件夹配置 Astro：

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
> 极狐GitLab Pages 仅支持静态站点。对于 SvelteKit，你可以使用 [`adapter-static`](https://kit.svelte.dev/docs/adapters#supported-environments-static-sites)。

使用 `adapter-static` 时，将以下内容添加到你的 `svelte.config.js` 中：

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

<a id="next-js"></a>

## Next.js

> [!note]
> 极狐GitLab Pages 仅支持静态站点。对于 Next.js，你可以使用 Next.js 的[静态 HTML 导出功能](https://nextjs.org/docs/pages/building-your-application/deploying/static-exports)。

随着 [Next.js 13](https://nextjs.org/blog/next-13) 的发布，Next.js 的工作方式发生了很大变化。你应该使用以下 `next.config.js`，以便所有静态资源都能正确导出：

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

一个示例 `.gitlab-ci.yml` 可以如下所示，非常精简：

```yaml
create-pages:
  before_script:
    - npm install
  script:
    - npm run build
    - mv out/* public
  pages: true  # specifies that this is a Pages job and publishes the default public directory
```

前面的 YAML 示例使用了[用户定义的作业名称](_index.md#user-defined-job-names)。

<a id="nuxt-js"></a>

## Nuxt.js

> [!note]
> 极狐GitLab Pages 仅支持静态站点。

默认情况下，Nuxt 使用 `public` 文件夹存储静态资源。对于极狐GitLab Pages，首先将 `public` 文件夹重命名为一个无冲突的替代名称：

1. 在你的项目目录中，运行：

   ```shell
   mv public static
   ```

1. 将以下内容添加到你的 `nuxt.config.js` 中：

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

1. 为[静态站点生成](https://nuxt.com/docs/getting-started/deployment#static-hosting)配置你的 Nuxt.js 应用程序。

<a id="vite"></a>

## Vite

更新你的 `vite.config.js` 以包含以下内容：

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

更新你的 `webpack.config.js` 以包含以下内容：

```javascript
// webpack.config.js
module.exports = {
  output: {
    path: __dirname + '/public'
  }
};
```

<a id="should-you-commit-the-public-folder"></a>

## 你应该提交 `public` 文件夹吗？

不一定。但是，当极狐GitLab Pages 部署流水线运行时，它会查找该名称的[产物](../../../ci/jobs/job_artifacts.md)。如果你设置了一个在部署前创建 `public` 文件夹的作业，例如通过运行 `npm run build`，则不需要提交该文件夹。

如果你更倾向于在本地构建站点，你可以提交 `public` 文件夹，并在作业期间省略构建步骤。