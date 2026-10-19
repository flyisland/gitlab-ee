---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用 BuildKit 构建 Docker 镜像
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

[BuildKit](https://docs.docker.com/build/buildkit/) 是 Docker 使用的构建引擎，
提供多平台构建和构建缓存。

<a id="buildkit-methods"></a>

## BuildKit 方法

BuildKit 提供以下方法来构建 Docker 镜像：

| 方法              | 安全要求                 | 命令                     | 适用场景 |
| ----------------- | ------------------------ | ------------------------ | ----------------- |
| BuildKit rootless | 无需特权容器             | `buildctl-daemonless.sh` | 需要最高安全性，或作为 Kaniko 的替代方案 |
| Docker Buildx     | 需要 `docker:dind`   | `docker buildx`          | 熟悉 Docker 工作流 |
| 原生 BuildKit     | 需要 `docker:dind`   | `buildctl`               | 需要高级 BuildKit 控制 |

<a id="prerequisites"></a>

## 先决条件

- 使用 Docker 执行器的极狐GitLab Runner
- 使用 Docker Buildx 需要 Docker 19.03 或更高版本
- 一个包含 `Dockerfile`的项目

<a id="buildkit-rootless"></a>

## BuildKit rootless

独立模式下的 BuildKit 提供无需 Docker 守护进程依赖的 rootless 镜像构建。
此方法完全消除了特权容器，并可直接替代 Kaniko 构建。

> [!note]
> Rootless 构建仍需要允许 BuildKit 用于创建用户命名空间和挂载点的系统调用的 runner。
> JihuLab.com 上的托管 runner 允许这些调用，且无需额外配置，因为它们以
> [特权模式](../runners/hosted_runners/linux.md#docker-in-docker-support)运行。
> 在使用 Docker 执行器但未启用特权模式的私有化部署 runner 上，构建可能会因权限错误而失败。
> 有关更多信息，请参见
> [rootless 构建因权限错误而失败](#rootless-build-fails-with-permission-errors)。
> 如果您无法更改 runner 安全设置，请改用
> [rootless Buildah](buildah_rootless_multi_arch.md) 来构建镜像。

与其他方法的主要区别：

- 使用 `moby/buildkit:rootless` 镜像
- 包含 `BUILDKITD_FLAGS: --oci-worker-no-process-sandbox` 以支持 rootless 运行
- 使用 `buildctl-daemonless.sh` 自动管理 BuildKit 守护进程
- 不依赖 Docker 守护进程或特权容器
- 需要手动设置镜像仓库认证

<a id="authenticate-with-container-registries"></a>

### 向容器镜像仓库进行认证

极狐GitLab CI/CD 通过预定义变量为极狐GitLab 容器镜像仓库提供自动认证。
对于 BuildKit rootless，您必须手动创建 Docker 配置文件。

<a id="authenticate-with-the-gitlab-container-registry"></a>

#### 向极狐GitLab 容器镜像仓库进行认证

极狐GitLab 自动提供以下预定义变量：

- `CI_REGISTRY`：镜像仓库 URL
- `CI_REGISTRY_USER`：镜像仓库用户名
- `CI_REGISTRY_PASSWORD`：镜像仓库密码

要为 rootless 构建配置认证，请在作业中添加 `before_script` 配置。例如：

```yaml
before_script:
  - mkdir -p ~/.docker
  - echo "{\"auths\":{\"$CI_REGISTRY\":{\"username\":\"$CI_REGISTRY_USER\",\"password\":\"$CI_REGISTRY_PASSWORD\"}}}" > ~/.docker/config.json
```

<a id="authenticate-with-multiple-registries"></a>

#### 向多个镜像仓库进行认证

要向其他容器镜像仓库进行认证，请在 `before_script` 部分中合并认证条目。例如：

```yaml
before_script:
  - mkdir -p ~/.docker
  - |
    echo "{
      \"auths\": {
        \"${CI_REGISTRY}\": {
          \"auth\": \"$(printf "%s:%s" "${CI_REGISTRY_USER}" "${CI_REGISTRY_PASSWORD}" | base64 | tr -d '\n')\"
        },
        \"docker.io\": {
          \"auth\": \"$(printf "%s:%s" "${DOCKER_HUB_USER}" "${DOCKER_HUB_PASSWORD}" | base64 | tr -d '\n')\"
        }
      }
    }" > ~/.docker/config.json
```

<a id="authenticate-with-the-dependency-proxy"></a>

#### 向依赖代理进行认证

要通过极狐GitLab 依赖代理拉取镜像，请在 `before_script` 部分中配置认证。例如：

```yaml
before_script:
  - mkdir -p ~/.docker
  - |
    echo "{
      \"auths\": {
        \"${CI_REGISTRY}\": {
          \"auth\": \"$(printf "%s:%s" "${CI_REGISTRY_USER}" "${CI_REGISTRY_PASSWORD}" | base64 | tr -d '\n')\"
        },
        \"$(echo -n $CI_DEPENDENCY_PROXY_SERVER | awk -F[:] '{print $1}')\": {
          \"auth\": \"$(printf "%s:%s" ${CI_DEPENDENCY_PROXY_USER} "${CI_DEPENDENCY_PROXY_PASSWORD}" | base64 | tr -d '\n')\"
        }
      }
    }" > ~/.docker/config.json
```

有关更多信息，请参见[在 CI/CD 中进行认证](../../user/packages/dependency_proxy/_index.md#authenticate-within-cicd)。

<a id="build-images-in-rootless-mode"></a>

### 以 rootless 模式构建镜像

要在不依赖 Docker 守护进程的情况下构建镜像，请添加类似以下示例的作业：

```yaml
build-rootless:
  image:
    name: moby/buildkit:rootless
    entrypoint: [""]
  stage: build
  variables:
    BUILDKITD_FLAGS: --oci-worker-no-process-sandbox
  before_script:
    - mkdir -p ~/.docker
    - echo "{\"auths\":{\"$CI_REGISTRY\":{\"username\":\"$CI_REGISTRY_USER\",\"password\":\"$CI_REGISTRY_PASSWORD\"}}}" > ~/.docker/config.json
  script:
    - |
      buildctl-daemonless.sh build \
        --frontend dockerfile.v0 \
        --local context=. \
        --local dockerfile=. \
        --output type=image,name=$CI_REGISTRY_IMAGE:$CI_COMMIT_SHA,push=true
```

必须使用 `entrypoint: [""]` 覆盖。默认情况下，`moby/buildkit:rootless` 镜像会将 BuildKit 守护进程作为长期运行的服务启动。如果不进行覆盖，作业会运行守护进程而不是构建命令，并一直挂起直到作业超时。

<a id="build-multi-platform-images-in-rootless-mode"></a>

### 以 rootless 模式构建多平台镜像

要以 rootless 模式为多种架构构建镜像，请配置作业以指定目标平台。例如：

```yaml
build-multiarch-rootless:
  image:
    name: moby/buildkit:rootless
    entrypoint: [""]
  stage: build
  variables:
    BUILDKITD_FLAGS: --oci-worker-no-process-sandbox
  before_script:
    - mkdir -p ~/.docker
    - echo "{\"auths\":{\"$CI_REGISTRY\":{\"username\":\"$CI_REGISTRY_USER\",\"password\":\"$CI_REGISTRY_PASSWORD\"}}}" > ~/.docker/config.json
  script:
    - |
      buildctl-daemonless.sh build \
        --frontend dockerfile.v0 \
        --local context=. \
        --local dockerfile=. \
        --opt platform=linux/amd64,linux/arm64 \
        --output type=image,name=$CI_REGISTRY_IMAGE:$CI_COMMIT_SHA,push=true
```

<a id="use-caching-in-rootless-mode"></a>

### 在 rootless 模式中使用缓存

要启用基于镜像仓库的缓存以加快后续构建，请在构建作业中配置缓存导入和导出。例如：

```yaml
build-cached-rootless:
  image:
    name: moby/buildkit:rootless
    entrypoint: [""]
  stage: build
  variables:
    BUILDKITD_FLAGS: --oci-worker-no-process-sandbox
    CACHE_IMAGE: $CI_REGISTRY_IMAGE:cache
  before_script:
    - mkdir -p ~/.docker
    - echo "{\"auths\":{\"$CI_REGISTRY\":{\"username\":\"$CI_REGISTRY_USER\",\"password\":\"$CI_REGISTRY_PASSWORD\"}}}" > ~/.docker/config.json
  script:
    - |
      buildctl-daemonless.sh build \
        --frontend dockerfile.v0 \
        --local context=. \
        --local dockerfile=. \
        --export-cache type=registry,ref=$CACHE_IMAGE \
        --import-cache type=registry,ref=$CACHE_IMAGE \
        --output type=image,name=$CI_REGISTRY_IMAGE:$CI_COMMIT_SHA,push=true
```

<a id="use-a-registry-mirror-in-rootless-mode"></a>

### 在 rootless 模式中使用镜像仓库镜像

镜像仓库镜像可加快镜像拉取速度，并有助于应对速率限制或网络限制。

要配置镜像仓库镜像，请创建一个 `buildkit.toml` 文件来指定镜像端点。例如：

```yaml
build-mirror-rootless:
  image:
    name: moby/buildkit:rootless
    entrypoint: [""]
  stage: build
  variables:
    BUILDKITD_FLAGS: --oci-worker-no-process-sandbox --config /tmp/buildkit.toml
  before_script:
    - mkdir -p ~/.docker
    - echo "{\"auths\":{\"$CI_REGISTRY\":{\"username\":\"$CI_REGISTRY_USER\",\"password\":\"$CI_REGISTRY_PASSWORD\"}}}" > ~/.docker/config.json
    - cat <<'EOF' > /tmp/buildkit.toml
      [registry."docker.io"]
        mirrors = ["mirror.example.com"]
      EOF
  script:
    - |
      buildctl-daemonless.sh build \
        --frontend dockerfile.v0 \
        --local context=. \
        --local dockerfile=. \
        --output type=image,name=$CI_REGISTRY_IMAGE:$CI_COMMIT_SHA,push=true
```

在此示例中，将 `mirror.example.com` 替换为您的镜像仓库镜像 URL。

<a id="configure-proxy-settings"></a>

### 配置代理设置

如果您的极狐GitLab Runner 在 HTTP(S) 代理后面运行，请在作业中将代理设置配置为变量。例如：

```yaml
build-behind-proxy:
  image:
    name: moby/buildkit:rootless
    entrypoint: [""]
  stage: build
  variables:
    BUILDKITD_FLAGS: --oci-worker-no-process-sandbox
    http_proxy: <your-proxy>
    https_proxy: <your-proxy>
    no_proxy: <your-no-proxy>
  before_script:
    - mkdir -p ~/.docker
    - echo "{\"auths\":{\"$CI_REGISTRY\":{\"username\":\"$CI_REGISTRY_USER\",\"password\":\"$CI_REGISTRY_PASSWORD\"}}}" > ~/.docker/config.json
  script:
    - |
      buildctl-daemonless.sh build \
        --frontend dockerfile.v0 \
        --local context=. \
        --local dockerfile=. \
        --build-arg http_proxy=$http_proxy \
        --build-arg https_proxy=$https_proxy \
        --build-arg no_proxy=$no_proxy \
        --output type=image,name=$CI_REGISTRY_IMAGE:$CI_COMMIT_SHA,push=true
```

在此示例中，将 `<your-proxy>` 和 `<your-no-proxy>` 替换为您的代理配置。

<a id="add-custom-certificates"></a>

### 添加自定义证书

要推送到使用自定义 CA 证书的镜像仓库，请在守护进程启动前在 BuildKit 配置文件中配置该证书。例如：

```yaml
build-with-custom-certs:
  image:
    name: moby/buildkit:rootless
    entrypoint: [""]
  stage: build
  variables:
    BUILDKITD_FLAGS: --oci-worker-no-process-sandbox
  before_script:
    - mkdir -p "$HOME/.docker"
    - echo "{\"auths\":{\"$CI_REGISTRY\":{\"username\":\"$CI_REGISTRY_USER\",\"password\":\"$CI_REGISTRY_PASSWORD\"}}}" > "$HOME/.docker/config.json"
    - REG_HOST="${CI_REGISTRY%%/*}"
    - mkdir -p "$HOME/.config/buildkit/certs/$REG_HOST"
    - echo "$CA_CERT" > "$HOME/.config/buildkit/certs/$REG_HOST/ca.pem"
    - |
      cat > "$HOME/.config/buildkit/buildkitd.toml" << EOT
      [registry."$REG_HOST"]
        ca = ["$HOME/.config/buildkit/certs/$REG_HOST/ca.pem"]
      EOT
    - export SSL_CERT_FILE="$HOME/.config/buildkit/certs/$REG_HOST/ca.pem"
  script:
    - |
      buildctl-daemonless.sh build \
        --frontend dockerfile.v0 \
        --local context=. \
        --local dockerfile=. \
        --output type=image,name=$CI_REGISTRY_IMAGE:$CI_COMMIT_SHA,push=true
```

在此示例中：

- `REG_HOST="${CI_REGISTRY%%/*}"` 从镜像仓库 URL 中提取主机名。
- `buildkitd.toml` 配置 BuildKit 信任目标镜像仓库的 CA 证书。
  BuildKit 会从 `$HOME/.config/buildkit/` 自动发现此文件。
- 除了 `buildkitd.toml` 之外，还需要 `SSL_CERT_FILE`，以覆盖在
  BuildKit 守护进程完全初始化之前建立的 TLS 连接。

添加一个 `CA_CERT` CI/CD 变量，其中包含完整的证书链，包括根证书和所有中间证书。由于 PEM 证书包含换行符，`CA_CERT`的值无法被掩码。要掩码该值，请改用[文件类型变量](../variables/_index.md#use-file-type-cicd-variables)，并在 `before_script`中将 `echo "$CA_CERT"` 替换为 `cat "$CA_CERT"`。

如果目标镜像仓库使用与您的极狐GitLab 实例相同的证书颁发机构，并且 runner 配置了 `tls-ca-file`，您可以引用预定义的 [`CI_SERVER_TLS_CA_FILE`](../variables/predefined_variables.md) 变量，而无需使用 `CA_CERT` 变量。

<a id="migrate-from-kaniko-to-buildkit"></a>

## 从 Kaniko 迁移到 BuildKit

BuildKit rootless 是 Kaniko 的安全替代方案，提供更高的性能、更好的
缓存以及增强的安全功能，且无需特权容器。

<a id="update-your-configuration"></a>

### 更新您的配置

将现有的 Kaniko 配置更新为使用 BuildKit rootless 方法。例如：

之前，使用 Kaniko：

```yaml
build:
  image:
    name: gcr.io/kaniko-project/executor:debug
    entrypoint: [""]
  script:
    - /kaniko/executor
      --context $CI_PROJECT_DIR
      --dockerfile $CI_PROJECT_DIR/Dockerfile
      --destination $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
```

之后，使用 BuildKit rootless：

```yaml
build:
  image:
    name: moby/buildkit:rootless
    entrypoint: [""]
  variables:
    BUILDKITD_FLAGS: --oci-worker-no-process-sandbox
  before_script:
    - mkdir -p ~/.docker
    - echo "{\"auths\":{\"$CI_REGISTRY\":{\"username\":\"$CI_REGISTRY_USER\",\"password\":\"$CI_REGISTRY_PASSWORD\"}}}" > ~/.docker/config.json
  script:
    - |
      buildctl-daemonless.sh build \
        --frontend dockerfile.v0 \
        --local context=. \
        --local dockerfile=. \
        --output type=image,name=$CI_REGISTRY_IMAGE:$CI_COMMIT_SHA,push=true
```

<a id="custom-ca-certificates"></a>

### 自定义 CA 证书

如果您的 Kaniko 作业使用了自定义 CA 证书，您必须为 BuildKit rootless 显式配置这些证书。与 Kaniko 不同，`moby/buildkit:rootless` 镜像不包含系统证书存储。您必须在守护进程启动前在 BuildKit 配置文件中配置 CA 证书。

要将自定义 CA 证书配置迁移到 BuildKit rootless：

1. 将完整证书链存储在名为 `CA_CERT`的 [CI/CD 变量](../variables/_index.md)中。
   包括根证书和所有中间证书。

1. 更新您的作业配置，以使用 `buildkitd.toml` 文件和 `SSL_CERT_FILE`
   环境变量。
   完整示例请参见[添加自定义证书](#add-custom-certificates)。

<a id="alternative-buildkit-methods"></a>

## 其他 BuildKit 方法

如果您不需要 rootless 构建，BuildKit 还提供其他方法，这些方法需要 `docker:dind` 服务，但提供熟悉的工作流或高级功能。

<a id="docker-buildx"></a>

### Docker Buildx

Docker Buildx 在保持熟悉命令语法的同时，通过 BuildKit 功能扩展了 Docker 构建能力。
此方法需要 `docker:dind` 服务。

<a id="build-basic-images"></a>

#### 构建基本镜像

要使用 Buildx 构建 Docker 镜像，请为作业配置 `docker:dind` 服务并创建 `buildx` 构建器。例如：

```yaml
variables:
  DOCKER_TLS_CERTDIR: "/certs"

build-image:
  image: docker:cli
  services:
    - docker:dind
  stage: build
  before_script:
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
    - docker buildx create --use --driver docker-container --name builder
    - docker buildx inspect --bootstrap
  script:
    - docker buildx build --tag $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA --push .
  after_script:
    - docker buildx rm builder
```

<a id="build-multi-platform-images"></a>

#### 构建多平台镜像

多平台构建在单个构建命令中为不同架构创建镜像。生成的清单支持多种架构，Docker 会为每个部署目标自动选择合适的镜像。

要为多种架构构建镜像，请添加 `--platform` 标志以指定目标架构。例如：

```yaml
variables:
  DOCKER_TLS_CERTDIR: "/certs"

build-multiplatform:
  image: docker:cli
  services:
    - docker:dind
  stage: build
  before_script:
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
    - docker buildx create --use --driver docker-container --name multibuilder
    - docker buildx inspect --bootstrap
  script:
    - docker buildx build
        --platform linux/amd64,linux/arm64
        --tag $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
        --push .
  after_script:
    - docker buildx rm multibuilder
```

<a id="use-build-caching"></a>

#### 使用构建缓存

基于镜像仓库的缓存将构建层存储在容器镜像仓库中，以便在多次构建之间复用。

`mode=max` 选项会将所有层导出到缓存，并为后续构建提供最大的复用潜力。

要使用构建缓存，请在构建命令中添加缓存选项。例如：

```yaml
variables:
  DOCKER_TLS_CERTDIR: "/certs"
  CACHE_IMAGE: $CI_REGISTRY_IMAGE:cache

build-with-cache:
  image: docker:cli
  services:
    - docker:dind
  stage: build
  before_script:
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
    - docker buildx create --use --driver docker-container --name cached-builder
    - docker buildx inspect --bootstrap
  script:
    - docker buildx build
        --cache-from type=registry,ref=$CACHE_IMAGE
        --cache-to type=registry,ref=$CACHE_IMAGE,mode=max
        --tag $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
        --push .
  after_script:
    - docker buildx rm cached-builder
```

<a id="native-buildkit"></a>

### 原生 BuildKit

使用原生 BuildKit `buildctl` 命令可对构建过程进行更多控制。此方法需要 `docker:dind` 服务。

要直接使用 BuildKit，请为作业配置 BuildKit 镜像和 `docker:dind` 服务。例如：

```yaml
variables:
  DOCKER_TLS_CERTDIR: "/certs"

build-with-buildkit:
  image: moby/buildkit:latest
  services:
    - docker:dind
  stage: build
  before_script:
    - mkdir -p ~/.docker
    - echo "{\"auths\":{\"$CI_REGISTRY\":{\"username\":\"$CI_REGISTRY_USER\",\"password\":\"$CI_REGISTRY_PASSWORD\"}}}" > ~/.docker/config.json
  script:
    - |
      buildctl build \
        --frontend dockerfile.v0 \
        --local context=. \
        --local dockerfile=. \
        --output type=image,name=$CI_REGISTRY_IMAGE:$CI_COMMIT_SHA,push=true
```

<a id="troubleshooting"></a>

## 故障排除

使用 BuildKit 构建镜像时，您可能会遇到以下问题。

<a id="build-fails-with-authentication-errors"></a>

### 构建因认证错误而失败

如果您遇到镜像仓库认证失败：

- 确认 `CI_REGISTRY_USER` 和 `CI_REGISTRY_PASSWORD` 变量可用。
- 检查您是否具有目标镜像仓库的推送权限。
- 对于外部镜像仓库，请确保在项目的 CI/CD 变量中正确配置了认证凭据。

<a id="rootless-build-fails-with-permission-errors"></a>

### Rootless 构建因权限错误而失败

如果 rootless 构建因权限错误而失败，请检查以下内容：

- 确保已设置 `BUILDKITD_FLAGS: --oci-worker-no-process-sandbox`。
- 确认极狐GitLab Runner 已分配足够的资源。
- 确认您的 `Dockerfile`中没有尝试任何特权操作。

在 Kubernetes runner 上，与 AppArmor 相关的挂载权限错误也可能阻止 rootless
容器。有关更多信息，请参见
[Kubernetes 执行器上的 AppArmor 挂载权限错误](https://gitlab.cn/docs/runner/executors/kubernetes/troubleshooting/#error-failed-to-share-mount-point-permission-denied)。

如果失败与以下错误匹配，则说明 runner 安全策略阻止了 rootless BuildKit
所需的系统调用。

<a id="error-forkexec-procselfexe-operation-not-permitted"></a>

#### 错误：`fork/exec /proc/self/exe: operation not permitted`

在使用 Docker 执行器但未启用特权模式的 runner 上，您可能会遇到以下错误之一：

```plaintext
could not connect to unix:///run/user/1000/buildkit/buildkitd.sock after 10 trials
[rootlesskit:parent] error: failed to start the child: fork/exec /proc/self/exe: operation not permitted
```

出现此问题是因为 runner 的 seccomp 配置文件阻止了 rootless
BuildKit 所需的系统调用。JihuLab.com 上的托管 runner 以特权模式运行，不受影响。

要在私有化部署 runner 上解决此问题，请将 Docker 执行器的
[`security_opt`](https://gitlab.cn/docs/runner/configuration/advanced-configuration/#the-runnersdocker-section)
设置配置为仅允许 BuildKit 所需的系统调用。

> [!warning]
> 不要将 `security_opt` 设置为 `seccomp:unconfined`。虽然这样可以解决错误，但它
> 会禁用容器的默认 seccomp 配置文件，从而移除对危险
> 系统调用的防护并降低隔离性。请改用仅允许所需调用的自定义 seccomp 配置文件，
> 或使用 rootless Buildah 构建镜像。

<a id="error-invalid-local-stat-pathtoimagedockerfile-not-a-directory"></a>

### 错误：`invalid local: stat path/to/image/Dockerfile: not a directory`

您可能会遇到错误 `invalid local: stat path/to/image/Dockerfile: not a directory`。

当您为 `--local dockerfile=` 参数指定文件路径而不是目录路径时，会出现此问题。BuildKit 期望的是一个包含名为 `Dockerfile`的文件的目录路径。

要解决此问题，请使用目录路径而不是完整文件路径。例如：

- 使用：`--local dockerfile=path/to/image`
- 而不是：`--local dockerfile=path/to/image/Dockerfile`

<a id="multi-platform-builds-fail"></a>

### 多平台构建失败

对于多平台构建问题：

- 确认您的 `Dockerfile`中的基础镜像支持目标架构。
- 检查所有目标平台是否都有特定于架构的依赖项。
- 考虑在 `Dockerfile`中使用条件语句来处理特定于架构的逻辑。
