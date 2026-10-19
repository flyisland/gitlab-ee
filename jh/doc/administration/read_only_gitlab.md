---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 将极狐GitLab 置于只读状态
description: 将极狐GitLab 置于只读状态。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

> [!note]
> 将极狐GitLab 置于只读状态的推荐方法是启用
> [维护模式](maintenance_mode/_index.md)。

在某些情况下，您可能希望将极狐GitLab 置于只读状态。具体如何配置取决于您想要达成的目标。

<a id="make-the-repositories-read-only"></a>

## 将代码仓库设为只读

您首先要做的是确保无法对代码仓库进行任何更改。您可以通过两种方式实现这一点：

- 停止 Puma，使内部 API 无法访问：

  ```shell
  sudo gitlab-ctl stop puma
  ```

- 或者，打开 Rails 控制台：

  ```shell
  sudo gitlab-rails console
  ```

  并将所有项目的代码仓库设为只读：

  ```ruby
  Project.all.find_each { |project| project.update!(repository_read_only: true) }
  ```

  如果只想将部分代码仓库设为只读，请运行以下命令：

  ```ruby
  # List of project IDs of projects to set to read-only.
  projects = [1,2,3]

  projects.each do |p|
   project =  Project.find p
   project.update!(repository_read_only: true)
   rescue ActiveRecord::RecordNotFound
   puts "Project ID #{p} not found"

  end
  ```

  当您准备还原此操作时，请将这些项目的 `repository_read_only` 改为 `false`。例如，运行以下命令：

  ```ruby
  Project.all.find_each { |project| project.update!(repository_read_only: false) }
  ```

<a id="shut-down-the-gitlab-ui"></a>

## 关闭极狐GitLab UI

如果您不介意关闭极狐GitLab UI，那么最简单的方法是停止 `sidekiq` 和 `puma`，这样就能有效确保无法对极狐GitLab 进行任何更改：

```shell
sudo gitlab-ctl stop sidekiq
sudo gitlab-ctl stop puma
```

当您准备还原此操作时：

```shell
sudo gitlab-ctl start sidekiq
sudo gitlab-ctl start puma
```

<a id="make-the-database-read-only"></a>

## 将数据库设为只读

如果您希望允许用户使用极狐GitLab UI，请确保数据库为只读：

1. 进行[极狐GitLab 备份](backup_restore/_index.md)，
   以防出现意外情况。
1. 以管理员用户身份在控制台上进入 PostgreSQL：

   ```shell
   sudo \
       -u gitlab-psql /opt/gitlab/embedded/bin/psql \
       -h /var/opt/gitlab/postgresql gitlabhq_production
   ```

1. 创建 `gitlab_read_only` 用户。密码设置为 `mypassword`，
   请按您的需要修改：

   ```sql
   -- NOTE: Use the password defined earlier
   CREATE USER gitlab_read_only WITH password 'mypassword';
   GRANT CONNECT ON DATABASE gitlabhq_production to gitlab_read_only;
   GRANT USAGE ON SCHEMA public TO gitlab_read_only;
   GRANT SELECT ON ALL TABLES IN SCHEMA public TO gitlab_read_only;
   GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO gitlab_read_only;

   -- Tables created by "gitlab" should be made read-only for "gitlab_read_only"
   -- automatically.
   ALTER DEFAULT PRIVILEGES FOR USER gitlab IN SCHEMA public GRANT SELECT ON TABLES TO gitlab_read_only;
   ALTER DEFAULT PRIVILEGES FOR USER gitlab IN SCHEMA public GRANT SELECT ON SEQUENCES TO gitlab_read_only;
   ```

1. 获取 `gitlab_read_only` 用户的哈希密码并复制结果：

   ```shell
   sudo gitlab-ctl pg-password-md5 gitlab_read_only
   ```

1. 编辑 `/etc/gitlab/gitlab.rb` 并添加上一步得到的密码：

   ```ruby
   postgresql['sql_user_password'] = 'a2e20f823772650f039284619ab6f239'
   postgresql['sql_user'] = "gitlab_read_only"
   ```

1. 重新配置极狐GitLab 并重启 PostgreSQL：

   ```shell
   sudo gitlab-ctl reconfigure
   sudo gitlab-ctl restart postgresql
   ```

当您准备还原只读状态时，请移除 `/etc/gitlab/gitlab.rb`中添加的
行，然后重新配置极狐GitLab 并重启 PostgreSQL：

```shell
sudo gitlab-ctl reconfigure
sudo gitlab-ctl restart postgresql
```

在确认一切按预期工作后，从数据库中移除 `gitlab_read_only` 用户。
