---
stage: Software Supply Chain Security
group: Compliance
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 探索极狐GitLab 合规违规报告，查看并管理项目和群组中的不合规问题。
title: 合规违规报告
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用合规违规报告，可全面查看群组中所有项目的合规违规情况。该报告提供有关被违反的控制措施、相关审计事件的详细信息，并允许您管理违规状态。

<a id="enable-compliance-violations-report"></a>

## 启用合规违规报告

在违规出现在合规违规报告中之前，您必须：

1. [创建带控制措施的合规框架](../compliance_frameworks/_index.md)。
1. [将框架应用到您的项目](../compliance_frameworks/_index.md#apply-a-compliance-framework-to-a-project)。

完成这些步骤后，检测到的违规会出现在合规违规报告中。

当审计事件违反框架中定义的控制措施时，系统会自动检测违规。系统会持续监控审计事件，并将其与框架的控制措施定义进行比对，以识别不合规情况。

<a id="supported-controls"></a>

### 支持的控制措施

以下合规控制措施支持违规检测：

- `minimum_approvals_required_1`
- `minimum_approvals_required_2`
- `merge_request_prevent_author_approval`
- `merge_request_prevent_committers_approval`

有关合规控制措施的更多信息，请参阅[合规框架](../compliance_frameworks/_index.md)。

<a id="view-the-compliance-violations-report"></a>

## 查看合规违规报告

先决条件：

- 您必须是管理员，或拥有项目或群组的安全管理员或所有者角色。

查看合规违规报告：

1. 在顶部栏中，选择**搜索或跳转到**，找到您的项目或群组。
1. 在左侧边栏中，选择**安全** > **合规中心**。

合规违规报告显示：

- **状态**：违规的当前状态。例如，需要审核、已解决或已忽略。
- **被违反的控制措施和框架**：被违反的具体合规控制措施及其关联框架。
- **审计事件**：触发违规的事件的详细信息。
- **项目**：发生违规的项目。
- **检测日期**：识别出违规的时间。
- **操作**：查看违规详细信息的链接。

在报告中，您可以：

- 通过选择列标题对报告排序。
- 使用状态下拉列表更改违规状态。
- 使用分页浏览多页违规记录。
- 查看每条违规的详细信息。
- 将报告导出为 CSV 文件。

<a id="filter-compliance-violations"></a>

### 筛选合规违规

您可以筛选合规违规报告，以聚焦特定违规：

1. 在合规违规报告中，使用页面顶部的筛选选项。
1. 选择一个或多个筛选条件：
   - **状态**：按违规状态筛选（已检测、已忽略、审核中或已解决）。
   - **项目**：按群组中的特定项目筛选。
   - **控制措施**：按合规控制措施筛选。
   - **检测时间早于**：显示在特定日期之前检测到的违规。
   - **检测时间晚于**：显示在特定日期当天或之后检测到的违规。

结合使用**检测时间早于**和**检测时间晚于**，可将报告限制在某个日期范围内。

报告会自动更新，仅显示与您所选筛选条件匹配的违规。

要清除筛选条件，请清空筛选选项或选择**清除**。

<a id="violation-details"></a>

## 违规详情

当您为特定违规选择**详情**时，可以查看：

- 违规 ID 和状态。
- 发生违规的位置（项目）。
- 全面的审计事件信息，包括：
  - 事件作者。
  - 事件目标。
  - 事件详情。
  - IP 地址。
  - 目标类型。
- 被违反的控制措施信息，包括：
  - 控制措施名称和描述。
  - 关联的合规框架。
  - 要求。
- 修复建议及解决违规的链接。
- 与该违规相关的评论和讨论串。

<a id="add-comments-to-violations"></a>

### 为违规添加评论

您可以为违规添加评论，与团队协作开展修复工作：

1. 在违规详情视图中，滚动到评论部分。
1. 在文本字段中输入您的评论。
1. 选择**评论**发布您的评论。

您的评论会添加到该违规中，并对所有有权访问合规违规报告的用户可见。

<a id="manage-violation-statuses"></a>

## 管理违规状态

您可以更新合规违规的状态，以跟踪其修复进度。可用状态包括：

- **需要审核**：新违规的默认状态
- **进行中**：违规正在处理中
- **已解决**：违规已修复
- **已忽略**：违规已经过审核并被忽略

更改违规状态：

1. 在合规违规报告中，找到您要更新的违规。
1. 在**状态**列中选择当前状态下拉列表。
1. 从下拉列表菜单中选择新状态。

状态会立即更新并反映在报告中。

<a id="export-compliance-violations-report"></a>

## 导出合规违规报告

导出群组中所有项目的合规违规 CSV 报告。导出的报告包括：

- 检测时间（日期时间，最新的在前）
- 违规 ID
- 状态
- 框架
- 合规控制措施
- 合规要求
- 审计事件作者
- 审计事件类型
- 审计事件名称
- 审计事件消息
- 项目 ID

报告：

- 在 15 MB 处截断，以免电子邮件附件过大。
- 包含所有违规，无论 Web 界面中应用了何种筛选条件。

先决条件：

- 您必须是管理员，或拥有群组的安全管理员或所有者角色。

导出合规违规报告：

1. 在顶部栏中，选择**搜索或跳转到**，找到您的群组。
1. 在左侧边栏中，选择**安全** > **合规中心**。
1. 在右上角，选择**导出**。
1. 选择**导出违规报告**。

系统会生成报告，并作为附件发送到您的电子邮箱。

<a id="static-compliance-violations-report"></a>

## 静态合规违规报告

> [!warning]
> 此功能已在极狐GitLab 18.2 中[弃用](https://gitlab.com/gitlab-org/gitlab/-/issues/551236)，
> 并计划在 18.8 中移除。

静态合规违规报告提供群组中所有项目的合并请求活动的高层级视图。

当您在静态合规违规报告中选择某一行时，会出现一个抽屉，其中提供：

- 项目名称和[合规框架标记](../../project/working_with_projects.md#add-a-compliance-framework-to-a-project)（如果项目已分配）。
- 指向引入该违规的合并请求的链接。
- 合并请求的分支路径，格式为`[source] into [target]`。
- 向该合并请求提交更改的用户列表。
- 对该合并请求发表评论的用户列表。
- 批准该合并请求的用户列表。
- 合并该合并请求的用户。

<a id="view-the-static-compliance-violations-report"></a>

### 查看静态合规违规报告

先决条件：

- 您必须是管理员，或拥有项目或群组的安全管理员或所有者角色。

查看静态合规违规报告：

1. 在顶部栏中，选择**搜索或跳转到**，找到您的项目或群组。
1. 在左侧边栏中，选择**安全** > **合规中心**。

您可以按以下条件对合规报告排序：

- 严重级别。
- 违规类型。
- 合并请求标题。

您可以按以下条件筛选合规违规报告：

- 发现违规的项目。
- 违规的日期范围。
- 违规的目标分支。

选择某一行可查看该合规违规的详情。

<a id="severity-levels"></a>

### 严重级别

每条合规违规具有以下严重级别之一。

<!-- vale gitlab_base.SubstitutionWarning = NO -->

| 图标                                  | 严重级别 |
|:--------------------------------------|:---------------|
| {{< icon name="severity-critical" >}} | 严重       |
| {{< icon name="severity-high" >}}     | 高           |
| {{< icon name="severity-medium" >}}   | 中         |
| {{< icon name="severity-low" >}}      | 低            |
| {{< icon name="severity-info" >}}     | 信息           |

<!-- vale gitlab_base.SubstitutionWarning = YES -->

<a id="violation-types"></a>

### 违规类型

| 违规                         | 严重级别 | 类别                                      | 描述                                                                                                                                                                                                                                            |
|:----------------------------------|:---------------|:----------------------------------------------|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 作者批准了合并请求     | 高           | [职责分离](#separation-of-duties) | 合并请求的作者批准了自己的合并请求。更多信息，请参阅[阻止合并请求创建者批准](../../project/merge_requests/approvals/settings.md#prevent-approval-by-merge-request-creator)。                     |
| 提交者批准了合并请求 | 高           | [职责分离](#separation-of-duties) | 合并请求的提交者批准了他们参与贡献的合并请求。更多信息，请参阅[阻止添加提交的用户批准](../../project/merge_requests/approvals/settings.md#prevent-approvals-by-users-who-add-commits)。 |
| 审批数少于两个          | 高           | [职责分离](#separation-of-duties) | 合并请求在审批数少于两个的情况下被合并。更多信息，请参阅[合并请求审批规则](../../project/merge_requests/approvals/rules.md)。                                                                                     |

<a id="separation-of-duties"></a>

#### 职责分离

极狐GitLab 支持在创建和批准合并请求的用户之间实施职责分离策略。职责分离的标准是：

- [合并请求创建者不得批准自己的合并请求](../../project/merge_requests/approvals/settings.md#prevent-approval-by-merge-request-creator)。
- [合并请求提交者不得批准其已添加提交的合并请求](../../project/merge_requests/approvals/settings.md#prevent-approvals-by-users-who-add-commits)。
- [合并合并请求所需的最低审批数至少为两个](../../project/merge_requests/approvals/rules.md)。

<a id="export-a-report-of-merge-request-compliance-violations-on-projects-in-a-group"></a>

### 导出群组中项目的合并请求合规违规报告

导出群组中项目所属合并请求的合并请求合规违规报告。报告：

- 不使用违规报告上的筛选条件。
- 在 15 MB 处截断，以免电子邮件附件过大。

先决条件：

- 您必须是管理员，或拥有群组的安全管理员或所有者角色。

导出群组中项目的合并请求合规违规报告：

1. 在顶部栏中，选择**搜索或跳转到**，找到您的群组。
1. 在左侧边栏中，选择**安全** > **合规中心**。
1. 在右上角，选择**导出**。
1. 选择**导出违规报告**。

系统会生成报告，并作为附件发送到您的电子邮箱。
