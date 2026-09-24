---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 服务
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

配置 CI/CD 时，您需要指定一个用于创建作业运行容器的镜像。要指定此镜像，请使用 `image` 关键字。

您还可以使用 `services` 关键字指定额外的镜像。此额外镜像用于创建另一个容器，该容器可用于第一个容器。这两个容器可以相互访问，并在运行作业时进行通信。

服务镜像可以运行任何应用程序，但最常见的用例是运行数据库容器，例如：

- [MySQL](mysql.md)
- [PostgreSQL](postgres.md)
- [Redis](redis.md)
- [极狐GitLab](gitlab.md) 作为提供 JSON API 的微服务示例

> [!warning]
> 要启用服务间网络，请将 `FF_NETWORK_PER_BUILD` 设置为 `true`。
> 如果没有此功能标志，服务可能无法正常工作。更多信息，请参见
> [功能标志](https://gitlab.cn/docs/runner/configuration/feature-flags)

假设您正在开发一个使用数据库进行存储的内容管理系统。您需要一个数据库来测试应用程序中的所有功能。在此场景中，将数据库容器作为服务运行是一个很好的用例。

使用现有镜像并将其作为附加容器运行，而不是每次构建项目时都安装 `mysql`。

您不仅限于数据库服务。您可以向 `.gitlab-ci.yml` 添加所需任意数量的服务，或手动修改 [`config.toml`](https://gitlab.cn/docs/runner/configuration/advanced-configuration/)。在 [Docker Hub](https://hub.docker.com/) 或您的私有容器镜像仓库中找到的任何镜像都可以用作服务。

有关使用私有镜像的信息，请参见[从私有容器镜像仓库访问镜像](../docker/using_docker_images.md#access-an-image-from-a-private-container-registry)。

服务继承与 CI 容器本身相同的 DNS 服务器、搜索域和额外主机。

<a id="how-services-are-linked-to-the-job"></a>

## 服务如何与作业关联

为了更好地理解容器链接的工作原理，请阅读[连接容器](https://docs.docker.com/network/links/)。

如果向应用程序添加 `mysql` 作为服务，则使用该镜像创建一个链接到作业容器的容器。

MySQL 服务容器的主机名为 `mysql`。要访问数据库服务，请连接到名为 `mysql` 的主机，而不是套接字或 `localhost`。更多信息请参见[访问服务](#accessing-the-services)。

<a id="how-the-health-check-of-services-works"></a>

## 服务健康检查的工作原理

服务旨在提供**网络可访问**的附加功能。它们可以是像 MySQL 或 Redis 这样的数据库，甚至可以是允许使用 DinD（Docker-in-Docker）的 `docker:dind`。它几乎可以是 CI/CD 作业继续执行所需的任何东西，并且通过网络访问。

为确保此功能有效，Runner 会：

1. 检查容器默认暴露哪些端口。
1. 启动一个等待这些端口可访问的特殊容器。

如果检查的第二阶段失败，则会输出警告：`*** WARNING：Service XYZ probably didn't start properly`。此问题可能由以下原因引起：

- 服务中没有开放端口。
- 服务在超时前未正确启动，且端口无响应。

多数情况下，这会影响作业，但也可能作业仍会成功，即使打印了该警告。例如：

- 服务在警告发出后不久启动，而作业并非从一开始就使用链接的服务。这种情况下，当作业需要访问服务时，它可能已经在等待连接了。
- 服务容器不提供任何网络服务，但它在处理作业的目录（所有服务都将作业目录作为卷挂载在 `/builds` 下）。在这种情况下，服务完成了它的工作，而作业没有尝试连接它，因此不会失败。

如果服务成功启动，它们会在 [`before_script`](../yaml/_index.md#before_script) 运行之前启动。这意味着您可以编写一个查询服务的 `before_script`。

服务在作业结束时停止，即使作业失败也是如此。

<a id="using-software-provided-by-a-service-image"></a>

## 使用服务镜像提供的软件

当您指定 `service` 时，它提供**网络可访问**的服务。数据库是此类服务最简单的例子。

服务功能不会将已定义的 `services` 镜像中的任何软件添加到作业的容器中。

例如，如果您在作业中定义了以下 `services`，那么 `php`、`node` 或 `go` 命令**不能**用于您的脚本，作业会失败：

```yaml
job:
  services:
    - php:8.4
    - node:latest
    - golang:1.25
  image: alpine:3.23
  script:
    - php -v
    - node -v
    - go version
```

如果您需要在脚本中使用 `php`、`node` 和 `go`，您应该：

- 选择包含所有必需工具的现有 Docker 镜像。
- 创建您自己的 Docker 镜像，包含所有必需工具，并在作业中使用它。

<a id="define-services-in-the-gitlab-ci-yml-file"></a>

## 在 `.gitlab-ci.yml` 文件中定义 `services`

也可以按作业定义不同的镜像和服务：

```yaml
default:
  before_script:
    - bundle install

test:4.0:
  image: ruby:4.0
  services:
    - postgres:18
  script:
    - bundle exec rake spec

test:3.4:
  image: ruby:3.4
  services:
    - postgres:17
  script:
    - bundle exec rake spec
```

或者您可以为 `image` 和 `services` 传递一些[扩展配置选项](../docker/using_docker_images.md#extended-docker-configuration-options)：

```yaml
default:
  image:
    name: ruby:4.0
    entrypoint: ["/bin/bash"]
  services:
    - name: my-postgres:18
      alias: db,postgres,pg
      entrypoint: ["/usr/local/bin/db-postgres"]
      command: ["start"]
  before_script:
    - bundle install

test:
  script:
    - bundle exec rake spec
```

<a id="accessing-the-services"></a>

## 访问服务

如果您未[指定服务别名](#available-settings-for-services)，则可以通过构建容器中的两个主机名来访问服务：

- `namespace-projectname`
- `namespace__projectname`

带下划线的主机名不符合 RFC 规范，可能会导致第三方应用程序出现问题。

服务主机名的默认别名基于其镜像名称按以下规则创建：

- 冒号 (`:`) 之后的所有内容都将被去掉。
- 斜杠 (`/`) 替换为双下划线 (`__`)，并创建主别名。
- 斜杠 (`/`) 替换为单破折号 (`-`)，并创建辅助别名。

要覆盖默认行为，您可以[指定一个或多个服务别名](#available-settings-for-services)。

<a id="connecting-services"></a>

### 连接服务

您可以将相互依赖的服务用于复杂的作业，如端到端测试，其中外部 API 需要与其自己的数据库通信。

例如，对于使用 API 且 API 需要数据库的前端应用端到端测试：

```yaml
end-to-end-tests:
  image: node:latest
  services:
    - name: selenium/standalone-firefox:${FIREFOX_VERSION}
      alias: firefox
    - name: registry.gitlab.com/organization/private-api:latest
      alias: backend-api
    - name: postgres:18
      alias: db postgres db
  variables:
    FF_NETWORK_PER_BUILD: 1 # 激活容器间网络
    POSTGRES_PASSWORD: supersecretpassword
    BACKEND_POSTGRES_HOST: postgres
  script:
    - npm install
    - npm test
```

要使此方案有效，您必须使用[为每个作业创建新网络的网络模式](https://gitlab.cn/docs/runner/executors/docker/#create-a-network-for-each-job)。

<a id="passing-cicd-variables-to-services"></a>

## 将 CI/CD 变量传递给服务

您还可以直接在 `.gitlab-ci.yml` 文件中传递自定义 CI/CD [变量](../variables/_index.md) 以微调您的 Docker `images` 和 `services`。更多信息，请阅读 [`.gitlab-ci.yml` 定义的变量](../variables/_index.md#define-a-cicd-variable-in-the-gitlab-ciyml-file)。

```yaml
# 以下变量将自动传递给 Postgres 容器和 Ruby 容器，并在每个容器中可用。
variables:
  HTTPS_PROXY: "https://10.1.1.1:8090"
  HTTP_PROXY: "https://10.1.1.1:8090"
  POSTGRES_DB: "my_custom_db"
  POSTGRES_USER: "postgres"
  POSTGRES_PASSWORD: "example"
  PGDATA: "/var/lib/postgresql/data"
  POSTGRES_INITDB_ARGS: "--encoding=UTF8 --data-checksums"

default:
  services:
    - name: postgres:18
      alias: db
      entrypoint: ["docker-entrypoint.sh"]
      command: ["postgres"]
  image:
    name: ruby:4.0
    entrypoint: ["/bin/bash"]
  before_script:
    - bundle install

test:
  script:
    - bundle exec rake spec
```

<a id="available-settings-for-services"></a>

## `services` 的可用设置

有关 `services:` 子键的详细信息，请参见 [CI/CD YAML 参考](../yaml/_index.md#services)。

<a id="starting-multiple-services-from-the-same-image"></a>

## 从同一镜像启动多个服务

在新的扩展 Docker 配置选项之前，以下配置无法正常工作：

```yaml
services:
  - mysql:latest
  - mysql:latest
```

Runner 会启动两个容器，每个都使用 `mysql:latest` 镜像。然而，根据[默认主机名命名](#accessing-the-services)，两者都将以 `mysql` 别名添加到作业容器中。这将导致其中一个服务无法访问。

在新的扩展 Docker 配置选项之后，前面的示例如下所示：

```yaml
services:
  - name: mysql:latest
    alias: mysql-1
  - name: mysql:latest
    alias: mysql-2
```

Runner 仍然使用 `mysql:latest` 镜像启动两个容器，但是现在每个容器都可以通过 `.gitlab-ci.yml` 文件中配置的别名访问。

<a id="setting-a-command-for-the-service"></a>

## 为服务设置命令

假设您有一个 `super/sql:latest` 镜像，其中包含一些 SQL 数据库。您想将其用作作业的服务。再假设此镜像在启动容器时不会启动数据库进程。用户需要手动使用 `/usr/bin/super-sql run` 作为命令来启动数据库。

在新的扩展 Docker 配置选项之前，您需要：

- 基于 `super/sql:latest` 镜像创建您自己的镜像。
- 添加默认命令。
- 在作业配置中使用该镜像。

  - `my-super-sql:latest` 镜像的 Dockerfile：

    ```dockerfile
    FROM super/sql:latest
    CMD ["/usr/bin/super-sql", "run"]
    ```

  - 在 `.gitlab-ci.yml` 的作业中：

    ```yaml
    services:
      - my-super-sql:latest
    ```

在新的扩展 Docker 配置选项之后，您可以改为在 `.gitlab-ci.yml` 文件中设置 `command`：

```yaml
services:
  - name: super/sql:latest
    command: ["/usr/bin/super-sql", "run"]
```

`command` 的语法类似于 [Dockerfile `CMD`](https://docs.docker.com/reference/dockerfile/#cmd)。

<a id="using-aliases-as-service-container-names-for-the-kubernetes-executor"></a>

## 使用别名作为 Kubernetes 执行器的服务容器名称

{{< history >}}

- 在 极狐GitLab 与 极狐GitLab Runner 17.9 中引入。

{{< /history >}}

您可以使用服务别名作为 Kubernetes 执行器的服务容器名称。极狐GitLab Runner 基于以下条件命名容器：

- 当为一个服务设置多个别名时，服务容器将以第一个别名命名，该别名：
  - 尚未被其他服务容器使用。
  - 遵循 [Kubernetes 标签名称约束](https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#dns-label-names)。
- 当无法使用别名命名服务容器时，极狐GitLab Runner 回退到 `svc-i` 模式。

以下示例说明了如何将别名用于 Kubernetes 执行器的服务容器命名。

<a id="one-alias-per-services"></a>

### 每个服务一个别名

在以下 `.gitlab-ci.yml` 文件中：

```yaml
job:
  image: alpine:latest
  script:
    - sleep 10
  services:
    - name: alpine:latest
      alias: alpine
    - name: mysql:latest
      alias: mysql
```

系统会创建包含名为 `alpine` 和 `mysql` 的容器的作业 Pod，除了标准的 `build` 和 `helper` 容器。这些别名被使用是因为它们：

- 未被其他服务容器使用。
- 遵循 [Kubernetes 标签名称约束](https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#dns-label-names)。

但是，在以下 `.gitlab-ci.yml` 中：

```yaml
job:
  image: alpine:latest
  script:
    - sleep 10
  services:
    - name: mysql:lts
      alias: mysql
    - name: mysql:latest
      alias: mysql
```

除了 `build` 和 `helper` 容器之外，系统还会创建另外两个名为 `mysql` 和 `svc-0` 的容器。`mysql` 容器对应 `mysql:lts` 镜像，而 `svc-0` 容器对应 `mysql:latest` 镜像。

<a id="multiple-aliases-per-services"></a>

### 每个服务多个别名

在以下 `.gitlab-ci.yml` 文件中：

```yaml
job:
  image: alpine:latest
  script:
    - sleep 10
  services:
    - name: alpine:latest
      alias: alpine,alpine-latest
    - name: alpine:edge
      alias: alpine,alpine-edge,alpine-latest
```

除了 `build` 和 `helper` 容器之外，系统还会创建另外四个容器：

- `alpine` 应对应使用 `alpine:latest` 镜像的容器。
- `alpine-edge` 应对应使用 `alpine:edge` 镜像的容器（`alpine` 别名已被前一个容器使用）。

在此示例中，未使用别名 `alpine-latest`。

但是，在以下 `.gitlab-ci.yml` 中：

```yaml
job:
  image: alpine:latest
  script:
    - sleep 10
  services:
    - name: alpine:latest
      alias: alpine,alpine-edge
    - name: alpine:edge
      alias: alpine,alpine-edge
    - name: alpine:3.21
      alias: alpine,alpine-edge
```

除了 `build` 和 `helper` 容器之外，还会创建另外六个容器。

- `alpine` 应指向使用 `alpine:latest` 镜像的容器。
- `alpine-edge` 应指向使用 `alpine:edge` 镜像的容器（`alpine` 别名已被前一个容器使用）。
- `svc-0` 应指向使用 `alpine:3.21` 镜像的容器（`alpine` 和 `alpine-edge` 别名已被前面的容器使用）。

  - `svc-i` 模式中的 `i` 并不表示服务在提供列表中的位置。相反，它表示未找到可用别名时服务的位置。

  - 当提供了无效别名（不符合 Kubernetes 约束）时，作业会失败并显示以下错误（使用别名 `alpine_edge` 的示例）。此失败发生，因为别名也用于在作业 Pod 上创建本地 DNS 条目。

    ```plaintext
    ERROR: Job failed (system failure): prepare environment: setting up build pod: provided host alias
    alpine_edge for service alpine:edge is invalid DNS. a lowercase RFC 1123 subdomain must consist of lower
    case alphanumeric characters, '-' or '.', and must start and end with an alphanumeric character (e.g.
    'example.com', regex used for validation is '[a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*')。
    有关更多信息，请查看 https://gitlab.cn/docs/runner/shells/index/#shell-profile-loading。
    ```

<a id="using-services-with-docker-run-docker-in-docker-side-by-side"></a>

## 与 `docker run`（DinD）并行使用 `services`

使用 `docker run` 启动的容器也可以连接到极狐GitLab 提供的服务。

如果启动服务的开销很大或耗时很长，您可以从不同的客户端环境运行测试，而只启动一次被测试的服务。

```yaml
access-service:
  stage: build
  image: docker:20.10.16
  services:
    - docker:dind                    # docker run 所需
    - traefik/whoami:latest
  variables:
    FF_NETWORK_PER_BUILD: "true"     # 激活容器间网络
  script: |
    docker run --rm --name curl \
      --volume  "$(pwd)":"$(pwd)"    \
      --workdir "$(pwd)"             \
      --network=host                 \
      curlimages/curl:latest curl "http://traefik-whoami"
```

要使此方案有效，您必须：

- 使用[为每个作业创建新网络的网络模式](https://gitlab.cn/docs/runner/executors/docker/#create-a-network-for-each-job)。
- [不使用 Docker 执行器与 Docker 套接字绑定](../docker/using_docker_build.md#use-docker-socket-binding)。如果您必须这样做，那么在前面的示例中，不要使用 `host`，而是使用为此作业创建的动态网络名称。

<a id="how-docker-integration-works"></a>

## Docker 集成的工作原理

以下是 Docker 在作业期间执行步骤的概要。

1. 创建任何服务容器：`mysql`、`postgresql`、`mongodb`、`redis`。
1. 创建一个缓存容器以存储 `config.toml` 和构建镜像（如前述示例中的 `ruby:4.0`）的 `Dockerfile` 中定义的所有卷。
1. 创建一个构建容器并将所有服务容器链接到构建容器。
1. 启动构建容器，并将作业脚本发送到容器。
1. 运行作业脚本。
1. 将代码检出到：`/builds/group-name/project-name/`。
1. 运行 `.gitlab-ci.yml` 中定义的任何步骤。
1. 检查构建脚本的退出状态。
1. 移除构建容器和所有已创建的服务容器。

<a id="capturing-service-container-logs"></a>

## 捕获服务容器日志

服务容器中运行的应用程序生成的日志可以被捕获，以供后续检查和调试。当服务容器成功启动，但由于非预期行为导致作业失败时，可以查看服务容器日志。这些日志可以指示容器中服务的缺失或不正确的配置。

`CI_DEBUG_SERVICES` 应仅在主动调试服务容器时启用，因为捕获服务容器日志会带来存储和性能影响。

> [!warning]
> 启用 `CI_DEBUG_SERVICES` 可能会泄露已屏蔽的变量。当 `CI_DEBUG_SERVICES` 启用时，服务容器日志和 CI 作业的日志会同时流式传输到作业的跟踪日志中。这意味着服务容器日志可能会插入到作业的已屏蔽日志中。这会破坏变量屏蔽机制，并导致已屏蔽的变量被泄露。

要启用服务日志记录，请将 `CI_DEBUG_SERVICES` 变量添加到项目的 `.gitlab-ci.yml` 文件中：

```yaml
variables:
  CI_DEBUG_SERVICES: "true"
```

允许的值是：

- 启用：`TRUE`，`true`，`True`
- 禁用：`FALSE`，`false`，`False`

任何其他值都会导致错误消息，并有效地禁用该功能。

启用后，所有服务容器的日志都会被捕获，并与其他日志同时流式传输到作业的跟踪日志中。每个容器的日志都会以其容器别名为前缀，并以不同的颜色显示。

> [!note]
> 要诊断作业失败，您可以调整要捕获日志的服务容器的日志级别。默认日志级别可能无法提供足够的故障排除信息。

请参阅 [屏蔽 CI/CD 变量](../variables/_index.md#mask-a-cicd-variable)

<a id="debug-a-job-locally"></a>

## 本地调试作业

以下命令以非 root 权限运行。请验证您可以使用用户账户运行 Docker 命令。

首先创建一个名为 `build_script` 的文件：

```shell
cat <<EOF > build_script
git clone https://jihulab.com/gitlab-cn/gitlab-runner.git /builds/gitlab-cn/gitlab-runner
cd /builds/gitlab-cn/gitlab-runner
make runner-bin-host
EOF
```

此示例使用极狐GitLab Runner 仓库，其中包含一个 Makefile，因此运行 `make` 会执行 Makefile 中定义的目标。您可以运行特定于您项目的命令，而不是 `make runner-bin-host`。

然后创建一个服务容器：

```shell
docker run -d --name service-redis redis:latest
```

前面的命令使用最新的 Redis 镜像创建了一个名为 `service-redis` 的服务容器。该服务容器在后台运行 (`-d`)。

最后，通过执行您之前创建的 `build_script` 文件来创建一个构建容器：

```shell
docker run --name build -i --link=service-redis:redis golang:latest /bin/bash < build_script
```

前面的命令创建了一个名为 `build` 的容器，该容器基于 `golang:latest` 镜像生成，并链接了一个服务。`build_script` 通过 `stdin` 管道传递给 bash 解释器，后者随即在 `build` 容器中执行 `build_script`。

测试完成后，使用以下命令移除容器：

```shell
docker rm -f -v build service-redis
```

这会强制 (`-f`) 移除 `build` 容器、服务容器以及随容器创建而创建的所有卷 (`-v`)。

<a id="security-when-using-services-containers"></a>

## 使用服务容器时的安全

Docker 特权模式适用于服务。这意味着服务镜像容器可以访问主机系统。您应仅使用来自可信源的容器镜像。

<a id="shared-builds-directory"></a>

## 共享 `/builds` 目录

构建目录作为卷挂载在 `/builds` 下，并在作业和服务之间共享。作业会在服务运行后将项目检出到 `/builds/$CI_PROJECT_PATH` 中。您的服务可能需要访问项目文件或存储产物。如果是这样，请等待该目录存在并检出 `$CI_COMMIT_SHA`。在作业完成检出过程之前所做的任何更改都会被检出过程移除。

服务必须检测作业目录何时填充完毕并准备好进行处理。例如，等待某个特定文件可用。

启动后立即开始工作的服务可能会失败，因为作业数据可能还不可用。例如，容器使用 `docker build` 命令建立到 DinD 服务的网络连接。该服务指示其 API 开始构建容器镜像。Docker Engine 必须能够访问您在 Dockerfile 中引用的文件。因此，您需要访问服务中的 `CI_PROJECT_DIR`。但是，Docker Engine 直到作业中调用 `docker build` 命令时才会尝试访问它。此时，`/builds` 目录已经填充了数据。试图在启动后立即写入 `CI_PROJECT_DIR` 的服务可能会失败，并显示 `No such file or directory` 错误。

在与作业数据交互的服务不受作业本身控制的场景下，请考虑使用 [Docker 执行器工作流](https://gitlab.cn/docs/runner/executors/docker/#docker-executor-workflow)。