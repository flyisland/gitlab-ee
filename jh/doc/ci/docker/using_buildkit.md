---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用 BuildKit 构建 Docker 镜像
---

{{< details >}}

- Tier: 基础版、专业版、旗舰版
- Offering: JihuLab.com、私有化部署

{{< /details >}}

<a id="buildkit-methods"></a>

## BuildKit 方法

[BuildKit](https://docs.docker.com/build/buildkit/) 是 Docker 使用的构建引擎，提供多平台构建和构建缓存功能。

BuildKit 提供以下方法来构建 Docker 镜像：

| 方法            | 安全要求     | 命令                 | 适用场景 |
| ----------------- | ------------------------ | ------------------------ | ----------------- |
| BuildKit 无根模式 | 不需要特权容器 | `buildctl-daemonless.sh` | 最大安全性或替代 Kaniko |
| Docker Buildx     | 需要 `docker:dind`   | `docker buildx`          | 熟悉的 Docker 工作流程 |
| 原生 BuildKit   | 需要 `docker:dind`   | `buildctl`               | 高级 BuildKit 控制 |

<a id="prerequisites"></a>

## 前提条件

- 带有 Docker 执行器的极狐GitLab Runner
- Docker 19.03 或更高版本以使用 Docker Buildx
- 带有 `Dockerfile` 的项目

<a id="buildkit-rootless"></a>

## BuildKit 无根模式

独立模式下的 BuildKit 提供无根镜像构建，无需 Docker 守护进程依赖。该方法完全消除了特权容器，并可直接替代 Kaniko 构建。

与其他方法的主要区别：

- 使用 `moby/buildkit:rootless` 镜像
- 包含 `BUILDKITD_FLAGS: --oci-worker-no-process-sandbox` 以实现无根操作
- 使用 `buildctl-daemonless.sh` 自动管理 BuildKit 守护进程
- 无需 Docker 守护进程或特权容器依赖
- 需要手动设置镜像仓库认证

<a id="authenticate-with-container-registries"></a>

### 与容器镜像仓库认证

极狐GitLab CI/CD 通过预定义变量为极狐GitLab 容器镜像仓库提供自动认证。对于 BuildKit 无根模式，你必须手动创建 Docker 配置文件。

<a id="authenticate-with-the-gitlab-container-registry"></a>

#### 与极狐GitLab 容器镜像仓库认证

极狐GitLab 自动提供以下预定义变量：

- `CI_REGISTRY`：镜像仓库 URL
- `CI_REGISTRY_USER`：镜像仓库用户名
- `CI_REGISTRY_PASSWORD`：镜像仓库密码

要为无根构建配置认证，在你的作业中添加 `before_script` 配置。例如：

```yaml
before_script:
  - mkdir -p ~/.docker
  - echo "{\"auths\":{\"$CI_REGISTRY\":{\"username\":\"$CI_REGISTRY_USER\",\"password\":\"$CI_REGISTRY_PASSWORD\"}}}" > ~/.docker/config.json
```

<a id="authenticate-with-multiple-registries"></a>

#### 与多个镜像仓库认证

要与额外的容器镜像仓库认证，在你的 `before_script` 部分组合认证条目。例如：

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

#### 与依赖代理认证

要通过极狐GitLab 依赖代理拉取镜像，在你的 `before_script` 部分配置认证。例如：

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

更多信息，请参见[在 CI/CD 中进行认证](../../user/packages/dependency_proxy/_index.md#authenticate-within-cicd)。

<a id="build-images-in-rootless-mode"></a>

### 在无根模式下构建镜像

要在没有 Docker 守护进程依赖的情况下构建镜像，添加一个类似以下示例的作业：

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

<a id="build-multi-platform-images-in-rootless-mode"></a>

### 在无根模式下构建多平台镜像

要在无根模式下为多种架构构建镜像，配置你的作业以指定目标平台。例如：

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

### 在无根模式下使用缓存

要启用基于镜像仓库的缓存以实现更快的后续构建，在你的构建作业中配置缓存导入和导出。例如：

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

### 在无根模式下使用镜像仓库镜像

镜像仓库镜像可提供更快的镜像拉取速度，并有助于应对速率限制或网络限制。

要配置镜像仓库镜像，创建一个指定镜像端点的 `buildkit.toml` 文件。例如：

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

在此示例中，将 `mirror.example.com` 替换为你的镜像仓库镜像 URL。

<a id="configure-proxy-settings"></a>

### 配置代理设置

如果你的极狐GitLab Runner 运行在 HTTP(S) 代理后面，请在你的作业中将代理设置配置为变量。例如：

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

在此示例中，将 `<your-proxy>` 和 `<your-no-proxy>` 替换为你的代理配置。

<a id="add-custom-certificates"></a>

### 添加自定义证书

要推送到使用自定义 CA 证书的镜像仓库，请在构建之前将证书添加到容器的证书存储中。例如：

```yaml
build-with-custom-certs:
  image:
    name: moby/buildkit:rootless
    entrypoint: [""]
  stage: build
  variables:
    BUILDKITD_FLAGS: --oci-worker-no-process-sandbox
  before_script:
    - export SSL_CERT_FILE="$HOME/ca_chain.pem"
    - cat /etc/ssl/certs/ca-certificates.crt > "$SSL_CERT_FILE"
    - echo "$MY_CA_CERT" >> "$SSL_CERT_FILE"
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

在此示例中，将 `MY_CA_CERT` 变量填充为你的 CA 证书的完整内容，包括根证书和所有中间证书。

<a id="migrate-from-kaniko-to-buildkit"></a>

## 从 Kaniko 迁移到 BuildKit

BuildKit 无根模式是 Kaniko 的安全替代方案。它在保持无根操作的同时，提供了改进的性能、更好的缓存和增强的安全功能。

<a id="update-your-configuration"></a>

### 更新你的配置

将你现有的 Kaniko 配置更新为使用 BuildKit 无根方法。例如：

使用 Kaniko 之前：

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

使用 BuildKit 无根模式之后：

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

<a id="alternative-buildkit-methods"></a>

## 替代的 BuildKit 方法

如果你不需要无根构建，BuildKit 提供了需要 `docker:dind` 服务的其他方法，但能提供熟悉的工作流程或高级功能。

<a id="docker-buildx"></a>

### Docker Buildx

Docker Buildx 扩展了 Docker 的构建能力，并提供了 BuildKit 的特性，同时保持了熟悉的命令语法。此方法需要 `docker:dind` 服务。

<a id="build-basic-images"></a>

#### 构建基本镜像

要使用 Buildx 构建 Docker 镜像，请使用 `docker:dind` 服务配置你的作业，并创建一个 `buildx` 构建器。例如：

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

多平台构建可在单个构建命令中为不同架构创建镜像。生成的清单支持多种架构，Docker 会自动为每个部署目标选择合适的镜像。

要为多种架构构建镜像，添加 `--platform` 标志以指定目标架构。例如：

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

基于镜像仓库的缓存将构建层存储在容器镜像仓库中，以便在不同构建之间重用。

`mode=max` 选项将所有层导出到缓存，并为后续构建提供最大的重用潜力。

要使用构建缓存，在你的构建命令中添加缓存选项。例如：

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

使用原生 BuildKit `buildctl` 命令可以更精细地控制构建过程。此方法需要 `docker:dind` 服务。

要直接使用 BuildKit，请使用 BuildKit 镜像和 `docker:dind` 服务配置你的作业。例如：

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

<a id="build-fails-with-authentication-errors"></a>

### 构建因认证错误而失败

如果你遇到镜像仓库认证失败：

- 验证 `CI_REGISTRY_USER` 和 `CI_REGISTRY_PASSWORD` 变量是否可用。
- 检查你是否有对目标镜像仓库的推送权限。
- 对于外部镜像仓库，确保在你的项目 CI/CD 变量中正确配置了认证凭据。

<a id="rootless-build-fails-with-permission-errors"></a>

### 无根构建因权限错误而失败

对于无根模式下的权限相关问题：

- 确保设置了 `BUILDKITD_FLAGS: --oci-worker-no-process-sandbox`。
- 验证极狐GitLab Runner 是否分配了足够的资源。
- 检查你的 `Dockerfile` 中没有尝试执行特权操作。

如果你在 Kubernetes runner 上收到 `[rootlesskit:child ] error: failed to share mount point: /: permission denied` 错误，这是因为 AppArmor 阻止了 BuildKit 所需的挂载系统调用。

要解决此问题，请在你的 runner 配置中添加以下内容：

```toml
[runners.kubernetes.pod_annotations]
  "container.apparmor.security.beta.kubernetes.io/build" = "unconfined"
```

<a id="error-invalid-local-stat-pathtoimagedockerfile-not-a-directory"></a>

### 错误：`invalid local: stat path/to/image/Dockerfile: not a directory`

你可能会遇到一个错误，提示 `invalid local: stat path/to/image/Dockerfile: not a directory`。

当你在 `--local dockerfile=` 参数中指定文件路径而不是目录路径时，会出现此问题。BuildKit 期望一个包含名为 `Dockerfile` 文件的目录路径。

要解决此问题，请使用目录路径而不是完整文件路径。例如：

- 使用：`--local dockerfile=path/to/image`
- 而不是：`--local dockerfile=path/to/image/Dockerfile`

<a id="multi-platform-builds-fail"></a>

### 多平台构建失败

对于多平台构建问题：

- 验证你的 `Dockerfile` 中的基础镜像是否支持目标架构。
- 检查所有目标平台是否有特定架构的依赖项。
- 考虑在 `Dockerfile` 中为特定架构的逻辑使用条件语句。

