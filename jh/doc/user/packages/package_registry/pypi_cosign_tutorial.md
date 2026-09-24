---
stage: Package
group: Package Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: '教程：使用极狐GitLab CI/CD 构建并签名 Python 软件包'
---

本教程向您展示如何为 Python 软件包实施安全的流水线。该流水线包含使用极狐GitLab CI/CD 和 [Sigstore Cosign](https://docs.sigstore.dev/) 对 Python 软件包进行加密签名和验证的阶段。

完成本教程后，您将学会如何：

- 使用极狐GitLab CI/CD 构建并签名 Python 软件包。
- 使用通用软件包仓库存储和管理软件包签名。
- 以最终用户的身份验证软件包签名。

## 软件包签名有哪些好处？

软件包签名提供了多项关键的安全优势：

- 真实性：用户可以验证软件包是否来自可信来源。
- 数据完整性：如果软件包在分发过程中被篡改，将被检测到。
- 不可否认性：软件包的来源可以通过加密方式证明。
- 供应链安全：软件包签名可防范供应链攻击和代码仓泄露。

## 准备工作

要完成本教程，您需要：

- 一个极狐GitLab 账号和一个测试项目。
- 熟悉 Python 打包、极狐GitLab CI/CD 和软件包仓库概念的基本知识。

## 步骤

以下是您将要执行的操作概览：

1. [设置 Python 项目。](#set-up-a-python-project)
1. [添加基础配置。](#add-base-configuration)
1. [配置构建阶段。](#configure-the-build-stage)
1. [配置签名阶段。](#configure-the-sign-stage)
1. [配置验证阶段。](#configure-the-verify-stage)
1. [配置发布阶段。](#configure-the-publish-stage)
1. [配置发布签名阶段。](#configure-the-publish-signatures-stage)
1. [配置消费者验证阶段。](#configure-the-consumer-verification-stage)
1. [以用户身份验证软件包。](#verify-packages-as-a-user)

### 设置 Python 项目

首先，创建一个测试项目。在项目根目录中添加一个 `pyproject.toml` 文件：

```toml
[build-system]
requires = ["setuptools>=45", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "<my_package>"  # 将被 CI/CD 流水线动态替换
version = "<1.0.0>"    # 将被 CI/CD 流水线动态替换
description = "<您的软件包描述>"
readme = "README.md"
requires-python = ">=3.7"
authors = [
    {name = "<您的姓名>", email = "<您的邮箱@example.com>"},
]

[project.urls]
"Homepage" = "<https://gitlab.com/my_package>"  # 将被替换为实际的项目 URL
```

请务必将 `<您的姓名>` 和 `<您的邮箱@example.com>` 替换为您自己的个人信息。

当您在后续步骤中完成 CI/CD 流水线的构建后，流水线会自动：

- 将 `my_package` 替换为您的项目名称的规范化版本。
- 更改 `version` 以匹配流水线版本。
- 更改 `Homepage` URL 以匹配您的极狐GitLab 项目 URL。

#### 添加基础配置

在项目根目录中，添加一个 `.gitlab-ci.yml` 文件。添加以下配置：

```yaml
variables:
  # 所有作业的基础 Python 版本
  PYTHON_VERSION: '3.10'
  # 软件包名称和版本
  PACKAGE_NAME: ${CI_PROJECT_NAME}
  PACKAGE_VERSION: "1.0.0"  # 使用语义化版本
  # Sigstore 服务 URL
  FULCIO_URL: 'https://fulcio.sigstore.dev'
  REKOR_URL: 'https://rekor.sigstore.dev'
  # 用于 Sigstore 验证的身份
  CERTIFICATE_IDENTITY: 'https://gitlab.com/${CI_PROJECT_PATH}//.gitlab-ci.yml@refs/heads/${CI_DEFAULT_BRANCH}'
  CERTIFICATE_OIDC_ISSUER: 'https://gitlab.com'
  # Pip 缓存目录，用于加速构建
  PIP_CACHE_DIR: "$CI_PROJECT_DIR/.pip-cache"
  # 自动接受 Cosign 的提示
  COSIGN_YES: "true"
  # 通用软件包仓库的基础 URL
  GENERIC_PACKAGE_BASE_URL: "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/generic/${PACKAGE_NAME}/${PACKAGE_VERSION}"

default:
  before_script:
    # 在任何作业开始时规范化软件包名称
    - export NORMALIZED_NAME=$(echo "${CI_PROJECT_NAME}" | tr '-' '_')

# 基于 Python 的作业模板
.python-job:
  image: python:${PYTHON_VERSION}
  before_script:
    # 首先规范化软件包名称
    - export NORMALIZED_NAME=$(echo "${CI_PROJECT_NAME}" | tr '-' '_')
    # 然后安装 Python 依赖项
    - pip install --upgrade pip
    - pip install build twine setuptools wheel
  cache:
    paths:
      - ${PIP_CACHE_DIR}

# 用于 Python + Cosign 作业的模板
.python+cosign-job:
  extends: .python-job
  before_script:
    # 首先规范化软件包名称
    - export NORMALIZED_NAME=$(echo "${CI_PROJECT_NAME}" | tr '-' '_')
    # 然后安装依赖项
    - apt-get update && apt-get install -y curl wget
    - wget -O cosign https://github.com/sigstore/cosign/releases/download/v2.2.3/cosign-linux-amd64
    - chmod +x cosign && mv cosign /usr/local/bin/
    - export COSIGN_EXPERIMENTAL=1
    - pip install --upgrade pip
    - pip install build twine setuptools wheel
stages:
  - build
  - sign
  - verify
  - publish
  - publish_signatures
  - consumer_verification
```

此基础配置：

- 指示流水线使用 Python `3.10` 作为基础镜像，以确保一致性
- 设置两个可复用模板：`.python-job` 用于基础 Python 操作，`.python+cosign-job` 用于签名操作
- 实现 pip 缓存以加速构建
- 通过将连字符转换为下划线来规范化软件包名称，以提高 Python 兼容性
- 在流水线级别定义所有关键变量，以便于管理

### 配置构建阶段

构建阶段会构建 Python 分发包。

在您的 `.gitlab-ci.yml` 文件中，添加以下配置：

```yaml
build:
  extends: .python-job
  stage: build
  script:
    # 使用实际内容初始化 git 代码仓
    - git init
    - git config --global init.defaultBranch main
    - git config --global user.email "ci@example.com"
    - git config --global user.name "CI"
    - git add .
    - git commit -m "Initial commit"

    # 更新 pyproject.toml 中的软件包名称、版本和 Homepage URL
    - sed -i "s/name = \".*\"/name = \"${NORMALIZED_NAME}\"/" pyproject.toml
    - sed -i "s/version = \".*\"/version = \"${PACKAGE_VERSION}\"/" pyproject.toml
    - sed -i "s|\"Homepage\" = \".*\"|\"Homepage\" = \"https://gitlab.com/${CI_PROJECT_PATH}\"|" pyproject.toml

    # 调试：显示更新后的文件
    - echo "Updated pyproject.toml contents:"
    - cat pyproject.toml

    # 构建软件包
    - python -m build
  artifacts:
    paths:
      - dist/
      - pyproject.toml
```

构建阶段配置：

- 为构建上下文初始化一个 Git 代码仓
- 动态更新 `pyproject.toml` 中的软件包元数据
- 添加 wheel (`.whl`) 和源码分发包 (`.tar.gz`) 两种格式的软件包
- 为后续阶段保留构建产物
- 提供用于故障排除的调试输出

### 配置签名阶段

签名阶段使用 Sigstore Cosign 对软件包进行签名。

在您的 `.gitlab-ci.yml` 文件中，添加以下配置：

```yaml
sign:
  extends: .python+cosign-job
  stage: sign
  id_tokens:
    SIGSTORE_ID_TOKEN:
      aud: sigstore
  script:
    - |
      for file in dist/*.whl dist/*.tar.gz; do
        if [ -f "$file" ]; then
          filename=$(basename "$file")

          cosign sign-blob --yes \
            --fulcio-url=${FULCIO_URL} \
            --rekor-url=${REKOR_URL} \
            --oidc-issuer $CI_SERVER_URL \
            --identity-token $SIGSTORE_ID_TOKEN \
            --output-signature "dist/${filename}.sig" \
            --output-certificate "dist/${filename}.crt" \
            "$file"

          # 调试：验证文件已创建
          echo "Checking generated signature and certificate:"
          ls -l "dist/${filename}.sig" "dist/${filename}.crt"
        fi
      done
  artifacts:
    paths:
      - dist/
```

签名阶段配置：

- 使用来自 Sigstore 的[无密钥签名](https://docs.sigstore.dev/cosign/signing/overview/)以增强安全性
- 对 wheel 和源码分发包这两种格式进行签名
- 创建单独的签名 (`.sig`) 和证书 (`.crt`) 文件
- 使用 OIDC 集成进行身份验证
- 包含签名生成的详细日志

### 配置验证阶段

验证阶段在本地验证签名。

在您的 `.gitlab-ci.yml` 文件中，添加以下配置：

```yaml
verify:
  extends: .python+cosign-job
  stage: verify
  script:
    - |
      failed=0

      for file in dist/*.whl dist/*.tar.gz; do
        if [ -f "$file" ]; then
          filename=$(basename "$file")

          echo "Verifying file: $file"
          echo "Using signature: dist/${filename}.sig"
          echo "Using certificate: dist/${filename}.crt"

          if ! cosign verify-blob \
            --signature "dist/${filename}.sig" \
            --certificate "dist/${filename}.crt" \
            --certificate-identity "${CERTIFICATE_IDENTITY}" \
            --certificate-oidc-issuer "${CERTIFICATE_OIDC_ISSUER}" \
            "$file"; then
            echo "Verification failed for $filename"
            failed=1
          fi
        fi
      done

      if [ $failed -eq 1 ]; then
        exit 1
      fi
```

验证阶段配置：

- 在签名后立即验证签名
- 检查 wheel 和源码分发包这两种格式
- 验证证书身份和 OIDC 颁发者
- 如果任何验证失败，则快速失败
- 提供详细的验证日志

### 配置发布阶段

发布阶段将软件包上传到极狐GitLab PyPI 软件包仓库。

在您的 `.gitlab-ci.yml` 文件中，添加以下配置：

```yaml
publish:
  extends: .python-job
  stage: publish
  script:
    - |
      # 为极狐GitLab 软件包仓库配置 PyPI 设置
      cat << EOF > ~/.pypirc
      [distutils]
      index-servers = gitlab
      [gitlab]
      repository = ${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/pypi
      username = gitlab-ci-token
      password = ${CI_JOB_TOKEN}
      EOF

      # 使用 twine 上传软件包
      TWINE_PASSWORD=${CI_JOB_TOKEN} TWINE_USERNAME=gitlab-ci-token \
        twine upload --repository-url ${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/pypi \
        dist/*.whl dist/*.tar.gz
```

发布阶段配置：

- 配置 PyPI 仓库认证
- 使用极狐GitLab 内置的软件包仓库
- 发布 wheel 和源码分发包
- 使用作业令牌进行安全认证
- 创建一个可复用的 `.pypirc` 配置

### 配置发布签名阶段

发布签名阶段将签名存储在极狐GitLab 通用软件包仓库中。

在您的 `.gitlab-ci.yml` 文件中，添加以下配置：

```yaml
publish_signatures:
  extends: .python+cosign-job
  stage: publish_signatures
  script:
    - |
      for file in dist/*.whl dist/*.tar.gz; do
        if [ -f "$file" ]; then
          filename=$(basename "$file")

          ls -l "dist/${filename}.sig" "dist/${filename}.crt"

          echo "Publishing signatures for $filename"
          echo "Publishing to: ${GENERIC_PACKAGE_BASE_URL}/${filename}.sig"

          # 上传签名和证书
          curl --header "JOB-TOKEN: ${CI_JOB_TOKEN}" \
               --fail \
               --upload-file "dist/${filename}.sig" \
               "${GENERIC_PACKAGE_BASE_URL}/${filename}.sig"

          curl --header "JOB-TOKEN: ${CI_JOB_TOKEN}" \
               --fail \
               --upload-file "dist/${filename}.crt" \
               "${GENERIC_PACKAGE_BASE_URL}/${filename}.crt"
        fi
      done
```

发布签名阶段配置：

- 将签名存储在通用软件包仓库中
- 维护签名到软件包的映射
- 为产物使用一致的命名约定
- 包含对签名的大小验证
- 提供详细的上传日志

### 配置消费者验证阶段

消费者验证阶段模拟最终用户的软件包验证。

在您的 `.gitlab-ci.yml` 文件中，添加以下配置：

```yaml
consumer_verification:
  extends: .python+cosign-job
  stage: consumer_verification
  script:
    - |
      # 为 setuptools_scm 初始化 git 代码仓
      git init
      git config --global init.defaultBranch main

      # 创建用于下载软件包的目录
      mkdir -p pkg signatures

      # 下载特定版本的 wheel 包
      pip download --index-url "https://gitlab-ci-token:${CI_JOB_TOKEN}@gitlab.com/api/v4/projects/${CI_PROJECT_ID}/packages/pypi/simple" \
          "${NORMALIZED_NAME}==${PACKAGE_VERSION}" --no-deps -d ./pkg --verbose

      # 下载特定版本的源码分发包
      pip download --no-binary :all: \
          --index-url "https://gitlab-ci-token:${CI_JOB_TOKEN}@gitlab.com/api/v4/projects/${CI_PROJECT_ID}/packages/pypi/simple" \
          "${NORMALIZED_NAME}==${PACKAGE_VERSION}" --no-deps -d ./pkg --verbose

      failed=0
      for file in pkg/*.whl pkg/*.tar.gz; do
        if [ -f "$file" ]; then
          filename=$(basename "$file")

          sig_url="${GENERIC_PACKAGE_BASE_URL}/${filename}.sig"
          cert_url="${GENERIC_PACKAGE_BASE_URL}/${filename}.crt"

          echo "Downloading signatures for $filename"
          echo "Signature URL: $sig_url"
          echo "Certificate URL: $cert_url"

          # 下载签名
          curl --fail --silent --show-error \
               --header "JOB-TOKEN: ${CI_JOB_TOKEN}" \
               --output "signatures/${filename}.sig" \
               "$sig_url"

          curl --fail --silent --show-error \
               --header "JOB-TOKEN: ${CI_JOB_TOKEN}" \
               --output "signatures/${filename}.crt" \
               "$cert_url"

          # 验证签名
          if ! cosign verify-blob \
            --signature "signatures/${filename}.sig" \
            --certificate "signatures/${filename}.crt" \
            --certificate-identity "${CERTIFICATE_IDENTITY}" \
            --certificate-oidc-issuer "${CERTIFICATE_OIDC_ISSUER}" \
            "$file"; then
            echo "Signature verification failed"
            failed=1
          fi
        fi
      done

      if [ $failed -eq 1 ]; then
        echo "Verification failed for one or more packages"
        exit 1
      fi
```

消费者验证阶段配置：

- 模拟实际环境中的软件包安装
- 下载并验证两种软件包格式
- 使用完全相同的版本匹配以确保一致性
- 实现全面的错误处理
- 测试完整的验证工作流

### 以用户身份验证软件包

作为最终用户，您可以按照以下步骤验证软件包签名：

1. 安装 Cosign：

   ```shell
   wget -O cosign https://github.com/sigstore/cosign/releases/download/v2.2.3/cosign-linux-amd64
   chmod +x cosign && sudo mv cosign /usr/local/bin/
   ```

   Cosign 需要特殊权限才能进行全局安装。请使用 `sudo` 绕过权限问题。

1. 下载软件包及其签名：

   ```shell
   # 您可以在极狐GitLab 项目首页的项目名称下方找到您的 PROJECT_ID

   # 下载特定版本的软件包
   pip download your-package-name==1.0.0 --no-deps

   # FILENAME 将是 pip download 命令的输出结果
   # 例如：your-package-name-1.0.0.tar.gz 或 your-package-name-1.0.0-py3-none-any.whl

   # 从极狐GitLab 的通用软件包仓库下载签名
   # 请将这些值替换为您项目的详细信息：
   # GITLAB_URL：您的极狐GitLab 实例 URL（例如，https://gitlab.com）
   # PROJECT_ID：您项目的 ID 编号
   # PACKAGE_NAME：您的软件包名称
   # VERSION：软件包版本（例如，1.0.0）
   # FILENAME：您下载的软件包的确切文件名

   curl --output "${FILENAME}.sig" \
     "${GITLAB_URL}/api/v4/projects/${PROJECT_ID}/packages/generic/${PACKAGE_NAME}/${VERSION}/${FILENAME}.sig"

   curl --output "${FILENAME}.crt" \
     "${GITLAB_URL}/api/v4/projects/${PROJECT_ID}/packages/generic/${PACKAGE_NAME}/${VERSION}/${FILENAME}.crt"
   ```

1. 验证签名：

   ```shell
   # 将 CERTIFICATE_IDENTITY 和 CERTIFICATE_OIDC_ISSUER 替换为项目流水线中的值
   export CERTIFICATE_IDENTITY="https://gitlab.com/your-group/your-project//.gitlab-ci.yml@refs/heads/main"
   export CERTIFICATE_OIDC_ISSUER="https://gitlab.com"

   # 验证 wheel 软件包
   FILENAME="your-package-name-1.0.0-py3-none-any.whl"
   COSIGN_EXPERIMENTAL=1 cosign verify-blob \
     --signature "${FILENAME}.sig" \
     --certificate "${FILENAME}.crt" \
     --certificate-identity "${CERTIFICATE_IDENTITY}" \
     --certificate-oidc-issuer "${CERTIFICATE_OIDC_ISSUER}" \
     "${FILENAME}"

   # 验证源码分发包
   FILENAME="your-package-name-1.0.0.tar.gz"
   COSIGN_EXPERIMENTAL=1 cosign verify-blob \
     --signature "${FILENAME}.sig" \
     --certificate "${FILENAME}.crt" \
     --certificate-identity "${CERTIFICATE_IDENTITY}" \
     --certificate-oidc-issuer "${CERTIFICATE_OIDC_ISSUER}" \
     "${FILENAME}"
   ```

以最终用户身份验证软件包时：

- 确保下载的软件包与您要验证的确切版本匹配。
- 分别验证每种软件包类型（wheel 和源码分发包）。
- 确保证书身份与用于签名软件包的身份完全匹配。
- 检查所有 URL 组件是否正确设置。例如，`GITLAB_URL` 或 `PROJECT_ID`。
- 检查软件包文件名是否与上传到仓库的文件名完全匹配。
- 使用 `COSIGN_EXPERIMENTAL=1` 功能标志进行无密钥验证。此标志是必需的。
- 请理解，验证失败可能表明软件包被篡改，或者证书与签名对不正确。
- 记录项目流水线中的证书身份和颁发者值。

## 故障排除

完成本教程时，您可能会遇到以下错误：

### 错误：`404 Not Found`

如果您遇到 `404 Not Found` 错误页面：

- 仔细检查所有 URL 组件。
- 验证该软件包版本是否存在于仓库中。
- 确保文件名完全匹配，包括版本和平台标签。

### 验证失败

如果签名验证失败，请确保：

- `CERTIFICATE_IDENTITY` 与签名流水线匹配。
- `CERTIFICATE_OIDC_ISSUER` 正确无误。
- 签名和证书对适用于该软件包。

### 权限被拒绝

如果您遇到权限问题：

- 检查您是否有权访问软件包仓库。
- 如果仓库是私有的，请验证身份验证。
- 安装 Cosign 时使用正确的文件权限。

### 身份验证问题

如果您遇到身份验证问题：

- 检查 `CI_JOB_TOKEN` 的权限。
- 验证仓库认证配置。
- 检查项目的访问设置。

### 验证软件包配置和流水线设置

检查软件包配置。确保：

- 软件包名称使用下划线 (`_`)，而不是连字符 (`-`)。
- 版本字符串使用有效的 [PEP 440](https://peps.python.org/pep-0440/) 格式。
- `pyproject.toml` 文件格式正确。

检查流水线设置。确保：

- OIDC 配置正确。
- 作业依赖项正确设置。
- 所需权限已到位。