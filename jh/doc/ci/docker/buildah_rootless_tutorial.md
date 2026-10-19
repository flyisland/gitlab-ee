---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: '教程：在 OpenShift 上使用 GitLab Runner Operator 在无根容器中使用 Buildah'
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

本教程将教您如何使用 `buildah` 工具成功构建镜像，并使用 [GitLab Runner Operator](https://gitlab.com/gitlab-org/gl-openshift/gitlab-runner-operator) 在 OpenShift 集群上部署极狐GitLab Runner。

本指南改编自 [在无根 OpenShift 容器中使用 Buildah 构建镜像](https://github.com/podman-container-tools/buildah/blob/main/docs/tutorials/05-openshift-rootless-build.md) 文档，适用于 GitLab Runner Operator。

要完成本教程：

1. 配置 Buildah 镜像。
1. 配置服务账号。
1. 配置作业。

<a id="before-you-begin"></a>

## 开始之前

在完成本教程之前，请确保您具备以下条件：

- 一个已部署到 `gitlab-runner` 命名空间的 Runner。

<a id="configure-the-buildah-image"></a>

## 配置 Buildah 镜像

首先，基于 `quay.io/buildah/stable:v1.23.1` 镜像准备一个自定义镜像。

1. 创建 `Containerfile-buildah` 文件：

   ```shell
   cat > Containerfile-buildah <<EOF
   FROM quay.io/buildah/stable:v1.23.1

   RUN touch /etc/subgid /etc/subuid \
   && chmod g=u /etc/subgid /etc/subuid /etc/passwd \
   && echo build:10000:65536 > /etc/subuid \
   && echo build:10000:65536 > /etc/subgid

   # Use chroot because the default runc does not work when running rootless
   RUN echo "export BUILDAH_ISOLATION=chroot" >> /home/build/.bashrc

   # Use VFS because fuse does not work
   RUN mkdir -p /home/build/.config/containers \
   && (echo '[storage]';echo 'driver = "vfs"') > /home/build/.config/containers/storage.conf

   # The buildah container will run as `build` user
   USER build
   WORKDIR /home/build
   EOF
   ```

1. 构建 Buildah 镜像并将其推送到容器镜像仓库。让我们推送到 [极狐GitLab 容器镜像仓库](../../user/packages/container_registry/_index.md)：

   ```shell
   docker build -f Containerfile-buildah -t registry.example.com/group/project/buildah:1.23.1 .
   docker push registry.example.com/group/project/buildah:1.23.1
   ```

<a id="configure-the-service-account"></a>

## 配置服务账号

对于这些步骤，您需要在连接到 OpenShift 集群的终端中运行命令。

1. 运行此命令以创建名为 `buildah-sa` 的服务账号：

   ```shell
   oc create -f - <<EOF
   apiVersion: v1
   kind: ServiceAccount
   metadata:
     name: buildah-sa
     namespace: gitlab-runner
   EOF
   ```

1. 授予所创建的服务账号使用 `anyuid` [SCC](https://docs.openshift.com/container-platform/4.3/authentication/managing-security-context-constraints.html) 运行的权限：

   ```shell
   oc adm policy add-scc-to-user anyuid -z buildah-sa -n gitlab-runner
   ```

1. 使用 [Runner 配置模板](https://gitlab.cn/docs/runner/configuration/configuring_runner_operator/#customize-configtoml-with-a-configuration-template) 配置 Operator 以使用新的服务账号。创建一个包含以下内容的 `custom-config.toml` 文件：

   ```toml
   [[runners]]
     [runners.kubernetes]
         service_account_overwrite_allowed = "buildah-*"
   ```

1. 从 `custom-config.toml` 文件创建一个名为 `custom-config-toml` 的 `ConfigMap`：

   ```shell
   oc create configmap custom-config-toml --from-file config.toml=custom-config.toml -n gitlab-runner
   ```

1. 通过更新其 [自定义资源定义 (CRD) 文件](https://gitlab.cn/docs/runner/install/operator/#install-gitlab-runner) 来设置 `Runner` 的 `config` 属性：

   ```yaml
   apiVersion: apps.gitlab.com/v1beta2
   kind: Runner
   metadata:
     name: buildah-runner
   spec:
     gitlabUrl: https://gitlab.example.com
     token: gitlab-runner-secret
     config: custom-config-toml
   ```

<a id="configure-the-job"></a>

## 配置作业

最后一步是在您的项目中设置一个极狐GitLab CI/CD 配置文件，以使用新的 Buildah 镜像和已配置的服务账号：

```yaml
build:
  stage: build
  image: registry.example.com/group/project/buildah:1.23.1
  variables:
    STORAGE_DRIVER: vfs
    BUILDAH_FORMAT: docker
    BUILDAH_ISOLATION: chroot
    FQ_IMAGE_NAME: "$CI_REGISTRY_IMAGE/test"
    KUBERNETES_SERVICE_ACCOUNT_OVERWRITE: "buildah-sa"
  before_script:
    # Log in to the GitLab container registry
    - buildah login -u "$CI_REGISTRY_USER" --password $CI_REGISTRY_PASSWORD $CI_REGISTRY
  script:
    - buildah images
    - buildah build -t $FQ_IMAGE_NAME
    - buildah images
    - buildah push $FQ_IMAGE_NAME
```

作业应使用您构建的镜像作为 `image` 关键字的值。

`KUBERNETES_SERVICE_ACCOUNT_OVERWRITE` 变量的值应为您创建的服务账号名称。

恭喜，您已成功在无根容器中使用 Buildah 构建了镜像！

<a id="troubleshooting"></a>

## 故障排除

以非 root 用户运行时存在一个 [已知问题](https://github.com/containers/buildah/issues/4049)。如果您使用的是 OpenShift Runner，则可能需要使用 [变通方法](https://gitlab.cn/docs/runner/configuration/configuring_runner_operator/#configure-setfcap)。
