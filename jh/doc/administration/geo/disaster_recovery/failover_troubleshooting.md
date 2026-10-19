---
stage: GitLab Dedicated
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 故障排除 Geo 故障转移
---

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

<a id="fixing-errors-during-a-failover-or-when-promoting-a-secondary-to-a-primary-site"></a>

## 修复故障转移期间或将从站点提升为主站点时的错误

以下是故障转移期间或将从站点提升为主站点时可能遇到的错误消息，以及解决这些错误的策略。

<a id="message-activerecordrecordinvalid-validation-failed-name-has-already-been-taken"></a>

### 消息：`ActiveRecord::RecordInvalid: Validation failed: Name has already been taken`

在[提升从站点](_index.md#step-2-promoting-a-secondary-site)时，
您可能会遇到以下错误消息：

```plaintext
Running gitlab-rake gitlab:geo:set_secondary_as_primary...

rake aborted!
ActiveRecord::RecordInvalid: Validation failed: Name has already been taken
/opt/gitlab/embedded/service/gitlab-rails/ee/lib/tasks/geo.rake:236:in `block (3 levels) in <top (required)>'
/opt/gitlab/embedded/service/gitlab-rails/ee/lib/tasks/geo.rake:221:in `block (2 levels) in <top (required)>'
/opt/gitlab/embedded/bin/bundle:23:in `load'
/opt/gitlab/embedded/bin/bundle:23:in `<main>'
Tasks: TOP => gitlab:geo:set_secondary_as_primary
(See full trace by running task with --trace)

You successfully promoted this node!
```

如果在运行 `gitlab-rake gitlab:geo:set_secondary_as_primary` 或 `gitlab-ctl promote-to-primary-node` 时遇到此消息，请进入 Rails 控制台并运行：

  ```ruby
  Rails.application.load_tasks; nil
  Gitlab::Geo.expire_cache!
  Rake::Task['gitlab:geo:set_secondary_as_primary'].invoke
  ```

<a id="message-nomethoderror-undefined-method-secondary-for-nilnilclass"></a>

### 消息：``NoMethodError: undefined method `secondary?' for nil:NilClass``

在[提升从站点](_index.md#step-2-promoting-a-secondary-site)时，
您可能会遇到以下错误消息：

```plaintext
sudo gitlab-rake gitlab:geo:set_secondary_as_primary

rake aborted!
NoMethodError: undefined method `secondary?' for nil:NilClass
/opt/gitlab/embedded/service/gitlab-rails/ee/lib/tasks/geo.rake:232:in `block (3 levels) in <top (required)>'
/opt/gitlab/embedded/service/gitlab-rails/ee/lib/tasks/geo.rake:221:in `block (2 levels) in <top (required)>'
/opt/gitlab/embedded/bin/bundle:23:in `load'
/opt/gitlab/embedded/bin/bundle:23:in `<main>'
Tasks: TOP => gitlab:geo:set_secondary_as_primary
(See full trace by running task with --trace)
```

此命令仅用于在从站点上执行，如果您尝试在主站点上运行此命令，就会显示此错误消息。

<a id="expired-artifacts"></a>

### 过期的产物

如果您发现由于某种原因，Geo 从站点上的产物比 Geo 主站点上的多，可以使用 Rake 任务
[清理孤立产物文件](../../raketasks/cleanup.md#remove-orphan-artifact-files)。

在 Geo 从站点上，此命令还会清理磁盘上所有与孤立文件相关的 Geo 注册表记录。

<a id="fixing-sign-in-errors"></a>

### 修复登录错误

<a id="message-the-redirect-uri-included-is-not-valid"></a>

#### 消息：The redirect URI included is not valid

如果您能够登录主站点的 Web 界面，但在尝试登录从站点 Web 界面时收到此错误消息，则应验证 Geo 站点的 URL 与其外部 URL 是否匹配。

先决条件：

- 管理员访问权限。

在主站点上：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择 **Geo** > **站点**。
1. 找到受影响的从站点并选择**编辑**。
1. 确保 **URL** 字段与从站点 Rails 节点上 `/etc/gitlab/gitlab.rb`
   中 `external_url "https://gitlab.example.com"` 的值一致。

<a id="authenticating-with-saml-on-the-secondary-site-always-lands-on-the-primary-site"></a>

#### 在从站点上使用 SAML 进行身份验证时总是跳转到主站点

此[问题通常在升级到极狐GitLab 15.1 时遇到](../../../update/versions/gitlab_15_changes.md#1510)。要解决此问题，请参阅[在 Geo 中通过单点登录配置实例级 SAML](../replication/single_sign_on.md#configuring-instance-wide-saml)。

<a id="recovering-from-a-partial-failover"></a>

## 从部分故障转移中恢复

向 Geo 从站点的部分故障转移可能是临时/瞬态问题导致的。因此，请先尝试再次运行提升命令。

1. 通过 SSH 登录从站点中的每个 Sidekiq、PostgreSQL、Gitaly 和 Rails 节点，并运行以下命令之一：

   - 将从站点提升为主站点：

     ```shell
     sudo gitlab-ctl geo promote
     ```

   - 在无需进一步确认的情况下将从站点提升为主站点：

     ```shell
     sudo gitlab-ctl geo promote --force
     ```

1. 验证您能否使用之前用于从站点的 URL 连接到新提升的主站点。
1. 如果成功，从站点现已提升为主站点。

如果前面的步骤未成功，请继续执行以下步骤：

1. 通过 SSH 登录从站点中的每个 Sidekiq、PostgreSQL、Gitaly 和 Rails 节点，并执行以下操作：

   - 创建包含以下内容的 `/etc/gitlab/gitlab-cluster.json` 文件：

     ```shell
     {
       "primary": true,
       "secondary": false
     }
     ```

   - 重新配置极狐GitLab 以使更改生效：

     ```shell
     sudo gitlab-ctl reconfigure
     ```

1. 验证您能否使用之前用于从站点的 URL 连接到新提升的主站点。
1. 如果成功，从站点现已提升为主站点。
