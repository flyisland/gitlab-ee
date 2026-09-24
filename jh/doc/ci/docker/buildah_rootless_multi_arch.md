---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用 Buildah 构建多平台镜像
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用 Buildah 为多种 CPU 架构构建镜像。多平台构建创建的镜像可在不同硬件平台上运行，Docker 会自动为每个部署目标选择合适的镜像。

<a id="prerequisites"></a>

## 先决条件

- 用于构建镜像的 Dockerfile
- （可选）在不同 CPU 架构上运行的极狐GitLab Runner

<a id="build-multi-platform-images"></a>

## 构建多平台镜像

要使用 Buildah 构建多平台镜像：

1. 为每个目标架构配置单独的构建作业。
1. 创建一个清单作业，将特定架构的镜像组合起来。
1. 配置清单作业，将组合后的清单推送到你的镜像仓库。

在各自架构上运行作业可避免因 CPU 指令转换而导致的性能问题。但如有需要，你也可以在单一架构上运行两个构建。为非原生架构构建可能导致构建时间变长。

以下示例使用了两个 [Linux 上的极狐GitLab 托管 Runner](../runners/hosted_runners/linux.md)：

- `saas-linux-small-arm64`
- `saas-linux-small-amd64`

```yaml
stages:
  - build

variables:
  STORAGE_DRIVER: vfs
  BUILDAH_FORMAT: docker
  FQ_IMAGE_NAME: "$CI_REGISTRY_IMAGE:latest"

default:
  image: quay.io/buildah/stable
  before_script:
    - echo "$CI_REGISTRY_PASSWORD" | buildah login -u "$CI_REGISTRY_USER" --password-stdin $CI_REGISTRY

build-amd64:
  stage: build
  tags:
    - saas-linux-small-amd64
  script:
    - buildah build --platform=linux/amd64 -t $CI_REGISTRY_IMAGE:amd64 .
    - buildah push $CI_REGISTRY_IMAGE:amd64

build-arm64:
  stage: build
  tags:
    - saas-linux-small-arm64
  script:
    - buildah build --platform=linux/arm64/v8 -t $CI_REGISTRY_IMAGE:arm64 .
    - buildah push $CI_REGISTRY_IMAGE:arm64

create_manifest:
  stage: build
  needs: ["build-arm64", "build-amd64"]
  tags:
    - saas-linux-small-amd64
  script:
    - buildah manifest create $FQ_IMAGE_NAME
    - buildah manifest add $FQ_IMAGE_NAME docker://$CI_REGISTRY_IMAGE:amd64
    - buildah manifest add $FQ_IMAGE_NAME docker://$CI_REGISTRY_IMAGE:arm64
    - buildah manifest push --all $FQ_IMAGE_NAME
```

此流水线创建了带有 `amd64` 和 `arm64` 标签的特定架构镜像，然后将它们组合成一个可通过 `latest` 标签使用的单一清单。

<a id="troubleshooting"></a>

## 故障排除

<a id="build-fails-with-authentication-errors"></a>

### 构建因认证错误而失败

如果你遇到镜像仓库认证失败：

- 验证 `CI_REGISTRY_USER` 和 `CI_REGISTRY_PASSWORD` 变量是否可用。
- 检查你是否拥有目标镜像仓库的推送权限。
- 对于外部镜像仓库，请确保在项目的 CI/CD 变量中正确配置了认证凭据。

<a id="multi-platform-builds-fail"></a>

### 多平台构建失败

对于多平台构建问题：

- 验证 `Dockerfile` 中的基础镜像是否支持目标架构。
- 检查特定架构的依赖项是否适用于所有目标平台。
- 考虑在 `Dockerfile` 中使用条件语句来实现特定架构的逻辑。

<a id="error-error-during-unshare-clonenewuser-operation-not-permitted"></a>

### 错误：`Error during unshare(CLONE_NEWUSER): Operation not permitted`

当你在 CI/CD 作业中以无根模式使用 Buildah 或 [Docker BuildKit](using_buildkit.md) 构建 Docker 镜像时，可能会遇到 `Error during unshare(CLONE_NEWUSER): Operation not permitted` 错误。

当未为无根容器构建设置所需的安全选项时，会发生此错误。

要解决此问题，请在 Runner 的 `config.toml` 文件中配置 `[runners.docker]` 部分：

```toml
[runners.docker]
  security_opt = ["seccomp:unconfined", "apparmor:unconfined"]
```

有关更多信息，请参见 [BuildKit 无根 Docker 构建和安全要求](https://github.com/moby/buildkit/blob/master/docs/rootless.md#docker)。