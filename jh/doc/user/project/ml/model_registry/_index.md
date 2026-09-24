---
stage: ModelOps
group: MLOps
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 模型注册表
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 引入于 GitLab 16.8，作为[实验性版本](../../../../policy/development_stages_support.md#experiment)发布，通过名为 `model_registry` 的[功能标志](../../../../administration/feature_flags/_index.md)控制。默认禁用。要启用该功能，管理员可以[启用功能标志](../../../../administration/feature_flags/_index.md) `model_registry`。
- 于 GitLab 17.1 变更为 Beta 版本。
- 于 GitLab 17.6 变更为 GA。

{{< /history >}}

机器学习模型注册表作为一个集中式仓库，用于管理机器学习模型的全生命周期。它就像一个专门的数据库，存储模型版本以及包括性能指标、验证结果和数据沿袭信息在内的基本元数据。

使用 极狐GitLab 模型注册表可以：

- 系统化地注册和版本化机器学习模型
- 追踪包括性能指标、参数和数据沿袭在内的全面元数据
- 比较模型版本并监控其随时间的变化
- 保持模型行为和需求的清晰文档

有关模型注册表功能和能力的更多信息，请参见 epic 9423。

<a id="access-the-model-registry"></a>

## 访问模型注册表

模型注册表由软件包仓库设置控制。
在使用模型注册表之前，请确保已[启用软件包仓库](../../../../administration/packages/_index.md#enable-or-disable-the-package-registry)。

要访问模型注册表，请在左侧边栏中选择 **部署** > **模型注册表**。

如果 **模型注册表** 不可用，请确保已将其启用。

要启用模型注册表或将[可见性级别](../../../public_access.md)设置为公开或私有：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的群组。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **可见性、项目功能、权限**。
1. 在 **模型注册表** 下，确保开关处于开启状态，并选择你希望具有访问权限的人员。
   用户必须至少具有 [报告者角色](../../../permissions.md#roles) 才能修改或删除模型和模型版本。

<a id="create-machine-learning-models-by-using-the-ui"></a>

## 通过 UI 创建机器学习模型

要通过 极狐GitLab UI 创建新的机器学习模型：

1. 在左侧边栏中，选择 **部署** > **模型注册表**。
1. 在 **模型注册表** 页面上，你可以：
   - 如果你还没有模型，请选择 **创建模型**。
   - 在右上角，选择 **创建/导入模型**，然后在下拉列表中选择 **创建新模型**。
1. 填写字段：
   - 为你的模型输入唯一的名称。
   - 可选。为模型提供描述。
1. 选择 **创建**。

现在你可以在模型注册表中查看新创建的模型。

<a id="create-a-model-version-by-using-the-ui"></a>

## 通过 UI 创建模型版本

要创建新的模型版本：

1. 在模型详情页面上，选择 **创建新版本**。
1. 填写字段：
   - 输入遵循语义化版本规范的唯一版本号。
   - 可选。为模型版本提供描述。
   - 上传与模型版本关联的任何文件、日志、指标或参数。
1. 选择 **创建并导入**。

新的模型版本现在在模型注册表中可用。

<a id="delete-a-model"></a>

### 删除模型

要删除模型及其所有关联版本：

1. 在左侧边栏中，选择 **部署** > **模型注册表**。
1. 找到你要删除的模型。
1. 在最右侧列中，选择垂直省略号 ({{< icon name="ellipsis_v" >}}) 和 **删除模型**。

或者你也可以从模型详情页面删除模型：

1. 在左侧边栏中，选择 **部署** > **模型注册表**。
1. 找到你要删除的模型。
1. 选择模型名称以查看其详情。
1. 选择垂直省略号 ({{< icon name="ellipsis_v" >}}) 和 **删除模型**。
1. 确认删除。

<a id="delete-a-model-version"></a>

### 删除模型版本

要删除模型版本：

1. 在左侧边栏中，选择 **部署** > **模型注册表**。
1. 找到带有你要删除的版本的模型。
1. 选择模型名称以查看其详情。
1. 选择 **版本** 选项卡。
1. 找到你要删除的模型版本。
1. 在最右侧列中，选择垂直省略号 ({{< icon name="ellipsis_v" >}}) 和 **删除版本**。

或者你也可以从模型版本详情页面删除模型：

1. 在左侧边栏中，选择 **部署** > **模型注册表**。
1. 找到带有你要删除的版本的模型。
1. 选择模型名称以查看其详情。
1. 选择 **版本** 选项卡。
1. 选择版本名称以查看其详情。
1. 选择垂直省略号 ({{< icon name="ellipsis_v" >}}) 和 **删除版本**。
1. 确认删除。

<a id="add-artifacts-to-a-model-version"></a>

### 向模型版本添加产物

要向模型版本添加产物：

1. 在左侧边栏中，选择 **部署** > **模型注册表**。
1. 找到模型。
1. 选择模型名称以查看其详情。
1. 选择 **版本** 选项卡。
1. 选择版本名称以查看其详情。
1. 选择 **产物** 选项卡。
1. 可选。为要上传的文件指定子文件夹路径。例如 `config`。
1. 使用 **选择** 来选取要上传的文件。
1. 选择 **上传**。

或者，你也可以将文件拖放到投放区域。产物将自动上传。

因为每个文件的大小限制为 5 GB，因此必须对较大的模型进行分区。

<a id="delete-artifacts-from-a-model-version"></a>

### 从模型版本删除产物

要删除版本的产物：

1. 在左侧边栏中，选择 **部署** > **模型注册表**。
1. 找到模型。
1. 选择模型名称以查看其详情。
1. 选择 **版本** 选项卡。
1. 选择版本名称以查看其详情。
1. 选择 **产物** 选项卡。
1. 选择你要删除的每个产物旁边的复选框。
1. 选择 **删除**。
1. 确认删除。

<a id="create-machine-learning-models-and-model-versions-by-using-mlflow"></a>

## 使用 MLflow 创建机器学习模型和模型版本

可以使用 [MLflow](https://www.mlflow.org/docs/latest/tracking.html) 客户端兼容性来创建模型和模型版本。有关如何创建和管理模型和模型版本的更多信息，请参见 [MLflow 客户端兼容性](../experiment_tracking/mlflow_client.md#model-registry)。你也可以通过在 极狐GitLab 上选择 **创建模型**（位于模型注册表页面）来直接创建模型。

<a id="add-artifacts-metrics-and-parameters-to-a-model-version-by-using-mlflow"></a>

### 使用 MLflow 向模型版本添加产物、指标和参数

可以使用以下方式将文件上传到模型版本：

- 软件包仓库，其中模型版本与名为 `<model_name>/<model_version>` 的软件包关联。
- MLflow 客户端兼容性。[查看详情](../experiment_tracking/mlflow_client.md#logging-artifacts-to-a-model-version)。

用户可以通过 MLflow 客户端兼容性记录模型版本的指标和参数，[查看详情](../experiment_tracking/mlflow_client.md#logging-metrics-and-parameters-to-a-model-version)

<a id="link-a-model-version-to-a-cicd-job"></a>

## 将模型版本链接到 CI/CD 作业

当通过 极狐GitLab CI/CD 作业创建模型版本时，你可以将该模型版本链接到作业，从而方便地访问作业的日志、合并请求和流水线。这可以通过 MLflow 客户端兼容性完成。[查看详情](../experiment_tracking/mlflow_client.md#linking-a-model-version-to-a-cicd-job)。

<a id="model-versions-and-semantic-versioning"></a>

## 模型版本与语义版本控制

极狐GitLab 中模型版本的版本号必须遵循[语义版本规范](https://semver.org/)。
使用语义版本控制有助于模型部署，它传达了新版本是否可以在不更改应用程序的情况下进行部署：

- **主版本号（整数）**：主版本号的变更表示模型发生了破坏性变更，消费该模型的应用程序必须更新才能正确使用此新版本。
  新的算法或增加一个必需的 特征列都是破坏性变更的例子，这些变更将需要递增主版本号。

- **次版本号（整数）**：次版本号的变更表示非破坏性变更，消费者可以安全地使用新版本而不会中断，尽管消费者可能需要更新才能使用其新功能。例如，为模型添加一个带有默认值的非必需特征列是一个次版本号递增，因为当没有为新增列传递值时，推理仍然有效。

- **修订号（整数）**：修订号的变更表示新版本发布，它不需要应用程序采取任何行动。例如，对模型进行每日重新训练不会改变特征集或应用程序消费模型版本的方式。自动更新到新的修订版本是安全的。

- **预发布版（文本）**：表示尚未准备好用于生产的版本。用于标识模型的 alpha、beta 或候选发布版本。

<a id="model-version-examples"></a>

### 模型版本示例

- 初始版本：1.0.0 - 模型的首次发布，没有任何变更或补丁。
- 新功能：1.1.0 - 向模型添加了一个新的非破坏性功能，递增次版本号。
- Bug 修复：1.1.1 - 修复了模型中的一个错误，递增修订号。
- 破坏性变更：2.0.0 - 对模型进行了破坏性变更，递增主版本号。
- 补丁发布：2.0.1 - 修复了模型中的一个错误，递增修订号。
- 预发布版：2.0.1-alpha1 - 模型的预发布版本，带有一个 alpha 版本。
- 预发布版：2.0.1-rc2 - 模型的候选发布版本。
- 新功能：2.1.0 - 向模型添加了一个新功能，因此递增次版本号。