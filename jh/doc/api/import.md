---
stage: Create
group: Import
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 导入 API
description: "Import repositories from GitHub or Bitbucket Server with the REST API."
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 当导入到个人命名空间时，将贡献重新分配给个人命名空间所有者，已在极狐GitLab 18.3 中引入，并带有一个功能标志 `user_mapping_to_personal_namespace_owner`，默认禁用。
- 当导入到个人命名空间时，将贡献重新分配给个人命名空间所有者，已在极狐GitLab 18.6 中 GA，功能标志 `user_mapping_to_personal_namespace_owner` 已移除。

{{< /history >}}

> [!flag]
> 此功能的可用性由功能标志控制。
> 更多信息，请参见历史记录。

使用此 API 从外部源[导入仓库](../user/import/_index.md)。

> [!note]
> 当您将项目导入到[个人命名空间](../user/namespace/_index.md#types-of-namespaces)时，不支持用户贡献映射。
> 当您导入到个人命名空间时，所有贡献都将分配给个人命名空间所有者，并且无法重新分配。

<a id="import-repository-from-github"></a>

## 从 GitHub 导入仓库

{{< history >}}

- 在极狐GitLab 16.0 中引入了要求维护者角色而非开发者角色，并向后移植到极狐GitLab 15.11.1 和 15.10.5。
- `optional_stages` 中的 `collaborators_import` 键在极狐GitLab 16.0 中引入。
- 功能标志 `github_import_extended_events` 在极狐GitLab 16.8 中引入，默认禁用。此标志提高了导入性能，但禁用了 `single_endpoint_issue_events_import` 可选阶段。
- 功能标志 `github_import_extended_events` 在极狐GitLab 16.9 中于 JihuLab.com 和私有化部署实例上启用。
- 改进的导入性能在极狐GitLab 16.11 中 GA，功能标志 `github_import_extended_events` 已移除。

{{< /history >}}

从 GitHub 导入仓库到极狐GitLab。

先决条件：

- [GitHub 导入器的先决条件](../user/project/import/github.md#prerequisites)。
- `target_namespace` 中设置的命名空间必须存在。
- 命名空间可以是您的用户命名空间，或者您拥有维护者或所有者角色的现有群组。

```plaintext
POST /import/github
```

| 属性                   | 类型    | 必需 | 描述 |
|-------------------------|---------|----------|-------------|
| `personal_access_token` | string  | 是      | GitHub 个人访问令牌。 |
| `repo_id`               | integer | 是      | GitHub 仓库 ID。 |
| `target_namespace`      | string  | 是      | 要导入仓库的命名空间。支持子群组，如 `/namespace/subgroup`。不能为空。 |
| `github_hostname`       | string  | 否       | 自定义 GitHub Enterprise 主机名。对于 GitHub.com 不要设置。从极狐GitLab 16.5 到 17.1，必须包含路径 `/api/v3`。 |
| `new_name`              | string  | 否       | 新项目的名称。也用作新路径，因此不能以特殊字符开头或结尾，且不能包含连续的特殊字符。 |
| `optional_stages`       | object  | 否       | [要导入的额外项](../user/project/import/github.md#select-additional-items-to-import)。 |
| `pagination_limit`      | integer | 否       | 每个 API 请求从 GitHub 检索的项目数。默认值为每页 100 个项目。对于从大型仓库导入项目，较小的数字可以降低 GitHub API 端点返回 `500` 或 `502` 错误的风险。但是，较小的页面大小会增加迁移时间。 |
| `timeout_strategy`      | string  | 否       | 处理导入超时的策略。有效值为 `optimistic`（继续到下一导入阶段）或 `pessimistic`（立即失败）。默认为 `pessimistic`。在极狐GitLab 16.5 中[引入](https://jihulab.com/gitlab-cn/gitlab/-/issues/422979)。 |

```shell
curl --request POST \
  --url "https://gitlab.example.com/api/v4/import/github" \
  --header "content-type: application/json" \
  --header "Authorization: Bearer <your_access_token>" \
  --data '{
    "personal_access_token": "aBc123abC12aBc123abC12abC123+_A/c123",
    "repo_id": "12345",
    "target_namespace": "group/subgroup",
    "new_name": "NEW-NAME",
    "github_hostname": "https://github.example.com",
    "optional_stages": {
      "single_endpoint_notes_import": true,
      "attachments_import": true,
      "collaborators_import": true
    }
}'
```

`optional_stages` 可用的键如下：

- `attachments_import`，用于 Markdown 附件导入。
- `collaborators_import`，用于导入非外部协作者的直接仓库协作者。
- `single_endpoint_issue_events_import`，用于议题和拉取请求事件导入。此可选阶段在极狐GitLab 16.9 中已移除。
- `single_endpoint_notes_import`，用于替代且更彻底的评论导入。

更多信息，请参见[选择要导入的额外项](../user/project/import/github.md#select-additional-items-to-import)。

示例响应：

```json
{
    "id": 27,
    "name": "my-repo",
    "full_path": "/root/my-repo",
    "full_name": "Administrator / my-repo",
    "refs_url": "/root/my-repo/refs",
    "import_source": "my-github/repo",
    "import_status": "scheduled",
    "human_import_status_name": "scheduled",
    "provider_link": "/my-github/repo",
    "relation_type": null,
    "import_warning": null
}
```

<a id="import-a-public-project-through-the-api-using-a-group-access-token"></a>

### 通过 API 使用群组访问令牌导入公共项目

当您通过 API 使用群组访问令牌从 GitHub 导入项目到极狐GitLab 时：

- 极狐GitLab 项目继承原始项目的可见性设置。因此，如果原始项目是公共的，该项目也是公共可访问的。
- 如果 `path` 或 `target_namespace` 不存在，项目导入将失败。

<a id="cancel-github-project-import"></a>

### 取消 GitHub 项目导入

取消正在进行的 GitHub 项目导入。

```plaintext
POST /import/github/cancel
```

| 属性    | 类型    | 必需 | 描述 |
|--------------|---------|----------|-------------|
| `project_id` | integer | 是      | 极狐GitLab 项目 ID。 |

```shell
curl --request POST \
  --url "https://gitlab.example.com/api/v4/import/github/cancel" \
  --header "content-type: application/json" \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --data '{
    "project_id": 12345
}'
```

示例响应：

```json
{
    "id": 160,
    "name": "my-repo",
    "full_path": "/root/my-repo",
    "full_name": "Administrator / my-repo",
    "import_source": "source/source-repo",
    "import_status": "canceled",
    "human_import_status_name": "canceled",
    "provider_link": "/source/source-repo"
}
```

返回以下状态码：

- `200 OK`：项目导入正在被取消。
- `400 Bad Request`：无法取消项目导入。
- `404 Not Found`：与 `project_id` 关联的项目不存在。

<a id="import-github-gists-into-gitlab-snippets"></a>

### 将 GitHub Gist 导入到极狐GitLab 代码片段

将个人 GitHub Gist 导入到极狐GitLab 代码片段中。您可以导入最多包含 10 个文件的 Gist。超过 10 个文件的 GitHub Gist 将被跳过。您应手动迁移这些 GitHub Gist。

如果有任何 Gist 无法导入，将发送一封电子邮件，列出未导入的 Gist。

```plaintext
POST /import/github/gists
```

| 属性               | 类型   | 必需 | 描述 |
|-------------------------|--------|----------|-------------|
| `personal_access_token` | string | 是      | GitHub 个人访问令牌。 |

```shell
curl --request POST \
  --url "https://gitlab.example.com/api/v4/import/github/gists" \
  --header "content-type: application/json" \
  --header "PRIVATE-TOKEN: <your_gitlab_access_token>" \
  --data '{
    "personal_access_token": "<your_github_personal_access_token>"
}'
```

返回以下状态码：

- `202 Accepted`：Gist 导入已开始。
- `401 Unauthorized`：用户的 GitHub 个人访问令牌无效。
- `422 Unprocessable Entity`：Gist 导入已在进行中。
- `429 Too Many Requests`：用户已超出 GitHub 的速率限制。

<a id="import-repository-from-bitbucket-server"></a>

## 从 Bitbucket Server 导入仓库

从 Bitbucket Server 导入仓库到极狐GitLab。

Bitbucket 项目键仅用于在 Bitbucket 中查找仓库。
如果您想将仓库导入到极狐GitLab 群组，则必须指定 `target_namespace`。
如果不指定 `target_namespace`，项目将导入到您的个人用户命名空间。

先决条件：

- 更多信息，请参见 [Bitbucket Server 导入器的先决条件](../user/import/bitbucket_server.md)。

```plaintext
POST /import/bitbucket_server
```

| 属性                   | 类型   | 必需 | 描述 |
|-----------------------------|--------|----------|-------------|
| `bitbucket_server_project`  | string | 是      | Bitbucket 项目键。 |
| `bitbucket_server_repo`     | string | 是      | Bitbucket 仓库名称。 |
| `bitbucket_server_url`      | string | 是      | Bitbucket Server URL。 |
| `bitbucket_server_username` | string | 是      | Bitbucket Server 用户名。 |
| `personal_access_token`     | string | 是      | Bitbucket Server 个人访问令牌或密码。 |
| `new_name`                  | string | 否       | 新项目的名称。也用作新路径，因此不能以特殊字符开头或结尾，且不能包含连续的特殊字符。在极狐GitLab 16.9 及更早版本中，项目路径[从 Bitbucket 复制](https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/88845)。在极狐GitLab 16.10 中，行为[恢复](https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/145793)为原始行为。 |
| `target_namespace`          | string | 否       | 要导入仓库的命名空间。支持子群组，如 `/namespace/subgroup`。 |
| `timeout_strategy`          | string | 否       | 处理导入超时的策略。有效值为 `optimistic`（继续到下一导入阶段）或 `pessimistic`（立即失败）。默认为 `pessimistic`。在极狐GitLab 16.5 中[引入](https://jihulab.com/gitlab-cn/gitlab/-/issues/422979)。 |

```shell
curl --request POST \
  --url "https://gitlab.example.com/api/v4/import/bitbucket_server" \
  --header "content-type: application/json" \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --data '{
    "bitbucket_server_url": "http://bitbucket.example.com",
    "bitbucket_server_username": "root",
    "personal_access_token": "Nzk4MDcxODY4MDAyOiP8y410zF3tGAyLnHRv/E0+3xYs",
    "bitbucket_server_project": "NEW",
    "bitbucket_server_repo": "my-repo",
    "new_name": "NEW-NAME"
}'
```

<a id="import-repository-from-bitbucket-cloud"></a>

## 从 Bitbucket Cloud 导入仓库

{{< history >}}

- 在极狐GitLab 17.0 中引入。
- 在极狐GitLab 18.9 中添加了对 Bitbucket Cloud API 令牌的支持。
- 在极狐GitLab 19.0 中移除了对 Bitbucket Cloud 应用密码的支持。

{{< /history >}}

从 Bitbucket Cloud 导入仓库到极狐GitLab。

先决条件：

- [Bitbucket Cloud 导入器的先决条件](../user/import/bitbucket_cloud.md)。
- 具有所需范围的 [Bitbucket Cloud API 令牌](#bitbucket-cloud-api-token-scopes)。

```plaintext
POST /import/bitbucket
```

| 属性             | 类型   | 必需 | 描述 |
|:----------------------|:-------|:---------|:------------|
| `bitbucket_api_token` | string | 是      | Bitbucket Cloud API 令牌。 |
| `bitbucket_email`     | string | 是      | Bitbucket Cloud 电子邮件。 |
| `repo_path`           | string | 是      | 仓库路径。 |
| `target_namespace`    | string | 是      | 要导入仓库的命名空间。支持子群组，如 `/namespace/subgroup`。 |
| `new_name`            | string | 否       | 新项目的名称。也用作新路径，因此不能以特殊字符开头或结尾，且不能包含连续的特殊字符。 |

```shell
curl --request POST \
  --url "https://gitlab.example.com/api/v4/import/bitbucket" \
  --header "content-type: application/json" \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --data '{
    "bitbucket_email": "email@example.com",
    "bitbucket_api_token": "your_bitbucket_api_token",
    "repo_path": "username/my_project",
    "target_namespace": "my_group/my_subgroup",
    "new_name": "new_project_name"
}'
```

<a id="bitbucket-cloud-api-token-scopes"></a>

### Bitbucket Cloud API 令牌范围

如果您使用 Bitbucket Cloud API 令牌进行身份验证，令牌必须具有以下范围：

- `read:repository:bitbucket`
- `read:pullrequest:bitbucket`
- `read:issue:bitbucket`
- `read:wiki:bitbucket`

