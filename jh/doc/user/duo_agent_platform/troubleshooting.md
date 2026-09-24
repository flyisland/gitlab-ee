---
stage: AI-powered
group: Agent Foundations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Troubleshoot common issues with the GitLab Duo Agent Platform, including flows, permissions, and push rule configuration.
title: 极狐GitLab Duo Agent Platform 故障排查
---

如果您正在使用极狐GitLab Duo Agent Platform，可能会遇到以下问题。

<a id="view-logs"></a>

## 查看日志

创建流程后，您可以通过转到 **AI** > **会话** 来查看流程的会话。

**详情** 选项卡会显示一个指向 CI/CD 作业日志的链接。
这些日志可能包含故障排查信息。

<a id="flows-not-visible-in-the-ui"></a>

## 流程在 UI 中不可见

如果您尝试运行流程，但在极狐GitLab UI 中看不到它：

1. 确保您在项目中至少具有开发者角色。
1. 确保极狐GitLab Duo 已[开启且允许执行流程](../gitlab_duo/turn_on_off.md)。
1. 确保您所在的群组已被授予[使用流程的权限](../../administration/gitlab_duo/configure/access_control.md)。
1. 如果顶级群组配置正确，但单个项目的流程不可见：
   1. 转到该项目。
   1. 选择 **AI** > **流程**。
   1. 在右上角，选择 **从群组启用流程**。
   1. 选择一个流程，然后选择 **启用**。

1. 如果仍然无效：
   1. 在顶级群组中禁用受影响的流程并保存配置。
   1. 在顶级群组中启用受影响的流程并保存配置。
   1. 等待几分钟，让设置传播到各个群组。

<a id="insufficient-permissions-to-create-a-new-pipeline-for-imported-projects"></a>

## 为导入项目创建新流水线的权限不足

如果您尝试在导入的项目或从模板创建的项目中运行内置任务流，可能会收到错误：`Error in creating workload: Insufficient permissions to create a new pipeline`。

要解决此问题：

1. 转到顶级群组。
1. 选择 **设置** > **通用**。
1. 展开 **极狐GitLab Duo 功能**。
1. 在 **流程执行** 下，找到您要开启的内置任务流。
1. 在顶级群组中禁用这些流程并保存配置。
1. 在顶级群组中启用相同的流程并保存配置。
1. 等待几分钟，让设置传播到群组中的各个项目。

<a id="error-your-request-was-valid-but-workflow-failed-to-complete-it"></a>

## 错误：`您的请求有效，但工作流未能完成`

流程要求项目仓库至少有一个提交。
如果您在没有提交的项目中运行流程，会收到错误：
`您的请求有效，但工作流未能完成。请重试。`

出现此错误是因为流程在没有任何提交的仓库中找不到默认分支。

要解决此问题，请在运行流程之前向项目推送一个初始提交。
例如，添加一个 `README.md` 文件。

<a id="session-is-stuck-in-created-state"></a>

## 会话卡在已创建状态

如果您的流程会话未启动：

- 确保推送规则已配置。

<a id="configure-push-rules-to-allow-a-service-account"></a>

### 配置推送规则以允许服务账号

在极狐GitLab UI 中，内置任务流使用一个服务账号，该账号会：

