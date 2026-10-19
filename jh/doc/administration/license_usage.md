---
stage: Fulfillment
group: Seat Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 许可证用量
description: 查看并导出与您的极狐GitLab 许可证关联的用量。
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

您可以查看与您的极狐GitLab 许可证关联的用量，并导出包含以下信息的许可证用量文件：

- 许可证密钥
- 被许可方邮箱
- 许可证开始日期（UTC）
- 许可证结束日期（UTC）
- 公司
- 文件生成并导出的时间戳（UTC）
- 该期间内每天的历史用户数表格：
  - 记录计数的时间戳（UTC）
  - 计费用户数

> [!note]
> CSV 文件中的[日期](https://gitlab.com/gitlab-org/gitlab/blob/3be39f19ac3412c089be28553e6f91b681e5d739/config/initializers/date_time_formats.rb#L7)和[时间](https://gitlab.com/gitlab-org/gitlab/blob/3be39f19ac3412c089be28553e6f91b681e5d739/config/initializers/date_time_formats.rb#L13)使用自定义格式。

<a id="export-license-usage"></a>

## 导出许可证用量

先决条件：

- 您必须是管理员。

您可以将许可证用量导出为 CSV 文件。

该文件包含极狐GitLab 用于手动处理[季度对账](../subscriptions/quarterly_reconciliation.md)和[续订](../subscriptions/manage_subscription.md#renew-subscription)的信息。如果您的实例位于防火墙内或处于离线环境，则必须向极狐GitLab 提供此信息。

> [!warning]
> 请勿打开许可证用量文件。如果您打开该文件，[提交许可证用量数据](license_file.md#submit-license-usage-data)时可能会失败。

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**订阅**。
1. 在右上角，选择**导出许可证用量文件**。
