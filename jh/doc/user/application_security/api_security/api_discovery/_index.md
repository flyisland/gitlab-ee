---
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: API Discovery
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 15.9 中引入。API Discovery 功能处于[测试版](../../../../policy/development_stages_support.md)。

{{< /history >}}

API Discovery 分析您的应用程序并生成描述其公开的 Web API 的 OpenAPI 文档。此 schema 文档随后可供 [API 安全测试分析器](../../api_security_testing/_index.md) 或 [API 模糊测试](../../api_fuzzing/_index.md) 使用，以对 Web API 执行安全扫描。

<a id="supported-frameworks"></a>

## 支持的框架

- [Java Spring-Boot](#java-spring-boot)

<a id="when-does-api-discovery-run"></a>

## API Discovery 何时运行？

API Discovery 作为流水线中的独立作业运行。生成的 OpenAPI 文档被捕获为作业产物，以便在后续阶段被其他作业使用。

API Discovery 默认在 `test` 阶段运行。选择 `test` 阶段是因为它通常在 API 安全测试和 API 模糊测试等其他安全功能所使用的阶段之前执行。

<a id="example-api-discovery-configurations"></a>

## API Discovery 配置示例

以下项目演示了 API Discovery：

- [Example Java Spring Boot v2 Pet Store](https://jihulab.com/gitlab-cn/security-products/demos/api-discovery/java-spring-boot-v2-petstore)

<a id="java-spring-boot"></a>

## Java Spring-Boot

[Spring Boot](https://spring.io/projects/spring-boot/) 是一个流行的框架，用于创建独立的、生产级的基于 Spring 的应用程序。

<a id="supported-applications"></a>

### 支持的应用程序

- Spring Boot：v2.X（>= 2.1）
- Java：11、17（LTS 版本）
- 可执行 JAR

API Discovery 支持 Spring Boot 主版本 2，次版本 1 及更高版本。由于已知的错误会影响 API Discovery 并在 2.1 中修复，因此不支持 2.0.X 版本。

未来计划支持主版本 3。不计划支持主版本 1。

API Discovery 经过测试并正式支持 Java 运行时的 LTS 版本。其他版本也可能工作，欢迎来自非 LTS 版本的错误报告。

仅支持构建为 Spring Boot [可执行 JAR](https://docs.spring.io/spring-boot/redirect.html?page=executable-jar#appendix.executable-jar.nested-jars.jar-structure) 的应用程序。

<a id="configure-as-pipeline-job"></a>

### 配置为流水线作业

运行 API Discovery 的最简单方法是通过基于我们 CI 模板的流水线作业。使用此方法运行时，您需要提供一个安装了所需依赖项（例如适当的 Java 运行时）的容器镜像。有关更多信息，请参阅[镜像要求](#image-requirements)。

1. 将满足[镜像要求](#image-requirements)的容器镜像上传到容器镜像仓库。如果容器镜像仓库需要身份验证，请参阅[此帮助部分](../../../../ci/docker/using_docker_images.md#access-an-image-from-a-private-container-registry)。
1. 在 `build` 阶段的作业中，构建您的应用程序并将生成的 Spring Boot 可执行 JAR 配置为作业产物。
1. 在您的 `.gitlab-ci.yml` 文件中包含 API Discovery 模板。

   ```yaml
   include:
      - template: Security/API-Discovery.gitlab-ci.yml
   ```

   每个 `.gitlab-ci.yml` 文件只允许一个 `include` 语句。如果您包含其他文件，请将它们合并到一个 `include` 语句中。

   ```yaml
   include:
      - template: Security/API-Discovery.gitlab-ci.yml
      - template: Security/DAST-API.gitlab-ci.yml
   ```

1. 创建一个从 `.api_discovery_java_spring_boot` 扩展的新作业。默认阶段是 `test`，可以选择更改为任何值。

   ```yaml
   api_discovery:
       extends: .api_discovery_java_spring_boot
   ```

1. 为作业配置 `image`。

   ```yaml
   api_discovery:
       extends: .api_discovery_java_spring_boot
       image: eclipse-temurin:17-jre-alpine
   ```

1. 提供应用程序所需的 Java 类路径。这包括来自步骤 2 的兼容构建产物以及任何其他依赖项。在此示例中，构建产物是 `build/libs/spring-boot-app-0.0.0.jar` 并包含所有需要的依赖项。变量 `API_DISCOVERY_JAVA_CLASSPATH` 用于提供类路径。

   ```yaml
   api_discovery:
       extends: .api_discovery_java_spring_boot
       image: eclipse-temurin:17-jre-alpine
       variables:
           API_DISCOVERY_JAVA_CLASSPATH: build/libs/spring-boot-app-0.0.0.jar
   ```

1. 可选。如果提供的镜像缺少 API Discovery 所需的依赖项，可以使用 `before_script` 添加。在此示例中，`eclipse-temurin:17-jre-alpine` 容器不包含 API Discovery 所需的 `curl`。可以使用 Debian 软件包管理器 `apt` 安装依赖项：

   ```yaml
   api_discovery:
       extends: .api_discovery_java_spring_boot
       image: eclipse-temurin:17-jre-alpine
       variables:
           API_DISCOVERY_JAVA_CLASSPATH: build/libs/spring-boot-app-0.0.0.jar
       before_script:
           - apk add --no-cache curl
   ```

1. 可选。如果提供的镜像未自动设置 `JAVA_HOME` 环境变量，或未在路径中包含 `java`，则可以使用 `API_DISCOVERY_JAVA_HOME` 变量。

   ```yaml
   api_discovery:
       extends: .api_discovery_java_spring_boot
       image: eclipse-temurin:17-jre-alpine
       variables:
           API_DISCOVERY_JAVA_CLASSPATH: build/libs/spring-boot-app-0.0.0.jar
           API_DISCOVERY_JAVA_HOME: /opt/java
   ```

1. 可选。如果 `API_DISCOVERY_PACKAGES` 处的软件包仓库不是公开的，请使用 `API_DISCOVERY_PACKAGE_TOKEN` 变量提供一个具有极狐GitLab API 和镜像仓库读取权限的令牌。如果您使用的是 `gitlab.com` 且未自定义 `API_DISCOVERY_PACKAGES` 变量，则不需要此操作。以下示例使用名为 `GITLAB_READ_TOKEN` 的[自定义 CI/CD 变量](../../../../ci/variables/_index.md#define-a-cicd-variable-in-the-ui)来存储令牌。

   ```yaml
   api_discovery:
       extends: .api_discovery_java_spring_boot
       image: eclipse-temurin:17-jre-alpine
       variables:
           API_DISCOVERY_JAVA_CLASSPATH: build/libs/spring-boot-app-0.0.0.jar
           API_DISCOVERY_PACKAGE_TOKEN: $GITLAB_READ_TOKEN
   ```

API Discovery 作业成功运行后，OpenAPI 文档将作为名为 `gl-api-discovery-openapi.json` 的作业产物提供。

<a id="image-requirements"></a>

#### 镜像要求

- Linux 容器镜像。
- 正式支持 Java 11 或 17 版本，但其他版本也可能兼容。
- `curl` 命令。
- `/bin/sh` 处的 shell（如 `busybox`、`sh` 或 `bash`）。

<a id="available-cicd-variables"></a>

### 可用的 CI/CD 变量

| CI/CD 变量                              | 描述        |
|---------------------------------------------|--------------------|
| `API_DISCOVERY_DISABLED`                    | 使用模板作业规则时禁用 API Discovery 作业。 |
| `API_DISCOVERY_DISABLED_FOR_DEFAULT_BRANCH` | 使用模板作业规则时，为默认分支流水线禁用 API Discovery 作业。 |
| `API_DISCOVERY_JAVA_CLASSPATH`              | 包含目标 Spring Boot 应用程序的 Java 类路径。（`build/libs/sample-0.0.0.jar`） |
| `API_DISCOVERY_JAVA_HOME`                   | 如果提供，用于设置 `JAVA_HOME`。 |
| `API_DISCOVERY_PACKAGES`                    | 极狐GitLab 项目软件包 API 前缀（默认为 `$CI_API_V4_URL/projects/42503323/packages`）。 |
| `API_DISCOVERY_PACKAGE_TOKEN`               | 用于调用极狐GitLab 软件包 API 的极狐GitLab 令牌。仅当 `API_DISCOVERY_PACKAGES` 设置为非公开项目时才需要。 |
| `API_DISCOVERY_VERSION`                     | 要使用的 API Discovery 版本（默认为 `1`）。可用于通过提供完整版本号 `1.1.0` 来固定版本。 |

<a id="get-support-or-request-an-improvement"></a>

## 获取支持或请求改进

要获取针对您特定问题的支持，请使用[获取帮助渠道](https://gitlab.cn/get-help/)。

[JihuLab.com 上的极狐GitLab 议题跟踪器](https://jihulab.com/gitlab-cn/gitlab/-/issues)是报告有关 API Discovery 的错误和功能提案的正确位置。在创建关于 API Discovery 的新议题时，请使用 `~"Category:API Security"` 标签，以确保合适的人员能够快速审阅。

在提交您自己的内容之前，请[搜索议题跟踪器](https://jihulab.com/gitlab-cn/gitlab/-/issues)中类似的条目，很有可能其他人也有相同的问题或功能提案。用表情符号反应表示您的支持或加入讨论。

当遇到行为不符合预期的情况时，请考虑提供上下文信息：

- 如果使用私有化部署实例，请提供极狐GitLab 版本。
- `.gitlab-ci.yml` 作业定义。
- 完整的作业控制台输出。
- 使用的框架及其版本（例如“Spring Boot v2.3.2”）。
- 语言运行时及其版本（例如“Eclipse Temurin v17.0.1”）。

<!-- - 扫描器日志文件作为名为 `gl-api-discovery.log` 的作业产物提供。 -->

> [!warning]
> **清理附加到支持议题的数据**。删除敏感信息，包括：凭据、密码、令牌、密钥和密钥。