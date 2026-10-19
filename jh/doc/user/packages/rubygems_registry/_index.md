---
stage: Package
group: Package Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 软件包仓库中的 Ruby gem
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Status: 实验

{{< /details >}}

> [!flag]
> 此功能的可用性由功能标志控制。
> 此功能可用于测试，但尚未准备好用于生产环境。

您可以将 Ruby gem 发布到项目的软件包仓库。之后，您可以从 UI 或通过 API 下载它们。

此功能是一项[实验](../../../policy/development_stages_support.md)。有关此功能开发的更多信息，请参见[史诗 3200](https://gitlab.com/groups/gitlab-org/-/work_items/3200)。

<a id="authenticate-to-the-package-registry"></a>

## 向软件包仓库进行身份验证

在与软件包仓库交互之前，您必须先进行身份验证。

为此，您可以使用：

- 一个[个人访问令牌](../../profile/personal_access_tokens.md)，
  其作用域设置为 `api`。
- 一个[部署令牌](../../project/deploy_tokens/_index.md)，其作用域设置为
  `read_package_registry`、`write_package_registry`，或两者。
- 一个 [CI/CD 作业令牌](../../../ci/jobs/ci_job_token.md)。

例如：

{{< tabs >}}

{{< tab title="使用访问令牌" >}}

要使用访问令牌进行身份验证：

- 创建或编辑您的 `~/.gem/credentials` 文件，并添加：

  ```ini
  ---
  https://gitlab.example.com/api/v4/projects/<project_id>/packages/rubygems: '<token>'
  ```

在此示例中：

- `<token>` 必须是您的个人访问令牌或部署令牌的令牌值。
- `<project_id>` 显示在[项目概览页面](../../project/working_with_projects.md#find-the-project-id)上。

{{< /tab >}}

{{< tab title="使用 CI/CD 作业令牌" >}}

要使用 CI/CD 作业令牌进行身份验证：

- 创建或编辑您的 `.gitlab-ci.yml` 文件，并添加：

  ```yaml
  # assuming a my_gem.gemspec file is present in the repository with the version currently set to 0.0.1
  image: ruby

  run:
    before_script:
      - mkdir ~/.gem
      - echo "---" > ~/.gem/credentials
      - |
        echo "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/rubygems: '${CI_JOB_TOKEN}'" >> ~/.gem/credentials
      - chmod 0600 ~/.gem/credentials # rubygems requires 0600 permissions on the credentials file
    script:
      - gem build my_gem
      - gem push my_gem-0.0.1.gem --host ${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/rubygems
  ```

  您还可以在检入到极狐GitLab 的 `~/.gem/credentials` 文件中使用 `CI_JOB_TOKEN`：

  ```ini
  ---
  https://gitlab.example.com/api/v4/projects/${env.CI_PROJECT_ID}/packages/rubygems: '${env.CI_JOB_TOKEN}'
  ```

{{< /tab >}}

{{< /tabs >}}

<a id="push-a-ruby-gem"></a>

## 推送 Ruby gem

先决条件：

- 您必须[向软件包仓库进行身份验证](#authenticate-to-the-package-registry)。
- 您的 Ruby gem 必须不超过 3 GB。

为此：

- 运行如下命令：

  ```shell
  gem push my_gem-0.0.1.gem --host <host>
  ```

  在此示例中，`<host>` 是您在设置身份验证时使用的 URL。例如：

  ```shell
  gem push my_gem-0.0.1.gem --host https://gitlab.example.com/api/v4/projects/1/packages/rubygems
  ```

当 gem 成功发布后，会显示如下消息：

```plaintext
Pushing gem to https://gitlab.example.com/api/v4/projects/1/packages/rubygems...
{"message":"201 Created"}
```

该 gem 会发布到您的软件包仓库，并显示在**软件包和镜像仓库**页面上。极狐GitLab 处理和显示您的 gem 最多可能需要 10 分钟。

<a id="pushing-gems-with-the-same-name-or-version"></a>

### 推送同名或同版本的 gem

如果已存在同名同版本的软件包，您仍然可以推送 gem。两者都会在 UI 中可见且可访问。

<a id="delete-a-ruby-gem"></a>

## 删除 Ruby gem

先决条件：

- 您必须具有维护者或所有者角色。

在删除软件包之前，请确保您了解[相关的安全风险](../package_registry/supported_functionality.md#deleting-packages)。

要删除软件包，您可以：

- [使用 UI](../package_registry/reduce_package_registry_storage.md#delete-a-package)。
- [使用 API](../../../api/packages.md#delete-a-project-package)。

<a id="install-a-ruby-gem"></a>

## 安装 Ruby gem

先决条件：

- 您必须[向软件包仓库进行身份验证](#authenticate-to-the-package-registry)。

要安装 gem，请在源 URL 中通过 HTTP 基本身份验证传递您的凭据。使用 `__token__` 作为用户名，并将您的个人访问令牌、部署令牌或 CI/CD 作业令牌作为密码。

在以下示例中：

- `<token>` 是您的个人访问令牌、部署令牌或 CI/CD 作业令牌。
- `<project_id>` 显示在[项目概览页面](../../project/working_with_projects.md#find-the-project-id)上。

{{< tabs >}}

{{< tab title="使用 gem 命令" >}}

运行如下命令：

```shell
gem install my_gem --source "https://__token__:<token>@gitlab.example.com/api/v4/projects/<project_id>/packages/rubygems"
```

{{< /tab >}}

{{< tab title="使用 Bundler" >}}

在您的 `Gemfile`中，添加一个 `source` 块：

```ruby
source "https://__token__:<token>@gitlab.example.com/api/v4/projects/<project_id>/packages/rubygems" do
  gem "my_gem"
end
```

{{< /tab >}}

{{< /tabs >}}

<a id="download-a-gem-file"></a>

## 下载 gem 文件

要下载 gem 文件以供本地使用而不安装它：

1. 在顶部栏中，选择**搜索或跳转到**，并找到您的项目。
1. 在左侧边栏中，选择**部署** > **软件包仓库**。
1. 选择软件包名称和版本。
1. 在**资产**下，选择您要下载的 Ruby gem。

要下载 gem 文件，您也可以[使用 API](../../../api/packages/rubygems.md#download-a-gem-file)。
