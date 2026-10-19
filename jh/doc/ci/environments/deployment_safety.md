---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 部署安全
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

[部署作业](../jobs/_index.md#deployment-jobs)是一种特殊的 CI/CD 作业。它们可能比流水线中的其他作业更敏感，可能需要格外谨慎地处理。极狐GitLab 提供了多项功能，帮助维护部署安全性和稳定性。

您可以：

- 为您的项目设置适当的角色。有关极狐GitLab 支持的不同用户角色及各自的权限，请参阅[项目成员权限](../../user/permissions.md#project-permissions)。
- [限制对关键环境的写入访问权限](#restrict-write-access-to-a-critical-environment)
- [在部署冻结窗口期间阻止部署](#prevent-deployments-during-deploy-freeze-windows)
- [保护生产密钥](#protect-production-secrets)
- [为部署使用单独的项目](#separate-project-for-deployments)

如果您使用持续部署工作流，并希望确保不会发生对同一环境的并发部署，您应该：

- [确保一次只运行一个部署作业](#ensure-only-one-deployment-job-runs-at-a-time)。
- [阻止过期的部署作业](#prevent-outdated-deployment-jobs)。

<a id="restrict-write-access-to-a-critical-environment"></a>

## 限制对关键环境的写入访问权限

默认情况下，任何至少具有开发者角色的团队成员都可以修改环境。如果您想限制对关键环境（例如 `production` 环境）的写入访问权限，可以设置[受保护环境](protected_environments.md)。

<a id="ensure-only-one-deployment-job-runs-at-a-time"></a>

## 确保一次只运行一个部署作业

极狐GitLab CI/CD 中的流水线作业会并行运行，因此两个不同流水线中的两个部署作业可能会尝试同时部署到同一环境。部署应按顺序进行，因此这种行为是不可取的。

您可以在`.gitlab-ci.yml`中使用 [`resource_group` 关键字](../yaml/_index.md#resource_group)来确保一次只运行一个部署作业。

例如：

```yaml
deploy:
 script: deploy-to-prod
 resource_group: prod
```

未使用资源组时存在问题的流水线流程示例：

1. 流水线 A 中的 `deploy` 作业开始运行。
1. 流水线 B 中的 `deploy` 作业开始运行。*这是一次并发部署，可能会导致意外结果。*
1. 流水线 A 中的 `deploy` 作业完成。
1. 流水线 B 中的 `deploy` 作业完成。

使用资源组后改进的流水线流程：

1. 流水线 A 中的 `deploy` 作业开始运行。
1. 流水线 B 中的 `deploy` 作业尝试启动，但会等待第一个 `deploy` 作业完成。
1. 流水线 A 中的 `deploy` 作业完成。
1. 流水线 B 中的 `deploy` 作业开始运行。

有关更多信息，请参阅[资源组文档](../resource_groups/_index.md)。

<a id="prevent-outdated-deployment-jobs"></a>

## 阻止过期的部署作业

流水线作业的实际执行顺序可能因运行而异，这可能会导致不期望的行为。例如，较新流水线中的[部署作业](../jobs/_index.md#deployment-jobs)可能会在较旧流水线中的部署作业之前完成。这会产生竞态条件，导致较旧的部署稍后完成，覆盖“较新”的部署。

您可以使用[**阻止过期的部署作业**](../pipelines/settings.md#prevent-outdated-deployment-jobs)设置，在启动较新的部署作业时阻止较旧的部署作业运行。

当较旧的部署作业启动时，它会失败并被标记为：

- 在流水线视图中标记为 `failed outdated deployment job`。
- 查看已完成的作业时显示 `The deployment job is older than the latest deployment, and therefore failed.`。

当较旧的部署作业为手动作业时，**运行**（{{< icon name="play" >}}）按钮会被禁用，并显示消息
`This deployment job does not run automatically and must be started manually, but it's older than the latest deployment, and therefore can't run.`。

作业新旧程度由作业开始时间决定，而不是提交时间，因此在某些情况下较新的提交可能会被阻止。例如，流水线 A（较旧的提交）和流水线 B（较新的提交）都有手动部署作业。如果您在创建流水线 B 之后启动流水线 A 的作业，流水线 B 的手动部署作业会因过期而被阻止，即使流水线本身较新。

<a id="job-retries-for-rollback-deployments"></a>

### 回滚部署的作业重试

您可能需要快速回滚到稳定的、过期的部署。默认情况下，[部署回滚](deployments.md#deployment-rollback)的流水线作业重试是启用的。

要禁用流水线重试，请清除**允许回滚部署的作业重试**复选框。在敏感项目中，您应禁用流水线重试。

需要回滚时，您必须使用先前的提交运行新的流水线。

<a id="example"></a>

### 示例

禁用**阻止过期的部署作业**设置时存在问题的流水线流程示例：

1. 在默认分支上创建流水线 A。
1. 之后，在默认分支上创建流水线 B（具有较新的提交 SHA）。
1. 流水线 B 中的 `deploy` 作业先完成，并部署较新的代码。
1. 流水线 A 中的 `deploy` 作业稍后完成，并部署较旧的代码，覆盖较新（最新）的部署。

启用该设置后改进的流水线流程：

1. 在默认分支上创建流水线 A。
1. 之后，在默认分支上创建流水线 B（具有较新的 SHA）。
1. 流水线 B 中的 `deploy` 作业先完成，并部署较新的代码。
1. 流水线 A 中的 `deploy` 作业失败，因此不会覆盖较新流水线的部署。

<a id="prevent-deployments-during-deploy-freeze-windows"></a>

## 在部署冻结窗口期间阻止部署

如果您想阻止特定时间段内的部署，例如在计划休假期间、大多数员工都不在时，您可以设置[部署冻结](../../user/project/releases/_index.md#prevent-unintentional-releases-by-setting-a-deploy-freeze)。在部署冻结期间，极狐GitLab 会阻止所有部署，使其不会意外发生。

下一个已配置的部署冻结会显示在[环境部署列表](_index.md#view-environments-and-deployments)页面顶部。

<a id="protect-production-secrets"></a>

## 保护生产密钥

成功部署需要生产密钥。例如，部署到云时，云提供商会要求使用这些密钥连接到其服务。在项目设置中，您可以为这些密钥定义并保护 CI/CD 变量。[受保护变量](../variables/_index.md#protect-a-cicd-variable)只会传递给在[受保护分支](../../user/project/repository/branches/protected.md)或[受保护标签](../../user/project/protected_tags.md)上运行的流水线。其他流水线不会获得受保护变量。您还可以[将变量限定到特定环境](../variables/where_variables_can_be_used.md#variables-with-an-environment-scope)。在受保护环境中使用受保护变量，以确保密钥不会被意外泄露。您还可以在 [Runner 端](../runners/configure_runners.md#prevent-runners-from-revealing-sensitive-information)定义生产密钥。这样可以防止其他具有维护者角色的用户读取密钥，并确保 Runner 只在受保护分支上运行。

有关更多信息，请参阅[流水线安全](../pipelines/_index.md#pipeline-security-on-protected-branches)。

<a id="separate-project-for-deployments"></a>

## 为部署使用单独的项目

所有具有项目维护者角色的用户都可以访问生产密钥。如果您需要限制可以部署到生产环境的用户数量，可以创建一个单独的项目并配置新的权限模型，将 CD 权限与原始项目隔离，并阻止原始项目中具有维护者角色的用户访问生产密钥和 CD 配置。您可以使用[多项目流水线](../pipelines/downstream_pipelines.md#multi-project-pipelines)将 CD 项目连接到您的开发项目。

<a id="protect-gitlab-ciyml-from-change"></a>

## 保护 `.gitlab-ci.yml` 不被更改

`.gitlab-ci.yml` 可能包含将应用程序部署到生产服务器的规则。这种部署通常在推送合并请求后自动运行。要防止开发者更改 `.gitlab-ci.yml`，您可以将其定义在其他代码仓库中。该配置可以引用另一个项目中具有完全不同权限集的文件（类似于[为部署分离项目](#separate-project-for-deployments)）。在这种情况下，`.gitlab-ci.yml` 是公开可访问的，但只能由其他项目中具有适当权限的用户编辑。

有关更多信息，请参阅[自定义 CI/CD 配置路径](../pipelines/settings.md#specify-a-custom-cicd-configuration-file)。

<a id="require-an-approval-before-deploying"></a>

## 部署前需要审批

在将部署提升到生产环境之前，与专门的测试群组进行交叉验证是确保安全的有效方法。有关更多信息，请参阅[部署审批](deployment_approvals.md)。
