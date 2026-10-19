---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Google Cloud 集成 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Status: Experiment

{{< /details >}}

使用此 API 与 Google Cloud 集成进行交互。更多信息，请参阅[极狐GitLab 与 Google Cloud 集成](../ci/gitlab_google_cloud_integration/_index.md)。

<a id="project-level-google-cloud-integration-scripts"></a>

## 项目级别的 Google Cloud 集成脚本

{{< details >}}

- Status: Experiment

{{< /details >}}

{{< history >}}

- 引入 于极狐GitLab 16.10。此功能为 [实验](../policy/development_stages_support.md)。

{{< /history >}}

<a id="workload-identity-federation-creation-script"></a>

### 工作负载身份联合创建脚本

{{< history >}}

- 引入 于极狐GitLab 16.10。

{{< /history >}}

具有项目维护者或所有者角色的用户可以使用以下端点来查询一个 Shell 脚本，该脚本会在 Google Cloud 中创建并配置工作负载身份联合：

```plaintext
GET /projects/:id/google_cloud/setup/wlif.sh
```

支持的属性：

| 属性                                               | 类型    | 是否必需 | 描述                                                                                      |
|---------------------------------------------------|--------|----------|------------------------------------------------------------------------------------------|
| `id`                                              | integer | 是       | 项目的 ID。                                                                              |
| `google_cloud_project_id`                         | string  | 是       | 用于工作负载身份联合的 Google Cloud 项目 ID。                                               |
| `google_cloud_workload_identity_pool_id`          | string  | 否       | 要创建的 Google Cloud 工作负载身份池的 ID。默认为 `gitlab-wlif`。                             |
| `google_cloud_workload_identity_pool_display_name`| string  | 否       | 要创建的 Google Cloud 工作负载身份池的显示名称。默认为 `WLIF for GitLab integration`。           |
| `google_cloud_workload_identity_pool_provider_id` | string  | 否       | 要创建的 Google Cloud 工作负载身份池提供程序的 ID。默认为 `gitlab-wlif-oidc-provider`。            |
| `google_cloud_workload_identity_pool_provider_display_name` | string | 否 | 要创建的 Google Cloud 工作负载身份池提供程序的显示名称。默认为 `GitLab OIDC provider`。                |

示例请求：

```shell
curl --request GET \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --url "https://jihulab.com/api/v4/projects/<your_project_id>/google_cloud/setup/wlif.sh"
```

<a id="script-to-set-up-a-google-cloud-integration"></a>

### 设置 Google Cloud 集成的脚本

{{< history >}}

- 引入 于极狐GitLab 16.10。

{{< /history >}}

具有项目维护者或所有者角色的用户可以使用以下端点来查询一个 Shell 脚本，以设置 Google Cloud 集成：

```plaintext
GET /projects/:id/google_cloud/setup/integrations.sh
```

目前仅支持 [Google Artifact Management 集成](../user/project/integrations/google_artifact_management.md)。
该脚本会创建 IAM 策略以访问 Google Artifact Registry：

- [Artifact Registry Reader](https://cloud.google.com/artifact-registry/docs/access-control#roles) 角色授予给至少具有报告者角色的成员
- [Artifact Registry Writer](https://cloud.google.com/artifact-registry/docs/access-control#roles) 角色授予给至少具有开发者角色的成员

支持的属性：

| 属性                                    | 类型    | 是否必需 | 描述                                                                 |
|-----------------------------------------|--------|----------|---------------------------------------------------------------------|
| `id`                                    | integer | 是       | 极狐GitLab 项目的 ID。                                                        |
| `enable_google_cloud_artifact_registry` | boolean | 是       | 指示是否应启用 Google Artifact Management 集成的标志。                     |
| `google_cloud_artifact_registry_project_id` | string  | 是   | 用于 Artifact Registry 的 Google Cloud 项目 ID。                         |

示例请求：

```shell
curl --request GET \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --url "https://jihulab.com/api/v4/projects/<your_project_id>/google_cloud/setup/integrations.sh"
```

<a id="script-to-configure-a-google-cloud-project-for-runner-provisioning"></a>

### 为 Runner 预配配置 Google Cloud 项目的脚本

{{< history >}}

- 引入 于极狐GitLab 16.10。

{{< /history >}}

具有项目维护者或所有者角色的用户可以使用以下端点来查询一个 Shell 脚本，以配置 Google Cloud 项目用于 Runner 的预配和执行：

```plaintext
GET /projects/:id/google_cloud/setup/runner_deployment_project.sh
```

该脚本在指定的 Google Cloud 项目中执行预配置步骤，即启用所需的服务，并创建 `GRITProvisioner` 角色和 `grit-provisioner` 服务账号。

支持的属性：

| 属性                 | 类型    | 是否必需 | 描述                          |
|---------------------|--------|----------|------------------------------|
| `id`                | integer | 是       | 极狐GitLab 项目的 ID。             |
| `google_cloud_project_id` | string  | 是       | Google Cloud 项目的 ID。         |

示例请求：

```shell
curl --request GET \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --url "https://jihulab.com/api/v4/projects/<your_project_id>/google_cloud/setup/runner_deployment_project.sh?google_cloud_project_id=<your_google_cloud_project_id>"
```