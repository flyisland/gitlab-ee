---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 设置 Postfix 以接收邮件
description: Configure Postfix for incoming email.
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

本文档将引导你完成在 Ubuntu 上设置一个带有 IMAP 认证的基本 Postfix 邮件服务器的步骤，用于 [接收邮件](incoming_email.md)。

这些说明假设你使用的是电子邮件地址 `incoming@gitlab.example.com`，即主机 `gitlab.example.com` 上的用户名 `incoming`。在执行示例代码片段时，请不要忘记将其更改为你的实际主机。

<a id="configure-your-server-firewall"></a>

## 配置服务器防火墙

1. 在服务器上打开端口 25，以便人们可以通过 SMTP 向服务器发送邮件。
1. 如果邮件服务器与运行极狐GitLab 的服务器不同，请在服务器上打开端口 143，以便极狐GitLab 可以通过 IMAP 从服务器读取邮件。

<a id="install-packages"></a>

## 安装软件包

1. 如果尚未安装 `postfix` 软件包，请安装它：

   ```shell
   sudo apt-get install postfix
   ```

   当询问环境时，选择 'Internet Site'。当要求确认主机名时，请确保它与 `gitlab.example.com` 匹配。

1. 安装 `mailutils` 软件包。

   ```shell
   sudo apt-get install mailutils
   ```

<a id="create-user"></a>

## 创建用户

1. 为接收邮件创建一个用户。

   ```shell
   sudo useradd -m -s /bin/bash incoming
   ```

1. 为该用户设置密码。

   ```shell
   sudo passwd incoming
   ```

   请务必记住此密码，稍后会用到。

<a id="test-the-out-of-the-box-setup"></a>

## 测试开箱即用的设置

1. 连接到本地 SMTP 服务器：

   ```shell
   telnet localhost 25
   ```

   你应该会看到类似以下的提示：

   ```shell
   Trying 127.0.0.1...
   Connected to localhost.
   Escape character is '^]'.
   220 gitlab.example.com ESMTP Postfix (Ubuntu)
   ```

   如果收到 `Connection refused` 错误，请验证 `postfix` 是否正在运行：

   ```shell
   sudo postfix status
   ```

   如果未运行，请启动它：

   ```shell
   sudo postfix start
   ```

