---
stage: Application Security Testing
group: Static Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 离线环境
description: 离线安全扫描和解决漏洞。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

> [!note]
> 要设置离线环境，你必须在购买前获得[云许可的退出豁免](https://gitlab.cn/pricing/licensing-faq/cloud-licensing/#offline-cloud-licensing)。更多详情，请联系你的极狐GitLab 销售代表。

在未连接到互联网时，也可以运行大多数极狐GitLab 安全扫描器。

本文档描述了如何在离线环境中操作安全类别（即扫描器类型）。这些说明也适用于已加固、具有安全策略（例如防火墙策略）或以其他方式限制访问完整互联网的极狐GitLab 私有化部署实例。极狐GitLab 将这些环境称为_离线环境_。其他常见名称包括：

- 气隙环境
- 有限连接环境
- 局域网 (LAN) 环境
- 内网环境

这些环境具有物理屏障或安全策略（例如防火墙），可防止或限制互联网访问。这些说明专为物理断开的网络而设计，但也可在其他用例中遵循。

<a id="defining-offline-environments"></a>

## 定义离线环境

在离线环境中，极狐GitLab 实例可以是一台或多台可在本地网络上通信的服务器和服务，但无法访问互联网或访问受限。假设极狐GitLab 实例和支持基础设施（例如私有 Maven 仓库）中的任何内容都可以通过本地网络连接访问。假设来自互联网的任何文件都必须通过物理介质（USB 驱动器、硬盘、可写 DVD 等）传入。

<a id="use-offline-scanners"></a>

## 使用离线扫描器

极狐GitLab 扫描器通常会连接到互联网以下载最新的签名、规则和补丁集。需要一些额外的步骤来配置这些工具，以便使用本地网络上可用的资源正常运行。

<a id="container-registries-and-package-repositories"></a>

### 容器镜像仓库和软件包仓库

从高层次来看，安全分析器以 Docker 镜像的形式交付，并可能利用各种软件包仓库。当你在连接互联网的极狐GitLab 安装上运行作业时，极狐GitLab 会检查 JihuLab.com 托管的容器镜像仓库，以确认你拥有这些 Docker 镜像的最新版本，并可能连接到软件包仓库以安装必要的依赖项。

在离线环境中，必须禁用这些检查，以免查询 JihuLab.com。由于 JihuLab.com 的镜像仓库和仓库不可用，你必须更新每个扫描器，使其引用不同的内部托管镜像仓库，或提供对各个扫描器镜像的访问。

你还必须确保你的应用可以访问不在 JihuLab.com 上托管的常见软件包仓库，例如 npm、yarn 或 Ruby gems。这些仓库中的软件包可以通过临时连接到网络或在自己的离线网络中镜像软件包来获取。

<a id="interacting-with-the-vulnerabilities"></a>

### 与漏洞交互

发现漏洞后，你可以与之交互。阅读有关如何[处理漏洞](../vulnerabilities/_index.md)的更多信息。

在某些情况下，报告的漏洞提供的元数据可能包含在 UI 中暴露的外部链接。这些链接在离线环境中可能无法访问。

<a id="resolving-vulnerabilities"></a>

### 解决漏洞

[解决漏洞](../vulnerabilities/_index.md#resolve-a-vulnerability)功能可用于离线依赖项扫描和容器扫描，但可能无法正常工作，具体取决于实例的配置。极狐GitLab 只能在能够访问托管该依赖项或镜像最新版本的最新注册表服务时，才能建议解决方案（通常是更新的修补版本）。

<a id="scanner-signature-and-rule-updates"></a>

### 扫描器签名和规则更新

连接到互联网时，某些扫描器会参考公共数据库以获取最新的签名和规则集来进行检查。没有连接时，这是不可能的。因此，根据扫描器的不同，你必须禁用这些自动更新检查，并使用它们自带的数据库并手动更新这些数据库，或提供对网络中托管的自有副本的访问。

<a id="specific-scanner-instructions"></a>

## 特定扫描器说明

每个扫描器可能与之前描述的步骤略有不同。你可以在以下每个页面中找到更多信息：

- [容器扫描离线说明](../container_scanning/_index.md#offline-environment)
- [SAST 离线说明](../sast/_index.md#running-sast-in-an-offline-environment)
- [密钥检测离线说明](../secret_detection/pipeline/configure.md#offline-configuration)
- [DAST 离线说明](../dast/browser/configuration/offline_configuration.md)
- [API 模糊测试离线说明](../api_fuzzing/configuration/offline_configuration.md)
- [许可证扫描离线说明](../../compliance/license_scanning_of_cyclonedx_files/_index.md#running-in-an-offline-environment)
- [依赖项扫描离线说明](../dependency_scanning/dependency_scanning_sbom/_index.md#offline-environment)
- [IaC 扫描离线说明](../iac_scanning/_index.md#offline-configuration)

<a id="loading-docker-images-onto-your-offline-host"></a>

## 将 Docker 镜像加载到离线主机上

要使用许多极狐GitLab 功能，包括安全扫描和 [Auto DevOps](../../../topics/autodevops/_index.md)，Runner 必须能够获取相关的 Docker 镜像。

在不直接访问公共互联网的情况下使这些镜像可用的过程包括下载镜像，然后打包并将其传输到离线主机。以下是一个此类传输的示例：

1. 从公共互联网下载 Docker 镜像。
1. 将 Docker 镜像打包为 tar 归档文件。
1. 将镜像传输到离线环境。
1. 将传输的镜像加载到离线 Docker 注册表中。

<a id="using-the-official-gitlab-template"></a>

### 使用官方极狐GitLab 模板

极狐GitLab 提供了一个[内置模板](../../../ci/yaml/_index.md#includetemplate)来简化此过程。

此模板应在一个新的空项目中使用，其中包含一个 `.gitlab-ci.yml` 文件，内容如下：

```yaml
include:
  - template: Security/Secure-Binaries.gitlab-ci.yml
```

该流水线下载安全扫描器所需的 Docker 镜像，并将其保存为[作业产物](../../../ci/jobs/job_artifacts.md)或推送到执行流水线的项目的[容器镜像仓库](../../packages/container_registry/_index.md)。这些归档文件可以传输到另一个位置，并在 Docker 守护进程中[加载](https://docs.docker.com/reference/cli/docker/image/load/)。此方法需要一个能够同时访问 `jihulab.com`（包括 `registry.jihulab.com`）和本地离线实例的 Runner。该 Runner 必须以[特权模式](https://gitlab.cn/docs/runner/executors/docker/#use-docker-in-docker-with-privileged-mode)运行，以便能够在作业中使用 `docker` 命令。此 Runner 可以安装在 DMZ 或堡垒机上，并仅用于此特定项目。

> [!warning]
> 此模板不包括容器扫描分析器的更新。请参阅[容器扫描离线说明](../container_scanning/_index.md#offline-environment)。

<a id="scheduling-the-updates"></a>

#### 计划更新

默认情况下，此项目的流水线仅在将 `.gitlab-ci.yml` 添加到仓库时运行一次。要更新极狐GitLab 安全扫描器和签名，必须定期运行此流水线。极狐GitLab 提供了一种[计划流水线](../../../ci/pipelines/schedules.md)的方法。例如，你可以设置每周下载并存储 Docker 镜像。

<a id="using-the-secure-bundle-created"></a>

#### 使用创建的安全包

使用 `Secure-Binaries.gitlab-ci.yml` 模板的项目现在应托管运行极狐GitLab 安全功能所需的所有镜像和资源。

接下来，你必须告诉离线实例使用这些资源，而不是 JihuLab.com 上的默认资源。为此，请使用项目的[容器镜像仓库](../../packages/container_registry/_index.md)的 URL 设置 CI/CD 变量 `SECURE_ANALYZERS_PREFIX`。

你可以在项目的 `.gitlab-ci.yml` 中设置此变量，或者在项目或群组的极狐GitLab UI 中设置。有关更多信息，请参阅[极狐GitLab CI/CD 变量页面](../../../ci/variables/_index.md#define-a-cicd-variable-in-the-ui)。

<a id="variables"></a>

#### 变量

| CI/CD 变量                            | 描述                                   | 默认值                     |
|-------------------------------------------|-----------------------------------------------|-----------------------------------|
| `SECURE_BINARIES_ANALYZERS`               | 要下载的分析器的逗号分隔列表 | `"bandit, brakeman, gosec, ..."` |
| `SECURE_BINARIES_DOWNLOAD_IMAGES`         | 用于禁用作业                          | `"true"`                          |
| `SECURE_BINARIES_PUSH_IMAGES`             | 将文件推送到项目镜像仓库            | `"true"`                          |
| `SECURE_BINARIES_SAVE_ARTIFACTS`          | 也将镜像归档保存为产物         | `"false"`                         |
| `SECURE_BINARIES_ANALYZER_VERSION`        | 默认分析器版本（Docker 标签）         | `"2"`                             |

<a id="alternate-way-without-the-official-template"></a>

### 不使用官方模板的替代方法

如果无法遵循之前的方法，可以手动传输镜像：

<a id="example-image-packager-script"></a>

#### 示例镜像打包脚本

```shell
#!/bin/bash
set -ux

# Specify needed analyzer images
analyzers=${SAST_ANALYZERS:-"bandit eslint gosec"}
gitlab=registry.gitlab.com/security-products/

for i in "${analyzers[@]}"
do
  tarname="${i}_2.tar"
  docker pull $gitlab$i:2
  docker save $gitlab$i:2 -o ./analyzers/${tarname}
  chmod +r ./analyzers/${tarname}
done
```

<a id="example-image-loader-script"></a>

#### 示例镜像加载脚本

```shell
#!/bin/bash
set -ux

# Specify needed analyzer images
analyzers=${SAST_ANALYZERS:-"bandit eslint gosec"}
registry=$GITLAB_HOST:4567

for i in "${analyzers[@]}"
do
  tarname="${i}_2.tar"
  scp ./analyzers/${tarname} ${GITLAB_HOST}:~/${tarname}
  ssh $GITLAB_HOST "sudo docker load -i ${tarname}"
  ssh $GITLAB_HOST "sudo docker tag $(sudo docker images | grep $i | awk '{print $3}') ${registry}/analyzers/${i}:2"
  ssh $GITLAB_HOST "sudo docker push ${registry}/analyzers/${i}:2"
done
```

<a id="using-gitlab-secure-with-autodevops-in-an-offline-environment"></a>

### 在离线环境中将极狐GitLab Secure 与 AutoDevOps 结合使用

你可以在离线环境中使用极狐GitLab AutoDevOps 进行 Secure 扫描。但是，你必须首先执行以下步骤：

1. 将容器镜像加载到本地镜像仓库。极狐GitLab Secure 利用分析器容器镜像来执行各种扫描。这些镜像必须作为运行 AutoDevOps 的一部分可用。在运行 AutoDevOps 之前，请按照[官方极狐GitLab 模板](#using-the-official-gitlab-template)中的步骤将这些容器镜像加载到本地容器镜像仓库中。
2. 设置 CI/CD 变量，以确保 AutoDevOps 在正确的位置查找这些镜像。AutoDevOps 模板利用 `SECURE_ANALYZERS_PREFIX` 变量来识别分析器镜像的位置。有关更多信息，请参阅[使用创建的安全包](#using-the-secure-bundle-created)。确保将此变量设置为加载分析器镜像的正确值。你可以考虑通过项目 CI/CD 变量或直接[修改](../../../topics/autodevops/customize.md#customize-gitlab-ciyml) `.gitlab-ci.yml` 文件来实现。

完成这些步骤后，极狐GitLab 拥有 Secure 分析器的本地副本，并设置为使用它们而不是互联网托管的容器镜像。这允许你在离线环境中运行 AutoDevOps 中的 Secure。

这些步骤特定于极狐GitLab Secure 与 AutoDevOps。将其他阶段与 AutoDevOps 结合使用可能需要 [Auto DevOps 文档](../../../topics/autodevops/_index.md)中涵盖的其他步骤。