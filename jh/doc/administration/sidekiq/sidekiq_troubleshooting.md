---
stage: Tenant Scale
group: Tenant Services
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 故障排除 Sidekiq
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

Sidekiq 是极狐GitLab 用于异步运行任务的后台作业处理器。当出现问题时，故障排除可能会很困难。这些情况往往也伴随着较大压力，因为生产系统的作业队列可能正在不断积压。用户会注意到这种情况，因为新分支可能不会显示，合并请求也可能不会更新。以下是一些故障排除步骤，可帮助您诊断瓶颈所在。

极狐GitLab 管理员/用户应考虑与极狐GitLab 支持一起执行这些调试步骤，以便我们的团队分析回溯信息。这可能会揭示极狐GitLab 中的缺陷或需要改进之处。

在任何回溯信息中，请警惕怀疑所有线程似乎都在等待数据库、Redis 或等待获取互斥锁的情况。例如，这可能意味着数据库中存在争用，但请寻找一个与其他线程不同的线程。这个其他线程可能正在占用所有可用的 CPU，或者持有 Ruby 全局解释器锁，从而阻止其他线程继续运行。

<a id="log-arguments-to-sidekiq-jobs"></a>

## 记录 Sidekiq 作业的参数

默认情况下，会记录传递给 Sidekiq 作业的部分参数。为避免记录敏感信息（例如密码重置令牌），极狐GitLab 会记录所有 worker 的数字参数，并对某些参数不敏感的特定 worker 进行覆盖。

示例日志输出：

```json
{"severity":"INFO","time":"2020-06-08T14:37:37.892Z","class":"AdminEmailsWorker","args":["[FILTERED]","[FILTERED]","[FILTERED]"],"retry":3,"queue":"admin_emails","backtrace":true,"jid":"9e35e2674ac7b12d123e13cc","created_at":"2020-06-08T14:37:37.373Z","meta.user":"root","meta.caller_id":"Admin::EmailsController#create","correlation_id":"37D3lArJmT1","uber-trace-id":"2d942cc98cc1b561:6dc94409cfdd4d77:9fbe19bdee865293:1","enqueued_at":"2020-06-08T14:37:37.410Z","pid":65011,"message":"AdminEmailsWorker JID-9e35e2674ac7b12d123e13cc: done: 0.48085 sec","job_status":"done","scheduling_latency_s":0.001012,"redis_calls":9,"redis_duration_s":0.004608,"redis_read_bytes":696,"redis_write_bytes":6141,"duration_s":0.48085,"cpu_s":0.308849,"completed_at":"2020-06-08T14:37:37.892Z","db_duration_s":0.010742}
{"severity":"INFO","time":"2020-06-08T14:37:37.894Z","class":"ActiveJob::QueueAdapters::SidekiqAdapter::JobWrapper","wrapped":"ActionMailer::MailDeliveryJob","queue":"mailers","args":["[FILTERED]"],"retry":3,"backtrace":true,"jid":"e47a4f6793d475378432e3c8","created_at":"2020-06-08T14:37:37.884Z","meta.user":"root","meta.caller_id":"AdminEmailsWorker","correlation_id":"37D3lArJmT1","uber-trace-id":"2d942cc98cc1b561:29344de0f966446d:5c3b0e0e1bef987b:1","enqueued_at":"2020-06-08T14:37:37.885Z","pid":65011,"message":"ActiveJob::QueueAdapters::SidekiqAdapter::JobWrapper JID-e47a4f6793d475378432e3c8: start","job_status":"start","scheduling_latency_s":0.009473}
{"severity":"INFO","time":"2020-06-08T14:39:50.648Z","class":"NewIssueWorker","args":["455","1"],"retry":3,"queue":"new_issue","backtrace":true,"jid":"a24af71f96fd129ec47f5d1e","created_at":"2020-06-08T14:39:50.643Z","meta.user":"root","meta.project":"h5bp/html5-boilerplate","meta.root_namespace":"h5bp","meta.caller_id":"Projects::IssuesController#create","correlation_id":"f9UCZHqhuP7","uber-trace-id":"28f65730f99f55a3:a5d2b62dec38dffc:48ddd092707fa1b7:1","enqueued_at":"2020-06-08T14:39:50.646Z","pid":65011,"message":"NewIssueWorker JID-a24af71f96fd129ec47f5d1e: start","job_status":"start","scheduling_latency_s":0.001144}
```

