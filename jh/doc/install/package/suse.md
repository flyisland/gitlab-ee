---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 在 OpenSUSE 和 SLES 上安装 Linux 软件包
title: 在 OpenSUSE 和 SLES 上安装 Linux 软件包
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

> [!note]
> 查看 [支持的平台](_index.md#supported-platforms) 获取受支持的发行版和架构的完整列表。

## 先决条件

- 操作系统要求：
  - OpenSUSE Leap 15.6
  - SLES 12
  - SLES 15 SP6
- 请参阅 [安装要求](../requirements.md) 了解最低硬件要求。
- 开始之前，请确保您已正确 [设置 DNS](https://gitlab.cn/docs/omnibus/settings/dns)。在以下命令中将 `https://gitlab.example.com` 替换为您首选的极狐GitLab URL。极狐GitLab 将自动配置并在该地址启动。
- 对于 `https://` URL，极狐GitLab 会自动 [通过 Let's Encrypt 请求证书](https://gitlab.cn/docs/omnibus/settings/ssl/#enable-the-lets-encrypt-integration)，这需要入站 HTTP 访问和有效的主机名。您也可以使用 [自己的证书](https://gitlab.cn/docs/omnibus/settings/ssl/#configure-https-manually)，或者仅使用 `http://`（不带 `s`）作为未加密的 URL。
- Linux 软件包和其他相关元数据文件存储并从 Google Cloud Storage 提供。如果使用防火墙，您需要允许访问以下 URL 前缀：
      - `https://packages.gitlab.cn/*`
      - `https://storage.googleapis.com/packages-ops/*`

## 启用 SSH 并打开防火墙端口

要打开所需的防火墙端口 (80, 443, 22) 并能够访问极狐GitLab：

1. 启用并启动 OpenSSH 服务器守护进程：

   ```shell
   sudo systemctl enable --now sshd
   ```

1. 安装 `firewalld` 后，打开防火墙端口：

   ```shell
   sudo firewall-cmd --permanent --add-service=http
   sudo firewall-cmd --permanent --add-service=https
   sudo firewall-cmd --permanent --add-service=ssh
   sudo systemctl reload firewalld
   ```

## 添加极狐GitLab 软件包仓库

要安装极狐GitLab，首先添加极狐GitLab 软件包仓库。

1. 安装所需的软件包：

   ```shell
   sudo zypper install curl
   ```

1. 使用以下脚本添加极狐GitLab 仓库（您可以在管道传输到 `bash` 之前，将脚本的 URL 粘贴到浏览器中以查看其功能）：

   {{< tabs >}}

   {{< tab title="极狐版" >}}

   ```shell
   curl --location "https://packages.gitlab.cn/repository/raw/scripts/setup.sh" | sudo bash
   ```

   {{< /tab >}}

   {{< /tabs >}}

## 安装软件包

使用您系统的软件包管理器安装极狐GitLab。

> [!note]
> 设置 `EXTERNAL_URL` 是可选的，但推荐设置。如果您在安装时未设置，可以 [之后再进行设置](https://gitlab.cn/docs/omnibus/settings/configuration/#configure-the-external-url-for-gitlab)。

{{< tabs >}}

{{< tab title="极狐版" >}}

```shell
sudo EXTERNAL_URL="https://gitlab.example.com" zypper install gitlab-jh
```

{{< /tab >}}

{{< /tabs >}}

极狐GitLab 会为 root 管理员账户生成一个随机密码和电子邮箱地址，并将其存储在 `/etc/gitlab/initial_root_password` 中，有效期为 24 小时。出于安全考虑，该文件会在 24 小时后自动删除。

## 初始登录

极狐GitLab 安装完成后，请访问您设置的 URL，并使用以下凭据登录：

- 用户名：`root`
- 密码：请查看 `/etc/gitlab/initial_root_password`

登录后，请修改您的 [密码](../../user/profile/user_passwords.md#change-your-password) 和 [电子邮箱地址](../../user/profile/_index.md#add-emails-to-your-user-profile)。

## 高级配置

您可以在安装前设置以下可选环境变量来自定义极狐GitLab 安装。**这些变量仅在首次安装时有效**，对后续的重新配置运行没有影响。对于现有安装，请使用 `/etc/gitlab/initial_root_password` 中的密码或 [重置 root 密码](../../security/reset_user_password.md)。

| 变量 | 用途 | 是否必须 | 示例 |
|----------|---------|----------|---------|
| `EXTERNAL_URL` | 设置极狐GitLab 实例的外部 URL | 推荐 | `EXTERNAL_URL="https://gitlab.example.com"` |
| `GITLAB_ROOT_EMAIL` | root 管理员账户的自定义电子邮箱 | 可选 | `GITLAB_ROOT_EMAIL="admin@example.com"` |
| `GITLAB_ROOT_PASSWORD` | root 管理员账户的自定义密码（至少 8 个字符） | 可选 | `GITLAB_ROOT_PASSWORD="strongpassword"` |

如果极狐GitLab 在安装过程中无法检测到有效的主机名，则不会自动运行重新配置。在这种情况下，请将任何所需的环境变量传递给您的第一个 `gitlab-ctl reconfigure` 命令。

> [!warning]
> 虽然您也可以通过设置 `/etc/gitlab/gitlab.rb` 中的 `gitlab_rails['initial_root_password']` 来设置初始密码，但不建议这样做。这会带来安全风险，因为密码是明文存储的。如果您配置了此项，请务必在安装后将其删除。

使用上述环境变量自定义极狐GitLab 安装：

{{< tabs >}}

{{< tab title="极狐版" >}}

```shell
sudo GITLAB_ROOT_EMAIL="admin@example.com" GITLAB_ROOT_PASSWORD="strongpassword" EXTERNAL_URL="https://gitlab.example.com" zypper install gitlab-jh
```

{{< /tab >}}

{{< /tabs >}}

## 设置您的通信偏好

访问我们的 [电子邮件订阅偏好中心](https://gitlab.cn/company/preference-center/) 告知我们何时与您联系。我们有明确的电子邮件选择加入政策，因此您可以完全控制我们向您发送电子邮件的内容和频率。

我们每月两次发送您需要了解的极狐GitLab 新闻，包括新功能、集成、文档以及来自我们开发团队的幕后故事。有关与错误和系统性能相关的关键安全更新，请注册我们的专用安全新闻简报。

> [!note]
> 如果您未选择加入安全新闻简报，将不会收到安全警报。

## 推荐的后续步骤

完成安装后，请考虑 [推荐的后续步骤，包括身份验证选项和新用户账户限制](../next_steps.md)。
