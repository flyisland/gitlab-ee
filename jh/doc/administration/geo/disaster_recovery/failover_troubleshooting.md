---
stage: Tenant Scale
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 排查 Geo 故障转移问题
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

<a id="fixing-errors-during-a-failover-or-when-promoting-a-secondary-to-a-primary-site"></a>

## 修复故障转移期间或将次要站点提升为主要站点时的错误

以下是故障转移期间或将次要站点提升为主要站点时可能遇到的错误消息，以及解决这些错误消息的策略。

<a id="message-activerecord-recordinvalid-validation-failed-name-has-already-been-taken"></a>

### 消息：`ActiveRecord::RecordInvalid: 验证失败：名称已被占用`

当[提升**次要**站点](_index.md#step-2-promoting-a-secondary-site)时，可能会遇到以下错误消息：

```plaintext
正在运行 gitlab-rake geo:set_secondary_as_primary...

rake 已中止！
ActiveRecord::RecordInvalid：验证失败：名称已被占用
/opt/gitlab/embedded/service/gitlab-rails/ee/lib/tasks/geo.rake:236:in `block (3 levels) in <top (required)>'
/opt/gitlab/embedded/service/gitlab-rails/ee/lib/tasks/geo.rake:221:in `block (2 levels) in <top (required)>'
/opt/gitlab/embedded/bin/bundle:23:in `load'
/opt/gitlab/embedded/bin/bundle:23:in `<main>'
任务：TOP => geo:set_secondary_as_primary
（通过运行任务 --trace 查看完整回溯）

您已成功提升此节点！
```

如果在运行 `gitlab-rake geo:set_secondary_as_primary` 或 `gitlab-ctl promote-to-primary-node` 时遇到此消息，请进入 Rails 控制台并运行：

  ```ruby
  Rails.application.load_tasks; nil
  Gitlab::Geo.expire_cache!
  Rake::Task['geo:set_secondary_as_primary'].invoke
  ```

<a id="message-nomethoderror-undefined-method-secondary-for-nilnilclass"></a>

### 消息：``NoMethodError: 对于 nil:NilClass，未定义方法 `secondary?` ``

当[提升**次要**站点](_index.md#step-2-promoting-a-secondary-site)时，可能会遇到以下错误消息：

```plaintext
sudo gitlab-rake geo:set_secondary_as_primary

rake 已中止！
NoMethodError: undefined method `secondary?` for nil:NilClass
/opt/gitlab/embedded/service/gitlab-rails/ee/lib/tasks/geo.rake:232:in `block (3 levels) in <top (required)>'
/opt/gitlab/embedded/service/gitlab-rails/ee/lib/tasks/geo.rake:221:in `block (2 levels) in <top (required)>'
/opt/gitlab/embedded/bin/bundle:23:in `load'
/opt/gitlab/embedded/bin/bundle:23:in `<main>'
任务：TOP => geo:set_secondary_as_primary
（通过运行任务 --trace 查看完整回溯）
```

此命令仅在次要站点上执行，如果您尝试在主要站点上运行此命令，则会显示此错误消息。

<a id="expired-artifacts"></a>

### 过期的产物

如果您发现由于某种原因，Geo **次要**站点上的产物比 Geo **主要**站点上的多，您可以使用 Rake 任务来[清理孤立的产物文件](../../raketasks/cleanup.md#remove-orphan-artifact-files)。

在 Geo **次要**站点上，此命令还会清理磁盘上与孤立文件相关的所有 Geo 注册表记录。

<a id="fixing-sign-in-errors"></a>

### 修复登录错误

<a id="message-the-redirect-uri-included-is-not-valid"></a>

#### 消息：包含的重定向 URI 无效

如果您能够登录到**主要**站点的 Web 界面，但在尝试登录到**次要**站点的 Web 界面时收到此错误消息，则应验证 Geo 站点的 URL 是否与其外部 URL 匹配。

先决条件：

- 管理员访问权限。

在**主要**站点上：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **Geo** > **站点**。
1. 找到受影响的**次要**站点，然后选择 **编辑**。
1. 确保 **URL** 字段与在 `/etc/gitlab/gitlab.rb` 中的 `external_url "https://gitlab.example.com"` 的值匹配，该值位于**次要站点的 Rails 节点**上。

<a id="authenticating-with-saml-on-the-secondary-site-always-lands-on-the-primary-site"></a>

#### 在次要站点上使用 SAML 认证总是跳转到主要站点

此[问题通常在升级到 极狐GitLab 15.1 时遇到](../../../update/versions/gitlab_15_changes.md#1510)。要解决此问题，请参阅[在 Geo 中使用单点登录配置实例范围 SAML](../replication/single_sign_on.md#configuring-instance-wide-saml)。

<a id="recovering-from-a-partial-failover"></a>

## 从部分故障转移中恢复

向次要 Geo 站点的部分故障转移可能是由于临时/短暂问题导致的。因此，首先尝试再次运行提升命令。

1. 通过 SSH 进入**次要**站点的每个 Sidekiq、PostgreSQL、Gitaly 和 Rails 节点，并运行以下命令之一：

   - 将次要站点提升为主要站点：

     ```shell
     sudo gitlab-ctl geo promote
     ```

   - 将次要站点提升为主要站点**无需任何进一步确认**：

     ```shell
     sudo gitlab-ctl geo promote --force
     ```

1. 验证您可以使用以前用于**次要**站点的 URL 连接到新提升的**主要**站点。
1. 如果**成功**，则**次要**站点现在已提升为**主要**站点。

如果前面的步骤**不成功**，请继续执行以下步骤：

1. 通过 SSH 连接到**次要**站点的每个 Sidekiq、PostgreSQL、Gitaly 和 Rails 节点，并执行以下操作：

   - 创建一个 `/etc/gitlab/gitlab-cluster.json` 文件，内容如下：

     ```shell
     {
       "primary": true,
       "secondary": false
     }
     ```

   - 重新配置 极狐GitLab 以使更改生效：

     ```shell
     sudo gitlab-ctl reconfigure
     ```

1. 验证您可以使用以前用于**次要**站点的 URL 连接到新提升的**主要**站点。
1. 如果成功，则**次要**站点现在已提升为**主要**站点。