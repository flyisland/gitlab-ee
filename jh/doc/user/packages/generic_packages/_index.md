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

使用通用软件包仓库在项目的软件包仓库中发布和管理通用文件，例如发布二进制文件。此功能特别适用于存储和分发不适合特定软件包格式（如 npm 或 Maven）的产物。

通用软件包仓库提供：

- 一个将任何文件类型存储为软件包的位置。
- 软件包的版本控制。
- 与极狐GitLab CI/CD 集成。
- 用于自动化的 API 访问。

<a id="authenticate-to-the-package-registry"></a>

## 向软件包仓库认证

要与软件包仓库交互，你必须使用以下方法之一进行认证：

- 一个范围设置为 `api` 的[个人访问令牌](../../profile/personal_access_tokens.md)。
- 一个范围设置为 `api` 且具有开发者、维护者或所有者角色的[项目访问令牌](../../project/settings/project_access_tokens.md)。
- 一个 [CI/CD 作业令牌](../../../ci/jobs/ci_job_token.md)。
- 一个范围设置为 `read_package_registry`、`write_package_registry` 或两者的[部署令牌](../../project/deploy_tokens/_index.md)。

不要使用此处未记录的认证方法。未记录的认证方法将来可能会被移除。

当你向软件包仓库认证时，应遵循以下最佳实践：

- 要访问与开发者角色关联的权限，请使用个人访问令牌。
- 对自动化流水线使用 CI/CD 作业令牌。
- 对外部系统集成使用部署令牌。
- 始终通过 HTTPS 发送认证信息。

<a id="http-basic-authentication"></a>

### HTTP 基本认证

如果你使用的工具不支持标准认证方法，可以使用 HTTP 基本认证：

```shell
curl --user "<用户名>:<令牌>" <其他选项> <极狐GitLab API 端点>
```

尽管用户名会被忽略，但你必须提供。令牌是你的个人访问令牌、CI/CD 作业令牌或部署令牌。

<a id="publish-a-package"></a>

## 发布软件包

你可以使用 API 发布软件包。

<a id="publish-a-single-file"></a>

### 发布单个文件

要发布单个文件，请使用以下 API 端点：

```shell
PUT /projects/:id/packages/generic/:package_name/:package_version/:file_name
```

将 URL 中的占位符替换为你的具体值：

