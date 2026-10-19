---
stage: Deploy
group: MLOps
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 模型仓库 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 与机器学习[模型仓库](../user/project/ml/model_registry/_index.md)进行交互。

每个端点中的 `:model_version_id` 属性接受模型版本 ID 或候选运行 ID。详情请参见[模型版本和候选 ID](#model-version-and-candidate-ids)。

<a id="download-a-machine-learning-model-package-file"></a>

## 下载机器学习模型包文件

下载机器学习模型包中指定的文件。

```plaintext
GET /api/v4/projects/:id/packages/ml_models/:model_version_id/files/(*path/):file_name
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
| --- | --- | --- | --- |
| `id` | 整数或字符串 | 是 | 项目 ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths)。 |
| `model_version_id` | 整数或字符串 | 是 | 模型版本 ID 或候选运行 ID。参见[模型版本和候选 ID](#model-version-and-candidate-ids)。 |
| `file_name` | 字符串 | 是 | 文件名。 |
| `path` | 字符串 | 否 | 文件的目录路径。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes) 并返回文件内容。

请求示例：

```shell
curl --header "Authorization: Bearer <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/packages/ml_models/2/files/foo.txt"
```

带目录路径的请求示例：

```shell
curl --header "Authorization: Bearer <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/packages/ml_models/2/files/my_dir/foo.txt"
```

<a id="upload-a-model-package-file"></a>

## 上传模型包文件

将文件上传到机器学习模型包。

<a id="authorize-the-upload"></a>

### 授权上传

授权将文件上传到机器学习模型包。

```plaintext
PUT /api/v4/projects/:id/packages/ml_models/:model_version_id/files/(*path/):file_name/authorize
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
| --- | --- | --- | --- |
| `id` | 整数或字符串 | 是 | 项目 ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths)。 |
| `model_version_id` | 整数或字符串 | 是 | 模型版本 ID 或候选运行 ID。参见[模型版本和候选 ID](#model-version-and-candidate-ids)。 |
| `file_name` | 字符串 | 是 | 文件名。 |
| `path` | 字符串 | 否 | 文件的目录路径。 |

如果成功，返回 [`200 OK`](rest/troubleshooting.md#status-codes)。

请求示例：

```shell
curl --request PUT \
  --header "Authorization: Bearer <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/packages/ml_models/2/files/model.pkl/authorize"
```

<a id="send-the-file"></a>

### 发送文件

将文件上传到机器学习模型包。

```plaintext
PUT /api/v4/projects/:id/packages/ml_models/:model_version_id/files/(*path/):file_name
```

支持的属性：

| 属性 | 类型 | 是否必需 | 描述 |
| --- | --- | --- | --- |
| `id` | 整数或字符串 | 是 | 项目 ID 或 [URL 编码的项目路径](rest/_index.md#namespaced-paths)。 |
| `model_version_id` | 整数或字符串 | 是 | 模型版本 ID 或候选运行 ID。参见[模型版本和候选 ID](#model-version-and-candidate-ids)。 |
| `file_name` | 字符串 | 是 | 文件名。 |
| `path` | 字符串 | 否 | 文件的目录路径。 |
| `file` | 文件 | 是 | 要上传的文件。 |

如果成功，返回 [`201 Created`](rest/troubleshooting.md#status-codes)。

请求示例：

```shell
curl --request PUT \
  --header "Authorization: Bearer <your_access_token>" \
  --form "file=@model.pkl" \
  --url "https://gitlab.example.com/api/v4/projects/1/packages/ml_models/2/files/model.pkl"
```

带目录路径的请求示例：

```shell
curl --request PUT \
  --header "Authorization: Bearer <your_access_token>" \
  --form "file=@model.pkl" \
  --url "https://gitlab.example.com/api/v4/projects/1/packages/ml_models/2/files/my_dir/model.pkl"
```

<a id="model-version-and-candidate-ids"></a>

## 模型版本和候选 ID

`:model_version_id` 属性接受模型版本 ID 或候选运行 ID。

要查找模型版本 ID，请检查模型版本页面的 URL。例如，在 `https://gitlab.example.com/my-namespace/my-project/-/ml/models/1/versions/5` 中，模型版本 ID 为 `5`。

```shell
curl --header "Authorization: Bearer <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/packages/ml_models/5/files/model.pkl"
```

要使用候选运行 ID，请在候选的内部 ID 前面加上 `candidate:`。例如，在 `https://gitlab.example.com/my-namespace/my-project/-/ml/candidates/5` 中，`:model_version_id` 的值为 `candidate:5`。

```shell
curl --header "Authorization: Bearer <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/packages/ml_models/candidate:5/files/model.pkl"
```

