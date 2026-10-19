---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 将 SSH 密钥与极狐GitLab 配合使用
description: 使用 SSH 密钥进行安全身份验证，并与极狐GitLab 代码仓库安全通信。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用 SSH 密钥可以安全地向极狐GitLab 进行身份验证，无需在每次推送或拉取代码时输入用户名和密码。

要将 SSH 密钥与极狐GitLab 配合使用，您必须：

1. 在本地系统上生成 SSH 密钥对。
1. 将 SSH 密钥添加到您的极狐GitLab 账户。
1. 验证您与极狐GitLab 的连接。

然后，您可以[使用 SSH 克隆代码仓库](../topics/git/clone.md#clone-with-ssh)。
一个 SSH 密钥即可让您通过身份验证，访问您的账户可以访问的每个项目和群组。您无需为每个项目使用单独的密钥。要为特定代码仓库使用不同的密钥，请参阅
[为不同代码仓库使用不同密钥](ssh_advanced.md#use-different-keys-for-different-repositories)。

> [!note]
> 对于不太常见的设置，例如硬件安全密钥、多个账户或 Microsoft Windows，
> 请参阅[高级 SSH 密钥配置](ssh_advanced.md)。

<a id="what-are-ssh-keys"></a>

## 什么是 SSH 密钥

SSH 使用两个密钥：公钥和私钥。

- 公钥可以分发。
- 私钥应受到保护。

上传公钥不可能泄露机密数据。当您需要复制或上传 SSH 公钥时，请确保不要意外复制或上传私钥。

您可以使用私钥[签署提交](project/repository/signed_commits/ssh.md)，
这会让您对极狐GitLab 的使用以及您的数据更加安全。任何人都可以使用您的公钥验证该签名。

有关详情，请参阅[非对称加密，也称为公钥加密](https://en.wikipedia.org/wiki/Public-key_cryptography)。

<a id="prerequisites"></a>

## 先决条件

要使用 SSH 与极狐GitLab 通信，您需要：

- OpenSSH 客户端，它已预装在 GNU/Linux、macOS 和 Windows 10 上。
- SSH 6.5 或更高版本。更早的版本使用 MD5 签名，不安全。

> [!note]
> 要查看系统上安装的 SSH 版本，请运行 `ssh -V`。

<a id="supported-ssh-key-types"></a>

## 支持的 SSH 密钥类型

要与极狐GitLab 通信，您可以使用以下 SSH 密钥类型：

| 算法           | 说明 |
| ------------------- | ----- |
| ED25519（首选） | 比 RSA 密钥更安全、性能更好。在 OpenSSH 6.5（2014 年）中引入，大多数操作系统都支持。可能并非所有 FIPS 系统都完全支持。有关详情，请参阅[议题 367429](https://gitlab.com/gitlab-org/gitlab/-/issues/367429)。 |
| ED25519_SK          | 要求本地客户端和极狐GitLab 服务器上都安装 OpenSSH 8.2 或更高版本。 |
| ECDSA_SK            | 要求本地客户端和极狐GitLab 服务器上都安装 OpenSSH 8.2 或更高版本。 |
| RSA                 | 安全性低于 ED25519。如果使用，极狐GitLab 建议密钥长度至少为 4096 位。由于 Go 的限制，最大密钥长度为 8192 位。默认密钥长度取决于您的 `ssh-keygen` 版本。 |
| ECDSA               | 与 DSA 相关的[安全问题](https://leanpub.com/gocrypto/read#leanpub-auto-ecdsa)同样适用于 ECDSA 密钥。 |

<a id="check-for-existing-ssh-key-pairs"></a>

## 检查现有的 SSH 密钥对

在创建密钥对之前，请先查看是否已存在密钥对。

1. 转到您的主目录。
1. 转到 `.ssh/` 子目录。如果 `.ssh/` 子目录不存在，
   那么您要么不在主目录中，要么之前从未使用过 `ssh`。
   如果是后者，您需要[生成 SSH 密钥对](#generate-an-ssh-key-pair)。
1. 查看是否存在以下任一格式的文件：

   | 算法             | 公钥 | 私钥 |
   |-----------------------|------------|-------------|
   |  ED25519（首选）  | `id_ed25519.pub` | `id_ed25519` |
   |  ED25519_SK           | `id_ed25519_sk.pub` | `id_ed25519_sk` |
   |  ECDSA_SK             | `id_ecdsa_sk.pub` | `id_ecdsa_sk` |
   |  RSA（密钥长度至少 4096 位） | `id_rsa.pub` | `id_rsa` |
   |  DSA（已弃用）     | `id_dsa.pub` | `id_dsa` |
   |  ECDSA                | `id_ecdsa.pub` | `id_ecdsa` |

<a id="generate-an-ssh-key-pair"></a>

## 生成 SSH 密钥对

如果您没有现成的 SSH 密钥对，请生成一个新的：

1. 打开终端。
1. 运行 `ssh-keygen -t`，并指定密钥类型和可选注释，以便日后识别该密钥。
   一个常见的做法是使用您的电子邮件地址作为注释。
   该注释会包含在 `.pub` 文件中。

   例如，对于 ED25519：

   ```shell
   ssh-keygen -t ed25519 -C "<comment>"
   ```

   对于 4096 位 RSA：

   ```shell
   ssh-keygen -t rsa -b 4096 -C "<comment>"
   ```

1. 按 <kbd>Enter</kbd>。将显示类似以下的输出：

   ```plaintext
   Generating public/private ed25519 key pair.
   Enter file in which to save the key (/home/user/.ssh/id_ed25519):
   ```

1. 接受建议的文件名和目录，除非您要生成[部署密钥](project/deploy_keys/_index.md)
   或想保存到存放其他密钥的特定目录。

   您也可以将该 SSH 密钥对专用于[特定主机](ssh_advanced.md#use-ssh-keys-in-another-directory)。

1. 指定[密码短语](https://www.ssh.com/academy/ssh/passphrase)：

   ```plaintext
   Enter passphrase (empty for no passphrase):
   Enter same passphrase again:
   ```

   将显示确认信息，其中包括您的文件存储位置的相关信息。
   公钥和私钥已生成。

1. 将 SSH 私钥添加到 `ssh-agent`。

   例如，对于 ED25519：

   ```shell
   ssh-add ~/.ssh/id_ed25519
   ```

<a id="add-an-ssh-key-to-your-gitlab-account"></a>

## 将 SSH 密钥添加到您的极狐GitLab 账户

要将 SSH 与极狐GitLab 配合使用，请将您的公钥复制到您的极狐GitLab 账户。极狐GitLab 无法访问您的私钥。

当您添加 SSH 密钥时，极狐GitLab 会将其与已知泄露密钥列表进行比对。您无法添加已泄露的密钥，因为相应的私钥已公开，可能被用于访问账户。此限制无法配置。

如果您的密钥被阻止，请[生成新的 SSH 密钥对](#generate-an-ssh-key-pair)。

要将 SSH 密钥添加到您的极狐GitLab 账户：

1. 复制公钥文件的内容。您可以手动复制，也可以使用脚本。

   在这些示例中，请将 `id_ed25519.pub` 替换为您的文件名。例如，对于 RSA，请使用 `id_rsa.pub`。

   {{< tabs >}}

   {{< tab title="macOS" >}}

   ```shell
   tr -d '\n' < ~/.ssh/id_ed25519.pub | pbcopy
   ```

   {{< /tab >}}

   {{< tab title="Linux（需要 xclip 软件包）" >}}

   ```shell
   xclip -sel clip < ~/.ssh/id_ed25519.pub
   ```

   {{< /tab >}}

   {{< tab title="Windows 上的 Git Bash" >}}

   ```shell
   cat ~/.ssh/id_ed25519.pub | clip
   ```

   {{< /tab >}}

   {{< /tabs >}}

1. 登录极狐GitLab。
1. 在右上角，选择您的头像。
1. 选择 **编辑个人资料**。
1. 在左侧边栏中，选择 **访问** > **SSH 密钥**。
1. 选择 **添加新密钥**。
1. 在 **密钥** 框中，粘贴您的公钥内容。
   如果您是手动复制密钥，请确保复制完整的密钥，
   它以 `ssh-rsa`、`ssh-dss`、`ecdsa-sha2-nistp256`、`ecdsa-sha2-nistp384`、`ecdsa-sha2-nistp521`、
   `ssh-ed25519`、`sk-ecdsa-sha2-nistp256@openssh.com` 或 `sk-ssh-ed25519@openssh.com` 开头，并可能以注释结尾。
1. 在 **标题** 框中，输入描述，例如 `Work Laptop` 或
   `Home Workstation`。
1. 可选。选择密钥的 **使用类型**。它可用于 `Authentication` 或 `Signing`，或两者皆可。`Authentication & Signing` 是默认值。
1. 可选。更新 **过期日期** 以修改默认过期日期。有关详情，请参阅
   [SSH 密钥过期](#ssh-key-expiration)。
1. 选择 **添加密钥**。

<a id="verify-your-ssh-connection"></a>

## 验证您的 SSH 连接

验证您的 SSH 密钥已正确添加，并且您可以连接到极狐GitLab 实例：

1. 为确保连接到正确的服务器，请确认 SSH 主机密钥指纹：
   - 对于 JihuLab.com，请参阅 [SSH 主机密钥指纹](jihulab_com/_index.md#ssh-host-keys-fingerprints)文档。
   - 对于极狐GitLab 私有化部署，请参阅 `https://gitlab.example.com/help/instance_configuration#ssh-host-keys-fingerprints`，
     其中 `gitlab.example.com` 是极狐GitLab 实例 URL。
1. 打开终端并运行以下命令：
   - 对于 JihuLab.com，请使用 `ssh -T git@gitlab.com`。
   - 对于极狐GitLab 私有化部署，请使用 `ssh -T git@gitlab.example.com`，
     其中 `gitlab.example.com` 是极狐GitLab 实例 URL。

默认情况下，连接使用 `git` 用户名，但极狐GitLab 私有化部署管理员
可以[更改该用户名](https://gitlab.cn/docs/omnibus/settings/configuration/#change-the-name-of-the-git-user-or-group)。

1. 首次连接时，您可能需要验证极狐GitLab 主机的真实性。
   如果您看到类似以下的消息，请按照屏幕上的提示操作：

   ```plaintext
   The authenticity of host 'gitlab.example.com (35.231.145.151)' can't be established.
   ECDSA key fingerprint is SHA256:HbW3g8zUjNSksFbqTiUWPWg2Bq1x8xdGUrliXFzSnUw.
   Are you sure you want to continue connecting (yes/no)?
   ```

   您应该会收到一条欢迎消息。

   ```plaintext
   Welcome to GitLab, <username>!
   ```

   如果未出现该消息，您可以
   [排查 SSH 连接问题](ssh_troubleshooting.md#general-ssh-troubleshooting)。

<a id="view-your-ssh-keys"></a>

## 查看您的 SSH 密钥

要查看您账户的 SSH 密钥：

1. 在右上角，选择您的头像。
1. 选择 **编辑个人资料**。
1. 在左侧边栏中，选择 **访问** > **SSH 密钥**。

您现有的 SSH 密钥列在页面底部。信息包括：

- 密钥的标题
- 公钥指纹
- 允许的使用类型
- 创建日期
- 上次使用日期
- 过期日期

<a id="remove-an-ssh-key"></a>

## 移除 SSH 密钥

您可以撤销或删除 SSH 密钥，将其从您的账户中永久移除。

如果您使用该密钥签署提交，移除 SSH 密钥还会有其他影响。有关详情，请参阅[使用已移除的 SSH 密钥签署的提交](project/repository/signed_commits/ssh.md#signed-commits-with-removed-ssh-keys)。

<a id="revoke-an-ssh-key"></a>

### 撤销 SSH 密钥

如果您的 SSH 密钥已泄露，请撤销该密钥。

先决条件：

- 该 SSH 密钥的使用类型必须为 `Signing` 或 `Authentication & Signing`。

要撤销 SSH 密钥：

1. 在右上角，选择您的头像。
1. 选择 **编辑个人资料**。
1. 在左侧边栏中，选择 **访问** > **SSH 密钥**。
1. 在要撤销的 SSH 密钥旁边，选择 **撤销**。
1. 选择 **撤销**。

<a id="delete-an-ssh-key"></a>

### 删除 SSH 密钥

要删除 SSH 密钥：

1. 在右上角，选择您的头像。
1. 选择 **编辑个人资料**。
1. 在左侧边栏中，选择 **访问** > **SSH 密钥**。
1. 在要删除的密钥旁边，选择 **移除**（{{< icon name="remove" >}}）。
1. 选择 **删除**。

<a id="ssh-key-expiration"></a>

## SSH 密钥过期

您可以在向账户添加 SSH 密钥时设置过期日期。此可选设置有助于降低安全漏洞的风险。

SSH 密钥过期后，您将无法再使用它进行身份验证或签署提交。您必须
[生成新的 SSH 密钥](#generate-an-ssh-key-pair)并
[将其添加到您的账户](#add-an-ssh-key-to-your-gitlab-account)。

在极狐GitLab 私有化部署上，管理员可以查看过期日期，并在
[删除密钥](../administration/credentials_inventory.md#delete-ssh-keys)时将其作为参考。

极狐GitLab 每天检查即将过期的 SSH 密钥并发送通知：

- 在过期前七天，UTC 时间凌晨 01:00。
- 在过期日期当天，UTC 时间凌晨 02:00。
