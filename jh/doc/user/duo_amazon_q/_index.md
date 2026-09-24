---
stage: AI-powered
group: AI Framework
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐 GitLab Duo
---

{{< details >}}

- Tier: 旗舰版
- Add-on: 极狐 GitLab Duo
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 在极狐 GitLab 17.7 中作为 [测试版](../../policy/development_stages_support.md#beta) 引入，带有名为 `amazon_q_integration` 的 [功能标志](../../administration/feature_flags/_index.md)。默认禁用。
- 功能标志 `amazon_q_integration` 在极狐 GitLab 17.8 中移除。
- 在极狐 GitLab 17.11 中 GA，并提供额外的极狐 GitLab Duo 功能支持。

{{< /history >}}

> [!note]
> 极狐 GitLab Duo 不能与其他极狐 GitLab Duo 附加组件组合使用。

极狐 GitLab Duo：

- 可以在议题和合并请求中执行各种任务。
- [包含许多其他极狐 GitLab Duo 功能](../gitlab_duo/feature_summary.md)。

要获取极狐 GitLab Duo 的订阅，请联系您的客户经理。

## 设置极狐 GitLab Duo

<a id="set-up-gitlab-duo-with-amazon-q"></a>

## 设置极狐 GitLab Duo

当您拥有极狐 GitLab Duo 订阅和极狐 GitLab 17.11 或更高版本时，您可以 [在您的实例上设置极狐 GitLab Duo](setup.md)。

## 在议题中使用极狐 GitLab Duo

<a id="use-gitlab-duo-with-amazon-q-in-an-issue"></a>

## 在议题中使用极狐 GitLab Duo

要在议题中调用极狐 GitLab Duo，您将使用 [快速操作](../project/quick_actions.md)。

### 将想法转化为合并请求

<a id="turn-an-idea-into-a-merge-request"></a>

### 将想法转化为合并请求

将议题中的想法转化为包含建议实现的合并请求。

极狐 GitLab Duo 使用议题标题和描述以及项目上下文来创建合并请求，其中包含解决议题的代码。

#### 从议题描述

<a id="from-the-issue-description"></a>

#### 从议题描述

1. 创建新议题，或打开现有议题，然后在右上角选择 **编辑**。
1. 在描述框中，输入 `/q dev`。
1. 选择 **保存更改**。

#### 从评论

<a id="from-a-comment"></a>

#### 从评论

1. 在议题的评论中，输入 `/q dev`。
1. 选择 **评论**。

### 升级 Java

<a id="upgrade-java"></a>

### 升级 Java

极狐 GitLab Duo 可以分析 Java 8 或 11 代码，并确定必要的 Java 更改以将代码更新为 Java 17。

前提条件：

- 您必须 [为项目配置 Runner 和 CI/CD 流水线](../../ci/_index.md)。
- 您的 `pom.xml` 文件必须具有 [source 和 target](https://maven.apache.org/plugins/maven-compiler-plugin/examples/set-compiler-source-and-target.html)。

要升级 Java：

1. 创建议题。
1. 在议题标题和描述中，解释您想要升级 Java。
   您无需输入版本详细信息。极狐 GitLab Duo 可以确定版本。
1. 保存议题。然后，在评论中，输入 `/q transform`。
1. 选择 **评论**。

CI/CD 作业启动。将显示包含详细信息和作业链接的评论。

- 如果作业成功，将创建包含升级所需代码更改的合并请求。
- 如果作业失败，评论将提供有关潜在修复的详细信息。

## 在合并请求中使用极狐 GitLab Duo

<a id="use-gitlab-duo-with-amazon-q-in-a-merge-request"></a>

## 在合并请求中使用极狐 GitLab Duo

要在合并请求中调用极狐 GitLab Duo，您将使用 [快速操作](../project/quick_actions.md)。

### 审查合并请求

<a id="review-a-merge-request"></a>

### 审查合并请求

极狐 GitLab Duo 可以分析您的合并请求并建议改进代码。
它可以发现安全问题、质量问题、低效率和其他错误。

[您可以让极狐 GitLab Duo 自动审查](setup.md#enter-the-arn-in-gitlab-and-enable-amazon-q)
当您打开或重新打开合并请求时，或者您可以手动启动审查。

要手动启动：

1. 打开您的合并请求。
1. 在 **概述** 选项卡上，在评论中，输入 `/q review`。
1. 选择 **评论**。

极狐 GitLab Duo 执行合并请求更改的审查
并在评论中显示结果。

### 根据反馈进行代码更改

<a id="make-code-changes-based-on-feedback"></a>

### 根据反馈进行代码更改

极狐 GitLab Duo 可以根据审查者反馈进行代码更改。

1. 打开具有审查者反馈的合并请求。
1. 在 **概述** 选项卡上，转到您要解决的评论。
1. 在评论下方，在 **回复** 框中，输入 `/q dev`。
1. 选择 **立即添加评论**。

极狐 GitLab Duo 根据审查者的评论和反馈提议对合并请求进行更改。

### 生成单元测试

<a id="generate-unit-tests"></a>

### 生成单元测试

使用极狐 GitLab Duo 为您的代码生成新的单元测试。

#### 从议题

<a id="from-an-issue"></a>

#### 从议题

1. 创建议题。
1. 使用以下选项之一请求为您的代码生成测试：
   - 在议题描述中，描述您的请求并选择 **保存更改**。
   - 在评论中，输入 `/q dev` 并选择 **评论**。

极狐 GitLab Duo 创建包含建议测试的合并请求。

#### 从合并请求

<a id="from-a-merge-request"></a>

#### 从合并请求

1. 打开您的合并请求。
1. 在 **更改** 选项卡上，在您想要添加测试的位置留下内联评论。在反馈中包含尽可能多的详细信息，例如文件名、类名和行号。
1. 在评论中，在新行上输入 `/q dev` 并选择 **立即添加评论**。

极狐 GitLab Duo 使用建议的测试更新合并请求。

## 相关主题

<a id="related-topics"></a>

## 相关主题

- [设置极狐 GitLab Duo](setup.md)
- [极狐 GitLab Duo 身份验证和授权](../gitlab_duo/security.md)
