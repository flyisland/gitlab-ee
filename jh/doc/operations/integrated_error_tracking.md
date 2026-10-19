---
stage: Analytics
group: Platform Insights
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 集成错误跟踪
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

本指南提供有关如何为项目设置集成错误跟踪的基本信息，并使用了不同语言的示例。

极狐GitLab 可观测性提供的错误跟踪基于
[Sentry SDK](https://docs.sentry.io/)。
有关如何在应用程序中使用 Sentry SDK 的更多信息和示例，
请参阅 [Sentry SDK 文档](https://docs.sentry.io/platforms/)。

<a id="enable-error-tracking-for-a-project"></a>

## 为项目启用错误跟踪

无论您使用哪种编程语言，首先都需要为极狐GitLab 项目启用错误跟踪。本指南使用 `GitLab.com` 实例。

先决条件：

- 您必须拥有一个要为其启用错误跟踪的项目。
  请参阅如何[创建项目](../user/project/_index.md)。

要以极狐GitLab 作为后端启用错误跟踪：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 转到**设置** > **监控**。
1. 展开**错误跟踪**。
1. 对于**启用错误跟踪**，选择**活跃**。
1. 对于**错误跟踪后端**，选择 **极狐GitLab**。
1. 选择**保存更改**。
1. 复制**数据源名称 (DSN)** 字符串。您需要用它来配置 SDK 实现。

<a id="configure-user-tracking"></a>

## 配置用户跟踪

要跟踪受某个错误影响的用户数量：

- 在埋点代码中，确保每个用户都有唯一标识。
  您可以使用用户 ID、姓名、电子邮件地址或 IP 地址来标识用户。

例如，如果您使用
[Python](https://docs.sentry.io/platforms/python/enriching-events/identify-user/)，
可以通过电子邮件标识用户：

```python
sentry_sdk.set_user({ email: "john.doe@example.com" });
```

有关用户标识的更多信息，请参阅 [Sentry 文档](https://docs.sentry.io/)。

<a id="view-tracked-errors"></a>

## 查看已跟踪的错误

在您的应用程序通过 Sentry SDK 向错误跟踪 API 发送错误后，这些错误便可在极狐GitLab UI 中查看。要查看它们：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 转到**监控** > **错误跟踪**，查看未解决错误的列表：

   ![错误跟踪页面上的未解决错误列表。](img/list_errors_v16_0.png)

1. 选择一个错误以查看**错误详情**视图：

   ![错误详情视图，包含异常详情和堆栈追踪。](img/detail_errors_v16_0.png)

   此页面显示异常的更多详情，包括：

   - 发生总次数。
   - 受影响的用户总数。
   - 首次出现：日期和提交 ({{< icon name="commit" >}})。
   - 最后出现日期，以相对日期显示。要查看时间戳，请将鼠标悬停在该日期上。
   - 每小时错误频率的柱状图。要查看特定小时内的错误总数，请将鼠标悬停在某个柱上。
   - 堆栈追踪。

<a id="create-an-issue-from-an-error"></a>

### 从错误创建议题

如果您想跟踪与某个错误相关的工作，可以直接从该错误创建议题：

- 在**错误详情**视图中，选择**创建议题**。

系统会创建一个议题。议题描述中包含错误堆栈追踪。

<a id="analyze-an-errors-details"></a>

### 分析错误的详情

要查看错误的完整时间戳：

- 在**错误详情**页面上，将鼠标悬停在**最后出现**日期上。

在以下示例中，错误发生在欧洲中部夏令时间 11:41：

![在最后出现日期上显示完整时间戳的工具提示。](img/last_seen_v16_10.png)

**最近 24 小时**图表衡量此错误每小时发生的次数。当您指向 `11 am` 柱时，对话框显示该错误出现了 239 次：

![每小时错误频率的柱状图，11 am 时有 239 个错误。](img/error_bucket_v16_10.png)

由于用于调用的库
[`import * as timeago from 'timeago.js'`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/app/assets/javascripts/lib/utils/datetime/timeago_utility.js#L1)，
**最后出现**字段要到整点结束后才会更新。

<a id="emit-errors"></a>

## 发送错误

<a id="supported-language-sdks--sentry-types"></a>

### 支持的语言 SDK 和 Sentry 类型

极狐GitLab 错误跟踪支持以下事件类型：

| 语言 | 经过测试的 SDK 客户端和版本   | 端点   | 支持的条目类型              |
| -------- | ------------------------------- | ---------- | --------------------------------- |
| Go       | `sentry-go/0.20.0`              | `store`    | `exception`, `message`            |
| Java     | `sentry.java:6.18.1`            | `envelope` | `exception`, `message`            |
| NodeJS   | `sentry.javascript.node:7.38.0` | `envelope` | `exception`, `message`            |
| PHP      | `sentry.php/3.18.0`             | `store`    | `exception`, `message`            |
| Python   | `sentry.python/1.21.0`          | `envelope` | `exception`, `message`, `session` |
| Ruby     | `sentry.ruby:5.9.0`             | `envelope` | `exception`, `message`            |
| Rust     | `sentry.rust/0.31.0`            | `envelope` | `exception`, `message`, `session` |

有关此表格的详细版本，请参阅[议题 1737](https://gitlab.com/gitlab-org/opstrace/opstrace/-/issues/1737)。

另请参阅[受支持语言 SDK 的可运行示例](https://gitlab.com/gitlab-org/opstrace/opstrace/-/tree/main/test/sentry-sdk/testdata/supported-sdk-clients)，其中展示了如何使用该 SDK 捕获异常、事件或消息。有关更多信息，请参阅特定语言的 [Sentry SDK 文档](https://docs.sentry.io/)。

<a id="rotate-generated-dsn"></a>

## 轮换生成的 DSN

> [!warning]
> 根据 Sentry 的说法，[将 DSN 公开是安全的](https://docs.sentry.io/concepts/key-terms/dsn-explainer/#dsn-utilization)，但这会让恶意用户有可能向 Sentry 发送垃圾事件。因此，如果可能，您应保密 DSN。这不适用于客户端应用程序，因为在这类应用程序中 DSN 会被加载，因而存储在用户设备上。

先决条件：

- 您需要项目的数字[项目 ID](../user/project/working_with_projects.md#find-the-project-id)。

要轮换 Sentry DSN：

1. [创建访问令牌](../user/profile/personal_access_tokens.md#create-a-personal-access-token)，
   并授予 `api` 范围。复制此值，因为后续步骤中需要用到它。
1. 使用[错误跟踪 API](../api/error_tracking.md) 创建新的 Sentry DSN，
   将 `<your_access_token>` 和 `<your_project_number>` 替换为您的值：

   ```shell
   curl --request POST \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Content-Type: application/json" \
     --url "https://gitlab.example.com/api/v4/projects/<your_project_number>/error_tracking/client_keys"
   ```

1. 获取可用的客户端密钥（Sentry DSN）。确保您新创建的 Sentry DSN
   已就位。使用旧客户端密钥的密钥 ID 运行以下命令，将 `<your_access_token>`
   和 `<your_project_number>` 替换为您的值：

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

Sentry 支持的大多数语言都会在初始化过程中公开一个 `debug` 选项。当您调试发送错误相关的问题时，`debug` 选项可以为您提供帮助。还有其他选项可以在将数据发送到 API 之前输出 JSON。

<a id="data-retention"></a>

## 数据保留

极狐GitLab 对所有错误设有 90 天的保留期限。

要就错误跟踪的缺陷或功能提供反馈，请在[反馈议题](https://gitlab.com/gitlab-org/opstrace/opstrace/-/issues/2362)中发表评论，或提交[新议题](https://gitlab.com/gitlab-org/opstrace/opstrace/-/issues/new)。
