---

stage: Application Security Testing
group: Static Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 配置基于 CodeClimate 的代码质量扫描（已弃用）

---

<!--- start_remove The following content will be removed on remove_date: '2026-08-15' -->

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

> [!warning]
> 此功能在极狐GitLab 17.3 中[已弃用](../../update/deprecations.md#codeclimate-based-code-quality-scanning-will-be-removed)，并计划在 19.0 中移除。
> 请改为[直接集成来自支持工具的结果](code_quality.md#import-code-quality-results-from-a-cicd-job)。这是一个重大变更。

代码质量包含一个内置的 CI/CD 模板 `Code-Quality.gitlab-ci.yaml`。
此模板基于开源 CodeClimate 扫描引擎运行扫描。

CodeClimate 引擎运行：

- 针对[一组支持的语言](https://docs.codeclimate.com/docs/supported-languages-for-maintainability)的基本可维护性检查。
- 一组可配置的[插件](https://docs.codeclimate.com/docs/list-of-engines)，这些插件封装了开源扫描器，用于分析你的源代码。

<a id="enable-codeclimate-based-scanning"></a>

## 启用基于 CodeClimate 的扫描

先决条件：

- 极狐GitLab CI/CD 配置 (`.gitlab-ci.yml`) 必须包含 `test` 阶段。
- 如果你使用实例 runner，则必须为 [Docker-in-Docker 工作流](../docker/using_docker_build.md#use-docker-in-docker)配置代码质量作业。
  使用此工作流时，必须挂载 `/builds` 卷以允许保存报告。
- 如果你使用私有 runner，你应该使用推荐的[替代配置](#use-private-runners)，以便更高效地运行代码质量分析。
- runner 必须有足够的磁盘空间来存储生成的代码质量文件。例如，在 [极狐GitLab 项目](https://gitlab.com/gitlab-org/gitlab) 中，文件大约为 7 GB。

要启用代码质量，可以：

- 启用 [Auto DevOps](../../topics/autodevops/_index.md)，其中包含 [Auto Code Quality](../../topics/autodevops/stages.md#auto-code-quality)。

- 在你的 `.gitlab-ci.yml` 文件中包含[代码质量模板](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Jobs/Code-Quality.gitlab-ci.yml)。

  示例：

  ```yaml
     include:
     - template: Jobs/Code-Quality.gitlab-ci.yml
  ```

  代码质量现在会在流水线中运行。

> [!warning]
> 在私有化部署实例上，如果恶意行为者破坏了代码质量作业定义，他们可能在 runner 主机上执行特权 Docker 命令。拥有适当的访问控制策略可以通过仅允许受信任的行为者访问来缓解此攻击向量。

<a id="disable-codeclimate-based-scanning"></a>

## 禁用基于 CodeClimate 的扫描

如果存在 `$CODE_QUALITY_DISABLED` CI/CD 变量，则 `code_quality` 作业不会运行。有关如何定义变量的更多信息，请参阅[极狐GitLab CI/CD 变量](../variables/_index.md)。

要禁用代码质量，请为以下范围之一创建一个名为 `CODE_QUALITY_DISABLED` 的自定义 CI/CD 变量：

- [整个项目](../variables/_index.md#for-a-project)。
- [单条流水线](../pipelines/_index.md#run-a-pipeline-manually)。

<a id="configure-codeclimate-analysis-plugins"></a>

## 配置 CodeClimate 分析插件

默认情况下，`code_quality` 作业将 CodeClimate 配置为：

- 使用[一组特定的插件](https://gitlab.com/gitlab-org/ci-cd/codequality/-/blob/master/codeclimate_defaults/.codeclimate.yml.template?ref_type=heads)。
- 为这些插件使用[默认配置](https://gitlab.com/gitlab-org/ci-cd/codequality/-/tree/master/codeclimate_defaults?ref_type=heads)。

要扫描更多语言，你可以启用更多[插件](https://docs.codeclimate.com/docs/list-of-engines)。
你也可以禁用 `code_quality` 作业默认启用的插件。

例如，要使用 [SonarJava 分析器](https://docs.codeclimate.com/docs/sonar-java)：

1. 将名为 `.codeclimate.yml` 的文件添加到你的仓库根目录
1. 将插件的[启用代码](https://docs.codeclimate.com/docs/sonar-java#enable-the-plugin)添加到仓库根目录的 `.codeclimate.yml` 文件中：

   ```yaml
   version: "2"
   plugins:
     sonar-java:
       enabled: true
   ```

这会将 SonarJava 添加到项目中包含的[默认 `.codeclimate.yml`](https://gitlab.com/gitlab-org/ci-cd/codequality/-/blob/master/codeclimate_defaults/.codeclimate.yml.template) 文件的 `plugins:` 部分。

对 `plugins:` 部分的更改不会影响默认 `.codeclimate.yml` 文件的 `exclude_patterns` 部分。有关更多详细信息，请参阅 Code Climate 关于[排除文件和文件夹](https://docs.codeclimate.com/docs/excluding-files-and-folders)的文档。

<a id="customize-scan-job-settings"></a>

## 自定义扫描作业设置

你可以通过在极狐GitLab CI/CD YAML 中设置 [CI/CD 变量](#available-cicd-variables) 来更改 `code_quality` 扫描作业的行为。

要配置代码质量作业：

1. 在包含模板之后，声明一个与代码质量作业同名的作业。
1. 在作业节中指定额外的键。

有关示例，请参阅[以 HTML 格式下载输出](#output-in-only-html-format)。

<a id="available-cicd-variables"></a>

### 可用的 CI/CD 变量

可以通过定义可用的 CI/CD 变量来自定义代码质量：

| CI/CD 变量                       | 描述 |
|---------------------------------|-------------|
| `CODECLIMATE_DEBUG`             | 设置为启用 [Code Climate 调试模式](https://github.com/codeclimate/codeclimate#environment-variables)。 |
| `CODECLIMATE_DEV`               | 设置为启用 `--dev` 模式，该模式允许你运行 CLI 未知的引擎。 |
| `CODECLIMATE_PREFIX`            | 设置一个前缀，用于 CodeClimate 引擎中的所有 `docker pull` 命令。对于[离线扫描](https://github.com/codeclimate/codeclimate/pull/948)很有用。更多信息，请参阅[使用私有容器镜像仓库](#use-a-private-container-image-registry)。 |
| `CODECLIMATE_REGISTRY_USERNAME` | 设置从 `CODECLIMATE_PREFIX` 解析出的镜像仓库域的用户名。 |
| `CODECLIMATE_REGISTRY_PASSWORD` | 设置从 `CODECLIMATE_PREFIX` 解析出的镜像仓库域的密码。 |
| `CODE_QUALITY_DISABLED`         | 阻止代码质量作业运行。 |
| `CODE_QUALITY_IMAGE`            | 设置为完全前缀的镜像名称。镜像必须可从你的作业环境访问。 |
| `ENGINE_MEMORY_LIMIT_BYTES`     | 设置引擎的内存限制。默认值：1,024,000,000 字节。 |
| `REPORT_STDOUT`                 | 设置为将报告打印到 `STDOUT`，而不是生成通常的报告文件。 |
| `REPORT_FORMAT`                 | 设置控制生成的报告文件的格式。可以是 `json` 或 `html`。 |
| `SOURCE_CODE`                   | 要扫描的源代码的路径。必须是存储克隆源代码的目录的绝对路径。 |
| `TIMEOUT_SECONDS`               | 为 `codeclimate analyze` 命令的每个引擎容器自定义超时时间。默认值：900 秒（15 分钟） |

<a id="output"></a>

### 输出

代码质量输出一份报告，其中包含发现的问题的详细信息。此报告的内容在内部进行处理，结果会显示在 UI 中。报告也作为 `code_quality` 作业的作业产物输出，文件名为 `gl-code-quality-report.json`。你可以选择以 HTML 格式输出报告。例如，你可以在极狐GitLab Pages 上发布 HTML 格式文件，以便于更轻松地进行审阅。

<a id="output-in-json-and-html-format"></a>

#### 以 JSON 和 HTML 格式输出

要以 JSON 和 HTML 格式输出代码质量报告，你需要创建一个额外的作业。这要求代码质量作业运行两次，每种文件格式各一次。

要以 HTML 格式输出代码质量报告，请使用 `extends: code_quality` 向你的模板添加另一个作业：

```yaml
include:
  - template: Jobs/Code-Quality.gitlab-ci.yml

code_quality_html:
  extends: code_quality
  variables:
    REPORT_FORMAT: html
  artifacts:
    paths: [gl-code-quality-report.html]
```

JSON 和 HTML 文件都将作为作业产物输出。HTML 文件包含在 `artifacts.zip` 作业产物中。

<a id="output-in-only-html-format"></a>

#### 仅以 HTML 格式输出

要仅以 HTML 格式下载代码质量报告，请将 `REPORT_FORMAT` 设置为 `html`，从而覆盖 `code_quality` 作业的默认定义。

> [!note]
> 这不会创建 JSON 格式文件，因此代码质量结果不会显示在合并请求部件、流水线报告或变更视图中。

```yaml
include:
  - template: Jobs/Code-Quality.gitlab-ci.yml

code_quality:
  variables:
    REPORT_FORMAT: html
  artifacts:
    paths: [gl-code-quality-report.html]
```

HTML 文件将作为作业产物输出。

<a id="use-code-quality-with-merge-request-pipelines"></a>

## 在合并请求流水线中使用代码质量

默认的代码质量配置不允许 `code_quality` 作业在[合并请求流水线](../pipelines/merge_request_pipelines.md)上运行。

要使代码质量在合并请求流水线上运行，请覆盖代码质量的 `rules` 或 [`workflow: rules`](../yaml/_index.md#workflow)，使其与你当前的 `rules` 匹配。

例如：

```yaml
include:
  - template: Jobs/Code-Quality.gitlab-ci.yml

code_quality:
  rules:
    - if: $CODE_QUALITY_DISABLED
      when: never
    - if: $CI_PIPELINE_SOURCE == "merge_request_event" # 在合并请求流水线中运行代码质量作业
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH      # 在默认分支的流水线中运行代码质量作业（但不在其他分支流水线中运行）
    - if: $CI_COMMIT_TAG                               # 在标签的流水线中运行代码质量作业
```

<a id="change-how-codeclimate-images-are-downloaded"></a>

## 更改 CodeClimate 镜像的下载方式

CodeClimate 引擎会下载容器镜像来运行其每个插件。
默认情况下，镜像从 Docker Hub 下载。
你可以更改镜像源以提高性能、解决 Docker Hub 速率限制问题或使用私有仓库。

<a id="use-the-dependency-proxy-to-download-images"></a>

### 使用依赖代理下载镜像

你可以使用依赖代理来减少下载依赖项所需的时间。

先决条件：

- 在项目所属的群组中启用了[依赖代理](../../user/packages/dependency_proxy/_index.md)。

要引用依赖代理，请在 `.gitlab-ci.yml` 文件中配置以下变量：

- `CODE_QUALITY_IMAGE`
- `CODECLIMATE_PREFIX`
- `CODECLIMATE_REGISTRY_USERNAME`
- `CODECLIMATE_REGISTRY_PASSWORD`

例如：

```yaml
include:
  - template: Jobs/Code-Quality.gitlab-ci.yml

code_quality:
  variables:
    ## 你必须在 `$CI_DEPENDENCY_PROXY_GROUP_IMAGE_PREFIX` 后添加一个尾随斜杠。
    CODECLIMATE_PREFIX: $CI_DEPENDENCY_PROXY_GROUP_IMAGE_PREFIX/
    CODECLIMATE_REGISTRY_USERNAME: $CI_DEPENDENCY_PROXY_USER
    CODECLIMATE_REGISTRY_PASSWORD: $CI_DEPENDENCY_PROXY_PASSWORD
```

<a id="use-docker-hub-with-authentication"></a>

### 使用带身份验证的 Docker Hub

你可以使用 Docker Hub 作为代码质量镜像的备用源。

先决条件：

- 在项目中添加用户名和密码作为[受保护的 CI/CD 变量](../variables/_index.md#for-a-project)。

要使用 DockerHub，请在 `.gitlab-ci.yml` 文件中配置以下变量：

- `CODECLIMATE_PREFIX`
- `CODECLIMATE_REGISTRY_USERNAME`
- `CODECLIMATE_REGISTRY_PASSWORD`

示例：

```yaml
include:
  - template: Jobs/Code-Quality.gitlab-ci.yml

code_quality:
  variables:
    CODECLIMATE_PREFIX: "registry-1.docker.io/"
    CODECLIMATE_REGISTRY_USERNAME: $DOCKERHUB_USERNAME
    CODECLIMATE_REGISTRY_PASSWORD: $DOCKERHUB_PASSWORD
```

<a id="use-a-private-container-image-registry"></a>

### 使用私有容器镜像仓库

使用私有容器镜像仓库可以减少下载镜像所需的时间，并减少外部依赖。由于容器执行的嵌套方法，你必须配置镜像仓库前缀，将其传递给 CodeClimate 针对各个引擎的后续 `docker pull` 命令。

以下变量可以处理所有必需的镜像拉取：

- `CODE_QUALITY_IMAGE`：一个完全前缀的镜像名称，可以位于你的作业环境可访问的任何位置。你可以在此处使用极狐GitLab 容器镜像仓库来托管你自己的副本。
- `CODECLIMATE_PREFIX`：你预期的容器镜像仓库的域。这是 [CodeClimate CLI](https://github.com/codeclimate/codeclimate/pull/948) 支持的配置选项。你必须：
  - 包含一个尾随斜杠 (`/`)。
  - 不包含协议前缀，例如 `https://`。
- `CODECLIMATE_REGISTRY_USERNAME`：一个可选变量，用于指定从 `CODECLIMATE_PREFIX` 解析出的镜像仓库域的用户名。
- `CODECLIMATE_REGISTRY_PASSWORD`：一个可选变量，用于指定从 `CODECLIMATE_PREFIX` 解析出的镜像仓库域的密码。

```yaml
include:
  - template: Jobs/Code-Quality.gitlab-ci.yml

code_quality:
  variables:
    CODE_QUALITY_IMAGE: "my-private-registry.local:12345/codequality:0.85.24"
    CODECLIMATE_PREFIX: "my-private-registry.local:12345/"
```

此示例特定于极狐GitLab 代码质量。有关如何配置带有镜像仓库镜像的 DinD 的更多通用说明，请参阅[为 Docker-in-Docker 服务启用镜像仓库镜像](../docker/using_docker_build.md#enable-registry-mirror-for-dockerdind-service)。

<a id="required-images"></a>

#### 必需的镜像

[默认 `.codeclimate.yml`](https://gitlab.com/gitlab-org/ci-cd/codequality/-/blob/master/codeclimate_defaults/.codeclimate.yml.template) 需要以下镜像：

- `codeclimate/codeclimate-structure:latest`
- `codeclimate/codeclimate-csslint:latest`
- `codeclimate/codeclimate-coffeelint:latest`
- `codeclimate/codeclimate-duplication:latest`
- `codeclimate/codeclimate-eslint:latest`
- `codeclimate/codeclimate-fixme:latest`
- `codeclimate/codeclimate-rubocop:rubocop-0-92`

如果你使用的是自定义的 `.codeclimate.yml` 配置文件，则必须将指定的插件添加到你的私有容器镜像仓库中。

<a id="change-runner-configuration"></a>

## 更改 Runner 配置

CodeClimate 为其每个分析步骤运行单独的容器。
你可能需要调整你的 Runner 配置，以便基于 CodeClimate 的扫描可以运行，或者使其运行得更快。

<a id="use-private-runners"></a>

### 使用私有 runners

如果你有私有 runner，你应该使用此配置来提高代码质量的性能，因为：

- 不使用特权模式。
- 不使用 Docker-in-Docker。
- Docker 镜像，包括所有 CodeClimate 镜像，都会被缓存，并且不会为后续作业重新获取。

此替代配置使用套接字绑定与作业环境共享 Runner 的 Docker 守护进程。在实施此配置之前，请考虑其[局限性](../docker/using_docker_build.md#use-docker-socket-binding)。

要使用私有 runner：

1. 注册一个新的 runner：

   ```shell
   $ gitlab-runner register --executor "docker" \
     --docker-image="docker:cli" \
     --url "https://gitlab.com/" \
     --description "cq-sans-dind" \
     --docker-volumes "/cache"\
     --docker-volumes "/builds:/builds"\
     --docker-volumes "/var/run/docker.sock:/var/run/docker.sock" \
     --registration-token="<project_token>" \
     --non-interactive
   ```

1. **可选，但推荐**：将构建目录设置为 `/tmp/builds`，以便定期从 runner 主机中清除作业产物。如果跳过此步骤，你必须自己清理默认的构建目录 (`/builds`)。
   你可以通过在上一步的 `gitlab-runner register` 中添加以下两个标志来实现。

   ```shell
   --builds-dir "/tmp/builds"
   --docker-volumes "/tmp/builds:/tmp/builds" # 使用此选项代替 --docker-volumes "/builds:/builds"
   ```

   生成的配置：

   ```toml
   [[runners]]
     name = "cq-sans-dind"
     url = "https://gitlab.com/"
     token = "<project_token>"
     executor = "docker"
     builds_dir = "/tmp/builds"
     [runners.docker]
       tls_verify = false
       image = "docker:cli"
       privileged = false
       disable_entrypoint_overwrite = false
       oom_kill_disable = false
       disable_cache = false
       volumes = ["/cache", "/var/run/docker.sock:/var/run/docker.sock", "/tmp/builds:/tmp/builds"]
       shm_size = 0
     [runners.cache]
       [runners.cache.s3]
       [runners.cache.gcs]
   ```

1. 对模板创建的 `code_quality` 作业应用两个覆盖：

   ```yaml
   include:
     - template: Jobs/Code-Quality.gitlab-ci.yml

   code_quality:
     services:            # 关闭 Docker-in-Docker
     tags:
       - cq-sans-dind     # 将此作业设置为仅在我们新的专用 runner 上运行
   ```

代码质量现在以标准 Docker 模式运行。

<a id="run-codeclimate-rootless-with-private-runners"></a>

### 使用私有 runner 以无根模式运行 CodeClimate

如果你正在使用私有 runner 并且希望[以无根 Docker 模式](https://docs.docker.com/engine/security/rootless/)运行代码质量扫描，代码质量需要进行一些特殊更改才能使其正常运行。这可能需要一个专用于仅运行代码质量作业的 runner，因为套接字绑定的更改可能会导致其他作业出现问题。

要使用无根私有 runner：

1. 注册一个新的 runner：

   将 `/run/user/<gitlab-runner-user>/docker.sock` 替换为 `gitlab-runner` 用户的本地 `docker.sock` 的路径。

   ```shell
   $ gitlab-runner register --executor "docker" \
     --docker-image="docker:cli" \
     --url "https://gitlab.com/" \
     --description "cq-rootless" \
     --tag-list "cq-rootless" \
     --locked="false" \
     --access-level="not_protected" \
     --docker-volumes "/cache" \
     --docker-volumes "/tmp/builds:/tmp/builds" \
     --docker-volumes "/run/user/<gitlab-runner-user>/docker.sock:/run/user/<gitlab-runner-user>/docker.sock" \
     --token "<project_token>" \
     --non-interactive \
     --builds-dir "/tmp/builds" \
     --env "DOCKER_HOST=unix:///run/user/<gitlab-runner-user>/docker.sock" \
     --docker-host "unix:///run/user/<gitlab-runner-user>/docker.sock"
   ```

   生成的配置：

   ```toml
   [[runners]]
     name = "cq-rootless"
     url = "https://gitlab.com/"
     token = "<project_token>"
     executor = "docker"
     builds_dir = "/tmp/builds"
     environment = ["DOCKER_HOST=unix:///run/user/<gitlab-runner-user>/docker.sock"]
     [runners.docker]
       tls_verify = false
       image = "docker:cli"
       privileged = false
       disable_entrypoint_overwrite = false
       oom_kill_disable = false
       disable_cache = false
       volumes = ["/cache", "/run/user/<gitlab-runner-user>/docker.sock:/run/user/<gitlab-runner-user>/docker.sock", "/tmp/builds:/tmp/builds"]
       shm_size = 0
       host = "unix:///run/user/<gitlab-runner-user>/docker.sock"
     [runners.cache]
       [runners.cache.s3]
       [runners.cache.gcs]
   ```

1. 对模板创建的 `code_quality` 作业应用以下覆盖：

   ```yaml
   code_quality:
     services:
     variables:
       DOCKER_SOCKET_PATH: /run/user/997/docker.sock
     tags:
       - cq-rootless
   ```

代码质量现在以标准 Docker 模式和无根模式运行。

如果你的目标是[使用无根 Podman 运行 Docker](https://docs.gitlab.com/runner/executors/docker/#use-podman-to-run-docker-commands) 来进行代码质量扫描，也需要相同的配置。确保将 `/run/user/<gitlab-runner-user>/docker.sock` 替换为你系统中正确的 `podman.sock` 路径，例如：`/run/user/<gitlab-runner-user>/podman/podman.sock`。

<a id="configure-kubernetes-or-openshift-runners"></a>

### 配置 Kubernetes 或 OpenShift runner

你必须设置 Docker-in-Docker 模式才能使用代码质量。Kubernetes executor [支持 Docker-in-Docker](https://docs.gitlab.com/runner/executors/kubernetes/#using-dockerdind)。

要确保代码质量作业可以在 Kubernetes executor 上运行：

- 如果你使用 TLS 与 Docker 守护进程通信，则 executor [必须以特权模式运行](https://docs.gitlab.com/runner/executors/kubernetes/#other-configtoml-settings)。此外，证书目录必须[被指定为卷挂载](../docker/using_docker_build.md#docker-in-docker-with-tls-enabled-in-kubernetes)。
- DinD 服务可能在代码质量作业开始前未完全启动。这是 [Kubernetes executor 故障排除](https://docs.gitlab.com/runner/executors/kubernetes/troubleshooting/#docker-cannot-connect-to-the-docker-daemon-at-tcpdocker2375-is-the-docker-daemon-running)中记录的一个限制。要解决此问题，请使用 `before_script` 等待 Docker 守护进程完全启动。有关示例，请参阅下一节中描述的 `.gitlab-ci.yml` 文件中的配置。

<a id="kubernetes"></a>

#### Kubernetes

要在 Kubernetes 中运行代码质量：

- Docker in Docker 服务必须作为服务容器添加到 `config.toml` 文件中。
- 服务容器中的 Docker 守护进程必须同时监听 TCP 和 UNIX 套接字，因为代码质量需要这两种套接字。
- Docker 套接字必须通过卷共享。

根据 [Docker 要求](https://docs.docker.com/reference/cli/docker/container/run/#privileged)，必须为服务容器启用特权标志。

```toml
[runners.kubernetes]

[runners.kubernetes.service_container_security_context]
privileged = true
allow_privilege_escalation = true

[runners.kubernetes.volumes]

[[runners.kubernetes.volumes.empty_dir]]
mount_path = "/var/run/"
name = "docker-sock"

[[runners.kubernetes.services]]
alias = "dind"
command = [
    "--host=tcp://0.0.0.0:2375",
    "--host=unix://var/run/docker.sock",
    "--storage-driver=overlay2"
]
entrypoint = ["dockerd"]
name = "docker:29.1.4-dind"
```

> [!note]
> 如果你使用 [极狐GitLab Runner Helm Chart](https://docs.gitlab.com/runner/install/kubernetes/)，你可以在 `values.yaml` 文件的 [`config` 字段](https://docs.gitlab.com/runner/install/kubernetes_helm_chart_configuration/)中使用前面的 Kubernetes 配置。

为确保你使用 `overlay2` [存储驱动](https://docs.docker.com/storage/storagedriver/select-storage-driver/)（它提供最佳的整体性能）：

- 指定 Docker CLI 通信的 `DOCKER_HOST`。
- 将 `DOCKER_DRIVER` 变量设置为空。

使用 `before_script` 部分等待 Docker 守护进程完全启动。从极狐GitLab Runner v16.9 开始，这也可以[通过仅设置 `HEALTHCHECK_TCP_PORT` 变量](https://docs.gitlab.com/runner/executors/kubernetes/#define-a-list-of-services)来完成。

```yaml
include:
  - template: Code-Quality.gitlab-ci.yml

code_quality:
  services: []
  variables:
    DOCKER_HOST: tcp://dind:2375
    DOCKER_DRIVER: ""
  before_script:
    - while ! docker info > /dev/null 2>&1; do sleep 1; done
```

<a id="openshift"></a>

#### OpenShift

对于 OpenShift，你应该使用 [极狐GitLab Runner Operator](https://docs.gitlab.com/runner/install/operator/)。
要授予服务容器中的 Docker 守护进程初始化其存储的权限，你必须将 `/var/lib` 目录挂载为卷挂载。

> [!note]
> 如果你无法将 `/var/lib` 目录挂载为卷挂载，你可以将 `--storage-driver` 设置为 `vfs`。
> 如果你选择 `vfs` 值，可能会对[性能](https://docs.docker.com/storage/storagedriver/select-storage-driver/)产生负面影响。

要配置 Docker 守护进程的权限：

1. 使用此配置模板创建一个 `config.toml` 文件来自定义 runner 的配置：

```toml
[[runners]]

[runners.kubernetes]

[runners.kubernetes.service_container_security_context]
privileged = true
allow_privilege_escalation = true

[runners.kubernetes.volumes]

[[runners.kubernetes.volumes.empty_dir]]
mount_path = "/var/run/"
name = "docker-sock"

[[runners.kubernetes.volumes.empty_dir]]
mount_path = "/var/lib/"
name = "docker-data"

[[runners.kubernetes.services]]
alias = "dind"
command = [
    "--host=tcp://0.0.0.0:2375",
    "--host=unix://var/run/docker.sock",
    "--storage-driver=overlay2"
]
entrypoint = ["dockerd"]
name = "docker:29.1.4-dind"
```

1. [将自定义配置设置到你的 runner](https://docs.gitlab.com/runner/configuration/configuring_runner_operator/#customize-configtoml-with-a-configuration-template)。
1. 可选。将[`特权`服务账户](https://docs.openshift.com/container-platform/3.11/admin_guide/manage_scc.html)附加到构建 Pod。这取决于你的 OpenShift 集群设置：

   ```shell
   oc create sa dind-sa
   oc adm policy add-scc-to-user anyuid -z dind-sa
   oc adm policy add-scc-to-user -z dind-sa privileged
   ```

1. 在 [`[runners.kubernetes]` 部分](https://docs.gitlab.com/runner/executors/kubernetes/#other-configtoml-settings)设置权限。
1. 设置作业定义与 Kubernetes 情况相同：

   ```yaml
   include:
   - template: Code-Quality.gitlab-ci.yml

   code_quality:
   services: []
   variables:
     DOCKER_HOST: tcp://dind:2375
     DOCKER_DRIVER: ""
   before_script:
     - while ! docker info > /dev/null 2>&1; do sleep 1; done
   ```

<a id="volumes-and-docker-storage"></a>

#### 卷和 Docker 存储
Docker 将其所有数据存储在 `/var/lib` 卷中，这可能导致很大的卷。要在集群中复用 Docker-in-Docker 存储，您可以使用 [持久卷](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) 作为替代方案。
<!--- end_remove -->