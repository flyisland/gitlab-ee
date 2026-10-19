---
stage: AI Coding
group: Code Review
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 将合并请求导出为 CSV
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

将项目合并请求中收集的所有数据导出为逗号分隔值（CSV）文件。

要将合并请求导出为 CSV 文件：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**代码** > **合并请求**。
1. 添加任意搜索或筛选条件。这有助于将 CSV 文件大小控制在 15 MB 限制以内。该限制可确保
   文件能够通过电子邮件发送给各种电子邮件提供商。
1. 选择**操作**（{{< icon name="ellipsis_v" >}}）> **导出为 CSV**。
1. 确认要导出的合并请求数量正确。
1. 选择**导出合并请求**。

<a id="csv-output"></a>

## CSV 输出

下表显示了 CSV 文件中的属性。

| 列                 | 描述                                                         |
|--------------------|--------------------------------------------------------------|
| Title              | 合并请求标题                                                 |
| Description        | 合并请求描述                                                 |
| 合并请求 ID              | 合并请求 `iid`                                                     |
| URL                | 指向极狐GitLab 上合并请求的链接                        |
| State              | Opened、Closed、Locked 或 Merged                             |
| Source Branch      | 源分支                                                       |
| Target Branch      | 目标分支                                                     |
| Source Project ID  | 源项目的 ID                                                  |
| Target Project ID  | 目标项目的 ID                                                |
| Author             | 合并请求作者的全名                                  |
| Author Username    | 作者的用户名，省略 @ 符号                                    |
| Assignees          | 合并请求指派人的全名，以 `,` 连接           |
| Assignee Usernames | 指派人的用户名，省略 @ 符号                                  |
| Approvers          | 审批人的全名，以 `,` 连接                           |
| Approver Usernames | 审批人的用户名，省略 @ 符号                                  |
| Merged User        | 合并用户的全名                                               |
| Merged Username    | 合并用户的用户名，省略 @ 符号                                |
| Milestone ID       | 合并请求里程碑的 ID                                 |
| Created At (UTC)   | 格式为 `YYYY-MM-DD HH:MM:SS`                           |
| Updated At (UTC)   | 格式为 `YYYY-MM-DD HH:MM:SS`                           |
