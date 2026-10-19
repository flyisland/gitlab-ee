---
stage: Solutions Architecture
group: Solutions Architecture
info: This page is owned by the Solutions Architecture team.
description: Integrate Jira with GitLab for real-time incident replication, enabling accurate DORA metrics tracking including Change Failure Rate and Time to Restore Service.
title: Jira 与极狐GitLab DORA 集成
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

借助极狐GitLab，您可以查看 [DORA 指标](../../user/analytics/dora_metrics.md)，以帮助您衡量 DevOps 性能。这 4 个指标包括：

- **部署频率**：每天部署到生产环境的平均次数
- **变更前置时间**：将提交成功交付到生产环境所需的秒数（从代码提交到代码在生产环境中成功运行）
- **变更失败率**：在给定时间段内，导致生产环境事件的部署百分比
- **恢复服务时间**：生产环境上事件保持开启状态的中位时间

虽然前两个指标由极狐GitLab CI/CD 和合并请求生成，但后两个指标依赖于创建 [极狐GitLab 事件](../../operations/incident_management/manage_incidents.md)。

对于使用 Jira 进行事件跟踪的团队，这意味着需要将事件从 Jira 实时复制到极狐GitLab。本项目将逐步介绍如何设置该复制。

> [!note]
> 存在一个类似的集成，用于议题复制以生成价值流分析指标（前置时间、已创建议题和已关闭议题）。如果您对用于 VSA 指标的议题复制感兴趣，请参考 [Jira 与极狐GitLab VSA 集成](jira_vsa.md)。

<a id="architecture"></a>

## 架构

我们需要创建 2 个自动化工作流：

1. 当 Jira 中创建事件时，在极狐GitLab 中创建事件。
2. 当 Jira 中解决事件时，在极狐GitLab 中解决事件。

<a id="incident-creation"></a>

### 事件创建

![显示 Jira 事件如何在极狐GitLab 中触发警报的工作流。](img/jira_dora_creation_flow_v18_1.png)

<a id="incident-resolution"></a>

### 事件解决

![显示已解决的 Jira 事件如何在极狐GitLab 中触发事件解决的工作流。](img/jira_dora_resolution_flow_v18_1.png)

<a id="setup"></a>

## 设置

<a id="pre-requisites"></a>

### 先决条件

本指南假设您具备以下条件：

- 极狐GitLab 旗舰版许可证
- 一个用于克隆事件的 Jira 项目

