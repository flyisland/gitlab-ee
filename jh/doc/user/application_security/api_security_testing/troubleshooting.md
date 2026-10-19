---
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 故障排除 API 安全测试作业
---

<a id="api-security-testing-job-times-out-after-n-hours"></a>

## API 安全测试作业在 N 小时后超时

对于较大的代码仓库，API 安全测试作业可能会在默认设置的 [Linux 小型托管 Runner](../../../ci/runners/hosted_runners/linux.md#machine-types-available-for-linux---x86-64) 上超时。如果您的作业遇到此情况，应升级到[更大的 Runner](performance.md#using-a-larger-runner)。

请参阅以下文档章节寻求帮助：

- [性能调优和测试速度](performance.md)
- [使用更大的 Runner](performance.md#using-a-larger-runner)
- [按路径排除操作](configuration/customizing_analyzer_settings.md#exclude-paths)
- [排除慢速操作](performance.md#excluding-slow-operations)

<a id="api-security-testing-job-takes-too-long-to-complete"></a>

## API 安全测试作业耗时过长

请参阅[性能调优和测试速度](performance.md)

<a id="error-error-waiting-for-dast-api-http1270015000-to-become-available"></a>

## 错误：`Error waiting for DAST API 'http://127.0.0.1:5000' to become available`

v1.6.196 之前的 API 安全测试分析器版本存在一个缺陷，可能导致后台进程在特定条件下失败。解决方案是更新到更新版本的 API 安全测试分析器。

版本信息可在 `dast_api` 作业的作业详情中找到。

如果问题发生在 v1.6.196 或更高版本，请联系支持并提供以下信息：

1. 引用此故障排除章节，并请求将问题升级给动态分析团队。
1. 作业的完整控制台输出。
1. 作为作业产物提供的 `gl-api-security-scanner.log` 文件。在作业详情页面的右侧面板中，选择 **浏览**。
1. 来自您的 `.gitlab-ci.yml` 文件的 `dast_api` 作业定义。

<a id="failed-to-start-scanner-session-version-header-not-found"></a>

## `Failed to start scanner session (version header not found)`

当 API 安全测试引擎无法与扫描器应用程序组件建立连接时，会输出错误消息。该错误消息显示在 `dast_api` 作业的作业输出窗口中。此问题的一个常见原因是更改了 `APISEC_API` 变量的默认值。

**错误消息**

- `Failed to start scanner session (version header not found).`

**解决方案**

- 从 `.gitlab-ci.yml` 文件中移除 `APISEC_API` 变量。该值继承自 API 安全测试 CI/CD 模板。请使用此方法，而不是手动设置值。
- 如果无法移除该变量，请检查此值在最新版本的 [API 安全测试 CI/CD 模板](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Security/API-Security.gitlab-ci.yml) 中是否已更改。如果已更改，请更新 `.gitlab-ci.yml` 文件中的值。

<a id="failed-to-start-session-with-scanner-please-retry-and-if-the-problem-persists-reach-out-to-support"></a>

## `Failed to start session with scanner. Please retry, and if the problem persists reach out to support.`

当 API 安全测试引擎无法与扫描器应用程序组件建立连接时，会输出错误消息。该错误消息显示在 `dast_api` 作业的作业输出窗口中。此问题的一个常见原因是后台组件无法使用所选端口，因为该端口已被占用。如果时序因素起作用（竞态条件），此错误可能会间歇性出现。此问题在 Kubernetes 环境中最为常见，因为其他服务映射到容器中会导致端口冲突。

在继续解决方案之前，务必确认错误消息是由于端口已被占用而产生的。要确认这是原因：

1. 转到作业控制台。
1. 查找产物 `gl-api-security-scanner.log`。您可以通过选择 **下载** 下载所有产物然后搜索该文件，或直接选择 **浏览** 开始搜索。
1. 在文本编辑器中打开文件 `gl-api-security-scanner.log`。
1. 如果错误消息是由于端口已被占用而产生的，您应该在文件中看到类似以下的消息：

   ```log
   Failed to bind to address http://127.0.0.1:5500: address already in use.
   ```

上一条消息中的文本 `http://[::]:5000` 在您的情况下可能不同，例如可能是 `http://[::]:5500` 或 `http://127.0.0.1:5500`。只要错误消息的其余部分相同，就可以安全地假设端口已被占用。

如果您没有找到端口已被占用的证据，请检查同样处理作业控制台输出中显示的错误消息的其他故障排除章节。如果没有更多选项，请随时通过适当的渠道[获取支持或请求改进](_index.md#get-support-or-request-an-improvement)。

如果您能确认问题是由于端口已被占用而发生的，请使用 CI/CD 变量 `APISEC_API_PORT` 为扫描器后台组件指定不同的端口。

**解决方案**

1. 确保您的 `.gitlab-ci.yml` 文件定义了配置变量 `APISEC_API_PORT`。
1. 将 `APISEC_API_PORT` 的值更新为任何大于 1024 的可用端口号。您应检查建议的端口号未被极狐GitLab 使用。请参阅 [软件包默认值](../../../administration/package_information/defaults.md#ports) 中极狐GitLab 使用的完整端口列表。

<a id="application-cannot-determine-the-base-url-for-the-target-api"></a>

## `Application cannot determine the base URL for the target API`

当 API 安全测试引擎在检查 OpenAPI 文档后无法确定目标 API 时，会输出错误消息。当目标 API 未在 `.gitlab-ci.yml` 文件中设置、在 `environment_url.txt` 文件中不可用，且无法使用 OpenAPI 文档计算时，会显示此错误消息。

API 安全测试引擎在检查不同来源时，尝试获取目标 API 存在优先级顺序。首先，它尝试使用 `APISEC_TARGET_URL`。如果未设置环境变量，则 API 安全测试引擎尝试使用 `environment_url.txt` 文件。如果没有 `environment_url.txt` 文件，则 API 安全测试引擎使用 OpenAPI 文档内容和 `APISEC_OPENAPI` 中提供的 URL（如果提供了 URL）来尝试计算目标 API。

最合适的解决方案取决于您的目标 API 是否因每次部署而变化。在静态环境中，目标 API 在每次部署中都是相同的。在这种情况下，请参阅[静态环境解决方案](#static-environment-solution)。如果目标 API 因每次部署而变化，则应应用[动态环境解决方案](#dynamic-environment-solutions)。

<a id="api-security-testing-job-excludes-some-paths-from-operations"></a>

## API 安全测试作业从操作中排除某些路径

如果您发现某些路径被排除在操作之外，请确保：

- 变量 `APISEC_EXCLUDE_URLS` 未配置为排除您要测试的操作。
- `consumes` 数组已定义，并在目标定义 JSON 文件中具有有效类型。

  有关示例定义，请参阅[示例项目目标定义文件](https://gitlab.com/gitlab-org/security-products/demos/api-dast/openapi-example/-/blob/12e2b039d08208f1dd38a1e7c52b0bda848bb449/rest_target_openapi.json?plain=1#L13)。

<a id="static-environment-solution"></a>

### 静态环境解决方案

此解决方案适用于目标 API URL 不变的流水线（即静态的）。

**添加环境变量**

对于目标 API 保持不变的场景，请使用 `APISEC_TARGET_URL` 环境变量指定目标 URL。在您的 `.gitlab-ci.yml` 中，添加变量 `APISEC_TARGET_URL`。该变量必须设置为 API 测试目标的基础 URL。例如：

```yaml
stages:
  - dast

include:
  - template: API-Security.gitlab-ci.yml

variables:
  APISEC_TARGET_URL: http://test-deployment/
  APISEC_OPENAPI: test-api-specification.json
```

<a id="dynamic-environment-solutions"></a>

### 动态环境解决方案

在动态环境中，您的目标 API 因每次不同的部署而变化。在这种情况下，有不止一种可能的解决方案：在处理动态环境时使用 `environment_url.txt` 文件。

**使用 `environment_url.txt`**

为支持目标 API URL 在每次流水线中变化的动态环境，API 安全测试引擎支持使用包含要使用的 URL 的 `environment_url.txt` 文件。此文件不检入代码仓库，而是在流水线期间由部署测试目标的作业创建，并作为产物收集，供后续流水线中的作业使用。创建 `environment_url.txt` 文件的作业必须在 API 安全测试引擎作业之前运行。

1. 修改测试目标部署作业，在项目根目录的 `environment_url.txt` 文件中添加基础 URL。
1. 修改测试目标部署作业，将 `environment_url.txt` 作为产物收集。

示例：

```yaml
deploy-test-target:
  script:
    # Perform deployment steps
    # Create environment_url.txt (example)
    - echo http://${CI_PROJECT_ID}-${CI_ENVIRONMENT_SLUG}.example.org > environment_url.txt

  artifacts:
    paths:
      - environment_url.txt
```

<a id="use-openapi-with-an-invalid-schema"></a>

## 使用具有无效模式的 OpenAPI

自动生成的 OpenAPI 文档有时会带有无效模式，或者无法及时手动编辑。在这些情况下，API 安全测试可以通过设置变量 `APISEC_OPENAPI_RELAXED_VALIDATION` 来执行宽松验证。提供完全符合规范的 OpenAPI 文档以防止意外行为。

<a id="edit-a-non-compliant-openapi-file"></a>

### 编辑不符合规范的 OpenAPI 文件

使用编辑器检测并纠正不符合 OpenAPI 规范的元素。编辑器通常提供文档验证和创建符合模式的 OpenAPI 文档的建议。建议的编辑器包括：

| 编辑器                                             | OpenAPI 2.0            | OpenAPI 3.0.x          | OpenAPI 3.1.x |
|----------------------------------------------------|------------------------|------------------------|---------------|
| [Stoplight Studio](https://stoplight.io/solutions) | {{< yes >}} YAML、JSON | {{< yes >}} YAML、JSON | {{< yes >}} YAML、JSON |
| [Swagger Editor](https://editor.swagger.io/)       | {{< yes >}} YAML、JSON | {{< yes >}} YAML、JSON | {{< no >}} YAML、JSON |

如果您的 OpenAPI 文档是手动生成的，请在编辑器中加载您的文档并修复任何不符合规范的内容。如果您的文档是自动生成的，请在编辑器中加载它以识别模式中的问题。然后根据您使用的框架在应用程序中纠正这些问题。

<a id="enable-openapi-relaxed-validation"></a>

### 启用 OpenAPI 宽松验证

宽松验证适用于 OpenAPI 文档无法满足 OpenAPI 规范，但仍包含足够内容可供不同工具使用的情况。会执行验证，但对文档模式的验证不那么严格。

API 安全测试仍然可以尝试使用不完全符合 OpenAPI 规范的 OpenAPI 文档。要指示 API 安全测试执行宽松验证，请将变量 `APISEC_OPENAPI_RELAXED_VALIDATION` 设置为任意值，例如：

```yaml
stages:
  - dast

include:
  - template: API-Security.gitlab-ci.yml

variables:
  APISEC_PROFILE: Quick
  APISEC_TARGET_URL: http://test-deployment/
  APISEC_OPENAPI: test-api-specification.json
  APISEC_OPENAPI_RELAXED_VALIDATION: 'On'
```

<a id="no-operation-in-the-openapi-document-is-consuming-any-supported-media-type"></a>

## `No operation in the OpenAPI document is consuming any supported media type`

API 安全测试使用 OpenAPI 文档中指定的媒体类型来生成请求。如果由于缺少受支持的媒体类型而无法创建任何请求，则会抛出错误。

**错误消息**

- `Error, no operation in the OpenApi document is consuming any supported media type. Check 'OpenAPI Specification' to check the supported media types.`

**解决方案**

1. 查看 [OpenAPI 规范](configuration/enabling_the_analyzer.md#openapi-specification) 章节中受支持的媒体类型。
1. 编辑您的 OpenAPI 文档，至少允许给定的操作接受任何受支持的媒体类型。或者，可以在 OpenAPI 文档级别设置受支持的媒体类型，并将其应用于所有操作。此步骤可能需要更改您的应用程序，以确保应用程序接受受支持的媒体类型。

<a id="error-the-ssl-connection-could-not-be-established-see-inner-exception"></a>

## 错误：`The SSL connection could not be established, see inner exception.`

API 安全测试兼容广泛的 TLS 配置，包括过时的协议和密码套件。尽管支持广泛，您仍可能遇到连接错误，例如：

```plaintext
Error, error occurred trying to download `<URL>`:
There was an error when retrieving content from Uri:' <URL>'.
Error:The SSL connection could not be established, see inner exception.
```

发生此错误是因为 API 安全测试无法与给定 URL 处的服务器建立安全连接。

要解决此问题：

如果错误消息中的主机支持非 TLS 连接，请在您的配置中将 `https://` 更改为 `http://`。例如，如果使用以下配置发生错误：

```yaml
stages:
  - dast

include:
  - template: API-Security.gitlab-ci.yml

variables:
  APISEC_TARGET_URL: https://test-deployment/
  APISEC_OPENAPI: https://specs/openapi.json
```

将 `APISEC_OPENAPI` 的前缀从 `https://` 更改为 `http://`：

```yaml
stages:
  - dast

include:
  - template: API-Security.gitlab-ci.yml

variables:
  APISEC_TARGET_URL: https://test-deployment/
  APISEC_OPENAPI: http://specs/openapi.json
```

如果您无法使用非 TLS 连接访问该 URL，请联系支持团队寻求帮助。

您可以使用 [testssl.sh 工具](https://testssl.sh/) 加快调查。从具有 bash shell 且能连接到受影响服务器的机器上：

1. 下载最新版本的 `zip` 或 `tar.gz` 文件，并从 <https://github.com/testssl/testssl.sh/releases> 解压。
1. 运行 `./testssl.sh --log https://specs`。
1. 将日志文件附加到您的支持工单中。

<a id="error-job-failed-failed-to-pull-image"></a>

## `ERROR: Job failed: failed to pull image`

当从需要身份验证才能访问（非公开）的容器镜像仓库拉取镜像时，会出现此错误消息。

在作业控制台输出中，错误如下所示：

```plaintext
Running with gitlab-runner 15.6.0~beta.186.ga889181a (a889181a)
  on blue-2.shared.runners-manager.gitlab.com/default XxUrkriX
Resolving secrets
00:00
Preparing the "docker+machine" executor
00:06
Using Docker executor with image registry.gitlab.com/security-products/api-security:2 ...
Starting service registry.example.com/my-target-app:latest ...
Pulling docker image registry.example.com/my-target-app:latest ...
WARNING: Failed to pull image with policy "always": Error response from daemon: Get https://registry.example.com/my-target-app/manifests/latest: unauthorized (manager.go:237:0s)
ERROR: Job failed: failed to pull image "registry.example.com/my-target-app:latest" with specified policies [always]: Error response from daemon: Get https://registry.example.com/my-target-app/manifests/latest: unauthorized (manager.go:237:0s)
```

**解决方案**

使用[从私有容器镜像仓库访问镜像](../../../ci/docker/using_docker_images.md#access-an-image-from-a-private-container-registry)文档章节中概述的方法提供身份验证凭据。使用的方法由您的容器镜像仓库提供商及其配置决定。如果您使用的是第三方提供的容器镜像仓库，例如云提供商（Azure、Google Cloud (GCP)、AWS 等），请查看提供商的文档，了解如何向其容器镜像仓库进行身份验证。

以下示例使用[静态定义的凭据](../../../ci/docker/using_docker_images.md#use-statically-defined-credentials)身份验证方法。在此示例中，容器镜像仓库是 `registry.example.com`，镜像是 `my-target-app:latest`。

1. 阅读如何[确定您的 `DOCKER_AUTH_CONFIG` 数据](../../../ci/docker/using_docker_images.md#determine-your-docker_auth_config-data)以了解如何计算 `DOCKER_AUTH_CONFIG` 的变量值。配置变量 `DOCKER_AUTH_CONFIG` 包含用于提供适当身份验证信息的 Docker JSON 配置。例如，要使用凭据 `abcdefghijklmn` 访问私有容器镜像仓库 `registry.example.com`，Docker JSON 如下所示：

   ```json
   {
       "auths": {
           "registry.example.com": {
               "auth": "abcdefghijklmn"
           }
       }
   }
   ```

1. 将 `DOCKER_AUTH_CONFIG` 添加为 CI/CD 变量。您不应直接将配置变量添加到 `.gitlab-ci.yml` 文件中，而应创建项目 [CI/CD 变量](../../../ci/variables/_index.md#for-a-project)。
1. 重新运行您的作业，静态定义的凭据现在将用于登录私有容器镜像仓库 `registry.example.com`，并允许您拉取镜像 `my-target-app:latest`。如果成功，作业控制台将显示类似以下的输出：

   ```log
   Running with gitlab-runner 15.6.0~beta.186.ga889181a (a889181a)
     on blue-4.shared.runners-manager.gitlab.com/default J2nyww-s
   Resolving secrets
   00:00
   Preparing the "docker+machine" executor
   00:56
   Using Docker executor with image registry.gitlab.com/security-products/api-security:2 ...
   Starting service registry.example.com/my-target-app:latest ...
   Authenticating with credentials from $DOCKER_AUTH_CONFIG
   Pulling docker image registry.example.com/my-target-app:latest ...
   Using docker image sha256:139c39668e5e4417f7d0eb0eeb74145ba862f4f3c24f7c6594ecb2f82dc4ad06 for registry.example.com/my-target-app:latest with digest registry.example.com/my-target-
   app@sha256:2b69fc7c3627dbd0ebaa17674c264fcd2f2ba21ed9552a472acf8b065d39039c ...
   Waiting for services to be up and running (timeout 30 seconds)...
   ```

<a id="differing-vulnerability-results-between-consecutive-scans"></a>

## 连续扫描之间的漏洞结果不同

在没有代码或配置更改的情况下，连续扫描可能会返回不同的漏洞发现。这主要是由于目标环境及其状态相关的不可预测性，以及扫描器发送请求的并行化。扫描器并行发送多个请求以优化扫描时间，这意味着目标服务器响应请求的确切顺序不是预先确定的。

通过请求和响应之间的时间长度检测的时序攻击漏洞，例如 OS 命令或 SQL 注入，如果服务器处于负载状态且无法在给定阈值内响应测试，则可能会被检测到。当服务器不处于负载状态时，相同的扫描执行可能不会返回这些漏洞的阳性发现，从而导致结果不同。分析目标服务器、[性能调优和测试速度](performance.md)以及在测试期间为最佳服务器性能建立基线，可能有助于识别因上述因素而可能出现误报的位置。

<a id="error-sudo-the-no-new-privileges-flag-is-set-which-prevents-sudo-from-running-as-root"></a>

## 错误：`sudo: The "no new privileges" flag is set, which prevents sudo from running as root.`

从分析器的 v5 版本开始，默认使用非 root 用户。这要求在执行特权操作时使用 `sudo`。

当特定的容器守护进程设置阻止运行中的容器获得新权限时，会出现此错误。在大多数设置中，这不是默认配置。这是专门配置的，通常是安全加固指南的一部分。

**错误消息**

可以通过执行 `before_script` 或 `APISEC_PRE_SCRIPT` 时生成的错误消息来识别此问题：

```shell
$ sudo apk add nodejs

sudo: The "no new privileges" flag is set, which prevents sudo from running as root.

sudo: If sudo is running in a container, you may need to adjust the container configuration to disable the flag.
```

**解决方案**

可以通过以下方式变通解决此问题：

- 以 `root` 用户身份运行容器。您应测试此配置，因为它可能并非在所有情况下都有效。这可以通过修改 CI/CD 配置并检查作业输出以确保 `whoami` 返回 `root` 而不是 `gitlab` 来完成。如果显示 `gitlab`，请使用其他变通方法。测试确认更改成功后，可以移除 `before_script`。

  ```yaml
  api_security:
    image:
      name: $SECURE_ANALYZERS_PREFIX/$APISEC_IMAGE:$APISEC_VERSION$APISEC_IMAGE_SUFFIX
      docker:
        user: root
   before_script:
     - whoami
  ```

  _示例作业控制台输出：_

  ```log
  Executing "step_script" stage of the job script
  Using docker image sha256:8b95f188b37d6b342dc740f68557771bb214fe520a5dc78a88c7a9cc6a0f9901 for registry.gitlab.com/security-products/api-security:5 with digest registry.gitlab.com/security-products/api-security@sha256:092909baa2b41db8a7e3584f91b982174772abdfe8ceafc97cf567c3de3179d1 ...
  $ whoami
  root
  $ /peach/analyzer-api-security
  17:17:14 [INF] API Security: Gitlab API Security
  17:17:14 [INF] API Security: -------------------
  17:17:14 [INF] API Security:
  17:17:14 [INF] API Security: version: 5.7.0
  ```

- 包装容器并在构建时添加任何依赖项。此选项的优点是使用比 root 更低的权限运行，这可能是某些客户的要求。

  1. 创建一个包装现有镜像的新 `Dockerfile`。

     ```yaml
     ARG SECURE_ANALYZERS_PREFIX
     ARG APISEC_IMAGE
     ARG APISEC_VERSION
     ARG APISEC_IMAGE_SUFFIX
     FROM $SECURE_ANALYZERS_PREFIX/$APISEC_IMAGE:$APISEC_VERSION$APISEC_IMAGE_SUFFIX
     USER root

     RUN pip install ...
     RUN apk add ...

     USER gitlab
     ```

  1. 在 API 安全测试作业开始之前，构建新镜像并将其推送到您的本地容器镜像仓库。在 `api_security` 作业完成后，应移除该镜像。

     ```shell
     TARGET_NAME=apisec-$CI_COMMIT_SHA
     docker build -t $TARGET_IMAGE \
       --build-arg "SECURE_ANALYZERS_PREFIX=$SECURE_ANALYZERS_PREFIX" \
       --build-arg "APISEC_IMAGE=$APISEC_IMAGE" \
       --build-arg "APISEC_VERSION=$APISEC_VERSION" \
       --build-arg "APISEC_IMAGE_SUFFIX=$APISEC_IMAGE_SUFFIX" \
       .
     docker login -u gitlab-ci-token -p $CI_JOB_TOKEN $CI_REGISTRY
     docker push $TARGET_IMAGE
     ```

  1. 扩展 `api_security` 作业并使用新的镜像名称。

     ```yaml
     api_security:
       image: apisec-$CI_COMMIT_SHA
     ```

  1. 从镜像仓库中移除临时容器。请参阅[此文档页面了解如何删除容器镜像。](../../packages/container_registry/delete_container_registry_images.md)

- 更改极狐GitLab Runner 配置，禁用 no-new-privileges 标志。这可能会产生安全影响，应与您的运维和安全团队讨论。

<a id="index-was-outside-the-bounds-of-the-array----at-peachwebrunnerservicesrunneroptionsgetheaders"></a>

## `Index was outside the bounds of the array.    at Peach.Web.Runner.Services.RunnerOptions.GetHeaders()`

此错误消息表示 API 安全测试分析器无法解析 `APISEC_REQUEST_HEADERS` 或 `APISEC_REQUEST_HEADERS_BASE64` 配置变量的值。

**错误消息**

可以通过两个错误消息来识别此问题。第一个错误消息出现在作业控制台输出中，第二个出现在 `gl-api-security-scanner.log` 文件中。

_来自作业控制台的错误消息：_

```plaintext
05:48:38 [ERR] API Security: Testing failed: An unexpected exception occurred: Index was outside the bounds of the array.
```

_来自 `gl_api_security-scanner.log` 的错误消息：_

```plaintext
08:45:43.616 [ERR] <Peach.Web.Core.Services.WebRunnerMachine> Unexpected exception in WebRunnerMachine::Run()
System.IndexOutOfRangeException: Index was outside the bounds of the array.
   at Peach.Web.Runner.Services.RunnerOptions.GetHeaders() in /builds/gitlab-org/security-products/analyzers/api-fuzzing-src/web/PeachWeb/Runner/Services/[RunnerOptions.cs:line 362
   at Peach.Web.Runner.Services.RunnerService.Start(Job job, IRunnerOptions options) in /builds/gitlab-org/security-products/analyzers/api-fuzzing-src/web/PeachWeb/Runner/Services/RunnerService.cs:line 67
   at Peach.Web.Core.Services.WebRunnerMachine.Run(IRunnerOptions runnerOptions, CancellationToken token) in /builds/gitlab-org/security-products/analyzers/api-fuzzing-src/web/PeachWeb/Core/Services/WebRunnerMachine.cs:line 321
08:45:43.634 [WRN] <Peach.Web.Core.Services.WebRunnerMachine> * Session failed: An unexpected exception occurred: Index was outside the bounds of the array.
08:45:43.677 [INF] <Peach.Web.Core.Services.WebRunnerMachine> Finished testing. Performed a total of 0 requests.
```

**解决方案**

此问题是由于格式错误的 `APISEC_REQUEST_HEADERS` 或 `APISEC_REQUEST_HEADERS_BASE64` 变量引起的。预期格式是一个或多个 `Header: value` 结构的标头，以逗号分隔。解决方案是纠正语法以匹配预期格式。

_有效示例：_

- `Authorization: Bearer XYZ`
- `X-Custom: Value,Authorization: Bearer XYZ`

_无效示例：_

- `Header:,value`
- `HeaderA: value,HeaderB:,HeaderC: value`
- `Header`
