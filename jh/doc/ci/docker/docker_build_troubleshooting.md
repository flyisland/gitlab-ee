---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Docker 构建故障排除
---

<a id="error-docker-cannot-connect-to-the-docker-daemon-at-tcpdocker2375"></a>

## 错误：`docker: Cannot connect to the Docker daemon at tcp://docker:2375`

当您使用 v19.03 或更高版本的 [Docker-in-Docker](using_docker_build.md#use-docker-in-docker) 时，此错误很常见：

```plaintext
docker: Cannot connect to the Docker daemon at tcp://docker:2375. Is the docker daemon running?
```

出现此错误是因为 Docker 会自动在 TLS 上启动。

- 如果这是您首次设置，请参阅
  [将 Docker 执行器与 Docker 镜像配合使用](using_docker_build.md#use-docker-in-docker)。
- 如果您要从 v18.09 或更早版本升级，请参阅
  [升级指南](https://about.gitlab.com/blog/docker-in-docker-with-docker-19-dot-03/)。

当尝试在 Docker-in-Docker 服务完全启动之前访问它时，[Kubernetes 执行器](https://gitlab.cn/docs/runner/executors/kubernetes/#using-dockerdind)也可能出现此错误。有关更详细的说明，请参阅[议题 27215](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/27215)。

<a id="docker-no-such-host-error"></a>

## Docker `no such host` 错误

您可能会遇到如下错误：
`docker: error during connect: Post https://docker:2376/v1.40/containers/create: dial tcp: lookup docker on x.x.x.x:53: no such host`。

当服务的镜像名称[包含镜像仓库主机名](../services/_index.md#available-settings-for-services)时，可能会出现此问题。例如：

```yaml
default:
  image: docker:24.0.5-cli
  services:
    - registry.hub.docker.com/library/docker:24.0.5-dind
```

服务的主机名[派生自完整的镜像名称](../services/_index.md#accessing-the-services)。但是，需要使用较短的服务主机名 `docker`。要允许服务解析和访问，请为服务名称 `docker` 添加显式别名：

```yaml
default:
  image: docker:24.0.5-cli
  services:
    - name: registry.hub.docker.com/library/docker:24.0.5-dind
      alias: docker
```

<a id="error-cannot-connect-to-the-docker-daemon-at-unixvarrundockersock"></a>

## 错误：`Cannot connect to the Docker daemon at unix:///var/run/docker.sock`

当您尝试运行 `docker` 命令来访问 `dind` 服务时，可能会遇到以下错误：

```shell
$ docker ps
Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?
```

请确保您的作业已定义以下环境变量：

- `DOCKER_HOST`
- `DOCKER_TLS_CERTDIR`（可选）
- `DOCKER_TLS_VERIFY`（可选）

您可能还需要更新提供 Docker 客户端的镜像。例如，[`docker/compose` 镜像已过时](https://hub.docker.com/r/docker/compose)，应替换为 [`docker`](https://hub.docker.com/_/docker)。

如 [runner 议题 30944](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/30944#note_1514250909)中所述，如果您的作业之前依赖于已弃用的 [Docker `--link` 参数](https://docs.docker.com/network/links/#environment-variables)派生的环境变量（例如 `DOCKER_PORT_2375_TCP`），则可能出现此错误。如果出现以下情况，您的作业会因此错误而失败：

- 您的 CI/CD 镜像依赖于旧版变量，例如 `DOCKER_PORT_2375_TCP`。
- [runner 功能标志 `FF_NETWORK_PER_BUILD`](https://gitlab.cn/docs/runner/configuration/feature-flags/) 设置为 `true`。
- 未显式设置 `DOCKER_HOST`。

<a id="error-unauthorized-incorrect-username-or-password"></a>

## 错误：`unauthorized: incorrect username or password`

当您使用已弃用的变量 `CI_BUILD_TOKEN` 时，会出现此错误：

```plaintext
Error response from daemon: Get "https://registry-1.docker.io/v2/": unauthorized: incorrect username or password
```

为防止用户收到此错误，您应该：

- 改用 [CI_JOB_TOKEN](../jobs/ci_job_token.md)。
- 将 `gitlab-ci-token/CI_BUILD_TOKEN` 更改为 `$CI_REGISTRY_USER/$CI_REGISTRY_PASSWORD`。

<a id="error-during-connect-no-such-host"></a>

## 连接期间错误：`no such host`

当 `dind` 服务启动失败时，会出现此错误：

```plaintext
error during connect: Post "https://docker:2376/v1.24/auth": dial tcp: lookup docker on 127.0.0.11:53: no such host
```

检查作业日志，看是否出现 `mount: permission denied (are you root?)`。例如：

```plaintext
Service container logs:
2023-08-01T16:04:09.541703572Z Certificate request self-signature ok
2023-08-01T16:04:09.541770852Z subject=CN = docker:dind server
2023-08-01T16:04:09.556183222Z /certs/server/cert.pem: OK
2023-08-01T16:04:10.641128729Z Certificate request self-signature ok
2023-08-01T16:04:10.641173149Z subject=CN = docker:dind client
2023-08-01T16:04:10.656089908Z /certs/client/cert.pem: OK
2023-08-01T16:04:10.659571093Z ip: can't find device 'ip_tables'
2023-08-01T16:04:10.660872131Z modprobe: can't change directory to '/lib/modules': No such file or directory
2023-08-01T16:04:10.664620455Z mount: permission denied (are you root?)
2023-08-01T16:04:10.664692175Z Could not mount /sys/kernel/security.
2023-08-01T16:04:10.664703615Z AppArmor detection and --privileged mode might break.
2023-08-01T16:04:10.665952353Z mount: permission denied (are you root?)
```

这表明极狐GitLab Runner 没有启动 `dind` 服务的权限：

1. 检查 `config.toml`中是否设置了 `privileged = true`。
1. 确保 CI 作业具有正确的 Runner 标签，以使用这些特权 runner。

<a id="error-cgroups-cgroup-mountpoint-does-not-exist-unknown"></a>

## 错误：`cgroups: cgroup mountpoint does not exist: unknown`

Docker Engine 20.10 引入了一个已知的不兼容问题。

当主机使用 Docker Engine 20.10 或更高版本时，低于 20.10 版本的 `docker:dind` 服务将无法按预期工作。

虽然服务本身可以正常启动，但尝试构建容器镜像时会导致以下错误：

```plaintext
cgroups: cgroup mountpoint does not exist: unknown
```

要解决此问题，请将 `docker:dind` 容器更新到至少 20.10.x 版本，例如 `docker:24.0.5-dind`。

相反的配置（`docker:24.0.5-dind` 服务与主机上 19.06.x 或更早版本的 Docker Engine）可以正常工作。最佳策略是，您应经常测试并将作业环境版本更新到最新版本。这会带来新功能和更高的安全性。对于此特定情况，它还能使 runner 主机上底层 Docker Engine 的升级对作业透明。

<a id="error-failed-to-verify-certificate-x509-certificate-signed-by-unknown-authority"></a>

## 错误：`failed to verify certificate: x509: certificate signed by unknown authority`

当在 Docker-in-Docker 环境中执行 `docker build` 或 `docker pull` 等 Docker 命令，且该环境使用自定义或私有证书（例如 Zscaler 证书）时，可能会出现此错误：

```plaintext
error pulling image configuration: download failed after attempts=6: tls: failed to verify certificate: x509: certificate signed by unknown authority
```

出现此错误是因为 Docker-in-Docker 环境中的 Docker 命令使用两个独立的容器：

- **构建容器**运行 Docker 客户端（`/usr/bin/docker`）并执行作业的脚本命令。
- **服务容器**（通常名为 `svc`）运行处理大多数 Docker 命令的 Docker 守护进程。

当您的组织使用自定义证书时，两个容器都需要这些证书。如果两个容器中都没有正确配置证书，连接到外部镜像仓库或服务的 Docker 操作会因证书错误而失败。

要解决此问题：

1. 将您的根证书存储为名为 `CA_CERTIFICATE`的 [CI/CD 变量](../variables/_index.md#define-a-cicd-variable-in-the-ui)。
   证书应采用以下格式：

   ```plaintext
   -----BEGIN CERTIFICATE-----
   (certificate content)
   -----END CERTIFICATE-----
   ```

1. 配置您的流水线，在启动 Docker 守护进程之前将证书安装到服务容器中。例如：

   ```yaml
   image_build:
     stage: build
     image:
       name: docker:19.03
     variables:
       DOCKER_HOST: tcp://localhost:2375
       DOCKER_TLS_CERTDIR: ""
       CA_CERTIFICATE: "$CA_CERTIFICATE"
     services:
       - name: docker:19.03-dind
         command:
           - /bin/sh
           - -c
           - |
             echo "$CA_CERTIFICATE" > /usr/local/share/ca-certificates/custom-ca.crt && \
             update-ca-certificates && \
             dockerd-entrypoint.sh || exit
     script:
       - docker info
       - docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD $DOCKER_REGISTRY
       - docker build -t "${DOCKER_REGISTRY}/my-app:${CI_COMMIT_REF_NAME}" .
       - docker push "${DOCKER_REGISTRY}/my-app:${CI_COMMIT_REF_NAME}"
   ```
