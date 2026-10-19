---
stage: Create
group: Source Code
info: "To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments"
type: howto, reference
---

# 用命令行编辑文件 **(BASIC ALL)**

当您[用命令行使用 Git](start-using-git.md)，您不仅仅需要使用 Git 命令。有几个基本的命令，您应该学习，以便充分利用命令行。

## 开始您的项目

首先您需要将您的项目[克隆（拷贝）](start-using-git.md#克隆一个仓库)到您的电脑里，以便于您可以在本地（在您自己的电脑上）管理您的Git项目。

## 用命令行管理文件

本节提供了一些您可能会觉得有用的基本 shell 命令的示例。有关详细信息，请在 web 上搜索 *bash commands* 。

或者您可以使用您选择的编辑器（IDE）或极狐GitLab 用户接口来编辑文件接口（非本地）。

### 常用命令

下面的列表并不详尽，但包含许多最常用的命令。

| 命令                       | 描述                                               |
| ------------------------------ | ---------------------------------------------------------- |
| `cd NAME-OF-DIRECTORY`         | 进入工作目录                                               |
| `cd ..`                        | 回到上层目录                                               |
| `ls`                           | 列出当前目录中的内容                                       |
| `ls a*`                        | 列出当前目录中以 'a' 开头的文件                              |
| `ls *.md`                      | 列出当前目录中以 '.md' 结尾的文件                            |
| `mkdir NAME-OF-YOUR-DIRECTORY` | 创建一个新的目录                                           |
| `cat README.md`                | 显示[您以前创建的文本文件](#在当前目录创建文本文件)的内容 |
| `pwd`                          | 显示当前路径                                               |
| `clear`                        | 清除 shell 终端                                              |

### 在当前目录创建文本文件

要从命令行创建文本文件，例如 “README.md”，请执行以下步骤：

```shell
touch README.md
nano README.md
#### ADD YOUR INFORMATION
#### Press: control + X
#### Type: Y
#### Press: enter
```

### 删除文件或目录

删除文件或目录很容易，但要小心：

WARNING:
这会**永久地**删除文件.

```shell
rm NAME-OF-FILE
```

WARNING:
这将**永久**删除目录和**其所有**内容。

```shell
rm -r NAME-OF-DIRECTORY
```

### 查看和执行历史命令

您可以查看从命令行执行的所有命令的历史记录，如果需要，可以再次执行其中任何一个。

首先，列出所以之前执行过的命令：

```shell
history
```

然后，从列表中选择一个命令，并检查该命令旁边的数字（例如`123`）。使用以下命令执行相同的完整命令：

```shell
!123
```

### 执行当前账户没有权限的命令

并非所有命令都可以从计算机上的基本用户账户执行，您可能需要管理员权限才能执行影响系统的命令，例如，尝试访问受保护的数据。您可以使用 'sudo' 来执行这些命令，但是可能需要管理员密码。

```shell
sudo RESTRICTED-COMMAND
```

WARNING:
小心使用 'sudo' 运行的命令。某些命令可能导致损坏您的数据或系统。

## Git 任务流示例

如果您对 Git 完全陌生，请浏览一些[示例任务流](https://rogerdudler.github.io/git-guide/)。这或许可以帮助您了解在工作中使用这些命令的最佳实践。

<!-- ## Troubleshooting

Include any troubleshooting steps that you can foresee. If you know beforehand what issues
one might have when setting this up, or when something is changed, or on upgrading, it's
important to describe those, too. Think of things that may go wrong and include them here.
This is important to minimize requests for support, and to avoid doc comments with
questions that you know someone might ask.

Each scenario can be a third-level heading, e.g. `### Getting error message X`.
If you have none to add when creating a doc, leave this section in place
but commented out to help encourage others to add to it in the future. -->
