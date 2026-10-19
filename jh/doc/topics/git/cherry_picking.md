---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
description: Cherry-pick a Git commit when you want to add a single commit from one branch to another.
title: 使用 Git 进行变更的 Cherry-pick 提交
---

{{< details >}}

- Tier: 基础版, 专业版, 旗舰版
- Offering: JihuLab.com, 私有化部署

{{< /details >}}

使用 `git cherry-pick` 将特定提交的更改应用到您当前的工作分支。使用此命令可以：

- 将错误修复从默认分支回移到先前的发布分支。
- 将更改从一个分支复制到上游仓库。
- 在不合并整个分支的情况下应用特定更改。

您还可以使用极狐GitLab UI 来 cherry-pick。有关更多信息，请参阅 [Cherry-pick changes](../../user/project/merge_requests/cherry_pick_changes.md)。

{{< alert type="warning" >}}

谨慎使用 `git cherry-pick`，因为它可能会创建重复提交并可能使您的项目历史复杂化。

{{< /alert >}}

<a id="cherry-pick-a-single-commit"></a>

## Cherry-pick 一个单一提交

要从另一个分支 cherry-pick 一个单一提交到您当前的工作分支：

1. 检出您要 cherry-pick 到的分支：

   ```shell
   git checkout your_branch
   ```

1. 确定要 cherry-pick 的提交的安全散列算法 (SHA)。
   要找到这个，检查提交历史或使用 `git log` 命令。例如：

   ```shell
   $ git log

   commit 0000011111222223333344444555556666677777
   Merge: 88888999999 aaaaabbbbbb
   Author: user@example.com
   Date:   Tue Aug 31 21:19:41 2021 +0000
    ```

1. 使用 `git cherry-pick` 命令。将 `<commit_sha>` 替换为您确定的提交的 SHA：

   ```shell
   git cherry-pick <commit_sha>
   ```

Git 将指定提交的更改应用到您当前的工作分支。如果有冲突，会显示通知。然后您可以解决冲突并继续 cherry-pick 过程。

<a id="cherry-pick-multiple-commits"></a>

## Cherry-pick 多个提交

要从另一个分支 cherry-pick 多个提交到您当前的工作分支：

1. 检出您要 cherry-pick 到的分支：

   ```shell
   git checkout your_branch
   ```

1. 确定要 cherry-pick 的提交的安全散列算法 (SHA)。
   要找到这个，检查提交历史或使用 `git log` 命令。例如：

   ```shell
   $ git log

   commit 0000011111222223333344444555556666677777
   Merge: 88888999999 aaaaabbbbbb
   Author: user@example.com
   Date:   Tue Aug 31 21:19:41 2021 +0000
    ```

1. 对每个提交使用 `git cherry-pick` 命令，
   将 `<commit_sha>` 替换为提交的 SHA：

   ```shell
   git cherry-pick <commit_sha_1>
   git cherry-pick <commit_sha_2>
   ...
   ```

或者，您可以使用 `..` 表示法 cherry-pick 一系列提交：

   ```shell
   git cherry-pick <start_commit_sha>..<end_commit_sha>
   ```

这会将 `<start_commit_sha>` 和 `<end_commit_sha>` 之间的所有提交应用到您当前的工作分支。

<a id="cherry-pick-a-merge-commit"></a>

## Cherry-pick 一个合并提交

Cherry-pick 一个合并提交会将合并提交的更改应用到您当前的工作分支。

要从另一个分支 cherry-pick 一个合并提交到您当前的工作分支：

1. 检出您要 cherry-pick 到的分支：

   ```shell
   git checkout your_branch
   ```

1. 确定要 cherry-pick 的提交的安全散列算法 (SHA)。
   要找到这个，检查提交历史或使用 `git log` 命令。例如：

   ```shell
   $ git log

   commit 0000011111222223333344444555556666677777
   Merge: 88888999999 aaaaabbbbbb
   Author: user@example.com
   Date:   Tue Aug 31 21:19:41 2021 +0000
    ```

1. 使用带有 `-m` 选项的 `git cherry-pick` 命令和您要用作主线的父提交的索引。
   将 `<commit_sha>` 替换为合并提交的 SHA，`<parent_index>` 替换为父提交的索引。索引从 `1` 开始。例如：

   ```shell
   git cherry-pick -m 1 <merge-commit-hash>
   ```

这会将 Git 配置为将第一个父提交用作主线。要将第二个父提交用作主线，请使用 `-m 2`。

<a id="related-topics"></a>

## 相关主题

- [在极狐GitLab UI 上进行变更的 Cherry-pick 变更](../../user/project/merge_requests/cherry_pick_changes.md)。
- [提交 API](../../api/commits.md#cherry-pick-a-commit)

<a id="troubleshooting"></a>

## 故障排除

如果在 cherry-pick 过程中遇到冲突：

1. 手动在受影响的文件中解决冲突。
1. 暂存解决的文件：

   ```shell
   git add <resolved_file>
   ```

1. 继续 cherry-pick 过程：

   ```shell
   git cherry-pick --continue
   ```

要中止 cherry-pick 过程并返回到之前的状态，
请使用以下命令：

```shell
git cherry-pick --abort
```

这将撤销 cherry-pick 过程中的任何更改。
