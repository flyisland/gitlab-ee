---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab 托管的 Kubernetes 资源
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用极狐GitLab 托管的 Kubernetes 资源，通过环境模板预配 Kubernetes 资源。环境模板可以：

- 为新环境自动创建命名空间和服务账号
- 通过角色绑定管理访问权限
- 配置其他所需的 Kubernetes 资源

当开发者部署应用时，极狐GitLab 会根据环境模板创建这些资源。

<a id="configure-gitlab-managed-kubernetes-resources"></a>

## 配置极狐GitLab 托管的 Kubernetes 资源

先决条件：

- 您必须已配置[极狐GitLab Kubernetes Agent](install/_index.md)。
- 您已[授权该 Agent](ci_cd_workflow.md#authorize-agent-access) 访问相关项目或群组。
- （可选）您已配置 [Agent 模拟](ci_cd_workflow.md#restrict-project-and-group-access-by-using-impersonation)以防止权限提升。默认环境模板假定您已配置 [`ci_job` 模拟](ci_cd_workflow.md#impersonate-the-cicd-job-that-accesses-the-cluster)。

<a id="turn-on-kubernetes-resource-management"></a>

### 开启 Kubernetes 资源管理

<a id="in-your-agent-configuration-file"></a>

#### 在 Agent 配置文件中

要开启资源管理，请修改 Agent 配置文件以包含所需权限：

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

<a id="in-your-cicd-jobs"></a>

#### 在 CI/CD 作业中

要让 Agent 为某个环境管理资源，请在部署作业中指定该 Agent。例如：

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

Agent 路径中可以使用 CI/CD 变量。更多信息，请参见[可以使用变量的位置](../../../ci/variables/where_variables_can_be_used.md)。

<a id="create-environment-templates"></a>

### 创建环境模板

环境模板定义要创建、更新或移除哪些 Kubernetes 资源。

[默认环境模板](https://gitlab.com/gitlab-org/cluster-integration/gitlab-agent/-/blob/master/internal/module/managed_resources/server/default_template.yaml)会创建一个 `Namespace`，并为 CI/CD 作业配置一个 `RoleBinding`。

要覆盖默认模板，请在 Agent 目录中添加名为 `default.yaml`的模板配置文件：

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

以下示例创建一个命名空间，并授予群组管理员对集群的访问权限。

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

# Resource lifecycle configuration
apply_resources: on_start    # Resources are applied when environment is started/restarted
delete_resources: on_stop    # Resources are removed when environment is stopped
```

<a id="template-variables"></a>

### 模板变量

环境模板支持有限的变量替换。以下变量可用：

| 类别       | 变量                      | 描述               | 类型    | 未设置时的默认值 |
|----------------|-------------------------------|---------------------------|---------|----------------------------|
| Agent          | `{{ .agent.id }}`             | Agent ID。             | 整数 | 不适用                       |
| Agent          | `{{ .agent.name }}`           | Agent 名称。           | 字符串  | 不适用                       |
| Agent          | `{{ .agent.url }}`            | Agent URL。            | 字符串  | 不适用                       |
| 环境    | `{{ .environment.id }}`       | 环境 ID。       | 整数 | 不适用                       |
| 环境    | `{{ .environment.name }}`     | 环境名称。     | 字符串  | 不适用                       |
| 环境    | `{{ .environment.slug }}`     | 基于环境名称的环境 slug。最多 24 个小写字母数字字符，可包含 `-`，以字母开头，且不以 `-` 结尾。 | 字符串  | 不适用                       |
| 环境    | `{{ .environment.url }}`      | 环境 URL。      | 字符串  | 空字符串               |
| 环境    | `{{ .environment.page_url }}` | 环境页面 URL。 | 字符串  | 不适用                       |
| 环境    | `{{ .environment.tier }}`     | 环境层级。     | 字符串  | 不适用                       |
| 项目        | `{{ .project.id }}`           | 项目 ID。           | 整数 | 不适用                       |
| 项目        | `{{ .project.slug }}`         | 项目 slug。这是项目路径中未经修改的最后一部分。        | 字符串  | 不适用                       |
| 项目        | `{{ .project.path }}`         | 项目路径。         | 字符串  | 不适用                       |
| 项目        | `{{ .project.url }}`          | 项目 URL。          | 字符串  | 不适用                       |
| CI/CD 流水线 | `{{ .ci_pipeline.id }}`       | 流水线 ID。          | 整数 | 零                       |
| CI/CD 作业      | `{{ .ci_job.id }}`            | CI/CD 作业 ID。         | 整数 | 零                       |
| 用户           | `{{ .user.id }}`              | 用户 ID。              | 整数 | 不适用                       |
| 用户           | `{{ .user.username }}`        | 用户名。             | 字符串  | 不适用                       |
| 命名空间      | `{{ .legacy_namespace }}`     | 已弃用的基于证书的集群集成原本会为此环境生成的 Kubernetes 命名空间。此命名空间仅用于从基于证书的集群集成迁移到极狐GitLab 托管的资源。请勿将其用于任何其他用途。 | 字符串 | 不适用 |

所有变量都应使用双花括号语法引用，例如：`{{ .project.id }}`。有关所用模板系统的更多信息，请参见 [`text/template`](https://pkg.go.dev/text/template) 文档。

<a id="template-functions"></a>

### 模板函数

环境模板支持有限的函数来操作变量值。以下函数可用：

| 名称         | 参数                | 描述                                          | 示例                                    |
|--------------|--------------------------|------------------------------------------------------|--------------------------------------------|
| `lower`      | `<string>`               | 转换为小写。                               | `lower "HELLO"` -> `"hello"`               |
| `substr`     | `<start> <end> <string>` | 从字符串中截取子串。                      | `substr 0 5 "hello world"` -> `"hello"`    |
| `replace`    | `<old> <new> <string>`   | 替换字符串中所有出现的子串。 | `replace "_" "-" "foo_bar"` -> `"foo-bar"` |
| `trimPrefix` | `<prefix> <string>`      | 从字符串中移除前缀。                   | `trimPrefix "-" "-hello"` -> `"hello"`     |
| `trimSuffix` | `<suffix> <string>`      | 从字符串中移除后缀。                   | `trimSuffix "-" "hello-"` -> `"hello"`   |
| `slugify`    | `[<len>] <string>`       | 根据 RFC1123 将给定字符串转换为 slug。默认截断为 `63` 个字符。 | `slugify "hello WORLD"` -> `"hello-world"`   |

为使变量符合 Kubernetes 值的要求，函数数量被有意限制为一组最小的函数，例如用于命名空间名称或标签。

<a id="resource-lifecycle-management"></a>

### 资源生命周期管理

使用以下设置配置何时移除 Kubernetes 资源：

```yaml
# Never delete resources
delete_resources: never

# Delete resources when environment is stopped
delete_resources: on_stop
```

默认值为 `on_stop`，在[默认环境模板](https://gitlab.com/gitlab-org/cluster-integration/gitlab-agent/-/blob/master/internal/module/managed_resources/server/default_template.yaml)中指定。

<a id="managed-resource-labels-and-annotations"></a>

### 托管资源的标签和注解

极狐GitLab 创建的资源使用一系列标签和注解，用于跟踪和故障排除。

极狐GitLab 创建的每个资源上都定义了以下标签。这些值有意留空：

- `agent.gitlab.com/id-<agent_id>: ""`
- `agent.gitlab.com/project_id-<project_id>: ""`
- `agent.gitlab.com/env-<gitlab_environment_slug>-<project_id>-<agent_id>: ""`
- `agent.gitlab.com/environment_slug-<gitlab_environment_slug>: ""`

在极狐GitLab 创建的每个资源上，都定义了一个 `agent.gitlab.com/env-<gitlab_environment_slug>-<project_id>-<agent_id>` 注解。该注解的值是一个 JSON 对象，包含以下键：

| 键 | 描述                                      |
|-----|--------------------------------------------------|
| `environment_id` | 极狐GitLab 环境 ID。                       |
| `environment_name` | 极狐GitLab 环境名称。                     |
| `environment_slug` | 极狐GitLab 环境 slug。                     |
| `environment_url` | 指向环境的链接。可选。           |
| `environment_page_url` | 指向极狐GitLab 环境页面的链接。         |
| `environment_tier` | 极狐GitLab 环境部署层级。          |
| `agent_id` | Agent ID。                                    |
| `agent_name` | Agent 名称。                                  |
| `agent_url` | Agent 注册项目中的 Agent URL。 |
| `project_id` | 极狐GitLab 项目 ID。                           |
| `project_slug` | 极狐GitLab 项目 slug。                         |
| `project_path` | 完整的极狐GitLab 项目路径。                    |
| `project_url` | 指向极狐GitLab 项目的链接。                  |
| `template_name` | 所用模板的名称。                   |

<a id="disable-gitlab-managed-kubernetes-resources"></a>

### 禁用极狐GitLab 托管的 Kubernetes 资源

您可以为特定环境禁用极狐GitLab 托管的 Kubernetes 资源，同时仍使用仪表板等其他 Kubernetes 功能。当使用默认已启用托管资源的全局 Agent，但您需要为特定项目或环境选择退出时，禁用托管资源会很有帮助。

要为某个环境禁用托管资源，请添加 `managed_resources.enabled: false` 配置：

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

与托管的 Kubernetes 资源相关的任何错误都可以在以下位置找到：

- 极狐GitLab 项目中的环境页面
- 在流水线中使用该功能时的 CI/CD 作业日志
