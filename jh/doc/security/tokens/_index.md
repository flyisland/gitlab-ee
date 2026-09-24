---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab 令牌概览
description: 了解不同的认证令牌及其安全影响。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

本文档列出了极狐GitLab 中使用的令牌、它们的用途以及（如适用）安全指导。

## 安全注意事项

<a id="security-considerations"></a>

为确保令牌安全：

- 将令牌视为密码并妥善保管。
- 创建有作用域的令牌时，请尽可能使用最受限的作用域，以降低意外泄露令牌的影响。
  - 如果不同的流程需要不同的作用域（例如，`read` 和 `write`），请考虑为每个作用域使用单独的令牌。如果一个令牌泄露，与具有完全 API 访问权限等宽泛作用域的单个令牌相比，它提供的访问权限更少。
- 创建令牌时：
  - 选择一个能描述令牌的名称。例如，`GITLAB_API_TOKEN-application1` 或 `GITLAB_READ_API_TOKEN-application2`。
  - 避免使用通用名称，如 `GITLAB_API_TOKEN`、`API_TOKEN` 或 `default`。
  - 考虑设置一个在你的任务完成后即过期的令牌。例如，如果你需要执行一次性导入，可将令牌设置为几小时后过期。
  - 添加描述以提供更多上下文，包括任何相关的 URL。
- 使用请求头而不是 URL 传递令牌：
  - 对于个人、项目和群组访问令牌，使用 `PRIVATE-TOKEN`。
  - 对于作业令牌，使用 `JOB-TOKEN`。
