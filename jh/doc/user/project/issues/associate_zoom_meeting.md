---
stage: Plan
group: Work Items
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 将 Zoom 会议与议题关联
description: 使用 /zoom 快速操作将 Zoom 会议与议题关联，让团队成员可以快速加入通话。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

为了在事件管理中进行同步沟通，您可以将 Zoom 会议与议题关联。为处置紧急事件发起 Zoom 通话后，您需要一种方式将该会议通话与议题关联起来。这样您的团队成员就可以快速加入，无需请求链接。

<a id="adding-a-zoom-meeting-to-an-issue"></a>

## 向议题添加 Zoom 会议

要将 Zoom 会议与议题关联，您可以使用[`/zoom` 快速操作](../quick_actions.md#zoom)。

在议题中，使用 `/zoom` 快速操作并附上有效的 Zoom 链接发表评论：

```shell
/zoom https://zoom.us/j/123456789
```

如果 Zoom 会议 URL 有效，并且您拥有报告者、开发者、维护者或所有者角色，系统会提示您已成功添加。议题的描述会自动编辑以包含 Zoom 链接，并且议题标题正下方会出现一个按钮。

![极狐GitLab 议题视图，显示“加入 Zoom 会议”按钮。](img/zoom_quickaction_button_v16_6.png)

您只能将一个 Zoom 会议附加到议题。如果您尝试使用 `/zoom` 快速操作添加第二个 Zoom 会议，该操作不会生效。您需要先[将其移除](#removing-an-existing-zoom-meeting-from-an-issue)。

极狐GitLab 专业版和旗舰版的用户还可以[向事件添加多个 Zoom 链接](../../../operations/incident_management/linked_resources.md#link-zoom-meetings-from-an-incident)。

<a id="removing-an-existing-zoom-meeting-from-an-issue"></a>

## 从议题中移除现有 Zoom 会议

与添加 Zoom 会议类似，您可以使用快速操作将其移除：

```shell
/remove_zoom
```

您也可以使用[`/remove_zoom` 快速操作](../quick_actions.md#remove_zoom)。

如果您拥有报告者、开发者、维护者或所有者角色，系统会提示您会议 URL 已成功移除。
