---
stage: Create
group: Source Code
info: 要确定分配给与此页面相关的阶段/群组的技术作家，请参考 https://about.gitlab.cn/handbook/engineering/ux/technical-writing/#assignments
type: howto, tutorial
description: "通过命令行介绍Git的使用"
---

# 常用的 Git 命令 **(BASIC ALL)**

[Git](https://git-scm.com/) 是一个开源的分布式版本控制系统，极狐GitLab 是建立在 Git 之上。

您可以在极狐GitLab 中直接执行很多 Git 操作。但是，高级任务是需要命令行操作的，比如修复复杂的合并冲突或回滚提交。

如果您是 Git 新手并且想通过自己的项目来学习，[学习如何进行第一次提交](../tutorials/make_your_first_git_commit.md)。

<!--要获得 Git 命令的快速参考，请下载 [Git Cheat Sheet](https://about.gitlab.cn/images/press/git-cheat-sheet.pdf)-->

<!--
有关使用 Git 和 GitLab 的优势的更多信息:

- <i class="fa fa-youtube-play youtube" aria-hidden="true"></i>&nbsp;Watch the [GitLab Source Code Management Walkthrough](https://www.youtube.com/watch?v=wTQ3aXJswtM) video.
- 学习如何在开发环境中让 [GitLab 成为 Worldline 的基础](https://about.gitlab.cn/customers/worldline/)。
-->

为了帮助您去可视化您在本地所做的事情，您可以安装一个 [Git GUI app](https://git-scm.com/download/gui/)。

### 选择一个终端

要在计算机上执行 Git 命令，必须打开终端（也称为命令提示符、命令 shell 和命令行）。这里有一些选项：

- 对于 macOS 用户：
  - 内置 [Terminal](https://blog.teamtreehouse.com/introduction-to-the-mac-os-x-command-line)，按 <kbd>⌘ command</kbd> + <kbd>space</kbd> 然后输入 `terminal`；
  - [iTerm2](https://iterm2.com/)，您可以将其与 [Zsh](https://git-scm.com/book/id/v2/Appendix-A%3A-Git-in-Other-Environments-Git-in-Zsh) 和 [Oh My Zsh](https://ohmyz.sh/)集成，用于颜色突出显示和其它高级功能。
- 对于 Windows 用户：
  - 内置命令行。在 Windows 任务栏，选择搜索图标或者输入`cmd`；
  - [PowerShell](https://learn.microsoft.com/en-us/powershell/scripting/windows-powershell/install/installing-windows-powershell?view=powershell-7)；
  - Git Bash。这是建立在 [Git for Windows](https://gitforwindows.org/) 之上的。
- 对于 Linux 用户：
  - 内置 [Linux Terminal](https://ubuntu.com/tutorials/command-line-for-beginners#3-opening-a-terminal)。

## 确认 Git 已安装

您可以通过打开终端并执行以下命令，来确定计算机上是否已经安装了 Git：

```shell
git --version
```

如果 Git 已经安装好，输出为：

```shell
git version X.Y.Z
```

如果您的计算机不识别 `git`命令，您必须[安装 Git](../topics/git/how_to_install_git/index.md)。

## 配置 Git

要开始在计算机上使用 Git，必须输入凭据，证明自己是作品的作者。用户名和电子邮件地址应该与您在极狐GitLab 中使用的一致。

1. 在 shell 中，添加您的用户名：

   ```shell
   git config --global user.name "your_username"
   ```

1. 添加您的邮件地址：

   ```shell
   git config --global user.email "your_email_address@example.com"
   ```

1. 检查配置, 运行:

   ```shell
   git config --global --list
   ```

  `--global` 选项使得 Git 始终将此信息用于您在系统上执行的任何操作。如果省略 `--global` 或者用 `--local`，该配置仅适用于当前仓库。

您可以阅读[Git 管理配置文档](https://git-scm.com/book/en/v2/Customizing-Git-Git-Configuration)，获取有关 Git 如何管理配置的更多信息。

### 选择一个仓库

在开始之前，选择您要工作的仓库。您可以任何极狐GitLab 实例<!--在 GitLab.cn或任何其它GitLab 实例-->上使用您有权访问的任何项目。

要使用本页示例中的仓库，请执行以下操作：

1. 打开链接 [https://jihulab.com/gitlab-tests/sample-project/](https://jihulab.com/gitlab-tests/sample-project/)；
1. 在右上角，选择 **派生**；
1. 为您的派生项目选择一个命名空间。

该项目在 `https://jihulab.com/<您的命名空间>/sample-project/` 中可用。

您可以<!--[派生](../user/project/repository/forking_workflow.md#creating-a-fork)-->派生任何您可以访问的项目。

<a id="clone-a-repository"></a>

## 克隆一个仓库

当您克隆仓库时，远端仓库中的文件会被下载到您的计算机上，这样就建立了连接。

这个连接需要您添加凭据，您可以使用 SSH 或 HTTPS，推荐使用SSH。

### 用 SSH 进行克隆

当您只想进行一次验证时，使用 SSH 克隆。

1. 使用极狐GitLab 进行身份验证，参考 [SSH 文档](../user/ssh.md)-->；
1. 跳转到项目页面并选择 **克隆**. 复制 **使用 SSH 克隆** 的URL；
1. 打开终端，进入要克隆文件的目录。Git 会自动创建一个带有仓库名称的文件夹并下载文件到该目录。

1. 运行命令:

   ```shell
   git clone git@gitlab.com:gitlab-tests/sample-project.git
   ```

1. 要查看这些文件，请转到目录:

   ```shell
   cd sample-project
   ```

您也可以<!--[克隆一个仓库，并直接在Visual Studio Code中打开它](../user/project/repository/index.md#clone-and-open-in-visual-studio-code)-->克隆一个仓库，并直接在 Visual Studio Code 中打开它。

<a id="clone-with-https"></a>

### 用 HTTPS 进行克隆

当您需要计算机和极狐GitLab 之间执行操作时均进行身份验证时，请使用HTTPS 进行克隆：

1. 转到项目的页面并选择 **克隆**. 复制 **使用 HTTPS 克隆** 的URL；
1. 打开终端，进入要克隆文件的目录；
1. 运行如下命令，Git 会自动创建一个带有仓库名称的文件夹并下载文件到该目录。

   ```shell
   git clone https://gitlab.com/gitlab-tests/sample-project.git
   ```

1. 极狐GitLab 需要您的用户名和密码:
   
   如果您在您的账户上启用了双重身份验证 (2FA)，则无法使用您的账户密码。您可以执行以下操作之一：

   - [使用令牌进行克隆](#clone-using-a-token)，令牌具有 `read_repository` 或 `write_repository` 权限。
   - 安装 [Git Credential Manager](../user/profile/account/two_factor_authentication.md#git-credential-manager)。
   
   如果您没有启用 2FA，请直接使用账号密码。

1. 要查看这些文件，请转到目录:

   ```shell
   cd sample-project
   ```

NOTE:
在 Windows 上，如果您多次输入错误密码并出现 `Access denied` 消息，请将您的命名空间（用户名或群组）添加到路径中：`git clone https://namespace@gitlab.cn/gitlab-cn/gitlab.git`。

### 将本地目录转换成仓库

您可以初始化本地文件夹，以便 Git 将其作为仓库进行跟踪。

1. 在要转换的目录中打开终端。
1. 运行命令：

   ```shell
   git init
   ```

  在您的目录中创建了一个 `.git` 文件夹。该文件夹包含 Git 记录和配置文件，不建议直接编辑这些文件。

1. 添加[到远端仓库的路径](#add-a-remote)。这样 Git 就可以将文件上传到正确的项目中。

<a id="add-a-remote"></a>

#### 添加一个远端

您可以添加一个 "remote" 告诉 Git 与您计算机上的特定本地文件夹相关联的是极狐GitLab 中的哪个远端仓库。远端告诉 Git 从哪里 push 或 pull。

将远端文件添加到本地副本：

1. 在极狐GitLab 中，<!--[创建一个项目](../user/project/working_with_projects.md#create-a-project)-->来保存您的文件。
1. 访问这个项目的主页，往下滚动到 **推送现有文件夹**，并复制以 ` git remote add` 开头的命令。
1. 在您的计算机上, 在已初始化的目录中打开终端，粘贴刚复制的命令，并按 <kbd>enter</kbd>：

   ```shell
   git remote add origin git@gitlab.com:username/projectpath.git
   ```

在您做完这些之后, 您可以[提交文件](#添加并提交本地更改)并且[上传它们到极狐Gitlab](#将更改推送到远端)。

#### 查看远端仓库

要查看远端仓库，请输入:

```shell
git remote -v
```

 `-v` 代表verbose。

<a id="download-the-latest-changes-in-the-project"></a>

### 下载项目中的最新更改

要处理项目的最新副本，使用 `pull` 以获取自上次克隆或拉取项目以来用户所做的所有更改。用您的默认分支<!--[默认分支](../user/project/repository/branches/default.md)-->替换 `<name-of-branch>` 来获取主分支代码，或将其替换为您当前所在分支的分支名称。

```shell
git pull <REMOTE> <name-of-branch>
```

当您克隆一个仓库，`REMOTE` 通常是 `origin`，仓库从这里克隆的。它指示远端服务器仓库的 SSH 或 HTTPS URL。`<name-of-branch>` 通常是默认分支<!--[默认分支](../user/project/repository/branches/default.md)-->的名字，但它可能是任何现有的分支。您可以根据需要创建附加的命名远端和分支。

可以从[Git 远端文档](https://git-scm.com/book/en/v2/Git-Basics-Working-with-Remotes)了解更多 Git 如何管理远端仓库的信息。

## 分支

**分支**是您创建分支时仓库中文件的副本。
您可以在您的分支工作，而不会影响其他分支。当您准备好将更改添加到主代码库时，您可以将您的分支合并到默认分支中，例如，`main`。

在如下情况下使用分支：

- 想要向项目添加代码，但您不确定它是否正常工作；
- 正在与他人合作完成项目，并且不希望您的工作混乱；

一个新的分支通常被称为**功能分支**，不同于默认分支<!--[默认分支](../user/project/repository/branches/default.md)-->。

### 创建一个分支

创建一个功能分支：

```shell
git checkout -b <name-of-branch>
```

分支名称不能包含空格和特殊字符，只使用小写字母，数字，连字符(`-`)和下划线(`_`)。

### 切换分支

Git 中的所有工作都是在一个分支中完成的。
您可以在分支之间切换，以查看文件的状态和在该分支中的工作。

切换到现有分支：

```shell
git checkout <name-of-branch>
```

例如，要切换到 `main` 分支：

```shell
git checkout main
```

### 查看差异

查看本地提交的更改与您克隆或拉取的最新版本之间的差异：

```shell
git diff
```

### 查看更改的文件

当您添加、更改或删除文件或文件夹时，Git 知道这些更改。

检查哪些文件已更改：

```shell
git status
```

### 添加并提交本地更改

当您输入 `git status`，本地更改的文件显示为红色。这些变化可能是新建、修改或删除的文件或文件夹。

1. 添加要暂存的准备提交的文件：

   ```shell
   git add <file-name OR folder-name>
   ```

1. 对要添加的每个文件或文件夹重复步骤 1，或者，将所有文件暂存到当前目录和子目录中，输入 `git add .`。

1. 确认文件已经添加到暂存中；

   ```shell
   git status
   ```

   文件应该以绿色文本显示。

1. 提交暂存文件：

   ```shell
   git commit -m "COMMENT TO DESCRIBE THE INTENTION OF THE COMMIT"
   ```

#### 准备并提交所有更改

有一个快捷方式，您可以将所有本地更改添加到暂存，并使用一个命令提交它们:

```shell
git commit -a -m "COMMENT TO DESCRIBE THE INTENTION OF THE COMMIT"
```

<a id="send-changes-to-gitlabcom"></a>

### 将更改推送到远端

将所有本地更改推到远端仓库:

```shell
git push <remote> <name-of-branch>
```

例如，要将本地提交推送到 `origin` 远端的 `main` 分支:

```shell
git push origin main
```

有时 Git 不允许您推送到仓库。相反，必须[强制更新](../topics/git/git_rebase.md#强制推送)。

### 删除分支中的所有更改

放弃对跟踪文件的所有更改:

```shell
git checkout .
```

此操作删除对文件的*更改*，而不是文件本身。未跟踪的（新的）文件不会更改。

### 取消已添加到暂存区的所有更改

要取消暂存（删除）所有尚未提交的文件：

```shell
git reset
```

### 撤销最近的提交

撤销最近的提交：

```shell
git reset HEAD~1
```

此操作将更改的文件和文件夹保留在本地仓库中。

WARNING:
如果您已经将 Git 提交推送到远端仓库，则不应撤销该提交。虽然您可以撤消提交，但最好是通过谨慎的操作来避免这种情况的出现。

可以从[Git 撤销事务文档](https://git-scm.com/book/en/v2/Git-Basics-Undoing-Things)了解更多关于 Git 撤销更改的不同方式。

### 将一个分支与默认分支合并

当您准备将更改添加到默认分支时，您可以将功能分支合并到其中。

```shell
git checkout <default-branch>
git merge <feature-branch>
```

在极狐GitLab 中，通常会使用合并请求<!--[合并请求](../user/project/merge_requests/)-->来合并您的修改，而不是用命令行。

<!--要创建从分支到上游仓库的合并请求，请参考：
[派生工作流](../user/project/repository/forking_workflow.md)。-->

## Git 使用命令行的高级用法

有关更高级的 Git 技术的介绍，请参考 [Git 变基，强制推送和合并冲突](../topics/git/git_rebase.md)文档。

## 将派生仓库中的更改与上游同步

要在您的命名空间中创建仓库的副本, 您可以派生<!--[派生](../user/project/repository/forking_workflow.md)-->。对仓库副本所做的更改不会自动与原始项目同步。要使项目与原始项目保持同步，您需要从原始仓库中 `pull`。

您必须[创建到远端仓库的链接](#添加一个远端)，从原始仓库中拉取更改，通常将此远端仓库称为 `upstream`。
现在您可以从原始仓库，把 `upstream` 作为一个 [`<remote>` 去 `pull` 最新更新](#下载项目中的最新更改)，并使用 `origin` 来[提交本地更改](#将更改推送到远端) 并创建新的合并请求。

<!-- ## Troubleshooting

Include any troubleshooting steps that you can foresee. If you know beforehand what issues
one might have when setting this up, or when something is changed, or on upgrading, it's
important to describe those, too. Think of things that may go wrong and include them here.
This is important to minimize requests for support, and to avoid doc comments with
questions that you know someone might ask.

Each scenario can be a third-level heading, e.g. `### Getting error message X`.
If you have none to add when creating a doc, leave this section in place
but commented out to help encourage others to add to it in the future. -->
