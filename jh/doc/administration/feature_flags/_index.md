---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: '极狐GitLab 管理员：启用和禁用通过功能标志部署的极狐GitLab 功能'
title: 启用和禁用通过功能标志部署的极狐GitLab 功能
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 采用功能标志策略，在开发早期阶段部署功能，以便能够逐步推出。

在功能永久可用之前，出于多种原因，功能可以先通过标志部署，例如：

- 测试该功能。
- 在功能开发早期阶段获取用户和客户的反馈。
- 评估用户采用情况。
- 评估该功能对极狐GitLab 性能的影响。
- 在多个版本中分小块构建该功能。

通过标志部署的功能可以逐步推出，通常流程如下：

1. 功能默认处于禁用状态。
1. 功能默认变为启用状态。
1. 功能标志被移除。

这些功能可以被启用和禁用，以允许或阻止用户使用它们。拥有 [Rails 控制台](#how-to-enable-and-disable-features-behind-flags)或 [功能标志 API](../../api/features.md) 访问权限的极狐GitLab 管理员可以执行此操作。

当您禁用功能标志时，该功能将对用户隐藏，并且所有相关功能都会关闭。例如，不会记录数据，服务也不会运行。

如果您使用了某个功能并发现了错误、异常行为或报错，请务必尽快[提供反馈](https://gitlab.com/gitlab-org/gitlab/-/work_items/new?issue[title]=Docs%20-%20feature%20flag%20feedback%3A%20Feature%20Name&issue[description]=Describe%20the%20problem%20you%27ve%20encountered.%0A%0A%3C!--%20Don%27t%20edit%20below%20this%20line%20--%3E%0A%0A%2Flabel%20~%22docs%5C-comments%22%20)给 GitLab，以便我们能在功能仍处于标志保护下时改进或修复它。当您升级极狐GitLab 时，功能标志状态可能会发生变化。

<a id="risks-when-enabling-features-still-in-development"></a>

## 启用仍处于开发阶段的功能的风险

在生产极狐GitLab 环境中启用默认禁用的功能标志之前，了解其中涉及的潜在风险至关重要。

> [!warning]
> 如果您启用默认禁用的功能，可能会出现数据损坏、稳定性下降、性能下降和安全问题。

默认禁用的功能在未来的极狐GitLab 版本中可能会在无通知的情况下发生变更或被移除。

不建议在生产环境中使用受默认禁用的功能标志控制的功能，并且使用默认禁用功能所导致的问题不在极狐GitLab 支持范围内。

在默认禁用功能中发现的安全问题会在常规版本中修复，并且不遵循我们常规的[维护策略](../../policy/maintenance.md#patch-releases)中关于向后移植修复的规定。

<a id="risks-when-disabling-released-features"></a>

## 禁用已发布功能的风险

在大多数情况下，功能标志代码会在未来的极狐GitLab 版本中被移除。如果发生这种情况，从那时起，您将无法再将该功能保持在禁用状态。

<a id="how-to-enable-and-disable-features-behind-flags"></a>

## 如何启用和禁用通过标志部署的功能

每个功能都有自己的标志，应使用该标志来启用和禁用该功能。每个通过标志部署的功能的文档都包含一个章节，说明该标志的状态以及启用或禁用它的命令。

<a id="start-the-gitlab-rails-console"></a>

### 启动 GitLab Rails 控制台

要启用或禁用通过标志部署的功能，您必须做的第一件事是在 GitLab Rails 控制台上启动一个会话。

对于 Linux 软件包安装：

```shell
sudo gitlab-rails console
```

对于从源代码安装：

```shell
sudo -u git -H bundle exec rails console -e production
```

有关详细信息，请参阅[启动 Rails 控制台会话](../operations/rails_console.md#starting-a-rails-console-session)。

<a id="enable-or-disable-the-feature"></a>

### 启用或禁用功能

Rails 控制台会话启动后，相应地运行 `Feature.enable` 或 `Feature.disable` 命令。具体标志可以在功能自身的文档中找到。

要启用功能，请运行：

```ruby
Feature.enable(:<feature flag>)
```

例如，要启用名为 `example_feature`的虚构功能标志：

```ruby
Feature.enable(:example_feature)
```

要禁用功能，请运行：

```ruby
Feature.disable(:<feature flag>)
```

例如，要禁用名为 `example_feature`的虚构功能标志：

```ruby
Feature.disable(:example_feature)
```

某些功能标志可以按项目启用或禁用：

```ruby
Feature.enable(:<feature flag>, Project.find(<project id>))
```

例如，要为项目 `1234` 启用 `:example_feature` 功能标志：

```ruby
Feature.enable(:example_feature, Project.find(1234))
```

某些功能标志可以按用户启用或禁用。例如，为用户 `sidney_jones` 启用 `:example_feature` 标志：

```ruby
Feature.enable(:example_feature, User.find_by_username("sidney_jones"))
```

`Feature.enable` 和 `Feature.disable` 始终返回 `true`，即使应用程序未使用该标志：

```ruby
irb(main):001:0> Feature.enable(:example_feature)
=> true
```

当功能准备就绪时，极狐GitLab 会移除功能标志，启用和禁用它的选项将不再存在。该功能将在所有实例中可用。

<a id="check-if-a-feature-flag-is-enabled"></a>

### 检查功能标志是否已启用

要检查标志是启用还是禁用，请使用 `Feature.enabled?` 或 `Feature.disabled?`。例如，对于名为 `example_feature` 且已启用的功能标志：

```ruby
Feature.enabled?(:example_feature)
=> true
Feature.disabled?(:example_feature)
=> false
```

当功能准备就绪时，极狐GitLab 会移除功能标志，启用和禁用它的选项将不再存在。该功能将在所有实例中可用。

<a id="view-set-feature-flags"></a>

### 查看已设置的功能标志

您可以查看极狐GitLab 管理员设置的所有功能标志：

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
