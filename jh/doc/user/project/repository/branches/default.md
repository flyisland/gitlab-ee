---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 使用 Git 分支开发新功能。为关键分支添加分支保护，确保只有受信任的用户才能合并到这些分支。
title: 默认分支
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

当您创建新[项目](../../_index.md)时，极狐GitLab 会在代码仓库中创建一个默认分支。默认分支具有其他分支所没有的特殊配置选项：

- 它无法被删除。
- 它[初始即受保护](protected.md)，可防止强制推送。
- 当合并请求使用[议题关闭模式](../../issues/managing_issues.md#closing-issues-automatically)关闭议题时，相关工作会合并到该分支。

[新项目](../../_index.md)默认分支的名称取决于您的极狐GitLab 管理员对实例或群组所做的配置更改。极狐GitLab 会先检查特定的自定义设置，然后在更宽泛的层级上检查，只有在未设置任何自定义设置时才使用极狐GitLab 默认值：

1. [项目特定](#change-the-default-branch-name-for-a-project)的自定义默认分支名称。
1. 在项目的直接子群组中指定的[自定义群组默认分支名称](#change-the-default-branch-name-for-new-projects-in-a-group)。
1. 在项目的顶级群组中指定的自定义群组默认分支名称。
1. 为[实例](#change-the-default-branch-name-for-new-projects-in-an-instance)设置的自定义默认分支名称。
1. 如果在任何层级都未设置自定义默认分支名称，极狐GitLab 默认使用 `main`。

在极狐GitLab UI 中，您可以在任何层级更改默认值。极狐GitLab 还提供了[您所需的 Git 命令](#update-the-default-branch-name-in-your-repository)，用于更新您的代码仓库副本。

<a id="change-the-default-branch-name-for-a-project"></a>

## 更改项目的默认分支名称

先决条件：

- 您拥有该项目的维护者或所有者角色。

要更新单个[项目](../../_index.md)的默认分支：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**设置** > **代码仓库**。
1. 展开**分支默认设定**。在**默认分支**中，选择一个新的默认分支。
1. 可选。选中**在默认分支上自动关闭引用的议题**复选框，以便在合并请求[使用关闭模式](../../issues/managing_issues.md#closing-issues-automatically)时关闭议题。
1. 选择**保存更改**。

您也可以使用[项目 API](../../../../api/projects.md)的 `default_branch` 属性。当您使用 API 创建项目并将 `initialize_with_readme` 设置为 `true` 时，可以将 `default_branch` 参数指定为以下任一项：

- 分支名称。例如，`main`。
- 完全限定的引用。例如，`refs/heads/main`。

如果您提供完全限定的引用，API 会去除 `refs/heads/` 前缀。

<a id="change-the-default-branch-name-for-new-projects-in-an-instance"></a>

## 更改实例中新项目的默认分支名称

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 私有化部署的[管理员](../../../permissions.md)可以为该实例上托管的项目自定义初始分支。各个群组和子群组可以为其项目覆盖实例默认值。

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **代码仓库**。
1. 展开**默认分支**。
1. 在**初始默认分支名称**中，选择一个新的默认分支。
1. 选择**保存更改**。

在您更改设置后，在该实例上创建的项目将使用自定义分支名称，除非群组或子群组配置覆盖了它。

<a id="change-the-default-branch-name-for-new-projects-in-a-group"></a>

## 更改群组中新项目的默认分支名称

先决条件：

- 您必须拥有该群组及其子群组的所有者角色。

要更改群组中新项目的默认分支名称：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的群组。
1. 在左侧边栏中，选择**设置** > **代码仓库**。
1. 展开**默认分支**。
1. 在**初始默认分支名称**中，选择一个新的默认分支。
1. 选择**保存更改**。

在您更改设置后，在该群组中创建的项目将使用自定义分支名称，除非子群组配置覆盖了它。

<a id="protect-initial-default-branches"></a>

## 保护初始默认分支

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

极狐GitLab 管理员和群组所有者可以定义[分支保护](protected.md)，将其应用于实例中每个代码仓库的默认分支，或应用于各个群组，可选择以下选项之一：

- **完全保护** - 默认值。开发者无法推送新提交，但维护者可以。任何人都无法强制推送。
- **初始推送后完全保护** - 开发者可以将初始提交推送到代码仓库，但之后无法推送。维护者始终可以推送。任何人都无法强制推送。
- **防止推送** - 开发者无法推送新提交，但可以接受合并到该分支的合并请求。维护者可以推送到该分支。
- **部分保护** - 开发者和维护者都可以推送新提交，但无法强制推送。
- **不受保护** - 开发者和维护者都可以推送新提交并强制推送。

> [!warning]
> 除非选择**完全保护**，否则恶意开发者可能会试图窃取您的敏感数据。例如，恶意的 `.gitlab-ci.yml` 文件可能被提交到受保护的分支，之后如果针对该分支运行流水线，就可能导致群组 CI/CD 变量被泄露。

<a id="for-all-projects-in-an-instance"></a>

### 针对实例中的所有项目

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

此设置仅适用于每个代码仓库的默认分支。要保护其他分支，您必须执行以下任一操作：

- 在代码仓库中配置[分支保护](protected.md)。
- 为群组配置[分支保护](../../../group/manage.md#change-the-default-branch-protection-of-a-group)。

极狐GitLab 私有化部署实例的管理员可以为该实例上托管的项目自定义初始默认分支保护。各个群组和子群组可以为其项目覆盖实例默认设置。

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **代码仓库**。
1. 展开**默认分支**。
1. 选择[**初始默认分支保护**](#protect-initial-default-branches)。
1. 要允许群组所有者覆盖实例的默认分支保护，请选择[**允许所有者按群组管理默认分支保护**](#prevent-overrides-of-default-branch-protection)。
1. 选择**保存更改**。

<a id="prevent-overrides-of-default-branch-protection"></a>

#### 防止覆盖默认分支保护

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

群组所有者可以按群组覆盖为整个实例设置的默认分支保护。在 [极狐GitLab 专业版或旗舰版](https://gitlab.cn/pricing)中，极狐GitLab 管理员可以禁用群组所有者的此权限，强制执行针对该实例设置的保护规则：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **代码仓库**。
1. 展开**默认分支**部分。
1. 清除**允许所有者按群组管理默认分支保护**复选框。
1. 选择**保存更改**。

> [!note]
> 极狐GitLab 管理员仍然可以更新群组的默认分支保护。

<a id="for-all-projects-in-a-group"></a>

### 针对群组中的所有项目

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

群组所有者可以按群组覆盖为整个实例设置的默认分支保护。在 [极狐GitLab 专业版或旗舰版](https://gitlab.cn/pricing)中，极狐GitLab 管理员可以[强制执行初始默认分支保护](#prevent-overrides-of-default-branch-protection)，这会锁定群组所有者的此设置。

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的群组。
1. 在左侧边栏中，选择**设置** > **代码仓库**。
1. 展开**默认分支**。
1. 选择[**初始默认分支保护**](#protect-initial-default-branches)。
1. 选择**保存更改**。

<a id="update-the-default-branch-name-in-your-repository"></a>

## 更新代码仓库中的默认分支名称

> [!warning]
> 更改默认分支的名称可能会破坏测试、CI/CD 配置、服务、辅助工具以及您的代码仓库使用的任何集成。在更改此分支名称之前，请咨询您的项目所有者和维护者。确保他们了解此更改的范围包括相关代码和脚本中对旧分支名称的引用。

当您更改现有代码仓库的默认分支名称时，不要创建新分支。通过重命名来保留默认分支的历史记录。以下示例重命名 Git 代码仓库（`example`）的默认分支：

1. 在本地命令行中，转到您的 `example` 代码仓库，并确保您位于默认分支上：

   ```plaintext
   cd example
   git checkout master
   ```

1. 将现有默认分支重命名为新名称（`main`）。参数 `-m` 会将所有提交历史转移到新分支：

   ```plaintext
   git branch -m master main
   ```

1. 将新创建的 `main` 分支推送到上游，并将您的本地分支设置为跟踪同名的远程分支：

   ```plaintext
   git push -u origin main
   ```

1. 如果您计划删除旧的默认分支，请更新 `HEAD` 使其指向您的新默认分支 `main`：

   ```plaintext
   git symbolic-ref refs/remotes/origin/HEAD refs/remotes/origin/main
   ```

1. 至少以维护者角色登录极狐GitLab，并按照说明[更改此项目的默认分支](#change-the-default-branch-name-for-a-project)。选择 `main` 作为您的新默认分支。
1. 按照[受保护分支文档](protected.md)中的说明保护您的新 `main` 分支。
1. 可选。如果您想删除旧的默认分支：
   1. 确认没有任何内容指向它。
   1. 在远程删除该分支：

      ```plaintext
      git push origin --delete master
      ```

      您可以在确认新默认分支按预期工作后，稍后再删除该分支。

1. 将此更改通知您的项目贡献者，因为他们也必须采取一些步骤：

   - 贡献者应将新的默认分支拉取到其本地代码仓库副本。
   - 拥有以旧默认分支为目标的开放合并请求的贡献者，应手动将合并请求重新指向 `main`。
1. 在您的代码仓库中，更新代码中对旧分支名称的任何引用。
1. 更新代码仓库之外的相关代码和脚本（例如辅助工具和集成）中对旧分支名称的引用。

<a id="default-branch-rename-redirect"></a>

## 默认分支重命名重定向

项目中特定文件或目录的 URL 会嵌入项目的默认分支名称，这些 URL 通常出现在文档或浏览器书签中。当您[更新代码仓库中的默认分支名称](#update-the-default-branch-name-in-your-repository)时，这些 URL 会发生变化，必须进行更新。

为了缓解过渡期的影响，每当项目的默认分支发生更改时，极狐GitLab 都会记录旧默认分支的名称。如果该分支被删除，尝试查看其上的文件或目录时会被重定向到当前默认分支，而不是显示“未找到”页面。

<a id="troubleshooting"></a>

## 故障排除

<a id="unable-to-change-default-branch-resets-to-current-branch"></a>

### 无法更改默认分支：重置为当前分支

我们在[议题 20474](https://gitlab.com/gitlab-org/gitlab/-/issues/20474)中跟踪此问题。当代码仓库中存在名为 `HEAD`的分支时，通常会出现此问题。要解决此问题：

1. 在您的本地代码仓库中，创建一个新的临时分支并推送它：

   ```shell
   git checkout -b tmp_default && git push -u origin tmp_default
   ```

1. 在极狐GitLab 中，继续[更改默认分支](#change-the-default-branch-name-for-a-project)为该临时分支。
1. 在您的本地代码仓库中，删除 `HEAD` 分支：

   ```shell
   git push -d origin HEAD
   ```

1. 在极狐GitLab 中，[更改默认分支](#change-the-default-branch-name-for-a-project)为您打算使用的分支。

<a id="query-graphql-for-default-branches"></a>

### 使用 GraphQL 查询默认分支

您可以使用 [GraphQL 查询](../../../../api/graphql/_index.md)来检索群组中所有项目的默认分支。

要将所有项目返回到单页结果中，请将 `GROUPNAME` 替换为您群组的完整路径。极狐GitLab 会返回第一页结果。如果 `hasNextPage` 为 `true`，您可以通过将 `after: null`中的 `null` 替换为 `endCursor`的值来请求下一页：

```graphql
{
 group(fullPath: "GROUPNAME") {
   projects(after: null) {
     pageInfo {
       hasNextPage
       endCursor
     }
     nodes {
       name
       repository {
         rootRef
       }
     }
   }
 }
}
```

<a id="new-subgroups-do-not-inherit-default-branch-name-from-a-higher-level-subgroup"></a>

### 新子群组不会从更高级别的子群组继承默认分支名称

当您在包含另一个子群组（该子群组又包含一个项目）的子群组中配置默认分支时，默认分支不会被继承。

我们在[议题 327208](https://gitlab.com/gitlab-org/gitlab/-/issues/327208)中跟踪此问题。
