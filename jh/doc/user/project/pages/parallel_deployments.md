---
stage: Plan
group: Planner Intelligence
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: GitLab Pages 并行部署
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

借助并行部署，您可以同时发布多个版本的 [GitLab Pages](_index.md) 站点。每个版本都有自己独特的 URL，该 URL 基于您指定的路径前缀。

使用并行部署可以：

- 在合并到生产环境之前，增强您在开发分支中测试更改的工作流程。
- 与利益相关者共享工作预览以获取反馈。
- 同时维护多个软件版本的文档。
- 为不同受众发布本地化内容。
- 在最终发布前创建用于评审的预发布环境。

您站点的每个版本都会根据您指定的路径前缀获得自己的 URL。控制这些并行部署的存续时间。它们默认在 24 小时后过期，但您可以自定义此持续时间以符合您的评审时间线。

<a id="create-a-parallel-deployment"></a>

## 创建并行部署

先决条件：

- 根级命名空间必须有可用的并行部署槽位。

要创建并行部署：

1. 在您的 `.gitlab-ci.yml` 文件中，添加一个带有 `path_prefix` 的 Pages 作业：

   ```yaml
   pages:
     stage: deploy
     script:
       - echo "Pages accessible through ${CI_PAGES_URL}"
     pages:  # specifies that this is a Pages job and publishes the default public directory
       path_prefix: "$CI_COMMIT_BRANCH"
   ```

   `path_prefix` 值：

   - 会转换为小写。
   - 可以包含数字 (`0-9`)、字母 (`a-z`) 和句点 (`.`)。
   - 任何其他字符都会替换为连字符 (`-`)。
   - 不能以连字符 (`-`) 或句点 (`.`) 开头或结尾，因此这些字符会被移除。
   - 必须为 63 字节或更短。任何更长的内容都会被截断。

