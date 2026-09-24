---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Install the Linux package on Ubuntu
title: 在 Ubuntu 上安装 Linux 软件包
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

> [!note]
> 查看[支持的平台](_index.md#supported-platforms)获取完整支持发行版和架构列表。

<a id="prerequisites"></a>

## 先决条件

- 操作系统要求：
  - Ubuntu 20.04
  - Ubuntu 22.04
  - Ubuntu 24.04
- 查看[安装要求](../requirements.md)了解最低硬件要求。
- 开始之前，确保已正确[设置 DNS](https://gitlab.cn/docs/omnibus/settings/dns)。
  将以下命令中的 `https://gitlab.example.com` 替换为你首选的极狐GitLab URL。极狐GitLab 将自动配置并在该地址启动。
- 对于 `https://` URL，极狐GitLab 会自动[通过 Let's Encrypt 请求证书](https://gitlab.cn/docs/omnibus/settings/ssl/#enable-the-lets-encrypt-integration)，
  这需要入站 HTTP 访问和有效的主机名。你也可以使用
  [自己的证书](https://gitlab.cn/docs/omnibus/settings/ssl/#configure-https-manually)，
  或仅使用 `http://`（不带 `s`）作为未加密的 URL。
- Linux 软件包和其他相关元数据文件存储在 Google Cloud Storage 中并提供服务。如果使用防火墙，需要允许访问以下 URL 前缀：
  - `https://packages.gitlab.cn/*`
  - `https://storage.googleapis.com/packages-ops/*`

<a id="enable-ssh-and-open-firewall-ports"></a>

## 启用 SSH 并打开防火墙端口

要打开所需的防火墙端口（80、443、22）并能够访问极狐GitLab：

1. 启用并启动 OpenSSH 服务器守护进程：

   ```shell
   sudo systemctl enable --now ssh
   ```

1. 安装 `ufw` 后，打开防火墙端口：

   ```shell
   sudo ufw allow 22/tcp
   sudo ufw allow 80/tcp
   sudo ufw allow 443/tcp
   sudo ufw enable
   ```

<a id="add-the-gitlab-package-repository"></a>

## 添加极狐GitLab 软件包仓库

要安装极狐GitLab，首先添加极狐GitLab 软件包仓库。

1. 安装所需的软件包：

   ```shell
   sudo apt update
   sudo apt install -y curl
   ```

1. 使用以下脚本添加极狐GitLab 仓库（你可以将脚本 URL 粘贴到浏览器中查看其作用，然后再通过管道传递给 `bash`）：

   {{< tabs >}}

   {{< tab title="极狐版" >}}

   ```shell
   curl --location "https://packages.gitlab.cn/repository/raw/scripts/setup.sh" | sudo bash
   ```

   {{< /tab >}}

   {{< /tabs >}}

<a id="install-the-package"></a>

## 安装软件包

使用系统包管理器安装极狐GitLab。

> [!note]
> 设置 `EXTERNAL_URL` 是可选的，但建议设置。
> 如果在安装时未设置，可以
> [稍后设置](https://gitlab.cn/docs/omnibus/settings/configuration/#configure-the-external-url-for-gitlab)。

{{< tabs >}}

{{< tab title="极狐版" >}}

```shell
sudo EXTERNAL_URL="https://gitlab.example.com" apt install gitlab-jh
```

{{< /tab >}}

{{< /tabs >}}

极狐GitLab 会为 root 管理员账户生成一个随机密码和电子邮件地址，存储在 `/etc/gitlab/initial_root_password` 中，有效期为 24 小时。
24 小时后，出于安全原因，该文件会被自动删除。

<a id="initial-sign-in"></a>

## 初始登录

安装极狐GitLab 后，访问你设置的 URL，并使用以下凭据登录：

- 用户名：`root`
- 密码：查看 `/etc/gitlab/initial_root_password`

登录后，更改你的[密码](../../user/profile/user_passwords.md#change-your-password)
和[电子邮件地址](../../user/profile/_index.md#add-emails-to-your-user-profile)。

<a id="advanced-configuration"></a>

## 高级配置

你可以在安装前通过设置以下可选环境变量来自定义极狐GitLab 安装。**这些变量仅在首次安装时有效**，对后续的重新配置运行没有影响。对于现有安装，请使用 `/etc/gitlab/initial_root_password` 中的密码或[重置 root 密码](../../security/reset_user_password.md)。

| 变量 | 用途 | 是否必需 | 示例 |
|----------|---------|----------|---------|
| `EXTERNAL_URL` | 设置极狐GitLab 实例的外部 URL | 建议 | `EXTERNAL_URL="https://gitlab.example.com"` |
| `GITLAB_ROOT_EMAIL` | root 管理员账户的自定义电子邮件 | 可选 | `GITLAB_ROOT_EMAIL="admin@example.com"` |
| `GITLAB_ROOT_PASSWORD` | root 管理员账户的自定义密码（至少 8 个字符） | 可选 | `GITLAB_ROOT_PASSWORD="strongpassword"` |

如果极狐GitLab 在安装期间无法检测到有效的主机名，重新配置将不会自动运行。
在这种情况下，将所需的环境变量传递给第一个 `gitlab-ctl reconfigure` 命令。

> [!warning]
> 虽然你也可以通过在 `/etc/gitlab/gitlab.rb` 中设置
> `gitlab_rails['initial_root_password']` 来设置初始密码，但不建议这样做。
> 这存在安全风险，因为密码是明文存储的。如果你进行了此配置，
> 请确保在安装后将其删除。

使用上述环境变量自定义极狐GitLab 安装：

{{< tabs >}}

{{< tab title="极狐版" >}}

```shell
sudo GITLAB_ROOT_EMAIL="admin@example.com" GITLAB_ROOT_PASSWORD="strongpassword" EXTERNAL_URL="https://gitlab.example.com" apt install gitlab-jh
```

{{< /tab >}}

{{< /tabs >}}

<a id="set-up-your-communication-preferences"></a>

## 设置你的通信偏好

访问我们的[电子邮件订阅偏好中心](https://gitlab.cn/company/preference-center/)
告知我们何时与你联系。我们有明确的电子邮件选择加入政策，因此你可以完全控制我们向你发送电子邮件的内容和频率。

每月两次，我们会发送你需要了解的极狐GitLab 新闻，包括新功能、集成、文档以及我们开发团队的幕后故事。
对于与错误和系统性能相关的关键安全更新，请注册我们的专用安全新闻通讯。

> [!note]
> 如果你未选择加入安全新闻通讯，将不会收到安全警报。

<a id="recommended-next-steps"></a>

## 推荐的后续步骤

完成安装后，请考虑[推荐的后续步骤，包括身份验证选项和新用户账户限制](../next_steps.md)。
