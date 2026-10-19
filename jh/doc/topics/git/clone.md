---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 了解如何使用不同协议（SSH 或 HTTPS）和各种 IDE 从极狐GitLab 服务器克隆 Git 代码仓库。
title: 将 Git 代码仓库克隆到本地计算机
---

您可以将 Git 代码仓库克隆到本地计算机。此操作会创建代码仓库的副本，并建立连接，在您的计算机与极狐GitLab 服务器之间同步更改。此连接需要您添加凭据。您可以[使用 SSH 克隆](#clone-with-ssh)或[使用 HTTPS 克隆](#clone-with-https)。SSH 是推荐的认证方式。

克隆代码仓库会：

- 将所有项目文件、历史和元数据下载到您的本地计算机。
- 创建一个包含最新版本文件的工作目录。
- 设置远程跟踪，以同步未来的更改。
- 提供对完整代码库的离线访问。
- 为向项目回馈代码奠定基础。

<a id="clone-with-ssh"></a>

## 使用 SSH 克隆

当您只想认证一次时，请使用 SSH 克隆。

1. 按照 [SSH 文档](../../user/ssh.md)中的说明，通过极狐GitLab 进行认证。
1. 在顶部栏中，选择**搜索或跳转到**，找到您要克隆的项目。
1. 在项目概览页面的右上角，选择**代码**，然后复制**使用 SSH 克隆**的 URL。
1. 打开终端，进入您要克隆文件的目录。
   Git 会自动创建一个以代码仓库命名的文件夹，并将文件下载到该文件夹中。
1. 运行以下命令：

   ```shell
   git clone <copied URL>
   ```

1. 要查看文件，请进入新目录：

   ```shell
   cd <new directory>
   ```

<a id="clone-with-https"></a>

## 使用 HTTPS 克隆

当您在计算机与极狐GitLab 之间执行每次操作都需要认证时，请使用 HTTPS 克隆。[OAuth 凭据助手](../../user/profile/account/two_factor_authentication.md#oauth-credential-helpers)可以减少您必须手动认证的次数，让 HTTPS 体验更加顺畅。

1. 在顶部栏中，选择**搜索或跳转到**，找到您要克隆的项目。
1. 在项目概览页面的右上角，选择**代码**，然后复制**使用 HTTPS 克隆**的 URL。
1. 打开终端，进入您要克隆文件的目录。
1. 运行以下命令。Git 会自动创建一个以代码仓库命名的文件夹，并将文件下载到该文件夹中。

   ```shell
   git clone <copied URL>
   ```

1. 对您的请求进行认证。

   > [!note]
   > 如果您已启用双因素认证 (2FA)，则无法使用用户名和密码认证。请改为：
   >
   > - [使用令牌](#clone-using-a-token)，并授予 `read_repository` 或 `write_repository` 权限。
   > - 安装 [OAuth 凭据助手](../../user/profile/account/two_factor_authentication.md#oauth-credential-helpers)

1. 要查看文件，请进入新目录：

   ```shell
   cd <new directory>
   ```

> [!note]
> 在 Windows 上，如果您多次输入错误的密码并出现 `Access denied` 消息，
> 请将您的命名空间（用户名或群组）添加到路径中：
> `git clone https://namespace@gitlab.com/gitlab-org/gitlab.git`。

<a id="clone-using-a-token"></a>

### 使用令牌克隆

在以下情况下，请使用令牌通过 HTTPS 克隆：

- 您想使用 2FA。
- 您希望拥有一组可撤销的、限定在一个或多个代码仓库范围内的凭据。

通过 HTTPS 克隆时，您可以使用以下任意令牌进行认证：

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

包含 `.xcodeproj` 或 `.xcworkspace` 目录的项目可以克隆
到 macOS 上的 Xcode 中。

1. 在极狐GitLab UI 中，进入项目概览页面。
1. 在右上角，选择**代码**。
1. 选择 **Xcode**。

项目会克隆到您的计算机上，并提示您打开 Xcode。

<a id="clone-and-open-in-visual-studio-code"></a>

## 克隆并在 Visual Studio Code 中打开

所有项目都可以从极狐GitLab 用户界面克隆到 Visual Studio Code 中，但您
也可以安装 [GitLab for VS Code 扩展](../../editor_extensions/visual_studio_code/_index.md)，以便从
Visual Studio Code 中克隆。

先决条件：

- 您的本地计算机上必须安装 [Visual Studio Code](https://code.visualstudio.com/)。
  不支持其他版本的 VS Code，例如 VS Code Insiders 和 VSCodium。
- [为 IDE 协议配置浏览器](#configure-browsers-for-ide-protocols)。
- 在极狐GitLab 界面中：
  1. 进入项目概览页面。
  1. 在右上角，选择**代码**。
  1. 在**在您的 IDE 中打开**下，选择 **Visual Studio Code (SSH)** 或 **Visual Studio Code (HTTPS)**。
  1. 选择一个文件夹，将项目克隆到其中。

     Visual Studio Code 克隆项目后，会打开该文件夹。
- 在 Visual Studio Code 中，安装[扩展](../../editor_extensions/visual_studio_code/_index.md)后，使用
  该扩展的 [`Git: Clone` 命令](../../editor_extensions/visual_studio_code/remote_urls.md#clone-a-git-project)。

<a id="clone-and-open-in-intellij-idea"></a>

## 克隆并在 IntelliJ IDEA 中打开

所有项目都可以从极狐GitLab 用户界面克隆到 [IntelliJ IDEA](https://www.jetbrains.com/idea/)
中。

先决条件：

- 您的本地计算机上必须安装 [IntelliJ IDEA](https://www.jetbrains.com/idea/)。
- [为 IDE 协议配置浏览器](#configure-browsers-for-ide-protocols)。

操作步骤：

1. 进入项目概览页面。
1. 在右上角，选择**代码**。
1. 在**在您的 IDE 中打开**下，选择 **IntelliJ IDEA (SSH)** 或 **IntelliJ IDEA (HTTPS)**。

<a id="configure-browsers-for-ide-protocols"></a>

## 为 IDE 协议配置浏览器

为确保**在 IDE 中打开**功能正常工作，您必须配置浏览器以处理自定义应用程序协议，例如 `vscode://` 或 `jetbrains://`。

<a id="firefox"></a>

### Firefox

如果您的系统上安装了所需的应用程序，Firefox 会自动处理自定义协议。当您首次选择自定义协议链接时，会打开一个对话框，询问您是否要打开该应用程序。选择**打开链接**，允许 Firefox 打开该应用程序。

如果您不想再次收到提示，请选中复选框以记住您的选择。

如果提示对话框没有打开，您需要手动配置 Firefox：

1. 打开 Firefox。
1. 在右上角，选择**打开应用程序菜单** ({{< icon name="hamburger" >}})。
1. 搜索或转到**应用程序**部分。
1. 在列表中找到并选择您想要的应用程序。例如，`vscode` 或 `jetbrains`。
1. 从下拉列表中选择 Visual Studio Code 或 IntelliJ IDEA，或选择**使用其他...** 来定位可执行文件。

如果您首选的 IDE 未列出，则在您首次选择相应链接时，系统会提示您选择一个应用程序。

<a id="chrome"></a>

### Chrome

如果您的系统上安装了所需的应用程序，Chrome 会自动处理自定义协议。当您在 Chrome 中首次选择自定义协议链接时，会打开一个对话框，询问您是否要打开该应用程序。选择**打开**，允许 Chrome 打开该应用程序。

如果您不想再次收到提示，请选中复选框以记住您的选择。

<a id="reduce-clone-size"></a>

## 减小克隆大小

随着 Git 代码仓库规模的增长，由于以下原因，它们可能会变得难以使用：

- 必须下载大量历史记录。
- 它们需要占用大量磁盘空间。

[部分克隆](https://git-scm.com/docs/partial-clone)是一种性能优化，允许 Git 在没有代码仓库完整副本的情况下运行。这项工作的目标是让 Git 更好地处理超大型代码仓库。

需要 Git 2.22.0 或更高版本。

<a id="filter-by-file-size"></a>

### 按文件大小筛选

通常不建议在 Git 中存储大型二进制文件，因为此后每个克隆或获取更改的人都会下载添加的每个大文件。这些下载速度缓慢且问题重重，尤其是在网络连接缓慢或不稳定的情况下工作时。

使用带文件大小筛选的部分克隆可以解决此问题，它会将麻烦的大文件从克隆和获取中排除。当 Git 遇到缺失的文件时，会按需下载。

克隆代码仓库时，请使用 `--filter=blob:limit=<size>` 参数。例如，要克隆代码仓库并排除大于 1 兆字节的文件：

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

输出更长，因为 Git 会：

1. 克隆代码仓库，排除大于 1 兆字节的文件。
1. 下载检出默认分支所需的任何缺失的大文件。

切换分支时，Git 可能会下载更多缺失的文件。

<a id="filter-by-object-type"></a>

### 按对象类型筛选

对于包含数百万个文件和漫长历史的代码仓库，您可以排除所有文件，并使用 [`git sparse-checkout`](https://git-scm.com/docs/git-sparse-checkout) 来减小工作副本的大小。

```shell
# Clone the repo excluding all files
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

更多详情，请参阅 Git 文档中关于 [`sparse-checkout`](https://git-scm.com/docs/git-sparse-checkout)的内容。

<a id="filter-by-file-path"></a>

### 按文件路径筛选

通过 `--filter=sparse:oid=<blob-ish>` 筛选规范，可以实现部分克隆与稀疏检出之间更深入的集成。这种筛选模式使用类似于 `.gitignore` 文件的格式，来指定克隆和获取时要包含哪些文件。

> [!warning]
> 使用 `sparse` 筛选的部分克隆仍处于实验阶段。它可能速度缓慢，并显著增加
> 克隆和获取时的 [Gitaly](../../administration/gitaly/_index.md) 资源占用。
> 请改为[筛选所有 blob 并使用稀疏检出](#filter-by-object-type)，因为
> [`git-sparse-checkout`](https://git-scm.com/docs/git-sparse-checkout) 简化了
> 这种部分克隆的用法，并克服了其局限性。

更多详情，请参阅 Git 文档中关于 [`rev-list-options`](https://git-scm.com/docs/git-rev-list#Documentation/git-rev-list.txt---filterltfilter-specgt)的内容。

1. 创建筛选规范。例如，考虑一个包含许多应用程序的单体代码仓库，
   每个应用程序位于根目录下的不同子目录中。创建一个文件 `shiny-app/.filterspec`：

   ```plaintext
   # Only the paths listed in the file will be downloaded when performing a
   # partial clone using `--filter=sparse:oid=shiny-app/.gitfilterspec`

   # Explicitly include filterspec needed to configure sparse checkout with
   # git config --local core.sparsecheckout true
   # git show master:snazzy-app/.gitfilterspec >> .git/info/sparse-checkout
   shiny-app/.gitfilterspec

   # Shiny App
   shiny-app/

   # Dependencies
   shimmery-app/
   shared-component-a/
   shared-component-b/
   ```

1. 按路径克隆并筛选。使用克隆命令的 `--filter=sparse:oid`
   支持尚未与稀疏检出完全集成。

   ```shell
   # Clone the filtered set of objects using the filterspec stored on the
   # server. WARNING: this step may be very slow!
   git clone --sparse --filter=sparse:oid=master:shiny-app/.gitfilterspec <url>

   # Optional: Check for missing objects that have not been fetched
   git rev-list --all --quiet --objects --missing=print | wc -l
   ```

   > [!warning]
   > Git 与 `bash`、Zsh 等的集成，以及自动
   > 显示 Git 状态信息的编辑器，通常会运行 `git fetch`，从而获取
   > 整个代码仓库。可能需要禁用或重新配置这些集成。

<a id="remove-partial-clone-filtering"></a>

### 移除部分克隆筛选

带有部分克隆筛选的 Git 代码仓库可以移除筛选。要移除筛选：

1. 获取所有被筛选排除的内容，以确保
   代码仓库完整。如果使用了 `git sparse-checkout`，请使用
   `git sparse-checkout disable` 将其禁用。更多信息请参阅
   [`disable` 文档](https://git-scm.com/docs/git-sparse-checkout#Documentation/git-sparse-checkout.txt-emdisableem)。

   然后执行常规的 `fetch`，以确保代码仓库完整。要检查是否
   有缺失的对象需要获取，然后获取它们，尤其是在不使用
   `git sparse-checkout` 时，可以使用以下命令：

   ```shell
   # Show missing objects
   git rev-list --objects --all --missing=print | grep -e '^\?'

   # Show missing objects without a '?' character before them (needs GNU grep)
   git rev-list --objects --all --missing=print | grep -oP '^\?\K\w+'

   # Fetch missing objects
   git fetch origin $(git rev-list --objects --all --missing=print | grep -oP '^\?\K\w+')

   # Show number of missing objects
   git rev-list --objects --all --missing=print | grep -e '^\?' | wc -l
   ```

1. 重新打包所有内容。例如，可以使用 `git repack -a -d` 来完成。这
   应使 `.git/objects/pack/` 中只留下三个文件：
   - 一个 `pack-<SHA1>.pack` 文件。
   - 其对应的 `pack-<SHA1>.idx` 文件。
   - 一个 `pack-<SHA1>.promisor` 文件。

1. 删除 `.promisor` 文件。上一步应只留下一个
   `pack-<SHA1>.promisor` 文件，该文件应为空，应将其删除。
1. 移除部分克隆配置。与部分克隆相关的配置
   变量应从 Git 配置文件中移除。通常只需移除以下
   配置：
   - `remote.origin.promisor`。
   - `remote.origin.partialclonefilter`。
