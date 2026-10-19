---
stage: Fulfillment
group: Provision
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 激活极狐GitLab 企业版
description: 使用许可证文件或密钥激活极狐GitLab 企业版。
---

如果您收到来自极狐GitLab 的许可证文件（例如用于试用），可以将其上传到您的实例，或在安装期间添加。许可证文件是采用 base64 编码的 ASCII 文本文件，扩展名为 `.gitlab-license`。

首次登录极狐GitLab 实例时，应会显示一条带有**添加许可证**页面链接的提示。

否则，请在管理区域中添加您的许可证。

<a id="add-license-in-the-admin-area"></a>

## 在管理区域中添加许可证

1. 以管理员身份登录极狐GitLab。
1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 在**添加许可证**区域中，通过上传文件或输入密钥来添加许可证。
1. 选中**服务条款**复选框。
1. 选择**添加许可证**。

<a id="activate-subscription-during-installation"></a>

## 在安装期间激活订阅

要在安装期间激活订阅，请使用激活码设置 `GITLAB_ACTIVATION_CODE` 环境变量：

```shell
export GITLAB_ACTIVATION_CODE=your_activation_code
```

<a id="add-license-file-during-installation"></a>

## 在安装期间添加许可证文件

如果您有许可证，也可以在安装极狐GitLab 时导入。

- 对于自行编译的安装：
  - 将 `Gitlab.gitlab-license` 文件放在 `config/` 目录中。
  - 要为许可证指定自定义位置和文件名，请将文件路径设置到
    `GITLAB_LICENSE_FILE` 环境变量中：

    ```shell
    export GITLAB_LICENSE_FILE="/path/to/license/file"
    ```

- 对于 Linux 软件包安装：
  - 将 `Gitlab.gitlab-license` 文件放在 `/etc/gitlab/` 目录中。
  - 要为许可证指定自定义位置和文件名，请将以下条目添加到 `gitlab.rb`：

    ```ruby
    gitlab_rails['initial_license_file'] = "/path/to/license/file"
    ```

