---
stage: Package
group: Container Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Harbor 镜像仓库
description: 将 Harbor 容器镜像仓库与你的极狐GitLab 项目或群组集成。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- **Harbor 镜像仓库** 在 极狐GitLab 17.0 中从 **运维** 菜单部分移动到 **部署**。

{{< /history >}}

你可以将 [Harbor 容器镜像仓库](../../project/integrations/harbor.md) 集成到 极狐GitLab 中，并使用 Harbor 作为你的 极狐GitLab 项目的容器镜像仓库来存储镜像。

<a id="view-the-harbor-registry"></a>

## 查看 Harbor 镜像仓库

你可以查看项目或群组的 Harbor 镜像仓库。

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目或群组。
1. 在左侧边栏中，选择 **部署** > **Harbor 镜像仓库**。

你可以在此页面上搜索、排序和筛选镜像。你可以通过复制浏览器的 URL 来共享筛选后的视图。

在项目级别，在右上角，你可以看到 **CLI 命令**，你可以复制相应的命令来登录、构建镜像和推送镜像。**CLI 命令** 在群组级别不显示。

> [!note]
> 项目级别的 Harbor 集成的默认设置继承自群组级别。

<a id="use-images-from-the-harbor-registry"></a>

## 使用 Harbor 镜像仓库中的镜像

要下载并运行托管在 极狐GitLab Harbor 镜像仓库中的 Harbor 镜像：

1. 复制容器镜像的链接：
   1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目或群组。
   1. 选择 **部署** > **Harbor 镜像仓库** 并找到你想要的镜像。
   1. 选择镜像名称旁边的 **复制** 图标。

1. 使用命令运行你想要的容器镜像。

<a id="view-the-tags-of-a-specific-artifact"></a>

## 查看特定产物的标签

要查看与特定产物关联的标签列表：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目或群组。
1. 转到 **部署** > **Harbor 镜像仓库**。
1. 选择镜像名称以查看其产物。
1. 选择你想要的产物。

这将显示标签列表。你可以查看标签数量和发布时间。

你还可以复制标签 URL 并使用它来拉取相应的产物。

<a id="build-and-push-images-by-using-commands"></a>

## 使用命令构建和推送镜像

要构建并推送到 Harbor 镜像仓库：

1. 向 Harbor 镜像仓库进行身份验证。
1. 运行命令以构建或推送。

要查看这些命令：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目或群组。
1. 在左侧边栏中，选择 **部署** > **Harbor 镜像仓库**。
1. 选择 **CLI 命令**。

<a id="disable-the-harbor-registry-for-a-project"></a>

## 为项目禁用 Harbor 镜像仓库

要移除项目的 Harbor 镜像仓库：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目或群组。
1. 在左侧边栏中，选择 **设置** > **集成**。
1. 在 **活跃的集成** 下选择 **Harbor**。
1. 在 **启用集成** 下，清除 **活跃** 复选框。
1. 选择 **保存更改**。

**部署** > **Harbor 镜像仓库** 条目将从侧边栏中移除。