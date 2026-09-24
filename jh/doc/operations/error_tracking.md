---
stage: Analytics
group: Platform Insights
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.jihulab.com/handbook/product/ux/technical-writing/#assignments>
title: 错误追踪
description: 错误追踪、日志记录、调试和数据保留。
---

错误追踪帮助开发者发现和查看其应用程序生成的错误。
由于错误信息会显示在代码开发的位置，错误追踪提高了效率和感知度。
用户可以在[极狐GitLab 集成错误追踪](integrated_error_tracking.md)和[基于 Sentry 的](sentry_error_tracking.md)后端之间进行选择。

<a id="prerequisites"></a>

## 先决条件

要使错误追踪正常工作，您需要：

- **使用 Sentry SDK 配置您的应用程序**：当错误发生时，Sentry SDK 会捕获相关信息并通过网络发送到后端。后端存储所有错误的信息。
- **错误追踪后端**：后端可以是极狐GitLab 本身或 Sentry。
  - 要使用极狐GitLab 后端，请参阅[极狐GitLab 集成错误追踪](integrated_error_tracking.md)。
    集成错误追踪仅在 JihuLab.com 上可用。
  - 要使用 Sentry 作为后端，请参阅[Sentry 错误追踪](sentry_error_tracking.md)。
    基于 Sentry 的错误追踪适用于 JihuLab.com 和私有化部署。

<a id="how-error-tracking-works"></a>

## 错误追踪工作原理

下表概述了每种极狐GitLab 产品的功能：

| 功能 | 可用性 | 数据收集 | 数据存储 | 数据查询 |
| ----------- | ----------- | ----------- | ----------- | ----------- |
| [极狐GitLab 集成错误追踪](integrated_error_tracking.md) | JihuLab.com | 使用 [Sentry SDK](https://github.com/getsentry/sentry?tab=readme-ov-file#official-sentry-sdks) | 在 JihuLab.com 上 | 通过 JihuLab.com |
| [基于 Sentry 的错误追踪](sentry_error_tracking.md) | JihuLab.com，私有化部署 | 使用 [Sentry SDK](https://github.com/getsentry/sentry?tab=readme-ov-file#official-sentry-sdks) | 在 Sentry 实例上（Sentry.io 云服务或[自托管 Sentry](https://develop.sentry.dev/self-hosted/)） | 通过 JihuLab.com 或 Sentry 实例 |

