---
stage: Package
group: Package Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Ruby gems API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

使用此 API 与 [Ruby gems 和 Bundler 软件包管理器客户端](../../user/packages/rubygems_registry/_index.md) 交互。

> [!warning]
> 此 API 供 [Ruby gems 和 Bundler 软件包管理器客户端](https://maven.apache.org/) 使用，
> 通常不用于手动调用。此 API 仍在开发中，功能有限，尚未准备好用于生产环境。

这些端点不遵循标准的 API 身份验证方法。
有关支持哪些标头和令牌类型的详细信息，请参阅 [Ruby gems registry 文档](../../user/packages/rubygems_registry/_index.md)。
未来可能会移除未记录的身份验证方法。

<a id="enable-the-ruby-gems-api"></a>

## 启用 Ruby gems API

极狐GitLab 的 Ruby gems API 受默认禁用的功能标志控制。可以通过极狐GitLab Rails 控制台为您的实例启用此 API。

启用方法：

```ruby
Feature.enable(:rubygem_packages)
```

禁用方法：

```ruby
Feature.disable(:rubygem_packages)
```

针对特定项目启用或禁用：

```ruby
Feature.enable(:rubygem_packages, Project.find(1))
Feature.disable(:rubygem_packages, Project.find(2))
```

<a id="download-a-gem-file"></a>

## 下载 gem 文件

下载项目的指定 gem 文件。

```plaintext
GET projects/:id/packages/rubygems/gems/:file_name
```

| 属性        | 类型   | 是否必需 | 描述 |
| ------------ | ------ | -------- | ----------- |
| `id`         | string | 是       | 项目的 ID 或完整路径。 |
| `file_name`  | string | 是       | `.gem` 文件的名称。 |

```shell
curl --header "Authorization:<personal_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/packages/rubygems/gems/my_gem-1.0.0.gem"
```

将输出写入文件：

```shell
curl --header "Authorization:<personal_access_token>" "https://gitlab.example.com/api/v4/projects/1/packages/rubygems/gems/my_gem-1.0.0.gem" >> my_gem-1.0.0.gem
```

这会将下载的文件写入当前目录的 `my_gem-1.0.0.gem`。

<a id="download-a-gemspec-file"></a>

## 下载 gemspec 文件

以 Marshal 格式下载指定 gem 版本的 gemspec 文件。

```plaintext
GET projects/:id/packages/rubygems/quick/Marshal.4.8/:file_name
```

| 属性        | 类型   | 是否必需 | 描述 |
| ------------ | ------ | -------- | ----------- |
| `id`         | string | 是       | 项目的 ID 或完整路径。 |
| `file_name`  | string | 是       | gemspec 文件名，格式为 `<gem_name>-<version>.gemspec.rz`。 |

响应是一个经过 deflate 压缩的、已编组的 `Gem::Specification` 对象。

```shell
curl --header "Authorization:<personal_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/packages/rubygems/quick/Marshal.4.8/my_gem-1.0.0.gemspec.rz"
```

<a id="retrieve-dependencies"></a>

## 获取依赖项

获取指定 gem 的依赖项列表。

响应是所请求 gem 所有版本的已编组哈希数组。由于响应是编组的，您可以将其存储在文件中。

```plaintext
GET projects/:id/packages/rubygems/api/v1/dependencies
```

| 属性 | 类型   | 是否必需 | 描述 |
| --------- | ------ | -------- | ----------- |
| `id`      | string | 是       | 项目的 ID 或完整路径。 |
| `gems`    | string | 否       | 以逗号分隔的 gem 列表，用于获取依赖项。 |

```shell
curl --header "Authorization:<personal_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/1/packages/rubygems/api/v1/dependencies?gems=my_gem,foo"
```

如果已安装 Ruby，您可以使用以下
Ruby 命令读取响应。要使此命令生效，您必须
[在 `~/.gem/credentials` 中设置凭据](../../user/packages/rubygems_registry/_index.md#authenticate-to-the-package-registry)，
或在请求中传递您的访问令牌：

```shell
$ ruby -ropen-uri -rpp -e \
  'pp Marshal.load(URI.open("https://gitlab.example.com/api/v4/projects/1/packages/rubygems/api/v1/dependencies?gems=my_gem,rails,foo", "Authorization" => <personal_access_token>))'

[{:name=>"my_gem", :number=>"0.0.1", :platform=>"ruby", :dependencies=>[]},
 {:name=>"my_gem",
  :number=>"0.0.3",
  :platform=>"ruby",
  :dependencies=>
   [["dependency_1", "~> 1.2.3"],
    ["dependency_2", "= 3.0.0"],
    ["dependency_3", ">= 1.0.0"],
    ["dependency_4", ">= 0"]]},
 {:name=>"my_gem",
  :number=>"0.0.2",
  :platform=>"ruby",
  :dependencies=>
   [["dependency_1", "~> 1.2.3"],
    ["dependency_2", "= 3.0.0"],
    ["dependency_3", ">= 1.0.0"],
    ["dependency_4", ">= 0"]]},
 {:name=>"foo",
  :number=>"0.0.2",
  :platform=>"ruby",
  :dependencies=>
    ["dependency_2", "= 3.0.0"],
    ["dependency_4", ">= 0"]]}]
```

<a id="upload-a-gem"></a>

## 上传 gem

为指定项目上传 gem。

```plaintext
POST projects/:id/packages/rubygems/api/v1/gems
```

| 属性 | 类型   | 是否必需 | 描述 |
| --------- | ------ | -------- | ----------- |
| `id`      | string | 是       | 项目的 ID 或完整路径。 |

```shell
curl --request POST \
     --upload-file path/to/my_gem_file.gem \
     --header "Authorization:<personal_access_token>" \
     --url "https://gitlab.example.com/api/v4/projects/1/packages/rubygems/api/v1/gems"
```