---
stage: ModelOps
group: MLOps
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: MLflow 客户端兼容性
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 15.11 中引入。
- 在极狐GitLab 17.8 中 GA。

{{< /history >}}

[MLflow](https://mlflow.org/) 是一个流行的开源机器学习实验跟踪工具。极狐GitLab 的[模型实验跟踪](_index.md)和[模型仓库](../model_registry/_index.md)与 MLflow 客户端兼容。设置只需对现有代码进行最少更改。

<a id="enable-mlflow-client-integration"></a>

## 启用 MLflow 客户端集成

先决条件：

- 一个与极狐GitLab 兼容的 Python 客户端：
  - 推荐：[极狐GitLab MLOps Python 客户端](https://jihulab.com/gitlab-cn/modelops/mlops/gitlab-mlops)。
  - 另一个选项是 MLflow 客户端版本。MLflow 客户端[与极狐GitLab 兼容](https://jihulab.com/gitlab-cn/modelops/mlops/mlflow-compatibility-qa)。
- 一个具有开发者、维护者或所有者角色以及 `api` 范围的[个人](../../../profile/personal_access_tokens.md)、[项目](../../settings/project_access_tokens.md)或[群组](../../../group/settings/group_access_tokens.md)访问令牌。
- 项目 ID。要查找项目 ID：
  1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
  1. 选择 **设置** > **通用**。

要从本地环境使用 MLflow 客户端兼容性：

1. 在运行代码的主机上设置跟踪 URI 和令牌环境变量。
   这可以是你的本地环境、CI 流水线或远程主机。例如：

   ```shell
   export MLFLOW_TRACKING_URI="<your gitlab endpoint>/api/v4/projects/<your project id>/ml/mlflow"
   export MLFLOW_TRACKING_TOKEN="<your_access_token>"
   ```

1. 如果训练代码包含对 `mlflow.set_tracking_uri()` 的调用，请将其移除。

在模型仓库中，你可以通过选择右上角的垂直省略号 ({{< icon name="ellipsis_v" >}}) 从溢出菜单中复制跟踪 URI。

<a id="model-experiments"></a>

## 模型实验

运行训练代码时，可以使用 MLflow 客户端在极狐GitLab 上创建实验、运行、模型、模型版本、记录参数、指标、元数据和产物。

实验记录后，它们会列在 `/<your project>/-/ml/experiments` 下。

运行会被注册，并可以通过选择实验、模型或模型版本来探索。

<a id="creating-an-experiment"></a>

### 创建实验

```python
import mlflow

# 创建一个新的实验
experiment_id = mlflow.create_experiment(name="<your_experiment>")

# 设置活动实验时，如果该实验不存在，也会创建一个新的实验。
mlflow.set_experiment(experiment_name="<your_experiment>")
```

<a id="creating-a-run"></a>

### 创建运行

```python
import mlflow

# 创建运行需要实验 ID 或活动实验
mlflow.set_experiment(experiment_name="<your_experiment>")

# 可以使用上下文管理器或不使用上下文管理器来创建运行
with mlflow.start_run() as run:
    print(run.info.run_id)
    # 你的训练代码

with mlflow.start_run():
    # 你的训练代码
```

<a id="logging-parameters-and-metrics"></a>

### 记录参数和指标

```python
import mlflow

mlflow.set_experiment(experiment_name="<your_experiment>")

with mlflow.start_run():
    # 参数键在运行范围内必须唯一
    mlflow.log_param(key="param_1", value=1)

    # 指标可以在整个运行过程中更新
    mlflow.log_metric(key="metrics_1", value=1)
    mlflow.log_metric(key="metrics_1", value=2)
```

<a id="logging-artifacts"></a>

### 记录产物

```python
import mlflow

mlflow.set_experiment(experiment_name="<your_experiment>")

with mlflow.start_run():
    # 纯文本文件可以使用 `log_text` 作为产物记录
    mlflow.log_text('Hello, World!', artifact_file='hello.txt')

    mlflow.log_artifact(
        local_path='<local/path/to/file.txt>',
        artifact_path='<optional relative path to log the artifact at>'
    )
```

<a id="logging-models"></a>

### 记录模型

可以使用受支持的 [MLflow 模型风格](https://mlflow.org/docs/latest/models.html#built-in-model-flavors)之一来记录模型。使用模型风格记录会记录元数据，从而更轻松地跨不同工具和环境管理、加载和部署模型。

```python
import mlflow
from sklearn.ensemble import RandomForestClassifier

mlflow.set_experiment(experiment_name="<your_experiment>")

with mlflow.start_run():
    # 创建并训练一个简单模型
    model = RandomForestClassifier(n_estimators=10, random_state=42)
    model.fit(X_train, y_train)

    # 使用 MLflow sklearn 模型风格记录模型
    mlflow.sklearn.log_model(model, artifact_path="")
```

<a id="loading-a-run"></a>

### 加载运行

{{< history >}}

- 在极狐GitLab 17.9 中引入。

{{< /history >}}

你可以从极狐GitLab 模型仓库加载运行，例如进行预测。

```python
import mlflow
import mlflow.pyfunc

run_id = "<your_run_id>"
download_path = "models"  # 下载到的本地文件夹

mlflow.pyfunc.load_model(f"runs:/{run_id}/", dst_path=download_path)

sample_input = [[1,0,3,4],[2,0,1,2]]
model.predict(data=sample_input)
```

<a id="associating-a-run-to-a-cicd-job"></a>

### 将运行关联到 CI/CD 作业

{{< history >}}

- 在极狐GitLab 16.1 中引入。
- 在极狐GitLab 17.1 中变更为测试版。

{{< /history >}}

如果你的训练代码是从 CI/CD 作业运行的，极狐GitLab 可以使用该信息来增强运行元数据。要将运行关联到 CI/CD 作业：

1. 在[项目 CI 变量](../../../../ci/variables/_index.md)中，包含以下变量：
   - `MLFLOW_TRACKING_URI`: `"<your gitlab endpoint>/api/v4/projects/<your project id>/ml/mlflow"`
   - `MLFLOW_TRACKING_TOKEN`: `<your_access_token>`

1. 在运行执行上下文中的训练代码里，添加以下代码片段：

   ```python
   import os
   import mlflow

   with mlflow.start_run(run_name=f"Run {index}"):
     # 你的训练代码

     # 要包含的代码片段开始
     if os.getenv('GITLAB_CI'):
       mlflow.set_tag('gitlab.CI_JOB_ID', os.getenv('CI_JOB_ID'))
     # 要包含的代码片段结束
   ```

<a id="model-registry"></a>

## 模型仓库

你还可以使用 MLflow 客户端管理模型和模型版本。模型注册在 `/<your project>/-/ml/models` 下。

<a id="models"></a>

### 模型

<a id="creating-a-model"></a>

#### 创建模型

```python
from mlflow import MlflowClient

client = MlflowClient()
model_name = '<your_model_name>'
description = 'Model description'
model = client.create_registered_model(model_name, description=description)
```

**注意**

- `create_registered_model` 参数 `tags` 被忽略。
- `name` 在项目内必须唯一。
- `name` 不能是现有实验的名称。

<a id="fetching-a-model"></a>

#### 获取模型

```python
from mlflow import MlflowClient

client = MlflowClient()
model_name = '<your_model_name>'
model = client.get_registered_model(model_name)
```

<a id="updating-a-model"></a>

#### 更新模型

```python
from mlflow import MlflowClient

client = MlflowClient()
model_name = '<your_model_name>'
description = 'New description'
client.update_registered_model(model_name, description=description)
```

<a id="deleting-a-model"></a>

#### 删除模型

```python
from mlflow import MlflowClient

client = MlflowClient()
model_name = '<your_model_name>'
client.delete_registered_model(model_name)
```

<a id="logging-runs-to-a-model"></a>

### 将运行记录到模型

每个模型都有一个关联的实验，其名称相同，但带有 `[model]` 前缀。要将运行记录到模型，请使用传递正确名称的实验：

```python
from mlflow import MlflowClient

client = MlflowClient()
model_name = '<your_model_name>'
exp = client.get_experiment_by_name(f"[model]{model_name}")
run = client.create_run(exp.experiment_id)
```

<a id="model-version"></a>

### 模型版本

<a id="creating-a-model-version"></a>

#### 创建模型版本

```python
from mlflow import MlflowClient

client = MlflowClient()
model_name = '<your_model_name>'
description = 'Model version description'
model_version = client.create_model_version(model_name, source="", description=description)
```

如果未传递版本参数，它将从最新上传的版本自动递增。你可以在创建模型版本时通过传递标签来设置版本。版本必须遵循 [SemVer](https://semver.org/) 格式。

```python
from mlflow import MlflowClient

client = MlflowClient()
model_name = '<your_model_name>'
version = '<your_version>'
tags = { "gitlab.version": version }
client.create_model_version(model_name, version, description=description, tags=tags)
```

**注意**

- 参数 `run_id` 被忽略。每个模型版本的行为类似于一个运行。尚不支持从运行创建模型版本。
- 参数 `source` 被忽略。极狐GitLab 将为模型版本文件创建一个软件包位置。
- 参数 `run_link` 被忽略。
- 参数 `await_creation_for` 被忽略。

<a id="updating-a-model"></a>

#### 更新模型

```python
from mlflow import MlflowClient

client = MlflowClient()
model_name = '<your_model_name>'
version = '<your_version>'
description = 'New description'
client.update_model_version(model_name, version, description=description)
```

<a id="fetching-a-model-version"></a>

#### 获取模型版本

```python
from mlflow import MlflowClient

client = MlflowClient()
model_name = '<your_model_name>'
version = '<your_version>'
client.get_model_version(model_name, version)
```

<a id="getting-latest-versions-of-a-model"></a>

#### 获取模型的最新版本

```python
from mlflow import MlflowClient

client = MlflowClient()
model_name = '<your_model_name>'
client.get_latest_versions(model_name)
```

**注意**

- 参数 `stages` 被忽略。
- 版本按最高语义版本排序。

<a id="loading-a-model-version"></a>

#### 加载模型版本

```python
from mlflow import MlflowClient

client = MlflowClient()
model_name = '<your_model_name>'
version = '<your_version'  # 例如：'1.0.0'

# 或者搜索版本
version = mlflow.search_registered_models(filter_string="name='{model_name}'")[0].latest_versions[0].version

model = mlflow.pyfunc.load_model(f"models:/{model_name}/{latest_version}")

# 或者加载最新版本
model = mlflow.pyfunc.load_model(f"models:/{model_name}/latest")
```

<a id="logging-metrics-and-parameters-to-a-model-version"></a>

#### 将指标和参数记录到模型版本

每个模型版本也是一个运行，允许用户记录参数和指标。运行 ID 可以在极狐GitLab 的模型版本页面找到，或使用 MLflow 客户端：

```python
from mlflow import MlflowClient

client = MlflowClient()
model_name = '<your_model_name>'
version = '<your_version>'
model_version = client.get_model_version(model_name, version)
run_id = model_version.run_id

# 你的训练代码

client.log_metric(run_id, '<metric_name>', '<metric_value>')
client.log_param(run_id, '<param_name>', '<param_value>')
client.log_batch(run_id, metric_list, param_list, tag_list)
```

因为每个文件有 5 GB 的大小限制，你必须对较大的模型进行分区。

<a id="logging-artifacts-to-a-model-version"></a>

#### 将产物记录到模型版本

极狐GitLab 创建一个软件包，MLflow 客户端可以使用它来上传文件。

```python
from mlflow import MlflowClient

client = MlflowClient()
model_name = '<your_model_name>'
version = '<your_version>'
model_version = client.get_model_version(model_name, version)
run_id = model_version.run_id

# 你的训练代码

client.log_artifact(run_id, '<local/path/to/file.txt>', artifact_path="")
client.log_figure(run_id, figure, artifact_file="my_plot.png")
client.log_dict(run_id, my_dict, artifact_file="my_dict.json")
client.log_image(run_id, image, artifact_file="image.png")
```

产物随后将在 `https/<your project>/-/ml/models/<model_id>/versions/<version_id>` 下可用。

<a id="linking-a-model-version-to-a-cicd-job"></a>

#### 将模型版本链接到 CI/CD 作业

与运行类似，也可以将模型版本链接到 CI/CD 作业：

```python
import os
from mlflow import MlflowClient

client = MlflowClient()
model_name = '<your_model_name>'
version = '<your_version>'
model_version = client.get_model_version(model_name, version)
run_id = model_version.run_id

# 你的训练代码

if os.getenv('GITLAB_CI'):
    client.set_tag(model_version.run_id, 'gitlab.CI_JOB_ID', os.getenv('CI_JOB_ID'))
```

<a id="supported-mlflow-client-methods-and-caveats"></a>

## 支持的 MLflow 客户端方法和注意事项

极狐GitLab 支持 MLflow 客户端的以下方法。更多信息可以在 [MLflow 文档](https://mlflow.org/docs/latest/index.html)中找到。以下方法的 MlflowClient 对应方法也受支持，并具有相同的注意事项。

| 方法                       | 支持           | 添加版本 | 注释                                                                                     |
|--------------------------|-----------------|---------------|----------------------------------------------------------------------------------------------|
| `create_experiment`      | 是             | 15.11         |                                                                                              |
| `get_experiment`         | 是             | 15.11         |                                                                                              |
| `get_experiment_by_name` | 是             | 15.11         |                                                                                              |
| `delete_experiment`      | 是             | 17.5          |                                                                                              |
| `set_experiment`         | 是             | 15.11         |                                                                                              |
| `get_run`                | 是             | 15.11         |                                                                                              |
| `delete_run`             | 是             | 17.5          |                                                                                              |
| `start_run`              | 是             | 15.11         | (16.3) 如果未提供名称，运行将获得一个随机昵称。                        |
| `search_runs`            | 是             | 15.11         | (16.4) `experiment_ids` 仅支持单个实验 ID，并按列或指标排序。 |
| `log_artifact`           | 是（有注意事项） | 15.11         | (15.11) `artifact_path` 必须为空。不支持目录。                         |
| `log_artifacts`          | 是（有注意事项） | 15.11         | (15.11) `artifact_path` 必须为空。不支持目录。                         |
| `log_batch`              | 是             | 15.11         |                                                                                              |
| `log_metric`             | 是             | 15.11         |                                                                                              |
| `log_metrics`            | 是             | 15.11         |                                                                                              |
| `log_param`              | 是             | 15.11         |                                                                                              |
| `log_params`             | 是             | 15.11         |                                                                                              |
| `log_figure`             | 是             | 15.11         |                                                                                              |
| `log_image`              | 是             | 15.11         |                                                                                              |
| `log_text`               | 是（有注意事项） | 15.11         | (15.11) 不支持目录。                                                        |
| `log_dict`               | 是（有注意事项） | 15.11         | (15.11) 不支持目录。                                                        |
| `set_tag`                | 是             | 15.11         |                                                                                              |
| `set_tags`               | 是             | 15.11         |                                                                                              |
| `set_terminated`         | 是             | 15.11         |                                                                                              |
| `end_run`                | 是             | 15.11         |                                                                                              |
| `update_run`             | 是             | 15.11         |                                                                                              |
| `log_model`              | 部分           | 15.11         | (15.11) 保存产物，但不保存模型数据。`artifact_path` 必须为空。          |
| `load_model`             | 是             | 17.5          |                                                                                              |
| `download_artifacts`     | 是             | 17.9          |                                                                                              |
| `list_artifacts`         | 是             | 17.9          |                                                                                              |

其他 MlflowClient 方法：

| 方法                       | 支持           | 添加版本 | 注释                                         |
|---------------------------|------------------|---------------|--------------------------------------------------|
| `create_registered_model` | 是（有注意事项） | 16.8          | [参见