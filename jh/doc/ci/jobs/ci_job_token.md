---
stage: Software Supply Chain Security
group: Pipeline Security
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 使用短期作业令牌，通过极狐GitLab 功能对 CI/CD 作业进行身份验证。
title: CI/CD 作业令牌
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

当 CI/CD 流水线作业即将运行时，极狐GitLab 会生成一个唯一令牌，并将其作为 [`CI_JOB_TOKEN` 预定义变量](../variables/predefined_variables.md)提供给作业。
该令牌仅在作业运行期间有效。作业完成后，令牌访问权限即被撤销，您无法再使用该令牌。

使用 CI/CD 作业令牌，可从正在运行的作业中向极狐GitLab 的某些功能进行身份验证。
该令牌拥有与触发流水线的用户相同的访问级别，但可访问的[资源](#job-token-access)少于个人访问令牌。用户可以通过推送提交、运行手动作业或拥有定时流水线来触发作业。
该用户必须拥有[具备所需权限的角色](../../user/permissions.md#project-cicd)才能访问这些资源。

您可以使用作业令牌向极狐GitLab 进行身份验证，以访问另一个群组或项目的资源（目标项目）。
默认情况下，作业令牌所属的群组或项目必须[添加到目标项目的允许列表中](#add-a-group-or-project-to-the-job-token-allowlist)。

如果项目是公开或内部项目，您无需在允许列表中即可访问某些功能。
例如，您可以从项目的公开流水线中获取产物。
此访问权限也[可以受到限制](#limit-job-token-scope-for-public-or-internal-projects)。

<a id="job-token-access"></a>

## 作业令牌访问权限

CI/CD 作业令牌可以访问以下资源：

| 资源                                                                                              | 说明 |
| ----------------------------------------------------------------------------------------------------- | ----- |
| [徽章 API](../../api/project_badges.md)                                                             | 可以访问此 API 中的所有端点。 |
| [分支 API](../../api/branches.md)                                                                 | 可以访问 `GET /projects/:id/repository/branches` 端点。 |
| [提交 API](../../api/commits.md)                                                                   | 可以访问 `GET /projects/:id/repository/commits/:sha`、`GET /projects/:id/repository/commits/:sha/merge_requests` 和 `GET /projects/:id/repository/commits/:sha/refs` 端点。 |
| [容器镜像仓库](../../user/packages/container_registry/build_and_push_images.md#use-gitlab-cicd) | 用作 `$CI_REGISTRY_PASSWORD` [预定义变量](../variables/predefined_variables.md)，以对与作业项目关联的容器镜像仓库进行身份验证。 |
| [软件包仓库](../../user/packages/package_registry/_index.md#to-build-packages)                  | 用于对仓库进行身份验证。 |
| [Terraform 模块仓库](../../user/packages/terraform_module_registry/_index.md)                  | 用于对仓库进行身份验证。 |
| [安全文件](../secure_files/_index.md#use-secure-files-in-cicd-jobs)                               | 由 [`glab securefile`](https://gitlab.com/gitlab-org/cli/-/tree/main/docs/source/securefile) 命令用于在作业中使用安全文件。 |
| [容器镜像仓库 API](../../api/container_registry.md)                                             | 只能对与作业项目关联的容器镜像仓库进行身份验证。 |
| [部署 API](../../api/deployments.md)                                                           | 可以访问此 API 中的所有端点。 |
| [环境 API](../../api/environments.md)                                                         | 可以访问此 API 中的所有端点。 |
| [文件 API](../../api/repository_files.md)                                                            | 可以访问 `GET /projects/:id/repository/files/:file_path/raw` 端点。 |
| [作业 API](../../api/jobs.md#retrieve-a-job-by-job-token)                                             | 只能访问 `GET /job` 端点。 |
| [作业产物 API](../../api/job_artifacts.md)                                                       | 只能访问下载端点。 |
| [合并请求 API](../../api/merge_requests.md)                                                     | 可以访问 `GET /projects/:id/merge_requests` 和 `GET /projects/:id/merge_requests/:merge_request_iid` 端点。 |
| [评论 API](../../api/notes.md)                                                                       | 可以访问 `GET /projects/:id/merge_requests/:merge_request_iid/notes` 和 `GET /projects/:id/merge_requests/:merge_request_iid/notes/:note_id` 端点。 |
| [软件包 API](../../api/packages.md)                                                                 | 可以访问此 API 中的所有端点。 |
| [流水线触发器令牌 API](../../api/pipeline_triggers.md#trigger-a-pipeline-with-a-token)         | 只能访问 `POST /projects/:id/trigger/pipeline` 端点。 |
| [流水线 API](../../api/pipelines.md#update-pipeline-metadata)                                      | 只能访问 `PUT /projects/:id/pipelines/:pipeline_id/metadata` 端点。 |
| [发布链接 API](../../api/releases/links.md)                                                      | 可以访问此 API 中的所有端点。 |
| [发布 API](../../api/releases/_index.md)                                                          | 可以访问此 API 中的所有端点。 |
| [代码仓库 API](../../api/repositories.md)                                                         | 可以访问 `GET /projects/:id/repository/archive` 和 `GET /projects/:id/repository/changelog` 端点。 |
| [标签 API](../../api/tags.md)                                                                         | 可以访问 `GET /projects/:id/repository/tags` 和 `GET /projects/:id/repository/tags/:tag_name` 端点。 |

有一个开放的[提案](https://gitlab.com/groups/gitlab-org/-/epics/3559)，旨在使权限更加细化。

<a id="gitlab-cicd-job-token-security"></a>

## 极狐GitLab CI/CD 作业令牌安全

如果作业令牌泄露，则可能被用来访问运行 CI/CD 作业的用户可访问的私有数据。为帮助防止此令牌泄露或滥用，极狐GitLab：

- 在作业日志中屏蔽作业令牌。
- 仅在作业运行时授予作业令牌权限。

您还应该配置您的 [Runner](../runners/_index.md) 以确保安全：

- 如果机器被重复使用，请避免使用 Docker `privileged` 模式。
- 当作业在同一台机器上运行时，请避免使用 [`shell` 执行器](https://gitlab.cn/docs/runner/executors/shell/)。

不安全的极狐GitLab Runner 配置会增加他人从其他作业中窃取令牌的风险。

<a id="control-job-token-access-to-your-project"></a>

## 控制对您项目的作业令牌访问权限

您可以控制哪些群组或项目可以使用作业令牌进行身份验证并访问您项目的部分资源。

默认情况下，作业令牌访问权限仅限于在您项目中的流水线中运行的 CI/CD 作业。要允许另一个群组或项目使用来自其他项目流水线的作业令牌进行身份验证：

- 您必须[将群组或项目添加到作业令牌允许列表](#add-a-group-or-project-to-the-job-token-allowlist)。
- 触发作业的用户必须是您项目的成员。
- 该用户必须拥有执行该操作的[权限](../../user/permissions.md)。

如果您的项目是公开或内部项目，则任何项目中的作业令牌都可以访问某些公开可访问的资源。这些资源也[可以限制为仅允许列表中的项目访问](#limit-job-token-scope-for-public-or-internal-projects)。

极狐GitLab 私有化部署管理员可以[覆盖并强制执行此设置](../../administration/settings/continuous_integration.md#access-job-token-permission-settings)。
强制执行该设置后，CI/CD 作业令牌将始终仅限于项目的允许列表。

<a id="add-a-group-or-project-to-the-job-token-allowlist"></a>

### 将群组或项目添加到作业令牌允许列表

您可以将群组或项目添加到作业令牌允许列表，以允许使用作业令牌进行身份验证来访问您项目的资源。默认情况下，任何项目的允许列表仅包含其自身。
仅在需要跨项目访问时，才将群组或项目添加到允许列表。

将项目添加到允许列表并不会为被允许项目的成员授予额外的[权限](../../user/permissions.md)。他们必须已经拥有访问您项目中资源的权限，才能使用来自被允许项目的作业令牌访问您的项目。

例如，项目 A 可以将项目 B 添加到项目 A 的允许列表中。项目 B（“被允许的项目”）中的 CI/CD 作业现在可以使用 CI/CD 作业令牌对 API 调用进行身份验证，以访问项目 A。

当您将群组添加到允许列表时，该条目将授予对该群组中每个项目及其任意深度的子群组的访问权限。极狐GitLab 会在每次作业使用该令牌时评估匹配情况，因此之后添加到群组的项目无需更改允许列表即可被包含在内。

例如，项目 A 将群组 `example-group` 添加到其允许列表。`example-group/team-b/project-c` 中的作业随后可以使用作业令牌访问项目 A，之后在 `example-group` 下创建的任何项目中的作业也可以。

先决条件：

- 您必须对当前项目拥有维护者或所有者角色。如果被允许的项目是内部或私有项目，您必须对该项目拥有访客、计划者、报告者、开发者、维护者或所有者角色。
- 允许列表中的群组不得超过 200 个，项目也不得超过 200 个。这两个限制是分别计算的。

要将群组或项目添加到允许列表：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **CI/CD**。
1. 展开 **作业令牌权限**。
1. 在 **CI/CD 作业令牌允许列表** 右侧，选择 **添加**。
1. 选择 **群组或项目**。
1. 输入要添加到允许列表的群组或项目的路径，然后选择 **添加**。

您也可以[通过 API](../../api/graphql/reference/_index.md#mutationcijobtokenscopeaddgrouporproject) 将群组或项目添加到允许列表。

<a id="limit-job-token-scope-for-public-or-internal-projects"></a>

### 限制公开或内部项目的作业令牌范围

不在允许列表中的项目可以使用作业令牌对公开或内部项目进行身份验证，以：

- 获取产物。
- 访问容器镜像仓库。
- 访问软件包仓库。
- 访问发布、部署和环境。
- 访问代码仓库。

您可以通过将每个功能设置为仅对项目成员可见，来将这些操作的访问权限限制为仅允许列表中的项目。

先决条件：

- 您必须对项目拥有维护者角色。

要将功能设置为仅对项目成员可见：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **可见性、项目功能、权限**。
1. 对于您要限制访问的功能，将可见性设置为 **仅项目成员**。
   - 获取产物的访问权限由 CI/CD 可见性设置控制。
1. 选择 **保存更改**。

<a id="allow-any-project-to-access-your-project"></a>

### 允许任何项目访问您的项目

{{< details >}}

- Offering: 私有化部署

{{< /details >}}

> [!warning]
> 禁用令牌访问限制和允许列表存在安全风险。恶意用户可能试图破坏在未授权项目中创建的流水线。如果该流水线由您的某个维护者创建，则作业令牌可能被用来尝试访问您的项目。

如果您禁用 CI/CD 作业令牌允许列表，则任何项目中的作业都可以使用作业令牌访问您的项目。触发流水线的用户必须拥有访问您项目的权限。
您只应在测试或类似原因下禁用此设置，并应尽快重新启用。

此选项仅在 [**为所有项目启用并强制执行作业令牌允许列表**设置](../../administration/settings/continuous_integration.md#enforce-job-token-allowlist) 已禁用的极狐GitLab 私有化部署实例上可用。

先决条件：

- 您必须对项目拥有维护者或所有者角色。

要禁用作业令牌允许列表：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **CI/CD**。
1. 展开 **作业令牌权限**。
1. 选择 **所有群组和项目**。
1. 建议。测试完成后，选择 **此项目以及允许列表中的任何群组和项目** 以重新启用作业令牌允许列表。

您也可以通过 [GraphQL](../../api/graphql/reference/_index.md#mutationprojectcicdsettingsupdate)（`inboundJobTokenScopeEnabled`）或 [REST](../../api/project_job_token_scopes.md#update-the-cicd-job-token-access-settings-for-a-project) API 修改此设置。

<a id="allow-git-push-requests-to-your-project-repository"></a>

### 允许向您的项目代码仓库发起 Git 推送请求

您可以配置您的项目，以允许使用 CI/CD 作业令牌进行身份验证的 Git 推送请求。此设置默认处于关闭状态。

当您开启此设置时，只有项目流水线中运行的 CI/CD 作业生成的作业令牌才能推送到该项目。

当您使用作业令牌推送到项目时，不会触发任何 CI/CD 流水线。
作业令牌拥有与启动作业的用户相同的访问权限。

如果您使用 `semantic-release` 工具，[此设置可能会阻止流水线的创建](#the-semantic-release-tool-and-job-tokens)。

> [!warning]
> 不要在配置为[拉取镜像](../../user/project/repository/mirror/pull.md)的项目上启用此设置，尤其是在[为镜像更新运行流水线](../../user/project/repository/mirror/pull.md#trigger-pipelines-for-mirror-updates)时。
> 上游代码仓库所有者可能会尝试使用 `CI_JOB_TOKEN` 向镜像项目推送提交。

先决条件：

- 您必须对项目拥有维护者或所有者角色。

要授予在您的项目中生成的作业令牌推送到项目代码仓库的权限：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **CI/CD**。
1. 展开 **作业令牌权限**。
1. 在 **权限** 部分，选择 **允许向代码仓库发起 Git 推送请求**。

您也可以通过 [projects API](../../api/projects.md#update-a-project) 中的 `ci_push_repository_for_job_token_allowed` 参数控制此设置。

<a id="allow-cross-project-git-push-requests-from-allowlisted-projects"></a>

### 允许来自允许列表项目的跨项目 Git 推送请求

您可以允许来自允许列表项目的 CI/CD 作业令牌推送到您的项目代码仓库。
跨项目推送可避免 GitOps 工作流、子模块标记和跨代码仓库 CI/CD 流水线中的长期访问令牌。

当作业令牌推送成功时，不会在目标项目中触发任何 CI/CD 流水线。

> [!warning]
> 不要在配置为[拉取镜像](../../user/project/repository/mirror/pull.md)的项目上启用此设置，尤其是在[为镜像更新触发流水线](../../user/project/repository/mirror/pull.md#trigger-pipelines-for-mirror-updates)时。
> 允许列表中的源项目所有者可以使用 CI/CD 作业令牌向您的镜像项目推送提交。

要使跨项目推送生效，必须满足以下所有条件：

- 目标项目已启用 **允许向代码仓库发起 Git 推送请求**。
- 目标项目已启用 **允许来自允许列表项目的跨项目 Git 推送请求**。
- 目标项目已启用[作业令牌允许列表](#add-a-group-or-project-to-the-job-token-allowlist)。
- 源项目在目标项目的允许列表中，并具有 `admin_repositories` [细粒度权限](fine_grained_permissions.md)，或具有默认权限（未设置细粒度限制）。
  允许列表中包含源项目的群组条目也满足此要求。
- 启动流水线的用户对目标项目至少拥有开发者角色。

先决条件：

- 您必须对项目拥有维护者或所有者角色。

要允许跨项目推送请求：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 选择 **设置** > **CI/CD**。
1. 展开 **作业令牌权限**。
1. 在 **权限** 部分，选择 **允许向代码仓库发起 Git 推送请求**。
1. 选择 **允许来自允许列表项目的跨项目 Git 推送请求**。
1. 选择 **保存更改**。
1. [将源项目或其群组添加到允许列表](#add-a-group-or-project-to-the-job-token-allowlist)，并授予 `ADMIN_REPOSITORIES` 细粒度权限，或保留默认权限。

<a id="fine-grained-permissions-for-job-tokens"></a>

## 作业令牌的细粒度权限

您可以使用细粒度权限来显式允许访问一组有限的 REST API 端点。

有关更多信息，请参阅 [CI/CD 作业令牌的细粒度权限](fine_grained_permissions.md)。

<a id="git-repository-cloning"></a>

## Git 代码仓库克隆

您可以在 CI/CD 作业中使用作业令牌进行身份验证并克隆私有项目中的代码仓库。使用 `gitlab-ci-token` 作为用户名，作业令牌的值作为密码。

例如：

```shell
git clone https://gitlab-ci-token:${CI_JOB_TOKEN}@gitlab.example.com/<namespace>/<project>
```

即使 HTTPS 协议被[群组、项目或实例设置禁用](../../administration/settings/visibility_and_access_controls.md#configure-enabled-git-access-protocols)，您也可以使用此作业令牌克隆代码仓库。

<a id="rest-api-authentication"></a>

## REST API 身份验证

您可以使用作业令牌通过以下方法对特定 REST API 端点的请求进行身份验证：

- 请求头：`--header "JOB-TOKEN: $CI_JOB_TOKEN"`（推荐）
- 表单：`--form "token=$CI_JOB_TOKEN"`
- 数据：`--data "job_token=$CI_JOB_TOKEN"`
- URL 中的查询字符串：`?job_token=$CI_JOB_TOKEN`（不推荐）

例如，使用推荐的请求头方法：

```shell
curl --verbose --request POST --header "JOB-TOKEN: $CI_JOB_TOKEN" --form ref=master "https://gitlab.com/api/v4/projects/1234/trigger/pipeline"
```

有关令牌安全指南，请参阅[安全注意事项](../../security/tokens/_index.md#security-considerations)。

您不能使用作业令牌对 GraphQL 请求进行身份验证。

<a id="job-token-authentication-log"></a>

## 作业令牌身份验证日志

您可以在身份验证日志中跟踪哪些其他项目使用 CI/CD 作业令牌对您的项目进行身份验证。要查看日志：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **CI/CD**。
1. 展开 **作业令牌权限**。**身份验证日志** 部分会显示通过作业令牌进行身份验证访问您项目的其他项目列表。
1. 可选。选择 **下载 CSV** 以 CSV 格式下载完整的身份验证日志。

身份验证日志最多显示 100 条身份验证事件。如果事件数超过 100，请下载 CSV 文件以查看日志。

对项目的新身份验证最多可能需要 5 分钟才能出现在身份验证日志中。

<a id="use-legacy-format-for-cicd-tokens"></a>

## 为 CI/CD 令牌使用旧版格式

从极狐GitLab 19.0 开始，CI/CD 作业令牌默认使用 JWT 标准。项目可以通过为其项目配置顶级群组来继续使用旧版格式。此设置仅在极狐GitLab 20.0 版本发布前可用。

要为您的 CI/CD 令牌使用旧版格式：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **设置** > **CI/CD**。
1. 展开 **通用流水线**。
1. 关闭 **为 CI/CD 作业令牌启用 JWT 格式**。

您的 CI/CD 令牌现在使用旧版格式。如果您希望稍后再次使用 JWT 格式，可以重新启用此设置。

<a id="troubleshooting"></a>

## 故障排查

CI 作业令牌失败通常显示为类似 `404 Not Found` 的响应：

- 未授权的 Git 克隆：

  ```plaintext
  $ git clone https://gitlab-ci-token:$CI_JOB_TOKEN@gitlab.com/fabiopitino/test2.git

  Cloning into 'test2'...
  remote: The project you were looking for could not be found or you don't have permission to view it.
  fatal: repository 'https://gitlab-ci-token:[MASKED]@gitlab.com/<namespace>/<project>.git/' not found
  ```

- 未授权的软件包下载：

  ```plaintext
  $ wget --header="JOB-TOKEN: $CI_JOB_TOKEN" ${CI_API_V4_URL}/projects/1234/packages/generic/my_package/0.0.1/file.txt

  --2021-09-23 11:00:13--  https://gitlab.com/api/v4/projects/1234/packages/generic/my_package/0.0.1/file.txt
  Resolving gitlab.com (gitlab.com)... 172.65.251.78, 2606:4700:90:0:f22e:fbec:5bed:a9b9
  Connecting to gitlab.com (gitlab.com)|172.65.251.78|:443... connected.
  HTTP request sent, awaiting response... 404 Not Found
  2021-09-23 11:00:13 ERROR 404: Not Found.
  ```

- 未授权的 API 请求：

  ```plaintext
  $ curl --verbose --request POST --form "token=$CI_JOB_TOKEN" --form ref=master "https://gitlab.com/api/v4/projects/1234/trigger/pipeline"

  < HTTP/2 404
  < date: Thu, 23 Sep 2021 11:00:12 GMT
  {"message":"404 Not Found"}
  < content-type: application/json
  ```

在排查 CI/CD 作业令牌身份验证问题时，请注意：

- 有一个 [GraphQL 示例变更](../../api/graphql/getting_started.md#update-project-settings) 可用于切换每个项目的范围设置。
- [此评论](https://gitlab.com/gitlab-org/gitlab/-/issues/351740#note_1335673157) 演示了如何使用 Bash 和 cURL 结合 GraphQL 来：
  - 启用入站令牌访问范围。
  - 从项目 A 授予项目 B 访问权限，或将 B 添加到 A 的允许列表。
  - 移除项目访问权限。
- 如果作业不再运行、已被清除，或者项目正在被删除，则 CI 作业令牌将失效。

<a id="the-semantic-release-tool-and-job-tokens"></a>

### `semantic-release` 工具和作业令牌

如果您将 `semantic-release` 工具与 [**允许向代码仓库发起 Git 推送请求**设置](#allow-git-push-requests-to-your-project-repository)一起使用，则存在一个已知问题。启用后：

- 该工具会使用作业令牌进行身份验证，即使该工具配置为使用个人访问令牌。
- 作业令牌不会触发新的流水线，因此发布流水线可能不会运行。

有关更多信息，请参阅 [议题 891](https://github.com/semantic-release/gitlab/issues/891)。

<a id="jwt-format-job-token-errors"></a>

### JWT 格式作业令牌错误

CI/CD 作业令牌的 JWT 格式存在以下已知问题。

<a id="error-when-persisting-the-task-arn-error-with-ec2-fargate-runner-custom-executor"></a>

#### 使用 EC2 Fargate Runner 自定义执行器时出现 `Error when persisting the task ARN.` 错误

EC2 Fargate 自定义执行器的 `0.5.0` 及更早版本中存在[一个错误](https://gitlab.com/gitlab-org/ci-cd/custom-executor-drivers/fargate/-/issues/86)。此问题会导致以下错误：

- `Error when persisting the task ARN. Will stop the task for cleanup`

要修复此问题，请将 Fargate 自定义执行器升级到 `0.5.1` 或更高版本。

<a id="invalid-character-n-in-string-literal-error-with-base64-encoding"></a>

#### 使用 `base64` 编码时出现 `invalid character '\n' in string literal` 错误

如果您使用 `base64` 对作业令牌进行编码，您可能会收到 `invalid character '\n'` 错误。

`base64` 命令的默认行为是换行超过 79 个字符的字符串。当在作业执行期间使用 `base64` 对 JWT 格式的作业令牌进行编码时，例如使用 `echo $CI_JOB_TOKEN | base64`，令牌将变为无效。

要修复此问题，请使用 `base64 -w0` 禁用令牌的自动换行。

<a id="error-403-forbidden-in-long-running-jobs"></a>

#### 长时间运行的作业中出现 `403 Forbidden` 错误

在极狐GitLab 18.8 及更早版本中使用 JWT 格式作业令牌时，作业可能会因 `403 Forbidden` 错误而失败。这可能在以下情况中发生：

- 使用 [`needs`](../yaml/_index.md#needs) 的作业。
- [子流水线](../pipelines/downstream_pipelines.md#parent-child-pipelines)中的作业。
- 运行时间超过约 6 分钟且未产生控制台输出的作业。

该错误通常出现在 Runner 日志中，如下所示：

```plaintext
WARNING: Submitting job to coordinator... job failed
  code=403 job=<job_id> status=PUT https://gitlab.com/api/v4/jobs/<job_id>: 403 Forbidden
```

升级到极狐GitLab 18.9 以避免此问题。
