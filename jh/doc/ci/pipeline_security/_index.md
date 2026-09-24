---
stage: Software Supply Chain Security
group: Pipeline Security
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 流水线安全
description: Secrets management, job tokens, secure files, and cloud security.
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

<a id="secrets-management"></a>

## 密钥管理

密钥管理是开发者用来在具有严格访问控制的安全环境中安全地存储敏感数据的系统。**密钥** 是应该保密的敏感凭据。密钥的示例包括：

- 密码
- SSH 密钥
- 访问令牌
- 任何其他类型的凭据，如果暴露会对组织造成危害

<a id="secrets-storage"></a>

## 密钥存储

<a id="secrets-management-providers"></a>

### 密钥管理提供商

最敏感且受最严格策略管控的密钥应存储在密钥管理器中。使用密钥管理器解决方案时，密钥存储在极狐GitLab 实例之外。该领域有许多提供商，包括 [HashiCorp's Vault](https://www.vaultproject.io)、[Azure Key Vault](https://azure.microsoft.com/en-us/products/key-vault) 和 [Google Cloud Secret Manager](https://cloud.google.com/security/products/secret-manager)。

你可以利用极狐GitLab 针对特定 [外部密钥管理提供商](../secrets/_index.md) 的原生集成，在需要时在 CI/CD 流水线中检索这些密钥。

<a id="ci-cd-variables"></a>

### CI/CD 变量

[CI/CD 变量](../variables/_index.md) 是一种在 CI/CD 流水线中存储和复用数据的便捷方式，但变量不如密钥管理提供商安全。变量值：

- 存储在极狐GitLab 项目、群组或实例设置中。能够访问这些设置的用户可以访问未被 [隐藏](../variables/_index.md#hide-a-cicd-variable) 的变量值。
- 可以被 [覆盖](../variables/_index.md#use-pipeline-variables)，导致难以确定实际使用了哪个值。
- 可能由于流水线配置错误而意外暴露。

适合存储在变量中的信息应该是可以暴露而不会带来利用风险的数据（非敏感数据）。

敏感数据应存储在密钥管理解决方案中。如果你没有密钥管理解决方案，并且想把敏感数据存储在 CI/CD 变量中，请务必始终：

- [屏蔽变量](../variables/_index.md#mask-a-cicd-variable)。
- [隐藏变量](../variables/_index.md#hide-a-cicd-variable)。
- 尽可能 [保护变量](../variables/_index.md#protect-a-cicd-variable)。

<a id="pass-parameters-to-ci-cd-pipelines"></a>

## 向 CI/CD 流水线传递参数

要向 CI/CD 流水线传递参数，请使用 [CI/CD 输入](../inputs/_index.md) 而不是流水线变量。

输入提供：

- 在流水线创建时进行类型安全的验证。
- 明确的参数契约。
- 范围化的可用性，可增强安全性。

在实现输入时，考虑 [禁用流水线变量](../variables/_index.md#restrict-pipeline-variables) 以防止安全漏洞，因为流水线变量：

- 缺乏类型验证。
- 可能覆盖预定义变量，导致意外行为。
- 与敏感密钥共享相同的权限范围。

<a id="pipeline-integrity"></a>

## 流水线完整性

确保流水线完整性的关键安全原则包括：

- **供应链安全**：应从可信来源获取资产，并验证其完整性。
- **可重现性**：流水线在使用相同输入时应产生一致的结果。
- **可审计性**：所有流水线依赖项都应可追溯，且其来源可验证。
- **版本控制**：对流水线依赖项的变更应进行跟踪和控制。

<a id="docker-images"></a>

### Docker 镜像

始终使用 SHA 摘要来确保 Docker 镜像的客户端完整性验证。例如：

- Node：
  - 使用：`image: node@sha256:0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef`
  - 而不是：`image: node:latest`
- Python：
  - 使用：`image: python@sha256:9876543210abcdef9876543210abcdef9876543210abcdef9876543210abcdef`
  - 而不是：`image: python:3.9`

你可以使用以下命令查找带有特定标签的镜像的 SHA 摘要：

```shell
docker pull node:18.17.1
docker images --digests node:18.17.1
```

建议从保护镜像完整性的容器镜像仓库拉取：

- 使用 [受保护的容器仓库](../../user/packages/container_registry/container_repository_protection_rules.md) 来限制哪些用户可以更改容器仓库中的容器镜像。
- 使用 [受保护的标签](../../user/packages/container_registry/protected_container_tags.md) 控制谁能推送和删除容器标签。

尽可能避免在容器引用中使用变量，因为它们可能被修改为指向恶意镜像。例如：

- 推荐：
  - `image: my-registry.example.com/node:18.17.1`
- 而不是：
  - `image: ${CUSTOM_REGISTRY}/node:latest`
  - `image: node:${VERSION}`

<a id="package-dependencies"></a>

### 软件包依赖

你应在作业中锁定软件包依赖。使用锁定文件中定义的精确版本：

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
  - 使用 `go.sum` 中的精确版本：
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

在作业中安装工具时，始终指定并验证确切的版本。例如，在 Terraform 作业中：

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
    # 使用 nvm 安装并使用指定的 Node 版本
    - |
      nvm install 16.15.1
      nvm use 16.15.1
    - node --version  # 验证版本
    - npm ci
    - npm run build
```

<a id="included-configurations"></a>

### 包含的配置

使用 [`include` 关键字](../yaml/_index.md#include) 将配置或 CI/CD 组件添加到流水线时，尽可能使用特定的 ref。例如：

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

避免不带版本的 include：

```yaml
include:
  - project: 'my-group/my-project'                   # 不安全
    file: '/templates/build.yml'
  - component: 'my-group/security-scans'             # 不安全
  - remote: 'https://example.com/security-scan.yml'  # 不安全
```

不要直接包含远程文件，应下载文件并将其保存到你的仓库中。然后你可以包含本地副本：

```yaml
include:
  - local: '/ci/security-scan.yml'  # 已验证并存储在仓库中
```

