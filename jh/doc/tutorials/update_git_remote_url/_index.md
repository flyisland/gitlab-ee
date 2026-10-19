---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: '教程：更新 Git 远程 URL'
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

在以下情况下，请更新您的 Git 远程 URL：

- 您从其他 Git 代码仓库托管平台导入了现有项目。
- 您的组织已将项目迁移到具有新域名的新极狐GitLab 实例。
- 项目在同一极狐GitLab 实例中被重命名为新路径。

> [!note]
> 如果您没有来自旧远程的现有本地工作副本，则无需本教程。
> 您可以改为从新的极狐GitLab URL 克隆项目。

本教程介绍如何更新本地代码仓库的远程 URL，同时不会：

- 丢失任何未完成的本地更改。
- 丢失尚未发布到极狐GitLab 的更改。
- 从新 URL 创建新的克隆工作副本。

本教程使用 `git-remote` 命令来
[管理远程和跟踪代码仓库](https://git-scm.com/docs/git-remote)。

要更新 Git 远程 URL：

- [确定现有 URL 和新 URL](#determine-existing-and-new-urls)
- [更新 Git 远程 URL](#update-git-remote-urls)
- [（可选）保留原始远程 URL](#optional-keep-original-remote-urls)

<a id="before-you-begin"></a>

## 开始之前

您必须具备：

- 一个带有 Git 代码仓库和新极狐GitLab URL 的极狐GitLab 项目。
- 一个已克隆的本地工作副本，即您要迁移到新极狐GitLab URL 的项目。
- 在本地机器上[安装 Git](../../topics/git/how_to_install_git/_index.md)。
- 能够访问本地机器的命令行界面（CLI）。在 macOS 上，
  您可以使用终端。在 Windows 上，您可以使用 PowerShell。Linux 用户可能
  已经熟悉其系统的 CLI。
- 极狐GitLab 的身份验证凭据：
  - 您必须通过极狐GitLab 进行身份验证才能更新 Git 远程 URL。如果您的极狐GitLab 账号使用
    基本用户名和密码身份验证，则必须禁用[双重身份验证（2FA）](../../user/profile/account/two_factor_authentication.md)
    才能从 CLI 进行身份验证。或者，您可以[使用 SSH 密钥向极狐GitLab 进行身份验证](../../user/ssh.md)。

<a id="determine-existing-and-new-urls"></a>

## 确定现有 URL 和新 URL

要更新 Git 远程 URL，请确定代码仓库的现有 URL 和新 URL：

1. 打开终端或命令提示符。
1. 转到您的本地代码仓库工作副本。要更改目录，请使用 `cd`：

   ```shell
   cd <repository-name>
   ```

1. 每个代码仓库都有一个名为 `origin`的默认远程。要查看远程代码仓库当前的远程 _fetch_ 和 _push_ URL，
   请运行：

   ```shell
   git remote -v
   ```

1. 复制并记下返回的 URL。它们通常相同。
1. 获取新 URL：
   1. 转到极狐GitLab。
   1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
   1. 在左侧边栏中，选择**代码** > **代码仓库**，以转到项目的**代码仓库**页面
   1. 在右上角，选择**代码**
   1. 根据您使用 `git` 进行身份验证和克隆的方法，
      复制 HTTPS 或 SSH URL。如果不确定，请使用与上一步中 `origin` URL 相同的方法。
   1. 记下复制的 URL。

<a id="update-git-remote-urls"></a>

## 更新 Git 远程 URL

要更新 Git 远程 URL：

1. 打开终端或命令提示符。
1. 转到您的本地代码仓库工作副本。要更改目录，请使用 `cd`：

   ```shell
   cd <repository-name>
   ```

1. 更新远程 URL，将 `<new_url>` 替换为您复制的新代码仓库 URL：

   ```shell
   git remote set-url origin <new_url>
   ```

1. 验证远程 URL 更新是否成功。
   以下命令会显示 fetch 和 push 操作的新 URL，
   列出本地分支，并确认它们已跟踪到极狐GitLab：

   ```shell
   git remote show origin
   ```

   - 如果更新失败，请返回上一步，确保您
     拥有正确的 `<new_url>`，然后重试。

要更新多个代码仓库的远程 URL：

1. 使用 `git remote set-url` 命令。将 `origin` 替换为您要更新的
   远程的名称。例如：

   ```shell
   git remote set-url <remote_name> <new_url>
   ```

1. 验证每个远程 URL 的更新：

   ```shell
   git remote show <remote_name>
   ```

更新远程 URL 后，您可以照常继续使用 Git 命令。您下一次执行 `git fetch`、`git pull` 或 `git push` 时，将使用极狐GitLab 中的新 URL。

恭喜，您已成功更新代码仓库的远程 URL。

<a id="optional-keep-original-remote-urls"></a>

## （可选）保留原始远程 URL

您的项目可能有多个远程位置。例如，您有一个从 GitHub 上托管的项目 forked 而来的代码仓库，但您希望在向 GitHub 发起拉取请求之前，先在极狐GitLab 中处理您的 fork。

要在更新远程 URL 的同时保留原始远程 URL，并同时维护新旧远程 URL，您可以添加一个新的远程，而不是修改现有的远程。

通过这种方法，您可以逐步过渡到新 URL，同时仍保持对原始代码仓库的访问。

要添加新的远程 URL：

1. 打开终端或命令提示符。
1. 转到您的本地代码仓库工作副本。
1. 添加新的远程 URL。将 `<new_remote_name>` 替换为新远程的名称，
   例如 `new-origin`，并将 `<new_url>` 替换为新代码仓库 URL：

   ```shell
   git remote add <new_remote_name> <new_url>
   ```

1. 验证新远程已添加：

   ```shell
   git remote -v
   ```

现在您可以同时使用原始远程和新远程。例如：

- 推送到原始远程：`git push origin main`
- 推送到新远程：`git push <new_remote_name> main`
