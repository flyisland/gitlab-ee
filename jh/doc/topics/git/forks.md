---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Fork 一个 Git 代码仓库，当您想将更改贡献回一个您没有直接贡献权限的上游代码仓库时。
title: 更新一个 fork
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

fork 是代码仓库及其所有分支的个人副本，您可以在自己选择的命名空间中创建它。您可以使用 forks 向您没有访问权限的其他项目提出更改建议。有关更多信息，请参见 [forking 工作流](../../user/project/repository/forking_workflow.md)。

您还可以通过[极狐GitLab UI](../../user/project/repository/forking_workflow.md#from-the-ui) 更新 fork。

先决条件：

- 您必须在本地机器上[下载并安装 Git 客户端](how_to_install_git/_index.md)。
- 您必须为要更新的代码仓库[创建一个 fork](../../user/project/repository/forking_workflow.md#create-a-fork)。

要从命令行更新您的 fork：

1. 检查您的 fork 是否配置了 `upstream` 远程代码仓库：

   1. 如果尚未在本地克隆您的 fork，请先克隆。有关更多信息，请参见[克隆代码仓库](clone.md)。
   1. 查看为您的 fork 配置的远程：

      ```shell
      git remote -v
      ```

   1. 如果您的 fork 没有指向原始代码仓库的远程，请使用以下示例之一配置名为 upstream 的远程：

      ```shell
      # Set any repository as your upstream after editing <upstream_url>
      git remote add upstream <upstream_url>

      # Set the main GitLab repository as your upstream
      git remote add upstream https://jihulab.com/gitlab-cn/gitlab.git
      ```

1. 更新您的 fork：

   1. 在本地副本中，检出[默认分支](../../user/project/repository/branches/default.md)。请将 `main` 替换为您的默认分支名称：

      ```shell
      git checkout main
      ```

      > [!note]
      > 如果 Git 识别到未暂存的更改，请在继续之前[提交或暂存](commit.md)它们。

   1. 从上游代码仓库获取更改：

      ```shell
      git fetch upstream
      ```

   1. 将更改拉取到您的 fork 中。请将 `main` 替换为您正在更新的分支名称：

      ```shell
      git pull upstream main
      ```

   1. 将更改推送到服务器上您的 fork 代码仓库：

      ```shell
      git push origin main
      ```

<a id="collaborate-across-forks"></a>

## 跨 forks 协作

极狐GitLab 支持上游项目维护者与 fork 所有者之间进行协作。有关更多信息，请参见：

- [跨 forks 协作处理合并请求](../../user/project/merge_requests/allow_collaboration.md)
  - [允许来自上游成员的提交](../../user/project/merge_requests/allow_collaboration.md#allow-commits-from-upstream-members)
  - [阻止来自上游成员的提交](../../user/project/merge_requests/allow_collaboration.md#prevent-commits-from-upstream-members)

<a id="push-to-a-fork-as-an-upstream-member"></a>

### 作为上游成员推送到 fork

如果满足以下条件，您可以直接推送到 forked 代码仓库的分支：

- 合并请求的作者已允许来自上游成员的贡献。
- 您在上游项目中拥有开发者、维护者或所有者角色。

在以下示例中：

- forked 代码仓库 URL 为 `git@jihulab.com:contributor/forked-project.git`。
- 合并请求的分支为 `fork-branch`。

要更改或添加提交到贡献者的合并请求：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 转到**代码** > **合并请求**并找到该合并请求。
1. 在右上角，选择**代码**，然后选择**检出分支**。
1. 在对话框中，选择**复制**（{{< icon name="copy-to-clipboard" >}}）。
1. 在您的终端中，进入代码仓库的克隆版本，并粘贴命令。例如：

   ```shell
   git fetch "git@jihulab.com:contributor/forked-project.git" 'fork-branch'
   git checkout -b 'contributor/fork-branch' FETCH_HEAD
   ```

   这些命令会从 forked 项目获取分支，并创建一个本地分支供您使用。
1. 对分支的本地副本进行更改，然后提交它们。
1. 将您的本地更改推送到 forked 项目。以下命令将本地分支 `contributor/fork-branch` 推送到 `git@jihulab.com:contributor/forked-project.git` 代码仓库的 `fork-branch` 分支：

   ```shell
   git push git@jihulab.com:contributor/forked-project.git contributor/fork-branch:fork-branch
   ```

   如果您已修订或压缩了任何提交，则必须使用 `git push --force`。请谨慎操作，因为此命令会重写提交历史。

   ```shell
   git push --force git@jihulab.com:contributor/forked-project.git contributor/fork-branch:fork-branch
   ```

   冒号（`:`）用于指定源分支和目标分支。其格式为：

   ```shell
   git push <forked_repository_git_url> <local_branch>:<fork_branch>
   ```
