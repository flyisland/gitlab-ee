---
stage: Security Risk Management
group: Security Insights
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 项目漏洞 API
description: Project Vulnerabilities API for listing and creating project vulnerabilities. Requires authentication and appropriate permissions.
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- `last_edited_at` 已在极狐GitLab 16.7 中弃用。
- `start_date` 已在极狐GitLab 16.7 中弃用。
- `updated_by_id` 已在极狐GitLab 16.7 中弃用。
- `last_edited_by_id` 已在极狐GitLab 16.7 中弃用。
- `due_date` 已在极狐GitLab 16.7 中弃用。

{{< /history >}}

> [!warning]
> 此 API 正在被弃用，且被视为不稳定。
> 响应载荷可能在不同极狐GitLab 版本之间发生更改或破坏。
> 请改用 [GraphQL API](graphql/reference/_index.md#queryvulnerabilities)。

使用此 API 管理[项目漏洞](../user/application_security/vulnerabilities/_index.md)。
每次调用此 API 都需要身份验证。

如果用户不是私有项目的成员，对私有项目的请求会返回 `404 Not Found` 状态码。

<a id="list-project-vulnerabilities"></a>

## 列出项目漏洞

列出项目的所有漏洞。

如果经过身份验证的用户无权[使用项目安全仪表盘](../user/permissions.md#project-permissions)，
则对此项目漏洞的 `GET` 请求将导致 `403` 状态码。

响应是[分页的](rest/_index.md#pagination)，默认返回 20 条结果。

```plaintext
GET /projects/:id/vulnerabilities
```

| 属性     | 类型           | 是否必需 | 描述                                                                                                                                                                 |
| ------------- | -------------- | -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `id`          | 整数或字符串 | 是      | 项目 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)。                                                            |

```shell
curl --request GET \
    --header "PRIVATE-TOKEN: <your_access_token>" \
    --url "https://gitlab.example.com/api/v4/projects/4/vulnerabilities"
```

响应示例：

```json
[
    {
        "author_id": 1,
        "confidence": "medium",
        "created_at": "2020-04-07T14:01:04.655Z",
        "description": null,
        "dismissed_at": null,
        "dismissed_by_id": null,
        "finding": {
            "confidence": "medium",
            "created_at": "2020-04-07T14:01:04.630Z",
            "id": 103,
            "location_fingerprint": "228998b5db51d86d3b091939e2f5873ada0a14a1",
            "metadata_version": "2.0",
            "name": "Regular Expression Denial of Service in debug",
            "primary_identifier_id": 135,
            "project_id": 24,
            "raw_metadata": "{\"category\":\"dependency_scanning\",\"name\":\"Regular Expression Denial of Service\",\"message\":\"Regular Expression Denial of Service in debug\",\"description\":\"The debug module is vulnerable to regular expression denial of service when untrusted user input is passed into the `o` formatter. It takes around 50k characters to block for 2 seconds making this a low severity issue.\",\"cve\":\"yarn.lock:debug:gemnasium:37283ed4-0380-40d7-ada7-2d994afcc62a\",\"severity\":\"Unknown\",\"solution\":\"Upgrade to latest versions.\",\"scanner\":{\"id\":\"gemnasium\",\"name\":\"Gemnasium\"},\"location\":{\"file\":\"yarn.lock\",\"dependency\":{\"package\":{\"name\":\"debug\"},\"version\":\"1.0.5\"}},\"identifiers\":[{\"type\":\"gemnasium\",\"name\":\"Gemnasium-37283ed4-0380-40d7-ada7-2d994afcc62a\",\"value\":\"37283ed4-0380-40d7-ada7-2d994afcc62a\",\"url\":\"https://deps.sec.gitlab.com/packages/npm/debug/versions/1.0.5/advisories\"}],\"links\":[{\"url\":\"https://nodesecurity.io/advisories/534\"},{\"url\":\"https://github.com/visionmedia/debug/issues/501\"},{\"url\":\"https://github.com/visionmedia/debug/pull/504\"}],\"remediations\":[null]}",
            "report_type": "dependency_scanning",
            "scanner_id": 63,
            "severity": "low",
            "updated_at": "2020-04-07T14:01:04.664Z",
            "uuid": "f1d528ae-d0cc-47f6-a72f-936cec846ae7",
            "vulnerability_id": 103
        },
        "id": 103,
        "project": {
            "created_at": "2020-04-07T13:54:25.634Z",
            "description": "",
            "id": 24,
            "name": "security-reports",
            "name_with_namespace": "gitlab-org / security-reports",
            "path": "security-reports",
            "path_with_namespace": "gitlab-org/security-reports"
        },
        "project_default_branch": "main",
        "report_type": "dependency_scanning",
        "resolved_at": null,
        "resolved_by_id": null,
        "resolved_on_default_branch": false,
        "severity": "low",
        "state": "detected",
        "title": "Regular Expression Denial of Service in debug",
        "updated_at": "2020-04-07T14:01:04.655Z"
    }
]
```

<a id="create-a-vulnerability"></a>

## 创建漏洞

创建一个新漏洞。

如果经过身份验证的用户无权[创建新漏洞](../user/permissions.md#project-permissions)，
此请求将导致 `403` 状态码。

```plaintext
POST /projects/:id/vulnerabilities?finding_id=<your_finding_id>
```

| 属性           | 类型              | 是否必需   | 描述                                                                                                                  |
| ------------------- | ----------------- | ---------- | -----------------------------------------------------------------------------------------------------------------------------|
| `id`                | 整数或字符串 | 是        | 项目 ID 或 [URL 编码路径](rest/_index.md#namespaced-paths)，且经过身份验证的用户必须是其成员  |
| `finding_id`        | 整数或字符串 | 是        | 用于创建新漏洞的漏洞发现 ID |

新创建的漏洞的其他属性将根据其源漏洞发现来填充，或使用以下默认值：

| 属性    | 值                                                 |
|--------------|-------------------------------------------------------|
| `author`     | 经过身份验证的用户                                |
| `title`      | 漏洞发现的 `name` 属性       |
| `state`      | `opened`                                              |
| `severity`   | 漏洞发现的 `severity` 属性   |
| `confidence` | 漏洞发现的 `confidence` 属性 |

```shell
curl --request POST \
    --header "PRIVATE-TOKEN: <your_access_token>" \
    --url "https://gitlab.example.com/api/v4/projects/1/vulnerabilities?finding_id=1"
```

响应示例：

```json
{
    "author_id": 1,
    "confidence": "medium",
    "created_at": "2020-04-07T14:01:04.655Z",
    "description": null,
    "dismissed_at": null,
    "dismissed_by_id": null,
    "finding": {
        "confidence": "medium",
        "created_at": "2020-04-07T14:01:04.630Z",
        "id": 103,
        "location_fingerprint": "228998b5db51d86d3b091939e2f5873ada0a14a1",
        "metadata_version": "2.0",
        "name": "Regular Expression Denial of Service in debug",
        "primary_identifier_id": 135,
        "project_id": 24,
        "raw_metadata": "{\"category\":\"dependency_scanning\",\"name\":\"Regular Expression Denial of Service\",\"message\":\"Regular Expression Denial of Service in debug\",\"description\":\"The debug module is vulnerable to regular expression denial of service when untrusted user input is passed into the `o` formatter. It takes around 50k characters to block for 2 seconds making this a low severity issue.\",\"cve\":\"yarn.lock:debug:gemnasium:37283ed4-0380-40d7-ada7-2d994afcc62a\",\"severity\":\"Unknown\",\"solution\":\"Upgrade to latest versions.\",\"scanner\":{\"id\":\"gemnasium\",\"name\":\"Gemnasium\"},\"location\":{\"file\":\"yarn.lock\",\"dependency\":{\"package\":{\"name\":\"debug\"},\"version\":\"1.0.5\"}},\"identifiers\":[{\"type\":\"gemnasium\",\"name\":\"Gemnasium-37283ed4-0380-40d7-ada7-2d994afcc62a\",\"value\":\"37283ed4-0380-40d7-ada7-2d994afcc62a\",\"url\":\"https://deps.sec.gitlab.com/packages/npm/debug/versions/1.0.5/advisories\"}],\"links\":[{\"url\":\"https://nodesecurity.io/advisories/534\"},{\"url\":\"https://github.com/visionmedia/debug/issues/501\"},{\"url\":\"https://github.com/visionmedia/debug/pull/504\"}],\"remediations\":[null]}",
        "report_type": "dependency_scanning",
        "scanner_id": 63,
        "severity": "low",
        "updated_at": "2020-04-07T14:01:04.664Z",
        "uuid": "f1d528ae-d0cc-47f6-a72f-936cec846ae7",
        "vulnerability_id": 103
    },
    "id": 103,
    "project": {
        "created_at": "2020-04-07T13:54:25.634Z",
        "description": "",
        "id": 24,
        "name": "security-reports",
        "name_with_namespace": "gitlab-org / security-reports",
        "path": "security-reports",
        "path_with_namespace": "gitlab-org/security-reports"
    },
    "project_default_branch": "main",
    "report_type": "dependency_scanning",
    "resolved_at": null,
    "resolved_by_id": null,
    "resolved_on_default_branch": false,
    "severity": "low",
    "state": "detected",
    "title": "Regular Expression Denial of Service in debug",
    "updated_at": "2020-04-07T14:01:04.655Z"
}
```

<a id="errors"></a>

### 错误

当选择用于创建漏洞的发现未找到或已关联到其他漏洞时，会发生此错误：

```plaintext
未找到漏洞发现或已关联至其他漏洞
```

状态码：`400`

响应示例：

```json
{
  "message": {
    "base": [
      "finding is not found or is already attached to a vulnerability"
    ]
  }
}
```