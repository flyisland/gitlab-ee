---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 排序和排列议题列表
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

你可以通过多种方式对议题列表进行排序。
可用的排序选项会根据列表的上下文而变化。

<a id="sorting-by-blocking-issues"></a>

## 按阻塞议题排序

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

当你按 **阻塞** 排序时，议题列表会按每个议题所 [阻塞](related_issues.md#blocking-issues) 的议题数量降序排列。

<a id="sorting-by-created-updated-or-closed-date"></a>

## 按创建日期、更新日期或关闭日期排序

当你按 **创建日期**、**更新日期** 或 **关闭日期** 排序时，议题列表会按相应的日期和时间戳降序排列。最近创建、更新或关闭的议题排在最前面。

<a id="sorting-by-due-date"></a>

## 按截止日期排序

当你按 **截止日期** 排序时，议题列表会按议题的 [截止日期](due_dates.md) 升序排列。截止日期最早的议题排在最前面，没有截止日期的议题排在最后。

<a id="sorting-by-label-priority"></a>

## 按标签优先级排序

当你按 **标签优先级** 排序时，议题列表会降序排列。
优先级最高的标签的议题排在最前面，然后是所有其他议题。

平局时任意排序。仅检查优先级最高的标签，优先级较低的标签会被忽略。
更多信息，请参见 [议题 14523](https://jihulab.com/gitlab-cn/gitlab/-/issues/14523)。

更多信息，请参见 [标签优先级](../labels.md#set-label-priority)。

<a id="manual-sorting"></a>

## 手动排序

当你按 **手动** 顺序排序时，可以通过拖放议题来更改顺序。更改后的顺序会保留，并且访问同一列表的每个人都会看到更新后的议题顺序，但有一些例外。

每个议题都会被分配一个相对顺序值，表示它相对于列表中其他议题的顺序。当你拖放重新排序一个议题时，它的相对顺序值会发生变化。

此外，每当一个议题出现在手动排序的列表中时，更新后的相对顺序值就会用于排序。
因此，如果在你的极狐GitLab 实例中有人将议题 `A` 拖到议题 `B` 之上，那么每当它们同时出现在任何列表中时，此顺序都会保持不变。

此排序也会影响 [议题板](../issue_board.md#ordering-issues-in-a-list)。
在议题列表中更改顺序会更改议题板中的顺序，反之亦然。

<a id="sorting-by-milestone-due-date"></a>

## 按里程碑截止日期排序

当你按 **里程碑截止日期** 排序时，议题列表会按分配的里程碑截止日期升序排列。里程碑截止日期最早的议题排在最前面，然后是没有截止日期的里程碑的议题。

<a id="sorting-by-popularity"></a>

## 按受欢迎度排序

当你按 **受欢迎度** 排序时，议题顺序会按每个议题的赞成票数（带有“竖起大拇指”的 [表情反应](../../emoji_reactions.md)）降序排列。你可以使用此方法来识别需求量大的议题。

总票数不会累加。一个有 18 个赞成票和 5 个反对票的议题被认为比一个有 17 个赞成票且没有反对票的议题更受欢迎。

<a id="sorting-by-priority"></a>

## 按优先级排序

当你按 **优先级** 排序时，议题顺序会按以下顺序排列：

1. 具有截止日期的里程碑的议题，其中最早分配的里程碑排在最前面。
1. 没有截止日期的里程碑的议题。
1. 具有更高优先级标签的议题。
1. 没有优先级标签的议题。

平局时任意排序。

更多信息，请参见 [标签优先级](../labels.md#set-label-priority)。

<a id="sorting-by-title"></a>

## 按标题排序

当你按 **标题** 排序时，议题顺序会按议题标题的字母顺序排列，顺序如下：

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

{{< history >}}

- 在极狐GitLab 15.7 [引入](https://gitlab.com/gitlab-org/gitlab/-/issues/377841)。

{{< /history >}}

当你按 **健康** 排序时，议题列表会按议题的 [健康状态](managing_issues.md#health-status) 排序。
降序排列时，议题按以下顺序显示：

1. **有风险** 议题
1. **需要注意** 议题
1. **正常** 议题
1. 所有其他议题

<a id="sorting-by-weight"></a>

## 按权重排序

当你按 **权重** 排序时，议题列表会按 [议题权重](../../work_items/weight.md) 升序排列。
权重最低的议题排在最前面，没有权重的议题排在最后。

<a id="sorting-by-status"></a>

## 按状态排序

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 18.5 [引入](https://gitlab.com/gitlab-org/gitlab/-/issues/550262)，[带有功能标志](../../../administration/feature_flags/_index.md) 名为 `work_item_status_mvc2`。默认启用。
- 在极狐GitLab 18.6 [GA](https://gitlab.com/gitlab-org/gitlab/-/issues/576610)。功能标志 `work_item_status_mvc2` 已移除。

{{< /history >}}

当你按 **状态** 排序时，议题列表会按 [议题状态](../../work_items/status.md) 升序排列。
议题首先按其状态类别排序。如果两个议题属于同一类别，系统会回退到按议题 ID 排序。

