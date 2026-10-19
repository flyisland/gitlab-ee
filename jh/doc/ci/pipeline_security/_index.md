---
stage: Software Supply Chain Security
group: Pipeline Security
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 流水线安全
description: 密钥管理、作业令牌、安全文件和云安全。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

<a id="secrets-management"></a>

## 密钥管理

密钥管理是开发者用来在具有严格访问控制的安全环境中安全存储敏感数据的系统。**密钥**是应予以保密的敏感凭据。密钥的示例包括：

- 密码
- SSH 密钥
- 访问令牌
- 任何其他一旦泄露就会对组织造成危害的凭据

<a id="secrets-storage"></a>

## 密钥存储

<a id="secrets-management-providers"></a>

### 密钥管理提供商

最敏感且受最严格策略约束的密钥应存储在密钥管理器中。使用密钥管理器解决方案时，密钥存储在极狐GitLab 实例之外。多家提供商提供此服务，包括
[HashiCorp Vault](https://www.vaultproject.io)、[Azure Key Vault](https://azure.microsoft.com/en-us/products/key-vault)
和 [Google Cloud Secret Manager](https://cloud.google.com/security/products/secret-manager)。

您可以使用极狐GitLab 针对某些[外部密钥管理提供商](../secrets/_index.md)的原生集成，在需要时于 CI/CD 流水线中检索这些密钥。

<a id="cicd-variables"></a>

### CI/CD 变量

[CI/CD 变量](../variables/_index.md)是在 CI/CD 流水线中存储和复用数据的便捷方式，但变量的安全性低于密钥管理提供商。变量值：

- 存储在极狐GitLab 项目、群组或实例设置中。有权访问这些设置的用户可以访问未[隐藏](../variables/_index.md#hide-a-cicd-variable)的变量值。
- 可以被[覆盖](../variables/_index.md#use-pipeline-variables)，
  从而难以确定实际使用了哪个值。
- 可能因意外的流水线配置错误而泄露。

适合存储在变量中的信息应是可以公开而不会被利用的数据（非敏感数据）。

敏感数据应存储在密钥管理解决方案中。如果您没有密钥管理解决方案，并且想要将敏感数据存储在 CI/CD 变量中，请务必始终：

- [屏蔽变量](../variables/_index.md#mask-a-cicd-variable)。
- [隐藏变量](../variables/_index.md#hide-a-cicd-variable)。
- 尽可能[保护变量](../variables/_index.md#protect-a-cicd-variable)。

<a id="pass-parameters-to-cicd-pipelines"></a>

## 向 CI/CD 流水线传递参数

要向 CI/CD 流水线传递参数，请使用 [CI/CD 输入](../inputs/_index.md)而不是流水线变量。

输入提供：

- 在创建流水线时进行类型安全的验证。
- 明确的参数约定。
- 作用域受限的可用性，从而增强安全性。

在实施输入时，请考虑[禁用流水线变量](../variables/_index.md#restrict-pipeline-variables)以防止安全漏洞，因为流水线变量：

- 缺少类型验证。
- 可以覆盖预定义变量，导致意外行为。
- 与敏感密钥共享相同的权限范围。

<a id="pipeline-integrity"></a>

## 流水线完整性

确保流水线完整性的关键安全原则包括：

- **供应链安全**：资产应从可信来源获取，并验证其完整性。
- **可复现性**：流水线在使用相同输入时应产生一致的结果。
- **可审计性**：所有流水线依赖项都应可追溯，其来源可验证。
- **版本控制**：对流水线依赖项的更改应被跟踪和控制。

<a id="docker-images"></a>

### Docker 镜像

请始终对 Docker 镜像使用 SHA 摘要，以确保客户端完整性验证。例如：

- Node：
  - 使用：`image: node@sha256:0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef`
  - 而不是：`image: node:latest`
- Python：
  - 使用 `image: python@sha256:9876543210abcdef9876543210abcdef9876543210abcdef9876543210abcdef`
  - 而不是：`image: python:3.9`

您可以使用以下命令查找具有特定标签的镜像的 SHA 摘要：

```shell
docker pull node:18.17.1
docker images --digests node:18.17.1
```

优先从保护镜像完整性的容器镜像仓库拉取：

- 使用[受保护的容器仓库](../../user/packages/container_registry/container_repository_protection_rules.md)
  来限制哪些用户可以更改容器镜像仓库中的容器镜像。
- 使用[受保护的标签](../../user/packages/container_registry/protected_container_tags.md)
  来控制谁可以推送和删除容器标签。

如有可能，请避免在容器引用中使用变量，因为它们可能被修改为指向恶意镜像。例如：

- 优先使用：
  - `image: my-registry.example.com/node:18.17.1`
- 而不是：
  - `image: ${CUSTOM_REGISTRY}/node:latest`
  - `image: node:${VERSION}`

<a id="package-dependencies"></a>

### 软件包依赖项

您应锁定作业中的软件包依赖项。使用锁定文件中定义的精确版本：

- npm：
  - 使用：`npm ci`
  - 而不是：`npm install`
- yarn：
  - 使用：`yarn install --frozen-lockfile`
  - 而不是：`yarn install`
- Python：
  - 使用：
    - `pip install -r requirements.txt --require-hashes`
    - `pip install -r requirements.lock`
  - 而不是：`pip install -r requirements.txt`
- Go：
  - 使用 `go.sum`中的精确版本：
    - `go mod verify`
    - `go mod download`
  - 而不是：`go get ./...`

例如，在 CI/CD 作业中：

```yaml
javascript-job:
  script:
    - npm ci
```

<a id="shell-commands-and-scripts"></a>

### Shell 命令和脚本

在作业中安装工具时，请始终指定并验证精确版本。
例如，在 Terraform 作业中：

```yaml
terraform_job:
  script:
    # Download specific version
    - |
      wget https://releases.hashicorp.com/terraform/1.5.7/terraform_1.5.7_linux_amd64.zip
      # IMPORTANT: Always verify checksums
      echo "c0ed7bc32ee52ae255af9982c8c88a7a4c610485cf1d55feeb037eab75fa082c terraform_1.5.7_linux_amd64.zip" | sha256sum -c
      unzip terraform_1.5.7_linux_amd64.zip
      mv terraform /usr/local/bin/
    # Use the installed version
    - terraform init
    - terraform plan
```

<a id="version-management-tools"></a>

### 版本管理工具

如有可能，请使用版本管理器：

```yaml
node_build:
  script:
    # Use nvm to install and use a specific Node version
    - |
      nvm install 16.15.1
      nvm use 16.15.1
    - node --version  # Verify version
    - npm ci
    - npm run build
```

<a id="included-configurations"></a>

### 包含的配置

使用 [`include` 关键字](../yaml/_index.md#include)向流水线添加配置或 CI/CD 组件时，请尽可能使用特定的 ref。例如：

```yaml
include:
  - project: 'my-group/my-project'
    ref: 8b0c8b318857c8211c15c6643b0894345a238c4e  # Pin to a specific commit
    file: '/templates/build.yml'
  - project: 'my-group/security'
    ref: v2.1.0                                    # Pin to a protected tag
    file: '/templates/scan.yml'
  - component: 'my-group/security-scans'           # Pin to a specific version
    version: '1.2.3'
```

避免使用不带版本的 include：

```yaml
include:
  - project: 'my-group/my-project'                   # Unsafe
    file: '/templates/build.yml'
  - component: 'my-group/security-scans'             # Unsafe
  - remote: 'https://example.com/security-scan.yml'  # Unsafe
```

与其包含远程文件，不如下载该文件并将其保存在您的代码仓库中。然后您可以包含本地副本：

```yaml
include:
  - local: '/ci/security-scan.yml'  # Verified and stored in the repository
```
