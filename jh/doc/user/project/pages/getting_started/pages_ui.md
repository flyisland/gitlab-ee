---
stage: Plan
group: Knowledge
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 创建面向静态站点的极狐GitLab Pages 部署
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

创建一个极狐GitLab Pages 部署，将你的静态站点或框架转换为托管在极狐GitLab 上的网站。通过一个分步表单，极狐GitLab 会：

- 根据你的项目设置生成自定义 CI/CD 配置。
- 创建一个为极狐GitLab Pages 部署配置的 `.gitlab-ci.yml` 文件。
- 通过合并请求提交更改以供你审核。
- 当合并请求被提交时，自动部署你的网站。

本指南说明了如何使用 Pages UI 部署静态站点或基于框架的应用程序。

<a id="prerequisites"></a>

## 前提条件

- 你的应用必须[将文件输出到 `public` 文件夹](../public_folder.md)。如果你在构建流水线中创建了此文件夹，则无需将其提交到 Git。

  > [!warning]
  > 这一步很重要。确保你的文件位于根级的 `public` 文件夹中。

- 你必须拥有满足以下条件之一的项目：
  - 生成静态站点或客户端渲染的单页应用 (SPA)，例如 [Eleventy](https://www.11ty.dev)、[Astro](https://astro.build) 或 [Jekyll](https://jekyllrb.com)。
  - 包含配置为静态输出的框架，例如 [Next.js](https://nextjs.org)、[Nuxt](https://nuxt.com) 或 [SvelteKit](https://kit.svelte.dev)。
- 必须为项目启用极狐GitLab Pages。（要启用，请前往 **设置** > **常规**，展开 **可见性、项目功能、权限**，并打开 **Pages** 开关。）

<a id="create-the-pages-deployment"></a>

## 创建 Pages 部署

要完成设置并生成极狐GitLab Pages 部署：

1. 在顶部栏，选择 **搜索或跳转到** 并找到你的项目。
2. 在左侧边栏，选择 **部署** > **Pages**。

   此时会显示 **开始使用 Pages** 表单。如果此表单不可用，请参照[故障排除](#if-the-get-started-with-pages-form-is-not-available)。

3. 在 **第 1 步** 中，输入镜像名称。你还可以[设置要与 Pages 一起部署的自定义文件夹](../introduction.md#customize-the-default-folder)。
4. 选择 **下一步**。
5. 在 **第 2 步** 中，输入安装步骤。如果你的框架构建过程不需要某个提供的构建命令，你可以：
   - 通过选择 **下一步** 跳过该步骤。
   - 如果你仍想将该步骤的样板代码合并到你的 `.gitlab-ci.yml` 文件中，可以输入 `:` （即 bash 的“什么都不做”命令）。
6. 选择 **下一步**。
7. 在 **第 3 步** 中，输入指示如何构建你的应用程序的脚本。
8. 选择 **下一步**。
9. 可选。根据需要编辑生成的 `.gitlab-ci.yml` 文件。
10. 在 **第 4 步** 中，添加提交消息并选择 **提交**。此提交将触发你的第一次极狐GitLab Pages 部署。

要查看正在运行的流水线，请前往 **构建** > **流水线**。当流水线成功后，你的 Pages 站点就被部署并可以访问。

要查看部署期间创建的产物，请查看作业，然后在右侧选择 **下载产物**。

<a id="view-deployment-url"></a>

## 查看部署 URL

流水线成功完成后：

1. 在顶部栏，选择 **搜索或跳转到** 并找到你的项目。
2. 在左侧边栏，选择 **部署** > **Pages**。
3. 在 **部署** 中，你可以查看你的活动部署 URL。
4. 要访问你已部署的极狐GitLab Pages 站点，请选择该 URL。

> [!note]
> 流水线完成后，站点可能需要几分钟才能变为可用。

<a id="troubleshooting"></a>

## 故障排除

<a id="if-the-get-started-with-pages-form-is-not-available"></a>

### 如果 `开始使用 Pages` 表单不可用

如果你存在以下情况，`开始使用 Pages` 表单将不可用：

- 之前已经部署过极狐GitLab Pages 站点。
- 至少通过表单提交过一次 `.gitlab-ci.yml`。

要解决此问题：

- 如果出现消息 **等待 Pages 流水线完成**，请选择 **重新开始** 以重新启动表单。
- 如果你的项目之前已成功部署极狐GitLab Pages，请[手动更新](pages_from_scratch.md)你的 `.gitlab-ci.yml` 文件。

