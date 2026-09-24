---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Trello 增强功能
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以使用针对极狐GitLab 的 Trello 增强功能，将极狐GitLab 合并请求附加到 Trello 卡片。

![极狐GitLab Trello 增强功能 - Trello 卡片](img/trello_card_with_gitlab_powerup_v9_4.png)

<a id="configure-power-ups"></a>

## 配置增强功能

要为 Trello 看板配置增强功能：

1. 前往您的 Trello 看板。
1. 选择 **增强功能** 并找到 **极狐GitLab** 行。
1. 选择 **启用**。
1. 选择 **设置**（齿轮图标）。
1. 选择 **授权帐户**。
1. 输入[极狐GitLab API URL](#get-the-api-url)和具有 **API** 作用域的[个人访问令牌](../user/profile/personal_access_tokens.md#create-a-personal-access-token)。
1. 选择 **保存**。

<a id="get-the-api-url"></a>

## 获取 API URL

您的 API URL 是您的极狐GitLab 实例 URL，末尾附加 `/api/v4`。
例如，如果您的极狐GitLab 实例 URL 是 `https://jihulab.com`，那么您的 API URL 就是 `https://jihulab.com/api/v4`。
如果您的实例 URL 是 `https://example.com`，那么您的 API URL 就是 `https://example.com/api/v4`。

