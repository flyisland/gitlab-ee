---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 作业产物 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 下载、保留和删除[作业产物](../ci/jobs/job_artifacts.md)。

<a id="download-job-artifacts-by-job-id"></a>

## 按作业 ID 下载作业产物

使用作业 ID 下载作业的产物归档。要下载特定的报告文件（例如 JUnit 测试结果），请使用 `file_type` 属性。

如果您使用 cURL 从 JihuLab.com 下载产物，请使用 `--location` 参数，因为请求可能会通过 CDN 重定向。

```plaintext
GET /projects/:id/jobs/:job_id/artifacts
```

支持的属性：

| 属性   | 类型              | 是否必需 | 描述 |
| ----------- | ----------------- | -------- | ----------- |
| `id`        | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `job_id`    | integer           | 是      | 作业的 ID。 |
| `file_type` | string            | 否       | 要下载的产物类型。默认为 `archive`，即返回完整的产物归档。将此值设置为特定的报告类型，可直接下载该报告文件。可用类型：`accessibility`、`api_fuzzing`、`archive`、`browser_performance`、`cluster_image_scanning`、`cobertura`、`codequality`、`container_scanning`、`cyclonedx`、`dast`、`dependency_scanning`、`dotenv`、`jacoco`、`junit`、`license_scanning`、`load_performance`、`lsif`、`metrics`、`performance`、`requirements`、`requirements_v2`、`sarif`、`sast` 和 `secret_detection`。`performance` 和 `browser_performance` 共享一个报告组。如果作业同时上传了两者，则返回所请求的类型。如果作业只上传了其中之一，则无论请求的是哪种类型，都会返回该产物。 |
| `job_token` | string            | 否       | 用于多项目流水线的 CI/CD 作业令牌。仅专业版和旗舰版。 |

