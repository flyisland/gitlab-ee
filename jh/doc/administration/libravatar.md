---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Set up avatar services for user profiles using Gravatar, Libravatar, or custom services.
title: 在极狐GitLab 中使用 Libravatar 服务
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 默认支持 [Gravatar](https://gravatar.com) 头像服务。

Libravatar 是另一个可以将你的头像（个人资料图片）投递到其他网站的服务。Libravatar 的 API [极度依赖 Gravatar](https://wiki.libravatar.org/api/)，因此你可以切换到 Libravatar 头像服务，甚至是你自己的 Libravatar 服务器。

<a id="change-the-libravatar-service-to-your-own-service"></a>

## 将 Libravatar 服务更改为你自己的服务

在 [`gitlab.yml` gravatar 部分](https://jihulab.com/gitlab-cn/gitlab/-/blob/68dac188ec6b1b03d53365e7579422f44cbe7a1c/config/gitlab.yml.example#L469-476) 中，按照如下方式设置配置选项：

对于 Linux 软件包安装：

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['gravatar_enabled'] = true
   #### 若使用 HTTPS
   gitlab_rails['gravatar_ssl_url'] = "https://seccdn.libravatar.org/avatar/%{hash}?s=%{size}&d=identicon"
   #### 若使用 HTTP，则使用此行
   # gitlab_rails['gravatar_plain_url'] = "http://cdn.libravatar.org/avatar/%{hash}?s=%{size}&d=identicon"
   ```

1. 要使变更生效，请运行 `sudo gitlab-ctl reconfigure`。

对于自行编译的安装：

1. 编辑 `config/gitlab.yml`：

   ```yaml
     gravatar:
       enabled: true
       # 默认值：https://www.gravatar.com/avatar/%{hash}?s=%{size}&d=identicon
       plain_url: "http://cdn.libravatar.org/avatar/%{hash}?s=%{size}&d=identicon"
       # 默认值：https://secure.gravatar.com/avatar/%{hash}?s=%{size}&d=identicon
       ssl_url: "https://seccdn.libravatar.org/avatar/%{hash}?s=%{size}&d=identicon"
   ```

1. 保存文件，然后 [重启](restart_gitlab.md#self-compiled-installations)
   极狐GitLab 以使变更生效。

<a id="set-the-libravatar-service-to-default-gravatar"></a>

## 将 Libravatar 服务设为默认（Gravatar）

对于 Linux 软件包安装：

1. 从 `/etc/gitlab/gitlab.rb` 中删除 `gitlab_rails['gravatar_ssl_url']` 或 `gitlab_rails['gravatar_plain_url']`。
1. 要使变更生效，请运行 `sudo gitlab-ctl reconfigure`。

对于自行编译的安装：

1. 从 `config/gitlab.yml` 中删除 `gravatar:` 部分。
1. 保存文件，然后 [重启](restart_gitlab.md#self-compiled-installations)
   极狐GitLab 以应用变更。

<a id="disable-gravatar-service"></a>

## 禁用 Gravatar 服务

例如，要禁止第三方服务，请完成以下步骤来禁用 Gravatar：

对于 Linux 软件包安装：

1. 编辑 `/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_rails['gravatar_enabled'] = false
   ```

1. 要使变更生效，请运行 `sudo gitlab-ctl reconfigure`。

对于自行编译的安装：

1. 编辑 `config/gitlab.yml`：

   ```yaml
     gravatar:
       enabled: false
   ```

1. 保存文件，然后 [重启](restart_gitlab.md#self-compiled-installations)
   极狐GitLab 以应用变更。

<a id="your-own-libravatar-server"></a>

### 你自己的 Libravatar 服务器

如果你正在 [运行自己的 Libravatar 服务](https://wiki.libravatar.org/running_your_own/)，配置中的 URL 会有所不同，但你必须提供相同的占位符，以便极狐GitLab 能够正确解析 URL。

例如，你在 `https://libravatar.example.com` 上托管了一个服务，那么在 `gitlab.yml` 中需要提供的 `ssl_url` 为：

`https://libravatar.example.com/avatar/%{hash}?s=%{size}&d=identicon`

<a id="default-url-for-missing-images"></a>

## 缺失图片的默认 URL

对于在 Libravatar 服务上未找到的用户电子邮件地址，[Libravatar 支持多种不同的](https://wiki.libravatar.org/api/) 缺失图片集合。

要使用 `identicon` 以外的集合，请将 URL 中的 `&d=identicon` 部分替换为其他支持的集合。例如，你可以使用 `retro` 集合，此情况下 URL 将类似于：`ssl_url: "https://seccdn.libravatar.org/avatar/%{hash}?s=%{size}&d=retro"`

<a id="usage-examples-for-microsoft-office-365"></a>

## Microsoft Office 365 的使用示例

如果你的用户是 Office 365 用户，则可以使用 `GetPersonaPhoto` 服务。
该服务需要登录，因此此用例在公司内部安装中最为有用，因为所有用户都可以访问 Office 365。

```ruby
gitlab_rails['gravatar_plain_url'] = 'http://outlook.office.com/owa/service.svc/s/GetPersonaPhoto?email=%{email}&size=HR120x120'
gitlab_rails['gravatar_ssl_url'] = 'https://outlook.office.com/owa/service.svc/s/GetPersonaPhoto?email=%{email}&size=HR120x120'
```