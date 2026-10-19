---
stage: Systems
group: Gitaly
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: 示例配置文件
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

<a id="gitaly-and-gitaly-cluster-are-configured-by-using-configuration-files"></a>

极狐GitLab Gitaly 和 Gitaly Cluster 通过使用配置文件进行配置。配置文件的默认位置取决于您安装的类型：

1. 对于 Linux 软件包安装，Gitaly 和 Gitaly Cluster 配置的默认位置在 `/etc/gitlab/gitlab.rb` Ruby 文件中。
1. 对于自编译，Gitaly 和 Gitaly Cluster 配置的默认位置在 `/home/git/gitaly/config.toml` 和 `/home/git/gitaly/config.prafect.toml` TOML 文件中。

您可以在 `gitaly` 项目中找到 TOML 配置文件示例：

1. Gitaly: <https://jihulab.com/gitlab-cn/gitaly/-/blob/master/config.toml.example>
1. Gitaly Cluster: <https://jihulab.com/gitlab-cn/gitaly/-/blob/master/config.praefect.toml.example>

如果您正在配置 Linux 软件包安装，您必须将示例转换为 Ruby 才能使用它们。

有关更多信息，请参阅：

1. 配置 Gitaly，请参阅 [配置 Gitaly](configure_gitaly.md)。
1. 配置 Gitaly Cluster，请参阅 [配置 Gitaly Cluster](praefect.md)。
