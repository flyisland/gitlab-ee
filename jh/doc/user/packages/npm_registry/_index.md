---
stage: Package
group: Package Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 软件包仓库中的 npm 软件包
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

Node Package Manager (npm) 是 JavaScript 和 Node.js 的默认软件包管理器。开发者使用 npm 来分享和复用代码、管理依赖项，并简化项目工作流程。在极狐GitLab 中，npm 软件包在软件开发生命周期中扮演着至关重要的角色。

有关 npm 端点的信息，请参阅 [API](../../../api/packages/npm.md)。

## 向软件包仓库进行认证

你必须向软件包仓库进行认证，才能从私有项目或私有群组发布或安装软件包。
如果项目或群组是公开的，则无需认证。
如果项目是内部的，你必须是极狐GitLab 实例上的注册用户。
匿名用户无法从内部项目拉取软件包。

要进行认证，你可以使用以下任一方式：

- 以下令牌之一，其范围设置为 `api`：
  - [个人访问令牌](../../profile/personal_access_tokens.md)
  - [群组访问令牌](../../group/settings/group_access_tokens.md)
  - [项目访问令牌](../../project/settings/project_access_tokens.md)
- 一个范围设置为 `read_package_registry`、`write_package_registry` 或两者兼具的[部署令牌](../../project/deploy_tokens/_index.md)。
- 如果你想通过 CI/CD 流水线发布软件包，可以使用 [CI/CD 作业令牌](../../../ci/jobs/ci_job_token.md)。

