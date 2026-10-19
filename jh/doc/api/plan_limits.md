---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: yes
title: 套餐限制 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

使用此 API 与您现有订阅套餐的应用限制进行交互。

现有套餐取决于极狐GitLab 版本。在基础版中，仅提供套餐 `default`。在企业版中，还提供其他套餐。

先决条件：

- 您必须具有实例的管理员访问权限。

<a id="retrieve-current-plan-limits"></a>

## 检索当前套餐限制

检索极狐GitLab 实例上某个套餐的当前限制。

```plaintext
GET /application/plan_limits
```

| 属性                         | 类型    | 是否必需 | 描述 |
| --------------------------------- | ------- | -------- | ----------- |
| `plan_name`                       | string  | 否       | 要获取限制的套餐名称。默认值：`default`。 |

```shell
curl --request GET \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/application/plan_limits"
```

示例响应：

```json
{
  "ci_instance_level_variables": 25,
  "ci_pipeline_size": 0,
  "ci_active_jobs": 0,
  "ci_project_subscriptions": 2,
  "ci_pipeline_schedules": 10,
  "ci_needs_size_limit": 50,
  "ci_registered_group_runners": 1000,
  "ci_registered_project_runners": 1000,
  "dotenv_size": 5120,
  "dotenv_variables": 20,
  "cargo_max_file_size": 5368709120,
  "conan_max_file_size": 3221225472,
  "enforcement_limit": 10000,
  "generic_packages_max_file_size": 5368709120,
  "helm_max_file_size": 5242880,
  "notification_limit": 10000,
  "maven_max_file_size": 3221225472,
  "npm_max_file_size": 524288000,
  "nuget_max_file_size": 524288000,
  "max_pipelines_per_merge_train": 20,
  "pipeline_hierarchy_size": 1000,
  "pypi_max_file_size": 3221225472,
  "service_desk_outbound_emails_per_hour": 0,
  "service_desk_outbound_emails_per_day": 0,
  "terraform_module_max_file_size": 1073741824,
  "storage_size_limit": 15000
}
```

<a id="update-plan-limits"></a>

## 更新套餐限制

更新极狐GitLab 实例上某个套餐的限制。

```plaintext
PUT /application/plan_limits
```

| 属性                         | 类型    | 是否必需 | 描述 |
| --------------------------------- | ------- | -------- | ----------- |
| `plan_name`                       | string  | 是      | 要更新的套餐名称。 |
| `ci_instance_level_variables`     | integer | 否       | 可定义的实例级 CI/CD 变量的最大数量。 |
| `ci_pipeline_size`                | integer | 否       | 单个流水线中的最大作业数量。 |
| `ci_active_jobs`                  | integer | 否       | 当前活跃流水线中的作业总数。 |
| `ci_project_subscriptions`        | integer | 否       | 项目发起或接收的流水线订阅的最大数量。 |
| `ci_pipeline_schedules`           | integer | 否       | 流水线计划的最大数量。 |
| `ci_needs_size_limit`             | integer | 否       | 一个作业可以拥有的 [`needs`](../ci/yaml/needs.md) 依赖项的最大数量。 |
| `ci_registered_group_runners`     | integer | 否       | 过去七天内在一个群组中创建或活跃的 runner 的最大数量。 |
| `ci_registered_project_runners`   | integer | 否       | 过去七天内在一个项目中创建或活跃的 runner 的最大数量。 |
| `dotenv_size`                     | integer | 否       | dotenv 产物的最大大小（以字节为单位）。[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/432529)于极狐GitLab 17.1。 |
| `dotenv_variables`                | integer | 否       | dotenv 产物中变量的最大数量。[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/432529)于极狐GitLab 17.1。 |
| `cargo_max_file_size`             | integer | 否       | Cargo 软件包文件的最大大小（以字节为单位）。[引入](https://gitlab.com/gitlab-org/gitlab/-/work_items/33060)于极狐GitLab 19.3。 |
| `conan_max_file_size`             | integer | 否       | Conan 软件包文件的最大大小（以字节为单位）。 |
| `enforcement_limit`               | integer | 否       | 触发根命名空间存储大小限制强制执行的最大存储大小（以 MiB 为单位）。 |
| `generic_packages_max_file_size`  | integer | 否       | 通用软件包文件的最大大小（以字节为单位）。 |
| `helm_max_file_size`              | integer | 否       | Helm chart 文件的最大大小（以字节为单位）。 |
| `maven_max_file_size`             | integer | 否       | Maven 软件包文件的最大大小（以字节为单位）。 |
| `notification_limit`              | integer | 否       | 触发根命名空间存储大小限制通知的最大存储大小（以 MiB 为单位）。 |
| `npm_max_file_size`               | integer | 否       | NPM 软件包文件的最大大小（以字节为单位）。 |
| `nuget_max_file_size`             | integer | 否       | NuGet 软件包文件的最大大小（以字节为单位）。 |
| `max_pipelines_per_merge_train`   | integer | 否       | 每个合并列车的并行流水线最大数量。默认值：`20`。最小值：`1`。[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/374188)于极狐GitLab 19.0。 |
| `pipeline_hierarchy_size`         | integer | 否       | 一个流水线层级树中下游流水线的最大数量。默认值：`1000`。大于 1000 的值[不建议使用](../administration/cicd/limits.md#limit-pipeline-hierarchy-size)。 |
| `pypi_max_file_size`              | integer | 否       | PyPI 软件包文件的最大大小（以字节为单位）。 |
| `service_desk_outbound_emails_per_hour` | integer | 否       | 每个顶级命名空间每小时发出的服务台电子邮件最大数量。0 表示无限制。[引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/253087)于极狐GitLab 19.4。 |
| `service_desk_outbound_emails_per_day`  | integer | 否       | 每个顶级命名空间每天发出的服务台电子邮件最大数量。0 表示无限制。[引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/253087)于极狐GitLab 19.4。 |
| `terraform_module_max_file_size`  | integer | 否       | Terraform Module 软件包文件的最大大小（以字节为单位）。 |
| `storage_size_limit`              | integer | 否       | 根命名空间的最大存储大小（以 MiB 为单位）。 |
| `web_hook_calls`                  | integer | 否       | 每个顶级命名空间每分钟可调用 webhook 的最大次数。[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/571738)于极狐GitLab 18.5。 |

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/application/plan_limits?plan_name=default&conan_max_file_size=3221225472"
```

示例响应：

```json
{
  "ci_instance_level_variables": 25,
  "ci_pipeline_size": 0,
  "ci_active_jobs": 0,
  "ci_project_subscriptions": 2,
  "ci_pipeline_schedules": 10,
  "ci_needs_size_limit": 50,
  "ci_registered_group_runners": 1000,
  "ci_registered_project_runners": 1000,
  "cargo_max_file_size": 5368709120,
  "conan_max_file_size": 3221225472,
  "dotenv_variables": 20,
  "dotenv_size": 5120,
  "generic_packages_max_file_size": 5368709120,
  "helm_max_file_size": 5242880,
  "maven_max_file_size": 3221225472,
  "npm_max_file_size": 524288000,
  "nuget_max_file_size": 524288000,
  "max_pipelines_per_merge_train": 20,
  "pipeline_hierarchy_size": 1000,
  "pypi_max_file_size": 3221225472,
  "service_desk_outbound_emails_per_hour": 0,
  "service_desk_outbound_emails_per_day": 0,
  "terraform_module_max_file_size": 1073741824
}
```
