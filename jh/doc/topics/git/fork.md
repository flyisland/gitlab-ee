---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
description: Fork a Git repository when you want to contribute changes back to an upstream repository you don't have permission to contribute to directly.
title: 更新派生
---

{{< details >}}

- Tier: 基础版, 专业版, 旗舰版
- Offering: JihuLab.com, 私有化部署

{{< /details >}}

fork 是一个仓库及其所有分支的个人副本，您可以在自己选择的命名空间中创建。您可以使用 fork 向您无权访问的其他项目提出更改建议。有关更多信息，请参阅[分叉工作流](../../user/project/repository/forking_workflow.md)。

您还可以使用[极狐GitLab 界面](../../user/project/repository/forking_workflow.md#from-the-ui)更新 fork。

先决条件：

- 您必须在本地机器上[下载并安装 Git 客户端](how_to_install_git/_index.md)。
- 您必须[创建一个 fork](../../user/project/repository/forking_workflow.md#create-a-fork)，用于更新的仓库。

通过命令行更新您的 fork：

1. 检查您的 fork 是否配置了 `upstream` 远程仓库：

   1. 如果尚未在本地克隆您的 fork，请进行克隆。有关更多信息，请参阅[克隆仓库](clone.md)。
   1. 查看为您的 fork 配置的远程仓库：

      ```shell
      git remote -v
      ```

   1. 如果您的 fork 没有指向原始仓库的远程仓库，请使用以下示例之一配置一个名为 upstream 的远程仓库：

       ```shell
       # 在编辑 <upstream_url> 后，将任何仓库设置为您的 upstream
       git remote add upstream <upstream_url>

       # 将主极狐GitLab 仓库设置为您的 upstream
       git remote add upstream https://jihulab.com/gitlab-cn/gitlab.git
       ```

1. 更新您的 fork：

   1. 在本地副本中，检出[默认分支](../../user/project/repository/branches/default.md)。将 `main` 替换为您的默认分支的名称：

      ```shell
      git checkout main
      ```

      {{< alert type="note" >}}

      如果 Git 检测到未暂存的更改，请在继续之前[提交或存储](commit.md)这些更改。

      {{< /alert >}}

   1. 从 upstream 仓库获取更改：

      ```shell
      git fetch upstream
      ```

   1. 将更改拉入您的 fork。将 `main` 替换为您正在更新的分支的名称：

      ```shell
      git pull upstream main
      ```

   1. 将更改推送到服务器上的 fork 仓库：

      ```shell
      git push origin main
      ```

<a id="collaborate-across-forks"></a>

## 跨 fork 协作

极狐GitLab 使上游项目维护者与 fork 所有者之间的协作成为可能。有关更多信息，请参阅：

- [跨 fork 的合并请求协作](../../user/project/merge_requests/allow_collaboration.md)
  - [允许上游成员提交](../../user/project/merge_requests/allow_collaboration.md#allow-commits-from-upstream-members)
  - [阻止上游成员提交](../../user/project/merge_requests/allow_collaboration.md#prevent-commits-from-upstream-members)

<a id="push-to-a-fork-as-an-upstream-member"></a>

### 作为上游成员推送到 fork

如果满足以下条件，您可以直接推送到 fork 仓库的分支：

- 合并请求的作者启用了来自上游成员的贡献。
- 您至少具有上游项目的开发者角色。

在以下示例中：

- fork 仓库的 URL 是 `git@gitlab.com:contributor/forked-project.git`。
- 合并请求的分支是 `fork-branch`。

要更改或添加提交到贡献者的合并请求：

1. 在左侧边栏中，选择**搜索或转到**并找到您的项目。
1. 转到**代码** > **合并请求**并找到合并请求。
1. 在右上角，选择**代码**，然后选择**检出分支**。
1. 在对话框中，选择**复制** ({{< icon name="copy-to-clipboard" >}})。
1. 在终端中，转到仓库的克隆版本，并粘贴命令。例如：

   ```shell
   git fetch "git@gitlab.com:contributor/forked-project.git" 'fork-branch'
   git checkout -b 'contributor/fork-branch' FETCH_HEAD
   ```

   这些命令从 fork 项目中获取分支并为您创建一个本地分支进行工作。

1. 对分支的本地副本进行更改，然后提交这些更改。
1. 将本地更改推送到 fork 项目。以下命令将本地分支 `contributor/fork-branch` 推送到 `git@gitlab.com:contributor/forked-project.git` 仓库的 `fork-branch` 分支：

   ```shell
   git push git@gitlab.com:contributor/forked-project.git contributor/fork-branch:fork-branch
   ```

   如果您修改或压缩了任何提交，您必须使用 `git push --force`。请谨慎操作，因为此命令会重写提交历史。

   ```shell
   git push --force git@gitlab.com:contributor/forked-project.git contributor/fork-branch:fork-branch
   ```

   冒号 (`:`) 指定源分支和目标分支。格式为：

   ```shell
   git push <forked_repository_git_url> <local_branch>:<fork_branch>
   ```

<a id="related-topics"></a>

## 相关主题

- [分叉工作流](../../user/project/repository/forking_workflow.md)
  - [创建一个 fork](../../user/project/repository/forking_workflow.md#create-a-fork)
  - [取消链接 fork](../../user/project/repository/forking_workflow.md#unlink-a-fork)
- [跨 fork 的合并请求协作](../../user/project/merge_requests/allow_collaboration.md)
- [合并请求](../../user/project/merge_requests/_index.md)
