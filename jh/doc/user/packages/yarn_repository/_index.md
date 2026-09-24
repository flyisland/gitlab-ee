---
stage: Package
group: Package Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用 Yarn 发布软件包
---

你可以使用 [Yarn 1（经典版）](https://classic.yarnpkg.com) 和 [Yarn 2+](https://yarnpkg.com) 发布和安装软件包。

要查找部署容器中使用的 Yarn 版本，请在负责调用 `yarn publish` 的 CI/CD 脚本任务的 `script` 块中运行 `yarn --version`。Yarn 版本会显示在流水线输出中。

<a id="authenticating-to-the-package-registry"></a>

## 向软件包仓库进行身份认证

你需要一个令牌才能与软件包仓库交互。根据你的目的，有不同的令牌可用。更多信息，请参考 [令牌指南](../package_registry/supported_functionality.md#authenticate-with-the-registry)。

- 如果你的组织使用双因素身份认证（2FA），你必须使用 [个人访问令牌](../../profile/personal_access_tokens.md)，其范围设置为 `api`。
- 如果你使用 CI/CD 流水线发布软件包，你可以结合私有 runner 使用 [CI/CD 任务令牌](../../../ci/jobs/ci_job_token.md)。你也可以为实例 runner [注册一个变量](https://gitlab.cn/docs/runner/register/#register-with-a-runner-authentication-token)。

<a id="configure-yarn-for-publication"></a>

### 配置 Yarn 以进行发布

要配置 Yarn 发布到软件包仓库，请编辑你的 `.yarnrc.yml` 文件。你可以在项目的根目录中找到这个文件，与 `package.json` 文件在同一位置。

- 编辑 `.yarnrc.yml` 并添加以下配置：

  ```yaml
  npmScopes:
    <my-org>:
      npmPublishRegistry: 'https://<domain>/api/v4/projects/<project_id>/packages/npm/'
      npmAlwaysAuth: true
      npmAuthToken: '<token>'
  ```

  在此配置中：

  - 将 `<my-org>` 替换为你的组织作用域。不要包含 `@` 符号。
  - 将 `<domain>` 替换为你的域名。
  - 将 `<project_id>` 替换为你项目的 ID，可以在 [项目概览页面](../../project/working_with_projects.md#find-the-project-id) 上找到。
  - 将 `<token>` 替换为部署令牌、群组访问令牌、项目访问令牌或个人访问令牌。

在 Yarn 经典版中，不支持使用 `publishConfig["@scope:registry"]` 的作用域注册表。有关更多信息，请参阅 [Yarn 拉取请求 7829](https://github.com/yarnpkg/yarn/pull/7829)。相反，在 `package.json` 文件中将 `publishConfig` 设置为 `registry`。

<a id="publish-a-package"></a>

## 发布软件包

你可以通过命令行或使用极狐GitLab CI/CD 发布软件包。

<a id="with-the-command-line"></a>

### 使用命令行

手动发布软件包：

- 运行以下命令：

  ```shell
  # Yarn 1（经典版）
  yarn publish

  # Yarn 2 及更高版本
  yarn npm publish
  ```

<a id="with-cicd"></a>

### 使用 CI/CD

你可以使用实例 runner（默认）或私有 runner（高级）自动发布软件包。在使用 CI/CD 发布时，你可以使用流水线变量。

{{< tabs >}}

{{< tab title="实例 runner" >}}

1. 为你的项目或群组创建身份验证令牌：

   1. 在顶部栏，选择 **搜索或跳转到** 并找到你的项目或群组。
   1. 在左侧边栏，选择 **设置** > **代码仓** > **部署令牌**。
   1. 创建一个具有 `read_package_registry` 和 `write_package_registry` 范围的部署令牌，并复制生成的令牌。
   1. 在左侧边栏，选择 **设置** > **CI/CD** > **变量**。
   1. 选择 **添加变量** 并使用以下设置：

   | 字段                | 值                           |
   |--------------------|------------------------------|
   | key                | `NPM_AUTH_TOKEN`             |
   | value              | `<DEPLOY-TOKEN>` |
   | type               | Variable                     |
   | 受保护变量           | `CHECKED`                    |
   | 掩码变量             | `CHECKED`                    |
   | 展开变量             | `CHECKED`                    |

1. 可选。要使用受保护的变量：

   1. 转到包含 Yarn 软件包源代码的代码仓。
   1. 在左侧边栏，选择 **设置** > **代码仓**。
      - 如果你是从带有标签的分支构建，请选择 **受保护的标签**，并添加 `v*`（通配符）以用于语义版本控制。
      - 如果你是从不带标签的分支构建，请选择 **分支规则**。

1. 将创建的 `NPM_AUTH_TOKEN` 添加到软件包项目根目录中的 `.yarnrc.yml` 配置文件（即 `package.json` 所在位置）：

   ```yaml
   npmScopes:
     <my-org>:
       npmPublishRegistry: '${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/npm/'
       npmAlwaysAuth: true
       npmAuthToken: '${NPM_AUTH_TOKEN}'
   ```

   在此配置中，将 `<my-org>` 替换为你的组织作用域，不包括 `@` 符号。

{{< /tab >}}

{{< tab title="私有 runner" >}}

1. 将你的 `CI_JOB_TOKEN` 添加到软件包项目根目录的 `.yarnrc.yml` 配置文件中（即 `package.json` 所在位置）：

   ```yaml
   npmScopes:
     <my-org>:
       npmPublishRegistry: '${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/npm/'
       npmAlwaysAuth: true
       npmAuthToken: '${CI_JOB_TOKEN}'
   ```

   在此配置中，将 `<my-org>` 替换为你的组织作用域，不包括 `@` 符号。

1. 在包含 `.yarnrc.yml` 的极狐GitLab 项目中，编辑或创建一个 `.gitlab-ci.yml` 文件。例如，仅在推送标签时触发：

   对于 Yarn 1：

   ```yaml
   image: node:lts

   stages:
     - deploy

   rules:
   - if: $CI_COMMIT_TAG

   deploy:
     stage: deploy
     script:
       - yarn publish
   ```

   对于 Yarn 2 及更高版本：

   ```yaml
   image: node:lts

   stages:
     - deploy

   rules:
     - if: $CI_COMMIT_TAG

   deploy:
     stage: deploy
     before_script:
       - corepack enable
       - yarn set version stable
     script:
       - yarn npm publish
   ```

当流水线运行时，你的软件包将被添加到软件包仓库中。

{{< /tab >}}

{{< /tabs >}}

<a id="install-a-package"></a>

## 安装软件包

你可以从实例或项目安装。如果有多个软件包具有相同的名称和版本，则在安装软件包时只会检索最近发布的软件包。

<a id="scoped-package-names"></a>

### 作用域软件包名称

要从实例安装，软件包必须以 [作用域](https://docs.npmjs.com/misc/scope/) 命名。你可以在 `.yarnrc.yml` 文件中设置软件包的作用域，并在 `package.json` 中使用 `publishConfig` 选项。如果你从项目或群组安装，则无需遵循软件包命名规范。

软件包作用域以 `@` 开头，格式为 `@owner/package-name`：

- `@owner` 是托管软件包的顶级项目，而不是包含软件包源代码的项目根目录。
- 软件包名称可以是任何内容。

例如：

| 项目 URL                                                          | 软件包仓库           | 组织作用域      | 完整软件包名称             |
|-------------------------------------------------------------------|----------------------|----------------|-----------------------------|
| `https://jihulab.com/<my-org>/<group-name>/<package-name-example>` | 软件包名称示例        | `@my-org`      | `@my-org/package-name`      |
| `https://jihulab.com/<example-org>/<group-name>/<project-name>`    | 项目名称              | `@example-org` | `@example-org/project-name` |

<a id="install-from-the-instance"></a>

### 从实例安装

如果你在同一组织作用域下使用多个软件包，请考虑从实例安装。

1. 配置你的组织作用域。在你的 `.yarnrc.yml` 文件中，添加以下内容：

   ```yaml
   npmScopes:
    <my-org>:
      npmRegistryServer: 'https://<domain_name>/api/v4/packages/npm'
   ```

   - 将 `<my-org>` 替换为你安装软件包的目标项目的根级群组，不包括 `@` 符号。
   - 将 `<domain_name>` 替换为你的域名，例如 `jihulab.com`。

1. 可选。如果你的软件包是私有的，你必须配置对软件包仓库的访问：

   ```yaml
   npmRegistries:
     //<domain_name>/api/v4/packages/npm:
       npmAlwaysAuth: true
       npmAuthToken: '<token>'
   ```

   - 将 `<domain_name>` 替换为你的域名，例如 `jihulab.com`。
   - 将 `<token>` 替换为部署令牌（推荐）、群组访问令牌、项目访问令牌或个人访问令牌。

1. [使用 Yarn 安装软件包](#install-with-yarn)。

<a id="install-from-a-group-or-project"></a>

### 从群组或项目安装

如果你有一个一次性使用的软件包，你可以从群组或项目安装。

{{< tabs >}}

{{< tab title="从群组" >}}

1. 配置群组作用域。在你的 `.yarnrc.yml` 文件中，添加以下内容：

   ```yaml
   npmScopes:
     <my-org>:
       npmRegistryServer: 'https://<domain_name>/api/v4/groups/<group_id>/-/packages/npm'
   ```

   - 将 `<my-org>` 替换为包含你要安装软件包的目标群组的顶级群组。不包括 `@` 符号。
   - 将 `<domain_name>` 替换为你的域名，例如 `jihulab.com`。
   - 将 `<group_id>` 替换为你的群组 ID，可以在 [群组概览页面](../../group/_index.md#find-the-group-id) 上找到。

1. 可选。如果你的软件包是私有的，你必须设置注册表：

   ```yaml
   npmRegistries:
     //<domain_name>/api/v4/groups/<group_id>/-/packages/npm:
       npmAlwaysAuth: true
       npmAuthToken: "<token>"
   ```

   - 将 `<domain_name>` 替换为你的域名，例如 `jihulab.com`。
   - 将 `<token>` 替换为部署令牌（推荐）、群组访问令牌、项目访问令牌或个人访问令牌。
   - 将 `<group_id>` 替换为你的群组 ID，可以在 [群组概览页面](../../group/_index.md#find-the-group-id) 上找到。

1. [使用 Yarn 安装软件包](#install-with-yarn)。

{{< /tab >}}

{{< tab title="从项目" >}}

1. 配置项目作用域。在你的 `.yarnrc.yml` 文件中，添加以下内容：

   ```yaml
   npmScopes:
    <my-org>:
      npmRegistryServer: "https://<domain_name>/api/v4/projects/<project_id>/packages/npm"
   ```

   - 将 `<my-org>` 替换为包含你要安装软件包的目标项目的顶级群组。不包括 `@` 符号。
   - 将 `<domain_name>` 替换为你的域名，例如 `jihulab.com`。
   - 将 `<project_id>` 替换为你的项目 ID，可以在 [项目概览页面](../../project/working_with_projects.md#find-the-project-id) 上找到。

1. 可选。如果你的软件包是私有的，你必须设置注册表：

   ```yaml
   npmRegistries:
     //<domain_name>/api/v4/projects/<project_id>/packages/npm:
       npmAlwaysAuth: true
       npmAuthToken: "<token>"
   ```

   - 将 `<domain_name>` 替换为你的域名，例如 `jihulab.com`。
   - 将 `<token>` 替换为部署令牌（推荐）、群组访问令牌、项目访问令牌或个人访问令牌。
   - 将 `<project_id>` 替换为你的项目 ID，可以在 [项目概览页面](../../project/working_with_projects.md#find-the-project-id) 上找到。

1. [使用 Yarn 安装软件包](#install-with-yarn)。

{{< /tab >}}

{{< /tabs >}}

<a id="install-with-yarn"></a>

### 使用 Yarn 安装

{{< tabs >}}

{{< tab title="Yarn 2 或更高版本" >}}

- 从命令行或 CI/CD 流水线运行 `yarn add`：

```shell
yarn add @scope/my-package
```

{{< /tab >}}

{{< tab title="Yarn 经典版" >}}

Yarn 经典版需要 `.npmrc` 和 `.yarnrc` 两个文件。有关更多信息，请参阅 [Yarn 议题 4451](https://github.com/yarnpkg/yarn/issues/4451#issuecomment-753670295)。

1. 将你的凭据放在 `.npmrc` 文件中，将作用域注册表放在 `.yarnrc` 文件中：

   ```shell
   # .npmrc
   ## 对于实例
   //<domain_name>/api/v4/packages/npm/:_authToken='<token>'
   ## 对于群组
   //<domain_name>/api/v4/groups/<group_id>/-/packages/npm/:_authToken='<token>'
   ## 对于项目
   //<domain_name>/api/v4/projects/<project_id>/packages/npm/:_authToken='<token>'

   # .yarnrc
   ## 对于实例
   '@scope:registry' 'https://<domain_name>/api/v4/packages/npm/'
   ## 对于群组
   '@scope:registry' 'https://<domain_name>/api/v4/groups/<group_id>/-/packages/npm/'
   ## 对于项目
   '@scope:registry' 'https://<domain_name>/api/v4/projects/<project_id>/packages/npm/'
   ```

1. 从命令行或 CI/CD 流水线运行 `yarn add`：

   ```shell
   yarn add @scope/my-package
   ```

{{< /tab >}}

{{< /tabs >}}

<a id="delete-a-yarn-package"></a>

## 删除 Yarn 软件包

先决条件：

- 你必须具有维护者或所有者角色。

在删除软件包之前，请确保你了解 [相关的安全风险](../package_registry/supported_functionality.md#deleting-packages)。

要删除软件包，你可以：

- [使用 UI](../package_registry/reduce_package_registry_storage.md#delete-a-package)。
- [使用 API](../../../api/packages.md#delete-a-project-package)。

<a id="troubleshooting"></a>

## 故障排除

<a id="error-running-yarn-with-the-package-registry-for-the-npm-registry"></a>

### 在用于 npm 注册表的软件包仓库中运行 Yarn 时出错

如果你将 [Yarn](https://classic.yarnpkg.com/en/) 与 npm 注册表一起使用，可能会收到如下错误消息：

```shell
yarn install v1.15.2
警告 package.json: 没有许可字段
信息 未发现锁定文件。
警告 XXX: 没有许可字段
[1/4] 🔍  正在解析包...
[2/4] 🚚  正在获取包...
错误 发生意外错误: "https://gitlab.example.com/api/v4/projects/XXX/packages/npm/XXX/XXX/-/XXX/XXX-X.X.X.tgz: 请求失败 \"404 未找到\""。
信息 如果你认为这是一个 bug，请使用“/Users/XXX/gitlab-migration/module-util/yarn-error.log”中提供的信息提交 bug 报告。
信息 访问 https://classic.yarnpkg.com/en/docs/cli/install 获取关于此命令的文档
```

在这种情况下，以下命令会在当前目录中创建一个名为 `.yarnrc` 的文件。请确保位于用户主目录（用于全局配置）或项目根目录（用于每个项目的配置）中：

```shell
yarn config set '//gitlab.example.com/api/v4/projects/<project_id>/packages/npm/:_authToken' '<token>'
yarn config set '//gitlab.example.com/api/v4/packages/npm/:_authToken' '<token>'
```

<a id="yarn-classic-returns-404-not-found-when-fetching-a-tarball-from-a-group-install"></a>

### 从群组安装获取 tarball 时，Yarn 经典版返回 `404 未找到`

当你使用 Yarn 经典版从群组中的注册表安装软件包时，软件包解析可能成功，但 tarball 下载失败并显示 `404 未找到` 错误：

```shell
[1/4] 正在解析包...
[2/4] 正在获取包...
错误 Error: https://gitlab.example.com/api/v4/projects/<project_id>/packages/npm/@scope/my-package/-/@scope/my-package-1.0.0.tgz: 请求失败 "404 未找到"
```

发生此错误的原因是群组注册表返回的软件包元数据中包含指向项目端点的 tarball 下载 URL。如果你的 `.npmrc` 文件只有群组端点的身份验证令牌，那么对项目端点的请求是未经验证的，并返回 `404`。

要解决此问题，请在 `.npmrc` 文件中为群组和项目端点添加身份验证令牌：

```ini
# .npmrc
//gitlab.example.com/api/v4/groups/<group_id>/-/packages/npm/:_authToken='<token>'
//gitlab.example.com/api/v4/projects/<project_id>/packages/npm/:_authToken='<token>'
```

<a id="yarn-classic-returns-401-unauthorized-with-shortened-authentication-paths"></a>

### 使用短身份验证路径时，Yarn 经典版返回 `401 未授权`

当使用 Yarn 经典版与极狐GitLab 软件包仓库时，即使你的身份验证令牌有效，你也可能收到 `401 未授权` 错误。错误消息可能如下所示：

```shell
错误 无法在 "npm" 注册表中找到软件包 "@scope/my-package"。
```

使用 `--verbose` 标志，日志会显示 `401` 状态码：

```shell
详细 正在对 "https://jihulab.com/api/v4/groups/<group_id>/-/packages/npm/..." 执行 "GET" 请求
详细 请求 "https://jihulab.com/api/v4/groups/<group_id>/-/packages/npm/..." 完成，状态码 401。
```

当 `.npmrc` 中的 `_authToken` 条目使用了缩短的父路径而非完整的端点路径时，就会出现此问题。例如：

```ini
# 不适用于 Yarn 经典版
//jihulab.com/api/v4/:_authToken='<token>'
```

虽然 npm 8 及更高版本支持分层身份验证匹配（在父路径上设置的令牌适用于所有子路径），但 Yarn 经典版要求 `_authToken` 条目与注册表 URL 之间精确路径匹配。

要解决此问题，请在 `.npmrc` 文件中为你要进行身份验证的每个注册表使用完整的端点路径。例如，当从群组注册表安装托管在特定项目中的软件包时：

```ini
# .npmrc
//jihulab.com/api/v4/groups/<group_id>/-/packages/npm/:_authToken='<token>'
//jihulab.com/api/v4/projects/<project_id>/packages/npm/:_authToken='<token>'
```

需要项目条目，因为群组端点返回的软件包元数据中包含指向项目端点的 tarball 下载 URL。

<a id="yarn-install-fails-to-clone-repository-as-a-dependency"></a>

### `yarn install` 无法将仓库克隆为依赖项

如果你从 Dockerfile 中使用 `yarn install`，在构建 Dockerfile 时可能会收到如下错误：

```plaintext
...
#6 8.621 致命错误：无法访问 'https://jihulab.com/path/to/project/'：SSL CA 证书问题（路径？访问权限？）
#6 8.621 信息 访问 https://yarnpkg.com/en/docs/cli/install 获取关于此命令的文档。
#6 ...
```

要解决此问题，请在 [.dockerignore](https://docs.docker.com/build/building/context/#dockerignore-files) 文件中为每个 Yarn 相关路径 [添加感叹号（`!`）](https://docs.docker.com/build/building/context/#negating-matches)。

```dockerfile
**

!./package.json
!./yarn.lock
...
```