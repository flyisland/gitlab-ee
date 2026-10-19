---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用极狐GitLab CI/CD 进行增量发布
description: Kubernetes、CI/CD、风险缓解和部署。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

在向应用程序推出变更时，作为一种风险缓解策略，您可以仅将生产变更发布到一部分 Kubernetes pod。通过逐步发布生产变更，可以监控错误率或性能下降情况，如果没有问题，则可以更新所有 pod。

极狐GitLab 支持使用增量发布，以手动触发和定时两种方式向 Kubernetes 生产系统发布。使用手动发布时，每一批 pod 的发布都需手动触发。使用定时发布时，发布会在默认暂停 5 分钟后分批执行。定时发布也可以在暂停期结束前手动触发。

手动发布和定时发布会自动包含在由 [Auto DevOps](../../topics/autodevops/_index.md) 控制的项目中，但也可以通过极狐GitLab CI/CD 在 `.gitlab-ci.yml` 配置文件中进行配置。

手动触发的发布可以通过持续交付来实现，而定时发布无需人工干预，可以作为持续部署策略的一部分。您还可以将两者结合使用，使应用自动部署，除非您在必要时最终进行手动干预。

以下示例应用程序演示了这三种选项。您可以将它们用作构建自己方案的示例：

- [手动增量发布](https://gitlab.com/gl-release/incremental-rollout-example/blob/master/.gitlab-ci.yml)
- [定时增量发布](https://gitlab.com/gl-release/timed-rollout-example/blob/master/.gitlab-ci.yml)
- [手动和定时发布](https://gitlab.com/gl-release/incremental-timed-rollout-example/blob/master/.gitlab-ci.yml)

<a id="manual-rollouts"></a>

## 手动发布

可以通过 `.gitlab-ci.yml` 将极狐GitLab 配置为手动执行增量发布。手动配置允许对此功能进行更多控制。增量发布中的步骤取决于为部署定义的 pod 数量，这些数量在创建 Kubernetes 集群时配置。

例如，如果您的应用程序有 10 个 pod，并且运行了一个 10% 的发布作业，则应用程序的新实例会部署到单个 pod，而其余 pod 仍显示应用程序的先前实例。

首先，[将模板定义为手动](https://gitlab.com/gl-release/incremental-rollout-example/blob/master/.gitlab-ci.yml#L100-103)：

```yaml
.manual_rollout_template: &manual_rollout_template
  <<: *rollout_template
  stage: production
  when: manual
```

接下来，[为每个步骤定义发布数量](https://gitlab.com/gl-release/incremental-rollout-example/blob/master/.gitlab-ci.yml#L152-155)：

```yaml
rollout 10%:
  <<: *manual_rollout_template
  variables:
    ROLLOUT_PERCENTAGE: 10
```

作业构建完成后，选择作业名称旁边的**运行**（{{< icon name="play" >}}）以发布每个阶段的 pod。您也可以通过运行较低百分比的作业来回滚。达到 100% 后，您将无法使用此方法回滚。要回滚部署，请参阅[重试或回滚部署](deployments.md#retry-or-roll-back-a-deployment)。

有一个[可部署应用程序](https://gitlab.com/gl-release/incremental-rollout-example)可用，用于演示手动触发的增量发布。

<a id="timed-rollouts"></a>

## 定时发布

定时发布的行为与手动发布相同，不同之处在于每个作业都定义了部署前的延迟分钟数。选择该作业会显示倒计时。

![正在进行的定时发布。](img/timed_rollout_v17_9.png)

可以将此功能与手动增量发布结合使用，使作业先倒计时，然后再部署。

首先，[将模板定义为定时](https://gitlab.com/gl-release/timed-rollout-example/blob/master/.gitlab-ci.yml#L86-89)：

```yaml
.timed_rollout_template: &timed_rollout_template
  <<: *rollout_template
  when: delayed
  start_in: 1 minutes
```

您可以使用 `start_in` 键定义延迟时间：

```yaml
start_in: 1 minutes
```

接下来，[为每个步骤定义发布数量](https://gitlab.com/gl-release/timed-rollout-example/blob/master/.gitlab-ci.yml#L97-101)：

```yaml
timed rollout 30%:
  <<: *timed_rollout_template
  stage: timed rollout 30%
  variables:
    ROLLOUT_PERCENTAGE: 30
```

有一个[可部署应用程序](https://gitlab.com/gl-release/timed-rollout-example)可用，[演示了定时发布的配置](https://gitlab.com/gl-release/timed-rollout-example/blob/master/.gitlab-ci.yml#L86-95)。

<a id="blue-green-deployment"></a>

## 蓝绿部署

> [!note]
> 团队可以利用 Ingress 注解并[设置流量权重](../../user/project/canary_deployments.md#how-to-change-the-traffic-weight-on-a-canary-ingress-deprecated)
> 作为此处记录的蓝绿部署策略的替代方法。

这种技术有时也称为 A/B 部署或红黑部署，用于在部署期间减少停机时间和风险。与增量发布结合使用时，您可以将部署导致问题的影响降至最低。

使用此技术时，会有两个部署（“蓝色”和“绿色”，但可以使用任何命名）。除增量发布期间外，任一时刻只有一个部署处于活动状态。

例如，您的蓝色部署可以在生产环境中处于活动状态，而绿色部署则处于“活动”状态以供测试，但未部署到生产环境。如果发现问题，可以在不影响生产部署（蓝色）的情况下更新绿色部署。如果测试未发现问题，则将生产环境切换到绿色部署，此时蓝色部署可用于测试下一个版本。

此过程可减少停机时间，因为无需关闭生产部署即可切换到其他部署。两个部署并行运行，并且可以随时切换。

有一个[示例可部署应用程序](https://gitlab.com/gl-release/blue-green-example)可用，其中包含一个[`.gitlab-ci.yml` CI/CD 配置文件](https://gitlab.com/gl-release/blue-green-example/blob/master/.gitlab-ci.yml)，用于演示蓝绿部署。
