---
stage: Tenant Scale
group: Organizations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Organizations API 速率限制
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Status: 实验

{{< /details >}}

> [!flag]
> 此功能的可用性由功能标志控制。

超过速率限制的请求会记录到 `auth.log` 文件中。

例如，如果您为 `POST /organizations` 设置 400 的限制，则对该 API 端点的请求在一分钟内超过 400 次后将被阻止。一分钟后，对该端点的访问将恢复。

您可以为每个用户配置对 [POST /organizations API](../../api/organizations.md#create-an-organization) 请求的每分钟速率限制。默认值为 10。

<a id="change-the-rate-limit"></a>

## 更改速率限制

前提条件：

- 管理员访问权限。

要更改速率限制：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **网络**。
1. 展开 **Organizations API 速率限制**。
1. 更改任何速率限制的值。速率限制按每个用户每分钟计算。
   要禁用速率限制，请将该值设置为 `0`。
1. 选择 **保存更改**。
