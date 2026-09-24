---
stage: Software Supply Chain Security
group: Pipeline Security
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: SLSA 出处规范
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com
- Status: Experiment

{{< /details >}}

{{< history >}}

- 在极狐GitLab 18.3 引入，并带有功能标志，命名为 `slsa_provenance_statement`。默认禁用。

{{< /history >}}

> [!flag]
> 此功能的可用性由功能标志控制。
> 欲了解更多信息，请参阅历史记录。
> 此功能可用于测试，但尚未准备好用于生产环境。

[SLSA 出处规范](https://slsa.dev/spec/v1.1/provenance) 要求记录并发布 `buildType` 引用。此引用旨在帮助极狐GitLab SLSA 证明的消费者解析极狐GitLab SLSA 出处声明中特有的特定字段。

有关更多详细信息，请参阅 SLSA [`buildType` 文档](https://slsa.dev/spec/v1.1/provenance#builddefinition)。

<a id="buildtype"></a>

## `构建类型`

此官方 [SLSA 出处](https://slsa.dev/spec/v1.1/provenance) `buildType` 引用：

- 描述极狐GitLab [CI/CD 作业](_index.md) 的执行。
- 由极狐GitLab 托管和维护。

<a id="description"></a>

### 描述

此 `构建类型` 描述了一个构建软件产物的工作流的执行。

> [!note]
> 消费者应忽略无法识别的外部参数。任何更改不得改变现有外部参数的语义。

<a id="external-parameters"></a>

### 外部参数

外部参数：

| 字段 | 值 |
|-------|-------|
| `source`     | 项目的 URL。 |
| `entryPoint` | 触发构建的 CI/CD 作业名称。 |
| `variables`  | 构建命令执行期间可用的任何 CI/CD 或环境变量的名称和值。如果变量被 [屏蔽或隐藏](../../../variables/_index.md)，则变量的值设置为 `[MASKED]`。 |

<a id="internal-parameters"></a>

### 内部参数

内部参数，默认情况下自动填充：

| 字段 | 值 |
|-------|-------|
| `name`         | runner 的名称。 |
| `executor`     | runner 执行器。 |
| `architecture` | 运行 CI/CD 作业的架构。 |
| `job`          | 触发构建的 CI/CD 作业的 ID。 |

<a id="example"></a>

### 示例

此示例展示了一个极狐GitLab 生成的出处声明的格式：

```json
{
  "_type": "https://in-toto.io/Statement/v1",
  "subject": [
    {
      "name": "artifacts.zip",
      "digest": {
        "sha256": "717a1ee89f0a2829cf5aad57054c83615675b04baa913bdc19999d7519edf3f2"
      }
    }
  ],
  "predicateType": "https://slsa.dev/provenance/v1",
  "predicate": {
    "buildDefinition": {
      "buildType": "<Link to Build Type>",
      "externalParameters": {
        "source": "http://gdk.test:3000/root/repo_name",
        "entryPoint": "build-job",
        "variables": {
          "CI_PIPELINE_ID": "576",
          "CI_PIPELINE_URL": "http://gdk.test:3000/root/repo_name/-/pipelines/576",
          "CI_JOB_ID": "412",

          [... additional environment variables ...]

          "masked_and_hidden_variable": "[MASKED]",
          "masked_variable": "[MASKED]",
          "visible_variable": "visible_variable",
        }
      },
      "internalParameters": {
        "architecture": "arm64",
        "executor": "docker",
        "job": 412,
        "name": "9-mfdkBG"
      },
      "resolvedDependencies": [
        {
          "uri": "http://gdk.test:3000/root/repo_name",
          "digest": {
            "gitCommit": "a288201509dd9a85da4141e07522bad412938dbe"
          }
        }
      ]
    },
    "runDetails": {
      "builder": {
        "id": "http://gdk.test:3000/groups/user/-/runners/33",
        "version": {
          "gitlab-runner": "4d7093e1"
        }
      },
      "metadata": {
        "invocationId": 412,
        "startedOn": "2025-06-05T01:33:18Z",
        "finishedOn": "2025-06-05T01:33:23Z"
      }
    }
  }
}
```