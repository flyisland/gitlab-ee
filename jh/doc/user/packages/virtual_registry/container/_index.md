---
stage: Package
group: Container Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 容器虚拟注册中心
description: 使用容器虚拟注册中心缓存来自上游注册中心的容器镜像。
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Status: 测试版

{{< /details >}}

{{< history >}}

- 在极狐GitLab 18.5 中引入，有一个名为 `container_virtual_registries` 的功能标志。默认禁用。
- 在极狐GitLab 18.9 中从实验阶段转为测试版。
- 在极狐GitLab 18.10 中于 JihuLab.com、私有化部署和 GitLab Dedicated 上启用。

{{< /history >}}

> [!flag]
> 此功能的可用性由功能标志控制。
> 更多信息，请参阅历史记录。

极狐GitLab 容器虚拟注册中心是一个本地代理，可用于缓存来自上游注册中心的容器镜像。它充当拉取式缓存，将频繁访问的镜像存储在本地，以减少带宽使用并提高构建性能。

## 准备工作

<a id="prerequisites"></a>

在使用容器虚拟注册中心之前：

- 查看使用虚拟注册中心的[准备工作](../_index.md#prerequisites)。
- 配置对虚拟注册中心的认证。更多信息，请参阅[认证到虚拟注册中心](../_index.md#authenticate-to-the-virtual-registry)。

使用容器虚拟注册中心时，请记住以下限制：

- 每个顶级群组最多可以创建 `5` 个容器虚拟注册中心。
- 对于给定容器虚拟注册中心，最多只能设置 `5` 个上游。
- 未实现 Geo 支持。

## 管理虚拟注册中心

<a id="manage-virtual-registries"></a>

{{< history >}}

- 在极狐GitLab 18.10 中引入，有一个名为 `ui_for_container_virtual_registries` 的功能标志。
- 在极狐GitLab 18.11 中更改为名为 `container_virtual_registries` 的功能标志。功能标志 `ui_for_container_virtual_registries` 已移除。

{{< /history >}}

为你的群组管理容器虚拟注册中心。

你也可以[使用 API](../../../../api/container_virtual_registries.md)。

### 创建容器虚拟注册中心

<a id="create-a-container-virtual-registry"></a>

要创建容器虚拟注册中心：

1. 在顶部栏中，选择**搜索或跳转到**并找到你的群组。此群组必须是顶级群组。
1. 选择**部署** > **虚拟注册中心**。
1. 如果你：
   - 已有注册中心，选择**创建注册中心**。从下拉列表中，选择**容器**。
   - 没有注册中心，从下拉列表中，选择**容器**。然后，选择**创建注册中心**。
1. 输入**名称**和可选的**描述**。
1. 选择**创建注册中心**。

## 管理上游注册中心

<a id="manage-upstream-registries"></a>

管理虚拟注册中心中的上游容器注册中心。

### 创建容器上游注册中心

<a id="create-a-container-upstream-registry"></a>

创建容器上游注册中心以连接到虚拟注册中心。

准备工作：

- 你必须有一个容器虚拟注册中心。更多信息，请参阅[创建虚拟注册中心](#create-a-container-virtual-registry)。

要创建容器上游注册中心：

1. 在顶部栏中，选择**搜索或跳转到**并找到你的群组。此群组必须是顶级群组。
1. 选择**部署** > **虚拟注册中心**。
1. 在**注册中心类型**下，选择**查看注册中心**。
1. 在**注册中心**选项卡下，选择一个注册中心。
1. 选择**添加上游**。如果虚拟注册中心已有上游，从下拉列表中，选择以下任一选项：
   - **创建新上游**以配置上游。
   - **链接现有上游** > **选择现有上游**。
     1. 从下拉列表中，选择一个上游。
     1. 可选。选择**测试上游**以在创建之前测试上游连接。
     1. 选择**添加上游**。
1. 完成字段。
   - 同时包含**用户名**和**密码**，或都不包含。如果未设置，则使用公开（匿名）请求访问上游。
1. 选择**创建上游**。

有关缓存有效性设置的更多信息，请参阅[设置缓存有效期](../_index.md#set-the-cache-validity-period)。

## 认证到容器虚拟注册中心

<a id="authenticate-with-the-container-virtual-registry"></a>

容器虚拟注册中心将容器镜像存储并关联到与你的顶级群组关联的注册中心。
要访问容器镜像，你必须认证到你的群组的容器虚拟注册中心。

要手动认证，请运行以下命令：

```shell
echo "$CONTAINER_REGISTRY_PASSWORD" | docker login gitlab.example.com/virtual_registries/container/1 --username <your_username> --password-stdin
```

或者，使用[认证到虚拟注册中心](../_index.md#authenticate-to-the-virtual-registry)中描述的任何方法配置认证。

容器虚拟注册中心遵循 [Docker v2 令牌认证流程](https://distribution.github.io/distribution/spec/auth/token/)：

1. 客户端认证后，颁发给客户端的 JWT 令牌授权客户端拉取容器镜像。
1. 令牌根据其过期时间失效。
1. 当令牌过期时，大多数 Docker 客户端会存储用户凭证并自动请求新令牌，无需进一步操作。

## 从虚拟注册中心拉取容器镜像

<a id="pull-container-images-from-the-virtual-registry"></a>

要通过虚拟注册中心拉取容器镜像：

1. 认证到虚拟注册中心。
1. 使用虚拟注册中心 URL 格式拉取镜像：

   ```plaintext
   gitlab.example.com/virtual_registries/container/<registry_id>/<image_path>:<tag>
   ```

例如：

- 通过标签拉取镜像：

  ```shell
  docker pull gitlab.example.com/virtual_registries/container/1/library/alpine:latest
  ```

- 通过摘要拉取镜像：

  ```shell
  docker pull gitlab.example.com/virtual_registries/container/1/library/alpine@sha256:c9375e662992791e3f39e919b26f510e5254b42792519c180aad254e6b38f4dc
  ```

- 在 `Dockerfile` 中拉取镜像：

  ```dockerfile
  FROM gitlab.example.com/virtual_registries/container/1/library/alpine:latest
  ```

- 在 `.gitlab-ci.yml` 文件中拉取镜像：

  ```yaml
  image: gitlab.example.com/virtual_registries/container/1/library/alpine:latest
  ```

当你拉取镜像时，虚拟注册中心：

1. 检查镜像是否已被缓存。
   1. 如果镜像已缓存且根据上游的 `cache_validity_hours` 设置仍然有效，则从缓存提供镜像。
   1. 如果镜像未缓存或缓存无效，则从配置的上游注册中心获取镜像并缓存。
1. 将镜像提供给 Docker 客户端。

### 镜像的虚拟注册中心缓存验证

<a id="virtual-registry-cache-validation-for-images"></a>

像 `alpine:latest` 这样的镜像标签总是拉取镜像的最新版本。新版本包含更新的镜像清单。当清单发生变化时，容器虚拟注册中心不会拉取新镜像。

相反，容器虚拟注册中心：

1. 检查上游中的 `cache_validity_hours` 设置以确定镜像清单何时失效。
1. 发送 HEAD 请求到上游。如果清单失效，则拉取新镜像。

例如，如果你的流水线拉取 `node:latest` 并且你已将 `cache_validity_period` 设置为 24 小时，虚拟注册中心会缓存该镜像，并在缓存过期或 `node:latest` 在上游发生变化时更新它。

## 故障排查

<a id="troubleshooting"></a>

### 认证错误：`HTTP Basic: Access Denied`

<a id="authentication-error-http-basic-access-denied"></a>

如果在认证到虚拟注册中心时收到 `HTTP Basic: Access denied` 错误，
请参考[双因素认证故障排查](../../../profile/account/two_factor_authentication_troubleshooting.md#error-http-basic-access-denied-if-a-password-was-provided-for-git-authentication-)。

### 虚拟注册中心连接失败

<a id="virtual-registry-connection-failure"></a>

如果未设置服务别名，`docker:20.10.16` 镜像无法找到
`dind` 服务，并抛出如下错误：

```plaintext
error during connect: Get http://docker:2376/v1.39/info: dial tcp: lookup docker on 192.168.0.1:53: no such host
```

要解决此错误，请为 Docker 服务设置服务别名：

```yaml
services:
  - name: docker:20.10.16-dind
    alias: docker
```

### 来自 CI/CD 任务的虚拟注册中心认证问题

<a id="virtual-registry-authentication-issues-from-cicd-jobs"></a>

极狐GitLab Runner 使用 CI/CD 任务令牌自动认证。然而，底层 Docker 引擎仍然受其[授权解析过程](https://docs.gitlab.com/runner/configuration/advanced-configuration/#precedence-of-docker-authorization-resolving)的约束。

认证机制中的错误配置可能导致 `HTTP Basic: Access denied` 和 `403: Access forbidden` 错误。

你可以使用任务日志查看用于认证到虚拟注册中心的认证机制：

```plaintext
通过来自 $DOCKER_AUTH_CONFIG 的凭据进行认证
```

```plaintext
通过来自 /root/.docker/config.json 的凭据进行认证
```

```plaintext
通过来自任务有效负载的凭据进行认证(极狐GitLab 注册中心)
```

确保你正在使用预期的认证机制。

### 拉取镜像时出现 `Not Found` 或 `404` 错误

<a id="not-found-or-404-error-when-pulling-image"></a>

此类错误可能表明：

- 运行任务的用户对拥有该虚拟注册中心的群组，不具备访客、计划者、报告者、开发者、维护者或所有者角色，或具有 `read_virtual_registry` 能力的最小访问权限的自定义角色。
- URL 中的虚拟注册中心 ID 不正确。
- 上游注册中心不包含所请求的镜像。
- 虚拟注册中心未配置上游。

错误消息示例：

```plaintext
ERROR: gitlab.example.com/virtual_registries/container/1/library/alpine:latest: not found
```

```plaintext
ERROR: Job failed: failed to pull image "gitlab.example.com/virtual_registries/container/1/library/alpine:latest" with specified policies [always]:
Error response from daemon: error parsing HTTP 404 response body: unexpected end of JSON input: "" (manager.go:237:1s)
```

要解决这些错误：

1. 确认你对群组具有访客、计划者、报告者、开发者、维护者或所有者角色，或具有 `read_virtual_registry` 能力的最小访问权限的自定义角色。
1. 确认虚拟注册中心 ID 正确。
1. 检查虚拟注册中心至少配置了一个上游。
1. 验证镜像在上游注册中心中存在。