Jira 根据您的 Jira 许可证对自动化运行频率设置了[限制](https://www.atlassian.com/software/jira/pricing)。目前，限制如下：

| **版本**   | **限制**                    |
|------------|------------------------------|
| 免费版       | 每月 100 次运行           |
| 标准版   | 每月 1700 次运行          |
| 高级版    | 每用户每月 1000 次运行 |
| 企业版 | 无限制运行               |

每次事件创建计为 1 次运行，每次事件解决计为 1 次运行。

<a id="gitlab-alert-endpoint"></a>

### 极狐GitLab 警报端点

首先，我们需要创建一个 HTTP 端点，该端点可以被触发以在极狐GitLab 中创建/解决警报，进而创建/解决事件。

1. 前往您希望创建 Jira 事件的极狐GitLab 项目。从侧边栏中，转到 **设置** > **监控**。展开 **警报** 部分。
2. 在 **警报** 下，切换到 **警报设置** 选项卡。勾选以下复选框，然后点击 **保存更改**：
   - _创建事件。每次触发警报时都会创建事件。_
   - _当恢复警报通知解决警报时，自动关闭关联的事件_
3. 在 **警报** 下，切换到 **当前集成** 选项卡。点击 **添加新集成**。将 **集成类型** 设置为 `HTTP Endpoint`，为其命名（例如 `Jira 事件同步`），并将 **启用集成** 设置为 **活跃**。在设置好 Jira 自动化工作流后，我们将返回来自定义警报负载映射。
4. 点击 **保存集成**。应出现一条消息，显示“集成已成功保存”。点击 **查看 URL 和授权密钥**。
5. 在设置 Jira 自动化工作流和 Lambda 函数时，我们将需要端点 URL 和授权密钥，因此请保存以备后用。

<a id="jira-incident-creation-workflow"></a>

### Jira 事件创建工作流

要在 Jira 事件创建时自动触发极狐GitLab 警报端点，我们将使用 [Jira 自动化](https://community.atlassian.com/t5/Jira-articles/Automation-for-Jira-Send-web-request-using-Jira-REST-API/ba-p/1443828)。

1. 导航到管理事件的 Jira 项目。从侧边栏中，前往 **项目设置** > **自动化**（您可能需要向下滚动一点才能找到）。
2. 在这里我们可以管理 Jira 自动化工作流。在右上角，点击 **创建规则**。
3. 对于触发器，搜索并选择 **议题已创建**。点击 **保存**。
4. 接下来，选择 **IF：添加条件**。您可以在此处指定要检查的条件，以确定创建的议题是否与事件相关。在本指南中，我们将选择 **议题字段条件**。在 **字段** 下，选择 **摘要**，**条件** 设置为 **包含**，值设置为 `incident`。点击 **保存**。
5. 设置好触发器和条件后，选择 **THEN：添加操作**。搜索并选择 **发送 Web 请求**。
6. 将 **Web 请求 URL** 设置为上一节中的极狐GitLab **Webhook URL**。
7. 查看极狐GitLab 文档中的[端点身份验证选项](../../operations/incident_management/integrations.md#authorization)。在本指南中，我们将使用 [Bearer 授权标头](../../operations/incident_management/integrations.md#bearer-authorization-header)方法。在 Jira 自动化配置中，添加以下标头：

   | 名称 | 值 |
   | ------ | ------ |
   | Authorization | Bearer \<极狐GitLab 端点 **授权密钥**（来自上一节）\> |
   | Content-Type | `application/json` |

   - 您可能希望将 `Authorization` 标头设置为“隐藏”。
8. 确保 **HTTP 方法** 设置为 **POST**，并将 **Web 请求正文** 设置为 **议题数据（Jira 格式）**。
9. 最后，点击 **保存**，为自动化命名（例如 `Jira 事件创建`），然后点击 **启用**。在右上角，点击 **返回列表**。
10. 您需要做的最后一件事是将 Jira 负载值映射到极狐GitLab 警报参数。如果您还计划为 **恢复服务时间** 指标设置事件解决，请暂时跳过此步骤。否则，请跳至 [将 Jira 负载值映射到极狐GitLab 警报参数](#map-jira-payload-values-to-gitlab-alert-parameters) 并按照其中的步骤操作。

映射负载值后，您在 Jira 中创建的事件也将在极狐GitLab 中创建。这将使您能够查看 **变更失败率** DORA 指标。

<a id="jira-incident-resolution-workflow"></a>

### Jira 事件解决工作流

按照上述方法创建另一个 Jira 自动化工作流，但进行以下更改：

1. 将触发器设置为 **议题已转换**。“从状态”字段可以留空。“到状态”字段可以设置为根据工作流表示已解决事件的任何状态（例如 `Closed`、`Done`、`Resolved`、`Completed`）。
2. 确保为自动化适当命名（例如 `Jira 事件关闭`）。

<a id="map-jira-payload-values-to-gitlab-alert-parameters"></a>

### 将 Jira 负载值映射到极狐GitLab 警报参数

1. 创建 Jira 自动化工作流后，点击您刚刚创建的工作流，然后选择 **Then：发送 Web 请求**。
2. 展开 **验证您的 Web 请求配置** 部分，然后输入一个 _已解决_ 的议题密钥进行测试（您必须有一个可用的现有议题密钥）。点击 **验证**。
3. 展开 **请求 POST** 部分，然后展开 **负载** 部分。复制整个负载。
4. 返回您的极狐GitLab 项目，然后转到 **设置** > **监控** > **警报** > **当前集成**。点击您之前创建的集成旁边的“设置”图标，然后切换到 **配置详情** 选项卡。
5. 在 **自定义警报负载映射** 下，粘贴您在步骤 3 中从 Jira 复制的负载。然后点击 **解析负载字段**。
6. 按照如下所示映射字段：

    | 极狐GitLab 警报键 | 负载警报键 |
    | ------ | ------ |
    | Title | issue.fields.summary |
    | Description | issue.fields.status.description |
    | End time | issue.fields.resolutiondate<sup>1</sup> |
    | Monitoring tool | issue.fields.reporter.accountType |
    | Severity | issue.fields.priority.name |
    | Fingerprint | issue.key |
    | Environment | issue.fields.project.name |

<sup>1</sup> 仅当您设置了事件解决自动化时才需要此项。如果此字段未显示为选项，请确保您在上面的步骤 2 中输入了 _已解决_ 的议题密钥进行测试。

7. 最后，点击 **保存集成**。

此时，您在 Jira 中解决的事件也将在极狐GitLab 中得到解决。这将使您能够查看 **恢复服务时间** DORA 指标。

<a id="resources"></a>

## 资源

- [DORA 指标](../../user/analytics/dora_metrics.md)
  - [使用 Jira 衡量 DORA 指标](../../user/analytics/dora_metrics.md#with-jira)
- [极狐GitLab 事件管理](../../operations/incident_management/manage_incidents.md)
- [极狐GitLab HTTP 端点](../../operations/incident_management/integrations.md#alerting-endpoints)
  - [极狐GitLab HTTP 端点授权](../../operations/incident_management/integrations.md#authorization)
  - [极狐GitLab 警报参数](../../operations/incident_management/integrations.md#customize-the-alert-payload-outside-of-gitlab)
  - [极狐GitLab 恢复警报](../../operations/incident_management/integrations.md#recovery-alerts)
- [Jira 自动化与 Web 请求](https://community.atlassian.com/t5/Jira-articles/Automation-for-Jira-Send-web-request-using-Jira-REST-API/ba-p/1443828)