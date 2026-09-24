---
stage: Software Supply Chain Security
group: Pipeline Security
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 项目级安全文件
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- GA 和功能标志 `ci_secure_files` 在 极狐GitLab 15.7 中被移除。

{{< /history >}}

您可以将最多 100 个文件安全地存储为安全文件，以便在 CI/CD 流水线中使用。这些文件安全地存储在项目仓库之外，且不受版本控制。在这些文件中存储敏感信息是安全的。安全文件支持纯文本和二进制文件类型，但文件大小必须为 5 MB 或更小。

您可以在项目设置中管理安全文件，或使用 [安全文件 API](../../api/secure_files.md)。

安全文件可以通过使用 [`glab securefile`](https://jihulab.com/gitlab-cn/cli/-/tree/main/docs/source/securefile) 命令被 [CI/CD 作业下载和使用](#use-secure-files-in-cicd-jobs)。

<a id="add-a-secure-file-to-a-project"></a>

## 向项目添加安全文件

要向项目添加安全文件：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **设置** > **CI/CD**。
1. 展开 **安全文件** 部分。
1. 选择 **上传文件**。
1. 找到要上传的文件，选择 **打开**，文件上传立即开始。上传完成后，文件将显示在列表中。

<a id="use-secure-files-in-cicd-jobs"></a>

## 在 CI/CD 作业中使用安全文件

> [!warning]
> 安全文件的内容在作业日志输出中未被 [屏蔽](../variables/_index.md#mask-a-cicd-variable)。请确保避免在作业日志中输出安全文件内容，尤其是在记录可能包含敏感信息的输出时。

<a id="with-the-glab-tool"></a>

### 使用 `glab` 工具

要使用 [`glab`](https://jihulab.com/gitlab-cn/cli/) 下载一个或多个安全文件，您可以在 CI/CD 作业中使用 `cli` Docker 镜像。

<a id="download-all-the-files-in-a-project"></a>

#### 下载项目中的所有文件

```yaml
test:
  image: registry.jihulab.com/gitlab-cn/cli:latest
  script:
    - glab auth login --job-token $CI_JOB_TOKEN --hostname $CI_SERVER_FQDN --api-protocol $CI_SERVER_PROTOCOL
    - glab -R $CI_PROJECT_PATH securefile download --all --output-dir="where/to/save"
```

在此示例中，所有变量都是自动可用的 [预定义变量](../variables/predefined_variables.md)。

<a id="download-a-single-file-in-a-project"></a>

#### 下载项目中的单个文件

```yaml
test:
  image: registry.jihulab.com/gitlab-cn/cli:latest
  script:
    - glab auth login --job-token $CI_JOB_TOKEN --hostname $CI_SERVER_FQDN --api-protocol $CI_SERVER_PROTOCOL
    - glab -R $CI_PROJECT_PATH securefile download $SECURE_FILE_ID --path="where/to/save/file.txt"
```

`SECURE_FILE_ID` CI/CD 变量需要显式传递给作业，例如在 [CI/CD 设置](../variables/_index.md#define-a-cicd-variable-in-the-ui) 中或 [手动运行流水线](../pipelines/_index.md#run-a-pipeline-manually) 时。其他所有变量都是自动可用的 [预定义变量](../variables/predefined_variables.md)。

或者，您也可以不使用 Docker 镜像，而是 [下载二进制文件](https://jihulab.com/gitlab-cn/cli/-/releases) 并在 CI/CD 作业中使用它。

<a id="with-the-download-secure-files-tool-deprecated"></a>

### 使用 `download-secure-files` 工具（已弃用）

{{< history >}}

- 在 极狐GitLab 18.6 中已弃用。

{{< /history >}}

> [!warning]
> 此方法已弃用。

要在 CI/CD 作业中使用安全文件，您可以使用 [`download-secure-files`](https://jihulab.com/gitlab-cn/incubation-engineering/mobile-devops/download-secure-files) 工具在作业中下载文件。下载后，您可以将其与其他脚本命令一起使用。

在作业的 `script` 部分添加命令以下载 `download-secure-files` 工具并执行它。文件将下载到项目根目录下的 `.secure_files` 目录中。要更改安全文件的下载位置，请在 `SECURE_FILES_DOWNLOAD_PATH` [CI/CD 变量](../variables/_index.md) 中设置路径。

例如：

```yaml
test:
  variables:
    SECURE_FILES_DOWNLOAD_PATH: './where/files/should/go/'
  script:
    - curl --silent "https://jihulab.com/gitlab-cn/incubation-engineering/mobile-devops/download-secure-files/-/raw/main/installer" | bash
```

<a id="security-details"></a>

## 安全细节

项目级安全文件在上传时使用 [Lockbox](https://github.com/ankane/lockbox) Ruby gem 通过 [`Ci::SecureFileUploader`](https://jihulab.com/gitlab-cn/gitlab/-/blob/master/app/uploaders/ci/secure_file_uploader.rb) 接口进行加密。该接口在上传期间生成源文件的 SHA256 校验和，该校验和与记录一起持久化在数据库中，以便在下载时用于验证文件内容。

每个文件在创建时都会生成一个 [唯一的加密密钥](https://jihulab.com/gitlab-cn/gitlab/-/blob/master/app/models/ci/secure_file.rb#L27) 并持久化在数据库中。加密的上传文件根据 [极狐GitLab 实例配置](../../administration/cicd/secure_files.md) 存储在本地存储或对象存储中。

可以使用 [安全文件下载 API](../../api/secure_files.md#download-a-secure-file) 检索单个文件。可以使用 [列表](../../api/secure_files.md#list-all-secure-files-for-a-project) 或 [显示](../../api/secure_files.md#retrieve-details-of-a-secure-file) API 端点检索元数据。也可以使用 [`glab securefile`](https://jihulab.com/gitlab-cn/cli/-/tree/main/docs/source/securefile) 命令检索文件。此命令在下载每个文件时自动验证其校验和。

任何具有开发者、维护者或所有者角色的项目成员都可以访问项目级安全文件。与项目级安全文件的交互不包含在审计事件中。