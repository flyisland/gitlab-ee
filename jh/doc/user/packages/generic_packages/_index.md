---
stage: Package
group: Package Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab 通用软件包仓库
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用通用软件包仓库，可以在项目的软件包仓库中发布和管理通用文件，例如发布二进制文件。此功能特别适用于存储和分发不符合 npm 或 Maven 等特定软件包格式的产物。

通用软件包仓库提供：

- 一个将任意文件类型作为软件包存储的位置。
- 软件包的版本控制。
- 与极狐GitLab CI/CD 的集成。
- 用于自动化的 API 访问。

<a id="authenticate-to-the-package-registry"></a>

## 向软件包仓库进行身份验证

要与软件包仓库交互，您必须使用以下方法之一进行身份验证：

- 作用域设置为 `api`的[个人访问令牌](../../profile/personal_access_tokens.md)。
- 作用域设置为 `api` 且具有开发者、维护者或所有者角色的[项目访问令牌](../../project/settings/project_access_tokens.md)。
- [CI/CD 作业令牌](../../../ci/jobs/ci_job_token.md)。
- 作用域设置为 `read_package_registry`、`write_package_registry` 或两者的[部署令牌](../../project/deploy_tokens/_index.md)。

请勿使用此处记录的方法之外的其他身份验证方法。未记录的身份验证方法可能会在未来被移除。

向软件包仓库进行身份验证时，应遵循以下最佳实践：

- 要访问与开发者角色关联的权限，请使用个人访问令牌。
- 对自动化流水线使用 CI/CD 作业令牌。
- 对外部系统集成使用部署令牌。
- 始终通过 HTTPS 发送身份验证信息。

<a id="http-basic-authentication"></a>

### HTTP 基本身份验证

如果您使用的工具不支持标准身份验证方法，可以使用 HTTP 基本身份验证：

```shell
curl --user "<username>:<token>" <other options> <GitLab API endpoint>
```

尽管用户名会被忽略，但您仍必须提供用户名。令牌是您的个人访问令牌、CI/CD 作业令牌或部署令牌。

<a id="publish-a-package"></a>

## 发布软件包

您可以使用 API 发布软件包。

<a id="publish-a-single-file"></a>

### 发布单个文件

要发布单个文件，请使用以下 API 端点：

```shell
PUT /projects/:id/packages/generic/:package_name/:package_version/:file_name
```

将 URL 中的占位符替换为您的具体值：