1. 可选。如果您想要动态前缀，请在您的 `path_prefix` 中使用 [CI/CD 变量](../../../ci/variables/where_variables_can_be_used.md#gitlab-ciyml-file)。例如：

   ```yaml
   pages:
     path_prefix: "mr-$CI_MERGE_REQUEST_IID" # Results in paths like mr-123
   ```

1. 可选。要为部署设置过期时间，请添加 `expire_in`：

   ```yaml
   pages:
     pages:
       path_prefix: "$CI_COMMIT_BRANCH"
       expire_in: 1 week
   ```

   默认情况下，并行部署会在 24 小时后[过期](#expiration)。

1. 提交您的更改并推送到您的代码仓库。

该部署可通过以下地址访问：

- 使用[唯一域名](_index.md#unique-domains)时：`https://project-123456.gitlab.io/your-prefix-name`。
- 未使用唯一域名时：`https://namespace.gitlab.io/project/your-prefix-name`。

站点域名和公共目录之间的 URL 路径由 `path_prefix` 决定。例如，如果您的主部署在 `/index.html` 有内容，则前缀为 `staging` 的并行部署可以在 `/staging/index.html` 访问相同内容。

为避免路径冲突，请避免使用与您站点中现有文件夹名称匹配的路径前缀。有关更多信息，请参阅[路径冲突](#path-clash)。

<a id="example-configuration"></a>

## 配置示例

考虑一个项目，例如 `https://gitlab.example.com/namespace/project`。默认情况下，其主 Pages 部署可以通过以下方式访问：

- 使用[唯一域名](_index.md#unique-domains)时：`https://project-123456.gitlab.io/`。
- 未使用唯一域名时：`https://namespace.gitlab.io/project`。

如果 `pages.path_prefix` 配置为项目分支名称，例如 `path_prefix = $CI_COMMIT_BRANCH`，并且存在一个名为 `username/testing_feature` 的分支，则此并行 Pages 部署可以通过以下方式访问：

- 使用[唯一域名](_index.md#unique-domains)时：`https://project-123456.gitlab.io/username-testing-feature`。
- 未使用唯一域名时：`https://namespace.gitlab.io/project/username-testing-feature`。

<a id="limits"></a>

## 限制

并行部署的数量受根级命名空间限制。有关具体限制，请参阅：

- JihuLab.com 暂未开启 GitLab Pages。详情参阅 [JihuLab.com 设置](../../jihulab_com/_index.md#gitlab-pages)。
- 极狐GitLab 私有化部署，请参阅 [并行 Pages 部署数量](../../../administration/instance_limits.md#number-of-parallel-pages-deployments)。

要立即减少您命名空间中活跃部署的数量，请删除一些部署。有关更多信息，请参阅[删除部署](_index.md#delete-a-deployment)。

要配置过期时间以自动删除较旧的部署，请参阅[过期部署](_index.md#expiring-deployments)。

<a id="expiration"></a>

## 过期

默认情况下，并行部署会在 24 小时后[过期](_index.md#expiring-deployments)，之后会被删除。如果您使用的是私有化部署实例，您的实例管理员可以[配置不同的默认持续时间](../../../administration/pages/_index.md#configure-the-default-expiry-for-parallel-deployments)。

要自定义过期时间，请[配置 `pages.expire_in`](_index.md#expiring-deployments)。

要防止部署自动过期，请将 `pages.expire_in` 设置为 `never`。

<a id="path-clash"></a>

## 路径冲突

`pages.path_prefix` 可以从 [CI/CD 变量](../../../ci/variables/_index.md) 获取动态值，这些值可能会创建与您站点中现有路径冲突的页面部署。例如，给定一个具有以下路径的现有 GitLab Pages 站点：

```plaintext
/index.html
/documents/index.html
```

如果 `pages.path_prefix` 为 `documents`，则该版本会覆盖现有路径。换句话说，`https://namespace.gitlab.io/project/documents/index.html` 指向站点 `documents` 部署上的 `/index.html`，而不是站点 `main` 部署的 `documents/index.html`。

将 [CI/CD 变量](../../../ci/variables/_index.md) 与其他字符串混合使用可以降低路径冲突的可能性。例如：

```yaml
create-pages:
  stage: deploy
  script:
    - echo "Pages accessible through ${CI_PAGES_URL}"
  variables:
    PAGES_PREFIX: "" # No prefix by default (main)
  pages:  # specifies that this is a Pages job and publishes the default public directory
    path_prefix: "$PAGES_PREFIX"
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH # Run on default branch (with default PAGES_PREFIX)
    - if: $CI_COMMIT_BRANCH == "staging" # Run on main (with default PAGES_PREFIX)
      variables:
        PAGES_PREFIX: '_stg' # Prefix with _stg for the staging branch
    - if: $CI_PIPELINE_SOURCE == "merge_request_event" # Conditionally change the prefix for Merge Requests
      when: manual # Run pages manually on Merge Requests
      variables:
        PAGES_PREFIX: 'mr-$CI_MERGE_REQUEST_IID' # Prefix with the mr-<iid>, like `mr-123`
```

将 [变量](../../../ci/variables/_index.md) 与字符串混合用于动态前缀的其他一些示例：

- `pages.path_prefix: 'mr-$CI_COMMIT_REF_SLUG'`：以 `mr-` 为前缀的分支或标签名称，例如 `mr-branch-name`。
- `pages.path_prefix: '_${CI_MERGE_REQUEST_IID}_'`：以 `_` 为前缀和后缀的合并请求编号，例如 `_123_`。

前面的 YAML 示例使用了[用户定义的作业名称](_index.md#user-defined-job-names)。

<a id="use-parallel-deployments-to-create-pages-environments"></a>

## 使用并行部署创建 Pages 环境

您可以使用并行 GitLab Pages 部署来创建新的[环境](../../../ci/environments/_index.md)。例如：

```yaml
create-pages:
  stage: deploy
  script:
    - echo "Pages accessible through ${CI_PAGES_URL}"
  variables:
    PAGES_PREFIX: "" # no prefix by default (run on the default branch)
  pages:  # specifies that this is a Pages job and publishes the default public directory
    path_prefix: "$PAGES_PREFIX"
  environment:
    name: "Pages ${PAGES_PREFIX}"
    url: $CI_PAGES_URL
  rules:
    - if: $CI_COMMIT_BRANCH == "staging" # ensure to run on the default branch (with default PAGES_PREFIX)
      variables:
        PAGES_PREFIX: '_stg' # prefix with _stg for the staging branch
    - if: $CI_PIPELINE_SOURCE == "merge_request_event" # conditionally change the prefix on Merge Requests
      when: manual # run pages manually on Merge Requests
      variables:
        PAGES_PREFIX: 'mr-$CI_MERGE_REQUEST_IID' # prefix with the mr-<iid>, like `mr-123`
```

使用此配置，用户可以通过 UI 访问每个 GitLab Pages 部署。当为页面使用[环境](../../../ci/environments/_index.md)时，所有页面环境都会列在项目环境列表中。

您还可以将[相似的环境分组](../../../ci/environments/_index.md#group-similar-environments)在一起。

前面的 YAML 示例使用了[用户定义的作业名称](_index.md#user-defined-job-names)。

<a id="auto-clean"></a>

### 自动清理

由带有 `path_prefix` 的合并请求创建的并行 Pages 部署，会在该合并请求关闭或合并时自动删除。

<a id="usage-with-redirects"></a>

## 与重定向一起使用

重定向使用绝对路径。由于并行部署在子路径上可用，因此重定向需要对 `_redirects` 文件进行额外修改才能在并行部署中工作。

现有文件始终优先于重定向规则，因此您可以使用通配符占位符来捕获对带前缀路径的请求。

如果您的 `path_prefix` 为 `/mr-${$CI_MERGE_REQUEST_IID}`，请调整此 `_redirect` 文件示例，以重定向主部署和并行部署的请求：

```shell
# Redirect the primary deployment
/will-redirect.html /redirected.html 302

# Redirect parallel deployments
/*/will-redirect.html /:splat/redirected.html 302
```
