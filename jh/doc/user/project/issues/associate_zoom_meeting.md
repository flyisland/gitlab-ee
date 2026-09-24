---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 将 Zoom 会议与议题关联
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

为了同步进行事件管理沟通，你可以将 Zoom 会议与议题关联。当你为了应对紧急事件发起 Zoom 通话后，需要一种方式将该会议通话与议题关联起来，这样你的团队成员就能快速加入，无需索要链接。

<a id="adding-a-zoom-meeting-to-an-issue"></a>

## 在议题中添加 Zoom 会议

要将 Zoom 会议与议题关联，你可以使用 [`/zoom` 快速操作](../quick_actions.md#zoom)。

在议题中，使用 `/zoom` 快速操作后跟一个有效的 Zoom 链接来发表评论：

```shell
/zoom https://zoom.us/j/123456789
```

如果 Zoom 会议 URL 有效，并且你具有报告者、开发者、维护者或所有者角色，系统会弹出提示告知你添加成功。议题的描述将被自动编辑以包含该 Zoom 链接，并且议题标题正下方会出现一个按钮。

![显示加入 Zoom 会议按钮的 极狐GitLab 议题视图](img/zoom_quickaction_button_v16_6.png)

你只能为一个议题关联一个 Zoom 会议。如果你尝试使用 `/zoom` 快速操作添加第二个 Zoom 会议，操作将不会生效。你需要先[移除它](#removing-an-existing-zoom-meeting-from-an-issue)。

极狐GitLab 专业版和旗舰版用户还可以[向事件添加多个 Zoom 链接](../../../operations/incident_management/linked_resources.md#link-zoom-meetings-from-an-incident)。

<a id="removing-an-existing-zoom-meeting-from-an-issue"></a>

## 从议题中移除现有的 Zoom 会议

与添加 Zoom 会议类似，你也可以通过快速操作将其移除：

```shell
/remove_zoom
```

你也可以使用 [`/remove_zoom` 快速操作](../quick_actions.md#remove_zoom)。

如果你具有报告者、开发者、维护者或所有者角色，系统会弹出提示告知你会议 URL 已成功移除。