---
stage: Agent Foundations
group: Agent Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 排查极狐GitLab Duo Agent Platform 的常见问题，包括任务流、权限和推送规则配置。
title: 故障排除极狐GitLab Duo Agent Platform
---

如果您正在使用极狐GitLab Duo Agent Platform，
可能会遇到以下问题。

<a id="view-logs"></a>

## 查看日志

创建任务流后，您可以通过转到 **AI** > **会话**来查看该任务流的会话。

**详细信息**标签页会显示指向 CI/CD 作业日志的链接。这些日志可能包含故障排除信息。

<a id="flows-not-visible-in-the-ui"></a>

## 任务流在 UI 中不可见

如果您尝试运行任务流，但它在极狐GitLab UI 中不可见：

1. 确保您在项目中至少拥有开发者角色。
1. 确保极狐GitLab Duo 已[开启并允许任务流执行](../gitlab_duo/turn_on_off.md)。
1. 确保您所在的群组已被授予[使用任务流](../../administration/gitlab_duo/configure/access_control.md)的权限。
1. 如果顶级群组配置正确，但任务流在单个项目中不可见：
   1. 转到该项目。
   1. 选择 **AI** > **任务流**。
   1. 在右上角，选择**从群组启用任务流**。
   1. 选择一个任务流，然后选择**启用**。

1. 如果仍然无法正常工作：
   1. 在顶级群组中禁用受影响的任务流并保存配置。
   1. 在顶级群组中启用受影响的任务流并保存配置。
   1. 等待几分钟，让该设置传播到您的各个群组。

<a id="insufficient-permissions-to-create-a-new-pipeline-for-imported-projects"></a>

## 权限不足，无法为导入的项目创建新流水线

如果您尝试在导入的项目或基于模板创建的项目中运行内置任务流，可能会收到错误：`Error in creating workload: Insufficient permissions to create a new pipeline`。

要解决此问题：

1. 转到顶级群组。
1. 选择**设置** > **常规**。
1. 展开**极狐GitLab Duo 功能**。
1. 在**任务流执行**下，找到您要开启的内置任务流。
1. 在顶级群组中禁用这些任务流并保存配置。
1. 在顶级群组中启用相同的任务流并保存配置。
1. 等待几分钟，让该设置传播到群组中的各个项目。

<a id="error-your-request-was-valid-but-workflow-failed-to-complete-it"></a>

## 错误：`Your request was valid but Workflow failed to complete it`

任务流要求项目代码仓库至少有一次提交。如果您在没有提交的项目中运行任务流，会收到错误：
`Your request was valid but Workflow failed to complete it. Please try again.`

出现此错误是因为任务流无法在没有提交的代码仓库中找到默认分支。

要解决此问题，请在运行任务流之前向项目推送一次初始提交。例如，添加一个 `README.md` 文件。

<a id="session-is-stuck-in-created-state"></a>

## 会话卡在已创建状态

如果您的任务流会话没有启动：

- 确保已配置推送规则。

<a id="configure-push-rules-to-allow-a-service-account"></a>

### 配置推送规则以允许服务账号

在极狐GitLab UI 中，内置任务流使用一个服务账号，该账号会：

