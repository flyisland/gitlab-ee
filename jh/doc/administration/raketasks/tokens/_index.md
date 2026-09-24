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

{{< history >}}

- 在极狐GitLab 17.2 引入。

{{< /history >}}

<a id="analyze-token-expiration-dates"></a>

## 分析令牌过期日期

在极狐GitLab 16.0 中，一个后台迁移为所有未过期的个人、项目和群组访问令牌设置了过期日期，日期为创建令牌后一年。

要识别哪些令牌可能受此迁移影响，你可以运行一个 Rake 任务来分析所有访问令牌，并显示最常见的十个过期日期：

   {{< tabs >}}

   {{< tab title="Linux 软件包 (Omnibus)" >}}

   ```shell
   gitlab-rake gitlab:tokens:analyze
   ```

   {{< /tab >}}

   {{< tab title="Helm chart (Kubernetes)" >}}

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

   {{< tab title="自编译（源代码）" >}}

   ```shell
   sudo RAILS_ENV=production -u git -H bundle exec rake gitlab:tokens:analyze
   ```

   {{< /tab >}}

   {{< /tabs >}}

此任务会分析所有访问令牌并按过期日期进行分组。左列显示过期日期，右列显示拥有该过期日期的令牌数量。示例输出：

```plaintext
======= 个人/项目/群组访问令牌过期迁移 =======
开始时间：2023-06-15 10:20:35 +0000
完成时间：2023-06-15 10:23:01 +0000
===== 前 10 个个人/项目/群组访问令牌过期日期 =====
| 过期日期 | 数量 |
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

在此示例中，你可以看到超过 150 万个访问令牌的过期日期为 2024-06-15，即迁移运行日期 2023-06-15 后的一年。这表明这些令牌中的大多数是由迁移分配的。但是，无法确定是否有其他令牌是在同一日期手动创建的。

<a id="update-expiration-dates-in-bulk"></a>

## 批量更新过期日期

先决条件：

你必须：

- 成为管理员。
- 拥有交互式终端。

运行以下 Rake 任务以批量延长或移除令牌的过期日期：

1. 运行工具：

   {{< tabs >}}

   {{< tab title="Linux 软件包 (Omnibus)" >}}

   ```shell
   gitlab-rake gitlab:tokens:edit
   ```

   {{< /tab >}}

   {{< tab title="Helm chart (Kubernetes)" >}}

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

   {{< tab title="自编译（源代码）" >}}

   ```shell
   sudo RAILS_ENV=production -u git -H bundle exec rake gitlab:tokens:edit
   ```

   {{< /tab >}}

   {{< /tabs >}}

   工具启动后，会先显示[分析步骤](#analyze-token-expiration-dates)的输出，然后显示一个关于修改过期日期的额外提示：

   ```plaintext
   ======= 个人/项目/群组访问令牌过期迁移 =======
   开始时间：2023-06-15 10:20:35 +0000
   完成时间：2023-06-15 10:23:01 +0000
   ===== 前 10 个个人/项目/群组访问令牌过期日期 =====
   | 过期日期 | 数量 |
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
   你想做什么？（按 ↑/↓ 箭头或 1-3 数字键移动，按 Enter 选择）
   ‣ 1. 延长过期日期
     2. 移除过期日期
     3. 退出
   ```

<a id="extend-expiration-dates"></a>

### 延长过期日期

要延长所有匹配给定过期日期的令牌的过期日期：

1. 选择选项 1，`延长过期日期`：

   ```plaintext
   你想做什么？
   ‣ 1. 延长过期日期
     2. 移除过期日期
     3. 退出
   ```

1. 工具会要求你从列出的过期日期中选择一个。例如：

   ```plaintext
   选择一个过期日期（按 ↑/↓/←/→ 箭头移动，按 Enter 选择）
   ‣ 2024-05-14
     2017-12-31
     2018-01-01
     2016-12-31
     2017-08-31
     2017-06-30
   ```

   使用键盘上的箭头键选择一个日期。要中止，请一直向下滚动并选择 `--> 中止`。按 <kbd>Enter</kbd> 确认你的选择：

   ```plaintext
   选择一个过期日期
     2017-06-30
     2018-12-31
     2017-05-31
     2017-09-30
     2017-07-31
   ‣ --> 中止
   ```

   如果选择了一个日期，工具会提示你输入新的过期日期：

   ```plaintext
   你希望新的过期日期是什么？（2025-05-14）2024-05-14
   ```

   默认值为所选日期后的一年。按 <kbd>Enter</kbd> 使用默认值，或手动输入 `YYYY-MM-DD` 格式的日期。

1. 输入有效日期后，工具会再次要求你确认：

   ```plaintext
   旧过期日期：2024-05-14
   新过期日期：2025-05-14
   WARNING: 这将立即更新 1565353 个令牌。你确定吗？(y/N)
   ```

   如果输入 `y`，工具会为所有具有所选过期日期的令牌延长过期日期。

   如果输入 `N`，工具将中止更新任务并返回原始分析输出。

<a id="remove-expiration-dates"></a>

### 移除过期日期

要移除所有匹配给定过期日期的令牌的过期日期：

1. 选择选项 2，`移除过期日期`：

   ```plaintext
   你想做什么？
     1. 延长过期日期
   ‣ 2. 移除过期日期
     3. 退出
   ```

1. 工具会要求你从表格中选择一个过期日期。例如：

   ```plaintext
   选择一个过期日期（按 ↑/↓/←/→ 箭头移动，按 Enter 选择）
   ‣ 2024-05-14
     2017-12-31
     2018-01-01
     2016-12-31
     2017-08-31
     2017-06-30
   ```

   使用键盘上的箭头键选择一个日期。要中止，请一直向下滚动并选择 `--> 中止`。按 <kbd>Enter</kbd> 确认你的选择：

   ```plaintext
   选择一个过期日期
     2017-06-30
     2018-12-31
     2017-05-31
     2017-09-30
     2017-07-31
   ‣ --> 中止
   ```

1. 选择一个日期后，工具会提示你确认选择：

   ```plaintext
   WARNING: 这将移除过期日期为 2024-05-14 的令牌的过期时间。
   这将影响 1565353 个令牌。你确定吗？(y/N)
   ```

   如果输入 `y`，工具会移除所有具有所选过期日期的令牌的过期日期。

   如果输入 `N`，工具将中止更新任务并返回第一个菜单。

<a id="validate-custom-issuer-url-configuration-for-ci-cd-id-tokens"></a>

## 验证 CI/CD ID 令牌的自定义颁发者 URL 配置

如果你将非公开极狐GitLab 实例配置为通过 [AWS 中的 OpenID Connect 获取临时凭证](../../../ci/cloud_services/aws/_index.md#configure-a-non-public-gitlab-instance)，请使用 `ci:validate_id_token_configuration` Rake 任务来验证令牌配置：

```shell
bundle exec rake ci:validate_id_token_configuration
```