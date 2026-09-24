---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 将极狐GitLab 置为只读状态
description: Place GitLab into a read-only state
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

> [!note]
> 推荐将极狐GitLab 设为只读状态的方法是启用 [维护模式](maintenance_mode/_index.md)。

在某些情况下，你可能希望将极狐GitLab 置于只读状态。具体的配置方法取决于你期望的结果。

<a id="make-the-repositories-read-only"></a>

## 将代码仓库设为只读

第一件要做的事是确保你的代码仓库不会被做出任何更改。有两种方法可以实现：

- 要么停止 Puma 使内部 API 不可达：

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

  如果只想将一部分代码仓库设为只读，请运行以下命令：

  ```ruby
  # 要设为只读的项目的项目 ID 列表。
  projects = [1,2,3]

  projects.each do |p|
   project =  Project.find p
   project.update!(repository_read_only: true)
   rescue ActiveRecord::RecordNotFound
   puts "项目 ID #{p} 未找到"

  end
  ```

  当你准备撤销时，请将项目的 `repository_read_only` 更改为 `false`。例如，运行以下命令：

  ```ruby
  Project.all.find_each { |project| project.update!(repository_read_only: false) }
  ```

<a id="shut-down-the-gitlab-ui"></a>

## 关闭极狐GitLab UI

如果你不介意关闭极狐GitLab UI，那么最简单的方法是停止 `sidekiq` 和 `puma`，这样可以确保不会对极狐GitLab 做出任何更改：

```shell
sudo gitlab-ctl stop sidekiq
sudo gitlab-ctl stop puma
```

当你准备撤销时：

```shell
sudo gitlab-ctl start sidekiq
sudo gitlab-ctl start puma
```

<a id="make-the-database-read-only"></a>

## 将数据库设为只读

如果你希望允许用户使用极狐GitLab UI，请确保数据库处于只读状态：

1. 先进行 [极狐GitLab 备份](backup_restore/_index.md) 以防不测。
2. 以管理员用户身份进入 PostgreSQL 控制台：

   ```shell
   sudo \
       -u gitlab-psql /opt/gitlab/embedded/bin/psql \
       -h /var/opt/gitlab/postgresql gitlabhq_production
   ```

3. 创建 `gitlab_read_only` 用户。密码设置为 `mypassword`，你可以自行更改：

   ```sql
   -- 注意：使用之前定义的密码
   CREATE USER gitlab_read_only WITH password 'mypassword';
   GRANT CONNECT ON DATABASE gitlabhq_production to gitlab_read_only;
   GRANT USAGE ON SCHEMA public TO gitlab_read_only;
   GRANT SELECT ON ALL TABLES IN SCHEMA public TO gitlab_read_only;
   GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO gitlab_read_only;

   -- 由 “gitlab” 创建的表应自动对 “gitlab_read_only” 设为只读。
   ALTER DEFAULT PRIVILEGES FOR USER gitlab IN SCHEMA public GRANT SELECT ON TABLES TO gitlab_read_only;
   ALTER DEFAULT PRIVILEGES FOR USER gitlab IN SCHEMA public GRANT SELECT ON SEQUENCES TO gitlab_read_only;
   ```

4. 获取 `gitlab_read_only` 用户的哈希密码并复制结果：

   ```shell
   sudo gitlab-ctl pg-password-md5 gitlab_read_only
   ```

5. 编辑 `/etc/gitlab/gitlab.rb` 并添加从上一步获得的密码：

   ```ruby
   postgresql['sql_user_password'] = 'a2e20f823772650f039284619ab6f239'
   postgresql['sql_user'] = "gitlab_read_only"
   ```

6. 重新配置极狐GitLab 并重启 PostgreSQL：

   ```shell
   sudo gitlab-ctl reconfigure
   sudo gitlab-ctl restart postgresql
   ```

当你准备撤销只读状态时，请移除 `/etc/gitlab/gitlab.rb` 中添加的行，然后重新配置极狐GitLab 并重启 PostgreSQL：

```shell
sudo gitlab-ctl reconfigure
sudo gitlab-ctl restart postgresql
```

在确认一切按预期工作后，从数据库中删除 `gitlab_read_only` 用户。