---
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: API 模糊测试问题排查
---

<a id="api-fuzzing-job-times-out-after-n-hours"></a>

## API 模糊测试作业在 N 小时后超时

对于较大的代码仓库，API 模糊测试作业可能在默认设置的 [Linux 小型托管 Runner](../../../ci/runners/hosted_runners/linux.md#machine-types-available-for-linux---x86-64) 上超时。如果您的作业出现这种情况，应该扩展到 [更大的 Runner](performance.md#using-a-larger-runner)。

请参阅以下文档部分以获得帮助：

- [性能调优与测试速度](performance.md)
- [使用更大的 Runner](performance.md#using-a-larger-runner)
- [按路径排除操作](configuration/customizing_analyzer_settings.md#exclude-paths)
- [排除慢速操作](performance.md#excluding-slow-operations)

<a id="api-fuzzing-job-takes-too-long-to-complete"></a>

## API 模糊测试作业完成时间过长

请参阅 [性能调优与测试速度](performance.md)

<a id="error-error-waiting-for-api-fuzzing-http1270015000-to-become-available"></a>

## 错误：`等待 API 模糊测试 'http://127.0.0.1:5000' 可用时出错`

在 API 模糊测试分析器 v1.6.196 之前的版本中存在一个错误，可能导致后台进程在某些条件下失败。解决方案是更新到更新版本的 API 模糊测试分析器。

版本信息可以在 `apifuzzer_fuzz` 作业的作业详情中找到。

如果问题出现在 v1.6.196 或更高版本，请联系支持团队，并提供以下信息：

1. 引用此问题排查部分，并请求将问题升级至动态分析团队。
1. 作业的完整控制台输出。
1. 可作为作业产物获取的 `gl-api-security-scanner.log` 文件。在作业详情页面的右侧面板中，选择 **浏览** 按钮。
1. 从您的 `.gitlab-ci.yml` 文件中获取的 `apifuzzer_fuzz` 作业定义。

**错误信息**

- 在极狐GitLab 15.6 及更高版本中，`Error waiting for API Fuzzing 'http://127.0.0.1:5000' to become available`
- 在极狐GitLab 15.5 及更早版本中，`Error waiting for API Security 'http://127.0.0.1:5000' to become available`。

<a id="failed-to-start-session-with-scanner-please-retry-and-if-the-problem-persists-reach-out-to-support"></a>

### 无法启动与扫描器的会话。请重试，如果问题仍然存在，请联系支持。

当 API 模糊测试引擎无法与扫描器应用程序组件建立连接时，会输出一条错误消息。该错误消息显示在 `apifuzzer_fuzz` 作业的作业输出窗口中。此问题的一个常见原因是后台组件无法使用所选端口，因为该端口已被占用。如果时间因素造成竞态条件，该错误可能间歇性出现。此问题在 Kubernetes 环境中最为常见，当其他服务映射到容器中时会导致端口冲突。

在继续解决方案之前，确认错误消息是因端口已被占用而生成的非常重要。要确认此原因：

1. 转到作业控制台。
1. 查找产物 `gl-api-security-scanner.log`。您可以选择 **下载** 来下载所有产物然后搜索该文件，或者直接通过选择 **浏览** 开始搜索。
1. 在文本编辑器中打开 `gl-api-security-scanner.log` 文件。
1. 如果错误消息是因端口已被占用而生成的，您应在此文件中看到类似以下的消息：

- 在极狐GitLab 15.5 及更高版本中：

  ```log
  无法绑定到地址 http://127.0.0.1:5500: 地址已被使用。
  ```

- 在极狐GitLab 15.4 及更早版本中：

  ```log
  无法绑定到地址 http://[::]:5000: 地址已被使用。
  ```

先前消息中的文本 `http://[::]:5000` 在您的情况下可能不同，例如可能是 `http://[::]:5500` 或 `http://127.0.0.1:5500`。只要错误消息的其余部分相同，就可以安全地假设端口已被占用。

如果未找到端口已被占用的证据，请检查其他也处理作业控制台输出中显示相同错误消息的问题排查部分。如果没有更多选项，可以通过适当的渠道 [获取支持或请求改进](_index.md#get-support-or-request-an-improvement)。

一旦确认问题是由端口已被占用引起的，极狐GitLab 15.5 及更高版本引入了配置变量 `FUZZAPI_API_PORT`。此配置变量允许为扫描器后台组件设置固定的端口号。

**解决方案**

1. 确保您的 `.gitlab-ci.yml` 文件定义了配置变量 `FUZZAPI_API_PORT`。
1. 将 `FUZZAPI_API_PORT` 的值更新为任何大于 1024 的可用端口号。确保新值未被极狐GitLab 使用。请参阅 [软件包默认值](../../../administration/package_information/defaults.md#ports) 中极狐GitLab 使用的完整端口列表。

<a id="error-errors-were-found-during-validation-of-the-document-using-the-published-openapi-schema"></a>

## 错误：`使用发布的 OpenAPI 架构验证文档时发现错误`

在 API 模糊测试作业开始时，OpenAPI 规范会依据 [发布的架构](https://github.com/OAI/OpenAPI-Specification/tree/master/schemas) 进行验证。当提供的 OpenAPI 规范存在验证错误时，会显示此错误：

```plaintext
错误，OpenAPI 文档无效。
使用发布的 OpenAPI 架构验证文档时发现错误
```

手动创建 OpenAPI 规范或自动生成架构时都可能引入错误。

对于自动生成的 OpenAPI 规范，验证错误通常是由于缺少代码注解所致。

**错误信息**

- `错误，OpenAPI 文档无效。使用发布的 OpenAPI 架构验证文档时发现错误`
  - `OpenAPI 2.0 架构验证错误 ...`
  - `OpenAPI 3.0.x 架构验证错误 ...`

**解决方案**

**对于生成的 OpenAPI 规范**

1. 识别验证错误。
   1. 使用 [Swagger Editor](https://editor.swagger.io/) 识别规范中的验证问题。Swagger Editor 的可视化特性使其更容易理解需要更改的内容。
   1. 或者，您可以检查日志输出并查找架构验证警告。它们以类似 `OpenAPI 2.0 schema validation error` 或 `OpenAPI 3.0.x schema validation error` 的信息开头。每个失败的验证都会提供关于 `location` 和 `description` 的额外信息。JSON Schema 验证消息可能很复杂，编辑器可以帮助您验证架构文档。
1. 查看您正在使用的框架/技术栈的 OpenAPI 生成文档。确定需要进行的更改以生成正确的 OpenAPI 文档。
1. 解决验证问题后，重新运行您的流水线。

**对于手动创建的 OpenAPI 规范**

1. 识别验证错误。
   1. 最简单的解决方案是使用可视化工具来编辑和验证 OpenAPI 文档。例如，[Swagger Editor](https://editor.swagger.io/) 会突出显示架构错误和可能的解决方案。
   1. 或者，您可以检查日志输出并查找架构验证警告。它们以类似 `OpenAPI 2.0 schema validation error` 或 `OpenAPI 3.0.x schema validation error` 的信息开头。每个失败的验证都会提供关于 `location` 和 `description` 的额外信息。纠正每个验证失败项，然后重新提交 OpenAPI 文档。JSON Schema 验证消息可能很复杂，编辑器可以帮助您验证架构文档。
1. 解决验证问题后，重新运行您的流水线。

<a id="failed-to-start-scanner-session-version-header-not-found"></a>

## `无法启动扫描器会话（未找到版本头）`

当 API 模糊测试引擎无法与扫描器应用程序组件建立连接时，会输出一条错误消息。该错误消息显示在 `apifuzzer_fuzz` 作业的作业输出窗口中。此问题的一个常见原因是更改了 `FUZZAPI_API` 变量的默认值。

**错误信息**

- `Failed to start scanner session (version header not found).`

**解决方案**

- 从 `.gitlab-ci.yml` 文件中移除 `FUZZAPI_API` 变量。该值继承自 API 模糊测试 CI/CD 模板。请使用此方法，而不是手动设置一个值。
- 如果无法移除该变量，请检查该值在最新版本的 [API 模糊测试 CI/CD 模板](https://jihulab.com/gitlab-cn/gitlab/-/blob/master/lib/gitlab/ci/templates/Security/API-Fuzzing.gitlab-ci.yml) 中是否已更改。如果是，请更新 `.gitlab-ci.yml` 文件中的值。

<a id="application-cannot-determine-the-base-url-for-the-target-api"></a>

## `应用程序无法确定目标 API 的基本 URL`

API 模糊测试分析器在检查 OpenAPI 文档后无法确定目标 API 时，会输出一条错误消息。该错误消息在以下情况下显示：未在 `.gitlab-ci.yml` 文件中设置目标 API，`environment_url.txt` 文件中也没有提供，并且无法使用 OpenAPI 文档计算出来。

API 模糊测试分析器在检查不同来源时尝试获取目标 API 的顺序存在优先级。首先，它尝试使用 `FUZZAPI_TARGET_URL`。如果未设置该环境变量，则 API 模糊测试分析器尝试使用 `environment_url.txt` 文件。如果没有 `environment_url.txt` 文件，API 模糊测试分析器现在使用 OpenAPI 文档内容和 `FUZZAPI_OPENAPI` 中提供的 URL（如果提供了 URL）来尝试计算目标 API。

最适合的解决方案取决于您的目标 API 是否针对每次部署而改变：

- 如果目标 API 在每次部署中都相同（静态环境），请使用 [静态环境解决方案](#static-environment-solution)。
- 如果目标 API 每次部署都发生变化，请使用 [动态环境解决方案](#dynamic-environment-solutions)。

<a id="static-environment-solution"></a>

### 静态环境解决方案

此解决方案适用于目标 API URL 不变（静态）的流水线。

**添加环境变量**

对于目标 API 保持不变的环境，您应使用 `FUZZAPI_TARGET_URL` 环境变量指定目标 URL。在您的 `.gitlab-ci.yml` 文件中，添加一个变量 `FUZZAPI_TARGET_URL`。该变量必须设置为 API 测试目标的基本 URL。例如：

```yaml
stages:
  - fuzz

include:
  - template: API-Fuzzing.gitlab-ci.yml

variables:
  FUZZAPI_TARGET_URL: http://test-deployment/
  FUZZAPI_OPENAPI: test-api-specification.json
```

<a id="dynamic-environment-solutions"></a>

### 动态环境解决方案

在动态环境中，您的目标 API 会因每次部署而改变。在这种情况下，存在多种可能的解决方案：处理动态环境时，可以考虑使用 `environment_url.txt` 文件。

**使用 `environment_url.txt`**

为了支持目标 API URL 在每次流水线中变化的动态环境，API 模糊测试支持使用一个包含要使用 URL 的 `environment_url.txt` 文件。此文件不会被检入仓库，而是在流水线中由部署测试目标的作业创建，并作为产物收集，供流水线中后续作业使用。创建 `environment_url.txt` 文件的作业必须在 API 模糊测试作业之前运行。

1. 修改测试目标部署作业，在项目根目录的 `environment_url.txt` 文件中添加基本 URL。
1. 修改测试目标部署作业，将 `environment_url.txt` 作为产物收集。

示例：

```yaml
deploy-test-target:
  script:
    # 执行部署步骤
    # 创建 environment_url.txt（示例）
    - echo http://${CI_PROJECT_ID}-${CI_ENVIRONMENT_SLUG}.example.org > environment_url.txt

  artifacts:
    paths:
      - environment_url.txt
```

<a id="use-openapi-with-an-invalid-schema"></a>

## 使用具有无效架构的 OpenAPI

在某些情况下，文档是自动生成的，但具有无效架构，或者无法及时手动编辑。在这些场景中，API 模糊测试可以通过设置变量 `FUZZAPI_OPENAPI_RELAXED_VALIDATION` 来执行宽松验证。请提供完全合规的 OpenAPI 文档，以防止意外行为。

<a id="edit-a-non-compliant-openapi-file"></a>

### 编辑不符合规范的 OpenAPI 文件

使用编辑器检测并纠正不符合 OpenAPI 规范的元素。编辑器通常提供文档验证和建议，以创建符合规范的 OpenAPI 文档。推荐的编辑器包括：

| 编辑器                                             | OpenAPI 2.0                   | OpenAPI 3.0.x                 | OpenAPI 3.1.x |
|----------------------------------------------------|-------------------------------|-------------------------------|---------------|
| [Swagger Editor](https://editor.swagger.io/)       | {{< icon name="check-circle" >}} YAML, JSON | {{< icon name="check-circle" >}} YAML, JSON | {{< icon name="dotted-circle" >}} YAML, JSON |
| [Stoplight Studio](https://stoplight.io/solutions) | {{< icon name="check-circle" >}} YAML, JSON | {{< icon name="check-circle" >}} YAML, JSON | {{< icon name="check-circle" >}} YAML, JSON |

如果您的 OpenAPI 文档是手动生成的，请在编辑器中加载您的文档并修复任何不符合规范的地方。如果您的文档是自动生成的，请在编辑器中加载它以识别架构中的问题，然后转到应用程序，根据您使用的框架执行更正。

<a id="enable-openapi-relaxed-validation"></a>

### 启用 OpenAPI 宽松验证

宽松验证适用于 OpenAPI 文档无法满足 OpenAPI 规范，但仍具有足够内容供不同工具使用的情况。验证仍然执行，但相对于文档架构不那么严格。

API 模糊测试仍然可以尝试使用不完全符合 OpenAPI 规范的 OpenAPI 文档。要指示 API 模糊测试分析器执行宽松验证，请将变量 `FUZZAPI_OPENAPI_RELAXED_VALIDATION` 设置为任何值，例如：

```yaml
stages:
  - fuzz

include:
  - template: API-Fuzzing.gitlab-ci.yml

variables:
  FUZZAPI_PROFILE: Quick-10
  FUZZAPI_TARGET_URL: http://test-deployment/
  FUZZAPI_OPENAPI: test-api-specification.json
  FUZZAPI_OPENAPI_RELAXED_VALIDATION: 'On'
```

<a id="no-operation-in-the-openapi-document-is-consuming-any-supported-media-type"></a>

## `OpenAPI 文档中没有操作消费任何支持的媒体类型`

API 模糊测试使用 OpenAPI 文档中指定的媒体类型来生成请求。如果由于缺少支持的媒体类型而无法创建任何请求，则会抛出错误。

**错误信息**

- `错误，OpenApi 文档中没有操作消费任何支持的媒体类型。请检查 'OpenAPI Specification' 以查看支持的媒体类型。`

**解决方案**

1. 查看 [OpenAPI 规范](configuration/enabling_the_analyzer.md#openapi-specification) 部分中支持的媒体类型。
1. 编辑您的 OpenAPI 文档，至少允许一个给定的操作接受任何支持的媒体类型。或者，可以在 OpenAPI 文档级别设置支持的媒体类型，并将其应用于所有操作。此步骤可能需要更改您的应用程序，以确保应用程序接受支持的媒体类型。

<a id="error-the-ssl-connection-could-not-be-established-see-inner-exception"></a>

## 错误：`无法建立 SSL 连接，请参阅内部异常。`

API 模糊测试兼容广泛的 TLS 配置，包括过时的协议和密码套件。
尽管支持范围广泛，您仍可能遇到连接错误，例如：

```plaintext
错误，尝试下载 `<URL>` 时发生错误：
从 Uri：' <URL>' 检索内容时出错。
错误：无法建立 SSL 连接，请参阅内部异常。
```

发生此错误是因为 API 模糊测试无法与给定 URL 的服务器建立安全连接。

要解决此问题：

如果错误消息中的主机支持非 TLS 连接，请在您的配置中将 `https://` 更改为 `http://`。
例如，如果以下配置发生错误：

```yaml
stages:
  - fuzz

include:
  - template: API-Fuzzing.gitlab-ci.yml

variables:
  FUZZAPI_TARGET_URL: https://test-deployment/
  FUZZAPI_OPENAPI: https://specs/openapi.json
```

将 `FUZZAPI_OPENAPI` 的前缀从 `https://` 更改为 `http://`：

```yaml
stages:
  - fuzz

include:
  - template: API-Fuzzing.gitlab-ci.yml

variables:
  FUZZAPI_TARGET_URL: https://test-deployment/
  FUZZAPI_OPENAPI: http://specs/openapi.json
```

如果无法使用非 TLS 连接访问 URL，请联系支持团队寻求帮助。

您可以使用 [testssl.sh 工具](https://testssl.sh/) 加快调查。从具有 bash shell 且能连接到受影响服务器的机器上：

1. 从 <https://github.com/drwetter/testssl.sh/releases> 下载最新的 `zip` 或 `tar.gz` 发布文件并解压。
1. 运行 `./testssl.sh --log https://specs`。
1. 将日志文件附加到您的支持工单中。

<a id="error-job-failed-failed-to-pull-image"></a>

## `ERROR：作业失败：无法拉取镜像`

当从需要认证才能访问（非公开）的容器镜像仓库拉取镜像时，会出现此错误信息。

在作业控制台输出中，错误类似于：

```plaintext
Running with gitlab-runner 15.6.0~beta.186.ga889181a (a889181a)
  on blue-2.shared.runners-manager.jihulab.com/default XxUrkriX
Resolving secrets
00:00
Preparing the "docker+machine" executor
00:06
Using Docker executor with image registry.jihulab.com/security-products/api-security:2 ...
Starting service registry.example.com/my-target-app:latest ...
Pulling docker image registry.example.com/my-target-app:latest ...
WARNING: Failed to pull image with policy "always": Error response from daemon: Get https://registry.example.com/my-target-app/manifests/latest: unauthorized (manager.go:237:0s)
ERROR: Job failed: failed to pull image "registry.example.com/my-target-app:latest" with specified policies [always]: Error response from daemon: Get https://registry.example.com/my-target-app/manifests/latest: unauthorized (manager.go:237:0s)
```

**错误信息**

- 在极狐GitLab 15.9 及更早版本中，`ERROR: Job failed: failed to pull image` 后跟 `Error response from daemon: Get IMAGE: unauthorized`。

**解决方案**

认证凭据使用 [从私有容器镜像仓库访问镜像](../../../ci/docker/using_docker_images.md#access-an-image-from-a-private-container-registry) 文档部分中概述的方法提供。所使用的方法取决于您的容器镜像仓库提供者及其配置。如果您使用的是第三方提供的容器镜像仓库，例如云提供商（Azure、Google Cloud (GCP)、AWS 等），请查看提供商的文档，了解如何向其容器镜像仓库进行认证。

以下示例使用 [静态定义的凭据](../../../ci/docker/using_docker_images.md#use-statically-defined-credentials) 认证方法。在此示例中，容器镜像仓库为 `registry.example.com`，镜像为 `my-target-app:latest`。

1. 阅读 [确定您的 `DOCKER_AUTH_CONFIG` 数据](../../../ci/docker/using_docker_images.md#determine-your-docker_auth_config-data) 以了解如何计算 `DOCKER_AUTH_CONFIG` 的变量值。配置变量 `DOCKER_AUTH_CONFIG` 包含 Docker JSON 配置，用于提供适当的认证信息。例如，要访问私有容器镜像仓库：`registry.example.com`，凭据为 `abcdefghijklmn`，则 Docker JSON 如下所示：

   ```json
   {
       "auths": {
           "registry.example.com": {
               "auth": "abcdefghijklmn"
           }
       }
   }
   ```

1. 将 `DOCKER_AUTH_CONFIG` 添加为 CI/CD 变量。您不应直接将配置变量添加到 `.gitlab-ci.yml` 文件中，而应创建一个项目 [CI/CD 变量](../../../ci/variables/_index.md#for-a-project)。
1. 重新运行您的作业，现在静态定义的凭据将用于登录私有容器镜像仓库 `registry.example.com`，并允许您拉取镜像 `my-target-app:latest`。如果成功，作业控制台会显示类似以下输出：

   ```log
   Running with gitlab-runner 15.6.0~beta.186.ga889181a (a889181a)
     on blue-4.shared.runners-manager.jihulab.com/default J2nyww-s
   Resolving secrets
   00:00
   Preparing the "docker+machine" executor
   00:56
   Using Docker executor with image registry.jihulab.com/security-products/api-security:2 ...
   Starting service registry.example.com/my-target-app:latest ...
   Authenticating with credentials from $DOCKER_AUTH_CONFIG
   Pulling docker image registry.example.com/my-target-app:latest ...
   Using docker image sha256:139c39668e5e4417f7d0eb0eeb74145ba862f4f3c24f7c6594ecb2f82dc4ad06 for registry.example.com/my-target-app:latest with digest registry.example.com/my-target-
   app@sha256:2b69fc7c3627dbd0ebaa17674c264fcd2f2ba21ed9552a472acf8b065d39039c ...
   Waiting for services to be up and running (timeout 30 seconds)...
   ```

<a id="error-sudo-the-no-new-privileges-flag-is-set-which-prevents-sudo-from-running-as-root"></a>

## 错误：`sudo："no new privileges" 标志已设置，阻止 sudo 以 root 身份运行。`

从分析器 v5 开始，默认使用非 root 用户。这要求在执行特权操作时使用 `sudo`。

当特定的容器守护进程设置阻止运行中的容器获取新权限时，会出现此错误。在大多数情况下，这不是默认配置，而是专门配置的，通常是安全加固指南的一部分。

**错误信息**

当执行 `before_script` 或 `FUZZAPI_PRE_SCRIPT` 时，可以通过生成的错误信息来识别此问题：

```shell
$ sudo apk add nodejs

sudo: The "no new privileges" flag is set, which prevents sudo from running as root.

sudo: If sudo is running in a container, you may need to adjust the container configuration to disable the flag.
```

**解决方案**

可以通过以下方式解决此问题：

- 以 `root` 用户身份运行容器。建议测试此配置，因为它可能并非在所有情况下都有效。可以通过修改 CICD 配置并检查作业输出来确保 `whoami` 返回 `root` 而不是 `gitlab`。如果显示 `gitlab`，请使用其他解决方法。测试后，可以移除 `before_script`。

  ```yaml
  apifuzzer_fuzz:
    image:
      name: $SECURE_ANALYZERS_PREFIX/$FUZZAPI_IMAGE:$FUZZAPI_VERSION$FUZZAPI_IMAGE_SUFFIX
      docker:
        user: root
   before_script:
     - whoami
  ```

  _示例作业控制台输出：_

  ```log
  Executing "step_script" stage of the job script
  Using docker image sha256:8b95f188b37d6b342dc740f68557771bb214fe520a5dc78a88c7a9cc6a0f9901 for registry.jihulab.com/security-products/api-security:5 with digest registry.jihulab.com/security-products/api-security@sha256:092909baa2b41db8a7e3584f91b982174772abdfe8ceafc97cf567c3de3179d1 ...
  $ whoami
  root
  $ /peach/analyzer-api-fuzzing
  17:17:14 [INF] API Security: Gitlab API Security
  17:17:14 [INF] API Security: -------------------
  17:17:14 [INF] API Security:
  17:17:14 [INF] API Security: version: 5.7.0
  ```

- 在构建时包装容器并添加任何依赖项。此选项的优点是使用比 root 更低的权限运行，这对某些客户可能是必需的。

  1. 创建包装现有镜像的新 `Dockerfile`。

     ```yaml
     ARG SECURE_ANALYZERS_PREFIX
     ARG FUZZAPI_IMAGE
     ARG FUZZAPI_VERSION
     ARG FUZZAPI_IMAGE_SUFFIX
     FROM $SECURE_ANALYZERS_PREFIX/$FUZZAPI_IMAGE:$FUZZAPI_VERSION$FUZZAPI_IMAGE_SUFFIX
     USER root

     RUN pip install ...
     RUN apk add ...

     USER gitlab
     ```

  1. 在 API 模糊测试作业开始之前，构建新镜像并将其推送到您的本地容器镜像仓库。作业完成后应移除该镜像。

     ```shell
     TARGET_NAME=apifuzz-$CI_COMMIT_SHA
     docker build -t $TARGET_IMAGE \
       --build-arg "SECURE_ANALYZERS_PREFIX=$SECURE_ANALYZERS_PREFIX" \
       --build-arg "FUZZAPI_IMAGE=$APISEC_IMAGE" \
       --build-arg "FUZZAPI_VERSION=$APISEC_VERSION" \
       --build-arg "FUZZAPI_IMAGE_SUFFIX=$APISEC_IMAGE_SUFFIX" \
       .
     docker login -u gitlab-ci-token -p $CI_JOB_TOKEN $CI_REGISTRY
     docker push $TARGET_IMAGE
     ```

  1. 扩展 `apifuzzer_fuzz` 作业并使用新镜像名称。

     ```yaml
     apifuzzer_fuzz:
       image: apifuzz-$CI_COMMIT_SHA
     ```

  1. 从镜像仓库中移除临时容器。有关移除容器镜像的信息，请参阅 [此文档页面](../../packages/container_registry/delete_container_registry_images.md)。

- 更改 GitLab Runner 配置，禁用 no-new-privileges 标志。这可能存在安全隐患，应与您的运维和安全团队讨论。
<a id="index-was-outside-the-bounds-of-the-array-at-peach.web.runner.services.runneroptions.getheaders()"></a>

## `在 Peach.Web.Runner.Services.RunnerOptions.GetHeaders() 中“索引超出数组界限”`

此错误消息表示 API 模糊测试分析器无法解析 `FUZZAPI_REQUEST_HEADERS` 或 `FUZZAPI_REQUEST_HEADERS_BASE64` 配置变量的值。

**错误消息**

此问题可通过两条错误消息识别。第一条错误消息显示在作业控制台输出中，第二条显示在 `gl-api-security-scanner.log` 文件中。

_来自作业控制台的错误消息：_

```plaintext
05:48:38 [ERR] API 安全：测试失败：发生意外异常：索引超出了数组界限。
```

_来自 `gl_api_security-scanner.log` 的错误消息：_

```plaintext
08:45:43.616 [ERR] <Peach.Web.Core.Services.WebRunnerMachine> WebRunnerMachine::Run() 中出现意外异常
System.IndexOutOfRangeException: 索引超出了数组界限。
   在 Peach.Web.Runner.Services.RunnerOptions.GetHeaders() 中 /builds/gitlab-org/security-products/analyzers/api-fuzzing-src/web/PeachWeb/Runner/Services/[RunnerOptions.cs:行 362
   在 Peach.Web.Runner.Services.RunnerService.Start(Job job, IRunnerOptions options) 中 /builds/gitlab-org/security-products/analyzers/api-fuzzing-src/web/PeachWeb/Runner/Services/RunnerService.cs:行 67
   在 Peach.Web.Core.Services.WebRunnerMachine.Run(IRunnerOptions runnerOptions, CancellationToken token) 中 /builds/gitlab-org/security-products/analyzers/api-fuzzing-src/web/PeachWeb/Core/Services/WebRunnerMachine.cs:行 321
08:45:43.634 [WRN] <Peach.Web.Core.Services.WebRunnerMachine> * 会话失败：发生意外异常：索引超出了数组界限。
08:45:43.677 [INF] <Peach.Web.Core.Services.WebRunnerMachine> 测试完成。共执行了 0 个请求。
```

**解决方案**

此问题是由于 `FUZZAPI_REQUEST_HEADERS` 或 `FUZZAPI_REQUEST_HEADERS_BASE64` 变量格式错误导致的。预期格式为由逗号分隔的一个或多个 `标头: 值` 结构。解决方案是纠正语法以符合预期。

_有效示例：_

- `授权: 持有者 XYZ`
- `X-Custom: 值,授权: 持有者 XYZ`

_无效示例：_

- `标头:,值`
- `标头A: 值,标头B:,标头C: 值`
- `标头`