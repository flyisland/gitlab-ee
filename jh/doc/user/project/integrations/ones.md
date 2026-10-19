---
stage: Foundations
group: Import and Integrate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: ONES 集成
---

{{< details >}}

- Tier: 专业版, 旗舰版
- Offering: 私有化部署

{{< /details >}}

> [引入](https://jihulab.com/gitlab-cn/gitlab/-/issues/1161)于 15.5 版本，[功能标志](../../../administration/feature_flags.md)为 `ff_ones_issues_integration`。默认禁用。

使用 ONES 作为极狐GitLab 群组或项目的议题跟踪器。

NOTE:
每个极狐GitLab 群组或项目只能集成一个外部议题跟踪器。如果您的群组或项目已集成其他的外部议题跟踪器，您将无法配置启用 ONES 集成。

## 准备工作

在极狐GitLab 上配置启用 ONES 集成之前，需要在 ONES 上获取配置所需的信息。

<a id="fetch-team-id-and-project-id"></a>

### 获取团队 ID 和项目 ID

使用您的账户登录 ONES，并进入要与极狐GitLab 关联的 ONES 项目。通过项目页面的 URL，您即可获取该项目的团队 ID 和项目 ID。

以 [ONES SaaS 平台](https://ones.cn/)上的某个项目为例：

```
https://ones.cn/project/#/team/E5****Gt/project/WM********9L/...
```

在此示例中，`E5****Gt` 为 **ONES 团队 ID**，`WM********9L` 为 **ONES 项目 ID**。记录这两个参数，在极狐GitLab 上配置启用 ONES 集成时需要使用。

<a id="fetch-user-id-and-api-token"></a>

### 获取用户 ID 和 API 令牌

参考调用以下 curl 命令获取用户 ID 和 API 令牌，将 `<your-email>` 替换为 ONES 用户的邮箱，将 `<your-ones-password>` 替换为 ONES 用户的密码，以 [ONES SaaS 平台](https://ones.cn/)为例：

```
curl -s --data-raw '{"email": "<your-email>", "password": "<your-ones-password>"}' \
--request POST 'https://ones.cn/project/api/project/auth/login' --header 'Content-Type: application/json' \
| python3 -c "import sys, json; u=json.load(sys.stdin)['user'];  print({'ones_user_id': u['uuid'], 'ones_api_token': u['token']})"
```

输出格式为：

```
{'ones_user_id': 'your-ones-user-uuid', 'ones_api_token': 'your-ones-api-token'}
```

输出示例：

```
{'ones_user_id': 'KM****xj', 'ones_api_token': '3vFt7l********************ABc7aMTnrjOj'}
```

在此示例中，`KM****xj` 为 **ONES 用户 ID**，`3vFt7l********************ABc7aMTnrjOj` 为 **ONES API 令牌**。记录这两个参数，在极狐GitLab 上配置启用 ONES 集成时需要使用。

## 配置 ONES 集成

支持在群组级别或项目级别集成 ONES 项目，在极狐GitLab 上完成以下步骤：

1. 在左侧边栏的顶部：
   - 配置群组级别集成：选择 **搜索或转到** 并找到您的群组。
   - 配置项目级别集成：选择 **搜索或转到** 并找到您的项目。

1. 在左侧边栏中，选择 **设置 > 集成**。
1. 选择 ONES。
1. 在 **启用集成** 下，选择 **启用**。
1. 提供以下 ONES 配置信息：
   - **ONES web URL**：通过 web 访问 ONES 实例的 URL。默认为 `https://ones.cn/`，即 ONES SaaS 平台。
   - **ONES API URL（可选）**：留空时，默认与 web URL 相同。如果与 web URL 不同，可以配置此项。
   - **ONES 团队 ID**：参考[获取团队 ID 和项目 ID](#fetch-team-id-and-project-id)。
   - **ONES 项目 ID**：参考[获取团队 ID 和项目 ID](#fetch-team-id-and-project-id)。
   - **ONES 用户 ID**：参考[获取用户 ID 和 API 令牌](#fetch-user-id-and-api-token)。
   - **ONES API 令牌**：参考[获取用户 ID 和 API 令牌](#fetch-user-id-and-api-token)。
1. 选择 **保存更改**。

配置完成后，在集成了 ONES 项目的群组或项目页面的左导航栏中，您可以：

- 在群组或项目页面的左导航栏中，选择 **计划 > ONES 议题**，查看来自 ONES 平台的议题。
- 在群组或项目页面的左导航栏中，选择 **计划 > 打开 ONES**，访问 ONES 登录页面。
