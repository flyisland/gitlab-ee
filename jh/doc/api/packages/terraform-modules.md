---
stage: Package
group: Package Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Terraform 模块仓库 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 与 [Terraform CLI](../../user/packages/terraform_module_registry/_index.md) 交互。

> [!warning]
> 此 API 供 [Terraform CLI](https://www.terraform.io/) 使用，通常不建议手动调用。未记录的认证方法可能会在未来被移除。

<a id="list-available-versions-for-a-specific-module"></a>

## 列出特定模块的可用版本

列出指定模块的所有可用版本。

```plaintext
GET packages/terraform/modules/v1/:module_namespace/:module_name/:module_system/versions
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `module_namespace` | string | 是 | Terraform 模块项目或子群组所属的顶级群组（命名空间）。 |
| `module_name` | string | 是 | 模块名称。 |
| `module_system` | string | 是 | 模块系统或 [provider](https://www.terraform.io/registry/providers) 的名称。 |

```shell
curl --header "Authorization: Bearer <personal_access_token>" \
  --url "https://gitlab.example.com/api/v4/packages/terraform/modules/v1/group/hello-world/local/versions"
```

示例响应：

```json
{
  "modules": [
    {
      "versions": [
        {
          "version": "1.0.0",
          "submodules": [],
          "root": {
            "dependencies": [],
            "providers": [
              {
                "name": "local",
                "version":""
              }
            ]
          }
        },
        {
          "version": "0.9.3",
          "submodules": [],
          "root": {
            "dependencies": [],
            "providers": [
              {
                "name": "local",
                "version":""
              }
            ]
          }
        }
      ],
      "source": "https://gitlab.example.com/group/hello-world"
    }
  ]
}
```

<a id="retrieve-latest-version-for-a-module"></a>

## 获取模块的最新版本

获取指定模块最新版本的信息。

```plaintext
GET packages/terraform/modules/v1/:module_namespace/:module_name/:module_system
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `module_namespace` | string | 是 | Terraform 模块项目所属的群组。 |
| `module_name` | string | 是 | 模块名称。 |
| `module_system` | string | 是 | 模块系统或 [provider](https://www.terraform.io/registry/providers) 的名称。 |

```shell
curl --header "Authorization: Bearer <personal_access_token>" \
  --url "https://gitlab.example.com/api/v4/packages/terraform/modules/v1/group/hello-world/local"
```

示例响应：

```json
{
  "name": "hello-world/local",
  "provider": "local",
  "providers": [
    "local"
  ],
  "root": {
    "dependencies": []
  },
  "source": "https://gitlab.example.com/group/hello-world",
  "submodules": [],
  "version": "1.0.0",
  "versions": [
    "1.0.0"
  ]
}
```

<a id="retrieve-a-specific-version-for-a-module"></a>

## 获取模块的特定版本

获取指定模块特定版本的信息。

```plaintext
GET packages/terraform/modules/v1/:module_namespace/:module_name/:module_system/1.0.0
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `module_namespace` | string | 是 | Terraform 模块项目所属的群组。 |
| `module_name` | string | 是 | 模块名称。 |
| `module_system` | string | 是 | 模块系统或 [provider](https://www.terraform.io/registry/providers) 的名称。 |

```shell
curl --header "Authorization: Bearer <personal_access_token>" \
  --url "https://gitlab.example.com/api/v4/packages/terraform/modules/v1/group/hello-world/local/1.0.0"
```

示例响应：

```json
{
  "name": "hello-world/local",
  "provider": "local",
  "providers": [
    "local"
  ],
  "root": {
    "dependencies": []
  },
  "source": "https://gitlab.example.com/group/hello-world",
  "submodules": [],
  "version": "1.0.0",
  "versions": [
    "1.0.0"
  ]
}
```

<a id="retrieve-download-url-for-latest-module-version"></a>

## 获取最新模块版本的下载 URL

在 `X-Terraform-Get` 头中获取最新模块版本的下载 URL。

```plaintext
GET packages/terraform/modules/v1/:module_namespace/:module_name/:module_system/download
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `module_namespace` | string | 是 | Terraform 模块项目所属的群组。 |
| `module_name` | string | 是 | 模块名称。 |
| `module_system` | string | 是 | 模块系统或 [provider](https://www.terraform.io/registry/providers) 的名称。 |

```shell
curl --header "Authorization: Bearer <personal_access_token>" \
  --url "https://gitlab.example.com/api/v4/packages/terraform/modules/v1/group/hello-world/local/download"
```

示例响应：

```plaintext
HTTP/1.1 204 No Content
Content-Length: 0
X-Terraform-Get: /api/v4/packages/terraform/modules/v1/group/hello-world/local/1.0.0/file?token=&archive=tgz
```

在底层，此 API 端点重定向到 `packages/terraform/modules/v1/:module_namespace/:module_name/:module_system/:module_version/download`

<a id="retrieve-download-url-for-a-specific-module-version"></a>

## 获取特定模块版本的下载 URL

在 `X-Terraform-Get` 头中获取指定模块版本的下载 URL。

```plaintext
GET packages/terraform/modules/v1/:module_namespace/:module_name/:module_system/:module_version/download
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `module_namespace` | string | 是 | Terraform 模块项目所属的群组。 |
| `module_name` | string | 是 | 模块名称。 |
| `module_system` | string | 是 | 模块系统或 [provider](https://www.terraform.io/registry/providers) 的名称。 |
| `module_version` | string | 是 | 要下载的特定模块版本。 |

```shell
curl --header "Authorization: Bearer <personal_access_token>" \
  --url "https://gitlab.example.com/api/v4/packages/terraform/modules/v1/group/hello-world/local/1.0.0/download"
```

示例响应：

```plaintext
HTTP/1.1 204 No Content
Content-Length: 0
X-Terraform-Get: /api/v4/packages/terraform/modules/v1/group/hello-world/local/1.0.0/file?token=&archive=tgz
```

<a id="download-module"></a>

## 下载模块

<a id="from-a-namespace"></a>

### 从命名空间下载

```plaintext
GET packages/terraform/modules/v1/:module_namespace/:module_name/:module_system/:module_version/file
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `module_namespace` | string | 是 | Terraform 模块项目所属的群组。 |
| `module_name` | string | 是 | 模块名称。 |
| `module_system` | string | 是 | 模块系统或 [provider](https://www.terraform.io/registry/providers) 的名称。 |
| `module_version` | string | 是 | 要下载的特定模块版本。 |

```shell
curl --header "Authorization: Bearer <personal_access_token>" \
  --url "https://gitlab.example.com/api/v4/packages/terraform/modules/v1/group/hello-world/local/1.0.0/file"
```

将输出写入文件：

```shell
curl --header "Authorization: Bearer <personal_access_token>" \
  --url "https://gitlab.example.com/api/v4/packages/terraform/modules/v1/group/hello-world/local/1.0.0/file" \
  --output hello-world-local.tgz
```

<a id="from-a-project"></a>

### 从项目下载

```plaintext
GET /projects/:id/packages/terraform/modules/:module_name/:module_system/:module_version
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | integer 或 string | 是 | 项目的 ID 或 URL 编码路径。 |
| `module_name` | string | 是 | 模块名称。 |
| `module_system` | string | 是 | 模块系统或 [provider](https://www.terraform.io/registry/providers) 的名称。 |
| `module_version` | string | 否 | 要下载的特定模块版本。如果省略，则下载最新版本。 |

```shell
curl --user "<username>:<personal_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/packages/terraform/modules/hello-world/local/1.0.0"
```

将输出写入文件：

```shell
curl --user "<username>:<personal_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/packages/terraform/modules/hello-world/local/1.0.0" \
  --output hello-world-local.tgz
```

<a id="upload-module"></a>

## 上传模块

为指定项目上传模块。

```plaintext
PUT /projects/:id/packages/terraform/modules/:module-name/:module-system/:module-version/file
```

| 属性        | 类型              | 是否必需 | 描述 |
|------------------|-------------------|----------|-------------|
| `id`             | integer 或 string | 是      | 项目的 ID 或 URL 编码路径。 |
| `module-name`    | string            | 是      | 模块名称。 |
| `module-system`  | string            | 是      | 模块系统或 [provider](https://www.terraform.io/registry/providers) 的名称。 |
| `module-version` | string            | 是      | 要上传的特定模块版本。 |

```shell
curl --fail-with-body \
   --header "PRIVATE-TOKEN: <your_access_token>" \
   --upload-file path/to/file.tgz \
   --url  "https://gitlab.example.com/api/v4/projects/<your_project_id>/packages/terraform/modules/my-module/my-system/0.0.1/file"
```

可用于认证的令牌：

| 头          | 值 |
|-----------------|-------|
| `PRIVATE-TOKEN` | 具有 `api` 范围的[个人访问令牌](../../user/profile/personal_access_tokens.md)。 |
| `DEPLOY-TOKEN`  | 具有 `write_package_registry` 范围的[部署令牌](../../user/project/deploy_tokens/_index.md)。 |
| `JOB-TOKEN`     | [作业令牌](../../ci/jobs/ci_job_token.md)。 |

示例响应：

```json
{
  "message": "201 Created"
}
```