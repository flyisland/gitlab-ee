---
stage: Analytics
group: Platform Insights
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 在极狐GitLab 中为告警和事件配置通知与寻呼，包括 Slack、电子邮件以及针对值班响应者的升级策略。
title: 寻呼和通知
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

当出现新的告警或事件时，响应者必须立即收到通知，以便他们能够对问题进行排查和响应。响应者可以使用本页所述的方法接收通知。

<a id="slack-notifications"></a>

## Slack 通知

可以使用 GitLab for Slack 应用接收重要的事件通知。

当[配置了 GitLab for Slack 应用](slack.md)后，每次声明新事件时，事件响应者都会在 Slack 中收到通知。为确保您不会错过移动设备上的任何重要事件通知，请在手机上启用 Slack 通知。

<a id="email-notifications-for-alerts"></a>

## 告警的电子邮件通知

项目可以为触发的告警提供电子邮件通知。具有**所有者**或**维护者**角色的项目成员可以选择接收新告警的单封电子邮件通知。

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**设置** > **监控**。
1. 展开**告警**。
1. 在**告警设置**标签页上，选中
   **向所有者和维护者发送新告警的单封电子邮件通知**复选框。
1. 选择**保存更改**。

[更新告警的状态](alerts.md#change-an-alerts-status)以管理告警的电子邮件通知。

<a id="paging"></a>

## 寻呼

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

在配置了[升级策略](escalation_policies.md)的项目中，可以通过电子邮件自动向值班响应者寻呼关键问题。

<a id="escalating-an-alert"></a>

### 升级告警

当告警触发时，它会立即开始向值班响应者升级。对于项目升级策略中的每条升级规则，当规则触发时，指定的值班响应者会收到一封电子邮件。您可以通过[更新告警的状态](alerts.md#change-an-alerts-status)来响应寻呼或停止告警升级。

<a id="escalating-an-incident"></a>

### 升级事件

对于事件，向值班响应者寻呼对每个单独的事件都是可选的。

要开始升级事件，请[设置事件的升级策略](manage_incidents.md#change-escalation-policy)。

对于每条升级规则，当规则触发时，指定的值班响应者会收到一封电子邮件。通过[更改事件的状态](manage_incidents.md#change-status)或将事件的升级策略改回**无升级策略**，来响应寻呼或停止事件升级。

所有事件（包括[从告警创建的事件](manage_incidents.md#from-an-alert)）都可以独立升级。
