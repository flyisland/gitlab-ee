---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 授予用户 Kubernetes 访问权限
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Status: 测试版

{{< /details >}}

作为组织中 Kubernetes 集群的管理员，您可以将 Kubernetes 访问权限授予特定项目或群组的成员。

授予访问权限还会为项目或群组激活 [Kubernetes 仪表板](../../../ci/environments/kubernetes_dashboard.md)。

对于极狐GitLab 私有化部署实例，请确保满足以下任一条件：

- 将极狐GitLab 实例和 [KAS](../../../administration/clusters/kas.md) 托管在同一域名下。
- 将 KAS 托管在极狐GitLab 的子域名下。例如，极狐GitLab 位于 `gitlab.com`，KAS 位于 `kas.gitlab.com`。

<a id="configure-kubernetes-access"></a>

## 配置 Kubernetes 访问权限

当您想授予用户访问 Kubernetes 集群的权限时，可以配置访问权限。

先决条件：

- Kubernetes 集群中已安装极狐GitLab Kubernetes Agent。
- 您必须具有开发者或更高角色。

要配置访问权限：

- 在 Agent 配置文件中，定义一个 `user_access` 关键字，包含以下参数：

  - `projects`：其成员应具有访问权限的项目列表。您最多可以授权 500 个项目。
  - `groups`：其成员应具有访问权限的群组列表。您最多可以授权 500 个群组。它会授予对该群组及其所有后代的访问权限。
  - `access_as`：使用 Agent 身份访问时，值为 `{ agent: {...} }`。

