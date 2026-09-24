---
stage: Package
group: Package Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 软件包仓库中的 PyPI 软件包
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

Python Package Index (PyPI) 是 Python 官方第三方软件仓库。
使用极狐GitLab PyPI 软件包仓库，你可以在极狐GitLab 项目、群组和组织中发布和共享 Python 软件包。该集成使你能够与代码一起管理 Python 依赖项，为极狐GitLab 中的 Python 开发提供无缝工作流。

该软件包仓库支持：

- [pip](https://pypi.org/project/pip/)
- [twine](https://pypi.org/project/twine/)

有关 `pip` 和 `twine` 客户端使用的特定 API 端点的文档，请参阅 [PyPI API 文档](../../../api/packages/pypi.md)。

了解如何 [构建 PyPI 软件包](../workflows/build_packages.md#pypi)。

<a id="package-request-forwarding-security-notice"></a>

## 软件包请求转发安全通知

使用极狐GitLab PyPI 软件包仓库时，在极狐GitLab 仓库中找不到的软件包请求会自动转发到 `pypi.org`。即使使用 `--index-url` 标志，这也会导致从 `pypi.org` 下载软件包。

为确保私有软件包的最高安全性：

- 在群组设置中关闭软件包转发。
- 安装软件包时同时使用 [`--index-url` 和 `--no-index`](#security-implications) 标志。

先决条件：

- 你必须具有群组的 所有者 角色。

要关闭软件包请求转发：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的群组。
1. 在左侧边栏中，选择 **设置** > **软件包和镜像仓库**。
1. 在 **软件包转发** 下，清除 **转发 PyPI 软件包请求** 复选框。

有关如何在 **管理员** 区域关闭软件包转发的信息，请参阅 [控制软件包转发](../../../administration/settings/continuous_integration.md#control-package-forwarding)。

<a id="authenticate-with-the-gitlab-package-registry"></a>

## 向极狐GitLab 软件包仓库认证

在与极狐GitLab 软件包仓库交互之前，你必须先向其认证。

你可以使用以下方式进行认证：

- 一个 [个人访问令牌](../../profile/personal_access_tokens.md)，其作用域设置为 `api`。
- 一个 [部署令牌](../../project/deploy_tokens/_index.md)，其作用域设置为 `read_package_registry`、`write_package_registry` 或两者兼有。
- 一个 [CI/CD 作业令牌](../../../ci/jobs/ci_job_token.md)。

请勿使用本文档以外的方法进行认证。未记录的认证方法可能在将来被移除。

要使用极狐GitLab 令牌进行认证：

- 更新 `TWINE_USERNAME` 和 `TWINE_PASSWORD` 环境变量。

例如：

{{< tabs >}}

{{< tab title="使用个人访问令牌" >}}

```yaml
run:
  image: python:latest
  variables:
    TWINE_USERNAME: <personal_access_token_name>
    TWINE_PASSWORD: <personal_access_token>
  script:
    - pip install build twine
    - python -m build
    - python -m twine upload --repository-url ${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/pypi dist/*
```

{{< /tab >}}

{{< tab title="使用部署令牌" >}}

```yaml
run:
  image: python:latest
  variables:
    TWINE_USERNAME: <deploy_token_username>
    TWINE_PASSWORD: <deploy_token>
  script:
    - pip install build twine
    - python -m build
    - python -m twine upload --repository-url ${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/pypi dist/*
```

{{< /tab >}}

{{< tab title="使用 CI/CD 作业令牌" >}}

```yaml
run:
  image: python:latest
  variables:
    TWINE_USERNAME: gitlab-ci-token
    TWINE_PASSWORD: $CI_JOB_TOKEN
  script:
    - pip install build twine
    - python -m build
    - python -m twine upload --repository-url ${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/pypi dist/*
```

{{< /tab >}}

{{< /tabs >}}

<a id="authenticate-for-a-group"></a>

### 为群组进行认证

要为群组向软件包仓库认证：

- 向软件包仓库认证，但使用群组 URL 而不是项目 URL：

```shell
https://gitlab.example.com/api/v4/groups/<group_id>/-/packages/pypi
```

<a id="publish-a-pypi-package"></a>

## 发布 PyPI 软件包

你可以使用 twine 发布软件包。

先决条件：

- 你必须 [向软件包仓库认证](#authenticate-with-the-gitlab-package-registry)。
- 你的 [版本字符串必须有效](#use-valid-version-strings)。
- 软件包：
  - 大小不超过 5 GB。
  - `描述` 不超过 4000 个字符。更长的 `描述` 字符串会被截断。
  - 尚未发布到软件包仓库。尝试发布相同版本的软件包会返回 `400 Bad Request`。

PyPI 软件包使用你的项目 ID 发布。如果项目位于群组中，发布到项目仓库的 PyPI 软件包也会在群组仓库中可用。有关更多信息，请参阅 [从群组安装](#install-from-a-group)。

发布软件包：

1. 定义你的仓库源，编辑 `~/.pypirc` 文件并添加：

   ```ini
   [distutils]
   index-servers =
       gitlab

   [gitlab]
   repository = https://gitlab.example.com/api/v4/projects/<project_id>/packages/pypi
   ```

1. 使用 twine 上传你的软件包：

   ```shell
   python3 -m twine upload --repository gitlab dist/*
   ```

   软件包发布成功后，会显示如下消息：

   ```plaintext
   正在上传 distributions 至 https://gitlab.example.com/api/v4/projects/<project_id>/packages/pypi
   正在上传 mypypipackage-0.0.1-py3-none-any.whl
   100%|███████████████████████████████████████████████████████████████████████████████████████████| 4.58k/4.58k [00:00<00:00, 10.9kB/s]
   正在上传 mypypipackage-0.0.1.tar.gz
   100%|███████████████████████████████████████████████████████████████████████████████████████████| 4.24k/4.24k [00:00<00:00, 11.0kB/s]
   ```

软件包发布到软件包仓库，并显示在 **软件包和镜像仓库** 页面。

<a id="publish-with-inline-authentication"></a>

### 使用内联认证发布

如果你没有使用 `.pypirc` 文件定义仓库源，可以使用内联认证发布到仓库：

```shell
TWINE_PASSWORD=<personal_access_token、deploy_token 或 $CI_JOB_TOKEN> \
TWINE_USERNAME=<username、deploy_token_username 或 gitlab-ci-token> \
python3 -m twine upload --repository-url https://gitlab.example.com/api/v4/projects/<project_id>/packages/pypi dist/*
```

<a id="publishing-packages-with-the-same-name-and-version"></a>

### 发布同名同版本软件包

如果已存在同名同版本的软件包，则无法发布。你必须先 [删除现有软件包](../package_registry/reduce_package_registry_storage.md#delete-a-package)。
如果尝试多次发布同一个软件包，将发生 `400 Bad Request` 错误。

<a id="install-a-pypi-package"></a>

## 安装 PyPI 软件包

默认情况下，当在极狐GitLab 软件包仓库中找不到 PyPI 软件包时，请求会转发到 [pypi.org](https://pypi.org/)。有关如何防止请求转发的更多信息，请参阅 [软件包请求转发和安全通知](#package-request-forwarding-security-notice)。

此行为：

- 默认在所有极狐GitLab 实例上启用
- 可以在群组的 **软件包和镜像仓库** 设置中进行配置
- 即使在使用 `--index-url` 标志时也适用

管理员可以在 [持续集成设置](../../../administration/settings/continuous_integration.md#control-package-forwarding) 中全局禁用此行为。群组所有者可以在群组设置的 **软件包和镜像仓库** 部分为特定群组禁用此行为。

> [!note]
> 使用 `--index-url` 选项时，如果端口是默认端口，请不要指定端口。`http` URL 默认为 80，`https` URL 默认为 443。

<a id="install-from-a-project"></a>

### 从项目安装

要安装软件包的最新版本，请使用以下命令：

```shell
pip install --index-url https://<personal_access_token_name>:<personal_access_token>@gitlab.example.com/api/v4/projects/<project_id>/packages/pypi/simple --no-deps <package_name>
```

- `<package_name>` 是软件包名称。
- `<personal_access_token_name>` 是具有 `read_api` 作用域的个人访问令牌名称。
- `<personal_access_token>` 是具有 `read_api` 作用域的个人访问令牌。
- `<project_id>` 是项目的 [URL 编码](../../../api/rest/_index.md#namespaced-paths) 路径（例如 `group%2Fproject`）或项目 ID（例如 `42`）。

在这些命令中，你可以使用 `--extra-index-url` 替代 `--index-url`。如果你正在按照指南操作并想要安装 `MyPyPiPackage` 软件包，可以运行：

```shell
pip install mypypipackage --no-deps --index-url https://<personal_access_token_name>:<personal_access_token>@gitlab.example.com/api/v4/projects/<project_id>/packages/pypi/simple
```

此消息表示软件包安装成功：

```plaintext
Looking in indexes: https://<personal_access_token_name>:****@gitlab.example.com/api/v4/projects/<project_id>/packages/pypi/simple
Collecting mypypipackage
  Downloading https://gitlab.example.com/api/v4/projects/<project_id>/packages/pypi/files/d53334205552a355fee8ca35a164512ef7334f33d309e60240d57073ee4386e6/mypypipackage-0.0.1-py3-none-any.whl (1.6 kB)
Installing collected packages: mypypipackage
Successfully installed mypypipackage-0.0.1
```

<a id="install-from-a-group"></a>

### 从群组安装

要从群组安装软件包的最新版本，请使用以下命令：

```shell
pip install --index-url https://<personal_access_token_name>:<personal_access_token>@gitlab.example.com/api/v4/groups/<group_id>/-/packages/pypi/simple --no-deps <package_name>
```

在此命令中：

- `<package_name>` 是软件包名称。
- `<personal_access_token_name>` 是具有 `read_api` 作用域的个人访问令牌名称。
- `<personal_access_token>` 是具有 `read_api` 作用域的个人访问令牌。
- `<group_id>` 是群组 ID。

在这些命令中，你可以使用 `--extra-index-url` 替代 `--index-url`。
如果你按照指南操作并想要安装 `MyPyPiPackage` 软件包，可以运行：

```shell
pip install mypypipackage --no-deps --index-url https://<personal_access_token_name>:<personal_access_token>@gitlab.example.com/api/v4/groups/<group_id>/-/packages/pypi/simple
```

<a id="package-names"></a>

### 软件包名称

极狐GitLab 查找使用 [Python 标准化名称 (PEP-503)](https://www.python.org/dev/peps/pep-0503/#normalized-names) 的软件包。字符 `-`、`_` 和 `.` 都被同等对待，重复字符会被移除。

对 `my.package` 的 `pip install` 请求会查找与这三种字符匹配的软件包，例如 `my-package`、`my_package` 和 `my....package`。

<a id="security-implications"></a>

### 安全影响

安装 PyPI 软件包时使用 `--extra-index-url` 与 `--index-url` 的安全影响非常重要，值得详细了解：

- `--index-url`：此选项将默认的 PyPI 索引 URL 替换为指定的 URL。极狐GitLab 软件包转发设置（默认开启）可能仍然从 PyPI 下载在软件包仓库中找不到的软件包。为确保仅从极狐GitLab 安装软件包，可以：
  - 在群组设置中禁用软件包转发
  - 同时使用 `--index-url` 和 `--no-index` 标志
- `--extra-index-url`：此选项添加一个额外的索引进行搜索，与默认的 PyPI 索引并列。
  它安全性较低，更容易受到依赖混淆攻击，因为它会同时检查默认 PyPI 和附加索引来查找软件包。

使用私有软件包时，请牢记以下最佳实践：

- 检查群组的软件包转发设置。
- 安装私有软件包时同时使用 `--no-index` 和 `--index-url` 标志。
- 定期使用 `pip debug` 审计你的软件包源。

<a id="delete-a-pypi-package"></a>

## 删除 PyPI 软件包

先决条件：

- 你必须具有 维护者 或 所有者 角色。

在删除软件包之前，请确保你了解 [相关的安全风险](../package_registry/supported_functionality.md#deleting-packages)。

要删除软件包，你可以：

- [使用 UI](../package_registry/reduce_package_registry_storage.md#delete-a-package)。
- [使用 API](../../../api/packages.md#delete-a-project-package)。

<a id="install-a-private-pypi-package-in-a-cicd-pipeline"></a>

## 在 CI/CD 流水线中安装私有 PyPI 软件包

你可以使用 [CI/CD 作业令牌](../../../ci/jobs/ci_job_token.md) 在 CI/CD 流水线中安装私有 PyPI 软件包。作业令牌会自动认证，并且还可以访问同一顶级群组内其他项目中的软件包。

先决条件：

- 如果软件包位于不同的项目中，该项目必须允许你的项目的作业令牌。有关更多信息，请参阅 [控制作业令牌访问](../../../ci/jobs/ci_job_token.md#control-job-token-access-to-your-project)。
- 使用 CI/CD 作业令牌认证时，用户名必须是 `gitlab-ci-token`。

<a id="use-inline-credentials"></a>

### 使用内联凭据

直接在 `pip install` 命令中传递 `CI_JOB_TOKEN`：

{{< tabs >}}

{{< tab title="从项目" >}}

```yaml
install:
  image: python:latest
  script:
    - pip install <package_name> --index-url https://gitlab-ci-token:${CI_JOB_TOKEN}@gitlab.example.com/api/v4/projects/<project_id>/packages/pypi/simple
```

{{< /tab >}}

{{< tab title="从群组" >}}

要从包含群组内所有项目软件包的群组索引安装：

```yaml
install:
  image: python:latest
  script:
    - pip install <package_name> --index-url https://gitlab-ci-token:${CI_JOB_TOKEN}@gitlab.example.com/api/v4/groups/<group_id>/-/packages/pypi/simple
```

{{< /tab >}}

{{< /tabs >}}

<a id="use-a-netrc-file-for-cicd"></a>

### 使用 `.netrc` 文件进行 CI/CD

`.netrc` 可使你的 `requirements.txt` 免于包含凭据，因此同一文件在本地和 CI/CD 流水线中均可使用。pip 会自动读取 `.netrc` 文件以查找给定主机名的凭据。有关更多信息，请参阅 [.netrc support](https://pip.pypa.io/en/stable/topics/authentication/#netrc-support)。

在你的 `.gitlab-ci.yml` 中，在 `before_script` 中创建 `.netrc` 文件：

```yaml
install:
  image: python:latest
  before_script:
    - |
      echo "machine gitlab.example.com
      login gitlab-ci-token
      password ${CI_JOB_TOKEN}" > ~/.netrc
  script:
    - pip install -r requirements.txt
```

你的 `requirements.txt` 引用极狐GitLab 仓库时不包含凭据：

```plaintext
--extra-index-url https://gitlab.example.com/api/v4/projects/<project_id>/packages/pypi/simple
package-name==1.0.0
```

对于本地开发，创建一个 `~/.netrc` 文件，使用具有 `api` 作用域的 [个人访问令牌](../../profile/personal_access_tokens.md)：

```plaintext
machine gitlab.example.com
login <personal_access_token_name>
password <personal_access_token>
```

> [!note]
> `.netrc` 文件为每个主机名配置一组凭据。如果你必须对多个极狐GitLab 实例上的软件包进行认证，请为每个主机名添加单独的 `machine` 条目。

<a id="install-private-packages-during-a-docker-build"></a>

### 在 Docker 构建期间安装私有软件包

构建需要私有 PyPI 软件包的 Docker 镜像时，将 `CI_JOB_TOKEN` 作为构建参数传递：

```yaml
build:
  image: docker:latest
  services:
    - docker:dind
  script:
    - docker build --build-arg CI_JOB_TOKEN=$CI_JOB_TOKEN -t my-image .
```

在你的 `Dockerfile` 中，使用该令牌向仓库认证：

```dockerfile
ARG CI_JOB_TOKEN
RUN pip install <package_name> --index-url https://gitlab-ci-token:${CI_JOB_TOKEN}@gitlab.example.com/api/v4/projects/<project_id>/packages/pypi/simple
```

> [!note]
> 构建参数可能在镜像历史中可见。对于生产镜像，使用 [多阶段构建](https://docs.docker.com/build/building/multi-stage/) 以防止令牌出现在最终镜像层中。

<a id="using-requirements-txt"></a>

## 使用 `requirements.txt`

如果你希望 pip 访问你的公开仓库，请将 `--extra-index-url` 参数以及仓库的 URL 添加到你的 `requirements.txt` 文件中。

```plaintext
--extra-index-url https://gitlab.example.com/api/v4/projects/<project_id>/packages/pypi/simple
package-name==1.0.0
```

如果这是私有仓库，你可以通过几种方式进行认证。例如：

- 使用你的 `requirements.txt` 文件搭配 [个人访问令牌](../../profile/personal_access_tokens.md)：

  ```plaintext
  --extra-index-url https://<personal_access_token_name>:<personal_access_token>@gitlab.example.com/api/v4/projects/<project_id>/packages/pypi/simple
  package-name==1.0.0
  ```

- 使用 `~/.netrc` 文件搭配 [个人访问令牌](../../profile/personal_access_tokens.md)：

  ```plaintext
  machine gitlab.example.com
  login <personal_access_token_name>
  password <personal_access_token>
  ```

<a id="versioning-pypi-packages"></a>

## PyPI 软件包版本控制

正确的版本控制对于有效管理 PyPI 软件包非常重要。遵循以下最佳实践来确保你的软件包正确版本化。

<a id="use-semantic-versioning-semver"></a>

### 使用语义化版本控制 (SemVer)

为你的软件包采用语义化版本控制。版本号应采用 `MAJOR.MINOR.PATCH` 格式：

- 当进行不兼容的 API 更改时，递增 `MAJOR` 版本。
- 当添加向后兼容的新功能时，递增 `MINOR` 版本。
- 当进行向后兼容的 Bug 修复时，递增 `PATCH` 版本。

例如：1.0.0、1.1.0、1.1.1。

对于新项目，从版本 0.1.0 开始。这表示 API 尚不稳定的初始开发阶段。

<a id="use-valid-version-strings"></a>

### 使用有效的版本字符串

确保你的版本字符串符合 PyPI 标准。极狐GitLab 使用特定的正则表达式来验证版本字符串：

```ruby
\A(?:
    v?
    (?:([0-9]+)!)?                                                 (?# epoch)
    ([0-9]+(?:\.[0-9]+)*)                                          (?# release segment)
    ([-_\.]?((a|b|c|rc|alpha|beta|pre|preview))[-_\.]?([0-9]+)?)?  (?# pre-release)
    ((?:-([0-9]+))|(?:[-_\.]?(post|rev|r)[-_\.]?([0-9]+)?))?       (?# post release)
    ([-_\.]?(dev)[-_\.]?([0-9]+)?)?                                (?# dev release)
    (?:\+([a-z0-9]+(?:[-_\.][a-z0-9]+)*))?                         (?# local version)
)\z}xi
```

你可以使用此 [正则表达式编辑器](https://rubular.com/r/FKM6d07ouoDaFV) 试验该正则表达式并测试你的版本字符串。

有关正则表达式的更多详细信息，请参阅 [Python 文档](https://www.python.org/dev/peps/pep-0440/#appendix-b-parsing-version-strings-with-regular-expressions)。

<a id="supported-cli-commands"></a>

## 支持的 CLI 命令

极狐GitLab PyPI 仓库支持以下 CLI 命令：

- `twine upload`：将软件包上传到仓库。
- `pip install`：从仓库安装 PyPI 软件包。

<a id="troubleshooting"></a>

## 故障排除

为提高性能，pip 命令会缓存与软件包相关的文件。pip 本身不会删除数据。随着新软件包的安装，缓存会增长。如果遇到问题，请使用以下命令清除缓存：

```shell
pip cache purge
```

<a id="multiple-index-url-or-extra-index-url-parameters"></a>

### 多个 `index-url` 或 `extra-index-url` 参数

你可以定义多个 `index-url` 和 `extra-index-url` 参数。

如果你多次使用相同的域名（例如 `gitlab.example.com`）但使用不同的认证令牌，`pip` 可能无法找到你的软件包。此问题是由于在命令执行期间 `pip` [注册和存储你的令牌](https://github.com/pypa/pip/pull/10904#issuecomment-1126690115) 的方式导致的。

要解决此问题，你可以从所有 `index-url` 和 `extra-index-url` 值所覆盖的项目或群组的共同父级群组中，使用具有 `read_package_registry` 作用域的 [群组部署令牌](../../project/deploy_tokens/_index.md)。

<a id="unexpected-package-sources"></a>

### 意外的软件包源

如果在你打算仅使用极狐GitLab 仓库时却从 PyPI 安装了软件包：

- 检查群组的软件包转发设置。
- 同时使用 `--no-index` 和 `--index-url` 标志以防止回退到 PyPI。
- 定期使用 `pip debug` 审计你的软件包源。