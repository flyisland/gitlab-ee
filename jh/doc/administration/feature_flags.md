---
stage: Systems
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
description: 'GitLab administrator: enable and disable GitLab features deployed behind feature flags'
title: 启用和禁用部署在功能标志之后的极狐GitLab 功能
---

{{< details >}}

- Tier: 基础版, 专业版, 旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 采用了[功能标志策略](../development/feature_flags/_index.md)来在开发的早期阶段部署功能，以便能够逐步推出。在将其永久可用之前，可以由于多种原因将功能部署在标志后面，例如：

- 测试功能。
- 在功能开发的早期阶段从用户和客户那里获取反馈。
- 评估用户采用情况。
- 评估其对极狐GitLab 性能的影响。
- 在多个版本中逐步构建它。

在标志后面的功能可以逐步推出，通常：

1. 功能默认情况下处于禁用状态。
1. 功能变为默认启用。
1. 功能标志被移除。

这些功能可以启用和禁用，以允许或阻止用户使用它们。极狐GitLab 管理员可以通过访问 [Rails 控制台](#how-to-enable-and-disable-features-behind-flags)或[功能标志 API](../api/features.md)来完成。

当您禁用功能标志时，该功能对用户隐藏，所有功能都被关闭。例如，数据不会被记录，服务也不会运行。

<a id="risks-when-enabling-features-still-in-development"></a>

## 开启仍在开发中的功能的风险

在生产环境中的极狐GitLab 中启用已禁用的功能标志之前，了解潜在风险至关重要。

{{< alert type="warning" >}}

如果您启用了默认情况下禁用的功能，可能会发生数据损坏、稳定性下降、性能下降和安全问题。

{{< /alert >}}

默认情况下禁用的功能可能会在极狐GitLab 的未来版本中更改或被移除而不另行通知。

默认禁用功能标志后面的功能不建议在生产环境中使用，使用默认禁用功能引起的问题不在极狐GitLab 支持范围内。

在默认情况下禁用的功能中发现的安全问题会在常规版本中修补，不会遵循我们的常规[维护政策](../policy/maintenance.md#patch-releases)进行修复的回溯。

<a id="risks-when-disabling-released-features"></a>

## 禁用已发布功能的风险

在大多数情况下，功能标志代码将在极狐GitLab 的未来版本中被移除。如果发生这种情况，从那时起，您无法保持功能处于禁用状态。

<a id="how-to-enable-and-disable-features-behind-flags"></a>

## 如何启用和禁用标志后的功能

每个功能都有其自己的标志，用于启用和禁用它。标志后每个功能的文档中都有一个部分，说明标志的状态以及启用或禁用它的命令。

<a id="start-the-gitlab-rails-console"></a>

### 启动极狐GitLab Rails 控制台

要启用或禁用标志后的功能，首先要在极狐GitLab Rails 控制台上启动会话。

对于 Linux 软件包安装：

```shell
sudo gitlab-rails console
```

对于从源代码安装：

```shell
sudo -u git -H bundle exec rails console -e production
```

有关详细信息，请参阅[启动 Rails 控制台会话](operations/rails_console.md#starting-a-rails-console-session)。

<a id="enable-or-disable-the-feature"></a>

### 启用或禁用功能

Rails 控制台会话启动后，运行 `Feature.enable` 或 `Feature.disable` 命令。具体标志可以在功能的文档中找到。

要启用功能，运行：

```ruby
Feature.enable(:<feature flag>)
```

例如，要启用名为 `example_feature` 的虚构功能标志：

```ruby
Feature.enable(:example_feature)
```

要禁用功能，运行：

```ruby
Feature.disable(:<feature flag>)
```

例如，要禁用名为 `example_feature` 的虚构功能标志：

```ruby
Feature.disable(:example_feature)
```

某些功能标志可以在每个项目的基础上启用或禁用：

```ruby
Feature.enable(:<feature flag>, Project.find(<project id>))
```

例如，要为项目 `1234` 启用 `:example_feature` 功能标志：

```ruby
Feature.enable(:example_feature, Project.find(1234))
```

某些功能标志可以在每个用户的基础上启用或禁用。例如，要为用户 `sidney_jones` 启用 `:example_feature` 标志：

```ruby
Feature.enable(:example_feature, User.find_by_username("sidney_jones"))
```

`Feature.enable` 和 `Feature.disable` 总是返回 `true`，即使应用程序不使用该标志：

```ruby
irb(main):001:0> Feature.enable(:example_feature)
=> true
```

当功能准备好时，极狐GitLab 移除功能标志，启用和禁用它的选项不再存在。该功能在所有实例中都可用。

<a id="check-if-a-feature-flag-is-enabled"></a>

### 检查功能标志是否已启用

要检查标志是否已启用或禁用，使用 `Feature.enabled?` 或 `Feature.disabled?`。例如，对于一个已经启用的名为 `example_feature` 的功能标志：

```ruby
Feature.enabled?(:example_feature)
=> true
Feature.disabled?(:example_feature)
=> false
```

当功能准备好时，极狐GitLab 移除功能标志，启用和禁用它的选项不再存在。该功能在所有实例中都可用。

<a id="view-set-feature-flags"></a>

### 查看设置的功能标志

您可以查看所有极狐GitLab 管理员设置的功能标志：

```ruby
Feature.all
=> [#<Flipper::Feature:198220 name="example_feature", state=:on, enabled_gate_names=[:boolean], adapter=:memoizable>]

# Nice output
Feature.all.map {|f| [f.name, f.state]}
```

<a id="unset-feature-flag"></a>

### 取消设置功能标志

您可以取消设置功能标志，以便极狐GitLab 回退到该标志的当前默认值：

```ruby
Feature.remove(:example_feature)
=> true
```