- 如果你有演示环境，请在录制视频或发布关于项目的博客文章后撤销所有令牌。
- 你可以使用 [Git 凭据存储](https://git-scm.com/book/en/v2/Git-Tools-Credential-Storage) 来存储令牌。
- 定期审查所有类型的所有活跃访问令牌，并撤销你不需要的。

不要：

- 将令牌添加到 URL 中：
  - 当使用 URL 中的令牌克隆或添加远程仓库时，Git 会将 URL 以纯文本形式写入其 `.git/config` 文件中。
  - URL 通常会由代理和应用服务器记录，这可能会向系统管理员泄露这些凭据。
- 在项目中以纯文本形式存储令牌。
  - 如果令牌是极狐GitLab CI/CD 的外部密钥，请查看如何[在 CI/CD 中使用外部密钥](../../ci/secrets/_index.md)。
- 在将代码、控制台命令或日志输出粘贴到议题、MR 描述、评论或任何其他自由文本输入中时，包含令牌。
- 在控制台日志或产物中记录凭据。考虑[保护](../../ci/variables/_index.md#protect-a-cicd-variable) 和[屏蔽](../../ci/variables/_index.md#mask-a-cicd-variable)你的凭据。

### CI/CD 中的令牌

<a id="tokens-in-cicd"></a>

由于其作用域广泛，请尽可能避免在 CI/CD 变量中使用个人访问令牌。如果 CI/CD 作业需要访问其他资源，请按访问作用域从最小到最大的顺序使用以下方式之一：

1. 作业令牌（最小的访问作用域）
1. 项目令牌
1. 群组令牌

[CI/CD 变量安全](../../ci/variables/_index.md#cicd-variable-security)的其他建议包括：

- 为任何凭据使用[密钥存储](../../ci/pipeline_security/_index.md#secrets-storage)。
- 包含敏感信息的 CI/CD 变量应该是[受保护的](../../ci/variables/_index.md#protect-a-cicd-variable)、[被屏蔽的](../../ci/variables/_index.md#mask-a-cicd-variable) 和[隐藏的](../../ci/variables/_index.md#hide-a-cicd-variable)。

## 个人访问令牌

<a id="personal-access-tokens"></a>

你可以创建[个人访问令牌](../../user/profile/personal_access_tokens.md) 以进行认证：

- 极狐GitLab API。
- 极狐GitLab 代码仓。
- 极狐GitLab 镜像仓库。

你可以限制个人访问令牌的作用域和过期日期。默认情况下，它们继承自创建它们的用户的权限。

你可以使用个人访问令牌 API 以编程方式执行操作，例如[轮换个人访问令牌](../../api/personal_access_tokens.md#rotate-a-personal-access-token)。

当你的个人访问令牌即将过期时，你会[收到一封电子邮件](../../user/profile/personal_access_tokens.md#personal-access-token-expiry-emails)。

在考虑需要令牌权限的 CI/CD 作业时，请避免使用个人访问令牌，尤其是将其存储为 CI/CD 变量时。CI/CD 作业令牌和项目访问令牌通常可以以更小的风险实现相同的结果。

## OAuth 2.0 令牌

<a id="oauth-20-tokens"></a>

极狐GitLab 可以作为 [OAuth 2.0 提供者](../../api/oauth2.md)，允许其他服务代表用户访问极狐GitLab API。

你可以限制 OAuth 2.0 令牌的作用域和生命周期。

## 模拟令牌

<a id="impersonation-tokens"></a>

[模拟令牌](../../api/rest/authentication.md#impersonation-tokens) 是一种特殊类型的个人访问令牌。它只能由管理员为特定用户创建。模拟令牌可以帮助你构建以特定用户身份与极狐GitLab API、代码仓和极狐GitLab 镜像仓库进行认证的应用程序或脚本。

你可以限制模拟令牌的作用域并设置过期日期。

## 项目访问令牌

<a id="project-access-tokens"></a>

[项目访问令牌](../../user/project/settings/project_access_tokens.md) 的作用域是一个项目。与个人访问令牌一样，你可以使用它们进行认证：

- 极狐GitLab API。
- 极狐GitLab 代码仓。
- 极狐GitLab 镜像仓库。

你可以限制项目访问令牌的作用域和过期日期。创建项目访问令牌时，极狐GitLab 会创建一个[项目机器人用户](../../user/project/settings/project_access_tokens.md#bot-users-for-projects)。项目的机器人用户是服务账户，不计入许可证席位。

你可以使用[项目访问令牌 API](../../api/project_access_tokens.md) 以编程方式执行操作，例如[轮换项目访问令牌](../../api/project_access_tokens.md#rotate-a-project-access-token)。

当项目访问令牌即将过期时，具有该项目维护者或所有者角色的成员会[收到一封电子邮件](../../user/project/settings/project_access_tokens.md#project-access-token-expiry-emails)。

## 群组访问令牌

<a id="group-access-tokens"></a>

[群组访问令牌](../../user/group/settings/group_access_tokens.md) 的作用域是一个群组。与个人访问令牌一样，你可以使用它们进行认证：

- 极狐GitLab API。
- 极狐GitLab 代码仓。
- 极狐GitLab 镜像仓库。

你可以限制群组访问令牌的作用域和过期日期。创建群组访问令牌时，极狐GitLab 会创建一个[群组机器人用户](../../user/group/settings/group_access_tokens.md#bot-users-for-groups)。群组的机器人用户是服务账户，不计入许可证席位。

你可以使用[群组访问令牌 API](../../api/group_access_tokens.md) 以编程方式执行操作，例如[轮换群组访问令牌](../../api/group_access_tokens.md#rotate-a-group-access-token)。

当群组访问令牌即将过期时，具有该群组所有者角色的成员会[收到一封电子邮件](../../user/group/settings/group_access_tokens.md#group-access-token-expiry-emails)。

## 部署令牌

<a id="deploy-tokens"></a>

[部署令牌](../../user/project/deploy_tokens/_index.md) 允许你在没有用户和密码的情况下克隆、推送和拉取项目的软件包和容器镜像仓库镜像。部署令牌不能与极狐GitLab API 一起使用。

要管理部署令牌，你必须是至少具有维护者角色的项目成员。

## 部署密钥

<a id="deploy-keys"></a>

[部署密钥](../../user/project/deploy_keys/_index.md) 通过将 SSH 公钥导入你的极狐GitLab 实例，允许对你的代码仓进行只读或读写访问。部署密钥不能与极狐GitLab API 或镜像仓库一起使用。

你可以使用部署密钥将代码仓克隆到你的持续集成服务器，而无需设置虚假用户账户。

要添加或启用项目的部署密钥，你必须至少具有维护者角色。

## Runner 认证令牌

<a id="runner-authentication-tokens"></a>

在极狐GitLab 16.0 及更高版本中，要注册 runner，你可以使用 runner 认证令牌，而不是 runner 注册令牌。Runner 注册令牌已[弃用](../../ci/runners/new_creation_workflow.md)。

创建 runner 及其配置后，你会收到一个 runner 认证令牌，用于注册该 runner。Runner 认证令牌本地存储在 [`config.toml`](https://gitlab.cn/docs/runner/configuration/advanced-configuration/) 文件中，你使用该文件来配置 runner。

Runner 使用 runner 认证令牌在从作业队列提取作业时向极狐GitLab 进行认证。Runner 向极狐GitLab 认证后，会收到一个[作业令牌](../../ci/jobs/ci_job_token.md)，用于执行作业。

Runner 认证令牌保留在 runner 机器上。以下执行器的执行环境只能访问作业令牌，而不能访问 runner 认证令牌：

- Docker Machine
- Kubernetes
- VirtualBox
- Parallels
- SSH

对 runner 文件系统的恶意访问可能会暴露 `config.toml` 文件和 runner 认证令牌。攻击者可以使用 runner 认证令牌来[克隆 runner](https://gitlab.cn/docs/runner/security/#cloning-a-runner)。

你可以使用 runners API 来[轮换或撤销 runner 认证令牌](../../api/runners.md#reset-runners-authentication-token-by-using-the-current-token)。

## Runner 注册令牌（旧版）

<a id="runner-registration-tokens-legacy"></a>

> [!warning]
> 传递 runner 注册令牌的选项和对某些配置参数的支持被视为旧版，不推荐使用。
> 使用 [runner 创建工作流](https://gitlab.cn/docs/runner/register/#register-with-a-runner-authentication-token) 生成认证令牌来注册 runners。此过程提供了 runner 所有权的完全可追溯性，并增强了 runner 机群的安全性。
> 极狐GitLab 已经实施了一种新的[极狐GitLab Runner 令牌架构](../../ci/runners/new_creation_workflow.md)，它引入了一种注册 runners 的新方法，并移除了 runner 注册令牌。

Runner 注册令牌用于向极狐GitLab [注册](https://gitlab.cn/docs/runner/register/) [runner](https://gitlab.cn/docs/runner/)。群组或项目所有者或实例管理员可以通过极狐GitLab 用户界面获取它们。该注册令牌仅限于 runner 注册，没有其他作用域。

你可以使用 runner 注册令牌添加 runners，以执行项目或群组中的作业。该 runner 可以访问项目的代码，因此在分配项目或群组权限时要小心。

## CI/CD 作业令牌

<a id="cicd-job-tokens"></a>

[CI/CD](../../ci/jobs/ci_job_token.md) 作业令牌是一个仅在作业持续期间有效的短期令牌。它使 CI/CD 作业能够访问有限数量的 API 端点。API 认证使用作业令牌，其授权基于触发作业的用户。

作业令牌因其短生命周期和有限的作用域而受到保护。如果多个作业在同一台机器上运行（例如，使用 [shell runner](https://gitlab.cn/docs/runner/security/#usage-of-shell-executor)），此令牌可能会泄露。你可以使用[项目允许列表](../../ci/jobs/ci_job_token.md#add-a-group-or-project-to-the-job-token-allowlist) 进一步限制作业令牌可以访问的内容。

在 Docker Machine runners 上，你应该配置 [`MaxBuilds=1`](https://gitlab.cn/docs/runner/configuration/advanced-configuration/#the-runnersmachine-section) 以确保 runner 机器只运行一个构建，然后被销毁。配置可能需要时间，因此此配置可能影响性能。

## 极狐GitLab 集群代理令牌

<a id="gitlab-cluster-agent-tokens"></a>

当你[注册极狐GitLab Kubernetes 代理](../../user/clusters/agent/install/_index.md#register-the-agent-with-gitlab) 时，极狐GitLab 会生成一个访问令牌，用于向极狐GitLab 认证集群代理。

要撤销此集群代理令牌，你可以：

- 使用 [agents API](../../api/cluster_agents.md#revoke-an-agent-token) 撤销令牌。
- [重置令牌](../../user/clusters/agent/work_with_agent.md#reset-the-agent-token)。

对于这两种方法，你都必须知道令牌、代理和项目的 ID。要找到这些信息，请使用 [Rails 控制台](../../administration/operations/rails_console.md)：

```ruby
# Find token ID
Clusters::AgentToken.find_by_token('glagent-xxx').id

# Find agent ID
Clusters::AgentToken.find_by_token('glagent-xxx').agent.id
=> 1234

# Find project ID
Clusters::AgentToken.find_by_token('glagent-xxx').agent.project_id
=> 12345
```

你也可以直接在 Rails 控制台中撤销令牌：

```ruby
# 使用 RevokeService 撤销令牌，包括生成审计事件
Clusters::AgentTokens::RevokeService.new(token: Clusters::AgentToken.find_by_token('glagent-xxx'), current_user: User.find_by_username('admin-user')).execute

# 手动撤销令牌，不会生成审计事件
Clusters::AgentToken.find_by_token('glagent-xxx').revoke!
```

## 其他令牌

<a id="other-tokens"></a>

### 订阅源令牌

<a id="feed-token"></a>

每个用户都有一个长期有效的订阅源令牌，不会过期。使用此令牌进行认证：

- RSS 阅读器，用于加载个性化的 RSS 订阅源。
- 日历应用程序，用于加载个性化的日历。

你无法使用此令牌访问任何其他数据。

你可以将用户作用域的订阅源令牌用于所有订阅源。但是，订阅源和日历 URL 是使用仅对一个订阅源有效的不同令牌生成的。

任何拥有你令牌的人都可以像你一样查看你的订阅源活动，包括机密议题。如果你认为你的令牌已泄露，请[立即重置该令牌](../../user/profile/contributions_calendar.md#reset-the-user-activity-feed-token)。

#### 禁用订阅源令牌

<a id="disable-a-feed-token"></a>

先决条件：

- 你必须是管理员。

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **可见性和访问控制**。
1. 在 **订阅源令牌** 下，选择 **禁用订阅源令牌** 复选框，然后选择 **保存更改**。

### 接收邮件令牌

<a id="incoming-email-token"></a>

每个用户都有一个不会过期的接收邮件令牌。该令牌包含在与个人项目关联的电子邮件地址中。你使用此令牌来[通过发送电子邮件创建新议题](../../user/project/issues/create_issues.md#by-sending-an-email)。

你无法使用此令牌访问任何其他数据。任何拥有你令牌的人都可以像你一样创建议题和合并请求。如果你认为你的令牌已泄露，请立即重置令牌。

### 工作空间令牌

<a id="workspace-token"></a>

{{< history >}}

- 在极狐GitLab 18.2 中[引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/194097)。

{{< /history >}}

每个[工作空间](../../user/workspace/_index.md)都有一个内部的、自动管理的令牌，不会过期。它允许与工作空间进行 HTTP 和 SSH 通信。每当请求工作空间处于 **运行中** 状态时，它就存在，并由工作空间自动注入和使用。

启动已停止的工作空间会创建一个新的工作空间令牌。
重启正在运行的工作空间会删除现有令牌并创建一个新令牌。

你无法直接查看或管理此内部令牌。你无法使用此令牌访问任何其他数据。

要撤销工作空间令牌，请[**停止**或**终止**工作空间](../../user/workspace/_index.md#manage-workspaces-from-a-project)。令牌会立即被删除。

## 可用作用域

<a id="available-scopes"></a>

此表显示了每个令牌的默认作用域。对于某些令牌，你可以在创建令牌时进一步限制作用域。

| 令牌名称                 | API 访问              | 镜像仓库访问         | 代码仓访问 |
|-----------------------------|-------------------------|-------------------------|-------------------|
| 个人访问令牌       | {{< yes >}}             | {{< yes >}}             | {{< yes >}}       |
| OAuth 2.0 令牌             | {{< yes >}}             | {{< no >}}              | {{< yes >}}       |
| 模拟令牌         | {{< yes >}}             | {{< yes >}}             | {{< yes >}}       |
| 项目访问令牌        | {{< yes >}}<sup>1</sup> | {{< yes >}}<sup>1</sup> | {{< yes >}}<sup>1</sup> |
| 群组访问令牌          | {{< yes >}}<sup>2</sup> | {{< yes >}}<sup>2</sup> | {{< yes >}}<sup>2</sup> |
| 部署令牌                | {{< no >}}              | {{< yes >}}             | {{< yes >}}       |
| 部署密钥                  | {{< no >}}              | {{< no >}}              | {{< yes >}}       |
| Runner 注册令牌   | {{< no >}}              | {{< no >}}              | 受限<sup>3</sup> |
| Runner 认证令牌 | {{< no >}}              | {{< no >}}              | 受限<sup>3</sup> |
| 作业令牌                   | 受限<sup>4</sup>     | {{< no >}}              | {{< yes >}}       |

**脚注**：

1. 仅限于一个项目。
1. 仅限于一个群组。
1. Runner 注册和认证令牌不提供对代码仓的直接访问，但可以用于注册和认证新的 runner，这些 runner 可以执行确实可以访问代码仓的作业。
1. 仅限[某些端点](../../ci/jobs/ci_job_token.md)。

## 令牌前缀

<a id="token-prefixes"></a>

下表显示了每种令牌的前缀。
除了个人访问令牌外，这些前缀不可配置，因为它们被设计为标准标识。

|            令牌名称             |      前缀        |
|-----------------------------------|--------------------|
| 个人访问令牌             | `glpat-`           |
| OAuth 应用程序密钥          | `gloas-`           |
| 模拟令牌               | `glpat-`           |
| 项目访问令牌              | `glpat-`           |
| 群组访问令牌                | `glpat-`           |
| 部署令牌                      | `gldt-` ([在极狐GitLab 16.7 中添加](https://gitlab.com/gitlab-org/gitlab/-/issues/376752)) |
| Runner 认证令牌       | `glrt-` 或 `glrtr-`（如果通过注册令牌创建） |
| CI/CD 作业令牌                   | `glcbt-` <br /> &bull; ([在极狐GitLab 16.8 中引入](https://gitlab.com/gitlab-org/gitlab/-/issues/426137)，位于名为 `prefix_ci_build_tokens` 的功能标志之后。默认禁用。) <br /> &bull; ([在极狐GitLab 16.9 中 GA](https://gitlab.com/gitlab-com/gl-infra/production/-/issues/17299)。功能标志 `prefix_ci_build_tokens` 已移除。) |
| 触发器令牌                     | `glptt-`           |
| 订阅源令牌                        | `glft-`            |
| 接收邮件令牌               | `glimt-`           |
| 极狐GitLab Kubernetes 代理令牌 | `glagent-`         |
| 工作空间令牌                   | `glwt-` (在极狐GitLab 18.2 中添加) |
| 极狐GitLab 会话 Cookie            | `_gitlab_session=` |
| SCIM 令牌                       | `glsoat-` <br /> &bull; ([在极狐GitLab 16.8 中引入](https://gitlab.com/gitlab-org/gitlab/-/issues/435096)，位于名为 `prefix_scim_tokens` 的功能标志之后。默认禁用。) <br > &bull; ([在极狐GitLab 16.9 中 GA](https://gitlab.com/gitlab-org/gitlab/-/issues/435423)。功能标志 `prefix_scim_tokens` 已移除。) |
| 功能标志客户端令牌        | `glffct-`          |