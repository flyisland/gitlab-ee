---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 软件包信息
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

Linux 软件包捆绑了极狐GitLab 正常运行所需的全部依赖项。更多详情请参见[捆绑依赖项文档](omnibus_packages.md)。

<a id="package-version"></a>

## 软件包版本

已发布软件包的版本格式为 `MAJOR.MINOR.PATCH-EDITION.OMNIBUS_RELEASE`

| 组件                | 含义                                                                                                                                      | 示例     |
|:--------------------|:------------------------------------------------------------------------------------------------------------------------------------------|:---------|
| `MAJOR.MINOR.PATCH` | 对应的极狐GitLab 版本。                                                                                                                    | `13.3.0` |
| `EDITION`           | 对应的极狐GitLab 版本类型。                                                                                                                | `ee`     |
| `OMNIBUS_RELEASE`   | Linux 软件包的发布版本号。通常为 `0`。如果需要在不变更极狐GitLab 版本的情况下构建新软件包，我们会递增此值。 | `0`      |

<a id="licenses"></a>

## 许可证

请参见[许可](licensing.md)

<a id="defaults"></a>

## 默认值

Linux 软件包需要各种配置才能使各组件正常工作。如果未提供配置，软件包将使用软件包中假定的默认值。

这些默认值记录在软件包的[默认值文档](defaults.md)中。

<a id="checking-the-versions-of-bundled-software"></a>

## 检查捆绑软件的版本

安装 Linux 软件包后，您可以在 `/opt/gitlab/version-manifest.txt`中找到极狐GitLab 及所有捆绑库的版本。

如果您尚未安装该软件包，可以随时查看 Linux 软件包的[源代码仓库](https://jihulab.com/gitlab-cn/omnibus-gitlab/-/tree/master)，特别是[配置目录](https://jihulab.com/gitlab-cn/omnibus-gitlab/-/tree/master/config)。

例如，如果您查看 `8-6-stable` 分支，可以推断出 8.6 软件包运行的是 [Ruby 2.1.8](https://jihulab.com/gitlab-cn/omnibus-gitlab/-/blob/8-6-stable/config/projects/gitlab.rb#L48)。或者，8.5 软件包捆绑的是 [NGINX 1.9.0](https://jihulab.com/gitlab-cn/omnibus-gitlab/-/blob/8-5-stable/config/software/nginx.rb#L20)。

<a id="signatures-of-gitlab-inc-provided-packages"></a>

## GitLab, Inc. 提供的软件包签名

有关软件包签名的文档，请参见[已签名软件包](signed_packages.md)

<a id="checking-for-newer-configuration-options-on-upgrade"></a>

## 升级时检查更新的配置选项

`/etc/gitlab/gitlab.rb` 配置文件在首次安装 Linux 软件包时创建。为避免意外覆盖用户配置，升级 Linux 软件包安装时，不会使用新配置更新 `/etc/gitlab/gitlab.rb` 配置文件。

新配置选项记录在 [`gitlab.rb.template` 文件](https://gitlab.com/gitlab-org/omnibus-gitlab/raw/master/files/gitlab-config-template/gitlab.rb.template)中。

Linux 软件包还提供了一个便捷命令，用于将现有用户配置与软件包中包含的最新版模板进行比较。

要查看您的配置文件与最新版本之间的差异，请运行：

```shell
sudo gitlab-ctl diff-config
```

> [!warning]
> 如果要将此命令的输出粘贴到
> `/etc/gitlab/gitlab.rb` 配置文件中，请省略每行开头的 `+` 和 `-`
> 字符。

<a id="init-system-detection"></a>

## Init 系统检测

Linux 软件包会尝试查询底层系统，以检查其使用的 init 系统。这会在运行 `sudo gitlab-ctl reconfigure` 时显示为一条 `WARNING`。

根据 init 系统的不同，此 `WARNING` 可能是以下之一：

```plaintext
/sbin/init: unrecognized option '--version'
```

当底层 init 系统不是 upstart 时。

```plaintext
  -.mount loaded active mounted   /
```

当底层 init 系统是 systemd 时。

这些警告可以安全地忽略。之所以不抑制这些警告，是因为这样可以让大家更快地调试可能的检测问题。
