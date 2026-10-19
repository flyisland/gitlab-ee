---
stage: GitLab Dedicated
group: Import
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 从 Bitbucket Cloud 迁移
description: "从 Bitbucket Cloud 迁移到极狐GitLab。"
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

将您的项目从 Bitbucket Cloud 导入到极狐GitLab。

Bitbucket Cloud 导入器会从 Bitbucket Cloud 导入部分条目。

| Bitbucket Cloud 条目              | 是否导入 |
|:----------------------------------|:---------|
| 代码仓库描述                      | {{< yes >}} |
| Git 代码仓库数据                  | {{< yes >}} |
| 议题（包括评论）                  | {{< yes >}} |
| 拉取请求（包括评论）              | {{< yes >}} |
| 里程碑                            | {{< yes >}} |
| Wiki                              | {{< yes >}} |
| 标记                              | {{< yes >}} |
| 里程碑                            | {{< yes >}} |
| LFS 对象                          | {{< yes >}} |
| Markdown 中的内嵌图片和附件       | {{< no >}} |
| 拉取请求审批                      | {{< no >}} |
| 审批规则                          | {{< no >}} |

<a id="known-issues"></a>

## 已知问题

- 议题、议题评论和拉取请求中内嵌的图片和文件附件不会复制到极狐GitLab。
  它们会保留为指向原始 Bitbucket 托管 URL 的外部链接（例如 `bitbucket.org` 或 `bbuseruploads.s3.amazonaws.com`）。
  如果源 Bitbucket 代码仓库被删除，所有内嵌图片和附件链接将永久失效。
  在删除源 Bitbucket 代码仓库之前，请确认所有内嵌图片和附件均可访问，或单独保存它们。
  导入图片和附件的支持已在[工作项 623235](https://gitlab.com/gitlab-org/gitlab/-/work_items/623235)中提出。

<a id="importer-workflow"></a>

## 导入器工作流

导入 Bitbucket Cloud 条目时：

- 对拉取请求和议题的引用会保留。
- 代码仓库的公开访问权限会保留。如果代码仓库在 Bitbucket Cloud 中是私有的，则在极狐GitLab 中也会创建为私有。
- 导入的议题、合并请求和评论在极狐GitLab 中带有 **已导入** 徽章。

导入议题、拉取请求和评论时，Bitbucket Cloud 导入器会：

- 使用作者/指派人的 Bitbucket 昵称，并尝试在极狐GitLab 中查找相同的 Bitbucket 身份。
- 如果两者不匹配，或在极狐GitLab 数据库中找不到该用户，则将项目创建者（通常是启动导入流程的当前
  用户）设为作者，并在议题上保留关于原始 Bitbucket
  作者的引用。

对于拉取请求，导入器会：

- 使用源 SHA，如果代码仓库中不存在该 SHA，则尝试将源提交设置为合并提交 SHA。
- 将合并请求指派人设为作者，并将用户名与极狐GitLab 中 Bitbucket 身份匹配的用户设为审核人。
- 将极狐GitLab 中的合并请求设置为 `opened`、`closed` 或 `merged`。

对于议题，导入器会：

- 添加一个与 Bitbucket 上议题类型对应的标记。可以是 `bug`、`enhancement`、`proposal` 或 `task`。
- 如果 Bitbucket 上的议题状态为 `resolved`、`invalid`、`duplicate`、`wontfix` 或 `closed` 之一，则在
  极狐GitLab 中关闭该议题。

如果新的命名空间（群组）不存在，Bitbucket Cloud 导入器会创建它们。如果命名空间已被占用，则代码仓库会导入到启动导入流程的用户的命名空间下。

<a id="prerequisites"></a>

## 先决条件

- 您必须启用 [Bitbucket Cloud 集成](../../integration/bitbucket.md)，或
  请极狐GitLab 管理员启用它。在 JihuLab.com 上默认启用。
- 您必须启用 [Bitbucket Cloud 导入源](../../administration/settings/import_and_export_settings.md#configure-allowed-import-sources)，
  或请极狐GitLab 管理员启用它。在 JihuLab.com 上默认启用。
- 您必须在目标群组上拥有维护者或所有者角色才能导入。
- Bitbucket 中的拉取请求必须具有相同的源项目和目标项目，且不能来自项目的 fork。
  否则，拉取请求会作为空合并请求导入。

要映射用户贡献，每个用户必须在项目导入前完成以下操作：

1. 确认 [Bitbucket 账号设置](https://bitbucket.org/account/settings/)
   中的用户名与 [Atlassian 账号设置](https://id.atlassian.com/manage-profile/profile-and-visibility)中的公开名称一致。
   如果不一致，请修改 Atlassian 账号设置中的公开名称，使其与
   Bitbucket 账号设置中的用户名一致。
1. 在[极狐GitLab 个人资料服务登录](https://gitlab.com/-/profile/account)中连接您的 Bitbucket 账号。

<a id="generate-a-bitbucket-cloud-app-password-removed"></a>

### 生成 Bitbucket Cloud 应用密码（已移除）

<!--- start_remove The following content will be removed on remove_date: '2026-08-15' -->

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

此功能已在极狐GitLab 18.9 中[弃用](https://gitlab.com/gitlab-org/gitlab/-/work_items/588961)，
并在极狐GitLab 19.0 中[移除](https://gitlab.com/gitlab-org/gitlab/-/work_items/588961)。
请改用 [Bitbucket Cloud API 令牌](#generate-a-bitbucket-cloud-api-token)。

<!--- end_remove -->

<a id="generate-a-bitbucket-cloud-api-token"></a>

### 生成 Bitbucket Cloud API 令牌

要使用导入 API 导入 Bitbucket Cloud 代码仓库，您必须创建一个 Bitbucket Cloud API 令牌。

要生成 Bitbucket Cloud API 令牌：

1. 前往 <https://id.atlassian.com/manage-profile/security/api-tokens>。
1. 选择 **创建具有作用域的 API 令牌**。
1. 输入令牌名称和到期日期，然后选择 **下一步**。
1. 选择 **Bitbucket**，然后选择 **Next**。
1. 至少选择以下范围：

   - `read:repository:bitbucket`
   - `read:pullrequest:bitbucket`
   - `read:issue:bitbucket`
   - `read:wiki:bitbucket`

1. 选择 **创建令牌** 并复制该令牌。

<a id="import-your-bitbucket-cloud-repositories"></a>

## 导入您的 Bitbucket Cloud 代码仓库

1. 在右上角，选择 **新建**（{{< icon name="plus" >}}）和 **新建项目/代码仓库**。
1. 选择 **导入项目**。
1. 选择 **Bitbucket Cloud**。
1. 登录 Bitbucket，然后选择 **授权访问**，以授予极狐GitLab 访问您 Bitbucket 账号的权限。
1. 选择您要导入的项目，或导入所有项目。您可以按名称筛选项目，并为每个项目选择
   导入到的命名空间。
1. 要导入项目：
   - 首次导入时，选择 **导入**。
   - 后续导入时，选择 **重新导入**。指定新名称并再次选择 **重新导入**。重新导入会创建
     源项目的新副本。

<a id="troubleshooting"></a>

## 故障排除

以下各节包含从 Bitbucket Cloud 导入时可能遇到的问题的可行解决方案。

<a id="import-process-used-wrong-account"></a>

### 导入流程使用了错误的账号

请务必登录正确的账号。如果您不小心使用错误的账号启动了导入流程，请按以下步骤操作：

1. 撤销极狐GitLab 对您 Bitbucket 账号的访问权限，这基本上就是反向执行
   [导入您的 Bitbucket Cloud 代码仓库](#import-your-bitbucket-cloud-repositories)时的流程。
1. 退出该 Bitbucket 账号，然后再次[导入您的 Bitbucket Cloud 代码仓库](#import-your-bitbucket-cloud-repositories)。

<a id="user-mapping-fails-despite-matching-names"></a>

### 名称匹配但用户映射失败

[要让用户映射正常工作](mapping/post_migration_mapping.md)，Bitbucket 账号设置中的用户名必须与
Atlassian 账号设置中的公开名称一致。

如果这些名称一致，但用户映射仍然失败，则该用户可能是在
[极狐GitLab 个人资料服务登录](https://gitlab.com/-/profile/account)中连接其 Bitbucket 账号后修改了 Bitbucket 用户名。

要解决此问题，用户必须确认其在极狐GitLab 数据库中的 Bitbucket 外部 UID 与其当前 Bitbucket 公开名称一致，如果不一致则重新连接：

1. [使用 API 获取已认证用户](../../api/users.md#retrieve-the-current-user)。
1. 在 API 响应中，`identities` 属性包含极狐GitLab 数据库中存在的 Bitbucket 账号。
   如果 `extern_uid` 与当前 Bitbucket 公开名称不一致，则该用户应在
   [极狐GitLab 个人资料服务登录](https://gitlab.com/-/profile/account)中重新连接其 Bitbucket 账号。
1. 重新连接后，该用户应再次使用 API 确认其在
   极狐GitLab 数据库中的 `extern_uid` 现在与其当前 Bitbucket 公开名称一致。

随后，导入该项目的用户必须[删除已导入的项目](../project/working_with_projects.md#delete-a-project)
并重新导入。
