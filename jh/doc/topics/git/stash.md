---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 暂存更改
---

当你需要切换到其他分支，但目前有未提交的更改且不准备提交时，可以使用 `git stash`。

<a id="create-stash-entries"></a>

## 创建暂存条目

默认情况下，`git stash` 会存储工作目录中已跟踪的更改以及所有暂存的更改。
你可以使用选项来控制包含哪些更改。

- 暂存已跟踪的更改：

  ```shell
  git stash
  ```

- 暂存更改并附加信息：

  ```shell
  git stash push -m "描述你的更改"
  ```

- 暂存更改但保留暂存区域中的更改：

  ```shell
  git stash push -k
  ```

  使用 `-k`（`--keep-index`）选项将更改暂存起来，但同时保留在工作目录中。
  当你希望临时保存更改但继续处理它们时，可以使用此选项。
- 暂存更改并包括未跟踪的文件：

  ```shell
  git stash push -u
  ```

  使用 `-u`（`--include-untracked`）选项也会暂存 Git 尚未跟踪的文件。
  如果不使用此选项，尚未提交的新文件将继续保留在工作目录中。
- 仅暂存已暂存的更改：

  ```shell
  git stash push -S
  ```

  使用 `-S`（`--staged`）选项仅暂存已暂存的更改。
  当你希望保存已暂存的更改并继续处理未暂存的更改时，可以使用此选项。

<a id="apply-stash-entries"></a>

## 应用暂存条目

如果你在暂存工作后进行了大量更改，应用暂存时可能会发生冲突。
你必须解决这些冲突才能应用更改。

- 应用最近的暂存条目并将其保留在暂存区中：

  ```shell
  git stash apply
  ```

- 应用指定的暂存条目：

  ```shell
  git stash apply stash@{3}
  ```

- 应用最近的暂存条目并将其从暂存区中移除：

  ```shell
  git stash pop
  ```

<a id="view-stash-entries"></a>

## 查看暂存条目

- 查看所有暂存条目：

  ```shell
  git stash list
  ```

- 查看更详细的暂存条目：

  ```shell
  git stash list --stat
  ```

<a id="delete-stash-entries"></a>

## 删除暂存条目

- 删除最近的暂存条目：

  ```shell
  git stash drop
  ```

- 删除指定的暂存条目：

  ```shell
  git stash drop <name>
  ```

- 删除所有暂存条目：

  ```shell
  git stash clear
  ```

<a id="example-create-and-apply-a-stash-entry"></a>

## 示例：创建并应用一个暂存条目

尝试使用 Git 暂存：

1. 在 Git 仓库中修改一个文件。
1. 暂存此次修改：

   ```shell
   git stash push -m "Saving changes from edit"
   ```

1. 查看暂存列表：

   ```shell
   git stash list
   ```

1. 确认没有待处理的更改：

   ```shell
   git status
   ```

1. 应用暂存的更改并从暂存区中移除该条目：

   ```shell
   git stash pop
   ```

1. 查看暂存列表确认该条目已被移除：

   ```shell
   git stash list
   ```

<a id="related-topics"></a>

## 相关主题

- [官方 Git stash 文档](https://git-scm.com/docs/git-stash)