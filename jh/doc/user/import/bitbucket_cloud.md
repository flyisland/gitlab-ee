---
stage: Create
group: Import
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 从 Bitbucket Cloud 迁移
description: "从 Bitbucket Cloud 迁移到极狐GitLab。"
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在 GitLab 16.0 中引入了要求维护者角色而非开发者角色的要求，并回溯移植到 GitLab 15.11.1 和 GitLab 15.10.5。
- 在 GitLab 16.6 中引入了从 Bitbucket Cloud 的并行导入，通过功能标志 `bitbucket_parallel_importer` 实现，默认禁用。
- 在 GitLab 16.6 中于 JihuLab.com 上启用。
- 在 GitLab 16.7 中 GA。功能标志 `bitbucket_parallel_importer` 已移除。
- 在 GitLab 17.2 中为某些导入项引入了 **已导入** 徽章。

{{< /history >}}

将你的项目从 Bitbucket Cloud 导入到极狐GitLab。

Bitbucket Cloud 导入器会从 Bitbucket Cloud 导入部分项目。

| Bitbucket Cloud 项目              | 是否导入 |
|:----------------------------------|:---------|
| 仓库描述                          | 是 |
| Git 仓库数据                      | 是 |
| 议题，包括评论                    | 是 |
| 拉取请求，包括评论                | 是 |
| 里程碑                            | 是 |
| Wiki                              | 是 |
| 标签                              | 是 |
| 里程碑                            | 是 |
| LFS 对象                          | 是 |
| 拉取请求批准                      | 否 |
| 批准规则                          | 否 |

<a id="importer-workflow"></a>

## 导入器工作流

导入 Bitbucket Cloud 项目时：

- 保留对拉取请求和议题的引用。
- 保留仓库的公开访问权限。如果仓库在 Bitbucket Cloud 中是私有的，则在极狐GitLab 中创建为私有。
- 导入的议题、合并请求和评论在极狐GitLab 中带有 **已导入** 徽章。

导入议题、拉取请求和评论时，Bitbucket Cloud 导入器：

- 使用作者/指派人的 Bitbucket 昵称，并尝试在极狐GitLab 中找到相同的 Bitbucket 身份。
- 如果不匹配或在极狐GitLab 数据库中未找到该用户，则将项目创建者（通常是启动导入过程的当前用户）设置为作者，并在议题上保留对原始 Bitbucket 作者的引用。

对于拉取请求，导入器：

- 使用源 SHA，如果仓库中不存在该 SHA，则尝试将源提交设置为合并提交 SHA。
- 将合并请求的指派人设置为作者，并将审查者设置为与极狐GitLab 中的 Bitbucket 身份匹配的用户名。
- 将极狐GitLab 中的合并请求设置为 `opened`、`closed` 或 `merged`。

对于议题，导入器：

- 添加与 Bitbucket 上的议题类型对应的标签，即 `bug`、`enhancement`、`proposal` 或 `task`。
- 如果 Bitbucket 上的议题状态为 `resolved`、`invalid`、`duplicate`、`wontfix` 或 `closed`，则在极狐GitLab 中关闭该议题。

Bitbucket Cloud 导入器会创建任何不存在的命名空间（群组）。如果命名空间已被占用，则仓库将导入到启动导入过程的用户的命名空间下。

<a id="prerequisites"></a>

## 先决条件

