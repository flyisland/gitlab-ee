---
stage: Fulfillment
group: Provision
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 激活 极狐GitLab 企业版
description: Activate GitLab Enterprise Edition with a license file or key.
---

如果您从极狐GitLab 收到许可证文件（例如用于试用），您可以
将其上传到您的实例或在安装期间添加。许可证文件
是一个 base64 编码的 ASCII 文本文件，扩展名为 `.gitlab-license`。

首次登录极狐GitLab 实例时，应显示一条带有指向
**添加许可证** 页面链接的提示。

否则，请在管理区域添加您的许可证。

<a id="add-license-in-the-admin-area"></a>

## 在管理区域添加许可证

1. 以管理员身份登录极狐GitLab。
1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 在 **添加许可证** 区域，通过上传文件或输入密钥来添加许可证。
1. 选中 **服务条款** 复选框。
1. 选择 **添加许可证**。

<a id="activate-subscription-during-installation"></a>

## 在安装期间激活订阅

{{< history >}}

- 在极狐GitLab 16.0 引入。

{{< /history >}}

要在安装期间激活订阅，请使用激活码设置 `GITLAB_ACTIVATION_CODE` 环境变量：

```shell
export GITLAB_ACTIVATION_CODE=your_activation_code
```

<a id="add-license-file-during-installation"></a>

## 在安装期间添加许可证文件

如果您有许可证，也可以在安装极狐GitLab 时导入它。

- 对于自编译安装：
  - 将 `Gitlab.gitlab-license` 文件放在 `config/` 目录中。
  - 要指定许可证的自定义位置和文件名，请使用文件路径设置
    `GITLAB_LICENSE_FILE` 环境变量：

    ```shell
    export GITLAB_LICENSE_FILE="/path/to/license/file"
    ```

- 对于 Linux 软件包安装：
  - 将 `Gitlab.gitlab-license` 文件放在 `/etc/gitlab/` 目录中。
  - 要指定许可证的自定义位置和文件名，请将以下条目添加到 `gitlab.rb`：

    ```ruby
    gitlab_rails['initial_license_file'] = "/path/to/license/file"
    ```

