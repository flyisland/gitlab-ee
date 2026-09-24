---
stage: Create
group: Code Review
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 如何在极狐GitLab 中创建合并请求。
title: 创建合并请求
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

准备好创建合并请求时，您可以根据自己的工作流选择合适的方法。您可以通过以下方式创建合并请求：

- 在 极狐GitLab UI 中。
- 在命令行中，使用 [`glab mr`](https://jihulab.com/gitlab-cn/cli/-/tree/main/docs/source/mr) 命令，或结合 [推送选项](../../../topics/git/commit.md#push-options) 的 Git 命令。
- 通过发送邮件。
- 使用[合并请求 API](../../../api/merge_requests.md)。

创建合并请求时，极狐GitLab 会强制执行项目的分支命名规则。
要将合并请求连接到分支，请遵循[分支命名模式](../repository/branches/_index.md#name-your-branch)。

合并请求标题支持[有限的格式](../../markdown.md#work-item-and-merge-request-titles)。

<a id="from-the-top-bar"></a>

## 从顶部栏

您可以从项目的顶部栏创建合并请求：

1. 在顶部栏上，选择 **搜索或跳转到** 并找到您的项目。
1. 在右上角，选择 **新建** ({{< icon name="plus" >}}) 和 **新合并请求**。

<a id="from-the-merge-request-list"></a>

## 从合并请求列表

您可以从合并请求列表创建合并请求。

1. 在顶部栏上，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **代码** > **合并请求**。
1. 在右上角，选择 **新合并请求**。
1. 选择源分支和目标分支，然后选择 **比较分支并继续**。
1. 填写 **新合并请求** 页面上的字段，然后选择 **创建合并请求**。

每个分支只能关联一个打开的合并请求。如果该分支已存在合并请求，则会显示指向现有合并请求的链接。

<a id="from-an-issue"></a>

## 从议题

如果您的工作流要求每个合并请求都必须有一个议题，您可以直接从议题创建分支，以加快流程。
新分支及其后续的合并请求都会标记为与该议题相关。
合并请求合并后，议题会自动关闭，除非
[自动关闭议题功能被禁用](../issues/managing_issues.md#disable-automatic-issue-closing)。

<a id="new-branch-from-an-issue"></a>

### 从议题新建分支

要同时创建分支和合并请求：

1. 在顶部栏上，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **计划** > **工作项**，然后按 **类型** = **议题** 筛选并选择您的议题。
1. 转到议题描述的底部。
1. 选择 **创建合并请求** > **创建合并请求和分支**。
1. 在对话框中，查看建议的分支名称。它基于您项目的
   [分支名称模板](../repository/branches/_index.md)。
1. 可选。如果分支名称已被占用，或者您需要不同的分支名称，请重命名。
1. 选择源分支或标签。
1. 选择 **创建合并请求**。

<a id="existing-branch-from-an-issue"></a>

### 从议题使用现有分支

{{< history >}}

- Introduced in 极狐GitLab 17.11。

{{< /history >}}

先决条件：

- 分支必须已链接到该议题。
- 您必须拥有在项目中创建合并请求的权限。

当分支已在开发部分链接时，创建合并请求：

1. 在顶部栏上，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **计划** > **工作项**，然后按 **类型** = **议题** 筛选并选择您的议题。
1. 在 **开发** 部分，找到已链接的分支。
1. 选择分支操作菜单 ({{< icon name="ellipsis_v" >}})。
1. 选择 **创建合并请求**。
1. 填写 **新合并请求** 页面上的字段，然后选择 **创建合并请求**。

合并请求表单会预填适当的关键词，将其链接回议题。

<a id="from-a-task"></a>

## 从任务

{{< history >}}

- Introduced in 极狐GitLab 17.8。

{{< /history >}}

如果您的团队将议题拆分为任务，您可以直接从任务创建分支，以加快流程。
新分支及其后续的合并请求都会标记为与该任务相关。
合并请求合并后，任务会自动关闭，除非
[自动关闭议题功能被禁用](../issues/managing_issues.md#disable-automatic-issue-closing)。

<a id="new-branch-from-a-task"></a>

### 从任务新建分支

先决条件：

- 您必须对包含该任务的项目具有开发者、维护者或所有者角色。

要同时创建分支和合并请求：

1. 在顶部栏上，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **计划** > **工作项**，然后按 **类型** = **任务** 筛选并选择您的任务。
1. 转到任务描述的底部。
1. 选择 **创建合并请求**。
1. 在对话框中，查看建议的分支名称。
   它基于您项目的[分支名称模板](../repository/branches/_index.md)。
1. 可选。如果分支名称已被占用，或者您需要不同的分支名称，请重命名。
1. 选择源分支或标签。
1. 选择 **创建合并请求**。

<a id="existing-branch-from-a-task"></a>

### 从任务使用现有分支

{{< history >}}

- Introduced in 极狐GitLab 17.11。

{{< /history >}}

先决条件：

- 分支必须已链接到该任务。
- 您必须拥有在项目中创建合并请求的权限。

当分支已在开发部分链接时，创建合并请求：

1. 在顶部栏上，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **计划** > **工作项**，然后按 **类型** = **任务** 筛选并选择您的任务。
1. 在 **开发** 部分，找到已链接的分支。
1. 选择分支操作菜单 ({{< icon name="ellipsis_v" >}})。
1. 选择 **创建合并请求**。
1. 填写 **新合并请求** 页面上的字段，然后选择 **创建合并请求**。

合并请求表单会预填适当的关键词，将其链接回任务。

<a id="when-your-git-repository-is-empty"></a>

## 当 Git 仓库为空时

如果您从议题或任务创建合并请求时 Git 仓库为空，极狐GitLab 会：

- 创建默认分支。
- 向其中提交一个空白 `README.md` 文件。
- 创建一个新分支并重定向您到该分支，分支名基于议题或任务标题。
- 如果您的项目配置了像 Kubernetes 这样的部署服务，
  会提示您设置[自动部署](../../../topics/autodevops/stages.md#auto-deploy)，
  并帮助您创建 `.gitlab-ci.yml` 文件。

<a id="automatic-issue-and-task-closing"></a>

## 自动关闭议题和任务

如果您创建的分支名称
[以议题或任务编号为前缀](../repository/branches/_index.md#prefix-branch-names-with-a-number)，
极狐GitLab 会交叉链接议题或任务与合并请求，并在合并请求的描述中添加
[关闭模式](../issues/managing_issues.md#closing-issues-automatically)。
在大多数情况下，这看起来像 `Closes #ID`，其中 `ID` 是议题或任务的 ID。如果您的项目配置了
关闭模式，当合并请求合并时，议题或任务会关闭。

> [!note]
> 使用关闭模式（如 `Closes #123`）链接或使用关键词（如 `Related to #456`）提及的工作项会自动出现在
> 合并请求侧边栏的 **工作项** 小部件中。更多信息，请参见
> [合并请求中的工作项](../../work_items/_index.md#work-items-in-merge-requests)。

<a id="from-the-web-editor"></a>

## 从 Web 编辑器

在执行以下操作时，您可以使用 [Web 编辑器](../repository/web_editor.md) 创建合并请求：

- 创建、编辑、上传或删除文件。
- 创建目录。

<a id="when-you-create-a-branch"></a>

## 当您创建分支时

您可以在创建分支时创建合并请求。

1. 在顶部栏上，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **代码** > **分支**。
1. 输入分支名称并选择 **新分支**。
1. 在文件列表上方，选择 **创建合并请求**。
   一个合并请求被创建。默认分支作为目标。
1. 填写字段并选择 **创建合并请求**。

<a id="when-you-work-in-a-fork"></a>

## 当您在 Fork 中工作时

您可以从您的 Fork 创建一个合并请求，以向主项目做贡献。

1. 在顶部栏上，选择 **搜索或跳转到** 并找到您的 Fork。
1. 在左侧边栏中，选择 **代码** > **合并请求**，然后选择 **新合并请求**。
1. 对于 **源分支**，选择您的 Fork 中包含您更改的分支。
1. 对于 **目标分支**：

   1. 选择上游仓库，而不是您的 Fork。
      如果您经常向上游贡献更改，请考虑为您的 Fork 设置默认目标。
   1. 从上游仓库中选择一个分支：

      ![用于在上游仓库中选择目标分支的下拉列表](img/forking_workflow_branch_select_v15_9.png)

   > [!note]
   > 如果您的 Fork 的可见性比父仓库更受限制，则目标分支
   > 默认为您 Fork 的默认分支。这可以防止潜在泄露您 Fork 中的私有信息。

1. 选择 **比较分支并继续**。
1. 选择 **创建合并请求**。合并请求在目标仓库中创建，
   而不是在您的 Fork 中。
1. 如果您被分配了开发者、维护者或所有者角色，添加所需的指派人、审核人、标签
   和里程碑。
1. 选择 **提交合并请求**。

如果合并请求以另一个仓库为目标，它将使用：

- 目标项目的审批规则。
- 您 Fork 的 CI/CD 配置、资源和项目 CI/CD 变量。

要在上游项目中运行 CI/CD 流水线，
[您必须是该项目的成员](../../../ci/pipelines/merge_request_pipelines.md#use-with-forked-projects)。
如果您为来自 Fork 的合并请求在父项目中运行合并请求流水线，
所有变量对该流水线可用。

在您的工作合并后，如果您不打算再做贡献，请[取消链接您的 Fork](../repository/forking_workflow.md#unlink-a-fork)。

<a id="set-the-default-target-project"></a>

### 设置默认目标项目

默认情况下，从 Fork 发起的合并请求以上游仓库为目标，而非您的 Fork。
您可以将 Fork 仓库配置为默认目标，而不是上游仓库。

先决条件：

- 您正在一个 Fork 中工作。
- 您必须具有开发者、维护者或所有者角色，或被允许在项目中创建合并请求。
- 上游仓库允许创建合并请求。
- Fork 的[可见性设置](../../public_access.md#change-project-visibility) 必须匹配或比上游仓库更宽松。例如：
  如果您的 Fork 是私有的，但上游是公开的，则不显示此设置。

要执行此操作：

1. 在顶部栏上，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **合并请求**。
1. 在 **目标项目** 部分，选择您要用于默认目标项目的选项。
1. 选择 **保存更改**。

<a id="by-sending-an-email"></a>

## 通过发送邮件

{{< history >}}

- **Email a new merge request to this project** 在 极狐GitLab 18.6 中被重命名为 **Email merge request to this project**。

{{< /history >}}

您可以通过向 极狐GitLab 发送邮件来创建合并请求。
合并请求的目标分支是仓库的默认分支。

先决条件：

- 合并请求必须以当前仓库为目标，而不是上游仓库。
- 极狐GitLab 管理员必须配置[接收邮件](../../../administration/incoming_email.md)。
  此设置已在 JihuLab.com 上启用。
- 极狐GitLab 管理员必须配置[通过邮件回复](../../../administration/reply_by_email.md)。
  此设置已在 JihuLab.com 上启用。
- 您必须具有开发者、维护者或所有者角色，或被允许在项目中创建合并请求。

要通过发送邮件创建合并请求：

1. 在顶部栏上，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **代码** > **合并请求**。
1. 如果项目包含任何合并请求，选择 **Email merge request to this project**。
1. 在对话框中，复制显示的电子邮件地址。请勿分享此地址。任何拥有此地址的人
   都可以以您的名义创建议题或合并请求。
1. 打开邮件并撰写包含以下信息的邮件：

   - **收件人** 行填写您复制的电子邮件地址。
   - **主题** 填写源分支名称。
   - 邮件正文填写合并请求描述。

1. 要添加提交，请将 `.patch` 文件附加到邮件中。
1. 发送邮件。

合并请求将被创建。

<a id="add-attachments-when-creating-a-merge-request-by-email"></a>

### 通过邮件创建合并请求时添加附件

通过在邮件中添加补丁作为附件，可以将提交添加到合并请求中。

- 补丁的总大小必须为 2 MB 或更小。
- 附件文件名必须以 `.patch` 结尾才会被视为补丁。
- 补丁按名称顺序处理。
- 如果主题中的源分支不存在，则会从仓库的 `HEAD` 或默认目标分支创建它。
  要手动更改目标分支，请使用
  `/target_branch` 快速操作。
- 如果源分支已存在，则补丁会应用到其顶端。

<a id="troubleshooting"></a>

## 故障排除

<a id="no-option-to-create-a-merge-request-on-an-issue"></a>

### 议题上没有创建合并请求的选项

如果出现以下情况，议题上不会显示 **创建合并请求** 选项：

- 已存在同名的分支。
- 该分支已存在合并请求。
- 您的项目存在活跃的 Fork 关系。
- 您的项目是私有的，并且议题是机密的。

要使此按钮出现，一种可能的解决方法是
[移除项目的 Fork 关系](../repository/forking_workflow.md#unlink-a-fork)。
移除后，您无法恢复 Fork 关系。您的项目将无法
再向源项目或其其他 Fork 发送或接收合并请求。

<a id="email-message-could-not-be-processed"></a>

### 无法处理邮件消息

在发送邮件创建合并请求时，如果您尝试以上游仓库为目标，极狐GitLab 会返回以下错误：

```plaintext
很遗憾，您发送给 极狐GitLab 的邮件无法被处理。

您无权执行此操作。如果您认为这是一个错误，请联系工作人员。
```