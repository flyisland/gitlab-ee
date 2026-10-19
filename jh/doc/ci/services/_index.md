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

配置 CI/CD 时，您需要指定一个镜像，用于创建运行作业的容器。要指定该镜像，请使用 `image` 关键字。

您还可以使用 `services` 关键字指定一个附加镜像。该附加镜像用于创建另一个容器，供第一个容器使用。这两个容器可以相互访问，并在运行作业时进行通信。

服务镜像可以运行任何应用，但最常见的用例是运行数据库容器，例如：

- [MySQL](mysql.md)
- [PostgreSQL](postgres.md)
- [Redis](redis.md)
- [GitLab](gitlab.md)，作为提供 JSON API 的微服务示例

> [!warning]
> 要启用服务间网络，请将 `FF_NETWORK_PER_BUILD` 设置为 `true`。
> 如果没有此功能标志，服务可能无法正常工作。有关更多信息，请参阅
> [功能标志](https://gitlab.cn/docs/runner/configuration/feature-flags/)

假设您正在开发一个使用数据库进行存储的内容管理系统。您需要一个数据库来测试应用中的所有功能。在这种情况下，将数据库容器作为服务镜像运行是一个很好的用例。

使用现有镜像并将其作为附加容器运行，而不是在每次构建项目时都安装 `mysql`。

您不仅限于数据库服务。您可以根据需要向 `.gitlab-ci.yml` 添加任意数量的服务，或手动修改 [`config.toml`](https://gitlab.cn/docs/runner/configuration/advanced-configuration/)。在 [Docker Hub](https://hub.docker.com/) 或您的私有容器镜像仓库中找到的任何镜像都可以用作服务。

有关使用私有镜像的信息，请参阅[从私有容器镜像仓库访问镜像](../docker/using_docker_images.md#access-an-image-from-a-private-container-registry)。

服务会继承与 CI 容器本身相同的 DNS 服务器、搜索域和附加主机。

<a id="how-services-are-linked-to-the-job"></a>

## 服务如何链接到作业

要更好地理解容器链接的工作原理，请阅读[将容器链接在一起](https://docs.docker.com/engine/network/links/)。

如果您将 `mysql` 作为服务添加到您的应用，该镜像将用于创建一个链接到作业容器的容器。

MySQL 的服务容器可通过主机名 `mysql` 访问。要访问您的数据库服务，请连接到名为 `mysql`的主机，而不是套接字或 `localhost`。有关更多信息，请阅读[访问服务](#accessing-the-services)。

<a id="docker-integration-workflow"></a>

## Docker 集成工作流

以下是 Docker 在作业期间执行的步骤的高层次概述。

1. 创建任何服务容器：`mysql`、`postgresql`、`mongodb`、`redis`。
1. 创建一个缓存容器，用于存储 `config.toml` 和构建镜像的 `Dockerfile`中定义的所有卷（如前面示例中的 `ruby:4.0`）。
1. 创建一个构建容器，并将任何服务容器链接到构建容器。
1. 启动构建容器，并向该容器发送作业脚本。
1. 运行作业脚本。
1. 检出代码到：`/builds/group-name/project-name/`。
1. 运行 `.gitlab-ci.yml`中定义的任何步骤。
1. 检查构建脚本的退出状态。
1. 移除构建容器和所有已创建的服务容器。

<a id="service-health-check-workflow"></a>

## 服务健康检查工作流

服务旨在提供可通过网络访问的附加功能。它们可能是 MySQL 或 Redis 之类的数据库，甚至是 `docker:dind`，它允许您使用 Docker-in-Docker (DinD)。它实际上可以是 CI/CD 作业继续执行所需的任何内容，并通过网络访问。

为确保其正常工作，Runner 会：

1. 检查容器默认公开哪些端口。
1. 启动一个特殊容器，等待这些端口可访问。

如果检查的第二阶段失败，它会打印警告：`*** WARNING: Service XYZ probably didn't start properly`。出现此问题可能是因为：

- 服务中没有打开的端口。
- 服务在超时前未正确启动，且端口没有响应。

在大多数情况下，这会影响作业，但在某些情况下，即使打印了该警告，作业仍可能成功。例如：

- 服务在警告发出后不久启动，而作业从一开始就没有使用链接的服务。在这种情况下，当作业需要访问该服务时，它可能已经在那里等待连接了。
- 服务容器不提供任何网络服务，但它对作业的目录执行了某些操作（所有服务都将作业目录作为卷挂载在 `/builds` 下）。在这种情况下，服务完成了它的工作，而由于作业没有尝试连接它，因此不会失败。

如果服务成功启动，它们会在 [`before_script`](../yaml/_index.md#before_script) 运行之前启动。这意味着您可以编写一个查询该服务的 `before_script`。

服务会在作业结束时停止，即使作业失败也是如此。

<a id="using-software-provided-by-a-service-image"></a>

## 使用服务镜像提供的软件

当您指定 `service` 时，它会提供可通过网络访问的服务。数据库是此类服务最简单的示例。

服务功能不会将定义的 `services` 镜像中的任何软件添加到作业的容器中。

例如，如果您的作业中定义了以下 `services`，则 `php`、`node` 或 `go` 命令对您的脚本不可用，作业会失败：

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

如果您需要让 `php`、`node` 和 `go` 对您的脚本可用，您应该：

- 选择一个包含所有所需工具的现有 Docker 镜像。
- 创建您自己的 Docker 镜像，包含所有所需工具，并在您的作业中使用它。

<a id="define-services-in-the-gitlab-ciyml-file"></a>

## 在 `.gitlab-ci.yml` 文件中定义 `services`

也可以为每个作业定义不同的镜像和服务：

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

如果您没有[指定服务别名](#available-settings-for-services)，您可以从构建容器通过两个主机名访问它：

- `namespace-projectname`
- `namespace__projectname`

带下划线的主机名不符合 RFC 规范，可能会导致第三方应用出现问题。

服务主机名的默认别名根据其镜像名称按以下规则创建：

- 冒号（`:`）之后的所有内容都会被去除。
- 斜杠（`/`）替换为双下划线（`__`），并创建主别名。
- 斜杠（`/`）替换为单个短横线（`-`），并创建辅助别名。

要覆盖默认行为，您可以[指定一个或多个服务别名](#available-settings-for-services)。

<a id="connecting-services"></a>

### 连接服务

您可以在复杂作业中使用相互依赖的服务，例如端到端测试，其中外部 API 需要与其自己的数据库通信。

例如，对于一个使用 API 的前端应用的端到端测试，且该 API 需要一个数据库：

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
    FF_NETWORK_PER_BUILD: 1 # activate container-to-container networking
    POSTGRES_PASSWORD: supersecretpassword
    BACKEND_POSTGRES_HOST: postgres
  script:
    - npm install
    - npm test
```

要使此解决方案正常工作，您必须使用[为每个作业创建新网络的网络模式](https://gitlab.cn/docs/runner/executors/docker/#create-a-network-for-each-job)。

<a id="passing-cicd-variables-to-services"></a>

## 将 CI/CD 变量传递给服务

您还可以直接在 `.gitlab-ci.yml` 文件中将自定义 CI/CD [变量](../variables/_index.md)传递给您的 Docker `images` 和 `services` 以进行微调。有关更多信息，请阅读[`.gitlab-ci.yml` 定义的变量](../variables/_index.md#define-a-cicd-variable-in-the-gitlab-ciyml-file)。

```yaml
# The following variables are automatically passed down to the Postgres container
# as well as the Ruby container and available within each.
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

## `services`的可用设置

有关 `services:` 子键的详细信息，请参阅 [CI/CD YAML 参考](../yaml/_index.md#services)。

<a id="starting-multiple-services-from-the-same-image"></a>

## 从同一镜像启动多个服务

在新的扩展 Docker 配置选项出现之前，以下配置无法正常工作：

```yaml
services:
  - mysql:latest
  - mysql:latest
```

Runner 会启动两个容器，每个都使用 `mysql:latest` 镜像。但是，根据[默认主机名命名规则](#accessing-the-services)，它们都会以 `mysql` 别名添加到作业的容器中。这会导致其中一个服务无法访问。

使用新的扩展 Docker 配置选项后，前面的示例将如下所示：

```yaml
services:
  - name: mysql:latest
    alias: mysql-1
  - name: mysql:latest
    alias: mysql-2
```

Runner 仍会启动两个使用 `mysql:latest` 镜像的容器，但现在每个容器还可以通过 `.gitlab-ci.yml` 文件中配置的别名访问。

<a id="setting-a-command-for-the-service"></a>

## 为服务设置命令

假设您有一个 `super/sql:latest` 镜像，其中包含某个 SQL 数据库。您想将其用作作业的服务。再假设该镜像在启动容器时不会启动数据库进程。用户需要手动使用 `/usr/bin/super-sql run` 作为命令来启动数据库。

在新的扩展 Docker 配置选项出现之前，您需要：

- 基于 `super/sql:latest` 镜像创建您自己的镜像。
- 添加默认命令。
- 在作业配置中使用该镜像。

  - `my-super-sql:latest` 镜像的 Dockerfile：

    ```dockerfile
    FROM super/sql:latest
    CMD ["/usr/bin/super-sql", "run"]
    ```

  - 在 `.gitlab-ci.yml`中的作业里：

    ```yaml
    services:
      - my-super-sql:latest
    ```

使用新的扩展 Docker 配置选项后，您可以改为在 `.gitlab-ci.yml` 文件中设置 `command`：

```yaml
services:
  - name: super/sql:latest
    command: ["/usr/bin/super-sql", "run"]
```

`command`的语法类似于 [Dockerfile `CMD`](https://docs.docker.com/reference/dockerfile/#cmd)。

<a id="using-aliases-as-service-container-names-for-the-kubernetes-executor"></a>

## 将别名用作 Kubernetes 执行器的服务容器名称

您可以将服务别名用作 Kubernetes 执行器的服务容器名称。极狐GitLab Runner 根据以下条件为容器命名：

- 当为一个服务设置了多个别名时，服务容器以第一个满足以下条件的别名命名：
  - 尚未被另一个服务容器使用。
  - 符合 [Kubernetes 标签名称约束](https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#dns-label-names)。
- 当别名无法用于命名服务容器时，极狐GitLab Runner 会回退到 `svc-i` 模式。

以下示例说明了如何为 Kubernetes 执行器使用别名来命名服务容器。

<a id="one-alias-per-service"></a>

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

系统会创建一个作业 Pod，其中除了标准的 `build` 和 `helper` 容器外，还包含名为 `alpine` 和 `mysql`的容器。使用这些别名是因为它们：

- 未被另一个服务容器使用。
- 符合 [Kubernetes 标签名称约束](https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#dns-label-names)。

但是，在以下 `.gitlab-ci.yml`中：

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

系统除了 `build` 和 `helper` 容器外，还会创建两个名为 `mysql` 和 `svc-0`的容器。`mysql` 容器对应 `mysql:lts` 镜像，而 `svc-0` 容器对应 `mysql:latest` 镜像。

<a id="multiple-aliases-per-service"></a>

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

系统除了 `build` 和 `helper` 容器外，还会创建四个容器：

- `alpine`，应对应使用 `alpine:latest` 镜像的容器。
- `alpine-edge`，应对应使用 `alpine:edge` 镜像的容器（`alpine` 别名已被前一个容器使用）。

在此示例中，别名 `alpine-latest` 未被使用。

但是，在以下 `.gitlab-ci.yml`中：

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

除了 `build` 和 `helper` 容器外，还会创建六个容器。

- `alpine` 应指使用 `alpine:latest` 镜像的容器。
- `alpine-edge` 应指使用 `alpine:edge` 镜像的容器（`alpine` 别名
  已被前一个容器使用）。
- `svc-0` 应指使用 `alpine:3.21` 镜像的容器（`alpine` 和 `alpine-edge`
  别名已被前几个容器使用）。

  - `svc-i` 模式中的 `i` 并不表示服务在所提供的列表中的位置。
    相反，它表示在找不到可用别名时服务的位置。

  - 当提供了无效别名（不符合 Kubernetes 约束）时，作业会失败并显示
    以下错误（以别名 `alpine_edge` 为例）。出现此失败是因为别名
    还用于在作业 Pod 上创建本地 DNS 条目。

    ```plaintext
    ERROR: Job failed (system failure): prepare environment: setting up build pod: provided host alias
    alpine_edge for service alpine:edge is invalid DNS. a lowercase RFC 1123 subdomain must consist of lower
    case alphanumeric characters, '-' or '.', and must start and end with an alphanumeric character (e.g.
    'example.com', regex used for validation is '[a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*').
    Check https://docs.gitlab.com/runner/shells/index/#shell-profile-loading for more information.
    ```

<a id="using-services-with-docker-run-docker-in-docker-side-by-side"></a>

## 将 `services` 与 `docker run`（Docker-in-Docker）并行使用

使用 `docker run` 启动的容器也可以连接到极狐GitLab 提供的服务。

如果启动服务的成本很高或很耗时，您可以从不同的客户端环境运行测试，而只需启动一次被测服务。

```yaml
access-service:
  stage: build
  image: docker:20.10.16
  services:
    - docker:dind                    # necessary for docker run
    - traefik/whoami:latest
  variables:
    FF_NETWORK_PER_BUILD: "true"     # activate container-to-container networking
  script: |
    docker run --rm --name curl \
      --volume  "$(pwd)":"$(pwd)"    \
      --workdir "$(pwd)"             \
      --network=host                 \
      curlimages/curl:latest curl "http://traefik-whoami"
```

要使此解决方案正常工作，您必须：

- 使用[为每个作业创建新网络的网络模式](https://gitlab.cn/docs/runner/executors/docker/#create-a-network-for-each-job)。
- [不要将 Docker 执行器与 Docker 套接字绑定一起使用](../docker/using_docker_build.md#use-docker-socket-binding)。
  如果必须使用，则在前面的示例中，请使用为此作业创建的动态网络名称，而不是 `host`。

<a id="capturing-service-container-logs"></a>

## 捕获服务容器日志

可以捕获服务容器中运行的应用生成的日志，以供后续检查和调试。当服务容器成功启动但由于意外行为导致作业失败时，可以查看服务容器日志。这些日志可以指示容器中服务的配置缺失或不正确。

只有在主动调试服务容器时才应启用 `CI_DEBUG_SERVICES`，因为捕获服务容器日志会带来存储和性能方面的影响。

> [!warning]
> 启用 `CI_DEBUG_SERVICES` 可能会泄露已屏蔽的变量。当启用 `CI_DEBUG_SERVICES` 时，
> 服务容器日志和 CI 作业日志会同时流式传输到作业的跟踪日志中。这意味着
> 服务容器日志可能会被插入到作业的已屏蔽日志中。这会破坏变量屏蔽机制，
> 导致已屏蔽的变量被泄露。

要启用服务日志记录，请将 `CI_DEBUG_SERVICES` 变量添加到项目的 `.gitlab-ci.yml` 文件中：

```yaml
variables:
  CI_DEBUG_SERVICES: "true"
```

可接受的值为：

- 启用：`TRUE`、`true`、`True`
- 禁用：`FALSE`、`false`、`False`

任何其他值都会导致错误消息，并实际上禁用该功能。

启用后，所有服务容器的日志都会被捕获，并与其他日志同时流式传输到作业的跟踪日志中。每个容器的日志都会以其别名作为前缀，并以不同的颜色显示。

> [!note]
> 要诊断作业失败，您可以调整要捕获日志的服务容器中的日志级别。
> 默认日志级别可能无法提供足够的故障排除信息。

请参阅[屏蔽 CI/CD 变量](../variables/_index.md#mask-a-cicd-variable)

<a id="debug-a-job-locally"></a>

## 在本地调试作业

以下命令无需 root 权限即可运行。请确认您可以使用自己的用户账号运行 Docker 命令。

首先创建一个名为 `build_script`的文件：

```shell
cat <<EOF > build_script
git clone https://jihulab.com/gitlab-cn/gitlab-runner.git /builds/gitlab-cn/gitlab-runner
cd /builds/gitlab-cn/gitlab-runner
make runner-bin-host
EOF
```

此示例使用包含 Makefile 的极狐GitLab Runner 代码仓库，因此运行 `make` 会执行 Makefile 中定义的目标。除了 `make runner-bin-host`，您也可以运行特定于您项目的命令。

然后创建一个服务容器：

```shell
docker run -d --name service-redis redis:latest
```

前面的命令使用最新的 Redis 镜像创建一个名为 `service-redis`的服务容器。该服务容器在后台运行（`-d`）。

最后，通过执行您之前创建的 `build_script` 文件来创建一个构建容器：

```shell
docker run --name build -i --link=service-redis:redis golang:latest /bin/bash < build_script
```

前面的命令创建一个名为 `build`的容器，它由 `golang:latest` 镜像生成，并有一个服务链接到它。`build_script` 通过 `stdin` 管道传输到 bash 解释器，后者又在 `build` 容器中执行 `build_script`。

测试完成后，使用以下命令移除容器：

```shell
docker rm -f -v build service-redis
```

这会强制（`-f`）移除 `build` 容器、服务容器以及创建容器时创建的所有卷（`-v`）。

<a id="security-when-using-services-containers"></a>

## 使用服务容器时的安全性

Docker 特权模式适用于服务。这意味着服务镜像容器可以访问主机系统。您应仅使用来自可信来源的容器镜像。

<a id="shared-builds-directory"></a>

## 共享的 `/builds` 目录

构建目录作为卷挂载在 `/builds` 下，并在作业和服务之间共享。作业会在服务运行后将项目检出到 `/builds/$CI_PROJECT_PATH`。您的服务可能需要访问项目文件或存储产物。如果是这样，请等待该目录存在并且 `$CI_COMMIT_SHA` 被检出。在作业完成检出过程之前所做的任何更改都会被检出过程移除。

服务必须检测作业目录何时已填充并准备好处理。例如，等待特定文件变为可用。

启动后立即开始工作的服务很可能会失败，因为作业数据可能尚不可用。例如，容器使用 `docker build` 命令与 DinD 服务建立网络连接。
该服务指示其 API 启动容器镜像构建。Docker Engine
必须能够访问您在 Dockerfile 中引用的文件。因此，您需要在服务中访问 `CI_PROJECT_DIR`。但是，Docker Engine 在作业中调用 `docker build` 命令之前不会尝试访问它。此时，`/builds` 目录已经填充了数据。启动后立即尝试写入 `CI_PROJECT_DIR`的服务可能会失败并显示 `No such file or directory` 错误。

在服务与作业数据交互但不受作业本身控制的情况下，请考虑 [Docker 执行器工作流](https://gitlab.cn/docs/runner/executors/docker/#docker-executor-workflow)。
