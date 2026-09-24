---
stage: Plan
group: Product Planning
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: 测试史诗新的外观
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Status: Beta

{{< /details >}}

{{< history >}}

- 引入于极狐GitLab 17.2，使用名为 `work_item_epics` 的功能标志。默认禁用。此功能处于 [beta](../../../policy/development_stages_support.md#beta) 阶段。
- 使用 [GraphQL API](../../../api/graphql/reference/_index.md) 列出史诗引入于极狐GitLab 17.4。
- 在极狐GitLab 17.6 中为 JihuLab.com 启用。
- 在极狐GitLab 17.7 中，为私有化部署启用。

{{< /history >}}

{{< alert type="flag" >}}

此功能的可用性受控于功能标志。有关更多信息，请参阅历史记录。

{{< /alert >}}

<!-- When epics as work items are generally available and `work_item_epics` flag is removed,
incorporate this content into epics/index.md and redirect this page there -->

我们通过将史诗迁移到一个统一的工作项框架来改变其外观，以更好地满足我们的敏捷规划产品需求。

<a id="troubleshooting"></a>

## 故障排除

如果在新的体验中导航数据时遇到任何问题，可以尝试以下几种方法来解决。

<a id="access-the-old-experience"></a>

### 访问旧体验

您可以通过编辑 URL 并包含 `force_legacy_view=true` 参数来暂时加载旧体验，例如，`https://jihulab.com/gitlab-cn/-/epics/9290?force_legacy_view=true`。使用此参数在旧体验和新体验之间进行比较，以便在打开支持请求时提供详细信息。

<a id="disable-the-new-experience"></a>

### 禁用新体验

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

我们不建议禁用此更改，因为我们希望了解您不喜欢它的原因。如果您必须禁用新的体验以解除工作流程的阻碍，请禁用 `work_item_epics` [feature flag](../../../administration/feature_flags.md#how-to-enable-and-disable-features-behind-flags)。

<a id="related-topics"></a>

## 相关主题

- [工作项开发](../../../development/work_items.md)
