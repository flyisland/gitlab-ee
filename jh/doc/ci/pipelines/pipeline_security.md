---
stage: Software Supply Chain Security
group: Pipeline Security
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: 流水线安全
---

{{< details >}}

- Tier: 基础版, 专业版, 旗舰版
- Offering: JihuLab.com, 私有化部署

{{< /details >}}

<a id="secrets-management"></a>

## 密钥管理

密钥管理是开发人员用来在具有严格访问控制的安全环境中安全存储敏感数据的系统。**密钥**是一种应该保密的敏感凭证。密钥的例子包括：

1. 密码
1. SSH 密钥
1. 访问令牌
1. 任何其他类型的凭证，暴露会对组织有害

<a id="secrets-storage"></a>

## 密钥存储

<a id="secrets-management-providers"></a>

### 密钥管理供应商

最敏感和最严格的政策下的密钥应该存储在密钥管理器中。当使用密钥管理器解决方案时，密钥存储在极狐 GitLab 实例之外。在这个领域有许多供应商，包括 HashiCorp's Vault 和 Azure Key Vault。

您可以使用极狐 GitLab 原生集成的某些[外部密钥管理供应商](../secrets/_index.md)来在需要时在 CI/CD 流水线中检索这些密钥。

<a id="cicd-variables"></a>

### CI/CD 变量

[CI/CD 变量](../variables/_index.md)是存储和重用数据在 CI/CD 流水线中的一种方便方式，但变量不如密钥管理供应商安全。变量值：

1. 存储在极狐 GitLab 项目、群组或实例设置中。具有访问设置权限的用户可以访问未[隐藏](../variables/_index.md#hide-a-cicd-variable)的变量值。
1. 可以被[覆盖](../variables/_index.md#use-pipeline-variables)，使得难以确定使用了哪个值。
1. 可以因为意外的流水线配置错误而暴露。

适合存储在变量中的信息应该是可以暴露而不具风险的利用（非敏感）的数据。

敏感数据应该存储在密钥管理解决方案中。如果您没有密钥管理解决方案并希望在 CI/CD 变量中存储敏感数据，请确保总是：

1. [遮掩变量](../variables/_index.md#mask-a-cicd-variable)。
1. [隐藏变量](../variables/_index.md#hide-a-cicd-variable)。
1. 尽可能[保护变量](../variables/_index.md#protect-a-cicd-variable)。

<a id="pipeline-integrity"></a>

## 流水线完整性

确保流水线完整性的关键安全原则包括：

1. **供应链安全**：资产应该从可信来源获得，并验证其完整性。
1. **可重现性**：流水线在使用相同输入时应产生一致结果。
1. **可审计性**：所有流水线的依赖项应该是可追踪的，并且其来源是可验证的。
1. **版本控制**：对流水线依赖项的更改应该被追踪和控制。

<a id="docker-images"></a>

### Docker 镜像

始终使用 SHA 摘要来确保客户端的完整性验证。例如：

1. Node：
   - 使用：`image: node@sha256:0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef`
   - 而不是：`image: node:latest`
1. Python：
   - 使用：`image: python@sha256:9876543210abcdef9876543210abcdef9876543210abcdef9876543210abcdef`
   - 而不是：`image: python:3.9`

您可以使用以下命令找到具有特定标签的镜像的 SHA 摘要：

```shell
docker pull node:18.17.1
docker images --digests node:18.17.1
```

优先从保护镜像完整性的容器镜像仓库拉取：

1. 使用[受保护的容器库](../../user/packages/container_registry/container_repository_protection_rules.md)来限制哪些用户可以更改您的容器库中的容器镜像。
1. 使用[受保护的标签](../../user/packages/container_registry/protected_container_tags.md)来控制谁可以推送和删除容器标签。

尽可能避免在容器引用中使用变量，因为它们可以被修改指向恶意镜像。例如：

1. 优先：
   - `image: my-registry.example.com/node:18.17.1`
1. 而不是：
   - `image: ${CUSTOM_REGISTRY}/node:latest`
   - `image: node:${VERSION}`

<a id="package-dependencies"></a>

### 软件包依赖项

您应该在您的工作中锁定软件包依赖项。使用锁定文件中定义的精确版本：

1. npm：
   - 使用：`npm ci`
   - 而不是：`npm install`
1. yarn：
   - 使用：`yarn install --frozen-lockfile`
   - 而不是：`yarn install`
1. Python：
   - 使用：
     - `pip install -r requirements.txt --require-hashes`
     - `pip install -r requirements.lock`
   - 而不是：`pip install -r requirements.txt`
1. Go：
   - 使用 `go.sum` 中的精确版本：
     - `go mod verify`
     - `go mod download`
   - 而不是：`go get ./...`

例如，在一个 CI/CD 工作中：

```yaml
javascript-job:
  script:
    - npm ci
```

<a id="shell-commands-and-scripts"></a>

### Shell 命令和脚本

在工作中安装工具时，始终指定并验证精确版本。例如，在一个 Terraform 工作中：

```yaml
terraform_job:
  script:
    # 下载特定版本
    - |
      wget https://releases.hashicorp.com/terraform/1.5.7/terraform_1.5.7_linux_amd64.zip
      # 重要：始终验证校验和
      echo "c0ed7bc32ee52ae255af9982c8c88a7a4c610485cf1d55feeb037eab75fa082c terraform_1.5.7_linux_amd64.zip" | sha256sum -c
      unzip terraform_1.5.7_linux_amd64.zip
      mv terraform /usr/local/bin/
    # 使用安装的版本
    - terraform init
    - terraform plan
```

<a id="version-management-tools"></a>

### 版本管理工具

尽可能使用版本管理器：

```yaml
node_build:
  script:
    # 使用 nvm 安装并使用特定的 Node 版本
    - |
      nvm install 16.15.1
      nvm use 16.15.1
    - node --version  # 验证版本
    - npm ci
    - npm run build
```

<a id="included-configurations"></a>

### 包含的配置

使用 [`include` 关键字](../yaml/_index.md#include)添加配置或 CI/CD 组件到您的流水线时，尽可能使用特定的引用。例如：

```yaml
include:
  - project: 'my-group/my-project'
    ref: 8b0c8b318857c8211c15c6643b0894345a238c4e  # 固定到特定提交
    file: '/templates/build.yml'
  - project: 'my-group/security'
    ref: v2.1.0                                    # 固定到受保护的标签
    file: '/templates/scan.yml'
  - component: 'my-group/security-scans'           # 固定到特定版本
    version: '1.2.3'
```

避免无版本包含：

```yaml
include:
  - project: 'my-group/my-project'                   # 不安全
    file: '/templates/build.yml'
  - component: 'my-group/security-scans'             # 不安全
  - remote: 'https://example.com/security-scan.yml'  # 不安全
```

而不是包含远程文件，下载文件并保存在您的仓库中。然后您可以包含本地副本：

```yaml
include:
  - local: '/ci/security-scan.yml'  # 已验证并存储在仓库中
```
