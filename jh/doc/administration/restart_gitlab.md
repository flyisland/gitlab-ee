---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 如何重启极狐GitLab
description: 如何重启极狐GitLab。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

根据您安装极狐GitLab 的方式，重启其服务的方法也有所不同。

> [!note]
> 所有方法都会造成短暂的服务中断。

<a id="linux-package-installations"></a>

## Linux 软件包安装

如果您使用 [Linux 软件包](https://gitlab.cn/install)安装极狐GitLab，您的 `PATH`中应该已经有 `gitlab-ctl`。

`gitlab-ctl` 与 Linux 软件包安装交互，可用于重启
GitLab Rails 应用（Puma）以及其他组件，例如：

- GitLab Workhorse
- Sidekiq
- PostgreSQL（如果您使用的是内置的 PostgreSQL）
- NGINX（如果您使用的是内置的 NGINX）
- Redis（如果您使用的是内置的 Redis）
- [Mailroom](reply_by_email.md)
- Logrotate

<a id="restart-a-linux-package-installation"></a>

### 重启 Linux 软件包安装

文档中有时会要求您*重启*极狐GitLab。要重启 Linux 软件包安装，请运行：

```shell
sudo gitlab-ctl restart
```

输出应类似如下：

```plaintext
ok: run: gitlab-workhorse: (pid 11291) 1s
ok: run: logrotate: (pid 11299) 0s
ok: run: mailroom: (pid 11306) 0s
ok: run: nginx: (pid 11309) 0s
ok: run: postgresql: (pid 11316) 1s
ok: run: redis: (pid 11325) 0s
ok: run: sidekiq: (pid 11331) 1s
ok: run: puma: (pid 11338) 0s
```

要单独重启某个组件，您可以在 `restart` 命令后附加其服务名称。例如，要仅重启 NGINX，请运行：

```shell
sudo gitlab-ctl restart nginx
```

要检查极狐GitLab 服务的状态，请运行：

```shell
sudo gitlab-ctl status
```

请注意，所有服务都显示 `ok: run`。

有时，组件会在重启期间超时（请在日志中查找 `timeout`），有时它们会卡住。在这种情况下，您可以使用 `gitlab-ctl kill <service>` 向该服务发送 `SIGKILL` 信号，例如 `sidekiq`。之后，重启应该可以正常执行。

作为最后的手段，您可以尝试改为重新配置极狐GitLab。

<a id="reconfigure-a-linux-package-installation"></a>

### 重新配置 Linux 软件包安装

文档中有时会要求您*重新配置*极狐GitLab。请记住，此方法仅适用于 Linux 软件包安装。

要重新配置 Linux 软件包安装，请运行：

```shell
sudo gitlab-ctl reconfigure
```

当极狐GitLab 的配置（`/etc/gitlab/gitlab.rb`）发生变化时，应重新配置极狐GitLab。

当您运行 `gitlab-ctl reconfigure` 时，[Chef](https://www.chef.io/products/chef-infra)——驱动 Linux 软件包安装的底层配置管理应用——会运行一些检查。Chef 会确保目录、权限和服务均已就位并正常工作。

如果任何组件的配置文件发生了更改，Chef 还会重启极狐GitLab 组件。

如果您手动编辑了 `/var/opt/gitlab`中由 Chef 管理的任何文件，运行 `reconfigure` 会还原这些更改，并重启依赖这些文件的服务。

<a id="self-compiled-installations"></a>

## 自行编译安装

如果您已按照官方安装指南[自行编译安装](../install/self_compiled/_index.md)，请运行以下命令来重启极狐GitLab：

```shell
# For systems running systemd
sudo systemctl restart gitlab.target

# For systems running SysV init
sudo service gitlab restart
```

这应该会重启 Puma、Sidekiq、GitLab Workhorse 和 [Mailroom](reply_by_email.md)
（如果已启用）。

<a id="helm-chart-installations"></a>

## Helm chart 安装

没有单一命令可以重启通过
[云原生 Helm chart](https://gitlab.cn/docs/charts/) 安装的整个极狐GitLab 应用。通常，
单独重启某个特定组件就足够了（例如 `gitaly`、`puma`、`workhorse` 或 `gitlab-shell`），方法是删除与其相关的所有 pod：

```shell
kubectl delete pods -l release=<helm release name>,app=<component name>
```

发布名称可以从 `helm list` 命令的输出中获取。

<a id="docker-installation"></a>

## Docker 安装

如果您更改了 [Docker 安装](../install/docker/_index.md)的配置，要使更改生效，您必须重启：

- 主 `gitlab` 容器。
- 任何独立的组件容器。

例如，如果您在单独的容器上部署了 Sidekiq，要重启这些容器，请运行：

```shell
sudo docker restart gitlab
sudo docker restart sidekiq
```
