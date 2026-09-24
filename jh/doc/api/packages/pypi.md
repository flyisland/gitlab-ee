---
stage: Package
group: Package Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: PyPI API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用此 API 与 [PyPI 软件包管理器客户端](../../user/packages/pypi_repository/_index.md) 进行交互。

> [!warning]
> 此 API 由 [PyPI 软件包管理器客户端](https://pypi.org/) 使用，通常不用于手动调用。

这些端点不遵循标准 API 认证方法。有关支持的标头和令牌类型的详细信息，请参阅 [PyPI 软件包仓库文档](../../user/packages/pypi_repository/_index.md)。未记录的认证方法未来可能会被移除。

> [!note]
> 在启用 FIPS 模式时，建议使用 [Twine 3.4.2](https://twine.readthedocs.io/en/stable/changelog.html?highlight=FIPS#id28) 或更高版本。

<a id="download-a-package-file-for-a-group"></a>

## 下载群组的软件包文件

下载指定群组的 PyPI 软件包文件。[简单 API](#retrieve-package-descriptor-for-a-group) 通常会提供此 URL。

```plaintext
GET groups/:id/-/packages/pypi/files/:sha256/:file_identifier
```

| 属性 | 类型 | 是否必需 | 描述 |
| ----------------- | ------ | -------- | ----------- |
| `id`              | string | 是      | 群组的 ID 或完整路径。 |
| `sha256`          | string | 是      | PyPI 软件包文件的 sha256 校验和。 |
| `file_identifier` | string | 是      | PyPI 软件包文件名。 |

```shell
curl --user <username>:<personal_access_token> \
  --url "https://gitlab.example.com/api/v4/groups/1/-/packages/pypi/files/5y57017232013c8ac80647f4ca153k3726f6cba62d055cd747844ed95b3c65ff/my.pypi.package-0.0.1.tar.gz"
```

要将输出写入文件：

```shell
curl --user <username>:<personal_access_token> \
  --url "https://gitlab.example.com/api/v4/groups/1/-/packages/pypi/files/5y57017232013c8ac80647f4ca153k3726f6cba62d055cd747844ed95b3c65ff/my.pypi.package-0.0.1.tar.gz" >> my.pypi.package-0.0.1.tar.gz
```

这会将下载的文件写入当前目录的 `my.pypi.package-0.0.1.tar.gz`。

<a id="list-all-packages-for-a-group"></a>

## 列出群组的所有软件包

以 HTML 文件形式列出指定群组的所有软件包。

```plaintext
GET groups/:id/-/packages/pypi/simple
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | string | 是 | 群组的 ID 或完整路径。 |

```shell
curl --user <username>:<personal_access_token> \
  --url "https://gitlab.example.com/api/v4/groups/1/-/packages/pypi/simple"
```

响应示例：

```html
<!DOCTYPE html>
<html>
  <head>
    <title>群组链接</title>
  </head>
  <body>
    <h1>群组链接</h1>
    <a href="https://gitlab.example.com/api/v4/groups/1/-/packages/pypi/simple/my-pypi-package" data-requires-python="">my.pypi.package</a><br><a href="https://gitlab.example.com/api/v4/groups/1/-/packages/pypi/simple/package-2" data-requires-python="3.8">package_2</a><br>
  </body>
</html>
```

要将输出写入文件：

```shell
curl --user <username>:<personal_access_token> \
  --url "https://gitlab.example.com/api/v4/groups/1/-/packages/pypi/simple" >> simple_index.html
```

这会将下载的文件写入当前目录的 `simple_index.html`。

<a id="retrieve-package-descriptor-for-a-group"></a>

## 检索群组的软件包描述符

以 HTML 文件形式检索群组中指定软件包的描述符。

```plaintext
GET groups/:id/-/packages/pypi/simple/:package_name
```

| 属性 | 类型 | 是否必需 | 描述 |
| -------------- | ------ | -------- | ----------- |
| `id`           | string | 是      | 群组的 ID 或完整路径。 |
| `package_name` | string | 是      | 软件包名称。 |

```shell
curl --user <username>:<personal_access_token> \
  --url "https://gitlab.example.com/api/v4/groups/1/-/packages/pypi/simple/my.pypi.package"
```

响应示例：

```html
<!DOCTYPE html>
<html>
  <head>
    <title>my.pypi.package 链接</title>
  </head>
  <body>
    <h1>my.pypi.package 链接</h1>
    <a href="https://gitlab.example.com/api/v4/groups/1/-/packages/pypi/files/5y57017232013c8ac80647f4ca153k3726f6cba62d055cd747844ed95b3c65ff/my.pypi.package-0.0.1-py3-none-any.whl#sha256=5y57017232013c8ac80647f4ca153k3726f6cba62d055cd747844ed95b3c65ff" data-requires-python="&gt;=3.6">my.pypi.package-0.0.1-py3-none-any.whl</a><br><a href="https://gitlab.example.com/api/v4/groups/1/-/packages/pypi/files/9s9w01b0bcd52b709ec052084e33a5517ffca96f7728ddd9f8866a30cdf76f2/my.pypi.package-0.0.1.tar.gz#sha256=9s9w011b0bcd52b709ec052084e33a5517ffca96f7728ddd9f8866a30cdf76f2" data-requires-python="&gt;=3.6">my.pypi.package-0.0.1.tar.gz</a><br>
  </body>
</html>
```

要将输出写入文件：

```shell
curl --user <username>:<personal_access_token> \
  --url "https://gitlab.example.com/api/v4/groups/1/-/packages/pypi/simple/my.pypi.package" >> simple.html
```

这会将下载的文件写入当前目录的 `simple.html`。

<a id="download-a-package-file-for-a-project"></a>

## 下载项目的软件包文件

下载指定项目的 PyPI 软件包文件。[简单 API](#retrieve-package-descriptor-for-a-project) 通常会提供此 URL。

```plaintext
GET projects/:id/packages/pypi/files/:sha256/:file_identifier
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id`              | string | 是 | 项目的 ID 或完整路径。 |
| `sha256`          | string | 是 | PyPI 软件包文件的 sha256 校验和。 |
| `file_identifier` | string | 是 | PyPI 软件包文件名。 |

```shell
curl --user <username>:<personal_access_token> \
  --url "https://gitlab.example.com/api/v4/projects/1/packages/pypi/files/5y57017232013c8ac80647f4ca153k3726f6cba62d055cd747844ed95b3c65ff/my.pypi.package-0.0.1.tar.gz"
```

要将输出写入文件：

```shell
curl --user <username>:<personal_access_token> \
  --url "https://gitlab.example.com/api/v4/projects/1/packages/pypi/files/5y57017232013c8ac80647f4ca153k3726f6cba62d055cd747844ed95b3c65ff/my.pypi.package-0.0.1.tar.gz" >> my.pypi.package-0.0.1.tar.gz
```

这会将下载的文件写入当前目录的 `my.pypi.package-0.0.1.tar.gz`。

<a id="list-all-packages-for-a-project"></a>

## 列出项目的所有软件包

以 HTML 文件形式列出指定项目的所有软件包。

```plaintext
GET projects/:id/packages/pypi/simple
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id` | string | 是 | 项目的 ID 或完整路径。 |

```shell
curl --user <username>:<personal_access_token> \
  --url "https://gitlab.example.com/api/v4/projects/1/packages/pypi/simple"
```

响应示例：

```html
<!DOCTYPE html>
<html>
  <head>
    <title>项目链接</title>
  </head>
  <body>
    <h1>项目链接</h1>
    <a href="https://gitlab.example.com/api/v4/projects/1/packages/pypi/simple/my-pypi-package" data-requires-python="">my.pypi.package</a><br><a href="https://gitlab.example.com/api/v4/projects/1/packages/pypi/simple/package-2" data-requires-python="3.8">package_2</a><br>
  </body>
</html>
```

要将输出写入文件：

```shell
curl --user <username>:<personal_access_token> \
  --url "https://gitlab.example.com/api/v4/projects/1/packages/pypi/simple" >> simple_index.html
```

这会将下载的文件写入当前目录的 `simple_index.html`。

<a id="retrieve-package-descriptor-for-a-project"></a>

## 检索项目的软件包描述符

以 HTML 文件形式检索项目中指定软件包的描述符。

```plaintext
GET projects/:id/packages/pypi/simple/:package_name
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id`           | string | 是 | 项目的 ID 或完整路径。 |
| `package_name` | string | 是 | 软件包名称。 |

```shell
curl --user <username>:<personal_access_token> \
  --url "https://gitlab.example.com/api/v4/projects/1/packages/pypi/simple/my.pypi.package"
```

响应示例：

```html
<!DOCTYPE html>
<html>
  <head>
    <title>my.pypi.package 链接</title>
  </head>
  <body>
    <h1>my.pypi.package 链接</h1>
    <a href="https://gitlab.example.com/api/v4/projects/1/packages/pypi/files/5y57017232013c8ac80647f4ca153k3726f6cba62d055cd747844ed95b3c65ff/my.pypi.package-0.0.1-py3-none-any.whl#sha256=5y57017232013c8ac80647f4ca153k3726f6cba62d055cd747844ed95b3c65ff" data-requires-python="&gt;=3.6">my.pypi.package-0.0.1-py3-none-any.whl</a><br><a href="https://gitlab.example.com/api/v4/projects/1/packages/pypi/files/9s9w01b0bcd52b709ec052084e33a5517ffca96f7728ddd9f8866a30cdf76f2/my.pypi.package-0.0.1.tar.gz#sha256=9s9w011b0bcd52b709ec052084e33a5517ffca96f7728ddd9f8866a30cdf76f2" data-requires-python="&gt;=3.6">my.pypi.package-0.0.1.tar.gz</a><br>
  </body>
</html>
```

要将输出写入文件：

```shell
curl --user <username>:<personal_access_token> \
  --url "https://gitlab.example.com/api/v4/projects/1/packages/pypi/simple/my.pypi.package" >> simple.html
```

这会将下载的文件写入当前目录的 `simple.html`。

<a id="upload-a-package"></a>

## 上传软件包

为指定项目上传一个 PyPI 软件包。

```plaintext
POST projects/:id/packages/pypi
```

| 属性 | 类型 | 是否必需 | 描述 |
| --------- | ---- | -------- | ----------- |
| `id`      | string | 是 | 项目的 ID 或完整路径。 |
| `requires_python` | string | 否 | PyPI 所需的版本。 |
| `sha256_digest` | string | 否 | 软件包文件的 SHA256 校验和。上传不是必需的，但如果没有此属性，`pip install` 会失败，因为软件包索引 URL 缺少必需的校验和。 |

```shell
curl --request POST \
     --form 'content=@path/to/my.pypi.package-0.0.1.tar.gz' \
     --form "sha256_digest=$(shasum -a 256 < path/to/my.pypi.package-0.0.1.tar.gz | cut -d' ' -f1)" \
     --form 'name=my.pypi.package' \
     --form 'version=1.3.7' \
     --user <username>:<personal_access_token> \
     --url "https://gitlab.example.com/api/v4/projects/1/packages/pypi"
```

