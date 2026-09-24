---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用 Auto DevOps 将应用程序部署到 Amazon Elastic Kubernetes Service (EKS)
---

<a id="use-auto-devops-to-deploy-an-application-to-amazon-elastic-kubernetes-service-eks"></a>

# 使用 Auto DevOps 将应用程序部署到 Amazon Elastic Kubernetes Service (EKS)

本教程以如何将应用程序部署到 Amazon Elastic Kubernetes Service (EKS) 为例，带您快速上手 [Auto DevOps](../_index.md)。

本教程使用极狐GitLab 原生 Kubernetes 集成，因此您无需通过 AWS 控制台手动创建 Kubernetes 集群。

您也可以在私有化部署的极狐GitLab 实例上遵循本教程。确保您自己的 [Runner 已配置](../../../ci/runners/_index.md)。

要将项目部署到 EKS：

1. [配置您的 Amazon 账户](#configure-your-amazon-account)
1. [创建 Kubernetes 集群并部署代理](#create-a-kubernetes-cluster)
1. [从模板创建新项目](#create-an-application-project-from-a-template)
1. [配置代理](#configure-the-agent)
1. [安装 Ingress](#install-ingress)
1. [配置 Auto DevOps](#configure-auto-devops)
1. [启用 Auto DevOps 并运行流水线](#enable-auto-devops-and-run-the-pipeline)
1. [部署应用程序](#deploy-the-application)

<a id="configure-your-amazon-account"></a>

## 配置您的 Amazon 账户

在创建 Kubernetes 集群并将其连接到您的极狐GitLab 项目之前，您需要一个 [Amazon Web Services 账户](https://aws.amazon.com/)。使用现有 Amazon 账户登录或创建一个新账户。

<a id="create-a-kubernetes-cluster"></a>

## 创建 Kubernetes 集群

要在 Amazon EKS 上创建新集群：

- 按照[创建 Amazon EKS 集群](../../../user/infrastructure/clusters/connect/new_eks_cluster.md)中的步骤操作。

如果您愿意，也可以使用 `eksctl` 手动创建集群。

<a id="create-an-application-project-from-a-template"></a>

## 从模板创建应用程序项目

使用极狐GitLab 项目模板快速开始。顾名思义，这些项目提供了基于一些知名框架构建的极简应用程序。

> [!warning]
> 在群组层级中，将应用程序项目创建在与集群管理项目相同或更低的位置。否则，将无法[授权代理](../../../user/clusters/agent/ci_cd_workflow.md#authorize-agent-access)。

1. 在右上角，选择 **创建新项目** ({{< icon name="plus" >}}) 和 **新项目/仓库**。
1. 选择 **从模板创建**。
1. 选择 **Ruby on Rails** 模板。
1. 为您的项目命名，可选填描述，并将其设为公开，这样您就可以充分利用[极狐GitLab 旗舰版计划](https://gitlab.cn/pricing/)中提供的功能。
1. 选择 **创建项目**。

现在您有一个可以部署到 EKS 集群的应用程序项目。

<a id="configure-the-agent"></a>

## 配置代理

接下来，配置极狐GitLab Kubernetes 代理，以便使用它来部署应用程序项目。

1. 前往[您为管理集群而创建的项目](#create-a-kubernetes-cluster)。
1. 找到[代理配置文件](../../../user/clusters/agent/install/_index.md#create-an-agent-configuration-file) (`.gitlab/agents/eks-agent/config.yaml`) 并进行编辑。
1. 配置 `ci_access:projects` 属性。使用应用程序项目路径作为 `id`：

```yaml
ci_access:
  projects:
    - id: path/to/application-project
```

<a id="install-ingress"></a>

## 安装 Ingress

集群运行后，您必须安装 NGINX Ingress Controller 作为负载均衡器，将来自互联网的流量路由到您的应用程序。可以通过极狐GitLab [集群管理项目模板](../../../user/clusters/management_project_template.md)安装 NGINX Ingress Controller，也可以使用命令行手动安装：

1. 确保您的机器上安装了 `kubectl` 和 Helm。
1. 创建一个 IAM 角色以访问集群。
1. 创建一个访问令牌以访问集群。
1. 使用 `kubectl` 连接到您的集群：

   ```shell
   helm upgrade --install ingress-nginx ingress-nginx \
   --repo https://kubernetes.github.io/ingress-nginx \
   --namespace gitlab-managed-apps --create-namespace

   # Check that the ingress controller is installed successfully
   kubectl get service ingress-nginx-controller -n gitlab-managed-apps
   ```

<a id="configure-auto-devops"></a>

## 配置 Auto DevOps

按照以下步骤配置 Auto DevOps 所需的基础域名和其他设置。

1. 安装 NGINX 几分钟后，负载均衡器会获取一个 IP 地址，您可以使用以下命令获取外部 IP 地址：

   ```shell
   kubectl get all -n gitlab-managed-apps --selector app.kubernetes.io/instance=ingress-nginx
   ```

   如果您覆盖了命名空间，请将 `gitlab-managed-apps` 替换为您的命名空间。

   接着，使用以下命令查找集群的实际外部 IP 地址：

   ```shell
   nslookup [External IP]
   ```

   其中 `[External IP]` 是上一条命令查找到的主机名。

   IP 地址可能列在响应的 `非权威应答:` 部分。

   复制此 IP 地址，下一步需要使用。
1. 返回应用程序项目。
1. 在左侧边栏中，选择 **设置** > **CI/CD** 并展开 **变量**。
   - 添加名为 `KUBE_INGRESS_BASE_DOMAIN` 的键，值设置为应用程序部署域名。本示例使用域名 `<IP address>.nip.io`。
   - 添加名为 `KUBE_NAMESPACE` 的键，值为您的部署所针对的 Kubernetes 命名空间。您可以为不同环境使用不同命名空间。配置环境时，请使用环境范围。
   - 添加名为 `KUBE_CONTEXT` 的键，值类似于 `path/to/agent/project:eks-agent`。选择您想要的环境范围。
   - 选择 **保存更改**。

<a id="enable-auto-devops-and-run-the-pipeline"></a>

## 启用 Auto DevOps 并运行流水线

虽然默认启用了 Auto DevOps，但可以在整个实例（对于私有化部署的极狐GitLab 实例）和单个群组中禁用。如果 Auto DevOps 被禁用，请完成以下步骤以启用它：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到应用程序项目。
1. 选择 **设置** > **CI/CD**。
1. 展开 **Auto DevOps**。
1. 选择 **默认使用 Auto DevOps 流水线** 以显示更多选项。
1. 在 **部署策略** 中，选择所需的[持续部署策略](../requirements.md#auto-devops-deployment-strategy)，以便在流水线在默认分支上成功运行后将应用程序部署到生产环境。
1. 选择 **保存更改**。
1. 编辑 `.gitlab-ci.yml` 文件以包含 Auto DevOps 模板，并将更改提交到默认分支：

   ```yaml
   include:
   - template: Auto-DevOps.gitlab-ci.yml
   ```

该提交应会触发一条流水线。下一节将说明流水线中每个作业的作用。

<a id="deploy-the-application"></a>

## 部署应用程序

当您的流水线运行时，它在做什么？

要查看流水线中的作业，请选择流水线的状态徽章。当流水线作业运行时，会显示 {{< icon name="status_running" >}} 图标，并会在作业完成时更新为 {{< icon name="status_success" >}}（成功）或 {{< icon name="status_failed" >}}（失败），无需刷新页面。

作业分为若干阶段：

![Pipeline stages](img/guide_pipeline_stages_v13_0.png)

- **构建** - 应用程序构建 Docker 镜像并将其上传到您项目的[容器镜像仓库](../../../user/packages/container_registry/_index.md)（[自动构建](../stages.md#auto-build)）。
- **测试** - 极狐GitLab 对应用程序运行各种检查，但测试阶段中除 `test` 外的所有作业都允许失败：

  - `test` 作业通过检测语言和框架来运行单元测试和集成测试（[自动测试](../stages.md#auto-test)）
  - `code_quality` 作业检查代码质量并允许失败（[自动代码质量](../stages.md#auto-code-quality)）
  - `container_scanning` 作业检查 Docker 容器是否存在任何漏洞并允许失败（[自动容器扫描](../stages.md#auto-container-scanning)）
  - `dependency_scanning` 作业检查应用程序是否存在任何易受攻击的依赖项并允许失败（[自动依赖项扫描](../stages.md#auto-dependency-scanning)）
  - 后缀为 `-sast` 的作业对当前代码进行静态分析以检查潜在的安全问题，并允许失败（[自动 SAST](../stages.md#auto-sast)）
  - `secret-detection` 作业检查密钥泄露并允许失败（[自动密钥检测](../stages.md#auto-secret-detection)）
- **审查** - 默认分支上的流水线包含此阶段和 `dast_environment_deploy` 作业。要了解更多，请参阅[动态应用程序安全测试（DAST）](../../../user/application_security/dast/_index.md)。
- **生产** - 在测试和检查完成后，应用程序部署到 Kubernetes（[自动部署](../stages.md#auto-deploy)）。
- **性能** - 对已部署的应用程序运行性能测试（[自动浏览器性能测试](../stages.md#auto-browser-performance-testing)）。
- **清理** - 默认分支上的流水线包含此阶段和 `stop_dast_environment` 作业。

运行流水线后，您应查看已部署的网站并了解如何监控它。

<a id="monitor-your-project"></a>

### 监控您的项目

成功部署应用程序后，您可以通过导航到 **运维** > **环境** 在 **环境** 页面上查看其网站并检查其健康状况。此页面显示有关已部署应用程序的详细信息，右侧列显示链接到常见环境任务的图标：

![Environments](img/guide_environments_v12_3.png)

- **打开生产环境** ({{< icon name="external-link" >}}) - 打开部署到生产环境的应用程序的 URL
- **监控** ({{< icon name="chart" >}}) - 打开指标页面，Prometheus 在其中收集有关 Kubernetes 集群以及应用程序在内存使用、CPU 使用和延迟方面如何影响它的数据
- **部署到** ({{< icon name="play" >}} {{< icon name="chevron-lg-down" >}}) - 显示您可以部署到的环境列表
- **终端** ({{< icon name="terminal" >}}) - 在运行应用程序的容器内打开一个 [Web 终端](../../../ci/environments/_index.md#web-terminals-deprecated) 会话
- **重新部署到环境** ({{< icon name="repeat" >}}) - 有关更多信息，请参阅[重试和回滚](../../../ci/environments/deployments.md#retry-or-roll-back-a-deployment)
- **停止环境** ({{< icon name="stop" >}}) - 有关更多信息，请参阅[停止环境](../../../ci/environments/_index.md#stopping-an-environment)

极狐GitLab 在环境信息下方显示[部署面板](../../../user/project/deploy_boards.md)，其中的方块代表 Kubernetes 集群中的 Pod，用颜色编码显示其状态。将鼠标悬停在部署面板上的方块上会显示部署状态，选择方块会进入 Pod 的日志页面。

虽然示例目前只显示一个托管应用程序的 Pod，但您可以通过在 **设置** > **CI/CD** > **变量** 中定义 [`REPLICAS` CI/CD 变量](../cicd_variables.md)来添加更多 Pod。

<a id="work-with-branches"></a>

### 使用分支

接下来，创建一个功能分支来为应用程序添加内容：

1. 在您项目的仓库中，找到以下文件：`app/views/welcome/index.html.erb`。此文件应只包含一个段落：`<p>You're on Rails!</p>`。
1. 打开极狐GitLab [Web IDE](../../../user/project/web_ide/_index.md) 进行更改。
1. 编辑文件使其包含：

   ```html
   <p>You're on Rails! Powered by GitLab Auto DevOps.</p>
   ```

1. 暂存文件。添加提交消息，然后通过选择 **提交** 创建一个新分支和一个合并请求。

   ![Web IDE commit](img/guide_ide_commit_v12_3.png)

提交合并请求后，极狐GitLab 会运行您的流水线，包含[前面所述](#deploy-the-application)的所有作业，以及一些仅在非默认分支上运行的额外作业。

几分钟后，一个测试失败了，这意味着您的更改“破坏”了某个测试。选择失败的 `test` 作业以查看有关它的更多信息：

```plaintext
Failure:
WelcomeControllerTest#test_should_get_index [/app/test/controllers/welcome_controller_test.rb:7]:
<You're on Rails!> expected but was
<You're on Rails! Powered by GitLab Auto DevOps.>..
Expected 0 to be >= 1.

bin/rails test test/controllers/welcome_controller_test.rb:4
```

要修复失败的测试：

1. 返回您的合并请求。
1. 在右上角，选择 **代码**，然后选择 **在 Web IDE 中打开**。
1. 在左侧的文件目录中，找到 `test/controllers/welcome_controller_test.rb` 文件，并选择它以将其打开。
1. 将第 7 行改为 `You're on Rails! Powered by GitLab Auto DevOps.`
1. 在左侧边栏中，选择 **源代码管理** ({{< icon name="merge" >}})。
1. 编写提交消息，然后选择 **提交**。

返回到合并请求的 **概览** 页面，您不仅应该看到测试通过，还应该看到应用程序作为[审查应用](../stages.md#auto-review-apps)部署。您可以通过选择 **查看应用** {{< icon name="external-link" >}} 按钮来访问它，以查看您的更改已部署。

合并合并请求后，极狐GitLab 在默认分支上运行流水线，然后将应用程序部署到生产环境。

<a id="conclusion"></a>

## 总结

完成此项目后，您应该对 Auto DevOps 的基础知识有了扎实的理解。您从构建和测试开始，到在极狐GitLab 中部署和监控应用程序。尽管 Auto DevOps 具有自动化特性，但它也可以进行配置和自定义以适合您的工作流程。以下是一些有助于进一步阅读的资源：

1. [Auto DevOps](../_index.md)
1. [多个 Kubernetes 集群](../multiple_clusters_auto_devops.md)
1. [增量发布到生产环境](../cicd_variables.md#incremental-rollout-to-production)
1. [使用 CI/CD 变量禁用不需要的作业](../cicd_variables.md)
1. [使用您自己的构建包来构建应用程序](../customize.md#custom-buildpacks)