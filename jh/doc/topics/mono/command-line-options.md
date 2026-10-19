---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
description: Mono, Repo, Project, labels.
title: 命令行选项 
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

> [引入](https://jihulab.com/gitlab-cn/gitlab/-/issues/2861)于极狐GitLab 16.4。[功能标志](../../user/feature_flags.md)为 `ff_monorepo`，默认禁用。

Mono 命令的格式如下，方括号 `[ ]` 中为可选参数。

```bash
mono <COMMAND> [ARGS]
```

## help

安装 Mono 后，获取命令行帮助：

```bash
mono help
```

获取指定命令的信息：

```bash
mono help <COMMAND>
```

## init

在当前目录中安装并初始化 Mono：

```bash
mono init -u <URL> [<OPTIONS>]
```

支持的命令行选项：

* `-u`：指定保存了 manifest 文件的初始化项目代码仓库的 URL。

* `-m`：指定代码仓库中的 manifest 文件。如果未配置，则默认为 `default.xml`。

* `-b`：指定代码仓库的检出分支。

* `--git-lfs`：启用 LFS 功能。

## sync

下载新的变更并更新指定的本地项目中的工作文件：

```bash
mono sync [<PROJECT_LIST>]
```

如果您未指定项目或项目列表，则该命令会同步更新所有项目的文件。

运行此命令后，将出现以下情况：

* 如果未同步过目标项目，则相当于执行了 `git clone` 命令，将远端仓库中的所有分支复制到本地项目目录中。
* 如果已同步过目标项目，则相当于执行了以下命令，同步远端分支并检查是否有冲突：

    * 如果远端仓库存在同名分支，则先同步远端同名分支，再同步主分支代码。

	  ```bash
	  git remote update
	  git branch --set-upstream-to=origin/<BRANCH> <BRANCH>
	  git pull
	  git rebase <MAIN-BRANCH>
	  ```

    * 如果远端仓库不存在同名分支，则只同步主分支代码。

	  ```bash
	  git remote update
	  git rebase <MAIN-BRANCH>
	  ```

	其中 `BRANCH` 是本地项目中当前已检出的分支。即使项目的本地分支没有对应的远端 origin 分支，也会同步主分支代码。

* 如果 `git rebase` 操作导致合并冲突，您需要使用 Git 命令（例如 `git rebase --continue`）来解决冲突。
	
`repo sync` 命令运行成功后，指定的本地项目中的代码会与远端仓库中的代码保持同步。

## upload

上传推送本地变更到远端：

```bash
mono upload
```

上传的同时在极狐GitLab 上会自动创建合并请求，合并请求带有 `monorepo` 标签。

执行此命令后，如果本地存在多个有变更的项目，您需要选择要上传的分支，例如：

```bash
# Uncomment the branches to upload:
# 
# project local-dirname/repo1/:
   branch test20-upload ( 1 commit, Thu Jul 6 17:51:48 2023 +0809) to remote branch main:
#            d77059da Add repo1.txt
# project local-dirname/repo2/:
   branch test26-upload ( 1 commit, Thu Jul 6 17:51:53 2023 +0800) to remote branch main:
#           725cf8e2 Add repo2.txt
```

在以上示例中，通过取消注释的方式，选择了上传项目 `repo1` 的分支 `test20-upload`，以及项目 `repo2` 的分支 `test26-upload`。

## diff

查看本地所有项目与远端之间的差异：

```bash
mono diff
```

例如：

```bash
$ mono diff
project local-dirname/repo1/
diff --git a/test.rb b/test.rb
new file mode 100644
index 0000000..e69de29
```

## start

创建新的主题分支来进行开发：

```bash
mono start <FEATURE_BRANCH_NAME> <PROJECT_NAME>
```

`<FEATURE_BRANCH_NAME>` 为新建分支的名称。如果在远端有同名分支，则基于该同名分支创建本地分支。

`<PROJECT_NAME>` 为指定创建分支所在项目的名称。此外还支持以下选项：

* `.`：在当前目录下的所有项目中创建分支，例如 `mono start <FEATURE_BRANCH_NAME> .`。
* `--all`：在所有项目中创建同名分支，例如 `mono start <FEATURE_BRANCH_NAME> --all`。

## status

查看当前所有项目的文件变更状态：

```bash
mono status
```

例如：

```bash
$ mono status
project local-dirname/repo1/                  branch feature2
 A-     test.rb
project local-dirname/repo2/                  branch main
```

## 常见问题

#### 我在执行 mono init 时没有启用 LFS，之后还可以再启用吗？

可以。重新执行 `mono init --git-lfs` 即可启用 LFS 功能。

**注意：** 此操作仅对后续拉取的新仓库生效，已存在的本地仓库需要手动处理。完整步骤如下：

```bash
# 1. 启用 LFS
mono init --git-lfs

# 2. 为已存在的仓库手动启用 LFS（请先确保工作目录无待提交改动）
mono forall -c 'git config --unset filter.lfs.smudge 2>/dev/null || true; git config --unset filter.lfs.process 2>/dev/null || git lfs pull || true'
```