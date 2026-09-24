---
stage: Plan
group: Knowledge
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Confluence 工作区
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用 Confluence Cloud 工作区作为你的项目 Wiki。

此集成会添加一个指向 Confluence Wiki 的链接，而非 [极狐GitLab Wiki](../wiki/_index.md)。
你在 Confluence 中拥有的任何内容都不会在极狐GitLab 中显示。

当你开启集成时：

- 左侧边栏会新增一个菜单项：**计划** > **Confluence**。
  它链接到你的 Confluence Wiki。
- **计划** > **Wiki** 菜单项会被隐藏。

  要访问项目的极狐GitLab Wiki，请使用其 URL：
  `<example_project_URL>/-/wikis/home`。
  要重新显示 **计划** > **Wiki** 菜单项，请关闭此集成。

创建一个更全面的 Confluence Cloud 集成正在
[史诗 3629](https://jihulab.com/groups/gitlab-cn/-/epics/3629) 中推进。

## 设置集成

此集成可以为单个项目或群组中的所有项目，或实例中的所有项目开启。

### 为你的项目或群组中的所有项目设置

前提条件：

- 你必须拥有项目的维护者或所有者角色。
- 你必须使用 Confluence Cloud URL（`https://example.atlassian.net/wiki/`）。

要为你的项目或群组设置集成：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目或群组。
1. 在左侧边栏中，选择 **设置** > **集成**。
1. 在 **Confluence 工作区** 旁边，选择 **配置**。
1. 在 **启用集成** 下，选中 **活跃** 复选框。
1. 在 **Confluence 工作区 URL** 中，输入你的 Confluence 工作区 URL。
1. 选择 **保存更改**。

如果为群组开启了集成，你仍然可以为个别项目关闭它。

### 为实例上的所有项目设置

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

前提条件：

- 你必须拥有实例的管理员访问权限。
- 你必须使用 Confluence Cloud URL（`https://example.atlassian.net/wiki/`）。

要为你的实例设置集成：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **集成**。
1. 在 **Confluence 工作区** 旁边，选择 **配置**。
1. 在 **启用集成** 下，选中 **活跃** 复选框。
1. 在 **Confluence 工作区 URL** 中，输入你的 Confluence 工作区 URL。
1. 选择 **保存更改**。

## 从极狐GitLab 访问你的 Confluence 工作区

前提条件：

- 你必须[为你的项目、群组](#for-your-project-or-all-projects-in-a-group)或[为你的实例](#for-all-projects-on-the-instance)设置了集成。

要从极狐GitLab 项目访问你的 Confluence 工作区：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **计划** > **Confluence**。
1. 选择 **前往 Confluence**。