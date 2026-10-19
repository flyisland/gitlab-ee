---
stage: Application Security Testing
group: Composition Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 多容器扫描
description: 镜像漏洞扫描、配置、自定义和报告。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Status: 测试版

{{< /details >}}

使用多容器扫描可在单个流水线中扫描多个容器镜像。此功能使您可以：

- 并行扫描多个镜像。
- 在单个配置文件中配置扫描目标。
- 与现有容器扫描工作流集成。

多容器扫描使用[动态子流水线](../../../ci/pipelines/downstream_pipelines.md#dynamic-child-pipelines)并发运行扫描，从而缩短整体流水线执行时间。

<a id="supported-images"></a>

## 支持的镜像

多容器扫描支持：

- 来自公共镜像仓库的镜像（Docker Hub、极狐GitLab 容器镜像仓库等）
- 来自私有镜像仓库的镜像（已配置身份验证）
- 多架构镜像

<a id="turn-on-multi-container-scanning"></a>

## 开启多容器扫描

先决条件：

- 项目的开发者、维护者或所有者角色。
- 使用 Docker 执行器的极狐GitLab Runner。
- 代码仓库根目录中存在 `.gitlab-multi-image.yml` 配置文件。
- 至少一个要扫描的容器镜像。

要开启多容器扫描：

1. 在代码仓库根目录中创建 `.gitlab-multi-image.yml` 文件：

   ```yaml
      scanTargets:
        - name: alpine
          tag: latest
        - name: python
          tag: 3.9-slim
   ```

1. 在 `.gitlab-ci.yml`中包含该模板：

   ```yaml
      include:
        - template: Jobs/Multi-Container-Scanning.latest.gitlab-ci.yml
   ```

1. 提交并推送您的更改。流水线会自动运行扫描。

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
# Include license information in reports
includeLicenses: true

# Configure registry authentication
auths:
  registry.example.com:
    username: ${REGISTRY_USER}
    password: ${REGISTRY_PASSWORD}

# Allow insecure connections (not recommended for production)
allowInsecure: false

# Additional CA certificates for custom registries
additionalCaCertificateBundle: |
  -----BEGIN CERTIFICATE-----
  ...
  -----END CERTIFICATE-----

# Images to scan
scanTargets:
  - name: registry.example.com/myapp
    tag: "v1.2.3"
  - name: postgres
    tag: "15-alpine"
```

<a id="configuration-options"></a>

### 配置选项

> [!note]
> 您无法为多容器扫描中的子作业指定 runner 标签，但
> [议题 363687](https://gitlab.com/gitlab-org/gitlab/-/work_items/363687) 提议更改此
> 行为。

| 选项                            | 类型    | 是否必需 | 描述                                     |
|---------------------------------|---------|----------|------------------------------------------|
| `scanTargets`                   | Array   | 是       | 要扫描的容器镜像列表                     |
| `scanTargets[].name`            | String  | 是       | 镜像名称（可带镜像仓库）                 |
| `scanTargets[].tag`             | String  | 否       | 镜像标签（默认：`latest`）              |
| `scanTargets[].registry`        | String  | 否       | 镜像仓库覆盖                             |
| `includeLicenses`               | Boolean | 否       | 在报告中包含许可证信息                   |
| `auths`                         | Object  | 否       | 镜像仓库身份验证凭据                     |
| `allowInsecure`                 | Boolean | 否       | 允许不安全的 HTTPS 连接                  |
| `additionalCaCertificateBundle` | String  | 否       | PEM 格式的附加 CA 证书                   |

<a id="common-scenarios"></a>

## 常见场景

以下各节介绍了一些示例场景，您可以根据需要进行调整。

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

### 使用私有镜像仓库身份验证

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

### 为满足合规要求扫描特定版本

```yaml
scanTargets:
  - name: postgres
    tag: "14.10"
  - name: redis
    tag: "7.2.3"
  - name: nginx
    tag: "1.25.3"
```

<a id="scan-dynamically-built-images"></a>

### 扫描动态构建的镜像

如果镜像名称和标签仅在运行时才确定，您无法在静态的 `.gitlab-multi-image.yml` 文件中定义 `scanTargets`。

要扫描这些镜像，请覆盖 `multi-cs::generate-scan` 作业，根据构建作业生成的 dotenv 产物动态构建配置文件：

```yaml
include:
  - template: Jobs/Multi-Container-Scanning.latest.gitlab-ci.yml

.build-rules: &build-rules
  rules:
    - if: $CONTAINER_SCANNING_DISABLED == 'true' || $CONTAINER_SCANNING_DISABLED == '1'
      when: never
    - if: $CI_PIPELINE_SOURCE == 'merge_request_event'
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH

build-image-1:
  stage: build
  image: docker:latest
  services:
    - docker:dind
  <<: *build-rules
  script:
    - docker login -u "$CI_REGISTRY_USER" -p "$CI_REGISTRY_PASSWORD" "$CI_REGISTRY"
    - export IMAGE1_NAME="$CI_REGISTRY_IMAGE/app1:$CI_COMMIT_SHORT_SHA-$CI_JOB_ID"
    - docker build -f Dockerfiles/Dockerfile.app1 -t "$IMAGE1_NAME" .
    - docker push "$IMAGE1_NAME"
    - echo "IMAGE1_NAME=$IMAGE1_NAME" >> build1.env
  artifacts:
    reports:
      dotenv: build1.env

build-image-2:
  stage: build
  image: docker:latest
  services:
    - docker:dind
  <<: *build-rules
  script:
    - docker login -u "$CI_REGISTRY_USER" -p "$CI_REGISTRY_PASSWORD" "$CI_REGISTRY"
    - export IMAGE2_NAME="$CI_REGISTRY_IMAGE/app2:$CI_COMMIT_SHORT_SHA-$CI_JOB_ID"
    - docker build -f Dockerfiles/Dockerfile.app2 -t "$IMAGE2_NAME" .
    - docker push "$IMAGE2_NAME"
    - echo "IMAGE2_NAME=$IMAGE2_NAME" >> build2.env
  artifacts:
    reports:
      dotenv: build2.env

# Override the template job to inject the dynamically generated config
multi-cs::generate-scan:
  needs:
    - job: build-image-1
      artifacts: true
    - job: build-image-2
      artifacts: true
  before_script:
    - !reference [.multi-cs-generate-scan-base, before_script]  # preserve template steps if any
    - IMAGE1_REPO="${IMAGE1_NAME%:*}"
    - IMAGE1_TAG="${IMAGE1_NAME##*:}"
    - IMAGE2_REPO="${IMAGE2_NAME%:*}"
    - IMAGE2_TAG="${IMAGE2_NAME##*:}"
    - |
      cat > .gitlab-multi-image.yml <<EOF
      scanTargets:
        - name: ${IMAGE1_REPO}
          tag: ${IMAGE1_TAG}
        - name: ${IMAGE2_REPO}
          tag: ${IMAGE2_TAG}
      auths:
        registry.gitlab.com: # Replace with your $CI_REGISTRY value for self-managed GitLab
          username: \${CI_REGISTRY_USER}
          password: \${CI_REGISTRY_PASSWORD}
      EOF
```

<a id="cicd-variables"></a>

## CI/CD 变量

您可以使用 CI/CD 变量自定义多容器扫描行为。

| 变量                          | 默认值                                                 | 描述                                       |
|-------------------------------|--------------------------------------------------------|--------------------------------------------|
| `CONTAINER_SCANNING_DISABLED` | -                                                      | 设置为 `true` 或 `1` 可禁用扫描   |
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
- 已为项目开启多容器扫描。
- 流水线已完成并生成容器扫描结果。

要查看扫描结果：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的项目。
1. 转到您的合并请求或流水线详情页面。
1. 选择 **安全** 标签页。
1. 查看所有已扫描镜像中检测到的漏洞。

每个已扫描的镜像会生成：

- 一份容器扫描报告。
- 一份 CycloneDX SBOM（软件物料清单）。
- 许可证信息（如果 `includeLicenses: true`）。

<a id="pipeline-structure"></a>

### 流水线结构

多容器扫描会创建两个作业：

- `multi-cs::generate-scan`：生成扫描配置
- `multi-cs::trigger-scan`：触发包含并行扫描作业的子流水线

子流水线为 `scanTargets`中的每个镜像包含一个作业。

<a id="troubleshooting"></a>

## 故障排除

使用多容器扫描时，您可能会遇到以下问题。

<a id="pipeline-fails-with-configuration-file-not-found"></a>

### 流水线失败并提示“configuration file not found”

原因：`.gitlab-multi-image.yml` 文件缺失或位置错误。

解决方案：确保代码仓库根目录中存在 `.gitlab-multi-image.yml`。

<a id="authentication-fails-for-private-registry"></a>

### 私有镜像仓库身份验证失败

原因：凭据无效或缺少身份验证配置。

解决方案：

1. 确认凭据正确且已正确配置。

   ```yaml
      auths:
        registry.example.com:
          username: ${REGISTRY_USER}
          password: ${REGISTRY_PASSWORD}
   ```

1. 在**设置** > **CI/CD** > **变量**中定义变量。

<a id="scan-takes-too-long"></a>

### 扫描耗时过长

原因：多个大型镜像按顺序扫描。

解决方案：多容器扫描已并行运行扫描。

请考虑：

- 使用更小的基础镜像
- 仅扫描特定的镜像版本
- 调整极狐GitLab Runner 并发设置

<a id="child-pipeline-doesnt-show-reports"></a>

### 子流水线不显示报告

原因：触发配置中缺少 `strategy: mirror`。

解决方案：模板中默认已配置此项。如果您自定义了模板，请确保触发作业包含 `strategy: mirror`。

<a id="child-pipeline-runs-on-unexpected-runner"></a>

### 子流水线在非预期的 runner 上运行

您可能会发现子流水线作业在您未预期的 runner 上运行。

出现此问题是因为子流水线作业不会继承父作业的 runner 标签。[议题 363687](https://gitlab.com/gitlab-org/gitlab/-/work_items/363687) 提议更改此行为。
