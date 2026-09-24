---
stage: Software Supply Chain Security
group: Compliance
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 合规违规报告
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 15.9 中重命名为合规违规报告。
- 在极狐GitLab 16.0 中引入了创建和编辑合规框架的功能。
- 动态合规违规报告
  - 在极狐GitLab 18.2 中引入，带有功能标志 `compliance_violations_report` 和 `enable_project_compliance_violations`。默认禁用。
  - 在极狐GitLab 18.3 中为私有化部署启用。
  - 在极狐GitLab 18.5 中 GA。功能标志 `compliance_violations_report` 和 `enable_project_compliance_violations` 已移除。

{{< /history >}}

使用合规违规报告查看群组内所有项目的合规违规的全面视图。该报告提供有关违规控制、关联审计事件的详细信息，并允许你管理违规状态。

<a id="enable-compliance-violations-report"></a>

## 启用合规违规报告

在违规出现在合规违规报告中之前，你必须：

1. [创建带有控制的合规框架](../compliance_frameworks/_index.md)。
1. [将框架应用于你的项目](../compliance_frameworks/_index.md#apply-a-compliance-framework-to-a-project)。

完成这些步骤后，违规在检测到时就会出现在合规违规报告中。

当审计事件违反框架中定义的控制时，系统会自动检测违规。系统持续监控审计事件，并将其与框架的控制定义进行比较，以识别不合规情况。

<a id="supported-controls"></a>

### 支持的控制

以下合规控制支持违规检测：

- `minimum_approvals_required_1`
- `minimum_approvals_required_2`
- `merge_request_prevent_author_approval`
- `merge_request_prevent_committers_approval`

有关合规控制的更多信息，请参见[合规框架](../compliance_frameworks/_index.md)。

<a id="view-the-compliance-violations-report"></a>

## 查看合规违规报告

前提条件：

- 你必须是管理员或拥有项目或群组的安全经理或所有者角色。

要查看合规违规报告：

1. 在顶部栏，选择 **搜索或跳转到** 并找到你的项目或群组。
1. 在左侧边栏，选择 **安全** > **合规中心**。

合规违规报告显示：

- **状态**：违规的当前状态。例如，需要审核、已解决或已驳回。
- **违规的控制和框架**：被违反的特定合规控制及其关联框架。
- **审计事件**：触发违规的事件的详细信息。
- **项目**：发生违规的项目。
- **检测日期**：识别违规的时间。
- **操作**：查看违规详细信息的链接。

在报告中，你可以：

- 通过选择列标题对报告进行排序。
- 使用状态下拉列表更改违规的状态。
- 使用分页浏览多个页面的违规。
- 查看每个违规的详细信息。
- 将报告导出为 CSV 文件。

<a id="filter-compliance-violations"></a>

### 筛选合规违规

{{< history >}}

- 在极狐GitLab 18.7 中引入。

{{< /history >}}

你可以筛选合规违规报告以关注特定的违规：

1. 在合规违规报告中，使用页面顶部的筛选选项。
1. 选择一个或多个筛选器：
   - **状态**：按违规状态筛选（已检测、已驳回、审核中或已解决）。
   - **项目**：按群组中的特定项目筛选。
   - **控制**：按合规控制筛选。

报告会自动更新，仅显示与你选择的筛选器匹配的违规。

要清除筛选器，清除筛选选项或选择 **清除**。

<a id="violation-details"></a>

## 违规详情

当你为特定违规选择 **详情** 时，你可以查看：

- 违规 ID 和状态。
- 发生违规的位置（项目）。
- 全面的审计事件信息，包括：
  - 事件作者。
  - 事件目标。
  - 事件详情。
  - IP 地址。
  - 目标类型。
- 违规的控制信息，包括：
  - 控制名称和描述。
  - 关联的合规框架。
  - 要求。
- 带有解决违规链接的修复建议。
- 与违规相关的评论和讨论主题。

<a id="add-comments-to-violations"></a>

### 向违规添加评论

{{< history >}}

- 在极狐GitLab 18.7 中引入。

{{< /history >}}

你可以向违规添加评论，以便与团队协作进行修复工作：

1. 在违规详情视图中，滚动到评论部分。
1. 在文本字段中输入你的评论。
1. 选择 **评论** 发布你的评论。

你的评论会添加到违规中，并对所有有权访问合规违规报告的用户可见。

<a id="manage-violation-statuses"></a>

## 管理违规状态

你可以更新合规违规的状态，以跟踪其修复进度。可用的状态包括：

- **需要审核**：新违规的默认状态
- **进行中**：违规正在处理中
- **已解决**：违规已修复
- **已驳回**：违规已审核并驳回

要更改违规状态：

1. 在合规违规报告中，找到你要更新的违规。
1. 在 **状态** 列中选择当前状态下拉列表。
1. 从下拉列表菜单中选择新状态。

状态会立即更新，并反映在报告中。

<a id="export-compliance-violations-report"></a>

## 导出合规违规报告

{{< history >}}

- 在极狐GitLab 18.3 中引入。

{{< /history >}}

导出群组中所有项目的合规违规的 CSV 报告。导出的报告包括：

- 检测时间（日期时间，最新的在前）
- 违规 ID
- 状态
- 框架
- 合规控制
- 合规要求
- 审计事件作者
- 审计事件类型
- 审计事件名称
- 审计事件消息
- 项目 ID

报告：

- 截断为 15 MB，以免电子邮件附件过大。
- 包括所有违规，无论 Web 界面当前应用了何种筛选器。

前提条件：

- 你必须是管理员或拥有群组的安全经理或所有者角色。

要导出合规违规报告：

1. 在顶部栏，选择 **搜索或跳转到** 并找到你的群组。
1. 在左侧边栏，选择 **安全** > **合规中心**。
1. 在右上角，选择 **导出**。
1. 选择 **导出违规报告**。

报告会编译并通过电子邮件附件发送到你的邮箱。

<a id="static-compliance-violations-report"></a>

## 静态合规违规报告

> [!警告]
> 此功能在极狐GitLab 18.2 中已弃用，并计划在 18.8 中移除。

静态合规违规报告提供群组中所有项目的合并请求活动的高级视图。

当你在静态合规违规报告中选择一行时，会出现一个抽屉，其中提供：

- 项目名称和[合规框架标签](../../project/working_with_projects.md#add-a-compliance-framework-to-a-project)（如果项目已分配）。
- 引入违规的合并请求的链接。
- 合并请求的分支路径，格式为 `[源分支] into [目标分支]`。
- 向合并请求提交了更改的用户列表。
- 评论了合并请求的用户列表。
- 批准了合并请求的用户列表。
- 合并了合并请求的用户。

<a id="view-the-static-compliance-violations-report"></a>

### 查看静态合规违规报告

{{< history >}}

- 在极狐GitLab 16.0 中引入了目标分支搜索。

{{< /history >}}

前提条件：

- 你必须是管理员或拥有项目或群组的安全经理或所有者角色。

要查看静态合规违规报告：

1. 在顶部栏，选择 **搜索或跳转到** 并找到你的项目或群组。
1. 在左侧边栏，选择 **安全** > **合规中心**。

你可以按以下方式对合规报告进行排序：

- 严重级别。
- 违规类型。
- 合并请求标题。

你可以按以下方式筛选合规违规报告：

- 发现违规的项目。
- 违规的日期范围。
- 违规的目标分支。

选择一行以查看合规违规的详细信息。

<a id="severity-levels"></a>

### 严重级别

每个合规违规都有以下严重级别之一。

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
| 作者批准了合并请求     | 高           | [职责分离](#separation-of-duties) | 合并请求的作者批准了自己的合并请求。有关更多信息，请参见[防止合并请求创建者批准](../../project/merge_requests/approvals/settings.md#prevent-approval-by-merge-request-creator)。                     |
| 提交者批准了合并请求 | 高           | [职责分离](#separation-of-duties) | 合并请求的提交者批准了他们贡献的合并请求。有关更多信息，请参见[防止添加提交的用户批准](../../project/merge_requests/approvals/settings.md#prevent-approvals-by-users-who-add-commits)。 |
| 少于两个批准          | 高           | [职责分离](#separation-of-duties) | 合并请求在少于两个批准的情况下被合并。有关更多信息，请参见[合并请求批准规则](../../project/merge_requests/approvals/rules.md)。                                                                                     |

<a id="separation-of-duties"></a>

#### 职责分离

极狐GitLab 支持在创建和批准合并请求的用户之间实施职责分离策略。我们对于职责分离的标准是：

- [不允许合并请求创建者批准自己的合并请求](../../project/merge_requests/approvals/settings.md#prevent-approval-by-merge-request-creator)。
- [不允许合并请求提交者批准他们添加了提交的合并请求](../../project/merge_requests/approvals/settings.md#prevent-approvals-by-users-who-add-commits)。
- [合并合并请求所需的最少批准数量至少为两个](../../project/merge_requests/approvals/rules.md)。

<a id="export-a-report-of-merge-request-compliance-violations-on-projects-in-a-group"></a>

### 导出群组中项目的合并请求合规违规报告

{{< history >}}

- 在极狐GitLab 16.4 中引入，带有功能标志 `compliance_violation_csv_export`。默认禁用。
- 在极狐GitLab 16.5 中为 JihuLab.com 和私有化部署启用。
- 在极狐GitLab 16.9 中移除了功能标志 `compliance_violation_csv_export`。

{{< /history >}}

导出群组中项目所属合并请求的合并请求合规违规报告。报告：

- 不使用违规报告上的筛选器。
- 截断为 15 MB，以免电子邮件附件过大。

前提条件：

- 你必须是管理员或拥有群组的安全经理或所有者角色。

要导出群组中项目的合并请求合规违规报告：

1. 在顶部栏，选择 **搜索或跳转到** 并找到你的群组。
1. 在左侧边栏，选择 **安全** > **合规中心**。
1. 在右上角，选择 **导出**。
1. 选择 **导出违规报告**。

报告会编译并通过电子邮件附件发送到你的邮箱。