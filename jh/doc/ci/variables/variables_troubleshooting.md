---
stage: Verify
group: Pipeline Authoring
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 故障排除 CI/CD 变量
---

<a id="list-all-variables"></a>

## 列出所有变量

您可以使用 Bash 中的 `export` 命令或 PowerShell 中的 `dir env:` 列出脚本可用的所有变量。这会公开所有可用变量的值，可能带来[安全风险](_index.md#cicd-variable-security)。[掩码变量](_index.md#mask-a-cicd-variable)显示为 `[MASKED]`。

例如，使用 Bash：

```yaml
job_name:
  script:
    - export
```

作业日志输出示例（截断）：

```shell
export CI_JOB_ID="50"
export CI_COMMIT_SHA="1ecfd275763eff1d6b4844ea3168962458c9f27a"
export CI_COMMIT_SHORT_SHA="1ecfd275"
export CI_COMMIT_REF_NAME="main"
export CI_REPOSITORY_URL="https://gitlab-ci-token:[MASKED]@example.com/gitlab-org/gitlab.git"
export CI_COMMIT_TAG="1.0.0"
export CI_JOB_NAME="spec:other"
export CI_JOB_STAGE="test"
export CI_JOB_MANUAL="true"
export CI_JOB_TRIGGERED="true"
export CI_JOB_TOKEN="[MASKED]"
export CI_PIPELINE_ID="1000"
export CI_PIPELINE_IID="10"
export CI_PAGES_DOMAIN="gitlab.io"
export CI_PAGES_URL="https://gitlab-org.gitlab.io/gitlab"
export CI_PROJECT_ID="34"
export CI_PROJECT_DIR="/builds/gitlab-org/gitlab"
export CI_PROJECT_NAME="gitlab"
export CI_PROJECT_TITLE="GitLab"
...
```

<a id="enable-debug-logging"></a>

## 启用调试日志

> [!warning]
> 调试日志可能带来严重的安全风险。输出中包含作业可用的所有变量的内容。输出会上传到
> 极狐GitLab 服务器，并可在作业日志中查看。

您可以使用调试日志来帮助排查流水线配置或作业脚本的问题。调试日志会公开通常被 Runner 隐藏的作业执行详情，使作业日志更加详细。它还会公开作业可用的所有变量和密钥。

在启用调试日志之前，请确保只有团队成员可以查看作业日志。在再次公开日志之前，您还应[删除包含调试输出的作业日志](../jobs/_index.md#view-jobs-in-a-pipeline)。

要启用调试日志，请将 `CI_DEBUG_TRACE` 变量设置为 `true`：

```yaml
job_name:
  variables:
    CI_DEBUG_TRACE: "true"
```

输出示例（截断）：

```plaintext
...
export CI_SERVER_TLS_CA_FILE="/builds/gitlab-examples/ci-debug-trace.tmp/CI_SERVER_TLS_CA_FILE"
if [[ -d "/builds/gitlab-examples/ci-debug-trace/.git" ]]; then
  echo $'\''\x1b[32;1mFetching changes...\x1b[0;m'\''
  $'\''cd'\'' "/builds/gitlab-examples/ci-debug-trace"
  $'\''git'\'' "config" "fetch.recurseSubmodules" "false"
  $'\''rm'\'' "-f" ".git/index.lock"
  $'\''git'\'' "clean" "-ffdx"
  $'\''git'\'' "reset" "--hard"
  $'\''git'\'' "remote" "set-url" "origin" "https://gitlab-ci-token:xxxxxxxxxxxxxxxxxxxx@example.com/gitlab-examples/ci-debug-trace.git"
  $'\''git'\'' "fetch" "origin" "--prune" "+refs/heads/*:refs/remotes/origin/*" "+refs/tags/*:refs/tags/lds"
++ CI_BUILDS_DIR=/builds
++ export CI_PROJECT_DIR=/builds/gitlab-examples/ci-debug-trace
++ CI_PROJECT_DIR=/builds/gitlab-examples/ci-debug-trace
++ export CI_CONCURRENT_ID=87
++ CI_CONCURRENT_ID=87
++ export CI_CONCURRENT_PROJECT_ID=0
++ CI_CONCURRENT_PROJECT_ID=0
++ export CI_SERVER=yes
++ CI_SERVER=yes
++ mkdir -p /builds/gitlab-examples/ci-debug-trace.tmp
++ echo -n '-----BEGIN CERTIFICATE-----
-----END CERTIFICATE-----'
++ export CI_SERVER_TLS_CA_FILE=/builds/gitlab-examples/ci-debug-trace.tmp/CI_SERVER_TLS_CA_FILE
++ CI_SERVER_TLS_CA_FILE=/builds/gitlab-examples/ci-debug-trace.tmp/CI_SERVER_TLS_CA_FILE
++ export CI_PIPELINE_ID=52666
++ CI_PIPELINE_ID=52666
++ export CI_PIPELINE_URL=https://gitlab.com/gitlab-examples/ci-debug-trace/pipelines/52666
++ CI_PIPELINE_URL=https://gitlab.com/gitlab-examples/ci-debug-trace/pipelines/52666
++ export CI_JOB_ID=7046507
++ CI_JOB_ID=7046507
++ export CI_JOB_URL=https://gitlab.com/gitlab-examples/ci-debug-trace/-/jobs/379424655
++ CI_JOB_URL=https://gitlab.com/gitlab-examples/ci-debug-trace/-/jobs/379424655
++ export CI_JOB_TOKEN=[MASKED]
++ CI_JOB_TOKEN=[MASKED]
++ export CI_REGISTRY_USER=gitlab-ci-token
++ CI_REGISTRY_USER=gitlab-ci-token
++ export CI_REGISTRY_PASSWORD=[MASKED]
++ CI_REGISTRY_PASSWORD=[MASKED]
++ export CI_REPOSITORY_URL=https://gitlab-ci-token:[MASKED]@gitlab.com/gitlab-examples/ci-debug-trace.git
++ CI_REPOSITORY_URL=https://gitlab-ci-token:[MASKED]@gitlab.com/gitlab-examples/ci-debug-trace.git
++ export CI_JOB_NAME=debug_trace
++ CI_JOB_NAME=debug_trace
++ export CI_JOB_STAGE=test
++ CI_JOB_STAGE=test
++ export CI_NODE_TOTAL=1
++ CI_NODE_TOTAL=1
++ export CI=true
++ CI=true
++ export GITLAB_CI=true
++ GITLAB_CI=true
++ export CI_SERVER_URL=https://gitlab.com:3000
++ CI_SERVER_URL=https://gitlab.com:3000
++ export CI_SERVER_HOST=gitlab.com
++ CI_SERVER_HOST=gitlab.com
++ export CI_SERVER_PORT=3000
++ CI_SERVER_PORT=3000
++ export CI_SERVER_SHELL_SSH_HOST=gitlab.com
++ CI_SERVER_SHELL_SSH_HOST=gitlab.com
++ export CI_SERVER_SHELL_SSH_PORT=22
++ CI_SERVER_SHELL_SSH_PORT=22
++ export CI_SERVER_PROTOCOL=https
++ CI_SERVER_PROTOCOL=https
++ export CI_SERVER_NAME=GitLab
++ CI_SERVER_NAME=GitLab
++ export GITLAB_FEATURES=audit_events,burndown_charts,code_owners,contribution_analytics,description_diffs,elastic_search,group_bulk_edit,group_burndown_charts,group_webhooks,issuable_default_templates,issue_weights,jenkins_integration,ldap_group_sync,member_lock,merge_request_approvers,multiple_issue_assignees,multiple_ldap_servers,multiple_merge_request_assignees,protected_refs_for_users,push_rules,related_issues,repository_mirrors,repository_size_limit,scoped_issue_board,usage_quotas,wip_limits,admin_audit_log,auditor_user,batch_comments,blocking_merge_requests,board_assignee_lists,board_milestone_lists,ci_cd_projects,cluster_deployments,code_analytics,code_owner_approval_required,commit_committer_check,cross_project_pipelines,custom_file_templates,custom_file_templates_for_namespace,custom_project_templates,custom_prometheus_metrics,cycle_analytics_for_groups,db_load_balancing,default_project_deletion_protection,dependency_proxy,deploy_board,design_management,email_additional_text,extended_audit_events,external_authorization_service_api_management,feature_flags,file_locks,geo,github_integration,group_allowed_email_domains,group_project_templates,group_saml,issues_analytics,jira_dev_panel_integration,ldap_group_sync_filter,merge_pipelines,merge_request_performance_metrics,merge_trains,metrics_reports,multiple_approval_rules,multiple_group_issue_boards,object_storage,operations_dashboard,packages,productivity_analytics,project_aliases,protected_environments,reject_unsigned_commits,required_ci_templates,scoped_labels,service_desk,smartcard_auth,group_timelogs,type_of_work_analytics,unprotection_restrictions,ci_project_subscriptions,container_scanning,dast,dependency_scanning,epics,group_ip_restriction,incident_management,insights,license_management,personal_access_token_expiration_policy,pod_logs,prometheus_alerts,report_approver_rules,sast,security_dashboard,tracing,web_ide_terminal
++ GITLAB_FEATURES=audit_events,burndown_charts,code_owners,contribution_analytics,description_diffs,elastic_search,group_bulk_edit,group_burndown_charts,group_webhooks,issuable_default_templates,issue_weights,jenkins_integration,ldap_group_sync,member_lock,merge_request_approvers,multiple_issue_assignees,multiple_ldap_servers,multiple_merge_request_assignees,protected_refs_for_users,push_rules,related_issues,repository_mirrors,repository_size_limit,scoped_issue_board,usage_quotas,wip_limits,admin_audit_log,auditor_user,batch_comments,blocking_merge_requests,board_assignee_lists,board_milestone_lists,ci_cd_projects,cluster_deployments,code_analytics,code_owner_approval_required,commit_committer_check,cross_project_pipelines,custom_file_templates,custom_file_templates_for_namespace,custom_project_templates,custom_prometheus_metrics,cycle_analytics_for_groups,db_load_balancing,default_project_deletion_protection,dependency_proxy,deploy_board,design_management,email_additional_text,extended_audit_events,external_authorization_service_api_management,feature_flags,file_locks,geo,github_integration,group_allowed_email_domains,group_project_templates,group_saml,issues_analytics,jira_dev_panel_integration,ldap_group_sync_filter,merge_pipelines,merge_request_performance_metrics,merge_trains,metrics_reports,multiple_approval_rules,multiple_group_issue_boards,object_storage,operations_dashboard,packages,productivity_analytics,project_aliases,protected_environments,reject_unsigned_commits,required_ci_templates,scoped_labels,service_desk,smartcard_auth,group_timelogs,type_of_work_analytics,unprotection_restrictions,ci_project_subscriptions,cluster_health,container_scanning,dast,dependency_scanning,epics,group_ip_restriction,incident_management,insights,license_management,personal_access_token_expiration_policy,pod_logs,prometheus_alerts,report_approver_rules,sast,security_dashboard,tracing,web_ide_terminal
++ export CI_PROJECT_ID=17893
++ CI_PROJECT_ID=17893
++ export CI_PROJECT_NAME=ci-debug-trace
++ CI_PROJECT_NAME=ci-debug-trace
...
```

<a id="access-to-debug-logging"></a>

### 调试日志的访问权限

调试日志的访问权限仅限于[具有开发者、维护者或所有者角色的用户](../../user/permissions.md#project-cicd)。当通过以下位置的变量启用调试日志时，角色较低的用户无法看到日志：

- [`.gitlab-ci.yml` 文件](_index.md#define-a-cicd-variable-in-the-gitlab-ciyml-file)。
- 在极狐GitLab UI 中设置的 CI/CD 变量。

> [!warning]
> 如果您将 `CI_DEBUG_TRACE` 作为本地变量添加到 Runner，则会生成调试日志，并且所有有权访问作业日志的用户都可以看到。Runner 不会检查权限级别，
> 因此您只应在极狐GitLab 本身中使用该变量。

<a id="argument-list-too-long-error"></a>

## `argument list too long` 错误

当为作业定义的所有 CI/CD 变量的总长度超过作业执行所在 shell 施加的限制时，会出现此问题。这包括预定义变量和用户定义变量的名称和值。此限制通常称为 `ARG_MAX`，具体取决于 shell 和操作系统。当单个[文件类型](_index.md#use-file-type-cicd-variables)变量的内容超过 `ARG_MAX` 时，也会出现此问题。

更多信息，请参见[议题 392406](https://gitlab.com/gitlab-org/gitlab/-/issues/392406#note_1414219596)。

作为变通方法，您可以：

- 尽可能对大型环境变量使用[文件类型](_index.md#use-file-type-cicd-variables) CI/CD 变量。
- 如果单个大型变量大于 `ARG_MAX`，请尝试使用[安全文件](../secure_files/_index.md)，或
  通过其他机制将该文件引入作业。

<a id="insufficient-permissions-to-set-pipeline-variables-error-for-a-downstream-pipeline"></a>

## 下游流水线出现 `Insufficient permissions to set pipeline variables` 错误

触发下游流水线时，您可能会意外遇到此错误：

```plaintext
Failed - (downstream pipeline can not be created, Insufficient permissions to set pipeline variables)
```

当下游项目[限制了流水线变量](_index.md#restrict-pipeline-variables)，且触发作业满足以下任一条件时，会出现此错误：

- 定义了变量。例如：

  ```yaml
  trigger-job:
    variables:
      VAR_FOR_DOWNSTREAM: "test"
    trigger: my-group/my-project
  ```

- 从顶层 `variables` 部分定义的[默认变量](../yaml/_index.md#default-variables)接收变量。例如：

  ```yaml
  variables:
    DEFAULT_VAR: "test"

  trigger-job:
    trigger: my-group/my-project
  ```

在触发作业中传递给下游流水线的变量属于[流水线变量](_index.md#use-pipeline-variables)，因此变通方法是：

- 移除触发作业中定义的 `variables`，以避免传递变量。
- [阻止默认变量传递到下游流水线](../pipelines/downstream_pipelines.md#prevent-default-variables-from-being-passed)。

<a id="default-variable-doesnt-expand-in-job-variable-of-the-same-name"></a>

## 默认变量不会在同名作业变量中展开

您无法在同名作业变量中使用默认变量的值。只有当作业未定义同名变量时，默认变量才会提供给该作业。如果作业定义了同名变量，则作业的变量优先，默认变量在该作业中不可用。

例如，以下两个示例是等效的：

- 在此示例中，`$MY_VAR` 没有值，因为它未在任何位置定义：

  ```yaml
  Job-with-variable:
    variables:
      MY_VAR: $MY_VAR
    script: echo "Value is '$MY_VAR'"
  ```

- 在此示例中，`$MY_VAR` 没有值，因为同名默认变量
  在该作业中不可用：

  ```yaml
  variables:
    MY_VAR: "Default value"

  Job-with-same-name-variable:
    variables:
      MY_VAR: $MY_VAR
    script: echo "Value is '$MY_VAR'"
  ```

在这两种情况下，echo 命令都会输出 `Value is '$MY_VAR'`。

通常，您应直接在作业中使用默认变量，而不是将其值重新赋给新变量。如果您需要这样做，请改用名称不同的变量。例如：

```yaml
variables:
  MY_VAR1: "Default value1"
  MY_VAR2: "Default value2"

overwrite-same-name:
  variables:
    MY_VAR2_FROM_DEFAULTS: $MY_VAR2
  script: echo "Values are '$MY_VAR1' and '$MY_VAR2_FROM_DEFAULTS'"
```
