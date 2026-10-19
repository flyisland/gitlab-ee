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

Linux 软件包附带多种不同的库和服务，为用户提供了大量配置选项。

随着库和服务不断更新，其配置选项也会发生变化并逐渐过时。为了提高可维护性并保持可用的环境，需要移除各种配置。

<a id="configuration-deprecation"></a>

## 配置弃用

<a id="policy"></a>

### 政策

Linux 软件包会至少保留一个大版本内的配置。我们无法保证已弃用的配置在下一个大版本中仍然可用。更多详情请参见[示例](#example)。

<a id="notice"></a>

### 通知

如果配置过时，我们会宣布弃用：

- 通过 `https://about.gitlab.com/blog/` 上的发布博客文章。博客文章条目中包含弃用通知以及目标移除日期。
- 通过安装/重新配置的输出（如适用）。
- 通过 `https://docs.gitlab.com/` 上的官方文档。文档更新中包含更正后的语法（如适用）或配置移除日期。

<a id="procedure"></a>

### 流程

本节列出了弃用和移除配置所需的步骤。

我们可以区分两种不同类型的配置：

- 敏感：可能导致重大服务中断的配置（例如数据完整性、安装完整性，或阻止用户访问安装实例）
- 常规：可能使某项功能不可用，但仍使安装实例可用的配置（例如默认项目/群组设置的变更，或与其他组件通信不畅）

我们还必须区分弃用流程和移除流程。

<a id="deprecating-configuration"></a>

#### 弃用配置

弃用流程对于 `sensitive` 和 `regular` 配置是类似的。唯一的区别在于目标移除日期。

通用步骤：

1. 在 [`omnibus-gitlab` 议题跟踪器](https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues)中创建议题，包含弃用类型详情及其他必要信息。应用标记 `deprecation`。
1. 确定已弃用配置的目标移除时间
1. 按照[通知部分](#notice)所述，为每个条目拟定弃用通知

目标移除时间：

对于常规配置，目标移除时间应始终为下一个大版本的发布日期。如果日期未知，您可以引用下一个大版本号。

对于敏感配置，情况会稍微复杂一些。如果下一个大版本距离当前还有 2 个小版本，我们应尽量不在下一个大版本中移除敏感配置（选择这个数字是为了与我们的安全向后移植发布政策保持一致）。

请参见下表了解一些示例：

| 配置类型 | 宣布弃用 | 最终小版本 | 移除 |
| -------- | -------- | -------- | -------- |
| 敏感 | 10.1.0   | 10.9.0   | 11.0.0 |
| 敏感 | 10.7.0   | 10.9.0   | 12.0.0 |
| 常规 | 10.1.0 | 10.9.0 | 11.0.0 |
| 常规 | 10.8.0 | 10.9.0 | 11.0.0 |

<a id="removing-configuration"></a>

#### 移除配置

当弃用已宣布且目标移除时间已确定后，应将议题的里程碑更改为与目标移除版本一致。

议题中的最终评论必须包含：

- 用于发布博客文章部分的文本片段。
- 指向引入该变更的文档合并请求（或文档片段）的链接。
- 以下任一项：
  - 指向移除该配置的草稿合并请求的链接。
  - 关于必须完成哪些工作的详情。

<a id="example"></a>

## 示例

`/etc/gitlab/gitlab.rb`中可用的用户配置在 GitLab 10.0 版本中引入，即 `gitlab_rails['configuration'] = true`。在 GitLab 10.4.0 版本中，引入了一项新变更，要求重命名此配置选项。新的配置选项为 `gitlab_rails['better_configuration'] = true`。开发团队将旧配置转换为新配置，并触发弃用流程。

这意味着这两个配置选项在 GitLab 10 版本中均有效。换句话说，如果您在 GitLab 10.8.0 中仍然设置了 `gitlab_rails['configuration'] = true`，该功能将继续以与设置 `gitlab_rails['better_configuration'] = true` 时相同的方式工作。但是，设置旧版配置会在安装/升级/重新配置运行结束时打印弃用通知。

在 GitLab 11 中，`gitlab_rails['configuration'] = true` 不再有效，您必须手动将 `/etc/gitlab/gitlab.rb`中的配置更改为新的有效配置。**注意**：如果此配置选项属于敏感配置，可能危及安装实例或数据的完整性，则安装或升级会被中止。
