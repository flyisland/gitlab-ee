---
stage: Package
group: Package Registry
info: 要确定与此页面相关的阶段/组对应的技术文档撰写人员，请参阅 <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 软件包仓库中的 Helm Chart
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

将 Helm 软件包发布到项目的软件包仓库中。然后，在需要将其作为依赖项使用时，即可安装这些软件包。

有关 Helm 软件包管理器客户端使用的特定 API 端点的文档，请参阅 [Helm API 文档](../../../api/packages/helm.md)。

<a id="build-a-helm-package"></a>

## 构建 Helm 软件包

有关以下主题的更多信息，请参阅 Helm 文档：

- [创建自己的 Helm Charts](https://helm.sh/docs/intro/using_helm/#creating-your-own-charts)
- [将 Helm Chart 打包为 Chart 存档](https://helm.sh/docs/helm/helm_package/#helm-package)

<a id="authenticate-to-the-helm-repository"></a>

## 向 Helm 仓库进行身份验证

要向 Helm 仓库进行身份验证，你需要以下任一内容：

- 一个作用域设置为 `api` 的[个人访问令牌](../../profile/personal_access_tokens.md)。
- 一个作用域设置为 `read_package_registry`、`write_package_registry` 或两者皆有的[部署令牌](../../project/deploy_tokens/_index.md)。
- 一个 [CI/CD 作业令牌](../../../ci/jobs/ci_job_token.md)。

<a id="publish-a-package"></a>

## 发布软件包

> [!note]
> 你可以发布具有重复名称或版本的 Helm Chart。如果存在重复，极狐GitLab 始终返回最新版本的 Chart。

构建完成后，可以使用 `curl` 或 `helm cm-push` 将 Chart 上传到所需的通道：

- 使用 `curl`：

  ```shell
  curl --fail-with-body --request POST \
       --form 'chart=@mychart-0.1.0.tgz' \
       --user <username>:<access_token> \
       https://gitlab.example.com/api/v4/projects/<project_id>/packages/helm/api/<channel>/charts
  ```

  - `<username>`：极狐GitLab 用户名或部署令牌用户名。
  - `<access_token>`：个人访问令牌或部署令牌。
  - `<project_id>`：项目 ID（如 `42`）或项目的 [URL 编码](../../../api/rest/_index.md#namespaced-paths) 路径（如 `group%2Fproject`）。
  - `<channel>`：通道名称（如 `stable`）。
- 使用 [`helm cm-push`](https://github.com/chartmuseum/helm-push/#readme) 插件：

  ```shell
  helm repo add --username <username> --password <access_token> project-1 https://gitlab.example.com/api/v4/projects/<project_id>/packages/helm/<channel>
  helm cm-push mychart-0.1.0.tgz project-1
  ```

  - `<username>`：极狐GitLab 用户名或部署令牌用户名。
  - `<access_token>`：个人访问令牌或部署令牌。
  - `<project_id>`：项目 ID（如 `42`）。
  - `<channel>`：通道名称（如 `stable`）。

<a id="release-channels"></a>

### 发布通道

你可以将 Helm Chart 发布到极狐GitLab 中的通道。通道是一种可用于区分 Helm Chart 仓库的方法。例如，你可以使用 `stable` 和 `devel` 作为通道，以便允许用户添加 `stable` 仓库，同时隔离 `devel` Chart。

<a id="use-cicd-to-publish-a-helm-package"></a>

## 使用 CI/CD 发布 Helm 软件包

要通过[极狐GitLab CI/CD](../../../ci/_index.md) 自动发布 Helm 软件包，你可以在命令中使用 `CI_JOB_TOKEN` 来代替个人访问令牌。

例如：

```yaml
stages:
  - upload

upload:
  image: curlimages/curl:latest
  stage: upload
  script:
    - 'curl --fail-with-body --request POST --user gitlab-ci-token:$CI_JOB_TOKEN --form "chart=@mychart-0.1.0.tgz" "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/helm/api/<channel>/charts"'
```

- `<username>`：极狐GitLab 用户名或部署令牌用户名。
- `<access_token>`：个人访问令牌或部署令牌。
- `<channel>`：通道名称（如 `stable`）。

<a id="install-a-package"></a>

## 安装软件包

> [!note]
> 对于每个软件包，仅返回最新的软件包文件。

要安装 Chart 的最新版本，请使用以下命令：

```shell
helm repo add --username <username> --password <access_token> project-1 https://gitlab.example.com/api/v4/projects/<project_id>/packages/helm/<channel>
helm install my-release project-1/mychart
```

- `<username>`：极狐GitLab 用户名或部署令牌用户名。
- `<access_token>`：个人访问令牌或部署令牌。
- `<project_id>`：项目 ID（如 `42`）。
- `<channel>`：通道名称（如 `stable`）。

如果仓库先前已被添加，你可能需要运行：

```shell
helm repo update
```

以使用当前可用的 Chart 更新 Helm 客户端。

有关更多信息，请参阅[使用 Helm](https://helm.sh/docs/intro/using_helm/)。

<a id="delete-a-helm-package"></a>

## 删除 Helm 软件包

先决条件：

- 你必须具有维护者或所有者角色。

在删除软件包之前，请确保你了解[相关的安全风险](../package_registry/supported_functionality.md#deleting-packages)。

要删除软件包，你可以：

- [使用 UI](../package_registry/reduce_package_registry_storage.md#delete-a-package)。
- [使用 API](../../../api/packages.md#delete-a-project-package)。

<a id="troubleshooting"></a>

## 故障排除

<a id="the-chart-is-not-visible-in-the-package-registry-after-uploading"></a>

### 上传后 Chart 在软件包仓库中不可见

检查 [Sidekiq 日志](../../../administration/logs/_index.md#sidekiqlog) 中是否有任何相关错误。如果看到 `Validation failed: Version is invalid`，这意味着你的 `Chart.yaml` 文件中的版本不符合 [Helm Chart 版本规范](https://helm.sh/docs/topics/charts/#charts-and-versioning)。要修复此错误，请使用正确的版本语法并重新上传 Chart。

<a id="helm-push-results-in-an-error"></a>

### `helm push` 导致错误

Helm 3.7 为 `helm-push` 插件引入了重大更改。你可以更新 [Chart Museum 插件](https://github.com/chartmuseum/helm-push/#readme) 以使用 `helm cm-push`。