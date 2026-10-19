---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 访问令牌 Rake 任务
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

<a id="analyze-token-expiration-dates"></a>

## 分析令牌过期日期

在极狐GitLab 16.0 中，一项[后台迁移](https://gitlab.com/gitlab-org/gitlab/-/issues/369123)为所有未设置过期日期的个人、项目和群组访问令牌设置了过期日期，即这些令牌创建一年之后。

要确定哪些令牌可能受此迁移影响，您可以运行一个 Rake 任务，该任务会分析所有访问令牌并显示最常见的十个过期日期：

   {{< tabs >}}

   {{< tab title="Linux 软件包（Omnibus）" >}}

   ```shell
   gitlab-rake gitlab:tokens:analyze
   ```

   {{< /tab >}}

   {{< tab title="Helm chart（Kubernetes）" >}}

   ```shell
   # Find the toolbox pod
   kubectl --namespace <namespace> get pods -lapp=toolbox
   kubectl exec -it <toolbox-pod-name> -- sh -c 'cd /srv/gitlab && bin/rake gitlab:tokens:analyze'
   ```

   {{< /tab >}}

   {{< tab title="Docker" >}}

   ```shell
   sudo docker exec -it <container_name> /bin/bash
   gitlab-rake gitlab:tokens:analyze
   ```

   {{< /tab >}}

   {{< tab title="自行编译（源代码）" >}}

   ```shell
   sudo RAILS_ENV=production -u git -H bundle exec rake gitlab:tokens:analyze
   ```

   {{< /tab >}}

   {{< /tabs >}}

此任务会分析所有访问令牌，并按过期日期对其进行分组。左列显示过期日期，右列显示具有该过期日期的令牌数量。示例输出：

```plaintext
======= Personal/Project/Group Access Token Expiration Migration =======
Started at: 2023-06-15 10:20:35 +0000
Finished  : 2023-06-15 10:23:01 +0000
===== Top 10 Personal/Project/Group Access Token Expiration Dates =====
| Expiration Date | Count |
|-----------------|-------|
| 2024-06-15      | 1565353 |
| 2017-12-31      | 2508  |
| 2018-01-01      | 1008  |
| 2016-12-31      | 833   |
| 2017-08-31      | 705   |
| 2017-06-30      | 596   |
| 2018-12-31      | 548   |
| 2017-05-31      | 523   |
| 2017-09-30      | 520   |
| 2017-07-31      | 494   |
========================================================================
```

在此示例中，您可以看到超过 150 万个访问令牌的过期日期为 2024-06-15，即该迁移于 2023-06-15 运行后的一年。这表明这些令牌中的大多数是由该迁移分配的。但是，无法确定其他令牌是否也是手动创建并具有相同日期。

排名前 10 的日期可能包含过去的日期，也可能出现一行 `(none)`，用于表示没有过期日期的令牌。在查找即将发生的大规模过期时，请查看日期，而不只是数量。

<a id="update-expiration-dates-in-bulk"></a>

## 批量更新过期日期

先决条件：

您必须：

- 是管理员。
- 拥有交互式终端。

运行以下 Rake 任务以批量延长或移除令牌的过期日期：

1. 运行该工具：

   {{< tabs >}}

   {{< tab title="Linux 软件包（Omnibus）" >}}

   ```shell
   gitlab-rake gitlab:tokens:edit
   ```

   {{< /tab >}}

   {{< tab title="Helm chart（Kubernetes）" >}}

   ```shell
   # Find the toolbox pod
   kubectl --namespace <namespace> get pods -lapp=toolbox
   kubectl exec -it <toolbox-pod-name> -- sh -c 'cd /srv/gitlab && bin/rake gitlab:tokens:edit'
   ```

   {{< /tab >}}

   {{< tab title="Docker" >}}

   ```shell
   sudo docker exec -it <container_name> /bin/bash
   gitlab-rake gitlab:tokens:edit
   ```

   {{< /tab >}}

   {{< tab title="自行编译（源代码）" >}}

   ```shell
   sudo RAILS_ENV=production -u git -H bundle exec rake gitlab:tokens:edit
   ```

   {{< /tab >}}

   {{< /tabs >}}

   该工具启动后，会显示[分析步骤](#analyze-token-expiration-dates)的输出，
   并额外提示您修改过期日期：

   ```plaintext
   ======= Personal/Project/Group Access Token Expiration Migration =======
   Started at: 2023-06-15 10:20:35 +0000
   Finished  : 2023-06-15 10:23:01 +0000
   ===== Top 10 Personal/Project/Group Access Token Expiration Dates =====
   | Expiration Date | Count |
   |-----------------|-------|
   | 2024-05-14      | 1565353 |
   | 2017-12-31      | 2508  |
   | 2018-01-01      | 1008  |
   | 2016-12-31      | 833   |
   | 2017-08-31      | 705   |
   | 2017-06-30      | 596   |
   | 2018-12-31      | 548   |
   | 2017-05-31      | 523   |
   | 2017-09-30      | 520   |
   | 2017-07-31      | 494   |
   ========================================================================
   What do you want to do? (Press ↑/↓ arrow or 1-3 number to move and Enter to select)
   ‣ 1. Extend expiration date
     2. Remove expiration date
     3. Quit
   ```

<a id="extend-expiration-dates"></a>

### 延长过期日期

该任务会为每个令牌设置所选的过期日期，包括已撤销的令牌和模拟令牌。在您确认操作之前显示的数量包含这些令牌。

要延长所有匹配给定过期日期的令牌的过期日期：

1. 选择选项 1，`Extend expiration date`：

   ```plaintext
   What do you want to do?
   ‣ 1. Extend expiration date
     2. Remove expiration date
     3. Quit
   ```

1. 该工具会要求您从列出的过期日期中选择一个。例如：

   ```plaintext
   Select an expiration date (Press ↑/↓/←/→ arrow to move and Enter to select)
   ‣ 2024-05-14
     2017-12-31
     2018-01-01
     2016-12-31
     2017-08-31
     2017-06-30
   ```

   使用键盘上的方向键选择一个日期。要中止，
   请一直向下滚动并选择 `--> Abort`。按 <kbd>Enter</kbd> 确认
   您的选择：

   ```plaintext
   Select an expiration date
     2017-06-30
     2018-12-31
     2017-05-31
     2017-09-30
     2017-07-31
   ‣ --> Abort
   ```

   如果您选择了一个日期，该工具会提示您输入新的过期日期：

   ```plaintext
   What would you like the new expiration date to be? (2025-05-14) 2024-05-14
   ```

   默认值为所选日期的一年之后。按 <kbd>Enter</kbd>
   以使用默认值，或手动输入 `YYYY-MM-DD` 格式的日期。

1. 输入有效日期后，该工具会再次要求您确认：

   ```plaintext
   Old expiration date: 2024-05-14
   New expiration date: 2025-05-14
   WARNING: This will now update 1565353 token(s). Are you sure? (y/N)
   ```

   如果您输入 `y`，该工具会延长所有具有所选过期日期的令牌的过期日期。

   如果您输入 `N`，该工具会中止更新任务并返回
   原始分析输出。

<a id="remove-expiration-dates"></a>

### 移除过期日期

要移除所有匹配给定过期日期的令牌的过期日期：

1. 选择选项 2，`Remove expiration date`：

   ```plaintext
   What do you want to do?
     1. Extend expiration date
   ‣ 2. Remove expiration date
     3. Quit
   ```

1. 该工具会要求您从表中选择过期日期。例如：

   ```plaintext
   Select an expiration date (Press ↑/↓/←/→ arrow to move and Enter to select)
   ‣ 2024-05-14
     2017-12-31
     2018-01-01
     2016-12-31
     2017-08-31
     2017-06-30
   ```

   使用键盘上的方向键选择一个日期。要中止，
   请一直向下滚动并选择 `--> Abort`。按 <kbd>Enter</kbd> 确认
   您的选择：

   ```plaintext
   Select an expiration date
     2017-06-30
     2018-12-31
     2017-05-31
     2017-09-30
     2017-07-31
   ‣ --> Abort
   ```

1. 选择日期后，该工具会提示您确认选择：

   ```plaintext
   WARNING: This will remove the expiration for tokens that expire on 2024-05-14.
   This will affect 1565353 tokens. Are you sure? (y/N)
   ```

   如果您输入 `y`，该工具会移除所有具有所选过期日期的令牌的过期日期。

   如果您输入 `N`，该工具会中止更新任务并返回第一个菜单。

<a id="find-tokens-the-rake-tasks-do-not-report"></a>

## 查找 Rake 任务未报告的令牌

`gitlab:tokens:analyze` 任务按过期日期对令牌进行分组，并报告每个日期有多少令牌。它不会列出单个令牌，并且只报告最常见的 10 个日期。

对于个人访问令牌，请改用[个人访问令牌 API](../../../api/personal_access_tokens.md)。管理员可以列出实例中的每个个人访问令牌，并使用 `expires_before` 和 `expires_after` 进行筛选。

项目和群组访问令牌 API 仅按单个项目或群组的过期日期进行筛选。要扫描整个实例中的项目和群组访问令牌，请在 [Rails 控制台](../../operations/rails_console.md)中运行以下脚本。

要列出在给定日期范围内过期的项目和群组访问令牌：

```ruby
# Any duration works. For example: 1.week, 90.days, 6.months, 1.year.
date_range = 1.month

PersonalAccessToken.project_access_token.where(expires_at: Date.today .. Date.today + date_range).find_each do |token|
  token.user.members.each do |member|
    type = member.is_a?(GroupMember) ? 'Group' : 'Project'

    puts "Expiring #{type} access token in #{type} ID #{member.source_id}, Token ID: #{token.id}, Name: #{token.name}, Scopes: #{token.scopes}, Last used: #{token.last_used_at}"
  end
end
```

要列出没有过期日期的项目和群组访问令牌，请将 `expires_at` 条件替换为 `expires_at: nil`，并将消息中的 `Expiring` 改为 `No expiration date for`。

<a id="validate-custom-issuer-url-configuration-for-cicd-id-tokens"></a>

## 验证 CI/CD ID 令牌的自定义签发者 URL 配置

如果您为非公开的极狐GitLab 实例配置了[在 AWS 中使用 OpenID Connect 获取临时凭证](../../../ci/cloud_services/aws/_index.md#configure-a-non-public-gitlab-instance)，请使用 `ci:validate_id_token_configuration` Rake 任务来验证令牌配置：

```shell
bundle exec rake ci:validate_id_token_configuration
```
