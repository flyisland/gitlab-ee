---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Rails 控制台
description: 从命令行与极狐GitLab 实例进行交互。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 的核心是一个[基于 Ruby on Rails 框架构建](https://gitlab.cn/blog/why-we-use-rails-to-build-gitlab/)的 Web 应用程序。[Rails 控制台](https://guides.rubyonrails.org/command_line.html#rails-console) 提供了一种从命令行与极狐GitLab 实例进行交互的方式，并且还能访问 Rails 内置的强大工具。

> [!warning]
> Rails 控制台会直接与极狐GitLab 交互。在很多情况下，
> 没有防护措施来防止你永久修改、损坏或破坏生产数据。如果你想在无风险的情况下探索 Rails 控制台，
> 强烈建议你在测试环境中操作。

Rails 控制台适用于正在排查问题或需要获取某些数据（只能通过直接访问极狐GitLab 应用程序完成）的极狐GitLab 系统管理员。需要具备基本的 Ruby 知识（可以尝试 [这个 30 分钟的教程](https://try.ruby-lang.org/) 快速入门）。有 Rails 经验会有所帮助，但不是必需的。

<a id="starting-a-rails-console-session"></a>

## 启动 Rails 控制台会话

启动 Rails 控制台会话的过程取决于极狐GitLab 安装类型。

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

```shell
sudo gitlab-rails console
```

{{< /tab >}}

{{< tab title="Docker" >}}

```shell
docker exec -it <container-id> gitlab-rails console
```

{{< /tab >}}

{{< tab title="自编译（源代码）" >}}

```shell
sudo -u git -H bundle exec rails console -e production
```

{{< /tab >}}

{{< tab title="Helm Chart（Kubernetes）" >}}

```shell
# find the pod
kubectl get pods --namespace <namespace> -lapp=toolbox

# open the Rails console
kubectl exec -it -c toolbox <toolbox-pod-name> -- gitlab-rails console
```

{{< /tab >}}

{{< /tabs >}}

要退出控制台，请输入：`quit`。

<a id="disable-autocompletion"></a>

### 禁用自动补全

Ruby 自动补全可能会降低终端速度。如果你想：

- 禁用自动补全，运行 `Reline.autocompletion = IRB.conf[:USE_AUTOCOMPLETE] = false`。
- 重新启用自动补全，运行 `Reline.autocompletion = IRB.conf[:USE_AUTOCOMPLETE] = true`。

<a id="enable-active-record-logging"></a>

## 启用 Active Record 日志记录

你可以通过在 Rails 控制台会话中运行以下命令来启用 Active Record 调试日志的输出：

```ruby
ActiveRecord::Base.logger = Logger.new($stdout)
```

默认情况下，上述脚本会将日志输出到标准输出。你可以通过将 `$stdout` 替换为所需文件路径来指定日志文件以重定向输出。例如，以下代码将所有内容记录到 `/tmp/output.log`：

```ruby
ActiveRecord::Base.logger = Logger.new('/tmp/output.log')
```

这将显示在控制台中运行任意 Ruby 代码所触发的数据库查询信息。要再次关闭日志记录，请运行：

```ruby
ActiveRecord::Base.logger = nil
```

<a id="attributes"></a>

## 属性

查看可用属性，并使用 pretty print（`pp`）格式化输出。

例如，确定哪些属性包含用户姓名和电子邮件地址：

```ruby
u = User.find_by_username('someuser')
pp u.attributes
```

部分输出：

```plaintext
{"id"=>1234,
 "email"=>"someuser@example.com",
 "sign_in_count"=>99,
 "name"=>"S User",
 "username"=>"someuser",
 "first_name"=>nil,
 "last_name"=>nil,
 "bot_type"=>nil}
```

然后利用这些属性，例如[测试 SMTP](https://gitlab.cn/docs/omnibus/settings/smtp/#testing-the-smtp-configuration)：

```ruby
e = u.email
n = u.name
Notify.test_email(e, "Test email for #{n}", 'Test email').deliver_now
#
Notify.test_email(u.email, "Test email for #{u.name}", 'Test email').deliver_now
```

<a id="disable-database-statement-timeout"></a>

## 禁用数据库语句超时

你可以为当前 Rails 控制台会话禁用 PostgreSQL 语句超时。

在 极狐GitLab 15.11 及更早版本中，要禁用数据库语句超时，请运行：

```ruby
ActiveRecord::Base.connection.execute('SET statement_timeout TO 0')
```

在 极狐GitLab 16.0 及更高版本中，[极狐GitLab 默认使用两个数据库连接](../../update/versions/gitlab_16_changes.md#1600)。要禁用数据库语句超时，请运行：

```ruby
ActiveRecord::Base.connection.execute('SET statement_timeout TO 0')
Ci::ApplicationRecord.connection.execute('SET statement_timeout TO 0')
```

运行 极狐GitLab 16.0 及更高版本但已重新配置为使用单个数据库连接的实例，应使用针对极狐GitLab 15.11 及更早版本的代码来禁用数据库语句超时。

禁用数据库语句超时仅影响当前的 Rails 控制台会话，不会持久保存到极狐GitLab 生产环境或下次 Rails 控制台会话中。

<a id="output-rails-console-session-history"></a>

## 输出 Rails 控制台会话历史

在 Rails 控制台中输入以下命令以显示你的命令历史记录。

```ruby
puts Reline::HISTORY.to_a
```

然后你可以将其复制到剪贴板并保存以备将来参考。

<a id="using-the-rails-runner"></a>

## 使用 Rails Runner

如果你需要在极狐GitLab 生产环境中运行一些 Ruby 代码，可以使用 [Rails Runner](https://guides.rubyonrails.org/command_line.html#rails-runner) 来实现。执行脚本文件时，该脚本必须可由 `git` 用户访问。

当命令或脚本完成后，Rails Runner 进程结束。这对于在其他脚本或 cron 作业中运行非常有用。

- 对于 Linux 软件包安装：

  ```shell
  sudo gitlab-rails runner "RAILS_COMMAND"

  # 使用两行 Ruby 脚本的示例
  sudo gitlab-rails runner "user = User.first; puts user.username"

  # 使用 Ruby 脚本文件的示例（确保使用完整路径）
  sudo gitlab-rails runner /path/to/script.rb
  ```

- 对于自编译安装：

  ```shell
  sudo -u git -H bundle exec rails runner -e production "RAILS_COMMAND"

  # 使用两行 Ruby 脚本的示例
  sudo -u git -H bundle exec rails runner -e production "user = User.first; puts user.username"

  # 使用 Ruby 脚本文件的示例（确保使用完整路径）
  sudo -u git -H bundle exec rails runner -e production /path/to/script.rb
  ```

Rails Runner 不会产生与控制台相同的输出。

如果你在控制台上设置变量，控制台会生成有用的调试输出，例如变量的内容或引用实体的属性：

```ruby
irb(main):001:0> user = User.first
=> #<User id:1 @root>
```

Rails Runner 不会这样做：你必须明确地生成输出：

```shell
$ sudo gitlab-rails runner "user = User.first"
$ sudo gitlab-rails runner "user = User.first; puts user.username ; puts user.id"
root
1
```

具备一些 Ruby 基础知识是非常有用的。尝试 [这个 30 分钟教程](https://try.ruby-lang.org/) 快速入门。有 Rails 经验会有所帮助，但不是必需的。

<a id="find-specific-methods-for-an-object"></a>

## 查找对象的特定方法

```ruby
Array.methods.select { |m| m.to_s.include? "sing" }
Array.methods.grep(/sing/)
```

<a id="find-method-source"></a>

## 查找方法源代码

```ruby
instance_of_object.method(:foo).source_location

# 示例：调用 project.private? 时
project.method(:private?).source_location
```

<a id="limiting-output"></a>

## 限制输出

在语句末尾添加分号（`;`）和一个后续语句会阻止默认的隐式返回输出。如果你已经显式地打印了详细信息并且可能有很多返回输出，这很有用：

```ruby
puts ActiveRecord::Base.descendants; :ok
Project.select(&:pages_deployed?).each {|p| puts p.path }; true
```

<a id="get-or-store-the-result-of-last-operation"></a>

## 获取或存储上一次操作的结果

下划线（`_`）表示上一条语句的隐式返回值。你可以使用它来从上一条命令的输出快速分配变量：

```ruby
Project.last
# => #<Project id:2537 root/discard>>
project = _
# => #<Project id:2537 root/discard>>
project.id
# => 2537
```

<a id="time-an-operation"></a>

## 为操作计时

如果你想对一个或多个操作进行计时，请使用以下格式，将占位符 `<operation>` 替换为你选择的 Ruby 或 Rails 命令：

```ruby
# 单个操作
Benchmark.measure { <operation> }

# 多个操作的细分
Benchmark.bm do |x|
  x.report(:label1) { <operation_1> }
  x.report(:label2) { <operation_2> }
end
```

有关更多信息，请查看我们关于基准测试的开发文档。

<a id="active-record-objects"></a>

## Active Record 对象

<a id="looking-up-database-persisted-objects"></a>

### 查找数据库持久化对象

在底层，Rails 使用 [Active Record](https://guides.rubyonrails.org/active_record_basics.html)（一个对象关系映射系统）来读取、写入并将应用程序对象映射到 PostgreSQL 数据库。这些映射由 Active Record 模型处理，这些模型是在 Rails 应用程序中定义的 Ruby 类。对于极狐GitLab，模型类位于 `/opt/gitlab/embedded/service/gitlab-rails/app/models`。

让我们为 Active Record 启用调试日志记录，以便查看底层数据库查询：

```ruby
ActiveRecord::Base.logger = Logger.new($stdout)
```

现在，让我们尝试从数据库中检索一个用户：

```ruby
user = User.find(1)
```

将返回：

```ruby
D, [2020-03-05T16:46:25.571238 #910] DEBUG -- :   User Load (1.8ms)  SELECT "users".* FROM "users" WHERE "users"."id" = 1 LIMIT 1
=> #<User id:1 @root>
```

我们可以看到，我们已经从数据库中查询了 `users` 表中 `id` 列值为 `1` 的行，并且 Active Record 已将该数据库记录转换为我们可以交互的 Ruby 对象。试试以下几个：

- `user.username`
- `user.created_at`
- `user.admin`

按照约定，列名直接转换为 Ruby 对象属性，因此你应该能够通过 `user.<列名>` 来查看属性值。

同样按照约定，Active Record 的类名（单数、驼峰式）直接映射到表名（复数、蛇形命名法），反之亦然。例如，`users` 表映射到 `User` 类，而 `application_settings` 表映射到 `ApplicationSetting` 类。

你可以在 Rails 数据库 schema 中找到表和列名的列表，该 schema 位于 `/opt/gitlab/embedded/service/gitlab-rails/db/schema.rb`。

你还可以通过属性名称从数据库中查找对象：

```ruby
user = User.find_by(username: 'root')
```

将返回：

```ruby
D, [2020-03-05T17:03:24.696493 #910] DEBUG -- :   User Load (2.1ms)  SELECT "users".* FROM "users" WHERE "users"."username" = 'root' LIMIT 1
=> #<User id:1 @root>
```

试试以下操作：

- `User.find_by(username: 'root')`
- `User.where.not(admin: true)`
- `User.where('created_at < ?', 7.days.ago)`

你注意到最后两条命令返回了一个 `ActiveRecord::Relation` 对象，该对象似乎包含多个 `User` 对象吗？

到目前为止，我们一直使用 `.find` 或 `.find_by`，它们旨在仅返回单个对象（注意到生成的 SQL 查询中的 `LIMIT 1` 了吗？）。当需要获取对象集合时，可以使用 `.where`。

让我们获取一个非管理员用户的集合，看看我们可以用它做什么：

```ruby
users = User.where.not(admin: true)
```

将返回：

```ruby
D, [2020-03-05T17:11:16.845387 #910] DEBUG -- :   User Load (2.8ms)  SELECT "users".* FROM "users" WHERE "users"."admin" != TRUE LIMIT 11
=> #<ActiveRecord::Relation [#<User id:3 @support-bot>, #<User id:7 @alert-bot>, #<User id:5 @carrie>, #<User id:4 @bernice>, #<User id:2 @anne>]>
```

现在，尝试以下操作：

- `users.count`
- `users.order(created_at: :desc)`
- `users.where(username: 'support-bot')`

在最后一条命令中，我们看到可以链式调用 `.where` 语句来生成更复杂的查询。还要注意，虽然返回的集合只包含一个对象，但我们无法直接与之交互：

```ruby
users.where(username: 'support-bot').username
```

将返回：

```ruby
Traceback (most recent call last):
        1: from (irb):37
D, [2020-03-05T17:18:25.637607 #910] DEBUG -- :   User Load (1.6ms)  SELECT "users".* FROM "users" WHERE "users"."admin" != TRUE AND "users"."username" = 'support-bot' LIMIT 11
NoMethodError (undefined method `username' for #<ActiveRecord::Relation [#<User id:3 @support-bot>]>)
Did you mean?  by_username
```

让我们使用 `.first` 方法获取集合中的第一个项目，从而从集合中检索单个对象：

```ruby
users.where(username: 'support-bot').first.username
```

现在，我们得到了想要的结果：

```ruby
D, [2020-03-05T17:18:30.406047 #910] DEBUG -- :   User Load (2.6ms)  SELECT "users".* FROM "users" WHERE "users"."admin" != TRUE AND "users"."username" = 'support-bot' ORDER BY "users"."id" ASC LIMIT 1
=> "support-bot"
```

有关使用 Active Record 从数据库检索数据的不同方法的更多信息，请参阅 [Active Record 查询接口文档](https://guides.rubyonrails.org/active_record_querying.html)。

<a id="query-the-database-using-an-active-record-model"></a>

## 使用 Active Record 模型查询数据库

```ruby
m = Model.where('attribute like ?', 'ex%')

# 例如查询项目
projects = Project.where('path like ?', 'Oumua%')
```

<a id="modifying-active-record-objects"></a>

### 修改 Active Record 对象

在上一节中，我们学习了如何使用 Active Record 检索数据库记录。现在，让我们学习如何将更改写入数据库。

首先，让我们检索 `root` 用户：

```ruby
user = User.find_by(username: 'root')
```

接下来，让我们尝试更新用户的密码：

```ruby
user.password = 'password'
user.save
```

将返回：

```ruby
Enqueued ActionMailer::MailDeliveryJob (Job ID: 05915c4e-c849-4e14-80bb-696d5ae22065) to Sidekiq(mailers) with arguments: "DeviseMailer", "password_change", "deliver_now", #<GlobalID:0x00007f42d8ccebe8 @uri=#<URI::GID gid://gitlab/User/1>>
=> true
```

在这里，我们看到 `.save` 命令返回了 `true`，表示密码更改已成功保存到数据库。

我们还看到保存操作触发了其他动作——在这种情况下，是一个用于发送电子邮件通知的后台作业。这是 [Active Record 回调](https://guides.rubyonrails.org/active_record_callbacks.html) 的一个例子——指定在 Active Record 对象生命周期中响应事件而运行的代码。这也是为什么在需要对数据进行直接更改时最好使用 Rails 控制台，因为通过直接数据库查询进行的更改不会触发这些回调。

也可以在一行中更新属性：

```ruby
user.update(password: 'password')
```

或者一次更新多个属性：

```ruby
user.update(password: 'password', email: 'hunter2@example.com')
```

现在，让我们尝试一些不同的操作：

```ruby
# 再次检索对象以获取其最新状态
user = User.find_by(username: 'root')
user.password = 'password'
user.password_confirmation = 'hunter2'
user.save
```

这将返回 `false`，表示我们所做的更改未保存到数据库。你可能已经猜到原因了，但让我们确认一下：

```ruby
user.save!
```

应该返回：

```ruby
Traceback (most recent call last):
        1: from (irb):64
ActiveRecord::RecordInvalid (Validation failed: Password confirmation doesn't match Password)
```

啊哈！我们触发了一个 [Active Record 验证](https://guides.rubyonrails.org/active_record_validations.html)。验证是在应用程序层面设置的业务逻辑，用于防止不需要的数据被保存到数据库，并且在大多数情况下会附带有用的消息，告诉你如何修复问题输入。

我们还可以在 `.update` 中添加感叹号（Ruby 中表示 `!`）：

```ruby
user.update!(password: 'password', password_confirmation: 'hunter2')
```

在 Ruby 中，以 `!` 结尾的方法名通常被称为“bang 方法”。按照约定，感叹号表示该方法直接修改它所操作的对象，而不是返回转换后的结果并保持底层对象不变。对于写入数据库的 Active Record 方法，bang 方法还有一个额外的功能：每当发生错误时，它们会引发显式异常，而不是仅仅返回 `false`。

我们还可以完全跳过验证：

```ruby
# 再次检索对象以获取其最新状态
user = User.find_by(username: 'root')
user.password = 'password'
user.password_confirmation = 'hunter2'
user.save!(validate: false)
```

不建议这样做，因为验证通常是为了确保用户提供数据的完整性和一致性。

验证错误会阻止整个对象被保存到数据库。你可以在下面的章节中看到这一点。当你在极狐GitLab UI 中提交表单时收到一个神秘的红色横幅，这通常是最快找到问题根源的方法。

<a id="interacting-with-active-record-objects"></a>

### 与 Active Record 对象交互

说到底，Active Record 对象只是标准的 Ruby 对象。因此，我们可以在它们上定义方法来执行任意操作。

例如，极狐GitLab 开发者添加了一些有助于双因素认证的方法：

```ruby
def disable_two_factor!
  transaction do
    update(
      otp_required_for_login:      false,
      encrypted_otp_secret:        nil,
      encrypted_otp_secret_iv:     nil,
      encrypted_otp_secret_salt:   nil,
      otp_grace_period_started_at: nil,
      otp_backup_codes:            nil
    )
    self.second_factor_webauthn_registrations.destroy_all # rubocop: disable DestroyAll
  end
end

def two_factor_enabled?
  two_factor_otp_enabled? || two_factor_webauthn_enabled?
end
```

（参见：`/opt/gitlab/embedded/service/gitlab-rails/app/models/user.rb`）

然后我们可以在任何用户对象上使用这些方法：

```ruby
user = User.find_by(username: 'root')
user.two_factor_enabled?
user.disable_two_factor!
```

有些方法是由极狐GitLab 使用的 gem 或 Ruby 软件包定义的。例如，极狐GitLab 使用 [StateMachines](https://github.com/state-machines/state_machines-activerecord) gem 来管理用户状态：

```ruby
state_machine :state, initial: :active do
  event :block do

  ...

  event :activate do

  ...

end
```

试试看：

```ruby
user = User.find_by(username: 'root')
user.state
user.block
user.state
user.activate
user.state
```

之前，我们提到验证错误会阻止整个对象被保存到数据库。让我们看看这会导致怎样的意外交互：

```ruby
user.password = 'password'
user.password_confirmation = 'hunter2'
user.block
```

我们得到了 `false` 返回！让我们像之前一样加上感叹号来找出发生了什么：

```ruby
user.block!
```

将返回：

```ruby
Traceback (most recent call last):
        1: from (irb):87
StateMachines::InvalidTransition (Cannot transition state via :block from :active (Reason(s): Password confirmation doesn't match Password))
```

我们看到，当我们尝试以任何方式更新用户时，来自看似完全不同的属性的验证错误会回来困扰我们。

实际上，我们有时会在极狐GitLab 管理设置中看到这种情况——验证有时会在极狐GitLab 更新中添加或更改，导致之前保存的设置现在无法通过验证。由于你一次只能通过 UI 更新一个设置的子集，在这种情况下，恢复到良好状态的唯一方法是通过 Rails 控制台进行直接操作。

<a id="commonly-used-active-record-models-and-how-to-look-up-objects"></a>

### 常用 Active Record 模型及如何查找对象

**通过主要电子邮件地址或用户名获取用户**：

```ruby
User.find_by(email: 'admin@example.com')
User.find_by(username: 'root')
```

**通过主要或次要电子邮件地址获取用户**：

```ruby
User.find_by_any_email('user@example.com')
```

`find_by_any_email` 方法是极狐GitLab 开发者添加的自定义方法，而不是 Rails 提供的默认方法。

**获取管理员用户集合**：

```ruby
User.admins
```

`admins` 是一个[作用域便捷方法](https://guides.rubyonrails.org/active_record_querying.html#scopes)，它在底层执行 `where(admin: true)`。

**通过路径获取项目**：

```ruby
Project.find_by_full_path('group/subgroup/project')
```

`find_by_full_path` 是极狐GitLab 开发者添加的自定义方法，而不是 Rails 提供的默认方法。

**通过数字 ID 获取项目的议题或合并请求**：

```ruby
project = Project.find_by_full_path('group/subgroup/project')
project.issues.find_by(iid: 42)
project.merge_requests.find_by(iid: 42)
```

`iid` 表示“内部 ID”，是我们将议题和合并请求 ID 限定在每个极狐GitLab 项目范围内的方式。

**通过路径获取群组**：

```ruby
Group.find_by_full_path('group/subgroup')
```

**获取群组的相关群组**：

```ruby
group = Group.find_by_full_path('group/subgroup')

# 获取群组的父群组
group.parent

# 获取群组的子群组
group.children
```

**获取群组的项目**：

```ruby
group = Group.find_by_full_path('group/subgroup')

# 获取群组的直接子项目
group.projects

# 获取群组的子项目，包括子群组中的项目
group.all_projects
```

**获取 CI 流水线或构建**：

```ruby
Ci::Pipeline.find(4151)
Ci::Build.find(66124)
```

流水线和作业 ID 编号在整个极狐GitLab 实例中全局递增，因此无需使用内部 ID 属性来查找它们，这与议题或合并请求不同。

**获取当前应用程序设置对象**：

```ruby
ApplicationSetting.current
```

<a id="open-object-in-irb"></a>

### 在 `irb` 中打开对象

> [!warning]
> 更改数据的命令如果运行不正确或在正确的条件下运行，可能会造成损坏。始终首先在测试环境中运行命令，并准备好备份实例以便恢复。

有时候，如果你在对象的上下文中，浏览方法会更容易。你可以通过在 `Object` 的命名空间中添加一个方法，让你在任何对象的上下文中打开 `irb`：

```ruby
Object.define_method(:irb) { binding.irb }

project = Project.last
# => #<Project id:2537 root/discard>>
project.irb
# 注意新上下文
irb(#<Project>)> web_url
# => "https://gitlab-example/root/discard"
```

<a id="troubleshooting"></a>

## 故障排查

<a id="rails-runner-syntax-error"></a>

### Rails Runner `语法错误`

`gitlab-rails` 命令默认使用非 root 账户和组来执行 Rails Runner：`git:git`。

如果非 root 账户找不到传递给 `gitlab-rails runner` 的 Ruby 脚本文件名，你可能会收到语法错误，而不是文件无法访问的错误。

一个常见的原因是脚本被放在了 root 账户的主目录中。

`runner` 尝试将路径和文件参数作为 Ruby 代码进行解析。

例如：

```plaintext
[root ~]# echo 'puts "hello world"' > ./helloworld.rb
[root ~]# sudo gitlab-rails runner ./helloworld.rb
Please specify a valid ruby command or the path of a script to run.
Run 'rails runner -h' for help.

/opt/gitlab/..../runner_command.rb:45: syntax error, unexpected '.'
./helloworld.rb
^
[root ~]# sudo gitlab-rails runner /root/helloworld.rb
Please specify a valid ruby command or the path of a script to run.
Run 'rails runner -h' for help.

/opt/gitlab/..../runner_command.rb:45: unknown regexp options - hllwrld
[root ~]# mv ~/helloworld.rb /tmp
[root ~]# sudo gitlab-rails runner /tmp/helloworld.rb
hello world
```

如果目录可以访问但文件无法访问，则应生成有意义的错误：

```plaintext
[root ~]# chmod 400 /tmp/helloworld.rb
[root ~]# sudo gitlab-rails runner /tmp/helloworld.rb
Traceback (most recent call last):
      [traceback removed]
/opt/gitlab/..../runner_command.rb:42:in `load': cannot load such file -- /tmp/helloworld.rb (LoadError)
```

如果你遇到类似的错误：

```plaintext
[root ~]# sudo gitlab-rails runner helloworld.rb
Please specify a valid ruby command or the path of a script to run.
Run 'rails runner -h' for help.

undefined local variable or method `helloworld' for main:Object
```

你可以将文件移动到 `/tmp` 目录，或者创建一个由用户 `git` 拥有新目录，并将脚本保存在该目录中，如下所示：

```shell
sudo mkdir /scripts
sudo mv /script_path/helloworld.rb /scripts
sudo chown -R git:git /scripts
sudo chmod 700 /scripts
sudo gitlab-rails runner /scripts/helloworld.rb
```

<a id="filtered-console-output"></a>

### 过滤后的控制台输出

控制台中的某些输出可能会被默认过滤，以防止泄露某些值，例如变量、日志或密钥。此输出显示为 `[FILTERED]`。例如：

```plaintext
> Plan.default.actual_limits
=> ci_instance_level_variables: "[FILTERED]",
```

要绕过过滤，可以直接从对象读取值。例如：

```plaintext
> Plan.default.limits.ci_instance_level_variables
=> 25
```