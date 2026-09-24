---
stage: Application Security Testing
group: Composition Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 依赖扫描自动修复
description: 自动打开合并请求以修复易受攻击的依赖项。
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署
- Status: 测试版

{{< /details >}}

依赖扫描自动修复功能会打开一个合并请求，将易受攻击的依赖项升级到可用的非易受攻击版本。服务账号会在无需人工输入的情况下创建合并请求，然后该请求会经过标准的审核和批准流程。

在测试版中，依赖扫描自动修复支持两个可独立配置的功能：

- 依赖版本升级：极狐GitLab 会打开更新易受攻击依赖项的合并请求。
- Agentic 破坏性变更解决：当版本升级因破坏性变更导致流水线失败时，极狐GitLab Duo 会尝试解决该问题。有关更多信息，请参阅[启用 Agentic 破坏性变更解决](#enable-agentic-breaking-change-resolution)。

有关正式发布路线图，请参阅[史诗 19244](https://gitlab.com/groups/gitlab-org/-/work_items/19244)。

<a id="turn-on-dependency-scanning-auto-remediation"></a>

## 开启依赖扫描自动修复

先决条件：

- 必须已启用[依赖扫描](../dependency_scanning/_index.md)并生成结果。
- 项目必须使用[受支持的包管理器](#supported-package-managers)。
- 项目必须关联依赖扫描自动修复配置文件。有关说明，请参阅[依赖扫描自动修复配置文件](../configuration/security_configuration_profiles.md#dependency-scanning-auto-remediation-profile)。

要触发漏洞检测和自动修复，请运行流水线。当极狐GitLab 检测到有可用修复的漏洞时，依赖扫描自动修复会自动触发。

<a id="how-dependency-version-bumps-work"></a>

## 依赖版本升级的工作原理

依赖扫描自动修复配置文件控制此行为。使用默认配置文件：

- 严重性阈值：极狐GitLab 会修复严重性为 `high` 或以上的漏洞。
- 冷却期：极狐GitLab 会排除最近七天内发布的修复版本。
- 升级策略：极狐GitLab 仅建议补丁和次要版本升级，除非已启用 [Agentic 破坏性变更解决](#enable-agentic-breaking-change-resolution)。
- 打开的合并请求数量限制：每个项目同时最多可打开 10 个自动修复合并请求。在现有合并请求被合并或关闭之前，极狐GitLab 不会创建新的合并请求。

每次流水线运行后，极狐GitLab 会根据这些值检查依赖扫描结果。对于每个符合条件的漏洞：

1. 极狐GitLab 确定最近的非破坏性升级路径。
1. 服务账号打开一个更新相关清单文件的合并请求。
1. 极狐GitLab 将项目的活跃维护者指派为审核人。如果不存在活跃维护者，则合并请求保持打开状态，且不指派审核人。
1. 该合并请求会经过您项目的标准批准流程。

在测试版期间，极狐GitLab 每次处理三个漏洞，从严重性最高的发现结果开始。

<a id="enable-agentic-breaking-change-resolution"></a>

## 启用 Agentic 破坏性变更解决

当版本升级因破坏性变更导致流水线失败时，极狐GitLab Duo 可以尝试自动解决该破坏性变更。此功能独立于依赖版本升级功能，并有自己的开关。

先决条件：

- 项目必须已启用 [极狐GitLab Duo](../../gitlab_duo/_index.md)。
- 必须为项目的根命名空间启用 `enable_dependency_bump_breaking_changes` [功能标志](../../../administration/feature_flags/_index.md)。

要启用 Agentic 破坏性变更解决，请使用 [Projects API](../../../api/projects.md#update-a-project) 将项目的 `duo_dependency_bump_breaking_changes_enabled` 设置为 `true`。

<a id="configure-scheduler-concurrency"></a>

## 配置调度器并发

管理员可以限制 Sidekiq 集群中并发运行的自动修复调度器作业数量。使用 `security_update_scheduler_max_concurrency` [应用程序设置](../../../api/settings.md) 来设置上限。默认值为 `30`，上限为 `200`。将该值设置为 `0` 可暂停调度。

<a id="supported-package-managers"></a>

## 受支持的包管理器

依赖扫描自动修复支持以下包管理器：

| 语言                    | 包管理器                            | 文件                                                                          |
| ----------------------- | ------------------------------------ | ------------------------------------------------------------------------------ |
| Ruby                    | Bundler                             | `Gemfile`, `Gemfile.lock`                                                      |
| Java                    | Maven                               | `pom.xml`                                                                      |
| Java                    | Gradle                              | `build.gradle`, `build.gradle.kts`                                             |
| Python                  | pip, pipenv, poetry, setuptools, uv | `requirements.txt`, `Pipfile`, `pyproject.toml`, `setup.py`, `uv.lock`         |
| JavaScript / TypeScript | npm, yarn, pnpm, bun                | `package.json`, `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`, `bun.lock` |
| Go                      | Go modules                          | `go.mod`, `go.sum`                                                             |
| Rust                    | Cargo                               | `Cargo.toml`, `Cargo.lock`                                                     |

对其他生态系统的支持已在[史诗 19244](https://gitlab.com/groups/gitlab-org/-/work_items/19244) 中提出。

<a id="known-issues"></a>

## 已知问题

在测试版阶段：

- 冷却期：极狐GitLab 不会建议使用最近七天内发布的修复版本，以降低修复到后来被发现存在缺陷或恶意的版本的风险。
- 版本升级范围：仅建议补丁和次要版本升级。更可能引入破坏性变更的主要版本升级，除非启用了 Agentic 破坏性变更解决，否则不会尝试。
- 每次流水线运行处理一个漏洞：每次流水线运行仅针对一个具有可用修复的漏洞。将多个修复合并到一个合并请求中的功能已在[史诗 19244](https://gitlab.com/groups/gitlab-org/-/work_items/19244) 中提出。
- 无可用修复：如果某个漏洞不存在非破坏性的修复版本，则不会为该发现结果创建合并请求。
