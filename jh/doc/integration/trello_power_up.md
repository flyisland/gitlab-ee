---
stage: Plan
group: Work Items
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Trello 增强功能
description: 为极狐GitLab 配置 Trello 增强功能，以将合并请求附加到 Trello 看板上的 Trello 卡片。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

> [!warning]
> 此功能未处于积极开发中。

您可以使用面向 GitLab 的 Trello 增强功能将
极狐GitLab 合并请求附加到 Trello 卡片。

![带有 GitLab 增强功能的 Trello 卡片。](img/trello_card_with_gitlab_powerup_v9_4.png)

<a id="configure-power-ups"></a>

## 配置增强功能

要为 Trello 看板配置增强功能：

1. 转到您的 Trello 看板。
1. 选择 **增强功能**，找到 **GitLab** 行。
1. 选择 **启用**。
1. 选择 **设置**（齿轮图标）。
1. 选择 **授权帐户**。
1. 输入[极狐GitLab API URL](#get-the-api-url) 和具有 **API** 作用域的[个人访问令牌](../user/profile/personal_access_tokens.md#create-a-personal-access-token)。
1. 选择 **保存**。

<a id="get-the-api-url"></a>

## 获取 API URL

您的 API URL 是您的极狐GitLab 实例 URL，并在 URL 末尾附加 `/api/v4`。
例如，如果您的极狐GitLab 实例 URL 是 `https://gitlab.com`，则您的 API URL 是 `https://gitlab.com/api/v4`。如果您的实例 URL 是 `https://example.com`，则您的 API URL 是 `https://example.com/api/v4`。
