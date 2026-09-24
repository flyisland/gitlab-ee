---
stage: Verify
group: Pipeline Authoring
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 排查作业问题
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

在使用作业时，您可能会遇到以下问题。

<a id="jobs-or-pipelines-run-unexpectedly-when-using-changes:"></a>

使用 `changes:` 时作业或流水线意外运行

当使用 [`rules: changes`](../yaml/_index.md#ruleschanges) 或 [`only: changes`](../yaml/deprecated_keywords.md#onlychanges--exceptchanges) 而没有 [合并请求流水线](../pipelines/merge_request_pipelines.md) 时，您可能会遇到作业或流水线意外运行的情况。

在没有与合并请求明确关联的分支或标签上的流水线，会使用之前的 SHA 来计算差异。此计算等同于 `git diff HEAD~`，并可能导致意外行为，包括：

- 向极狐GitLab 推送新分支或新标签时，`changes` 规则始终评估为 true。
- 推送新提交时，更改的文件是通过使用上一个提交作为基础 SHA 来计算的。

此外，在 [计划流水线](../pipelines/schedules.md) 中，带有 `changes` 的规则始终评估为 true。当计划流水线运行时，所有文件都被视为已更改，因此作业可能总是被添加到使用 `changes` 的计划流水线中。

<a id="file-paths-in-cicd-variables"></a>

CI/CD 变量中的文件路径

在 CI/CD 变量中使用文件路径时要小心。尾部斜杠在变量定义中可能看起来正确，但在 `script:`、`changes:` 或其他关键字中展开时可能会变得无效。例如：

```yaml
docker_build:
  variables:
    DOCKERFILES_DIR: 'path/to/files/'  # This variable should not have a trailing '/' character
  script: echo "A docker job"
  rules:
    - changes:
        - $DOCKERFILES_DIR/*
```

当 `DOCKERFILES_DIR` 变量在 `changes:` 部分展开时，完整路径变为 `path/to/files//*`。双斜杠可能会导致意外行为，具体取决于所使用的关键字、Runner 的 shell 和操作系统等因素。

<a id="you-are-not-allowed-to-download-code-from-this-project-error-message"></a>

`您无权从该项目下载代码。` 错误消息

当极狐GitLab 管理员在私有项目中运行受保护的手动作业时，您可能会看到流水线失败。

CI/CD 作业通常在作业启动时克隆项目，这使用了运行作业的用户的 [权限](../../user/permissions.md#project-cicd)。所有用户，包括管理员，必须是私有项目的直接成员才能克隆该项目的源代码。[存在一个议题](https://jihulab.com/gitlab-cn/gitlab/-/issues/23130) 以更改此行为。

要运行受保护的手动作业：

- 将管理员添加为私有项目的直接成员（任何角色）
- [模拟用户](../../administration/admin_area.md#user-impersonation) 作为项目的直接成员。

<a id="a-cicd-job-does-not-use-newer-configuration-when-run-again"></a>

CI/CD 作业再次运行时不会使用较新的配置

流水线的配置仅在创建流水线时获取。当您重新运行作业时，每次都会使用相同的配置。如果您更新配置文件，包括使用 [`include`](../yaml/_index.md#include) 添加的单独文件，则必须启动新的流水线才能使用新配置。

<a id="job-may-allow-multiple-pipelines-to-run-for-a-single-action-warning"></a>

`作业可能允许单个操作运行多个流水线` 警告

当您使用带有 `when` 子句但没有 `if` 子句的 [`rules`](../yaml/_index.md#rules) 时，可能会运行多个流水线。通常，当您向具有关联的开放合并请求的分支推送提交时，会发生这种情况。

要 [防止重复流水线](job_rules.md#avoid-duplicate-pipelines)，请使用 [`workflow: rules`](../yaml/_index.md#workflow) 或重写规则以控制哪些流水线可以运行。

<a id="this-gitlab-ci-configuration-is-invalid-for-variable-expressions"></a>

变量表达式的 `此极狐GitLab CI 配置无效`

在使用 [CI/CD 变量表达式](job_rules.md#cicd-variable-expressions) 时，您可能会收到多个 `此极狐GitLab CI 配置无效` 错误之一。这些语法错误可能是由于引号字符使用不当造成的。

在变量表达式中，字符串应该用引号引起来，而变量不应该用引号引起来。例如：

```yaml
variables:
  ENVIRONMENT: production

job:
  script: echo
  rules:
    - if: $ENVIRONMENT == "production"
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
```

在此示例中，两个 `if:` 子句都有效，因为 `production` 字符串用引号引起来了，而 CI/CD 变量没有用引号引起来。

另一方面，这些 `if:` 子句都是无效的：

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

- `if: ${ENVIRONMENT} == "production"` 无效，因为 `${ENVIRONMENT}` 不是 `if:` 中 CI/CD 变量的有效格式。
- `if: "$ENVIRONMENT" == "production"` 无效，因为变量用引号引起来了。
- `if: $ENVIRONMENT == production` 无效，因为字符串没有用引号引起来。
- `if: "production" == "production"` 无效，因为没有要比较的 CI/CD 变量。

<a id="get_sources-job-section-fails-because-of-an-http/2-problem"></a>

`get_sources` 作业部分因 HTTP/2 问题而失败

有时，作业会因以下 cURL 错误而失败：

```plaintext
++ git -c 'http.userAgent=gitlab-runner <version>' fetch origin +refs/pipelines/<id>:refs/pipelines/<id> ...
错误：RPC 失败；curl 16 HTTP/2 再次发送但长度减小
致命：...
```

您可以通过配置 Git 和 `libcurl` 来 [使用 HTTP/1.1](https://git-scm.com/docs/git-config#Documentation/git-config.txt-httpversion) 来解决此问题。

可以将配置添加到：

- 作业的 [`pre_get_sources_script`](../yaml/_index.md#hookspre_get_sources_script)：

  ```yaml
  job_name:
    hooks:
      pre_get_sources_script:
        - git config --global http.version "HTTP/1.1"
  ```

- Runner 的 [`config.toml`](https://gitlab.cn/docs/runner/configuration/advanced-configuration/) 以及 [Git 配置环境变量](https://git-scm.com/docs/git-config#ENVIRONMENT)：

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

使用 `resource_group` 的作业卡住

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

如果使用 [`resource_group`](../yaml/_index.md#resource_group) 的作业卡住，极狐GitLab 管理员可以尝试从 [Rails 控制台](../../administration/operations/rails_console.md#starting-a-rails-console-session) 运行以下命令：

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

<a id="you-are-not-authorized-to-run-this-manual-job-message"></a>

`您无权运行此手动作业` 消息

如果出现以下情况，您在尝试运行手动作业时可能会收到此消息，并且 **运行** 按钮被禁用：

- 目标环境是 [受保护的环境](../environments/protected_environments.md)，并且您的账户未包含在 **允许部署** 列表中。
- 启用了 [防止过时的部署作业](../environments/deployment_safety.md#prevent-outdated-deployment-jobs) 设置，并且运行该作业会覆盖最新的部署。