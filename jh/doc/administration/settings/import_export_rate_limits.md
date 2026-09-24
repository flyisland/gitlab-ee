---
stage: Create
group: Import
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 项目和群组的导入导出速率限制
description: "Configure rate limit settings for your 极狐GitLab instance when importing or exporting projects or groups."
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

您可以配置项目和群组的文件导入和导出的速率限制。有关默认速率限制的信息，请参阅[导入和导出速率限制](../instance_limits.md#import-and-export)。

当用户超出速率限制时，会记录在 `auth.log` 中。

<a id="change-an-import-or-export-rate-limit"></a>

## 更改导入或导出速率限制

先决条件：

- 管理员访问权限。

要更改速率限制：

1. 在右上角，选择 **管理员**。
2. 在左侧边栏，选择 **设置** > **网络**。
3. 展开 **导入和导出速率限制**。
4. 更改任何速率限制的值。速率限制是每个用户每分钟，而不是每个 IP 地址。设置为 `0` 以禁用速率限制。