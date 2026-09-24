---
stage: AI-powered
group: Editor Extensions
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Connect and use 极狐GitLab Duo in Neovim.
title: Neovim 故障排除
---

在排查 Neovim 的极狐GitLab 插件问题时，您应确认该问题是在与其他 Neovim 插件和设置隔离的情况下发生的。首先，运行 Neovim [测试步骤](#test-your-neovim-configuration)，然后执行极狐GitLab Duo 代码建议的故障排除步骤。

<a id="test-your-neovim-configuration"></a>

## 测试你的 Neovim 配置

Neovim 插件的维护者通常在故障排除过程中要求提供这些检查的结果：

1. 确保您已[生成帮助标签](#generate-help-tags)。
2. 运行 [`:checkhealth`](#run-checkhealth)。
3. 启用[调试日志](#enable-debug-logs)。
4. 尝试[在最小项目中重现问题](#reproduce-the-problem-in-a-minimal-project)。

<a id="generate-help-tags"></a>

### 生成帮助标签

如果您看到错误 `E149: Sorry, no help for gitlab.txt`，则需要在 Neovim 中生成帮助标签。要解决此问题：

- 运行以下任一命令：
  - `:helptags ALL`
  - 从插件的根目录运行 `:helptags doc/`

<a id="run-checkhealth"></a>

### 运行 `:checkhealth`

运行 `:checkhealth gitlab*` 以获取当前会话配置的诊断信息。这些检查可帮助您自行识别和解决配置问题。

<a id="enable-debug-logs"></a>

## 启用调试日志

启用调试日志以捕获有关问题的更多信息。调试日志可能包含敏感的工作区配置，因此在与他人共享之前请检查输出。

要启用额外日志记录：

- 在当前缓冲区中设置 `vim.lsp` 日志级别：

  ```lua
  :lua vim.lsp.set_log_level('debug')
  ```

<a id="reproduce-the-problem-in-a-minimal-project"></a>

## 在最小项目中重现问题

为帮助项目维护者理解和解决您的问题，请创建一个可重现问题的示例配置或项目。例如，在排查代码建议问题时：

1. 创建一个示例项目：

   ```plaintext
   mkdir issue-25
   cd issue-25
   echo -e "def hello(name)\n\nend" > hello.rb
   ```

2. 创建一个名为 `minimal.lua` 的新文件，内容如下：

   ```lua
   -- 注意：请勿在常规配置中设置此项，因为此日志级别
   -- 可能包含敏感的工作区配置。
   vim.lsp.set_log_level('debug')

   vim.opt.rtp:append('$HOME/.local/share/nvim/site/pack/gitlab/start/gitlab.vim')

   vim.cmd('runtime plugin/gitlab.lua')

   -- gitlab.config 选项覆盖：
   local minimal_user_options = {}
   require('gitlab').setup(minimal_user_options)
   ```

3. 在最小化 Neovim 会话中，编辑 `hello.rb`：

   ```shell
   nvim --clean -u minimal.lua hello.rb
   ```

4. 尝试重现您遇到的行为。根据需要调整 `minimal.lua` 或其他项目文件。
5. 查看 `~/.local/state/nvim/lsp.log` 中的最近条目并捕获相关输出。
6. 编辑掉任何对敏感信息的引用，例如以 `glpat-` 开头的令牌。
7. 从任何 Vim 寄存器或日志文件中删除敏感信息。

<a id="error-gcsunavailable"></a>

### 错误：`GCS:unavailable`

当您的本地项目未在 `.git/config` 中设置远程时，会发生此错误。

要解决此问题：使用 [`git remote add`](../../topics/git/commands.md#git-remote-add) 在本地项目中添加一个 Git 远程。