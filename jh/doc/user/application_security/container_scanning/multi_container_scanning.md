---
stage: Application Security Testing
group: Composition Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 多容器扫描
description: Image vulnerability scanning, configuration, customization, and reporting.
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- 状态：测试版

{{< /details >}}

{{< history >}}

- 在极狐GitLab 18.7 中作为[实验](../../../policy/development_stages_support.md)引入。

{{< /history >}}

使用多容器扫描可在单个流水线中扫描多个容器镜像。
此功能让你能够：

- 并行扫描多个镜像。
- 在单个配置文件中配置扫描目标。
- 与现有容器扫描工作流集成。

多容器扫描使用[动态子流水线](../../../ci/pipelines/downstream_pipelines.md#dynamic-child-pipelines)来并发运行扫描，从而减少整体流水线执行时间。

<a id="supported-images"></a>

## 支持的镜像

多容器扫描支持：

- 来自公共镜像仓库的镜像（Docker Hub，极狐GitLab 容器镜像仓库和其他）
- 来自私有镜像仓库的镜像（已配置认证）
- 多架构镜像

<a id="turn-on-multi-container-scanning"></a>

## 打开多容器扫描

先决条件：

- 项目的开发者、维护者或所有者角色。
- 具有 Docker 执行器的极狐GitLab Runner。
- 在仓库根目录中有一个 `.gitlab-multi-image.yml` 配置文件。
- 至少有一个容器镜像要扫描。

要打开多容器扫描：

1. 在你的仓库根目录中创建一个 `.gitlab-multi-image.yml` 文件：

   ```yaml
      scanTargets:
        - name: alpine
          tag: latest
        - name: python
          tag: 3.9-slim
   ```

1. 在你的 `.gitlab-ci.yml` 中包含模板：

   ```yaml
      include:
        - template: Jobs/Multi-Container-Scanning.latest.gitlab-ci.yml
   ```

1. 提交并推送你的变更。流水线将自动运行扫描。

<a id="configuration"></a>

## 配置

通过编辑 `.gitlab-multi-image.yml` 文件来配置多容器扫描。

<a id="basic-configuration-example"></a>

### 基本配置示例

```yaml
scanTargets:
  - name: alpine
    tag: "3.19"
  - name: ubuntu
    tag: "22.04"
```

<a id="complete-configuration-example"></a>

### 完整配置示例

```yaml
# 在报告中包含许可证信息
includeLicenses: true

# 配置镜像仓库认证
auths:
  registry.example.com:
    username: ${REGISTRY_USER}
    password: ${REGISTRY_PASSWORD}

# 允许不安全连接（不建议在生产环境中使用）
allowInsecure: false

# 用于自定义镜像仓库的额外 CA 证书
additionalCaCertificateBundle: |
  -----BEGIN CERTIFICATE-----
  ...
  -----END CERTIFICATE-----

# 要扫描的镜像
scanTargets:
  - name: registry.example.com/myapp
    tag: "v1.2.3"
  - name: postgres
    tag: "15-alpine"
```

<a id="configuration-options"></a>

### 配置选项

| 选项                          | 类型    | 必需 | 描述                              |
|--------------------------------|---------|----------|------------------------------------------|
| `scanTargets`                   | Array   | 是      | 要扫描的容器镜像列表         |
| `scanTargets[].name`            | String  | 是      | 镜像名称（可选填镜像仓库）      |
| `scanTargets[].tag`             | String  | 否       | 镜像标签（默认值：`latest`）            |
| `scanTargets[].registry`        | String  | 否       | 镜像仓库覆盖                        |
| `includeLicenses`               | Boolean | 否       | 在报告中包含许可证信息   |
| `auths`                         | Object  | 否       | 镜像仓库认证凭据      |
| `allowInsecure`                 | Boolean | 否       | 允许不安全的 HTTPS 连接         |
| `additionalCaCertificateBundle` | String  | 否       | 额外 CA 证书，PEM 格式 |

<a id="common-scenarios"></a>

## 常见场景

以下部分描述了一些示例场景，你可以根据自己的需求进行调整。

<a id="scan-images-from-different-registries"></a>

### 扫描来自不同镜像仓库的镜像

```yaml
scanTargets:
  - name: docker.io/library/nginx
    tag: "1.25"
  - name: registry.gitlab.com/mygroup/myapp
    tag: "main"
  - name: gcr.io/myproject/service
    tag: "prod"
```

<a id="use-private-registry-authentication"></a>

### 使用私有镜像仓库认证

```yaml
auths:
  registry.gitlab.com:
    username: ${CI_REGISTRY_USER}
    password: ${CI_REGISTRY_PASSWORD}
  docker.io:
    username: ${DOCKERHUB_USER}
    password: ${DOCKERHUB_TOKEN}

scanTargets:
  - name: registry.gitlab.com/private/image
    tag: latest
```

<a id="scan-specific-versions-for-compliance"></a>

### 扫描特定版本以符合合规要求

```yaml
scanTargets:
  - name: postgres
    tag: "14.10"
  - name: redis
    tag: "7.2.3"
  - name: nginx
    tag: "1.25.3"
```

<a id="cicd-variables"></a>

## CI/CD 变量

你可以使用 CI/CD 变量来自定义多容器扫描行为。

| 变量                      | 默认值                                                | 描述                                |
|-------------------------------|--------------------------------------------------------|--------------------------------------------|
| `CONTAINER_SCANNING_DISABLED` | -                                                      | 设置为 `true` 或 `1` 以禁用扫描   |
| `AST_ENABLE_MR_PIPELINES`     | `true`                                                 | 在合并请求流水线中启用扫描 |
| `CS_SCANNER_IMAGE`            | `registry.gitlab.com/.../multiple-container-scanner:0` | 要使用的扫描器镜像                       |

<a id="disable-multi-container-scanning"></a>

### 禁用多容器扫描

要临时禁用扫描：

```yaml
variables:
  CONTAINER_SCANNING_DISABLED: "true"
```

<a id="disable-mr-pipeline-scanning"></a>

### 禁用合并请求流水线扫描

```yaml
variables:
  AST_ENABLE_MR_PIPELINES: "false"
```

<a id="view-scan-results"></a>

## 查看扫描结果

先决条件：

- 项目的开发者、维护者或所有者角色。
- 为项目开启了多容器扫描。
- 流水线已完成并生成了容器扫描结果。

要查看扫描结果：

1. 在顶部栏中，选择 **搜索或跳转到** 并查找你的项目。
1. 转到你的合并请求或流水线详情页。
1. 选择 **安全** 选项卡。
1. 查看从所有扫描镜像中检测到的漏洞。

每个扫描的镜像会生成：

- 一份容器扫描报告。
- 一份 CycloneDX SBOM（软件物料清单）。
- 许可证信息（如果 `includeLicenses: true`）。

<a id="pipeline-structure"></a>

### 流水线结构

多容器扫描会创建两个作业：

- `multi-cs::generate-scan`：生成扫描配置
- `multi-cs::trigger-scan`：触发一个具有并行扫描作业的子流水线

子流水线为 `scanTargets` 中的每个镜像包含一个作业。

<a id="troubleshooting"></a>

## 故障排除

在使用多容器扫描时，你可能会遇到以下问题。

<a id="pipeline-fails-with-configuration-file-not-found"></a>

### 流水线失败并提示 "配置文件未找到"

原因：`.gitlab-multi-image.yml` 文件丢失或位于错误的位置。

解决方案：确保 `.gitlab-multi-image.yml` 存在于你的仓库根目录中。

<a id="authentication-fails-for-private-registry"></a>

### 私有镜像仓库认证失败

原因：凭据无效或缺少认证配置。

解决方案：

1. 验证凭据是否正确且配置正确。

   ```yaml
      auths:
        registry.example.com:
          username: ${REGISTRY_USER}
          password: ${REGISTRY_PASSWORD}
   ```

1. 在 **设置** > **CI/CD** > **变量** 中定义变量。

<a id="scan-takes-too-long"></a>

### 扫描耗时过长

原因：多个大型镜像被顺序扫描。

解决方案：多容器扫描已经并行运行扫描。

考虑：

- 使用更小的基础镜像
- 仅扫描特定的镜像版本
- 调整极狐GitLab Runner 的并发设置

<a id="child-pipeline-doesnt-show-reports"></a>

### 子流水线未显示报告

原因：触发器配置中缺少 `strategy: mirror`。

解决方案：此项在模板中默认已配置。如果你自定义了模板，请确保触发作业包含 `strategy: mirror`。

<a id="child-pipeline-runs-on-unexpected-runner"></a>

### 子流水线在非预期的 Runner 上运行

你可能会发现子流水线作业在你未预期的 Runner 上运行。

发生此问题的原因是子流水线作业不继承父作业的 Runner 标签。
