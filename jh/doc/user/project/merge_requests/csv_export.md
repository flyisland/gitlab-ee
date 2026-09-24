---
stage: Create
group: Code Review
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.jihulab.com/handbook/product/ux/technical-writing/#assignments>
title: 导出合并请求为 CSV
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

将项目中合并请求收集的所有数据导出为逗号分隔值 (CSV) 文件。

要将合并请求导出为 CSV 文件：

1. 在顶部栏，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏，选择 **代码** > **合并请求**。
1. 添加任何搜索或过滤条件。这有助于将 CSV 文件大小控制在 15 MB 限制以内。该限制确保文件可以通过电子邮件发送到各种电子邮件提供商。
1. 选择 **操作** ({{< icon name="ellipsis_v" >}}) > **导出为 CSV**。
1. 确认要导出的合并请求数量正确。
1. 选择 **导出合并请求**。

<a id="csv-output"></a>

## CSV 输出

下表显示了 CSV 文件中的属性。

| 列                 | 描述                                                         |
|--------------------|--------------------------------------------------------------|
| 标题               | 合并请求标题                                                 |
| 描述               | 合并请求描述                                                 |
| MR ID              | MR `iid`                                                     |
| URL                | 指向极狐GitLab 上合并请求的链接                              |
| 状态               | 已打开、已关闭、已锁定或已合并                               |
| 源分支             | 源分支                                                       |
| 目标分支           | 目标分支                                                     |
| 源项目 ID          | 源项目的 ID                                                  |
| 目标项目 ID        | 目标项目的 ID                                                |
| 作者               | 合并请求作者的全名                                           |
| 作者用户名         | 作者的用户名，省略 @ 符号                                    |
| 指派人             | 合并请求指派人的全名，用 `,` 连接                            |
| 指派人用户名       | 指派人的用户名，省略 @ 符号                                  |
| 审批人             | 审批人的全名，用 `,` 连接                                    |
| 审批人用户名       | 审批人的用户名，省略 @ 符号                                  |
| 合并用户           | 合并用户的全名                                               |
| 合并用户名         | 合并用户的用户名，省略 @ 符号                                |
| 里程碑 ID          | 合并请求里程碑的 ID                                          |
| 创建时间 (UTC)     | 格式为 `YYYY-MM-DD HH:MM:SS`                                 |
| 更新时间 (UTC)     | 格式为 `YYYY-MM-DD HH:MM:SS`                                 |