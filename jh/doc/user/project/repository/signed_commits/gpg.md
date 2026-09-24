---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Sign commits in your GitLab repository with GPG (GNU Privacy Guard) keys.
title: 使用 GPG 签署提交
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以使用 [GPG (GNU Privacy Guard)](https://gnupg.org/) 密钥对您在极狐GitLab 仓库中所做的提交进行签名。

> [!note]
> 极狐GitLab 使用 GPG 一词来指代所有 OpenPGP、PGP 和 GPG 相关的材料与实现。

要让极狐GitLab 将提交视为已验证：

- 提交者必须拥有 GPG 公钥/私钥对。
- 提交者的公钥必须上传至其极狐GitLab 帐户。
- GPG 公钥中的一个邮箱地址必须与提交者在极狐GitLab 中使用的已验证邮箱地址匹配。为了保持此地址的私密性，请使用极狐GitLab 在您个人资料中提供的自动生成的 [私有提交邮箱地址](../../../profile/_index.md#use-an-automatically-generated-private-commit-email)。
- 提交者的邮箱地址必须与 GPG 密钥中的已验证邮箱地址匹配。

极狐GitLab 使用自身的密钥环来验证 GPG 签名。它不会访问任何公钥服务器。

不支持 GPG 验证标签。

有关 GPG 的更多详细信息，请参阅 [相关主题列表](#related-topics)。

<a id="view-a-users-public-gpg-key"></a>

## 查看用户的公钥 GPG 密钥

要查看用户的公钥 GPG 密钥，您可以：

- 访问 `https://gitlab.example.com/<USERNAME>.gpg`。如果用户已配置 GPG 密钥，极狐GitLab 会显示该密钥；如果用户未配置 GPG 密钥，则显示空白页面。
- 访问用户个人资料（例如 `https://gitlab.example.com/<USERNAME>`）。在用户个人资料的右上角，选择 **查看公钥 GPG 密钥** ({{< icon name="key" >}})。仅当用户已配置密钥时，才会显示此按钮。

<a id="configure-commit-signing"></a>

## 配置提交签名

要对提交进行签名，您必须在本地机器和极狐GitLab 帐户上都进行配置：

1. [创建 GPG 密钥](#create-a-gpg-key)。
1. [将 GPG 密钥添加到您的帐户](#add-a-gpg-key-to-your-account)。
1. [将 GPG 密钥与 Git 关联](#associate-your-gpg-key-with-git)。
1. [对 Git 提交进行签名](#sign-your-git-commits)。

<a id="create-a-gpg-key"></a>

### 创建 GPG 密钥

如果您还没有 GPG 密钥，请创建一个：

1. 为您的操作系统[安装 GPG](https://www.gnupg.org/download/)。如果您的操作系统安装了 `gpg2`，请将本页命令中的 `gpg` 替换为 `gpg2`。
1. 要生成密钥对，请根据您的 `gpg` 版本运行相应命令：

   ```shell
   # 对于默认 GPG 版本（包括 Windows 上的 Gpg4win 和大多数 macOS 版本），使用此命令：
   gpg --gen-key

   # 对于高于 2.1.17 的 GPG 版本，使用此命令：
   gpg --full-gen-key
   ```

1. 选择密钥应使用的算法，或按 <kbd>Enter</kbd> 选择默认选项 `RSA and RSA`。
1. 选择密钥长度（以位为单位）。极狐GitLab 推荐使用 4096 位密钥。
1. 指定密钥的有效期。该值主观决定，默认值为永不过期。
1. 要确认您的答案，输入 `y`。
1. 输入您的姓名。
1. 输入您的邮箱地址。它必须与您极狐GitLab 帐户中的[已验证邮箱地址](../../../profile/_index.md#change-the-email-displayed-on-your-commits)匹配。
1. 可选。输入注释，将显示在您的姓名后的括号中。
1. GPG 会显示您到目前为止输入的信息。编辑信息或按 <kbd>O</kbd>（表示 `Okay`）继续。
1. 输入一个强密码，然后再次输入以确认。
1. 要列出您的私钥 GPG 密钥，请运行此命令，将 `<EMAIL>` 替换为生成密钥时使用的邮箱地址：

   ```shell
   gpg --list-secret-keys --keyid-format LONG <EMAIL>
   ```

1. 在输出中，找到 `sec` 行，并复制 GPG 密钥 ID。它紧跟在 `/` 字符之后。在此示例中，密钥 ID 为 `30F2B65B9246B6CA`：

   ```plaintext
   sec   rsa4096/30F2B65B9246B6CA 2017-08-18 [SC]
         D5E4F29F3275DC0CDA8FFC8730F2B65B9246B6CA
   uid                   [ultimate] Mr. Robot <your_email>
   ssb   rsa4096/B7ABC0813E4028C0 2017-08-18 [E]
   ```

1. 要显示关联的公钥，请运行此命令，将 `<ID>` 替换为上一步中的 GPG 密钥 ID：

   ```shell
   gpg --armor --export <ID>
   ```

1. 复制公钥，包括 `BEGIN PGP PUBLIC KEY BLOCK` 和 `END PGP PUBLIC KEY BLOCK` 行。您将在下一步中需要此密钥。

<a id="add-a-gpg-key-to-your-account"></a>

### 将 GPG 密钥添加到您的帐户

要将 GPG 密钥添加到您的用户设置：

1. 登录极狐GitLab。
1. 在右上角，选择您的头像。
1. 选择 **编辑个人资料**。
1. 在左侧边栏中，选择 **访问** > **GPG 密钥**。
1. 选择 **添加新密钥**。
1. 在 **密钥** 中，粘贴您的公钥。
1. 要将密钥添加到您的帐户，选择 **添加密钥**。

极狐GitLab 会显示密钥的指纹、邮箱地址和创建日期。

添加密钥后，您无法编辑它。相反，移除有问题的密钥并重新添加。

<a id="associate-your-gpg-key-with-git"></a>

### 将 GPG 密钥与 Git 关联

在您[创建 GPG 密钥](#create-a-gpg-key)并[将其添加到您的帐户](#add-a-gpg-key-to-your-account)后，您必须配置 Git 以使用此密钥：

1. 运行此命令以列出您刚刚创建的私钥 GPG 密钥，将 `<EMAIL>` 替换为您的密钥邮箱地址：

   ```shell
   gpg --list-secret-keys --keyid-format LONG <EMAIL>
   ```

1. 复制以 `sec` 开头的 GPG 私钥 ID。在此示例中，私钥 ID 为 `30F2B65B9246B6CA`：

   ```plaintext
   sec   rsa4096/30F2B65B9246B6CA 2017-08-18 [SC]
         D5E4F29F3275DC0CDA8FFC8730F2B65B9246B6CA
   uid                   [ultimate] Mr. Robot <your_email>
   ssb   rsa4096/B7ABC0813E4028C0 2017-08-18 [E]
   ```

1. 运行此命令以配置 Git 使用您的密钥对提交进行签名，将 `<KEY ID>` 替换为您的 GPG 密钥 ID：

   ```shell
   git config --global user.signingkey <KEY ID>
   ```

<a id="sign-your-git-commits"></a>

### 对 Git 提交进行签名

在[将公钥添加到您的帐户](#add-a-gpg-key-to-your-account)后，您可以手动对单个提交进行签名，或将 Git 配置为默认对提交进行签名：

- 手动对单个 Git 提交进行签名：
  1. 在要签名的任何提交上添加 `-S` 标志：

     ```shell
     git commit -S -m "我的提交消息"
     ```

  1. 在提示时输入您的 GPG 密钥密码。
  1. 推送至极狐GitLab 并检查您的提交[是否已验证](_index.md#verify-commits)。
- 通过运行以下命令，默认对所有 Git 提交进行签名：

  ```shell
  git config --global commit.gpgsign true
  ```

<a id="set-signing-key-conditionally"></a>

#### 有条件地设置签名密钥

如果您为不同目的（例如工作和个人使用）维护签名密钥，请在 `.gitconfig` 文件中使用 `IncludeIf` 语句来设置用于签名的密钥。

先决条件：

- 需要 Git 版本 2.13 或更高。

1. 在与主 `~/.gitconfig` 文件相同的目录中，创建第二个文件，例如 `.gitconfig-gitlab`。
1. 在主 `~/.gitconfig` 文件中，添加您在非极狐GitLab 项目中的工作 Git 设置。
1. 将以下信息追加到主 `~/.gitconfig` 文件末尾：

   ```ini
   # 此文件的内容仅在 JihuLab.com URL 时包含
   [includeIf "hasconfig:remote.*.url:https://jihulab.com/**"]

   # 编辑此行以指向您的备用配置文件
   path = ~/.gitconfig-gitlab
   ```

1. 在备用的 `.gitconfig-gitlab` 文件中，添加提交到极狐GitLab 仓库时要使用的配置覆盖。主 `~/.gitconfig` 文件中的所有设置都会保留，除非您显式覆盖它们。
   在此示例中，

   ```ini
   # 备用 ~/.gitconfig-gitlab 文件
   # 这些值用于匹配字符串 'jihulab.com' 的仓库，
   # 并覆盖其在 ~/.gitconfig 中的对应值

   [user]
   email = you@example.com
   signingkey = <KEY ID>

   [commit]
   gpgsign = true
   ```

<a id="revoke-a-gpg-key"></a>

## 吊销 GPG 密钥

如果 GPG 密钥被泄露，请吊销它。吊销密钥会更改未来和过去的提交：

- 过去由此密钥签名的提交将被标记为未验证。
- 未来由此密钥签名的提交将被标记为未验证。

要吊销 GPG 密钥：

1. 在右上角，选择您的头像。
1. 选择 **编辑个人资料**。
1. 在左侧边栏中，选择 **访问** > **GPG 密钥**。
1. 在要删除的 GPG 密钥旁边选择 **吊销**。

<a id="remove-a-gpg-key"></a>

## 移除 GPG 密钥

当您从极狐GitLab 帐户移除 GPG 密钥时：

- 先前由此密钥签名的提交仍保持已验证状态。
- 试图使用此密钥的未来提交（包括已创建但尚未推送的提交）将被标记为未验证。

要从您的帐户移除 GPG 密钥：

1. 在右上角，选择您的头像。
1. 选择 **编辑个人资料**。
1. 在左侧边栏中，选择 **访问** > **GPG 密钥**。
1. 在要删除的 GPG 密钥旁边选择 **移除** ({{< icon name="remove" >}})。

如果您必须同时取消未来和过去提交的验证，请[吊销关联的 GPG 密钥](#revoke-a-gpg-key)。

<a id="related-topics"></a>

## 相关主题

- [配置在 Web UI 中进行的提交的提交签名](../../../../administration/gitaly/configure_gitaly.md#configure-commit-signing-for-gitlab-ui-commits)
- GPG 资源：
  - [Git 工具 - 签名您的工作](https://git-scm.com/book/en/v2/Git-Tools-Signing-Your-Work)
  - [管理 OpenPGP 密钥](https://riseup.net/en/security/message-security/openpgp/gpg-keys)
  - [OpenPGP 最佳实践](https://riseup.net/en/security/message-security/openpgp/best-practices)
  - [使用子密钥创建新的 GPG 密钥](https://www.void.gr/kargig/blog/2013/12/02/creating-a-new-gpg-key-with-subkeys/)（高级）
  - [查看实例中的 GPG 密钥](../../../../administration/credentials_inventory.md#view-the-credentials-inventory)
  - [Beyond Identity 集成](../../integrations/beyond_identity.md)

<a id="troubleshooting"></a>

## 故障排除

<a id="secret-key-not-available"></a>

### 密钥不可用

如果您收到错误 `secret key not available` 或 `gpg: signing failed: secret key not available`，请尝试使用 `gpg2` 而不是 `gpg`：

```shell
git config --global gpg.program gpg2
```

如果您的 GPG 密钥受密码保护且密码输入提示未出现，请将 `export GPG_TTY=$(tty)` 添加到您 shell 的 `rc` 文件（通常是 `~/.bashrc` 或 `~/.zshrc`）中。

<a id="gpg-fails-to-sign-data"></a>

### GPG 签名数据失败

如果您的 GPG 密钥受密码保护，并且您收到以下错误之一：

```plaintext
error: gpg failed to sign the data
fatal: failed to write commit object
gpg: signing failed: Inappropriate ioctl for device
```

如果密码输入提示未出现：

1. 在文本编辑器中打开 shell 的配置文件，通常是 `~/.bashrc` 或 `~/.zshrc`。
1. 将以下行添加到文件中：

   ```shell
   export GPG_TTY=$(tty)
   ```

1. 保存文件并退出文本编辑器。
1. 应用更改。选择以下方式之一：

   - 重启终端。
   - 运行 `source ~/.bashrc` 或 `source ~/.zshrc`。

> [!note]
> 具体步骤可能因您的操作系统和 shell 配置而异。