- 对于 Helm Chart 安装，请使用 [`global.gitlab.license` 配置键](https://gitlab.cn/docs/charts/installation/command-line-options/#basic-configuration)。

> [!warning]
> 这些方法仅在安装时添加许可证。要续订或升级
> 许可证，请在 Web 用户界面的**管理**区域中添加许可证。

<a id="submit-license-usage-data"></a>

## 提交许可证使用数据

如果您在离线环境中使用许可证文件或密钥激活实例，建议您每月提交许可证使用数据，以简化未来的购买和续订。要提交数据，请[导出您的许可证使用情况](license_usage.md#export-license-usage)，并通过电子邮件发送到续订服务，地址为 `renewals-service@customers.gitlab.com`。**在发送之前，您不得打开许可证使用文件**。否则，文件内容可能会被所使用的程序篡改（例如，时间戳可能被转换为另一种格式），从而导致文件处理时失败。

如果您在订阅开始日期后没有每月提交数据，系统会向与您的订阅关联的地址发送电子邮件，并显示横幅提醒您提交数据。该横幅会显示在**管理**区域的**仪表板**和**订阅**页面上，并且在下载使用文件后可以关闭。您只能在提交许可证使用数据后的下个月之前关闭它。

<a id="what-happens-when-your-license-expires"></a>

## 许可证过期后会发生什么

在许可证过期前十五天，会向极狐GitLab 管理员显示一条带有即将到期日期的通知横幅。

许可证在到期日当天开始时过期，即服务器时间 00:00。

许可证过期后，极狐GitLab 会锁定功能，例如 Git 推送和议题创建。您的实例将变为只读，并向所有管理员显示过期消息。

<!-- vale gitlab_base.OxfordComma = NO -->
例如，如果许可证的开始日期为 2024 年 1 月 1 日，结束日期为 2025 年 1 月 1 日：
<!-- vale gitlab_base.OxfordComma = YES -->

- 它在服务器时间 2024 年 12 月 31 日晚上 11:59:59 过期。
- 从服务器时间 2025 年 1 月 1 日凌晨 12:00:00 起，它被视为已过期。

要移除只读状态并恢复功能，请[续订您的订阅](../subscriptions/manage_subscription.md#renew-manually)。

如果许可证已过期超过 30 天，您必须购买[新订阅](../subscriptions/manage_subscription.md)才能恢复功能。

要恢复到基础版功能，请[删除所有已过期的许可证](#remove-a-license)。

<a id="remove-a-license"></a>

## 移除许可证

要从极狐GitLab 私有化部署实例中移除许可证：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**订阅**。
1. 选择**移除许可证**。

重复这些步骤以移除所有许可证，包括过去应用的许可证。

<a id="view-license-details-and-history"></a>

## 查看许可证详情和历史记录

要查看您的许可证详情：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**订阅**。

您可以添加并查看多个许可证，但只有当前日期范围内最新的许可证才是有效许可证。

当您添加未来日期的许可证时，它要到适用日期才会生效。您可以在**订阅历史记录**表中查看所有有效订阅。

您还可以将许可证使用信息[导出](../subscriptions/manage_subscription.md)为 CSV 文件。

<a id="license-commands-in-the-rails-console"></a>

## Rails 控制台中的许可证命令

以下命令可以在 [Rails 控制台](operations/rails_console.md#starting-a-rails-console-session)中运行。

> [!warning]
> 任何直接更改数据的命令，如果运行不正确或在不当条件下运行，都可能造成损害。
> 强烈建议在测试环境中运行这些命令，并准备好可恢复的实例备份，以防万一。

<a id="see-current-license-information"></a>

### 查看当前许可证信息

```ruby
# License information (name, company, email address)
License.current.licensee

# Plan:
License.current.plan

# Uploaded:
License.current.created_at

# Started:
License.current.starts_at

# Expires at:
License.current.expires_at

# Is this a trial license?
License.current.trial?

# License ID for lookup on CustomersDot
License.current.license_id

# License data in Base64-encoded ASCII format
License.current.data

# Confirm the current billable seat count excluding guest users. This is useful for customers who use an Ultimate subscription tier where Guest seats are not counted.
User.active.without_bots.excluding_guests_and_requests.count

```

<a id="interaction-with-licenses-that-start-in-the-future"></a>

#### 与未来生效的许可证的交互

```ruby
# Future license data follows the same format as current license data it just uses a different modifier for the License prefix
License.future_dated
```

<a id="check-if-a-project-feature-is-available-on-the-instance"></a>

### 检查实例上是否有某个项目功能

功能列于 [`features.rb`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/app/models/gitlab_subscriptions/features.rb)。

```ruby
License.current.feature_available?(:jira_dev_panel_integration)
```

<a id="check-if-a-project-feature-is-available-in-a-project"></a>

#### 检查项目中是否有某个项目功能

功能列于 [`features.rb`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/app/models/gitlab_subscriptions/features.rb)。

```ruby
p = Project.find_by_full_path('<group>/<project>')
p.feature_available?(:jira_dev_panel_integration)
```

<a id="add-a-license-through-the-console"></a>

### 通过控制台添加许可证

<a id="using-a-key-variable"></a>

#### 使用 `key` 变量

```ruby
key = "<key>"
license = License.new(data: key)
license.save
License.current # check to make sure it applied
```

<a id="using-a-license-file"></a>

#### 使用许可证文件

```ruby
license_file = File.open("/tmp/Gitlab.license")

key = license_file.read.gsub("\r\n", "\n").gsub(/\n+$/, '') + "\n"

license = License.new(data: key)
license.save
License.current # check to make sure it applied
```

这些代码片段可以保存到文件中，并[使用 Rails Runner](operations/rails_console.md#using-the-rails-runner) 执行，从而可以通过 shell 自动化脚本应用许可证。

例如，在[许可证过期且存在多个 LDAP 服务器](auth/ldap/ldap-troubleshooting.md#expired-license-causes-errors-with-multiple-ldap-servers)的已知边缘情况中就需要这样做。

<a id="remove-licenses"></a>

### 移除许可证

要清理[许可证历史记录表](#view-license-details-and-history)：

```ruby
TYPE = :trial?
# or :expired?

License.select(&TYPE).each(&:destroy!)

# or even License.all.each(&:destroy!)
```

<a id="troubleshooting"></a>

## 故障排除

<a id="no-subscription-area-in-the-admin-area"></a>

### 管理区域中没有订阅区域

您无法添加许可证，因为没有**订阅**区域。此问题可能在以下情况下发生：

- 您运行的是极狐GitLab 基础版。在添加许可证之前，您
  必须升级到企业版。
- 您使用的是 JihuLab.com。您无法将极狐GitLab 私有化部署许可证添加到 JihuLab.com。
  要在 JihuLab.com 上使用付费功能，请[购买单独的订阅](../subscriptions/manage_seats.md#gitlabcom-billing-and-usage)。

<a id="users-exceed-license-limit-upon-renewal"></a>

### 续订时用户数超出许可证限制

极狐GitLab 会显示一条消息，提示您购买更多用户。如果您添加的许可证没有足够的用户来覆盖实例中的用户数量，就会出现此问题。

要解决此问题，请购买额外的席位以覆盖这些用户。有关更多信息，请阅读[许可证常见问题解答](https://about.gitlab.com/pricing/licensing-faq/)。

对于使用许可证文件的实例，适用以下规则：

- 如果超出许可证的用户数小于或等于许可证文件中用户数的 10%，
  则应用该许可证，您将在下次续订时支付超额费用。
- 如果超出许可证的用户数超过许可证文件中用户数的 10%，
  则您必须先购买更多用户，才能应用该许可证。

例如，如果您购买了 100 个用户的许可证，则在添加许可证时可以有 110 个用户。但是，如果您有 111 个用户，则必须先购买更多用户，才能添加该许可证。

<a id="start-gitlab-ultimate-trial-still-displays-after-adding-license"></a>

### 添加许可证后仍显示 `Start GitLab Ultimate trial`

要解决此问题，请重启 [Puma 或整个极狐GitLab 实例](restart_gitlab.md)。
