---
stage: Production Engineering
group: Runners Platform
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Windows 上的托管 Runner
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Status: Beta

{{< /details >}}

Windows 上的托管 Runner 通过启动虚拟机实现自动缩放。此解决方案使用一个由极狐GitLab 为[自定义执行器](https://gitlab.cn/docs/runner/executors/custom/)开发的[自动缩放驱动](https://jihulab.com/gitlab-cn/ci-cd/custom-executor-drivers/autoscaler/-/blob/main/docs/README.md)。Windows 上的托管 Runner 处于[测试版](../../../policy/development_stages_support.md#beta)阶段。

极狐GitLab 持续迭代，使 Windows Runner 达到稳定状态并[GA](../../../policy/development_stages_support.md#generally-available)。你可以在[相关史诗](https://jihulab.com/groups/gitlab-cn/-/epics/2162)中追踪这一目标的工作进展。

<a id="machine-types-available-for-windows"></a>

## 适用于 Windows 的机器类型

极狐GitLab 为 Windows 上的托管 Runner 提供以下机器类型。

| Runner 标签                  | vCPU | 内存   | 存储   |
| --------------------------- | ---- | ------ | ------ |
| `saas-windows-medium-amd64` | 2    | 7.5 GB | 75 GB |

<a id="supported-windows-versions"></a>

## 支持的 Windows 版本

Windows Runner 虚拟机实例不使用极狐GitLab Docker 执行器。这意味着你不能在你的流水线配置中指定 [`image`](../../yaml/_index.md#image) 或 [`services`](../../yaml/_index.md#services)。

你可以在以下 Windows 版本之一中执行你的作业：

| 版本          | 状态   |
| ------------- | ------ |
| Windows 2022  | `GA`   |

你可以在[预装软件文档](https://jihulab.com/gitlab-cn/ci-cd/shared-runners/images/gcp/windows-containers/-/blob/main/cookbooks/preinstalled-software/attributes/default.rb)中找到可用预装软件的完整列表。

<a id="supported-shell"></a>

## 支持的 Shell

Windows 上的托管 Runner 将 PowerShell 配置为 Shell。因此，`.gitlab-ci.yml` 文件的 `script` 部分要求使用 PowerShell 命令。

<a id="example-gitlab-ci-yml-file"></a>

## 示例 `.gitlab-ci.yml` 文件

使用此示例 `.gitlab-ci.yml` 文件开始使用 Windows 上的托管 Runner：

```yaml
.windows_job:
  tags:
    - saas-windows-medium-amd64
  before_script:
    - Set-Variable -Name "time" -Value (date -Format "%H:%m")
    - echo ${time}
    - echo "由 ${GITLAB_USER_NAME} / @${GITLAB_USER_LOGIN} 启动"

build:
  extends:
    - .windows_job
  stage: build
  script:
    - echo "正在构建作业中运行脚本"

test:
  extends:
    - .windows_job
  stage: test
  script:
    - echo "正在测试作业中运行脚本"
```

<a id="known-issues"></a>

## 已知问题

- 有关测试版功能支持的更多信息，请参阅[测试版](../../../policy/development_stages_support.md#beta)。
- 一个新的 Windows 虚拟机 (VM) 的平均配置时间为 5 分钟，因此在测试期间，你可能会注意到 Windows Runner 集群上的构建启动时间较慢。未来发布版本中计划更新自动缩放器，以支持虚拟机的预配置。此更新旨在大幅减少 Windows 集群上配置 VM 所需的时间。有关更多信息，请参阅[议题 #32](https://jihulab.com/gitlab-cn/ci-cd/custom-executor-drivers/autoscaler/-/issues/32)。
- Windows Runner 集群可能偶尔会因维护或更新而不可用。
- 作业处于待处理状态的时间可能比 Linux Runner 更长。
- 我们可能会引入重大变更，这需要更新使用 Windows Runner 集群的流水线。