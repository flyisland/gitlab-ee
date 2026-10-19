---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 为您的应用程序创建并维护自定义功能标志。
title: 功能标志
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

借助功能标志，您可以分批将应用程序的新功能部署到生产环境。您可以为部分用户开启或关闭某项功能，从而帮助您实现持续交付。功能标志有助于降低风险，让您可以进行受控测试，并将功能交付与客户发布分开。

您还可以查看极狐GitLab 中[功能标志的完整列表](../administration/feature_flags/list.md)。

如需查看点击式演示，请参阅[功能标志](https://tech-marketing.gitlab.io/static-demos/feature-flags/feature-flags-html.html)。
<!-- Demo published on 2023-07-13 -->

<a id="using-feature-flags"></a>

## 使用功能标志

极狐GitLab 为功能标志提供了兼容 [Unleash](https://github.com/Unleash/unleash)的 API。

通过在极狐GitLab 中启用或禁用某个标志，您的应用程序可以确定要启用或禁用哪些功能。

您可以在极狐GitLab 中创建功能标志，并在应用程序中使用该 API 获取功能标志列表及其状态。应用程序必须配置为与极狐GitLab 通信，因此需要由开发者使用兼容的客户端库，并[在您的应用中集成功能标志](#integrate-feature-flags-with-your-application)。

<a id="create-a-feature-flag"></a>

## 创建功能标志

要创建并启用功能标志：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**部署** > **功能标志**。
1. 选择**新建功能标志**。
1. 输入一个名称，该名称以字母开头，且仅包含小写字母、数字、下划线（`_`）
   或短横线（`-`），并且不以短横线（`-`）或下划线（`_`）结尾。
1. 可选。输入描述（最多 255 个字符）。
1. 添加功能标志[**策略**](#feature-flag-strategies)以定义该标志的应用方式。对于每个策略，请包含**类型**（默认为[**所有用户**](#all-users)）
   和**环境**（默认为所有环境）。
1. 选择**创建功能标志**。

要更改这些设置，请在列表中选择任意功能标志旁边的**编辑**（{{< icon name="pencil" >}}）。

<a id="restrict-who-can-manage-feature-flags"></a>

## 限制谁可以管理功能标志

> [!flag]
> 此功能的可用性由功能标志控制。

默认情况下，任何至少具有开发者角色的项目成员都可以创建、更新、切换和删除功能标志。为满足变更控制或合规要求，您可以提高此阈值。

先决条件：

- 您必须至少具有该项目的维护者角色。
- 要将最低角色从 `owner` 或 `no_one_allowed` 改为其他值，您必须具有
  该项目的所有者角色。

要设置最低角色：

1. 在左侧边栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 选择**设置** > **CI/CD**。
1. 展开**功能标志**。
1. 选择一个角色。
1. 选择**保存更改**。

或者，使用[更新功能标志设置](../api/feature_flags.md#update-feature-flag-settings) REST 端点设置最低角色：

```shell
curl --request PUT \
  --header "PRIVATE-TOKEN: <your_access_token>" \
  --url "https://gitlab.example.com/api/v4/projects/<project_id>/feature_flags_settings?minimum_role=maintainer"
```

您也可以将其设置为[更新项目](../api/projects.md#update-a-project)端点的 `feature_flags_minimum_role` 属性，以便在一次请求中配置多个项目设置。

该设置接受以下值之一：

| 值            | 谁可以管理功能标志 |
|------------------|------------------------------|
| `developer`      | 至少具有开发者角色的成员。这是默认值，与早期极狐GitLab 版本中的行为一致。 |
| `maintainer`     | 至少具有维护者角色的成员。 |
| `owner`          | 具有所有者角色的成员。 |
| `no_one_allowed` | 没有人，包括实例管理员。使用此值可完全冻结功能标志管理。 |

低于该阈值的成员如果至少具有开发者角色，仍可以查看功能标志及其状态，但不能创建、更新、切换或删除它们。他们也不能创建、编辑或删除[用户列表](#user-list)，因为用户列表会改变标志所适用的用户。

> [!warning]
> 维护者可以设置 `owner` 或 `no_one_allowed`，但之后无法再改回。
> 只有具有所有者角色的成员才能将该设置从这两个值改为其他值。

<a id="maximum-number-of-feature-flags"></a>

## 功能标志的最大数量

在极狐GitLab 私有化部署上，每个项目的功能标志最大数量为 200。对于 JihuLab.com，最大数量由[版本](https://gitlab.cn/pricing)决定：

| 版本     | 每个项目的功能标志数量（JihuLab.com） | 每个项目的功能标志数量（极狐GitLab 私有化部署） |
|----------|----------------------------------|------------------------------------------|
| 基础版     | 50                               | 200                                      |
| 专业版  | 150                              | 200                                      |
| 旗舰版 | 200                              | 200                                      |

<a id="feature-flag-strategies"></a>

## 功能标志策略

您可以在多个环境中应用同一个功能标志策略，而无需多次定义该策略。

极狐GitLab 功能标志基于 [Unleash](https://docs.getunleash.io/)。在 Unleash 中，有
用于精细化功能标志控制的[策略](https://docs.getunleash.io/reference/activation-strategies)。极狐GitLab 功能标志可以有多个策略，支持的策略包括：

- [所有用户](#all-users)
- [用户百分比](#percent-of-users)
- [用户 ID](#user-ids)
- [用户列表](#user-list)

可以在[创建功能标志](#create-a-feature-flag)时添加策略，也可以在创建后编辑现有功能标志来添加：导航到**部署** > **功能标志**，然后选择**编辑**（{{< icon name="pencil" >}}）。

<a id="all-users"></a>

### 所有用户

为所有用户启用该功能。它使用 Standard（`default`）Unleash 激活[策略](https://docs.getunleash.io/reference/activation-strategies#standard)。

<a id="percent-rollout"></a>

### 百分比发布

为一定百分比的页面浏览量启用该功能，并可配置行为的一致性。这种一致性也称为粘性。它使用
Gradual Rollout（`flexibleRollout`）Unleash 激活[策略](https://docs.getunleash.io/reference/activation-strategies#gradual-rollout)。

您可以将一致性配置为基于：

- **用户 ID**：每个用户 ID 具有一致的行为，忽略会话 ID。
- **会话 ID**：每个会话 ID 具有一致的行为，忽略用户 ID。
- **随机**：不保证行为一致。该功能会随机为
  选定百分比的页面浏览量启用。用户 ID 和会话 ID 会被忽略。
- **可用 ID**：根据用户的状态尝试实现一致的行为：
  - 如果用户已登录，则基于用户 ID 实现行为一致。
  - 如果用户是匿名用户，则基于会话 ID 实现行为一致。
  - 如果没有用户 ID 或会话 ID，则该功能会随机为选定
    百分比的页面浏览量启用。

例如，基于**可用 ID** 设置 15% 的值，可为 15% 的页面浏览量启用该功能。对于已认证用户，这基于其用户 ID。对于有会话 ID 的匿名用户，由于他们没有用户 ID，则会基于其会话 ID。如果未提供会话 ID，则回退为随机。

发布百分比可以为 0% 到 100%。

选择基于用户 ID 的一致性，其效果与[用户百分比](#percent-of-users)发布相同。

> [!warning]
> 选择**随机**会导致单个用户的应用程序行为不一致。

<a id="percent-of-users"></a>

### 用户百分比

为一定百分比的已认证用户启用该功能。它使用 Unleash 激活策略
[`gradualRolloutUserId`](https://docs.getunleash.io/reference/activation-strategies#gradual-rollout)。

例如，设置 15% 的值可为 15% 的已认证用户启用该功能。

发布百分比可以为 0% 到 100%。

对于已认证用户，可保证粘性（同一用户的应用程序行为一致），但匿名用户不保证。

基于**用户 ID** 一致性的[百分比发布](#percent-rollout)具有相同的行为。您应使用百分比发布，因为它比用户百分比更灵活。

> [!warning]
> 如果选择了用户百分比策略，则必须为 Unleash 客户端提供用户
> ID，才能启用该功能。请参阅下方的 [Ruby 示例](#ruby-application-example)。

<a id="user-ids"></a>

### 用户 ID

为一组目标用户启用该功能。它通过
Unleash UserIDs（`userWithId`）激活[策略](https://docs.getunleash.io/reference/activation-strategies#userids)实现。

以逗号分隔的值列表形式输入用户 ID（例如，`user@example.com, user2@example.com`，或 `username1,username2,username3`，等等）。用户 ID 是您应用程序用户的标识符。它们不必是极狐GitLab 用户。

> [!warning]
> 必须为 Unleash 客户端提供用户 ID，才能为目标用户启用该
> 功能。请参阅下方的 [Ruby 示例](#ruby-application-example)。

<a id="user-list"></a>

### 用户列表

为[在功能标志 UI 中](#create-a-user-list)创建的或通过[功能标志用户列表 API](../api/feature_flag_user_lists.md) 创建的用户列表启用该功能。
与[用户 ID](#user-ids) 类似，它使用 Unleash UsersIDs（`userWithId`）激活[策略](https://docs.getunleash.io/reference/activation-strategies#userids)。

您无法为某个用户禁用特定功能，但可以通过为用户列表启用该功能来达到类似效果。

例如：

- `Full-user-list` = `User1A, User1B, User2A, User2B, User3A, User3B, ...`
- `Full-user-list-excluding-B-users` = `User1A, User2A, User3A, ...`

<a id="create-a-user-list"></a>

#### 创建用户列表

要创建用户列表：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**部署** > **功能标志**。
1. 选择**查看用户列表**
1. 选择**新建用户列表**。
1. 输入列表的名称。
1. 选择**创建**。

您可以通过选择列表旁边的**编辑**（{{< icon name="pencil" >}}）来查看该列表的用户 ID。查看列表时，您可以通过选择**编辑**（{{< icon name="pencil" >}}）来重命名它。

<a id="add-users-to-a-user-list"></a>

#### 向用户列表添加用户

要向用户列表添加用户：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**部署** > **功能标志**。
1. 选择您要向其添加用户的列表旁边的**编辑**（{{< icon name="pencil" >}}）。
1. 选择**添加用户**。
1. 以逗号分隔的值列表形式输入用户 ID。例如，
   `user@example.com, user2@example.com`，或 `username1,username2,username3`，等等。
1. 选择**添加**。

<a id="remove-users-from-a-user-list"></a>

#### 从用户列表中移除用户

要从用户列表中移除用户：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**部署** > **功能标志**。
1. 选择您要更改的列表旁边的**编辑**（{{< icon name="pencil" >}}）。
1. 选择您要移除的 ID 旁边的**移除**（{{< icon name="remove" >}}）。

<a id="search-for-code-references"></a>

## 搜索代码引用

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

要在清理期间从代码中移除功能标志，请查找对其的任何项目引用。

要搜索功能标志的代码引用：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**部署** > **功能标志**。
1. 编辑您要移除的功能标志。
1. 选择**更多操作**（{{< icon name="ellipsis_v" >}}）。
1. 选择**搜索代码引用**。

<a id="disable-a-feature-flag-for-a-specific-environment"></a>

## 为特定环境禁用功能标志

要为特定环境禁用功能标志：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**部署** > **功能标志**。
1. 对于您要禁用的功能标志，选择**编辑**（{{< icon name="pencil" >}}）。
1. 要禁用该标志：
   - 对于它适用的每个策略，在**环境**下删除该环境。
1. 选择**保存更改**。

<a id="disable-a-feature-flag-for-all-environments"></a>

## 为所有环境禁用功能标志

要为所有环境禁用功能标志：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**部署** > **功能标志**。
1. 对于您要禁用的功能标志，将状态开关滑动到**已禁用**。

该功能标志会显示在**已禁用**选项卡上。

<a id="integrate-feature-flags-with-your-application"></a>

## 在您的应用程序中集成功能标志

要在您的应用程序中使用功能标志，请从极狐GitLab 获取访问凭据。然后使用客户端库准备您的应用程序。

<a id="get-access-credentials"></a>

### 获取访问凭据

要获取您的应用程序与极狐GitLab 通信所需的访问凭据：

1. 在顶部栏中，选择**搜索或跳转到**，然后找到您的项目。
1. 在左侧边栏中，选择**部署** > **功能标志**。
1. 选择**配置**以查看以下内容：
   - **API URL**：客户端（应用程序）连接以获取功能标志列表的 URL。
   - **实例 ID**：授权获取功能标志的唯一令牌。
   - **应用程序名称**：应用程序运行所在环境的名称
     （不是应用程序本身的名称）。

     例如，如果应用程序在生产服务器上运行，**应用程序名称**
     可以是 `production` 或类似值。此值用于环境规格评估。

这些字段的含义可能会随时间变化。例如，**实例 ID** 可能是分配给**环境**的单个令牌或多个令牌。此外，**应用程序名称**可能描述应用程序版本，而不是运行环境。

<a id="choose-a-client-library"></a>

### 选择客户端库

极狐GitLab 实现了一个与 Unleash 客户端兼容的单一后端。

借助 Unleash 客户端，开发者可以在应用程序代码中定义标志的默认值。每次功能标志评估都可以表达：如果提供的配置文件中不存在该标志，所期望的结果是什么。

Unleash 目前[为各种语言和框架提供了许多 SDK](https://github.com/Unleash/unleash#unleash-sdks)。

<a id="feature-flags-api-information"></a>

### 功能标志 API 信息

有关 API 内容，请参阅：

- [功能标志 API](../api/feature_flags.md)
- [功能标志用户列表 API](../api/feature_flag_user_lists.md)

<a id="go-application-example"></a>

### Go 应用程序示例

以下是在 Go 应用程序中集成功能标志的示例：

```go
package main

import (
    "io"
    "log"
    "net/http"

    "github.com/Unleash/unleash-client-go/v3"
)

type metricsInterface struct {
}

func init() {
    unleash.Initialize(
        unleash.WithUrl("https://jihulab.com/api/v4/feature_flags/unleash/42"),
        unleash.WithInstanceId("29QmjsW6KngPR5JNPMWx"),
        unleash.WithAppName("production"), // Set to the running environment of your application
        unleash.WithListener(&metricsInterface{}),
    )
}

func helloServer(w http.ResponseWriter, req *http.Request) {
    if unleash.IsEnabled("my_feature_name") {
        io.WriteString(w, "Feature enabled\n")
    } else {
        io.WriteString(w, "hello, world!\n")
    }
}

func main() {
    http.HandleFunc("/", helloServer)
    log.Fatal(http.ListenAndServe(":8080", nil))
}
```

<a id="ruby-application-example"></a>

### Ruby 应用程序示例

以下是在 Ruby 应用程序中集成功能标志的示例。

为 Unleash 客户端提供一个用户 ID，用于**百分比发布（已登录用户）**发布策略或**目标用户**列表。

```ruby
#!/usr/bin/env ruby

require 'unleash'
require 'unleash/context'

unleash = Unleash::Client.new({
  url: 'http://gitlab.com/api/v4/feature_flags/unleash/42',
  app_name: 'production', # Set to the running environment of your application
  instance_id: '29QmjsW6KngPR5JNPMWx'
})

unleash_context = Unleash::Context.new
# Replace "123" with the ID of an authenticated user.
# The context's user ID must be a string:
# https://unleash.github.io/docs/unleash_context
unleash_context.user_id = "123"

if unleash.is_enabled?("my_feature_name", unleash_context)
  puts "Feature enabled"
else
  puts "hello, world!"
end
```

<!--- start_remove The following content will be removed on remove_date: '2026-11-26' -->

<a id="unleash-proxy-example-deprecated"></a>

### Unleash Proxy 示例（已弃用）

> [!warning]
> Unleash Proxy 已于 2023-09-06 [弃用](https://github.com/Unleash/unleash-proxy/blob/main/README.md)。
> 计划于 2026-11-26 停止支持（EOL）。

从 [Unleash Proxy](https://docs.getunleash.io/reference/unleash-proxy) 0.2 版本
开始，该代理与功能标志兼容。

在 JihuLab.com 上，您应在生产环境中使用 Unleash Proxy。有关详细信息，请参阅[性能说明](#maximum-supported-clients-in-application-nodes)。

要运行 Docker 容器以连接到您项目的功能标志，请运行以下命令：

```shell
docker run \
  -e UNLEASH_PROXY_SECRETS=<secret> \
  -e UNLEASH_URL=<project feature flags URL> \
  -e UNLEASH_INSTANCE_ID=<project feature flags instance ID> \
  -e UNLEASH_APP_NAME=<project environment> \
  -e UNLEASH_API_TOKEN=<tokenNotUsed> \
  -p 3000:3000 \
  unleashorg/unleash-proxy
```

| 变量                    | 值                                                                                                                                |
| --------------------------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| `UNLEASH_PROXY_SECRETS`      | 用于配置 [Unleash Proxy 客户端](https://docs.getunleash.io/reference/unleash-proxy#how-to-connect-to-the-proxy)的共享密钥。 |
| `UNLEASH_URL`         | 您项目的 API URL。有关更多详细信息，请阅读[获取访问凭据](#get-access-credentials)。 |
| `UNLEASH_INSTANCE_ID` | 您项目的实例 ID。有关更多详细信息，请阅读[获取访问凭据](#get-access-credentials)。 |
| `UNLEASH_APP_NAME`    | 应用程序运行所在环境的名称。有关更多详细信息，请阅读[获取访问凭据](#get-access-credentials)。 |
| `UNLEASH_API_TOKEN`   | 启动 Unleash Proxy 所必需，但不用于连接到极狐GitLab。可以设置为任意值。 |

使用 Unleash Proxy 时存在一个限制：每个代理实例只能为 `UNLEASH_APP_NAME`中指定的环境请求标志。该代理会代表客户端将此信息发送给极狐GitLab，这意味着客户端无法覆盖它。

<!--- end_remove -->

<a id="feature-flag-related-issues"></a>

## 功能标志相关问题

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

您可以将相关议题链接到功能标志。在功能标志的**已链接议题**部分，选择 `+` 按钮，然后输入议题引用编号或议题的完整 URL。这些议题随后会显示在相关的功能标志中，反之亦然。

此功能类似于[已链接议题](../user/project/issues/related_issues.md)功能。

<a id="performance-factors"></a>

## 性能因素

极狐GitLab 功能标志可用于任何应用程序。大型应用程序可能需要高级配置。本节介绍性能因素，以帮助您的组织确定在使用该功能之前需要做哪些准备工作。有关更多信息，请参阅[使用功能标志](#using-feature-flags)。

<a id="maximum-supported-clients-in-application-nodes"></a>

### 应用程序节点中支持的最大客户端数

极狐GitLab 会接受尽可能多的客户端请求，直到达到[速率限制](../rate_limits/_index.md)。功能标志 API 被视为**未认证流量**，并针对每个源 IP 地址进行限制。
对于 JihuLab.com，请参阅 [JihuLab.com 特定限制](../user/jihulab_com/_index.md)。

由于速率限制适用于每个源 IP，共享出口地址后面的所有客户端会共同消耗一个配额，同时还会与该地址的其他 JihuLab.com 流量共享该配额。

轮询频率可在 SDK 中配置。假设所有客户端都从同一 IP 发起请求：

- 每分钟一次请求时，大约支持 500 个客户端（8 RPS）。
- 每 15 秒一次请求时，大约支持 125 个客户端。

要提高可用吞吐量，请将客户端分布到多个出口地址。由于限制是针对每个源 IP 的，因此无需更改应用程序。

对于需要减少出站请求量的应用程序，Unleash Proxy 位于您的客户端和极狐GitLab 之间。它代表客户端组发起请求，因此许多客户端侧评估会合并为少量出站调用。如果您运行了该代理但仍收到 `429` 响应，请增大其 `UNLEASH_FETCH_INTERVAL` 值。

Unleash Proxy 在上游已弃用，并计划于 2026 年 11 月 26 日停止支持。在该日期之后，不再计划发布任何版本，包括安全版本。它仍可与极狐GitLab 功能标志 API 配合使用，并且仍是已知唯一可与之配合使用的组件。

> [!warning]
> Unleash Edge 是 Unleash Proxy 的[推荐](https://docs.getunleash.io/unleash-edge/migrate-from-proxy)替代品，
> 但它与极狐GitLab 不兼容。这种不兼容是结构性的，而不是配置问题：
>
> - 环境模型。极狐GitLab 实现的是 v4 之前的 Unleash 环境模型。从 Unleash v4 开始，
>   环境被编码在 API 密钥中。
> - 令牌格式。Edge 需要有效的 Unleash 令牌。极狐GitLab 发放的是按项目的实例 ID，
>   它们不是 Unleash 令牌。
> - 自定义激活策略。极狐GitLab 的环境隔离依赖于自定义激活策略。
>   Unleash Proxy 通过 `UNLEASH_CUSTOM_STRATEGIES_FILE` 支持这些策略。Edge 没有对应的机制。

<a id="recovering-from-network-errors"></a>

### 从网络错误中恢复

一般来说，当服务器返回错误代码时，[Unleash 客户端](https://github.com/Unleash/unleash#unleash-sdks)具有回退机制。例如，`unleash-ruby-client` 会从本地备份读取标志数据，以便应用程序可以保持当前状态继续运行。

有关更多信息，请阅读 SDK 项目中的文档。

<a id="gitlab-self-managed"></a>

### 极狐GitLab 私有化部署

在功能方面没有差异。JihuLab.com 和极狐GitLab 私有化部署的行为相同。

就可扩展性而言，这取决于极狐GitLab 实例的规格。JihuLab.com 使用高度可扩展的架构来处理大量并发请求。

但是，基于[参考架构](../administration/reference_architectures/_index.md#additional-workloads)容量不足的极狐GitLab 私有化部署实例无法提供相当的性能，甚至可能被功能标志流量压垮。请考虑您所部署应用程序的用户数量，*此外*还要考虑您的极狐GitLab 用户数量。
