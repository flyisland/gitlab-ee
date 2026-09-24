---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用极狐GitLab 作为微服务
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

许多应用需要访问 JSON API，因此应用测试可能也需要访问 API。以下示例展示了如何将极狐GitLab 作为微服务使用，以便测试能够访问极狐GitLab API。

1. 配置一个使用 Docker 或 Kubernetes 执行器的 [runner](../runners/_index.md)。
1. 在你的 `.gitlab-ci.yml` 中添加：

   ```yaml
   services:
     - name: registry.gitlab.cn/omnibus/gitlab-jh:latest
       alias: gitlab

   variables:
     GITLAB_HTTPS: "false"             # 确保纯 HTTP 可用
     GITLAB_ROOT_PASSWORD: "password"  # 使用 root:password 用户访问 API
   ```

> [!note]
> 在极狐GitLab UI 中设置的变量不会传递到服务容器中。
> 更多信息，请参见[极狐GitLab CI/CD 变量](../variables/_index.md)。

然后，你的 `.gitlab-ci.yml` 文件中 `script` 部分的命令可以通过 `http://gitlab/api/v4` 访问 API。

有关为什么将 `gitlab` 用作 `Host` 的更多信息，请参见
[服务如何链接到作业](../docker/using_docker_images.md#extended-docker-configuration-options)。

你也可以使用 [Docker Hub](https://hub.docker.com/u/gitlab) 上可用的任何其他 Docker 镜像。

`gitlab` 镜像可以接受环境变量。更多详细信息，请参见 [Linux 软件包文档](../../install/_index.md)。