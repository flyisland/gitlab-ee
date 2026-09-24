---
stage: Analytics
group: Platform Insights
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 集成错误追踪
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

本指南提供有关如何为项目设置集成错误追踪的基本信息，使用来自不同语言的示例。

极狐GitLab 可观测性提供的错误追踪基于 [Sentry SDK](https://docs.sentry.io/)。
有关如何在应用程序中使用 Sentry SDK 的更多信息和示例，请参阅 [Sentry SDK 文档](https://docs.sentry.io/platforms/)。

<a id="enable-error-tracking-for-a-project"></a>

## 为项目启用错误追踪

无论你使用哪种编程语言，你首先需要为你的极狐GitLab 项目启用错误追踪。本指南使用 `JihuLab.com` 实例。

先决条件：

- 你必须有一个要为其启用错误追踪的项目。了解如何[创建项目](../user/project/_index.md)。

要以极狐GitLab 作为后端启用错误追踪：

1. 在顶部栏中，选择 **搜索或跳转到** 并查找你的项目。
1. 前往 **设置** > **监控**。
1. 展开 **错误追踪**。
1. 对于 **启用错误追踪**，选择 **启用**。
1. 对于 **错误追踪后端**，选择 **极狐GitLab**。
1. 选择 **保存修改**。
1. 复制 **数据源名称（DSN）** 字符串。你需要它来配置你的 SDK 实施。

<a id="configure-user-tracking"></a>

## 配置用户追踪

要追踪受错误影响的用户数量：

- 在插装代码中，确保每个用户都被唯一标识。你可以使用用户 ID、姓名、电子邮件地址或 IP 地址来标识用户。

例如，如果你使用 [Python](https://docs.sentry.io/platforms/python/enriching-events/identify-user/)，你可以通过电子邮件识别用户：

```python
sentry_sdk.set_user({ email: "john.doe@example.com" });
```

有关用户识别的更多信息，请参阅 [Sentry 文档](https://docs.sentry.io/)。

<a id="view-tracked-errors"></a>

## 查看已追踪的错误

在应用程序通过 Sentry SDK 将错误发送到错误追踪 API 之后，这些错误就会在极狐GitLab UI 中显示。要查看它们：

1. 在顶部栏中，选择 **搜索或跳转到** 并查找你的项目。
1. 前往 **监控** > **错误追踪** 以查看未处理错误的列表：

   ![MonitorListErrors](img/list_errors_v16_0.png)

1. 选择一个错误以查看 **错误详情** 视图：

   ![MonitorDetailErrors](img/detail_errors_v16_0.png)

   此页面显示异常的更多详细信息，包括：

   - 总发生次数。
   - 受影响的用户总数。
   - 首次出现：日期和提交 ({{< icon name="commit" >}})。
   - 最后出现日期，显示为相对日期。要查看时间戳，请将鼠标悬停在日期上。
   - 每小时错误频率的条形图。要查看特定小时内的错误总数，请将鼠标悬停在一个条形上。
   - 堆栈跟踪。

<a id="create-an-issue-from-an-error"></a>

### 从错误创建议题

如果你想要追踪与错误相关的工作，你可以直接从错误创建一个议题：

- 从 **错误详情** 视图中，选择 **创建议题**。

随即创建一个议题。议题描述包含错误堆栈跟踪。

<a id="analyze-an-errors-details"></a>

### 分析错误详情

要查看错误的完整时间戳：

- 在 **错误详情** 页面上，将鼠标悬停在 **最后出现** 日期上。

在以下示例中，错误发生在 11:41 CEST：

![MonitorDetailErrors](img/last_seen_v16_10.png)

**最近 24 小时** 图表衡量了该错误每小时发生的次数。将鼠标指向 `11 am` 条形时，对话框显示该错误出现了 239 次：

![MonitorDetailErrors](img/error_bucket_v16_10.png)

**最后出现** 字段在整小时结束之前不会更新，这是因为调用所使用的库 [`import * as timeago from 'timeago.js'`](https://jihulab.com/gitlab-cn/gitlab/-/blob/master/app/assets/javascripts/lib/utils/datetime/timeago_utility.js#L1)。

<a id="emit-errors"></a>

## 发送错误

<a id="supported-language-sdks-sentry-types"></a>

### 支持的语言 SDK 与 Sentry 类型

极狐GitLab 错误追踪支持以下事件类型：

| 语言     | 已测试的 SDK 客户端和版本          | 端点       | 支持的事件类型                    |
| -------- | ----------------------------------- | ---------- | --------------------------------- |
| Go       | `sentry-go/0.20.0`                  | `store`    | `exception`、`message`            |
| Java     | `sentry.java:6.18.1`                | `envelope` | `exception`、`message`            |
| NodeJS   | `sentry.javascript.node:7.38.0`     | `envelope` | `exception`、`message`            |
| PHP      | `sentry.php/3.18.0`                 | `store`    | `exception`、`message`            |
| Python   | `sentry.python/1.21.0`              | `envelope` | `exception`、`message`、`session` |
| Ruby     | `sentry.ruby:5.9.0`                 | `envelope` | `exception`、`message`            |
| Rust     | `sentry.rust/0.31.0`                | `envelope` | `exception`、`message`、`session` |

另请参阅[支持的语言 SDK 的工作示例](https://jihulab.com/gitlab-cn/opstrace/opstrace/-/tree/main/test/sentry-sdk/testdata/supported-sdk-clients)，展示了如何使用该 SDK 捕获异常、事件或消息。

有关更多信息，请参阅特定语言的 [Sentry SDK 文档](https://docs.sentry.io/)。

<a id="rotate-generated-dsn"></a>

## 轮换生成的 DSN

> [!warning]
> 根据 Sentry 的说法，[保持 DSN 公开是安全的](https://docs.sentry.io/concepts/key-terms/dsn-explainer/#dsn-utilization)，但这增加了恶意用户将垃圾事件发送到 Sentry 的可能性。因此，如果可能的话，你应该将 DSN 保密。这不适用于客户端应用程序，因为 DSN 会被加载并存储在用户设备上。

先决条件：

- 你需要项目的数字 [项目 ID](../user/project/working_with_projects.md#find-the-project-id)。

要轮换 Sentry DSN：

1. 使用 `api` 范围[创建访问令牌](../user/profile/personal_access_tokens.md#create-a-personal-access-token)。复制此值，因为在后续步骤中需要它。
1. 使用[错误追踪 API](../api/error_tracking.md) 创建一个新的 Sentry DSN，将 `<your_access_token>` 和 `<your_project_number>` 替换为你的值：

   ```shell
   curl --request POST \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Content-Type: application/json" \
     --url "https://gitlab.example.com/api/v4/projects/<your_project_number>/error_tracking/client_keys"
   ```

1. 获取可用的客户端密钥（Sentry DSN）。确保新创建的 Sentry DSN 就位。使用旧客户端密钥的密钥 ID 运行以下命令，将 `<your_access_token>` 和 `<your_project_number>` 替换为你的值：

   ```shell
   curl --header "PRIVATE-TOKEN: <your_access_token>" \
     --url "https://gitlab.example.com/api/v4/projects/<your_project_number>/error_tracking/client_keys"
   ```

1. 删除旧的客户端密钥：

   ```shell
   curl --request DELETE \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --url "https://gitlab.example.com/api/v4/projects/<your_project_number>/error_tracking/client_keys/<key_id>"
   ```

<a id="debug-sdk-issues"></a>

## 调试 SDK 问题

Sentry 支持的大多数语言都在初始化过程中提供了一个 `debug` 选项。在调试发送错误相关问题时，`debug` 选项可以提供帮助。还有其他选项可以在将数据发送到 API 之前输出 JSON。

<a id="data-retention"></a>

## 数据保留

极狐GitLab 对所有错误的保留期限为 90 天。