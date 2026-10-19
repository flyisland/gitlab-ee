---
stage: Software Supply Chain Security
group: Compliance
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 审计事件 API 的速率限制
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

您可以为三个 API 的请求配置速率限制：

- [实例审计事件 API](../../api/audit_events.md#instance-audit-events)。速率限制为每用户每分钟。默认值为 200。
- [群组审计事件 API](../../api/audit_events.md#group-audit-events)。速率限制为每用户每群组每分钟。默认值为 200。
- [项目审计事件 API](../../api/audit_events.md#project-audit-events)。速率限制为每用户每项目每分钟。默认值为 200。

超过上述任一速率限制的请求会返回 `429 Too Many Requests` 状态码，并记录到 `auth.log` 文件中。

- 实例审计事件 API 的速率限制同时适用于 `GET /audit_events` 和 `GET /audit_events/:id`。
- 群组审计事件 API 的速率限制同时适用于 `GET /groups/:id/audit_events` 和 `GET /groups/:id/audit_events/:audit_event_id`。
- 项目审计事件 API 的速率限制同时适用于 `GET /projects/:id/audit_events` 和 `GET /projects/:id/audit_events/:audit_event_id`。

例如，如果您将限制设置为 200，则在一分钟内对这些端点的请求超过 200 次时会被阻止。一分钟后恢复访问。

<a id="change-the-rate-limits"></a>

## 更改速率限制

先决条件：

- 管理员访问权限。

更改速率限制：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **网络**。
1. 展开**审计事件 API 速率限制**。
1. 更改您要更新的速率限制的值。
   要禁用速率限制，请将该值设置为 `0`。
1. 选择**保存更改**。
