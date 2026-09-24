---
stage: Package
group: Package Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 软件包仓库中的 Ruby gems
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Status: 实验性

{{< /details >}}

{{< history >}}

- 于极狐GitLab 13.9 [引入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/52147)，伴随一个名为 `rubygem_packages` 的[功能标志](../../../administration/feature_flags/_index.md)。默认禁用。此功能是[实验性功能](../../../policy/development_stages_support.md)。

{{< /history >}}

> [!flag]
> 此功能的可用性由功能标志控制。
> 更多信息，请参见历史记录。
> 此功能可用于测试，但尚不适合用于生产环境。

你可以将 Ruby gems 发布到项目的软件包仓库中。然后，你可以从 UI 或通过 API 下载它们。

此功能是[实验性功能](../../../policy/development_stages_support.md)。
有关此功能开发的更多信息，请参见[史诗 3200](https://jihulab.com/groups/gitlab-org/-/epics/3200)。

<a id="authenticate-to-the-package-registry"></a>

## 向软件包仓库进行认证

在与软件包仓库交互之前，你必须先进行认证。

为此，你可以使用：

- 一个 [个人访问令牌](../../profile/personal_access_tokens.md)，其作用域设置为 `api`。
- 一个 [部署令牌](../../project/deploy_tokens/_index.md)，其作用域设置为 `read_package_registry`、`write_package_registry` 或两者。
- 一个 [CI/CD 作业令牌](../../../ci/jobs/ci_job_token.md)。

例如：

{{< tabs >}}

{{< tab title="使用访问令牌" >}}

要使用访问令牌进行认证：

- 创建或编辑你的 `~/.gem/credentials` 文件，并添加：

  ```ini
  ---
  https://gitlab.example.com/api/v4/projects/<project_id>/packages/rubygems: '<token>'
  ```

在此示例中：

- `<token>` 必须是你个人访问令牌或部署令牌的令牌值。
- `<project_id>` 显示在 [项目概览页面](../../project/working_with_projects.md#find-the-project-id) 上。

{{< /tab >}}

{{< tab title="使用 CI/CD 作业令牌" >}}

要使用 CI/CD 作业令牌进行认证：

- 创建或编辑你的 `.gitlab-ci.yml` 文件，并添加：

  ```yaml
  # 假设仓库中存在一个 my_gem.gemspec 文件，其版本当前设置为 0.0.1
  image: ruby

  run:
    before_script:
      - mkdir ~/.gem
      - echo "---" > ~/.gem/credentials
      - |
        echo "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/rubygems: '${CI_JOB_TOKEN}'" >> ~/.gem/credentials
      - chmod 0600 ~/.gem/credentials # rubygems 要求凭证文件具有 0600 权限
    script:
      - gem build my_gem
      - gem push my_gem-0.0.1.gem --host ${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/rubygems
  ```

  你也可以在检入极狐GitLab 的 `~/.gem/credentials` 文件中使用 `CI_JOB_TOKEN`：

  ```ini
  ---
  https://gitlab.example.com/api/v4/projects/${env.CI_PROJECT_ID}/packages/rubygems: '${env.CI_JOB_TOKEN}'
  ```

{{< /tab >}}

{{< /tabs >}}

<a id="push-a-ruby-gem"></a>

## 推送 Ruby gem

前提条件：

- 你必须先 [向软件包仓库进行认证](#authenticate-to-the-package-registry)。
- 你的 Ruby gem 不得大于 3 GB。

操作步骤：

- 运行类似以下命令：

  ```shell
  gem push my_gem-0.0.1.gem --host <host>
  ```

  在此示例中，`<host>` 是你设置认证时使用的 URL。例如：

  ```shell
  gem push my_gem-0.0.1.gem --host https://gitlab.example.com/api/v4/projects/1/packages/rubygems
  ```

当 gem 发布成功时，会显示类似以下的消息：

```plaintext
正在将 gem 推送到 https://gitlab.example.com/api/v4/projects/1/packages/rubygems ...
{"message":"201 Created"}
```

gem 将被发布到你的软件包仓库，并显示在 **软件包与镜像仓库** 页面上。
极狐GitLab 可能需要最多 10 分钟来处理并显示你的 gem。

<a id="pushing-gems-with-the-same-name-or-version"></a>

### 推送同名或同版本的 gems

如果已存在同名和同版本的软件包，你仍然可以推送 gem。两者都会在 UI 中可见并可访问。

<a id="delete-a-ruby-gem"></a>

## 删除 Ruby gem

前提条件：

- 你必须具有维护者或所有者角色。

在删除软件包之前，请确保你了解相关的 [安全风险](../package_registry/supported_functionality.md#deleting-packages)。

要删除软件包，你可以使用以下方式之一：

- [使用 UI](../package_registry/reduce_package_registry_storage.md#delete-a-package)。
- [使用 API](../../../api/packages.md#delete-a-project-package)。

<a id="download-gems"></a>

## 下载 gems

你不能从极狐GitLab 软件包仓库安装 Ruby gems。然而，你可以下载 gem 文件供本地使用。

操作步骤：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
2. 在左侧边栏中，选择 **部署** > **软件包仓库**。
3. 选择软件包名称和版本。
4. 在 **资产** 下，选择你要下载的 Ruby gem。

你也可以 [使用 API](../../../api/packages/rubygems.md#download-a-gem-file) 下载 Ruby gems。