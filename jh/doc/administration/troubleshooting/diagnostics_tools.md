---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 诊断工具
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 支持团队在故障排除期间会使用这些诊断工具。此处列出这些工具是为了保持透明，也方便具备极狐GitLab 故障排除经验的用户使用。

如果您在使用极狐GitLab 时遇到问题，在尝试使用这些工具之前，您可能需要先查看[支持选项](https://gitlab.cn/support)。

<a id="sos-scripts"></a>

## SOS 脚本

- [`gitlabsos`](https://gitlab.com/gitlab-com/support/toolbox/gitlabsos/) 从基于 Linux 软件包或 Docker 的极狐GitLab 实例及其操作系统中收集信息和最近的日志。

  ```shell
  sudo gitlabsos
  ```

- [`kubesos`](https://gitlab.com/gitlab-com/support/toolbox/kubesos/) 从 GitLab Helm chart 部署中收集 Kubernetes 集群配置和最近的日志。
- [`gitlab:db:sos`](../raketasks/maintenance.md#collect-information-and-statistics-about-the-database) 收集有关数据库的详细诊断数据。

<a id="strace-parser"></a>

## `strace-parser`

[`strace-parser`](https://gitlab.com/gitlab-com/support/toolbox/strace-parser) 分析并汇总原始 `strace` 数据。建议阅读 [`strace` zine](https://wizardzines.com/zines/strace/) 以了解背景信息。

<a id="gitlabrb_sanitizer"></a>

## `gitlabrb_sanitizer`

[`gitlabrb_sanitizer`](https://gitlab.com/gitlab-com/support/toolbox/gitlabrb_sanitizer/) 输出一份 `/etc/gitlab/gitlab.rb` 内容的副本，其中敏感值已被隐去。

`gitlabsos` 会自动使用 `gitlabrb_sanitizer` 来清理配置。

<a id="fast-stats"></a>

## `fast-stats`

为了帮助调试性能和配置问题，[`fast-stats`](https://gitlab.com/gitlab-com/support/toolbox/fast-stats#fast-stats) 可快速汇总错误和资源密集型使用统计数据。

使用 `fast-stats` 解析并比较大量日志，或开始排查未知问题。

```shell
/opt/gitlab/embedded/bin/fast-stats
```

<a id="greenhat"></a>

## `greenhat`

[`greenhat`](https://gitlab.com/gitlab-com/support/toolbox/greenhat/) 提供一个交互式 shell，用于分析、筛选和汇总 [SOS 日志](#sos-scripts)。

<a id="gitlab-detective"></a>

## GitLab Detective

[GitLab Detective](https://gitlab.com/gitlab-com/support/toolbox/gitlab-detective) 在极狐GitLab 实例上运行自动检查，以识别并解决常见问题。

<a id="soslab"></a>

## `soslab`

[soslab](https://gitlab.com/gitlab-com/support/toolbox/soslab) 是一款日志分析器，用于跨多节点部署排查极狐GitLab SOS 诊断归档的问题。它提供模式聚类、关联追踪、系统指标仪表板、PowerSearch、自动分析和内置终端访问。使用 soslab 可识别大型极狐GitLab 基础设施中的问题。
