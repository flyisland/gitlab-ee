---
stage: GitLab Dedicated
group: Import
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 导入和导出速率限制
description: "为您的极狐GitLab 实例配置导入或导出项目或群组时的速率限制设置。"
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

您可以为项目和群组的文件导入和导出配置速率限制。有关默认速率限制的信息，请参阅[导入和导出速率限制](../instance_limits.md#import-and-export)。

当用户超过速率限制时，该事件会记录在 `auth.log`中。

<a id="change-an-import-or-export-rate-limit"></a>

## 更改导入或导出速率限制

先决条件：

- 管理员访问权限。

要更改速率限制：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **网络**。
1. 展开**导入和导出速率限制**。
1. 更改任意速率限制的值。速率限制按每分钟每用户计算，而不是按 IP 地址计算。
   设置为 `0` 可禁用速率限制。
