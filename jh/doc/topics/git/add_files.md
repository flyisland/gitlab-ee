---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Add, commit, and push a file to your Git repository using the command line.
title: 将文件添加到分支
---

使用 Git 将文件添加到本地仓库的分支中。
该操作为下一次提交创建文件的快照，并启动版本控制监控。
使用 Git 添加文件时，您可以：

- 准备内容以进行版本控制跟踪。
- 创建文件添加和修改的记录。
- 保留文件历史记录以供将来参考。
- 使项目文件可用于团队协作。

<a id="add-files-to-a-git-repository"></a>

## 将文件添加到 Git 仓库

要从命令行添加新文件：

1. 打开终端。
1. 切换到项目文件夹所在目录。

   ```shell
   cd my-project
   ```

1. 选择要工作的 Git 分支。
   - 要创建分支：`git checkout -b <分支名>`
   - 要切换到现有分支：`git checkout <分支名>`

1. 将要添加的文件复制到您想要添加到的目录中。
1. 确认文件位于目录中：
   - Windows：`dir`
   - 所有其他操作系统：`ls`

   文件名应显示出来。
1. 检查文件状态：

   ```shell
   git status
   ```

   文件名应为红色。文件已在文件系统中，但 Git 尚未跟踪它。
1. 告诉 Git 跟踪该文件：

   ```shell
   git add <文件名>
   ```

1. 再次检查文件状态：

   ```shell
   git status
   ```

   文件名应为绿色。文件已由 Git 暂存（本地跟踪），但尚未[提交和推送](commit.md)。

<a id="add-a-file-to-the-last-commit"></a>

## 将文件更改添加到上次提交

要将文件更改添加到上次提交，而不是创建新提交，可以修改现有提交：

```shell
git add <文件名>
git commit --amend
```

如果不想编辑提交信息，请在 `commit` 命令后追加 `--no-edit`。

<a id="related-topics"></a>

## 相关主题

- [从 UI 添加文件](../../user/project/repository/_index.md#add-a-file-from-the-ui)
- [签署提交](../../user/project/repository/signed_commits/gpg.md)