---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 将极狐GitLab 用作微服务
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

许多应用程序需要访问 JSON API，因此应用程序测试可能也需要访问 API。以下示例展示了如何将极狐GitLab 用作微服务，让测试能够访问极狐GitLab API。

1. 使用 Docker 或 Kubernetes 执行器配置一个 [runner](../runners/_index.md)。
1. 在您的 `.gitlab-ci.yml`中添加：

   ```yaml
   services:
     - name: registry.gitlab.cn/omnibus/gitlab-jh:latest
       alias: gitlab

   variables:
     GITLAB_HTTPS: "false"             # ensure that plain http works
     GITLAB_ROOT_PASSWORD: "password"  # to access the api with user root:password
   ```

> [!note]
> 在极狐GitLab UI 中设置的变量不会传递给服务容器。
> 更多信息，请参见[极狐GitLab CI/CD 变量](../variables/_index.md)。

之后，您的 `.gitlab-ci.yml` 文件中 `script` 部分的命令即可通过 `http://gitlab/api/v4` 访问该 API。

有关为何将 `gitlab` 用作 `Host`的更多信息，请参见[服务如何链接到作业](../docker/using_docker_images.md#extended-docker-configuration-options)。

您也可以使用 [Docker Hub](https://hub.docker.com/u/gitlab) 上提供的任何其他 Docker 镜像。

`gitlab` 镜像可以接受环境变量。更多详情，请参见 [Linux 软件包文档](../../install/_index.md)。
