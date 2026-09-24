---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 套餐限制 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

通过此 API，你可以与现有订阅套餐的应用程序限制进行交互。

现有套餐取决于 极狐GitLab 的版本。在基础版中，仅 `default` 套餐可用。在企业版中，还有其它套餐可用。

先决条件：

- 你必须拥有实例的管理员访问权限。

<a id="retrieve-current-plan-limits"></a>

## 获取当前套餐限制

获取 极狐GitLab 实例上某个套餐的当前限制。

```plaintext
GET /application/plan_limits
```

| 属性                                | 类型    | 是否必填 | 描述                                                         |
| ----------------------------------- | ------- | -------- | ------------------------------------------------------------ |
| `plan_name`                         | string  | 否       | 要获取限制的套餐名称。默认值：`default`。                    |

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
  "conan_max_file_size": 3221225472,
  "enforcement_limit": 10000,
  "generic_packages_max_file_size": 5368709120,
  "helm_max_file_size": 5242880,
  "notification_limit": 10000,
  "maven_max_file_size": 3221225472,
  "npm_max_file_size": 524288000,
  "nuget_max_file_size": 524288000,
  "pipeline_hierarchy_size": 1000,
  "pypi_max_file_size": 3221225472,
  "terraform_module_max_file_size": 1073741824,
  "storage_size_limit": 15000
}
```

<a id="update-plan-limits"></a>

## 更新套餐限制

更新 极狐GitLab 实例上某个套餐的限制。

```plaintext
PUT /application/plan_limits
```

| 属性                                | 类型    | 是否必填 | 描述                                                         |
| ----------------------------------- | ------- | -------- | ------------------------------------------------------------ |
| `plan_name`                         | string  | 是       | 要更新的套餐名称。                                           |
| `ci_instance_level_variables`       | integer | 否       | 可定义的实例级 CI/CD 变量的最大数量。                        |
| `ci_pipeline_size`                  | integer | 否       | 单个流水线中作业的最大数量。引入于 极狐GitLab 15.0。         |
| `ci_active_jobs`                    | integer | 否       | 当前活跃流水线中的作业总数。引入于 极狐GitLab 15.0。         |
| `ci_project_subscriptions`          | integer | 否       | 一个项目可以订阅或被订阅的流水线的最大数量。引入于 极狐GitLab 15.0。 |
| `ci_pipeline_schedules`             | integer | 否       | 流水线调度的最大数量。引入于 极狐GitLab 15.0。               |
| `ci_needs_size_limit`               | integer | 否       | 一个作业可以拥有的 [`needs` 依赖关系](../ci/yaml/needs.md) 的最大数量。引入于 极狐GitLab 15.0。 |
| `ci_registered_group_runners`       | integer | 否       | 过去七天内在一个群组中创建或处于活跃状态的 Runner 的最大数量。引入于 极狐GitLab 15.0。 |
| `ci_registered_project_runners`     | integer | 否       | 过去七天内在一个项目中创建或处于活跃状态的 Runner 的最大数量。引入于 极狐GitLab 15.0。 |
| `dotenv_size`                       | integer | 否       | dotenv 产物的最大大小（字节）。引入于 极狐GitLab 17.1。      |
| `dotenv_variables`                  | integer | 否       | dotenv 产物中变量的最大数量。引入于 极狐GitLab 17.1。        |
| `conan_max_file_size`               | integer | 否       | Conan 软件包文件的最大大小（字节）。                         |
| `enforcement_limit`                 | integer | 否       | 用于强制执行的根命名空间存储大小限制（MiB）。                 |
| `generic_packages_max_file_size`    | integer | 否       | 通用软件包文件的最大大小（字节）。                           |
| `helm_max_file_size`                | integer | 否       | Helm chart 文件的最大大小（字节）。                          |
| `maven_max_file_size`               | integer | 否       | Maven 软件包文件的最大大小（字节）。                         |
| `notification_limit`                | integer | 否       | 用于通知的根命名空间存储大小限制（MiB）。                     |
| `npm_max_file_size`                 | integer | 否       | NPM 软件包文件的最大大小（字节）。                           |
| `nuget_max_file_size`               | integer | 否       | NuGet 软件包文件的最大大小（字节）。                         |
| `pipeline_hierarchy_size`           | integer | 否       | 流水线层级树中下游流水线的最大数量。默认值：`1000`。大于 1000 的值[不推荐](../administration/instance_limits.md#limit-pipeline-hierarchy-size)。 |
| `pypi_max_file_size`                | integer | 否       | PyPI 软件包文件的最大大小（字节）。                          |
| `terraform_module_max_file_size`    | integer | 否       | Terraform 模块软件包文件的最大大小（字节）。                 |
| `storage_size_limit`                | integer | 否       | 根命名空间的最大存储大小（MiB）。                            |
| `web_hook_calls`                    | integer | 否       | 每个顶级命名空间每分钟可以调用 webhook 的最大次数。引入于 极狐GitLab 18.5。 |

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
  "conan_max_file_size": 3221225472,
  "dotenv_variables": 20,
  "dotenv_size": 5120,
  "generic_packages_max_file_size": 5368709120,
  "helm_max_file_size": 5242880,
  "maven_max_file_size": 3221225472,
  "npm_max_file_size": 524288000,
  "nuget_max_file_size": 524288000,
  "pipeline_hierarchy_size": 1000,
  "pypi_max_file_size": 3221225472,
  "terraform_module_max_file_size": 1073741824
}
```