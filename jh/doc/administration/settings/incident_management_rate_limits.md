---
stage: Analytics
group: Platform Insights
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Configure rate limits for inbound incident management alerts. Set maximum requests per project and time periods to prevent alert overload.
gitlab_dedicated: yes
title: 事件管理速率限制
---

{{< details >}}

- Tier: 旗舰版
- Offering: 私有化部署

{{< /details >}}

<a id="incident-management-rate-limits"></a>

# 事件管理速率限制

你可以限制在一段时间内为[事件](../../operations/incident_management/incidents.md)创建的入站告警数量。入站[事件管理](../../operations/incident_management/_index.md)告警限制可以通过减少告警或重复议题的数量，帮助防止事件响应人员过载。

例如，如果你设置每 `60` 秒限制 `10` 个请求，并且在一分钟内将 `11` 个请求发送到[告警集成端点](../../operations/incident_management/integrations.md)，则第十一个请求会被阻止。一分钟后，端点访问再次允许。

此限制：

- 按项目独立应用。
- 不按 IP 地址应用。
- 默认禁用。

超过限制的请求会记录到 `auth.log` 中。

## 设置入站告警限制

先决条件：

- 管理员访问权限。

要设置入站事件管理告警限制：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **网络**。
1. 展开 **事件管理限制**。
1. 选中 **启用事件管理入站告警限制** 复选框。
1. 可选。为 **每个速率限制周期内每个项目的最大请求数** 输入自定义值。默认为 3600。
1. 可选。为 **速率限制周期** 输入自定义值。默认为 3600 秒。