使用 [Sidekiq JSON 日志](../logs/_index.md#sidekiqlog)时，参数日志的最大大小限制为 10 KB 文本；超过此限制的任何参数都会被丢弃，并替换为包含字符串 `"..."` 的单个参数。

您可以将 `SIDEKIQ_LOG_ARGUMENTS` [环境变量](https://gitlab.cn/docs/omnibus/settings/environment-variables/)设置为 `0`（false）以禁用参数日志记录。

示例：

```ruby
gitlab_rails['env'] = {"SIDEKIQ_LOG_ARGUMENTS" => "0"}
```

<a id="investigating-sidekiq-queue-backlogs-or-slow-performance"></a>

## 调查 Sidekiq 队列积压或性能缓慢

Sidekiq 性能缓慢的症状包括合并请求状态更新问题，以及 CI 流水线开始运行前的延迟。

可能的原因包括：

- 极狐GitLab 实例可能需要更多 Sidekiq worker。默认情况下，单节点 Linux 软件包安装只运行一个 worker，将 Sidekiq 作业的执行限制在最多一个 CPU 核心上。[阅读有关运行多个 Sidekiq worker 的更多信息](extra_sidekiq_processes.md)。

- 实例配置了更多 Sidekiq worker，但大多数额外 worker 未配置为运行任何已排队的作业。当实例繁忙时，如果工作负载在配置 worker 后的数月或数年内发生了变化，或者由于极狐GitLab 产品变更，这可能会导致作业积压。

使用以下 Ruby 脚本收集 Sidekiq worker 的状态数据。

1. 创建脚本：

   ```ruby
   cat > /var/opt/gitlab/sidekiqcheck.rb <<EOF
   require 'sidekiq/monitor'
   Sidekiq::Monitor::Status.new.display('overview')
   Sidekiq::Monitor::Status.new.display('processes'); nil
   Sidekiq::Monitor::Status.new.display('queues'); nil
   puts "----------- workers ----------- "
   workers = Sidekiq::Workers.new
   workers.each do |_process_id, _thread_id, work|
     pp work
   end
   puts "----------- Queued Jobs ----------- "
   Sidekiq::Queue.all.each do |queue|
     queue.each do |job|
       pp job
     end
   end ;nil
   puts "----------- done! ----------- "
   EOF
   ```

1. 执行并捕获输出：

   ```shell
   sudo gitlab-rails runner /var/opt/gitlab/sidekiqcheck.rb > /tmp/sidekiqcheck_$(date '+%Y%m%d-%H:%M').out
   ```

   如果性能问题是间歇性的：

   - 每五分钟在 cron 作业中运行一次。将文件写入有足够空间的位置：每个文件至少预留 500 KB。

     ```shell
     cat > /etc/cron.d/sidekiqcheck <<EOF
     */5 * * * *  root  /opt/gitlab/bin/gitlab-rails runner /var/opt/gitlab/sidekiqcheck.rb > /tmp/sidekiqcheck_$(date '+\%Y\%m\%d-\%H:\%M').out 2>&1
     EOF
     ```

   - 回头查看数据以了解出了什么问题。

1. 分析输出。以下命令假设您有一个输出文件目录。

   1. `grep 'Busy: ' *` 显示正在运行的作业数量。`grep 'Enqueued: ' *` 显示当时的积压工作量。

   1. 查看 Sidekiq 处于负载状态时样本中各 worker 的繁忙线程数：

      ```shell
      ls | while read f ; do if grep -q 'Enqueued: 0' $f; then :
        else echo $f; egrep 'Busy:|Enqueued:|---- Processes' $f
        grep 'Threads:' $f ; fi
      done | more
      ```

      示例输出：

      ```plaintext
      sidekiqcheck_20221024-14:00.out
             Busy: 47
         Enqueued: 363
      ---- Processes (13) ----
        Threads: 30 (0 busy)
        Threads: 30 (0 busy)
        Threads: 30 (0 busy)
        Threads: 30 (0 busy)
        Threads: 23 (0 busy)
        Threads: 30 (0 busy)
        Threads: 30 (0 busy)
        Threads: 30 (0 busy)
        Threads: 30 (0 busy)
        Threads: 30 (0 busy)
        Threads: 30 (0 busy)
        Threads: 30 (24 busy)
        Threads: 30 (23 busy)
      ```

      - 在此输出文件中，有 47 个线程处于繁忙状态，积压了 363 个作业。
      - 在 13 个 worker 进程中，只有两个处于繁忙状态。
      - 这表明其他 worker 的配置过于具体。
      - 查看完整输出以确定哪些 worker 处于繁忙状态。将其与 `gitlab.rb` 中的 `sidekiq_queues` 配置相关联。
      - 过载的单 worker 环境可能如下所示：

        ```plaintext
        sidekiqcheck_20221024-14:00.out
               Busy: 25
           Enqueued: 363
        ---- Processes (1) ----
          Threads: 25 (25 busy)
        ```

   1. 查看输出文件的 `---- Queues (xxx) ----` 部分，以确定当时排队的作业。

   1. 这些文件还包含有关当时 Sidekiq 状态的低级别详细信息。这对于识别工作负载峰值来源可能很有用。

      - `----------- workers -----------` 部分详细说明了构成摘要中 `Busy` 计数的作业。
      - `----------- Queued Jobs -----------` 部分提供了有关 `Enqueued` 作业的详细信息。

<a id="thread-dump"></a>

## 线程转储

向 Sidekiq 进程 ID 发送 `TTIN` 信号，以在日志文件中输出线程回溯。

```shell
kill -TTIN <sidekiq_pid>
```

在 `/var/log/gitlab/sidekiq/current` 或 `$GITLAB_HOME/log/sidekiq.log` 中检查回溯输出。回溯信息通常很长，并且通常以多条 `WARN` 级别消息开头。以下是单个线程回溯的示例：

```plaintext
2016-04-13T06:21:20.022Z 31517 TID-orn4urby0 WARN: ActiveRecord::RecordNotFound: Couldn't find Note with 'id'=3375386
2016-04-13T06:21:20.022Z 31517 TID-orn4urby0 WARN: /opt/gitlab/embedded/service/gem/ruby/2.1.0/gems/activerecord-4.2.5.2/lib/active_record/core.rb:155:in `find'
/opt/gitlab/embedded/service/gitlab-rails/app/workers/new_note_worker.rb:7:in `perform'
/opt/gitlab/embedded/service/gem/ruby/2.1.0/gems/sidekiq-4.0.1/lib/sidekiq/processor.rb:150:in `execute_job'
/opt/gitlab/embedded/service/gem/ruby/2.1.0/gems/sidekiq-4.0.1/lib/sidekiq/processor.rb:132:in `block (2 levels) in process'
/opt/gitlab/embedded/service/gem/ruby/2.1.0/gems/sidekiq-4.0.1/lib/sidekiq/middleware/chain.rb:127:in `block in invoke'
/opt/gitlab/embedded/service/gitlab-rails/lib/gitlab/sidekiq_middleware/memory_killer.rb:17:in `call'
/opt/gitlab/embedded/service/gem/ruby/2.1.0/gems/sidekiq-4.0.1/lib/sidekiq/middleware/chain.rb:129:in `block in invoke'
/opt/gitlab/embedded/service/gitlab-rails/lib/gitlab/sidekiq_middleware/arguments_logger.rb:6:in `call'
...
```

在某些情况下，Sidekiq 可能会挂起且无法响应 `TTIN` 信号。如果发生这种情况，请继续使用其他故障排除方法。

<a id="ruby-profiling-with-rbspy"></a>

## 使用 `rbspy` 进行 Ruby 性能分析

[rbspy](https://rbspy.github.io) 是一款易于使用且开销较低的 Ruby 分析器，可用于创建 Ruby 进程 CPU 使用情况的火焰图样式图表。

使用它无需对极狐GitLab 进行任何更改，也没有任何依赖项。安装方法：

1. 从 [`rbspy` 发布页面](https://github.com/rbspy/rbspy/releases)下载二进制文件。
1. 使二进制文件可执行。

要对 Sidekiq worker 进行一分钟的性能分析，请运行：

```shell
sudo ./rbspy record --pid <sidekiq_pid> --duration 60 --file /tmp/sidekiq_profile.svg
```

![rbspy 火焰图示例](img/sidekiq_flamegraph_v14_6.png)

在这个由 `rbspy` 生成的火焰图示例中，Sidekiq 进程几乎将所有时间都花在了 `rev_parse` 上，这是 Rugged 中的一个原生 C 函数。在堆栈中，我们可以看到 `rev_parse` 被 `ExpirePipelineCacheWorker` 调用。

`rbspy` 在[容器化环境](https://rbspy.github.io/using-rbspy/index.html#containers)中需要额外的[能力](https://man7.org/linux/man-pages/man7/capabilities.7.html)。它至少需要 `SYS_PTRACE` 能力。否则，它会以 `permission denied` 错误终止。

{{< tabs >}}

{{< tab title="Kubernetes" >}}

```yaml
securityContext:
  capabilities:
    add:
      - SYS_PTRACE
```

{{< /tab >}}

{{< tab title="Docker" >}}

```shell
docker run --cap-add SYS_PTRACE [...]
```

{{< /tab >}}

{{< tab title="Docker Compose" >}}

```yaml
services:
  ruby_container_name:
    # ...
    cap_add:
      - SYS_PTRACE
```

{{< /tab >}}

{{< /tabs >}}

<a id="process-profiling-with-perf"></a>

## 使用 `perf` 进行进程性能分析

Linux 有一个名为 `perf` 的进程性能分析工具，当某个进程占用大量 CPU 时，该工具非常有用。如果您看到 CPU 使用率很高，并且 Sidekiq 没有响应 `TTIN` 信号，那么这是很好的下一步。

如果您的系统上未安装 `perf`，请使用 `apt-get` 或 `yum` 安装：

```shell
# Debian
sudo apt-get install linux-tools

# Ubuntu (may require these additional Kernel packages)
sudo apt-get install linux-tools-common linux-tools-generic linux-tools-`uname -r`

# Red Hat/CentOS
sudo yum install perf
```

对 Sidekiq PID 运行 `perf`：

```shell
sudo perf record -p <sidekiq_pid>
```

让它运行 30-60 秒，然后按 <kbd>Control</kbd>-<kbd>C</kbd>。然后查看 `perf` 报告：

```shell
$ sudo perf report

# Sample output
Samples: 348K of event 'cycles', Event count (approx.): 280908431073
 97.69%            ruby  nokogiri.so         [.] xmlXPathNodeSetMergeAndClear
  0.18%            ruby  libruby.so.2.1.0    [.] objspace_malloc_increase
  0.12%            ruby  libc-2.12.so        [.] _int_malloc
  0.10%            ruby  libc-2.12.so        [.] _int_free
```

`perf` 报告的示例输出显示，97% 的 CPU 都花在了 Nokogiri 和 `xmlXPathNodeSetMergeAndClear` 上。对于如此明显的情况，您应该接着调查极狐GitLab 中哪个作业会使用 Nokogiri 和 XPath。结合 `TTIN` 或 `gdb` 输出来显示发生这种情况的相应 Ruby 代码。

<a id="the-gnu-project-debugger-gdb"></a>

## GNU 项目调试器（`gdb`）

`gdb` 可以是调试 Sidekiq 的另一个有效工具。它为您提供了一种更具交互性的方式来查看每个线程并了解导致问题的原因。

使用 `gdb` 附加到进程会暂停进程的标准操作（附加 `gdb` 时，Sidekiq 不会处理作业）。

首先附加到 Sidekiq PID：

```shell
gdb -p <sidekiq_pid>
```

然后收集所有线程的信息：

```plaintext
info threads

# Example output
30 Thread 0x7fe5fbd63700 (LWP 26060) 0x0000003f7cadf113 in poll () from /lib64/libc.so.6
29 Thread 0x7fe5f2b3b700 (LWP 26533) 0x0000003f7ce0b68c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
28 Thread 0x7fe5f2a3a700 (LWP 26534) 0x0000003f7ce0ba5e in pthread_cond_timedwait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
27 Thread 0x7fe5f2939700 (LWP 26535) 0x0000003f7ce0b68c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
26 Thread 0x7fe5f2838700 (LWP 26537) 0x0000003f7ce0b68c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
25 Thread 0x7fe5f2737700 (LWP 26538) 0x0000003f7ce0b68c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
24 Thread 0x7fe5f2535700 (LWP 26540) 0x0000003f7ce0b68c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
23 Thread 0x7fe5f2434700 (LWP 26541) 0x0000003f7ce0b68c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
22 Thread 0x7fe5f2232700 (LWP 26543) 0x0000003f7ce0b68c in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
21 Thread 0x7fe5f2131700 (LWP 26544) 0x00007fe5f7b570f0 in xmlXPathNodeSetMergeAndClear ()
from /opt/gitlab/embedded/service/gem/ruby/2.1.0/gems/nokogiri-1.6.7.2/lib/nokogiri/nokogiri.so
...
```

如果您看到一个可疑线程，例如示例中的 Nokogiri 线程，您可能希望获取更多信息：

```plaintext
thread 21
bt

# Example output
#0  0x00007ff0d6afe111 in xmlXPathNodeSetMergeAndClear () from /opt/gitlab/embedded/service/gem/ruby/2.1.0/gems/nokogiri-1.6.7.2/lib/nokogiri/nokogiri.so
#1  0x00007ff0d6b0b836 in xmlXPathNodeCollectAndTest () from /opt/gitlab/embedded/service/gem/ruby/2.1.0/gems/nokogiri-1.6.7.2/lib/nokogiri/nokogiri.so
#2  0x00007ff0d6b09037 in xmlXPathCompOpEval () from /opt/gitlab/embedded/service/gem/ruby/2.1.0/gems/nokogiri-1.6.7.2/lib/nokogiri/nokogiri.so
#3  0x00007ff0d6b09017 in xmlXPathCompOpEval () from /opt/gitlab/embedded/service/gem/ruby/2.1.0/gems/nokogiri-1.6.7.2/lib/nokogiri/nokogiri.so
#4  0x00007ff0d6b092e0 in xmlXPathCompOpEval () from /opt/gitlab/embedded/service/gem/ruby/2.1.0/gems/nokogiri-1.6.7.2/lib/nokogiri/nokogiri.so
#5  0x00007ff0d6b0bc37 in xmlXPathRunEval () from /opt/gitlab/embedded/service/gem/ruby/2.1.0/gems/nokogiri-1.6.7.2/lib/nokogiri/nokogiri.so
#6  0x00007ff0d6b0be5f in xmlXPathEvalExpression () from /opt/gitlab/embedded/service/gem/ruby/2.1.0/gems/nokogiri-1.6.7.2/lib/nokogiri/nokogiri.so
#7  0x00007ff0d6a97dc3 in evaluate (argc=2, argv=0x1022d058, self=<value optimized out>) at xml_xpath_context.c:221
#8  0x00007ff0daeab0ea in vm_call_cfunc_with_frame (th=0x1022a4f0, reg_cfp=0x1032b810, ci=<value optimized out>) at vm_insnhelper.c:1510
```

要一次性输出所有线程的回溯：

```plaintext
set pagination off
thread apply all bt
```

使用 `gdb` 完成调试后，请务必从进程分离并退出：

```plaintext
detach
exit
```

<a id="sidekiq-kill-signals"></a>

## Sidekiq 终止信号

前面描述了 TTIN 是用于打印回溯以进行日志记录的信号。但是，Sidekiq 也会响应其他信号。例如，TSTP 和 TERM 可用于优雅地关闭 Sidekiq，请参阅 [Sidekiq Signals 文档](https://github.com/mperham/sidekiq/wiki/Signals#ttin)。

<a id="check-for-blocking-queries"></a>

## 检查阻塞查询

有时 Sidekiq 处理作业的速度可能非常快，以至于可能导致数据库争用。当之前记录的回溯显示许多线程卡在数据库适配器中时，请检查阻塞查询。

PostgreSQL wiki 提供了有关您可以运行以查看阻塞查询的查询的详细信息。该查询因 PostgreSQL 版本而异。有关查询详细信息，请参阅 [Lock Monitoring](https://wiki.postgresql.org/wiki/Lock_Monitoring)。

<a id="managing-sidekiq-queues"></a>

## 管理 Sidekiq 队列

可以使用 [Sidekiq API](https://github.com/sidekiq/sidekiq/wiki/API) 对 Sidekiq 执行多项故障排除步骤。

这些是管理命令，只有在当前管理界面因安装规模而不适用时才应使用。

所有这些命令都应使用 `gitlab-rails console` 运行。

<a id="view-the-queue-size"></a>

### 查看队列大小

```ruby
Sidekiq::Queue.new("pipeline_processing:build_queue").size
```

<a id="enumerate-all-enqueued-jobs"></a>

### 枚举所有已排队的作业

```ruby
queue = Sidekiq::Queue.new("chaos:chaos_sleep")
queue.each do |job|
  # job.klass # => 'MyWorker'
  # job.args # => [1, 2, 3]
  # job.jid # => jid
  # job.queue # => chaos:chaos_sleep
  # job["retry"] # => 3
  # job.item # => {
  #   "class"=>"Chaos::SleepWorker",
  #   "args"=>[1000],
  #   "retry"=>3,
  #   "queue"=>"chaos:chaos_sleep",
  #   "backtrace"=>true,
  #   "queue_namespace"=>"chaos",
  #   "jid"=>"39bc482b823cceaf07213523",
  #   "created_at"=>1566317076.266069,
  #   "correlation_id"=>"c323b832-a857-4858-b695-672de6f0e1af",
  #   "enqueued_at"=>1566317076.26761},
  # }

  # job.delete if job.jid == 'abcdef1234567890'
end
```

<a id="enumerate-currently-running-jobs"></a>

### 枚举当前正在运行的作业

```ruby
workers = Sidekiq::Workers.new
workers.each do |process_id, thread_id, work|
  # process_id is a unique identifier per Sidekiq process
  # thread_id is a unique identifier per thread
  # work is a Hash which looks like:
  # {"queue"=>"chaos:chaos_sleep",
  #  "payload"=>
  #  { "class"=>"Chaos::SleepWorker",
  #    "args"=>[1000],
  #    "retry"=>3,
  #    "queue"=>"chaos:chaos_sleep",
  #    "backtrace"=>true,
  #    "queue_namespace"=>"chaos",
  #    "jid"=>"b2a31e3eac7b1a99ff235869",
  #    "created_at"=>1566316974.9215662,
  #    "correlation_id"=>"e484fb26-7576-45f9-bf21-b99389e1c53c",
  #    "enqueued_at"=>1566316974.9229589},
  #  "run_at"=>1566316974}],
end
```

<a id="remove-sidekiq-jobs-for-given-parameters-destructive"></a>

### 根据给定参数删除 Sidekiq 作业（破坏性）

有条件地终止作业的通用方法是以下命令，该命令会删除已排队但尚未启动的作业。正在运行的作业无法终止。

```ruby
queue = Sidekiq::Queue.new('<queue name>')
queue.each { |job| job.delete if <condition>}
```

请参阅下面有关取消正在运行的作业的部分。

在前面记录的方法中，`<queue-name>` 是包含您要删除的作业的队列名称，`<condition>` 决定删除哪些作业。

通常，`<condition>` 引用作业参数，这些参数取决于相关作业的类型。要查找特定队列的参数，您可以查看相关 worker 文件的 `perform` 函数，该文件通常位于 `/app/workers/<queue-name>_worker.rb`。

例如，`repository_import` 将 `project_id` 作为作业参数，而 `update_merge_requests` 将 `project_id, user_id, oldrev, newrev, ref` 作为作业参数。

参数需要使用 `job.args[<id>]` 通过其序列 ID 引用，因为 `job.args` 是提供给 Sidekiq 作业的所有参数的列表。

以下是一些示例：

```ruby
queue = Sidekiq::Queue.new('update_merge_requests')
# In this example, we want to remove any update_merge_requests jobs
# for the Project with ID 125 and ref `ref/heads/my_branch`
queue.each { |job| job.delete if job.args[0] == 125 and job.args[4] == 'ref/heads/my_branch' }
```

```ruby
# Canceling jobs like: `RepositoryImportWorker.new.perform_async(100)`
id_list = [100]

queue = Sidekiq::Queue.new('repository_import')
queue.each do |job|
  job.delete if id_list.include?(job.args[0])
end
```

<a id="remove-specific-job-id-destructive"></a>

### 删除特定作业 ID（破坏性）

```ruby
queue = Sidekiq::Queue.new('repository_import')
queue.each do |job|
  job.delete if job.jid == 'my-job-id'
end
```

<a id="remove-sidekiq-jobs-for-a-specific-worker-destructive"></a>

### 删除特定 worker 的 Sidekiq 作业（破坏性）

```ruby
queue = Sidekiq::Queue.new("default")

queue.each do |job|
  if job.klass == "TodosDestroyer::PrivateFeaturesWorker"
    # Uncomment the line below to actually delete jobs
    #job.delete
    puts "Deleted job ID #{job.jid}"
  end
end
```

<a id="canceling-running-jobs-destructive"></a>

## 取消正在运行的作业（破坏性）

这是一项风险极高的操作，因此请仅将其作为最后的手段。这样做可能会导致数据损坏，因为作业在执行过程中被中断，并且无法保证已实现正确的事务回滚。

```ruby
Gitlab::SidekiqDaemon::Monitor.cancel_job('job-id')
```

这要求 Sidekiq 在运行时设置 `SIDEKIQ_MONITOR_WORKER=1` 环境变量。

要执行中断，我们使用 `Thread.raise`，它有许多缺点，如[为什么 Ruby 的 Timeout 是危险的（以及 `Thread.raise` 是可怕的）](https://jvns.ca/blog/2015/11/27/why-rubys-timeout-is-dangerous-and-thread-dot-raise-is-terrifying/#timeout-how-it-works-and-why-thread-raise-is-terrifying)中所述。

<a id="manually-trigger-a-cron-job"></a>

## 手动触发 cron 作业

通过访问 `/admin/background_jobs`，您可以查看实例上已调度/正在运行/待处理的作业。

您可以通过选择“立即入队”按钮从 UI 触发 cron 作业。要以编程方式触发 cron 作业，请先打开 [Rails 控制台](../operations/rails_console.md)。

要查找您要测试的 cron 作业：

```ruby
job = Sidekiq::Cron::Job.find('job-name')

# get status of job:
job.status

# enqueue job right now!
job.enque!
```

例如，要触发更新代码仓库镜像的 `update_all_mirrors_worker` cron 作业：

```ruby
irb(main):001:0> job = Sidekiq::Cron::Job.find('update_all_mirrors_worker')
=>
#<Sidekiq::Cron::Job:0x00007f147f84a1d0
...
irb(main):002:0> job.status
=> "enabled"
irb(main):003:0> job.enque!
=> 257
```

可用作业列表可以在 [workers](https://gitlab.com/gitlab-org/gitlab/-/tree/master/app/workers) 目录中找到。

有关 Sidekiq 作业的更多信息，请参阅 [Sidekiq-cron](https://github.com/sidekiq-cron/sidekiq-cron#work-with-job) 文档。

<a id="disabling-cron-jobs"></a>

## 禁用 cron 作业

您可以通过访问 [**管理员**区域中的监控部分](../admin_area.md#monitoring-section)来禁用任何 Sidekiq cron 作业。您也可以使用命令行和 [Rails Runner](../operations/rails_console.md#using-the-rails-runner) 执行相同的操作。

要禁用所有 cron 作业：

```shell
sudo gitlab-rails runner 'Sidekiq::Cron::Job.all.map(&:disable!)'
```

要启用所有 cron 作业：

```shell
sudo gitlab-rails runner 'Sidekiq::Cron::Job.all.map(&:enable!)'
```

如果您希望一次只启用部分作业，可以使用名称匹配。例如，要仅启用名称中包含 `geo` 的作业：

```shell
 sudo gitlab-rails runner 'Sidekiq::Cron::Job.all.select{ |j| j.name.match("geo") }.map(&:disable!)'
```

<a id="clearing-a-sidekiq-job-deduplication-idempotency-key"></a>

## 清除 Sidekiq 作业去重幂等键

有时，预期会运行的作业（例如 cron 作业）被观察到根本没有运行。检查日志时，可能会发现作业未运行且带有 `"job_status": "deduplicated"` 的情况。

当作业失败且幂等键未正确清除时，可能会发生这种情况。例如，[停止 Sidekiq 会在 25 秒后终止所有剩余作业](https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/4918)。

[默认情况下，该键会在 6 小时后过期](https://gitlab.com/gitlab-org/gitlab/-/blob/87c92f06eb92716a26679cd339f3787ae7edbdc3/lib/gitlab/sidekiq_middleware/duplicate_jobs/duplicate_job.rb#L23)，但如果您想立即清除幂等键，请按照以下步骤操作（提供的示例适用于 `Geo::VerificationBatchWorker`）：

1. 在 Sidekiq 日志中查找作业的 worker 类和 `args`：

   ```plaintext
   { ... "class":"Geo::VerificationBatchWorker","args":["container_repository"] ... }
   ```

1. 启动 [Rails 控制台会话](../operations/rails_console.md#starting-a-rails-console-session)。
1. 运行以下代码片段：

   ```ruby
   worker_class = Geo::VerificationBatchWorker
   args = ["container_repository"]
   dj = Gitlab::SidekiqMiddleware::DuplicateJobs::DuplicateJob.new({ 'class' => worker_class.name, 'args' => args }, worker_class.queue)
   dj.send(:idempotency_key)
   dj.delete!
   ```

<a id="cpu-saturation-in-redis-caused-by-sidekiq-brpop-calls"></a>

## Sidekiq BRPOP 调用导致的 Redis CPU 饱和

Sidekiq `BRPOP` 调用可能导致 Redis 上的 CPU 使用率增加。增大 [`SIDEKIQ_SEMI_RELIABLE_FETCH_TIMEOUT` 环境变量](../environment_variables.md)以改善 Redis 上的 CPU 使用率。

<a id="error-opensslcipherciphererror"></a>

## 错误：`OpenSSL::Cipher::CipherError`

如果您收到如下错误消息：

```plaintext
"OpenSSL::Cipher::CipherError","exception.message":"","exception.backtrace":["encryptor (3.0.0) lib/encryptor.rb:98:in `final'","encryptor (3.0.0) lib/encryptor.rb:98:in `crypt'","encryptor (3.0.0) lib/encryptor.rb:49:in `decrypt'"
```

此错误表示进程无法解密存储在极狐GitLab 数据库中的加密数据。这表明您的 `/etc/gitlab/gitlab-secrets.json` 文件存在问题。请确保您已将该文件从主极狐GitLab 节点复制到您的 Sidekiq 节点。
