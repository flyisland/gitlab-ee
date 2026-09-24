---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Jira 议题集成
---

{{< details >}}

- Tier: 免费版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 名称于极狐GitLab 17.6 [更新] 为 Jira 议题集成。

{{< /history >}}

Jira 议题集成将一个或多个极狐GitLab 项目连接到一个 Jira 实例。你可以自行托管 Jira 实例，或在 [Jira Cloud](https://www.atlassian.com/migration/assess/why-cloud) 中使用。支持的 Jira 版本为 `6.x`、`7.x`、`8.x`、`9.x` 和 `10.x`。

<a id="configure-the-integration"></a>

## 配置集成

{{< history >}}

- 在极狐GitLab 16.0 中，使用 Jira 个人访问令牌进行身份验证 [引入]。
- 在极狐GitLab 16.10 中，[通过一个名为 `jira_multiple_project_keys` 的功能标志](../../administration/feature_flags/_index.md) 引入了 **Jira 议题** 和 **针对漏洞的 Jira 议题** 部分。默认禁用。
- 在极狐GitLab 17.0 中，**Jira 议题** 和 **针对漏洞的 Jira 议题** 部分 [GA]。功能标志 `jira_multiple_project_keys` 已移除。
- **启用 Jira 议题** 复选框于极狐GitLab 17.0 [更名为] **查看 Jira 议题**。
- **启用从漏洞创建 Jira 议题** 复选框于极狐GitLab 17.0 [更名为] **为漏洞创建 Jira 议题**。
- **自定义 Jira 议题** 设置于极狐GitLab 17.5 [引入]。

{{< /history >}}

先决条件：

- 你的极狐GitLab 安装实例不得使用 [相对 URL](https://gitlab.cn/docs/omnibus/settings/configuration/#configure-a-relative-url-for-gitlab)。
- **对于 Jira Cloud**：
  - 你必须拥有一个 [Jira Cloud API 令牌](#create-a-jira-cloud-api-token) 和用于创建该令牌的电子邮件地址。
  - 如果你已启用 [IP 允许列表](https://support.atlassian.com/security-and-access-policies/docs/specify-ip-addresses-for-product-access/)，请将 [JihuLab.com IP 范围](../../user/jihulab_com/_index.md#ip-range) 添加到允许列表中，以便在极狐GitLab 中 [查看 Jira 议题](#view-jira-issues)。
- **对于 Jira Data Center 或 Jira Server**，你必须具备以下之一：
  - [Jira 用户名和密码](jira_server_configuration.md)。
  - Jira 个人访问令牌（极狐GitLab 16.0 及更高版本）。

你可以通过配置极狐GitLab 中的项目设置来启用 Jira 议题集成。你还可以在私有化部署的极狐GitLab 上为特定[群组](../../user/project/integrations/_index.md#manage-group-default-settings-for-a-project-integration)或整个[实例](../../administration/settings/project_integration_management.md#configure-default-settings-for-an-integration)配置该集成。

通过此集成，你的极狐GitLab 项目可以与实例上的所有 Jira 项目进行交互。
要在极狐GitLab 中配置项目设置：

1. 在顶部栏，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏，选择 **设置** > **集成**。
1. 选择 **Jira 议题**。
1. 在 **启用集成** 下，选择 **活跃** 复选框。
1. 提供连接详情：
   - **网页 URL**：你要链接到此极狐GitLab 项目的 Jira 实例 Web 界面的基本 URL（例如，`https://jira.example.com`）。
   - **Jira API URL**：Jira 实例 API 的基本 URL（例如，`https://jira-api.example.com`）。如果未设置此 URL，则默认使用 **网页 URL** 的值。对于 Jira Cloud，请将 **Jira API URL** 留空。
   - **认证方式**：
     - **基础**：
       - **电子邮件或用户名**：
         - 对于 Jira Cloud，输入电子邮件。
         - 对于 Jira Data Center 或 Jira Server，输入用户名。
       - **API 令牌或密码**：
         - 对于 Jira Cloud，输入 API 令牌。
         - 对于 Jira Data Center 或 Jira Server，输入密码。
     - **Jira 个人访问令牌**（仅适用于 Jira Data Center 和 Jira Server）：
       输入个人访问令牌。
1. 提供触发设置：
   - 选择 **提交**、**合并请求** 或两者作为触发器。当你在极狐GitLab 中提到 Jira 议题 ID 时，极狐GitLab 会链接到该议题。
   - 若要向 Jira 议题添加指回极狐GitLab 的评论，请选择 **启用评论** 复选框。
   - 若要 [在极狐GitLab 中自动转换 Jira 议题](../../user/project/issues/managing_issues.md#closing-issues-automatically) 的状态，请选择 **启用 Jira 状态转换** 复选框。
1. 在 **Jira 议题匹配** 部分：
   - 对于 **Jira 议题正则表达式**，[输入一个正则表达式模式](issues.md#define-a-regex-pattern)。
   - 对于 **Jira 议题前缀**，[输入一个前缀](issues.md#define-a-prefix)。
1. 可选。若要在极狐GitLab 中 [查看 Jira 议题](#view-jira-issues)，请在 **Jira 议题** 部分：
   1. 选择 **查看 Jira 议题** 复选框。

      {{< alert type="warning" >}}

      当你启用此设置时，所有有权访问你的极狐GitLab 项目的用户都可以查看你指定的 Jira 项目中的所有议题。

      {{< /alert >}}

   1. 输入一个或多个 Jira 项目密钥。留空则包含所有可用的密钥。
1. 可选。若要 [为漏洞创建 Jira 议题](#create-a-jira-issue-for-a-vulnerability)，请在 **针对漏洞的 Jira 议题** 部分：
   1. 选择 **为漏洞创建 Jira 议题** 复选框。

      {{< alert type="note" >}}

      你只能为单个项目和群组启用此设置。

      {{< /alert >}}

   1. 输入一个 Jira 项目密钥。
   1. 选择 **获取此项目密钥的议题类型**（{{< icon name="retry" >}}），然后选择要创建的 Jira 议题的类型。
   1. 可选。选择 **自定义 Jira 议题** 复选框，以便在为漏洞创建 Jira 议题时能够检查、修改或添加详细信息。
1. 可选。选择 **测试设置**。
1. 选择 **保存更改**。

<a id="view-jira-issues"></a>

## 查看 Jira 议题

{{< details >}}

- Tier: 专业版，旗舰版

{{< /details >}}

{{< history >}}

- 在极狐GitLab 16.9 中，为群组启用 Jira 议题 [引入]。
- 在极狐GitLab 16.10 中，[通过一个名为 `jira_multiple_project_keys` 的功能标志](../../administration/feature_flags/_index.md) 引入了查看多个 Jira 项目的议题的功能。默认禁用。
- 在极狐GitLab 17.0 中，查看多个 Jira 项目的议题 [GA]。功能标志 `jira_multiple_project_keys` 已移除。

{{< /history >}}

先决条件：

- 确保 Jira 议题集成已 [配置](#configure-the-integration)，并且 **查看 Jira 议题** 复选框已勾选。

你可以为特定群组或项目启用 Jira 议题，但只能在极狐GitLab 项目中查看这些议题。
要在极狐GitLab 项目中查看来自一个或多个 Jira 项目的议题：

1. 在顶部栏，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏，选择 **计划** > **Jira 议题**。

默认情况下，议题按 **创建日期** 排序，最新创建的议题显示在顶部。
你可以 [过滤 Jira 议题](#filter-jira-issues) 并选择一个议题以在极狐GitLab 中查看。

议题根据其 [Jira 状态](https://confluence.atlassian.com/adminjiraserver070/defining-status-field-values-749382903.html) 分组到以下选项卡中：

- **开放**：状态不为 **已完成** 的所有 Jira 议题。
- **已关闭**：状态为 **已完成** 的 Jira 议题。
- **全部**：所有状态的 Jira 议题。

<a id="filter-jira-issues"></a>

### 过滤 Jira 议题

{{< details >}}

- Tier: 专业版，旗舰版

{{< /details >}}

{{< history >}}

- 在极狐GitLab 16.10 中，[通过一个名为 `jira_multiple_project_keys` 的功能标志](../../administration/feature_flags/_index.md) 引入了按项目过滤 Jira 议题的功能。默认禁用。
- 在极狐GitLab 17.0 中，按项目过滤 Jira 议题 [GA]。功能标志 `jira_multiple_project_keys` 已移除。

{{< /history >}}

先决条件：

- 确保 Jira 议题集成已 [配置](#configure-the-integration)，并且 **查看 Jira 议题** 复选框已勾选。

当你在极狐GitLab 中 [查看 Jira 议题](#view-jira-issues) 时，你可以根据摘要和描述中的文本过滤议题。你还可以按以下条件过滤议题：

- **标签**：在 URL 的 `labels[]` 参数中指定一个或多个 Jira 议题标签。当指定多个标签时，只有同时具有所有指定标签的议题才会显示（例如，`/-/integrations/jira/issues?labels[]=backend&labels[]=feature&labels[]=QA`）。
- **状态**：在 URL 的 `status` 参数中指定 Jira 议题状态（例如，`/-/integrations/jira/issues?status=In Progress`）。
- **报告者**：在 URL 的 `author_username` 参数中指定 Jira 显示名称（例如，`/-/integrations/jira/issues?author_username=John Smith`）。
- **指派人**：在 URL 的 `assignee_username` 参数中指定 Jira 显示名称（例如，`/-/integrations/jira/issues?assignee_username=John Smith`）。
- **项目**：在 URL 的 `project` 参数中指定 Jira 项目密钥（例如，`/-/integrations/jira/issues?project=GTL`）。

<a id="jira-verification"></a>

## Jira 验证

{{< details >}}

- Tier: 专业版，旗舰版

{{< /details >}}

{{< history >}}

- 于极狐GitLab 18.3 [引入]。

{{< /history >}}

先决条件：

- 确保 Jira 议题集成已 [配置](#configure-the-integration)，并且 **查看 Jira 议题** 复选框已勾选。

你可以设置验证规则，以确保提交消息中引用的 Jira 议题在允许推送前满足特定条件。此功能有助于保持极狐GitLab 与 Jira 之间工作流的一致性。

要配置 Jira 验证：

1. 在顶部栏，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏，选择 **设置** > **集成**。
1. 选择 **Jira 议题**。
1. 前往 **Jira 验证** 部分。
1. 配置以下验证检查：
   - **检查议题是否存在**：验证提交消息中引用的 Jira 议题是否存在于 Jira 中。
   - **检查指派人**：验证提交者是否为提交消息中引用的 Jira 议题的指派人。
   - **检查议题状态**：验证提交消息中引用的 Jira 议题是否具有允许的状态之一。
   - **允许的状态**：以逗号分隔的允许的 Jira 议题状态列表（例如，`Ready, In Progress, Review`）。此字段仅在启用 **检查议题状态** 时可用。
1. 选择 **保存更改**。

当用户尝试推送不符合验证条件的更改时，极狐GitLab 会显示一条错误消息，说明推送被拒绝的原因。

{{< alert type="note" >}}

如果提交消息包含多个 Jira 议题密钥，则仅使用第一个密钥进行验证检查。

{{< /alert >}}

<a id="example-error-messages"></a>

### 示例错误消息

- 如果引用的 Jira 议题不存在（当启用 **检查议题是否存在** 时）：

  ```plaintext
  Jira 议题 PROJECT-123 不存在。
  ```

- 如果引用的 Jira 议题未指派给提交者（当启用 **检查指派人** 时）：

  ```plaintext
  Jira 议题 PROJECT-123 未指派给你。它指派的给 Jane Doe。
  ```

- 如果引用的 Jira 议题的状态不在允许列表中（当启用 **检查议题状态** 时）：

  ```plaintext
  Jira 议题 PROJECT-123 的状态为 'Done'，该状态不在允许的状态列表中：Ready、In Progress、Review。
  ```

<a id="use-case-for-verification-checks"></a>

### 验证检查用例

考虑以下示例：

1. 你的团队使用一种工作流，其中当积极处理 Jira 议题时，议题应处于特定状态。
1. 你配置 Jira 验证以：
   - 检查议题是否存在
   - 验证议题是否处于“In Progress”或“Review”状态
1. 开发人员尝试使用提交消息“Fix PROJECT-123 by adding validation”推送更改。
1. 极狐GitLab 检查：
   - Jira 议题 PROJECT-123 是否存在
   - 该议题的状态是否为“In Progress”或“Review”
1. 如果所有检查通过，则允许推送。如果任何检查失败，则推送被拒绝，并显示错误消息。

这确保你的团队遵循正确的工作流，防止在相应 Jira 议题未处于正确状态时推送代码更改。

<a id="create-a-jira-issue-for-a-vulnerability"></a>

## 为漏洞创建 Jira 议题

{{< details >}}

- Tier: 旗舰版

{{< /details >}}

先决条件：

- 确保 Jira 议题集成已 [配置](#configure-the-integration)，并且 **为漏洞创建 Jira 议题** 复选框已勾选。
- 你必须拥有一个有权在目标项目中创建议题的 Jira 用户账户。

你可以从极狐GitLab 创建一个 Jira 议题，以追踪任何为解决或缓解漏洞而采取的行动。
要为漏洞创建 Jira 议题：

1. 在顶部栏，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏，选择 **安全** > **漏洞报告**。
1. 选择漏洞的描述。
1. 选择 **创建 Jira 议题**。

   如果已选择 [**自定义 Jira 议题**](#configure-the-integration) 设置，你将被重定向到 Jira 实例上的议题创建表单，其中的漏洞数据已预填。你可以在创建 Jira 议题之前检查、修改或添加详细信息。

该议题将在目标 Jira 项目中创建，并包含漏洞报告中的信息。

要创建极狐GitLab 议题，请参阅 [为漏洞创建一个极狐GitLab 议题](../../user/application_security/vulnerabilities/_index.md#create-a-gitlab-issue-for-a-vulnerability)。

<a id="create-a-jira-cloud-api-token"></a>

## 创建 Jira Cloud API 令牌

要配置用于 Jira Cloud 的 Jira 议题集成，你必须拥有一个 Jira Cloud API 令牌。
要创建 Jira Cloud API 令牌：

1. 从具有 Jira 项目写入权限的账户登录 [Atlassian](https://id.atlassian.com/manage-profile/security/api-tokens)。

   该链接将打开 **API 令牌** 页面。或者，从你的 Atlassian 个人资料中，选择 **账户设置** > **安全** > **创建和管理 API 令牌**。
1. 选择 **创建 API 令牌**。
1. 在对话框中，为你的令牌输入标签，然后选择 **创建**。

要复制 API 令牌，请选择 **复制**。

<a id="migrate-from-one-jira-site-to-another"></a>

## 从一个 Jira 站点迁移到另一个站点

{{< history >}}

- 集成名称于极狐GitLab 17.6 [更新] 为 **Jira 议题**。

{{< /history >}}

要在极狐GitLab 中从一个 Jira 站点迁移到另一个站点并维护你的 Jira 议题集成：

1. 遵循 [配置集成](#configure-the-integration) 中的步骤。
1. 输入新的 Jira 站点 URL（例如，`https://myjirasite.atlassian.net`）。

在极狐GitLab 18.6 及更高版本中，现有的 Jira 议题引用会自动更新为使用新的 Jira 站点 URL。

在极狐GitLab 18.5 及更早版本中，你必须 [使 Markdown 缓存失效](../../administration/invalidate_markdown_cache.md#invalidate-the-cache) 来更新现有的 Jira 议题引用。