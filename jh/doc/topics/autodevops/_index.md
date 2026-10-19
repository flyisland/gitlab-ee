---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Auto DevOps
description: 自动化 DevOps，语言检测，部署与定制。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

Auto DevOps 能够将您的代码转变为生产就绪的应用程序，无需通常的配置开销。
整个 DevOps 生命周期已根据行业最佳实践预先配置。从默认配置开始快速发布，
然后根据需要自定义以获得更多控制。无需复杂的配置文件或深厚的 DevOps 专业知识。

通过 Auto DevOps，您可以获得：

- 自动检测语言和框架的 CI/CD 流水线
- 内置安全扫描，在生产前发现漏洞
- 每次提交时的代码质量与性能测试
- 开箱即用的审查应用，可在实时环境中预览变更
- 快速部署至 Kubernetes 集群
- 降低风险与停机时间的渐进式部署策略

## Auto DevOps 功能

Auto DevOps 支持在 [DevOps 阶段](stages.md)的每个环节进行开发。

| 阶段 | Auto DevOps 功能 |
|--------|---------------------|
| 构建 | [自动构建](stages.md#auto-build) |
| 构建 | [自动依赖项扫描](stages.md#auto-dependency-scanning) |
| 测试 | [自动测试](stages.md#auto-test) |
| 测试 | [自动浏览器性能测试](stages.md#auto-browser-performance-testing) |
| 测试 | [自动代码智能](stages.md#auto-code-intelligence) |
| 测试 | [自动代码质量](stages.md#auto-code-quality) |
| 测试 | [自动容器扫描](stages.md#auto-container-scanning) |
| 部署 | [自动审查应用](stages.md#auto-review-apps) |
| 部署 | [自动部署](stages.md#auto-deploy) |
| 安全 | [自动动态应用程序安全测试（DAST）](stages.md#auto-dast) |
| 安全 | [自动静态应用程序安全测试（SAST）](stages.md#auto-sast) |
| 安全 | [自动密钥检测](stages.md#auto-secret-detection) |

### 与应用平台和 PaaS 的比较

Auto DevOps 提供了通常包含在应用平台或平台即服务（PaaS）中的功能。

受 [Heroku](https://www.heroku.com/) 的启发，Auto DevOps 在多个方面超越了它：

- Auto DevOps 适用于任何 Kubernetes 集群。
- 无需额外费用。
- 您可以使用自己托管或任何公有云上的集群。
- Auto DevOps 提供了渐进式的成长路径。如果需要[自定义](customize.md)，可以从修改模板开始，并在此基础上逐步发展。

## Auto DevOps 入门

要开始使用，您只需[启用 Auto DevOps](#enable-or-disable-auto-devops)。
这足以运行 Auto DevOps 流水线来构建和测试您的应用程序。

如果您想要构建、测试并部署您的应用：

1. 查看[部署要求](requirements.md)。
1. [启用 Auto DevOps](#enable-or-disable-auto-devops)。
1. 部署您的应用到云提供商。

### 启用或禁用 Auto DevOps

只有当存在 [`Dockerfile` 或匹配的构建包](stages.md#auto-build)时，Auto DevOps 才会自动运行流水线。

您可以针对单个项目或整个群组启用或禁用 Auto DevOps。实例管理员还能将 Auto DevOps [设置为所有项目的默认配置](../../administration/settings/continuous_integration.md#configure-auto-devops-for-all-projects)。

在启用 Auto DevOps 之前，请考虑[为其部署做好准备](requirements.md)。
否则，Auto DevOps 可以构建和测试您的应用，但无法部署。

#### 针对项目

要对单个项目使用 Auto DevOps，您可以逐个项目启用。如果您打算在更多项目中使用，
您可以为[群组](#per-group)或[实例](../../administration/settings/continuous_integration.md#configure-auto-devops-for-all-projects)启用它。
这可以省去在每个项目中逐一启用的时间。

先决条件：

- 您必须具有项目的维护者或所有者角色。
- 确保您的项目没有 `.gitlab-ci.yml` 文件。如果存在，您的 CI/CD 配置将优先于 Auto DevOps 流水线。

要为项目启用 Auto DevOps：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开 **Auto DevOps**。
1. 选中**默认 Auto DevOps 流水线**复选框。
1. 可选但推荐。添加[基础域名](requirements.md#auto-devops-base-domain)。
1. 可选但推荐。选择[部署策略](requirements.md#auto-devops-deployment-strategy)。
1. 选择**保存更改**。

极狐GitLab 将在默认分支上触发 Auto DevOps 流水线。

要禁用它，重复上述步骤并取消选中**默认 Auto DevOps 流水线**复选框。

#### 针对群组

当您为群组启用 Auto DevOps 时，该群组下的子群组和项目会继承该配置。您可以通过为群组启用 Auto DevOps 来节省时间，
而不必为每个子群组或项目逐一启用。

为群组启用后，您仍然可以在不想使用 Auto DevOps 的子群组和项目中禁用它。

先决条件：

- 您必须具有该群组的所有者角色。

要为群组启用 Auto DevOps：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的群组。
1. 在左侧边栏中，选择**设置** > **CI/CD**。
1. 展开 **Auto DevOps**。
1. 选中**默认 Auto DevOps 流水线**复选框。
1. 选择**保存更改**。

要为群组禁用 Auto DevOps，重复上述步骤并取消选中**默认 Auto DevOps 流水线**复选框。

为群组启用 Auto DevOps 后，您可以触发该群组下任何项目的 Auto DevOps 流水线：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 确保项目不包含 `.gitlab-ci.yml` 文件。
1. 选择**构建** > **流水线**。
1. 要触发 Auto DevOps 流水线，选择**新建流水线**。

## 在极狐GitLab 更新时升级 Auto DevOps 依赖项

更新极狐GitLab 时，您可能需要升级 Auto DevOps 依赖项以匹配新的极狐GitLab 版本：

- [升级 Auto DevOps 资源](upgrading_auto_deploy_dependencies.md)：
  - Auto DevOps 模板。
  - Auto Deploy 模板。
  - Auto Deploy 镜像。
  - Helm。
  - Kubernetes。
  - 环境变量。
- [升级 PostgreSQL](upgrading_postgresql.md)。

## 私有镜像仓库支持

无法保证您可以配合 Auto DevOps 使用私有容器镜像仓库。

建议使用[极狐GitLab 容器镜像仓库](../../user/packages/container_registry/_index.md)与 Auto DevOps，以简化配置并防止任何意外问题。

## 在代理后安装应用程序

极狐GitLab 与 Helm 的集成不支持在代理后安装应用程序。

如果您想这样做，必须在运行时将代理设置注入到安装 Pod 中。

## 相关主题

- [持续方法论](../../ci/_index.md)
- [Docker](https://docs.docker.com)
- [极狐GitLab Runner](https://gitlab.cn/docs/runner)
- [Helm](https://helm.sh/docs/)
- [Kubernetes](https://kubernetes.io/docs/home/)
- [Prometheus](https://prometheus.io/docs/introduction/overview/)

## 故障排除

请参阅[Auto DevOps 故障排除](troubleshooting.md)。