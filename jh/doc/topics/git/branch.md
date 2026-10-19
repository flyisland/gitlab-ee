---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 为你的更改创建一个 Git 分支
---

分支是创建分支时代码仓中文件的副本。
你可以在自己的分支中工作，而不会影响其他分支。当你准备好将你的更改添加到主代码库时，可以将你的分支合并到默认分支中，例如 `main`。

在以下情况下使用分支：

- 想要向项目添加代码，但不确定它是否能正常运行。
- 正在与其他人共同协作一个项目，且不希望自己的工作与他人的工作混淆。

<a id="create-a-branch"></a>

创建分支

要创建分支：

```shell
git checkout -b <name-of-branch>
```

极狐GitLab 强制执行[分支命名规则](../../user/project/repository/branches/_index.md#name-your-branch)以避免问题，并提供[分支命名模式](../../user/project/repository/branches/_index.md#prefix-branch-names-with-a-number)以简化合并请求的创建。

<a id="switch-to-a-branch"></a>

切换到分支

Git 中的所有工作都在分支中进行。
你可以在分支之间切换，以查看文件的状态并在该分支中工作。

要切换到现有分支：

```shell
git checkout <name-of-branch>
```

例如，要切换到 `main` 分支：

```shell
git checkout main
```

<a id="keep-a-branch-up-to-date"></a>

保持分支更新

你的分支不会自动包含从其他分支合并到默认分支的更改。
要包含你创建分支后合并的更改，你必须手动更新分支。

要使用默认分支中的最新更改更新你的分支，可以执行以下任一操作：

- 运行 `git rebase` 将你的分支[变基](git_rebase.md)到默认分支。如果你希望你的更改在 Git 日志中列在默认分支的更改之后，请使用此命令。
- 运行 `git pull <remote-name> <default-branch-name>`。如果你希望你的更改在 Git 日志中与默认分支的更改按时间顺序一同出现，或者你正在与其他人共享分支，请使用此命令。如果你不确定 `<remote-name>` 的正确值，请运行：`git remote`。

<a id="related-topics"></a>

相关主题

- [分支](../../user/project/repository/branches/_index.md)
- [标签](../../user/project/repository/tags/_index.md)