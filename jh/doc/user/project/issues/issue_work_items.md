---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: 测试议题新外观
---

{{< details >}}

- Tier: 基础版, 专业版, 旗舰版
- Offering: JihuLab.com, 私有化部署
- Status: Beta

{{< /details >}}

{{< history >}}

- 引入于极狐GitLab 17.5，使用名为 `work_items_view_preference` 的[功能标志](../../../administration/feature_flags.md)。默认禁用。
- 在极狐GitLab 17.10 中，为 JihuLab.com、私有化部署启用。
- 在极狐GitLab 17.11 中，**新外观** 开关使用名为 `work_item_view_for_issues` 的功能标志进行隐藏。


{{< /history >}}

{{< alert type="flag" >}}

此功能的可用性受控于功能标志。更多信息，可查看历史。

{{< /alert >}}

我们通过将议题迁移到一个统一的工作项框架来改变议题的外观，以更好地满足我们敏捷规划产品的需求。

这些更改包括从议题列表、议题板或子项或链接项中打开的议题的新抽屉视图、议题和事件的新创建工作流程以及议题的新视图。

<a id="new-features"></a>

## 新功能

新的议题体验包括以下改进：

- **抽屉视图**：当您从议题列表、议题板或子项或链接项列表中打开议题时，议题会在抽屉中打开而不会离开当前页面。抽屉提供议题的完整视图。要查看完整页面，可以：
  1. 在抽屉顶部选择 **查看完整页面**。
  1. 在新标签中打开链接。
- **议题控件**：所有议题控件，包括机密性设置，现在都在顶部操作菜单中。您在页面中滚动时，此菜单始终可见。
- **重新设计的侧边栏**：侧边栏现在嵌入在页面中，类似于合并请求和史诗。在较小的屏幕上，侧边栏内容显示在描述下方。
- **父层次结构**：在标题上方，您可以查看此项所属的完整层次结构。侧边栏还显示父工作项（以前称为 "史诗"）。
- **更改类型**：您可以在不同类型的项目之间进行更改：
  1. 从顶部操作菜单中选择 **更改类型**。
  1. 选择新类型：议题、任务、事件或史诗。当您将议题更改为史诗时，史诗会在父群组中创建，因为史诗只能存在于群组中。
- **开发**：与此项相关的合并请求、分支和功能标志显示在一个列表中。

<a id="toggle-the-new-experience"></a>

## 切换到新体验

当您查看议题页面或议题详细信息页面时，可以切换到新体验。

前提条件：

- 必须启用功能标志 `work_items_view_preference`。
- 必须禁用功能标志 `work_item_view_for_issues`。

要切换新的议题外观：

1. 在右上角查找 **新外观** 徽章。
1. 选择徽章以打开或关闭体验。

<a id="related-topics"></a>

## 相关主题

- [工作项开发](../../../development/work_items.md)
- [测试史诗的新外观](../../group/epics/epic_work_items.md)
