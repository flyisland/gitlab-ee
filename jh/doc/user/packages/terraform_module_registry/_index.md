---
stage: Package
group: Package Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Terraform 模块仓库
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 基础架构仓库和 Terraform 模块仓库在极狐GitLab 15.11 中合并为单一的 Terraform 模块仓库功能。
- 群组支持在极狐GitLab 16.9 中引入。

{{< /history >}}

通过 Terraform 模块仓库，你可以：

- 使用极狐GitLab 项目作为 Terraform 模块的私有仓库。
- 通过极狐GitLab CI/CD 创建并发布模块，其他私有项目随后可以引用这些模块。

<a id="authenticate-to-the-terraform-module-registry"></a>

## 认证 Terraform 模块仓库

要认证 Terraform 模块仓库，你需要以下任一凭据：

- 一个至少具有 `read_api` 范围的[个人访问令牌](../../profile/personal_access_tokens.md)。
- 一个 [CI/CD 作业令牌](../../../ci/jobs/ci_job_token.md)。
- 一个具有 `read_package_registry` 或 `write_package_registry` 范围或两者兼具的[部署令牌](../../project/deploy_tokens/_index.md)。

使用 API 时：

- 如果你使用部署令牌进行认证，必须应用 `write_package_registry` 范围来发布模块。要下载模块，需应用 `read_package_registry` 范围。
- 如果你使用个人访问令牌进行认证，必须将其配置为至少具有 `read_api` 范围。

请勿使用本文档未记载的认证方法。未记载的认证方法将来可能会被移除。

<a id="prerequisites"></a>

## 前提条件

要发布 Terraform 模块：

- 你必须拥有开发者、维护者或所有者角色。

要删除模块：

- 你必须拥有维护者或所有者角色。

<a id="publish-a-terraform-module"></a>

## 发布 Terraform 模块

发布 Terraform 模块时，如果模块不存在，则会创建它。

