---
stage: Plan
group: Planner Intelligence
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Confluence 工作区
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

将 Confluence Cloud 工作区用作您的项目 Wiki。

此集成会添加一个指向 Confluence Wiki 的链接，而不是[极狐GitLab Wiki](../wiki/_index.md)。
极狐GitLab 不会显示您的 Confluence 内容。

开启此集成后：

- 左侧边栏中会新增一个菜单项：**计划** > **Confluence**。
  它链接到您的 Confluence Wiki。
- **计划** > **Wiki** 菜单项会被隐藏。

  要访问该项目的极狐GitLab Wiki，请使用其 URL：
  `<example_project_URL>/-/wikis/home`。
  要恢复**计划** > **Wiki** 菜单项，请关闭此集成。

与 Confluence Cloud 建立更全面的集成已在
[史诗 3629](https://gitlab.com/groups/gitlab-org/-/epics/3629)中跟踪。

<a id="set-up-the-integration"></a>

## 设置集成

此集成可以针对某个项目开启，也可以针对某个群组或实例中的所有项目开启。

<a id="for-your-project-or-all-projects-in-a-group"></a>

### 针对您的项目或群组中的所有项目

先决条件：

- 您必须拥有该项目的维护者或所有者角色。
- 您必须使用 Confluence Cloud URL（`https://example.atlassian.net/wiki/`）。

要为您的项目或群组设置集成：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目或群组。
1. 在左侧边栏中，选择**设置** > **集成**。
1. 在 **Confluence 工作区**旁边，选择**配置**。
1. 在**启用集成**下，选中**活跃**复选框。
1. 在 **Confluence 工作区 URL**中，输入您的 Confluence 工作区 URL。
1. 选择**保存更改**。

如果该集成已针对群组开启，您仍然可以针对单个项目将其关闭。

<a id="for-all-projects-on-the-instance"></a>

### 针对实例上的所有项目

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

先决条件：

- 您必须拥有该实例的管理员访问权限。
- 您必须使用 Confluence Cloud URL（`https://example.atlassian.net/wiki/`）。

要为您的实例设置集成：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **集成**。
1. 在 **Confluence 工作区**旁边，选择**配置**。
1. 在**启用集成**下，选中**活跃**复选框。
1. 在 **Confluence 工作区 URL**中，输入您的 Confluence 工作区 URL。
1. 选择**保存更改**。

<a id="access-your-confluence-workspace-from-gitlab"></a>

## 从极狐GitLab 访问您的 Confluence 工作区

先决条件：

- 您必须[为您的项目、群组](#for-your-project-or-all-projects-in-a-group)设置集成，
  或[为您的实例](#for-all-projects-on-the-instance)设置集成。

要从极狐GitLab 项目访问您的 Confluence 工作区：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**计划** > **Confluence**。
1. 选择**转到 Confluence**。
