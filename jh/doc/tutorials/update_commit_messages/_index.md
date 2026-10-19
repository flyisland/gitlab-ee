---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: '教程：更新 Git 提交信息'
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

有时，在向分支做了几次提交后，您会发现自己需要更新一条或多条提交信息。也许您发现了一个拼写错误，或者某个自动化工具警告您，您的提交信息没有完全符合项目的[提交信息准则](../../topics/git/commit.md#write-a-good-commit-message)。

如果您不太熟悉从命令行界面（CLI）使用 Git，更新提交信息可能会比较棘手。但别担心，即使您一直只在极狐GitLab UI 中工作，也可以按照以下步骤使用 CLI。

本教程介绍如何重写提交信息。如果您只在极狐GitLab UI 中工作，请从头开始。如果您已经在本地克隆了代码仓库，可以跳到获取并检出分支的步骤。

<a id="before-you-begin"></a>

## 先决条件

您必须具备：

- 一个极狐GitLab 项目，其中包含一个 Git 分支，且该分支中有您想要更新的提交。
- 已在[本地机器上安装](../../topics/git/how_to_install_git/_index.md) Git。
- 能够访问本地机器的命令行界面（CLI）。在 macOS 上，您可以使用终端。在 Windows 上，您可以使用 PowerShell。Linux 用户可能已经熟悉自己系统的 CLI。
- 熟悉系统的默认编辑器。本教程假设您的编辑器是 Vim，但任何文本编辑器都可以。如果您不熟悉 Vim，[Vim 入门](https://opensource.com/article/19/3/getting-started-vim)的第 1 步和第 2 步介绍了本教程后面用到的所有命令。
- 拥有覆盖提交信息的权限。如果您与多人在同一分支上协作，应先与他们确认可以更新这些提交。有些组织可能有禁止重写提交的规定，因为这被视为破坏性变更。

在最后一步中，您必须通过极狐GitLab 进行身份验证，才能覆盖提交信息。如果您的极狐GitLab 账号使用基本的用户名和密码身份验证，则必须禁用[双重身份验证（2FA）](../../user/profile/account/two_factor_authentication.md)，才能从 CLI 进行身份验证。或者，您可以[使用 SSH 密钥向极狐GitLab 进行身份验证](../../user/ssh.md)。

<a id="clone-your-repository-to-your-local-machine"></a>

## 将代码仓库克隆到本地机器

首先，在您的机器上创建代码仓库的本地副本。

{{< guide >}}

1. 复制代码仓库 URL。

   在极狐GitLab 中，在项目概览页面的右上角，选择 **代码**。
   在下拉列表中，选择以下项旁边的 {{< icon name="copy-to-clipboard" >}} 来复制代码仓库的 URL：

   - 如果您的极狐GitLab 账号使用基本的用户名和密码身份验证，请选择 **使用 HTTPS 克隆**。
   - 如果您使用 SSH 向极狐GitLab 进行身份验证，请选择 **使用 SSH 克隆**。

1. 克隆代码仓库。

   切换到本地机器上的 CLI（终端、PowerShell 或类似工具），然后转到您想要克隆代码仓库的目录。例如，`/users/my-username/my-projects/`。
   运行 `git clone` 并粘贴您之前复制的 URL：

   ```shell
   git clone https://gitlab.com/my-username/my-awesome-project.git
   ```

   这会将代码仓库克隆到一个名为 `my-awesome-project/` 的新目录中。

{{< /guide >}}

现在您的代码仓库已在您的计算机上，可以执行 Git CLI 命令了。

<a id="fetch-and-check-out-your-branch"></a>

## 获取并检出分支

接下来，切换到包含您想要更新的提交的分支。

{{< guide >}}

1. 切换到您的项目目录。

   假设您仍处于上一步在 CLI 中的同一位置，
   使用 `cd` 切换到您的项目目录：

   ```shell
   cd my-awesome-project
   ```

1. 如有需要，获取您的分支。

   如果您刚刚克隆了代码仓库，您的分支应该已经在您的计算机上。但是，如果您之前克隆了代码仓库并跳到了这一步，则可能需要获取您的分支：

   ```shell
   git fetch origin my-branch-name
   ```

1. 检出该分支。

   现在该分支已在您的本地系统上，切换到它：

   ```shell
   git checkout my-branch-name
   ```

1. 确认您位于正确的分支上。

   运行 `git log` 并检查最近的提交是否与极狐GitLab 上您分支中的提交一致。要退出日志，请使用 `q`。

{{< /guide >}}

<a id="update-the-commit-messages"></a>

## 更新提交信息

现在您可以使用交互式变基来重写提交信息了。

{{< guide >}}

1. 确定要更新多少条提交。

   在极狐GitLab 中，检查您需要在提交历史中回溯多远：

   - 如果您已经为您的分支打开了一个合并请求，可以查看 **提交** 选项卡，并使用提交总数。
   - 如果您只在一个分支上工作：
     1. 转到 **代码** > **提交**。
     1. 选择左上角的下拉列表，找到您的分支。
     1. 找到您想要更新的最早提交，并计算该提交往回数多少条。例如，如果您想更新第二条和第四条提交，则计数为 4。

1. 开始交互式变基。

   在 CLI 中，将上一步的提交计数添加到 `HEAD~` 的末尾，以开始变基过程：

   ```shell
   git rebase -i HEAD~4
   ```

   在此示例中，Git 选择分支中最近的四条提交进行更新。
1. 标记要改写哪些提交。

   Git 会启动一个文本编辑器并列出所选的提交。
   例如，它应该类似于：

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
   # [and so on...]
   ```

   `pick` 命令告诉 Git 原样使用这些提交。对于您想要更新的提交，将命令从 `pick` 改为 `reword`。
   输入 `i` 进入 `INSERT` 模式，然后开始编辑文本。

   例如，要更新前面示例中第二条和第四条提交的文本，
   请将其编辑为：

   ```shell
   pick a0cea50 Fix broken link
   reword bb84712 Update milestone-plan.md
   pick ce11fad Add list of maintainers
   reword d211d03 update template.md
   ```

1. 保存您的更改。

   按 <kbd>Escape</kbd> 退出 `INSERT` 模式，
   然后输入 `:wq` 并按 <kbd>Enter</kbd> 保存并退出。
1. 更新每条提交信息。

   现在 Git 会逐条处理每个提交。任何带有 `pick`的提交都会原样添加回分支。当 Git 遇到带有 `reword`的提交时，它会停下来并再次打开文本编辑器。

   根据需要更新提交信息：

   - 对于单行提交信息，更新文本。例如：

   ```plaintext
   Update the monthly milestone plan
   ```

   - 对于包含标题和正文的提交信息，用空行将它们分隔开。例如：

   ```plaintext
   Update the monthly milestone plan

   Make the milestone plan clearer by listing the responsibilities
   of each maintainer.
   ```

   保存并退出后，Git 会更新提交信息并按顺序处理后续提交。完成后，您应该会看到消息 `Successfully rebased and update refs/heads/my-branch-name`。

1. 验证更新。

   要确认提交信息已更新，请运行 `git log`
   并向下滚动查看提交信息。

{{< /guide >}}

<a id="push-the-changes-to-gitlab"></a>

## 将更改推送到极狐GitLab

最后，将更新后的提交推送回极狐GitLab。

{{< guide >}}

1. 强制推送更改。

   在 CLI 中，将更改推送回极狐GitLab。您必须使用 `-f`“强制推送”选项，
   因为提交已被更新，而强制推送会覆盖极狐GitLab 中的旧提交：

   ```shell
   git push -f origin
   ```

   在覆盖极狐GitLab 中的提交信息之前，您的终端可能会提示您输入用户名和密码。
1. 在极狐GitLab 中验证更改。

   在极狐GitLab 中的项目里，确认提交已更新：

   - 如果您已经为您的分支打开了一个合并请求，请查看 **提交** 选项卡。
   - 如果您只在一个分支上工作：
     1. 转到 **代码** > **提交**。
     1. 选择左上角的下拉列表，找到您的分支。
     1. 确认列表中相关提交现已更新。

{{< /guide >}}

恭喜，您已成功更新提交信息并将其推送到极狐GitLab！