如果你的组织使用了双因素认证 (2FA)，则必须使用范围设置为 `api` 的个人访问令牌。
更多信息，请参阅[关于令牌的指南](../package_registry/supported_functionality.md#authenticate-with-the-registry)。

请勿使用此处记录的认证方法之外的其他认证方法。未记录的认证方法将来可能会被移除。

### 使用 `.npmrc` 文件

在与你的 `package.json` 相同的目录中创建或编辑 `.npmrc` 文件。在 `.npmrc` 文件中包含以下几行：

```shell
  //<domain_name>/api/v4/projects/<project_id>/packages/npm/:_authToken="${NPM_TOKEN}"
```

> [!warning]
> 永远不要将极狐GitLab 令牌（或任何令牌）直接硬编码到 `.npmrc` 文件或任何其他可以提交到仓库的文件中。

例如：

{{< tabs >}}

{{< tab title="实例级别" >}}

```shell
//<domain_name>/api/v4/packages/npm/:_authToken="${NPM_TOKEN}"
```

将 `<domain_name>` 替换为你的域名。例如 `gitlab.com`。

{{< /tab >}}

{{< tab title="群组级别" >}}

```shell
//<domain_name>/api/v4/groups/<group_id>/-/packages/npm/:_authToken="${NPM_TOKEN}"
```

确保替换：

- `<domain_name>` 为你的域名。例如 `gitlab.com`。
- `<group_id>` 为群组主页上的群组 ID。

{{< /tab >}}

{{< tab title="项目级别" >}}

```shell
//<domain_name>/api/v4/projects/<project_id>/packages/npm/:_authToken="${NPM_TOKEN}"
```

确保替换：

- `<domain_name>` 为你的域名。例如 `gitlab.com`。
- `<project_id>` 为[项目概览页面](../../project/working_with_projects.md#find-the-project-id)上的项目 ID。

{{< /tab >}}

{{< /tabs >}}

### 使用 `npm config set`

为此，请执行：

```shell
npm config set -- //<domain_name>/:_authToken=<token>
```

根据你的 npm 版本，你可能需要对 URL 进行更改：

- 在 npm 版本 7 或更早版本上，请使用指向端点的完整 URL。
- 在版本 8 及更高版本上，对于 `_authToken` 参数，你可以使用 URI 片段而不是完整 URL。更多信息，请参阅 [身份验证相关配置](https://docs.npmjs.com/cli/v8/configuring-npm/npmrc/?v=true#auth-related-configuration)。

> [!note]
> 如果你使用 Yarn Classic 1.x，则必须在设置认证令牌时指定完整的端点路径。Yarn Classic 不支持分层认证匹配，因此在父路径（如 `//gitlab.com/api/v4/`）上设置的令牌不会应用于子路径（如 `//gitlab.com/api/v4/groups/<group_id>/-/packages/npm/`）。请始终使用完整的群组或项目路径。更多信息，请参阅 [Yarn Classic 因认证路径缩短而返回 `401 Unauthorized`](../yarn_repository/_index.md#yarn-classic-returns-401-unauthorized-with-shortened-authentication-paths)。

例如：

{{< tabs >}}

{{< tab title="实例级别" >}}

```shell
npm config set -- //<domain_name>/api/v4/packages/npm/:_authToken=<token>
```

确保替换：

- `<domain_name>` 为你的域名。例如 `gitlab.com`。
- `<token>` 为你的部署令牌、群组访问令牌、项目访问令牌或个人访问令牌。

{{< /tab >}}

{{< tab title="群组级别" >}}

```shell
npm config set -- //<domain_name>/api/v4/groups/<group_id>/-/packages/npm/:_authToken=<token>
```

确保替换：

- `<domain_name>` 为你的域名。例如 `gitlab.com`。
- `<group_id>` 为群组主页上的群组 ID。
- `<token>` 为你的部署令牌、群组访问令牌、项目访问令牌或个人访问令牌。

{{< /tab >}}

{{< tab title="项目级别" >}}

```shell
npm config set -- //<domain_name>/api/v4/projects/<project_id>/packages/npm/:_authToken=<token>
```

确保替换：

- `<domain_name>` 为你的域名。例如 `gitlab.com`。
- `<project_id>` 为项目 ID。
- `<token>` 为你的部署令牌、群组访问令牌、项目访问令牌或个人访问令牌。

{{< /tab >}}

{{< /tabs >}}

## 设置仓库 URL

要从极狐GitLab 软件包仓库发布或安装软件包，你需要配置 npm 以使用正确的仓库 URL。配置方法和 URL 结构取决于你是要发布还是安装软件包。

在配置仓库 URL 之前，了解不同配置方法的作用范围很重要：

- `.npmrc` 文件：配置仅对包含该文件的文件夹本地有效。
- `npm config set` 命令：这会修改全局 npm 配置并影响你系统上运行的所有 npm 命令。
- `package.json` 中的 `publishConfig`：此配置特定于该软件包，仅在发布该软件包时适用。

> [!warning]
> 运行 `npm config set` 会更改全局 npm 配置。此更改会影响你系统上运行的所有 npm 命令，无论当前工作目录如何。使用此方法时请务必谨慎，尤其是在共享系统上。

### 用于发布软件包

发布软件包时，请使用项目端点：

```shell
https://gitlab.example.com/api/v4/projects/<project_id>/packages/npm/
```

将 `gitlab.example.com` 替换为你的极狐GitLab 实例域名，并将 `<project_id>` 替换为你的项目 ID。
要配置此 URL，请使用以下方法之一：

{{< tabs >}}

{{< tab title="`.npmrc` 文件" >}}

在你的项目根目录中创建或编辑 `.npmrc` 文件：

```plaintext
@scope:registry=https://gitlab.example.com/api/v4/projects/<project_id>/packages/npm/
//gitlab.example.com/api/v4/projects/<project_id>/packages/npm/:_authToken="${NPM_TOKEN}"
```

{{< /tab >}}

{{< tab title="`npm config`" >}}

使用 `npm config set` 命令：

```shell
npm config set @scope:registry=https://gitlab.example.com/api/v4/projects/<project_id>/packages/npm/
```

{{< /tab >}}

{{< tab title="`package.json`" >}}

将 `publishConfig` 部分添加到你的 `package.json` 中：

```shell
{
  "publishConfig": {
    "@scope:registry": "https://gitlab.example.com/api/v4/projects/<project_id>/packages/npm/"
  }
}
```

{{< /tab >}}

{{< /tabs >}}

将 `@scope` 替换为你软件包的作用域。

### 用于安装软件包

安装软件包时，你可以使用项目、群组或实例端点。URL 结构相应有所不同。
要配置这些 URL，请使用以下方法之一：

{{< tabs >}}

{{< tab title="`.npmrc` 文件" >}}

在你的项目根目录中创建或编辑 `.npmrc` 文件。根据你的需求使用适当的 URL：

- 对于项目：

  ```shell
  @scope:registry=https://gitlab.example.com/api/v4/projects/<project_id>/packages/npm/
  ```

- 对于群组：

  ```shell
  @scope:registry=https://gitlab.example.com/api/v4/groups/<group_id>/-/packages/npm/
  ```

- 对于实例：

  ```shell
  @scope:registry=https://gitlab.example.com/api/v4/packages/npm/
  ```

{{< /tab >}}

{{< tab title="`npm config`" >}}

使用带有适当 URL 的 `npm config set` 命令：

- 对于项目：

  ```shell
  npm config set @scope:registry=https://gitlab.example.com/api/v4/projects/<project_id>/packages/npm/
  ```

- 对于群组：

  ```shell
  npm config set @scope:registry=https://gitlab.example.com/api/v4/groups/<group_id>/-/packages/npm/
  ```

- 对于实例：

  ```shell
  npm config set @scope:registry=https://gitlab.example.com/api/v4/packages/npm/
  ```

{{< /tab >}}

{{< /tabs >}}

将 `gitlab.example.com`、`<project_id>`、`<group_id>` 和 `@scope` 替换为你的极狐GitLab 实例和软件包的相应值。

配置好仓库 URL 后，你就可以向软件包仓库进行认证了。

## 发布到极狐GitLab 软件包仓库

要将 npm 软件包发布到极狐GitLab 软件包仓库，你必须经过认证。

### 命名约定

根据软件包的安装方式，你可能需要遵守命名约定。

你可以使用以下三个 API 端点之一来安装软件包：

- 实例：当你在不同的极狐GitLab 群组或它们各自的命名空间中拥有许多 npm 软件包时使用。
- 群组：当你在同一群组或子群组下的不同项目中拥有许多 npm 软件包时使用。
- 项目：当你只有少量 npm 软件包并且它们不在同一个极狐GitLab 群组中时使用。

如果你计划从项目或群组安装软件包，则无需遵守命名约定。

如果你计划从实例安装软件包，则必须使用作用域来命名你的软件包。带作用域的软件包以 `@` 开头，格式为 `@owner/package-name`。你可以在 `.npmrc` 文件中以及通过使用 `package.json` 中的 `publishConfig` 选项来设置软件包的作用域。

- 用于 `@scope` 的值是托管软件包的项目的根，而不是软件包源代码本身的项目的根。作用域应为小写。
- 软件包名称可以是任何你想要的名称。

更多信息，请参阅[带作用域的软件包](https://docs.npmjs.com/cli/v11/using-npm/scope)。

| 项目 URL                                                 | 软件包仓库位于 | 作用域     | 完整软件包名称          |
| ------------------------------------------------------- | ------------------- | --------- | ---------------------- |
| `https://gitlab.com/my-org/engineering-group/analytics` | Analytics           | `@my-org` | `@my-org/package-name` |

确保你的 `package.json` 文件中的软件包名称符合此约定：

```shell
"name": "@my-org/package-name"
```

### 通过命令行发布软件包

配置认证后，使用以下命令发布 NPM 软件包：

```shell
npm publish
```

如果你使用 `.npmrc` 文件进行认证，请设置预期的环境变量：

```shell
NPM_TOKEN=<token> npm publish
```

如果上传的软件包包含多个 `package.json` 文件，则只会使用找到的第一个文件，其他的将被忽略。

### 通过 CI/CD 流水线发布软件包

通过使用 CI/CD 流水线发布时，你可以使用[预定义变量](../../../ci/variables/predefined_variables.md) `${CI_PROJECT_ID}` 和 `${CI_JOB_TOKEN}` 向你的项目软件包仓库进行认证。你可以使用这些变量在 CI/CD 作业执行期间创建一个 `.npmrc` 文件用于认证。

> [!note]
> 生成 `.npmrc` 文件时，如果 `${CI_SERVER_HOST}` 后面是默认端口，则不要指定端口。
> `http` URL 默认为 `80`，`https` URL 默认为 `443`。

在包含你的 `package.json` 的极狐GitLab 项目中，编辑或创建一个 `.gitlab-ci.yml` 文件。例如：

```yaml
default:
  image: node:latest

stages:
  - deploy

publish-npm:
  stage: deploy
  script:
    - echo "@scope:registry=https://${CI_SERVER_HOST}/api/v4/projects/${CI_PROJECT_ID}/packages/npm/" > .npmrc
    - echo "//${CI_SERVER_HOST}/api/v4/projects/${CI_PROJECT_ID}/packages/npm/:_authToken=${CI_JOB_TOKEN}" >> .npmrc
    - npm publish
```

将 `@scope` 替换为正在发布的软件包的[作用域](https://docs.npmjs.com/cli/v10/using-npm/scope/)。

当流水线中的 `publish-npm` 作业运行时，你的软件包就会被发布到软件包仓库。

## 安装软件包

如果多个软件包具有相同的名称和版本，当你安装软件包时，将检索最近发布的软件包。

你可以从极狐GitLab 项目、群组或实例安装软件包：

- 实例：当你在不同的极狐GitLab 群组或它们各自的命名空间中拥有许多 npm 软件包时使用。
- 群组：当你在同一极狐GitLab 群组的不同项目中拥有许多 npm 软件包时使用。
- 项目：当你只有少量 npm 软件包并且它们不在同一个极狐GitLab 群组中时使用。

### 从实例安装

先决条件：

- 软件包是根据带作用域的命名约定发布的。

1. 向软件包仓库进行认证。
1. 设置仓库：

   ```shell
   npm config set @scope:registry https://<domain_name>.com/api/v4/packages/npm/
   ```

   - 将 `@scope` 替换为你正在安装软件包的项目的顶级群组。
   - 将 `<domain_name>` 替换为你的域名，例如 `gitlab.com`。

1. 安装软件包：

   ```shell
   npm install @scope/my-package
   ```

### 从群组安装

{{< history >}}

- 在极狐GitLab 16.0 [引入](https://gitlab.com/gitlab-org/gitlab/-/issues/299834)，[带有功能标志](../../../administration/feature_flags/_index.md) `npm_group_level_endpoints`。默认禁用。
- 在极狐GitLab 16.1 [全面可用](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/121837)。功能标志 `npm_group_level_endpoints` 已移除。

{{< /history >}}

1. 向软件包仓库进行认证。
1. 设置仓库：

   ```shell
   npm config set @scope:registry=https://<domain_name>/api/v4/groups/<group_id>/-/packages/npm/
   ```

   - 将 `@scope` 替换为你正在安装软件包的群组的顶级群组。
   - 将 `<domain_name>` 替换为你的域名，例如 `gitlab.com`。
   - 将 `<group_id>` 替换为你的群组 ID，该 ID 可在群组主页上找到。

1. 安装软件包：

   ```shell
   npm install @scope/my-package
   ```

### 从项目安装

1. 向软件包仓库进行认证。
1. 设置仓库：

   ```shell
   npm config set @scope:registry=https://<domain_name>/api/v4/projects/<project_id>/packages/npm/
   ```

   - 将 `@scope` 替换为你正在安装软件包的项目的[顶级群组](#naming-convention)。
   - 将 `<domain_name>` 替换为你的域名，例如 `gitlab.com`。
   - 将 `<project_id>` 替换为你的项目 ID，该 ID 可在[项目概览页面](../../project/working_with_projects.md#find-the-project-id)上找到。

1. 安装软件包：

   ```shell
   npm install @scope/my-package
   ```

### 在 CI/CD 流水线中安装软件包

在 CI/CD 流水线中安装软件包时，你可以使用预定义变量 `${CI_PROJECT_ID}` 和 `${CI_JOB_TOKEN}` 向你的项目软件包仓库进行认证。你可以使用这些变量在 CI/CD 作业执行期间创建一个 `.npmrc` 文件用于认证。

> [!note]
> 生成 `.npmrc` 文件时，如果 `${CI_SERVER_HOST}` 后面是默认端口，则不要指定端口。
> `http` URL 默认为 `80`，`https` URL 默认为 `443`。

在包含你的 `package.json` 的极狐GitLab 项目中，编辑或创建一个 `.gitlab-ci.yml` 文件。例如：

```yaml
default:
  image: node:latest

stages:
  - deploy

publish-npm:
  stage: deploy
  script:
    - echo "@scope:registry=https://${CI_SERVER_HOST}/api/v4/projects/${CI_PROJECT_ID}/packages/npm/" > .npmrc
    - echo "//${CI_SERVER_HOST}/api/v4/projects/${CI_PROJECT_ID}/packages/npm/:_authToken=${CI_JOB_TOKEN}" >> .npmrc
    - npm install @scope/my-package
```

将 `@scope` 替换为正在安装的软件包的作用域，以及软件包名称。

前面的示例使用了项目级端点。要使用群组级或实例级端点，请按照从群组安装或从实例安装中所述配置仓库和认证令牌 URL。

### 软件包转发到 npmjs.com

{{< history >}}

- 在极狐GitLab 17.0 中，所需角色从维护者[变更](https://gitlab.com/gitlab-org/gitlab/-/issues/370471)为所有者。

{{< /history >}}

当在软件包仓库中找不到 npm 软件包时，极狐GitLab 会响应一个 HTTP 重定向，以便请求客户端可以将请求重新发送到 `npmjs.com`。

管理员可以在[持续集成设置](../../../administration/settings/continuous_integration.md)中禁用此行为。

群组所有者可以在群组的**软件包与镜像仓库**设置中禁用此行为。

改进工作正在[史诗 3608]中跟踪。

### 弃用软件包

{{< history >}}

- 在极狐GitLab 16.0 [引入](https://gitlab.com/gitlab-org/gitlab/-/issues/396763)。

{{< /history >}}

你可以弃用一个软件包，以便在获取该软件包时显示弃用警告。

先决条件：

- 你拥有删除软件包所需的[权限](../../permissions.md)。
- 你已向软件包仓库进行认证。

在命令行中，运行：

```shell
npm deprecate @scope/package "弃用信息"
```

CLI 也接受 `@scope/package` 的版本范围。例如：

```shell
npm deprecate @scope/package "所有软件包版本均已弃用"
npm deprecate @scope/package@1.0.1 "仅版本 1.0.1 被弃用"
npm deprecate @scope/package@"< 1.0.5" "所有低于 1.0.5 的软件包版本均已弃用"
```

当软件包被弃用时，其状态将更新为 `deprecated`。

### 移除弃用警告

要移除软件包的弃用警告，请为消息指定 `""`（一个空字符串）。例如：

```shell
npm deprecate @scope/package ""
```

当软件包的弃用警告被移除后，其状态将更新为 `default`。

## 删除软件包

先决条件：

- 你必须具有维护者或所有者角色。

在删除软件包之前，请确保你了解[相关的安全风险](../package_registry/supported_functionality.md#deleting-packages)。

要删除软件包，你可以：

- [使用 UI](../package_registry/reduce_package_registry_storage.md#delete-a-package)。
- [使用 API](../../../api/packages.md#delete-a-project-package)。

## 有用提示

### 从其他组织安装 npm 软件包

你可以将软件包请求路由到极狐GitLab 之外的组织和用户。

为此，请在你的 `.npmrc` 文件中添加行。将 `@my-other-org` 替换为拥有你项目仓库的命名空间或群组，并使用你组织的 URL。名称区分大小写，必须与你的群组或命名空间的名称完全匹配。

```shell
@scope:registry=https://my_domain_name.com/api/v4/packages/npm/
@my-other-org:registry=https://my_domain_name.example.com/api/v4/packages/npm/
```

### npm 元数据

极狐GitLab 软件包仓库向 npm 客户端公开以下属性：

- `name`
- `versions`
  - `name`
  - `version`
  - `deprecated`
  - `dependencies`
  - `devDependencies`
  - `bundleDependencies`
  - `peerDependencies`
  - `bin`
  - `directories`
  - `dist`
  - `engines`
  - `_hasShrinkwrap`
  - `hasInstallScript`：`true`（如果此版本有安装脚本）

更多信息，请参阅[简略版本对象](https://github.com/npm/registry/blob/main/docs/responses/package-metadata.md#abbreviated-version-object)。

### 添加 npm 分发标签

你可以为最新发布的软件包添加[分发标签](https://docs.npmjs.com/cli/dist-tag/)。
标签是可选的，并且一次只能分配给一个软件包。

当你发布一个不带标签的软件包时，默认会添加 `latest` 标签。
当你在未指定标签或版本的情况下安装软件包时，会使用 `latest` 标签。

支持的 `dist-tag` 命令示例：

```shell
npm publish @scope/package --tag               # 发布带有新标签的软件包
npm dist-tag add @scope/package@version my-tag # 为现有软件包添加标签
npm dist-tag ls @scope/package                 # 列出软件包下的所有标签
npm dist-tag rm @scope/package@version my-tag  # 从软件包中删除标签
npm install @scope/package@my-tag              # 安装特定标签
```

#### 从 CI/CD 中

{{< history >}}

- 在极狐GitLab 15.10 [引入](https://gitlab.com/gitlab-org/gitlab/-/issues/258835)。

{{< /history >}}

你可以使用以下任一令牌在极狐GitLab CI/CD 作业中运行 `npm dist-tag` 命令：

- [`CI_JOB_TOKEN`](../../../ci/jobs/ci_job_token.md)
- 部署令牌

先决条件：

- 你拥有 npm 6.9.1 或更高版本。在更早版本中，由于 npm 6.9.0 中的一个错误，删除分发标签会失败。

例如：

```yaml
npm-deploy-job:
  script:
    - echo "//${CI_SERVER_HOST}/api/v4/projects/${CI_PROJECT_ID}/packages/npm/:_authToken=${CI_JOB_TOKEN}">.npmrc
    - npm dist-tag add @scope/package@version my-tag
```

### 审计 npm 软件包

极狐GitLab 支持 `npm audit` 命令，允许你检查软件包中已知的漏洞。

#### 使用 `npm audit`

先决条件：

- 配置向软件包仓库的认证。
- 设置好仓库 URL。

要运行安全审计，你可以运行以下命令：

```shell
npm audit --registry=https://gitlab.example.com/api/v4/packages/npm/
```

或者，如果你已经设置好了仓库配置：

```shell
npm audit
```

`npm audit` 命令会检查你的依赖项是否存在已知漏洞并提供报告。

#### `npm audit` 工作流程

当你针对极狐GitLab 软件包仓库运行 `npm audit` 时，会发生以下两种情况之一：

1. 如果启用了软件包转发（默认启用），极狐GitLab 会将审计请求转发到 `npmjs.com` 以检索公共和私有软件包的漏洞信息。
1. 如果禁用了软件包转发，极狐GitLab 会返回空结果集。极狐GitLab 不独立扫描软件包漏洞。

#### 重要安全注意事项

如果你没有将极狐GitLab 指定为你的软件包仓库（或者通过 `--registry` 标志，或者通过在 `.npmrc` 文件中将其设置为默认仓库），审计请求将改为发送到公共 npm 仓库。

在这种情况下，请求体包含你项目中所有软件包的信息，包括你的极狐GitLab 私有软件包。

为确保你的私有软件包信息留在极狐GitLab 内，请始终确保在运行 `npm audit` 命令时指定极狐GitLab 仓库。

#### 已知问题

- 审计结果取决于软件包转发是否已启用。如果管理员或群组所有者禁用了转发，`npm audit` 不会返回漏洞信息。
- 审计请求包括你项目中所有软件包的信息，包括私有软件包。

### 支持的 CLI 命令

极狐GitLab npm 仓库支持 npm CLI (`npm`) 和 yarn CLI (`yarn`) 的以下命令：

- `npm install`：安装 npm 软件包。
- `npm publish`：将 npm 软件包发布到仓库。
- `npm dist-tag add`：为 npm 软件包添加分发标签。
- `npm dist-tag ls`：列出软件包的分发标签。
- `npm dist-tag rm`：删除分发标签。
- `npm ci`：直接从你的 `package-lock.json` 文件安装 npm 软件包。
- `npm view`：显示软件包元数据。
- `npm pack`：从软件包创建 tarball。
- `npm deprecate`：弃用软件包的某个版本。
- `npm audit`：检查项目依赖项中的漏洞。

## 故障排除

### npm 日志未正确显示

你可能会遇到如下错误：

```shell
npm ERR! A complete log of this run can be found in: .npm/_logs/<date>-debug-0
```

如果日志未出现在 `.npm/_logs/` 目录中，你可以将该日志复制到你的根目录并在那里查看：

```yaml
  script:
    - npm install --loglevel verbose
    - cp -r /root/.npm/_logs/ .
  artifacts:
    paths:
      - './_logs'
```

npm 日志作为产物被复制到 `/root/.npm/_logs/`。

### `npm install` 或 `yarn` 时出现 `404 Not Found` 错误

使用 `CI_JOB_TOKEN` 安装依赖项在另一个项目中的 npm 软件包时，会出现 404 Not Found 错误。你需要使用有权访问该软件包及其所有依赖项的令牌进行认证。
当您使用 Yarn Classic 从群组软件包仓库安装软件包时，软件包解析可能成功，但 tarball 下载可能失败并出现 `404 Not Found` 错误。出现此错误的原因是群组端点返回的软件包元数据包含指向项目端点的 tarball URL。您必须为群组和项目端点配置认证令牌：

```ini
//gitlab.example.com/api/v4/groups/<group_id>/-/packages/npm/:_authToken=<token>
//gitlab.example.com/api/v4/projects/<project_id>/packages/npm/:_authToken=<token>
```

更多信息，请参见 [当从群组安装获取 tarball 时，Yarn Classic 返回 `404 Not Found`](../yarn_repository/_index.md#yarn-classic-returns-404-not-found-when-fetching-a-tarball-from-a-group-install)。

如果软件包及其依赖项位于不同的项目，但属于同一个群组，您可以使用 [群组部署令牌](../../project/deploy_tokens/_index.md#create-a-deploy-token)：

```ini
//gitlab.example.com/api/v4/packages/npm/:_authToken=<group-token>
@group-scope:registry=https://gitlab.example.com/api/v4/packages/npm/
```

如果软件包及其依赖项分布在多个群组之间，您可以使用有权访问所有群组或各个项目的用户的个人访问令牌：

```ini
//gitlab.example.com/api/v4/packages/npm/:_authToken=<personal-access-token>
@group-1:registry=https://gitlab.example.com/api/v4/packages/npm/
@group-2:registry=https://gitlab.example.com/api/v4/packages/npm/
```

> [!warning]
> 个人访问令牌必须谨慎处理。请阅读我们的 [令牌安全注意事项](../../../security/tokens/_index.md#security-considerations) 以获取关于管理个人访问令牌的指导（例如，设置较短的过期时间并使用最小范围）。

<a id="npm-publish-targets-default-npm-registry-registry-npmjs-org"></a>

### `npm publish` 默认指向 npm 仓库 (`registry.npmjs.org`)

确保您的软件包作用域在 `package.json` 和 `.npmrc` 文件中设置一致。

例如，如果您的极狐GitLab 项目名称为 `@scope/my-package`，则您的 `package.json` 文件应该如下所示：

```json
{
  "name": "@scope/my-package"
}
```

而 `.npmrc` 文件应如下所示：

```shell
@scope:registry=https://your_domain_name/api/v4/projects/your_project_id/packages/npm/
//your_domain_name/api/v4/projects/your_project_id/packages/npm/:_authToken="${NPM_TOKEN}"
```

<a id="npm-install-returns-npm-err-403-forbidden"></a>

### `npm install` 返回 `npm ERR! 403 Forbidden`

如果您遇到此错误，请确保：

- 您的项目设置中已启用软件包仓库。虽然软件包仓库默认启用，但可以 [禁用它](../package_registry/_index.md#turn-off-the-package-registry)。
- 您的令牌未过期且具有适当的权限。
- 给定作用域内不存在同名或同版本的软件包。
- 作用域内的软件包 URL 包含尾部斜杠：
  - 正确：`//gitlab.example.com/api/v4/packages/npm/`
  - 不正确：`//gitlab.example.com/api/v4/packages/npm`

<a id="npm-publish-returns-npm-err-400-bad-request"></a>

### `npm publish` 返回 `npm ERR! 400 Bad Request`

如果您遇到此错误，可能是以下问题之一导致的。

<a id="package-name-does-not-meet-the-naming-convention"></a>

### 软件包名称不符合命名约定

您的软件包名称可能不符合 `@scope/package-name` 软件包命名约定。

确保名称完全符合约定，包括大小写。然后尝试再次发布。

<a id="package-already-exists"></a>

### 软件包已存在

您的软件包已发布到同一根命名空间中的另一个项目，因此无法使用相同的名称再次发布。

即使先前发布的软件包共享相同的名称（但版本不同），情况也是如此。

<a id="package-json-file-is-too-large"></a>

### 软件包 JSON 文件过大

确保您的 `package.json` 文件不超过 `20,000` 个字符。

