---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 使用 sitespeed.io 跨分支衡量并比较网页渲染性能。
title: 浏览器性能测试
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用浏览器性能测试来衡量 Web 应用程序的渲染性能，并在性能退化进入生产环境之前将其检测出来。极狐GitLab 使用 [sitespeed.io](https://www.sitespeed.io) 为每个页面评分，并将结果输出到名为 `browser-performance.json`的文件中。

结果会直接显示在合并请求中，因此您可以在评审过程中发现性能退化。例如，向 `<head>` 中添加了一个 JavaScript 库，导致页面速度得分下降。

> [!note]
> 您可以使用 [Auto DevOps](../../topics/autodevops/_index.md) 自动化此功能。

<a id="browser-performance-results-in-merge-requests"></a>

## 合并请求中的浏览器性能结果

在 `.gitlab-ci.yml` 文件中定义一个作业，用于生成[浏览器性能报告产物](../yaml/artifacts_reports.md#artifactsreportsbrowser_performance)。极狐GitLab 会检查此报告，比较源分支和目标分支之间每个页面的关键性能指标，并在合并请求中显示结果。

![浏览器性能指标，包含退化、未变化和改进的值。](img/browser_performance_testing_v13_4.png)

> [!note]
> 只有在目标分支上至少运行过一次该作业，并且该作业在合并请求的最新流水线中运行过，该小组件才会显示。

<a id="configure-browser-performance-testing"></a>

## 配置浏览器性能测试

先决条件：

- [配置了 Docker-in-Docker 的极狐GitLab Runner](../docker/using_docker_build.md#use-docker-in-docker)。

要在您的代码上运行 [sitespeed.io 容器](https://hub.docker.com/r/sitespeedio/sitespeed.io/)，请将极狐GitLab CI/CD 与 Docker-in-Docker 配合使用：

1. 在 `.gitlab-ci.yml` 文件中，添加以下内容：

   ```yaml
   include:
     template: Verify/Browser-Performance.gitlab-ci.yml

   browser_performance:
     variables:
       URL: https://example.com
   ```

极狐GitLab 会创建一个 `browser_performance` 作业，针对该 URL 运行 sitespeed.io，并将完整的 HTML 报告保存为[浏览器性能产物](../yaml/artifacts_reports.md#artifactsreportsbrowser_performance)。如果启用了 [GitLab Pages](../../user/project/pages/_index.md)，您可以在浏览器中查看该报告。

> [!note]
> 此模板不适用于 Kubernetes 集群。请改用
> [`template: Jobs/Browser-Performance-Testing.gitlab-ci.yml`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Jobs/Browser-Performance-Testing.gitlab-ci.yml)。

您可以使用 CI/CD 变量自定义该作业：

| 变量                   | 默认值                    | 描述 |
| -------------------------- | -------------------------- | ----------- |
| `SITESPEED_IMAGE`          | `sitespeedio/sitespeed.io` | 要使用的 Docker 镜像。不控制版本。 |
| `SITESPEED_VERSION`        | `14.1.0`                   | Docker 镜像的版本。 |
| `SITESPEED_OPTIONS`        | 无                       | 其他 sitespeed.io 选项。有关更多信息，请参阅 [sitespeed.io 配置](https://www.sitespeed.io/documentation/sitespeed.io/configuration/)。 |
| `SITESPEED_DOCKER_OPTIONS` | 无                       | 传递给 `docker run`的其他选项，例如用于连接到特定 Docker 网络的 `--network`。 |

例如，要覆盖运行次数并更改版本：

```yaml
include:
  template: Verify/Browser-Performance.gitlab-ci.yml

browser_performance:
  variables:
    URL: https://www.sitespeed.io/
    SITESPEED_VERSION: 13.2.0
    SITESPEED_OPTIONS: -n 5
```

<a id="configure-the-degradation-threshold"></a>

### 配置退化阈值

为避免因分数轻微下降而触发告警，请设置 `DEGRADATION_THRESHOLD` CI/CD 变量。仅当 `Total Score` 下降达到或超过指定的分数时，才会显示告警。

例如：

```yaml
include:
  template: Verify/Browser-Performance.gitlab-ci.yml

browser_performance:
  variables:
    URL: https://example.com
    DEGRADATION_THRESHOLD: 5
```

`Total Score` 是性能、可访问性和最佳实践的综合得分，范围为 0-100。得分为 100 表示该页面没有需要解决的问题。有关更多信息，请参阅 [coach 如何为页面评分](https://www.sitespeed.io/documentation/coach/how-to/#what-do-the-coach-do)。

<a id="configure-browser-performance-testing-for-review-apps"></a>

### 为审查应用配置浏览器性能测试

先决条件：

- `browser_performance` 作业必须在动态环境启动后运行。

要为审查应用配置浏览器性能测试：

1. 在 `review` 作业中，使用动态 URL 生成 URL 列表文件：

   ```yaml
      script:
        - echo $CI_ENVIRONMENT_URL > environment_url.txt
   ```

1. 将该文件保存为产物：

   ```yaml
      artifacts:
        paths:
          - environment_url.txt
   ```

1. 将该文件作为 `URL` 变量传递给 `browser_performance` 作业。例如：

   ```yaml
   stages:
     - deploy
     - performance

   include:
     template: Verify/Browser-Performance.gitlab-ci.yml

   review:
     stage: deploy
     environment:
       name: review/$CI_COMMIT_REF_SLUG
       url: http://$CI_COMMIT_REF_SLUG.$APPS_DOMAIN
     script:
       - run_deploy_script
       - echo $CI_ENVIRONMENT_URL > environment_url.txt
     artifacts:
       paths:
         - environment_url.txt
     rules:
       - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
         when: never
       - if: $CI_COMMIT_BRANCH

   browser_performance:
     dependencies:
       - review
     variables:
       URL: environment_url.txt
   ```
