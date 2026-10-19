---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 使用 SSH 密钥为极狐GitLab 代码仓库中的提交和标签签名。
title: 使用 SSH 密钥为提交和标签签名
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用 SSH 密钥为提交或标签签名时，极狐GitLab 会使用与您的极狐GitLab 账号关联的 SSH 公钥以加密方式验证签名。如果验证成功，极狐GitLab 会在该提交或标签上显示**已验证**标记。

极狐GitLab 将提交视为已验证的条件：

- 您必须将用于为提交签名的 SSH 密钥添加到您的极狐GitLab 账号，且[用途类型](../../../ssh.md#add-an-ssh-key-to-your-gitlab-account)为 **认证和签名** 或 **签名**。
- 您的 Git 配置中的提交者电子邮件地址必须与您极狐GitLab 账号关联的[已验证电子邮件地址](../../../profile/_index.md#change-your-primary-email)一致。

如果签名有效，但提交者电子邮件与您账号中已验证的电子邮件不一致，则该提交会被标记为**未验证**。

只要 SSH 密钥的用途类型为 **认证和签名**，您就可以将同一组 SSH 密钥同时用于向极狐GitLab 进行 `git+ssh` 身份验证和为提交签名。您可以在[将 SSH 密钥添加到您的极狐GitLab 账号](../../../ssh.md#add-an-ssh-key-to-your-gitlab-account)页面进行验证。

有关管理与您的极狐GitLab 账号关联的 SSH 密钥的更多信息，请参阅[使用 SSH 密钥与极狐GitLab 通信](../../../ssh.md)。

<a id="configure-git-to-sign-commits-and-tags-with-your-ssh-key"></a>

## 配置 Git 以使用 SSH 密钥为提交和标签签名

在您[创建 SSH 密钥](../../../ssh.md#generate-an-ssh-key-pair)并[将其添加到您的极狐GitLab 账号](../../../ssh.md#add-an-ssh-key-to-your-gitlab-account)后，配置 Git 以开始使用该密钥。

先决条件：

- Git 2.34.0 或更高版本。
- OpenSSH 8.1 或更高版本。

  > [!note]
  > OpenSSH 8.7 的签名功能已损坏。如果您使用的是 OpenSSH 8.7，请升级到 OpenSSH 8.8。

- 一个 **用途类型** 为 `Authentication & Signing` 或 `Signing` 的 SSH 密钥。
  支持以下 SSH 密钥类型：
  - ED25519
  - ED25519_SK
  - RSA
  - ECDSA
  - ECDSA_SK

要配置 Git 使用您的密钥：

1. 配置 Git 使用 SSH 进行提交签名：

   ```shell
   git config --global gpg.format ssh
   ```

1. 指定要用作签名密钥的公钥，并将文件名（`~/.ssh/examplekey.pub`）更改为您的密钥所在位置。文件名可能因您生成密钥的方式而有所不同：

   ```shell
   git config --global user.signingkey ~/.ssh/examplekey.pub
   ```

<a id="sign-commits-with-your-ssh-key"></a>

## 使用 SSH 密钥为提交签名

先决条件：

- 您已[创建 SSH 密钥](../../../ssh.md#generate-an-ssh-key-pair)。
- 您已[将该密钥添加](../../../ssh.md#add-an-ssh-key-to-your-gitlab-account)到您的极狐GitLab 账号。
- 您已[配置 Git 使用您的 SSH 密钥为提交签名](#configure-git-to-sign-commits-and-tags-with-your-ssh-key)。
- 您的 Git `user.email` 与您极狐GitLab 账号关联的[已验证电子邮件地址](../../../profile/_index.md#change-your-primary-email)一致。

要为提交签名：

1. 为提交签名时使用 `-S` 标志：

   ```shell
   git commit -S -m "My commit msg"
   ```

1. 可选。如果您不想每次提交时都输入 `-S` 标志，可以让 Git 自动为您的提交签名：

   ```shell
   git config --global commit.gpgsign true
   ```

1. 如果您的 SSH 密钥受保护，Git 会提示您输入密码短语。
1. 推送到极狐GitLab。
1. 检查您的提交[是否已验证](#verify-commits)。
   签名验证使用 `allowed_signers` 文件来关联电子邮件和 SSH 密钥。
   有关配置此文件的帮助，请参阅[在本地验证提交](#verify-commits-locally)。

<a id="sign-and-verify-tags"></a>

## 为标签签名并验证

在您[配置 Git 使用您的 SSH 密钥为提交和标签签名](#configure-git-to-sign-commits-and-tags-with-your-ssh-key)后，您可以为标签签名：

1. 创建 Git 标签时，添加 `-s` 标志：

   ```shell
   git tag -s v1.1.1 -m "My signed tag"
   ```

1. 推送到极狐GitLab，并使用以下命令验证您的标签已签名：

   ```shell
   git tag --verify v1.1.1
   ```

1. 可选。要在不使用 `-s` 标志的情况下自动为标签签名，请运行：

   ```shell
   git config --global tag.gpgsign true
   ```

<a id="verify-commits"></a>

## 验证提交

您可以在[极狐GitLab UI 中](_index.md#verify-commits)验证所有类型的已签名提交。使用 SSH 密钥签名的提交也可以在本地验证。

<a id="verify-commits-locally"></a>

### 在本地验证提交

要在本地验证提交，请创建一个[允许签名者文件](https://man7.org/linux/man-pages/man1/ssh-keygen.1.html#ALLOWED_SIGNERS)，供 Git 将 SSH 公钥与用户关联。本示例使用 `~/.ssh/allowed_signers`，但您可以指定其他路径。在以下步骤中使用相同的路径。

1. 创建 SSH 目录：

   ```shell
   mkdir -p ~/.ssh
   ```

1. 创建允许签名者文件。

   ```shell
   touch ~/.ssh/allowed_signers
   ```

1. 配置 Git 使用该文件：

   ```shell
   git config gpg.ssh.allowedSignersFile "$HOME/.ssh/allowed_signers"
   ```

1. 将您的条目添加到允许签名者文件。将 `<MY_KEY>` 替换为您的密钥名称。如果您在步骤 1 中选择了其他路径，请将 `~/.ssh/allowed_signers` 替换为该路径：

   ```shell
   # Declaring the `git` namespace helps prevent cross-protocol attacks.
   echo "$(git config --get user.email) namespaces=\"git\" $(cat ~/.ssh/<MY_KEY>.pub)" >> ~/.ssh/allowed_signers
   ```

   生成的条目包含您的电子邮件地址、密钥类型和密钥内容：

   ```plaintext
   example@gitlab.com namespaces="git" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAmaTS47vRmsKyLyK1jlIFJn/i8wdGQ3J49LYyIYJ2hv
   ```

1. 对您要验证的每个其他用户重复此步骤。如果您与其他贡献者协作，可以考虑将此文件检入您的 Git 代码仓库。

1. 使用 `git log --show-signature` 查看提交的签名状态：

   ```shell
   $ git log --show-signature

   commit e2406b6cd8ebe146835ceab67ff4a5a116e09154 (HEAD -> main, origin/main, origin/HEAD)
   Good "git" signature for johndoe@example.com with ED25519 key SHA256:Ar44iySGgxic+U6Dph4Z9Rp+KDaix5SFGFawovZLAcc
   Author: John Doe <johndoe@example.com>
   Date:   Tue Nov 29 06:54:15 2022 -0600

       SSH signed commit
   ```

<a id="signed-commits-with-removed-ssh-keys"></a>

## 已移除 SSH 密钥的已签名提交

您可以撤销或删除用于为提交签名的 SSH 密钥。更多信息，请参阅[移除 SSH 密钥](../../../ssh.md#remove-an-ssh-key)。

移除您的 SSH 密钥可能会影响使用该密钥签名的任何提交：

- 撤销您的 SSH 密钥会将您之前的提交标记为**未验证**。在您添加新的 SSH 密钥之前，任何新提交也会被标记为**未验证**。
- 删除您的 SSH 密钥不会影响您之前的提交。在您添加新的 SSH 密钥之前，任何新提交都会被标记为**未验证**。
