---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 使用 GPG（GNU Privacy Guard）密钥为极狐GitLab 代码仓库中的提交和标签签名。
title: 使用 GPG 为提交和标签签名
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以使用 [GPG（GNU Privacy Guard）](https://gnupg.org/)密钥为在极狐GitLab 代码仓库中所做的提交签名。

> [!note]
> 极狐GitLab 使用 GPG 这一术语来指代所有 OpenPGP、PGP 和 GPG 相关材料及实现。

要让极狐GitLab 将某个提交视为已验证：

- 提交者必须拥有 GPG 公钥/私钥对。
- 提交者的公钥必须已上传到其极狐GitLab 账号。
- GPG 公钥中的某个电子邮件地址必须与提交者在极狐GitLab 中使用的某个已验证电子邮件地址匹配。若要保持该地址私密，请使用极狐GitLab 在您的个人资料中自动生成的[私人提交电子邮件地址](../../../profile/_index.md#use-an-automatically-generated-private-commit-email)。
- 提交者的电子邮件地址必须与 GPG 密钥中的已验证电子邮件地址匹配。

极狐GitLab 使用自己的密钥环来验证 GPG 签名，不会访问任何公钥服务器。

有关 GPG 的更多详细信息，请参阅下文的配置与故障排除说明。

<a id="view-a-users-public-gpg-key"></a>

## 查看用户的 GPG 公钥

要查看用户的 GPG 公钥，您可以：

- 访问 `https://gitlab.example.com/<USERNAME>.gpg`。如果用户已配置 GPG 密钥，极狐GitLab 会显示该 GPG 密钥；如果用户未配置 GPG 密钥，则显示空白页面。
- 访问用户的个人资料（例如 `https://gitlab.example.com/<USERNAME>`）。在用户个人资料的右上角，选择 **查看公开 GPG 密钥**（{{< icon name="key" >}}）。仅当用户已配置密钥时，才会显示此按钮。

<a id="configure-commit-signing"></a>

## 配置提交签名

要为提交签名，您必须同时配置本地机器和极狐GitLab 账号：

1. [创建 GPG 密钥](#create-a-gpg-key)。
1. [将 GPG 密钥添加到您的账号](#add-a-gpg-key-to-your-account)。
1. [将 GPG 密钥与 Git 关联](#associate-your-gpg-key-with-git)。
1. [为 Git 提交签名](#sign-your-git-commits)。

<a id="create-a-gpg-key"></a>

### 创建 GPG 密钥

如果您还没有 GPG 密钥，请创建一个：

1. 为您的操作系统[安装 GPG](https://www.gnupg.org/download/)。
   如果您的操作系统已安装 `gpg2`，请将本页命令中的 `gpg` 替换为 `gpg2`。
1. 要生成密钥对，请运行与您的 `gpg` 版本相应的命令：

   ```shell
   # Use this command for the default version of GPG, including
   # Gpg4win on Windows, and most macOS versions:
   gpg --gen-key

   # Use this command for versions of GPG later than 2.1.17:
   gpg --full-gen-key
   ```

1. 选择密钥应使用的算法，或按 <kbd>Enter</kbd> 选择默认选项 `RSA and RSA`。
1. 选择密钥长度（以位为单位）。极狐GitLab 建议使用 4096 位密钥。
1. 指定密钥的有效期。该值由您自行决定，默认值为永不过期。
1. 要确认您的选择，请输入 `y`。
1. 输入您的姓名。
1. 输入您的电子邮件地址。该地址必须与您极狐GitLab 账号中的某个[已验证电子邮件地址](../../../profile/_index.md#change-the-email-displayed-on-your-commits)匹配。
1. 可选。输入一条注释，显示在您姓名后面的括号中。
1. GPG 会显示您目前输入的信息。编辑这些信息，或按 <kbd>O</kbd>（表示 `Okay`）继续。
1. 输入一个强密码，然后再次输入以确认。
1. 要列出您的 GPG 私钥，请运行以下命令，并将 `<EMAIL>` 替换为您生成密钥时使用的电子邮件地址：

   ```shell
   gpg --list-secret-keys --keyid-format LONG <EMAIL>
   ```

1. 在输出中找到 `sec` 行，并复制 GPG 密钥 ID。它从 `/` 字符之后开始。在此示例中，密钥 ID 为 `30F2B65B9246B6CA`：

   ```plaintext
   sec   rsa4096/30F2B65B9246B6CA 2017-08-18 [SC]
         D5E4F29F3275DC0CDA8FFC8730F2B65B9246B6CA
   uid                   [ultimate] Mr. Robot <your_email>
   ssb   rsa4096/B7ABC0813E4028C0 2017-08-18 [E]
   ```

1. 要显示关联的公钥，请运行以下命令，并将 `<ID>` 替换为上一步中的 GPG 密钥 ID：

   ```shell
   gpg --armor --export <ID>
   ```

1. 复制公钥，包括 `BEGIN PGP PUBLIC KEY BLOCK` 和 `END PGP PUBLIC KEY BLOCK` 行。下一步中需要用到此密钥。

<a id="add-a-gpg-key-to-your-account"></a>

### 将 GPG 密钥添加到您的账号

要将 GPG 密钥添加到您的用户设置：

1. 登录极狐GitLab。
1. 在右上角，选择您的头像。
1. 选择 **编辑资料**。
1. 在左侧边栏中，选择 **访问** > **GPG 密钥**。
1. 选择 **添加新密钥**。
1. 在 **密钥**中，粘贴您的公钥。
1. 要将密钥添加到您的账号，请选择 **添加密钥**。

极狐GitLab 会显示该密钥的指纹、电子邮件地址和创建日期。

添加密钥后，您无法编辑它。请改为移除有问题的密钥，然后重新添加。

<a id="associate-your-gpg-key-with-git"></a>

### 将 GPG 密钥与 Git 关联

在您[创建 GPG 密钥](#create-a-gpg-key)并[将其添加到您的账号](#add-a-gpg-key-to-your-account)后，必须配置 Git 以使用此密钥：

1. 运行以下命令，列出您刚创建的 GPG 私钥，并将 `<EMAIL>` 替换为您密钥的电子邮件地址：

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

1. 运行以下命令，配置 Git 使用您的密钥为提交签名，并将 `<KEY ID>` 替换为您的 GPG 密钥 ID：

   ```shell
   git config --global user.signingkey <KEY ID>
   ```

<a id="sign-your-git-commits"></a>

### 为 Git 提交签名

在您[将公钥添加到您的账号](#add-a-gpg-key-to-your-account)后，您可以手动为单个提交签名，也可以配置 Git 默认对提交签名：

- 手动为单个 Git 提交签名：
  1. 为要签名的任何提交添加 `-S` 标志：

     ```shell
     git commit -S -m "My commit message"
     ```

  1. 在系统提示时输入您的 GPG 密钥的密码短语。
  1. 推送到极狐GitLab，并检查您的提交[是否已验证](_index.md#verify-commits)。
- 通过运行以下命令，默认对所有 Git 提交签名：

  ```shell
  git config --global commit.gpgsign true
  ```

<a id="set-signing-key-conditionally"></a>

#### 按条件设置签名密钥

如果您为不同用途（例如工作和个人用途）维护不同的签名密钥，请在 `.gitconfig` 文件中使用 `IncludeIf` 语句来设置用于为提交签名的密钥。

先决条件：

- 需要 Git 2.13 或更高版本。

1. 在主 `~/.gitconfig` 文件所在的同一目录中，创建第二个文件，例如 `.gitconfig-gitlab`。
1. 在主 `~/.gitconfig` 文件中，添加用于非极狐GitLab 项目工作的 Git 设置。
1. 将以下信息追加到主 `~/.gitconfig` 文件的末尾：

   ```ini
   # The contents of this file are included only for GitLab.com URLs
   [includeIf "hasconfig:remote.*.url:https://gitlab.com/**"]

   # Edit this line to point to your alternative configuration file
   path = ~/.gitconfig-gitlab
   ```

1. 在备用的 `.gitconfig-gitlab` 文件中，添加提交到极狐GitLab 代码仓库时要使用的配置覆盖项。除非您显式覆盖，否则主 `~/.gitconfig` 文件中的所有设置都会保留。在此示例中：

   ```ini
   # Alternative ~/.gitconfig-gitlab file
   # These values are used for repositories matching the string 'gitlab.com',
   # and override their corresponding values in ~/.gitconfig

   [user]
   email = you@example.com
   signingkey = <KEY ID>

   [commit]
   gpgsign = true
   ```

<a id="sign-and-verify-tags"></a>

## 为标签签名并验证

在您[将 GPG 密钥与 Git 关联](#associate-your-gpg-key-with-git)后，您可以为标签签名：

1. 创建 Git 标签时，添加 `-s` 标志：

   ```shell
   git tag -s v1.1.1 -m "My signed tag"
   ```

1. 将标签推送到极狐GitLab。
1. 要在本地验证签名，请运行：

   ```shell
   git tag --verify v1.1.1
   ```

1. 可选。要自动为所有标签签名，请运行：

   ```shell
   git config --global tag.gpgsign true
   ```

<a id="revoke-a-gpg-key"></a>

## 撤销 GPG 密钥

如果 GPG 密钥遭到泄露，请撤销它。撤销密钥会同时改变未来和过去的提交：

- 由该密钥签名的过去提交会被标记为未验证。
- 由该密钥签名的未来提交会被标记为未验证。

要撤销 GPG 密钥：

1. 在右上角，选择您的头像。
1. 选择 **编辑资料**。
1. 在左侧边栏中，选择 **访问** > **GPG 密钥**。
1. 在要删除的 GPG 密钥旁边，选择 **撤销**。

<a id="remove-a-gpg-key"></a>

## 移除 GPG 密钥

当您从极狐GitLab 账号中移除 GPG 密钥时：

- 之前使用该密钥签名的提交仍保持已验证。
- 未来尝试使用该密钥的提交（包括任何已创建但尚未推送的提交）会变为未验证。

要从您的账号中移除 GPG 密钥：

1. 在右上角，选择您的头像。
1. 选择 **编辑资料**。
1. 在左侧边栏中，选择 **访问** > **GPG 密钥**。
1. 在要删除的 GPG 密钥旁边，选择 **移除**（{{< icon name="remove" >}}）。

如果您必须同时取消未来和过去提交的验证，请改为[撤销关联的 GPG 密钥](#revoke-a-gpg-key)。

<a id="troubleshooting"></a>

## 故障排除

<a id="secret-key-not-available"></a>

### 密钥不可用

如果您收到 `secret key not available` 或 `gpg: signing failed: secret key not available` 错误，请尝试使用 `gpg2` 而不是 `gpg`：

```shell
git config --global gpg.program gpg2
```

如果您的 GPG 密钥受密码保护，但没有出现密码输入提示，请将 `export GPG_TTY=$(tty)` 添加到 shell 的 `rc` 文件（通常是 `~/.bashrc` 或 `~/.zshrc`）中。

<a id="gpg-fails-to-sign-data"></a>

### GPG 无法为数据签名

如果您的 GPG 密钥受密码保护，并且您收到以下错误之一：

```plaintext
error: gpg failed to sign the data
fatal: failed to write commit object
gpg: signing failed: Inappropriate ioctl for device
```

如果没有出现密码输入提示：

1. 在文本编辑器中打开 shell 的配置文件，通常是 `~/.bashrc` 或 `~/.zshrc`。
1. 将以下行添加到该文件：

   ```shell
   export GPG_TTY=$(tty)
   ```

1. 保存文件并退出文本编辑器。
1. 应用更改。选择以下方式之一：

   - 重启您的终端。
   - 运行 `source ~/.bashrc` 或 `source ~/.zshrc`。

> [!note]
> 具体步骤可能因您的操作系统和 shell 配置而异。
