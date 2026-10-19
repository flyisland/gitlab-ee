---
stage: Analytics
group: Platform Insights
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 错误跟踪
description: 错误跟踪、日志记录、调试和数据保留。
---

错误跟踪可帮助开发者发现并查看其应用程序产生的错误。由于错误信息会在代码开发的位置呈现，错误跟踪可以提高效率，并帮助开发者更及时地了解错误。用户可以在[极狐GitLab 集成错误跟踪](integrated_error_tracking.md)和[基于 Sentry](sentry_error_tracking.md)的后端之间进行选择。

<a id="prerequisites"></a>

## 先决条件

要使错误跟踪正常工作，您需要：

- **使用 Sentry SDK 配置您的应用程序**：发生错误时，Sentry SDK 会捕获相关信息，并通过网络将其发送到后端。后端会存储所有错误的相关信息。
- **错误跟踪后端**：后端可以是极狐GitLab 本身，也可以是 Sentry。
  - 要使用极狐GitLab 后端，请参阅[极狐GitLab 集成错误跟踪](integrated_error_tracking.md)。
    集成错误跟踪仅在 JihuLab.com 上可用。
  - 要使用 Sentry 作为后端，请参阅 [Sentry 错误跟踪](sentry_error_tracking.md)。
    基于 Sentry 的错误跟踪适用于 JihuLab.com 和极狐GitLab 私有化部署。

<a id="how-error-tracking-works"></a>

## 错误跟踪的工作原理

下表概述了每种极狐GitLab 交付方式的能力：

| 功能 | 可用性 | 数据收集 | 数据存储 | 数据查询 |
| ----------- | ----------- | ----------- | ----------- | ----------- |
| [极狐GitLab 集成错误跟踪](integrated_error_tracking.md) | JihuLab.com | 使用 [Sentry SDK](https://github.com/getsentry/sentry?tab=readme-ov-file#official-sentry-sdks) | 在 JihuLab.com 上 | 使用 JihuLab.com |
| [基于 Sentry 的错误跟踪](sentry_error_tracking.md) | JihuLab.com、极狐GitLab 私有化部署 | 使用 [Sentry SDK](https://github.com/getsentry/sentry?tab=readme-ov-file#official-sentry-sdks) | 在 Sentry 实例上（Sentry.io 云服务或[自托管 Sentry](https://develop.sentry.dev/self-hosted/)） | 使用 JihuLab.com 或 Sentry 实例 |
