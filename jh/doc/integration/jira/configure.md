---
stage: Plan
group: Work Items
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 将极狐GitLab 项目连接到 Jira Cloud、Data Center 或 Server 实例，以查看和管理 Jira 议题。
title: Jira 议题集成
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

Jira 议题集成可将一个或多个极狐GitLab 项目连接到一个 Jira 实例。
您可以将 Jira 实例托管在您自己的环境中，也可以托管在 [Jira Cloud](https://www.atlassian.com/migration/assess/why-cloud)中。
支持的 Jira 版本为 `6.x`、`7.x`、`8.x`、`9.x` 和 `10.x`。

<a id="configure-the-integration"></a>

## 配置集成

先决条件：

- 您的极狐GitLab 安装不得使用[相对 URL](https://gitlab.cn/docs/omnibus/settings/configuration/#configure-a-relative-url-for-gitlab)。
- **对于 Jira Cloud**：
  - 要将**基本身份验证**与经典（未限定范围的）API 令牌配合使用，您必须拥有
    [Jira Cloud API 令牌](#create-a-jira-cloud-api-token)以及创建该令牌时使用的电子邮件地址。
  - 要将**基本身份验证**与限定范围的 API 令牌配合使用，您必须为您的
    用户账号创建限定范围的令牌，并将 Jira API URL 设置为 Jira Platform API 网关
    (`https://api.atlassian.com/ex/jira/{cloudId}`)。有关更多信息，请参阅
    [管理您的 Atlassian 账号的 API 令牌](https://support.atlassian.com/atlassian-account/docs/manage-api-tokens-for-your-atlassian-account/)。
  - 要使用 **Jira Cloud 服务账号**，您必须拥有 Jira Cloud 服务账号以及该服务账号的限定范围
    API 令牌。有关更多信息，请参阅
    [管理服务账号的 API 令牌](https://support.atlassian.com/user-management/docs/manage-api-tokens-for-service-accounts/#Create-an-API-token-with-scopes)。
  - 如果您已开启
    [IP 允许名单](https://support.atlassian.com/security-and-access-policies/docs/specify-ip-addresses-for-product-access/)，请将
    [JihuLab.com IP 范围](../../user/jihulab_com/_index.md#ip-range)添加到允许名单，以便在极狐GitLab 中[查看 Jira 议题](#view-jira-issues)。
- **对于 Jira Data Center 或 Jira Server**，您必须拥有以下之一：
  - [Jira 用户名和密码](jira_server_configuration.md)。
  - Jira 个人访问令牌。

您可以通过在极狐GitLab 中配置项目设置来开启 Jira 议题集成。您还可以在极狐GitLab 私有化部署上为特定
[群组](../../user/project/integrations/_index.md#manage-group-default-settings-for-a-project-integration)或整个
[实例](../../administration/settings/project_integration_management.md#configure-default-settings-for-an-integration)
配置该集成。

通过此集成，您的极狐GitLab 项目可以与您实例上的所有 Jira 项目交互。要在极狐GitLab 中配置项目设置：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**设置** > **集成**。
1. 选择 **Jira 议题**。
1. 在**启用集成**下，选中**活跃**复选框。
1. 在**身份验证方法**下，选择以下之一：

   - **基本身份验证**：对于 Jira Cloud，使用电子邮件和 API 令牌；对于 Jira Data Center 或 Jira Server，使用用户名和
     密码。
     - **电子邮件或用户名**：
       - 对于 Jira Cloud，输入电子邮件。
       - 对于 Jira Data Center 或 Jira Server，输入用户名。
     - **API 令牌或密码**：
       - 对于 Jira Cloud，输入 API 令牌。
       - 对于 Jira Data Center 或 Jira Server，输入密码。

   - **个人访问令牌**（仅限 Jira Data Center 和 Jira Server）：输入 Jira 个人访问令牌。

   - **Jira Cloud 服务账号**（仅限 Jira Cloud）：

     - **服务账号令牌**：输入 Jira Cloud 服务账号的限定范围 API 令牌。
     - 确保该服务账号对您希望极狐GitLab 访问的 Jira 项目拥有足够的权限。
1. 提供连接详细信息：

   - **网页 URL**：您要链接到此极狐GitLab 项目的 Jira 实例 Web 界面的基础 URL
     （例如 `https://jira.example.com` 或 `https://example.atlassian.net`）。
   - **Jira API URL**：Jira 实例 API 的基础 URL。如果未设置，则使用 **网页 URL**的值。
     - 对于使用经典（未限定范围的）API 令牌的 Jira Cloud，请将此字段留空。
     - 对于使用限定范围 API 令牌（用户账号或服务账号）的 Jira Cloud，请输入 Jira
       Platform API 网关：`https://api.atlassian.com/ex/jira/{cloudId}`。
       要查找您的 Cloud ID，请参阅 [Atlassian 说明](https://support.atlassian.com/jira/kb/retrieve-my-atlassian-sites-cloud-id/)。
1. 提供触发器设置：
   - 选择**提交**、**合并请求**或两者作为触发器。
     当您在极狐GitLab 中提及 Jira 议题 ID 时，极狐GitLab 会链接到该议题。
   - 要向 Jira 议题添加链接回极狐GitLab 的评论，
     请选中**启用评论**复选框。
   - 要在极狐GitLab 中[自动转换 Jira 议题状态](../../user/project/issues/managing_issues.md#closing-issues-automatically)，
     请选中**启用 Jira 转换**复选框。
1. 在 **Jira 议题匹配**部分：
   - 对于 **Jira 议题正则表达式**，[输入正则表达式模式](issues.md#define-a-regex-pattern)。
   - 对于 **Jira 议题前缀**，[输入前缀](issues.md#define-a-prefix)。
1. 可选。要在极狐GitLab 中[查看 Jira 议题](#view-jira-issues)，
   请在 **Jira 议题**部分：
   1. 选中**查看 Jira 议题**复选框。

      > [!warning]
      > 所有有权访问您极狐GitLab 项目的用户都可以查看用于身份验证的
      > API 令牌所能访问的任何 Jira 议题。您在下方输入的 Jira 项目键
      > 用于筛选极狐GitLab 中显示的议题列表。它们不会限制
      > API 令牌的访问权限。要限制该集成可以读取的议题，请使用
      > 仅能访问您希望公开的 Jira 项目的 Jira 账号，并从该账号
      > 生成 API 令牌。

   1. 输入一个或多个要显示的 Jira 项目键。
      留空则显示 API 令牌可以访问的所有键。
1. 可选。要[为漏洞创建 Jira 议题](#create-a-jira-issue-for-a-vulnerability)，
   请在**漏洞的 Jira 议题**部分：
   1. 选中**为漏洞创建 Jira 议题**复选框。

      > [!note]
      > 您只能为单个项目和群组开启此设置。

   1. 输入 Jira 项目键。
   1. 选择**获取此项目键的议题类型** ({{< icon name="retry" >}})，
      然后选择要创建的 Jira 议题类型。
   1. 可选。选中**自定义 Jira 议题**复选框，以便在为漏洞创建 Jira 议题时
      查看、修改或添加详细信息。
1. 可选。选择**测试设置**。
1. 选择**保存更改**。

<a id="view-jira-issues"></a>

## 查看 Jira 议题

{{< details >}}

- Tier: 专业版，旗舰版

{{< /details >}}

先决条件：

- 确保 Jira 议题集成已[配置](#configure-the-integration)
  并且已选中**查看 Jira 议题**复选框。

您可以为特定群组或项目开启 Jira 议题，但只能在极狐GitLab 项目中查看这些议题。要在极狐GitLab 项目中查看来自一个或多个 Jira 项目的议题：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**计划** > **Jira 议题**。

默认情况下，议题按**创建日期**排序。最近创建的议题显示在顶部。您可以[筛选议题](#filter-jira-issues)并选择一个议题以在极狐GitLab 中查看该议题。

议题根据其
[Jira 状态](https://confluence.atlassian.com/adminjiraserver070/defining-status-field-values-749382903.html)分组到以下标签页中：

- **未关闭**：Jira 状态不是**完成**的议题。
- **已关闭**：Jira 状态为**完成**的议题。
- **全部**：具有任何 Jira 状态的议题。

<a id="filter-jira-issues"></a>

### 筛选 Jira 议题

{{< details >}}

- Tier: 专业版，旗舰版

{{< /details >}}

先决条件：

- 确保 Jira 议题集成已[配置](#configure-the-integration)
  并且已选中**查看 Jira 议题**复选框。

当您在极狐GitLab 中[查看 Jira 议题](#view-jira-issues)时，
您可以按摘要和描述中的文本筛选议题。您还可以按以下条件筛选议题：

- **标记**：在 URL 的 `labels[]` 参数中指定一个或多个 Jira 议题标记。
  当您指定多个标记时，只会显示具有所有指定标记的议题
  （例如 `/-/integrations/jira/issues?labels[]=backend&labels[]=feature&labels[]=QA`）。
- **状态**：在 URL 的 `status` 参数中指定 Jira 议题状态
  （例如 `/-/integrations/jira/issues?status=In Progress`）。
- **报告者**：在 URL 的 `author_username` 参数中指定 Jira 显示名称
  （例如 `/-/integrations/jira/issues?author_username=John Smith`）。
- **指派人**：在 URL 的 `assignee_username` 参数中指定 Jira 显示名称
  （例如 `/-/integrations/jira/issues?assignee_username=John Smith`）。
- **项目**：在 URL 的 `project` 参数中指定 Jira 项目键
  （例如 `/-/integrations/jira/issues?project=GTL`）。

<a id="jira-verification"></a>

## Jira 验证

{{< details >}}

- Tier: 专业版，旗舰版

{{< /details >}}

先决条件：

- 确保 Jira 议题集成已[配置](#configure-the-integration)
  并且已选中**查看 Jira 议题**复选框。

您可以设置验证规则，以确保提交消息中引用的 Jira 议题在允许推送之前满足特定条件。此功能有助于在极狐GitLab 和 Jira 之间保持一致的工作流。

当极狐GitLab 执行验证检查时：

- 如果提交消息包含多个 Jira 议题键，则仅使用第一个进行
  验证检查。
- 由于一个已知问题，清除**检查议题是否存在**设置并不会停止
  该检查的运行。停止该检查运行的唯一方法是清除所有 Jira 验证
  检查。

要配置 Jira 验证：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**设置** > **集成**。
1. 选择 **Jira 议题**。
1. 转到 **Jira 验证**部分。
1. 配置以下验证检查：
   - **检查议题是否存在**：验证提交消息中引用的 Jira 议题在 Jira 中存在。
   - **检查指派人**：验证提交者是否为提交消息中引用的 Jira 议题的指派人。
   - **检查议题状态**：验证提交消息中引用的 Jira 议题是否具有允许的状态之一。
   - **允许的状态**：以逗号分隔的允许的 Jira 议题状态列表（例如 `Ready, In Progress, Review`）。仅当选中**检查议题状态**时，此文本框才可用。
1. 选择**保存更改**。

当用户尝试推送不符合验证条件的更改时，极狐GitLab 会显示一条错误消息，说明推送被拒绝的原因。

<a id="example-error-messages"></a>

### 错误消息示例

- 如果引用的 Jira 议题不存在（当选中**检查议题是否存在**时）：

  ```plaintext
  Jira issue PROJECT-123 does not exist.
  ```

- 如果引用的 Jira 议题未分配给提交者（当选中**检查指派人**时）：

  ```plaintext
  Jira issue PROJECT-123 is not assigned to you. It is assigned to Jane Doe.
  ```

- 如果引用的 Jira 议题的状态不在允许列表中（当选中**检查议题状态**时）：

  ```plaintext
  Jira issue PROJECT-123 has status 'Done', which is not in the list of allowed statuses: Ready, In Progress, Review.
  ```

<a id="use-case-for-verification-checks"></a>

### 验证检查的用例

请考虑以下示例：

1. 您的团队使用的工作流要求 Jira 议题在被积极处理时处于特定状态。
1. 您配置 Jira 验证以：
   - 检查议题是否存在
   - 验证议题是否处于“In Progress”或“Review”状态
1. 开发者尝试推送提交消息为“Fix PROJECT-123 by adding validation”的更改。
1. 极狐GitLab 检查：
   - Jira 议题 PROJECT-123 是否存在
   - 该议题的状态是否为“In Progress”或“Review”
1. 如果所有检查都通过，则允许推送。如果任何检查失败，则推送会被拒绝并显示错误消息。

这可以确保您的团队遵循正确的工作流，在相应的 Jira 议题未处于正确状态时阻止推送代码更改。

<a id="create-a-jira-issue-for-a-vulnerability"></a>

## 为漏洞创建 Jira 议题

{{< details >}}

- Tier: 旗舰版

{{< /details >}}

先决条件：

- 确保 Jira 议题集成已[配置](#configure-the-integration)
  并且已选中**为漏洞创建 Jira 议题**复选框。
- 您必须拥有一个有权在目标项目中创建议题的 Jira 用户账号。

您可以从极狐GitLab 创建 Jira 议题，以跟踪为解决或缓解漏洞而采取的任何操作。要为漏洞创建 Jira 议题：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**安全** > **漏洞报告**。
1. 选择该漏洞的描述。
1. 选择**创建 Jira 议题**。

   如果选中了[**自定义 Jira 议题**](#configure-the-integration)设置，您将被重定向到 Jira 实例上的议题创建表单，其中已预填漏洞数据。您可以在创建 Jira 议题之前查看、修改或添加详细信息。

该议题会使用漏洞报告中的信息在目标 Jira 项目中创建。

要创建极狐GitLab 议题，请参阅[为漏洞创建极狐GitLab 议题](../../user/application_security/vulnerabilities/_index.md#create-a-gitlab-issue-for-a-vulnerability)。

<a id="create-a-jira-cloud-api-token"></a>

## 创建 Jira Cloud API 令牌

要为 Jira Cloud 配置 Jira 议题集成，您必须拥有 API 令牌。

<a id="for-a-user-account"></a>

### 对于用户账号

1. 从对 Jira 项目具有写入权限的账号登录 [Atlassian](https://id.atlassian.com/manage-profile/security/api-tokens)。

   该链接会打开 **API 令牌**页面。或者，从您的 Atlassian 个人资料中，
   选择**账号设置** > **安全** > **创建和管理 API 令牌**。
1. 选择**创建 API 令牌**。
1. 在对话框中，为您的令牌输入一个标签，然后选择**创建**。
1. 要复制 API 令牌，请选择**复制**。

<a id="for-a-service-account"></a>

### 对于服务账号

1. 创建或确定一个 Jira Cloud 服务账号。有关更多信息，请参阅
   [Atlassian 服务账号文档](https://support.atlassian.com/user-management/docs/understand-service-accounts/#Create-a-service-account)。
1. 为该服务账号创建限定范围的 API 令牌。有关更多信息，请参阅
   [管理服务账号的 API 令牌](https://support.atlassian.com/user-management/docs/manage-api-tokens-for-service-accounts/#Create-an-API-token-with-scopes)。
1. 确保该令牌至少具有以下经典 Jira 范围：

   - `read:jira-user`
   - `read:jira-work`
   - `write:jira-work`

<a id="migrate-from-one-jira-site-to-another"></a>

## 从一个 Jira 站点迁移到另一个

要在极狐GitLab 中从一个 Jira 站点迁移到另一个并保持您的 Jira 议题集成：

1. 按照[配置集成](#configure-the-integration)中的步骤操作。
1. 输入新的 Jira 站点 URL（例如 `https://myjirasite.atlassian.net`）。

在极狐GitLab 18.6 及更高版本中，现有的 Jira 议题引用会自动更新为使用新的 Jira 站点 URL。

在极狐GitLab 18.5 及更早版本中，您必须
[使 Markdown 缓存失效](../../administration/invalidate_markdown_cache.md#invalidate-the-cache)才能更新现有的 Jira 议题引用。
