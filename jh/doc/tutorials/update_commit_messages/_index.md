---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 教程：更新 Git 提交信息
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

偶尔，在向分支提交了几次后，你可能会发现需要更新一个或多个提交信息。也许你发现了一个拼写错误，或者某些自动化工具警告你的提交信息不完全符合项目的[提交信息指南](../../topics/git/commit.md#write-a-good-commit-message)。

如果你对使用命令行界面 (CLI) 操作 Git 不太熟练，更新提交信息可能会有些棘手。但别担心，即使你只在极狐GitLab UI 中工作过，也可以按照以下步骤来使用 CLI。

本教程解释了如何重写提交信息。如果你只在极狐GitLab UI 中工作，请从头开始。如果你已经在本地克隆了代码仓，可以跳到获取并检出分支的步骤。

## 准备工作

<a id="before-you-begin"></a>

你必须具备：

- 一个包含你想要更新的提交的 Git 分支的极狐GitLab 项目。
- [本地机器上安装了 Git](../../topics/git/how_to_install_git/_index.md)。
- 能够访问本地机器的命令行界面 (CLI)。在 macOS 中，你可以使用终端。在 Windows 中，你可以使用 PowerShell。Linux 用户可能已经熟悉其系统的 CLI。
- 熟悉系统默认的编辑器。本教程假设你的编辑器是 Vim，但任何文本编辑器都可以。如果你不熟悉 Vim，[Vim 入门](https://opensource.com/article/19/3/getting-started-vim) 的第 1 到 2 步解释了本教程后面使用的所有命令。
- 覆盖提交信息的权限。如果你和其他人在同一个分支上工作，你应该首先与他们确认是否可以更新提交。一些组织可能有禁止重写提交的规定，因为它被认为是一种破坏性变更。

在最后一步中，你必须向极狐GitLab 进行身份验证才能覆盖提交信息。如果你的极狐GitLab 账户使用基本的用户名和密码认证，则必须禁用[双重认证 (2FA)](../../user/profile/account/two_factor_authentication.md) 才能从 CLI 进行认证。或者，你可以[使用 SSH 密钥向极狐GitLab 进行认证](../../user/ssh.md)。

## 将代码仓克隆到本地机器

<a id="clone-your-repository-to-your-local-machine"></a>

首先，在你的机器上创建代码仓的本地副本。

{{< guide >}}

1. 复制代码仓 URL。

   在极狐GitLab 中，在你的项目概览页面，右上角，选择 **代码**。
   在下拉列表中，通过选择旁边的 {{< icon name="copy-to-clipboard" >}} 来复制你的代码仓 URL：

   - **使用 HTTPS 克隆**，如果你的极狐GitLab 账户使用基本的用户名和密码认证。
   - **使用 SSH 克隆**，如果你使用 SSH 向极狐GitLab 认证。

1. 克隆代码仓。

   切换到本地机器上的 CLI（终端、PowerShell 或类似工具），并进入你想要克隆代码仓的目录。例如，`/users/my-username/my-projects/`。
   运行 `git clone` 并粘贴你之前复制的 URL：

   ```shell
   git clone https://gitlab.com/my-username/my-awesome-project.git
   ```

   这会将代码仓克隆到一个名为 `my-awesome-project/` 的新目录中。

{{< /guide >}}

现在你的代码仓已经在你的计算机上了，可以使用你的 Git CLI 命令了。

## 获取并检出你的分支

<a id="fetch-and-check-out-your-branch"></a>

接下来，切换到包含你想要更新的提交的分支。

{{< guide >}}

1. 进入你的项目目录。

   假设你还在 CLI 中与上一步相同的位置，
   使用 `cd` 进入你的项目目录：

   ```shell
   cd my-awesome-project
   ```

1. 如果需要，获取你的分支。

   如果你刚刚克隆了代码仓，你的分支应该已经在你的计算机上了。但是，如果你之前克隆了代码仓并跳到了这一步，你可能需要获取你的分支：

   ```shell
   git fetch origin my-branch-name
   ```

1. 检出分支。

   现在分支已经在你的本地系统上了，切换到它：

   ```shell
   git checkout my-branch-name
   ```

1. 验证你是否在正确的分支上。

   运行 `git log` 并检查最近的提交是否与你在极狐GitLab 分支中的提交匹配。要退出日志，请按 `q`。

{{< /guide >}}

## 更新提交信息

<a id="update-the-commit-messages"></a>

现在，你可以使用交互式变基来重写提交信息了。

{{< guide >}}

1. 确定要更新多少个提交。

   在极狐GitLab 中，检查你需要在提交历史中回溯多远：

   - 如果你的分支已经有一个打开的合并请求，你可以检查 **提交** 选项卡并使用提交总数。
   - 如果你只在一个分支上工作：
     1. 前往 **代码** > **提交**。
     1. 选择左上角的下拉列表并找到你的分支。
     1. 找到你想更新的最旧的提交，并计算该提交是第几个。例如，如果你想更新第二个和第四个提交，那么计数就是 4。

1. 启动交互式变基。

   在 CLI 中，通过将上一步中的提交计数添加到 `HEAD~` 后面来启动变基过程：

   ```shell
   git rebase -i HEAD~4
   ```

   在这个例子中，Git 选择了分支中最近的四个提交进行更新。
1. 标记哪些提交需要修改信息。

   Git 启动一个文本编辑器并列出所选的提交。
   例如，它看起来应该类似于：

   ```shell
   pick a0cea50 Fix broken link
   pick bb84712 Update milestone-plan.md
   pick ce11fad Add list of maintainers
   pick d211d03 update template.md

   # Rebase 1f5ec88..d211d03 onto 1f5ec88 (4 commands)
   #
   # Commands:
   # p, pick <commit> = use commit
   # r, reword <commit> = use commit, but edit the commit message
   # e, edit <commit> = use commit, but stop for amending
   # s, squash <commit> = use commit, but meld into previous commit
   # f, fixup [-C | -c] <commit> = like "squash" but keep only the previous
   #                    commit's log message, unless -C is used, in which case
   # [等等...]
   ```

   `pick` 命令告诉 Git 直接使用这些提交而不做更改。对于你想要更新的提交，把命令从 `pick` 改为 `reword`。
   输入 `i` 进入 `INSERT` 模式，然后开始编辑文本。

   例如，要更新前面示例中第二个和第四个提交的文本，把它编辑成如下所示：

   ```shell
   pick a0cea50 Fix broken link
   reword bb84712 Update milestone-plan.md
   pick ce11fad Add list of maintainers
   reword d211d03 update template.md
   ```

1. 保存你的更改。

   按 <kbd>Escape</kbd> 退出 `INSERT` 模式，
   然后输入 `:wq` 并按 <kbd>Enter</kbd> 保存并退出。
1. 更新每个提交信息。

   Git 现在会逐一遍历每个提交。任何带有 `pick` 的提交都会原样添加回分支。当 Git 遇到带有 `reword` 的提交时，它会停下并再次打开文本编辑器。

   根据需要更新提交信息：

   - 对于一行式的提交信息，更新文本。例如：

   ```plaintext
   更新每月里程碑计划
   ```

   - 对于包含标题和正文的提交信息，用空行分隔它们。例如：

   ```plaintext
   更新每月里程碑计划

   通过列出每位维护者的职责，使里程碑计划更加清晰。
   ```

   在你保存并退出后，Git 会更新提交信息并按顺序处理下一个提交。完成后你应该会看到信息 `Successfully rebased and update refs/heads/my-branch-name`。

1. 验证更新。

   要确认提交信息已更新，运行 `git log`
   并向下滚动查看提交信息。

{{< /guide >}}

## 推送更改到极狐GitLab

<a id="push-the-changes-to-gitlab"></a>

最后，将你更新后的提交推送回极狐GitLab。

{{< guide >}}

1. 强制推送更改。

   在 CLI 中，将更改推送回极狐GitLab。你必须使用 `-f` “强制推送”选项，因为提交已更新，强制推送会覆盖极狐GitLab 中的旧提交：

   ```shell
   git push -f origin
   ```

   在覆盖极狐GitLab 中的提交信息之前，你的终端可能会提示你输入用户名和密码。
1. 在极狐GitLab 中验证更改。

   在极狐GitLab 的项目中，确认提交已更新：

   - 如果你的分支已经有一个打开的合并请求，请检查 **提交** 选项卡。
   - 如果你只在一个分支上工作：
     1. 前往 **代码** > **提交**。
     1. 选择左上角的下拉列表并找到你的分支。
     1. 验证列表中相关的提交现在已更新。

{{< /guide >}}

恭喜你，你已成功更新了提交信息并将其推送到了极狐GitLab！