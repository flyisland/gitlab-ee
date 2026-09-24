---
stage: Package
group: Container Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 容器镜像的依赖代理
description: 为了减少上游容器镜像的数据传输，为你的容器镜像配置极狐GitLab 依赖代理。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

极狐GitLab 容器镜像的依赖代理是一个本地代理，你可以将其用于频繁访问的上游镜像。

在 CI/CD 场景中，依赖代理接收请求，并从 registry 返回上游镜像，充当拉取缓存（pull-through cache）。

## 先决条件

要使用容器镜像的依赖代理，必须为极狐GitLab 实例启用它。它默认处于启用状态，但[管理员可以将其关闭](../../../administration/packages/dependency_proxy.md)。

### 支持的镜像和软件包

支持以下镜像和软件包。

| 镜像/软件包    | 极狐GitLab 版本 |
| ---------------- | -------------- |
| Docker           | 14.0+         |

有关计划添加的列表，请查看
[方向页面](https://about.gitlab.com/direction/package/#dependency-proxy)。

## 为群组启用或关闭依赖代理

{{< history >}}

- 在极狐GitLab 15.0 中，所需角色从 开发者 改为 维护者。
- 在极狐GitLab 17.0 中，所需角色从 维护者 改为 所有者。

{{< /history >}}

要为群组启用或关闭依赖代理：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的群组。
1. 在左侧边栏中，选择 **设置** > **软件包与镜像仓库**。
1. 展开 **依赖代理** 部分。
1. 要启用代理，打开 **启用代理**。要将其关闭，关闭此开关。

此设置仅影响群组的依赖代理。只有管理员才能为整个极狐GitLab 实例[打开或关闭依赖代理](../../../administration/packages/dependency_proxy.md)。

## 查看容器镜像的依赖代理

要查看容器镜像的依赖代理：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的群组。
1. 在左侧边栏中，选择 **运维** > **依赖代理**。

依赖代理不适用于项目。

## 为 Docker 镜像使用依赖代理

你可以将极狐GitLab 用作 Docker 镜像的源。

先决条件：

- 你的镜像必须存储在 [Docker Hub](https://hub.docker.com/) 上。

### 对容器镜像的依赖代理进行身份验证

{{< history >}}

- 在极狐GitLab 15.0 中，功能标志 `dependency_proxy_for_private_groups` 被移除。
- 在极狐GitLab 16.3 中，引入了对群组访问令牌的支持。
- 在极狐GitLab 17.11 中，引入了部署令牌范围 `read_virtual_registry` 和 `write_virtual_registry`，并带有一个名为 `dependency_proxy_read_write_scopes` 的功能标志。默认禁用。
- 在极狐GitLab 18.0 中，功能标志 `dependency_proxy_read_write_scopes` 被移除，该功能 GA。

{{< /history >}}

因为容器镜像的依赖代理将 Docker 镜像存储在与你的群组关联的空间中，所以你必须对其进行身份验证。

请遵循[使用私有镜像仓库镜像的说明](../../../ci/docker/using_docker_images.md#access-an-image-from-a-private-container-registry)，但不要使用 `registry.example.com:5000`，而是使用你的极狐GitLab 域名，不带端口，例如 `gitlab.example.com`。

> [!note]
> [管理员模式](../../../administration/settings/sign_in_restrictions.md#admin-mode) 不适用于容器镜像的依赖代理的身份验证。如果你是启用了管理员模式的管理员，并且你创建了一个没有 `admin_mode` 范围的个人访问令牌，即使启用了管理员模式，该令牌仍然有效。

例如，要手动登录：

```shell
echo "$CONTAINER_REGISTRY_PASSWORD" | docker login gitlab.example.com --username my_username --password-stdin
```

你可以使用以下方法进行身份验证：

- 你的极狐GitLab 用户名和密码。
- [极狐GitLab CLI](https://gitlab.cn/docs/cli/)。
- [个人访问令牌](../../profile/personal_access_tokens.md)。
- [群组部署令牌](../../project/deploy_tokens/_index.md)。
- 该群组的[群组访问令牌](../../group/settings/group_access_tokens.md)。

令牌应将其范围设置为以下之一：

- `api`：授予完整的 API 访问权限。
- `read_registry`：授予对容器镜像仓库的只读访问权限。
- `write_registry`：授予对容器镜像仓库的读写访问权限。
- `read_virtual_registry`：通过群组级依赖代理授予对容器镜像的只读（拉取）访问权限。仅在启用依赖代理时可用。
- `write_virtual_registry`：授予对群组级依赖代理缓存的写入权限，包括填充和清理缓存的镜像。同时也授予通过该缓存进行拉取的权限。
  不授予对项目容器镜像仓库的推送或删除访问权限。
  仅在启用依赖代理时可用。

在对容器镜像的依赖代理进行身份验证时，令牌必须包含以下范围组合之一：

- 容器镜像仓库范围：`read_registry` 和 `write_registry`。
- 依赖代理范围：`read_virtual_registry` 和 `write_virtual_registry`。当你通过依赖代理拉取镜像时，极狐GitLab 会将数据写入群组级依赖代理缓存。

使用个人访问令牌或用户名和密码访问容器镜像的依赖代理的用户，必须对他们从中拉取镜像的群组具有 访客、计划者、报告者、开发者、维护者 或 所有者 角色。

容器镜像的依赖代理遵循 [Docker v2 令牌身份验证流程](https://distribution.github.io/distribution/spec/auth/token/)，向客户端颁发 JWT 用于拉取。身份验证后颁发的 JWT 会在一段时间后过期。当令牌过期时，大多数 Docker 客户端会存储你的凭据，并自动请求一个新的令牌，无需进一步操作。

令牌过期时间是一个[可配置设置](../../../administration/packages/dependency_proxy.md#changing-the-jwt-expiration)。在 JihuLab.com 上，过期时间为 15 分钟。

#### SAML SSO

当启用 [SSO 强制](../../group/saml_sso/_index.md#sso-enforcement) 时，用户必须在通过 SSO 登录后，才能通过容器镜像的依赖代理拉取镜像。

SSO 强制也会影响[自动合并](../../project/merge_requests/auto_merge.md)。如果在自动合并触发前 SSO 会话过期，合并流水线将无法通过依赖代理拉取镜像。

#### 在 CI/CD 中进行身份验证

Runner 会自动登录到容器镜像的依赖代理。要通过依赖代理拉取镜像，请使用以下[预定义变量](../../../ci/variables/predefined_variables.md)之一：

- `CI_DEPENDENCY_PROXY_GROUP_IMAGE_PREFIX` 通过顶级群组进行拉取。
- `CI_DEPENDENCY_PROXY_DIRECT_GROUP_IMAGE_PREFIX` 通过子群组或项目所在的直属群组进行拉取。

拉取最新 alpine 镜像的示例：

```yaml
# .gitlab-ci.yml
image: ${CI_DEPENDENCY_PROXY_GROUP_IMAGE_PREFIX}/alpine:latest
```

还有其他可以使用的额外预定义 CI/CD 变量：

- `CI_DEPENDENCY_PROXY_USER`：用于登录依赖代理的 CI/CD 用户。
- `CI_DEPENDENCY_PROXY_PASSWORD`：用于登录依赖代理的 CI/CD 密码。
- `CI_DEPENDENCY_PROXY_SERVER`：用于登录依赖代理的服务器。
- `CI_DEPENDENCY_PROXY_GROUP_IMAGE_PREFIX`：用于从顶级群组通过依赖代理拉取镜像的镜像前缀。
- `CI_DEPENDENCY_PROXY_DIRECT_GROUP_IMAGE_PREFIX`：用于从项目所属的直属群组或子群组通过依赖代理拉取镜像的镜像前缀。

`CI_DEPENDENCY_PROXY_SERVER`、`CI_DEPENDENCY_PROXY_GROUP_IMAGE_PREFIX` 和 `CI_DEPENDENCY_PROXY_DIRECT_GROUP_IMAGE_PREFIX` 包含服务器端口。如果你显式包含依赖代理路径，则必须包含端口，除非你已在不包含端口的情况下手动登录依赖代理：

```shell
docker pull gitlab.example.com:443/my-group/dependency_proxy/containers/alpine:latest
```

使用依赖代理构建镜像的示例：

```plaintext
# Dockerfile
FROM gitlab.example.com:443/my-group/dependency_proxy/containers/alpine:latest
```

```yaml
# .gitlab-ci.yml
image: docker:20.10.16

variables:
  DOCKER_HOST: tcp://docker:2375
  DOCKER_TLS_CERTDIR: ""

services:
  - docker:20.10.16-dind

build:
  image: docker:20.10.16-cli
  before_script:
    - echo "$CI_DEPENDENCY_PROXY_PASSWORD" | docker login $CI_DEPENDENCY_PROXY_SERVER -u $CI_DEPENDENCY_PROXY_USER --password-stdin
  script:
    - docker build -t test .
```

你也可以使用[自定义 CI/CD 变量](../../../ci/variables/_index.md#for-a-project)来存储和访问你的个人访问令牌或部署令牌。

### 对 Docker Hub 进行身份验证

{{< history >}}

- 在极狐GitLab 17.10 中，添加了对 Docker Hub 凭据的支持。
- 在极狐GitLab 17.11 中，添加了 UI 支持。

{{< /history >}}

默认情况下，依赖代理在从 Docker Hub 拉取镜像时不使用凭据。你可以使用你的 Docker Hub 凭据或令牌配置 Docker Hub 身份验证。

要对 Docker Hub 进行身份验证，你可以使用：

- 你的 Docker Hub 用户名和密码。
  - 此方法不适用于[强制单点登录（SSO）](https://docs.docker.com/security/faqs/single-sign-on/enforcement-faqs/#does-docker-sso-support-authenticating-through-the-command-line) 的 Docker Hub 组织。
- Docker Hub [个人访问令牌](https://docs.docker.com/security/for-developers/access-tokens/)。
- Docker Hub [组织访问令牌](https://docs.docker.com/security/for-admins/access-tokens/)。

#### 配置凭据

要为群组的依赖代理设置 Docker Hub 凭据：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的群组。
1. 在左侧边栏中，选择 **设置** > **软件包与镜像仓库**。
1. 展开 **依赖代理** 部分。
1. 打开 **启用代理**。
1. 在 **Docker Hub 身份验证** 下，输入你的凭据：
   - **身份** 是你的用户名（用于密码或个人访问令牌）或组织名称（用于组织访问令牌）。
   - **密钥** 是你的密码、个人访问令牌或组织访问令牌。

   你必须填写两个字段，或者将两个字段都留空。如果你将两个字段都留空，发送到 Docker Hub 的请求将保持未认证状态。

#### 使用 GraphQL API 配置凭据

要使用 [GraphQL API](../../../api/graphql/_index.md) 在依赖代理设置中设置 Docker Hub 凭据：

1. 进入 GraphiQL：
   - 对于 JihuLab.com，请使用 <https://jihulab.com/-/graphql-explorer>。
   - 对于私有化部署实例，请使用 `https://gitlab.example.com/-/graphql-explorer`。
1. 在 GraphiQL 中，输入此 mutation：

   ```graphql
   mutation {
     updateDependencyProxySettings(input: {
       enabled: true,
         identity: "<identity>",
         secret: "<secret>",
         groupPath: "<group path>"
     }) {
       dependencyProxySetting {
        enabled
        identity
       }
       errors
     }
   }
   ```

   其中：
   - `<identity>` 是你的用户名（用于密码或个人访问令牌）或组织名称（用于组织访问令牌）。
   - `<secret>` 是你的密码、个人访问令牌或组织访问令牌。
   - `<group path>` 是依赖代理所在群组的路径。

1. 选择 **Play**。
1. 检查结果窗格中是否有任何错误。

#### 验证你的凭据

对依赖代理进行身份验证后，通过拉取 Docker 镜像来验证你的 Docker Hub 凭据：

```shell
docker pull gitlab.example.com/groupname/dependency_proxy/containers/alpine:latest
```

如果身份验证成功，你将在你的 [Docker Hub 用量仪表板](https://hub.docker.com/usage/pulls) 中看到活动。

### 在依赖代理缓存中存储 Docker 镜像

要在依赖代理存储中存储 Docker 镜像：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的群组。
1. 在左侧边栏中，选择 **运维** > **依赖代理**。
1. 复制 **依赖代理镜像前缀**。
1. 使用以下命令之一。在这些示例中，镜像是 `alpine:latest`。
1. 你也可以通过摘要拉取镜像，以确切指定要拉取哪个版本的镜像。

   - 通过标签拉取镜像，将镜像添加到你的 [`.gitlab-ci.yml`](../../../ci/yaml/_index.md#image) 文件中：

     ```shell
     image: gitlab.example.com/groupname/dependency_proxy/containers/alpine:latest
     ```

   - 通过摘要拉取镜像，将镜像添加到你的 [`.gitlab-ci.yml`](../../../ci/yaml/_index.md#image) 文件中：

     ```shell
     image: ${CI_DEPENDENCY_PROXY_GROUP_IMAGE_PREFIX}/alpine@sha256:c9375e662992791e3f39e919b26f510e5254b42792519c180aad254e6b38f4dc
     ```

   - 手动拉取 Docker 镜像：

     ```shell
     docker pull gitlab.example.com/groupname/dependency_proxy/containers/alpine:latest
     ```

   - 将 URL 添加到 `Dockerfile`：

     ```shell
     FROM gitlab.example.com/groupname/dependency_proxy/containers/alpine:latest
     ```

极狐GitLab 从 Docker Hub 拉取 Docker 镜像，并将 blobs 缓存到极狐GitLab 服务器上。下次你拉取相同镜像时，极狐GitLab 会从 Docker Hub 获取关于该镜像的最新信息，但从极狐GitLab 服务器提供现有的 blobs。

## 减少存储空间占用

有关减少容器镜像依赖代理的存储空间占用的信息，请参见 [减少依赖代理存储空间占用](reduce_dependency_proxy_storage.md)。

## Docker Hub 速率限制与依赖代理

Docker Hub 对拉取实施[速率限制](https://docs.docker.com/docker-hub/usage/pulls/)。如果你的极狐GitLab [CI/CD 配置](../../../ci/_index.md) 使用了来自 Docker Hub 的镜像，那么每次作业运行都可能计为一次拉取。为了帮助规避此限制，你可以改为从依赖代理缓存中拉取你的镜像。

当你拉取镜像时（通过使用类似 `docker pull` 的命令，或在 `.gitlab-ci.yml` 文件中使用 `image: foo:latest`），Docker 客户端会发出一系列请求：

1. 请求镜像清单（manifest）。清单包含有关如何构建镜像的信息。
1. 使用该清单，Docker 客户端一次一个地请求一组层（也称为 blobs）。

Docker Hub 的速率限制基于清单的 GET 请求数量。依赖代理会缓存给定镜像的清单和 blobs，因此当你再次请求它时，就不必联系 Docker Hub 了。

### 极狐GitLab 如何知道缓存的带标签镜像是否过时？

如果你使用的是像 `alpine:latest` 这样的镜像标签，该镜像会随着时间而改变。每次更改时，清单都会包含关于要请求哪些 blobs 的不同信息。依赖代理不会在每次清单更改时都拉取新镜像；它只在清单变得过时时才进行检查。

Docker 不会将清单的 HEAD 请求计入速率限制。你可以为 `alpine:latest` 发出 HEAD 请求，查看头部返回的摘要（校验和）值，并确定清单是否已更改。

依赖代理的所有请求都以 HEAD 请求开始。只有当清单变得过时时，才会拉取新镜像。

例如，如果你的流水线每五分钟拉取一次 `node:latest`，依赖代理会缓存整个镜像，并且只有在 `node:latest` 发生变化时才进行更新。因此，在六个小时内，你只有一次拉取，而不是对镜像发出 360 次请求（这超出了 Docker Hub 的速率限制），除非清单在此期间发生了变化。

### 检查你的 Docker Hub 速率限制

如果你想知道你已经向 Docker Hub 发出了多少次请求以及还剩多少次，你可以在你的 Runner 上，甚至在 CI/CD 脚本中运行以下命令：

```shell
# 注意，你必须安装 jq 才能运行此命令
TOKEN=$(curl "https://auth.docker.io/token?service=registry.docker.io&scope=repository:ratelimitpreview/test:pull" | jq --raw-output .token) && curl --head --header "Authorization: Bearer $TOKEN" "https://registry-1.docker.io/v2/ratelimitpreview/test/manifests/latest" 2>&1 | grep --ignore-case RateLimit
...
```

输出类似于：

```shell
RateLimit-Limit: 100;w=21600
RateLimit-Remaining: 98;w=21600
```

这个例子显示了在六小时内总共限制 100 次拉取，还剩 98 次。

#### 在 CI/CD 作业中检查速率限制

这个示例显示了一个极狐GitLab CI/CD 作业，它使用安装了 `jq` 和 `curl` 的镜像：

```yaml
hub_docker_quota_check:
    stage: build
    image: alpine:latest
    tags:
        - <optional_runner_tag>
    before_script: apk add curl jq
    script:
      - |
        TOKEN=$(curl "https://auth.docker.io/token?service=registry.docker.io&scope=repository:ratelimitpreview/test:pull" | jq --raw-output .token) && curl --head --header "Authorization: Bearer $TOKEN" "https://registry-1.docker.io/v2/ratelimitpreview/test/manifests/latest" 2>&1
```

## 故障排除

### 身份验证错误：`HTTP Basic: Access Denied`

如果你在对依赖代理进行身份验证时收到 `HTTP Basic: Access denied` 错误，请参阅[双重身份验证故障排除指南](../../profile/account/two_factor_authentication_troubleshooting.md)。

### 依赖代理连接失败

如果没有设置服务别名，`docker:20.10.16` 镜像会找不到 `dind` 服务，并且抛出类似以下的错误：

```plaintext
error during connect: Get http://docker:2376/v1.39/info: dial tcp: lookup docker on 192.168.0.1:53: no such host
```

这可以通过为 Docker 服务设置服务别名来解决：

```yaml
services:
    - name: ${CI_DEPENDENCY_PROXY_GROUP_IMAGE_PREFIX}/docker:18.09.7-dind
      alias: docker
```

### 从 CI/CD 作业对依赖代理进行身份验证时出现问题

极狐GitLab Runner 会自动向依赖代理进行身份验证。然而，底层的 Docker 引擎仍然受其[授权解决流程](https://docs.gitlab.com/runner/configuration/advanced-configuration/#precedence-of-docker-authorization-resolving) 的制约。

身份验证机制中的错误配置可能会导致 `HTTP Basic: Access denied` 和 `403: Access forbidden` 错误。

你可以使用作业日志来查看用于对依赖代理进行身份验证的身份验证机制：

```plaintext
Authenticating with credentials from $DOCKER_AUTH_CONFIG
```

```plaintext
Authenticating with credentials from /root/.docker/config.json
```

```plaintext
Authenticating with credentials from job payload (GitLab Registry)
```

确保你使用的是预期的身份验证机制。

### 拉取镜像时出现 `Not Found` 或 `404` 错误

类似以下错误可能表明运行作业的用户对依赖代理群组不具备最低 访客 角色：

- ```plaintext
  ERROR: gitlab.example.com:443/group1/dependency_proxy/containers/alpine:latest: not found

  failed to solve with frontend dockerfile.v0: failed to create LLB definition: gitlab.example.com:443/group1/dependency_proxy/containers/alpine:latest: not found
  ```

- ```plaintext
  ERROR: Job failed: failed to pull image "gitlab.example.com:443/group1/dependency_proxy/containers/alpine:latest" with specified policies [always]:
  Error response from daemon: error parsing HTTP 404 response body: unexpected end of JSON input: "" (manager.go:237:1s)
  ```

### 从依赖代理运行镜像时出现 `exec format error`

> [!note]
> 此问题已在极狐GitLab 16.3 中解决。
> 对于 16.2 或更早版本的极狐GitLab 私有化部署实例，你可以将实例更新到 16.3，或使用下面记录的解决方法。

如果你尝试在极狐GitLab 16.2 或更早版本的基于 ARM 的 Docker 安装上使用依赖代理，则会出现此错误。在拉取带有特定标签的镜像时，依赖代理仅支持 x86_64 架构。

作为一种解决方法，你可以指定镜像的 SHA256 来强制依赖代理拉取不同的架构：

```shell
docker pull ${CI_DEPENDENCY_PROXY_GROUP_IMAGE_PREFIX}/library/docker:20.10.3@sha256:bc9dcf5c8e5908845acc6d34ab8824bca496d6d47d1b08af3baf4b3adb1bd8fe
```

在此示例中，`bc9dcf5c8e5908845acc6d34ab8824bca496d6d47d1b08af3baf4b3adb1bd8fe` 是基于 ARM 的镜像的 SHA256。

### 恢复备份后出现 `MissingFile` 错误

如果你遇到 `MissingFile` 或 `Cannot read file` 错误，这可能是因为
[备份归档文件](../../../administration/backup_restore/backup_gitlab.md) 不包含 `gitlab-rails/shared/dependency_proxy/` 的内容。

要解决此已知问题，你可以使用 `rsync`、`scp` 或类似工具从作为备份源的极狐GitLab 实例复制受影响的文件或整个 `gitlab-rails/shared/dependency_proxy/` 文件夹结构。

如果不需要这些数据，你可以使用以下命令删除数据库条目：

```shell
gitlab-psql -c "DELETE FROM dependency_proxy_blobs; DELETE FROM dependency_proxy_blob_states; DELETE FROM dependency_proxy_manifest_states; DELETE FROM dependency_proxy_manifests;"
```