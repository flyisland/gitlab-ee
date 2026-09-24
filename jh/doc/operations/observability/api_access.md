---
stage: none
group: Embody
info: This page is owned by <https://handbook.gitlab.com/handbook/engineering/embody-team/>
description: 以编程方式访问极狐GitLab 可观测性 API，查询追踪、指标和日志。
ignore_in_report: true
title: 访问可观测性 API
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Status: 实验

{{< /details >}}

使用极狐GitLab 可观测性 API，以编程方式查询追踪、指标和日志，并管理仪表板和告警。

<a id="prerequisites"></a>

## 前提条件

- 您的群组或个人项目必须已启用可观测性。
  有关设置说明，请参阅
  [在 JihuLab.com 上设置可观测性](setup_gitlab_com.md) 或
  [在极狐GitLab 私有化部署上设置可观测性](setup_self_managed.md)。

{{< tabs >}}

{{< tab title="Group" >}}

- 您必须拥有该群组的开发者、维护者或所有者角色。

{{< /tab >}}

{{< tab title="Personal project" >}}

- 您必须拥有该项目的所有者角色。

{{< /tab >}}

{{< /tabs >}}

<a id="get-your-api-key"></a>

## 获取您的 API 密钥

{{< tabs >}}

{{< tab title="Group" >}}

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的群组。
1. 在左侧边栏中，选择 **可观测性** > **API 密钥**。
1. 复制您的 API 密钥。

{{< /tab >}}

{{< tab title="Personal project" >}}

1. 在顶部栏中，选择 **搜索或跳转到** 并找到您的项目。
1. 在左侧边栏中，选择 **可观测性** > **API 密钥**。
1. 复制您的 API 密钥。

{{< /tab >}}

{{< /tabs >}}

在发出 API 请求时，在 `SIGNOZ-API-KEY` 请求头中使用此密钥。

<a id="api-endpoint"></a>

## API 端点

API 端点取决于您的极狐GitLab 部署形态。

<a id="gitlabcom"></a>

### JihuLab.com

您的 API 基础 URL 遵循以下模式：

```plaintext
https://<group_id>.gitlab-o11y.com
```

将 `<group_id>` 替换为您的极狐GitLab 群组 ID。

<a id="gitlab-self-managed"></a>

### 极狐GitLab 私有化部署

您的 API 基础 URL 与您为群组配置的
`o11y_service_url` 相同。例如：

```plaintext
http://<your-instance-ip>:8080
```

<a id="make-api-requests"></a>

## 发出 API 请求

在每个请求的 `SIGNOZ-API-KEY` 请求头中包含您的 API 密钥。

以下示例查询健康端点：

```shell
curl --header "SIGNOZ-API-KEY: <your_api_key>" \
  https://<group_id>.gitlab-o11y.com/api/v1/health
```

将 `<your_api_key>` 替换为 **API 密钥** 页面中的密钥，并将
`<group_id>` 替换为您的极狐GitLab 群组 ID（或您的私有化部署实例 URL）。

<a id="available-api-endpoints"></a>

## 可用的 API 端点

极狐GitLab 可观测性使用 SigNoz API。
有关可用端点的完整列表、请求和响应格式以及使用示例，请参阅
[SigNoz API 参考](https://signoz.io/api-reference/)。
