---
stage: AI Clients
group: Developer Clients
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 在 Neovim 中连接并使用极狐GitLab Duo。
title: 安装并设置 Neovim 的极狐GitLab 插件
---

{{< details >}}

- Tier: [基础版](../../subscriptions/gitlab_credits.md#for-the-free-tier)、专业版、旗舰版
- Offering: JihuLab.com、私有化部署

{{< /details >}}

先决条件：

- 对于 JihuLab.com 和极狐GitLab 私有化部署，您需要极狐GitLab 16.1 或更高版本。
  虽然许多扩展功能可能在更早的版本上运行，但不受支持。
  - 极狐GitLab Duo 代码建议功能需要极狐GitLab 16.8 或更高版本。
- 您需要 [Neovim](https://neovim.io/) 0.9 或更高版本。
- 您需要安装 [NPM](https://docs.npmjs.com/downloading-and-installing-node-js-and-npm/)。安装代码建议需要 NPM。
- 对于代码建议，您需要满足[其他先决条件](../../user/project/repository/code_suggestions/set_up.md#prerequisites)。

要安装该扩展，请按照您所选插件管理器的安装步骤操作：

{{< tabs >}}

{{< tab title="No plugin manager" >}}

运行以下命令，以便在启动时通过
[`packadd`](https://neovim.io/doc/user/repeat.html#%3Apackadd) 包含此项目：

```shell
git clone https://gitlab.com/gitlab-org/editor-extensions/gitlab.vim.git ~/.local/share/nvim/site/pack/gitlab/start/gitlab.vim
```

{{< /tab >}}

{{< tab title="`lazy.nvim`" >}}

将此插件添加到您的 [lazy.nvim](https://github.com/folke/lazy.nvim) 配置中：

```lua
{
  'https://gitlab.com/gitlab-org/editor-extensions/gitlab.vim.git',
  -- Activate when a file is created/opened
  event = { 'BufReadPre', 'BufNewFile' },
  -- Activate when a supported filetype is open
  ft = { 'go', 'javascript', 'python', 'ruby' },
  cond = function()
    -- Only activate if token is present in environment variable.
    -- Remove this line to use the interactive workflow.
    return vim.env.GITLAB_TOKEN ~= nil and vim.env.GITLAB_TOKEN ~= ''
  end,
  opts = {
    statusline = {
      -- Hook into the built-in statusline to indicate the status
      -- of the GitLab Duo Code Suggestions integration
      enabled = true,
    },
  },
}
```

{{< /tab >}}

{{< tab title="`packer.nvim`" >}}

在您的 [packer.nvim](https://github.com/wbthomason/packer.nvim) 配置中声明该插件：

```lua
use {
  "git@gitlab.com:gitlab-org/editor-extensions/gitlab.vim.git",
}
```

{{< /tab >}}

{{< /tabs >}}

<a id="authenticate-with-gitlab"></a>

## 使用极狐GitLab 进行身份验证

要将此扩展连接到您的极狐GitLab 账号，请配置您的环境变量：

| 环境变量 | 默认值 | 描述 |
|----------------------|----------------------|-------------|
| `GITLAB_TOKEN`       | 不适用       | 用于已认证请求的默认极狐GitLab 个人访问令牌。如果提供，则跳过交互式身份验证。 |
| `GITLAB_VIM_URL`     | `https://gitlab.com` | 覆盖要连接的极狐GitLab 实例。默认为 `https://gitlab.com`。 |

完整的环境变量列表可在扩展的帮助文本 [`doc/gitlab.txt`](https://gitlab.com/gitlab-org/editor-extensions/gitlab.vim/-/blob/main/doc/gitlab.txt)中找到。

<a id="configure-the-extension"></a>

## 配置扩展

代码建议默认开启，但您需要配置其他设置才能开始使用它。

要配置此扩展：

1. 配置您所需的文件类型。例如，由于此插件支持 Ruby，它会添加一个 `FileType ruby` 自动命令。
   要为更多文件类型配置此行为，请将更多文件类型添加到 `code_suggestions.auto_filetypes` 设置选项中：

   ```lua
   require('gitlab').setup({
     statusline = {
       enabled = false
     },
     code_suggestions = {
       -- For the full list of default languages, see the 'auto_filetypes' array in
       -- https://gitlab.com/gitlab-org/editor-extensions/gitlab.vim/-/blob/main/lua/gitlab/config/defaults.lua
       auto_filetypes = { 'ruby', 'javascript' }, -- Default is { 'ruby' }
       ghost_text = {
         enabled = false, -- ghost text is an experimental feature
         toggle_enabled = "<C-h>",
         accept_suggestion = "<C-l>",
         clear_suggestions = "<C-k>",
         stream = true,
       },
     }
   })
   ```

1. [配置 Omni Completion](#configure-omni-completion) 以设置触发代码建议的按键映射。
1. 可选。[配置 `<Plug>` 按键映射](#configure-plug-key-mappings)。
1. 可选。使用 `:helptags ALL` 设置帮助标签，以便访问
   [`:help gitlab.txt`](https://gitlab.com/gitlab-org/editor-extensions/gitlab.vim/-/blob/main/doc/gitlab.txt)。

<a id="configure-omni-completion"></a>

### 配置 Omni Completion

要结合代码建议启用 [Omni Completion](https://neovim.io/doc/user/insert.html#compl-omni-filetypes)：

1. 创建一个具有 `api` 范围的[个人访问令牌](../../user/profile/personal_access_tokens.md#create-a-personal-access-token)。
1. 将该令牌作为 `GITLAB_TOKEN` 环境变量添加到您的 shell 中。
1. 通过运行 `:GitLabCodeSuggestionsInstallLanguageServer` vim 命令，安装代码建议[语言服务器](https://gitlab.com/gitlab-org/editor-extensions/gitlab-lsp)。
1. 通过运行 `:GitLabCodeSuggestionsStart` vim 命令启动语言服务器。可选，[配置 `<Plug>` 按键映射](#configure-plug-key-mappings)以切换语言服务器。
1. 可选。即使只有一个建议，也可以考虑配置 Omni Completion 的对话框：

   ```lua
   vim.o.completeopt = 'menu,menuone'
   ```

在受支持的文件类型中工作时，按 <kbd>Control</kbd>+<kbd>x</kbd>
然后按 <kbd>Control</kbd>+<kbd>o</kbd> 打开 Omni Completion 菜单。

代码建议提供 Language Server Protocol (LSP) 服务器，以支持内置的
<kbd>Control</kbd>+<kbd>x</kbd>、<kbd>Control</kbd>+<kbd>o</kbd> Omni Completion 按键映射：

| 模式     | 按键映射                          | 类型      | 描述 |
|----------|---------------------------------------|-----------|-------------|
| `INSERT` | <kbd>Control</kbd>+<kbd>x</kbd>、<kbd>Control</kbd>+<kbd>o</kbd> | 内置 | 通过语言服务器从极狐GitLab Duo 代码建议请求补全。 |
| `NORMAL` | `<Plug>(GitLabToggleCodeSuggestions)` | `<Plug>`  | 为当前缓冲区开启或关闭代码建议。需要[配置](#configure-plug-key-mappings)。 |

<a id="turn-code-suggestions-on-or-off"></a>

### 开启或关闭代码建议

代码建议默认开启。

要开启或关闭代码建议：

1. 转到 [Neovim `defaults.lua` 设置文件](https://gitlab.com/gitlab-org/editor-extensions/gitlab.vim/-/blob/main/lua/gitlab/config/defaults.lua)。
1. 在 `code_suggestions` 下，将 `enabled` 标志设置为 `true` 或 `false`。

   例如，要关闭建议：

   ```lua
   code_suggestions = {
   ...
    enabled = false,
   ```

要为单个缓冲区而非全局开启或关闭代码建议，请[配置 `<Plug>` 按键映射](#configure-plug-key-mappings)。

<a id="configure-plug-key-mappings"></a>

## 配置 `<Plug>` 按键映射

为方便起见，此插件提供了 `<Plug>` 按键映射。要使用 `<Plug>(GitLab...)` 按键映射，您需要自行添加一个引用它的按键映射：

```lua
-- Toggle Code Suggestions on/off with Control-G in normal mode:
vim.keymap.set('n', '<C-g>', '<Plug>(GitLabToggleCodeSuggestions)')
```

<a id="uninstall-the-extension"></a>

## 卸载扩展

要卸载该扩展，请使用以下命令移除此插件以及任何语言服务器二进制文件：

```shell
rm -r ~/.local/share/nvim/site/pack/gitlab/start/gitlab.vim
rm ~/.local/share/nvim/gitlab-code-suggestions-language-server-*
```
