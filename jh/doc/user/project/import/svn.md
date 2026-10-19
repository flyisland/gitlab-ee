---
stage: Foundations
group: Import and Integrate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: 从 SVN 迁移到极狐GitLab
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

极狐GitLab 使用 Git 作为其版本控制系统。如果您使用 Subversion (SVN) 作为版本控制系统，您可以使用 `svn2git` 迁移，到极狐GitLab 中使用 Git 仓库。

如果您的 SVN 仓库满足以下条件，您可以按照此页面上的步骤迁移到 Git：

- 具有标准格式（主干、分支和标签）。
- 不是嵌套结构的。

对于非标准仓库，请参阅 [`svn2git` 文档](https://github.com/nirvdrum/svn2git)。

我们建议从 SVN 硬切换到 Git 和极狐GitLab。运行一次迁移命令，然后让所有用户立即使用新的极狐GitLab 仓库。

## 安装 `svn2git`

在本地工作站而不是极狐GitLab 服务器上安装 `svn2git`：

- 在所有系统上，如果您已经安装了 Ruby 和 Git，则可以将其安装为 Ruby gem：

  ```shell
  sudo gem install svn2git
  ```

- 在基于 Debian 的 Linux 发行版上，您可以安装本机软件包：

  ```shell
  sudo apt-get install git-core git-svn ruby
  ```

## 准备作者文件（推荐）

准备一个作者文件，以便 `svn2git` 可以将 SVN 作者映射到 Git 作者。如果您选择不创建作者文件，则提交不会归因于正确的极狐GitLab 用户。

要映射作者，您必须将存在的每个作者映射到 SVN 仓库中的更改。如果不这样做，迁移将失败，您必须相应地更新作者文件。

1. 搜索 SVN 仓库，输出作者列表：

   ```shell
   svn log --quiet | grep -E "r[0-9]+ \| .+ \|" | cut -d'|' -f2 | sed 's/ //g' | sort | uniq
   ```

1. 使用上一条命令的输出构建作者文件。创建一个名为 `authors.txt` 的文件并每行添加一个映射。例如：

   ```plaintext
   sidneyjones = Sidney Jones <sidneyjones@example.com>
   ```

## 将 SVN 仓库迁移到 Git 仓库

`svn2git` 支持排除某些文件路径、分支、标签等。有关所有可用选项的完整文档，请参阅 [`svn2git` 文档](https://github.com/nirvdrum/svn2git)或运行 `svn2git --help`。

对于要迁移的每个仓库：

1. 创建一个新目录并进入它。
1. 对于以下仓库：

   - 不需要用户名和密码，运行：

     ```shell
     svn2git https://svn.example.com/path/to/repo --authors /path/to/authors.txt
     ```

   - 确实需要用户名和密码，运行：

     ```shell
     svn2git https://svn.example.com/path/to/repo --authors /path/to/authors.txt --username <username> --password <password>
     ```

1. 为您迁移的代码创建一个新的极狐GitLab 项目。
1. 从极狐GitLab 项目页面复制 SSH 或 HTTP(S) 仓库 URL。
1. 将极狐GitLab 仓库添加为 Git 远端并推送所有更改，会推送所有提交、分支和标签。

   ```shell
   git remote add origin git@gitlab.example.com:<group>/<project>.git
   git push --all origin
   git push --tags origin
   ```

## 相关主题

- [从 SVN 到极狐GitLab 的迁移指南](https://gitlab.cn/resources/articles/b92028b1-16df-4db9-a49a-afc6db72f65c)
- [SVN vs Git 不是技术之争，而是生态之争](https://gitlab.cn/resources/articles/2a4d7854-e2a6-487f-81b2-7a94d7e736c9)