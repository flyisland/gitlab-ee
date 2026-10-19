---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 使用 Gravatar、Libravatar 或自定义服务为用户个人资料设置头像服务。
title: 将 Libravatar 服务与极狐GitLab 搭配使用
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 默认支持 [Gravatar](https://gravatar.com) 头像服务。

Libravatar 是另一种将您的头像（个人资料图片）提供给其他网站的服务。Libravatar API [很大程度上基于 Gravatar](https://wiki.libravatar.org/api/)，因此您可以
切换到 Libravatar 头像服务，甚至使用您自己的 Libravatar
服务器。

<a id="change-the-libravatar-service-to-your-own-service"></a>

## 将 Libravatar 服务更改为您自己的服务

在 [`gitlab.yml`的 gravatar 部分](https://gitlab.com/gitlab-org/gitlab/-/blob/68dac188ec6b1b03d53365e7579422f44cbe7a1c/config/gitlab.yml.example#L469-476)中，按如下方式设置配置选项：

对于 Linux 软件包安装：

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['gravatar_enabled'] = true
   #### For HTTPS
   gitlab_rails['gravatar_ssl_url'] = "https://seccdn.libravatar.org/avatar/%{hash}?s=%{size}&d=identicon"
   #### Use this line instead for HTTP
   # gitlab_rails['gravatar_plain_url'] = "http://cdn.libravatar.org/avatar/%{hash}?s=%{size}&d=identicon"
   ```

1. 要应用更改，请运行 `sudo gitlab-ctl reconfigure`。

对于自行编译安装：

1. 编辑 `config/gitlab.yml`：

   ```yaml
     gravatar:
       enabled: true
       # default: https://www.gravatar.com/avatar/%{hash}?s=%{size}&d=identicon
       plain_url: "http://cdn.libravatar.org/avatar/%{hash}?s=%{size}&d=identicon"
       # default: https://secure.gravatar.com/avatar/%{hash}?s=%{size}&d=identicon
       ssl_url: "https://seccdn.libravatar.org/avatar/%{hash}?s=%{size}&d=identicon"
   ```

1. 保存文件，然后[重启](restart_gitlab.md#self-compiled-installations)
   极狐GitLab 以使更改生效。

<a id="set-the-libravatar-service-to-default-gravatar"></a>

## 将 Libravatar 服务设置为默认（Gravatar）

对于 Linux 软件包安装：

1. 从 `/etc/gitlab/gitlab.rb`中删除 `gitlab_rails['gravatar_ssl_url']` 或 `gitlab_rails['gravatar_plain_url']`。
1. 要应用更改，请运行 `sudo gitlab-ctl reconfigure`。

对于自行编译安装：

1. 从 `config/gitlab.yml`中移除 `gravatar:` 部分。
1. 保存文件，然后[重启](restart_gitlab.md#self-compiled-installations)
   极狐GitLab 以应用更改。

<a id="disable-gravatar-service"></a>

## 禁用 Gravatar 服务

要禁用 Gravatar，例如禁止使用第三方服务，请完成以下步骤：

对于 Linux 软件包安装：

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['gravatar_enabled'] = false
   ```

1. 要应用更改，请运行 `sudo gitlab-ctl reconfigure`。

对于自行编译安装：

1. 编辑 `config/gitlab.yml`：

   ```yaml
     gravatar:
       enabled: false
   ```

1. 保存文件，然后[重启](restart_gitlab.md#self-compiled-installations)
   极狐GitLab 以应用更改。

<a id="your-own-libravatar-server"></a>

### 您自己的 Libravatar 服务器

如果您[运行自己的 Libravatar 服务](https://wiki.libravatar.org/running_your_own/)，配置中的 URL 会有所不同，但您必须提供相同的占位符，以便极狐GitLab 能够正确解析该 URL。

例如，您在 `https://libravatar.example.com` 上托管服务，那么您必须在 `gitlab.yml`中提供的 `ssl_url` 为：

`https://libravatar.example.com/avatar/%{hash}?s=%{size}&d=identicon`

<a id="default-url-for-missing-images"></a>

## 缺失图片的默认 URL

[Libravatar 支持不同的集合](https://wiki.libravatar.org/api/)，
用于在 Libravatar 服务上找不到用户电子邮件地址时显示的缺失图片。

要使用 `identicon` 以外的集合，请将 URL 中的 `&d=identicon` 部分替换为其他受支持的集合。例如，您可以使用 `retro` 集合，此时 URL 将如下所示：`ssl_url: "https://seccdn.libravatar.org/avatar/%{hash}?s=%{size}&d=retro"`

<a id="usage-examples-for-microsoft-office-365"></a>

## Microsoft Office 365 的使用示例

如果您的用户是 Office 365 用户，可以使用 `GetPersonaPhoto` 服务。该服务需要登录，因此此用例最适合所有用户都能访问 Office 365 的企业安装环境。

```ruby
gitlab_rails['gravatar_plain_url'] = 'http://outlook.office.com/owa/service.svc/s/GetPersonaPhoto?email=%{email}&size=HR120x120'
gitlab_rails['gravatar_ssl_url'] = 'https://outlook.office.com/owa/service.svc/s/GetPersonaPhoto?email=%{email}&size=HR120x120'
```