- 使用自己的电子邮件地址创建提交。
- 创建[工作负载流水线](../../ci/pipelines/pipeline_types.md#workload-pipeline)。

先决条件：

- 管理员访问权限。

要为项目配置推送规则：

1. 找到与该服务账号关联的电子邮件地址：
   1. 在右上角，选择**管理员**。
   1. 选择**概览** > **用户**，然后搜索与该任务流关联的账号。
      该账号遵循 `duo-[flow-name]-[top-level-group-name]` 模式。
   1. 找到该服务账号用户并复制其电子邮件地址。

1. 允许该电子邮件地址推送到项目：
   1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
   1. 选择**设置** > **代码仓库**。
   1. 展开**推送规则**。
   1. 在**提交作者电子邮件**中，添加一个允许您刚刚复制的电子邮件地址的正则表达式。
   1. 选择**保存推送规则**。

1. 允许 `duo/feature/` 分支前缀：
   1. 在**推送规则**部分中，找到**分支名称**。
   1. 添加一个允许以 ^duo/(fix|feature|refactor|docs/).* 开头的分支的正则表达式。
      例如：`^(duo/feature)/.*$`
   1. 选择**保存推送规则**。

要为实例创建推送规则：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**推送规则**。
1. 按照前面的步骤允许**提交作者电子邮件**和**分支名称**。
1. 选择**保存推送规则**。

<a id="a-flows-job-or-session-fails-to-start"></a>

## 任务流的作业或会话无法启动

如果任务流的作业始终没有启动，或者作业卡在 `Starting job`，说明没有可用的 runner 来获取该作业。在会话页面（**AI** > **会话**）上，会出现 `Session failed to start` 警报。

任务流在满足以下要求的 runner 上运行：

- 该 runner 具有 `gitlab--duo` 标签。
- 该 runner 使用支持 Docker 镜像的执行器，例如 `docker`、
  `docker-autoscaler` 或 `kubernetes`。不支持 `shell` 执行器。
- 该 runner 是实例 runner 或分配给顶级群组的群组 runner。
  作用域为子群组或项目的 runner 不会获取任务流作业，除非
  `duo_runner_restrictions` 功能标志已关闭。

要解决此问题：

1. 在 JihuLab.com 上，确认该项目已开启[托管 runner](../../ci/runners/hosted_runners/_index.md)。
   托管 runner 默认满足所有要求。
1. 如果您使用自己的 runner，请确认至少有一个 runner 满足要求：
   1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目或顶级群组。
   1. 在左侧边栏中，选择**构建** > **Runner**。
   1. 确认具有 `gitlab--duo` 标签的 runner 处于在线状态。
1. 如果没有 runner 满足要求，请[配置一个 runner 来执行任务流](flows/execution/_index.md#configure-runners-to-execute-flows)。

如果某个 runner 满足所有要求，但作业仍然无法启动，请检查以下内容：

- 该命名空间已用完其所有[计算配额](../../ci/pipelines/instance_runner_compute_minutes.md#enforcement)，
  这也会移除对托管 runner 的访问权限。因此，配额用尽可能看起来像是 runner
  可用性问题。
- 顶级群组[按 IP 地址限制访问](../group/access_and_permissions.md#restrict-group-access-by-ip-address)。
  托管 runner 使用无法添加到允许名单的动态 IP 地址，因此无法为该群组运行
  任务流。请改为在顶级群组配置您自己的 runner。

<a id="error-something-went-wrong-while-requesting-a-review-from-gitlab-duo"></a>

## 错误：`Something went wrong while requesting a review from GitLab Duo`

在极狐GitLab 18.8 及更早版本中，代码评审任务流失败时会显示此错误消息。以下是常见的根本原因：

- 未创建内置任务流服务账号。
- 群组成员资格锁定导致无法将该服务账号添加到项目。
- 您属于多个极狐GitLab Duo 命名空间，且未设置默认命名空间。

在极狐GitLab 18.9 及更高版本中，会改为显示更具体的错误消息。有关更多信息，请参阅[代码评审任务流故障排除](flows/foundational_flows/code_review/troubleshooting.md)。

<a id="foundational-flow-service-account-not-created"></a>

### 未创建内置任务流服务账号

如果内置任务流已开启但无法正常工作，则可能未能成功创建顶级群组的服务账号。

要检查该服务账号是否存在：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的顶级群组。
1. 在左侧边栏中，选择**设置** > **服务账号**。
1. 查找名为 `duo-[flow-name]-[top-level-group-name]` 的账号。

如果该账号缺失，则可能是 `CascadeSyncFoundationalFlowsWorker` 未能创建它。要确认该账号缺失，请在 Sidekiq 日志中检查以下错误：

```json
{
  "severity": "ERROR",
  "meta.caller_id": "Ai::Catalog::Flows::CascadeSyncFoundationalFlowsWorker",
  "message": "Cannot obtain an exclusive lease. There must be another instance already in execution.",
  "lease_key": "sidekiq:concurrency_limit:{ai/catalog/flows/cascade_sync_foundational_flows_worker}",
  "lease_timeout": 600
}
```

要解决此问题，请[关闭内置任务流](flows/foundational_flows/_index.md#turn-foundational-flows-on-or-off)，并在 10 分钟后重新开启。

<a id="group-membership-locked"></a>

### 群组成员资格已锁定

如果顶级群组[锁定了成员资格](../group/access_and_permissions.md#prevent-members-from-being-added-to-projects-in-a-group)，内置任务流会静默失败，因为无法将该服务账号添加到所需项目中。

要解决此问题：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的顶级群组。
1. 在左侧边栏中，选择**设置** > **常规**。
1. 展开**权限和群组功能**。
1. 清除**用户无法添加到此群组中的项目**复选框，然后选择**保存更改**。
1. [关闭内置任务流](flows/foundational_flows/_index.md#turn-foundational-flows-on-or-off)，然后选择**保存更改**。
1. 重新开启内置任务流，然后选择**保存更改**。
1. 选中**用户无法添加到此群组中的项目**复选框，然后选择
   **保存更改**。

<a id="default-gitlab-duo-namespace-not-set"></a>

### 未设置默认极狐GitLab Duo 命名空间

在极狐GitLab 18.3 及更高版本中，当您属于多个极狐GitLab Duo 命名空间且
未设置默认命名空间时，极狐GitLab Duo Agent Platform 会被关闭。

在极狐GitLab 18.8 及更早版本中，您可能会看到以下错误消息：

```plaintext
Something went wrong while requesting a review from GitLab Duo.
```

在极狐GitLab 18.9 及更高版本中，您可能会收到与命名空间相关的错误。

要解决此问题，请[设置默认极狐GitLab Duo 命名空间](../profile/preferences.md#set-a-default-gitlab-duo-namespace)。

<a id="error-ssl-certificate-openssl-verify-result-unable-to-get-local-issuer-certificate-20"></a>

## 错误：`SSL certificate OpenSSL verify result: unable to get local issuer certificate (20)`

在使用自定义或自签名 CA 证书的极狐GitLab 私有化部署实例上，当极狐GitLab Duo Agent Platform 作业在
初始 `git clone`（`get_sources` 阶段）期间失败时，可能会显示此消息。

出现此情况是因为极狐GitLab Duo Agent Platform 作业设置了 `GIT_CONFIG_GLOBAL=/dev/null` 和 `GIT_CONFIG_NOSYSTEM=1`
以强化 Agent 沙箱。这些变量会阻止 Git 读取系统和全局配置文件。这会破坏 runner 在 `get_sources` 期间注入 CA 证书路径的机制。

不执行任务流的 CI/CD 作业不受影响。此问题特定于极狐GitLab Duo Agent Platform 的工作负载流水线。

要解决此问题，请在 [`config.toml`](https://gitlab.cn/docs/runner/configuration/advanced-configuration/) 文件中，在 runner 级别设置 `GIT_SSL_CAINFO` 环境变量，并将 CA 证书挂载到容器中：

```toml
[[runners]]
  environment = ["GIT_SSL_CAINFO=/etc/gitlab-runner/certs/ca.crt"]
  [runners.docker]
    volumes = ["/path/to/your/ca-bundle.crt:/etc/gitlab-runner/certs/ca.crt:ro"]
```

将 `/path/to/your/ca-bundle.crt` 替换为 runner 主机上您的 CA 证书包的路径。该文件必须是 PEM 格式的 CA 证书包，其中包含您的根 CA 和所有中间证书。

您可能期望将其设置为 CI/CD 变量，但自定义 CI/CD 变量
在极狐GitLab Duo Agent Platform 作业中[不可用](flows/execution/execution-variables.md#custom-cicd-variables)。
您必须改用 runner 的 `config.toml` `environment` 指令。

要通过自定义 CA 将极狐GitLab Duo CLI 连接到您的极狐GitLab 实例，请将 `NODE_EXTRA_CA_CERTS`
添加到同一 `environment` 行：

```toml
[[runners]]
  environment = [
    "GIT_SSL_CAINFO=/etc/gitlab-runner/certs/ca.crt",
    "NODE_EXTRA_CA_CERTS=/etc/gitlab-runner/certs/ca.crt"
  ]
  [runners.docker]
    volumes = ["/path/to/your/ca-bundle.crt:/etc/gitlab-runner/certs/ca.crt:ro"]
```

如果极狐GitLab Duo CLI 在 Anthropic Sandbox Runtime (SRT) 中运行，runner 的 `environment` 变量可能无法传递给它。如果此更改后 TLS 错误仍然存在，请在您的 `agent-config.yml`中，在 `setup_script`中改为设置 `NODE_EXTRA_CA_CERTS`。`setup_script` 在容器内运行，不会被沙箱过滤。

`GIT_SSL_CAINFO` 变量用于处理在极狐GitLab Duo CLI 启动之前发生的 Git 操作。有关极狐GitLab Duo CLI 证书配置，请参阅[证书错误](../gitlab_duo_cli/use.md#certificate-errors)。

<a id="connection-fails-with-websocket-error-1006-or-404"></a>

## 连接失败，出现 WebSocket 错误 `1006` 或 `404`

极狐GitLab Duo CLI、GitLab Language Server 和 IDE 客户端（GitLab for VS Code、适用于 JetBrains IDE 的极狐GitLab Duo 插件和 GitLab for Visual Studio）
通过 WebSocket 连接连接到极狐GitLab Duo Agent Platform。
当此连接失败时，客户端会记录以下错误之一：

- `1006`：WebSocket 异常关闭，没有关闭握手。
- `404`：客户端无法访问以下 WebSocket 端点：
  - 对于极狐GitLab Duo 非 Agentic：`/-/cable`。
  - 对于极狐GitLab Duo Agent Platform：`wss://\<instance\>/api/v4/ai/duo_workflows/ws`。

这些错误通常发生在您网络中的自定义证书颁发机构 (CA)、HTTP 代理、TLS 检查代理或双向 TLS (mTLS) 代理干扰连接时。要解决此问题，请逐一排查以下原因。

<a id="custom-ca-certificate"></a>

### 自定义 CA 证书

如果您的网络使用自定义或自签名 CA 证书，客户端将无法验证与您的极狐GitLab 实例的连接。请为您的客户端配置证书：

- 对于极狐GitLab Duo CLI，将 `NODE_EXTRA_CA_CERTS` 环境变量设置为您的 CA 证书路径。
- 对于 IDE 客户端，GitLab Language Server 会管理证书。
  对于 JetBrains IDE，请参阅[证书错误](../../editor_extensions/jetbrains_ide/jetbrains_troubleshooting.md#certificate-errors)。
  对于 VS Code，请参阅[自定义证书错误](../../editor_extensions/visual_studio_code/troubleshooting.md#errors-with-custom-certificates)。

<a id="http-proxy"></a>

### HTTP 代理

如果您的网络需要 HTTP 代理，请为您的客户端配置代理：

- 对于极狐GitLab Duo CLI，设置 `HTTP_PROXY`、`HTTPS_PROXY` 和 `NO_PROXY` 环境变量。
- 对于 IDE 客户端，请[配置 Language Server 以使用代理](../../editor_extensions/language_server/_index.md#configure-the-language-server-to-use-a-proxy)。

<a id="websocket-traffic-blocked"></a>

### WebSocket 流量被阻止

如果您看到 `404` 错误，或者日志中出现 `HTTP/1.1` 响应而不是 `/-/cable` WebSocket 端点，则您的极狐GitLab 实例可能阻止了入站 WebSocket 连接。请让您的管理员[允许 WebSocket 流量进入您的极狐GitLab 实例](../../administration/gitlab_duo/configure/_index.md#allow-inbound-connections-from-clients-to-the-gitlab-instance)。

<a id="mtls-or-tls-inspection-proxy"></a>

### mTLS 或 TLS 检查代理

如果您的网络通过 TLS 检查（SSL 拦截）代理路由流量，请同时配置以下两项：

- 将 `HTTPS_PROXY` 环境变量设置为您的代理 URL。
- 添加该代理的 [CA 证书](#custom-ca-certificate)。

极狐GitLab Duo CLI、适用于 JetBrains IDE 的极狐GitLab Duo 插件和 GitLab for Visual Studio
有两个已知问题：

- 如果代理 URL 使用 `https://`，WebSocket 连接会失败。
  请尽可能使用 `http://` 代理 URL。
- 这些客户端无法为 mTLS 提供客户端证书。

有关更多信息，请参阅[议题 2527](https://gitlab.com/gitlab-org/editor-extensions/gitlab-lsp/-/work_items/2527)。
GitLab for VS Code 不受影响。

<a id="troubleshooting-in-your-ide"></a>

## 在 IDE 中故障排除

如果您在 IDE 中使用极狐GitLab Duo Agent Platform 时遇到问题，请先
确保极狐GitLab Duo 已开启，并且您已正确连接。

- 您满足极狐GitLab Duo Agent Platform 的[先决条件](_index.md#prerequisites)。
- 管理员模式已[禁用](../../administration/settings/sign_in_restrictions.md#turn-off-admin-mode-for-your-session)。
- 您的项目位于[群组命名空间](../namespace/_index.md)中。
- 您已设置[默认极狐GitLab Duo 命名空间](../profile/preferences.md#namespace-resolution-in-your-local-environment)
  或已打开一个具有极狐GitLab Duo 访问权限的项目。

如需进一步支持，请参阅您的扩展和 IDE 对应的故障排除页面：

- [GitLab for VS Code](../../editor_extensions/visual_studio_code/troubleshooting.md#gitlab-duo)
- [适用于 JetBrains IDE 的极狐GitLab Duo 插件](../../editor_extensions/jetbrains_ide/jetbrains_troubleshooting.md)
- [GitLab for Visual Studio](../../editor_extensions/visual_studio/visual_studio_troubleshooting.md)

<a id="run-the-configuration-diagnostic-script"></a>

## 运行配置诊断脚本

如果您无法从相关功能文档中确定极狐GitLab Duo Agent Platform 问题的原因，请运行诊断脚本以检查您的配置。

该脚本会检查极狐GitLab Duo Agent Platform 功能所需的完整配置链：

- 许可证有效性和套餐。
- 实例级极狐GitLab Duo 设置。
- 具有 `gitlab--duo` 标签的 CI/CD runner。
- 命名空间和项目的极狐GitLab Duo 设置。
- 内置任务流及其服务账号。
- 功能可用性，例如代码评审任务流可用性和自动评审设置。

> [!warning]
> 此脚本仅读取配置数据，不会修改任何设置。
> 输出可能包含内部配置详细信息。
> 在将其分享给支持团队之前，请先对输出进行脱敏处理。

先决条件：

- 极狐GitLab 18.8 或更高版本

要在极狐GitLab 19.0 或更高版本中运行诊断脚本：

- 运行内置的 `gitlab:duo:verify_setup` [Rake 任务](../../administration/raketasks/_index.md)。
  将 `<group/project>` 替换为项目的完整路径，例如 `gitlab-org/gitlab`。

  例如：

  ```shell
  sudo gitlab-rake "gitlab:duo:verify_setup[<group/project>]"
  ```

要在极狐GitLab 18.8 到极狐GitLab 18.11 中运行诊断脚本：

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

1. 下载 [`verify_setup.rb`](https://gitlab.com/gitlab-org/gitlab/-/raw/master/ee/lib/gitlab/duo/administration/verify_setup.rb)。
1. 将 `verify_setup.rb` 文件复制到您的极狐GitLab 服务器。
1. 运行该脚本。
   将 `<group/project>` 替换为项目的完整路径，例如 `gitlab-org/gitlab`。

   ```shell
   sudo gitlab-rails runner "load '/tmp/verify_setup.rb'; Gitlab::Duo::Administration::VerifySetup.new('<group/project>').execute"
   ```

{{< /tab >}}

{{< tab title="Docker" >}}

1. 下载 [`verify_setup.rb`](https://gitlab.com/gitlab-org/gitlab/-/raw/master/ee/lib/gitlab/duo/administration/verify_setup.rb)。
1. 将 `verify_setup.rb` 文件复制到容器中。
1. 运行该脚本。
   将 `<group/project>` 替换为项目的完整路径，例如 `gitlab-org/gitlab`。

   ```shell
   docker cp verify_setup.rb <container-id>:/tmp/verify_setup.rb
   docker exec -it <container-id> gitlab-rails runner \
   "load '/tmp/verify_setup.rb'; Gitlab::Duo::Administration::VerifySetup.new('<group/project>').execute"
   ```

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

1. 下载 [`verify_setup.rb`](https://gitlab.com/gitlab-org/gitlab/-/raw/master/ee/lib/gitlab/duo/administration/verify_setup.rb)。
1. 将 `verify_setup.rb` 文件复制到您的极狐GitLab 服务器。
1. 从极狐GitLab 应用程序目录运行该脚本。
   将 `<group/project>` 替换为项目的完整路径，例如 `gitlab-org/gitlab`。

   ```shell
   sudo -u git bundle exec rails runner \
   "load '/tmp/verify_setup.rb'; Gitlab::Duo::Administration::VerifySetup.new('<group/project>').execute"
   ```

{{< /tab >}}

{{< tab title="Helm chart（Kubernetes）" >}}

1. 下载 [`verify_setup.rb`](https://gitlab.com/gitlab-org/gitlab/-/raw/master/ee/lib/gitlab/duo/administration/verify_setup.rb)。
1. 将 `verify_setup.rb` 文件复制到 toolbox pod 中。
1. 运行该脚本。
   将 `<group/project>` 替换为项目的完整路径，例如 `gitlab-org/gitlab`。

   ```shell
   # Find the toolbox pod
   kubectl get pods --namespace <namespace> -lapp=toolbox

   kubectl cp verify_setup.rb <namespace>/<toolbox-pod-name>:/tmp/verify_setup.rb
   kubectl exec -it <toolbox-pod-name> -- gitlab-rails runner \
   "load '/tmp/verify_setup.rb'; Gitlab::Duo::Administration::VerifySetup.new('<group/project>').execute"
   ```

{{< /tab >}}

{{< /tabs >}}
