---
stage: Create
group: Source Code
info: "To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments"
type: howto
---

# 添加文件到仓库 **(BASIC ALL)**

添加文件到仓库是一个小却关键的任务。把文件（比如代码文件，图片或者文档，甚至有可能这些文件是在别的地方创建的）放到仓库里，允许 Git 跟踪他们。

您可以用[终端](#用命令行添加文件)添加文件, 然后推送到极狐GitLab。您也可以在网页<!--[网页](../user/project/repository/web_editor.md#upload-a-file)-->上添加文件，这样更简单。

如果您需要先创建一个文件，比如一个叫  `README.md` 文本文件, 您同样可以在[终端](command-line-commands.md#在当前目录创建文本文件)或者网页<!--[网页](../user/project/repository/web_editor.md#create-a-file)-->上完成。

## 用命令行添加文件

打开一个 [shell 终端](command-line-commands.md)，进入到您的 极狐GitLab 项目文件夹。通常可以用下述命令达到目的：

```shell
cd <destination folder>
```

[创建一个新分支](../tutorials/make_your_first_git_commit.md#create-a-branch-and-make-changes)用以添加您的文件。应该避免直接向默认分支提交改动，除非是一个非常小的项目而且只有您自己在这个项目上工作。

如果分支已经存在，您也可以[切换到一个已有的分支](start-using-git.md#切换分支)。

用您的标准工具把文件（比如 macOS 的访达，或者 Windows 的文件浏览器）拷贝到您的 GitLab 项目的文件夹里。

用下述命令检查确保文件存在 （如果是 Windows 操作系统请用 `dir` 命令）：

```shell
ls
```

您的文件应该出现在输出列表里。

检查状态：

```shell
git status
```

您的文件名会以红色出现在输出里， 所以 `git` 已经知晓它了！现在把它添加到仓库里：

```shell
git add <name of file>
```

重新检查状态，您的文件名应该是绿色的了：

```shell
git status
```

提交（保存）文件到仓库:

```shell
git commit -m "DESCRIBE COMMIT IN A FEW WORDS"
```

现在您可以推送（发送）您的改动（在 `<branch-name>` 这个分支上）到极狐GitLab（命名为 'origin' 的远程 Git 服务器上）

```shell
git push origin <branch-name>
```

现在您的文件已经成功添加到您的极狐GitLab 仓库里了。

<!-- ## Troubleshooting

Include any troubleshooting steps that you can foresee. If you know beforehand what issues
one might have when setting this up, or when something is changed, or on upgrading, it's
important to describe those, too. Think of things that may go wrong and include them here.
This is important to minimize requests for support, and to avoid doc comments with
questions that you know someone might ask.

Each scenario can be a third-level heading, e.g. `### Getting error message X`.
If you have none to add when creating a doc, leave this section in place
but commented out to help encourage others to add to it in the future. -->
