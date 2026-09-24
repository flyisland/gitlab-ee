---
stage: AI-powered
group: Editor Extensions
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab 远程 URL 格式
---

在 VS Code 中，您可以克隆 Git 仓库或以只读模式浏览它们。

极狐GitLab 远程 URL 需要以下参数：

- `instanceUrl`：极狐GitLab 实例 URL，不包含 `https://` 或 `http://`。
  - 如果极狐GitLab 实例[使用了相对 URL](../../install/relative_url.md)，请在 URL 中包含此相对 URL。
  - 例如，`example.com/gitlab` 实例上项目 `templates/ui` 的 `main` 分支的 URL 为：
    `gitlab-remote://example.com/gitlab/<label>?project=templates/ui&ref=main`。
- `label`：Visual Studio Code 用作此工作区文件夹名称的文本：
  - 必须紧跟在实例 URL 之后。
  - 不能包含未转义的 URL 组成部分，例如 `/` 或 `?`。
  - 对于安装在域名根目录的实例，例如 `https://gitlab.com`，此标签必须是第一个路径元素。
  - 对于指向仓库根目录的 URL，此标签必须是最后一个路径元素。
  - VS Code 会将出现在标签之后的任何路径元素视为仓库内的路径。例如，
    `gitlab-remote://gitlab.com/GitLab/app?project=gitlab-org/gitlab&ref=master` 指向了 GitLab.com 上
    `gitlab-org/gitlab` 仓库的 `app` 目录。
- `projectId`：可以是项目的数字 ID（例如 `5261717`）或命名空间（例如 `gitlab-org/gitlab-vscode-extension`）。
  如果您的实例使用了反向代理，请使用数字 ID 指定 `projectId`。更多信息，请参见
  [issue 18775](https://gitlab.com/gitlab-org/gitlab/-/issues/18775)。
- `gitReference`：仓库分支或提交 SHA。

然后，将这些参数按以下顺序组合在一起：

```plaintext
gitlab-remote://<instanceUrl>/<label>?project=<projectId>&ref=<gitReference>
```

例如，主极狐GitLab 项目的 `projectId` 是 `278964`，因此主极狐GitLab 项目的远程 URL 为：

```plaintext
gitlab-remote://gitlab.com/<label>?project=278964&ref=master
```

## 克隆 Git 项目

适用于 VS Code 的极狐GitLab 扩展了 `Git：Clone` 命令。对于极狐GitLab 项目，它支持使用 HTTPS 或 Git URL 进行克隆。

前提条件：

- 要从极狐GitLab 实例返回搜索结果，您必须已为该极狐GitLab 实例[添加了一个访问令牌](setup.md#authenticate-with-gitlab)。
- 您必须是项目的成员，搜索才能将其作为结果返回。

要搜索并克隆一个极狐GitLab 项目：

1. 通过按以下键打开命令面板：
   - MacOS：<kbd>Command</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd>。
   - Windows：<kbd>Control</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd>。
1. 运行 **Git：Clone** 命令。
1. 选择 GitHub 或 GitLab 作为仓库来源。
1. 搜索并选择一个 **仓库名称**。
1. 选择一个本地文件夹来存放克隆的仓库。
1. 如果是克隆极狐GitLab 仓库，请选择克隆方法：
   - 要使用 Git 克隆，请选择以 `user@hostname.com` 开头的 URL。
   - 要使用 HTTPS 克隆，请选择以 `https://` 开头的 URL。此方法使用您的访问令牌来克隆仓库、获取提交和推送提交。
1. 选择是打开克隆的仓库，还是将其添加到当前工作区。

## 以只读模式浏览仓库

使用此扩展，您可以在不克隆的情况下，以只读模式浏览极狐GitLab 仓库。

前提条件：

- 您已为该极狐GitLab 实例[注册了一个访问令牌](setup.md#authenticate-with-gitlab)。

要以只读模式浏览极狐GitLab 仓库：

1. 通过按以下键打开命令面板：
   - MacOS：<kbd>Command</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd>。
   - Windows：<kbd>Control</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd>。
1. 运行 **极狐GitLab：Open Remote Repository** 命令。
1. 选择 **在当前窗口打开**、**在新窗口打开** 或 **添加到工作区**。
1. 要添加仓库，选择 `Enter gitlab-remote URL`，然后为您想要的项目输入 `gitlab-remote://` URL。
1. 要查看已添加的仓库，选择 **选择一个项目**，然后从下拉列表中选择您想要的项目。
1. 在下拉列表中，选择您要查看的 Git 分支，然后按 <kbd>Enter</kbd> 确认。

要将 `gitlab-remote` URL 添加到您的工作区文件，请参阅 VS Code 文档中的
[工作区文件](https://code.visualstudio.com/docs/editor/multi-root-workspaces#_workspace-file)。
 