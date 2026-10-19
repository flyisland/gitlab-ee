---
stage: Plan
group: Work Items
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Engineering Workflow Management (EWM)
description: 配置 Engineering Workflow Management (EWM) 集成，以关联合并请求和提交消息中提到的 EWM 工作项。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

通过 EWM 集成，您可以从极狐GitLab 跳转到合并请求描述和提交消息中提到的 EWM 工作项。每个工作项引用都会自动转换为指向该工作项的链接。

此 IBM 产品[原名为 Rational Team Concert (RTC)](https://jazz.net/blog/index.php/2019/04/23/renaming-the-ibm-continuous-engineering-portfolio/)。此集成与所有版本的 RTC 和 EWM 兼容。

要在项目中开启 EWM 集成：

1. 在顶部栏中，选择**搜索或跳转到**，找到您的项目。
1. 在左侧边栏中，选择**设置** > **集成**。
1. 选择 **EWM**。
1. 在**启用集成**下，选中**活跃**复选框。
1. 填写必填字段：

   - **项目 URL**：EWM 项目区域的 URL。

     要获取项目区域 URL，请转到
     路径 `/ccm/web/projects` 并复制所列项目的 URL。例如，`https://example.com/ccm/web/Example%20Project`。
   - **议题 URL**：EWM 项目区域中工作项编辑器的 URL。

     格式为 `<your-server-url>/resource/itemName/com.ibm.team.workitem.WorkItem/:id`。
     极狐GitLab 会将 `:id` 替换为议题编号
     （例如，`https://example.com/ccm/resource/itemName/com.ibm.team.workitem.WorkItem/:id`，
     会变为 `https://example.com/ccm/resource/itemName/com.ibm.team.workitem.WorkItem/123`）。
   - **新建议题 URL**：用于在 EWM 项目区域中创建新工作项的 URL。

     将以下片段追加到您的项目区域 URL：`#action=com.ibm.team.workitem.newWorkItem`。
     例如，`https://example.com/ccm/web/projects/JKE%20Banking#action=com.ibm.team.workitem.newWorkItem`。

1. 可选。选择**测试设置**。
1. 选择**保存更改**。

<a id="reference-ewm-work-items-in-commit-messages"></a>

## 在提交消息中引用 EWM 工作项

要引用工作项，您可以使用 EWM Git Integration Toolkit 支持的任何关键字。
使用格式：`<keyword> <id>`。

您可以使用以下关键字：

- `bug`
- `defect`
- `rtcwi`
- `task`
- `work item`
- `workitem`

避免使用关键字 `#`。有关更多信息，请参见[从提交评论创建链接](https://www.ibm.com/docs/en/elm/7.0.0?topic=commits-creating-links-from-commit-comments)。
