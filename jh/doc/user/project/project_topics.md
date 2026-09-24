---
stage: Tenant Scale
group: Organizations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 项目主题
description: Project organization, subscribe, and view.
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Status: Beta

{{< /details >}}

主题是你可以分配给项目以帮助组织和查找它们的标签。一个主题通常是一个简短的名称，描述项目的内容或目的。你可以将同一个主题分配给多个项目。

例如，你可以创建主题 `Python` 和 `Hackathon`，并将它们分配给所有使用 Python 并且旨在为 Hackathon 做出贡献的项目。

分配给项目的主题显示在 **项目概览** 和 [**项目**](working_with_projects.md#view-projects) 列表中，位于项目信息描述下方。

> [!NOTE]
> 只有有权访问项目的用户才能看到分配给该项目的主题，
> 但每个人（包括未经身份验证的用户）都可以看到 极狐GitLab 实例上可用的主题。
> 不要在主题名称中包含敏感信息。

<a id="explore-topics"></a>

## 探索主题

要探索项目主题：

1. 在顶部栏中，选择 **搜索或跳转到**。
1. 选择 **探索**。
1. 在左侧边栏中，选择 **主题**。**探索主题** 页面将显示所有项目主题的列表。
1. 可选。要根据名称筛选主题，请在搜索框中输入搜索条件。
1. 要查看与某个主题相关的项目，请选择该主题。你也可以通过 URL `https://jihulab.com/explore/projects/topics/<topic-name>` 访问主题页面。

<a id="filter-and-sort-topics"></a>

## 筛选和排序主题

在项目主题页面上，你可以按以下条件筛选具有该主题的项目列表：

- 名称
- 语言
- 可见性
- 所有者
- 已归档的项目

你还可以按以下方式排序项目：

- 日期
- 名称
- 星标数量
- 要按名称筛选项目，请在搜索框中输入搜索条件。
- 要按其他条件排序项目，请从下拉列表中选择一个选项。

<a id="subscribe-to-a-topic"></a>

## 订阅主题

如果你想了解何时有新项目添加到一个主题，你可以使用其 RSS 订阅。

你可以从 **探索主题** 页面或带有主题的项目执行此操作。

要订阅主题：

- 从 **探索主题** 页面：
  1. 在左侧边栏中，展开最顶部的折叠图标 ({{< icon name="chevron-down" >}})。
  1. 选择 **探索**。
  1. 选择 **主题**。
  1. 选择你要订阅的主题。
  1. 在右上角，选择 **订阅新项目源** ({{< icon name="rss" >}})。
- 从项目：
  1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
  1. 在 **项目概览** 页面，从 **主题** 列表中选择你要订阅的主题。
  1. 在右上角，选择 **订阅新项目源** ({{< icon name="rss" >}})。

结果以 Atom 格式的 RSS 源显示。结果的 URL 包含一个源令牌和具有该主题的项目列表。你可以将此 URL 添加到你的源阅读器中。

<a id="assign-topics-to-a-project"></a>

## 为项目分配主题

先决条件：

- 你必须具有项目的维护者或所有者角色。

要为项目分配主题：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **命名、描述、主题**。
1. 在 **项目主题** 文本框中，搜索主题。输入时系统会建议常用主题。
1. 选择 **保存更改**。

<a id="administer-topics"></a>

## 管理主题

实例管理员可以从 [**管理员** 区域的主题页面](../../administration/admin_area.md#administering-topics) 管理所有项目主题。