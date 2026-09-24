---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://gitlab.cn/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab 管理的 Kubernetes 资源
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 17.9 中[引入]，带一个名为 `gitlab_managed_cluster_resources` 的[功能标志]。默认禁用。
- 功能标志 `gitlab_managed_cluster_resources` 在极狐GitLab 18.1 中[移除]。

{{< /history >}}

使用极狐GitLab 管理的 Kubernetes 资源，通过环境模板来配置 Kubernetes 资源。环境模板可以：

- 自动为新环境创建命名空间和服务账号
- 通过角色绑定管理访问权限
- 配置其他必需的 Kubernetes 资源

当开发者部署应用时，极狐GitLab 会根据环境模板创建资源。

<a id="configure-gitlab-managed-kubernetes-resources"></a>

## 配置极狐GitLab 管理的 Kubernetes 资源

前提条件：

- 你必须已经配置了[极狐GitLab Kubernetes 代理](install/_index.md)。
- 你已[授权代理](ci_cd_workflow.md#authorize-agent-access)访问相关项目或群组。
- （可选）你已配置[代理模拟](ci_cd_workflow.md#restrict-project-and-group-access-by-using-impersonation)以防止权限提升。默认环境模板假设你已经配置了 [`ci_job` 模拟](ci_cd_workflow.md#impersonate-the-cicd-job-that-accesses-the-cluster)。

<a id="turn-on-kubernetes-resource-management"></a>

### 启用 Kubernetes 资源管理

<a id="in-your-agent-configuration-file"></a>

#### 在代理配置文件中

要启用资源管理，修改代理配置文件以包含所需的权限：

```yaml
ci_access:
  projects:
    - id: <your_group/your_project>
      access_as:
        ci_job: {}
      resource_management:
        enabled: true
  groups:
    - id: <your_other_group>
      access_as:
        ci_job: {}
      resource_management:
        enabled: true
```

<a id="in-your-ci/cd-jobs"></a>

#### 在 CI/CD 作业中

要让代理为环境管理资源，在你的部署作业中指定代理。例如：

```yaml
deploy_review:
  stage: deploy
  script:
    - echo "Deploy a review app"
  environment:
    name: review/$CI_COMMIT_REF_SLUG
    kubernetes:
      agent: path/to/agent/project:agent-name
```

CI/CD 变量可以在代理路径中使用。更多信息，请参阅[变量可以在何处使用](../../../ci/variables/where_variables_can_be_used.md)。

<a id="create-environment-templates"></a>

### 创建环境模板

环境模板定义了哪些 Kubernetes 资源被创建、更新或删除。

[默认环境模板](https://jihulab.com/gitlab-cn/cluster-integration/gitlab-agent/-/blob/master/internal/module/managed_resources/server/default_template.yaml)会创建一个 `Namespace` 并为 CI/CD 作业配置一个 `RoleBinding`。

要覆盖默认模板，在代理目录中添加一个名为 `default.yaml` 的模板配置文件：

```plaintext
.gitlab/agents/<agent-name>/environment_templates/default.yaml
```

<a id="supported-kubernetes-resources"></a>

#### 支持的 Kubernetes 资源

支持以下 Kubernetes 资源（`kind`）：

- `Namespace`
- `ServiceAccount`
- `RoleBinding`
- FluxCD Source Controller 对象：
  - `GitRepository`
  - `HelmRepository`
  - `HelmChart`
  - `Bucket`
  - `OCIRepository`
- FluxCD Kustomize Controller 对象：
  - `Kustomization`
- FluxCD Helm Controller 对象：
  - `HelmRelease`
- FluxCD Notification Controller 对象：
  - `Alert`
  - `Provider`
  - `Receiver`

<a id="example-environment-template"></a>

#### 环境模板示例

以下示例创建一个命名空间并授予群组管理员集群访问权限。

```yaml
objects:
  - apiVersion: v1
    kind: Namespace
    metadata:
      name: '{{ .environment.slug }}-{{ .project.id }}-{{ .agent.id }}'
  - apiVersion: rbac.authorization.k8s.io/v1
    kind: RoleBinding
    metadata:
      name: bind-{{ .environment.slug }}-{{ .project.id }}-{{ .agent.id }}
      namespace: '{{ .environment.slug }}-{{ .project.id }}-{{ .agent.id }}'
    subjects:
      - kind: Group
        apiGroup: rbac.authorization.k8s.io
        name: gitlab:project_env:{{ .project.id }}:{{ .environment.slug }}
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: admin

# 资源生命周期配置
apply_resources: on_start    # 环境启动/重启时应用资源
delete_resources: on_stop    # 环境停止时删除资源
```

<a id="template-variables"></a>

### 模板变量

环境模板支持有限的变量替换。可用变量如下：

| 分类          | 变量                           | 描述                                                     | 类型    | 未设置时的默认值            |
|---------------|--------------------------------|----------------------------------------------------------|---------|----------------------------|
| Agent         | `{{ .agent.id }}`              | 代理 ID。                                                | Integer | 不适用                     |
| Agent         | `{{ .agent.name }}`            | 代理名称。                                               | String  | 不适用                     |
| Agent         | `{{ .agent.url }}`             | 代理 URL。                                               | String  | 不适用                     |
| Environment   | `{{ .environment.id }}`        | 环境 ID。                                                | Integer | 不适用                     |
| Environment   | `{{ .environment.name }}`      | 环境名称。                                               | String  | 不适用                     |
| Environment   | `{{ .environment.slug }}`      | 基于环境名称的环境标识。最长 24 个小写字母数字字符（包括 `-`），以字母开头，不以 `-` 结尾。 | String  | 不适用                     |
| Environment   | `{{ .environment.url }}`       | 环境 URL。                                               | String  | 空字符串                   |
| Environment   | `{{ .environment.page_url }}`  | 环境页面 URL。                                           | String  | 不适用                     |
| Environment   | `{{ .environment.tier }}`      | 环境层级。                                               | String  | 不适用                     |
| Project       | `{{ .project.id }}`            | 项目 ID。                                                | Integer | 不适用                     |
| Project       | `{{ .project.slug }}`          | 项目标识。此为项目路径中未经修改的最后一部分。           | String  | 不适用                     |
| Project       | `{{ .project.path }}`          | 项目路径。                                               | String  | 不适用                     |
| Project       | `{{ .project.url }}`           | 项目 URL。                                               | String  | 不适用                     |
| CI/CD Pipeline| `{{ .ci_pipeline.id }}`        | 流水线 ID。                                              | Integer | 零                         |
| CI/CD Job     | `{{ .ci_job.id }}`             | CI/CD 作业 ID。                                          | Integer | 零                         |
| User          | `{{ .user.id }}`               | 用户 ID。                                                | Integer | 不适用                     |
| User          | `{{ .user.username }}`         | 用户名。                                                 | String  | 不适用                     |
| Namespace     | `{{ .legacy_namespace }}`      | 已弃用的基于证书的集集群成为此环境生成的 Kubernetes 命名空间。此命名空间仅用于从基于证书的集集群成迁移至极狐GitLab 管理的资源。请勿用于任何其他目的。 | String | 不适用 |

所有变量应使用双大括号语法引用，例如：`{{ .project.id }}`。有关所用模板系统的更多信息，请参见 [`text/template`](https://pkg.go.dev/text/template) 文档。

<a id="template-functions"></a>

### 模板函数

环境模板支持有限的函数来处理变量值。可用函数如下：

| 名称          | 参数                       | 描述                                               | 示例                                        |
|---------------|---------------------------|----------------------------------------------------|---------------------------------------------|
| `lower`       | `<string>`                | 转换为小写。                                       | `lower "HELLO"` -> `"hello"`                |
| `substr`      | `<start> <end> <string>`  | 从字符串中提取子串。                               | `substr 0 5 "hello world"` -> `"hello"`     |
| `replace`     | `<old> <new> <string>`    | 替换字符串中所有出现的子串。                       | `replace "_" "-" "foo_bar"` -> `"foo-bar"`  |
| `trimPrefix`  | `<prefix> <string>`       | 移除字符串的前缀。                                 | `trimPrefix "-" "-hello"` -> `"hello"`      |
| `trimSuffix`  | `<suffix> <string>`       | 移除字符串的后缀。                                 | `trimSuffix "-" "hello-"` -> `"hello"`      |
| `slugify`     | `[<len>] <string>`        | 根据 RFC1123 对给定字符串进行标识化。默认截断至 `63` 个字符。 | `slugify "hello WORLD"` -> `"hello-world"`  |

为使变量符合 Kubernetes 值的要求，函数数量有意限制为最小集合，例如命名空间名称或标签。

<a id="resource-lifecycle-management"></a>

### 资源生命周期管理

{{< history >}}

- 在极狐GitLab 18.0 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/507486)。

{{< /history >}}

使用以下设置来配置何时删除 Kubernetes 资源：

```yaml
# 永不删除资源
delete_resources: never

# 环境停止时删除资源
delete_resources: on_stop
```

默认值为 `on_stop`，在[默认环境模板](https://jihulab.com/gitlab-cn/cluster-integration/gitlab-agent/-/blob/master/internal/module/managed_resources/server/default_template.yaml)中指定。

<a id="managed-resource-labels-and-annotations"></a>

### 被管理资源的标签和注解

极狐GitLab 创建的资源使用一系列标签和注解，用于追踪和故障排除。

以下标签定义在极狐GitLab 创建的每个资源上，其值有意留空：

- `agent.gitlab.com/id-<agent_id>: ""`
- `agent.gitlab.com/project_id-<project_id>: ""`
- `agent.gitlab.com/env-<gitlab_environment_slug>-<project_id>-<agent_id>: ""`
- `agent.gitlab.com/environment_slug-<gitlab_environment_slug>: ""`

在极狐GitLab 创建的每个资源上，都会定义一个 `agent.gitlab.com/env-<gitlab_environment_slug>-<project_id>-<agent_id>` 注解。该注解的值是一个 JSON 对象，包含以下键：

| 键                     | 描述                               |
|------------------------|------------------------------------|
| `environment_id`       | 极狐GitLab 环境 ID。               |
| `environment_name`     | 极狐GitLab 环境名称。              |
| `environment_slug`     | 极狐GitLab 环境标识。              |
| `environment_url`      | 环境链接。可选。                   |
| `environment_page_url` | 极狐GitLab 环境页面链接。          |
| `environment_tier`     | 极狐GitLab 环境部署层级。          |
| `agent_id`             | 代理 ID。                          |
| `agent_name`           | 代理名称。                         |
| `agent_url`            | 代理注册项目中的代理 URL。         |
| `project_id`           | 极狐GitLab 项目 ID。               |
| `project_slug`         | 极狐GitLab 项目标识。              |
| `project_path`         | 极狐GitLab 项目完整路径。          |
| `project_url`          | 极狐GitLab 项目链接。              |
| `template_name`        | 所使用的模板名称。                 |

<a id="disable-gitlab-managed-kubernetes-resources"></a>

### 禁用极狐GitLab 管理的 Kubernetes 资源

你可以针对特定环境禁用极狐GitLab 管理的 Kubernetes 资源，同时仍然可以使用其他 Kubernetes 功能，如仪表板。当使用默认启用了管理资源的全局代理，但你需要为特定项目或环境选择退出时，禁用管理资源会很有帮助。

要为某个环境禁用管理资源，添加 `managed_resources.enabled: false` 配置：

```yaml
deploy_review:
  stage: deploy
  script:
    - echo "Deploy a review app"
  environment:
    name: review/$CI_COMMIT_REF_SLUG
    kubernetes:
      agent: path/to/agent/project:agent-name
      managed_resources:
        enabled: false
```

<a id="troubleshooting"></a>

## 故障排除

与管理的 Kubernetes 资源相关的任何错误都可以在以下位置找到：

- 极狐GitLab 项目中的环境页面
- 在流水线中使用该功能时的 CI/CD 作业日志