- `:id`：您的项目 ID 或 URL 编码路径
- `:package_name`：软件包的名称
- `:package_version`：软件包的版本
- `:file_name`：您要上传的文件名。请参见下方的[有效的软件包文件名格式](#valid-package-filename-format)。

例如：

{{< tabs >}}

{{< tab title="个人访问令牌" >}}

使用 HTTP 请求头：

```shell
curl --location --header "PRIVATE-TOKEN: <personal_access_token>" \
     --upload-file path/to/file.txt \
     "https://gitlab.example.com/api/v4/projects/24/packages/generic/my_package/1.0.0/file.txt"
```

使用 HTTP 基本身份验证：

```shell
curl --location --user "<username>:<personal_access_token>" \
     --upload-file path/to/file.txt \
     "https://gitlab.example.com/api/v4/projects/24/packages/generic/my_package/1.0.0/file.txt"
```

{{< /tab >}}

{{< tab title="Project access token" >}}

使用 HTTP 请求头：

```shell
curl --location --header "PRIVATE-TOKEN: <project_access_token>" \
     --upload-file path/to/file.txt \
     "https://gitlab.example.com/api/v4/projects/24/packages/generic/my_package/1.0.0/file.txt"
```

使用 HTTP 基本身份验证：

```shell
curl --location --user "<project_access_token_username>:project_access_token" \
     --upload-file path/to/file.txt \
     "https://gitlab.example.com/api/v4/projects/24/packages/generic/my_package/1.0.0/file.txt"
```

{{< /tab >}}

{{< tab title="部署令牌" >}}

使用 HTTP 请求头：

```shell
curl --location --header "DEPLOY-TOKEN: <deploy_token>" \
     --upload-file path/to/file.txt \
     "https://gitlab.example.com/api/v4/projects/24/packages/generic/my_package/1.0.0/file.txt"
```

使用 HTTP 基本身份验证：

```shell
curl --location --user "<deploy_token_username>:<deploy_token>" \
     --upload-file path/to/file.txt \
     "https://gitlab.example.com/api/v4/projects/24/packages/generic/my_package/1.0.0/file.txt"
```

将 `<deploy_token_username>` 替换为您的部署令牌用户名，将 `<deploy_token>` 替换为您实际的部署令牌。

{{< /tab >}}

{{< tab title="CI/CD job token" >}}

这些示例适用于 `.gitlab-ci.yml` 文件。极狐GitLab CI/CD 会自动提供 `CI_JOB_TOKEN`。

使用 HTTP 请求头：

```yaml
publish:
  stage: deploy
  script:
    - |
      curl --location --header "JOB-TOKEN: ${CI_JOB_TOKEN}" \
           --upload-file path/to/file.txt \
           "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/generic/my_package/${CI_COMMIT_TAG}/file.txt"
```

使用 HTTP 基本身份验证：

```yaml
publish:
  stage: deploy
  script:
    - |
      curl --location --user "gitlab-ci-token:${CI_JOB_TOKEN}" \
           --upload-file path/to/file.txt \
           "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/generic/my_package/${CI_COMMIT_TAG}/file.txt"
```

{{< /tab >}}

{{< /tabs >}}

每个请求都会返回一个表示成功或失败的响应。如果上传成功，响应状态为 `201 Created`。

<a id="publish-multiple-files"></a>

### 发布多个文件

要发布多个文件或整个目录，您必须为每个文件发起一次 API 调用。

向仓库发布多个文件时，应遵循以下最佳实践：

- 版本控制：为您的软件包使用一致的版本控制方案。可以基于项目的版本、构建编号或日期。
- 文件组织：考虑您希望如何在软件包内组织文件。您可能希望包含一个清单文件，列出所有包含的文件及其用途。
- 自动化：尽可能通过 CI/CD 流水线自动化发布流程。这可确保一致性并减少人为错误。
- 错误处理：在脚本中实现错误检查。例如，检查 cURL 返回的 HTTP 响应码，以确保每个文件都上传成功。
- 日志记录：维护已上传文件、上传时间及上传者的日志。这对于故障排除和审计至关重要。
- 压缩：对于大型目录，考虑在上传前将内容压缩为单个文件。这可以简化上传流程并减少 API 调用次数。
- 校验和：系统会自动为上传的文件计算并存储 SHA256 校验和。使用校验和验证下载文件的完整性。

例如：

{{< tabs >}}

{{< tab title="With a Bash script" >}}

创建一个 Bash 脚本以遍历文件并上传它们：

```shell
#!/bin/bash

TOKEN="<access_token>"
PROJECT_ID="24"
PACKAGE_NAME="my_package"
PACKAGE_VERSION="1.0.0"
DIRECTORY_PATH="./files_to_upload"

for file in "$DIRECTORY_PATH"/*; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        curl --location --header "PRIVATE-TOKEN: $TOKEN" \
             --upload-file "$file" \
             "https://gitlab.example.com/api/v4/projects/$PROJECT_ID/packages/generic/$PACKAGE_NAME/$PACKAGE_VERSION/$filename"
        echo "Uploaded: $filename"
    fi
done
```

{{< /tab >}}

{{< tab title="With GitLab CI/CD" >}}

要在 CI/CD 流水线中自动上传，您可以遍历文件并上传它们：

```yaml
upload_package:
  stage: publish
  script:
    - |
      for file in ./build/*; do
        if [ -f "$file" ]; then
          filename=$(basename "$file")
          curl --header "JOB-TOKEN: $CI_JOB_TOKEN" \
               --upload-file "$file" \
               "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/generic/my_package/${CI_COMMIT_TAG}/$filename"
          echo "Uploaded: $filename"
        fi
      done
```

{{< /tab >}}

{{< /tabs >}}

<a id="maintain-directory-structure"></a>

### 保持目录结构

要保留已发布目录的结构，请在文件名中包含相对路径：

```shell
#!/bin/bash

TOKEN="<access_token>"
PROJECT_ID="24"
PACKAGE_NAME="my_package"
PACKAGE_VERSION="1.0.0"
DIRECTORY_PATH="./files_to_upload"

find "$DIRECTORY_PATH" -type f | while read -r file; do
    relative_path=${file#"$DIRECTORY_PATH/"}
    curl --location --header "PRIVATE-TOKEN: $TOKEN" \
         --upload-file "$file" \
         "https://gitlab.example.com/api/v4/projects/$PROJECT_ID/packages/generic/$PACKAGE_NAME/$PACKAGE_VERSION/$relative_path"
    echo "Uploaded: $relative_path"
done
```

<a id="download-a-package"></a>

## 下载软件包

您可以使用 API 下载软件包。

<a id="download-a-single-file"></a>

### 下载单个文件

要下载单个软件包文件，请使用以下 API 端点：

```shell
GET /projects/:id/packages/generic/:package_name/:package_version/:file_name
```

将 URL 中的占位符替换为您的具体值：

- `:id`：您的项目 ID 或 URL 编码路径
- `:package_name`：软件包的名称
- `:package_version`：软件包的版本
- `:file_name`：您要下载的文件名

例如：

{{< tabs >}}

{{< tab title="个人访问令牌" >}}

使用 HTTP 请求头：

```shell
curl --header "PRIVATE-TOKEN: <access_token>" \
     --location \
     "https://gitlab.example.com/api/v4/projects/1/packages/generic/my_package/0.0.1/file.txt" \
     --output file.txt
```

使用 HTTP 基本身份验证：

```shell
curl --user "<username>:<access_token>" \
     --location \
     "https://gitlab.example.com/api/v4/projects/1/packages/generic/my_package/0.0.1/file.txt" \
     --output file.txt
```

{{< /tab >}}

{{< tab title="Project access token" >}}

使用 HTTP 请求头：

```shell
curl --header "PRIVATE-TOKEN: <project_access_token>" \
     --location \
     "https://gitlab.example.com/api/v4/projects/1/packages/generic/my_package/0.0.1/file.txt" \
     --output file.txt
```

使用 HTTP 基本身份验证：

```shell
curl --user "<project_access_token_username>:<project_access_token>" \
     --location \
     "https://gitlab.example.com/api/v4/projects/1/packages/generic/my_package/0.0.1/file.txt" \
     --output file.txt
```

{{< /tab >}}

{{< tab title="部署令牌" >}}

使用 HTTP 请求头：

```shell
curl --header "DEPLOY-TOKEN: <deploy_token>" \
     --location \
     "https://gitlab.example.com/api/v4/projects/1/packages/generic/my_package/0.0.1/file.txt" \
     --output file.txt
```

使用 HTTP 基本身份验证：

```shell
curl --user "<deploy_token_username>:<deploy_token>" \
     --location \
     "https://gitlab.example.com/api/v4/projects/1/packages/generic/my_package/0.0.1/file.txt" \
     --output file.txt
```

{{< /tab >}}

{{< tab title="CI/CD job token" >}}

这些示例适用于 `.gitlab-ci.yml` 文件。极狐GitLab CI/CD 会自动提供 `CI_JOB_TOKEN`。

使用 HTTP 请求头：

```yaml
download:
  stage: test
  script:
    - |
      curl --header "JOB-TOKEN: ${CI_JOB_TOKEN}" \
           --location \
           --output file.txt \
           "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/generic/my_package/${CI_COMMIT_TAG}/file.txt"
```

使用 HTTP 基本身份验证：

```yaml
download:
  stage: test
  script:
    - |
      curl --user "gitlab-ci-token:${CI_JOB_TOKEN}" \
           --location \
           --output file.txt \
           "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/generic/my_package/${CI_COMMIT_TAG}/file.txt"
```

每个请求都会返回一个表示成功或失败的响应。如果下载成功，响应状态为 `200 OK`。

{{< /tab >}}

{{< /tabs >}}

<a id="download-multiple-files"></a>

### 下载多个文件

要下载多个文件或整个目录，您必须为每个文件发起一次 API 调用，或使用其他工具。

从仓库下载多个文件时，应遵循以下最佳实践：

- 版本控制：始终指定要下载的软件包的确切版本，以确保一致性。
- 目录结构：下载时，保持软件包的原始目录结构，以保留文件组织方式。
- 自动化：将软件包下载集成到您的 CI/CD 流水线或构建脚本中，以实现自动化工作流。
- 错误处理：实现检查以确保所有文件都下载成功。您可以验证 HTTP 状态码或在下载后检查文件是否存在。
- 缓存：对于频繁使用的软件包，考虑实现缓存机制以减少网络使用并缩短构建时间。
- 并行下载：对于包含许多文件的大型软件包，您可能希望实现并行下载以加快流程。
- 校验和：使用 SHA256 校验和验证下载文件的完整性。校验和会在响应头和 API 响应中提供以供验证。
- 增量下载：对于频繁变更的大型软件包，考虑实现仅下载自上次下载以来已更改文件的机制。

例如：

{{< tabs >}}

{{< tab title="With a Bash script" >}}

创建一个 bash 脚本以下载多个文件：

```shell
#!/bin/bash

TOKEN="<access_token>"
PROJECT_ID="24"
PACKAGE_NAME="my_package"
PACKAGE_VERSION="1.0.0"
OUTPUT_DIR="./downloaded_files"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Array of files to download
files=("file1.txt" "file2.txt" "subdirectory/file3.txt")

for file in "${files[@]}"; do
    curl --location --header "PRIVATE-TOKEN: $TOKEN" \
         --output "$OUTPUT_DIR/$file" \
         --create-dirs \
         "https://gitlab.example.com/api/v4/projects/$PROJECT_ID/packages/generic/$PACKAGE_NAME/$PACKAGE_VERSION/$file"
    echo "Downloaded: $file"
done
```

{{< /tab >}}

{{< tab title="With GitLab CI/CD" >}}

要在 CI/CD 流水线中自动下载：

```yaml
download_package:
  stage: build
  script:
    - |
      FILES=("file1.txt" "file2.txt" "subdirectory/file3.txt")
      for file in "${FILES[@]}"; do
        curl --location --header "JOB-TOKEN: $CI_JOB_TOKEN" \
             --output "$file" \
             --create-dirs \
             "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/generic/my_package/${CI_COMMIT_TAG}/$file"
        echo "Downloaded: $file"
      done
```

{{< /tab >}}

{{< /tabs >}}

<a id="download-an-entire-package"></a>

### 下载整个软件包

要下载软件包中的所有文件，您必须：

1. 获取软件包 ID。
1. 使用极狐GitLab API 列出软件包内容。
1. 下载每个文件。

运行以下命令以下载软件包中的所有文件：

```shell
TOKEN="<access_token>"
PROJECT_ID="24"
PACKAGE_NAME="my_package"
PACKAGE_VERSION="1.0.0"
GITLAB_URL="https://gitlab.example.com"
OUTPUT_DIR="./downloaded_package"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Step 1: Get the package ID
PACKAGE_ID=$(curl --location --header "PRIVATE-TOKEN: $TOKEN" \
     "$GITLAB_URL/api/v4/projects/$PROJECT_ID/packages?package_type=generic&package_name=$PACKAGE_NAME&package_version=$PACKAGE_VERSION" \
     | jq -r ".[] | select(.name==\"$PACKAGE_NAME\" and .version==\"$PACKAGE_VERSION\") | .id")

if [ -z "$PACKAGE_ID" ] || [ "$PACKAGE_ID" = "null" ]; then
    echo "Error: Package '$PACKAGE_NAME' version '$PACKAGE_VERSION' not found"
    exit 1
fi

echo "Found package ID: $PACKAGE_ID"

# Step 2: Get list of files in the package
files=$(curl --location --header "PRIVATE-TOKEN: $TOKEN" \
     "$GITLAB_URL/api/v4/projects/$PROJECT_ID/packages/$PACKAGE_ID/package_files" \
     | jq -r '.[].file_name')

if [ -z "$files" ]; then
    echo "Error: No files found in package"
    exit 1
fi

# Step 3: Download each file
for file in $files; do
    echo "Downloading: $file"
    curl --location --header "PRIVATE-TOKEN: $TOKEN" \
         --output "$OUTPUT_DIR/$file" \
         --create-dirs \
         "$GITLAB_URL/api/v4/projects/$PROJECT_ID/packages/generic/$PACKAGE_NAME/$PACKAGE_VERSION/$file"
    # Check if download was successful
    if [ $? -eq 0 ]; then
        echo "✓ Downloaded: $file"
    else
        echo "✗ Failed to download: $file"
    fi
done

echo "Package download complete"
```

<a id="delete-a-package"></a>

## 删除软件包

在删除软件包之前，请确保您了解[相关的安全风险](../package_registry/supported_functionality.md#deleting-packages)。

要删除软件包，您可以：

- [使用 UI](../package_registry/reduce_package_registry_storage.md#delete-a-package)。
- [使用 API](../../../api/packages.md#delete-a-project-package)。

<a id="verify-file-integrity-with-checksums"></a>

## 使用校验和验证文件完整性

系统会自动为所有上传的文件计算并存储 SHA256 校验和。您可以使用这些校验和验证下载文件的完整性。

要验证校验和，您可以：

- 从 HTTP 响应头获取校验和。
- 从 API 响应获取校验和。
- 在 CI/CD 流水线中集成校验和验证。

<a id="get-checksums-from-response-headers"></a>

### 从响应头获取校验和

下载文件时，您可以在 `X-Checksum-SHA256` 响应头中获取 SHA256 校验和。

先决条件：

要在响应头中获取校验和，您必须满足以下任一条件：

- 禁用对象存储，使文件存储在本地。
- 启用对象存储，但禁用直接下载（文件通过 GitLab Workhorse 提供）。
  启用对象存储直接下载后，文件会被重定向到对象存储提供商，
  并且像 `X-Checksum-SHA256` 这样的自定义响应头无法包含在重定向响应中。

```shell
# Download a file and get the checksum from the response header
curl --header "PRIVATE-TOKEN: <access_token>" \
     --location \
     --output file.txt \
     --dump-header headers.txt \
     --url "https://gitlab.example.com/api/v4/projects/1/packages/generic/my_package/0.0.1/file.txt"

# Extract the checksum from the response header
CHECKSUM=$(grep "X-Checksum-SHA256:" headers.txt | cut -d' ' -f2 | tr -d '\r')
echo "Expected checksum: $CHECKSUM"

# Verify the downloaded file
ACTUAL_CHECKSUM=$(sha256sum file.txt | cut -d' ' -f1)
if [ "$CHECKSUM" = "$ACTUAL_CHECKSUM" ]; then
    echo "✓ File integrity verified"
else
    echo "✗ File integrity check failed"
fi
```

<a id="get-checksums-from-api-responses"></a>

### 从 API 响应获取校验和

通过在 API 调用中列出软件包文件来获取校验和：

```shell
# Get the package ID
PACKAGE_ID=$(curl --header "PRIVATE-TOKEN: <access_token>" \
     --url "https://gitlab.example.com/api/v4/projects/1/packages?package_type=generic&package_name=my_package&package_version=0.0.1" \
     | jq -r ".[] | select(.name==\"my_package\" and .version==\"0.0.1\") | .id")

# Get file information, including checksums
curl --header "PRIVATE-TOKEN: <access_token>" \
     --url "https://gitlab.example.com/api/v4/projects/1/packages/$PACKAGE_ID/package_files" \
     | jq '.[] | {file_name: .file_name, file_sha256: .file_sha256}'
```

<a id="verify-file-integrity-in-cicd-pipelines"></a>

### 在 CI/CD 流水线中验证文件完整性

您可以将校验和验证集成到您的 CI/CD 流水线中。

先决条件：

要在 CI/CD 流水线中验证校验和，您必须满足以下任一条件：

- 禁用对象存储，使文件存储在本地。
- 启用对象存储，但禁用直接下载（文件通过 GitLab Workhorse 提供）。
  启用对象存储直接下载后，文件会被重定向到对象存储提供商，
  并且像 `X-Checksum-SHA256` 这样的自定义响应头无法包含在重定向响应中。

```yaml
verify_download:
  stage: test
  script:
    - |
      # Download file and get checksum from header
      curl --header "JOB-TOKEN: ${CI_JOB_TOKEN}" \
           --location \
           --output file.txt \
           --dump-header headers.txt \
           "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/generic/my_package/${CI_COMMIT_TAG}/file.txt"

      # Extract checksum from response header
      EXPECTED_CHECKSUM=$(grep "X-Checksum-SHA256:" headers.txt | cut -d' ' -f2 | tr -d '\r')

      # Calculate actual checksum
      ACTUAL_CHECKSUM=$(sha256sum file.txt | cut -d' ' -f1)

      # Verify integrity
      if [ "$EXPECTED_CHECKSUM" = "$ACTUAL_CHECKSUM" ]; then
        echo "✓ File integrity verified"
      else
        echo "✗ File integrity check failed"
        exit 1
      fi
```

<a id="disable-publishing-duplicate-package-names"></a>

## 禁止发布重复的软件包名称

默认情况下，当您发布的软件包与现有软件包具有相同的名称和版本时，新文件会被添加到现有软件包中。您可以在设置中禁止发布重复的文件名。

先决条件：

- 您必须具有所有者角色。

要禁止发布重复的文件名：

1. 在顶部栏中，选择**搜索或跳转到**并找到您的群组。
1. 在左侧边栏中，选择**设置** > **软件包与镜像库**。
1. 在**重复软件包**表格的**通用**行中，关闭**允许重复**开关。
1. 可选。在**例外**文本框中，输入一个正则表达式，以匹配要允许的软件包名称和版本。

> [!note]
> 如果**允许重复**已开启，您可以在**例外**文本框中指定不应有重复的软件包名称和版本。

<a id="add-a-package-retention-policy"></a>

## 添加软件包保留策略

实施软件包保留策略以管理存储并维护相关版本。

为此：

- 使用极狐GitLab 内置的[清理策略](../package_registry/reduce_package_registry_storage.md#cleanup-policy)。

您也可以使用 API 实现自定义清理脚本。

<a id="generic-package-sample-project"></a>

## 通用软件包示例项目

[在流水线中写入 CI-CD 变量](https://gitlab.com/guided-explorations/cfg-data/write-ci-cd-variables-in-pipeline)项目包含一个可用的示例，您可以用它在极狐GitLab CI/CD 中创建、上传和下载通用软件包。

它还演示了如何管理通用软件包的语义版本：将其存储在 CI/CD 变量中、检索它、递增它，并在下载测试正确运行时将其写回 CI/CD 变量。

<a id="valid-package-filename-format"></a>

## 有效的软件包文件名格式

有效的软件包文件名可以包含：

- 字母：A-Z、a-z
- 数字：0-9
- 特殊字符：.（点）、_（下划线）、-（连字符）、+（加号）、~（波浪号）、@（at 符号）、/（正斜杠）

软件包文件名不能：

- 以波浪号（~）或 at 符号（@）开头
- 以波浪号（~）或 at 符号（@）结尾
- 包含空格

<a id="troubleshooting"></a>

## 故障排除

<a id="http-403-errors"></a>

### HTTP 403 错误

您可能会遇到 `HTTP 403 Forbidden` 错误。此错误发生在以下任一情况：

- 您无权访问某个资源。
- 项目未启用软件包仓库。

要解决此问题，请确保已启用软件包仓库，并且您有权访问它。

<a id="internal-server-error-on-large-file-uploads-to-s3"></a>

### 向 S3 上传大文件时出现内部服务器错误

兼容 S3 的对象存储[将单个 PUT 请求的大小限制为 5 GB](https://docs.aws.amazon.com/AmazonS3/latest/userguide/upload-objects.html)。如果在[对象存储连接设置](../../../administration/object_storage.md)中将 `aws_signature_version` 设置为 `2`，尝试发布大于 5 GB 限制的软件包文件可能会导致 `HTTP 500: Internal Server Error` 响应。

如果您在向 S3 发布大文件时收到 `HTTP 500: Internal Server Error` 响应，请将 `aws_signature_version` 设置为 `4`：

```ruby
# Consolidated Object Storage settings
gitlab_rails['object_store']['connection'] = {
  # Other connection settings
  'aws_signature_version' => '4'
}
# OR
# Storage-specific form settings
gitlab_rails['packages_object_store_connection'] = {
  # Other connection settings
  'aws_signature_version' => '4'
}
```
