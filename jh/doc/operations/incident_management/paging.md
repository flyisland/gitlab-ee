---
stage: Analytics
group: Platform Insights
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Configure notifications and paging for alerts and incidents in GitLab, including Slack, email, and escalation policies for on-call responders.
title: 寻呼和通知
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

当出现新警报或事件时，响应人员必须立即收到通知，以便他们能够分类并响应问题。响应人员可以使用本页面所述的方法接收通知。

<a id="slack-notifications"></a>

## Slack 通知

适用于 Slack 的极狐GitLab 应用程序可用于接收重要事件通知。

[配置适用于 Slack 的极狐GitLab 应用程序](slack.md)后，每当宣布新事件时，事件响应人员都会在 Slack 中收到通知。为确保你不会错过移动设备上的任何重要事件通知，请在你的手机上启用 Slack 通知。

<a id="email-notifications-for-alerts"></a>

## 警报的邮件通知

项目中提供了针对触发警报的邮件通知。具有 **所有者** 或 **维护者** 角色的项目成员可以选择接收关于新警报的一封邮件通知。

1. 在顶部栏中，选择 **搜索或跳转到** 并查找你的项目。
1. 在左侧边栏中，选择 **设置** > **监控**。
1. 展开 **警报**。
1. 在 **警报设置** 选项卡上，选中 **当有新的警报时，向所有者和维护者发送一封邮件通知** 复选框。
1. 选择 **保存更改**。

[更新警报状态](alerts.md#change-an-alerts-status)以管理警报的邮件通知。

<a id="paging"></a>

## 寻呼

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

在配置了[升级策略](escalation_policies.md)的项目中，可以通过邮件自动寻呼值班响应人员，通知他们关键问题。

<a id="escalating-an-alert"></a>

### 升级警报

当警报触发时，它会立即开始向值班响应人员升级。对于项目升级策略中的每条升级规则，指定的值班响应人员会在规则触发时收到一封邮件。你可以通过[更新警报状态](alerts.md#change-an-alerts-status)来响应寻呼或停止警报升级。

<a id="escalating-an-incident"></a>

### 升级事件

{{< history >}}

- 在极狐GitLab 14.9 引入，并带有名为 `incident_escalations` 的功能标志，默认禁用。
- 在极狐GitLab 14.10 在 JihuLab.com 和私有化部署上启用。
- 功能标志 `incident_escalations` 在极狐GitLab 15.1 中移除。

{{< /history >}}

对于事件，可以针对每个单独的事件选择是否寻呼值班响应人员。

要开始升级事件，请[设置事件的升级策略](manage_incidents.md#change-escalation-policy)。

对于每条升级规则，指定的值班响应人员会在规则触发时收到一封邮件。通过[更改事件状态](manage_incidents.md#change-status)或将事件的升级策略更改回 **无升级策略** 来响应寻呼或停止事件升级。

在极狐GitLab 15.1 及更早版本中，[从警报创建的事件](manage_incidents.md#from-an-alert)不支持独立升级。在极狐GitLab 15.2 及更高版本中，所有事件均可独立升级。