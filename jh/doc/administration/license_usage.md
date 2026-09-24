---
stage: Fulfillment
group: Seat Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 许可证使用情况
description: View and export usage associated with your 极狐GitLab license.
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

您可以查看与您的极狐GitLab许可证关联的使用情况，并导出许可证使用文件，其中包含以下信息：

- 许可证密钥
- 被许可方电子邮件
- 许可证开始日期（UTC）
- 许可证结束日期（UTC）
- 公司
- 文件生成和导出的时间戳（UTC）
- 期间每天的历史用户计数表：
  - 记录计数的时间戳（UTC）
  - 可计费用户计数

> [!note]
> CSV 文件中使用了自定义格式的 [日期](https://jihulab.com/gitlab-cn/gitlab/blob/3be39f19ac3412c089be28553e6f91b681e5d739/config/initializers/date_time_formats.rb#L7) 和 [时间](https://jihulab.com/gitlab-cn/gitlab/blob/3be39f19ac3412c089be28553e6f91b681e5d739/config/initializers/date_time_formats.rb#L13)。

<a id="export-license-usage"></a>

## 导出许可证使用情况

前置条件：

- 您必须是管理员。

您可以将许可证使用情况导出为 CSV 文件。

此文件包含极狐GitLab用于手动处理 [季度对账](../subscriptions/quarterly_reconciliation.md) 和 [续订](../subscriptions/manage_subscription.md#renew-subscription) 的信息。如果您的实例处于防火墙后或离线环境中，您必须向极狐GitLab提供此信息。

> [!warning]
> 不要打开许可证使用文件。如果您打开该文件，在 [提交许可证使用数据](license_file.md#submit-license-usage-data) 时可能会发生故障。

1. 在右上角，选择 **管理员**。
1. 在左侧边栏，选择 **订阅**。
1. 在右上角，选择 **导出许可证使用文件**。