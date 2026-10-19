---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Google Cloud 工作负载身份联合与 IAM 策略
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

要使用 Google Cloud 集成（例如
[Google Artifact Management 集成](../user/project/integrations/google_artifact_management.md)），
您必须创建并配置[工作负载身份池和提供商](https://cloud.google.com/iam/docs/workload-identity-federation)。
Google Cloud 集成使用工作负载身份联合，通过 OpenID Connect
(OIDC) 并借助 JSON Web Token (JWT) 令牌，
授予极狐GitLab 工作负载访问 Google Cloud 资源的权限。

<a id="workload-identity-federation"></a>

## 工作负载身份联合

工作负载身份联合让您可以使用身份与访问管理 (IAM) 为外部身份授予 [IAM 角色](https://cloud.google.com/iam/docs/overview#roles)。

传统上，在 Google Cloud 外部运行的应用程序使用[服务账号密钥](https://cloud.google.com/iam/docs/service-account-creds#key-types)访问 Google Cloud 资源。然而，服务账号密钥是强大的凭据，如果管理不当，可能会带来安全风险。

借助身份联合，您可以使用身份与访问管理 (IAM) 直接为外部身份授予 IAM 角色，而无需服务账号。这种方法消除了与服务账号及其密钥相关的维护和安全负担。

<a id="workload-identity-pools"></a>

## 工作负载身份池

*工作负载身份池*是一个实体，让您可以在 Google Cloud 上管理
非 Google 身份。

Google Cloud 上的极狐GitLab 集成会引导您设置工作负载
身份池，以便向 Google Cloud 进行身份验证。此设置包括将您的极狐GitLab 角色属性映射到
Google Cloud IAM 策略中的 IAM 声明。有关 Google Cloud 上的极狐GitLab 集成可用的
极狐GitLab 属性完整列表，请参阅 [OIDC 自定义声明](#oidc-custom-claims)。

<a id="workload-identity-pool-providers"></a>

## 工作负载身份池提供商

*工作负载身份池提供商*是一个实体，描述 Google Cloud 与您的身份提供商 (IdP) 之间的
关系。对于 Google Cloud 上的极狐GitLab 集成，极狐GitLab 是
您的工作负载身份池的 IdP。

有关外部工作负载身份联合的更多信息，请参阅[工作负载身份联合](https://cloud.google.com/iam/docs/workload-identity-federation)。

默认的 Google Cloud 上的极狐GitLab 集成假定您希望在极狐GitLab 组织级别
设置从极狐GitLab 到 Google Cloud 的身份验证。如果您希望按项目控制对 Google Cloud 的访问，则必须为工作负载身份池提供商配置 IAM 策略。有关控制谁可以从您的极狐GitLab 组织访问 Google Cloud 的更多信息，请参阅[使用 IAM 进行访问控制](https://cloud.google.com/docs/gitlab)。

<a id="gitlab-authentication-with-workload-identity-federation"></a>

## 使用工作负载身份联合进行极狐GitLab 身份验证

在您的工作负载身份池和提供商设置好，将您的极狐GitLab 角色和权限映射到 IAM 角色后，您可以通过将 [`identity`](../ci/yaml/_index.md#identity) 关键字设置为
`google_cloud` 以在 Google Cloud 上进行授权，从而预配 runner
以将工作负载从极狐GitLab 部署到 Google Cloud。

有关使用 Google Cloud 上的极狐GitLab 集成预配 runner 的更多信息，请参阅
教程
[在 Google Cloud 中预配 runner](../ci/runners/provision_runners_google_cloud.md)。

<a id="create-and-configure-a-workload-identity-federation"></a>

## 创建并配置工作负载身份联合

要设置工作负载身份联合，您可以：

- 使用极狐GitLab UI 进行引导式设置。
- 使用 Google Cloud CLI 手动设置工作负载身份联合。

<a id="with-the-gitlab-ui"></a>

### 使用极狐GitLab UI

要使用极狐GitLab UI 设置工作负载身份联合：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**设置** > **集成**。
1. 找到 Google Cloud IAM 集成并选择**配置**。
1. 选择**引导式设置**并按照说明操作。

<a id="with-the-google-cloud-cli"></a>

### 使用 Google Cloud CLI

先决条件：

- Google Cloud CLI 必须已[安装并完成身份验证](https://cloud.google.com/sdk/docs/install)
  以使用 Google Cloud。
- 您必须拥有在 Google Cloud 中管理
  工作负载身份联合的[权限](https://cloud.google.com/iam/docs/manage-workload-identity-pools-providers#required-roles)。

1. 使用以下命令创建工作负载身份池。替换以下
   值：

   - `<your_google_cloud_project_id>` 替换为您的
     [Google Cloud 项目 ID](https://cloud.google.com/resource-manager/docs/creating-managing-projects#identifying_projects)。
     为提高安全性，请使用专门用于身份管理的项目，
     与资源和 CI/CD 项目分开。
   - `<your_identity_pool_id>` 替换为要用于该池的 ID，该 ID 必须
     为 4 到 32 个小写字母、数字或连字符。为避免冲突，请使用
     唯一的 ID。您应包含极狐GitLab 项目 ID 或项目路径，
     因为这有助于 IAM 策略管理。例如，
     `gitlab-my-project-name`。

   ```shell
   gcloud iam workload-identity-pools create <your_identity_pool_id> \
            --project="<your_google_cloud_project_id>" \
            --location="global" \
            --display-name="Workload identity pool for GitLab project ID"
   ```

1. 使用以下命令向工作负载身份池添加 OIDC 提供商。
   替换以下值：

   - `<your_identity_provider_id>` 替换为要用于该提供商的 ID，该 ID
     必须为 4 到 32 个小写字母、数字或连字符。为避免
     冲突，请在身份池中使用唯一的 ID。例如，
     `gitlab`。
   - `<your_google_cloud_project_id>` 替换为您的
     [Google Cloud 项目 ID](https://cloud.google.com/resource-manager/docs/creating-managing-projects#identifying_projects)。
   - `<your_identity_pool_id>` 替换为您在
     上一步中创建的工作负载身份池的 ID。
   - `<your_issuer_uri>` 替换为您的身份提供商颁发者 URI，该值
     可以在选择手动设置时从 IAM 集成页面复制，
     并且必须与该值完全匹配。该参数必须包含
     顶级群组的路径。例如，如果项目位于
     `my-root-group/my-subgroup/project-a` 下，则 `issuer-uri` 必须设置为
     `https://auth.gcp.gitlab.com/oidc/my-root-group`。

   ```shell
   gcloud iam workload-identity-pools providers create-oidc "<your_identity_provider_id>" \
         --location="global" \
         --project="<your_google_cloud_project_id>" \
         --workload-identity-pool="<your_identity_pool_id>" \
         --issuer-uri="<your_issuer_uri>" \
         --display-name="GitLab OIDC provider" \
         --attribute-mapping="attribute.guest_access=assertion.guest_access,\
   attribute.reporter_access=assertion.reporter_access,\
   attribute.developer_access=assertion.developer_access,\
   attribute.maintainer_access=assertion.maintainer_access,\
   attribute.owner_access=assertion.owner_access,\
   attribute.namespace_id=assertion.namespace_id,\
   attribute.namespace_path=assertion.namespace_path,\
   attribute.project_id=assertion.project_id,\
   attribute.project_path=assertion.project_path,\
   attribute.user_id=assertion.user_id,\
   attribute.user_login=assertion.user_login,\
   attribute.user_email=assertion.user_email,\
   attribute.user_access_level=assertion.user_access_level,\
   google.subject=assertion.sub"
   ```

   `attribute-mapping` 参数必须包含从 JWT ID 令牌中包含的 OIDC 自定义
   声明到相应身份属性的映射，
   这些属性用于身份与访问管理 (IAM) 策略中以授予访问权限。
   有关更多信息，请参阅[支持的 OIDC 自定义声明](#oidc-custom-claims)，您可以使用它们
   来[控制对 Google Cloud 的访问](https://cloud.google.com/docs/gitlab#control-access-google)。

要将[身份令牌访问](https://cloud.google.com/iam/docs/workload-identity-federation#mapping)限制到特定的极狐GitLab 项目或群组，请使用属性条件。项目使用属性 `assertion.project_id`，群组使用属性 `assertion.namespace_id`。有关更多信息，请参阅 Google Cloud 文档中关于如何[定义属性条件](https://cloud.google.com/iam/docs/workload-identity-federation-with-deployment-pipelines#gitlab-saas_2)的内容。定义属性条件后，您可以[更新工作负载身份提供商](https://cloud.google.com/iam/docs/workload-identity-federation-with-deployment-pipelines#update_attribute_condition_on_a_workload_identity_provider)。

创建工作负载身份池和提供商后，要在极狐GitLab 中完成设置：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**设置** > **集成**。
1. 找到 Google Cloud IAM 集成并选择**配置**。
1. 选择**手动设置**
1. 填写字段。
   - **[项目 ID](https://cloud.google.com/resource-manager/docs/creating-managing-projects#identifying_projects)**
     用于您在其中创建工作负载身份
     池和提供商的 Google Cloud 项目。示例：`my-sample-project-191923`。
   - **[项目编号](https://cloud.google.com/resource-manager/docs/creating-managing-projects#identifying_projects)**
     用于同一个 Google Cloud 项目。示例：`314053285323`。
   - **池 ID**，即您为此集成创建的工作负载身份池的 ID。
   - **提供商 ID**，即您为此集成创建的工作负载身份提供商的 ID。

<a id="oidc-custom-claims"></a>

### OIDC 自定义声明

ID 令牌包含以下自定义声明：

| 声明名称              | 何时                      | 描述                                                                                              |
| ----------------------- | ------------------------- | -------------------------------------------------------------------------------------------------------- |
| `namespace_id`          | 在项目事件中         | 群组或用户级命名空间的 ID。                                                                 |
| `namespace_path`        | 在项目事件中         | 群组或用户级命名空间的路径。                                                               |
| `project_id`            | 在项目事件中         | 项目的 ID。                                                                                       |
| `project_path`          | 在项目事件中         | 项目的路径。                                                                                     |
| `root_namespace_id`     | 在群组事件中           | 顶级群组或用户级命名空间的 ID。                                                            |
| `root_namespace_path`   | 在群组事件中           | 顶级群组或用户级命名空间的路径。                                                          |
| `user_id`               | 在用户触发的事件中    | 用户的 ID。                                                                                          |
| `user_login`            | 在用户触发的事件中    | 用户的用户名。                                                                                    |
| `user_email`            | 在用户触发的事件中    | 用户的电子邮件。                                                                                       |
| `ci_config_ref_uri`     | 在 CI/CD 流水线运行期间 | 顶级 CI 流水线定义的 ref 路径。                                                    |
| `ci_config_sha`         | 在 CI/CD 流水线运行期间 | `ci_config_ref_uri`的 Git 提交 SHA。                                                              |
| `job_id`                | 在 CI/CD 流水线运行期间 | CI 作业的 ID。                                                                                        |
| `pipeline_id`           | 在 CI/CD 流水线运行期间 | CI 流水线的 ID。                                                                                   |
| `pipeline_source`       | 在 CI/CD 流水线运行期间 | CI 流水线来源。                                                                                      |
| `project_visibility`    | 在 CI/CD 流水线运行期间 | 流水线运行所在项目的可见性。                                             |
| `ref`                   | 在 CI/CD 流水线运行期间 | CI 作业的 Git ref。                                                                                  |
| `ref_path`              | 在 CI/CD 流水线运行期间 | CI 作业的完全限定 ref。                                                                      |
| `ref_protected`         | 在 CI/CD 流水线运行期间 | Git ref 是否受保护。                                                                             |
| `ref_type`              | 在 CI/CD 流水线运行期间 | Git ref 类型。                                                                                            |
| `runner_environment`    | 在 CI/CD 流水线运行期间 | CI 作业使用的 runner 类型。                                                                   |
| `runner_id`             | 在 CI/CD 流水线运行期间 | 执行 CI 作业的 runner 的 ID。                                                                   |
| `sha`                   | 在 CI/CD 流水线运行期间 | CI 作业的提交 SHA。                                                                           |
| `environment`           | 在 CI/CD 流水线运行期间 | CI 作业部署到的环境。                                                                       |
| `environment_protected` | 在 CI/CD 流水线运行期间 | 部署的环境是否受保护。                                                                    |
| `environment_action`    | 在 CI/CD 流水线运行期间 | CI 作业中指定的环境操作。                                                              |
| `deployment_tier`       | 在 CI/CD 流水线运行期间 | CI 作业指定的环境的部署层级。                                                 |
| `user_access_level`     | 在用户触发的事件中    | 用户的角色，取值为 `guest`、`reporter`、`developer`、`maintainer`、`owner`。                 |
| `guest_access`          | 在用户触发的事件中    | 指示用户是否至少具有 `guest` 角色，取值为字符串 "true" 或 "false"。      |
| `reporter_access`       | 在用户触发的事件中    | 指示用户是否至少具有 `reporter` 角色，取值为字符串 "true" 或 "false"。   |
| `developer_access`      | 在用户触发的事件中    | 指示用户是否至少具有 `developer` 角色，取值为字符串 "true" 或 "false"。  |
| `maintainer_access`     | 在用户触发的事件中    | 指示用户是否至少具有 `maintainer` 角色，取值为字符串 "true" 或 "false"。 |
| `owner_access`          | 在用户触发的事件中    | 指示用户是否至少具有 `owner` 角色，取值为字符串 "true" 或 "false"。      |

这些声明是 [ID 令牌声明](../ci/secrets/id_token_authentication.md#token-payload)的超集。所有值均为字符串类型。有关更多详细信息和示例值，请参阅 ID 令牌声明文档。

<a id="control-access-to-google-cloud"></a>

## 控制对 Google Cloud 的访问

当您[设置工作负载身份联合](#create-and-configure-a-workload-identity-federation)时，许多标准极狐GitLab 声明（例如 `user_access_level`）会自动映射到
Google Cloud 属性。

您可以进一步自定义谁可以从您的极狐GitLab 组织访问 Google Cloud。为此，您可以使用[通用表达式语言 (CEL)](https://github.com/google/cel-spec/blob/master/doc/intro.md#introduction)
基于 Google Cloud 上的极狐GitLab 集成的 [OIDC 自定义属性](#oidc-custom-claims)来设置主体。

例如，要允许极狐GitLab 中具有 `maintainer` 角色的用户从极狐GitLab 项目 `gitlab-org/my-project` 将产物推送到 Google 制品仓库：

1. 登录 Google Cloud Console 并转到
   [**工作负载身份联合**页面](https://console.cloud.google.com/iam-admin/workload-identity-pools?supportedpurview=project)。
1. 在**显示名称**列中，选择您的工作负载身份池。
1. 在**提供商**部分中，在您要编辑的工作负载身份提供商旁边，
   选择**编辑** ({{< icon name="pencil" >}}) 以打开**提供商详细信息**。
1. 在**属性映射**部分中，选择**添加映射**。
1. 在 **Google N** 文本框中，输入：

   ```shell
   attribute.my_project_maintainer
   ```

1. 在 **OIDC N** 文本框中，输入以下 CEL 表达式：

   ```shell
   assertion.maintainer_access=="true" && assertion.project_path=="gitlab-org/my-project"
   ```

1. 选择**保存**。

   Google 属性 `my_project_maintainer` 会映射到极狐GitLab 声明
   `maintainer_access==true` 和 `project_path=="gitlab-org/my-project"`。
1. 在 Google Cloud Console 中，转到 [**IAM** 页面](https://console.cloud.google.com/iam-admin/iam?supportedpurview=project)。
1. 选择**授予访问权限**。
1. 在**新主体**文本框中，输入包含
   `attribute.my_project_maintainer/true`的主体集，格式如下：

   ```shell
   principalSet://iam.googleapis.com/projects/<PROJECT_NUMBER>/locations/global/workloadIdentityPools/<POOL_ID>/attribute.my_project_maintainer/true
   ```

   替换以下内容：

   - `<PROJECT_NUMBER>` 替换为您的 Google Cloud 项目编号。要查找
     您的项目编号，请参阅[识别项目](https://cloud.google.com/resource-manager/docs/creating-managing-projects#identifying_projects)。
   - `<POOL_ID>` 替换为您的工作负载身份池 ID。

1. 在**选择角色**下拉列表中，选择 **Google 制品仓库 Writer 角色**
   (`roles/artifactregistry.writer`)。
1. 选择**保存**。

该角色会授予给包含极狐GitLab 中项目 `gitlab-org/my-project` 上具有 `maintainer` 角色的用户的主体集。

要防止您的其他极狐GitLab 项目将产物推送到 Google 制品仓库，您
可以在 Google Cloud Console 中查看您的 IAM 策略，并
根据需要移除或编辑角色。

<a id="view-your-iam-policies"></a>

## 查看您的 IAM 策略

登录 Google Cloud Console 并转到
[**IAM** 页面](https://console.cloud.google.com/iam-admin/iam?supportedpurview=project)

您可以选择**按主体查看**或**按角色查看**。
