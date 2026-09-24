---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 了解如何在专用 CI/CD 构建服务器或本地机器上托管的 Docker 容器中运行您的 CI/CD 作业。
title: 在 Docker 容器中运行您的 CI/CD 作业
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以在专用 CI/CD 构建服务器或本地机器上托管的 Docker 容器中运行您的 CI/CD 作业。

要在 Docker 容器中运行 CI/CD 作业，您需要：

1. 注册一个 Runner 并将其配置为使用 [Docker 执行器](https://gitlab.cn/docs/runner/executors/docker/)。
1. 在 `.gitlab-ci.yml` 文件中指定要运行 CI/CD 作业的容器镜像。
1. 可选。在容器中运行其他服务，如 MySQL。通过在您的 `.gitlab-ci.yml` 文件中指定 [服务](../services/_index.md) 来实现。

<a id="register-a-runner-that-uses-the-docker-executor"></a>

## 注册使用 Docker 执行器的 Runner

要将 极狐GitLab Runner 与 Docker 一起使用，您需要 [注册一个 Runner](https://gitlab.cn/docs/runner/register/)，该 Runner 使用 Docker 执行器。

以下示例展示了如何设置临时模板来提供服务：

```shell
cat > /tmp/test-config.template.toml << EOF
[[runners]]
[runners.docker]
[[runners.docker.services]]
name = "postgres:latest"
[[runners.docker.services]]
name = "mysql:latest"
EOF
```

然后使用此模板注册 Runner：

```shell
sudo gitlab-runner register \
  --url "https://gitlab.example.com/" \
  --token "$RUNNER_TOKEN" \
  --description "docker-ruby:2.6" \
  --executor "docker" \
  --template-config /tmp/test-config.template.toml \
  --docker-image ruby:3.3
```

注册的 Runner 使用 `ruby:2.6` Docker 镜像并运行两个服务，`postgres:latest` 和 `mysql:latest`，这两个服务在构建过程中均可访问。

<a id="what-is-an-image"></a>

## 什么是镜像

`image` 关键字是 Docker 执行器用来运行 CI/CD 作业的 Docker 镜像的名称。

默认情况下，执行器从 [Docker Hub](https://hub.docker.com/) 拉取镜像。但是，您可以在 `gitlab-runner/config.toml` 文件中配置镜像仓库位置。例如，您可以设置 [Docker 拉取策略](https://gitlab.cn/docs/runner/executors/docker/#how-pull-policies-work) 以使用本地镜像。

有关镜像和 Docker Hub 的更多信息，请参阅 [Docker 概述](https://docs.docker.com/get-started/overview/)。

<a id="image-requirements"></a>

## 镜像要求

用于运行 CI/CD 作业的任何镜像都必须安装以下应用程序：

- `sh` 或 `bash`
- `grep`

<a id="define-image-in-the-gitlab-ci-yml-file"></a>

## 在 `.gitlab-ci.yml` 文件中定义 `image`

您可以定义一个用于所有作业的镜像，以及一个您希望在运行时使用的服务列表：

```yaml
default:
  image: ruby:2.6
  services:
    - postgres:16.10
  before_script:
    - bundle install

test:
  script:
    - bundle exec rake spec
```

镜像名称必须采用以下格式之一：

- `image: <image-name>`（等同于使用带有 `latest` 标签的 `<image-name>`）
- `image: <image-name>:<tag>`
- `image: <image-name>@<digest>`

<a id="extended-docker-configuration-options"></a>

## 扩展的 Docker 配置选项

{{< history >}}

- 在 极狐GitLab 和 极狐GitLab Runner 9.4 中引入。

{{< /history >}}

您可以为 `image` 或 `services` 条目使用字符串或映射：

- 字符串必须包含完整的镜像名称（如果您想从 Docker Hub 以外的镜像仓库下载镜像，则包括镜像仓库地址）。
- 映射必须至少包含 `name` 选项，这与字符串设置中使用的镜像名称相同。

例如，以下两个定义是等效的：

- 使用字符串表示 `image` 和 `services`：

  ```yaml
  image: "registry.example.com/my/image:latest"

  services:
    - postgresql:16.10
    - redis:latest
  ```

- 使用映射表示 `image` 和 `services`。`image:name` 是必需的：

  ```yaml
  image:
    name: "registry.example.com/my/image:latest"

  services:
    - name: postgresql:16.10
    - name: redis:latest
  ```

<a id="where-scripts-are-executed"></a>

## 脚本执行的位置

当 CI 作业在 Docker 容器中运行时，`before_script`、`script` 和 `after_script` 命令在 `/builds/<project-path>/` 目录中运行。您的镜像可能定义了不同的默认 `WORKDIR`。要切换到您的 `WORKDIR`，请将 `WORKDIR` 保存为环境变量，以便在作业运行时可以在容器中引用它。

<a id="override-the-entrypoint-of-an-image"></a>

### 覆盖镜像的入口点

{{< history >}}

- 在 极狐GitLab 和 极狐GitLab Runner 9.4 中引入。了解更多关于 [扩展的配置选项](using_docker_images.md#extended-docker-configuration-options) 的信息。

{{< /history >}}

在解释可用的入口点覆盖方法之前，我们先描述一下 Runner 的启动方式。它为 CI/CD 作业中使用的容器使用 Docker 镜像：

1. Runner 使用定义的入口点启动一个 Docker 容器。该入口点可能来自 `Dockerfile` 的默认设置，并可在 `.gitlab-ci.yml` 文件中覆盖。
1. Runner 将自己附加到正在运行的容器上。
1. Runner 准备一个脚本（由 [`before_script`](../yaml/_index.md#before_script)、[`script`](../yaml/_index.md#script) 和 [`after_script`](../yaml/_index.md#after_script) 组合而成）。
1. Runner 将脚本发送到容器的 shell `stdin` 并接收输出。

要在 `.gitlab-ci.yml` 文件中覆盖 Docker 镜像的 [入口点](https://gitlab.cn/docs/runner/executors/docker/#configure-a-docker-entrypoint)：

- 对于 Docker 17.06 及更高版本，将 `entrypoint` 设置为空值。
- 对于 Docker 17.03 及更早版本，将 `entrypoint` 设置为 `/bin/sh -c`、`/bin/bash -c` 或镜像中可用的等效 shell。

`image:entrypoint` 的语法类似于 [Dockerfile `ENTRYPOINT`](https://docs.docker.com/reference/dockerfile/#entrypoint)。

假设您有一个包含 SQL 数据库的 `super/sql:experimental` 镜像。您想将其用作作业的基础镜像，因为您想使用此数据库二进制文件执行一些测试。我们还假设此镜像配置了 `/usr/bin/super-sql run` 作为入口点。当容器在没有额外选项的情况下启动时，它会运行数据库进程。Runner 期望镜像没有入口点，或者入口点已准备好启动 shell 命令。

使用扩展的 Docker 配置选项，您无需：

- 基于 `super/sql:experimental` 创建自己的镜像。
- 将 `ENTRYPOINT` 设置为 shell。
- 在您的 CI 作业中使用新镜像。

您现在可以在 `.gitlab-ci.yml` 文件中定义一个 `entrypoint`。

**对于 Docker 17.06 及更高版本**：

```yaml
image:
  name: super/sql:experimental
  entrypoint: [""]
```

**对于 Docker 17.03 及更早版本**：

```yaml
image:
  name: super/sql:experimental
  entrypoint: ["/bin/sh", "-c"]
```

<a id="define-image-and-services-in-config-toml"></a>

## 在 `config.toml` 中定义镜像和服务

在 `config.toml` 文件中，您可以定义：

- 在 [`[runners.docker]`](https://gitlab.cn/docs/runner/configuration/advanced-configuration#the-runnersdocker-section) 部分中，用于运行 CI/CD 作业的容器镜像
- 在 [`[[runners.docker.services]]`](https://gitlab.cn/docs/runner/configuration/advanced-configuration#the-runnersdockerservices-section) 部分中，[服务](../services/_index.md) 容器

```toml
[runners.docker]
  image = "ruby:latest"
  services = ["mysql:latest", "postgres:latest"]
```

以这种方式定义的镜像和服务将添加到该 Runner 运行的所有作业中。

<a id="access-an-image-from-a-private-container-registry"></a>

## 从私有容器镜像仓库访问镜像

要访问私有容器镜像仓库，极狐GitLab Runner 进程可以使用：

- [静态定义的凭据](#使用静态定义的凭据)。特定镜像仓库的用户名和密码。
- [凭据存储](#使用凭据存储)。有关更多信息，请参阅 [相关的 Docker 文档](https://docs.docker.com/reference/cli/docker/login/#credential-stores)。
- [凭据助手](#使用凭据助手)。有关更多信息，请参阅 [相关的 Docker 文档](https://docs.docker.com/reference/cli/docker/login/#credential-helpers)。

当您在同一 极狐GitLab 实例上使用 [极狐GitLab 容器镜像仓库](../../user/packages/container_registry/_index.md) 时，极狐GitLab 会为此镜像仓库提供默认凭据。使用这些凭据时，将使用 `CI_JOB_TOKEN` 进行身份验证。要使用作业令牌，启动作业的用户必须对托管私有镜像的项目具有开发者、维护者或所有者角色。托管私有镜像的项目还必须允许其他项目使用作业令牌进行身份验证。此访问权限默认处于禁用状态。有关更多详细信息，请参阅 [CI/CD 作业令牌](../jobs/ci_job_token.md#control-job-token-access-to-your-project)。

要定义应使用哪个选项，Runner 进程按以下顺序读取配置：

- `/root/.docker` 目录中的 `config.json` 文件。
- `DOCKER_AUTH_CONFIG` [CI/CD 变量](../variables/_index.md)。
- 在 Runner 的 `config.toml` 文件中设置的 `DOCKER_AUTH_CONFIG` 环境变量。
- 运行进程的用户的主目录 `$HOME/.docker` 中的 `config.json` 文件。如果提供了 `--user` 标志以非特权用户身份运行子进程，则使用主 Runner 进程用户的主目录。

<a id="requirements-and-limitations"></a>

### 要求和限制

- [凭据存储](#使用凭据存储) 和 [凭据助手](#使用凭据助手) 需要将二进制文件添加到 极狐GitLab Runner 的 `$PATH` 中，并且需要相应的访问权限。因此，这些功能在实例 Runner 或用户无法访问 Runner 安装环境的任何其他 Runner 上不可用。

<a id="use-statically-defined-credentials"></a>

### 使用静态定义的凭据

您可以使用两种方法访问私有镜像仓库。这两种方法都需要使用适当的身份验证信息设置 CI/CD 变量 `DOCKER_AUTH_CONFIG`。

1. 按作业：要配置一个作业以访问私有镜像仓库，请将 `DOCKER_AUTH_CONFIG` 添加为 [CI/CD 变量](../variables/_index.md)。
1. 按 Runner：要配置一个 Runner，使其所有作业都可以访问私有镜像仓库，请将 `DOCKER_AUTH_CONFIG` 添加为 Runner 配置中的环境变量。

有关每种方法的示例，请参阅以下部分。

<a id="determine-your-docker-auth-config-data"></a>

#### 确定您的 `DOCKER_AUTH_CONFIG` 数据

例如，假设您要使用 `registry.example.com:5000/private/image:latest` 镜像。此镜像是私有的，需要您登录到私有容器镜像仓库。

我们还假设以下是登录凭据：

| 键 | 值 |
|:---------|:------|
| registry | `registry.example.com:5000` |
| username | `my_username` |
| password | `my_password` |

使用以下方法之一确定 `DOCKER_AUTH_CONFIG` 的值：

- 在您的本地机器上执行 `docker login`：

  ```shell
  docker login registry.example.com:5000 --username my_username --password my_password
  ```

  然后复制 `~/.docker/config.json` 的内容。

  如果您不需要从计算机访问镜像仓库，可以执行 `docker logout`：

  ```shell
  docker logout registry.example.com:5000
  ```

- 在某些设置中，Docker 客户端可能使用可用的系统密钥存储来存储 `docker login` 的结果。在这种情况下，无法读取 `~/.docker/config.json`，因此您必须准备所需的 base64 编码版本的 `${username}:${password}` 并手动创建 Docker 配置 JSON。打开终端并执行以下命令：

  ```shell
  # 使用 printf（而不是 echo）可防止在密码中编码换行符。
  printf "my_username:my_password" | openssl base64 -A

  # 要复制的示例输出
  bXlfdXNlcm5hbWU6bXlfcGFzc3dvcmQ=
  ```

  > [!note]
  > 如果您的用户名包含特殊字符，如 `@`，则必须使用反斜杠 (` \ `) 对其进行转义，以防止身份验证问题。

  按如下方式创建 Docker JSON 配置内容：

  ```json
  {
      "auths": {
          "registry.example.com:5000": {
              "auth": "(上面的 Base64 内容)"
          }
      }
  }
  ```

<a id="configure-a-job"></a>

#### 配置作业

要配置单个作业以访问 `registry.example.com:5000`，请按照以下步骤操作：

1. 创建一个 [CI/CD 变量](../variables/_index.md) `DOCKER_AUTH_CONFIG`，其值为 Docker 配置文件的内容：

   ```json
   {
       "auths": {
           "registry.example.com:5000": {
               "auth": "bXlfdXNlcm5hbWU6bXlfcGFzc3dvcmQ="
           }
       }
   }
   ```

1. 您现在可以在 `.gitlab-ci.yml` 文件的 `image` 或 `services` 中使用来自 `registry.example.com:5000` 的任何私有镜像：

   ```yaml
   image: registry.example.com:5000/namespace/image:tag
   ```

   在前面的示例中，极狐GitLab Runner 会在 `registry.example.com:5000` 中查找镜像 `namespace/image:tag`。

您可以根据需要添加任意数量的镜像仓库配置，只需像前面描述的那样向 `"auths"` 哈希中添加更多镜像仓库即可。

Runner 要匹配 `DOCKER_AUTH_CONFIG`，必须在所有地方使用完整的 `hostname:port` 组合。例如，如果在 `.gitlab-ci.yml` 文件中指定了 `registry.example.com:5000/namespace/image:tag`，则 `DOCKER_AUTH_CONFIG` 也必须指定 `registry.example.com:5000`。仅指定 `registry.example.com` 是无效的。

<a id="configuring-a-runner"></a>

### 配置 Runner

如果您有许多流水线访问同一个镜像仓库，则应在 Runner 级别设置镜像仓库访问权限。这允许流水线作者只需在适当的 Runner 上运行作业即可访问私有镜像仓库。这也有助于简化镜像仓库更改和凭据轮换。

这意味着该 Runner 上的任何作业都可以以相同的权限访问镜像仓库，即使是跨项目也是如此。如果您需要控制对镜像仓库的访问，则需要确保控制对 Runner 的访问。

要将 `DOCKER_AUTH_CONFIG` 添加到 Runner：

1. 按如下方式修改 Runner 的 `config.toml` 文件：

   ```toml
   [[runners]]
     environment = ["DOCKER_AUTH_CONFIG={\"auths\":{\"registry.example.com:5000\":{\"auth\":\"bXlfdXNlcm5hbWU6bXlfcGFzc3dvcmQ=\"}}}"]
   ```

   - `DOCKER_AUTH_CONFIG` 数据中包含的双引号必须使用反斜杠进行转义。这可以防止它们被解释为 TOML。
   - `environment` 选项是一个列表。您的 Runner 可能已有现有条目，您应该将此条目添加到列表中，而不是替换它。

1. 重新启动 Runner 服务。

<a id="use-a-credentials-store"></a>

### 使用凭据存储

要配置凭据存储：

1. 要使用凭据存储，您需要一个外部帮助程序来与特定的密钥链或外部存储进行交互。确保帮助程序二进制文件在 极狐GitLab Runner 的 `$PATH` 中可用。

1. 使 极狐GitLab Runner 使用它。您可以通过以下选项之一来实现：

   - 创建一个 [CI/CD 变量](../variables/_index.md) `DOCKER_AUTH_CONFIG`，其值为 Docker 配置文件的内容：

     ```json
       {
         "credsStore": "osxkeychain"
       }
     ```

   - 或者，如果您运行的是私有化部署 Runner，请将 JSON 添加到 `${GITLAB_RUNNER_HOME}/.docker/config.json`。极狐GitLab Runner 会读取此配置文件，并为此特定仓库使用所需的帮助程序。

`credsStore` 用于访问**所有**镜像仓库。如果您同时使用来自私有镜像仓库的镜像和来自 Docker Hub 的公共镜像，则从 Docker Hub 拉取会失败。Docker 守护程序会尝试对所有镜像仓库使用相同的凭据。

<a id="use-checksum-to-keep-your-image-secure"></a>

### 使用校验和确保镜像安全

在 `.gitlab-ci.yml` 文件的作业定义中使用镜像校验和来验证镜像的完整性。镜像完整性验证失败可防止您使用被修改的容器。

要使用镜像校验和，您必须在末尾附加校验和：

```yaml
image: ruby:2.6.8@sha256:d1dbaf9665fe8b2175198e49438092fdbcf4d8934200942b94425301b17853c7
```

要获取镜像校验和，请在镜像的 `TAG` 选项卡上查看 `DIGEST` 列。例如，查看 [Ruby 镜像](https://hub.docker.com/_/ruby?tab=tags)。校验和是一个随机字符串，如 `6155f0235e95`。

您也可以使用命令 `docker images --digests` 获取系统上任何镜像的校验和：

```shell
❯ docker images --digests
REPOSITORY                                                        TAG       DIGEST                                                                    (...)
registry.gitlab.cn/omnibus/gitlab-jh                              latest    sha256:31e25acb08324d847a50111855f25b5ddc77daa9cadc00152f4fd4065b03e378   (...)
registry.gitlab.cn/jihulab/gitlab-runner                          latest    sha256:e579aad9c392fb70fc7ac1327c1584ee5e4ee2df531fe35d30755d9ee061c0ae   (...)
```