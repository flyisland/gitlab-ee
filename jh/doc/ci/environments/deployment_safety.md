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

[部署作业](../jobs/_index.md#deployment-jobs) 是 CI/CD 作业中的一种特定类型。它们可能比流水线中的其他作业更敏感，可能需要格外谨慎对待。极狐GitLab 提供了多种功能，有助于保持部署安全性和稳定性。

您可以：

- 为您的项目设置合适的角色。请参阅[项目成员权限](../../user/permissions.md#project-permissions)了解极狐GitLab 支持的不同用户角色及其权限。
- [限制对关键环境的写入访问](#restrict-write-access-to-a-critical-environment)
- [在部署冻结窗口期间阻止部署](#prevent-deployments-during-deploy-freeze-windows)
- [保护生产密钥](#protect-production-secrets)
- [部署的独立项目](#separate-project-for-deployments)

如果您使用持续部署工作流，并希望确保不会同时向同一环境进行并发部署，您应该：

- [确保一次只运行一个部署作业](#ensure-only-one-deployment-job-runs-at-a-time)。
- [阻止过时的部署作业](#prevent-outdated-deployment-jobs)。

<a id="restrict-write-access-to-a-critical-environment"></a>

## 限制对关键环境的写入访问

默认情况下，环境可以由至少具有开发者角色的团队成员修改。如果要限制对关键环境（例如 `production` 环境）的写入访问，可以设置[受保护的环境](protected_environments.md)。

<a id="ensure-only-one-deployment-job-runs-at-a-time"></a>

## 确保一次只运行一个部署作业

极狐GitLab CI/CD 中的流水线作业可以并行运行，因此两条不同流水线中的两个部署作业有可能同时尝试部署到同一环境。这是不希望发生的行为，因为部署应该按顺序进行。

您可以在 `.gitlab-ci.yml` 中使用 [`resource_group` 关键词](../yaml/_index.md#resource_group)来确保一次只运行一个部署作业。

例如：

```yaml
deploy:
 script: deploy-to-prod
 resource_group: prod
```

没有资源组时存在问题的流水线流程示例：

1. 流水线 A 中的 `deploy` 作业开始运行。
1. 流水线 B 中的 `deploy` 作业开始运行。*这就是可能导致意外结果的并发部署。*
1. 流水线 A 中的 `deploy` 作业完成。
1. 流水线 B 中的 `deploy` 作业完成。

使用资源组后改进的流水线流程：

1. 流水线 A 中的 `deploy` 作业开始运行。
1. 流水线 B 中的 `deploy` 作业尝试启动，但等待第一个 `deploy` 作业完成。
1. 流水线 A 中的 `deploy` 作业完成。
1. 流水线 B 中的 `deploy` 作业开始运行。

更多信息，请参阅[资源组文档](../resource_groups/_index.md)。

<a id="prevent-outdated-deployment-jobs"></a>

## 阻止过时的部署作业

{{< history >}}

- 在极狐GitLab 15.5 中[更改](https://gitlab.com/gitlab-org/gitlab/-/issues/363328)，以防止过时的作业运行。

{{< /history >}}

流水线作业的有效执行顺序可能因运行而异，这可能会导致非预期的行为。例如，较新流水线中的[部署作业](../jobs/_index.md#deployment-jobs)可能在较旧流水线中的部署作业之前完成。这会产生竞争条件，较旧的部署稍后完成，覆盖“较新”的部署。

您可以通过[**阻止过时的部署作业**](../pipelines/settings.md#prevent-outdated-deployment-jobs)设置，在较新的部署作业启动时阻止较旧的部署作业运行。

当较旧的部署作业启动时，它会失败并被标记为：

- 在流水线视图中显示为 `失败的过时部署作业`。
- 查看已完成的作业时显示为 `该部署作业比最新部署更旧，因此失败`。

当较旧的部署作业为手动时，**运行**（{{< icon name="play" >}}）按钮将被禁用，并显示消息 `此部署作业不会自动运行，必须手动启动，但它比最新部署更旧，因此无法运行`。

作业的新旧由作业开始时间决定，而不是提交时间，因此在某些情况下，较新的提交可能会被阻止。例如，流水线 A（较旧的提交）和流水线 B（较新的提交）都有手动部署作业。如果您在创建流水线 B 之后启动流水线 A 的作业，流水线 B 的手动部署作业将被视为过时而被阻止，即使该流水线本身是较新的。

<a id="job-retries-for-rollback-deployments"></a>

### 回滚部署的作业重试

{{< history >}}

- 通过作业重试进行回滚在极狐GitLab 15.6 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/378359)。
- 回滚部署的作业重试复选框在极狐GitLab 16.3 中[引入](https://gitlab.com/gitlab-org/gitlab/-/issues/410427)。

{{< /history >}}

您可能需要快速回滚到稳定但过时的部署。默认情况下，用于[部署回滚](deployments.md#deployment-rollback)的流水线作业重试是启用的。

要禁用流水线重试，请清除**允许回滚部署的作业重试**复选框。在敏感项目中，您应该禁用流水线重试。

当需要回滚时，您必须使用先前的提交运行新的流水线。

<a id="example"></a>

### 示例

在**阻止过时的部署作业**设置禁用时，存在问题的流水线流程示例：

1. 在默认分支上创建流水线 A。
1. 稍后，在默认分支上创建流水线 B（带有较新的提交 SHA）。
1. 流水线 B 中的 `deploy` 作业首先完成，并部署较新的代码。
1. 流水线 A 中的 `deploy` 作业稍后完成，并部署较旧的代码，**覆盖**了较新的（最新）部署。

启用该设置后改进的流水线流程：

1. 在默认分支上创建流水线 A。
1. 稍后，在默认分支上创建流水线 B（带有较新的 SHA）。
1. 流水线 B 中的 `deploy` 作业首先完成，并部署较新的代码。
1. 流水线 A 中的 `deploy` 作业失败，因此它不会覆盖来自较新流水线的部署。

<a id="prevent-deployments-during-deploy-freeze-windows"></a>

## 在部署冻结窗口期间阻止部署

如果您想在特定时间段内阻止部署，例如在大多数员工休假期间，可以设置[部署冻结](../../user/project/releases/_index.md#prevent-unintentional-releases-by-setting-a-deploy-freeze)。在部署冻结期间，无法执行任何部署。这有助于确保不会意外发生部署。

下一个配置的部署冻结会显示在[环境部署列表](_index.md#view-environments-and-deployments)页面的顶部。

<a id="protect-production-secrets"></a>

## 保护生产密钥

成功部署需要生产密钥。例如，在部署到云时，云提供商需要这些密钥才能连接其服务。在项目设置中，您可以为这些密钥定义和保护 CI/CD 变量。[受保护变量](../variables/_index.md#protect-a-cicd-variable)只会传递给在[受保护分支](../../user/project/repository/branches/protected.md)或[受保护标签](../../user/project/protected_tags.md)上运行的流水线。其他流水线不会获取受保护变量。您还可以[将变量限定到特定环境](../variables/where_variables_can_be_used.md#variables-with-an-environment-scope)。我们建议您在受保护的环境上使用受保护的变量，以确保密钥不会被意外暴露。您也可以在[ Runner 端](../runners/configure_runners.md#prevent-runners-from-revealing-sensitive-information)定义生产密钥。这可以防止具有维护者角色的其他用户读取密钥，并确保 Runner 仅在受保护分支上运行。

更多信息，请参阅[流水线安全](../pipelines/_index.md#pipeline-security-on-protected-branches)。

<a id="separate-project-for-deployments"></a>

## 部署的独立项目

项目中所有具有维护者角色的用户都可以访问生产密钥。如果您需要限制可以部署到生产环境的用户数量，可以创建一个单独的项目并配置新的权限模型，将 CD 权限与原始项目隔离，并阻止原始项目中具有维护者角色的用户访问生产密钥和 CD 配置。您可以使用[多项目流水线](../pipelines/downstream_pipelines.md#multi-project-pipelines)将 CD 项目连接到您的开发项目。

<a id="protect-gitlab-ci-yml-from-change"></a>

## 保护 `.gitlab-ci.yml` 免受更改

`.gitlab-ci.yml` 可能包含将应用程序部署到生产服务器的规则。此部署通常在推送合并请求后自动运行。为防止开发者更改 `.gitlab-ci.yml`，您可以在不同的代码库中定义它。该配置可以引用另一个项目中具有完全不同权限集的文件（类似于[分离项目用于部署](#separate-project-for-deployments)）。在这种场景下，`.gitlab-ci.yml` 是可公开访问的，但只能由在另一个项目中拥有适当权限的用户编辑。

更多信息，请参阅[自定义 CI/CD 配置路径](../pipelines/settings.md#specify-a-custom-cicd-configuration-file)。

<a id="require-an-approval-before-deploying"></a>

## 部署前要求审批

在将部署提升到生产环境之前，与专门的测试小组进行交叉验证是确保安全的有效方法。更多信息，请参阅[部署审批](deployment_approvals.md)。