- 使用自己的电子邮件地址创建提交。
- 创建一个[工作负载流水线](../../ci/pipelines/pipeline_types.md#workload-pipeline)。

先决条件：

- 管理员访问权限。

要为项目配置推送规则：

1. 查找与服务账号关联的电子邮件地址：
   1. 在右上角，选择 **管理员**。
   1. 选择 **概览** > **用户**，然后搜索与流程关联的账号。
      该账号遵循 `duo-[flow-name]-[top-level-group-name]` 模式。
   1. 找到服务账号用户并复制其电子邮件地址。

1. 允许该电子邮件地址向项目推送：
   1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
   1. 选择 **设置** > **代码仓**。
   1. 展开 **推送规则**。
   1. 在 **提交作者邮箱** 中，添加一个允许您刚刚复制的电子邮件地址的正则表达式。
   1. 选择 **保存推送规则**。

1. 允许 `duo/feature/` 分支前缀：
   1. 在 **推送规则** 部分，找到 **分支名称**。
   1. 添加一个允许以 ^duo/(fix|feature|refactor|docs/).* 开头的分支的正则表达式。
      例如：`^(duo/feature)/.*$`
   1. 选择 **保存推送规则**。

要为实例创建推送规则：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **推送规则**。
1. 按照前面的步骤允许 **提交作者邮箱** 和 **分支名称**。
1. 选择 **保存推送规则**。

<a id="error-ssl-certificate-openssl-verify-result-unable-to-get-local-issuer-certificate-20"></a>

## 错误：`SSL 证书 OpenSSL 验证结果：无法获取本地颁发者证书 (20)`

在使用了自定义或自签名 CA 证书的极狐GitLab 私有化部署实例上，当极狐GitLab Duo Agent Platform 作业在初始 `git clone`（`get_sources` 阶段）期间失败时，可能会显示此消息。

发生这种情况是因为极狐GitLab Duo Agent Platform 作业设置了 `GIT_CONFIG_GLOBAL=/dev/null` 和 `GIT_CONFIG_NOSYSTEM=1` 来强化代理沙箱。这些变量会阻止 Git 读取系统和全局配置文件，从而破坏了 Runner 在 `get_sources` 期间注入 CA 证书路径的机制。

不执行流程的 CI/CD 作业不受影响。此问题特定于极狐GitLab Duo Agent Platform 的工作负载流水线。

要解决此问题，请在 [`config.toml`](https://gitlab.cn/docs/runner/configuration/advanced-configuration/) 文件中，在 Runner 级别设置 `GIT_SSL_CAINFO` 环境变量，并将 CA 证书挂载到容器中：

```toml
[[runners]]
  environment = ["GIT_SSL_CAINFO=/etc/gitlab-runner/certs/ca.crt"]
  [runners.docker]
    volumes = ["/path/to/your/ca-bundle.crt:/etc/gitlab-runner/certs/ca.crt:ro"]
```

将 `/path/to/your/ca-bundle.crt` 替换为 Runner 主机上 CA 证书包的实际路径。
该文件必须是 PEM 格式的 CA 证书包，其中包含您的根 CA 和任何中间证书。

您可能期望将其设置为 CI/CD 变量，但自定义 CI/CD 变量在极狐GitLab Duo Agent Platform 作业中[不可用](flows/execution_variables.md#custom-cicd-variables)。
您必须使用 Runner 的 `config.toml` `environment` 指令。

要通过自定义 CA 将极狐GitLab Duo CLI 连接到极狐GitLab 实例，请将 `NODE_EXTRA_CA_CERTS` 添加到同一 `environment` 行：

```toml
[[runners]]
  environment = [
    "GIT_SSL_CAINFO=/etc/gitlab-runner/certs/ca.crt",
    "NODE_EXTRA_CA_CERTS=/etc/gitlab-runner/certs/ca.crt"
  ]
  [runners.docker]
    volumes = ["/path/to/your/ca-bundle.crt:/etc/gitlab-runner/certs/ca.crt:ro"]
```

如果极狐GitLab Duo CLI 在沙箱运行时 (SRT) 中运行，Runner 的 `environment` 变量可能无法传递给它。如果此更改后 TLS 错误仍然存在，请在 `agent-config.yml` 的 `setup_script` 中设置 `NODE_EXTRA_CA_CERTS`。`setup_script` 在容器内运行，不受沙箱过滤。

`GIT_SSL_CAINFO` 变量处理极狐GitLab Duo CLI 启动前发生的 Git 操作。有关极狐GitLab Duo CLI 证书配置，请参阅[自定义 SSL 证书](../gitlab_duo_cli/_index.md#custom-ssl-certificates)。

<a id="run-the-configuration-diagnostic-script"></a>

## 运行配置诊断脚本

如果您无法从相关功能文档中确定极狐GitLab Duo Agent Platform 问题的原因，请运行诊断脚本来检查您的配置。

该脚本会检查极狐GitLab Duo Agent Platform 功能所需的完整配置链：

- 许可证有效性和计划。
- 实例级别的极狐GitLab Duo 设置。
- 带有 `gitlab--duo` 标签的 CI/CD Runner。
- 命名空间和项目的极狐GitLab Duo 设置。
- 内置任务流及其服务账号。
- 功能可用性，例如代码审查流程可用性和自动审查设置。

> [!warning]
> 此脚本仅读取配置数据，不会修改任何设置。
> 输出可能包含内部配置详细信息。
> 在与支持人员共享之前，请对输出进行脱敏处理。

先决条件：

- 极狐GitLab 18.8 或更高版本

要在极狐GitLab 19.0 或更高版本中运行诊断脚本：

- 运行内置的 `gitlab:duo:verify_setup` [Rake 任务](../../administration/raketasks/_index.md)。
  将 `<group/project>` 替换为项目的完整路径，例如 `gitlab-org/gitlab`。

  例如：

  ```shell
  sudo gitlab-rake "gitlab:duo:verify_setup[<group/project>]"
  ```

要在极狐GitLab 18.8 至 18.11 版本中运行诊断脚本：

{{< tabs >}}

{{< tab title="Linux 软件包 (Omnibus)" >}}

1. 下载 [`verify_setup.rb`](https://jihulab.com/gitlab-cn/gitlab/-/raw/master/ee/lib/gitlab/duo/administration/verify_setup.rb)。
1. 将 `verify_setup.rb` 文件复制到您的极狐GitLab 服务器。
1. 运行脚本。
   将 `<group/project>` 替换为项目的完整路径，例如 `gitlab-org/gitlab`。

   ```shell
   sudo gitlab-rails runner "load '/tmp/verify_setup.rb'; Gitlab::Duo::Administration::VerifySetup.new('<group/project>').execute"
   ```

{{< /tab >}}

{{< tab title="Docker" >}}

1. 下载 [`verify_setup.rb`](https://jihulab.com/gitlab-cn/gitlab/-/raw/master/ee/lib/gitlab/duo/administration/verify_setup.rb)。
1. 将 `verify_setup.rb` 文件复制到容器中。
1. 运行脚本。
   将 `<group/project>` 替换为项目的完整路径，例如 `gitlab-org/gitlab`。

   ```shell
   docker cp verify_setup.rb <container-id>:/tmp/verify_setup.rb
   docker exec -it <container-id> gitlab-rails runner \
   "load '/tmp/verify_setup.rb'; Gitlab::Duo::Administration::VerifySetup.new('<group/project>').execute"
   ```

{{< /tab >}}

{{< tab title="自编译（源代码）" >}}

1. 下载 [`verify_setup.rb`](https://jihulab.com/gitlab-cn/gitlab/-/raw/master/ee/lib/gitlab/duo/administration/verify_setup.rb)。
1. 将 `verify_setup.rb` 文件复制到您的极狐GitLab 服务器。
1. 从极狐GitLab 应用程序目录运行脚本。
   将 `<group/project>` 替换为项目的完整路径，例如 `gitlab-org/gitlab`。

   ```shell
   sudo -u git bundle exec rails runner \
   "load '/tmp/verify_setup.rb'; Gitlab::Duo::Administration::VerifySetup.new('<group/project>').execute"
   ```

{{< /tab >}}

{{< tab title="Helm Chart (Kubernetes)" >}}

1. 下载 [`verify_setup.rb`](https://jihulab.com/gitlab-cn/gitlab/-/raw/master/ee/lib/gitlab/duo/administration/verify_setup.rb)。
1. 将 `verify_setup.rb` 文件复制到工具箱 Pod 中。
1. 运行脚本。
   将 `<group/project>` 替换为项目的完整路径，例如 `gitlab-org/gitlab`。

   ```shell
   # 查找工具箱 Pod
   kubectl get pods --namespace <namespace> -lapp=toolbox

   kubectl cp verify_setup.rb <namespace>/<toolbox-pod-name>:/tmp/verify_setup.rb
   kubectl exec -it <toolbox-pod-name> -- gitlab-rails runner \
   "load '/tmp/verify_setup.rb'; Gitlab::Duo::Administration::VerifySetup.new('<group/project>').execute"
   ```

{{< /tab >}}

{{< /tabs >}}