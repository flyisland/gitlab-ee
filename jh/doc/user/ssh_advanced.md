---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.jihulab.com/handbook/product/ux/technical-writing/#assignments>
title: 高级 SSH 密钥配置
description: Use SSH keys for secure authentication and communication with GitLab repositories.
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

配置高级 SSH 密钥选项以用于专业工作流。
> [!note]
> 有关基本 SSH 密钥用法，请参见[使用 SSH 密钥与极狐GitLab](ssh.md)。

<a id="generate-an-ssh-key-pair-for-a-fido2-hardware-security-key"></a>

## 生成 FIDO2 硬件安全密钥的 SSH 密钥对

要生成 ED25519_SK 或 ECDSA_SK SSH 密钥，你必须使用 OpenSSH 8.2 或更高版本：

1. 将硬件安全密钥插入你的计算机。
1. 打开终端。
1. 使用密钥类型和可选注释（有助于稍后标识该密钥）运行 `ssh-keygen -t`。常用做法是使用你的电子邮件地址作为注释。注释包含在 `.pub` 文件中。

   例如，对于 ED25519_SK：

   ```shell
   ssh-keygen -t ed25519-sk -C "<comment>"
   ```

   对于 ECDSA_SK：

   ```shell
   ssh-keygen -t ecdsa-sk -C "<comment>"
   ```

   如果你的安全密钥支持 FIDO2 驻留密钥，你可以在创建 SSH 密钥时启用此功能：

   ```shell
   ssh-keygen -t ed25519-sk -O resident -C "<comment>"
   ```

   `-O resident` 指示应将密钥存储在 FIDO 认证器本身上。驻留密钥更容易导入到新计算机，因为它可以直接通过 [`ssh-add -K`](https://man.openbsd.org/cgi-bin/man.cgi/OpenBSD-current/man1/ssh-add.1#K) 或 [`ssh-keygen -K`](https://man.openbsd.org/cgi-bin/man.cgi/OpenBSD-current/man1/ssh-keygen#K) 从安全密钥加载。

1. 按 <kbd>Enter</kbd>。将显示类似以下内容的输出：

   ```plaintext
   正在生成公钥/私钥 ed25519-sk 密钥对。
   你可能需要触摸认证器以授权密钥生成。
   ```

1. 触摸硬件安全密钥上的按钮。
1. 接受建议的文件名和目录：

   ```plaintext
   输入要保存密钥的文件 (/home/user/.ssh/id_ed25519_sk):
   ```

1. 指定[口令](https://www.ssh.com/academy/ssh/passphrase)：

   ```plaintext
   输入口令 (如果不需要口令则留空):
   再次输入相同口令:
   ```

   将显示一条确认信息，包括你的文件存储位置。

公钥和私钥已生成。
[将公钥 SSH 密钥添加到你的极狐GitLab 账户](ssh.md#add-an-ssh-key-to-your-gitlab-account)。

<a id="generate-an-ssh-key-pair-with-1password"></a>

## 使用 1Password 生成 SSH 密钥对

你可以使用 [1Password](https://1password.com/) 和 [1Password 浏览器扩展](https://support.1password.com/getting-started-browser/) 来执行以下任一操作：

- 自动生成新的 SSH 密钥。
- 使用 1Password 保管库中已有的 SSH 密钥对极狐GitLab 进行身份验证。

1. 登录极狐GitLab。
1. 在右上角，选择你的头像。
1. 选择 **编辑个人资料**。
1. 在左侧边栏中，选择 **访问** > **SSH 密钥**。
1. 选择 **添加新密钥**。
1. 选择 **密钥**，你应该会看到 1Password 助手出现。
1. 选择 1Password 图标并解锁 1Password。
1. 然后你可以选择 **创建 SSH 密钥** 或选择一个现有的 SSH 密钥来填充公钥。
1. 在 **标题** 框中，输入描述，例如 `Work Laptop` 或 `Home Workstation`。
1. 可选。选择密钥的 **用途类型**。它可以用于 `Authentication` 或 `Signing`，或同时用于两者。`Authentication & Signing` 是默认值。
1. 可选。更新 **到期日期** 以修改默认到期日期。
1. 选择 **添加密钥**。

有关将 1Password 与 SSH 密钥结合使用的更多信息，请参阅 [1Password 文档](https://developer.1password.com/docs/ssh/get-started/)。

<a id="disable-ssh-keys-for-enterprise-users"></a>

## 禁用企业用户的 SSH 密钥

{{< history >}}

- 在极狐GitLab 18.8 引入。

{{< /history >}}

先决条件：

- 你必须是企业用户所属群组的所有者角色。

禁用一个群组的[企业用户](enterprise_user/_index.md)的 SSH 密钥将：

- 阻止企业用户添加新的 SSH 密钥。
- 禁用企业用户现有的 SSH 密钥。

这也适用于作为群组管理员的企业用户。

要禁用企业用户的 SSH 密钥：

1. 在顶部栏中，选择 **搜索或跳转到** 并查找你的群组。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **权限和群组功能**。
1. 在 **企业用户** 下方，选择 **禁用 SSH 密钥**。
1. 选择 **保存更改**。

<a id="upgrade-your-rsa-key-pair-to-a-more-secure-format"></a>

## 将 RSA 密钥对升级到更安全的格式

如果你的 OpenSSH 版本介于 6.5 和 7.8 之间，你可以通过打开终端并运行以下命令，将你的私有 RSA SSH 密钥保存为更安全的 OpenSSH 格式：

```shell
ssh-keygen -o -f ~/.ssh/id_rsa
```

或者，你可以使用以下命令通过更安全的加密格式生成新的 RSA 密钥：

```shell
ssh-keygen -o -t rsa -b 4096 -C "<comment>"
```

<a id="update-your-ssh-key-passphrase"></a>

## 更新 SSH 密钥口令

你可以更新 SSH 密钥的口令：

1. 打开终端并运行以下命令：

   ```shell
   ssh-keygen -p -f /path/to/ssh_key
   ```

1. 在提示符下，输入口令，然后按 <kbd>Enter</kbd>。

<a id="use-different-accounts-on-a-single-gitlab-instance"></a>

## 在单个极狐GitLab 实例上使用不同账户

你可以使用多个账户连接到单个极狐GitLab 实例。你可以通过使用[上一个主题](#use-different-keys-for-different-repositories)中的命令来实现这一点。但是，即使你将 `IdentitiesOnly` 设置为 `yes`，如果 `IdentityFile` 存在于 `Host` 块之外，你也无法登录。

相反，你可以在 `~/.ssh/config` 文件中为主机分配别名。

- 对于 `Host`，使用类似 `user_1.gitlab.com` 和 `user_2.gitlab.com` 的别名。高级配置更难维护，而当你使用 `git remote` 等工具时，这些字符串更易于理解。
- 对于 `IdentityFile`，使用私钥的路径。

```conf
# User1 账户身份
Host <user_1.gitlab.com>
  Hostname gitlab.com
  PreferredAuthentications publickey
  IdentityFile ~/.ssh/<example_ssh_key1>

# User2 账户身份
Host <user_2.gitlab.com>
  Hostname gitlab.com
  PreferredAuthentications publickey
  IdentityFile ~/.ssh/<example_ssh_key2>
```

现在，要为 `user_1` 克隆仓库，请在 `git clone` 命令中使用 `user_1.gitlab.com`：

```shell
git clone git@<user_1.gitlab.com>:gitlab-org/gitlab.git
```

要更新之前克隆的别名为 `origin` 的仓库：

```shell
git remote set-url origin git@<user_1.gitlab.com>:gitlab-org/gitlab.git
```

> [!note]
> 私钥和公钥包含敏感数据。确保文件权限设置为只有你可读，而其他人不可访问。

<a id="use-different-keys-for-different-repositories"></a>

## 为不同仓库使用不同密钥

你可以为每个仓库使用不同的密钥。

打开终端并运行以下命令：

```shell
git config core.sshCommand "ssh -o IdentitiesOnly=yes -i ~/.ssh/private-key-filename-for-this-repository -F /dev/null"
```

此命令不使用 SSH Agent，并且需要 Git 2.10 或更高版本。有关 `ssh` 命令选项的更多信息，请参阅 `ssh` 和 `ssh_config` 的 `man` 手册页。

<a id="use-ssh-keys-in-another-directory"></a>

## 在另一个目录中使用 SSH 密钥

如果你的 SSH 密钥对不在默认目录中，请配置你的 SSH 客户端以指向你存储私钥的位置。

1. 打开终端并运行以下命令：

   ```shell
   eval $(ssh-agent -s)
   ssh-add <directory to private SSH key>
   ```

1. 将这些设置保存在 `~/.ssh/config` 文件中。例如：

   ```conf
   # GitLab.com
   Host gitlab.com
     PreferredAuthentications publickey
     IdentityFile ~/.ssh/gitlab_com_rsa

   # 私有极狐GitLab 实例
   Host gitlab.company.com
     PreferredAuthentications publickey
     IdentityFile ~/.ssh/example_com_rsa
   ```

有关这些设置的更多信息，请参阅 SSH 配置手册中的 [`man ssh_config`](https://man.openbsd.org/ssh_config) 页面。

公钥 SSH 密钥必须对极狐GitLab 唯一，因为它们会绑定到你的账户。你的 SSH 密钥是你在通过 SSH 推送代码时拥有的唯一标识符。它必须唯一地映射到单个用户。

<a id="use-ssh-with-egit-on-eclipse"></a>

## 在 Eclipse 上使用 EGit 配置 SSH

如果你使用 [EGit](https://projects.eclipse.org/projects/technology.egit)，你可以[将你的 SSH 密钥添加到 Eclipse](https://wiki.eclipse.org/EGit/User_Guide/#Eclipse_SSH_Configuration)。

<a id="use-ssh-on-microsoft-windows"></a>

## 在 Microsoft Windows 上使用 SSH

在 Windows 10 上，你可以使用[适用于 Linux 的 Windows 子系统 (WSL)](https://learn.microsoft.com/en-us/windows/wsl/install) 并结合 [WSL 2](https://learn.microsoft.com/en-us/windows/wsl/install#update-to-wsl-2)（预装了 `git` 和 `ssh`），或者安装 [Git for Windows](https://gitforwindows.org) 以通过 PowerShell 使用 SSH。

在 WSL 中生成的 SSH 密钥不能直接用于 Git for Windows，反之亦然，因为两者有不同的主目录：

- WSL: `/home/<user>`
- Git for Windows: `C:\Users\<user>`

你可以复制 `.ssh/` 目录以使用相同的密钥，或在每个环境中生成密钥。

如果你运行的是 Windows 11 并使用[适用于 Windows 的 OpenSSH](https://learn.microsoft.com/en-us/windows-server/administration/OpenSSH/openssh-overview)，请确保 `HOME` 环境变量设置正确。否则，可能找不到你的私有 SSH 密钥。

替代工具包括：

- [Cygwin](https://www.cygwin.com)
- [PuTTYgen](https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html) 0.81 及更高版本（早期版本[容易受到泄露攻击](https://www.openwall.com/lists/oss-security/2024/04/15/6)）

<a id="use-two-factor-authentication-for-git-over-ssh"></a>

## 对通过 SSH 进行的 Git 操作使用双重认证

你可以对[通过 SSH 进行的 Git 操作](../security/two_factor_authentication.md#2fa-for-git-over-ssh-operations)使用双重认证 (2FA)。你应该使用 `ED25519_SK` 或 `ECDSA_SK` SSH 密钥。有关更多信息，请参阅[支持的 SSH 密钥类型](ssh.md#supported-ssh-key-types)。