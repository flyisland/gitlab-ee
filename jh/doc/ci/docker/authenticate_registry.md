---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 在 Docker-in-Docker 中通过镜像仓库认证
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

当您使用 Docker-in-Docker 时，[标准认证方法](using_docker_images.md#access-an-image-from-a-private-container-registry) 不起作用，因为服务会启动一个新的 Docker 守护进程。

<a id="option-1-run-docker-login"></a>

## 选项 1：运行 `docker login`

在 [`before_script`](../yaml/_index.md#before_script) 中运行 `docker login`：

```yaml
default:
  image: docker:24.0.5-cli
  services:
    - docker:24.0.5-dind

variables:
  DOCKER_TLS_CERTDIR: "/certs"

build:
  stage: build
  before_script:
    - echo "$DOCKER_REGISTRY_PASS" | docker login $DOCKER_REGISTRY --username $DOCKER_REGISTRY_USER --password-stdin
  script:
    - docker build -t my-docker-image .
    - docker run my-docker-image /script/to/run/tests
```

要登录 Docker Hub，请将 `$DOCKER_REGISTRY` 留空或删除它。

<a id="option-2-mount-dockerconfigjson-on-each-job"></a>

## 选项 2：在每个作业上挂载 `~/.docker/config.json`

如果您是 极狐GitLab Runner 的管理员，可以将包含认证配置的文件挂载到 `~/.docker/config.json`。然后 Runner 拾取的每个作业都已通过认证。如果您使用的是官方 `docker:24.0.5` 镜像，则主目录位于 `/root` 下。

如果挂载了配置文件，任何修改 `~/.docker/config.json` 的 `docker` 命令都会失败。例如，`docker login` 会失败，因为文件是以只读方式挂载的。不要将其从只读更改为可写，因为这会导致问题。

以下是遵循 [`DOCKER_AUTH_CONFIG`](using_docker_images.md#determine-your-docker_auth_config-data) 文档的 `/opt/.docker/config.json` 示例：

```json
{
    "auths": {
        "https://index.docker.io/v1/": {
            "auth": "bXlfdXNlcm5hbWU6bXlfcGFzc3dvcmQ="
        }
    }
}
```

<a id="docker"></a>

### Docker

更新 [卷挂载](https://gitlab.cn/docs/runner/configuration/advanced-configuration/#volumes-in-the-runnersdocker-section) 以包含该文件。

```toml
[[runners]]
  ...
  executor = "docker"
  [runners.docker]
    ...
    privileged = true
    volumes = ["/opt/.docker/config.json:/root/.docker/config.json:ro"]
```

<a id="kubernetes"></a>

### Kubernetes

创建一个包含此文件内容的 [ConfigMap](https://kubernetes.io/docs/concepts/configuration/configmap/)。您可以使用如下命令执行此操作：

```shell
kubectl create configmap docker-client-config --namespace gitlab-runner --from-file /opt/.docker/config.json
```

更新 [卷挂载](https://gitlab.cn/docs/runner/executors/kubernetes/#custom-volume-mount) 以包含该文件。

```toml
[[runners]]
  ...
  executor = "kubernetes"
  [runners.kubernetes]
    image = "alpine:3.12"
    privileged = true
    [[runners.kubernetes.volumes.config_map]]
      name = "docker-client-config"
      mount_path = "/root/.docker/config.json"
      sub_path = "config.json"
```

<a id="option-3-use-docker_auth_config"></a>

## 选项 3：使用 `DOCKER_AUTH_CONFIG`

如果您已经定义了 [`DOCKER_AUTH_CONFIG`](using_docker_images.md#determine-your-docker_auth_config-data)，您可以使用该变量并将其保存在 `~/.docker/config.json` 中。

您可以通过以下几种方式定义此认证：

- 在 Runner 配置文件中的 [`pre_build_script`](https://gitlab.cn/docs/runner/configuration/advanced-configuration/#the-runners-section) 中。
- 在 [`before_script`](../yaml/_index.md#before_script) 中。
- 在 [`script`](../yaml/_index.md#script) 中。

以下示例显示了 [`before_script`](../yaml/_index.md#before_script)。相同的命令适用于您实施的任何解决方案。

```yaml
default:
  image: docker:24.0.5-cli
  services:
    - docker:24.0.5-dind

variables:
  DOCKER_TLS_CERTDIR: "/certs"

build:
  stage: build
  before_script:
    - mkdir -p $HOME/.docker
    - echo $DOCKER_AUTH_CONFIG > $HOME/.docker/config.json
  script:
    - docker build -t my-docker-image .
    - docker run my-docker-image /script/to/run/tests
```