---
stage: AI-powered
group: Editor Extensions
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.jihulab.com/handbook/product/ux/technical-writing/#assignments>
description: Connect and use 极狐 GitLab Duo in Neovim.
title: 极狐 GitLab Neovim 插件 - `gitlab.vim`
---

[极狐 GitLab 插件](https://jihulab.com/gitlab-cn/editor-extensions/gitlab.vim) 是一个基于 Lua 的插件，它将 极狐 GitLab 与 Neovim 集成在一起。

该插件允许你在命令行中使用 极狐 GitLab Duo 代码建议。

要安装和配置扩展，请参阅 [安装和设置](setup.md)。

<a id="disable-gitlabstatusline"></a>

## 禁用 `gitlab.statusline`

默认情况下，此插件启用 `gitlab.statusline`，它使用内置的 `statusline` 来显示 极狐 GitLab Duo 代码建议集成的状态。如果要禁用 `gitlab.statusline`，请将以下内容添加到你的配置中：

```lua
require('gitlab').setup({
  statusline = {
    enabled = false
  }
})
```

<a id="disable-started-code-suggestions-lsp-integration-messages"></a>

## 禁用 `已启动代码建议 LSP 集成` 消息

要更改最低消息级别，请将以下内容添加到你的配置中：

```lua
require('gitlab').setup({
  minimal_message_level = vim.log.levels.ERROR,
})
```

<a id="update-the-extension"></a>

## 更新扩展

要更新 `gitlab.vim` 插件，请使用 `git pull` 或你特定的 Vim 插件管理器。

<a id="report-issues-with-the-extension"></a>

## 报告扩展的问题

在 [`gitlab.vim` 议题跟踪器](https://jihulab.com/gitlab-cn/editor-extensions/gitlab.vim/-/issues) 中报告任何议题、错误或功能请求。

在 `gitlab.vim` 代码仓中的 [议题 22](https://jihulab.com/gitlab-cn/editor-extensions/gitlab.vim/-/issues/22) 提交你的反馈。
