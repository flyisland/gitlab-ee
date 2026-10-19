---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 暂存更改
---

当您想切换到其他分支，但存在尚未准备好提交的未提交更改时，可以使用 `git stash`。

<a id="create-stash-entries"></a>

## 创建暂存条目

默认情况下，`git stash` 会存储工作目录中的已跟踪更改以及任何已暂存的更改。您可以使用选项来控制包含哪些更改。

- 要暂存已跟踪的更改：

  ```shell
  git stash
  ```

- 要暂存更改并附带说明：

  ```shell
  git stash push -m "describe your changes here"
  ```

- 要暂存更改但将已暂存的更改保留在工作目录中：

  ```shell
  git stash push -k
  ```

  `-k`（`--keep-index`）选项会暂存您的更改，但同时将它们保留在工作目录中。
  当您想临时保存更改但仍继续处理这些更改时，可使用此选项。
- 要暂存更改并包含未跟踪的文件：

  ```shell
  git stash push -u
  ```

  `-u`（`--include-untracked`）选项还会暂存 Git 尚未跟踪的文件。
  如果不使用此选项，尚未提交的新文件会保留在您的工作目录中。
- 要仅暂存已暂存的更改：

  ```shell
  git stash push -S
  ```

  `-S`（`--staged`）选项仅暂存已暂存的更改。
  当您想保存已暂存的更改，同时继续处理未暂存的更改时，可使用此选项。

<a id="apply-stash-entries"></a>

## 应用暂存条目

如果您在暂存工作后进行了许多更改，应用暂存时可能会发生冲突。必须先解决这些冲突，才能应用更改。

- 要应用最近的暂存条目并将其保留在暂存中：

  ```shell
  git stash apply
  ```

- 要应用特定的暂存条目：

  ```shell
  git stash apply stash@{3}
  ```

- 要应用最近的暂存条目并将其从暂存中移除：

  ```shell
  git stash pop
  ```

<a id="view-stash-entries"></a>

## 查看暂存条目

- 要查看所有暂存条目：

  ```shell
  git stash list
  ```

- 要查看更详细的暂存条目：

  ```shell
  git stash list --stat
  ```

<a id="delete-stash-entries"></a>

## 删除暂存条目

- 要删除最近的暂存条目：

  ```shell
  git stash drop
  ```

- 要删除特定的暂存条目：

  ```shell
  git stash drop <name>
  ```

- 要删除所有暂存条目：

  ```shell
  git stash clear
  ```

<a id="example-create-and-apply-a-stash-entry"></a>

## 示例：创建并应用暂存条目

要尝试使用 Git 暂存：

1. 修改 Git 代码仓库中的某个文件。
1. 暂存该修改：

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

1. 应用暂存的更改，并将该条目从暂存中移除：

   ```shell
   git stash pop
   ```

1. 查看暂存列表，确认该条目已被移除：

   ```shell
   git stash list
   ```
