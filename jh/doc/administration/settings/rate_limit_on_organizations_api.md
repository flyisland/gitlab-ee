---
stage: Tenant Scale
group: Organizations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 组织 API 的速率限制
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Status: 实验性

{{< /details >}}

{{< history >}}

- 引入于极狐GitLab 17.5，带有一个 [功能标志](../feature_flags/_index.md) 名为 `allow_organization_creation`。默认禁用。此功能是一个 [实验](../../policy/development_stages_support.md)。
- 变更于极狐GitLab 18.4。功能标志 `allow_organization_creation` 合并并重命名为 `organization_switching`。

{{< /history >}}

> [!flag]
> 此功能的可用性由一个功能标志控制。
> 更多信息，请参见历史记录。

超出速率限制的请求将被记录到 `auth.log` 文件中。

例如，如果你将 `POST /organizations` 的速率限制设置为 400，则在一分钟内超过 400 次速率的对该 API 端点的请求将被阻止。一分钟后，对该端点的访问将被恢复。

你可以为 [POST /organizations API](../../api/organizations.md#create-an-organization) 的每个用户配置每分钟的速率限制。默认值为 10。

<a id="change-the-rate-limit"></a>

## 更改速率限制

前提条件：

- 管理员权限。

要更改速率限制：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **网络**。
1. 展开 **组织 API 速率限制**。
1. 更改任何速率限制的值。这些速率限制是针对每个用户每分钟的。
   要禁用某个速率限制，将值设置为 `0`。
1. 选择 **保存更改**。