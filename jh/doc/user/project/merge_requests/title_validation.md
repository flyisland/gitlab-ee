---
stage: Create
group: Code Review
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Use merge request title validation to enforce naming conventions and block merges when titles do not match a configured regex pattern.
title: 合并请求标题验证
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 于 极狐GitLab 17.11 引入，并以 [功能标志](../../../administration/feature_flags/_index.md) 的形式提供，命名为 `merge_request_title_regex`。默认禁用。
- 于 极狐GitLab 18.10 在 JihuLab.com 和私有化部署上启用。
- 于 极狐GitLab 18.10 全面可用（GA）。功能标志 `merge_request_title_regex` 已移除。

{{< /history >}}

你可以通过将合并请求标题与 RE2 正则表达式模式进行匹配来强制命名约定。当你为项目配置标题模式后，标题不符合该模式的合并请求将无法合并。

使用标题验证可以：

- 在标题中要求 Jira 或议题跟踪工具的票证引用。
- 强制执行 [常规提交](https://www.conventionalcommits.org/) 格式。
- 为发版管理或治理工作流标准化标题前缀。

<a id="configure-merge-request-title-validation"></a>

## 配置合并请求标题验证

配置一个正则表达式模式，项目中所有合并请求的标题在允许合并前必须与该模式匹配。

先决条件：

- 项目的维护者或所有者角色。

要配置标题验证：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **设置 > 合并请求**。
1. 在 **标题模式** 文本框中，输入正则表达式模式。
1. 在 **标题示例** 文本框中，输入对预期格式的描述。
   包含一个有效示例，以便合并请求作者知道该使用什么。
1. 选择 **保存更改**。

![项目的标题验证设置字段。](img/title_validation_settings_v18_10.png)

当你设置了 **标题模式** 时，也必须设置 **标题示例**。当用户的合并请求标题不匹配模式时，**标题示例** 会显示给用户。

要移除标题验证，请清空 **标题模式** 和 **标题示例** 文本框，然后选择 **保存更改**。

你还可以通过 API 配置标题验证，请 [使用 projects API](../../../api/projects.md)。

<a id="regex-syntax"></a>

## 正则表达式语法

标题验证使用 [RE2 语法](https://github.com/google/re2/wiki/Syntax)，而非 PCRE。RE2 不支持反向引用或先行/后行断言。

模式和描述字段每个最大长度为 255 个字符。

<a id="example-patterns"></a>

### 示例模式

以下是一些正则表达式模式示例：

- Jira 票证引用（有效标题示例：`PROJ-123 Fix login bug`）：

  ```plaintext
  ^[A-Z]+-\d+ .+
  ```

- 常规提交（有效标题示例：`feat(auth): add SSO support`）：

  ```plaintext
  ^(feat|fix|docs|chore|refactor|test|style)(\(.+\))?: .+
  ```

- 自定义前缀（有效标题示例：`BUGFIX: resolve timeout error`）：

  ```plaintext
  ^(FEATURE|BUGFIX|HOTFIX): .+
  ```

- 方括号分类（有效标题示例：`[Feature] Add dark mode`）：

  ```plaintext
  ^\[.+\] .+
  ```

<a id="validation-enforcement"></a>

## 验证执行

配置标题验证模式后：

- 标题不符合模式的合并请求无法合并。
- 标题检查会作为一个合并检查，与其他检查（如审批、流水线状态和主题解决）一同显示。
- 如果启用了 [自动合并](auto_merge.md)，合并请求会等待标题匹配模式后再合并。
- 验证在合并时应用于当前标题。作者可以在合并前的任何时间点更新标题。

![合并请求因标题验证检查而被阻止。](img/title_validation_failed_v18_10.png)

<a id="troubleshooting"></a>

## 故障排查

<a id="merge-request-cannot-be-merged-due-to-title-validation"></a>

### 因标题验证导致合并请求无法合并

如果合并请求因标题验证而被阻止：

1. 检查合并请求的合并检查部分，找到标题验证失败项。
1. 更新合并请求标题，使其匹配在 **设置** > **合并请求** > **标题模式** 中配置的模式。
1. 使用错误消息中显示的 **标题示例** 作为预期格式的参考。

<a id="draft-merge-requests"></a>

### 草稿合并请求

标题验证应用于完整的标题字符串，包括任何 `Draft:` 前缀。如果你的正则表达式模式未考虑 `Draft:` 前缀，草稿合并请求可能会验证失败。请考虑使用类似 `^(Draft: )?YOUR_PATTERN` 的模式，以同时允许草稿和非草稿标题。

<a id="regex-pattern-does-not-match-as-expected"></a>

### 正则表达式模式不符合预期

标题验证使用 [RE2 语法](https://github.com/google/re2/wiki/Syntax)，这与许多在线正则表达式测试器使用的 PCRE 语法不同。要验证你的模式：

- 使用兼容 RE2 的正则表达式测试器。
- 检查你是否使用了不支持的功能，如反向引用或先行断言。
- 验证特殊字符是否正确转义。