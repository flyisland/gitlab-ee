---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 管理集群应用
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

极狐GitLab 提供集群管理项目模板，您可以使用它来创建项目。该项目包含与极狐GitLab 集成并扩展极狐GitLab 功能的集群应用。您可以使用项目中展示的模式来扩展您的自定义集群应用。

> [!note]
> 该模板无需修改即可在 JihuLab.com 上使用。如果您使用的是极狐GitLab 私有化部署实例，则必须修改 `.gitlab-ci.yml` 文件。

<a id="use-one-project-for-the-agent-and-your-manifests"></a>

## 为代理和您的清单使用同一个项目

如果您尚未使用代理将集群与极狐GitLab 连接：

1. [基于集群管理项目模板创建项目](#create-a-project-based-on-the-cluster-management-project-template)。
1. [为代理配置项目](agent/install/_index.md)。
1. 在项目的设置中，创建一个名为 `$KUBE_CONTEXT`的
   [环境变量](../../ci/variables/_index.md#for-a-project)，
   并将其值设置为 `path/to/agent-configuration-project:your-agent-name`。
1. 根据需要[配置文件](#configure-the-project)。

<a id="use-separate-projects-for-the-agent-and-your-manifests"></a>

## 为代理和您的清单使用不同的项目

如果您已配置代理并将集群与极狐GitLab 连接：

1. [基于集群管理项目模板创建项目](#create-a-project-based-on-the-cluster-management-project-template)。
1. 在您配置代理的项目中，
   [授予代理访问新项目的权限](agent/ci_cd_workflow.md#authorize-agent-access)。
1. 在新项目中，创建一个名为 `$KUBE_CONTEXT`的
   [环境变量](../../ci/variables/_index.md#for-a-project)，
   并将其值设置为 `path/to/agent-configuration-project:your-agent-name`。
1. 在新项目中，根据需要[配置文件](#configure-the-project)。

<a id="create-a-project-based-on-the-cluster-management-project-template"></a>

## 基于集群管理项目模板创建项目

要基于集群管理项目模板创建项目：

1. 在右上角，选择**创建新的**（{{< icon name="plus" >}}）和**新建项目/代码仓库**。
1. 选择**从模板创建**。
1. 在模板列表中，找到 **GitLab集群管理**，选择**使用模板**。
1. 输入项目详细信息。
1. 选择**创建项目**。
1. 在新项目中，根据需要[配置文件](#configure-the-project)。

<a id="configure-the-project"></a>

## 配置项目

使用集群管理模板创建项目后，您可以配置：

- [`.gitlab-ci.yml` 文件](#the-gitlab-ciyml-file)。
- [主 `helmfile.yml` 文件](#the-main-helmfileyml-file)。
- [内置应用所在目录](#built-in-applications)。

<a id="the-gitlab-ciyml-file"></a>

### `.gitlab-ci.yml` 文件

`.gitlab-ci.yml` 文件：

- 确保您使用的是 Helm 版本 3。
- 从项目部署已启用的应用。

您可以编辑并扩展流水线定义。

流水线中使用的基础镜像由
[cluster-applications](https://gitlab.com/gitlab-org/cluster-integration/cluster-applications) 项目构建。
该镜像包含一组 Bash 实用脚本，用于支持 [Helm v3 release](https://helm.sh/docs/intro/using_helm/#three-big-concepts)。

如果您使用的是极狐GitLab 私有化部署实例，则必须修改 `.gitlab-ci.yml` 文件。具体来说，以注释 `Automatic package upgrades` 开头的部分在极狐GitLab 私有化部署实例上无法正常工作，因为其中的 `include` 引用了 JihuLab.com 上的项目。如果您删除该注释下方的所有内容，流水线即可成功运行。

<a id="the-main-helmfileyml-file"></a>

### 主 `helmfile.yml` 文件

该模板包含一个 [Helmfile](https://github.com/helmfile/helmfile)，您可以使用它通过 [Helm v3](https://helm.sh/) 管理集群应用。

该文件包含每个应用对应的其他 Helm 文件的路径列表。默认情况下，这些路径全部被注释掉，因此您必须取消注释您想在集群中使用的应用的路径。

默认情况下，这些子路径中的每个 `helmfile.yaml` 都具有属性 `installed: true`。这意味着，根据集群和 Helm release的状态，Helmfile 会在每次流水线运行时尝试安装或更新应用。如果您将该属性改为 `installed: false`，Helmfile 会尝试从集群中卸载该应用。[阅读更多](https://helmfile.readthedocs.io/en/latest/)内容，了解 Helmfile 的工作原理。

<a id="built-in-applications"></a>

### 内置应用

该模板包含一个 `applications` 目录，其中为模板中的每个应用配置了一个 `helmfile.yaml`。

[内置支持的应用程序](https://gitlab.com/gitlab-org/project-templates/cluster-management/-/tree/main/applications)包括：

- [Cert-manager](../infrastructure/clusters/manage/management_project_applications/certmanager.md)
- [极狐GitLab Runner](../infrastructure/clusters/manage/management_project_applications/runner.md)
- [Ingress](../infrastructure/clusters/manage/management_project_applications/ingress.md)
- [Vault](../infrastructure/clusters/manage/management_project_applications/vault.md)

每个应用都有一个 `applications/{app}/values.yaml` 文件。
对于极狐GitLab Runner，该文件为 `applications/{app}/values.yaml.gotmpl`。

在该文件中，您可以为应用的 Helm chart 定义默认值。部分应用已定义了默认值。
