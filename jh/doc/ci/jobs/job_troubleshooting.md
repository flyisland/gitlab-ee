---
stage: Verify
group: Pipeline Authoring
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 作业故障排除
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用作业时，您可能会遇到以下问题。

<a id="jobs-or-pipelines-run-unexpectedly-when-using-changes"></a>

## 使用 `changes:` 时作业或流水线意外运行

如果在没有[合并请求流水线](../pipelines/merge_request_pipelines.md)的情况下使用 [`rules: changes`](../yaml/_index.md#ruleschanges) 或 [`only: changes`](../yaml/deprecated_keywords.md#onlychanges--exceptchanges)，您可能会遇到作业或流水线意外运行的情况。

对于与合并请求没有明确关联的分支或标签上的流水线，会使用先前的 SHA 来计算差异。此计算等同于 `git diff HEAD~`，可能导致意外行为，包括：

- 向极狐GitLab 推送新分支或新标签时，`changes` 规则始终评估为 true。
- 推送新提交时，更改的文件是以上一个提交作为基础 SHA 计算得出的。

此外，带有 `changes`的规则在[计划流水线](../pipelines/schedules.md)中始终评估为 true。计划流水线运行时，所有文件都被视为已更改，因此作业可能会始终被添加到使用 `changes`的计划流水线中。

<a id="file-paths-in-cicd-variables"></a>

## CI/CD 变量中的文件路径

在 CI/CD 变量中使用文件路径时请务必小心。变量定义中的尾部斜杠看起来可能正确，但在 `script:`、`changes:` 或其他关键字中展开时可能会变得无效。例如：

```yaml
docker_build:
  variables:
    DOCKERFILES_DIR: 'path/to/files/'  # This variable should not have a trailing '/' character
  script: echo "A docker job"
  rules:
    - changes:
        - $DOCKERFILES_DIR/*
```

当 `DOCKERFILES_DIR` 变量在 `changes:` 部分中展开时，完整路径会变成 `path/to/files//*`。双斜杠可能会导致意外行为，具体取决于所使用的关键字，或 runner 的 shell 和操作系统等因素。

<a id="error-you-are-not-allowed-to-download-code-from-this-project"></a>

## 错误：`You are not allowed to download code from this project.`

当极狐GitLab 管理员在私有项目中运行受保护的手动作业时，您可能会看到流水线失败。

CI/CD 作业通常在作业启动时克隆项目，这会使用[运行该作业的用户的权限](../../user/permissions.md#project-cicd)。所有用户（包括管理员）都必须是私有项目的直接成员，才能克隆该项目的源代码。[存在一个议题](https://gitlab.com/gitlab-org/gitlab/-/issues/23130)来更改此行为。

要运行受保护的手动作业：

- 将管理员添加为私有项目的直接成员（任意角色）
- [模拟用户](../../administration/admin_area.md#user-impersonation)，该用户是
  项目的直接成员。

<a id="a-cicd-job-does-not-use-newer-configuration-when-run-again"></a>

## CI/CD 作业再次运行时未使用较新的配置

流水线的配置仅在创建流水线时获取。重新运行作业时，每次都会使用相同的配置。如果您更新配置文件，包括通过 [`include`](../yaml/_index.md#include) 添加的单独文件，则必须启动新的流水线才能使用新配置。

<a id="warning-job-may-allow-multiple-pipelines-to-run-for-a-single-action"></a>

## 警告：`Job may allow multiple pipelines to run for a single action`

当您将 [`rules`](../yaml/_index.md#rules) 与不带 `if` 子句的 `when` 子句一起使用时，可能会运行多个流水线。这通常发生在您向一个有关联的开放合并请求的分支推送提交时。

要[防止重复流水线](job_rules.md#avoid-duplicate-pipelines)，请使用 [`workflow: rules`](../yaml/_index.md#workflow) 或重写您的规则，以控制哪些流水线可以运行。

<a id="error-this-gitlab-ci-configuration-is-invalid-for-variable-expressions"></a>

## 错误：变量表达式出现 `This GitLab CI configuration is invalid`

在使用 [CI/CD 变量表达式](job_rules.md#cicd-variable-expressions)时，您可能会收到若干 `This GitLab CI configuration is invalid` 错误之一。这些语法错误可能是由引号字符使用不当引起的。

在变量表达式中，字符串应加引号，而变量不应加引号。例如：

```yaml
variables:
  ENVIRONMENT: production

job:
  script: echo
  rules:
    - if: $ENVIRONMENT == "production"
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
```

在此示例中，两个 `if:` 子句都有效，因为 `production` 字符串加了引号，而 CI/CD 变量未加引号。

另一方面，以下 `if:` 子句都无效：

```yaml
variables:
  ENVIRONMENT: production

job:
  script: echo
  rules:       # These rules all cause YAML syntax errors:
    - if: ${ENVIRONMENT} == "production"
    - if: "$ENVIRONMENT" == "production"
    - if: $ENVIRONMENT == production
    - if: "production" == "production"
```

在此示例中：

- `if: ${ENVIRONMENT} == "production"` 无效，因为 `${ENVIRONMENT}` 不是
  `if:` 中 CI/CD 变量的有效格式。
- `if: "$ENVIRONMENT" == "production"` 无效，因为变量加了引号。
- `if: $ENVIRONMENT == production` 无效，因为字符串未加引号。
- `if: "production" == "production"` 无效，因为没有可比较的 CI/CD 变量。

<a id="get_sources-job-section-fails-because-of-an-http2-problem"></a>

## `get_sources` 作业部分因 HTTP/2 问题而失败

有时，作业会因以下 cURL 错误而失败：

```plaintext
++ git -c 'http.userAgent=gitlab-runner <version>' fetch origin +refs/pipelines/<id>:refs/pipelines/<id> ...
error: RPC failed; curl 16 HTTP/2 send again with decreased length
fatal: ...
```

您可以通过将 Git 和 `libcurl` 配置为[使用 HTTP/1.1](https://git-scm.com/docs/git-config#Documentation/git-config.txt-httpversion) 来变通解决此问题。该配置可以添加到：

- 作业的 [`pre_get_sources_script`](../yaml/_index.md#hookspre_get_sources_script)：

  ```yaml
  job_name:
    hooks:
      pre_get_sources_script:
        - git config --global http.version "HTTP/1.1"
  ```

- [runner 的 `config.toml`](https://gitlab.cn/docs/runner/configuration/advanced-configuration/)，
  使用 [Git 配置环境变量](https://git-scm.com/docs/git-config#ENVIRONMENT)：

  ```toml
  [[runners]]
  ...
  environment = [
    "GIT_CONFIG_COUNT=1",
    "GIT_CONFIG_KEY_0=http.version",
    "GIT_CONFIG_VALUE_0=HTTP/1.1"
  ]
  ```

<a id="job-using-resource_group-gets-stuck"></a>

## 使用 `resource_group`的作业卡住

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

如果使用 [`resource_group`](../yaml/_index.md#resource_group)的作业卡住，
极狐GitLab 管理员可以尝试从 [rails console](../../administration/operations/rails_console.md#starting-a-rails-console-session) 运行以下命令：

```ruby
# find resource group by name
resource_group = Project.find_by_full_path('...').resource_groups.find_by(key: 'the-group-name')
busy_resources = resource_group.resources.where('build_id IS NOT NULL')

# identify which builds are occupying the resource
# (I think it should be 1 as of today)
busy_resources.pluck(:build_id)

# it's good to check why this build is holding the resource.
# Is it stuck? Has it been forcefully dropped by the system?
# free up busy resources
busy_resources.update_all(build_id: nil)
```

<a id="error-data-integrity-failure"></a>

## 错误：`data integrity failure`

在作业处理过程中，您可能会看到 `data integrity failure` 错误。它可能发生在任何作业类型上，包括[下游流水线](../pipelines/downstream_pipelines.md)的触发器作业、等待 runner 分配的作业，以及清理期间卡住的作业。

请检查您的 PostgreSQL 和 Sidekiq 日志以确定根本原因。
极狐GitLab 私有化部署实例上的常见原因包括：

升级后数据库序列损坏
: PostgreSQL 日志包含 `PG::UniqueViolation` 错误。请确认相关的
  数据库触发器函数引用了正确的序列。

升级后 Sidekiq 进程陈旧
: 故障是间歇性的，重试作业会成功。请确认所有 Sidekiq
  节点都运行预期的极狐GitLab 版本，并重启任何不符合的节点。

数据库模式变更导致 SQL 不明确或无效
: PostgreSQL 日志包含作业处理期间执行的查询产生的 SQL 错误。
  请确认最近的数据库模式变更是否影响了为此作业类型运行的查询。

如果错误仍然存在，请在
[Rails console](../../administration/operations/rails_console.md)中检查该作业，以确定
`failure_reason` 以及是否创建了下游流水线。

<a id="error-you-are-not-authorized-to-run-this-manual-job"></a>

## 错误：`You are not authorized to run this manual job`

在以下情况下，尝试运行手动作业时，您可能会看到此消息，且 **运行** 处于禁用状态：

- 目标环境是[受保护环境](../environments/protected_environments.md)，
  且您的账号未包含在 **允许部署** 列表中。
- 已启用[防止过时的部署作业](../environments/deployment_safety.md#prevent-outdated-deployment-jobs)
  设置，且运行该作业会覆盖最新的部署。

<a id="job-dropped-after-being-stuck-or-exceeding-its-timeout"></a>

## 作业在卡住或超时后被丢弃

如果作业长时间没有进展，极狐GitLab 会自动将其丢弃，并记录特定的 `failure_reason`。阈值取决于作业的状态：

| 作业状态  | 阈值                            | 失败原因                        |
|------------|----------------------------------------|-----------------------------------------|
| 待处理    | 24 小时                               | `stuck_pending_with_matching_runners`  |
| 待处理    | 1 小时                                 | `stuck_pending_no_matching_runners`    |
| 运行中    | 30 分钟无更新             | `no_updates_running`                   |
| 取消中  | 30 分钟无更新             | `no_updates_canceling`                 |
| 运行中    | 配置的 `timeout` 加 15 分钟   | `server_timeout_running`               |
| 取消中  | 配置的 `timeout` 加 15 分钟   | `server_timeout_canceling`             |

如果您的作业立即失败而不是等待，则这不是原因。要自动重试作业，或查看失败原因的完整列表，请参阅
[`retry:when`](../yaml/_index.md#retrywhen)。