- `:id`：你的项目 ID 或 URL 编码路径
- `:package_name`：你的软件包名称
- `:package_version`：你的软件包版本
- `:file_name`：你要上传的文件名。请参阅下面的[有效的软件包文件名格式](#valid-package-filename-format)。

例如：

{{< tabs >}}

{{< tab title="个人访问令牌" >}}

使用 HTTP 头：

```shell
curl --location --header "PRIVATE-TOKEN: <个人访问令牌>" \
     --upload-file path/to/file.txt \
     "https://gitlab.example.com/api/v4/projects/24/packages/generic/my_package/1.0.0/file.txt"
```

使用 HTTP 基本认证：

```shell
curl --location --user "<用户名>:<个人访问令牌>" \
     --upload-file path/to/file.txt \
     "https://gitlab.example.com/api/v4/projects/24/packages/generic/my_package/1.0.0/file.txt"
```

{{< /tab >}}

{{< tab title="项目访问令牌" >}}

使用 HTTP 头：

```shell
curl --location --header "PRIVATE-TOKEN: <项目访问令牌>" \
     --upload-file path/to/file.txt \
     "https://gitlab.example.com/api/v4/projects/24/packages/generic/my_package/1.0.0/file.txt"
```

使用 HTTP 基本认证：

```shell
curl --location --user "<项目访问令牌用户名>:项目访问令牌" \
     --upload-file path/to/file.txt \
     "https://gitlab.example.com/api/v4/projects/24/packages/generic/my_package/1.0.0/file.txt"
```

{{< /tab >}}

{{< tab title="部署令牌" >}}

使用 HTTP 头：

```shell
curl --location --header "DEPLOY-TOKEN: <部署令牌>" \
     --upload-file path/to/file.txt \
     "https://gitlab.example.com/api/v4/projects/24/packages/generic/my_package/1.0.0/file.txt"
```

使用 HTTP 基本认证：

```shell
curl --location --user "<部署令牌用户名>:<部署令牌>" \
     --upload-file path/to/file.txt \
     "https://gitlab.example.com/api/v4/projects/24/packages/generic/my_package/1.0.0/file.txt"
```

将 `<部署令牌用户名>` 替换为你的部署令牌用户名，`<部署令牌>` 替换为你的实际部署令牌。

{{< /tab >}}

{{< tab title="CI/CD 作业令牌" >}}

这些示例适用于 `.gitlab-ci.yml` 文件。极狐GitLab CI/CD 会自动提供 `CI_JOB_TOKEN`。

使用 HTTP 头：

```yaml
publish:
  stage: deploy
  script:
    - |
      curl --location --header "JOB-TOKEN: ${CI_JOB_TOKEN}" \
           --upload-file path/to/file.txt \
           "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/generic/my_package/${CI_COMMIT_TAG}/file.txt"
```

使用 HTTP 基本认证：

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

每个请求都会返回一个指示成功或失败的响应。如果上传成功，响应状态为 `201 Created`。

<a id="publish-multiple-files"></a>

### 发布多个文件

要发布多个文件或整个目录，你必须为每个文件发起一次 API 调用。

向仓库发布多个文件时，应遵循以下最佳实践：

- 版本控制：为你的软件包使用一致的版本控制方案。可以基于项目版本、构建编号或日期。
- 文件组织：考虑如何构建软件包内的文件。你可能希望包含一个清单文件，列出所有包含的文件及其用途。
- 自动化：尽可能通过 CI/CD 流水线自动化发布过程。这可以确保一致性并减少手动错误。
- 错误处理：在脚本中实现错误检查。例如，检查 cURL 的 HTTP 响应码以确保每个文件上传成功。
- 日志记录：维护哪些文件被上传、何时上传以及由谁上传的日志。这对于故障排除和审计至关重要。
- 压缩：对于大型目录，考虑在上传前将内容压缩为单个文件。这可以简化上传过程并减少 API 调用次数。
- 校验和：上传的文件会自动计算并存储 SHA256 校验和。使用校验和验证下载文件的完整性。

例如：

{{< tabs >}}

{{< tab title="使用 Bash 脚本" >}}

创建一个 Bash 脚本来遍历文件并上传：

```shell
#!/bin/bash

TOKEN="<访问令牌>"
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
        echo "已上传: $filename"
    fi
done
```

{{< /tab >}}

{{< tab title="使用极狐GitLab CI/CD" >}}

对于 CI/CD 流水线中的自动上传，你可以遍历文件并上传：

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
          echo "已上传: $filename"
        fi
      done
```

{{< /tab >}}

{{< /tabs >}}

<a id="maintain-directory-structure"></a>

### 维护目录结构

要保留已发布目录的结构，请在文件名中包含相对路径：

```shell
#!/bin/bash

TOKEN="<访问令牌>"
PROJECT_ID="24"
PACKAGE_NAME="my_package"
PACKAGE_VERSION="1.0.0"
DIRECTORY_PATH="./files_to_upload"

find "$DIRECTORY_PATH" -type f | while read -r file; do
    relative_path=${file#"$DIRECTORY_PATH/"}
    curl --location --header "PRIVATE-TOKEN: $TOKEN" \
         --upload-file "$file" \
         "https://gitlab.example.com/api/v4/projects/$PROJECT_ID/packages/generic/$PACKAGE_NAME/$PACKAGE_VERSION/$relative_path"
    echo "已上传: $relative_path"
done
```

<a id="download-a-package"></a>

## 下载软件包

你可以使用 API 下载软件包。

<a id="download-a-single-file"></a>

### 下载单个文件

要下载单个软件包文件，请使用以下 API 端点：

```shell
GET /projects/:id/packages/generic/:package_name/:package_version/:file_name
```

将 URL 中的占位符替换为你的具体值：

- `:id`：你的项目 ID 或 URL 编码路径
- `:package_name`：你的软件包名称
- `:package_version`：你的软件包版本
- `:file_name`：你要上传的文件名

例如：

{{< tabs >}}

{{< tab title="个人访问令牌" >}}

使用 HTTP 头：

```shell
curl --header "PRIVATE-TOKEN: <访问令牌>" \
     --location \
     "https://gitlab.example.com/api/v4/projects/1/packages/generic/my_package/0.0.1/file.txt" \
     --output file.txt
```

使用 HTTP 基本认证：

```shell
curl --user "<用户名>:<访问令牌>" \
     --location \
     "https://gitlab.example.com/api/v4/projects/1/packages/generic/my_package/0.0.1/file.txt" \
     --output file.txt
```

{{< /tab >}}

{{< tab title="项目访问令牌" >}}

使用 HTTP 头：

```shell
curl --header "PRIVATE-TOKEN: <项目访问令牌>" \
     --location \
     "https://gitlab.example.com/api/v4/projects/1/packages/generic/my_package/0.0.1/file.txt" \
     --output file.txt
```

使用 HTTP 基本认证：

```shell
curl --user "<项目访问令牌用户名>:<项目访问令牌>" \
     --location \
     "https://gitlab.example.com/api/v4/projects/1/packages/generic/my_package/0.0.1/file.txt" \
     --output file.txt
```

{{< /tab >}}

{{< tab title="部署令牌" >}}

使用 HTTP 头：

```shell
curl --header "DEPLOY-TOKEN: <部署令牌>" \
     --location \
     "https://gitlab.example.com/api/v4/projects/1/packages/generic/my_package/0.0.1/file.txt" \
     --output file.txt
```

使用 HTTP 基本认证：

```shell
curl --user "<部署令牌用户名>:<部署令牌>" \
     --location \
     "https://gitlab.example.com/api/v4/projects/1/packages/generic/my_package/0.0.1/file.txt" \
     --output file.txt
```

{{< /tab >}}

{{< tab title="CI/CD 作业令牌" >}}

这些示例适用于 `.gitlab-ci.yml` 文件。极狐GitLab CI/CD 会自动提供 `CI_JOB_TOKEN`。

使用 HTTP 头：

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

使用 HTTP 基本认证：

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

每个请求都会返回一个指示成功或失败的响应。如果上传成功，响应状态为 `201 Created`。

{{< /tab >}}

{{< /tabs >}}

<a id="download-multiple-files"></a>

### 下载多个文件

要下载多个文件或整个目录，你必须为每个文件发起一次 API 调用，或使用其他工具。

从仓库下载多个文件时，应遵循以下最佳实践：

- 版本控制：始终指定要下载的软件包的确切版本以确保一致性。
- 目录结构：下载时，保持软件包的原始目录结构以保留文件组织。
- 自动化：将软件包下载集成到 CI/CD 流水线或构建脚本中，以实现自动化工作流。
- 错误处理：实现检查以确保所有文件下载成功。你可以验证 HTTP 状态码或下载后检查文件是否存在。
- 缓存：对于频繁使用的软件包，考虑实现缓存机制以减少网络使用并缩短构建时间。
- 并行下载：对于包含许多文件的大型软件包，你可能希望实现并行下载以加快过程。
- 校验和：使用 SHA256 校验和验证下载文件的完整性。校验和在响应头和 API 响应中提供以供验证。
- 增量下载：对于频繁更改的大型软件包，考虑实现一种机制，仅下载自上次下载以来发生更改的文件。

例如：

{{< tabs >}}

{{< tab title="使用 Bash 脚本" >}}

创建一个 bash 脚本来下载多个文件：

```shell
#!/bin/bash

TOKEN="<访问令牌>"
PROJECT_ID="24"
PACKAGE_NAME="my_package"
PACKAGE_VERSION="1.0.0"
OUTPUT_DIR="./downloaded_files"

# 如果输出目录不存在则创建
mkdir -p "$OUTPUT_DIR"

# 要下载的文件数组
files=("file1.txt" "file2.txt" "subdirectory/file3.txt")

for file in "${files[@]}"; do
    curl --location --header "PRIVATE-TOKEN: $TOKEN" \
         --output "$OUTPUT_DIR/$file" \
         --create-dirs \
         "https://gitlab.example.com/api/v4/projects/$PROJECT_ID/packages/generic/$PACKAGE_NAME/$PACKAGE_VERSION/$file"
    echo "已下载: $file"
done
```

{{< /tab >}}

{{< tab title="使用极狐GitLab CI/CD" >}}

对于 CI/CD 流水线中的自动下载：

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
        echo "已下载: $file"
      done
```

{{< /tab >}}

{{< /tabs >}}

<a id="download-an-entire-package"></a>

### 下载整个软件包

要下载软件包中的所有文件，你必须：

1. 获取软件包 ID。
1. 使用极狐GitLab API 列出软件包内容。
1. 下载每个文件。

运行以下命令下载软件包中的所有文件：

```shell
TOKEN="<访问令牌>"
PROJECT_ID="24"
PACKAGE_NAME="my_package"
PACKAGE_VERSION="1.0.0"
GITLAB_URL="https://gitlab.example.com"
OUTPUT_DIR="./downloaded_package"

# 创建输出目录
mkdir -p "$OUTPUT_DIR"

# 步骤 1：获取软件包 ID
PACKAGE_ID=$(curl --location --header "PRIVATE-TOKEN: $TOKEN" \
     "$GITLAB_URL/api/v4/projects/$PROJECT_ID/packages?package_type=generic&package_name=$PACKAGE_NAME&package_version=$PACKAGE_VERSION" \
     | jq -r ".[] | select(.name==\"$PACKAGE_NAME\" and .version==\"$PACKAGE_VERSION\") | .id")

if [ -z "$PACKAGE_ID" ] || [ "$PACKAGE_ID" = "null" ]; then
    echo "错误: 未找到软件包 '$PACKAGE_NAME' 版本 '$PACKAGE_VERSION'"
    exit 1
fi

echo "找到软件包 ID: $PACKAGE_ID"

# 步骤 2：获取软件包中的文件列表
files=$(curl --location --header "PRIVATE-TOKEN: $TOKEN" \
     "$GITLAB_URL/api/v4/projects/$PROJECT_ID/packages/$PACKAGE_ID/package_files" \
     | jq -r '.[].file_name')

if [ -z "$files" ]; then
    echo "错误: 软件包中未找到文件"
    exit 1
fi

# 步骤 3：下载每个文件
for file in $files; do
    echo "正在下载: $file"
    curl --location --header "PRIVATE-TOKEN: $TOKEN" \
         --output "$OUTPUT_DIR/$file" \
         --create-dirs \
         "$GITLAB_URL/api/v4/projects/$PROJECT_ID/packages/generic/$PACKAGE_NAME/$PACKAGE_VERSION/$file"
    # 检查下载是否成功
    if [ $? -eq 0 ]; then
        echo "✓ 已下载: $file"
    else
        echo "✗ 下载失败: $file"
    fi
done

echo "软件包下载完成"
```

<a id="delete-a-package"></a>

## 删除软件包

在删除软件包之前，请确保你了解[相关安全风险](../package_registry/supported_functionality.md#deleting-packages)。

要删除软件包，你可以：

- [使用 UI](../package_registry/reduce_package_registry_storage.md#delete-a-package)。
- [使用 API](../../../api/packages.md#delete-a-project-package)。

<a id="verify-file-integrity-with-checksums"></a>

## 使用校验和验证文件完整性

所有上传的文件都会自动计算并存储 SHA256 校验和。你可以使用这些校验和验证下载文件的完整性。

要验证校验和，你可以：

- 从 HTTP 响应头获取校验和。
- 从 API 响应获取校验和。
- 在 CI/CD 流水线中集成校验和验证。

<a id="get-checksums-from-response-headers"></a>

### 从响应头获取校验和

下载文件时，你可以在 `X-Checksum-SHA256` 响应头中获取 SHA256 校验和。

先决条件：

要从响应头获取校验和，你必须：

- 禁用对象存储以便文件存储在本地。
- 或者启用对象存储但禁用直接下载（文件通过极狐GitLab Workhorse 提供）。
  当对象存储直接下载启用时，文件被重定向到对象存储提供商，
  并且像 `X-Checksum-SHA256` 这样的自定义头无法包含在重定向响应中。

```shell
# 下载文件并从响应头获取校验和
curl --header "PRIVATE-TOKEN: <访问令牌>" \
     --location \
     --output file.txt \
     --dump-header headers.txt \
     --url "https://gitlab.example.com/api/v4/projects/1/packages/generic/my_package/0.0.1/file.txt"

# 从响应头提取校验和
CHECKSUM=$(grep "X-Checksum-SHA256:" headers.txt | cut -d' ' -f2 | tr -d '\r')
echo "预期校验和: $CHECKSUM"

# 验证下载的文件
ACTUAL_CHECKSUM=$(sha256sum file.txt | cut -d' ' -f1)
if [ "$CHECKSUM" = "$ACTUAL_CHECKSUM" ]; then
    echo "✓ 文件完整性验证通过"
else
    echo "✗ 文件完整性检查失败"
fi
```

<a id="get-checksums-from-api-responses"></a>

### 从 API 响应获取校验和

通过在 API 调用中列出软件包文件来获取校验和：

```shell
# 获取软件包 ID
PACKAGE_ID=$(curl --header "PRIVATE-TOKEN: <访问令牌>" \
     --url "https://gitlab.example.com/api/v4/projects/1/packages?package_type=generic&package_name=my_package&package_version=0.0.1" \
     | jq -r ".[] | select(.name==\"my_package\" and .version==\"0.0.1\") | .id")

# 获取文件信息，包括校验和
curl --header "PRIVATE-TOKEN: <访问令牌>" \
     --url "https://gitlab.example.com/api/v4/projects/1/packages/$PACKAGE_ID/package_files" \
     | jq '.[] | {file_name: .file_name, file_sha256: .file_sha256}'
```

<a id="verify-file-integrity-in-cicd-pipelines"></a>

### 在 CI/CD 流水线中验证文件完整性

你可以将校验和验证集成到 CI/CD 流水线中。

先决条件：

要在 CI/CD 流水线中验证校验和，你必须：

- 禁用对象存储以便文件存储在本地。
- 或者启用对象存储但禁用直接下载（文件通过极狐GitLab Workhorse 提供）。
  当对象存储直接下载启用时，文件被重定向到对象存储提供商，
  并且像 `X-Checksum-SHA256` 这样的自定义头无法包含在重定向响应中。

```yaml
verify_download:
  stage: test
  script:
    - |
      # 下载文件并从响应头获取校验和
      curl --header "JOB-TOKEN: ${CI_JOB_TOKEN}" \
           --location \
           --output file.txt \
           --dump-header headers.txt \
           "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/generic/my_package/${CI_COMMIT_TAG}/file.txt"

      # 从响应头提取校验和
      EXPECTED_CHECKSUM=$(grep "X-Checksum-SHA256:" headers.txt | cut -d' ' -f2 | tr -d '\r')

      # 计算实际校验和
      ACTUAL_CHECKSUM=$(sha256sum file.txt | cut -d' ' -f1)

      # 验证完整性
      if [ "$EXPECTED_CHECKSUM" = "$ACTUAL_CHECKSUM" ]; then
        echo "✓ 文件完整性验证通过"
      else
        echo "✗ 文件完整性检查失败"
        exit 1
      fi
```

<a id="disable-publishing-duplicate-package-names"></a>

## 禁用发布重复软件包名称

{{< history >}}

- 所需角色在极狐GitLab 15.0 中从开发者更改为维护者。
- 所需角色在极狐GitLab 17.0 中从维护者更改为所有者。

{{< /history >}}

默认情况下，当你发布与现有软件包名称和版本相同的软件包时，新文件会添加到现有软件包中。你可以在设置中禁用发布重复文件名。

先决条件：

- 你必须具有所有者角色。

要禁用发布重复文件名：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的群组。
1. 在左侧边栏中，选择 **设置** > **软件包和镜像库**。
1. 在 **重复软件包** 表的 **通用** 行中，关闭 **允许重复** 开关。
1. 可选。在 **例外** 文本框中，输入一个正则表达式，匹配允许重复的软件包名称和版本。

> [!note]
> 如果 **允许重复** 已开启，你可以在 **例外** 文本框中指定不应有重复的软件包名称和版本。

<a id="add-a-package-retention-policy"></a>

## 添加软件包保留策略

实施软件包保留策略以管理存储并维护相关版本。

为此：

- 使用内置的极狐GitLab [清理策略](../package_registry/reduce_package_registry_storage.md#cleanup-policy)。

你也可以使用 API 实现自定义清理脚本。

<a id="generic-package-sample-project"></a>

## 通用软件包示例项目

[在流水线中写入 CI-CD 变量](https://gitlab.com/guided-explorations/cfg-data/write-ci-cd-variables-in-pipeline) 项目包含一个工作示例，你可以使用它在极狐GitLab CI/CD 中创建、上传和下载通用软件包。

它还演示了如何管理通用软件包的语义版本：将其存储在 CI/CD 变量中，检索它，递增它，并在下载测试正常工作时将其写回 CI/CD 变量。

<a id="valid-package-filename-format"></a>

## 有效的软件包文件名格式

有效的软件包文件名可以包含：

- 字母：A-Z、a-z
- 数字：0-9
- 特殊字符：.（点）、_（下划线）、-（连字符）、+（加号）、~（波浪号）、@（at 符号）、/（正斜杠）

软件包文件名不能：

- 以波浪号 (~) 或 at 符号 (@) 开头
- 以波浪号 (~) 或 at 符号 (@) 结尾
- 包含空格

<a id="troubleshooting"></a>

## 故障排除

<a id="http-403-errors"></a>

### HTTP 403 错误

你可能会遇到 `HTTP 403 Forbidden` 错误。此错误发生在以下情况之一：

- 你没有访问资源的权限。
- 项目未启用软件包仓库。

要解决此问题，请确保软件包仓库已启用，并且你有权访问它。

<a id="internal-server-error-on-large-file-uploads-to-s3"></a>

### 上传大文件到 S3 时出现内部服务器错误

S3 兼容的对象存储[将单个 PUT 请求的大小限制为 5 GB](https://docs.aws.amazon.com/AmazonS3/latest/userguide/upload-objects.html)。如果在[对象存储连接设置](../../../administration/object_storage.md)中将 `aws_signature_version` 设置为 `2`，尝试发布大于 5 GB 限制的软件包文件可能会导致 `HTTP 500: Internal Server Error` 响应。

如果你在将大文件发布到 S3 时收到 `HTTP 500: Internal Server Error` 响应，请将 `aws_signature_version` 设置为 `4`：

```ruby
# 统一对象存储设置
gitlab_rails['object_store']['connection'] = {
  # 其他连接设置
  'aws_signature_version' => '4'
}
# 或者
# 存储特定表单设置
gitlab_rails['packages_object_store_connection'] = {
  # 其他连接设置
  'aws_signature_version' => '4'
}
```