---
stage: Package
group: Container Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 容器虚拟仓库
description: 使用容器虚拟仓库缓存来自上游镜像仓库的容器镜像。
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Status: 测试版

{{< /details >}}

> [!flag]
> 此功能的可用性由功能标志控制。

极狐GitLab 容器虚拟仓库是一个本地代理，可用于缓存来自上游镜像仓库的容器镜像。它充当拉取式缓存，将频繁访问的镜像存储在本地，以减少带宽占用并提升构建性能。

<a id="prerequisites"></a>

## 先决条件

在使用容器虚拟仓库之前：

- 查看[先决条件](../_index.md#prerequisites)以使用虚拟仓库。
- 配置对虚拟仓库的身份验证。更多信息，请参见[向虚拟仓库进行身份验证](../_index.md#authenticate-to-the-virtual-registry)。

使用容器虚拟仓库时，请记住以下限制：

- 每个顶级群组最多可创建 `5` 个容器虚拟仓库。
- 每个容器虚拟仓库最多可设置 `5` 个上游。
- 未实现 Geo 支持。

<a id="manage-virtual-registries"></a>

## 管理虚拟仓库

为您的群组管理容器虚拟仓库。

您也可以[使用 API](../../../../api/container_virtual_registries.md)。

<a id="create-a-container-virtual-registry"></a>

### 创建容器虚拟仓库

要创建容器虚拟仓库：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的群组。该群组必须位于顶级。
1. 选择**部署** > **虚拟仓库**。
1. 如果您：
   - 已有镜像仓库，选择**创建镜像仓库**。从下拉列表中，选择**容器**。
   - 没有现有镜像仓库，从下拉列表中，选择**容器**。然后，选择**创建镜像仓库**。
1. 输入**名称**和可选的**描述**。
1. 选择**创建镜像仓库**。

<a id="manage-upstream-registries"></a>

## 管理上游镜像仓库

在虚拟仓库中管理上游容器镜像仓库。

<a id="create-a-container-upstream-registry"></a>

### 创建容器上游镜像仓库

创建容器上游镜像仓库以连接到虚拟仓库。

先决条件：

- 您必须有一个容器虚拟仓库。更多信息，请参见[创建虚拟仓库](#create-a-container-virtual-registry)。

要创建容器上游镜像仓库：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的群组。该群组必须位于顶级。
1. 选择**部署** > **虚拟仓库**。
1. 在**镜像仓库类型**下，选择**查看镜像仓库**。
1. 在**镜像仓库**标签页下，选择一个镜像仓库。
1. 选择**添加上游**。如果虚拟仓库已有上游，从下拉列表中，选择以下任一项：
   - **创建新上游**以配置上游。
   - **链接现有上游** > **选择现有上游**。
     1. 从下拉列表中，选择一个上游。
     1. 可选。选择**测试上游**以在创建前测试上游连接。
     1. 选择**添加上游**。
1. 填写字段。
   - 同时包含**用户名**和**密码**，或两者都不包含。如果未设置，将使用公开（匿名）请求访问上游。
   - 如果您想将上游连接到 Docker Hardened Images，请将以下内容用作**上游 URL**：

     ```plaintext
     https://dhi.io
     ```

   - 如果您想将上游连接到 Docker Hub，请将以下内容用作**上游 URL**：

     ```plaintext
     https://registry-1.docker.io
     ```

     Docker Hub 镜像仓库 API 托管在 `registry-1.docker.io`，而不是 `docker.io`。
     大多数容器工具会自动重写 `docker.io`，但虚拟仓库
     会代理到您提供的 URL。

     如果您使用 `https://docker.io`，镜像仓库会返回 HTML 而不是 OCI 响应。

   - **产物缓存期**默认为 24 小时。设置为 `0` 可禁用缓存条目检查。
   - 如果您想在创建前测试上游连接，选择**测试上游**。

1. 选择**创建上游**。

有关缓存有效期设置的更多信息，请参见[设置缓存有效期](../_index.md#set-the-cache-validity-period)。

<a id="authenticate-with-the-container-virtual-registry"></a>

## 使用容器虚拟仓库进行身份验证

容器虚拟仓库在与您的顶级群组关联的镜像仓库中存储并关联容器镜像。要访问容器镜像，您必须使用群组的容器虚拟仓库进行身份验证。

要手动进行身份验证，请运行以下命令：

```shell
echo "$CONTAINER_REGISTRY_PASSWORD" | docker login gitlab.example.com/virtual_registries/container/1 --username <your_username> --password-stdin
```

或者，使用[向虚拟仓库进行身份验证](../_index.md#authenticate-to-the-virtual-registry)中描述的任何方法配置身份验证。

容器虚拟仓库遵循 [Docker v2 令牌身份验证流程](https://distribution.github.io/distribution/spec/auth/token/)：

1. 客户端身份验证后，颁发给客户端的 JWT 令牌授权客户端拉取容器镜像。
1. 令牌按其过期时间失效。
1. 令牌过期后，大多数 Docker 客户端会存储用户凭据并自动请求新令牌，无需进一步操作。

<a id="pull-container-images-from-the-virtual-registry"></a>

## 从虚拟仓库拉取容器镜像

要通过虚拟仓库拉取容器镜像：

1. 使用虚拟仓库进行身份验证。
1. 使用虚拟仓库 URL 格式拉取镜像：

   ```plaintext
   gitlab.example.com/virtual_registries/container/<registry_id>/<image_path>:<tag>
   ```

例如：

- 按标签拉取镜像：

  ```shell
  docker pull gitlab.example.com/virtual_registries/container/1/library/alpine:latest
  ```

- 按摘要拉取镜像：

  ```shell
  docker pull gitlab.example.com/virtual_registries/container/1/library/alpine@sha256:c9375e662992791e3f39e919b26f510e5254b42792519c180aad254e6b38f4dc
  ```

- 在 `Dockerfile`中拉取镜像：

  ```dockerfile
  FROM gitlab.example.com/virtual_registries/container/1/library/alpine:latest
  ```

- 在`.gitlab-ci.yml` 文件中拉取镜像：

  ```yaml
  image: gitlab.example.com/virtual_registries/container/1/library/alpine:latest
  ```

当您拉取镜像时，虚拟仓库会：

1. 检查镜像是否已缓存。
   1. 如果镜像已缓存，且根据上游的 `cache_validity_hours` 设置仍然有效，则从缓存中提供该镜像。
   1. 如果镜像未缓存或缓存无效，则从配置的上游镜像仓库获取并缓存该镜像。
1. 将镜像提供给您的 Docker 客户端。

<a id="virtual-registry-cache-validation-for-images"></a>

### 镜像的虚拟仓库缓存验证

像 `alpine:latest` 这样的镜像标签始终拉取镜像的最新版本。新版本包含更新后的镜像清单。当清单发生变化时，容器虚拟仓库不会拉取新镜像。

相反，容器虚拟仓库会：

1. 检查上游中的 `cache_validity_hours` 设置，以确定镜像清单何时失效。
1. 向上游发送 HEAD 请求。如果清单无效，则拉取新镜像。

例如，如果您的流水线拉取 `node:latest`，并且您已将 `cache_validity_period` 设置为 24 小时，则虚拟仓库会缓存该镜像，并在缓存过期或上游中的 `node:latest` 发生变化时更新它。

<a id="troubleshooting"></a>

## 故障排除

<a id="authentication-error-http-basic-access-denied"></a>

### 身份验证错误：`HTTP Basic: Access Denied`

如果您在向虚拟仓库进行身份验证时收到 `HTTP Basic: Access denied` 错误，请参阅[双因素认证故障排除](../../../profile/account/two_factor_authentication_troubleshooting.md#error-http-basic-access-denied-if-a-password-was-provided-for-git-authentication-)。

<a id="virtual-registry-connection-failure"></a>

### 虚拟仓库连接失败

如果未设置服务别名，`docker:20.10.16` 镜像将无法找到 `dind` 服务，并抛出类似以下内容的错误：

```plaintext
error during connect: Get http://docker:2376/v1.39/info: dial tcp: lookup docker on 192.168.0.1:53: no such host
```

要解决此错误，请为 Docker 服务设置服务别名：

```yaml
services:
  - name: docker:20.10.16-dind
    alias: docker
```

<a id="virtual-registry-authentication-issues-from-cicd-jobs"></a>

### 来自 CI/CD 作业的虚拟仓库身份验证问题

极狐GitLab Runner 使用 CI/CD 作业令牌自动进行身份验证。但是，底层 Docker 引擎仍受其[授权解析过程](https://gitlab.cn/docs/runner/configuration/advanced-configuration/#precedence-of-docker-authorization-resolving)约束。

身份验证机制中的错误配置可能导致 `HTTP Basic: Access denied` 和 `403: Access forbidden` 错误。

您可以使用作业日志查看用于向虚拟仓库进行身份验证的身份验证机制：

```plaintext
Authenticating with credentials from $DOCKER_AUTH_CONFIG
```

```plaintext
Authenticating with credentials from /root/.docker/config.json
```

```plaintext
Authenticating with credentials from job payload (GitLab Registry)
```

确保您使用的是预期的身份验证机制。

<a id="not-found-or-404-error-when-pulling-image"></a>

### 拉取镜像时出现 `Not Found` 或 `404` 错误

类似这样的错误可能表明：

- 运行作业的用户对于拥有虚拟仓库的群组，不具有访客、计划者、报告者、开发者、维护者或所有者角色，也不具有最小访问权限、且具备 `read_virtual_registry` 能力的自定义角色。
- URL 中的虚拟仓库 ID 不正确。
- 上游镜像仓库不包含所请求的镜像。
- 虚拟仓库未配置任何上游。

示例错误消息：

```plaintext
ERROR: gitlab.example.com/virtual_registries/container/1/library/alpine:latest: not found
```

```plaintext
ERROR: Job failed: failed to pull image "gitlab.example.com/virtual_registries/container/1/library/alpine:latest" with specified policies [always]:
Error response from daemon: error parsing HTTP 404 response body: unexpected end of JSON input: "" (manager.go:237:1s)
```

要解决这些错误：

1. 确认您对于该群组具有访客、计划者、报告者、开发者、维护者或所有者角色，或具有最小访问权限、且具备 `read_virtual_registry` 能力的自定义角色。
1. 确认虚拟仓库 ID 正确。
1. 检查虚拟仓库是否至少配置了一个上游。
1. 确认该镜像存在于上游镜像仓库中。

<a id="error-unexpected-eof-when-the-s3-bucket-has-object-lock-enabled"></a>

### 错误：当 S3 存储桶启用对象锁定时出现 `unexpected EOF`

当依赖代理的对象存储存储桶启用了 S3 对象锁定时，容器镜像拉取可能会在某一层中途失败，并出现 `unexpected EOF`。

来自 Docker 客户端的示例错误：

```plaintext
sha256:9db411d588e2: Downloading [==================================================>]  12.18MB/12.18MB
unexpected EOF
```

GitLab Workhorse 日志显示来自上游 S3
`PutObject` 调用的 `400` 响应：

```plaintext
operation error S3: PutObject, https response error StatusCode: 400, ...
InvalidRequest: Content-MD5 OR x-amz-checksum- HTTP header is required for
Put Object requests with Object Lock parameters
```

当存储桶配置了对象锁定时，S3 要求每个 `PutObject` 请求都包含完整性标头。默认情况下，Workhorse 使用的 AWS SDK 不会发送这些标头。上传失败，从而截断了
Workhorse 向 Docker 客户端流式传输的响应。

要验证原因：

1. 检查依赖代理存储桶是否启用了对象锁定：

   ```shell
   aws s3api get-object-lock-configuration --bucket DEPENDENCY_PROXY_BUCKET
   ```

   如果启用了对象锁定，响应会包含
   `"ObjectLockEnabled": "Enabled"`。
1. 在拉取失败期间检查 Workhorse 日志。
   `InvalidRequest: Content-MD5 OR x-amz-checksum-`消息可确认原因。

要解决此问题：

1. 配置 Workhorse 中的 AWS SDK 以发送校验和标头。在 Workhorse 容器上设置以下两个环境变量：

   - `AWS_REQUEST_CHECKSUM_CALCULATION=when_supported`
   - `AWS_RESPONSE_CHECKSUM_VALIDATION=when_supported`

1. 对于：
   - 使用 Helm chart 安装的极狐GitLab，将变量添加到您的
`values.yaml`：

   ```yaml
   gitlab:
     webservice:
       extraEnv:
         AWS_REQUEST_CHECKSUM_CALCULATION: when_supported
         AWS_RESPONSE_CHECKSUM_VALIDATION: when_supported
   ```

   然后，应用这些值：

   ```shell
   helm upgrade gitlab gitlab/gitlab -f values.yaml
   ```

   - 使用 Linux 软件包安装的极狐GitLab，将变量添加到
`/etc/gitlab/gitlab.rb`：

   ```ruby
   gitlab_workhorse['env'] = {
     'AWS_REQUEST_CHECKSUM_CALCULATION' => 'when_supported',
     'AWS_RESPONSE_CHECKSUM_VALIDATION' => 'when_supported'
   }
   ```

   然后，重新配置：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

在 Workhorse 使用新环境变量重启后，重试拉取。下一个请求会将 blob 存储到 S3，并将完整层返回给
Docker 客户端。
