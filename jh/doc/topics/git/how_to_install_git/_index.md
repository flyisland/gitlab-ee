---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: How to install Git on your local machine.
title: 安装 Git
---

要参与极狐GitLab 项目，你必须在本地机器上下载、安装和配置 Git 客户端。极狐GitLab 使用 SSH 协议与 Git 安全通信。通过 SSH，你可以向极狐GitLab 远程服务器进行身份验证，而无需每次输入用户名和密码。

安装并配置 Git 后，[生成并添加 SSH 密钥对](../../../user/ssh.md#generate-an-ssh-key-pair) 到你的极狐GitLab 账户。

<a id="install-and-update-git"></a>

## 安装和更新 Git

{{< tabs >}}

{{< tab title="macOS" >}}

尽管 macOS 自带了一个 Git 版本，但你应安装最新版的 Git。常见的安装方式是通过 [Homebrew](https://brew.sh/index.html)。

要在 macOS 上使用 Homebrew 安装最新版本的 Git：

1. 如果你之前从未安装过 Homebrew，请按照 [Homebrew 安装说明](https://brew.sh/index.html) 操作。
1. 在终端中，通过运行 `brew install git` 来安装 Git。
1. 验证 Git 在你的本地机器上是否可以工作：

   ```shell
   git --version
   ```

通过定期运行以下命令保持 Git 为最新版本：

```shell
brew update && brew upgrade git
```

{{< /tab >}}

{{< tab title="Ubuntu Linux" >}}

尽管 Ubuntu 自带了一个 Git 版本，但你应安装最新版的 Git。最新版本可通过个人软件包存档 (PPA) 获取。

要通过 PPA 在 Ubuntu Linux 上安装最新版本的 Git：

1. 在终端中，配置所需的 PPA，更新 Ubuntu 软件包列表，然后安装 `git`：

   ```shell
   sudo apt-add-repository ppa:git-core/ppa
   sudo apt-get update
   sudo apt-get install git
   ```

1. 验证 Git 在你的本地机器上是否可以工作：

   ```shell
   git --version
   ```

通过定期运行以下命令保持 Git 为最新版本：

```shell
sudo apt-get update && sudo apt-get install git
```

{{< /tab >}}

{{< tab title="其他操作系统" >}}

有关在其他操作系统上下载和安装 Git 的信息，请参阅 [Git 官方网站](https://git-scm.com/downloads)。

{{< /tab >}}

{{< /tabs >}}

<a id="configure-git"></a>

## 配置 Git

要开始在本地机器上使用 Git，你必须输入凭据，以标识自己为工作的作者。

你可以在本地或全局配置你的 Git 身份：

- 本地：仅用于当前项目。
- 全局：用于所有当前和将来的项目。

{{< tabs >}}

{{< tab title="本地设置" >}}

在本地配置你的 Git 身份，以便仅用于当前项目。

全名和电子邮件地址应与你在极狐GitLab 中使用的保持一致。

1. 在终端中，添加你的全名。例如：

   ```shell
   git config --local user.name "Alex Smith"
   ```

1. 添加你的电子邮件地址。例如：

   ```shell
   git config --local user.email "your_email_address@example.com"
   ```

1. 要检查配置，请运行：

   ```shell
   git config --local --list
   ```

{{< /tab >}}

{{< tab title="全局设置" >}}

在全局配置你的 Git 身份，以便用于你机器上所有当前和将来的项目。

全名和电子邮件地址应与你在极狐GitLab 中使用的保持一致。

1. 在终端中，添加你的全名。例如：

   ```shell
   git config --global user.name "Sidney Jones"
   ```

1. 添加你的电子邮件地址。例如：

   ```shell
   git config --global user.email "your_email_address@example.com"
   ```

1. 要检查配置，请运行：

   ```shell
   git config --global --list
   ```

{{< /tab >}}

{{< /tabs >}}

<a id="check-git-configuration-settings"></a>

### 检查 Git 配置设置

要检查已配置的 Git 设置，请运行：

```shell
git config user.name && git config user.email
```