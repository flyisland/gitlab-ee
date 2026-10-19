---
stage: GitLab Dedicated
group: Import
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 文件钩子
description: "创建自定义文件钩子，将您的极狐GitLab 私有化部署实例与外部服务集成，而无需修改源代码。"
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

使用自定义文件钩子，无需修改极狐GitLab 源代码即可引入自定义集成。

文件钩子会在每个事件上运行。您可以在文件钩子的代码中筛选事件或项目，并按需创建任意数量的文件钩子。发生事件时，极狐GitLab 会异步触发每个文件钩子。有关事件列表，请参阅[系统钩子](system_hooks.md)和 [webhook](../user/project/integrations/webhook_events.md) 文档。

> [!note]
> 文件钩子必须在极狐GitLab 服务器的文件系统上配置。只有极狐GitLab
> 服务器管理员才能完成这些任务。如果您没有文件系统访问权限，可以探索
> [系统钩子](system_hooks.md)或 [webhook](../user/project/integrations/webhooks.md)
> 作为替代方案。

除了编写和维护您自己的文件钩子之外，您也可以直接修改极狐GitLab 源代码并向上游贡献。这样，我们可以确保功能在各版本间保持一致，并通过测试覆盖。

<a id="set-up-a-custom-file-hook"></a>

## 设置自定义文件钩子

文件钩子必须位于 `file_hooks` 目录中。子目录会被忽略。您可以在 [`example` 目录（位于 `file_hooks` 下）](https://gitlab.com/gitlab-org/gitlab/-/tree/master/file_hooks/examples)中找到示例。

要设置自定义钩子：

1. 在运行 Sidekiq 组件的极狐GitLab 服务器上，找到插件目录。对于自行编译的安装，路径通常为
   `/home/git/gitlab/file_hooks/`。对于 Linux 软件包安装，路径通常为
   `/opt/gitlab/embedded/service/gitlab-rails/file_hooks`。

   对于[多服务器配置](reference_architectures/_index.md)，您的钩子文件必须存在于每个极狐GitLab 应用（Rails）和 Sidekiq 服务器上。

1. 在 `file_hooks` 目录中，创建一个您自选名称的文件，
   名称中不得包含空格或特殊字符。
1. 使钩子文件可执行，并确保其归 Git 用户所有。
1. 编写代码，使文件钩子按预期工作。可以使用
   任何语言，并确保顶部的 'shebang' 正确反映
   语言类型。例如，如果脚本使用 Ruby，shebang 可能
   是 `#!/usr/bin/env ruby`。
1. 提供给文件钩子的数据以 JSON 形式通过 `STDIN` 传入。它与
   [系统钩子](system_hooks.md)完全相同。

假设文件钩子代码实现正确，钩子会在适当的时候触发。文件钩子文件列表会在每个事件时更新。无需重启极狐GitLab 即可应用新的文件钩子。

如果文件钩子以非零退出码执行或执行失败，会将消息记录到：

- 对于自行编译的安装，记录到 `log/file_hook.log`。
- 对于 Linux 软件包安装，记录到 `gitlab-rails/file_hook.log`。

仅当文件钩子以非零退出码退出时，才会创建此文件。当文件钩子执行时，每启动一个 `FileHookWorker`，都会向 Sidekiq 日志 `gitlab/sidekiq/current` 添加一条记录。该记录包含事件详情以及所执行脚本的信息。

<a id="file-hook-example"></a>

## 文件钩子示例

此示例仅响应 `project_create` 事件，极狐GitLab 实例会通知管理员已创建新项目。

```ruby
#!/opt/gitlab/embedded/bin/ruby
# By using the embedded ruby version we eliminate the possibility that our chosen language
# would be unavailable from
require 'json'
require 'mail'

# The incoming variables are in JSON format so we need to parse it first.
ARGS = JSON.parse($stdin.read)

# We only want to trigger this file hook on the event project_create
return unless ARGS['event_name'] == 'project_create'

# We will inform our admins of our gitlab instance that a new project is created
Mail.deliver do
  from    'info@gitlab_instance.com'
  to      'admin@gitlab_instance.com'
  subject "new project " + ARGS['name']
  body    ARGS['owner_name'] + 'created project ' + ARGS['name']
end
```

<a id="validation-example"></a>

## 验证示例

编写自己的文件钩子可能比较棘手，如果能在不改变系统的情况下进行检查，会更容易。我们提供了一个 Rake 任务，您可以在预发布环境中使用它，在生产环境使用文件钩子之前先进行测试。该 Rake 任务使用示例数据并执行每个文件钩子。其输出应足以判断系统是否识别到您的文件钩子，以及它是否无错误地执行。

```shell
# Omnibus installations
sudo gitlab-rake file_hooks:validate

# Installations from source
cd /home/git/gitlab
bundle exec rake file_hooks:validate RAILS_ENV=production
```

输出示例：

```plaintext
Validating file hooks from /file_hooks directory
* /home/git/gitlab/file_hooks/save_to_file.clj succeed (zero exit code)
* /home/git/gitlab/file_hooks/save_to_file.rb failure (non-zero exit code)
```