已授权的项目和群组必须与 Agent 的配置项目具有相同的顶级群组或用户命名空间，除非启用了[实例级授权](ci_cd_workflow.md#authorize-all-projects-in-your-gitlab-instance-to-access-the-agent)应用设置。

配置访问权限后，请求会使用 Agent 服务账号转发到 API 服务器。例如：

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

## 使用用户模拟配置访问权限

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以授予对 Kubernetes 集群的访问权限，并将请求转换为已认证用户的模拟请求。

先决条件：

- Kubernetes 集群中已安装极狐GitLab Kubernetes Agent。
- 您必须具有开发者或更高角色。

要使用用户模拟配置访问权限：

- 在 Agent 配置文件中，定义一个 `user_access` 关键字，包含以下参数：

  - `projects`：其成员应具有访问权限的项目列表。
  - `groups`：其成员应具有访问权限的群组列表。
  - `access_as`：使用用户模拟时，值为 `{ user: {...} }`。

配置访问权限后，请求会转换为已认证用户的模拟请求。

<a id="user-impersonation-workflow"></a>

### 用户模拟工作流

已安装的 `agentk` 会按如下方式模拟给定用户：

- `UserName` 为 `gitlab:user:<username>`
- `Groups` 为：
  - `gitlab:user`：来自极狐GitLab 用户的所有请求共有。
  - `gitlab:project_role:<project_id>:<role>`，对应每个已授权项目中的每个角色。
  - `gitlab:group_role:<group_id>:<role>`，对应每个已授权群组中的每个角色。
- `Extra` 携带有关请求的附加信息：
  - `agent.gitlab.com/id`：Agent ID。
  - `agent.gitlab.com/username`：极狐GitLab 用户的用户名。
  - `agent.gitlab.com/config_project_id`：Agent 配置项目 ID。
  - `agent.gitlab.com/access_type`：`personal_access_token` 或 `session_cookie` 之一。仅限旗舰版。

只有配置文件的 `user_access` 下直接列出的项目和群组才会被模拟。例如：

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

- 如果用户仅是 `group-1`的成员，则他们只会获得
  Kubernetes RBAC 群组 `gitlab:project_role:1:<role>`。
- 如果用户是 `group-2`的成员，则他们会同时获得两个 Kubernetes RBAC 群组：
  - `gitlab:project_role:2:<role>`，
  - `gitlab:group_role:2:<role>`。

<a id="rbac-authorization"></a>

### RBAC 授权

模拟请求需要 `ClusterRoleBinding` 或 `RoleBinding` 来标识 Kubernetes 内部的资源权限。有关适当的配置，请参阅 [RBAC 授权](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)。

例如，如果您允许 `awesome-org/deployment` 项目（ID：123）中的维护者读取 Kubernetes 工作负载，则必须向 Kubernetes 配置添加一个 `ClusterRoleBinding` 资源：

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

## 使用 Kubernetes API 访问集群

您可以配置 Agent，以允许极狐GitLab 用户使用 Kubernetes API 访问集群。

先决条件：

- 您已配置一个带有 `user_access` 条目的 Agent。

<a id="configure-local-access-with-the-gitlab-cli-recommended"></a>

### 使用 GitLab CLI 配置本地访问（推荐）

您可以使用 [GitLab CLI `glab`](../../../editor_extensions/gitlab_cli/_index.md) 创建或更新
Kubernetes 配置文件，以访问 Agent Kubernetes API。

使用 `glab cluster agent` 命令管理集群连接：

1. 查看与您的项目关联的所有 Agent 列表：

```shell
glab cluster agent list --repo '<group>/<project>'

# If your current working directory is the Git repository of the project with the agent, you can omit the --repo option:
glab cluster agent list
```

1. 使用输出第一列中显示的 Agent 数字 ID 更新您的 `kubeconfig`：

```shell
glab cluster agent update-kubeconfig --repo '<group>/<project>' --agent '<agent-id>' --use-context
```

1. 使用 `kubectl` 或您首选的 Kubernetes 工具验证更新：

```shell
kubectl get nodes
```

`update-kubeconfig` 命令将 `glab cluster agent get-token` 设置为[凭据插件](https://kubernetes.io/docs/reference/access-authn-authz/authentication/#client-go-credential-plugins)，供 Kubernetes 工具检索令牌。`get-token` 命令会创建并返回一个个人访问令牌，该令牌在当天结束前有效。Kubernetes 工具会缓存该令牌，直到其过期、API 返回授权错误或进程退出。预计后续对 Kubernetes 工具的所有调用都会创建新令牌。

`glab cluster agent update-kubeconfig` 命令支持多个命令行标志。您可以使用 `glab cluster agent update-kubeconfig --help` 查看所有支持的标志。

一些示例：

```shell
# When the current working directory is the Git repository where the agent is registered the --repo / -R flag can be omitted
glab cluster agent update-kubeconfig --agent '<agent-id>'

# When the --use-context option is specified the `current-context` of the kubeconfig file is changed to the agent context
glab cluster agent update-kubeconfig --agent '<agent-id>' --use-context

# The --kubeconfig flag can be used to specify an alternative kubeconfig path
glab cluster agent update-kubeconfig --agent '<agent-id>' --kubeconfig ~/gitlab.kubeconfig
```

<a id="configure-local-access-manually-using-a-personal-access-token"></a>

### 使用个人访问令牌手动配置本地访问

您可以使用长期有效的个人访问令牌配置对 Kubernetes 集群的访问：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**运维** > **Kubernetes 集群**，并获取您要访问的 Agent 的数字 ID。您需要该 ID 来构造完整的 API 令牌。
1. 创建一个具有 `k8s_proxy` 范围的[个人访问令牌](../../profile/personal_access_tokens.md)。您需要该访问令牌来构造完整的 API 令牌。
1. 构造 `kubeconfig` 条目以访问集群：
   1. 确保选择了正确的 `kubeconfig`。
      例如，您可以设置 `KUBECONFIG` 环境变量。
   1. 将 GitLab KAS 代理集群添加到 `kubeconfig`：

      ```shell
      kubectl config set-cluster <cluster_name> --server "https://kas.jihulab.com/k8s-proxy"
      ```

      `server` 参数指向您极狐GitLab 实例的 KAS 地址。
      在 JihuLab.com 上，该地址为 `https://kas.jihulab.com/k8s-proxy`。
      您可以在注册 Agent 时获取实例的 KAS 地址。

   1. 使用您的 Agent 数字 ID 和个人访问令牌构造 API 令牌：

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

已配置的用户可以使用 Kubernetes API 访问您的集群。
