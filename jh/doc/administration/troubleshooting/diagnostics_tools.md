---
stage: 极狐GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 诊断工具
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 支持团队在故障排除过程中会使用这些诊断工具。这里列出这些工具是为了保持透明度，也方便有 极狐GitLab 故障排除经验的用户参考。

如果你在使用 极狐GitLab 时遇到问题，在使用这些工具之前，你可能需要查看你的[支持选项](https://gitlab.cn/support/)。

<a id="sos-scripts"></a>

## SOS 脚本

{{< history >}}

- 在 极狐GitLab 18.3 中，`gitlabsos` 与 Linux 软件包和 Docker 镜像的捆绑引入。

{{< /history >}}

- [`gitlabsos`](https://gitlab.com/gitlab-com/support/toolbox/gitlabsos/) 会从基于 Linux 软件包或 Docker 的 极狐GitLab 实例及其操作系统中收集信息和近期日志。

  ```shell
  sudo gitlabsos
  ```

- [`kubesos`](https://gitlab.com/gitlab-com/support/toolbox/kubesos/) 会从 极狐GitLab Helm chart 部署中收集 Kubernetes 集群配置和近期日志。
- [`gitlab:db:sos`](../raketasks/maintenance.md#collect-information-and-statistics-about-the-database) 会收集有关数据库的详细诊断数据。

<a id="strace-parser"></a>

## `strace-parser` 工具

[`strace-parser`](https://gitlab.com/gitlab-com/support/toolbox/strace-parser) 分析和总结原始的 `strace` 数据。建议阅读 [`strace` zine](https://wizardzines.com/zines/strace/) 以了解上下文。

<a id="gitlabrb_sanitizer"></a>

## `gitlabrb_sanitizer` 工具

[`gitlabrb_sanitizer`](https://gitlab.com/gitlab-com/support/toolbox/gitlabrb_sanitizer/) 会输出一份 `/etc/gitlab/gitlab.rb` 内容的副本，其中敏感值已被遮盖处理。

`gitlabsos` 会自动使用 `gitlabrb_sanitizer` 来对配置进行脱敏。

<a id="fast-stats"></a>

## `fast-stats` 工具

{{< history >}}

- 在 极狐GitLab 18.3 中，`fast-stats` 与 Linux 软件包和 Docker 镜像的捆绑引入。

{{< /history >}}

为帮助调试性能和配置问题，
[`fast-stats`](https://gitlab.com/gitlab-com/support/toolbox/fast-stats#fast-stats) 可以快速总结错误信息和资源密集型使用统计。

使用 `fast-stats` 来解析和比较大量日志，或者开始排查未知问题。

```shell
/opt/gitlab/embedded/bin/fast-stats
```

<a id="greenhat"></a>

## `greenhat` 工具

[`greenhat`](https://gitlab.com/gitlab-com/support/toolbox/greenhat/) 提供了一个交互式 shell，用于分析、过滤和汇总 [SOS 日志](#sos-scripts)。

<a id="gitlab-detective"></a>

## 极狐GitLab Detective 诊断工具

[极狐GitLab Detective](https://gitlab.com/gitlab-com/support/toolbox/gitlab-detective) 会在 极狐GitLab 实例上运行自动化检查，以识别和解决常见问题。

<a id="soslab"></a>

## `soslab` 工具

[soslab](https://gitlab.com/gitlab-com/support/toolbox/soslab) 是一款日志分析器，用于在多节点部署中对 极狐GitLab SOS 捆绑包进行故障排除。
它提供了模式聚类、关联追踪、系统指标仪表盘、PowerSearch、自动分析以及内置终端访问功能。
使用 soslab 可以在大型 极狐GitLab 基础设施中识别问题。