---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.jihulab.com/handbook/product/ux/technical-writing/#assignments>
title: 软件包信息
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

Linux 软件包包含了极狐GitLab 正常运行所需的所有依赖项。更多详细信息请参阅[捆绑依赖文档](omnibus_packages.md)。

<a id="package-version"></a>

## 软件包版本

已发布软件包的版本格式为 `MAJOR.MINOR.PATCH-EDITION.OMNIBUS_RELEASE`

| 组件 | 含义 | 示例 |
|:--------------------|:------------------------------------------------------------------------------------------------------------------------------------------|:---------|
| `MAJOR.MINOR.PATCH` | 对应的极狐GitLab 版本。 | `13.3.0` |
| `EDITION` | 对应的极狐GitLab 版本类型。 | `ee` |
| `OMNIBUS_RELEASE` | Linux 软件包发行号。通常是 `0`。当需要在不更改极狐GitLab 版本的情况下构建新软件包时，我们会递增此值。 | `0` |

<a id="licenses"></a>

## 许可证

请参阅[许可证](licensing.md)

<a id="defaults"></a>

## 默认值

Linux 软件包需要各种配置才能使各组件正常工作。如果未提供配置，软件包将使用其预设的默认值。这些默认值记录在软件包[默认设定文档](defaults.md)中。

<a id="checking-the-versions-of-bundled-software"></a>

## 检查捆绑软件的版本

安装 Linux 软件包后，你可以在 `/opt/gitlab/version-manifest.txt` 中找到极狐GitLab 及所有捆绑库的版本。

如果你尚未安装该软件包，可以随时查看 Linux 软件包的[源代码仓库](https://jihulab.com/gitlab-cn/omnibus-gitlab/tree/master)，特别是[配置目录](https://jihulab.com/gitlab-cn/omnibus-gitlab/tree/master/config)。

例如，如果你查看 `8-6-stable` 分支，你可以得知 8.6 软件包运行的是 [Ruby 2.1.8](https://jihulab.com/gitlab-cn/omnibus-gitlab/blob/8-6-stable/config/projects/gitlab.rb#L48)。或者，8.5 软件包捆绑了 [NGINX 1.9.0](https://jihulab.com/gitlab-cn/omnibus-gitlab/blob/8-5-stable/config/software/nginx.rb#L20)。

<a id="signatures-of-gitlab-inc-provided-packages"></a>

## 极狐GitLab, Inc. 提供的软件包签名

关于软件包签名的文档可参阅[已签名软件包](signed_packages.md)

<a id="checking-for-newer-configuration-options-on-upgrade"></a>

## 升级时检查更新的配置选项

`/etc/gitlab/gitlab.rb` 配置文件是在初始安装 Linux 软件包时创建的。为避免意外覆盖用户配置，升级 Linux 软件包安装时不会用新配置更新 `/etc/gitlab/gitlab.rb` 配置文件。

新配置选项记录在 [`gitlab.rb.template` 文件](https://jihulab.com/gitlab-cn/omnibus-gitlab/raw/master/files/gitlab-config-template/gitlab.rb.template)中。

Linux 软件包还提供了一个便捷命令，用于比较现有用户配置与软件包中包含的最新模板版本。

要查看你的配置文件与最新版本之间的差异，请运行：

```shell
sudo gitlab-ctl diff-config
```

> [!warning]
> 如果将此命令的输出粘贴到你的 `/etc/gitlab/gitlab.rb` 配置文件中，请省略每行开头的 `+` 和 `-` 字符。

<a id="init-system-detection"></a>

## 初始化系统检测

Linux 软件包尝试查询底层系统，以检查其使用的是哪种初始化系统。这会在运行 `sudo gitlab-ctl reconfigure` 时表现为一个 `警告`。

根据初始化系统的不同，该 `警告` 可能为以下之一：

```plaintext
/sbin/init: 未识别的选项 '--version'
```

当底层初始化系统不是 upstart 时。

```plaintext
  -.mount 已加载 活跃 已挂载 /
```

当底层初始化系统是 systemd 时。

这些警告可以安全地忽略。它们未被抑制，因为这样可以让所有人更快地调试潜在的检测问题。