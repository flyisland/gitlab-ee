---
stage: Verify
group: Pipeline Authoring
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: CI 配置检查 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用该 API 来[验证你的极狐GitLab CI/CD 配置](../ci/yaml/lint.md)。

这些端点使用 JSON 编码的 YAML 内容。在某些情况下，可以使用第三方工具如 [`jq`](https://jqlang.org/) 在请求前正确格式化你的 YAML 内容。如果你想保持你的 CI/CD 配置格式，这会很有帮助。

例如，以下命令使用 JQ 对给定的 YAML 文件进行正确转义、编码为 JSON，并向 API 发起请求。

```shell
jq --null-input --arg yaml "$(<example-gitlab-ci.yml)" '.content=$yaml' \
| curl --url "https://gitlab.com/api/v4/projects/:id/ci/lint?include_merged_yaml=true" \
--header 'Content-Type: application/json' \
--data @-
```

1. 创建一个名为 `example-gitlab-ci.yml` 的 YAML 文件：

   ```yaml
   .api_test:
     rules:
       - if: $CI_PIPELINE_SOURCE=="merge_request_event"
         changes:
           - src/api/*
   deploy:
     extends:
       - .api_test
     rules:
       - when: manual
         allow_failure: true
     script:
       - echo "hello world"
   ```

1. 要转义并编码输入 YAML 文件（`example-gitlab-ci.yml`）然后 `POST` 到极狐GitLab API，创建一个组合 `curl` 和 `jq` 的单行命令：

   ```shell
   jq --null-input --arg yaml "$(<example-gitlab-ci.yml)" '.content=$yaml' \
   | curl --url "https://gitlab.com/api/v4/projects/:id/ci/lint?include_merged_yaml=true" \
       --header 'Content-Type: application/json' \
       --data @-
   ```

<a id="parse-responses-from-this-api"></a>

## 解析此 API 的响应

要重新格式化 CI Lint API 的响应，可以：

- 将 CI Lint 响应直接通过管道传递给 `jq`。
- 将 API 响应保存为文本文件，并将其作为参数提供给 `jq`，像这样：

  ```shell
  jq --raw-output '.merged_yaml | fromjson' <your_input_here>
  ```

例如，这个 JSON 数组：

```json
{"valid":"true","errors":[],"merged_yaml":"---\n.api_test:\n  rules:\n  - if: $CI_PIPELINE_SOURCE==\"merge_request_event\"\n    changes:\n    - src/api/*\ndeploy:\n  rules:\n  - when: manual\n    allow_failure: true\n  extends:\n  - \".api_test\"\n  script:\n  - echo \"hello world\"\n"}
```

解析并重新格式化后，生成的 YAML 文件包含：

```yaml
.api_test:
  rules:
  - if: $CI_PIPELINE_SOURCE=="merge_request_event"
    changes:
    - src/api/*
deploy:
  rules:
  - when: manual
    allow_failure: true
  extends:
  - ".api_test"
  script:
  - echo "hello world"
```

<a id="validate-cicd-configuration"></a>

## 验证 CI/CD 配置

验证指定项目的 `.gitlab-ci.yml` 配置。此端点会在项目上下文中验证 CI/CD 配置，包括：

- 使用项目的 CI/CD 变量。
- 在项目文件中搜索 `include:local` 条目。

```plaintext
POST /projects/:id/ci/lint
```

| 属性      | 类型    | 必需 | 描述 |
|----------------|---------|----------|-------------|
| `content`      | string  | 是      | CI/CD 配置内容。 |
| `dry_run`      | boolean | 否       | 运行[流水线创建模拟](../ci/yaml/lint.md#simulate-a-pipeline)，或仅进行静态检查。默认值：`false`。 |
| `include_jobs` | boolean | 否       | 如果在静态检查或流水线模拟中存在的作业列表应包含在响应中。默认值：`false`。 |
| `ref`          | string  | 否       | 当 `dry_run` 为 `true` 时，设置用于验证 CI/CD YAML 配置的分支或标签上下文。未设置时默认为项目的默认分支。 |

请求示例：

```shell
curl --request POST \
  --header "Content-Type: application/json" \
  --url "https://gitlab.example.com/api/v4/projects/:id/ci/lint" \
  --data @- <<'EOF'
{
  "content": "{
    \"image\": \"ruby:2.6\",
    \"services\": [\"postgres\"],
    \"before_script\": [
      \"bundle install\",
      \"bundle exec rake db:create\"
    ],
    \"variables\": {
      \"DB_NAME\": \"postgres\"
    },
    \"stages\": [\"test\", \"deploy\", \"notify\"],
    \"rspec\": {
      \"script\": \"rake spec\",
      \"tags\": [\"ruby\", \"postgres\"],
      \"only\": [\"branches\"]
    }
  }"
}
EOF
```

响应示例：

- 有效配置：

  ```json
  {
    "valid": true,
    "merged_yaml": "---\ntest_job:\n  script: echo 1\n",
    "errors": [],
    "warnings": [],
    "includes": []
  }
  ```

- 无效配置：

  ```json
  {
    "valid": false,
    "errors": [
      "jobs config should contain at least one visible job"
    ],
    "warnings": [],
    "merged_yaml": "---\n\".job\":\n  script:\n  - echo \"A hidden job\"\n",
    "includes": []
  }
  ```

<a id="validate-existing-cicd-configuration"></a>

## 验证现有 CI/CD 配置

{{< history >}}

- `sha` 属性在极狐GitLab 16.5 中引入。
- `sha` 和 `ref` 在极狐GitLab 16.10 中重命名为 `content_ref` 和 `dry_run_ref`。

{{< /history >}}

验证指定项目的现有 `.gitlab-ci.yml` 配置。此端点会在项目上下文中验证 CI/CD 配置，包括：

- 使用项目的 CI/CD 变量。
- 在项目文件中搜索 `include:local` 条目。

```plaintext
GET /projects/:id/ci/lint
```

| 属性      | 类型    | 必需 | 描述 |
|----------------|---------|----------|-------------|
| `content_ref`  | string  | 否       | CI/CD 配置内容取自该提交 SHA、分支或标签。未设置时默认为项目默认分支头部的 SHA。 |
| `dry_run`      | boolean | 否       | 运行流水线创建模拟，或仅进行静态检查。 |
| `dry_run_ref`  | string  | 否       | 当 `dry_run` 为 `true` 时，设置用于验证 CI/CD YAML 配置的分支或标签上下文。未设置时默认为项目的默认分支。 |
| `include_jobs` | boolean | 否       | 如果在静态检查或流水线模拟中存在的作业列表应包含在响应中。默认值：`false`。 |
| `ref`          | string  | 否       | （已弃用）当 `dry_run` 为 `true` 时，设置用于验证 CI/CD YAML 配置的分支或标签上下文。未设置时默认为项目的默认分支。改用 `dry_run_ref`。 |
| `sha`          | string  | 否       | （已弃用）CI/CD 配置内容取自该提交 SHA、分支或标签。未设置时默认为项目默认分支头部的 SHA。改用 `content_ref`。 |

请求示例：

```shell
curl --request GET \
  --url "https://gitlab.example.com/api/v4/projects/:id/ci/lint"
```

响应示例：

- 有效配置，具有 `include.yml` 作为[包含文件](../ci/yaml/_index.md#include) 且 `include_jobs` 设置为 `true`：

  ```json
  {
    "valid": true,
    "errors": [],
    "warnings": [],
    "merged_yaml": "---\ninclude-job:\n  script:\n  - echo \"An included job\"\njob:\n  rules:\n  - if: \"$CI_COMMIT_BRANCH\"\n  script:\n  - echo \"A test job\"\n",
    "includes": [
      {
        "type": "local",
        "location": "include.yml",
        "blob": "https://gitlab.example.com/test-group/test-project/-/blob/ef5014c045873c5c4ffeb7a2f5be021a1d3ed703/include.yml",
        "raw": "https://gitlab.example.com/test-group/test-project/-/raw/ef5014c045873c5c4ffeb7a2f5be021a1d3ed703/include.yml",
        "extra": {},
        "context_project": "test-group/test-project",
        "context_sha": "ef5014c045873c5c4ffeb7a2f5be021a1d3ed703"
      }
    ],
    "jobs": [
      {
        "name": "include-job",
        "stage": "test",
        "before_script": [],
        "script": [
          "echo \"An included job\""
        ],
        "after_script": [],
        "tag_list": [],
        "only": {
          "refs": [
            "branches",
            "tags"
          ]
        },
        "except": null,
        "environment": null,
        "when": "on_success",
        "allow_failure": false,
        "needs": null
      },
      {
        "name": "job",
        "stage": "test",
        "before_script": [],
        "script": [
          "echo \"A test job\""
        ],
        "after_script": [],
        "tag_list": [],
        "only": null,
        "except": null,
        "environment": null,
        "when": "on_success",
        "allow_failure": false,
        "needs": null
      }
    ]
  }
  ```

- 无效配置：

  ```json
  {
    "valid": false,
    "errors": [
      "jobs config should contain at least one visible job"
    ],
    "warnings": [],
    "merged_yaml": "---\n\".job\":\n  script:\n  - echo \"A hidden job\"\n",
    "includes": []
  }
  ```