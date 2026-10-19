---
stage: Plan
group: Planner Intelligence
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 为静态站点创建 GitLab Pages 部署
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

创建 GitLab Pages 部署，将您的静态站点或框架转换为托管在极狐GitLab 上的网站。通过分步表单，极狐GitLab 会：

- 根据您的项目设置生成自定义 CI/CD 配置。
- 创建为 GitLab Pages 部署配置的 `.gitlab-ci.yml` 文件。
- 通过合并请求提交更改，供您审阅。
- 在合并请求合并后自动部署您的网站。

本指南介绍如何使用 Pages UI 部署静态站点或基于框架的应用程序。

<a id="prerequisites"></a>

## 先决条件

- 您的应用必须[将文件输出到 `public` 文件夹](../public_folder.md)。如果您在构建流水线期间创建此文件夹，则无需将其提交到 Git。

  > [!warning]
  > 此步骤很重要。请确保您的文件位于根级 `public` 文件夹中。

- 您必须拥有一个满足以下任一条件的项目：
  - 生成静态站点或客户端渲染的单页应用（SPA），例如 [Eleventy](https://www.11ty.dev)、[Astro](https://astro.build) 或 [Jekyll](https://jekyllrb.com)。
  - 包含配置为静态输出的框架，例如 [Next.js](https://nextjs.org)、[Nuxt](https://nuxt.com) 或 [SvelteKit](https://kit.svelte.dev)。
- 必须为项目启用 GitLab Pages。（要启用，请前往**设置** > **通用**，展开**可见性、项目功能、权限**，然后打开 **Pages** 开关。）

<a id="create-the-pages-deployment"></a>

## 创建 Pages 部署

要完成设置并生成 GitLab Pages 部署：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**部署** > **Pages**。

   此时会出现**开始使用 Pages** 表单。如果此表单不可用，请参阅[故障排除](#if-the-get-started-with-pages-form-is-not-available)。
1. 在**第 1 步**中，输入镜像名称。您还可以[设置要使用 Pages 部署的自定义文件夹](../introduction.md#customize-the-default-folder)。
1. 选择**下一步**。
1. 在**第 2 步**中，输入您的安装步骤。如果您的框架构建过程不需要所提供的某个构建命令，您可以：
   - 选择**下一步**跳过该步骤。
   - 如果您仍想将该步骤的样板代码纳入您的 `.gitlab-ci.yml` 文件，请输入 `:`（bash 的“什么都不做”命令）。
1. 选择**下一步**。
1. 在**第 3 步**中，输入指示如何构建应用的脚本。
1. 选择**下一步**。
1. 可选。根据需要编辑生成的 `.gitlab-ci.yml` 文件。
1. 在**第 4 步**中，添加提交消息并选择**提交**。此提交会触发您的首次 GitLab Pages 部署。

要查看正在运行的流水线，请前往**构建** > **流水线**。当流水线成功后，您的 Pages 站点即已部署并可访问。

要查看部署期间创建的产物，请查看作业，并在右侧选择**下载产物**。

<a id="view-deployment-url"></a>

## 查看部署 URL

在您的流水线成功完成后：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**部署** > **Pages**。
1. 在**部署**中，您可以查看当前生效的部署 URL。
1. 要访问已部署的 GitLab Pages 站点，请选择该 URL。

> [!note]
> 在流水线完成后，您的站点可能需要几分钟才能可用。

<a id="troubleshooting"></a>

## 故障排除

<a id="if-the-get-started-with-pages-form-is-not-available"></a>

### 如果 `Get Started with Pages` 表单不可用

在以下情况下，`Get Started with Pages` 表单不可用：

- 您之前部署过 GitLab Pages 站点。
- 您至少通过表单提交过一次 `.gitlab-ci.yml`。

要解决此问题：

- 如果出现**正在等待 Pages 流水线完成**消息，请选择**重新开始**以再次启动表单。
- 如果您的项目之前已成功部署 GitLab Pages，请[手动更新](pages_from_scratch.md)您的 `.gitlab-ci.yml` 文件。
