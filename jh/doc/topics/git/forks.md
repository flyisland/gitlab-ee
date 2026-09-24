---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Fork a Git repository when you want to contribute changes back to an upstream repository you don't have permission to contribute to directly.
title: 更新派生仓库
---

<a id="update-a-fork"></a>

# 更新派生仓库

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

派生仓库是仓库及其所有分支的个人副本，您可以在自己选择的命名空间中创建。您可以使用派生仓库向您没有访问权限的其他项目提议更改。有关更多信息，请参见[派生工作流](../../user/project/repository/forking_workflow.md)。

您也可以使用[极狐GitLab UI](../../user/project/repository/forking_workflow.md#from-the-ui) 更新派生仓库。

先决条件：

- 您必须在本地计算机上[下载并安装 Git 客户端](how_to_install_git/_index.md)。
- 您必须为要更新的仓库[创建派生](../../user/project/repository/forking_workflow.md#create-a-fork)。

要从命令行更新派生仓库：

1. 检查是否已为您的派生仓库配置了 `upstream` 远程仓库：

   1. 如果尚未克隆，请在本地克隆您的派生仓库。有关更多信息，请参见[克隆仓库](clone.md)。
   1. 查看为您的派生仓库配置的远程仓库：

      ```shell
      git remote -v
      ```

   1. 如果您的派生仓库没有指向原始仓库的远程，请使用以下示例之一配置名为 upstream 的远程：

      ```shell
      # Set any repository as your upstream after editing <upstream_url>
      git remote add upstream <upstream_url>

      # Set the main GitLab repository as your upstream
      git remote add upstream https://jihulab.com/gitlab-cn/gitlab.git
      ```

1. 更新您的派生仓库：

   1. 在本地副本中，检出默认分支。将 `main` 替换为您的默认分支名称：

      ```shell
      git checkout main
      ```

      > [!note]
      > 如果 Git 识别到未暂存的更改，请在继续之前[提交或暂存](commit.md)它们。

   1. 从上游仓库获取更改：

      ```shell
      git fetch upstream
      ```

   1. 将更改拉取到您的派生仓库中。将 `main` 替换为您正在更新的分支名称：

      ```shell
      git pull upstream main
      ```

   1. 将更改推送到服务器上的派生仓库：

      ```shell
      git push origin main
      ```

<a id="collaborate-across-forks"></a>

## 跨派生仓库协作

极狐GitLab 支持上游项目维护者与派生仓库所有者之间的协作。有关更多信息，请参见：

- [跨派生仓库协作合并请求](../../user/project/merge_requests/allow_collaboration.md)
  - [允许来自上游成员的提交](../../user/project/merge_requests/allow_collaboration.md#allow-commits-from-upstream-members)
  - [阻止来自上游成员的提交](../../user/project/merge_requests/allow_collaboration.md#prevent-commits-from-upstream-members)

<a id="push-to-a-fork-as-an-upstream-member"></a>

### 作为上游成员推送到派生仓库

在以下情况下，您可以直接推送到派生仓库的分支：

- 合并请求的作者启用了来自上游成员的贡献。
- 您在上游项目中具有开发者、维护者或所有者角色。

在以下示例中：

- 派生仓库的 URL 为 `git@jihulab.com:contributor/forked-project.git`。
- 合并请求的分支是 `fork-branch`。

要更改或添加提交到贡献者的合并请求：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 转到 **代码** > **合并请求** 并找到合并请求。
1. 在右上角，选择 **代码**，然后选择 **检出分支**。
1. 在对话框中，选择 **复制** ({{< icon name="copy-to-clipboard" >}})。
1. 在终端中，转到仓库的克隆版本，并粘贴命令。例如：

   ```shell
   git fetch "git@jihulab.com:contributor/forked-project.git" 'fork-branch'
   git checkout -b 'contributor/fork-branch' FETCH_HEAD
   ```

   这些命令从派生项目获取分支，并创建一个本地分支供您工作。
1. 对分支的本地副本进行更改，然后提交它们。
1. 将本地更改推送到派生项目。以下命令将本地分支 `contributor/fork-branch` 推送到 `git@jihulab.com:contributor/forked-project.git` 仓库的 `fork-branch` 分支：

   ```shell
   git push git@jihulab.com:contributor/forked-project.git contributor/fork-branch:fork-branch
   ```

   如果您已修改或压缩了任何提交，则必须使用 `git push --force`。请谨慎操作，因为此命令会重写提交历史。

   ```shell
   git push --force git@jihulab.com:contributor/forked-project.git contributor/fork-branch:fork-branch
   ```

   冒号 (`:`) 指定源分支和目标分支。格式为：

   ```shell
   git push <forked_repository_git_url> <local_branch>:<fork_branch>
   ```

<a id="related-topics"></a>

## 相关主题

- [派生工作流](../../user/project/repository/forking_workflow.md)
  - [创建派生](../../user/project/repository/forking_workflow.md#create-a-fork)
  - [取消链接派生](../../user/project/repository/forking_workflow.md#unlink-a-fork)
- [跨派生仓库协作合并请求](../../user/project/merge_requests/allow_collaboration.md)
- [合并请求](../../user/project/merge_requests/_index.md)