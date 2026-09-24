---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Install the Linux package on Amazon Linux 2
title: 在 Amazon Linux 2 上安装极狐GitLab Linux 软件包
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

> [!note]
> 请参阅[支持的平台](_index.md#supported-platforms)获取完整的支持发行版和架构列表。

<a id="prerequisites"></a>

先决条件

- 操作系统要求：
  - Amazon Linux 2
- 请参阅[安装要求](../requirements.md)了解最低硬件要求。
- 开始之前，请确保已正确[设置您的 DNS](https://gitlab.cn/docs/omnibus/settings/dns)。
  在以下命令中将 `https://gitlab.example.com` 替换为您首选的极狐GitLab URL。极狐GitLab 将自动配置并在该地址启动。
- 对于 `https://` URL，极狐GitLab 会自动
  [使用 Let's Encrypt 请求证书](https://gitlab.cn/docs/omnibus/settings/ssl/#enable-the-lets-encrypt-integration)，
  这需要入站 HTTP 访问和有效的主机名。您也可以使用
  [自己的证书](https://gitlab.cn/docs/omnibus/settings/ssl/#configure-https-manually)，
  或者仅使用 `http://`（不带 `s`）作为未加密的 URL。
- Linux 软件包和其他相关元数据文件存储并托管在
  Google Cloud Storage 中。如果使用防火墙，您需要允许访问以下 URL 前缀：
      - `https://packages.gitlab.cn/*`
      - `https://storage.googleapis.com/packages-ops/*`

<a id="enable-ssh-and-open-firewall-ports"></a>

启用 SSH 并打开防火墙端口

要打开所需的防火墙端口（80、443、22）并能够访问极狐GitLab：

1. 启用并启动 OpenSSH 服务器守护进程：

   ```shell
   sudo systemctl enable --now sshd
   ```

1. 如果已安装 `firewalld`，打开防火墙端口：

   ```shell
   sudo firewall-cmd --permanent --add-service=http
   sudo firewall-cmd --permanent --add-service=https
   sudo firewall-cmd --permanent --add-service=ssh
   sudo systemctl reload firewalld
   ```

<a id="add-the-gitlab-package-repository"></a>

添加极狐GitLab 软件包仓库

要安装极狐GitLab，首先添加极狐GitLab 软件包仓库。

1. 安装所需的软件包：

   ```shell
   sudo yum install -y curl
   ```

1. 使用以下脚本添加极狐GitLab 仓库（您可以将脚本的 URL 粘贴到浏览器中，以在通过管道传递给 `bash` 之前查看其内容）：

   {{< tabs >}}

   {{< tab title="极狐版" >}}

   ```shell
   curl --location "https://packages.gitlab.cn/repository/raw/scripts/setup.sh" | sudo bash
   ```

   {{< /tab >}}

   {{< /tabs >}}

<a id="install-the-package"></a>

安装软件包

使用系统的软件包管理器安装极狐GitLab。

> [!note]
> 设置 `EXTERNAL_URL` 是可选的，但建议设置。
> 如果在安装过程中未设置，您可以
> [稍后设置](https://gitlab.cn/docs/omnibus/settings/configuration/#configure-the-external-url-for-gitlab)。

{{< tabs >}}

{{< tab title="极狐版" >}}

```shell
sudo EXTERNAL_URL="https://gitlab.example.com" yum install gitlab-jh
```

{{< /tab >}}

{{< /tabs >}}

极狐GitLab 会为 root 管理员账户生成一个随机密码和电子邮件地址，并存储在 `/etc/gitlab/initial_root_password` 中，有效期为 24 小时。
24 小时后，出于安全原因，该文件会被自动删除。

<a id="initial-sign-in"></a>

初始登录

极狐GitLab 安装完成后，前往您设置的 URL，并使用以下凭据登录：

- 用户名：`root`
- 密码：请查看 `/etc/gitlab/initial_root_password`

登录后，更改您的[密码](../../user/profile/user_passwords.md#change-your-password)和[电子邮件地址](../../user/profile/_index.md#add-emails-to-your-user-profile)。

<a id="advanced-configuration"></a>

高级配置

您可以在安装前通过设置以下可选环境变量来自定义极狐GitLab 安装。**这些变量仅在首次安装时有效**，对后续的重新配置运行没有影响。对于现有安装，请使用 `/etc/gitlab/initial_root_password` 中的密码或[重置 root 密码](../../security/reset_user_password.md)。

| 变量 | 用途 | 是否必需 | 示例 |
|----------|---------|----------|---------|
| `EXTERNAL_URL` | 设置极狐GitLab 实例的外部 URL | 建议 | `EXTERNAL_URL="https://gitlab.example.com"` |
| `GITLAB_ROOT_EMAIL` | 为 root 管理员账户设置自定义电子邮件 | 可选 | `GITLAB_ROOT_EMAIL="admin@example.com"` |
| `GITLAB_ROOT_PASSWORD` | 为 root 管理员账户设置自定义密码（最少 8 个字符） | 可选 | `GITLAB_ROOT_PASSWORD="strongpassword"` |

如果极狐GitLab 在安装过程中无法检测到有效的主机名，则不会自动运行重新配置。
在这种情况下，请将任何所需的环境变量传递给您的第一个 `gitlab-ctl reconfigure` 命令。

> [!warning]
> 虽然您也可以通过设置 `/etc/gitlab/gitlab.rb` 中的 `gitlab_rails['initial_root_password']` 来设置初始密码，但不建议这样做。
> 这会带来安全风险，因为密码以明文形式存储。如果您已进行此配置，请确保在安装后将其删除。

使用上述环境变量自定义极狐GitLab 安装：

{{< tabs >}}

{{< tab title="极狐版" >}}

```shell
sudo GITLAB_ROOT_EMAIL="admin@example.com" GITLAB_ROOT_PASSWORD="strongpassword" EXTERNAL_URL="https://gitlab.example.com" yum install gitlab-jh
```

{{< /tab >}}

{{< /tabs >}}

<a id="set-up-your-communication-preferences"></a>

设置您的通信偏好

请访问我们的[电子邮件订阅偏好中心](https://gitlab.cn/company/preference-center/)，告知我们何时与您联系。我们实行明确的电子邮件选择加入政策，因此您可以完全控制我们发送电子邮件的内容和频率。

我们每月两次发送您需要了解的极狐GitLab 新闻，包括新功能、集成、文档以及我们开发团队的幕后故事。对于与漏洞和系统性能相关的关键安全更新，请注册我们的专用安全通讯。

> [!note]
> 如果您未选择加入安全通讯，将不会收到安全警报。

<a id="recommended-next-steps"></a>

推荐的后续步骤

安装完成后，请考虑[推荐的后续步骤，包括身份验证选项和新用户账户限制](../next_steps.md)。
