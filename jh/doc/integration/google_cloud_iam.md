---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Google Cloud Workload Identity Federation 和 IAM 策略
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

{{< history >}}

- 在极狐GitLab 16.10 中引入，带有一个名为 `google_cloud_support_feature_flag` 的功能标志。
- 在极狐GitLab 17.1 中于 JihuLab.com 上启用。功能标志 `google_cloud_support_feature_flag` 被移除。

{{< /history >}}

要使用诸如
[Google Artifact Management 集成](../user/project/integrations/google_artifact_management.md)
之类的 Google Cloud 集成，
你必须创建并配置一个
[工作负载身份池和提供者](https://cloud.google.com/iam/docs/workload-identity-federation)。
Google Cloud 集成使用工作负载身份联合，
通过使用 JSON Web Token (JWT) 令牌的 OpenID Connect (OIDC)，
向极狐GitLab 工作负载授予对 Google Cloud 资源的访问权限。

## 工作负载身份联合

工作负载身份联合允许你使用 Identity and Access Management (IAM) 向外部身份授予
[IAM 角色](https://cloud.google.com/iam/docs/overview#roles)。

传统上，在 Google Cloud 之外运行的应用程序使用
[服务账号密钥](https://cloud.google.com/iam/docs/service-account-creds#key-types)
来访问 Google Cloud 资源。但是，服务账号密钥是强大的凭证，
如果管理不当，可能会带来安全风险。

通过身份联合，你可以使用 Identity and Access Management (IAM) 直接向
外部身份授予 IAM 角色，
而无需服务账号。此方法
消除了与服务账号及其密钥相关的
维护和安全负担。

## 工作负载身份池

_工作负载身份池_ 是一个实体，允许你管理
Google Cloud 上的非 Google 身份。

“极狐GitLab on Google Cloud”集成会引导你设置一个工作负载
身份池以向 Google Cloud 进行身份验证。此设置包括
将你的极狐GitLab 角色属性映射到你
Google Cloud IAM 策略中的 IAM 声明。有关“极狐GitLab on Google Cloud”集成可用的极狐GitLab
属性的完整列表，请参见
[OIDC 自定义声明](#oidc-custom-claims)。

## 工作负载身份池提供者

_工作负载身份池提供者_ 是描述 Google Cloud 与你的
身份提供者 (IdP) 之间关系的实体。对于“极狐GitLab on Google Cloud”集成，
极狐GitLab 是你工作负载身份池的 IdP。

有关外部工作负载身份联合的更多信息，请参见
[工作负载身份联合](https://cloud.google.com/iam/docs/workload-identity-federation)。

默认的“极狐GitLab on Google Cloud”集成假定你想要在极狐GitLab 组织级别设置从
极狐GitLab 到 Google Cloud 的身份验证。如果你想按项目
控制对 Google Cloud 的访问，则必须为你的
工作负载身份池提供者配置 IAM 策略。有关控制谁可以从你的极狐GitLab
组织访问 Google Cloud 的更多信息，请参见[使用 IAM 进行访问控制](https://cloud.google.com/docs/gitlab)。

## 使用工作负载身份联合进行极狐GitLab 身份验证

在你的工作负载身份池和提供者设置好，将你的极狐GitLab
角色和权限映射到 IAM 角色之后，你可以通过将
[`identity`](../ci/yaml/_index.md#identity) 关键字设置为
`google_cloud` 以在 Google Cloud 上进行授权，来配置极狐GitLab 执行器
以将工作负载从极狐GitLab 部署到 Google Cloud。

有关使用“极狐GitLab on Google Cloud”集成配置执行器的更多信息，请参见教程
[在 Google Cloud 中配置执行器](../ci/runners/provision_runners_google_cloud.md)。

## 创建和配置工作负载身份联合

要设置工作负载身份联合，你可以：

- 使用极狐GitLab UI 进行引导式设置。
- 使用 Google Cloud CLI 手动设置工作负载身份联合。

### 使用极狐GitLab UI

要使用极狐GitLab UI 设置工作负载身份联合：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **设置** > **集成**。
1. 找到 Google Cloud IAM 集成并选择 **配置**。
1. 选择 **引导式设置** 并按照说明操作。

### 使用 Google Cloud CLI

先决条件：

- Google Cloud CLI 必须已[安装并通过身份验证](https://cloud.google.com/sdk/docs/install)
  以访问 Google Cloud。
- 你必须拥有在 Google Cloud 中管理
  工作负载身份联合的[权限](https://cloud.google.com/iam/docs/manage-workload-identity-pools-providers#required-roles)。

1. 使用以下命令创建工作负载身份池。替换
   这些值：

   - `<your_google_cloud_project_id>` 为你的
     [Google Cloud 项目 ID](https://cloud.google.com/resource-manager/docs/creating-managing-projects#identifying_projects)。
     为了增强安全性，请使用一个专门用于身份管理的项目，
     与资源和 CI/CD 项目分开。
   - `<your_identity_pool_id>` 为要用于池的 ID，该 ID
     必须为 4 到 32 个小写字母、数字或连字符。为避免冲突，请使用一个
     唯一的 ID。你应该包含极狐GitLab 项目 ID 或项目路径，
     因为这有助于 IAM 策略管理。例如，
     `gitlab-my-project-name`。

   ```shell
   gcloud iam workload-identity-pools create <your_identity_pool_id> \
            --project="<your_google_cloud_project_id>" \
            --location="global" \
            --display-name="Workload identity pool for GitLab project ID"
   ```

1. 使用以下命令向工作负载身份池添加 OIDC 提供者。
   替换这些值：

   - `<your_identity_provider_id>` 为要用于提供者的 ID，
     必须为 4 到 32 个小写字母、数字或连字符。为避免冲突，
     请在身份池中使用唯一的 ID。例如，
     `gitlab`。
   - `<your_google_cloud_project_id>` 为你的
     [Google Cloud 项目 ID](https://cloud.google.com/resource-manager/docs/creating-managing-projects#identifying_projects)。
   - `<your_identity_pool_id>` 为你在上一步中创建的
     工作负载身份池的 ID。
   - `<your_issuer_uri>` 为你的身份提供者签发者 URI，该值
     可以在选择手动设置时从 IAM 集成页面复制，
     并且必须完全匹配。该参数必须包含顶层群组的路径。
     例如，如果项目位于 `my-root-group/my-subgroup/project-a` 下，
     则 `issuer-uri` 必须设置为
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

   `attribute-mapping` 参数必须包含 JWT ID 令牌中包含的 OIDC 自定义声明到
   用于在 Identity and Access Management (IAM) 策略中授予访问权限的
   对应身份属性的映射。有关更多信息，请参见你可以用来
   [控制对 Google Cloud 的访问](https://cloud.google.com/docs/gitlab#control-access-google)
   的[支持的 OIDC 自定义声明](google_cloud_iam.md#oidc-custom-claims)。

要将[身份令牌访问](https://cloud.google.com/iam/docs/workload-identity-federation#mapping)限制到特定的极狐GitLab 项目或群组，请使用属性条件。对项目使用属性 `assertion.project_id`，对群组使用属性 `assertion.namespace_id`。
有关更多信息，请参见关于如何[定义属性条件](https://cloud.google.com/iam/docs/workload-identity-federation-with-deployment-pipelines#gitlab-saas_2)的 Google Cloud 文档。在定义属性条件后，你可以[更新工作负载身份提供者](https://cloud.google.com/iam/docs/workload-identity-federation-with-deployment-pipelines#update_attribute_condition_on_a_workload_identity_provider)。

创建工作负载身份池和提供者后，要在极狐GitLab 中完成设置：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **设置** > **集成**。
1. 找到 Google Cloud IAM 集成并选择 **配置**。
1. 选择 **手动设置**
1. 填写字段。
   - **[项目 ID](https://cloud.google.com/resource-manager/docs/creating-managing-projects#identifying_projects)**
     用于你在其中创建工作负载身份池和提供者的 Google Cloud 项目。
     示例：`my-sample-project-191923`。
   - **[项目编号](https://cloud.google.com/resource-manager/docs/creating-managing-projects#identifying_projects)**
     用于同一个 Google Cloud 项目。示例：`314053285323`。
   - **Pool ID** 你为此集成创建的工作负载身份池的 ID。
   - **Provider ID** 你为此集成创建的工作负载身份提供者的 ID。

### OIDC 自定义声明

ID 令牌包含以下自定义声明：

| 声明名称                | 何时                      | 描述                                                                                              |
| ----------------------- | ------------------------- | -------------------------------------------------------------------------------------------------------- |
| `namespace_id`          | 项目事件时                | 群组或用户级别命名空间的 ID。                                                                 |
| `namespace_path`        | 项目事件时                | 群组或用户级别命名空间的路径。                                                               |
| `project_id`            | 项目事件时                | 项目的 ID。                                                                                       |
| `project_path`          | 项目事件时                | 项目的路径。                                                                                     |
| `root_namespace_id`     | 群组事件时                | 顶级群组或用户级别命名空间的 ID。                                                            |
| `root_namespace_path`   | 群组事件时                | 顶级群组或用户级别命名空间的路径。                                                          |
| `user_id`               | 用户触发的事件时          | 用户的 ID。                                                                                          |
| `user_login`            | 用户触发的事件时          | 用户的用户名。                                                                                    |
| `user_email`            | 用户触发的事件时          | 用户的电子邮件。                                                                                       |
| `ci_config_ref_uri`     | CI/CD 流水线运行期间      | 指向顶层 CI 流水线定义的引用路径。                                                    |
| `ci_config_sha`         | CI/CD 流水线运行期间      | `ci_config_ref_uri` 的 Git 提交 SHA。                                                              |
| `job_id`                | CI/CD 流水线运行期间      | CI 作业的 ID。                                                                                        |
| `pipeline_id`           | CI/CD 流水线运行期间      | CI 流水线的 ID。                                                                                   |
| `pipeline_source`       | CI/CD 流水线运行期间      | CI 流水线源。                                                                                      |
| `project_visibility`    | CI/CD 流水线运行期间      | 运行流水线的项目的可见性。                                             |
| `ref`                   | CI/CD 流水线运行期间      | CI 作业的 Git 引用。                                                                                  |
| `ref_path`              | CI/CD 流水线运行期间      | CI 作业的完全限定引用。                                                                      |
| `ref_protected`         | CI/CD 流水线运行期间      | Git 引用是否受保护。                                                                             |
| `ref_type`              | CI/CD 流水线运行期间      | Git 引用类型。                                                                                            |
| `runner_environment`    | CI/CD 流水线运行期间      | CI 作业使用的执行器类型。                                                                   |
| `runner_id`             | CI/CD 流水线运行期间      | 执行 CI 作业的极狐GitLab 执行器的 ID。                                                                   |
| `sha`                   | CI/CD 流水线运行期间      | CI 作业的提交 SHA。                                                                           |
| `environment`           | CI/CD 流水线运行期间      | CI 作业部署到的环境。                                                                       |
| `environment_protected` | CI/CD 流水线运行期间      | 部署的环境是否受保护。                                                                    |
| `environment_action`    | CI/CD 流水线运行期间      | CI 作业中指定的环境操作。                                                              |
| `deployment_tier`       | CI/CD 流水线运行期间      | CI 作业指定的环境的部署层级。                                                 |
| `user_access_level`     | 用户触发的事件时          | 用户的角色，值为 `guest`、`reporter`、`developer`、`maintainer`、`owner`。                 |
| `guest_access`          | 用户触发的事件时          | 指示用户是否至少具有 `guest` 角色，值为字符串 “true” 或 “false”。      |
| `reporter_access`       | 用户触发的事件时          | 指示用户是否至少具有 `reporter` 角色，值为字符串 “true” 或 “false”。   |
| `developer_access`      | 用户触发的事件时          | 指示用户是否至少具有 `developer` 角色，值为字符串 “true” 或 “false”。  |
| `maintainer_access`     | 用户触发的事件时          | 指示用户是否至少具有 `maintainer` 角色，值为字符串 “true” 或 “false”。 |
| `owner_access`          | 用户触发的事件时          | 指示用户是否至少具有 `owner` 角色，值为字符串 “true” 或 “false”。      |

这些声明是
[ID 令牌声明](../ci/secrets/id_token_authentication.md#token-payload)
的超集。所有值均为字符串类型。有关更多详细信息和示例值，请参见 ID 令牌声明文档。

## 控制对 Google Cloud 的访问

当你[设置工作负载身份联合](#create-and-configure-a-workload-identity-federation)时，
许多标准的极狐GitLab 声明（例如，`user_access_level`）会自动映射到
Google Cloud 属性。

你可以进一步自定义谁可以从你的极狐GitLab 组织访问 Google Cloud。
为此，你使用 [Common Expression Language (CEL)](https://github.com/google/cel-spec/blob/master/doc/intro.md#introduction)
来基于“极狐GitLab on Google Cloud”集成的 [OIDC 自定义属性](#oidc-custom-claims)设置主体。

例如，要允许在极狐GitLab 中具有 `maintainer` 角色的用户从
极狐GitLab 项目 `gitlab-org/my-project` 将
制品推送到 Google Artifact Registry：

1. 登录 Google Cloud 控制台并转到
   [**工作负载身份联合** 页面](https://console.cloud.google.com/iam-admin/workload-identity-pools?supportedpurview=project)。
1. 在 **显示名称** 列中，选择你的工作负载身份池。
1. 在 **提供者** 部分，在你想要编辑的工作负载身份提供者旁边，
   选择 **编辑** ({{< icon name="pencil" >}}) 以打开 **提供者详细信息**。
1. 在 **属性映射** 部分，选择 **添加映射**。
1. 在 **Google N** 文本框中，输入：

   ```shell
   attribute.my_project_maintainer
   ```

1. 在 **OIDC N** 文本框中，输入以下 CEL 表达式：

   ```shell
   assertion.maintainer_access=="true" && assertion.project_path=="gitlab-org/my-project"
   ```

1. 选择 **保存**。

   Google 属性 `my_project_maintainer` 映射到了极狐GitLab 声明
   `maintainer_access==true` 和 `project_path=="gitlab-org/my-project"`。
1. 在 Google Cloud 控制台中，转到 [**IAM** 页面](https://console.cloud.google.com/iam-admin/iam?supportedpurview=project)。
1. 选择 **授予访问权限**。
1. 在 **新的主体** 文本框中，以如下格式输入包含
   `attribute.my_project_maintainer/true` 的主体集：

   ```shell
   principalSet://iam.googleapis.com/projects/<PROJECT_NUMBER>/locations/global/workloadIdentityPools/<POOL_ID>/attribute.my_project_maintainer/true
   ```

   替换以下内容：

   - `<PROJECT_NUMBER>` 为你的 Google Cloud 项目编号。要查找
     你的项目编号，请参见[识别项目](https://cloud.google.com/resource-manager/docs/creating-managing-projects#identifying_projects)。
   - `<POOL_ID>` 为你的工作负载身份池 ID。

1. 在 **选择角色** 下拉列表中，选择 **Google Artifact Registry Writer 角色**
   (`roles/artifactregistry.writer`)。
1. 选择 **保存**。

该角色被授予包含在极狐GitLab 项目 `gitlab-org/my-project` 中
具有 `maintainer` 角色的用户的主体集。

要阻止你的其他极狐GitLab 项目将制品推送到 Google Artifact Registry，
你可以在 Google Cloud 控制台中查看你的 IAM 策略，
并根据需要移除或编辑角色。

## 查看你的 IAM 策略

登录 Google Cloud 控制台并转到
[**IAM** 页面](https://console.cloud.google.com/iam-admin/iam?supportedpurview=project)

你可以选择 **按主体查看** 或 **按角色查看**。