- 你必须启用 [Bitbucket Cloud 集成](../../integration/bitbucket.md) 或请你的极狐GitLab 管理员启用它。在 JihuLab.com 上默认启用。
- 你必须启用 [Bitbucket Cloud 导入源](../../administration/settings/import_and_export_settings.md#configure-allowed-import-sources) 或请你的极狐GitLab 管理员启用它。在 JihuLab.com 上默认启用。
- 你必须对要导入的目标群组具有维护者或所有者角色。
- Bitbucket 中的拉取请求必须具有相同的源项目和目标项目，且不能来自项目的派生。否则，拉取请求将作为空的合并请求导入。

要映射用户贡献，每个用户必须在项目导入前完成以下操作：

1. 验证 [Bitbucket 账户设置](https://bitbucket.org/account/settings/) 中的用户名是否与 [Atlassian 账户设置](https://id.atlassian.com/manage-profile/profile-and-visibility) 中的公开名称匹配。如果不匹配，请修改 Atlassian 账户设置中的公开名称，使其与 Bitbucket 账户设置中的用户名匹配。
1. 在 [极狐GitLab 个人资料服务登录](https://jihulab.com/-/profile/account) 中连接你的 Bitbucket 账户。

<a id="generate-a-bitbucket-cloud-app-password-removed"></a>

### 生成 Bitbucket Cloud 应用密码（已移除）

<!--- start_remove The following content will be removed on remove_date: '2026-08-15' -->

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

此功能在 GitLab 18.9 中已弃用，并在 GitLab 19.0 中移除。请改用 [Bitbucket Cloud API 令牌](#generate-a-bitbucket-cloud-api-token)。

<!--- end_remove -->

<a id="generate-a-bitbucket-cloud-api-token"></a>

### 生成 Bitbucket Cloud API 令牌

要使用导入 API 导入 Bitbucket Cloud 仓库，你必须创建一个 Bitbucket Cloud API 令牌。

要生成 Bitbucket Cloud API 令牌：

1. 前往 <https://id.atlassian.com/manage-profile/security/api-tokens>。
1. 选择 **创建带范围的 API 令牌**。
1. 输入令牌名称和过期日期，然后选择 **下一步**。
1. 选择 **Bitbucket**，然后选择 **下一步**。
1. 至少选择以下范围：

   - `read:repository:bitbucket`
   - `read:pullrequest:bitbucket`
   - `read:issue:bitbucket`
   - `read:wiki:bitbucket`

1. 选择 **创建令牌** 并复制令牌。

<a id="import-your-bitbucket-cloud-repositories"></a>

## 导入你的 Bitbucket Cloud 仓库

1. 在右上角，选择 **新建** ({{< icon name="plus" >}}) 和 **新建项目/仓库**。
1. 选择 **导入项目**。
1. 选择 **Bitbucket Cloud**。
1. 登录 Bitbucket，然后选择 **授权访问** 以允许极狐GitLab 访问你的 Bitbucket 账户。
1. 选择要导入的项目，或导入所有项目。你可以按名称筛选项目，并为每个项目选择导入到的命名空间。
1. 要导入项目：
   - 首次导入，选择 **导入**。
   - 后续导入，选择 **重新导入**。指定新名称，然后再次选择 **重新导入**。重新导入会创建源项目的新副本。

<a id="troubleshooting"></a>

## 故障排查

以下部分包含从 Bitbucket Cloud 导入时可能遇到的问题的可能解决方案。

<a id="import-process-used-wrong-account"></a>

### 导入过程使用了错误的账户

确保登录正确的账户。如果你不小心用错误的账户开始了导入过程，请按照以下步骤操作：

1. 撤销极狐GitLab 对你的 Bitbucket 账户的访问权限，这基本上逆转了你 [导入 Bitbucket Cloud 仓库](#import-your-bitbucket-cloud-repositories) 时的过程。
1. 退出 Bitbucket 账户，然后重新 [导入 Bitbucket Cloud 仓库](#import-your-bitbucket-cloud-repositories)。

<a id="user-mapping-fails-despite-matching-names"></a>

### 名称匹配但用户映射失败

[要使用户映射生效](mapping/post_migration_mapping.md)，Bitbucket 账户设置中的用户名必须与 Atlassian 账户设置中的公开名称匹配。

如果这些名称匹配但用户映射仍然失败，则用户可能是在 [极狐GitLab 个人资料服务登录](https://jihulab.com/-/profile/account) 中连接其 Bitbucket 账户后修改了其 Bitbucket 用户名。

要解决此问题，用户必须验证其 GitLab 数据库中的 Bitbucket 外部 UID 是否与其当前的 Bitbucket 公开名称匹配，如果不匹配则重新连接：

1. [使用 API 获取已认证用户](../../api/users.md#retrieve-the-current-user)。
1. 在 API 响应中，`identities` 属性包含存在于 GitLab 数据库中的 Bitbucket 账户。如果 `extern_uid` 与当前的 Bitbucket 公开名称不匹配，用户应在 [极狐GitLab 个人资料服务登录](https://jihulab.com/-/profile/account) 中重新连接其 Bitbucket 账户。
1. 重新连接后，用户应再次使用 API 验证其 GitLab 数据库中的 `extern_uid` 现在是否与其当前的 Bitbucket 公开名称匹配。

导入项目的用户随后必须 [删除已导入的项目](../project/working_with_projects.md#delete-a-project) 并重新导入。