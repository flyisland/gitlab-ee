---
stage: Verify
group: Pipeline Authoring
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 极狐GitLab CI/CD 流水线中可用的预定义 CI/CD 变量。
title: 预定义 CI/CD 变量参考
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

预定义的 [CI/CD 变量](_index.md) 在每个极狐GitLab CI/CD 流水线中都可用。

避免[覆盖](_index.md#use-pipeline-variables)预定义变量，
因为这可能导致流水线出现意外行为。

<a id="variable-availability"></a>

## 变量可用性

预定义变量在流水线执行的三个阶段可用：

- 流水线前：流水线前变量在流水线创建之前可用。
  这些变量是唯一可以与 [`include:rules`](../yaml/_index.md#includerules) 一起使用的变量，
  用于控制在创建流水线时使用哪些配置文件。
- 流水线：当极狐GitLab 正在创建流水线时，流水线变量变为可用。
  与流水线前变量一起，流水线变量可用于配置
  作业中定义的 [`rules`](../yaml/_index.md#rules)，以确定将哪些作业添加到流水线。
- 仅作业：这些变量仅在 Runner 获取并运行作业时对每个作业可用，并且：
  - 可以在作业脚本中使用。
  - 不能与[触发作业](../pipelines/downstream_pipelines.md#trigger-a-downstream-pipeline-from-a-job-in-the-gitlab-ciyml-file)一起使用。
  - 不能与 [`workflow`](../yaml/_index.md#workflow)、[`include`](../yaml/_index.md#include)
    或 [`rules`](../yaml/_index.md#rules) 一起使用。

<a id="predefined-variables"></a>

## 预定义变量

| 变量                                        | 可用性 | 描述 |
|-------------------------------------------------|--------------|-------------|
| `CHAT_CHANNEL`                                  | 流水线     | 触发 [ChatOps](../chatops/_index.md) 命令的 Source 聊天频道。 |
| `CHAT_INPUT`                                    | 流水线     | 与 [ChatOps](../chatops/_index.md) 命令一起传递的附加参数。 |
| `CHAT_USER_ID`                                  | 流水线     | 触发 [ChatOps](../chatops/_index.md) 命令的用户在聊天服务中的用户 ID。 |
| `CI`                                            | 流水线前 | 可用于 CI/CD 中执行的所有作业。可用时为 `true`。 |
| `CI_API_V4_URL`                                 | 流水线前 | 极狐GitLab API v4 根 URL。 |
| `CI_API_GRAPHQL_URL`                            | 流水线前 | 极狐GitLab API GraphQL 根 URL。 |
| `CI_BUILD_NETWORK_NAME`                         | 仅作业     | 作业创建的网络名称。仅在启用 [`FF_NETWORK_PER_BUILD`](https://gitlab.cn/docs/runner/configuration/feature-flags/#available-feature-flags) 时，使用 Docker 执行器才可用。 |
| `CI_BUILDS_DIR`                                 | 仅作业     | 执行构建的顶级目录。 |
| `CI_COMMIT_AUTHOR`                              | 流水线前 | 采用 `Name <email>` 格式的提交作者。 |
| `CI_COMMIT_BEFORE_SHA`                          | 流水线前 | 分支或标签上先前的最近提交。对于合并请求流水线、计划流水线、分支或标签的流水线中的首次提交，或手动运行流水线时，它始终是 `0000000000000000000000000000000000000000`。 |
| `CI_COMMIT_BRANCH`                              | 流水线前 | 提交分支名称。在分支流水线中可用，包括默认分支的流水线。在合并请求流水线或标签流水线中不可用。 |
| `CI_COMMIT_DEFAULT_BRANCH_BASE_SHA`             | 流水线前 | `CI_COMMIT_SHA` 与默认分支之间的合并基础。仅在非默认分支流水线中可用。在极狐GitLab 19.1 中引入。 |
| `CI_COMMIT_DESCRIPTION`                         | 流水线前 | 提交的描述。如果标题短于 100 个字符，则描述是不含第一行的消息。 |
| `CI_COMMIT_MESSAGE`                             | 流水线前 | 完整的提交消息。 |
| `CI_COMMIT_MESSAGE_IS_TRUNCATED`                | 流水线前 | 如果 `CI_COMMIT_MESSAGE` 因提交消息过长而被截断到 `GITLAB_CI_MAX_COMMIT_MESSAGE_SIZE_IN_BYTES` 系统环境变量（默认 100 KB）指定的大小，则为 `true`。否则为 `false`。在极狐GitLab 18.6 中引入。 |
| `CI_COMMIT_REF_NAME`                            | 流水线前 | 构建项目的分支或标签名称。 |
| `CI_COMMIT_REF_PROTECTED`                       | 流水线前 | 如果作业正在为受保护的引用运行，则为 `true`，否则为 `false`。 |
| `CI_COMMIT_REF_SLUG`                            | 流水线前 | `CI_COMMIT_REF_NAME` 的小写形式，缩短为 63 字节，并将除 `0-9` 和 `a-z` 之外的所有内容替换为 `-`。无前导/尾随 `-`。用于 URL、主机名和域名。 |
| `CI_COMMIT_SHA`                                 | 流水线前 | 构建项目所针对的提交修订版本。 |
| `CI_COMMIT_SHORT_SHA`                           | 流水线前 | `CI_COMMIT_SHA` 的前八个字符。 |
| `CI_COMMIT_TAG`                                 | 流水线前 | 提交标签名称。仅在标签的流水线中可用。 |
| `CI_COMMIT_TAG_MESSAGE`                         | 流水线前 | 提交标签消息。仅在标签的流水线中可用。 |
| `CI_COMMIT_TIMESTAMP`                           | 流水线前 | 采用 [ISO 8601](https://www.rfc-editor.org/rfc/rfc3339#appendix-A) 格式的提交时间戳。例如，`2022-01-31T16:47:55Z`。[默认使用 UTC](../../administration/timezone.md)。 |
| `CI_COMMIT_TITLE`                               | 流水线前 | 提交的标题。消息的完整第一行。 |
| `CI_COMMIT_USER_LOGIN`                          | 流水线前 | 如果提交作者的个人资料和电子邮件是公开的并且与提交电子邮件匹配，则为提交作者的极狐GitLab 用户名，否则为空字符串。在极狐GitLab 18.10 中引入。 |
| `CI_CONCURRENT_ID`                              | 仅作业     | 单个执行器中构建执行的唯一 ID。 |
| `CI_CONCURRENT_PROJECT_ID`                      | 仅作业     | 单个执行器和项目中构建执行的唯一 ID。 |
| `CI_CONFIG_PATH`                                | 流水线前 | CI/CD 配置文件的路径。默认为 `.gitlab-ci.yml`。 |
| `CI_CONFIG_REF_URI`                             | 流水线     | 顶级流水线定义的完整限定引用路径，例如 `gitlab.example.com/my-group/my-project//.gitlab-ci.yml@refs/heads/main`。当无法确定流水线源引用时不可用。[在极狐GitLab 19.0 中引入](https://gitlab.com/gitlab-org/gitlab/-/work_items/593105)。 |
| `CI_DEBUG_TRACE`                                | 流水线     | 如果启用了[调试日志（跟踪）](variables_troubleshooting.md#enable-debug-logging)，则为 `true`。 |
| `CI_DEBUG_SERVICES`                             | 流水线     | 如果启用了[服务容器日志](../services/_index.md#capturing-service-container-logs)，则为 `true`。 |
| `CI_DEFAULT_BRANCH`                             | 流水线前 | 项目默认分支的名称。 |
| `CI_DEFAULT_BRANCH_SLUG`                        | 流水线前 | `CI_DEFAULT_BRANCH` 的小写形式，缩短为 63 字节，并将除 `0-9` 和 `a-z` 之外的所有内容替换为 `-`。无前导/尾随 `-`。用于 URL、主机名和域名。 |
| `CI_DEPENDENCY_PROXY_DIRECT_GROUP_IMAGE_PREFIX` | 流水线前 | 通过依赖代理拉取镜像的直接群组镜像前缀。 |
| `CI_DEPENDENCY_PROXY_GROUP_IMAGE_PREFIX`        | 流水线前 | 通过依赖代理拉取镜像的顶级群组镜像前缀。 |
| `CI_DEPENDENCY_PROXY_PASSWORD`                  | 流水线     | 通过依赖代理拉取镜像的密码。 |
| `CI_DEPENDENCY_PROXY_SERVER`                    | 流水线前 | 用于登录依赖代理的服务器。此变量等同于 `$CI_SERVER_HOST:$CI_SERVER_PORT`。 |
| `CI_DEPENDENCY_PROXY_USER`                      | 流水线     | 通过依赖代理拉取镜像的用户名。 |
| `CI_DEPLOY_FREEZE`                              | 流水线前 | 仅在流水线在[部署冻结窗口](../../user/project/releases/_index.md#prevent-unintentional-releases-by-setting-a-deploy-freeze)期间运行时可用。可用时为 `true`。 |
| `CI_DEPLOY_PASSWORD`                            | 仅作业     | 如果项目有 [极狐GitLab 部署令牌](../../user/project/deploy_tokens/_index.md#gitlab-deploy-token)，则为该令牌的认证密码。 |
| `CI_DEPLOY_USER`                                | 仅作业     | 如果项目有 [极狐GitLab 部署令牌](../../user/project/deploy_tokens/_index.md#gitlab-deploy-token)，则为该令牌的认证用户名。 |
| `CI_DISPOSABLE_ENVIRONMENT`                     | 流水线     | 仅在作业在一次性环境中执行时可用（该环境仅为该作业创建并在执行后处理/销毁 - 除 `shell` 和 `ssh` 之外的所有执行器）。可用时为 `true`。 |
| `CI_ENVIRONMENT_ID`                             | 流水线     | 此作业的环境 ID。如果设置了 [`environment:name`](../yaml/_index.md#environmentname)，则可用。 |
| `CI_ENVIRONMENT_NAME`                           | 流水线     | 此作业的环境名称。如果设置了 [`environment:name`](../yaml/_index.md#environmentname)，则可用。 |
| `CI_ENVIRONMENT_SLUG`                           | 流水线     | 环境名称的简化版本，适用于 DNS、URL 和 Kubernetes 标签。如果设置了 [`environment:name`](../yaml/_index.md#environmentname)，则可用。该 slug 被[截断为 24 个字符](https://gitlab.com/gitlab-org/gitlab/-/issues/20941)。对于[大写环境名称](https://gitlab.com/gitlab-org/gitlab/-/issues/415526)，会自动添加随机后缀。 |
| `CI_ENVIRONMENT_URL`                            | 流水线     | 此作业的环境 URL。如果设置了 [`environment:url`](../yaml/_index.md#environmenturl)，则可用。 |
| `CI_ENVIRONMENT_ACTION`                         | 流水线     | 为此作业的环境指定的操作注解。如果设置了 [`environment:action`](../yaml/_index.md#environmentaction)，则可用。可以是 `start`、`prepare` 或 `stop`。 |
| `CI_ENVIRONMENT_TIER`                           | 流水线     | 此作业的[环境部署层级](../environments/_index.md#deployment-tier-of-environments)。 |
| `CI_GITLAB_FIPS_MODE`                           | 流水线前 | 仅在极狐GitLab 实例中启用了 [FIPS 模式](../../development/fips_gitlab.md) 时可用。可用时为 `true`。 |
| `CI_HAS_OPEN_REQUIREMENTS`                      | 流水线     | 仅当流水线的项目有开放的[需求](../../user/project/requirements/_index.md)时可用。可用时为 `true`。 |
| `CI_JOB_GROUP_NAME`                             | 流水线     | 使用 [`parallel`](../yaml/_index.md#parallel) 或[手动分组作业](../jobs/_index.md#group-similar-jobs-together-in-pipeline-views)时，一组作业的共享名称。例如，如果作业名称为 `rspec:test: [ruby, ubuntu]`，则 `CI_JOB_GROUP_NAME` 为 `rspec:test`。否则与 `CI_JOB_NAME` 相同。在极狐GitLab 17.10 中引入。 |
| `CI_JOB_ID`                                     | 仅作业     | 作业的内部 ID，在极狐GitLab 实例中的所有作业中唯一。 |
| `CI_JOB_IMAGE`                                  | 仅作业     | 运行作业的 Docker 镜像名称。仅在作业明确指定 Docker 镜像时可用。 |
| `CI_JOB_MANUAL`                                 | 流水线     | 仅在作业是手动启动时可用。可用时为 `true`。 |
| `CI_JOB_NAME`                                   | 流水线     | 作业的名称。 |
| `CI_JOB_NAME_SLUG`                              | 流水线     | `CI_JOB_NAME` 的小写形式，缩短为 63 字节，并将除 `0-9` 和 `a-z` 之外的所有内容替换为 `-`。无前导/尾随 `-`。用于路径。 |
| `CI_JOB_RETRY_COUNT`                            | 仅作业     | 作业在当前流水线中被重试的次数。首次运行时为 `0`，每次重试增加一。在极狐GitLab 19.3 中引入。 |
| `CI_JOB_STAGE`                                  | 流水线     | 作业阶段的名称。 |
| `CI_JOB_STATUS`                                 | 仅作业     | 每个 Runner 阶段执行时作业的状态。与 [`after_script`](../yaml/_index.md#after_script) 一起使用。可以是 `success`、`failed` 或 `canceled`。 |
| `CI_JOB_TAGS`                                   | 仅作业     | 作业的 [Runner 标签](../yaml/_index.md#tags) 的 JSON 数组。例如 `["tag_1", "tag_2"]`。在极狐GitLab 19.3 中引入。 |
| `CI_JOB_TIMEOUT`                                | 仅作业     | 作业超时时间，以秒为单位。 |
| `CI_JOB_TOKEN`                                  | 仅作业     | 用于向[某些 API 端点](../jobs/ci_job_token.md)进行身份验证的令牌。该令牌在作业运行期间有效。 |
| `CI_JOB_URL`                                    | 仅作业     | 作业详情 URL。 |
| `CI_JOB_STARTED_AT`                             | 仅作业     | 作业开始的日期和时间，采用 [ISO 8601](https://www.rfc-editor.org/rfc/rfc3339#appendix-A) 格式。例如，`2022-01-31T16:47:55Z`。[默认使用 UTC](../../administration/timezone.md)。 |
| `CI_JOB_STARTED_AT_SLUG`                        | 仅作业     | `CI_JOB_STARTED_AT` 的小写形式，缩短为 63 字节，并将除 `0-9` 和 `a-z` 之外的所有内容替换为 `-`。无前导/尾随 `-`。适用于 Docker 镜像标签和其他标识符。在极狐GitLab 18.7 中引入。 |
| `CI_KUBERNETES_ACTIVE`                          | 流水线前 | 仅当流水线有可用于部署的 Kubernetes 集群时可用。可用时为 `true`。 |
| `CI_NODE_INDEX`                                 | 流水线     | 作业在作业集中的索引。仅当作业使用 [`parallel`](../yaml/_index.md#parallel) 时可用。 |
| `CI_NODE_TOTAL`                                 | 流水线     | 并行运行的此作业实例的总数。如果作业不使用 [`parallel`](../yaml/_index.md#parallel)，则设置为 `1`。 |
| `CI_OPEN_MERGE_REQUESTS`                        | 流水线前 | 使用当前分支和项目作为合并请求来源的最多四个合并请求的逗号分隔列表。仅当分支有关联的合并请求时，在分支和合并请求流水线中可用。例如，`gitlab-org/gitlab!333,gitlab-org/gitlab-foss!11`。 |
| `CI_PAGES_DOMAIN`                               | 流水线前 | 托管 GitLab Pages 的实例域名，不包括命名空间子域。要使用完整主机名，请改用 `CI_PAGES_HOSTNAME`。 |
| `CI_PAGES_HOSTNAME`                             | 仅作业     | Pages 部署的完整主机名。 |
| `CI_PAGES_URL`                                  | 仅作业     | GitLab Pages 站点的 URL。始终是 `CI_PAGES_DOMAIN` 的子域。在极狐GitLab 17.9 及更高版本中，当指定了 `path_prefix` 时，该值包含它。 |
| `CI_PIPELINE_ID`                                | 仅作业     | 当前流水线的 ID。此 ID 在极狐GitLab 实例上的所有项目中唯一。 |
| `CI_PIPELINE_IID`                               | 流水线     | 当前流水线的 IID（内部 ID）。此 ID 仅在当前项目中唯一。 |
| `CI_PIPELINE_SOURCE`                            | 流水线前 | 流水线是如何触发的。该值可以是[流水线来源](../jobs/job_rules.md#ci_pipeline_source-predefined-variable)之一。 |
| `CI_PIPELINE_TRIGGERED`                         | 流水线     | 对于[使用触发器令牌触发的](../triggers/_index.md) 流水线，为 `true`。对于使用 [`trigger`](../yaml/_index.md#trigger) 关键字触发的流水线，请改用 [`CI_PIPELINE_SOURCE`](../jobs/job_rules.md#ci_pipeline_source-predefined-variable)。 |
| `CI_PIPELINE_URL`                               | 仅作业     | 流水线详情的 URL。 |
| `CI_PIPELINE_CREATED_AT`                        | 仅作业     | 流水线创建的日期和时间，采用 [ISO 8601](https://www.rfc-editor.org/rfc/rfc3339#appendix-A) 格式。例如，`2022-01-31T16:47:55Z`。[默认使用 UTC](../../administration/timezone.md)。 |
| `CI_PIPELINE_NAME`                              | 流水线前 | 在 [`workflow:name`](../yaml/_index.md#workflowname) 中定义的流水线名称。 |
| `CI_PIPELINE_SCHEDULE_DESCRIPTION`              | 流水线前 | 流水线计划的描述。仅在计划流水线中可用。在极狐GitLab 17.8 中引入。 |
| `CI_PROJECT_DIR`                                | 仅作业     | 代码仓库被克隆到的完整路径，以及作业运行的目录。如果设置了极狐GitLab Runner `builds_dir` 参数，则此变量相对于 `builds_dir` 的值设置。有关更多信息，请参阅[高级极狐GitLab Runner 配置](https://gitlab.cn/docs/runner/configuration/advanced-configuration/#the-runners-section)。 |
| `CI_PROJECT_ID`                                 | 流水线前 | 当前项目的 ID。此 ID 在极狐GitLab 实例上的所有项目中唯一。 |
| `CI_PROJECT_NAME`                               | 流水线前 | 项目目录的名称。例如，如果项目 URL 是 `gitlab.example.com/group-name/project-1`，则 `CI_PROJECT_NAME` 为 `project-1`。 |
| `CI_PROJECT_NAMESPACE`                          | 流水线前 | 作业的项目命名空间（用户名或群组名称）。 |
| `CI_PROJECT_NAMESPACE_ID`                       | 流水线前 | 作业的项目命名空间 ID。 |
| `CI_PROJECT_NAMESPACE_SLUG`                     | 流水线前 | `$CI_PROJECT_NAMESPACE` 的小写形式，缩短为 63 字节，并将除 `0-9` 和 `a-z` 之外的所有内容替换为 `-`。无前导/尾随 `-`。 |
| `CI_PROJECT_PATH_SLUG`                          | 流水线前 | `$CI_PROJECT_PATH` 的小写形式，缩短为 63 字节，并将除 `0-9` 和 `a-z` 之外的所有内容替换为 `-`。无前导/尾随 `-`。用于 URL 和域名。 |
| `CI_PROJECT_PATH`                               | 流水线前 | 包含项目名称的项目命名空间。 |
| `CI_PROJECT_REPOSITORY_LANGUAGES`               | 流水线前 | 代码仓库中使用语言的逗号分隔小写列表。例如 `ruby,javascript,html,css`。语言的最大数量限制为 5 种。有一个议题[提议增加此限制](https://gitlab.com/gitlab-org/gitlab/-/issues/368925)。 |
| `CI_PROJECT_ROOT_NAMESPACE`                     | 流水线前 | 作业的根项目命名空间（用户名或群组名称）。例如，如果 `CI_PROJECT_NAMESPACE` 是 `root-group/child-group/grandchild-group`，则 `CI_PROJECT_ROOT_NAMESPACE` 是 `root-group`。 |
| `CI_PROJECT_ROOT_NAMESPACE_SLUG`                | 流水线前 | `$CI_PROJECT_ROOT_NAMESPACE` 的小写形式，缩短为 63 字节，并将除 `0-9` 和 `a-z` 之外的所有内容替换为 `-`。无前导/尾随 `-`。在极狐GitLab 19.0 中引入。 |
| `CI_PROJECT_TITLE`                              | 流水线前 | 极狐GitLab Web 界面中显示的人类可读项目名称。 |
| `CI_PROJECT_DESCRIPTION`                        | 流水线前 | 极狐GitLab Web 界面中显示的项目描述。 |
| `CI_PROJECT_TOPICS`                             | 流水线前 | 分配给项目的[主题](../../user/project/project_topics.md)（限制为前 20 个）的逗号分隔小写列表。在极狐GitLab 18.3 中引入 |
| `CI_PROJECT_URL`                                | 流水线前 | 项目的 HTTP(S) 地址。 |
| `CI_PROJECT_VISIBILITY`                         | 流水线前 | 项目可见性。可以是 `internal`、`private` 或 `public`。 |
| `CI_PROJECT_CLASSIFICATION_LABEL`               | 流水线前 | 项目的[外部授权分类标签](../../administration/settings/external_authorization.md)。 |
| `CI_REGISTRY`                                   | 流水线前 | [容器镜像仓库](../../user/packages/container_registry/_index.md)服务器的地址，格式为 `<host>[:<port>]`。例如：`registry.gitlab.example.com`。仅当为极狐GitLab 实例启用了容器镜像仓库时可用。 |
| `CI_REGISTRY_IMAGE`                             | 流水线前 | 用于推送、拉取或标记项目镜像的容器镜像仓库的基础地址，格式为 `<host>[:<port>]/<project_full_path>`。例如：`registry.gitlab.example.com/my_group/my_project`。镜像名称必须遵循[容器镜像仓库命名约定](../../user/packages/container_registry/_index.md#naming-convention-for-your-container-images)。仅当为项目启用了容器镜像仓库时可用。 |
| `CI_REGISTRY_PASSWORD`                          | 仅作业     | 将容器推送到极狐GitLab 项目容器镜像仓库的密码。仅当为项目启用了容器镜像仓库时可用。此密码值与 `CI_JOB_TOKEN` 相同，并且仅在作业运行期间有效。如需对镜像仓库进行长期访问，请使用 `CI_DEPLOY_PASSWORD` |
| `CI_REGISTRY_USER`                              | 仅作业     | 将容器推送到项目极狐GitLab 容器镜像仓库的用户名。仅当为项目启用了容器镜像仓库时可用。 |
| `CI_RELEASE_DESCRIPTION`                        | 流水线     | 发布的描述。仅在标签的流水线中可用。描述长度限制为前 1024 个字符。 |
| `CI_REPOSITORY_URL`                             | 仅作业     | 使用 [CI/CD 作业令牌](../jobs/ci_job_token.md) 通过 HTTP 克隆代码仓库的完整路径，格式为 `https://gitlab-ci-token:$CI_JOB_TOKEN@gitlab.example.com/my-group/my-project.git`。 |
| `CI_RUNNER_DESCRIPTION`                         | 仅作业     | Runner 的描述。 |
| `CI_RUNNER_EXECUTABLE_ARCH`                     | 仅作业     | 极狐GitLab Runner 可执行文件的操作系统/架构。可能与执行器的环境不同。 |
| `CI_RUNNER_ID`                                  | 仅作业     | 正在使用的 Runner 的唯一 ID。 |
| `CI_RUNNER_REVISION`                            | 仅作业     | 运行作业的 Runner 的修订版本。 |
| `CI_RUNNER_SHORT_TOKEN`                         | 仅作业     | Runner 的唯一 ID，用于认证新的作业请求。该令牌包含一个前缀，并使用前 17 个字符。 |
| `CI_RUNNER_TAGS`                                | 仅作业     | 获取作业的 Runner 上配置的 Runner 标签的 JSON 数组。例如 `["tag_1", "tag_2"]`。 |
| `CI_RUNNER_VERSION`                             | 仅作业     | 运行作业的极狐GitLab Runner 的版本。 |
| `CI_SERVER_FQDN`                                | 流水线前 | 实例的完全限定域名（FQDN）。例如 `gitlab.example.com:8080`。 |
| `CI_SERVER_HOST`                                | 流水线前 | 极狐GitLab 实例 URL 的主机，不含协议或端口。例如 `gitlab.example.com`。 |
| `CI_SERVER_NAME`                                | 流水线前 | 协调作业的 CI/CD 服务器名称。 |
| `CI_SERVER_PORT`                                | 流水线前 | 极狐GitLab 实例 URL 的端口，不含主机或协议。例如 `8080`。 |
| `CI_SERVER_PROTOCOL`                            | 流水线前 | 极狐GitLab 实例 URL 的协议，不含主机或端口。例如 `https`。 |
| `CI_SERVER_SHELL_SSH_HOST`                      | 流水线前 | 极狐GitLab 实例的 SSH 主机，用于通过 SSH 访问 Git 代码仓库。例如 `gitlab.com`。 |
| `CI_SERVER_SHELL_SSH_PORT`                      | 流水线前 | 极狐GitLab 实例的 SSH 端口，用于通过 SSH 访问 Git 代码仓库。例如 `22`。 |
| `CI_SERVER_REVISION`                            | 流水线前 | 调度作业的极狐GitLab 修订版本。 |
| `CI_SERVER_TLS_CA_FILE`                         | 流水线     | 当在 [Runner 设置](https://gitlab.cn/docs/runner/configuration/advanced-configuration/#the-runners-section)中设置 `tls-ca-file` 时，包含用于验证极狐GitLab 服务器的 TLS CA 证书的文件。 |
| `CI_SERVER_TLS_CERT_FILE`                       | 流水线     | 当在 [Runner 设置](https://gitlab.cn/docs/runner/configuration/advanced-configuration/#the-runners-section)中设置 `tls-cert-file` 时，包含用于验证极狐GitLab 服务器的 TLS 证书的文件。 |
| `CI_SERVER_TLS_KEY_FILE`                        | 流水线     | 当在 [Runner 设置](https://gitlab.cn/docs/runner/configuration/advanced-configuration/#the-runners-section)中设置 `tls-key-file` 时，包含用于验证极狐GitLab 服务器的 TLS 密钥的文件。 |
| `CI_SERVER_URL`                                 | 流水线前 | 极狐GitLab 实例的基础 URL，包括协议和端口。例如 `https://gitlab.example.com:8080`。 |
| `CI_SERVER_VERSION_MAJOR`                       | 流水线前 | 极狐GitLab 实例的主版本号。例如，如果极狐GitLab 版本是 `17.2.1`，则 `CI_SERVER_VERSION_MAJOR` 是 `17`。 |
| `CI_SERVER_VERSION_MINOR`                       | 流水线前 | 极狐GitLab 实例的次版本号。例如，如果极狐GitLab 版本是 `17.2.1`，则 `CI_SERVER_VERSION_MINOR` 是 `2`。 |
| `CI_SERVER_VERSION_PATCH`                       | 流水线前 | 极狐GitLab 实例的补丁版本号。例如，如果极狐GitLab 版本是 `17.2.1`，则 `CI_SERVER_VERSION_PATCH` 是 `1`。 |
| `CI_SERVER_VERSION`                             | 流水线前 | 极狐GitLab 实例的完整版本。 |
| `CI_SERVER`                                     | 仅作业     | 可用于 CI/CD 中执行的所有作业。可用时为 `yes`。 |
| `CI_SHARED_ENVIRONMENT`                         | 流水线     | 仅在作业在共享环境中执行时可用（该环境在 CI/CD 调用之间持续存在，例如 `shell` 或 `ssh` 执行器）。可用时为 `true`。 |
| `CI_TEMPLATE_REGISTRY_HOST`                     | 流水线前 | CI/CD 模板使用的镜像仓库主机。默认为 `registry.gitlab.com`。 |
| `CI_TRIGGER_SHORT_TOKEN`                        | 仅作业     | 当前作业的[触发器令牌](../triggers/_index.md#create-a-pipeline-trigger-token)的前 4 个字符。仅当流水线是[使用触发器令牌触发](../triggers/_index.md)时才可用。例如，对于触发器令牌 `glptt-1234567890abcdefghij`，`CI_TRIGGER_SHORT_TOKEN` 将是 `1234`。在极狐GitLab 17.0 中引入。 <!-- gitleaks:allow --> |
| `CI_UPSTREAM_JOB_ID`                            | 流水线前 | 在多项目或父子流水线中，触发当前流水线的上游触发作业的 ID。在极狐GitLab 18.9 中引入。 |
| `CI_UPSTREAM_PIPELINE_ID`                       | 流水线前 | 在多项目或父子流水线中，触发当前流水线的上游流水线的 ID。在极狐GitLab 18.9 中引入。 |
| `CI_UPSTREAM_PROJECT_ID`                        | 流水线前 | 在多项目或父子流水线中，触发当前流水线的上游项目的 ID。在极狐GitLab 18.9 中引入。 |
| `CI_TRACEPARENT`                                | 仅作业     | 作业的 [W3C Trace Context](https://www.w3.org/TR/trace-context/) `traceparent` 标头值，格式为 `00-<trace_id>-<span_id>-01`。`trace_id` 是根流水线 ID，表示为零填充的 32 字符十六进制字符串，由同一流水线层级中的所有作业共享，包括父和子流水线。`span_id` 是从根流水线 ID 和作业 ID 派生的确定性哈希，每个作业唯一。您可以使用此变量将 CI/CD 作业与外部分布式跟踪系统关联起来。 |
| `CI_TRACESTATE`                                 | 仅作业     | 包含极狐GitLab 特定跟踪元数据的 [W3C Trace Context](https://www.w3.org/TR/trace-context/#tracestate-header) `tracestate` 标头值。格式：`gitlab=pipeline:<pipeline_id>;job:<job_id>`。 |
| `GITLAB_CI`                                     | 流水线前 | 可用于 CI/CD 中执行的所有作业。可用时为 `true`。 |
| `GITLAB_FEATURES`                               | 流水线前 | 极狐GitLab 实例和许可证可用的许可功能列表，以逗号分隔。 |
| `GITLAB_USER_EMAIL`                             | 流水线     | 启动流水线的用户的电子邮件，除非作业是手动作业。在手动作业中，该值是启动作业的用户的电子邮件。 |
| `GITLAB_USER_ID`                                | 流水线     | 启动流水线的用户的数字 ID，除非作业是手动作业。在手动作业中，该值是启动作业的用户的 ID。 |
| `GITLAB_USER_LOGIN`                             | 流水线     | 启动流水线的用户的唯一用户名，除非作业是手动作业。在手动作业中，该值是启动作业的用户的用户名。 |
| `GITLAB_USER_NAME`                              | 流水线     | 启动流水线的用户的显示名称（个人资料设置中用户定义的 **全名**），除非作业是手动作业。在手动作业中，该值是启动作业的用户的名称。 |
| `KUBECONFIG`                                    | 流水线     | 包含每个共享 Agent 连接的上下文的 `kubeconfig` 文件的路径。仅当 [极狐GitLab Kubernetes Agent 被授权访问项目](../../user/clusters/agent/ci_cd_workflow.md#authorize-agent-access)时可用。 |
| `TRIGGER_PAYLOAD`                               | 流水线     | Webhook 负载。仅当流水线是[使用 Webhook 触发](../triggers/_index.md#access-webhook-payload)时才可用。 |

<a id="predefined-variables-for-merge-request-pipelines"></a>

## 用于合并请求流水线的预定义变量

这些变量在极狐GitLab 创建流水线（流水线前）之前可用。这些变量可以与
[`include:rules`](../yaml/includes.md#use-rules-with-include)
一起使用，并作为作业中的环境变量使用。

流水线必须是 [合并请求流水线](../pipelines/merge_request_pipelines.md)，
并且合并请求必须处于打开状态。

| 变量                                    | 描述 |
|---------------------------------------------|-------------|
| `CI_MERGE_REQUEST_APPROVED`                 | 合并请求的审批状态。当 [合并请求审批](../../user/project/merge_requests/approvals/_index.md) 可用且合并请求已被批准时，为 `true`。 |
| `CI_MERGE_REQUEST_ASSIGNEES`                | 合并请求的指派人的用户名列表，以逗号分隔。仅当合并请求至少有一个指派人时可用。 |
| `CI_MERGE_REQUEST_DIFF_BASE_SHA`            | 合并请求差异的基础 SHA。 |
| `CI_MERGE_REQUEST_DIFF_ID`                  | 合并请求差异的版本。 |
| `CI_MERGE_REQUEST_EVENT_TYPE`               | 合并请求的事件类型。可以是 `detached`、`merged_result` 或 `merge_train`。 |
| `CI_MERGE_REQUEST_DESCRIPTION`              | 合并请求的描述。如果描述超过 2700 个字符，则变量中仅存储前 2700 个字符。 |
| `CI_MERGE_REQUEST_DESCRIPTION_IS_TRUNCATED` | 如果 `CI_MERGE_REQUEST_DESCRIPTION` 因合并请求的描述过长而被截断为 2700 个字符，则为 `true`，否则为 `false`。 |
| `CI_MERGE_REQUEST_ID`                       | 合并请求的 ID。此 ID 在极狐GitLab 实例上的所有项目中唯一。 |
| `CI_MERGE_REQUEST_IID`                      | 合并请求的 IID（内部 ID）。此 ID 对于当前项目是唯一的，并且是合并请求 URL、页面标题和其他可见位置中使用的编号。 |
| `CI_MERGE_REQUEST_LABELS`                   | 合并请求的标记名称，以逗号分隔。仅当合并请求至少有一个标记时可用。 |
| `CI_MERGE_REQUEST_MILESTONE`                | 合并请求的里程碑标题。仅当合并请求设置了里程碑时可用。 |
| `CI_MERGE_REQUEST_PROJECT_ID`               | 合并请求的项目的 ID。 |
| `CI_MERGE_REQUEST_PROJECT_PATH`             | 合并请求的项目的路径。例如 `namespace/awesome-project`。 |
| `CI_MERGE_REQUEST_PROJECT_URL`              | 合并请求的项目的 URL。例如，`http://192.168.10.15:3000/namespace/awesome-project`。 |
| `CI_MERGE_REQUEST_REF_PATH`                 | 合并请求的引用路径。例如，`refs/merge-requests/1/head`。 |
| `CI_MERGE_REQUEST_SOURCE_BRANCH_NAME`       | 合并请求的源分支名称。 |
| `CI_MERGE_REQUEST_SOURCE_BRANCH_PROTECTED`  | 当合并请求的源分支是[受保护](../../user/project/repository/branches/protected.md)的时，为 `true`。 |
| `CI_MERGE_REQUEST_SOURCE_BRANCH_SHA`        | 合并请求源分支的 HEAD SHA。该变量在合并请求流水线中为空。该 SHA 仅存在于[合并结果流水线](../pipelines/merged_results_pipelines.md)中。 |
| `CI_MERGE_REQUEST_SOURCE_PROJECT_ID`        | 合并请求的源项目的 ID。 |
| `CI_MERGE_REQUEST_SOURCE_PROJECT_PATH`      | 合并请求的源项目的路径。 |
| `CI_MERGE_REQUEST_SOURCE_PROJECT_URL`       | 合并请求的源项目的 URL。 |
| `CI_MERGE_REQUEST_SQUASH_ON_MERGE`          | 当设置了[合并时压缩](../../user/project/merge_requests/squash_and_merge.md)选项时，为 `true`。 |
| `CI_MERGE_REQUEST_TARGET_BRANCH_NAME`       | 合并请求的目标分支名称。 |
| `CI_MERGE_REQUEST_TARGET_BRANCH_PROTECTED`  | 当合并请求的目标分支是[受保护](../../user/project/repository/branches/protected.md)的时，为 `true`。 |
| `CI_MERGE_REQUEST_TARGET_BRANCH_SHA`        | 合并请求目标分支的 HEAD SHA。该变量在合并请求流水线中为空。该 SHA 仅存在于[合并结果流水线](../pipelines/merged_results_pipelines.md)中。 |
| `CI_MERGE_REQUEST_TITLE`                    | 合并请求的标题。 |
| `CI_MERGE_REQUEST_DRAFT`                    | 如果合并请求是草稿，则为 `true`。[在极狐GitLab 17.10 中引入](https://gitlab.com/gitlab-org/gitlab/-/issues/275981)。 |

<a id="predefined-variables-for-external-pull-request-pipelines"></a>

## 用于外部拉取请求流水线的预定义变量

这些变量仅在以下情况下可用：

- 流水线是[外部拉取请求流水线](../ci_cd_for_external_repos/_index.md#pipelines-for-external-pull-requests)
- 拉取请求处于打开状态。

| 变量                                      | 描述 |
|-----------------------------------------------|-------------|
| `CI_EXTERNAL_PULL_REQUEST_IID`                | 来自 GitHub 的拉取请求 ID。 |
| `CI_EXTERNAL_PULL_REQUEST_SOURCE_REPOSITORY`  | 拉取请求的源代码仓库名称。 |
| `CI_EXTERNAL_PULL_REQUEST_TARGET_REPOSITORY`  | 拉取请求的目标代码仓库名称。 |
| `CI_EXTERNAL_PULL_REQUEST_SOURCE_BRANCH_NAME` | 拉取请求的源分支名称。 |
| `CI_EXTERNAL_PULL_REQUEST_SOURCE_BRANCH_SHA`  | 拉取请求源分支的 HEAD SHA。 |
| `CI_EXTERNAL_PULL_REQUEST_TARGET_BRANCH_NAME` | 拉取请求的目标分支名称。 |
| `CI_EXTERNAL_PULL_REQUEST_TARGET_BRANCH_SHA`  | 拉取请求目标分支的 HEAD SHA。 |

<a id="deployment-variables"></a>

## 部署变量

负责部署配置的集成可以定义它们自己的预定义变量，这些变量在构建环境中设置。这些变量仅为
[部署作业](../environments/_index.md)定义。

例如，[Kubernetes 集成](../../user/project/clusters/deploy_to_cluster.md#deployment-variables)
定义了您可以与该集成一起使用的部署变量。

[每个集成的文档](../../user/project/integrations/_index.md)
说明了该集成是否有任何可用的部署变量。

<a id="auto-devops-variables"></a>

## Auto DevOps 变量

当启用 [Auto DevOps](../../topics/autodevops/_index.md) 时，一些额外的
[流水线前](#variable-availability) 变量可用：

- `AUTO_DEVOPS_EXPLICITLY_ENABLED`: 值为 `1` 表示已启用 Auto DevOps。
- `STAGING_ENABLED`: 请参阅 [Auto DevOps 部署策略](../../topics/autodevops/requirements.md#auto-devops-deployment-strategy)。
- `INCREMENTAL_ROLLOUT_MODE`: 请参阅 [Auto DevOps 部署策略](../../topics/autodevops/requirements.md#auto-devops-deployment-strategy)。
- `INCREMENTAL_ROLLOUT_ENABLED`: 已弃用。

<a id="integration-variables"></a>

## 集成变量

一些集成使变量在作业中可用。这些变量作为
[仅作业预定义变量](#variable-availability) 可用：

- [Harbor](../../user/project/integrations/harbor.md):
  - `HARBOR_URL`
  - `HARBOR_HOST`
  - `HARBOR_OCI`
  - `HARBOR_PROJECT`
  - `HARBOR_USERNAME`
  - `HARBOR_PASSWORD`
- [Apple App Store Connect](../../user/project/integrations/apple_app_store.md):
  - `APP_STORE_CONNECT_API_KEY_ISSUER_ID`
  - `APP_STORE_CONNECT_API_KEY_KEY_ID`
  - `APP_STORE_CONNECT_API_KEY_KEY`
  - `APP_STORE_CONNECT_API_KEY_IS_KEY_CONTENT_BASE64`
- [Google Play](../../user/project/integrations/google_play.md):
  - `SUPPLY_PACKAGE_NAME`
  - `SUPPLY_JSON_KEY_DATA`
- [Diffblue Cover](../../integration/diffblue_cover.md):
  - `DIFFBLUE_LICENSE_KEY`
  - `DIFFBLUE_ACCESS_TOKEN_NAME`
  - `DIFFBLUE_ACCESS_TOKEN`

<a id="troubleshooting"></a>

## 故障排除

您可以使用 `script` 命令[输出作业可用的所有变量的值](variables_troubleshooting.md#list-all-variables)。
