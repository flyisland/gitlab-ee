---
stage: Package
group: Package Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: '教程：使用极狐GitLab CI/CD 构建并签名 Python 软件包'
---

本教程向您展示如何为 Python 软件包实现安全的流水线。该流水线包含使用极狐GitLab CI/CD 和 [Sigstore Cosign](https://docs.sigstore.dev/) 对 Python 软件包进行加密签名和验证的阶段。

完成本教程后，您将学会如何：

- 使用极狐GitLab CI/CD 构建并签名 Python 软件包。
- 使用通用软件包仓库存储和管理软件包签名。
- 以最终用户身份验证软件包签名。

<a id="what-are-the-benefits-of-package-signing"></a>

## 软件包签名有哪些好处？

软件包签名可提供多项关键的安全优势：

- 真实性：用户可以验证软件包来自可信来源。
- 数据完整性：如果软件包在分发过程中被篡改，将会被检测到。
- 不可否认性：软件包的来源可以通过加密方式证明。
- 供应链安全：软件包签名可防范供应链攻击和被入侵的代码仓库。

<a id="before-you-begin"></a>

## 先决条件

要完成本教程，您需要：

- 一个极狐GitLab 账号和测试项目。
- 基本熟悉 Python 打包、极狐GitLab CI/CD 和软件包仓库概念。

<a id="steps"></a>

## 步骤

以下是您将要执行的操作概览：

1. [设置 Python 项目。](#set-up-a-python-project)
1. [添加基础配置。](#add-base-configuration)
1. [配置构建阶段。](#configure-the-build-stage)
1. [配置签名阶段。](#configure-the-sign-stage)
1. [配置验证阶段。](#configure-the-verify-stage)
1. [配置发布阶段。](#configure-the-publish-stage)
1. [配置发布签名阶段。](#configure-the-publish-signatures-stage)
1. [配置使用者验证阶段。](#configure-the-consumer-verification-stage)
1. [以用户身份验证软件包。](#verify-packages-as-a-user)

<a id="set-up-a-python-project"></a>

### 设置 Python 项目

首先，创建一个测试项目。在项目根目录中添加一个 `pyproject.toml` 文件：

```toml
[build-system]
requires = ["setuptools>=45", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "<my_package>"  # Will be dynamically replaced by CI/CD pipeline
version = "<1.0.0>"    # Will be dynamically replaced by CI/CD pipeline
description = "<Your package description>"
readme = "README.md"
requires-python = ">=3.7"
authors = [
    {name = "<Your Name>", email = "<your.email@example.com>"},
]

[project.urls]
"Homepage" = "<https://gitlab.com/my_package>"  # Will be replaced with actual project URL
```

请确保将 `Your Name` 和 `your.email@example.com` 替换为您自己的个人信息。

当您在后续步骤中完成 CI/CD 流水线的构建后，该流水线会自动：

- 将 `my_package` 替换为项目名称的规范化版本。
- 更改 `version` 以匹配流水线版本。
- 更改 `Homepage` URL 以匹配您的极狐GitLab 项目 URL。

<a id="add-base-configuration"></a>

#### 添加基础配置

在项目根目录中，添加一个 `.gitlab-ci.yml` 文件。添加以下配置：

```yaml
variables:
  # Base Python version for all jobs
  PYTHON_VERSION: '3.10'
  # Package names and versions
  PACKAGE_NAME: ${CI_PROJECT_NAME}
  PACKAGE_VERSION: "1.0.0"  # Use semantic versioning
  # Sigstore service URLs
  FULCIO_URL: 'https://fulcio.sigstore.dev'
  REKOR_URL: 'https://rekor.sigstore.dev'
  # Identity for Sigstore verification
  CERTIFICATE_IDENTITY: 'https://gitlab.com/${CI_PROJECT_PATH}//.gitlab-ci.yml@refs/heads/${CI_DEFAULT_BRANCH}'
  CERTIFICATE_OIDC_ISSUER: 'https://gitlab.com'
  # Pip cache directory for faster builds
  PIP_CACHE_DIR: "$CI_PROJECT_DIR/.pip-cache"
  # Auto-accept prompts from Cosign
  COSIGN_YES: "true"
  # Base URL for generic package registry
  GENERIC_PACKAGE_BASE_URL: "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/generic/${PACKAGE_NAME}/${PACKAGE_VERSION}"

default:
  before_script:
    # Normalize package name once at the start of any job
    - export NORMALIZED_NAME=$(echo "${CI_PROJECT_NAME}" | tr '-' '_')

# Template for Python-based jobs
.python-job:
  image: python:${PYTHON_VERSION}
  before_script:
    # First normalize package name
    - export NORMALIZED_NAME=$(echo "${CI_PROJECT_NAME}" | tr '-' '_')
    # Then install Python dependencies
    - pip install --upgrade pip
    - pip install build twine setuptools wheel
  cache:
    paths:
      - ${PIP_CACHE_DIR}

# Template for Python + Cosign jobs
.python+cosign-job:
  extends: .python-job
  before_script:
    # First normalize package name
    - export NORMALIZED_NAME=$(echo "${CI_PROJECT_NAME}" | tr '-' '_')
    # Then install dependencies
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

- 指示流水线使用 Python `3.10` 作为基础镜像以保持一致
- 设置两个可复用模板：`.python-job` 用于基本 Python 操作，`.python+cosign-job` 用于签名操作
- 实现 pip 缓存以加快构建速度
- 通过将连字符转换为下划线来规范化软件包名称，以兼容 Python
- 在流水线级别定义所有关键变量，便于管理

<a id="configure-the-build-stage"></a>

### 配置构建阶段

构建阶段用于构建 Python 分发包。

在您的 `.gitlab-ci.yml` 文件中，添加以下配置：

```yaml
build:
  extends: .python-job
  stage: build
  script:
    # Initialize git repo with actual content
    - git init
    - git config --global init.defaultBranch main
    - git config --global user.email "ci@example.com"
    - git config --global user.name "CI"
    - git add .
    - git commit -m "Initial commit"

    # Update package name, version, and homepage URL in pyproject.toml
    - sed -i "s/name = \".*\"/name = \"${NORMALIZED_NAME}\"/" pyproject.toml
    - sed -i "s/version = \".*\"/version = \"${PACKAGE_VERSION}\"/" pyproject.toml
    - sed -i "s|\"Homepage\" = \".*\"|\"Homepage\" = \"https://gitlab.com/${CI_PROJECT_PATH}\"|" pyproject.toml

    # Debug: show updated file
    - echo "Updated pyproject.toml contents:"
    - cat pyproject.toml

    # Build package
    - python -m build
  artifacts:
    paths:
      - dist/
      - pyproject.toml
```

构建阶段配置：

- 初始化 Git 代码仓库以提供构建上下文
- 动态更新 `pyproject.toml`中的软件包元数据
- 同时添加 wheel（`.whl`）和源码分发包（`.tar.gz`）
- 为后续阶段保留构建产物
- 提供调试输出以便故障排除

<a id="configure-the-sign-stage"></a>

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

          # Debug: Verify files were created
          echo "Checking generated signature and certificate:"
          ls -l "dist/${filename}.sig" "dist/${filename}.crt"
        fi
      done
  artifacts:
    paths:
      - dist/
```

签名阶段配置：

- 使用 Sigstore 的[无密钥签名](https://docs.sigstore.dev/cosign/signing/overview/)以增强安全性
- 同时为 wheel 和源码分发包签名
- 创建单独的签名（`.sig`）和证书（`.crt`）文件
- 使用 OIDC 集成进行身份验证
- 包含详细的签名生成日志

<a id="configure-the-verify-stage"></a>

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
- 同时检查 wheel 和源码分发包
- 验证证书身份和 OIDC 颁发者
- 如果任何验证失败则快速失败
- 提供详细的验证日志

<a id="configure-the-publish-stage"></a>

### 配置发布阶段

发布阶段将软件包上传到极狐GitLab PyPI 软件包仓库。

在您的 `.gitlab-ci.yml` 文件中，添加以下配置：

```yaml
publish:
  extends: .python-job
  stage: publish
  script:
    - |
      # Configure PyPI settings for GitLab package registry
      cat << EOF > ~/.pypirc
      [distutils]
      index-servers = gitlab
      [gitlab]
      repository = ${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/pypi
      username = gitlab-ci-token
      password = ${CI_JOB_TOKEN}
      EOF

      # Upload packages using twine
      TWINE_PASSWORD=${CI_JOB_TOKEN} TWINE_USERNAME=gitlab-ci-token \
        twine upload --repository-url ${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/pypi \
        dist/*.whl dist/*.tar.gz
```

发布阶段配置：

- 配置 PyPI 仓库身份验证
- 使用极狐GitLab 内置软件包仓库
- 同时发布 wheel 和源码分发包
- 使用作业令牌进行安全身份验证
- 创建可复用的 `.pypirc` 配置

<a id="configure-the-publish-signatures-stage"></a>

### 配置发布签名阶段

发布签名阶段将签名存储到极狐GitLab 通用软件包仓库中。

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

          # Upload signature and certificate
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

- 将签名存储到通用软件包仓库中
- 维护签名与软件包的映射关系
- 对产物使用一致的命名约定
- 包含签名的大小验证
- 提供详细的上传日志

<a id="configure-the-consumer-verification-stage"></a>

### 配置使用者验证阶段

使用者验证阶段模拟最终用户的软件包验证过程。

在您的 `.gitlab-ci.yml` 文件中，添加以下配置：

```yaml
consumer_verification:
  extends: .python+cosign-job
  stage: consumer_verification
  script:
    - |
      # Initialize git repo for setuptools_scm
      git init
      git config --global init.defaultBranch main

      # Create directory for downloading packages
      mkdir -p pkg signatures

      # Download the specific wheel version
      pip download --index-url "https://gitlab-ci-token:${CI_JOB_TOKEN}@gitlab.com/api/v4/projects/${CI_PROJECT_ID}/packages/pypi/simple" \
          "${NORMALIZED_NAME}==${PACKAGE_VERSION}" --no-deps -d ./pkg --verbose

      # Download the specific source distribution version
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

          # Download signatures
          curl --fail --silent --show-error \
               --header "JOB-TOKEN: ${CI_JOB_TOKEN}" \
               --output "signatures/${filename}.sig" \
               "$sig_url"

          curl --fail --silent --show-error \
               --header "JOB-TOKEN: ${CI_JOB_TOKEN}" \
               --output "signatures/${filename}.crt" \
               "$cert_url"

          # Verify signature
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

使用者验证阶段配置：

- 模拟真实环境中的软件包安装
- 下载并验证两种软件包格式
- 使用精确的版本匹配以保持一致
- 实现全面的错误处理
- 测试完整的验证工作流

<a id="verify-packages-as-a-user"></a>

### 以用户身份验证软件包

作为最终用户，您可以通过以下步骤验证软件包签名：

1. 安装 Cosign：

   ```shell
   wget -O cosign https://github.com/sigstore/cosign/releases/download/v2.2.3/cosign-linux-amd64
   chmod +x cosign && sudo mv cosign /usr/local/bin/
   ```

   Cosign 全局安装需要特殊权限。使用 `sudo` 绕过权限问题。

1. 下载软件包及其签名：

   ```shell
   # You can find your PROJECT_ID in your GitLab project's home page under the project name

   # Download the specific version of the package
   pip download your-package-name==1.0.0 --no-deps

   # The FILENAME will be the output from the pip download command
   # For example: your-package-name-1.0.0.tar.gz or your-package-name-1.0.0-py3-none-any.whl

   # Download signatures from GitLab's generic package registry
   # Replace these values with your project's details:
   # GITLAB_URL: Your GitLab instance URL (for example, https://gitlab.com)
   # PROJECT_ID: Your project's ID number
   # PACKAGE_NAME: Your package name
   # VERSION: Package version (for example, 1.0.0)
   # FILENAME: The exact filename of your downloaded package

   curl --output "${FILENAME}.sig" \
     "${GITLAB_URL}/api/v4/projects/${PROJECT_ID}/packages/generic/${PACKAGE_NAME}/${VERSION}/${FILENAME}.sig"

   curl --output "${FILENAME}.crt" \
     "${GITLAB_URL}/api/v4/projects/${PROJECT_ID}/packages/generic/${PACKAGE_NAME}/${VERSION}/${FILENAME}.crt"
   ```

1. 验证签名：

   ```shell
   # Replace CERTIFICATE_IDENTITY and CERTIFICATE_OIDC_ISSUER with the values from the project's pipeline
   export CERTIFICATE_IDENTITY="https://gitlab.com/your-group/your-project//.gitlab-ci.yml@refs/heads/main"
   export CERTIFICATE_OIDC_ISSUER="https://gitlab.com"

   # Verify wheel package
   FILENAME="your-package-name-1.0.0-py3-none-any.whl"
   COSIGN_EXPERIMENTAL=1 cosign verify-blob \
     --signature "${FILENAME}.sig" \
     --certificate "${FILENAME}.crt" \
     --certificate-identity "${CERTIFICATE_IDENTITY}" \
     --certificate-oidc-issuer "${CERTIFICATE_OIDC_ISSUER}" \
     "${FILENAME}"

   # Verify source distribution
   FILENAME="your-package-name-1.0.0.tar.gz"
   COSIGN_EXPERIMENTAL=1 cosign verify-blob \
     --signature "${FILENAME}.sig" \
     --certificate "${FILENAME}.crt" \
     --certificate-identity "${CERTIFICATE_IDENTITY}" \
     --certificate-oidc-issuer "${CERTIFICATE_OIDC_ISSUER}" \
     "${FILENAME}"
   ```

以最终用户身份验证软件包时：

- 确保下载的软件包与您要验证的精确版本一致。
- 分别验证每种软件包类型（wheel 和源码分发包）。
- 确保证书身份与签名软件包时使用的身份完全一致。
- 检查所有 URL 组件是否正确设置。例如 `GITLAB_URL` 或 `PROJECT_ID`。
- 检查软件包文件名是否与上传到仓库的文件名完全一致。
- 使用 `COSIGN_EXPERIMENTAL=1` 功能标志进行无密钥验证。此标志是必需的。
- 请理解，验证失败可能表示存在篡改，或证书与签名对不正确。
- 记录项目流水线中的证书身份和颁发者值。

<a id="troubleshooting"></a>

## 故障排除

完成本教程时，您可能会遇到以下错误：

<a id="error-404-not-found"></a>

### 错误：`404 Not Found`

如果您遇到 `404 Not Found` 错误页面：

- 仔细检查所有 URL 组件。
- 验证该软件包版本是否存在于仓库中。
- 确保文件名完全一致，包括版本和平台标签。

<a id="verification-failed"></a>

### 验证失败

如果签名验证失败，请确保：

- `CERTIFICATE_IDENTITY` 与签名流水线一致。
- `CERTIFICATE_OIDC_ISSUER` 正确。
- 签名与证书对与该软件包匹配。

<a id="permission-denied"></a>

### 权限被拒绝

如果您遇到权限问题：

- 检查您是否有权访问该软件包仓库。
- 如果仓库是私有的，请验证身份验证配置。
- 安装 Cosign 时使用正确的文件权限。

<a id="authentication-issues"></a>

### 身份验证问题

如果您遇到身份验证问题：

- 检查 `CI_JOB_TOKEN` 权限。
- 验证仓库身份验证配置。
- 验证项目的访问设置。

<a id="verify-package-configuration-and-pipeline-settings"></a>

### 验证软件包配置和流水线设置

检查软件包配置。确保：

- 软件包名称使用下划线（`_`），而不是连字符（`-`）。
- 版本字符串使用有效的 [PEP 440](https://peps.python.org/pep-0440/)。
- `pyproject.toml` 文件格式正确。

检查流水线设置。确保：

- OIDC 配置正确。
- 作业依赖关系设置正确。
- 所需权限已就位。