1. 向新创建的 `incoming` 用户发送一封测试 SMTP 的邮件，在 SMTP 提示符下输入以下内容：

   ```plaintext
   ehlo localhost
   mail from: root@localhost
   rcpt to: incoming@localhost
   data
   Subject: 回复：某个议题

   听起来不错！
   .
   quit
   ```

   > [!note]
   > `.` 是单独一行上的一个字面句点。

   如果在输入 `rcpt to: incoming@localhost` 后收到错误，则你的 Postfix `my_network` 配置不正确。错误信息会显示 'Temporary lookup failure'。请参阅 [配置 Postfix 接收来自互联网的邮件](#configure-postfix-to-receive-email-from-the-internet)。

1. 检查 `incoming` 用户是否收到了邮件：

   ```shell
   su - incoming
   mail
   ```

   你应该会看到类似以下的输出：

   ```plaintext
   "/var/mail/incoming": 1 message 1 unread
   >U   1 root@localhost                           59/2842  回复：某个议题
   ```

   退出邮件程序：

   ```shell
   q
   ```

1. 退出 `incoming` 账户，返回 `root` 身份：

   ```shell
   logout
   ```

<a id="configure-postfix-to-use-maildir-style-mailboxes"></a>

## 配置 Postfix 使用 Maildir 格式邮箱

Courier（我们稍后会安装以添加 IMAP 认证）要求邮箱采用 Maildir 格式，而不是 mbox。

1. 配置 Postfix 使用 Maildir 格式邮箱：

   ```shell
   sudo postconf -e "home_mailbox = Maildir/"
   ```

1. 重启 Postfix：

   ```shell
   sudo /etc/init.d/postfix restart
   ```

1. 测试新设置：

   1. 按照 [测试开箱即用的设置](#test-the-out-of-the-box-setup) 的步骤 1 和 2 操作。
   1. 检查 `incoming` 用户是否收到了邮件：

      ```shell
      su - incoming
      MAIL=/home/incoming/Maildir
      mail
      ```

      你应该会看到类似以下的输出：

      ```plaintext
      "/home/incoming/Maildir": 1 message 1 unread
      >U   1 root@localhost                           59/2842  回复：某个议题
      ```

      退出邮件程序：

      ```shell
      q
      ```

   如果 `mail` 返回错误 `Maildir: Is a directory`，则你的 `mail` 版本不支持 Maildir 格式邮箱。通过运行 `sudo apt-get install heirloom-mailx` 安装 `heirloom-mailx`。然后，再次尝试上述步骤，将 `mail` 命令替换为 `heirloom-mailx`。

1. 退出 `incoming` 账户，返回 `root` 身份：

   ```shell
   logout
   ```

<a id="install-the-courier-imap-server"></a>

## 安装 Courier IMAP 服务器

1. 安装 `courier-imap` 软件包：

   ```shell
   sudo apt-get install courier-imap
   ```

   Ubuntu 24.04 没有 `courier-imap` 软件包。更多信息，请参阅 [Ubuntu bug 2071662](https://bugs.launchpad.net/ubuntu/+source/courier/+bug/2071662)。

   安装 `courier-imap` 后，启动 `imapd`：

   ```shell
   imapd start
   ```

1. 安装后 `courier-authdaemon` 不会自动启动。没有它，IMAP 认证会失败：

   ```shell
   sudo service courier-authdaemon start
   ```

   你还可以配置 `courier-authdaemon` 在启动时自动运行：

   ```shell
   sudo systemctl enable courier-authdaemon
   ```

<a id="configure-postfix-to-receive-email-from-the-internet"></a>

## 配置 Postfix 接收来自互联网的邮件

1. 让 Postfix 知道它应视为本地的域：

   ```shell
   sudo postconf -e "mydestination = gitlab.example.com, localhost.localdomain, localhost"
   ```

1. 让 Postfix 知道它应视为局域网一部分的 IP：

   假设 `192.168.1.0/24` 是你的本地局域网。如果你在同一本地网络中没有其他机器，可以安全地跳过此步骤。

   ```shell
   sudo postconf -e "mynetworks = 127.0.0.0/8, 192.168.1.0/24"
   ```

1. 配置 Postfix 在所有接口上接收邮件，包括互联网：

   ```shell
   sudo postconf -e "inet_interfaces = all"
   ```

1. 配置 Postfix 使用 `+` 作为子地址分隔符：

   ```shell
   sudo postconf -e "recipient_delimiter = +"
   ```

1. 重启 Postfix：

   ```shell
   sudo service postfix restart
   ```

<a id="test-the-final-setup"></a>

## 测试最终设置

1. 测试新设置下的 SMTP：

   1. 连接到 SMTP 服务器：

      ```shell
      telnet gitlab.example.com 25
      ```

      你应该会看到类似以下的提示：

      ```shell
      Trying 123.123.123.123...
      Connected to gitlab.example.com.
      Escape character is '^]'.
      220 gitlab.example.com ESMTP Postfix (Ubuntu)
      ```

      如果收到 `Connection refused` 错误，请确保防火墙已设置为允许端口 25 的入站流量。

   1. 向 `incoming` 用户发送一封测试 SMTP 的邮件，在 SMTP 提示符下输入以下内容：

      ```plaintext
      ehlo gitlab.example.com
      mail from: root@gitlab.example.com
      rcpt to: incoming@gitlab.example.com
      data
      Subject: 回复：某个议题

      听起来不错！
      .
      quit
      ```

      > [!note]
      > `.` 是单独一行上的一个字面句点。

   1. 检查 `incoming` 用户是否收到了邮件：

      ```shell
      su - incoming
      MAIL=/home/incoming/Maildir
      mail
      ```

      你应该会看到类似以下的输出：

      ```plaintext
      "/home/incoming/Maildir": 1 message 1 unread
      >U   1 root@gitlab.example.com                           59/2842  回复：某个议题
      ```

      退出邮件程序：

      ```shell
      q
      ```

   1. 退出 `incoming` 账户，返回 `root` 身份：

      ```shell
      logout
      ```

1. 测试新设置下的 IMAP：

   1. 连接到 IMAP 服务器：

      ```shell
      telnet gitlab.example.com 143
      ```

      你应该会看到类似以下的提示：

      ```shell
      Trying 123.123.123.123...
      Connected to mail.gitlab.example.com.
      Escape character is '^]'.
      - OK [CAPABILITY IMAP4rev1 UIDPLUS CHILDREN NAMESPACE THREAD=ORDEREDSUBJECT THREAD=REFERENCES SORT QUOTA IDLE ACL ACL2=UNION] Courier-IMAP ready. Copyright 1998-2011 Double Precision, Inc.  See COPYING for distribution information.
      ```

   1. 以 `incoming` 用户身份登录以测试 IMAP，在 IMAP 提示符下输入以下内容：

      ```plaintext
      a login incoming PASSWORD
      ```

      将 PASSWORD 替换为你之前为 `incoming` 用户设置的密码。

      你应该会看到类似以下的输出：

      ```plaintext
      a OK LOGIN Ok.
      ```

   1. 断开与 IMAP 服务器的连接：

      ```shell
      a logout
      ```

<a id="done"></a>

## 完成

如果所有测试都成功，Postfix 已全部设置完毕并准备好接收邮件！继续按照 [接收邮件](incoming_email.md) 指南配置极狐GitLab。

---

_本文档改编自 <https://help.ubuntu.com/community/PostfixBasicSetupHowto>，由 Ubuntu 文档维基的贡献者提供。_

