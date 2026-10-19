---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 高级 SSH 密钥配置
description: 使用 SSH 密钥与极狐GitLab 代码仓库进行安全身份验证和通信。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

为特定工作流配置高级 SSH 密钥选项。
> [!note]
> 有关极狐GitLab 账号的基本 SSH 密钥用法，请参阅
> [将 SSH 密钥与极狐GitLab 一起使用](ssh.md)。

<a id="generate-an-ssh-key-pair-for-a-fido2-hardware-security-key"></a>

## 为 FIDO2 硬件安全密钥生成 SSH 密钥对

要生成 ED25519_SK 或 ECDSA_SK SSH 密钥，您必须使用 OpenSSH 8.2 或更高版本：

1. 将硬件安全密钥插入您的计算机。
1. 打开终端。
1. 运行 `ssh-keygen -t`，并指定密钥类型和可选注释，以便日后识别该密钥。
   一个常见的做法是使用您的电子邮件地址作为注释。
   该注释会包含在 `.pub` 文件中。

   例如，对于 ED25519_SK：

   ```shell
   ssh-keygen -t ed25519-sk -C "<comment>"
   ```

   对于 ECDSA_SK：

   ```shell
   ssh-keygen -t ecdsa-sk -C "<comment>"
   ```

   如果您的安全密钥支持 FIDO2 常驻密钥，您可以在创建 SSH 密钥时启用它：

   ```shell
   ssh-keygen -t ed25519-sk -O resident -C "<comment>"
   ```

   `-O resident` 表示该密钥应存储在 FIDO 认证器本身上。
   常驻密钥更易于导入到新计算机，因为它可以通过 [`ssh-add -K`](https://man.openbsd.org/cgi-bin/man.cgi/OpenBSD-current/man1/ssh-add.1#K)
   或 [`ssh-keygen -K`](https://man.openbsd.org/cgi-bin/man.cgi/OpenBSD-current/man1/ssh-keygen#K)
   直接从安全密钥加载。

1. 按 <kbd>Enter</kbd>。将显示类似以下内容的输出：

   ```plaintext
   Generating public/private ed25519-sk key pair.
   You may need to touch your authenticator to authorize key generation.
   ```

1. 触摸硬件安全密钥上的按钮。
1. 接受建议的文件名和目录：

   ```plaintext
   Enter file in which to save the key (/home/user/.ssh/id_ed25519_sk):
   ```

1. 指定[密码短语](https://www.ssh.com/academy/ssh/passphrase)：

   ```plaintext
   Enter passphrase (empty for no passphrase):
   Enter same passphrase again:
   ```

   将显示确认信息，其中包括有关文件存储位置的信息。

公钥和私钥已生成。[将SSH 公钥添加到您的极狐GitLab 账号](ssh.md#add-an-ssh-key-to-your-gitlab-account)。

<a id="generate-an-ssh-key-pair-with-1password"></a>

## 使用 1Password 生成 SSH 密钥对

您可以使用 [1Password](https://1password.com/) 和 [1Password 浏览器扩展](https://support.1password.com/getting-started-browser/)来：

- 自动生成新的 SSH 密钥。
- 使用 1Password 保管库中的现有 SSH 密钥向极狐GitLab 进行身份验证。

1. 登录极狐GitLab。
1. 在右上角，选择您的头像。
1. 选择**编辑个人资料**。
1. 在左侧边栏中，选择**访问** > **SSH 密钥**。
1. 选择**添加新密钥**。
1. 选择**密钥**，此时应会看到 1Password 助手出现。
1. 选择 1Password 图标并解锁 1Password。
1. 然后您可以选择**创建 SSH 密钥**，或选择现有 SSH 密钥以填入公钥。
1. 在**标题**框中，输入描述，例如 `Work Laptop` 或
   `Home Workstation`。
1. 可选。选择密钥的**用途类型**。它可用于 `Authentication` 或 `Signing`，或两者皆可。`Authentication & Signing` 是默认值。
1. 可选。更新**过期日期**以修改默认过期日期。
1. 选择**添加密钥**。

有关将 1Password 与 SSH 密钥一起使用的更多信息，请参阅 [1Password 文档](https://developer.1password.com/docs/ssh/get-started/)。

<a id="disable-ssh-keys-for-enterprise-users"></a>

## 为企业用户禁用 SSH 密钥

先决条件：

- 您必须拥有企业用户所属群组的所有者角色。

禁用群组中[企业用户](enterprise_user/_index.md)的 SSH 密钥：

- 阻止企业用户添加新的 SSH 密钥。
- 禁用企业用户现有的 SSH 密钥。

这也适用于作为群组管理员的企业用户。

要禁用企业用户的 SSH 密钥：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的群组。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**权限和群组功能**。
1. 在**企业用户**下，选择**禁用 SSH 密钥**。
1. 选择**保存更改**。

<a id="upgrade-your-rsa-key-pair-to-a-more-secure-format"></a>

## 将您的 RSA 密钥对升级为更安全的格式

如果您的 OpenSSH 版本介于 6.5 和 7.8 之间，您可以通过打开终端并运行以下命令，将您的私有
RSA SSH 密钥保存为更安全的 OpenSSH 格式：

```shell
ssh-keygen -o -f ~/.ssh/id_rsa
```

或者，您可以使用以下命令生成采用更安全加密格式的新 RSA 密钥：

```shell
ssh-keygen -o -t rsa -b 4096 -C "<comment>"
```

<a id="update-your-ssh-key-passphrase"></a>

## 更新您的 SSH 密钥密码短语

您可以更新 SSH 密钥的密码短语：

1. 打开终端并运行以下命令：

   ```shell
   ssh-keygen -p -f /path/to/ssh_key
   ```

1. 在提示符处，输入密码短语，然后按 <kbd>Enter</kbd>。

<a id="use-different-accounts-on-a-single-gitlab-instance"></a>

## 在单个极狐GitLab 实例上使用不同账号

您可以使用多个账号连接到单个极狐GitLab 实例。您可以通过使用[上一主题](#use-different-keys-for-different-repositories)中的命令来实现这一点。但是，即使您将 `IdentitiesOnly` 设置为 `yes`，如果 `IdentityFile` 存在于 `Host` 块之外，您也无法登录。

相反，您可以在 `~/.ssh/config` 文件中为主机分配别名。

- 对于 `Host`，使用类似 `user_1.gitlab.com` 和
  `user_2.gitlab.com`的别名。高级配置
  更难维护，而当您使用 `git remote` 等工具时，这些字符串更易于理解。
- 对于 `IdentityFile`，使用私钥的路径。

```conf
# User1 Account Identity
Host <user_1.gitlab.com>
  Hostname gitlab.com
  PreferredAuthentications publickey
  IdentityFile ~/.ssh/<example_ssh_key1>

# User2 Account Identity
Host <user_2.gitlab.com>
  Hostname gitlab.com
  PreferredAuthentications publickey
  IdentityFile ~/.ssh/<example_ssh_key2>
```

现在，要为 `user_1` 克隆代码仓库，请在 `git clone` 命令中使用 `user_1.gitlab.com`：

```shell
git clone git@<user_1.gitlab.com>:gitlab-org/gitlab.git
```

要更新之前克隆的、别名为 `origin`的代码仓库：

```shell
git remote set-url origin git@<user_1.gitlab.com>:gitlab-org/gitlab.git
```

> [!note]
> 私钥和公钥包含敏感数据。请确保文件的权限设置使您本人可读，
> 但其他人无法访问。

<a id="use-different-keys-for-different-repositories"></a>

## 为不同代码仓库使用不同密钥

您可以为每个代码仓库使用不同的密钥。

打开终端并运行以下命令：

```shell
git config core.sshCommand "ssh -o IdentitiesOnly=yes -i ~/.ssh/private-key-filename-for-this-repository -F /dev/null"
```

此命令不使用 SSH Agent，并且需要 Git 2.10 或更高版本。有关 `ssh` 命令选项的更多信息，请参阅 `ssh` 和 `ssh_config`的 `man` 页面。

<a id="use-ssh-keys-in-another-directory"></a>

## 在其他目录中使用 SSH 密钥

如果您的 SSH 密钥对不在默认目录中，请配置 SSH 客户端指向您存储私钥的位置。

1. 打开终端并运行以下命令：

   ```shell
   eval $(ssh-agent -s)
   ssh-add <path to private SSH key file>
   ```

1. 将这些设置保存到 `~/.ssh/config` 文件中。例如：

   ```conf
   # GitLab.com
   Host gitlab.com
     PreferredAuthentications publickey
     IdentityFile ~/.ssh/gitlab_com_rsa

   # Private GitLab instance
   Host gitlab.company.com
     PreferredAuthentications publickey
     IdentityFile ~/.ssh/example_com_rsa
   ```

有关这些设置的更多信息，请参阅 SSH 配置手册中的 [`man ssh_config`](https://man.openbsd.org/ssh_config) 页面。

SSH 公钥在极狐GitLab 中必须唯一，因为它们会绑定到您的账号。当您使用 SSH 推送代码时，SSH 密钥是您唯一的身份标识。它必须唯一映射到单个用户。

<a id="move-an-ssh-key-to-another-device"></a>

## 将 SSH 密钥移动到另一台设备

您可以通过复制私钥文件在多台设备上使用同一个 SSH 密钥。您无需在极狐GitLab 中更改任何内容。

> [!note]
> 为了更高的安全性，请考虑为每台设备[生成新的 SSH 密钥](ssh.md#generate-an-ssh-key-pair)。
> 这样可以限制设备丢失或受损带来的影响。

要将 SSH 密钥移动到另一台设备：

1. 在您的原始设备上，[找到您现有的 SSH 密钥对](ssh.md#check-for-existing-ssh-key-pairs)。
1. 将这些文件复制到新设备上的 `~/.ssh/` 目录。

   > [!warning]
   > 切勿通过电子邮件、聊天或未加密的云同步服务发送私钥。
   > 请使用加密的传输方式，例如密码管理器或加密的 USB 驱动器。

1. 在新设备上，打开终端。
1. 设置权限，使只有您本人可以读取私钥。
   例如，对于 ED25519：

   ```shell
   chmod 600 ~/.ssh/id_ed25519
   ```

1. 将密钥添加到 SSH agent：

   ```shell
   eval $(ssh-agent -s)
   ssh-add ~/.ssh/id_ed25519
   ```

1. 验证该密钥能否通过极狐GitLab 的身份验证。更多信息，请参阅
   [验证您的 SSH 连接](ssh.md#verify-your-ssh-connection)。

对于存储在 FIDO2 硬件安全密钥上的 SSH 密钥，请勿复制私钥文件。而应使用 `ssh-add -K` 从安全密钥导入该密钥。更多信息，请参阅[为 FIDO2 硬件安全密钥生成 SSH 密钥对](#generate-an-ssh-key-pair-for-a-fido2-hardware-security-key)。

在 Microsoft Windows 上，WSL 和 Git for Windows 环境使用不同的主目录。
更多信息，请参阅[在 Microsoft Windows 上使用 SSH](#use-ssh-on-microsoft-windows)。

<a id="use-ssh-with-egit-on-eclipse"></a>

## 在 Eclipse 上通过 EGit 使用 SSH

如果您使用 [EGit](https://projects.eclipse.org/projects/technology.egit)，您可以[将 SSH 密钥添加到 Eclipse](https://wiki.eclipse.org/EGit/User_Guide/#Eclipse_SSH_Configuration)。

<a id="use-ssh-on-microsoft-windows"></a>

## 在 Microsoft Windows 上使用 SSH

在 Windows 10 上，您可以使用[适用于 Linux 的 Windows 子系统 (WSL)](https://learn.microsoft.com/en-us/windows/wsl/install)
配合 [WSL 2](https://learn.microsoft.com/en-us/windows/wsl/install#update-to-wsl-2)，它
预装了 `git` 和 `ssh`，或者安装 [Git for Windows](https://gitforwindows.org) 以
通过 PowerShell 使用 SSH。

在 WSL 中生成的 SSH 密钥不能直接用于 Git for Windows，反之亦然，
因为两者具有不同的主目录：

- WSL：`/home/<user>`
- Git for Windows：`C:\Users\<user>`

您可以复制 `.ssh/` 目录以使用相同的密钥，也可以在每个环境中分别生成密钥。

如果您运行的是 Windows 11 并使用 [OpenSSH for Windows](https://learn.microsoft.com/en-us/windows-server/administration/OpenSSH/openssh-overview)，请确保 `HOME`
环境变量设置正确。否则，可能无法找到您的私有 SSH 密钥。

其他可选工具包括：

- [Cygwin](https://www.cygwin.com)
- [PuTTYgen](https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html) 0.81 及更高版本（更早版本[易受泄露攻击](https://www.openwall.com/lists/oss-security/2024/04/15/6)）

<a id="use-two-factor-authentication-for-git-over-ssh"></a>

## 为基于 SSH 的 Git 使用双因素认证

您可以为[基于 SSH 的 Git](../security/two_factor_authentication.md#2fa-for-git-over-ssh-operations) 使用双因素认证 (2FA)。您应使用 `ED25519_SK` 或 `ECDSA_SK` SSH 密钥。更多信息，请参阅[支持的 SSH 密钥类型](ssh.md#supported-ssh-key-types)。
