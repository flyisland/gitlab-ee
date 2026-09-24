---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 议题
description: 任务、缺陷报告、特性请求与跟踪。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

议题帮助您与团队协作，在极狐GitLab 中规划、跟踪和交付工作。
议题可用于：

- 跟踪特性提案、任务、支持请求和缺陷报告。
- 通过指派人、截止日期和健康状态组织和优先排序工作。
- 通过评论和主题讨论促进团队讨论与决策。
- 通过模板、标签、史诗和看板支持自定义工作流。
- 与 Zoom、Jira 和邮件服务等外部工具集成。

有关议题的更多信息，请参阅
[始终从议题开始讨论](https://gitlab.cn/blog/start-with-an-issue/) 博客文章。

议题总是与特定项目关联。如果您在一个群组中有多个
项目，您可以一次性查看所有项目的议题。

<a id="issues-as-work-items"></a>

## 作为工作项的议题

{{< history >}}

- 在极狐GitLab 17.5 中以功能标志 `work_items_view_preference` 引入。默认禁用。此功能处于[测试版](../../../policy/development_stages_support.md#beta)。
- 功能标志 `work_items_view_preference` 在极狐GitLab 17.9 于 JihuLab.com 上对部分用户启用。
- 功能标志 `work_items_view_preference` 在 17.10 中于 JihuLab.com 和私有化部署上[启用](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/184496)。
- 在极狐GitLab 17.11 中[于 JihuLab.com 和私有化部署上启用](https://gitlab.com/gitlab-org/gitlab/-/issues/482931)。
- 在极狐GitLab 18.1 中[移动](https://gitlab.com/gitlab-org/gitlab/-/issues/482931)到功能标志 `work_item_view_for_issues`。在 JihuLab.com 和私有化部署上启用。功能标志 `work_items_view_preference` 已移除。
- 在极狐GitLab 18.4 中为项目议题页面[引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/198544)额外过滤器。[于 JihuLab.com 和私有化部署上启用](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/204139)。
- 在极狐GitLab 18.5 中为群组议题页面[引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/202089)额外过滤器。[于 JihuLab.com 和私有化部署上启用](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/205308)。
- 在极狐GitLab 18.7 中[GA](https://gitlab.com/gitlab-org/gitlab/-/issues/520791)。功能标志 `work_item_view_for_issues` 已移除。

{{< /history >}}

我们通过将议题迁移到统一的工作项框架来改变其外观，从而更好地
满足我们敏捷规划产品的需求。

有关更多信息，请参阅 epic 9290 和[极狐GitLab 中的全新敏捷规划体验](https://gitlab.cn/blog/first-look-the-new-agile-planning-experience-in-gitlab/)博客文章
（2024 年 6 月）。

如果您在尝试此更改时遇到任何问题，可以使用反馈议题提供更多详细信息。

<a id="work-item-markdown-reference"></a>

### 工作项 Markdown 引用

{{< history >}}

- 在极狐GitLab 18.1 中以功能标志 `extensible_reference_filters` [引入](https://gitlab.com/gitlab-org/gitlab/-/issues/352861)。默认禁用。
- 在极狐GitLab 18.2 中[GA](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/197052)。功能标志 `extensible_reference_filters` 已移除。

{{< /history >}}

您可以在极狐GitLab Flavored Markdown 字段中使用 `[work_item:123]` 引用工作项。
有关更多信息，请参阅[极狐GitLab 特定引用](../../markdown.md#gitlab-specific-references)。

<a id="related-topics"></a>

## 相关主题

- [创建议题](create_issues.md)
- [从模板创建议题](../description_templates.md#use-the-templates)
- [编辑议题](managing_issues.md#edit-an-issue)
- [移动议题](managing_issues.md#move-an-issue)
- [关闭议题](managing_issues.md#close-an-issue)
- [删除议题](managing_issues.md#delete-an-issue)
- [升级议题为史诗](managing_issues.md#promote-an-issue-to-an-epic)
- [设置截止日期](due_dates.md)
- [导入议题](csv_import.md)
- [导出议题](csv_export.md)
- [上传设计到议题](design_management.md)
- [关联议题](related_issues.md)
- [相似议题](managing_issues.md#similar-issues)
- [健康状态](managing_issues.md#health-status)
- [交叉链接议题](crosslinking_issues.md)
- [排序议题列表](sorting_issue_lists.md)
- [搜索议题](managing_issues.md#filter-the-list-of-issues)
- [史诗](../../group/epics/_index.md)
- [议题看板](../issue_board.md)
- [议题 API](../../../api/issues.md)
- [配置外部议题跟踪器](../../../integration/external-issue-tracker.md)
- [任务](../../tasks.md)
- [查看议题中的任务数量和权重](../../tasks.md#view-count-and-weight-of-tasks-in-the-parent-issue)
- [查看带有子任务的议题进度](../../tasks.md#view-progress-of-the-parent-issue)
- [外部参与者](../service_desk/external_participants.md)