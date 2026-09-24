---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 向用户授权访问 Kubernetes
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Status: 测试版

{{< /details >}}

{{< history >}}

- 于 GitLab 16.1 推出，需启用功能标志 `environment_settings_to_graphql`、`kas_user_access`、`kas_user_access_project` 和 `expose_authorized_cluster_agents`。该功能处于[测试版](../../../policy/development_stages_support.md#beta)。
- 功能标志 `environment_settings_to_graphql` 于 GitLab 16.2 移除。
- 功能标志 `kas_user_access`、`kas_user_access_project` 和 `expose_authorized_cluster_agents` 于 GitLab 16.2 移除。
- 代理连接共享限制从 100 提升至 500，于 GitLab 17.0。
- `user_access` 参数 `access_as` 于 GitLab 18.3 变为可选。默认使用代理身份模拟。
- 于 GitLab 18.4 变更，允许授权属于不同顶级群组的项目和群组。

{{< /history >}}

作为组织中 Kubernetes 集群的管理员，你可以向特定项目或群组的成员授予 Kubernetes 访问权限。

授予访问权限同时会激活项目或群组的 [Kubernetes 仪表板](../../../ci/environments/kubernetes_dashboard.md)。

对于私有化部署的极狐GitLab 实例，请确保满足以下条件之一：

- 将你的极狐GitLab 实例和 [KAS](../../../administration/clusters/kas.md) 托管在相同的域名下。
- 将 KAS 托管在极狐GitLab 的子域名下。例如，极狐GitLab 使用 `jihulab.com`，KAS 使用 `kas.jihulab.com`。

<a id="configure-kubernetes-access"></a>

## 配置 Kubernetes 访问

当你想要授予用户访问 Kubernetes 集群的权限时，请进行配置。

先决条件：

- Kubernetes 集群中已安装 Kubernetes 代理。
- 你必须具有开发者角色或更高角色。

配置访问：

- 在代理配置文件中，使用以下参数定义 `user_access` 关键字：

  - `projects`：应具有访问权限的项目列表。最多可授权 500 个项目。
  - `groups`：应具有访问权限的群组列表。最多可授权 500 个群组。这将授予对群组及其所有后代的访问权限。
  - `access_as`：对于使用代理身份的访问，值为 `{ agent: {...} }`。

授权的项目和群组必须与代理的配置项目属于同一顶级群组或用户命名空间，除非启用了[实例级别授权](ci_cd_workflow.md#authorize-all-projects-in-your-gitlab-instance-to-access-the-agent)应用程序设置。

配置访问后，请求将使用代理服务账号转发到 API 服务器。
例如：

```yaml
# .gitlab/agents/my-agent/config.yaml

user_access:
  access_as:
    agent: {}
  projects:
    - id: group-1/project-1
    - id: group-2/project-2
  groups:
    - id: group-2
    - id: group-3/subgroup
```

<a id="configure-access-with-user-impersonation"></a>

## 配置用户身份模拟访问

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

你可以授予对 Kubernetes 集群的访问权限，并将请求转换为针对已认证用户的身份模拟请求。

先决条件：

- Kubernetes 集群中已安装 Kubernetes 代理。
- 你必须具有开发者角色或更高角色。

配置用户身份模拟访问：

- 在代理配置文件中，使用以下参数定义 `user_access` 关键字：

  - `projects`：应具有访问权限的项目列表。
  - `groups`：应具有访问权限的群组列表。
  - `access_as`：对于用户身份模拟，值为 `{ user: {...} }`。

配置访问后，请求将转换为针对已认证用户的身份模拟请求。

<a id="user-impersonation-workflow"></a>

### 用户身份模拟工作流

已安装的 `agentk` 按以下方式模拟给定用户：

- `UserName` 为 `gitlab:user:<username>`
- `Groups` 为：
  - `gitlab:user`：适用于所有来自极狐GitLab 用户的请求。
  - `gitlab:project_role:<project_id>:<role>`：针对每个授权项目中的每个角色。
  - `gitlab:group_role:<group_id>:<role>`：针对每个授权群组中的每个角色。
- `Extra` 包含有关请求的额外信息：
  - `agent.jihulab.com/id`：代理 ID。
  - `agent.jihulab.com/username`：极狐GitLab 用户的用户名。
  - `agent.jihulab.com/config_project_id`：代理配置项目 ID。
  - `agent.jihulab.com/access_type`：`personal_access_token` 或 `session_cookie` 之一。仅旗舰版。

仅配置文件中 `user_access` 下直接列出的项目和群组才会被模拟。例如：

```yaml
# .gitlab/agents/my-agent/config.yaml

user_access:
  access_as:
    user: {}
  projects:
    - id: group-1/project-1 # group_id=1, project_id=1
    - id: group-2/project-2 # group_id=2, project_id=2
  groups:
    - id: group-2 # group_id=2
    - id: group-3/subgroup # group_id=3, group_id=4
```

在此配置中：

- 如果用户仅为 `group-1` 的成员，他们将仅获得 Kubernetes RBAC 组 `gitlab:project_role:1:<role>`。
- 如果用户是 `group-2` 的成员，他们将获得两个 Kubernetes RBAC 组：
  - `gitlab:project_role:2:<role>`，
  - `gitlab:group_role:2:<role>`。

<a id="rbac-authorization"></a>

### RBAC 授权

模拟请求需要 `ClusterRoleBinding` 或 `RoleBinding` 来识别 Kubernetes 内部的资源权限。有关适当配置，请参阅 [RBAC 授权](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)。

例如，如果你希望 `awesome-org/deployment` 项目（ID：123）中的维护者读取 Kubernetes 工作负载，你必须向 Kubernetes 配置中添加一个 `ClusterRoleBinding` 资源：

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: my-cluster-role-binding
roleRef:
  name: view
  kind: ClusterRole
  apiGroup: rbac.authorization.k8s.io
subjects:
  - name: gitlab:project_role:123:maintainer
    kind: Group
```

<a id="access-a-cluster-with-the-kubernetes-api"></a>

## 通过 Kubernetes API 访问集群

{{< history >}}

- 于 GitLab 16.4 推出。

{{< /history >}}

你可以配置代理，以允许极狐GitLab 用户通过 Kubernetes API 访问集群。

先决条件：

- 你已配置带有 `user_access` 条目的代理。

<a id="configure-local-access-with-the-gitlab-cli-recommended"></a>

### 通过 GitLab CLI 配置本地访问（推荐）

你可以使用 [GitLab CLI `glab`](../../../editor_extensions/gitlab_cli/_index.md) 创建或更新 Kubernetes 配置文件，以访问代理 Kubernetes API。

使用 `glab cluster agent` 命令管理集群连接：

1. 查看关联到你的项目的所有代理列表：

```shell
glab cluster agent list --repo '<group>/<project>'

# 如果你当前工作目录是带有代理的项目的 Git 仓库，则可以省略 --repo 选项：
glab cluster agent list
```

1. 使用输出第一列中显示的代理数字 ID 更新你的 `kubeconfig`：

```shell
glab cluster agent update-kubeconfig --repo '<group>/<project>' --agent '<agent-id>' --use-context
```

1. 使用 `kubectl` 或你偏好的 Kubernetes 工具验证更新：

```shell
kubectl get nodes
```

`update-kubeconfig` 命令将 `glab cluster agent get-token` 设置为 Kubernetes 工具检索令牌的[凭证插件](https://kubernetes.io/docs/reference/access-authn-authz/authentication/#client-go-credential-plugins)。`get-token` 命令会创建并返回一个在当前日结束前有效的个人访问令牌。Kubernetes 工具会缓存该令牌，直到令牌过期、API 返回授权错误或进程退出。预计所有后续对 Kubernetes 工具的调用都会创建新的令牌。

`glab cluster agent update-kubeconfig` 命令支持许多命令行标志。你可以使用 `glab cluster agent update-kubeconfig --help` 查看所有支持的标志。

一些示例：

```shell
# 当当前工作目录是注册了代理的 Git 仓库时，可以省略 --repo / -R 标志
glab cluster agent update-kubeconfig --agent '<agent-id>'

# 当指定 --use-context 选项时，kubeconfig 文件的 `current-context` 会更改为代理上下文
glab cluster agent update-kubeconfig --agent '<agent-id>' --use-context

# --kubeconfig 标志可用于指定替代 kubeconfig 路径
glab cluster agent update-kubeconfig --agent '<agent-id>' --kubeconfig ~/gitlab.kubeconfig
```

<a id="configure-local-access-manually-using-a-personal-access-token"></a>

### 使用个人访问令牌手动配置本地访问

你可以使用长期个人访问令牌配置对 Kubernetes 集群的访问：

1. 在顶部栏，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏，选择 **运维** > **Kubernetes 集群**，并获取你想访问的代理的数字 ID。你需要该 ID 来构造完整的 API 令牌。
1. 创建一个具有 `k8s_proxy` 作用域的 [个人访问令牌](../../profile/personal_access_tokens.md)。你需要该访问令牌来构造完整的 API 令牌。
1. 构造用于访问集群的 `kubeconfig` 条目：
   1. 确保选择了正确的 `kubeconfig`。例如，你可以设置 `KUBECONFIG` 环境变量。
   1. 将 GitLab KAS 代理集群添加到 `kubeconfig`：

      ```shell
      kubectl config set-cluster <cluster_name> --server "https://kas.jihulab.com/k8s-proxy"
      ```

      `server` 参数指向你极狐GitLab 实例的 KAS 地址。
      在 JihuLab.com 上，这是 `https://kas.jihulab.com/k8s-proxy`。
      你可以在注册代理时获取你实例的 KAS 地址。

   1. 使用你的数字代理 ID 和个人访问令牌构造 API 令牌：

      ```shell
      kubectl config set-credentials <gitlab_user> --token "pat:<agent-id>:<token>"
      ```

   1. 添加上下文以组合集群和用户：

      ```shell
      kubectl config set-context <gitlab_agent> --cluster <cluster_name> --user <gitlab_user>
      ```

   1. 激活新上下文：

      ```shell
      kubectl config use-context <gitlab_agent>
      ```

1. 检查配置是否正常工作：

   ```shell
   kubectl get nodes
   ```

配置后，用户可以通过 Kubernetes API 访问你的集群。