- 对于 Helm Charts 安装，请使用 [`global.gitlab.license` 配置键](https://gitlab.cn/docs/charts/installation/command-line-options/#basic-configuration)。

> [!warning]
> 这些方法仅在安装时添加许可证。要续订或升级
> 许可证，请在 Web 用户界面中的 **管理员** 区域添加许可证。

<a id="submit-license-usage-data"></a>

## 提交许可证使用数据

如果您在离线环境中使用许可证文件或密钥激活实例，我们鼓励您每月提交许可证
使用数据，以简化未来的购买和续订。
要提交数据，[导出您的许可证使用情况](license_usage.md#export-license-usage)
并通过电子邮件将其发送至续订服务 `renewals-service@customers.jihulab.com`。**在发送之前，您不得打开许可证
使用文件**。否则，文件内容可能会被使用的程序操纵（例如，
时间戳可能被转换为其他格式），并在文件处理时导致失败。

如果您在订阅开始日期后每月未提交数据，系统会向与您的订阅关联的地址
发送电子邮件，并显示横幅提醒您提交数据。横幅显示在
**管理员** 区域的 **仪表盘** 和 **订阅** 页面上，在
下载使用文件后可以关闭。您只能在提交许可证使用数据后的
下一个月之前关闭它。

<a id="what-happens-when-your-license-expires"></a>

## 许可证过期时会发生什么

在许可证到期前十五天，会向极狐GitLab 管理员显示一个带有即将到期日期的
通知横幅。

许可证在到期日当天服务器时间 00:00 到期。

当您的许可证到期时，极狐GitLab 会锁定功能，例如 Git 推送
和议题创建。您的实例将变为只读，并且
所有管理员都会看到过期消息。

例如，如果许可证的开始日期为 2024 年 1 月 1 日，结束日期为 2025 年 1 月 1 日：

- 它将在服务器时间 2024 年 12 月 31 日 23:59:59 到期。
- 它被认为从服务器时间 2025 年 1 月 1 日 00:00:00 起已过期。

要移除只读状态并恢复功能，[续订您的订阅](../subscriptions/manage_subscription.md#renew-manually)。

如果许可证已过期超过 30 天，您必须购买[新订阅](../subscriptions/manage_subscription.md)才能恢复功能。

要恢复基础版功能，[删除所有过期的许可证](#remove-a-license)。

<a id="remove-a-license"></a>

## 移除许可证

要从私有化部署的极狐GitLab 实例中移除许可证：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **订阅**。
1. 选择 **移除许可证**。

重复这些步骤以移除所有许可证，包括过去应用的许可证。

<a id="view-license-details-and-history"></a>

## 查看许可证详细信息和历史记录

要查看您的许可证详细信息：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **订阅**。

您可以添加和查看多个许可证，但只有当前日期范围内最新的许可证
才是活动许可证。

当您添加一个未来日期的许可证时，它要到适用日期才会生效。
您可以在 **订阅历史** 表中查看所有活动订阅。

您还可以[导出](../subscriptions/manage_subscription.md)您的许可证使用信息到 CSV 文件。

<a id="license-commands-in-the-rails-console"></a>

## Rails 控制台中的许可证命令

以下命令可以在 [Rails 控制台](operations/rails_console.md#starting-a-rails-console-session)运行。

> [!warning]
> 任何直接更改数据的命令如果未正确运行或在合适的条件下运行，都可能造成破坏。
> 我们强烈建议在测试环境中运行它们，并准备好实例的备份以便恢复，以防万一。

### 查看当前许可证信息

```ruby
# 许可证信息（名称、公司、电子邮件地址）
License.current.licensee

# 计划：
License.current.plan

# 上传时间：
License.current.created_at

# 开始时间：
License.current.starts_at

# 到期时间：
License.current.expires_at

# 这是试用许可证吗？
License.current.trial?

# 在 CustomersDot 上查找的许可证 ID
License.current.license_id

# Base64 编码的 ASCII 格式许可证数据
License.current.data

# 确认当前可计费席位数量（不包括访客用户）。这对于使用旗舰版订阅层级（不计算访客席位）的客户很有用。
User.active.without_bots.excluding_guests_and_requests.count

```

#### 与未来开始的许可证交互

```ruby
# 未来许可证数据遵循与当前许可证数据相同的格式，只是许可证前缀的修饰符不同
License.future_dated
```

### 检查实例上是否提供项目功能

功能列在 [`features.rb`](https://jihulab.com/gitlab-cn/gitlab/-/blob/master/ee/app/models/gitlab_subscriptions/features.rb) 中。

```ruby
License.current.feature_available?(:jira_dev_panel_integration)
```

#### 检查项目中是否提供项目功能

功能列在 [`features.rb`](https://jihulab.com/gitlab-cn/gitlab/-/blob/master/ee/app/models/gitlab_subscriptions/features.rb) 中。

```ruby
p = Project.find_by_full_path('<群组>/<项目>')
p.feature_available?(:jira_dev_panel_integration)
```

### 通过控制台添加许可证

#### 使用 `key` 变量

```ruby
key = "<key>"
license = License.new(data: key)
license.save
License.current # 检查以确保它已应用
```

#### 使用许可证文件

```ruby
license_file = File.open("/tmp/Gitlab.license")

key = license_file.read.gsub("\r\n", "\n").gsub(/\n+$/, '') + "\n"

license = License.new(data: key)
license.save
License.current # 检查以确保它已应用
```

这些代码片段可以保存到文件中，并[使用 Rails Runner](operations/rails_console.md#using-the-rails-runner) 执行，以便
可以通过 shell 自动化脚本应用许可证。

例如，这在已知的[过期许可证和多个 LDAP 服务器](auth/ldap/ldap-troubleshooting.md#expired-license-causes-errors-with-multiple-ldap-servers)边缘案例中是必需的。

### 移除许可证

要清理[许可证历史表](license_file.md#view-license-details-and-history)：

```ruby
TYPE = :trial?
# 或 :expired?

License.select(&TYPE).each(&:destroy!)

# 甚至 License.all.each(&:destroy!)
```

<a id="troubleshooting"></a>

## 故障排除

### 管理区域中没有订阅区域

您无法添加许可证，因为没有 **订阅** 区域。
如果出现以下情况，可能会发生此问题：

- 您正在运行极狐GitLab 基础版。在添加许可证之前，您
  必须升级到企业版。
- 您正在使用 JihuLab.com。您无法向 JihuLab.com 添加私有化部署许可证。
  要在 JihuLab.com 上使用付费功能，请[购买一个单独的订阅](../subscriptions/manage_seats.md#jihulabcom-billing-and-usage)。

### 续订时用户数量超出许可证限制

极狐GitLab 会显示一条消息，提示您购买
额外的用户。如果您添加的许可证没有足够的
用户数量来覆盖实例中的用户数量，就会发生此问题。

要解决此问题，请购买额外的席位以覆盖这些用户。
有关更多信息，请阅读[许可常见问题解答](https://gitlab.cn/pricing/licensing-faq/)。

在极狐GitLab 14.2 及更高版本中，对于使用许可证文件的实例，以下
规则适用：

- 如果超出许可证的用户数小于或等于许可证文件中用户数的 10%，则应用许可证
  ，并在下次续订时支付超额费用。
- 如果超出许可证的用户数超过许可证文件中用户数的 10%，
  则您无法在不购买更多用户的情况下应用许可证。

例如，如果您购买了 100 个用户的许可证，则添加许可证时可以有 110 个用户。但是，如果您有 111 个用户，则必须在添加许可证之前购买更多用户。

### 添加许可证后仍显示“开始极狐GitLab 旗舰版试用”

要解决此问题，请重启 [Puma 或整个极狐GitLab 实例](restart_gitlab.md)。