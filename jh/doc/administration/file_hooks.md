---
stage: Create
group: Import
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 文件钩子
description: "Create custom file hooks to integrate your 极狐GitLab 私有化部署 instance with external services without modifying source code."
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

使用自定义文件钩子来引入自定义集成，无需修改 极狐GitLab 源代码。

文件钩子针对每个事件运行。你可以在文件钩子的代码中过滤事件或项目，并根据需要创建多个文件钩子。每个文件钩子会在事件发生时由 极狐GitLab 异步触发。有关事件列表，请参阅[系统钩子](system_hooks.md)和 [Webhook](../user/project/integrations/webhook_events.md) 文档。

> [!note]
> 文件钩子必须在 极狐GitLab 服务器的文件系统上进行配置。只有 极狐GitLab
> 服务器管理员才能完成这些任务。如果你没有文件系统访问权限，可以探索
> [系统钩子](system_hooks.md)或 [Webhook](../user/project/integrations/webhooks.md)
> 作为替代方案。

除了编写和维护自己的文件钩子之外，你也可以直接修改 极狐GitLab 源代码并向上游贡献。这样，我们可以确保功能在各个版本中得以保留，并得到测试覆盖。

<a id="set-up-a-custom-file-hook"></a>

## 设置自定义文件钩子

文件钩子必须位于 `file_hooks` 目录中。子目录会被忽略。你可以在 [`file_hooks` 下的 `example` 目录](https://jihulab.com/gitlab-cn/gitlab/-/tree/master/file_hooks/examples)中找到示例。

要设置自定义钩子：

1. 在运行 Sidekiq 组件的 极狐GitLab 服务器上，找到插件目录。对于自编译安装，路径通常为 `/home/git/gitlab/file_hooks/`。对于 Linux 软件包安装，路径通常为 `/opt/gitlab/embedded/service/gitlab-rails/file_hooks`。
   对于[多服务器配置](reference_architectures/_index.md)，你的钩子文件必须存在于每个 极狐GitLab 应用程序（Rails）和 Sidekiq 服务器上。
2. 在 `file_hooks` 目录中，创建一个名称自选、不包含空格和特殊字符的文件。
3. 确保钩子文件可执行，并由 Git 用户所有。
4. 编写代码以实现文件钩子预期功能。可以使用任何语言，并确保顶部的 shebang 正确反映语言类型。例如，如果脚本是用 Ruby 编写的，shebang 可能是 `#!/usr/bin/env ruby`。
5. 文件钩子的数据以 JSON 格式通过 `STDIN` 提供。这与[系统钩子](system_hooks.md)完全相同。

假设文件钩子代码正确实现，钩子将相应触发。文件钩子文件列表会在每个事件时更新。无需重启 极狐GitLab 来应用新的文件钩子。

如果文件钩子以非零退出码执行或执行失败，将记录一条消息到：
- 对于自编译安装：`log/file_hook.log`
- 对于 Linux 软件包安装：`gitlab-rails/file_hook.log`

该文件仅在文件钩子退出码非零时才创建。
当文件钩子执行时，每次启动 `FileHookWorker`，Sidekiq 日志 `gitlab/sidekiq/current` 中都会添加一条记录。
该记录包含事件详情及所执行脚本。

<a id="file-hook-example"></a>

## 文件钩子示例

此示例仅在 `project_create` 事件时响应，极狐GitLab 实例会通知管理员有新项目被创建。

```ruby
#!/opt/gitlab/embedded/bin/ruby
# 通过使用嵌入式 Ruby 版本，我们消除了所选语言不可用的可能性
require 'json'
require 'mail'

# 传入的变量为 JSON 格式，因此需要先进行解析。
ARGS = JSON.parse($stdin.read)

# 我们只想在 project_create 事件时触发此文件钩子
return unless ARGS['event_name'] == 'project_create'

# 我们将通知 极狐GitLab 实例的管理员有新项目创建
Mail.deliver do
  from    'info@gitlab_instance.com'
  to      'admin@gitlab_instance.com'
  subject "new project " + ARGS['name']
  body    ARGS['owner_name'] + 'created project ' + ARGS['name']
end
```

<a id="validation-example"></a>

## 验证示例

自行编写文件钩子可能有些棘手，如果能够在不影响系统的情况下进行检查，会容易得多。我们提供了一个 Rake 任务，以便你在预发环境中测试文件钩子，然后再用于生产环境。该 Rake 任务会使用样本数据并执行每个文件钩子。输出结果应足以确定系统是否检测到你的文件钩子，以及它是否无错误执行。

```shell
# Omnibus 安装
sudo gitlab-rake file_hooks:validate

# 从源代码安装
cd /home/git/gitlab
bundle exec rake file_hooks:validate RAILS_ENV=production
```

```plaintext
正在验证 /file_hooks 目录下的文件钩子
* /home/git/gitlab/file_hooks/save_to_file.clj 成功（退出码为零）
* /home/git/gitlab/file_hooks/save_to_file.rb 失败（退出码非零）
```

<a id="related-topics"></a>

## 相关主题

- [服务器钩子](server_hooks.md)
- [系统钩子](system_hooks.md)

