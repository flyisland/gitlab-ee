---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 'GitLab administrator: enable and disable GitLab features deployed behind feature flags'
title: 启用和禁用受功能标志控制的极狐GitLab 功能
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 采用了功能标志策略，以便在功能开发的早期阶段进行部署，从而逐步推出这些功能。

在功能正式永久可用之前，它们可能会在功能标志的背后进行部署，原因有很多，例如：

- 为了测试该功能。
- 为了在功能开发的早期阶段从用户和客户那里收集反馈。
- 为了评估用户的采用情况。
- 为了评估它对极狐GitLab 性能的影响。
- 为了在多个版本中逐步构建功能。

功能标志背后的功能可以逐步推出，通常的流程是：

1. 功能默认以禁用状态开始。
1. 该功能变为默认启用。
1. 功能标志被移除。

这些功能可以被启用和禁用，以允许或阻止用户使用它们。拥有 [Rails 控制台](#how-to-enable-and-disable-features-behind-flags) 或 [功能标志 API](../../api/features.md) 访问权限的极狐GitLab 管理员可以执行此操作。

当你禁用一个功能标志时，该功能会从用户界面中隐藏，并且所有相关功能都会被关闭。例如，不会记录数据，服务也不会运行。

如果你使用了某个功能并发现了缺陷、异常行为或错误，请务必尽快向极狐GitLab [**提供反馈**](https://jihulab.com/gitlab-cn/-/issues/new?issue[title]=Docs%20-%20feature%20flag%20feedback%3A%20Feature%20Name&issue[description]=Describe%20the%20problem%20you%27ve%20encountered.%0A%0A%3C!--%20Don%27t%20edit%20below%20this%20line%20--%3E%0A%0A%2Flabel%20~%22docs%5C-comments%22%20)，以便我们能够在功能标志的保护下改进或修复它。当你升级极狐GitLab 时，功能标志的状态可能会发生变化。

## 启用仍处于开发阶段的功能时的风险

在极狐GitLab 生产环境中启用默认禁用的功能标志之前，了解所涉及的潜在风险至关重要。

> [!warning]
> 如果你启用了默认禁用的功能，可能会发生数据损坏、稳定性下降、性能下降以及安全问题。

默认禁用的功能可能会在未来版本的极狐GitLab 中发生变更或被移除，且不另行通知。

不建议在生产环境中使用受默认禁用功能标志控制的功能，由使用默认禁用功能引起的问题不在极狐GitLab 支持的覆盖范围内。

在默认禁用功能中发现的安全问题会在常规版本中进行修补，并且不会遵循我们关于向后移植修复的常规[维护策略](../../policy/maintenance.md#patch-releases)。

## 禁用已发布功能时的风险

在大多数情况下，功能标志代码会在未来版本的极狐GitLab 中被移除。如果发生这种情况，从那时起，你将无法再将该功能保持在禁用状态。

<a id="how-to-enable-and-disable-features-behind-flags"></a>

## 如何启用和禁用功能标志背后的功能

每个功能都有其自己的标志，用于启用和禁用该功能。每个受功能标志控制的功能的文档中都包含一个部分，说明该标志的状态以及用于启用或禁用的命令。

### 启动极狐GitLab Rails 控制台

要启用或禁用受功能标志控制的功能，你需要做的第一件事是在极狐GitLab Rails 控制台上启动一个会话。

对于 Linux 软件包安装：

```shell
sudo gitlab-rails console
```

对于从源代码安装：

```shell
sudo -u git -H bundle exec rails console -e production
```

有关详细信息，请参阅[启动 Rails 控制台会话](../operations/rails_console.md#starting-a-rails-console-session)。

### 启用或禁用功能

在 Rails 控制台会话启动后，根据情况运行 `Feature.enable` 或 `Feature.disable` 命令。具体的标志可以在该功能的文档中找到。

要启用某个功能，请运行：

```ruby
Feature.enable(:<feature flag>)
```

例如，启用一个名为 `example_feature` 的虚构功能标志：

```ruby
Feature.enable(:example_feature)
```

要禁用某个功能，请运行：

```ruby
Feature.disable(:<feature flag>)
```

例如，禁用一个名为 `example_feature` 的虚构功能标志：

```ruby
Feature.disable(:example_feature)
```

某些功能标志可以按项目进行启用或禁用：

```ruby
Feature.enable(:<feature flag>, Project.find(<project id>))
```

例如，为项目 `1234` 启用 `:example_feature` 功能标志：

```ruby
Feature.enable(:example_feature, Project.find(1234))
```

某些功能标志可以按用户进行启用或禁用。例如，为用户 `sidney_jones` 启用 `:example_feature` 标志：

```ruby
Feature.enable(:example_feature, User.find_by_username("sidney_jones"))
```

即使应用程序未使用该标志，`Feature.enable` 和 `Feature.disable` 也始终返回 `true`：

```ruby
irb(main):001:0> Feature.enable(:example_feature)
=> true
```

当功能就绪后，极狐GitLab 会移除该功能标志，启用和禁用它的选项将不复存在。该功能将适用于所有实例。

### 检查功能标志是否已启用

要检查某个标志是启用还是禁用，请使用 `Feature.enabled?` 或 `Feature.disabled?`。例如，对于一个名为 `example_feature` 且已经启用的功能标志：

```ruby
Feature.enabled?(:example_feature)
=> true
Feature.disabled?(:example_feature)
=> false
```

当功能就绪后，极狐GitLab 会移除该功能标志，启用和禁用它的选项将不复存在。该功能将适用于所有实例。

### 查看已设置的功能标志

你可以查看所有由极狐GitLab 管理员设置的功能标志：

```ruby
Feature.all
=> [#<Flipper::Feature:198220 name="example_feature", state=:on, enabled_gate_names=[:boolean], adapter=:memoizable>]

# 易于阅读的输出
Feature.all.map {|f| [f.name, f.state]}
```

### 取消设置功能标志

你可以取消设置功能标志，使极狐GitLab 回退到该标志的当前默认值：

```ruby
Feature.remove(:example_feature)
=> true
```