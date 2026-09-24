---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.jihulab.com/handbook/product/ux/technical-writing/#assignments>
description: Use Git branches to develop new features. Add branch protections to critical branches to ensure only trusted users can merge into them.
title: 默认分支
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

当您创建新 [项目](../../_index.md) 时，极狐GitLab 会在代码仓中创建一个默认分支。默认分支具有其他分支不具备的特殊配置选项：

- 不可删除。
- 它[初始受保护](protected.md)，防止强制推送。
- 当合并请求使用
  [议题关闭模式](../../issues/managing_issues.md#closing-issues-automatically)
  关闭议题时，工作将合并到此分支。

新 [项目](../../_index.md) 默认分支的名称取决于极狐GitLab 管理员对实例或群组所做的任何配置更改。
极狐GitLab 首先检查特定自定义设置，然后检查更广的级别，仅在没有自定义设置时使用极狐GitLab 默认值：

1. [项目特定的](#change-the-default-branch-name-for-a-project) 自定义默认分支名称。
1. 在项目的直接子群组中指定的 [自定义群组默认分支名称](#change-the-default-branch-name-for-new-projects-in-a-group)。
1. 在项目的顶级群组中指定的自定义群组默认分支名称。
1. 为 [实例](#change-the-default-branch-name-for-new-projects-in-an-instance) 设置的自定义默认分支名称。
1. 如果任何级别都未设置自定义默认分支名称，极狐GitLab 默认为 `main`。

在极狐GitLab UI 中，您可以更改任何级别的默认值。极狐GitLab 还提供您需要的 [Git 命令](#update-the-default-branch-name-in-your-repository) 来更新仓库副本。

<a id="change-the-default-branch-name-for-a-project"></a>

## 更改项目的默认分支名称

先决条件：

- 您具有项目的所有者或维护者角色。

要更新单个 [项目](../../_index.md) 的默认分支：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **代码仓**。
1. 展开 **分支默认设定**。为 **默认分支** 选择新的默认分支。
1. 可选。勾选 **自动关闭默认分支上引用的议题** 复选框，以在合并请求
    [使用关闭模式](../../issues/managing_issues.md#closing-issues-automatically) 时关闭议题。
1. 选择 **保存更改**。

您也可以使用 [projects API](../../../../api/projects.md) 的 `default_branch` 属性。
当您通过 API 创建项目并将 `initialize_with_readme` 设置为 `true` 时，
您可以指定 `default_branch` 参数为：

- 分支名称。例如，`main`。
- 完全限定引用。例如，`refs/heads/main`。

如果您提供完全限定引用，API 会去除 `refs/heads/` 前缀。

<a id="change-the-default-branch-name-for-new-projects-in-an-instance"></a>

## 更改实例中新项目的默认分支名称

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 私有化部署实例的 [管理员](../../../permissions.md) 可以为托管在该实例上的项目自定义初始分支。单个群组和子群组可以为其项目覆盖实例默认值。

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **代码仓**。
1. 展开 **默认分支**。
1. 为 **初始默认分支名称** 选择新的默认分支。
1. 选择 **保存更改**。

更改设置后，除非群组或子群组配置覆盖，否则在此实例上创建的项目将使用自定义分支名称。

<a id="change-the-default-branch-name-for-new-projects-in-a-group"></a>

## 更改群组中新项目的默认分支名称

先决条件：

- 您必须具有群组和子群组的所有者角色。

要更改群组中新项目的默认分支名称：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **设置** > **代码仓**。
1. 展开 **默认分支**。
1. 为 **初始默认分支名称** 选择新的默认分支。
1. 选择 **保存更改**。

更改设置后，除非子群组配置覆盖，否则在此群组中创建的项目将使用自定义分支名称。

<a id="protect-initial-default-branches"></a>

## 保护初始默认分支

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 16.0 中引入初始推送后全面保护。

{{< /history >}}

极狐GitLab 管理员和群组所有者可以定义 [分支保护](protected.md)，以适用于实例或各个群组中每个仓库的默认分支，选项如下：

- **全面保护** - 默认值。开发者不能推送新提交，但维护者可以。任何人不能强制推送。
- **初始推送后全面保护** - 开发者可以推送初始提交到仓库，但之后不能。维护者始终可以推送。任何人不能强制推送。
- **防止推送** - 开发者不能推送新提交，但允许接受向该分支的合并请求。维护者可以推送到该分支。
- **部分保护** - 开发者和维护者都可以推送新提交，但不能强制推送。
- **不保护** - 开发者和维护者都可以推送新提交和强制推送。

> [!warning]
> 除非选择了 **全面保护**，否则恶意开发者可能会试图窃取您的敏感数据。例如，恶意的 `.gitlab-ci.yml` 文件可能被提交到受保护的分支，随后如果针对该分支运行流水线，可能导致群组 CI/CD 变量泄露。

<a id="for-all-projects-in-an-instance"></a>

### 对实例中的所有项目

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

此设置仅适用于每个仓库的默认分支。要保护其他分支，您必须：

- 在仓库中配置 [分支保护](protected.md)。
- 为群组配置 [分支保护](../../../group/manage.md#change-the-default-branch-protection-of-a-group)。

极狐GitLab 私有化部署实例的管理员可以为托管在该实例上的项目自定义初始默认分支保护。单个群组和子群组可以为其项目覆盖实例默认设置。

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **代码仓**。
1. 展开 **默认分支**。
1. 选择 [**初始默认分支保护**](#protect-initial-default-branches)。
1. 要允许群组所有者覆盖实例的默认分支保护，请选择
   [**允许所有者按群组管理默认分支保护**](#prevent-overrides-of-default-branch-protection)。
1. 选择 **保存更改**。

<a id="prevent-overrides-of-default-branch-protection"></a>

#### 防止覆盖默认分支保护

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

群组所有者可以在每个群组基础上覆盖为整个实例设置的默认分支保护。在
[极狐GitLab 专业版或旗舰版](https://gitlab.cn/pricing/) 中，极狐GitLab 管理员可以
禁用群组所有者的此权限，强制执行为实例设置的保护规则：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **代码仓**。
1. 展开 **默认分支** 部分。
1. 取消选中 **允许所有者按群组管理默认分支保护** 复选框。
1. 选择 **保存更改**。

> [!note]
> 极狐GitLab 管理员仍可更新群组的默认分支保护。

<a id="for-all-projects-in-a-group"></a>

### 对群组中的所有项目

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

群组所有者可以在每个群组基础上覆盖为整个实例设置的默认分支保护。在
[极狐GitLab 专业版或旗舰版](https://gitlab.cn/pricing/) 中，极狐GitLab 管理员可以
[强制初始默认分支的保护](#prevent-overrides-of-default-branch-protection)，
从而为群组所有者锁定此设置。

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **设置** > **代码仓**。
1. 展开 **默认分支**。
1. 选择 [**初始默认分支保护**](#protect-initial-default-branches)。
1. 选择 **保存更改**。

<a id="update-the-default-branch-name-in-your-repository"></a>

## 更新仓库中的默认分支名称

> [!warning]
> 更改默认分支的名称可能会破坏测试、
> CI/CD 配置、服务、辅助工具以及仓库使用的任何集成。更改此分支名称之前，请咨询您的项目所有者和维护者。
> 确保他们了解此更改的范围包括相关代码和脚本中对旧分支名称的引用。

当您更改现有仓库的默认分支名称时，不要创建新分支。
通过重命名来保留默认分支的历史记录。此示例重命名一个 Git 仓库
(`example`) 的默认分支：

1. 在本地命令行中，转到 `example` 仓库，并确保您位于默认分支上：

   ```plaintext
   cd example
   git checkout master
   ```

1. 将现有默认分支重命名为新名称 (`main`)。参数 `-m`
   将所有提交历史记录转移到新分支：

   ```plaintext
   git branch -m master main
   ```

1. 将新创建的 `main` 分支推送到上游，并设置本地分支追踪
   同名的远程分支：

   ```plaintext
   git push -u origin main
   ```

1. 如果您计划删除旧的默认分支，请更新 `HEAD` 指向新的默认分支 `main`：

   ```plaintext
   git symbolic-ref refs/remotes/origin/HEAD refs/remotes/origin/main
   ```

1. 以至少维护者角色登录极狐GitLab，并按照说明
   [更改此项目的默认分支](#change-the-default-branch-name-for-a-project)。
   选择 `main` 作为新的默认分支。
1. 按照 [受保护分支文档](protected.md) 中所述保护新的 `main` 分支。
1. 可选。如果要删除旧的默认分支：
   1. 验证没有任何东西指向它。
   1. 在远程上删除分支：

      ```plaintext
      git push origin --delete master
      ```

      您可以在稍后确认新的默认分支正常工作后再删除分支。

1. 通知您的项目贡献者此更改，因为他们还需要执行一些步骤：

   - 贡献者应将新的默认分支拉取到他们仓库的本地副本。
   - 有打开的、目标为旧默认分支的合并请求的贡献者应手动
     将合并请求重定向到 `main`。
1. 在您的仓库中，更新代码中对旧分支名称的任何引用。
1. 更新仓库之外的相关代码和脚本（如辅助工具和集成）中对旧分支名称的引用。

<a id="default-branch-rename-redirect"></a>

## 默认分支重命名重定向

项目中特定文件或目录的 URL 嵌入了项目的默认
分支名称，通常出现在文档或浏览器书签中。当您
[更新仓库中的默认分支名称](#update-the-default-branch-name-in-your-repository) 时，
这些 URL 会更改，必须进行更新。

为简化过渡期，每当项目的默认分支被更改时，
极狐GitLab 会记录旧默认分支的名称。如果该分支被删除，
尝试查看上面的文件或目录会被重定向到当前的
默认分支，而不是显示“未找到”页面。

<a id="troubleshooting"></a>

## 故障排除

<a id="unable-to-change-default-branch-resets-to-current-branch"></a>

### 无法更改默认分支：重置为当前分支

我们正在跟踪此问题。此问题通常发生在仓库中存在名为 `HEAD` 的分支时。
要解决此问题：

1. 在本地仓库中，创建一个新的临时分支并推送：

   ```shell
   git checkout -b tmp_default && git push -u origin tmp_default
   ```

1. 在极狐GitLab 中，继续 [更改默认分支](#change-the-default-branch-name-for-a-project) 为该临时分支。
1. 从本地仓库中，删除 `HEAD` 分支：

   ```shell
   git push -d origin HEAD
   ```

1. 在极狐GitLab 中，[更改默认分支](#change-the-default-branch-name-for-a-project) 为您打算使用的分支。

<a id="query-graphql-for-default-branches"></a>

### 使用 GraphQL 查询默认分支

您可以使用 [GraphQL 查询](../../../../api/graphql/_index.md) 来检索群组中所有项目的默认分支。

要返回一页中的所有项目，请将 `GROUPNAME` 替换为群组的完整路径。极狐GitLab 返回第一页结果。如果 `hasNextPage` 为 `true`，您可以通过将 `after: null` 中的 `null` 替换为 `endCursor` 的值来请求下一页：

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

### 新子群组不继承上级子群组的默认分支名称

当您在包含另一个子群组的子群组中配置了默认分支，该子群组中包含项目时，
默认分支不会被继承。

我们正在跟踪此问题。