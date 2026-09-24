---
stage: GitLab Delivery
group: Build
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Linux 软件包弃用政策
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

Linux 软件包附带了多个不同的库和服务，为用户提供了丰富的配置选项。

随着库和服务的更新，它们的配置选项会发生变化甚至过时。为了提升可维护性并确保系统稳定运行，有些配置项需要移除。

<a id="configuration-deprecation"></a>

## 配置弃用

<a id="policy"></a>

### 政策

Linux 软件包会保留配置至少 **一个大版本**。我们无法保证弃用的配置在下一个主要版本中仍然可用。详情请参见[示例](#example)。

<a id="notice"></a>

### 通知

一旦配置项过时，我们将通过以下方式发布弃用通知：

- 在 `https://gitlab.cn/blog/` 发布博客文章。文章条目会包含弃用通知及目标移除日期。
- 在安装/重新配置过程的输出中显示（如果适用）。
- 在 `https://gitlab.cn/docs` 的官方文档中说明。文档更新会包含修正后的语法（如果适用）或配置移除的日期。

<a id="procedure"></a>

### 流程

本节列出了弃用和移除配置所需的步骤。

我们将配置项分为两种不同类型：

- 敏感配置：可能导致重大服务中断的配置（如影响数据完整性、安装完整性，或阻止用户正常访问系统）。
- 常规配置：可能使某个功能不可用，但整体系统仍然可用的配置（如默认项目/群组设置变更，或与其他组件的通信问题）。

此外，需区分弃用流程和移除流程。

<a id="deprecating-configuration"></a>

#### 弃用配置

对于 `敏感` 和 `常规` 配置，弃用流程类似，唯一的区别在于移除目标日期。

通用步骤：

1. 在 [`omnibus-极狐GitLab` 议题追踪器](https://jihulab.com/gitlab-cn/omnibus-gitlab/-/issues)中创建一个议题，详细说明弃用类型及其他必要信息，并添加标签 `deprecation`。
1. 确定弃用配置的移除目标日期。
1. 按照[通知部分](#notice)的要求，为每项变更编写弃用通知。

移除目标：

对于常规配置，移除目标应始终是**下一个主要版本**的发布日期。若发布日期未知，可引用下一个主要版本的版本号。

对于敏感配置，情况稍复杂一些。
如果下一个主要版本距离当前只有 2 个次要版本，则应避免在下一个主要版本中移除敏感配置（此数字与我们的安全补丁回溯发布策略相匹配）。

请参考下表示例：

| 配置类型 | 弃用公告发布 | 最后一个次要版本 | 移除目标版本 |
| -------- | -------- | -------- | -------- |
| 敏感 | 10.1.0   | 10.9.0   | 11.0.0 |
| 敏感 | 10.7.0   | 10.9.0   | 12.0.0 |
| 常规 | 10.1.0 | 10.9.0 | 11.0.0 |
| 常规 | 10.8.0 | 10.9.0 | 11.0.0 |

<a id="removing-configuration"></a>

#### 移除配置

弃用公告发布且移除目标确定后，议题对应的里程碑应更改至移除目标版本。

议题中的最后一条评论必须包含：

- 用于发布博客文章的文本片段。
- 指向引入变更的文档合并请求（或文档片段）的链接。
- 以下之一：
  - 指向移除该配置的草稿合并请求的链接。
  - 需要完成的详细信息。

<a id="example"></a>

## 示例

假设 `/etc/gitlab/gitlab.rb` 中有一个用户配置项在 极狐GitLab 10.0 版本中引入：`gitlab_rails['configuration'] = true`。在 极狐GitLab 10.4.0 版中，引入了新的变更，要求重命名该配置项。新的配置项为 `gitlab_rails['better_configuration'] = true`。开发团队会将旧配置转换为新配置，并启动弃用流程。

这意味着在 极狐GitLab 10 的整个生命周期中，这两个配置项均有效。换言之，即使你在 极狐GitLab 10.8.0 中仍设置了 `gitlab_rails['configuration'] = true`，其功能与设置 `gitlab_rails['better_configuration'] = true` 时相同。不过，使用旧版配置会在安装/升级/重新配置运行结束时输出弃用通知。

在 极狐GitLab 11 中，`gitlab_rails['configuration'] = true` 将不再生效，你必须手动将 `/etc/gitlab/gitlab.rb` 中的配置更改为新的有效配置。**注意：** 如果该配置项属于敏感配置，并可能危及安装环境或数据的完整性，安装或升级过程将被中止。