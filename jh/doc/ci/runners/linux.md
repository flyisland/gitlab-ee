---
stage: Verify
group: Runner
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: 托管在 Linux 上的 runner
---

{{< details >}}

1. Tier: 基础版, 专业版, 旗舰版
1. Offering: JihuLab.com

{{< /details >}}

极狐GitLab.com 上的 Linux 托管 runner 运行在 Google Cloud Compute Engine 上。每个作业都获得一个完全隔离的、临时的虚拟机 (VM)。默认区域是 `us-east1`。

每个 VM 使用 Google Container-Optimized OS (COS) 和最新版本的 Docker Engine，运行 `docker+machine` [执行器](https://gitlab.cn/docs/runner/executors/#docker-machine-executor)。机器类型和底层处理器类型可能会发生变化。针对特定处理器设计优化的作业可能会表现不一致。

[未标记](../yaml/_index.md#tags) 的作业运行在 `small` Linux x86-64 runner 上。

<a id="machine-types-available-for-linux---x86-64"></a>

## Linux - x86-64 可用的机器类型

极狐GitLab 提供以下用于 Linux x86-64 托管 runner 的机器类型。

| Runner Tag                                             | vCPUs | 内存   | 存储   |
|--------------------------------------------------------|-------|--------|--------|
| `saas-linux-small-amd64` (默认)                        | 2     | 8 GB   | 30 GB  |
| `saas-linux-medium-amd64`                              | 4     | 16 GB  | 50 GB  |
| `saas-linux-large-amd64` (仅限专业版和旗舰版)          | 8     | 32 GB  | 100 GB |



<a id="container-images"></a>

## 容器镜像

由于 Linux 上的 runner 使用 `docker+machine` [执行器](https://gitlab.cn/docs/runner/executors/#docker-machine-executor)，您可以通过在 `.gitlab-ci.yml` 文件中定义 [`image`](../yaml/_index.md#image) 来选择任何容器镜像。确保您选择的 Docker 镜像与您的处理器架构兼容。

如果未设置镜像，默认是 `ruby:3.1`。

<a id="docker-in-docker-support"></a>

## Docker-in-Docker 支持

带有任何 `saas-linux-<size>-<architecture>` 标签的 runner 被配置为在 `privileged` 模式下运行，以支持 [Docker-in-Docker](../docker/using_docker_build.md#use-docker-in-docker)。使用这些 runner，您可以原生构建 Docker 镜像或在隔离的作业中运行多个容器。

带有 `gitlab-org` 标签的 runner 不在 `privileged` 模式下运行，不能用于 Docker-in-Docker 构建。

<a id="example-gitlab-ci-yml-file"></a>

## 示例 `.gitlab-ci.yml` 文件

要使用 `small` 以外的机器类型，请向您的作业添加 `tags:` 关键字。例如：

```yaml
job_small:
  script:
    - echo "This job is untagged and runs on the default small Linux x86-64 instance"

job_medium:
  tags:
    - saas-linux-medium-amd64
  script:
    - echo "This job runs on the medium Linux x86-64 instance"

job_large:
  tags:
    - saas-linux-large-arm64
  script:
    - echo "This job runs on the large Linux Arm64 instance"
```
