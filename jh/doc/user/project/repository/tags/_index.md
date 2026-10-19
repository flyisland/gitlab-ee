---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Use Git tags to mark important points in a repository's history, and trigger CI/CD pipelines.
title: 标签
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

在 Git 中，标签标记着仓库历史中的一个重要节点。
Git 支持两种类型的标签：

- 轻量标签指向特定的提交，不包含其他信息。
  也称为软标签。可根据需要创建或删除。
- 附注标签包含元数据，可以进行签名以用于验证，
  并且不可更改。

标签的创建或删除可用作自动化的触发器，包括：

- 使用 [Webhook](../../integrations/webhook_events.md#tag-events) 自动执行 Slack 通知等操作。
- 通知 [仓库镜像](../mirror/_index.md) 进行更新。
- 使用 [`if: $CI_COMMIT_TAG`](../../../../ci/jobs/job_rules.md#common-if-clauses-with-predefined-variables) 运行 CI/CD 流水线。

当你 [创建版本](../../releases/_index.md) 时，极狐GitLab 也会创建一个标签来标记该发布点。
许多项目会将附注发布标签与稳定分支结合使用。可以考虑自动设置部署或发布标签。

在极狐GitLab UI 中，每个标签显示：

![单标签示例](img/tag-display_v18_3.png)

- 标签名称 ({{< icon name="tag" >}})
- 复制标签名称 ({{< icon name="copy-to-clipboard" >}})
- 可选。如果标签为 [受保护](../../protected_tags.md) 的，会显示一个 **受保护** 徽章。
- 提交 SHA ({{< icon name="commit" >}})，链接至该提交的内容。
- 提交的标题及创建日期。
- 可选。指向该版本的链接 ({{< icon name="rocket" >}})。
- 可选。如果已运行流水线，会显示当前流水线状态。
- 下载链接，用于获取与标签关联的源代码和产物。
- 一个 [**创建版本**](../../releases/_index.md#create-a-release) ({{< icon name="pencil" >}}) 链接。
- 删除标签的链接。

<a id="view-tags-for-a-project"></a>

## 查看项目的标签

要查看项目的所有现有标签：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **代码** > **标签**。

<a id="view-tagged-commits-in-the-commits-list"></a>

## 在提交列表中查看带标签的提交

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **代码** > **提交**。
1. 带有标签的提交会标注标签图标 ({{< icon name="tag" >}}) 及标签名称。
   此示例展示了一个标记为 `v1.26.0` 的提交：

   ![提交视图中的带标签提交](img/tags_commits_view_v15_10.png)

要查看此标签中的提交列表，请选择该标签名称。

<a id="create-a-tag"></a>

## 创建标签

可以从命令行或极狐GitLab UI 创建标签。

<a id="from-the-command-line"></a>

### 通过命令行

要通过命令行创建轻量标签或附注标签并将其推送到上游：

1. 要创建轻量标签，运行命令 `git tag TAG_NAME`，将 `TAG_NAME` 替换为您所需的标签名称。
1. 要创建附注标签，请从命令行运行 `git tag` 的某个版本：

   ```shell
   # 在此简短版本中，附注标签的名称为“v1.0”，
   # 消息为“Version 1.0”。
   git tag -a v1.0 -m "Version 1.0"

   # 使用此版本在文本编辑器中
   # 为附注标签“v1.0”编写更长的标签消息。
   git tag -a v1.0
   ```

1. 使用 `git push origin --tags` 将您的标签推送到上游。

<a id="from-the-ui"></a>

### 通过 UI

要通过极狐GitLab UI 创建标签：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **代码** > **标签**。
1. 选择 **新建标签**。
1. 提供 **标签名称**。
1. 在 **创建自** 中，选择一个现有的分支名称、标签或提交 SHA。
1. 可选。添加一条 **消息** 以创建附注标签，或留空以创建轻量标签。
1. 选择 **创建标签**。

<a id="name-your-tag"></a>

## 命名您的标签

Git 强制执行 [标签命名规则](https://git-scm.com/docs/git-check-ref-format) 以确保标签名称与其他工具保持兼容。极狐GitLab 对标签名称增加了额外要求，并为结构良好的标签名称提供了便利。

极狐GitLab 对所有标签实施以下附加规则：

- 标签名称中不允许包含空格。
- 禁止以 40 个或 64 个十六进制字符开头的标签名称，因为它们类似于 Git 提交哈希。
- 标签名称不能以 `-`、`refs/heads/`、`refs/tags/` 或 `refs/remotes/` 开头。
- 标签名称区分大小写。

<a id="copy-a-tag-name"></a>

## 复制标签名称

要将标签名称复制到剪贴板：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **代码** > **标签**。
1. 在标签名称旁边，选择 **复制标签名称** ({{< icon name="copy-to-clipboard" >}})。

<a id="prevent-tag-deletion"></a>

## 阻止删除标签

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

要阻止用户通过 `git push` 删除标签，请创建 [推送规则](../push_rules.md)。

<a id="trigger-pipelines-from-a-tag"></a>

## 通过标签触发流水线

极狐GitLab CI/CD 提供了一个预定义变量 [`CI_COMMIT_TAG`](../../../../ci/variables/predefined_variables.md)，用于在您的流水线配置中识别标签。您可以在作业规则和工作流规则中使用此变量来判断流水线是否由标签触发。

默认情况下，如果您的 CI/CD 作业没有设置特定规则，它们会被包含在任何新创建标签的标签流水线中。仅当标签指向某个提交时，才会创建标签流水线。

在项目的 CI/CD 流水线配置 `.gitlab-ci.yml` 文件中，您可以使用 `CI_COMMIT_TAG` 变量来控制新标签的流水线：

- 在作业级别，使用 [`rules:if`](../../../../ci/yaml/_index.md#rulesif)。
- 在流水线级别，使用 [`workflow`](../../../../ci/yaml/workflow.md) 关键字。

<a id="trigger-security-scans-in-tag-pipelines"></a>

## 在标签流水线中触发安全扫描

默认情况下，扫描执行策略仅在分支上运行，而不在标签上运行。但是，您可以配置流水线执行策略以在标签上运行安全扫描。

要在标签上运行安全扫描：

1. 创建一个 CI/CD 配置 YAML 文件，其中包含扩展安全扫描器模板的自定义作业，并包含在标签上运行的规则。
1. 创建一个流水线执行策略，将此配置注入您的流水线。

<a id="example-pipeline-execution-policy"></a>

### 流水线执行策略示例

此示例展示了如何创建在标签上运行依赖扫描和 SAST 扫描的流水线执行策略：

```yaml
pipeline_execution_policy:
- name: Pipeline Execution Policy
  description: Run security scans on tags
  enabled: true
  pipeline_config_strategy: inject_policy
  content:
    include:
    - project: <Project path to YAML>
      file: tag-security-scans.yml
  skip_ci:
    allowed: false
```

<a id="example-cicd-configuration"></a>

### CI/CD 配置示例

此示例展示了如何扩展安全扫描作业以在标签上运行：

```yaml
include:
  - template: Jobs/Dependency-Scanning.gitlab-ci.yml
  - template: Jobs/SAST.gitlab-ci.yml

# Extend dependency scanning to run on tags
gemnasium-python-dependency_scanning_tags:
  extends: gemnasium-python-dependency_scanning
  rules:
    - if: $CI_COMMIT_TAG

# Extend SAST scanning to run on tags
semgrep-sast_tags:
  extends: semgrep-sast
  rules:
    - if: $CI_COMMIT_TAG

# Example of a custom job that runs only on tags
policy_job_for_tags:
  script:
    - echo "This job runs only on tags"
  rules:
    - if: $CI_COMMIT_TAG

# Example of a job that runs on all pipelines
policy_job_always:
  script:
    - echo "This policy job runs always."
```

<a id="related-topics"></a>

## 相关主题

- [标签 (Git 参考页)](https://git-scm.com/book/en/v2/Git-Basics-Tagging)
- [受保护的标签](../../protected_tags.md)
- [比较版本](../compare_revisions.md)
- [标签 API](../../../../api/tags.md)
