---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 使用 k6 负载测试衡量并比较各分支上的应用后端性能。
title: 负载性能测试
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用负载性能测试来衡量代码变更对应用后端性能的影响。极狐GitLab 使用 [k6](https://k6.io/) 对 API 和 Web 控制器等应用端点模拟负载，并将结果输出到名为 `load-performance.json`的文件中。

与[浏览器性能测试](browser_performance_testing.md)（衡量网页在浏览器中的渲染情况）不同，负载性能测试针对服务器端，可以评估负载下的响应时间和吞吐量。

结果会直接显示在合并请求中，因此您可以在评审过程中及时发现性能退化。

<a id="load-performance-results-in-merge-requests"></a>

## 合并请求中的负载性能结果

在 `.gitlab-ci.yml` 文件中定义一个作业，用于生成[负载性能报告产物](../yaml/artifacts_reports.md#artifactsreportsload_performance)。极狐GitLab 会检查该报告，比较源分支和目标分支之间的关键负载性能指标，并在合并请求中显示结果。

![一个合并请求显示性能指标，其中 TTFB 值出现退化。](img/load_performance_testing_v18_11.png)

合并请求小组件中显示的关键指标包括：

- **Checks**：k6 测试中配置的[检查项](https://grafana.com/docs/k6/latest/using-k6/checks/)的通过率百分比。
- **TTFB P90**：开始接收响应所需时间的第 90 百分位数，
  也称为[首字节时间](https://en.wikipedia.org/wiki/Time_to_first_byte)（TTFB）。
- **TTFB P95**：TTFB 的第 95 百分位数。
- **RPS**：测试达到的平均每秒请求数（RPS）。

> [!note]
> 只有在目标分支上至少运行过一次该作业后，才会显示此小组件。

<a id="configure-load-performance-testing"></a>

## 配置负载性能测试

使用极狐GitLab 随附的
[`Verify/Load-Performance-Testing.gitlab-ci.yml`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Verify/Load-Performance-Testing.gitlab-ci.yml)
模板，对您的应用运行 [k6 负载测试](https://grafana.com/docs/k6/latest/testing-guides/)。

先决条件：

- 已配置为运行 Docker 容器的极狐GitLab Runner，例如
  [Docker-in-Docker 工作流](../docker/using_docker_build.md#use-docker-in-docker)。
- 已为负载测试配置预生产测试环境。更多信息，请参见
  [计算负载测试的并发用户数](https://k6.io/blog/monthly-visits-concurrent-users)。
- 项目代码仓库中有一个 k6 测试文件。相关指导，请参见
  [编写您的第一个 k6 测试](https://grafana.com/docs/k6/latest/get-started/write-your-first-test/)。

要配置负载性能测试，请将以下内容添加到 `.gitlab-ci.yml` 文件中：

```yaml
include:
  template: Verify/Load-Performance-Testing.gitlab-ci.yml

load_performance:
  variables:
    K6_TEST_FILE: <PATH TO K6 TEST FILE IN PROJECT>
```

极狐GitLab 会创建一个 `load_performance` 作业，用于运行 k6 测试并将结果保存为[负载性能报告产物](../yaml/artifacts_reports.md#artifactsreportsload_performance)。始终使用可用的最新产物。如果启用了
[GitLab Pages](../../user/project/pages/_index.md)，
您可以直接在浏览器中查看报告。

您可以使用 CI/CD 变量自定义该作业：

| 变量            | 默认值      | 描述 |
| ------------------- | ------------ | ----------- |
| `K6_IMAGE`          | `grafana/k6` | 要使用的 Docker 镜像。不控制版本。 |
| `K6_VERSION`        | `0.54.0`     | Docker 镜像的版本。 |
| `K6_TEST_FILE`      | 无         | 项目代码仓库中 k6 测试文件的路径。 |
| `K6_OPTIONS`        | 无         | 其他 k6 选项。更多信息，请参见 [k6 选项参考](https://grafana.com/docs/k6/latest/using-k6/k6-options/reference/)。 |
| `K6_DOCKER_OPTIONS` | 无         | 传递给 `docker run`的其他选项，例如 `--env-file`，用于将环境变量传递给 k6 容器。 |

例如，要覆盖测试的持续时间：

```yaml
include:
  template: Verify/Load-Performance-Testing.gitlab-ci.yml

load_performance:
  variables:
    K6_TEST_FILE: <PATH TO K6 TEST FILE IN PROJECT>
    K6_OPTIONS: '--duration 30s'
```

> [!note]
> 此模板不适用于 Kubernetes 集群。请改用
> [`Jobs/Load-Performance-Testing.gitlab-ci.yml`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Jobs/Load-Performance-Testing.gitlab-ci.yml)。

对于大规模 k6 测试，请确保极狐GitLab Runner 实例能够承受该负载。[默认共享 JihuLab.com Runner](../runners/hosted_runners/linux.md)的规格可能不足以运行大多数大规模 k6 测试。详情请参见 [k6 关于运行大型测试的指导](https://grafana.com/docs/k6/latest/testing-guides/running-large-tests/#hardware-considerations)。

<a id="configure-load-performance-testing-for-review-apps"></a>

### 为评审应用配置负载性能测试

先决条件：

- `load_performance` 作业必须在动态环境启动后运行。

要为评审应用配置负载性能测试，请在 [`.env` 文件](https://docs.docker.com/compose/how-tos/environment-variables/set-environment-variables/#use-the-env_file-attribute)中捕获动态 URL，并使用 `K6_DOCKER_OPTIONS` 将其传递给 k6 容器。然后，k6 可以在测试脚本中使用标准 JavaScript 引用该文件中的环境变量，例如：
``http.get(`${__ENV.ENVIRONMENT_URL}`)``。

例如：

```yaml
stages:
  - deploy
  - performance

include:
  template: Verify/Load-Performance-Testing.gitlab-ci.yml

review:
  stage: deploy
  environment:
    name: review/$CI_COMMIT_REF_SLUG
    url: http://$CI_ENVIRONMENT_SLUG.example.com
  script:
    - run_deploy_script
    - echo "ENVIRONMENT_URL=$CI_ENVIRONMENT_URL" >> review.env
  artifacts:
    paths:
      - review.env
  rules:
    - if: $CI_COMMIT_BRANCH

load_performance:
  dependencies:
    - review
  variables:
    K6_DOCKER_OPTIONS: '--env-file review.env'
  rules:
    - if: $CI_COMMIT_BRANCH
```
