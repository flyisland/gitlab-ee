---
stage: Application Security Testing
group: Composition Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 容器镜像扫描
description: Image vulnerability scanning, configuration, customization, and reporting.
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

容器镜像中的安全漏洞在您的应用整个生命周期中带来风险。
容器镜像扫描能够在风险进入生产环境之前尽早检测到它们。当
您的基础镜像或操作系统软件包中出现漏洞时，容器镜像扫描
能够识别它们，并为可修复的漏洞提供修复路径。

- 有关入门教程，请参阅[扫描 Docker 容器中的漏洞](../../../tutorials/container_scanning/_index.md)。

容器镜像扫描通常被视为软件构成分析 (SCA) 的一部分。SCA 包含检查代码所使用项目的过程。这些项目通常包括应用程序和系统依赖项，它们几乎总是从外部源导入，而不是来自您自己编写的代码。

极狐GitLab 同时提供容器镜像扫描和依赖项扫描
以确保覆盖所有这些依赖类型。为了尽可能覆盖您所面临的风险领域，
请使用所有安全扫描工具。要比较这些功能，请参阅
[依赖项扫描与容器镜像扫描对比](../comparison_dependency_and_container_scanning.md)。

极狐GitLab 与 [Trivy](https://github.com/aquasecurity/trivy) 安全扫描器集成，对容器中的漏洞进行静态分析。

> [!warning]
> Grype 分析器已不再维护，仅根据极狐GitLab [支持声明](https://gitlab.cn/support/statement-of-support/#version-support)中说明的有限修复进行支持。
> Grype 分析器镜像的现有当前主版本将继续更新最新的公告数据库和操作系统软件包，直至极狐GitLab 19.0，届时该分析器将停止工作。

## 功能特性

| 功能特性 | 基础版和专业版 | 旗舰版 |
|----------|---------------------|-------------|
| 自定义设置（[变量](#available-cicd-variables)、[覆盖](#overriding-the-container-scanning-template)、[离线环境支持](#offline-environment)等） | {{< yes >}} | {{< yes >}} |
| 以 CI 作业产物的形式 [查看 JSON 报告](#reports-json-format) | {{< yes >}} | {{< yes >}} |
| 以 CI 作业产物的形式生成 [CycloneDX SBOM JSON 报告](#cyclonedx-software-bill-of-materials) | {{< yes >}} | {{< yes >}} |
| 通过极狐GitLab UI 中的 MR 启用容器镜像扫描 | {{< yes >}} | {{< yes >}} |
| [UBI 镜像支持](#fips-enabled-images) | {{< yes >}} | {{< yes >}} |
| 支持 Trivy | {{< yes >}} | {{< yes >}} |
| [End-of-life 操作系统检测](#end-of-life-operating-system-detection) | {{< yes >}} | {{< yes >}} |
| 包含极狐GitLab 公告数据库 | 仅限于极狐GitLab [advisories-communities](https://jihulab.com/gitlab-cn/advisories-community/) 项目中延迟发布的内容 | 是 - 来自 [Gemnasium DB](https://jihulab.com/gitlab-cn/security-products/gemnasium-db) 的所有最新内容 |
| 在合并请求和 CI 流水线作业的安全选项卡中展示报告数据 | {{< no >}} | {{< yes >}} |
| [漏洞解决方案（自动修复）](#solutions-for-vulnerabilities-auto-remediation) | {{< no >}} | {{< yes >}} |
| 支持 [漏洞允许列表](#vulnerability-allowlisting) | {{< no >}} | {{< yes >}} |
| [访问依赖项列表页面](../dependency_list/_index.md) | {{< no >}} | {{< yes >}} |

## 入门

在 CI/CD 流水线中启用容器镜像扫描分析器。当流水线运行时，您的应用程序所依赖的镜像会被扫描以查找漏洞。您可以通过使用 CI/CD 变量来自定义容器镜像扫描。

前提条件：

- `.gitlab-ci.yml` 文件中需要包含 `test` 阶段。
- 对于私有化部署的 runner，您需要在 Linux/amd64 上使用具有 `docker` 或 `kubernetes` 执行器的 runner。如果您使用的是 JihuLab.com 上的实例 runner，则该项默认已启用。
- 匹配[支持的操作系统发行版](#supported-distributions)的镜像。
- 将 Docker 镜像[构建并推送](../../packages/container_registry/build_and_push_images.md#use-gitlab-cicd)到您项目的容器镜像仓库中。
- 如果您使用的是第三方容器镜像仓库，可能需要使用 CI/CD 变量 `CS_REGISTRY_USER` 和 `CS_REGISTRY_PASSWORD` 提供认证凭据。有关如何使用这些变量的详细信息，请参阅[向私有的外部镜像仓库进行认证](#authenticate-to-private-external-registry)。

要启用分析器，可执行以下任一操作：

- 启用 Auto DevOps，其中包含依赖项扫描。
- 使用预配置的合并请求。
- 创建强制进行容器镜像扫描的[扫描执行策略](../policies/scan_execution_policies.md)。
- 手动编辑 `.gitlab-ci.yml` 文件。

### 使用预配置的合并请求

此方法会自动准备一个合并请求，其中包含 `.gitlab-ci.yml` 文件中的容器镜像扫描模板。然后您合并该合并请求以启用容器镜像扫描。

> [!note]
> 当不存在 `.gitlab-ci.yml` 文件，或仅有最小化配置文件时，此方法效果最佳。
> 如果您有复杂的极狐GitLab 配置文件，可能无法成功解析，并可能发生错误。在这种情况下，请改用手动方法。

前提条件：

- 拥有项目的 Developer、Maintainer 或 Owner 角色。
- `.gitlab-ci.yml` 文件中存在 `test` 阶段。
- 对于私有化部署的 runner，需要在 Linux/amd64 上使用具有 `docker` 或 `kubernetes` 执行器的 runner。如果您使用的是 JihuLab.com 上的实例 runner，则该项默认已启用。
- 匹配[支持的操作系统发行版](#supported-distributions)的镜像。
- Docker 镜像已[构建并推送](../../packages/container_registry/build_and_push_images.md#use-gitlab-cicd)到您项目的容器镜像仓库。
- 如果您使用的是第三方容器镜像仓库，可能需要使用 CI/CD 变量 `CS_REGISTRY_USER` 和 `CS_REGISTRY_PASSWORD` 提供认证凭据。有关详细信息，请参阅[向私有的外部镜像仓库进行认证](#authenticate-to-private-external-registry)。

要启用容器镜像扫描：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **安全** > **安全配置**。
1. 在 **容器镜像扫描** 行中，选择 **使用合并请求配置**。
1. 选择 **创建合并请求**。
1. 审查合并请求，然后选择 **合并**。

流水线现在包含容器镜像扫描作业。

### 手动编辑 `.gitlab-ci.yml` 文件

此方法要求您手动编辑现有的 `.gitlab-ci.yml` 文件。如果您有复杂的极狐GitLab 配置文件或需要使用非默认选项，请使用此方法。

前提条件：

- 拥有项目的 Developer、Maintainer 或 Owner 角色。
- `.gitlab-ci.yml` 文件中存在 `test` 阶段。
- 对于私有化部署的 runner，需要在 Linux/amd64 上使用具有 `docker` 或 `kubernetes` 执行器的 runner。如果您使用的是 JihuLab.com 上的实例 runner，则该项默认已启用。
- 匹配[支持的操作系统发行版](#supported-distributions)的镜像。
- Docker 镜像已[构建并推送](../../packages/container_registry/build_and_push_images.md#use-gitlab-cicd)到您项目的容器镜像仓库。
- 如果您使用的是第三方容器镜像仓库，可能需要使用 CI/CD 变量 `CS_REGISTRY_USER` 和 `CS_REGISTRY_PASSWORD` 提供认证凭据。有关详细信息，请参阅[向私有的外部镜像仓库进行认证](#authenticate-to-private-external-registry)。

要启用容器镜像扫描：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **构建** > **流水线编辑器**。
1. 如果不存在 `.gitlab-ci.yml` 文件，请选择 **配置流水线**，然后删除示例内容。
1. 将以下内容复制并粘贴到 `.gitlab-ci.yml` 文件底部。如果已存在 `include` 行，则仅在其下方添加 `template` 行。

   ```yaml
   include:
     - template: Jobs/Container-Scanning.gitlab-ci.yml
   ```

1. 选择 **验证** 选项卡，然后选择 **验证流水线**。

   消息 **模拟成功完成** 确认文件有效。
1. 选择 **编辑** 选项卡。
1. 填写字段。**分支** 字段不要使用默认分支。
1. 选中 **使用这些更改开始一个新的合并请求** 复选框，然后选择 **提交更改**。
1. 按照您的标准工作流程填写字段，然后选择 **创建合并请求**。
1. 按照您的标准工作流程审查和编辑合并请求，等待流水线通过，然后选择 **合并**。

流水线现在包含容器镜像扫描作业。

## 理解扫描结果

前提条件：

- 拥有项目的 Security Manager、Developer、Maintainer 或 Owner 角色。

您可以在流水线中审查漏洞：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **构建** > **流水线**。
1. 选择流水线。
1. 选择 **安全** 选项卡。
1. 选择一个漏洞以查看其详细信息，包括：
   - 描述：解释漏洞的成因、潜在影响以及推荐的修复步骤。
   - 状态：指示漏洞是否已进行分类或已解决。
   - 严重性：根据影响分为六个级别。 [了解更多关于严重性级别的信息](../vulnerabilities/severities.md)。
   - CVSS 评分：提供与严重性相对应的数值。
   - EPSS：显示该漏洞在野利用的可能性。
   - 已知利用漏洞 (KEV)：指示该漏洞已被利用。
   - 项目：突出显示发现漏洞的项目。
   - 报告类型：解释输出类型。
   - 扫描器：标识检测到漏洞的是哪个分析器。
   - 镜像：提供与该漏洞相关的镜像。
   - 命名空间：标识与该漏洞相关的工作区。
   - 链接：显示该漏洞被各种公告数据库收录的证据。
   - 标识符：用于对漏洞进行分类的引用列表，例如 CVE 标识符。

更多详情，请参阅[流水线安全报告](../detect/security_scanning_results.md)。

查看容器镜像扫描结果的其他方式：

- [漏洞报告](../vulnerability_report/_index.md)：显示默认分支上已确认的漏洞。
- [容器镜像扫描报告产物](../../../ci/yaml/artifacts_reports.md#artifactsreportscontainer_scanning)

## 优化

极狐GitLab 为容器镜像扫描提供两种方式：

- 标准容器镜像扫描：每个作业扫描单个容器镜像。最适合简单和分布式工作流程。
- [多容器扫描](multi_container_scanning.md)：使用单个配置文件并行扫描多个镜像。最适合高效扫描多个镜像。

## 推广

在对单个项目的容器镜像扫描结果有信心后，您可以将其实现扩展到更多项目：

- 使用[强制扫描执行](../detect/security_configuration.md#create-a-shared-configuration)在群组中应用容器镜像扫描设置。
- 如果您有特殊需求，可以在[离线环境](#offline-environment)中运行容器镜像扫描。

## 支持的操作系统发行版

支持以下 Linux 发行版：

- Alma Linux
- Alpine Linux
- Amazon Linux
- CentOS
- CBL-Mariner
- Debian
- Distroless
- Oracle Linux
- Photon OS
- Red Hat (RHEL)
- Rocky Linux
- SUSE
- Ubuntu

### 启用 FIPS 的镜像

极狐GitLab 还提供容器镜像扫描镜像的 [启用 FIPS 的 Red Hat UBI](https://www.redhat.com/en/blog/introducing-red-hat-universal-base-image) 版本。因此，您可以用启用 FIPS 的镜像替换标准镜像。要配置镜像，请将 `CS_IMAGE_SUFFIX` 设置为 `-fips`，或将 `CS_ANALYZER_IMAGE` 变量修改为标准标签加上 `-fips` 后缀。

> [!note]
> 当极狐GitLab 实例中启用 FIPS 模式时，`-fips` 标志会自动添加到 `CS_ANALYZER_IMAGE` 中。

启用 FIPS 模式时，不支持扫描需要认证的镜像仓库中的容器镜像。当 `CI_GITLAB_FIPS_MODE` 为 `"true"` 且设置了 `CS_REGISTRY_USER` 或 `CS_REGISTRY_PASSWORD` 时，分析器会报错退出，不执行扫描。

## 配置

### 自定义分析器行为

要自定义容器镜像扫描，请使用 [CI/CD 变量](#available-cicd-variables)。

#### 启用详细输出

当您需要详细了解依赖项扫描作业的具体操作时（例如进行故障排除时），请启用详细输出。

在以下示例中，包含了容器镜像扫描模板，并启用了详细输出。

```yaml
include:
  - template: Jobs/Container-Scanning.gitlab-ci.yml

variables:
    SECURE_LOG_LEVEL: 'debug'
```

#### 报告语言特定的发现项

`CS_DISABLE_LANGUAGE_VULNERABILITY_SCAN` CI/CD 变量控制扫描是否报告与编程语言相关的发现项。有关支持的语言的更多信息，请参阅 Trivy 文档中的[特定语言软件包](https://aquasecurity.github.io/trivy/latest/docs/coverage/language/#supported-languages)。

默认情况下，报告仅包括由操作系统 (OS) 软件包管理器（例如 `yum`、`apt`、`apk`、`tdnf`）管理的软件包。要报告非操作系统软件包中的安全发现项，请将 `CS_DISABLE_LANGUAGE_VULNERABILITY_SCAN` 设置为 `"false"`：

```yaml
include:
  - template: Jobs/Container-Scanning.gitlab-ci.yml

container_scanning:
  variables:
    CS_DISABLE_LANGUAGE_VULNERABILITY_SCAN: "false"
```

启用此功能后，如果您的项目同时启用了依赖项扫描，您可能在漏洞报告中看到[重复的发现项](../terminology/_index.md#duplicate-finding)。这是因为极狐GitLab 无法自动对不同类型扫描工具之间的发现项进行去重。要了解哪些类型的依赖项可能会重复，请参阅[依赖项扫描与容器镜像扫描对比](../comparison_dependency_and_container_scanning.md)。

#### 在合并请求流水线中运行作业

请参阅[在合并请求流水线中使用安全扫描工具](../detect/security_configuration.md#use-security-scanning-tools-with-merge-request-pipelines)。

#### 可用的 CI/CD 变量

要自定义容器镜像扫描，请使用 CI/CD 变量。下表列出了特定于容器镜像扫描的 CI/CD 变量。您也可以使用任何[预定义的 CI/CD 变量](../../../ci/variables/predefined_variables.md)。

> [!warning]
> 在将这些更改合并到默认分支之前，请在合并请求中测试对极狐GitLab 分析器的自定义。否则可能导致意外结果，包括大量误报。
| CI/CD 变量                              | 默认值                                                                          | 描述                                                                                                                                                                                                                                                                                                                                                                                                   |
|------------------------------------------|-------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `ADDITIONAL_CA_CERT_BUNDLE`              | `""`                                                                          | 您想信任的 CA 证书包。详情请参阅[使用自定义 SSL CA 证书颁发机构](#using-a-custom-ssl-ca-certificate-authority)。                                                                                                                                                                                                                                                                                              |
| `CI_APPLICATION_REPOSITORY`              | `$CI_REGISTRY_IMAGE/$CI_COMMIT_REF_SLUG`                                      | 要扫描的镜像的 Docker 仓库 URL。                                                                                                                                                                                                                                                                                                                                                                       |
| `CI_APPLICATION_TAG`                     | `$CI_COMMIT_SHA`                                                              | 要扫描的镜像的 Docker 仓库标签。                                                                                                                                                                                                                                                                                                                                                                       |
| `CS_ANALYZER_IMAGE`                      | `registry.gitlab.com/security-products/container-scanning:8`                  | 分析器的 Docker 镜像。请勿在 极狐GitLab 提供的分析器镜像上使用 `:latest` 标签。                                                                                                                                                                                                                                                                                                                           |
| `CS_DEFAULT_BRANCH_IMAGE`                | `""`                                                                          | 默认分支上的 `CS_IMAGE` 名称。详情请参阅[设置默认分支镜像](#setting-the-default-branch-image)。                                                                                                                                                                                                                                                                                                          |
| `CS_DISABLE_DEPENDENCY_LIST`             | `"false"`                                                                     | {{< icon name="warning" >}} **[已移除](https://gitlab.com/gitlab-org/gitlab/-/issues/439782)** 于极狐GitLab 17.0。                                                                                                                                                                                                                                                                                      |
| `CS_DISABLE_LANGUAGE_VULNERABILITY_SCAN` | `"true"`                                                                      | 禁用对被扫描镜像中安装的特定语言包的扫描。                                                                                                                                                                                                                                                                                                                                                             |
| `CS_DOCKER_INSECURE`                     | `"false"`                                                                     | 允许访问使用 HTTPS 的安全 Docker 仓库，但不验证证书。                                                                                                                                                                                                                                                                                                                                                  |
| `CS_DOCKERFILE_PATH`                     | `Dockerfile`                                                                  | 用于生成修复方案的 `Dockerfile` 路径。默认情况下，扫描器会在项目根目录下查找名为 `Dockerfile` 的文件。仅当您的 `Dockerfile` 位于非标准位置（如子目录）时才应配置此变量。详情请参阅[漏洞解决方案](#solutions-for-vulnerabilities-auto-remediation)。                                                                                                                                                       |
| `CS_INCLUDE_LICENSES`                    | `""`                                                                          | 如果设置，此变量会为每个组件包含许可证信息。仅适用于 cyclonedx 报告，这些许可证由 [trivy](https://trivy.dev/v0.60/docs/scanner/license/) 提供。                                                                                                                                                                                                                                                            |
| `CS_IGNORE_STATUSES`                     | `""`                                                                          | 强制分析器忽略具有指定状态的发现项，状态以逗号分隔列表指定。允许的值有：`unknown,not_affected,affected,fixed,under_investigation,will_not_fix,fix_deferred,end_of_life`。<sup>1</sup>                                                                                                                                                                                                                  |
| `CS_IGNORE_UNFIXED`                      | `"false"`                                                                     | 忽略未修复的发现项。被忽略的发现项不会包含在报告中。                                                                                                                                                                                                                                                                                                                                                    |
| `CS_IMAGE`                               | `$CI_APPLICATION_REPOSITORY:$CI_APPLICATION_TAG`                              | 要扫描的 Docker 镜像。如果设置，此变量会覆盖 `$CI_APPLICATION_REPOSITORY` 和 `$CI_APPLICATION_TAG` 变量。                                                                                                                                                                                                                                                                                               |
| `CS_IMAGE_SUFFIX`                        | `""`                                                                          | 添加到 `CS_ANALYZER_IMAGE` 的后缀。若设置为 `-fips`，则使用 `启用 FIPS` 镜像进行扫描。详情请参阅[启用 FIPS 的镜像](#fips-enabled-images)。                                                                                                                                                                                                                                                               |
| `CS_QUIET`                               | `""`                                                                          | 如果设置，此变量会在作业日志中禁用[漏洞表](#container-scanning-job-log-format)的输出。                                                                                                                                                                                                                                                                                                                  |
| `CS_REGISTRY_INSECURE`                   | `"false"`                                                                     | 允许访问不安全的仓库（仅 HTTP）。仅应在本地测试镜像时设置为 `true`。适用于所有扫描器，但仓库必须监听端口 `80/tcp` 才能使 Trivy 正常工作。                                                                                                                                                                                                                                                                   |
| `CS_REGISTRY_PASSWORD`                   | `$CI_REGISTRY_PASSWORD`                                                       | 用于访问需要认证的 Docker 仓库的密码。默认值仅在 `$CS_IMAGE` 位于 [`$CI_REGISTRY`](../../../ci/variables/predefined_variables.md) 时设置。启用 FIPS 模式时不支持。                                                                                                                                                                                                                                |
| `CS_REGISTRY_USER`                       | `$CI_REGISTRY_USER`                                                           | 用于访问需要认证的 Docker 仓库的用户名。默认值仅在 `$CS_IMAGE` 位于 [`$CI_REGISTRY`](../../../ci/variables/predefined_variables.md) 时设置。启用 FIPS 模式时不支持。                                                                                                                                                                                                                              |
| `CS_REPORT_OS_EOL`                       | `"false"`                                                                     | 启用 EOL 检测。                                                                                                                                                                                                                                                                                                                                                                                        |
| `CS_REPORT_OS_EOL_SEVERITY`              | `"Medium"`                                                                    | 当启用 `CS_REPORT_OS_EOL` 时，分配给 EOL 操作系统发现项的严重级别。无论 `CS_SEVERITY_THRESHOLD` 如何，EOL 发现项始终上报。支持的级别为 `UNKNOWN`、`LOW`、`MEDIUM`、`HIGH` 和 `CRITICAL`。                                                                                                                                                                                                                 |
| `CS_SEVERITY_THRESHOLD`                  | `UNKNOWN`                                                                     | 严重级别阈值。扫描器输出严重级别高于或等于此阈值的漏洞。支持的级别为 `UNKNOWN`、`LOW`、`MEDIUM`、`HIGH` 和 `CRITICAL`。                                                                                                                                                                                                                                                                                  |
| `CS_TRIVY_JAVA_DB`                       | `"registry.gitlab.com/gitlab-org/security-products/dependencies/trivy-java-db"` | 为 [trivy-java-db](https://github.com/aquasecurity/trivy-java-db) 漏洞数据库指定备用位置。                                                                                                                                                                                                                                                                                                            |
| `CS_TRIVY_DETECTION_PRIORITY`            | `"precise"`                                                                   | 使用定义的 Trivy [检测优先级](https://trivy.dev/latest/docs/scanner/vulnerability/#detection-priority) 进行扫描。允许的值有：`precise` 或 `comprehensive`。                                                                                                                                                                                                                                               |
| `SECURE_LOG_LEVEL`                       | `info`                                                                        | 设置最低日志记录级别。输出此日志级别或更高级别的消息。从最高到最低严重性，日志级别为：`fatal`、`error`、`warn`、`info`、`debug`。                                                                                                                                                                                                                                                                            |
| `TRIVY_TIMEOUT`                          | `5m0s`                                                                        | 设置扫描的超时时间。                                                                                                                                                                                                                                                                                                                                                                                   |
| `TRIVY_PLATFORM`                         | `linux/amd64`                                                                 | 如果镜像是多平台的，请以 `os/arch` 格式设置平台。                                                                                                                                                                                                                                                                                                                                                       |

**脚注**：

1. 修复状态信息高度依赖于软件供应商提供的准确修复可用性数据以及容器镜像操作系统软件包的元数据。同时，它也受到各个容器扫描器解释的影响。当容器扫描器错误报告某个漏洞的修复包可用性时，启用 `CS_IGNORE_STATUSES` 可能会导致对发现项的误判（误报或漏报）筛选。

<a id="configure-trivy-directly-with-native-environment-variables"></a>

#### 直接使用原生环境变量配置 Trivy

除了上面列出的极狐GitLab 特有的 `CS_*` 变量外，您还可以在 `container_scanning` 作业中直接设置 Trivy 的任何[原生环境变量](https://trivy.dev/docs/v0.69/guide/configuration/#environment-variables)来配置 Trivy。极狐GitLab 容器扫描分析器会自动将所有环境变量传递给 Trivy。

例如，要为 Trivy 无法自动检测的容器镜像手动指定操作系统发行版（例如定制的基础镜像）：

```yaml
include:
  - template: Jobs/Container-Scanning.gitlab-ci.yml

container_scanning:
  variables:
    GIT_STRATEGY: fetch
    TRIVY_DISTRO: "alma/10"
```

> [!note]
> `TRIVY_DISTRO` 使用的 `--distro` 标志在 Trivy 中为[实验性功能](https://trivy.dev/docs/v0.69/guide/references/configuration/cli/trivy_image/)。
> 结果可能因 Trivy 版本和指定的发行版而异。

<a id="variables-managed-by-the-gitlab-wrapper"></a>

##### 由 极狐GitLab 包装器管理的变量

以下 `TRIVY_*` 变量由极狐GitLab 容器扫描分析器内部设置。它们由对应的 GitLab CI/CD 变量控制，不能直接覆盖：

| Trivy 变量          | 极狐GitLab CI/CD 变量       |
|---------------------|--------------------------|
| `TRIVY_CACHE_DIR`   | （内部使用，不对外公开）  |
| `TRIVY_USERNAME`    | `CS_REGISTRY_USER`       |
| `TRIVY_PASSWORD`    | `CS_REGISTRY_PASSWORD`   |
| `TRIVY_DEBUG`       | `SECURE_LOG_LEVEL`       |
| `TRIVY_INSECURE`    | `CS_DOCKER_INSECURE`     |
| `TRIVY_NON_SSL`     | `CS_REGISTRY_INSECURE`   |

<a id="known-issue-with-trivy_db_repository"></a>

##### 使用 `TRIVY_DB_REPOSITORY` 的已知问题

将 `TRIVY_DB_REPOSITORY` 设置为指向自定义漏洞数据库没有效果。极狐GitLab 容器扫描分析器将漏洞数据库打包在分析器镜像内，并在运行时向 Trivy 传递 `--skip-db-update`，因此无论此变量如何，Trivy 都不会下载数据库。要使用自定义数据库位置，请参阅[使用 Trivy Java 数据库镜像](#use-a-trivy-java-database-mirror)（针对 Java 数据库）或[离线环境](#offline-environment)（针对一般的离线设置）。

<a id="overriding-the-container-scanning-template"></a>

### 覆盖容器扫描模板

如果您想覆盖作业定义（例如，更改诸如 `variables` 之类的属性），必须在包含模板之后声明并覆盖一个作业，然后指定任何额外的键。

此示例将 `GIT_STRATEGY` 设置为 `fetch`：

```yaml
include:
  - template: Jobs/Container-Scanning.gitlab-ci.yml

container_scanning:
  variables:
    GIT_STRATEGY: fetch
```

<a id="scan-image-in-external-registry"></a>

### 扫描外部仓库中的镜像

默认情况下，容器扫描会扫描极狐GitLab 容器镜像仓库中的镜像。您也可以扫描外部仓库中的镜像。

要扫描外部仓库中的镜像，请使用镜像的完整路径配置 `CS_IMAGE` 变量。

```yaml
include:
  - template: Jobs/Container-Scanning.gitlab-ci.yml

container_scanning:
  variables:
    CS_IMAGE: <example.com>/<user>/<image>:<tag>
```

<a id="authenticate-to-private-external-registry"></a>

#### 对私有外部仓库进行认证

如果外部仓库需要认证，请使用 `CS_REGISTRY_USER` 和 `CS_REGISTRY_PASSWORD` CI/CD 变量提供凭据。

> [!note]
> 启用 FIPS 模式时，不支持扫描外部私有仓库中的镜像。

<a id="use-a-trivy-java-database-mirror"></a>

### 使用 Trivy Java 数据库镜像

当使用 `trivy` 扫描器并在被扫描的容器镜像中遇到 `jar` 文件时，`trivy` 会下载一个额外的 `trivy-java-db` 漏洞数据库。默认情况下，`trivy-java-db` 数据库作为 [OCI 工件](https://oras.land/docs/quickstart/) 托管在 `ghcr.io/aquasecurity/trivy-java-db:1`。如果此仓库[不可访问](#offline-environment)或返回 `TOOMANYREQUESTS`，一个解决方案是将 `trivy-java-db` 镜像到更易访问的容器仓库中：

```yaml
mirror trivy java db:
  image:
    name: ghcr.io/oras-project/oras:v1.1.0
    entrypoint: [""]
  script:
    - oras login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
    - oras pull ghcr.io/aquasecurity/trivy-java-db:1
    - oras push $CI_REGISTRY_IMAGE:1 --config /dev/null:application/vnd.aquasec.trivy.config.v1+json javadb.tar.gz:application/vnd.aquasec.trivy.javadb.layer.v1.tar+gzip
```

漏洞数据库不是常规的 Docker 镜像，因此您不能使用 `docker pull` 拉取它。如果您在极狐GitLab UI 中查看该镜像，会显示错误。

如果容器仓库为 `gitlab.example.com/trivy-java-db-mirror`，则应按以下方式配置容器扫描作业。不要在末尾添加 `:1` 标签，它会由 `trivy` 添加：

```yaml
include:
  - template: Jobs/Container-Scanning.gitlab-ci.yml

container_scanning:
  variables:
    CS_TRIVY_JAVA_DB: gitlab.example.com/trivy-java-db-mirror
```

<a id="setting-the-default-branch-image"></a>

### 设置默认分支镜像

默认情况下，容器扫描假定镜像命名规范将任何分支特定的标识符存储在镜像标签中，而不是镜像名称中。当默认分支与非默认分支的镜像名称不同时，先前检测到的漏洞在合并请求中会显示为新发现的漏洞。

当同一镜像在默认分支和非默认分支上有不同名称时，您可以使用 `CS_DEFAULT_BRANCH_IMAGE` 变量指示该镜像在默认分支上的名称。然后，极狐GitLab 会在非默认分支上运行扫描时正确判断漏洞是否已存在。

例如，假设：

- 非默认分支使用命名规范 `$CI_REGISTRY_IMAGE/$CI_COMMIT_BRANCH:$CI_COMMIT_SHA` 发布镜像。
- 默认分支使用命名规范 `$CI_REGISTRY_IMAGE:$CI_COMMIT_SHA` 发布镜像。

在此示例中，您可以使用以下 CI/CD 配置来确保漏洞不会被重复：

```yaml
include:
  - template: Jobs/Container-Scanning.gitlab-ci.yml

container_scanning:
  variables:
    CS_DEFAULT_BRANCH_IMAGE: $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
  before_script:
    - export CS_IMAGE="$CI_REGISTRY_IMAGE/$CI_COMMIT_BRANCH:$CI_COMMIT_SHA"
    - |
      if [ "$CI_COMMIT_BRANCH" == "$CI_DEFAULT_BRANCH" ]; then
        export CS_IMAGE="$CI_REGISTRY_IMAGE:$CI_COMMIT_SHA"
      fi
```

对于给定的 `CS_IMAGE`，`CS_DEFAULT_BRANCH_IMAGE` 应保持不变。如果它发生变化，则会创建一组重复的漏洞，必须手动消除。

使用 Auto DevOps 时，`CS_DEFAULT_BRANCH_IMAGE` 会自动设置为 `$CI_REGISTRY_IMAGE/$CI_DEFAULT_BRANCH:$CI_APPLICATION_TAG`。

<a id="using-a-custom-ssl-ca-certificate-authority"></a>

### 使用自定义 SSL CA 证书颁发机构

您可以使用 `ADDITIONAL_CA_CERT_BUNDLE` CI/CD 变量配置自定义 SSL CA 证书颁发机构，用于在从使用 HTTPS 的仓库拉取 Docker 镜像时验证对端。`ADDITIONAL_CA_CERT_BUNDLE` 的值应包含 [X.509 PEM 公钥证书的文本表示](https://www.rfc-editor.org/rfc/rfc7468#section-5.1)。例如，要在 `.gitlab-ci.yml` 文件中配置此值，请使用以下内容：

```yaml
container_scanning:
  variables:
    ADDITIONAL_CA_CERT_BUNDLE: |
        -----BEGIN CERTIFICATE-----
        MIIGqTCCBJGgAwIBAgIQI7AVxxVwg2kch4d56XNdDjANBgkqhkiG9w0BAQsFADCB
        ...
        jWgmPqF3vUbZE0EyScetPJquRFRKIesyJuBFMAs=
        -----END CERTIFICATE-----
```

`ADDITIONAL_CA_CERT_BUNDLE` 值也可以在 UI 中配置为自定义变量，可以是 `file` 类型（需要证书路径），也可以是 `variable` 类型（需要证书的文本表示）。

<a id="scanning-a-multi-arch-image"></a>

### 扫描多架构镜像

您可以使用 `TRIVY_PLATFORM` CI/CD 变量将容器扫描配置为针对特定操作系统和架构运行。例如，要在 `.gitlab-ci.yml` 文件中配置此值，请使用以下内容：

```yaml
container_scanning:
  # 使用 arm64 SaaS Runner 本地扫描
  tags: ["saas-linux-small-arm64"]
  variables:
    TRIVY_PLATFORM: "linux/arm64"
```

<a id="vulnerability-allowlisting"></a>

### 漏洞允许列表

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

先决条件：

- 项目的开发者、维护者或所有者角色。

要将特定漏洞添加到允许列表中，请按以下步骤操作：

1. 在 `.gitlab-ci.yml` 文件中，按照[覆盖容器扫描模板](#overriding-the-container-scanning-template)的说明，设置 `GIT_STRATEGY: fetch`。
1. 在名为 `vulnerability-allowlist.yml` 的 YAML 文件中定义允许列表中的漏洞。此文件必须使用 [`vulnerability-allowlist.yml` 数据格式](#vulnerability-allowlistyml-data-format)中描述的格式。
1. 将 `vulnerability-allowlist.yml` 文件添加到项目 Git 仓库的根目录中。

<a id="vulnerability-allowlistyml-data-format"></a>

#### `vulnerability-allowlist.yml` 数据格式

`vulnerability-allowlist.yml` 文件是一个 YAML 文件，指定了允许存在的漏洞 CVE ID 列表，因为这些漏洞是误报，或者不适用。

如果在 `vulnerability-allowlist.yml` 文件中找到匹配的条目，则会发生以下情况：

- 当分析器生成 `gl-container-scanning-report.json` 文件时，该漏洞**不会包含**在内。
- 流水线的“安全”选项卡**不会显示**该漏洞。它不会包含在 JSON 文件中，该文件是“安全”选项卡的真相源。

示例 `vulnerability-allowlist.yml` 文件：

```yaml
generalallowlist:
  CVE-2019-8696:
  CVE-2014-8166: cups
  CVE-2017-18248:
images:
  registry.gitlab.com/gitlab-org/security-products/dast/webgoat-8.0@sha256:
    CVE-2018-4180:
  your.private.registry:5000/centos:
    CVE-2015-1419: libxml2
    CVE-2015-1447:
```

这个例子从 `gl-container-scanning-report.json` 中排除了：

1. 所有具有以下 CVE ID 的漏洞：`CVE-2019-8696`、`CVE-2014-8166`、`CVE-2017-18248`。
1. 所有在 `registry.gitlab.com/gitlab-org/security-products/dast/webgoat-8.0@sha256` 容器镜像中发现的 CVE ID 为 `CVE-2018-4180` 的漏洞。
1. 所有在 `your.private.registry:5000/centos` 容器中发现的 CVE ID 为 `CVE-2015-1419`、`CVE-2015-1447` 的漏洞。

<a id="file-format"></a>

##### 文件格式

- `generalallowlist` 块允许你全局指定 CVE ID。所有具有匹配 CVE ID 的漏洞都将从扫描报告中排除。
- `images` 块允许你为每个容器镜像独立指定 CVE ID。来自给定镜像且具有匹配 CVE ID 的所有漏洞都将从扫描报告中排除。镜像名称从用于指定要扫描的 Docker 镜像的环境变量之一中检索，例如 `$CI_APPLICATION_REPOSITORY:$CI_APPLICATION_TAG` 或 `CS_IMAGE`。此块中提供的镜像**必须**匹配此值，并且**不得**包含标签值。例如，如果你使用 `CS_IMAGE=alpine:3.7` 指定要扫描的镜像，那么在 `images` 块中你会使用 `alpine`，但不能使用 `alpine:3.7`。

  你可以通过多种方式指定容器镜像：

  - 仅作为镜像名称（例如 `centos`）。
  - 作为带有注册表主机名的完整镜像名称（例如 `your.private.registry:5000/centos`）。
  - 作为带有注册表主机名和 sha256 标签的完整镜像名称（例如 `registry.gitlab.com/gitlab-org/security-products/dast/webgoat-8.0@sha256`）。

> [!note]
> CVE ID 后面的字符串（上一个示例中的 `cups` 和 `libxml2`）是可选的注释格式。它**不影响**漏洞的处理。你可以包含注释来描述漏洞。

<a id="container-scanning-job-log-format"></a>

##### 容器扫描作业日志格式

你可以通过查看 `container_scanning` 作业详情中由容器扫描分析器生成的日志，来验证扫描结果和 `vulnerability-allowlist.yml` 文件的正确性。

日志包含一个找到的漏洞列表，以表格形式呈现，例如：

```plaintext
+------------+-------------------------+------------------------+-----------------------+------------------------------------------------------------------------+
|   状态     |      CVE 严重性         |     软件包名称           |   软件包版本           |                            CVE 描述                                    |
+------------+-------------------------+------------------------+-----------------------+------------------------------------------------------------------------+
|  已批准    |   高 CVE-2019-3462      |          apt           |         1.4.8         | apt 版本 1.4.8 及更早版本中，HTTP 传输方法中对 302 重定向字段的消毒不  |
|            |                         |                        |                       | 正确，可能允许中间人攻击者注入内容，从而可能导致目标机器上的远程代码  |
|            |                         |                        |                       | 执行。                                                                 |
+------------+-------------------------+------------------------+-----------------------+------------------------------------------------------------------------+
|  未批准    |  中 CVE-2020-27350      |          apt           |         1.4.8         | APT 在解析 .deb 包时存在多个整数溢出和下溢，即 GHSL-2020-168 GHSL-2020- |
|            |                         |                        |                       | 169，位于文件 apt-pkg/contrib/extracttar.cc、apt-pkg/deb/debfile.cc 和 |
|            |                         |                        |                       | apt-pkg/contrib/arfile.cc 中。此问题影响：apt 1.2.32ubuntu0 版本（低于  |
|            |                         |                        |                       | 1.2.32ubuntu0.2）；1.6.12ubuntu0 版本（低于 1.6.12ubuntu0.2）；2.0.2ub |
|            |                         |                        |                       | untu0 版本（低于 2.0.2ubuntu0.2）；2.1.10ubuntu0 版本（低于 2.1.10ubunt |
|            |                         |                        |                       | u0.1）；                                                                 |
+------------+-------------------------+------------------------+-----------------------+------------------------------------------------------------------------+
|  未批准    |  中 CVE-2020-3810       |          apt           |         1.4.8         | APT 在 2.1.2 版本之前，在处理特制的 deb 文件时缺少输入验证，可能导致拒绝 |
|            |                         |                        |                       | 服务。                                                                  |
+------------+-------------------------+------------------------+-----------------------+------------------------------------------------------------------------+
```

当日志中的漏洞对应的 CVE ID 被添加到 `vulnerability-allowlist.yml` 文件时，该漏洞会标记为 `已批准`。

<a id="offline-environment"></a>

### 离线环境

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

要在[离线环境](../offline_deployments/_index.md)中运行容器扫描，你必须进行初始设置并执行持续维护。

初始设置：

- 配置 Runner（确保 `docker` 或 `kubernetes` 执行器可用）。
- 设置本地容器镜像仓库。有关详细信息，请参见[极狐GitLab 容器镜像仓库](../../packages/container_registry/_index.md)。
- 将镜像复制到本地容器镜像仓库。
- 为每个使用容器扫描的项目配置 CI/CD。
- 根据你的需求，你可以选择性地配置以下内容：
  - [扫描外部镜像仓库中的镜像](#scan-image-in-external-registry)。
  - [使用 Trivy Java 数据库镜像](#use-a-trivy-java-database-mirror)。

持续维护：

- 随着新版本的发布，更新本地容器扫描镜像。

<a id="configure-runner"></a>

#### 配置 Runner

配置 Runner（确保 `docker` 或 `kubernetes` 执行器可用）。有关详细信息，请参见[入门指南](#getting-started)。

默认情况下，Runner 会从极狐GitLab 容器镜像仓库拉取容器镜像，即使本地有副本。如果你更希望仅使用本地容器镜像，可以将 [`pull_policy` 设置为 `if-not-present`](https://gitlab.cn/docs/runner/executors/docker/#using-the-if-not-present-pull-policy)。但是，除非有充分理由，否则你应保持 `pull_policy` 设置为默认值。

<a id="copy-container-image"></a>

#### 复制容器镜像

将以下镜像从 JihuLab.com 容器镜像仓库导入到你的本地容器镜像仓库。这个镜像必须可以从你的离线极狐GitLab 实例访问。

```plaintext
registry.gitlab.com/security-products/container-scanning:8
```

将镜像导入本地容器镜像仓库的过程取决于你的网络安全策略。请咨询你的 IT 人员，以找到一种可接受且经批准的流程，通过该流程你可以导入或临时访问外部资源。

<a id="configure-cicd-for-each-project"></a>

#### 为每个项目配置 CI/CD

> [!note]
> 这些配置更改不适用于对镜像仓库的容器扫描，因为它不引用 `.gitlab-ci.yml` 文件。要在离线环境中配置对镜像仓库的自动容器扫描，改为[在极狐GitLab UI 中定义 `CS_ANALYZER_IMAGE` 变量](#use-with-offline-or-air-gapped-environments)。

对于所有使用容器扫描的项目，在应用 CI/CD 配置的所有位置进行编辑。这可能包括：

- 各个项目的 `.gitlab-ci.yml` 文件
- 流水线执行策略
- 扫描执行策略

使用以下变量更新你的容器扫描配置：

1. 可选。如果尚未包含容器扫描模板，请将其添加。
1. 将 `CS_ANALYZER_IMAGE` 设置为本地容器镜像仓库中的容器扫描镜像。
1. 可选。如果使用非极狐GitLab 容器镜像仓库，请设置 `CS_REGISTRY_USER` 和 `CS_REGISTRY_PASSWORD` 以匹配你的镜像仓库凭据。
1. 可选。如果为本地容器镜像仓库使用自签名证书，请设置 `CS_DOCKER_INSECURE: "true"`。

离线环境的 `.gitlab-ci.yml` 配置示例：

   ```yaml
   include:
     - template: Jobs/Container-Scanning.gitlab-ci.yml

   container_scanning:
     variables:
       # 容器扫描特定变量
       CS_ANALYZER_IMAGE: <hostname>:<port>/analyzers/container-scanning:8
       CS_REGISTRY_USER: <username>
       CS_REGISTRY_PASSWORD: <password>
       CS_DOCKER_INSECURE: "true"
   ```

<a id="update-local-container-image"></a>

#### 更新本地容器镜像

容器扫描镜像会[定期更新](../detect/vulnerability_scanner_maintenance.md)并推送到 JihuLab.com 镜像仓库。在离线环境中，你必须更新本地容器镜像仓库中的容器扫描镜像，可以是自动（推荐）或手动方式。

- 手动方法：如果无法通过网络访问 JihuLab.com 镜像仓库，请手动更新本地镜像仓库中的容器扫描镜像。使用与[初始设置的复制镜像](#copy-container-image)相同的方法。
- 自动方法：如果你的离线极狐GitLab 实例具有对 JihuLab.com 的读取访问权限，请设置一个计划的流水线，以按预设时间表自动更新镜像。

<a id="automatic-image-update-method"></a>

##### 自动镜像更新方法

以下 `.gitlab-ci.yml` 摘录演示了如何在本地镜像仓库中自动更新容器扫描镜像。此方法定义了源镜像和目标镜像的变量，然后使用 Docker CLI 从 JihuLab.com 镜像仓库拉取镜像，并将其推送到你的本地镜像仓库。

如果你使用的是非极狐GitLab 镜像仓库，请更新 `CI_REGISTRY` 值，并通过设置 `CI_REGISTRY_USER` 和 `CI_REGISTRY_PASSWORD` 变量来配置身份验证，以匹配你的本地镜像仓库凭据。

```yaml
variables:
  SOURCE_IMAGE: registry.gitlab.com/security-products/container-scanning:8
  TARGET_IMAGE: $CI_REGISTRY/namespace/container-scanning

image: docker:cli

update-scanner-image:
  services:
    - docker:dind
  script:
    - docker pull $SOURCE_IMAGE
    - docker tag $SOURCE_IMAGE $TARGET_IMAGE
    - echo "$CI_REGISTRY_PASSWORD" | docker login $CI_REGISTRY --username $CI_REGISTRY_USER --password-stdin
    - docker push $TARGET_IMAGE
```

<a id="scanning-archive-formats"></a>

## 扫描存档格式

{{< history >}}

- 在 GitLab 18.0 中引入了 tar 文件扫描功能。

{{< /history >}}

容器扫描支持存档格式（`.tar`、`.tar.gz`）的镜像。例如，可以使用 `docker save` 或 `docker buildx build` 创建此类镜像。

要扫描存档文件，请将环境变量 `CS_IMAGE` 设置为格式 `archive://path/to/archive`：

- `archive://` 方案前缀指定分析器要扫描存档文件。
- `path/to/archive` 指定要扫描的存档的路径，可以是绝对路径或相对路径。

容器扫描支持遵循 [Docker 镜像规范](https://github.com/moby/docker-image-spec) 的 tar 镜像文件。不支持 OCI 压缩包。有关支持格式的更多信息，请参阅 [Trivy tar 文件支持](https://trivy.dev/v0.48/docs/target/container_image/#tar-files)。

<a id="building-supported-tar-files"></a>

### 构建支持的 tar 文件

容器扫描使用 tar 文件中的元数据进行镜像命名。在构建 tar 镜像文件时，请确保镜像已打标签：

```shell
# 拉取或构建一个带有名称和标签的镜像
docker pull image:latest
# 或者
docker build . -t image:latest
# 然后使用 docker save 导出为 tar
docker save image:latest -o image-latest.tar

# 或使用 buildx build 构建一个带有标签的镜像
docker buildx create --name container --driver=docker-container
docker buildx build -t image:latest --builder=container -o type=docker,dest=- . > image-latest.tar

# 使用 podman
podman build -t image:latest .
podman save -o image-latest.tar image:latest
```

<a id="image-name"></a>

### 镜像名称

容器扫描通过首先评估存档的 `manifest.json` 并使用 `RepoTags` 中的第一个项目来确定镜像名称。如果未找到，则使用 `index.json` 来获取 `io.containerd.image.name` 注释。如果仍未找到，则使用存档文件名。

- `manifest.json` 在 [Docker 镜像规范 v1.1.0](https://github.com/moby/docker-image-spec/blob/v1.1.0/v1.1.md#combined-image-json--filesystem-changeset-format) 中定义，使用命令 `docker save` 创建。
- `index.json` 格式在 [OCI 镜像规范 v1.1.1](https://github.com/opencontainers/image-spec/blob/v1.1.1/spec.md) 中定义。`io.containerd.image.name` 在 containerd v1.3.0 及更高版本中[可用](https://github.com/containerd/containerd/blob/v1.3.0/images/annotations.go)，当使用 `ctr image export` 时。

<a id="scanning-archives-built-in-a-previous-job"></a>

### 扫描在先前作业中构建的存档

要扫描在 CI/CD 作业中构建的存档，你必须将存档工件从构建作业传递到容器扫描作业。使用 [`artifacts:paths`](../../../ci/yaml/_index.md#artifactspaths) 和 [`dependencies`](../../../ci/yaml/_index.md#dependencies) 关键字将一个作业的工件传递给后续作业：

```yaml
build_job:
  script:
    - docker build . -t image:latest
    - docker save image:latest -o image-latest.tar
  artifacts:
    paths:
      - "image-latest.tar"

container_scanning:
  variables:
    CS_IMAGE: "archive://image-latest.tar"
  dependencies:
    - build_job
```

<a id="scanning-archives-from-the-project-repository"></a>

### 从项目仓库扫描存档

要扫描在项目仓库中找到的存档，请确保你的 [Git 策略](../../../ci/runners/configure_runners.md#git-strategy) 能够访问你的仓库。在 `container_scanning` 作业中，将 `GIT_STRATEGY` 关键字设置为 `clone` 或 `fetch`，因为它默认设置为 `none`。

```yaml
container_scanning:
  variables:
    GIT_STRATEGY: fetch
```

<a id="running-the-standalone-container-scanning-tool"></a>

## 运行独立的容器扫描工具

可以在不依赖于 CI 作业上下文的情况下，针对 Docker 容器运行[极狐GitLab 容器扫描工具](https://gitlab.com/gitlab-org/security-products/analyzers/container-scanning)。要直接扫描镜像，请按照以下步骤操作：

1. 运行 Docker Desktop 或 Docker Machine。
1. 运行分析器的 Docker 镜像，在 `CI_APPLICATION_REPOSITORY` 和 `CI_APPLICATION_TAG` 变量中传递你要分析的镜像和标签：

   ```shell
   docker run \
     --interactive --rm \
     --volume "$PWD":/tmp/app \
     -e CI_PROJECT_DIR=/tmp/app \
     -e CI_APPLICATION_REPOSITORY=registry.gitlab.com/gitlab-org/security-products/dast/webgoat-8.0@sha256 \
     -e CI_APPLICATION_TAG=bc09fe2e0721dfaeee79364115aeedf2174cce0947b9ae5fe7c33312ee019a4e \
     registry.gitlab.com/security-products/container-scanning
   ```

结果存储在 `gl-container-scanning-report.json` 中。

<a id="reports-json-format"></a>

## 报告 JSON 格式

容器扫描工具会发出 JSON 报告，极狐GitLab Runner 通过 CI/CD 配置文件中的 `artifacts:reports` 关键字识别这些报告。

CI/CD 作业完成后，Runner 将这些报告上传到极狐GitLab，然后可以在 CI/CD 作业工件中找到它们。在极狐GitLab 旗舰版中，可以在相应的流水线和漏洞报告中查看这些报告。

这些报告必须符合[容器扫描报告模式](https://gitlab.com/gitlab-org/security-products/security-report-schemas/-/blob/master/dist/container-scanning-report-format.json)。

[容器扫描报告示例](https://gitlab.com/gitlab-examples/security/security-reports/-/blob/master/samples/container-scanning.json)。

<a id="cyclonedx-software-bill-of-materials"></a>

### CycloneDX 软件物料清单

除了 JSON 报告文件外，容器扫描工具还会为已扫描的镜像输出 [CycloneDX](https://cyclonedx.org/) 软件物料清单 (SBOM)。此 CycloneDX SBOM 名为 `gl-sbom-report.cdx.json`，并保存在与 `JSON 报告文件` 相同的目录中。仅在使用 Trivy 分析器时支持此功能。

可以在[依赖项列表](../dependency_list/_index.md)中查看此报告。

你可以[像其他作业工件一样下载 CycloneDX SBOM](../../../ci/jobs/job_artifacts.md#download-job-artifacts)。

<a id="license-information-in-cyclonedx-reports"></a>

#### CycloneDX 报告中的许可证信息

{{< history >}}

- 在 GitLab 18.0 中引入。

{{< /history >}}

容器扫描可以在 CycloneDX 报告中包含许可证信息。此功能默认禁用，以保持向后兼容性。

要在容器扫描结果中启用许可证扫描：

- 在你的 `.gitlab-ci.yml` 文件中设置 `CS_INCLUDE_LICENSES` 变量：

```yaml
container_scanning:
  variables:
    CS_INCLUDE_LICENSES: "true"
```

- 启用此功能后，生成的 CycloneDX 报告将包含容器镜像中检测到的组件的许可证信息。
- 你可以在依赖项列表页面或作为可下载的 CycloneDX 作业工件查看此许可证信息。

需要注意的是，仅支持 SPDX 许可证。但是，不符合 SPDX 的许可证仍会被收录，且不会向用户显示任何错误。

<a id="end-of-life-operating-system-detection"></a>

## 操作系统生命周期终止检测

容器扫描包括检测和报告容器镜像何时使用已达到生命周期终止 (EOL) 的操作系统的能力。已达到 EOL 的操作系统将不再接收安全更新，使其容易受到新发现的安全问题的影响。

EOL 检测功能使用 Trivy 来识别不再受其各自发行版支持的操作系统。当检测到 EOL 操作系统时，它会作为漏洞与其他安全发现一起在你的容器扫描报告中报告。

要启用 EOL 检测，请将 `CS_REPORT_OS_EOL` 设置为 `"true"`。

<a id="container-scanning-for-registry"></a>

## 对镜像仓库的容器扫描

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在 GitLab 17.1 中引入，带有功能标志 `enable_container_scanning_for_registry`。默认禁用。
- 在 GitLab 17.2 中为私有化部署启用。
- 在 GitLab 17.2 中 GA。移除了功能标志 `enable_container_scanning_for_registry`。

{{< /history >}}

当使用 `latest` 标签推送容器镜像时，安全策略机器人会在针对默认分支的新流水线中自动触发容器扫描作业。

与常规容器扫描不同，扫描结果不包含安全报告。取而代之的是，对镜像仓库的容器扫描依赖于[持续漏洞扫描](../continuous_vulnerability_scanning/_index.md)来检查扫描检测到的组件。

当识别出安全发现时，极狐GitLab 会使用这些发现填充漏洞报告。漏洞可以在漏洞报告页面的 **容器镜像仓库漏洞** 选项卡下查看。

对镜像仓库的容器扫描仅在向[极狐GitLab 咨询数据库](../gitlab_advisory_database/_index.md)发布新咨询时填充漏洞报告。支持用所有现有咨询数据（而非仅新检测到的数据）填充漏洞报告的功能已在史诗 11219 中提出。

> [!warning]
> 对镜像仓库的容器扫描检测到的漏洞，在你更新或删除易受攻击的组件时，无法自动标记为已解决。这些漏洞将无限期保持可见，因为此功能仅生成 SBOM，而不生成漏洞解决所需的安全报告。

<a id="turn-on-container-scanning-for-registry"></a>

### 开启对镜像仓库的容器扫描

先决条件：

- 项目的安全管理员、维护者或所有者角色。
- 项目不能为空。如果你使用空项目仅用于存储容器镜像，此功能将无法按预期工作。作为一种解决方法，请确保项目在默认分支上包含一个初始提交。
- 默认情况下，每个项目每天限制 50 次扫描。
- 你必须[配置容器镜像仓库通知](../../../administration/packages/container_registry.md#configure-container-registry-notifications)。
- 你必须[配置软件包元数据数据库](../../../administration/settings/security_and_compliance.md#choose-package-registry-metadata-to-sync)。在 JihuLab.com 上，默认已配置。

要开启对极狐GitLab 容器镜像仓库的容器扫描：

1. 在顶部栏中，选择 **搜索或跳转到** 并查找你的项目。
1. 在左侧边栏中，选择 **安全** > **安全配置**。
1. 向下滚动到 **Container Scanning For Registry** 部分，然后打开开关。

<a id="use-with-offline-or-air-gapped-environments"></a>

### 在离线或气隙环境中使用

要在离线或气隙环境中使用对镜像仓库的容器扫描，你必须使用本地副本的容器扫描分析器镜像。由于此功能由极狐GitLab 安全策略机器人管理，因此无法通过编辑 `.gitlab-ci.yml` 文件来配置分析器镜像。

相反，你必须通过在极狐GitLab UI 中设置 `CS_ANALYZER_IMAGE` CI/CD 变量来覆盖默认的扫描器镜像。动态创建的扫描作业会继承在 UI 中定义的变量。你可以使用项目、群组或实例 CI/CD 变量。

先决条件：

- 项目或群组的维护者或所有者角色。

要配置自定义扫描器镜像：

1. 在顶部栏中，选择 **搜索或跳转到** 并查找你的项目或群组。
1. 在左侧边栏中，选择 **设置** > **CI/CD**。
1. 展开 **变量** 部分。
1. 选择 **添加变量** 并填写详细信息：
   - 键：`CS_ANALYZER_IMAGE`
   - 值：指向你镜像的容器扫描镜像的完整 URL。例如，`my.local.registry:5000/analyzers/container-scanning:7`。
1. 选择 **添加变量**。

极狐GitLab 安全策略机器人触发扫描时将使用指定的镜像。

<a id="vulnerabilities-database"></a>

## 漏洞数据库

所有分析器镜像[每天更新](https://gitlab.com/gitlab-org/security-products/analyzers/container-scanning/-/blob/master/README.md#image-updates)。

这些镜像使用来自上游咨询数据库的数据：

- AlmaLinux 安全公告
- Amazon Linux 安全中心
- Arch Linux 安全跟踪器
- SUSE CVRF
- CWE 公告
- Debian 安全缺陷跟踪器
- GitHub 安全公告
- Go 漏洞数据库
- CBL-Mariner 漏洞数据
- NVD
- OSV
- Red Hat OVAL v2
- Red Hat 安全数据 API
- Photon 安全公告
- Rocky Linux 更新信息
- Ubuntu CVE 跟踪器（仅限 2021 年中及以后的数据源）


除了这些扫描器提供的源数据外，极狐GitLab 还维护了以下漏洞数据库：

- 专有的[极狐GitLab 公告数据库](https://jihulab.com/gitlab-cn/security-products/gemnasium-db)。
- 开源的[极狐GitLab 公告数据库（开源版）](https://jihulab.com/gitlab-cn/advisories-community)。

在极狐GitLab 旗舰版中，极狐GitLab 公告数据库的数据会合并进来，以增强外部源数据。在极狐GitLab 专业版和基础版中，极狐GitLab 公告数据库（开源版）的数据会合并进来以增强外部源数据。这种增强仅适用于 Trivy 扫描器的分析器镜像。

其他分析器的数据库更新信息请参考[维护表](../detect/vulnerability_scanner_maintenance.md)。

<a id="solutions-for-vulnerabilities-auto-remediation"></a>

## 漏洞解决方案（自动修复）

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

部分漏洞可以通过应用极狐GitLab 自动生成的解决方案来修复。

要启用修复支持，扫描工具必须能够访问由 CI/CD 变量 `CS_DOCKERFILE_PATH` 指定的 `Dockerfile`。为确保扫描工具能够访问该文件，你需要按照本文档[覆盖容器扫描模板](#overriding-the-container-scanning-template)部分中的说明，在 `.gitlab-ci.yml` 文件中设置 [`GIT_STRATEGY: fetch`](../../../ci/runners/configure_runners.md#git-strategy)。

阅读更多关于[漏洞解决方案](../vulnerabilities/_index.md#resolve-a-vulnerability)的内容。