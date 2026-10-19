---
stage: Plan
group: Work Items
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 议题列表的排序与排列
description: 按截止日期、优先级、受欢迎程度、里程碑、健康状态或其他条件对议题列表进行排序，以查找和组织工作项。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以通过多种方式对议题列表进行排序。可用的排序选项会根据列表的上下文而变化。

<a id="sorting-by-blocking-issues"></a>

## 按阻塞议题排序

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

当您按**阻塞**排序时，议题列表会按每个议题[阻塞](related_issues.md#blocking-issues)的议题数量降序排列。

<a id="sorting-by-created-updated-or-closed-date"></a>

## 按创建、更新或关闭日期排序

当您按**创建日期**、**更新日期**或**关闭日期**排序时，议题列表会按相应的日期和时间戳降序排列。最近创建、更新或关闭的议题排在最前面。

<a id="sorting-by-due-date"></a>

## 按截止日期排序

当您按**截止日期**排序时，议题列表会按议题的[截止日期](due_dates.md)升序排列。截止日期最早的议题排在最前面，没有截止日期的议题排在最后。

<a id="sorting-by-label-priority"></a>

## 按标记优先级排序

当您按**标记优先级**排序时，议题列表会改为降序排列。具有最高优先级标记的议题排在最前面，然后是所有其他议题。

并列情况会任意处理。系统只会检查优先级最高的标记，优先级较低的标记会被忽略。
更多信息，请参见 [议题 14523](https://gitlab.com/gitlab-org/gitlab/-/issues/14523)。

更多信息，请参见[标记优先级](../labels.md#set-label-priority)。

<a id="manual-sorting"></a>

## 手动排序

当您按**手动**顺序排序时，可以通过拖放议题来更改顺序。更改后的顺序会保留，并且访问同一列表的每个人都会看到更新后的议题顺序，但存在一些例外情况。

每个议题都会被分配一个相对顺序值，表示它相对于列表中其他议题的顺序。当您拖放重新排序某个议题时，它的相对顺序值会发生变化。

此外，每当某个议题出现在手动排序的列表中时，更新后的相对顺序值都会用于排序。因此，如果有人在您的极狐GitLab 实例中将议题 `A` 拖到议题 `B` 上方，那么只要它们一起出现在任何列表中，这个顺序就会保持不变。

此顺序也会影响[议题看板](../issue_board.md#ordering-issues-in-a-list)。
在议题列表中更改顺序会更改议题看板中的顺序，反之亦然。

<a id="sorting-by-milestone-due-date"></a>

## 按里程碑截止日期排序

当您按**里程碑截止日期**排序时，议题列表会按已分配里程碑的截止日期升序排列。里程碑截止日期最早的议题排在最前面，然后是里程碑没有截止日期的议题。

<a id="sorting-by-popularity"></a>

## 按受欢迎程度排序

当您按**受欢迎程度**排序时，议题顺序会按每个议题获得的点赞数（带有“竖起大拇指”的[表情回应](../../emoji_reactions.md)）降序排列。您可以使用此方式来识别需求量大的议题。

总票数不会相加。一个有 18 个点赞和 5 个点踩的议题，会被视为比一个有 17 个点赞且没有点踩的议题更受欢迎。

<a id="sorting-by-priority"></a>

## 按优先级排序

当您按**优先级**排序时，议题顺序会按以下顺序排列：

1. 里程碑有截止日期的议题，其中最近到期的已分配里程碑排在最前面。
1. 里程碑没有截止日期的议题。
1. 具有更高优先级标记的议题。
1. 没有优先级标记的议题。

并列情况会任意处理。

更多信息，请参见[标记优先级](../labels.md#set-label-priority)。

<a id="sorting-by-title"></a>

## 按标题排序

当您按**标题**排序时，议题顺序会按议题标题的字母顺序排列，顺序如下：

- 表情符号
- 特殊字符
- 数字
- 字母：先是拉丁字母，然后是带重音符号的字母（例如 `ö`）

<a id="sorting-by-health-status"></a>

## 按健康状态排序

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

当您按**健康状态**排序时，议题列表会按议题的[健康状态](managing_issues.md#health-status)进行排序。
按降序排列时，议题会按以下顺序显示：

1. **有风险**的议题
1. **需要关注**的议题
1. **进展正常**的议题
1. 所有其他议题

<a id="sorting-by-weight"></a>

## 按权重排序

当您按**权重**排序时，议题列表会按[议题权重](../../work_items/weight.md)升序排列。权重最低的议题排在最前面，没有权重的议题排在最后。

<a id="sorting-by-status"></a>

## 按状态排序

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

当您按**状态**排序时，议题列表会按[议题状态](../../work_items/status.md)升序排列。议题首先按其状态类别排序。如果两个议题属于同一类别，系统会回退到按议题 ID 排序。
