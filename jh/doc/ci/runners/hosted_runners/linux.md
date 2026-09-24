---
stage: Production Engineering
group: Runners Platform
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Linux 上的托管 Runner
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

JihuLab.com 的 Linux 托管 Runner 在 Google Cloud Compute Engine 上运行。每个作业获得一个完全隔离的、临时的虚拟机（VM）。默认区域为 `us-east1`。

每个 VM 使用 Google Container-Optimized OS (COS) 和最新版本的 Docker Engine，运行 `docker+machine` [执行器](https://gitlab.cn/docs/runner/executors/#docker-machine-executor)。
机器类型和底层处理器类型可能会变化。针对特定处理器设计优化的作业可能表现不一致。

[未标记](../../yaml/_index.md#tags) 的作业在 `small` Linux x86-64 Runner 上运行。

<a id="machine-types-available-for-linux---x86-64"></a>

## Linux - x86-64 可用的机器类型

极狐GitLab 为 Linux x86-64 托管 Runner 提供以下机器类型。

<table id="x86-runner-specs" aria-label="Linux x86-64 可用的机器类型">
  <thead>
    <tr>
      <th>Runner 标签</th>
      <th>vCPU</th>
      <th>内存</th>
      <th>存储</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>
        默认
      </td>
      <td class="vcpus">2</td>
      <td>4 GB</td>
      <td>50 GB</td>
    </tr>
    <tr>
      <td>
        <code class="runner-tag">saas-linux-medium-amd64</code>
      </td>
      <td class="vcpus">2</td>
      <td>8 GB</td>
      <td>50 GB</td>
    </tr>
    <tr>
      <td>
        <code class="runner-tag">saas-linux-large-amd64</code>
      </td>
      <td class="vcpus">4</td>
      <td>16 GB</td>
      <td>50 GB</td>
    </tr>
  </tbody>
</table>



<a id="container-images"></a>

## 容器镜像

由于 Linux 上的 Runner 使用 `docker+machine` [执行器](https://gitlab.cn/docs/runner/executors/#docker-machine-executor)，您可以通过在 `.gitlab-ci.yml` 文件中定义 [`image`](../../yaml/_index.md#image) 来选择任何容器镜像。确保您选择的 Docker 镜像与您的处理器架构兼容。

如果未设置镜像，则默认使用 `ruby:3.1`。

<a id="docker-in-docker-support"></a>

## Docker-in-Docker 支持

带有任何 `saas-linux-<size>-<architecture>` 标签的 Runner 都配置为在 `privileged` 模式下运行，以支持 [Docker-in-Docker](../../docker/using_docker_build.md#use-docker-in-docker)。使用这些 Runner，您可以原生构建 Docker 镜像或在隔离的作业中运行多个容器。

带有 `gitlab-org` 标签的 Runner 不在 `privileged` 模式下运行，不能用于 Docker-in-Docker 构建。

<a id="example-gitlab-ciyml-file"></a>

## 示例 `.gitlab-ci.yml` 文件

要使用 `small` 以外的机器类型，请为作业添加 `tags:` 关键字。
例如：

```yaml
job_small:
  script:
    - echo "此作业未标记，并在默认的小型 Linux x86-64 实例上运行"

job_medium:
  tags:
    - saas-linux-medium-amd64
  script:
    - echo "此作业在中等 Linux x86-64 实例上运行"

job_large:
  tags:
    - saas-linux-large-arm64
  script:
    - echo "此作业在大型 Linux Arm64 实例上运行"
```