发布模块后，你可以在 [**Terraform 模块仓库**](#view-terraform-modules) 页面查看它。

<a id="with-the-api"></a>

### 使用 API

使用 [Terraform 模块仓库 API](../../../api/packages/terraform-modules.md) 发布 Terraform 模块。

```plaintext
PUT /projects/:id/packages/terraform/modules/:module-name/:module-system/:module-version/file
```

| 属性          | 类型            | 是否必需 | 描述                                                                                                                      |
| -------------------| --------------- | ---------| -------------------------------------------------------------------------------------------------------------------------------- |
| `id`               | 整数/字符串  | 是      | 项目 ID 或 [URL 编码路径](../../../api/rest/_index.md#namespaced-paths)。                                    |
| `module-name`      | 字符串          | 是      | 模块名称。支持语法：1 到 64 个 ASCII 字符，包含小写字母 (a-z) 和数字 (0-9)。 |
| `module-system`    | 字符串          | 是      | 模块系统。支持语法：1 到 64 个 ASCII 字符，包含小写字母 (a-z) 和数字 (0-9)。更多信息请参见 [模块仓库协议](https://opentofu.org/docs/internals/module-registry-protocol/)。 |
| `module-version`   | 字符串          | 是      | 模块版本。应遵循[语义化版本规范](https://semver.org/)。 |

在请求体中提供文件内容。

请求必须以 `/file` 结尾。如果发送的请求以其他内容结尾，将导致 `404 Not Found` 错误。

{{< tabs >}}

{{< tab title="个人访问令牌" >}}

使用个人访问令牌的请求示例：

```shell
curl --fail-with-body --header "PRIVATE-TOKEN: <your_access_token>" \
     --upload-file path/to/file.tgz \
     --url "https://gitlab.example.com/api/v4/projects/<your_project_id>/packages/terraform/modules/<your_module>/<your_system>/0.0.1/file"
```

{{< /tab >}}

{{< tab title="部署令牌" >}}

使用部署令牌的请求示例：

```shell
curl --fail-with-body --header "DEPLOY-TOKEN: <deploy_token>" \
     --upload-file path/to/file.tgz \
     --url "https://gitlab.example.com/api/v4/projects/<your_project_id>/packages/terraform/modules/<your_module>/<your_system>/0.0.1/file"
```

{{< /tab >}}

{{< /tabs >}}

示例响应：

```json
{
  "message":"201 Created"
}
```

<a id="with-a-ci-cd-template-recommended"></a>

### 使用 CI/CD 模板（推荐）

{{< history >}}

- 在极狐GitLab 15.9 中引入。

{{< /history >}}

你可以使用 [`Terraform-Module.gitlab-ci.yml`](https://jihulab.com/gitlab-cn/gitlab/-/blob/master/lib/gitlab/ci/templates/Terraform-Module.gitlab-ci.yml)
或高级的 [`Terraform/Module-Base.gitlab-ci.yml`](https://jihulab.com/gitlab-cn/gitlab/-/blob/master/lib/gitlab/ci/templates/Terraform/Module-Base.gitlab-ci.yml)
CI/CD 模板将 Terraform 模块发布到极狐GitLab Terraform 模块仓库：

```yaml
include:
  template: Terraform-Module.gitlab-ci.yml
```

流水线包含以下作业：

- `fmt`：验证 Terraform 模块的格式
- `kics-iac-sast`：测试 Terraform 模块的安全问题
- `deploy`：将 Terraform 模块部署到 Terraform 模块仓库（仅对标签流水线生效）

<a id="use-pipeline-variables"></a>

#### 使用流水线变量

使用以下变量配置流水线：

| 变量                   | 默认值              | 描述                                                                                     |
|----------------------------|----------------------|-------------------------------------------------------------------------------------------------|
| `TERRAFORM_MODULE_DIR`     | `${CI_PROJECT_DIR}`  | Terraform 项目根目录的相对路径。                               |
| `TERRAFORM_MODULE_NAME`    | `${CI_PROJECT_NAME}` | 模块名称。不得包含任何空格或下划线。                  |
| `TERRAFORM_MODULE_SYSTEM`  | `local`              | 你的模块所针对的系统或提供商。例如 `local`、`aws` 或 `google`。 |
| `TERRAFORM_MODULE_VERSION` | `${CI_COMMIT_TAG}`   | 模块版本。应遵循[语义化版本规范](https://semver.org/)。          |

<a id="configure-ci-cd-manually"></a>

### 手动配置 CI/CD

要在[极狐GitLab CI/CD](../../../ci/_index.md) 中使用 Terraform 模块，请在命令中使用 `CI_JOB_TOKEN` 代替个人访问令牌。

例如，以下作业上传一个针对 `local` [系统提供商](https://registry.terraform.io/browse/providers) 的新模块，并使用 Git 提交标签作为模块版本：

```yaml
stages:
  - deploy

upload:
  stage: deploy
  image: curlimages/curl:latest
  variables:
    TERRAFORM_MODULE_DIR: ${CI_PROJECT_DIR}    # Terraform 项目根目录的相对路径。
    TERRAFORM_MODULE_NAME: ${CI_PROJECT_NAME}  # 你的 Terraform 模块名称，不得包含空格或下划线（将转换为连字符）。
    TERRAFORM_MODULE_SYSTEM: local             # 你的 Terraform 模块所针对的系统或提供商（例如 local、aws、google）。
    TERRAFORM_MODULE_VERSION: ${CI_COMMIT_TAG} # 版本 - 建议 Terraform 模块版本遵循 SemVer 规范。
  script:
    - TERRAFORM_MODULE_NAME=$(echo "${TERRAFORM_MODULE_NAME}" | tr " _" -) # 模块名称不得包含空格或下划线，因此将其转换为连字符
    - tar -vczf /tmp/${TERRAFORM_MODULE_NAME}-${TERRAFORM_MODULE_SYSTEM}-${TERRAFORM_MODULE_VERSION}.tgz -C ${TERRAFORM_MODULE_DIR} --exclude=./.git .
    - 'curl --fail-with-body --location --header "JOB-TOKEN: ${CI_JOB_TOKEN}"
         --upload-file /tmp/${TERRAFORM_MODULE_NAME}-${TERRAFORM_MODULE_SYSTEM}-${TERRAFORM_MODULE_VERSION}.tgz
         ${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/terraform/modules/${TERRAFORM_MODULE_NAME}/${TERRAFORM_MODULE_SYSTEM}/${TERRAFORM_MODULE_VERSION}/file'
  rules:
    - if: $CI_COMMIT_TAG
```

要触发此上传作业，请向你的提交添加 Git 标签。确保标签遵循 Terraform 所需的[语义化版本规范](https://semver.org/)。`rules:if: $CI_COMMIT_TAG` 确保只有仓库中打了标签的提交才会触发模块上传作业。
关于控制作业的其他方式，请参见 [CI/CD YAML 语法参考](../../../ci/yaml/_index.md)。

<a id="module-resolution-workflow"></a>

### 模块解析工作流

当你上传一个新模块时，极狐GitLab 会为该模块生成一个路径。例如：

- `https://gitlab.example.com/parent-group/my-infra-package`

该路径符合 [Terraform 模块仓库协议](https://opentofu.org/docs/internals/module-registry-protocol/)，其中：

- `gitlab.example.com` 是主机名。
- `parent-group` 是 Terraform 模块仓库唯一顶级命名空间。
- `my-infra-package` 是模块名称。

如果[不允许重复](#allow-duplicate-terraform-modules)，则模块名称和版本必须在 `parent-group` 下的所有群组、子群组和项目中唯一。否则会收到以下错误：

- `{"message":"A module with the same name already exists in the namespace."}`

如果[允许重复](#allow-duplicate-terraform-modules)，模块解析基于最近发布的模块。

例如，如果：

- 项目是 `gitlab.example.com/parent-group/subgroup/my-project`。
- Terraform 模块是 `my-infra-package`。

如果允许重复，`my-infra-package` 是有效模块。
如果不允许重复，模块名称必须在 `parent-group` 下所有群组的所有项目中唯一。

命名模块时请注意以下命名约定：

- 你的项目和群组名称不得包含句点 (`.`)。
  例如，`source = "gitlab.example.com/my.group/project.name"` 是无效的。
- 模块版本应遵循[语义化版本规范](https://semver.org/)。

<a id="allow-duplicate-terraform-modules"></a>

### 允许重复的 Terraform 模块

{{< history >}}

- 在极狐GitLab 16.8 中引入。
- 在极狐GitLab 17.0 中，必需角色从维护者变更为所有者。

{{< /history >}}

默认情况下，Terraform 模块仓库强制在同一命名空间中模块名称唯一。

要允许发布重复的模块名称：

1. 在顶部栏，选择 **搜索或跳转到** 并找到你的群组。
1. 在左侧边栏，选择 **设置** > **软件包与镜像仓库**。
1. 在 **重复软件包** 表格的 **Terraform 模块** 行，关闭 **允许重复** 开关。
1. 可选。在 **例外** 文本框中，输入匹配要允许重复的模块名称的正则表达式。

你的更改会自动保存。

> [!note]
> 如果 **允许重复** 已开启，你可以在 **例外** 文本框中指定不应有重复的模块名称。

你还可以通过在 [GraphQL API](../../../api/graphql/reference/_index.md#packagesettings) 中启用 `terraform_module_duplicates_allowed` 来允许发布重复名称。

要允许特定名称的重复：

1. 确保 `terraform_module_duplicates_allowed` 已禁用。
1. 使用 `terraform_module_duplicate_exception_regex` 为正则表达式模式定义你希望允许重复的模块名称。

顶级命名空间设置优先于子命名空间设置。
例如，如果为一个群组启用 `terraform_module_duplicates_allowed`，而为子群组禁用它，
则该群组及其子群组中的所有项目都允许重复。

更多关于模块解析的信息，请参见[模块解析工作流](#module-resolution-workflow)

<a id="view-terraform-modules"></a>

## 查看 Terraform 模块

{{< history >}}

- 在极狐GitLab 17.2 中引入了对 `README` 文件的支持。

{{< /history >}}

要在项目或群组中查看 Terraform 模块：

1. 在顶部栏，选择 **搜索或跳转到** 并找到你的项目或群组。
1. 在左侧边栏，选择 **运维** > **Terraform 模块**。

你可以在此页面搜索、排序和过滤模块。

要查看模块的 `README` 文件：

1. 从 **Terraform 模块仓库** 页面，选择一个 Terraform 模块。
1. 选择 **`README`**。

<a id="reference-a-terraform-module"></a>

## 引用 Terraform 模块

从群组或项目引用模块。

<a id="from-a-namespace"></a>

### 从命名空间

你可以为 `terraform` 提供认证令牌（作业令牌、个人访问令牌或部署令牌）作为环境变量。

你应为域名添加前缀 `TF_TOKEN_`，并将点号编码为下划线。
更多信息请参见 [环境变量凭据](https://opentofu.org/docs/cli/config/config-file/#environment-variable-credentials)。

例如，名为 `TF_TOKEN_jihulab_com` 的环境变量的值在 CLI 向主机名 `jihulab.com` 发出服务请求时用作部署令牌：

```shell
export TF_TOKEN_jihulab_com='glpat-<deploy_token>'
```

这种方法适用于企业实施。对于本地或临时环境，
你可能想创建一个 `~/.terraformrc` 或 `%APPDATA%/terraform.rc` 文件：

```terraform
credentials "<jihulab.com>" {
  token = "<TOKEN>"
}
```

其中 `jihulab.com` 可替换为你的
私有化部署实例的主机名。

然后你就可以从下游 Terraform 项目引用你的 Terraform 模块：

```terraform
module "<module>" {
  source = "jihulab.com/<namespace>/<module-name>/<module-system>"
}
```

<a id="from-a-project"></a>

### 从项目

要使用项目源引用 Terraform 模块，
请使用 Terraform 提供的[通过 HTTP 获取归档文件](https://developer.hashicorp.com/terraform/language/modules/sources#fetching-archives-over-http)源类型。

你可以在 `~/.netrc` 文件中为 `terraform` 提供认证令牌（作业令牌、个人访问令牌或部署令牌）：

```plaintext
machine <jihulab.com>
login <USERNAME>
password <TOKEN>
```

其中 `jihulab.com` 可替换为你的私有化部署实例的主机名，
`<USERNAME>` 是你的令牌用户名。

你可以从下游 Terraform 项目引用你的 Terraform 模块：

```terraform
module "<module>" {
  source = "https://jihulab.com/api/v4/projects/<project-id>/packages/terraform/modules/<module-name>/<module-system>/<module-version>"
}
```

如果你需要引用模块的最新版本，可以从源 URL 中省略 `<module-version>`。为防止未来问题，请尽可能引用特定版本。

如果在同一命名空间存在[重复的模块名称](#allow-duplicate-terraform-modules)，从命名空间级别引用模块将安装最近发布的模块。要引用重复模块的特定版本，请使用[项目级别](#from-a-project)源类型。

<a id="download-a-terraform-module"></a>

## 下载 Terraform 模块

要下载 Terraform 模块：

1. 在左侧边栏，选择 **运维** > **Terraform 模块**。
1. 选择你要下载的模块名称。
1. 从 **资产** 表格中选择你要下载的模块。

<a id="delete-a-terraform-module"></a>

## 删除 Terraform 模块

将 Terraform 模块发布到 Terraform 模块仓库后，你无法编辑它。相反，你
必须删除并重新创建它。

你可以使用[软件包 API](../../../api/packages.md#delete-a-project-package) 或 UI 删除模块。

要通过 UI 删除项目中的模块：

1. 在左侧边栏，选择 **运维** > **Terraform 模块**。
1. 找到要删除的软件包名称。
1. 选择 **删除**。

软件包将被永久删除。

<a id="disable-the-terraform-module-registry"></a>

## 禁用 Terraform 模块仓库

Terraform 模块仓库自动启用。

对于私有化部署实例，极狐GitLab 管理员可以
[禁用](../../../administration/packages/_index.md#enable-or-disable-the-package-registry) **软件包与镜像仓库**，
这将从侧边栏移除此菜单项。

你也可以为特定项目移除 Terraform 模块仓库：

1. 在你的项目中，转到 **设置** > **通用**。
1. 展开 **可见性、项目功能、权限** 部分，关闭 **软件包** 开关。
1. 选择 **保存更改**。

<a id="example-projects"></a>

## 示例项目

有关 Terraform 模块仓库的示例，请查看以下项目：

- [_GitLab local file_ 项目](https://gitlab.com/mattkasa/gitlab-local-file) 创建一个最小 Terraform 模块并使用极狐GitLab CI/CD 将其上传到 Terraform 模块仓库。
- [_Terraform module test_ 项目](https://gitlab.com/mattkasa/terraform-module-test) 使用上一个示例的模块。