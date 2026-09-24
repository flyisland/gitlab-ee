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

极狐GitLab 提供了一个集群管理项目模板，你可以使用该模板来创建项目。该项目包含与极狐GitLab 集成并扩展极狐GitLab 功能的集群应用。你可以使用项目中展示的模式来扩展你的自定义集群应用。

> [!注]
> 该项目模板在 JihuLab.com 上无需修改即可运行。如果你使用的是私有化部署的极狐GitLab 实例，则必须修改 `.gitlab-ci.yml` 文件。

## 为代理和清单使用同一个项目

如果你**尚未**使用代理将集群连接到极狐GitLab：

1. [基于集群管理项目模板创建项目](#基于集群管理项目模板创建项目)。
1. [为代理配置项目](agent/install/_index.md)。
1. 在项目的设置中，创建一个名为 `$KUBE_CONTEXT` 的[环境变量](../../ci/variables/_index.md#for-a-project)，并将其值设置为 `path/to/agent-configuration-project:your-agent-name`。
1. 根据需要[配置文件](#配置项目)。

## 为代理和清单使用不同的项目

如果你已经配置了代理并将集群连接到极狐GitLab：

1. [基于集群管理项目模板创建项目](#基于集群管理项目模板创建项目)。
1. 在你配置了代理的项目中，[授予代理对新项目的访问权限](agent/ci_cd_workflow.md#authorize-agent-access)。
1. 在新项目中，创建一个名为 `$KUBE_CONTEXT` 的[环境变量](../../ci/variables/_index.md#for-a-project)，并将其值设置为 `path/to/agent-configuration-project:your-agent-name`。
1. 在新项目中，根据需要[配置文件](#配置项目)。

<a id="create-a-project-based-on-the-cluster-management-project-template"></a>

## 基于集群管理项目模板创建项目

要从集群管理项目模板创建项目：

1. 在右上角，选择 **新建** ({{< icon name="plus" >}}) 然后选择 **新项目/仓库**。
1. 选择 **从模板创建**。
1. 从模板列表中，找到 **极狐GitLab 集群管理**，选择 **使用模板**。
1. 输入项目详情。
1. 选择 **创建项目**。
1. 在新项目中，根据需要[配置文件](#配置项目)。

<a id="configure-the-project"></a>

## 配置项目

使用集群管理模板创建项目后，你可以配置：

- [`.gitlab-ci.yml` 文件](#gitlab-ciyml-文件)。
- [主 `helmfile.yml` 文件](#主-helmfileyml-文件)。
- [包含内置应用的目录](#内置应用)。

<a id="the-gitlab-ciyml-file"></a>

### `.gitlab-ci.yml` 文件

`.gitlab-ci.yml` 文件：

- 确保你使用的是 Helm 3 版本。
- 从项目中部署已启用的应用程序。

你可以编辑和扩展流水线定义。

流水线中使用的基础镜像由 [cluster-applications](https://gitlab.com/gitlab-org/cluster-integration/cluster-applications) 项目构建。
该镜像包含一组 Bash 实用脚本，用于支持 [Helm v3 版本](https://helm.sh/docs/intro/using_helm/#three-big-concepts)。

如果你使用的是私有化部署的极狐GitLab 实例，则必须修改 `.gitlab-ci.yml` 文件。
具体来说，以注释 `Automatic package upgrades` 开头的部分在私有化部署实例上无法运行，因为 `include` 引用了 JihuLab.com 项目。
如果你删除此注释下方的所有内容，流水线将会成功运行。

<a id="the-main-helmfileyml-file"></a>

### 主 `helmfile.yml` 文件

该模板包含一个 [Helmfile](https://github.com/helmfile/helmfile)，你可以使用 [Helm v3](https://helm.sh/) 来管理集群应用。

此文件包含指向每个应用的其他 Helm 文件的路径列表。默认情况下它们都被注释掉了，因此你必须取消注释你想要在集群中使用的应用的路径。

默认情况下，这些子路径中的每个 `helmfile.yaml` 都具有属性 `installed: true`。这意味着，根据你的集群和 Helm 版本的状态，每次流水线运行时 Helmfile 都会尝试安装或更新应用。如果将此属性更改为 `installed: false`，Helmfile 会尝试从你的集群中卸载此应用。[阅读更多](https://helmfile.readthedocs.io/en/latest/) 关于 Helmfile 如何工作的信息。

<a id="built-in-applications"></a>

### 内置应用

该模板包含一个 `applications` 目录，为模板中的每个应用配置了 `helmfile.yaml`。

[内置支持的应用](https://gitlab.com/gitlab-org/project-templates/cluster-management/-/tree/master/applications) 包括：

- [Cert-manager](../infrastructure/clusters/manage/management_project_applications/certmanager.md)
- [极狐GitLab Runner](../infrastructure/clusters/manage/management_project_applications/runner.md)
- [Ingress](../infrastructure/clusters/manage/management_project_applications/ingress.md)
- [Vault](../infrastructure/clusters/manage/management_project_applications/vault.md)

每个应用都有一个 `applications/{app}/values.yaml` 文件。
对于极狐GitLab Runner，该文件是 `applications/{app}/values.yaml.gotmpl`。

在此文件中，你可以为应用的 Helm Chart 定义默认值。
某些应用已经定义了默认值。