如果成功，返回 [`200`](rest/troubleshooting.md#status-codes) 并提供产物文件。如果 `file_type` 不是受支持的值，则返回 [`400`](rest/troubleshooting.md#status-codes)。

示例请求：

```shell
curl --request GET \
  --location \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/jobs/42/artifacts" \
  --output artifacts.zip
```

JUnit 测试报告的示例请求：

```shell
curl --request GET \
  --location \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/jobs/42/artifacts?file_type=junit" \
  --output junit.xml.gz
```

使用 CI/CD 作业令牌的示例请求：

```yaml
# Uses the job_token parameter
artifact_download:
  stage: test
  script:
    - 'curl --request GET \
         --location \
         --url "https://gitlab.example.com/api/v4/projects/1/jobs/42/artifacts?job_token=$CI_JOB_TOKEN" \
         --output artifacts.zip'
```

<a id="download-job-artifacts-by-reference-name"></a>

## 按引用名称下载作业产物

使用引用名称从最新的成功流水线中下载作业的产物归档。当 `search_recent_successful_pipelines=true` 时，搜索范围包括指定引用的最多 100 个最近成功的流水线。

最新的成功流水线根据创建时间确定。单个作业的开始或结束时间不会影响哪个流水线是最新的。

对于[父流水线和子流水线](../ci/pipelines/downstream_pipelines.md#parent-child-pipelines)，产物按从父到子的层级顺序搜索。如果父流水线和子流水线都有同名作业，则返回父流水线中的产物。

先决条件：

- 您必须有一个状态为 `success`的已完成流水线。
- 如果流水线包含手动作业，则这些作业必须满足以下任一条件：
  - 成功完成。
  - 设置了 `allow_failure: true`。

如果您使用 cURL 从 JihuLab.com 下载产物，请使用 `--location` 参数，因为请求可能会通过 CDN 重定向。

```plaintext
GET /projects/:id/jobs/artifacts/:ref_name/download?job=name
```

支持的属性：

| 属性   | 类型              | 是否必需 | 描述 |
| ----------- | ----------------- | -------- | ----------- |
| `id`        | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `job`       | string            | 是      | 作业的名称。 |
| `ref_name`  | string            | 是      | 代码仓库中的分支或标签名称。不支持 HEAD 或 SHA 引用。对于合并请求流水线，请使用 `refs/merge-requests/:iid/head` 而不是分支名称。 |
| `job_token` | string            | 否       | 用于多项目流水线的 CI/CD 作业令牌。仅专业版和旗舰版。 |
| `search_recent_successful_pipelines` | boolean | 否 | 在最近成功的流水线中搜索，而不仅仅是最新的一个。默认为 `false`。 |

如果成功，返回 [`200`](rest/troubleshooting.md#status-codes) 并提供产物文件。

如果未找到作业或产物，则返回 [`404`](rest/troubleshooting.md#status-codes)。

示例请求：

```shell
curl --request GET \
  --location \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/jobs/artifacts/main/download?job=test"
```

使用 CI/CD 作业令牌的示例请求：

```yaml
# Uses the job_token parameter
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

## 按作业 ID 下载单个产物文件

使用作业 ID 从作业的产物中下载单个文件。该文件会从归档中提取并流式传输到客户端。

如果您使用 cURL 从 JihuLab.com 下载产物，请使用 `--location` 参数，因为请求可能会通过 CDN 重定向。

```plaintext
GET /projects/:id/jobs/:job_id/artifacts/*artifact_path
```

支持的属性：

| 属性       | 类型              | 是否必需 | 描述 |
| --------------- | ----------------- | -------- | ----------- |
| `artifact_path` | string            | 是      | 产物归档中文件的路径。 |
| `id`            | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `job_id`        | integer           | 是      | 唯一的作业标识符。 |
| `job_token`     | string            | 否       | 用于多项目流水线的 CI/CD 作业令牌。仅专业版和旗舰版。 |

如果成功，返回 [`200`](rest/troubleshooting.md#status-codes) 并发送单个产物文件。

示例请求：

```shell
curl --request GET \
  --location \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/jobs/5/artifacts/some/release/file.pdf"
```

<a id="list-all-files-in-the-artifacts-archive"></a>

## 列出产物归档中的所有文件

列出指定作业的产物归档中的所有文件和目录。此操作读取产物元数据而不解压完整归档，因此浏览大型归档时效率很高。

```plaintext
GET /projects/:id/jobs/:job_id/artifacts/tree
```

支持的属性：

| 属性   | 类型              | 是否必需 | 描述 |
| ----------- | ----------------- | -------- | ----------- |
| `id`        | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `job_id`    | integer           | 是      | 作业的 ID。 |
| `path`      | string            | 否       | 要在产物归档中浏览的路径。默认为根目录。 |
| `recursive` | boolean           | 否       | 如果为 `true`，则递归返回所有条目。默认值：`false`。 |
| `job_token` | string            | 否       | 用于触发多项目流水线的 CI/CD 作业令牌。仅专业版和旗舰版。 |

此端点支持[分页](rest/_index.md#pagination)。

如果成功，返回 [`200`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性 | 类型    | 描述 |
|-----------|---------|-------------|
| `name`    | string  | 文件或目录名称。 |
| `path`    | string  | 产物归档中的完整路径。目录包含末尾斜杠。 |
| `type`    | string  | 条目类型。可能的值：`file`、`directory`。 |
| `size`    | integer | 文件大小（以字节为单位）。仅对文件存在。 |
| `mode`    | string  | 八进制格式的 Unix 文件模式。例如，文件为 `100644`，目录为 `040755`。 |

如果未找到作业、产物、产物元数据或指定的路径，则返回 [`404`](rest/troubleshooting.md#status-codes)。

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

递归列出的示例请求：

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/jobs/42/artifacts/tree?recursive=true"
```

使用 CI/CD 作业令牌的示例请求：

```yaml
# Uses the job_token parameter
list_artifacts:
  stage: test
  script:
    - 'curl --request GET \
         --url "https://gitlab.example.com/api/v4/projects/1/jobs/42/artifacts/tree?job_token=$CI_JOB_TOKEN"'
```

<a id="download-a-single-artifact-file-by-reference-name"></a>

## 按引用名称下载单个产物文件

使用引用名称从最新成功流水线中的作业产物里下载单个文件。该文件会从归档中提取，并以 `plain/text` 内容类型流式传输到客户端。当 `search_recent_successful_pipelines=true` 时，搜索范围包括指定引用的最多 100 个最近成功的流水线。

对于[父流水线和子流水线](../ci/pipelines/downstream_pipelines.md#parent-child-pipelines)，产物按从父到子的层级顺序搜索。如果父流水线和子流水线都有同名作业，则返回父流水线中的产物。

产物文件提供的详细信息比 [CSV 导出](../user/application_security/vulnerability_report/_index.md#exporting)中可用的信息更多。

先决条件：

- 您必须有一个状态为 `success`的已完成流水线。
- 如果流水线包含手动作业，则这些作业必须满足以下任一条件：
  - 成功完成。
  - 设置了 `allow_failure: true`。
- 要在最近成功的流水线中搜索，必须为项目启用 `ci_search_recent_successful_pipelines` 功能标志。

如果您使用 cURL 从 JihuLab.com 下载产物，请使用 `--location` 参数，因为请求可能会通过 CDN 重定向。

```plaintext
GET /projects/:id/jobs/artifacts/:ref_name/raw/*artifact_path?job=name
```

支持的属性：

| 属性       | 类型              | 是否必需 | 描述 |
| --------------- | ----------------- | -------- | ----------- |
| `artifact_path` | string            | 是      | 产物归档中文件的路径。 |
| `id`            | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `job`           | string            | 是      | 作业的名称。 |
| `ref_name`      | string            | 是      | 代码仓库中的分支或标签名称。不支持 `HEAD` 或 `SHA` 引用。对于合并请求流水线，请使用 `refs/merge-requests/:iid/head` 而不是分支名称。 |
| `job_token`     | string            | 否       | 用于多项目流水线的 CI/CD 作业令牌。仅专业版和旗舰版。 |
| `search_recent_successful_pipelines` | boolean | 否 | 在最近成功的流水线中搜索，而不仅仅是最新的一个。默认为 `false`。 |

如果成功，返回 [`200`](rest/troubleshooting.md#status-codes) 并发送单个产物文件。

如果未找到作业或产物文件，则返回 [`404`](rest/troubleshooting.md#status-codes)。

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

## 保留作业产物

防止作业的产物在达到过期日期时被自动删除。

```plaintext
POST /projects/:id/jobs/:job_id/artifacts/keep
```

支持的属性：

| 属性 | 类型              | 是否必需 | 描述 |
| --------- | ----------------- | -------- | ----------- |
| `id`      | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `job_id`  | integer           | 是      | 作业的 ID。 |

如果成功，返回 [`200`](rest/troubleshooting.md#status-codes) 以及作业详情。

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

## 删除作业产物

删除作业的产物。这包括归档文件、元数据以及[报告产物](../ci/yaml/artifacts_reports.md)，例如 JUnit 报告。此端点不会删除作业日志。删除后无法恢复产物。

要连同产物一起删除作业日志，请使用[擦除作业](jobs.md#erase-a-job) API 端点。

先决条件：

- 您必须拥有项目的维护者或所有者角色。

```plaintext
DELETE /projects/:id/jobs/:job_id/artifacts
```

支持的属性：

| 属性 | 类型              | 是否必需 | 描述 |
| --------- | ----------------- | -------- | ----------- |
| `id`      | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |
| `job_id`  | integer           | 是      | 作业的 ID。 |

如果成功，返回 [`204 No Content`](rest/troubleshooting.md#status-codes)。

示例请求：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/jobs/1/artifacts"
```

<a id="delete-all-job-artifacts-in-a-project"></a>

## 删除项目中的所有作业产物

删除项目中所有可删除的作业产物。产物删除后无法恢复。

默认情况下，极狐GitLab 会为每个引用保留最近完成的流水线和最近成功的流水线中的产物，无论是否过期。更多信息，请参见[保留最近成功作业中的产物](../ci/jobs/job_artifacts.md#keep-artifacts-from-most-recent-successful-jobs)。

对此端点的请求会将所有可删除的作业产物的过期时间设置为当前时间。随后，这些文件会在定期清理过期作业产物的过程中从系统中删除。作业日志永远不会被删除。

定期清理按计划异步进行，因此产物删除前可能会有短暂延迟。

先决条件：

- 您必须拥有项目的维护者或所有者角色。

```plaintext
DELETE /projects/:id/artifacts
```

支持的属性：

| 属性 | 类型           | 是否必需 | 描述 |
|-----------|----------------|----------|-------------|
| `id`      | integer or string | 是      | 项目的 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。 |

如果成功，返回 [`202 Accepted`](rest/troubleshooting.md#status-codes)。

示例请求：

```shell
curl --request DELETE \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/artifacts"
```

<a id="troubleshooting"></a>

## 故障排除

<a id="using-branch-names-with-merge-request-pipelines"></a>

### 将分支名称用于合并请求流水线

当您尝试使用分支名称作为 `ref_name` 下载作业产物时，可能会遇到 `404 Not Found` 错误。

出现此问题是因为合并请求流水线使用的引用格式与分支流水线不同。合并请求流水线运行在 `refs/merge-requests/:iid/head` 上，而不是直接运行在源分支上。

要下载合并请求流水线的作业产物，请使用 `refs/merge-requests/:iid/head` 作为 `ref_name`，而不是分支名称，其中 `:iid` 是合并请求 ID。在合并请求流水线中，该 ID 可从变量 `$CI_MERGE_REQUEST_IID` 获取，完整的 `ref_name` 可从变量 `$CI_MERGE_REQUEST_REF_PATH` 获取。

例如，对于合并请求 `!123`：

```shell
curl --request GET \
  --location \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/jobs/artifacts/refs/merge-requests/123/head/raw/file.txt?job=test"
```

<a id="downloading-artifactsreports-files"></a>

### 下载 `artifacts:reports` 文件

当您尝试使用作业产物 API 下载报告时，可能会遇到 `404 Not Found` 错误。

出现此问题是因为[报告](../ci/yaml/_index.md#artifactsreports)默认不包含在产物归档中。

要解决此问题，请使用[按作业 ID 下载作业产物](#download-job-artifacts-by-job-id)并将 `file_type` 设置为您想要的报告类型。

作为变通方法，您还可以通过将报告的文件名或 `gl-*-report.json` 添加到 [`artifacts:paths`](../ci/yaml/_index.md#artifactspaths)，将报告包含在产物归档本身中。
