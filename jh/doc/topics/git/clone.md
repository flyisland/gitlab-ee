---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 了解如何使用不同协议（SSH 或 HTTPS）从极狐GitLab 服务器克隆 Git 仓库。
title: 克隆 Git 仓库至本地计算机
---

你可以将 Git 仓库克隆到本地计算机。此操作会创建仓库的副本，
并建立一个连接，以同步你的计算机与极狐GitLab 服务器之间的更改。
此连接需要你添加凭据。
你可以[使用 SSH 克隆](#clone-with-ssh)或[使用 HTTPS 克隆](#clone-with-https)。
SSH 是推荐的认证方法。

克隆仓库会：

- 将所有项目文件、历史记录和元数据下载到你的本地计算机。
- 创建一个包含文件最新版本的工作目录。
- 设置用于同步未来更改的远程追踪。
- 提供对完整代码库的离线访问。
- 为将代码贡献回项目奠定基础。

<a id="clone-with-ssh"></a>

## 使用 SSH 克隆

当你只想进行一次认证时，请使用 SSH 克隆。

1.  按照 [SSH 文档](../../user/ssh.md) 中的说明，向极狐GitLab 进行认证。
1.  在顶栏中，选择 **搜索或跳转到** 并找到你想要克隆的项目。
1.  在项目的概览页面上，在右上角，选择 **代码**，然后复制 **使用 SSH 克隆** 对应的 URL。
1.  打开终端并转到你想要克隆文件的目录。
    Git 会自动创建一个以仓库命名的文件夹，并将文件下载到其中。
1.  运行此命令：

   ```shell
   git clone <copied URL>
   ```

1.  要查看文件，请转到新目录：

   ```shell
   cd <new directory>
   ```

<a id="clone-with-https"></a>

## 使用 HTTPS 克隆

当你想在每次计算机与极狐GitLab 之间执行操作时都进行认证，请使用 HTTPS 克隆。
[OAuth 凭据助手](../../user/profile/account/two_factor_authentication.md#oauth-credential-helpers)可以减少你必须手动认证的次数，使 HTTPS 成为一种无缝体验。

1.  在顶栏中，选择 **搜索或跳转到** 并找到你想要克隆的项目。
1.  在项目的概览页面上，在右上角，选择 **代码**，然后复制 **使用 HTTPS 克隆** 对应的 URL。
1.  打开终端并转到你想要克隆文件的目录。
1.  运行以下命令。Git 会自动创建一个以仓库命名的文件夹，并将文件下载到其中。

   ```shell
   git clone <copied URL>
   ```

1.  认证你的请求。

   > [!note]
   > 如果你已启用双因素认证 (2FA)，则不能使用用户名和密码进行认证。你可以：
   >
   > - [使用令牌](#clone-using-a-token)，并确保其具有 `read_repository` 或 `write_repository` 权限。
   > - 安装一个 [OAuth 凭据助手](../../user/profile/account/two_factor_authentication.md#oauth-credential-helpers)

1.  要查看文件，请转到新目录：

   ```shell
   cd <new directory>
   ```

> [!note]
> 在 Windows 上，如果你多次错误输入密码并出现 `Access denied` 消息，
> 请将你的命名空间（用户名或群组）添加到路径中：
> `git clone https://namespace@gitlab.com/gitlab-org/gitlab.git`。

<a id="clone-using-a-token"></a>

### 使用令牌克隆

在以下情况下，使用令牌通过 HTTPS 进行克隆：

- 你想使用 2FA。
- 你想要一组可撤销的、限定于一个或多个仓库的凭据。

你可以使用以下任何一种令牌在通过 HTTPS 克隆时进行认证：

- [个人访问令牌](../../user/profile/personal_access_tokens.md)。
- [部署令牌](../../user/project/deploy_tokens/_index.md)。
- [项目访问令牌](../../user/project/settings/project_access_tokens.md)。
- [群组访问令牌](../../user/group/settings/group_access_tokens.md)。

例如：

```shell
git clone https://<username>:<token>@gitlab.example.com/tanuki/awesome_project.git
```

<a id="clone-and-open-in-apple-xcode"></a>

## 克隆并在 Apple Xcode 中打开

包含 `.xcodeproj` 或 `.xcworkspace` 目录的项目可以在 macOS 上克隆到 Xcode 中。

1.  从极狐GitLab UI 中，转到项目的概览页面。
1.  在右上角，选择 **代码**。
1.  选择 **Xcode**。

项目将克隆到你的计算机上，并提示你打开 Xcode。

<a id="configure-browsers-for-ide-protocols"></a>

## 配置浏览器的 IDE 协议

为确保 **在 IDE 中打开** 功能正常工作，你必须配置浏览器以处理自定义应用程序协议，例如 `vscode://` 或 `jetbrains://`。

<a id="firefox"></a>

### Firefox

如果所需的应用程序已安装在你的系统上，Firefox 会自动处理自定义协议。
当你首次选择自定义协议链接时，会打开一个对话框，询问你是否要
打开该应用程序。选择 **打开链接** 以允许 Firefox 打开该应用程序。

如果你不想再次被提示，请选中复选框以记住你的选择。

如果提示对话框没有打开，你需要手动配置 Firefox：

1.  打开 Firefox。
1.  在右上角，选择 **打开应用程序菜单** ({{< icon name="hamburger" >}})。
1.  搜索或前往 **应用程序** 部分。
1.  在列表中找到并选择你想要的应用程序。例如，`vscode` 或 `jetbrains`。
1.  从下拉列表中选择 Visual Studio Code 或 IntelliJ IDEA，或者选择 **使用其他...** 来定位可执行文件。

如果你的首选 IDE 未列出，系统会在你首次选择相应链接时提示你选择一个应用程序。

<a id="chrome"></a>

### Chrome

如果所需的应用程序已安装在你的系统上，Chrome 会自动处理自定义协议。
当你首次在 Chrome 中选择自定义协议链接时，会打开一个对话框，询问你是否要
打开该应用程序。选择 **打开** 以允许 Chrome 打开该应用程序。

如果你不想再次被提示，请选中复选框以记住你的选择。

<a id="reduce-clone-size"></a>

## 减小克隆大小

随着 Git 仓库规模的增长，它们可能变得难以使用，
原因是：

- 必须下载的历史记录量很大。
- 它们需要大量的磁盘空间。

[部分克隆](https://git-scm.com/docs/partial-clone)
是一种性能优化，允许 Git 在不需要完整仓库副本的情况下运行。这项工作的目标是让 Git 更好地处理超大型仓库。

需要 Git 2.22.0 或更高版本。

<a id="filter-by-file-size"></a>

### 按文件大小过滤

通常不鼓励在 Git 中存储大型二进制文件，因为此后克隆或获取更改的每个人都需要下载每个已添加的大文件。
这些下载速度缓慢且容易出问题，尤其是在网络连接速度慢或不稳定的情况下工作时。

使用带有文件大小过滤器的部分克隆可以解决这个问题，因为它能从克隆和获取中排除有麻烦的大文件。当 Git 遇到缺失的文件时，会按需下载。

在克隆仓库时，使用 `--filter=blob:limit=<size>` 参数。例如，
要克隆仓库但排除大于 1 兆字节的文件：

```shell
git clone --filter=blob:limit=1m git@gitlab.com:gitlab-com/www-gitlab-com.git
```

这将产生以下输出：

```shell
Cloning into 'www-gitlab-com'...
remote: Enumerating objects: 832467, done.
remote: Counting objects: 100% (832467/832467), done.
remote: Compressing objects: 100% (207226/207226), done.
remote: Total 832467 (delta 585563), reused 826624 (delta 580099), pack-reused 0
Receiving objects: 100% (832467/832467), 2.34 GiB | 5.05 MiB/s, done.
Resolving deltas: 100% (585563/585563), done.
remote: Enumerating objects: 146, done.
remote: Counting objects: 100% (146/146), done.
remote: Compressing objects: 100% (138/138), done.
remote: Total 146 (delta 8), reused 144 (delta 8), pack-reused 0
Receiving objects: 100% (146/146), 471.45 MiB | 4.60 MiB/s, done.
Resolving deltas: 100% (8/8), done.
Updating files: 100% (13008/13008), done.
Filtering content: 100% (3/3), 131.24 MiB | 4.65 MiB/s, done.
```

输出更长是因为 Git：

1.  克隆仓库时排除了大于 1 兆字节的文件。
1.  下载检出默认分支所需的任何缺失的大文件。

当切换分支时，Git 可能会下载更多缺失的文件。

<a id="filter-by-object-type"></a>

### 按对象类型过滤

对于包含数百万文件和悠久历史的仓库，你可以排除所有文件并使用
[`git sparse-checkout`](https://git-scm.com/docs/git-sparse-checkout) 来减小工作副本的大小。

```shell
# 克隆仓库但排除所有文件
$ git clone --filter=blob:none --sparse git@gitlab.com:gitlab-com/www-gitlab-com.git
Cloning into 'www-gitlab-com'...
remote: Enumerating objects: 678296, done.
remote: Counting objects: 100% (678296/678296), done.
remote: Compressing objects: 100% (165915/165915), done.
remote: Total 678296 (delta 472342), reused 673292 (delta 467476), pack-reused 0
Receiving objects: 100% (678296/678296), 81.06 MiB | 5.74 MiB/s, done.
Resolving deltas: 100% (472342/472342), done.
remote: Enumerating objects: 28, done.
remote: Counting objects: 100% (28/28), done.
remote: Compressing objects: 100% (25/25), done.
remote: Total 28 (delta 0), reused 12 (delta 0), pack-reused 0
Receiving objects: 100% (28/28), 140.29 KiB | 341.00 KiB/s, done.
Updating files: 100% (28/28), done.

$ cd www-gitlab-com

$ git sparse-checkout set data --cone
remote: Enumerating objects: 301, done.
remote: Counting objects: 100% (301/301), done.
remote: Compressing objects: 100% (292/292), done.
remote: Total 301 (delta 16), reused 102 (delta 9), pack-reused 0
Receiving objects: 100% (301/301), 1.15 MiB | 608.00 KiB/s, done.
Resolving deltas: 100% (16/16), done.
Updating files: 100% (302/302), done.
```

更多详情，请参阅 Git 文档中关于
[`sparse-checkout`](https://git-scm.com/docs/git-sparse-checkout) 的部分。

<a id="filter-by-file-path"></a>

### 按文件路径过滤

通过 `--filter=sparse:oid=<blob-ish>` 过滤器规范，可以实现部分克隆和稀疏检出的更深层次集成。这种过滤模式使用类似于
`.gitignore` 文件的格式来指定在克隆和获取时要包含哪些文件。

> [!warning]
> 使用 `sparse` 过滤器进行部分克隆仍处于实验阶段。在克隆和获取时，它可能会很慢，并显著增加
> [Gitaly](../../administration/gitaly/_index.md) 的资源利用率。
> 请改用[过滤所有 blob 并使用 sparse-checkout](#filter-by-object-type)，因为
> [`git-sparse-checkout`](https://git-scm.com/docs/git-sparse-checkout) 简化了这种类型的部分克隆使用，并克服了其局限性。

更多详情，请参阅 Git 文档中关于
[`rev-list-options`](https://git-scm.com/docs/git-rev-list#Documentation/git-rev-list.txt---filterltfilter-specgt) 的部分。

1.  创建一个过滤器规范。例如，考虑一个包含许多应用程序的单体仓库，
    每个应用程序都位于根目录下的不同子目录中。创建一个文件 `shiny-app/.filterspec`：

   ```plaintext
   # 当使用 `--filter=sparse:oid=shiny-app/.gitfilterspec` 进行部分克隆时，
   # 只会下载文件中列出的路径。

   # 显式包含配置稀疏检出所需的 filterspec：
   # git config --local core.sparsecheckout true
   # git show master:snazzy-app/.gitfilterspec >> .git/info/sparse-checkout
   shiny-app/.gitfilterspec

   # Shiny 应用
   shiny-app/

   # 依赖项
   shimmery-app/
   shared-component-a/
   shared-component-b/
   ```

1.  按路径克隆和过滤。使用克隆命令对 `--filter=sparse:oid` 的支持尚未与稀疏检出完全集成。

   ```shell
   # 使用存储在服务器上的 filterspec 克隆过滤后的对象集。
   # 警告：此步骤可能非常慢！
   git clone --sparse --filter=sparse:oid=master:shiny-app/.gitfilterspec <url>

   # 可选：检查尚未获取的缺失对象
   git rev-list --all --quiet --objects --missing=print | wc -l
   ```

   > [!warning]
   > 与 `bash`、Zsh 等的 Git 集成以及会自动显示 Git 状态信息的编辑器通常会运行 `git fetch`，这会获取整个仓库。可能需要禁用或重新配置这些集成。

<a id="remove-partial-clone-filtering"></a>

### 移除部分克隆过滤

可以移除使用了部分克隆过滤的 Git 仓库的过滤设置。要移除过滤：

1.  获取所有被过滤器排除的内容，以确保仓库是完整的。如果使用了 `git sparse-checkout`，请使用
    `git sparse-checkout disable` 禁用它。更多信息请参阅
    [`disable` 文档](https://git-scm.com/docs/git-sparse-checkout#Documentation/git-sparse-checkout.txt-emdisableem)。

    然后执行常规的 `fetch` 以确保仓库是完整的。要检查是否存在需要获取的缺失对象，并获取它们，尤其是在不使用
    `git sparse-checkout` 时，可以使用以下命令：

   ```shell
   # 显示缺失的对象
   git rev-list --objects --all --missing=print | grep -e '^\?'

   # 显示前面没有 '?' 字符的缺失对象 (需要 GNU grep)
   git rev-list --objects --all --missing=print | grep -oP '^\?\K\w+'

   # 获取缺失的对象
   git fetch origin $(git rev-list --objects --all --missing=print | grep -oP '^\?\K\w+')

   # 显示缺失对象的数量
   git rev-list --objects --all --missing=print | grep -e '^\?' | wc -l
   ```

1.  重新打包所有内容。例如，可以使用 `git repack -a -d` 来完成。这应该
    只在 `.git/objects/pack/` 中留下三个文件：
    - 一个 `pack-<SHA1>.pack` 文件。
    - 其对应的 `pack-<SHA1>.idx` 文件。
    - 一个 `pack-<SHA1>.promisor` 文件。

1.  删除 `.promisor` 文件。上一步应该只留下一个
    `pack-<SHA1>.promisor` 文件，该文件应为空，应当删除。
1.  移除部分克隆配置。应从 Git 配置文件中移除与部分克隆相关的配置
    变量。通常只需要移除以下配置：
    - `remote.origin.promisor`。
    - `remote.origin.partialclonefilter`。