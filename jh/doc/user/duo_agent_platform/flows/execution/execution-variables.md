---
stage: Agent Foundations
group: Agent Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 了解执行任务流的作业中可用的预定义变量、环境变量和 ID 令牌变量，以及哪些不可用。
title: 任务流执行变量
---

{{< details >}}

- Tier: [基础版](../../../../subscriptions/gitlab_credits.md#for-the-free-tier)，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

并非所有变量都可用于执行任务流的作业。

- 部分预定义变量和 Agent Platform 专属变量可用。
- 预定义过滤变量、自定义 CI/CD 变量和用户身份变量不可用。

<a id="available-variables"></a>

## 可用变量

以下变量可用于执行您的任务流的作业中。

<a id="predefined-variables"></a>

### 预定义变量

以下预定义 CI/CD 变量可用：

| 变量 | 描述 |
|----------|-------------|
| `CI_PROJECT_ID` | 项目 ID。 |
| `CI_PROJECT_NAME` | 项目名称。 |
| `CI_PROJECT_PATH` | 包含命名空间的项目路径。 |
| `CI_PROJECT_URL` | 项目 HTTP URL。 |
| `CI_PROJECT_NAMESPACE` | 项目命名空间。 |
| `CI_PROJECT_VISIBILITY` | 项目可见性（`public`、`internal` 或 `private`）。 |
| `CI_DEFAULT_BRANCH` | 默认分支名称。 |
| `CI_JOB_ID` | 作业 ID。 |
| `CI_JOB_URL` | 作业 URL。 |
| `CI_JOB_TOKEN` | 作业身份验证令牌。 |
| `CI_JOB_IMAGE` | 用于作业的 Docker 镜像。 |
| `CI_JOB_STATUS` | 作业状态。 |
| `CI_JOB_TIMEOUT` | 作业超时时间（秒）。 |
| `CI_JOB_STARTED_AT` | 作业开始时间戳（ISO 8601 格式）。 |
| `CI_PIPELINE_ID` | 流水线 ID。 |
| `CI_PIPELINE_URL` | 流水线 URL。 |
| `CI_REGISTRY_USER` | 容器镜像仓库用户名（`gitlab-ci-token`）。 |
| `CI_REGISTRY_PASSWORD` | 容器镜像仓库密码（作业令牌）。 |
| `CI_DEPENDENCY_PROXY_USER` | 依赖代理用户名。 |
| `CI_DEPENDENCY_PROXY_PASSWORD` | 依赖代理密码。 |
| `CI_REPOSITORY_URL` | 包含内嵌凭据的 Git 克隆 URL。 |
| `CI_RUNNER_VERSION` | Runner 版本。 |
| `CI_RUNNER_EXECUTABLE_ARCH` | Runner 架构（例如，`linux/amd64`）。 |
| `CI_SERVER` | 在 CI/CD 环境中始终为 `yes`。 |
| `CI_WORKLOAD_REF` | 任务流执行的工作负载引用（例如，`refs/workloads/c727f70ba7f`）。这些是内部 Git 引用，在流水线作业完成或失败时自动移除。|

<a id="environment-variables"></a>

### 环境变量

以下环境变量是 Agent Platform 专属的。
这些变量在 `setup_script` 和主 Agent 运行时中均可用。

此表记录了关键变量。执行容器中可能还存在其他内部变量
（例如，调试标志和遥测标识符），但不适用于任务流配置。

| 变量 | 描述 | 示例 |
|----------|-------------|---------|
| `DUO_WORKFLOW_GIT_HTTP_BASE_URL` | 极狐GitLab 实例基础 URL。请使用此变量代替 `CI_SERVER_URL`。 | `https://gitlab.com` |
| `DUO_WORKFLOW_PROJECT_ID` | 项目 ID。与 `CI_PROJECT_ID` 的值相同。 | `77056053` |
| `DUO_WORKFLOW_NAMESPACE_ID` | 命名空间 ID。 | `91555435` |
| `DUO_WORKFLOW_GOAL` | 触发任务流的议题 URL。 | `https://gitlab.com/group/project/-/issues/10` |
| `DUO_WORKFLOW_DEFINITION` | 任务流定义标识符。 | `developer/v1` |
| `DUO_WORKFLOW_SERVICE_REALM` | 部署类型。 | `saas` 或 `self-managed` |
| `DUO_WORKFLOW_GIT_HTTP_USER` | 用于克隆的 Git HTTP 用户名。 | `oauth` |
| `DUO_WORKFLOW_GIT_HTTP_PASSWORD` | 用于克隆的 Git HTTP 密码。 | *(OAuth 令牌)* |
| `DUO_WORKFLOW_GIT_USER_NAME` | 触发任务流的用户名称。用作 Git 提交者。 | `Jane Developer` |
| `DUO_WORKFLOW_GIT_USER_EMAIL` | 触发任务流的用户邮箱。用作 Git 提交者邮箱。 | `jdeveloper@example.com` |
| `DUO_WORKFLOW_GIT_AUTHOR_EMAIL` | 服务账号的邮箱。用作 Git 作者邮箱。 | `service_account_group_<ID>@noreply.gitlab.com` |
| `DUO_WORKFLOW_GIT_AUTHOR_USER_NAME` | 服务账号的名称。用作 Git 作者名称。 | `Duo Developer` |
| `GITLAB_BASE_URL` | 极狐GitLab 实例基础 URL。与 `DUO_WORKFLOW_GIT_HTTP_BASE_URL` 的值相同。 | `https://gitlab.com` |
| `GITLAB_PROJECT_PATH` | 包含命名空间的项目完整路径。与 `CI_PROJECT_PATH` 的值相同。 | `my-group/my-project` |
| `GITLAB_TOKEN` | 用于极狐GitLab API 访问的 OAuth 令牌。与 `DUO_WORKFLOW_GIT_HTTP_PASSWORD` 的值相同。 | *(OAuth 令牌)* |
| `AGENT_PLATFORM_GITLAB_VERSION` | 运行任务流的极狐GitLab 版本。 | `18.9.0` |

<a id="id-token-variables"></a>

### ID 令牌变量

您声明的 [ID 令牌](../../../../ci/secrets/id_token_authentication.md) 可作为
环境变量在任务流作业中使用。每个变量使用您声明的令牌名称。

您可以在以下位置声明 ID 令牌：

- 对于使用 CI/CD 的任务流，在 `agent-config.yml` 文件中声明。更多信息，请参阅
  [配置 ID 令牌](_index.md#configure-id-tokens)。
- 在 [自定义外部 Agent](../../agents/external.md#authenticate-with-id-tokens) 的配置中声明。

例如，当您声明一个包含 `VAULT_ID_TOKEN` 令牌的 `id_tokens` 块时，
任务流可以使用 `$VAULT_ID_TOKEN`。

<a id="not-available"></a>

## 不可用

以下变量不可用于执行您的任务流的作业。

<a id="filtered-predefined-variables"></a>

### 过滤的预定义变量

以下预定义 CI/CD 变量不可用：

| 变量 | 原因 |
|----------|--------|
| `CI_REGISTRY` | 被工作负载变量门控过滤。请改用硬编码的镜像仓库主机名。 |
| `CI_REGISTRY_IMAGE` | 被工作负载变量门控过滤。请改用硬编码的镜像路径。 |
| `CI_SERVER_URL`、`CI_SERVER_HOST`、`CI_API_V4_URL` | 已被过滤。请改用 `GITLAB_BASE_URL` 或 `DUO_WORKFLOW_GIT_HTTP_BASE_URL`。 |
| `CI_COMMIT_SHA`、`CI_COMMIT_BRANCH`、`CI_COMMIT_REF_NAME` | 作业没有提交上下文。源分支由极狐GitLab Duo Agent 管理。 |
| `GITLAB_USER_LOGIN`、`GITLAB_USER_EMAIL`、`GITLAB_USER_NAME` | 作业以服务账号身份运行，而非触发用户。 |
| `CI_PIPELINE_SOURCE`、`CI_PIPELINE_IID` | 被工作负载变量门控过滤。 |

<a id="user-identity"></a>

### 用户身份

任务流执行期间使用的 CI 作业令牌是一个
[复合身份](../../composite_identity.md)
令牌，同时代表触发用户和服务账号。

任务流执行期间创建的 Git 提交由触发
任务流的用户提交，但作者标记为服务账号。

由于执行任务流的是服务账号而非用户，因此
`GITLAB_USER_LOGIN` 和 `GITLAB_USER_EMAIL` 变量不可用。

但是，触发任务流的用户身份可在
`DUO_WORKFLOW_GIT_USER_EMAIL` 和 `DUO_WORKFLOW_GIT_USER_NAME` 中获取，
服务账号身份可在
`DUO_WORKFLOW_GIT_AUTHOR_EMAIL` 和 `DUO_WORKFLOW_GIT_AUTHOR_USER_NAME` 中获取。

<a id="custom-cicd-variables"></a>

### 自定义 CI/CD 变量

在 **设置** > **CI/CD** > **变量** 中为项目、群组或实例定义的自定义 CI/CD 变量不可用。

自定义 CI/CD 变量包括受保护变量、非受保护变量、掩码变量和文件变量。

所有任务流配置必须在 `agent-config.yml` 中提供，或通过
[可用环境变量](#environment-variables) 提供。

<a id="accessing-the-gitlab-instance-url"></a>

## 访问极狐GitLab 实例 URL

标准 `CI_SERVER_URL` 变量不可用。请改用
`GITLAB_BASE_URL` 或 `DUO_WORKFLOW_GIT_HTTP_BASE_URL`。

例如，要在 `setup_script` 中进行 API 调用：

```yaml
setup_script:
  - "curl --silent --header 'JOB-TOKEN: ${CI_JOB_TOKEN}' ${GITLAB_BASE_URL}/api/v4/projects/${CI_PROJECT_ID}"
```
