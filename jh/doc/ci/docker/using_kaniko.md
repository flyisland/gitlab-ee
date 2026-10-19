---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 在极狐GitLab CI/CD 中使用 Docker、Buildah 或 Podman 构建容器镜像，作为 kaniko 的替代方案。
title: 使用 kaniko 构建 Docker 镜像（已移除）
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

[kaniko](https://github.com/GoogleContainerTools/kaniko) 已不再是一个维护中的项目。更多信息，请参见 [issue 3348](https://github.com/GoogleContainerTools/kaniko/issues/3348)。
请改用[使用 Docker 构建 Docker 镜像](using_docker_build.md)、[Buildah](using_docker_build.md#buildah-example)、[使用 Podman 运行 Docker 命令](https://gitlab.cn/docs/runner/executors/docker/#use-podman-to-run-docker-commands)，或在 Kubernetes 上[将 Podman 与极狐GitLab Runner 配合使用](https://gitlab.cn/docs/runner/executors/kubernetes/use_podman_with_kubernetes/)。
