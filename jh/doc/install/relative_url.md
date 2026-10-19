---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 在相对 URL 下安装极狐GitLab
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署
- Status: 测试版

{{< /details >}}

> [!warning]
> 为极狐GitLab 配置相对 URL 存在[与 Geo 相关的已知问题](https://gitlab.com/gitlab-org/gitlab/-/issues/456427)和
> [测试限制](https://gitlab.com/gitlab-org/gitlab/-/issues/439943)。
> 如果您已在使用相对 URL 并希望迁移到子域名，请参阅
> [迁移指南](../administration/operations/migrate_to_subdomain.md)。

虽然您应将极狐GitLab 安装在其自己的（子）域名下，但有时由于各种原因无法做到这一点。在这种情况下，极狐GitLab 也可以安装在相对 URL 下，例如 `https://example.com/gitlab`。

本文档介绍如何为从源代码进行的安装在相对 URL 下运行极狐GitLab。如果您不是从源代码安装，请查看
[Linux 软件包](https://gitlab.cn/docs/omnibus/settings/configuration/#configure-a-relative-url-for-gitlab)
或 [GitLab chart](https://gitlab.cn/docs/charts/charts/globals/#configure-a-relative-url-root)
的相对 URL 文档，以启用相对 URL。

如果您是首次安装极狐GitLab，请将本指南与[安装指南](self_compiled/_index.md)配合使用。

相对 URL 的嵌套深度没有限制。例如，您可以在 `/foo/bar/gitlab/git` 下提供极狐GitLab 服务，而不会有任何问题。

在现有极狐GitLab 安装上更改 URL 会更改所有远程 URL，因此您必须在任何指向您的极狐GitLab 实例的本地代码仓库中手动编辑它们。

要从相对 URL 提供极狐GitLab 服务，必须更改的配置文件列表如下：

- `/home/git/gitlab/config/initializers/relative_url.rb`
- `/home/git/gitlab/config/gitlab.yml`
- `/home/git/gitlab/config/puma.rb`
- `/home/git/gitlab-shell/config.yml`
- `/etc/default/gitlab`

完成所有更改后，您必须重新编译资产并[重启极狐GitLab](../administration/restart_gitlab.md#self-compiled-installations)。

<a id="relative-url-requirements"></a>

## 相对 URL 要求

如果您为极狐GitLab 配置相对 URL，则必须重新编译资产（包括 JavaScript、CSS、字体和图像），这可能会消耗大量 CPU 和内存资源。为避免内存不足错误，您的计算机上应至少有 2 GB 可用内存。理想情况下，您应拥有 4 GB 内存，以及四个或八个 CPU 核心。

有关更多信息，请参阅[要求](requirements.md)文档。

<a id="enable-relative-url-in-gitlab"></a>

## 在极狐GitLab 中启用相对 URL

> [!note]
> 请勿对 Web 服务器配置文件中与
> 相对 URL 相关的部分做任何更改。相对 URL 支持由 GitLab Workhorse 实现。

---

此过程假设：

- 极狐GitLab 在 `/gitlab` 下提供服务
- 极狐GitLab 的安装目录为 `/home/git/`

要在极狐GitLab 中启用相对 URL：

1. 可选。如果资源不足，您可以通过以下命令关闭极狐GitLab 服务，
   临时释放一些内存：

   ```shell
   sudo service gitlab stop
   ```

1. 创建 `/home/git/gitlab/config/initializers/relative_url.rb`

   ```shell
   cp /home/git/gitlab/config/initializers/relative_url.rb.sample \
      /home/git/gitlab/config/initializers/relative_url.rb
   ```

   并更改以下行：

   ```ruby
   config.relative_url_root = "/gitlab"
   ```

1. 编辑 `/home/git/gitlab/config/gitlab.yml`，取消注释/更改
   以下行：

   ```yaml
   relative_url_root: /gitlab
   ```

1. 编辑 `/home/git/gitlab/config/puma.rb`，取消注释/更改
   以下行：

   ```ruby
   ENV['RAILS_RELATIVE_URL_ROOT'] = "/gitlab"
   ```

1. 编辑 `/home/git/gitlab-shell/config.yml`，并将相对路径追加到
   以下行：

   ```yaml
   gitlab_url: http://127.0.0.1/gitlab
   ```

1. 确保您已按照[安装指南](self_compiled/_index.md#install-the-service)中所述，
   复制了提供的 systemd 服务，或 init
   脚本和默认文件。
   然后，编辑 `/etc/default/gitlab`，并在 `gitlab_workhorse_options`中将
   `-authBackend` 设置改为如下内容：

   ```shell
   -authBackend http://127.0.0.1:8080/gitlab
   ```

   > [!note]
   > 如果您使用自定义 init 脚本，请确保根据需要编辑前面的
   > GitLab Workhorse 设置。

1. [重启极狐GitLab](../administration/restart_gitlab.md#self-compiled-installations) 以使更改生效。

<a id="disable-relative-url-in-gitlab"></a>

## 在极狐GitLab 中禁用相对 URL

要禁用相对 URL：

1. 删除 `/home/git/gitlab/config/initializers/relative_url.rb`
1. 按照前面的步骤从第 2 步开始操作，并将
   极狐GitLab URL 设置为不包含相对路径的 URL。
