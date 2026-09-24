---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 任务产物 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 下载、保留和删除[任务产物](../ci/jobs/job_artifacts.md)。

<a id="download-job-artifacts-by-job-id"></a>

## 通过任务 ID 下载任务产物

使用任务 ID 下载任务的产物存档。

如果你使用 cURL 从 JihuLab.com 下载产物，请使用 `--location` 参数，因为请求可能会通过 CDN 重定向。

```plaintext
GET /projects/:id/jobs/:job_id/artifacts
```

支持的属性：

| 属性      | 类型              | 是否必需 | 描述 |
| --------- | ----------------- | -------- | ----------- |
| `id`      | 整数或字符串     | 是      | ID 或[项目的 URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `job_id`  | 整数             | 是      | 任务的 ID。 |
| `job_token` | 字符串          | 否       | 用于多项目流水线的 CI/CD 任务令牌。仅专业版和旗舰版。 |

如果成功，返回 [`200`](rest/troubleshooting.md#status-codes) 并提供产物文件。

示例请求：

```shell
curl --request GET \
  --location \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/jobs/42/artifacts" \
  --output artifacts.zip
```

使用 CI/CD 任务令牌的示例请求：

```yaml
# 使用 job_token 参数
artifact_download:
  stage: test
  script:
    - 'curl --request GET \
         --location \
         --url "https://gitlab.example.com/api/v4/projects/1/jobs/42/artifacts?job_token=$CI_JOB_TOKEN" \
         --output artifacts.zip'
```

<a id="download-job-artifacts-by-reference-name"></a>

## 通过引用名称下载任务产物

{{< history >}}

- `search_recent_successful_pipelines` 属性在极狐GitLab 18.7 中引入，通过一个功能标志 `ci_search_recent_successful_pipelines`，默认禁用。
- 功能标志 `ci_search_recent_successful_pipelines` 在极狐GitLab 18.10 中移除。

{{< /history >}}

使用引用名称从最近成功的流水线下载任务的产物存档。当 `search_recent_successful_pipelines=true` 时，搜索会包括指定引用最多 100 条最近成功的流水线。

最近成功的流水线根据创建时间确定。个别任务的开始或结束时间不影响哪条流水线是最近的。

对于[父流水线和子流水线](../ci/pipelines/downstream_pipelines.md#parent-child-pipelines)，产物会按从父到子的层次顺序搜索。如果父流水线和子流水线都有一个同名的任务，则返回父流水线的产物。

先决条件：

- 你必须拥有一个状态为 `success` 的已完成流水线。
- 如果流水线包含手动任务，它们必须满足以下条件之一：
  - 成功完成。
  - 设置了 `allow_failure: true`。

如果你使用 cURL 从 JihuLab.com 下载产物，请使用 `--location` 参数，因为请求可能会通过 CDN 重定向。

```plaintext
GET /projects/:id/jobs/artifacts/:ref_name/download?job=name
```

支持的属性：

| 属性      | 类型              | 是否必需 | 描述 |
| --------- | ----------------- | -------- | ----------- |
| `id`      | 整数或字符串     | 是      | ID 或[项目的 URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `job`     | 字符串           | 是      | 任务名称。 |
| `ref_name` | 字符串           | 是      | 仓库中的分支或标签名称。不支持 HEAD 或 SHA 引用。对于合并请求流水线，请使用 `refs/merge-requests/:iid/head` 代替分支名称。 |
| `job_token` | 字符串          | 否       | 用于多项目流水线的 CI/CD 任务令牌。仅专业版和旗舰版。 |
| `search_recent_successful_pipelines` | 布尔值 | 否       | 搜索最近成功的流水线，而不仅仅是最新的那一条。默认为 `false`。 |

如果成功，返回 [`200`](rest/troubleshooting.md#status-codes) 并提供产物文件。

如果找不到任务或产物，返回 [`404`](rest/troubleshooting.md#status-codes)。

示例请求：

```shell
curl --request GET \
  --location \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/jobs/artifacts/main/download?job=test"
```

使用 CI/CD 任务令牌的示例请求：

```yaml
# 使用 job_token 参数
artifact_download:
  stage: test
  script:
    - 'curl --request GET \
         --location \
         --url "https://gitlab.example.com/api/v4/projects/$CI_PROJECT_ID/jobs/artifacts/main/download?job=test&job_token=$CI_JOB_TOKEN" \
         --output artifacts.zip'
```

使用最近流水线搜索的示例请求：

```shell
curl --request GET \
  --location \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/jobs/artifacts/main/download?job=test&search_recent_successful_pipelines=true"
```

<a id="download-a-single-artifact-file-by-job-id"></a>

## 通过任务 ID 下载单个产物文件

使用任务 ID 从任务的产物中下载单个文件。该文件从存档中提取并以流方式传输到客户端。

如果你使用 cURL 从 JihuLab.com 下载产物，请使用 `--location` 参数，因为请求可能会通过 CDN 重定向。

```plaintext
GET /projects/:id/jobs/:job_id/artifacts/*artifact_path
```

支持的属性：

| 属性       | 类型              | 是否必需 | 描述 |
| --------------- | ----------------- | -------- | ----------- |
| `artifact_path` | 字符串            | 是      | 产物存档中文件的路径。 |
| `id`            | 整数或字符串     | 是      | ID 或[项目的 URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `job_id`        | 整数             | 是      | 唯一任务标识符。 |
| `job_token`     | 字符串            | 否       | 用于多项目流水线的 CI/CD 任务令牌。仅专业版和旗舰版。 |

如果成功，返回 [`200`](rest/troubleshooting.md#status-codes) 并发送单个产物文件。

示例请求：

```shell
curl --request GET \
  --location \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/jobs/5/artifacts/some/release/file.pdf"
```

<a id="list-all-files-in-the-artifacts-archive"></a>

## 列出产物存档中的所有文件

{{< history >}}

- 在极狐GitLab 18.8 中引入。

{{< /history >}}

列出指定任务产物存档中的所有文件和目录。此操作读取产物元数据而无需提取完整存档，从而提高浏览大型存档的效率。

```plaintext
GET /projects/:id/jobs/:job_id/artifacts/tree
```

支持的属性：

| 属性   | 类型              | 是否必需 | 描述 |
| ----------- | ----------------- | -------- | ----------- |
| `id`        | 整数或字符串     | 是      | ID 或[项目的 URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `job_id`    | 整数             | 是      | 任务的 ID。 |
| `path`      | 字符串            | 否       | 产物存档中要浏览的路径。默认为根目录。 |
| `recursive` | 布尔值           | 否       | 如果为 `true`，则递归返回所有条目。默认: `false`。 |
| `job_token` | 字符串            | 否       | 用于触发多项目流水线的 CI/CD 任务令牌。仅专业版和旗舰版。 |

此端点支持[分页](rest/_index.md#pagination)。

如果成功，返回 [`200`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性 | 类型    | 描述 |
|-----------|---------|-------------|
| `name`    | 字符串  | 文件或目录名称。 |
| `path`    | 字符串  | 产物存档中的完整路径。目录包含尾部斜杠。 |
| `type`    | 字符串  | 条目类型。可能的值：`file`、`directory`。 |
| `size`    | 整数   | 文件大小（以字节为单位）。仅对文件存在。 |
| `mode`    | 字符串  | 以八进制格式表示的 Unix 文件模式。例如，文件为 `100644`，目录为 `040755`。 |

如果找不到任务、产物、产物元数据或指定路径，返回 [`404`](rest/troubleshooting.md#status-codes)。

示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/jobs/42/artifacts/tree"
```

示例响应：

```json
[
  {
    "name": "ci_build_artifacts.zip",
    "path": "ci_build_artifacts.zip",
    "type": "file",
    "size": 1024,
    "mode": "100644"
  },
  {
    "name": "other_artifacts_0.1.2",
    "path": "other_artifacts_0.1.2/",
    "type": "directory",
    "mode": "040755"
  }
]
```

浏览子目录的示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/jobs/42/artifacts/tree?path=coverage/reports"
```

递归列出示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/jobs/42/artifacts/tree?recursive=true"
```

使用 CI/CD 任务令牌的示例请求：

```yaml
# 使用 job_token 参数
list_artifacts:
  stage: test
  script:
    - 'curl --request GET \
         --url "https://gitlab.example.com/api/v4/projects/1/jobs/42/artifacts/tree?job_token=$CI_JOB_TOKEN"'
```

<a id="download-a-single-artifact-file-by-reference-name"></a>

## 通过引用名称下载单个产物文件

{{< history >}}

- `search_recent_successful_pipelines` 属性在极狐GitLab 18.9 中引入，通过一个功能标志 `ci_search_recent_successful_pipelines`，默认禁用。
- 功能标志 `ci_search_recent_successful_pipelines` 在极狐GitLab 18.10 中移除。

{{< /history >}}

使用引用名称从最近成功的流水线中下载任务的单个产物文件。该文件从存档中提取并以 `plain/text` 内容类型流式传输给客户端。当 `search_recent_successful_pipelines=true` 时，搜索包括指定引用最多 100 条最近成功的流水线。

对于[父流水线和子流水线](../ci/pipelines/downstream_pipelines.md#parent-child-pipelines)，产物会按从父到子的层次顺序搜索。如果父流水线和子流水线都有一个同名的任务，则返回父流水线的产物。

产物文件提供比 [CSV 导出](../user/application_security/vulnerability_report/_index.md#exporting)更详细的信息。

先决条件：

- 你必须拥有一个状态为 `success` 的已完成流水线。
- 如果流水线包含手动任务，它们必须满足以下条件之一：
  - 成功完成。
  - 设置了 `allow_failure: true`。
- 要搜索最近成功的流水线，必须为项目启用 `ci_search_recent_successful_pipelines` 功能标志。

如果你使用 cURL 从 JihuLab.com 下载产物，请使用 `--location` 参数，因为请求可能会通过 CDN 重定向。

```plaintext
GET /projects/:id/jobs/artifacts/:ref_name/raw/*artifact_path?job=name
```

支持的属性：

| 属性       | 类型              | 是否必需 | 描述 |
| --------------- | ----------------- | -------- | ----------- |
| `artifact_path` | 字符串            | 是      | 产物存档中文件的路径。 |
| `id`            | 整数或字符串     | 是      | ID 或[项目的 URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `job`           | 字符串            | 是      | 任务名称。 |
| `ref_name`      | 字符串            | 是      | 仓库中的分支或标签名称。不支持 `HEAD` 或 `SHA` 引用。对于合并请求流水线，请使用 `refs/merge-requests/:iid/head` 代替分支名称。 |
| `job_token`     | 字符串            | 否       | 用于多项目流水线的 CI/CD 任务令牌。仅专业版和旗舰版。 |
| `search_recent_successful_pipelines` | 布尔值 | 否       | 搜索最近成功的流水线，而不仅仅是最新的那一条。默认为 `false`。 |

如果成功，返回 [`200`](rest/troubleshooting.md#status-codes) 并发送单个产物文件。

如果找不到任务或产物文件，返回 [`404`](rest/troubleshooting.md#status-codes)。

示例请求：

```shell
curl --request GET \
  --location \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/jobs/artifacts/main/raw/some/release/file.pdf?job=pdf"
```

使用最近流水线搜索的示例请求：

```shell
curl --request GET \
  --location \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/jobs/artifacts/main/raw/some/release/file.pdf?job=pdf&search_recent_successful_pipelines=true"
```

<a id="keep-job-artifacts"></a>

## 保留任务产物

阻止任务的产物在到达过期日期时被自动删除。

```plaintext
POST /projects/:id/jobs/:job_id/artifacts/keep
```

支持的属性：

| 属性 | 类型              | 是否必需 | 描述 |
| --------- | ----------------- | -------- | ----------- |
| `id`      | 整数或字符串     | 是      | ID 或[项目的 URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `job_id`  | 整数             | 是      | 任务的 ID。 |

如果成功，返回 [`200`](rest/troubleshooting.md#status-codes) 和任务详细信息。

示例请求：

```shell
curl --request POST \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/jobs/1/artifacts/keep"
```

示例响应：

```json
{
  "commit": {
    "author_email": "admin@example.com",
    "author_name": "Administrator",
    "created_at": "2015-12-24T16:51:14.000+01:00",
    "id": "0ff3ae198f8601a285adcf5c0fff204ee6fba5fd",
    "message": "Test the CI integration.",
    "short_id": "0ff3ae19",
    "title": "Test the CI integration."
  },
  "coverage": null,
  "allow_failure": false,
  "download_url": null,
  "id": 42,
  "name": "rubocop",
  "ref": "main",
  "artifacts": [],
  "runner": null,
  "stage": "test",
  "created_at": "2016-01-11T10:13:33.506Z",
  "started_at": "2016-01-11T10:13:33.506Z",
  "finished_at": "2016-01-11T10:15:10.506Z",
  "duration": 97.0,
  "status": "failed",
  "failure_reason": "script_failure",
  "tag": false,
  "web_url": "https://example.com/foo/bar/-/jobs/42",
  "user": null
}
```

<a id="delete-job-artifacts"></a>

## 删除任务产物

删除与特定任务关联的所有产物。产物删除后无法恢复。

先决条件：

- 你必须拥有项目的维护者或所有者角色。

```plaintext
DELETE /projects/:id/jobs/:job_id/artifacts
```

支持的属性：

| 属性 | 类型              | 是否必需 | 描述 |
| --------- | ----------------- | -------- | ----------- |
| `id`      | 整数或字符串     | 是      | ID 或[项目的 URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `job_id`  | 整数             | 是      | 任务的 ID。 |

如果成功，返回 [`204 No Content`](rest/troubleshooting.md#status-codes)。

示例请求：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/jobs/1/artifacts"
```

<a id="delete-all-job-artifacts-in-a-project"></a>

## 删除项目中的所有任务产物

删除项目中所有可删除的任务产物。产物删除后无法恢复。

默认情况下，来自[每个引用的最近成功流水线](../ci/jobs/job_artifacts.md#keep-artifacts-from-most-recent-successful-jobs)的产物不会被删除。

对此端点的请求将所有可删除的任务产物的过期时间设置为当前时间。文件随后作为过期任务产物常规清理的一部分从系统中删除。任务日志永远不会被删除。

常规清理按计划异步进行，因此在产物被删除之前可能会有短暂延迟。

先决条件：

- 你必须拥有项目的维护者或所有者角色。

```plaintext
DELETE /projects/:id/artifacts
```

支持的属性：

| 属性 | 类型           | 是否必需 | 描述 |
|-----------|----------------|----------|-------------|
| `id`      | 整数或字符串 | 是      | ID 或[项目的 URL 编码路径](rest/_index.md#namespaced-paths)。 |

如果成功，返回 [`202 Accepted`](rest/troubleshooting.md#status-codes)。

示例请求：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/artifacts"
```

<a id="troubleshooting"></a>

## 疑难解答

<a id="using-branch-names-with-merge-request-pipelines"></a>

### 在合并请求流水线中使用分支名称

当尝试使用分支名称作为 `ref_name` 下载任务产物时，你可能会遇到 `404 Not Found` 错误。

出现此问题是因为合并请求流水线使用了与分支流水线不同的引用格式。合并请求流水线在 `refs/merge-requests/:iid/head` 上运行，而不是直接在源分支上运行。

要下载合并请求流水线的任务产物，请使用 `refs/merge-requests/:iid/head` 作为 `ref_name` 而不是分支名称，其中 `:iid` 是合并请求 ID。在合并请求流水线中，该 ID 可从变量 `$CI_MERGE_REQUEST_IID` 获取，完整的 `ref_name` 可从变量 `$CI_MERGE_REQUEST_REF_PATH` 获取。

例如，对于合并请求 `!123`：

```shell
curl --request GET \
  --location \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/jobs/artifacts/refs/merge-requests/123/head/raw/file.txt?job=test"
```

<a id="downloading-artifacts-reports-files"></a>

### 下载 `artifacts:reports` 文件

当尝试使用任务产物 API 下载报告时，你可能会遇到 `404 Not Found` 错误。

出现此问题是因为默认情况下[报告](../ci/yaml/_index.md#artifactsreports)不可下载。

要使报告可下载，请将其文件名或 `gl-*-report.json` 添加到 [`artifacts:paths`](../ci/yaml/_index.md#artifactspaths) 中。