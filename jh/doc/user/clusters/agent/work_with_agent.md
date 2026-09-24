---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 管理 Kubernetes 实例的代理
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用以下任务操作 Kubernetes 代理。

<a id="view-your-agents"></a>

## 查看你的代理

已安装的 `agentk` 版本显示在 **代理** 标签页上。

先决条件：

- 你必须拥有开发者、维护者或所有者角色。

要查看代理列表：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到包含你的代理配置文件的项目。
   你无法从不包含代理配置文件的项目中查看已注册的代理。
1. 选择 **运维** > **Kubernetes 集群**。
1. 选择 **代理** 标签页以查看通过代理连接到极狐GitLab 的集群。

在此页面，你可以查看：

- 当前项目所有已注册的代理。
- 连接状态。
- 你的集群上安装的 `agentk` 版本。
- 每个代理配置文件的路径。

### 配置你的代理

要配置你的代理：

- 向可选在[安装过程中](install/_index.md#create-an-agent-configuration-file)创建的 `config.yaml` 文件添加内容。

你可以从代理列表中快速定位代理配置文件。
**配置** 列指示 `config.yaml` 文件的位置，或显示如何创建它。

代理配置文件管理各种代理功能：

- 对于极狐GitLab CI/CD 工作流，你必须[授权代理访问你的项目](ci_cd_workflow.md#authorize-agent-access)，然后[将 `kubectl` 命令添加到你的 `.gitlab-ci.yml` 文件](ci_cd_workflow.md#update-your-gitlab-ciyml-file-to-run-kubectl-commands)中。
- 用于从极狐GitLab UI 或本地终端[用户访问](user_access.md)集群。
- 用于配置[运营容器扫描](vulnerabilities.md)。
- 用于配置[远程工作区](../../workspace/gitlab_agent_configuration.md)。

### 可用的配置文件字段

代理的配置文件格式定义为源代码仓库中的[协议缓冲区消息](https://gitlab.com/gitlab-org/cluster-integration/gitlab-agent/-/blob/master/pkg/agentcfg/agentcfg.proto)。

要查看所有可用的配置文件字段：

1. 前往 [生成的文档](https://gitlab.com/gitlab-org/cluster-integration/gitlab-agent/-/blob/master/pkg/agentcfg/agentcfg_proto_docs.md) 中的 [`ConfigurationFile`](https://gitlab.com/gitlab-org/cluster-integration/gitlab-agent/-/blob/master/pkg/agentcfg/agentcfg_proto_docs.md#configurationfile) 查看整个代理配置文件的字段。
1. 选择任何字段类型以了解字段结构的更多信息。

<a id="view-shared-agents"></a>

## 查看共享代理

{{< history >}}

- 在极狐GitLab 16.1 中引入。

{{< /history >}}

除了你项目拥有的代理外，你还可以查看通过 [`ci_access`](ci_cd_workflow.md) 和 [`user_access`](user_access.md) 关键词共享的代理。一旦代理被共享给一个项目，它会自动出现在项目的代理标签页中。

要查看共享代理列表：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **运维** > **Kubernetes 集群**。
1. 选择 **代理** 标签页。

共享代理及其集群的列表会显示出来。

<a id="view-an-agents-activity-information"></a>

## 查看代理的活动信息

活动日志帮助你识别问题并获取故障排除所需的信息。你可以查看当前日期前一周的事件。要查看代理的活动：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到包含你的代理配置文件的项目。
1. 选择 **运维** > **Kubernetes 集群**。
1. 选择你想查看其活动的代理。

活动列表包括：

- 代理注册事件：新建令牌时。
- 连接事件：代理成功**连接**到集群时。

当你首次连接代理或超过一小时不活动后再次连接时，会记录连接状态。

<a id="debug-the-agent"></a>

## 调试代理

{{< history >}}

- `grpc_level` 在极狐GitLab 15.1 中引入。

{{< /history >}}

要调试代理的集群端组件（`agentk`），请根据可用选项设置日志级别：

- `error`
- `info`
- `debug`

代理有两个日志记录器：

- 一个通用日志记录器，默认为 `info`。
- 一个 gRPC 日志记录器，默认为 `error`。

你可以使用[代理配置文件](#configure-your-agent)中的顶层 `observability` 部分更改日志级别，例如将级别设置为 `debug` 和 `warn`：

```yaml
observability:
  logging:
    level: debug
    grpc_level: warn
```

当 `grpc_level` 设置为 `info` 或更低时，会产生大量 gRPC 日志。

提交配置更改并检查代理服务日志：

```shell
kubectl logs -f -l=app=gitlab-agent -n gitlab-agent
```

有关调试的更多信息，请参见[故障排除文档](troubleshooting.md)。

<a id="reset-the-agent-token"></a>

## 重置代理令牌

{{< history >}}

- 双令牌限制在极狐GitLab 16.1 中引入，带有一个名为 `cluster_agents_limit_tokens_created` 的功能标志。
- 双令牌限制在极狐GitLab 16.2 中 GA。功能标志 `cluster_agents_limit_tokens_created` 已移除。

{{< /history >}}

一个代理一次只能有两个活跃令牌。

要无需停机重置代理令牌：

1. 创建新令牌：
   1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
   1. 选择 **运维** > **Kubernetes 集群**。
   1. 选择你想要为其创建令牌的代理。
   1. 在 **访问令牌** 标签页上，选择 **创建令牌**。
   1. 输入令牌的名称和描述（可选），然后选择 **创建令牌**。
1. 安全地存储生成的令牌。
1. 使用该令牌[在集群中安装代理](install/_index.md#install-the-agent-in-the-cluster)并[将代理更新](install/_index.md#update-the-agent-version)到另一个版本。
1. 要删除你不再使用的令牌，返回到令牌列表并选择 **吊销** ({{< icon name="remove" >}})。

<a id="remove-an-agent"></a>

## 移除代理

你可以通过 [极狐GitLab UI](#remove-an-agent-through-the-gitlab-ui) 或 [极狐GitLab GraphQL API](#remove-an-agent-with-the-gitlab-graphql-api) 移除代理。代理和任何关联的令牌都会从极狐GitLab 中移除，但你的 Kubernetes 集群中不会发生任何更改。你必须手动清理这些资源。

<a id="remove-an-agent-through-the-gitlab-ui"></a>

### 通过极狐GitLab UI 移除代理

要通过 UI 移除代理：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到包含你的代理配置文件的项目。
1. 选择 **运维** > **Kubernetes 集群**。
1. 在表格中，找到你的代理所在行，在 **选项** 列中选择垂直省略号 ({{< icon name="ellipsis_v" >}})。
1. 选择 **删除代理**。

<a id="remove-an-agent-with-the-gitlab-graphql-api"></a>

### 使用极狐GitLab GraphQL API 移除代理

1. 从交互式 GraphQL 资源管理器的查询中获取 `<cluster-agent-token-id>`。
   - 对于 JihuLab.com，转到 <https://jihulab.com/-/graphql-explorer> 打开 GraphQL Explorer。
   - 对于私有化部署，转到 `https://gitlab.example.com/-/graphql-explorer`，将 `gitlab.example.com` 替换为你的实例 URL。

   ```graphql
   query{
     project(fullPath: "<full-path-to-agent-configuration-project>") {
       clusterAgent(name: "<agent-name>") {
         id
         tokens {
           edges {
             node {
               id
             }
           }
         }
       }
     }
   }
   ```

1. 通过删除 `clusterAgentToken`，使用 GraphQL 移除代理记录。

   ```graphql
   mutation deleteAgent {
     clusterAgentDelete(input: { id: "<cluster-agent-id>" } ) {
       errors
     }
   }

   mutation deleteToken {
     clusterAgentTokenDelete(input: { id: "<cluster-agent-token-id>" }) {
       errors
     }
   }
   ```

1. 验证移除是否成功发生。如果 Pod 日志中的输出包含 `unauthenticated`，则表示代理已成功移除：

   ```json
   {
       "level": "warn",
       "time": "2021-04-29T23:44:07.598Z",
       "msg": "GetConfiguration.Recv failed",
       "error": "rpc error: code = Unauthenticated desc = unauthenticated"
   }
   ```

1. 在你的集群中删除代理：

   ```shell
   kubectl delete -n gitlab-kubernetes-agent -f ./resources.yml
   ```

<a id="related-topics"></a>

## 相关主题

- [管理代理的工作区](../../workspace/_index.md#manage-workspaces-at-the-agent-level)