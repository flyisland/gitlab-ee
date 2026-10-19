---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 使用补丁版本更新自编译实例
description: 使用补丁版本更新单节点自编译实例。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

使用补丁版本更新自编译实例。

<a id="prerequisites"></a>

## 先决条件

更新之前：

1. 您必须[阅读必需信息并执行必需步骤](plan_your_upgrade.md)。
1. [备份](../administration/backup_restore/_index.md)您的自编译实例。

<a id="update-a-self-compiled-instance-with-a-patch-version"></a>

## 使用补丁版本更新自编译实例

要使用补丁版本更新自编译实例：

1. 考虑在更新期间[开启维护模式](../administration/maintenance_mode/_index.md)。
1. 暂停[正在运行的 CI/CD 流水线和作业](plan_your_upgrade.md#pause-cicd-pipelines-and-jobs)。
1. 将[极狐GitLab Runner](https://gitlab.cn/docs/runner/install/) 升级到与目标极狐GitLab 版本相同的版本。
1. 按照本页的说明更新极狐GitLab。

更新之后：

1. 取消暂停[正在运行的 CI/CD 流水线和作业](plan_your_upgrade.md#pause-cicd-pipelines-and-jobs)。
1. 如果已启用，[关闭维护模式](../administration/maintenance_mode/_index.md#disable-maintenance-mode)。
1. 运行[健康检查](plan_your_upgrade.md#run-upgrade-health-checks)。

<a id="stop-gitlab-server"></a>

### 停止极狐GitLab 服务器

要停止极狐GitLab 服务器：

```shell
# For systems running systemd
sudo systemctl stop gitlab.target

# For systems running SysV init
sudo service gitlab stop
```

<a id="get-latest-code-for-the-stable-branch"></a>

### 获取稳定分支的最新代码

在以下命令中，将 `LATEST_TAG` 替换为要更新到的极狐GitLab 标签。例如，`v8.0.3`。

1. 检查您的当前版本：

   ```shell
   cat VERSION
   ```

1. 获取所有可用标签的列表：

   ```shell
   git tag -l 'v*.[0-9]' --sort='v:refname'
   ```

1. 为您的当前主版本和次版本选择一个补丁版本。
1. 检出要使用的补丁版本的代码：

   ```shell
   cd /home/git/gitlab

   sudo -u git -H git fetch --all
   sudo -u git -H git checkout -- Gemfile.lock db/structure.sql locale
   sudo -u git -H git checkout LATEST_TAG -b LATEST_TAG
   ```

<a id="install-libraries-and-run-migrations"></a>

### 安装库并运行迁移

要安装库并运行迁移，请运行以下命令：

```shell
cd /home/git/gitlab

# If you haven't done so during installation or a previous upgrade already
sudo -u git -H bundle config set --local deployment 'true'
sudo -u git -H bundle config set --local without 'development test kerberos'

# Update gems
sudo -u git -H bundle install

# Optional: clean up old gems
sudo -u git -H bundle clean

# Run database migrations
sudo -u git -H bundle exec rake db:migrate RAILS_ENV=production

# Clean up assets and cache
sudo -u git -H bundle exec rake yarn:install gitlab:assets:clean gitlab:assets:compile cache:clear RAILS_ENV=production NODE_ENV=production NODE_OPTIONS="--max_old_space_size=4096"
```

<a id="update-gitlab-workhorse-to-the-new-patch-version"></a>

### 将 GitLab Workhorse 更新到新的补丁版本

要将 GitLab Workhorse 更新到新的补丁版本：

```shell
cd /home/git/gitlab

sudo -u git -H bundle exec rake "gitlab:workhorse:install[/home/git/gitlab-workhorse]" RAILS_ENV=production
```

<a id="update-gitaly-to-the-new-patch-version"></a>

### 将 Gitaly 更新到新的补丁版本

要将 Gitaly 更新到新的补丁版本：

```shell
cd /home/git/gitlab

sudo -u git -H bundle exec rake "gitlab:gitaly:install[/home/git/gitaly,/home/git/repositories]" RAILS_ENV=production
```

<a id="update-gitlab-shell-to-the-new-patch-version"></a>

### 将 GitLab Shell 更新到新的补丁版本

要将 GitLab Shell 更新到新的补丁版本：

```shell
cd /home/git/gitlab-shell

sudo -u git -H git fetch --all --tags
sudo -u git -H git checkout v$(</home/git/gitlab/GITLAB_SHELL_VERSION) -b v$(</home/git/gitlab/GITLAB_SHELL_VERSION)
sudo -u git -H make build
```

<a id="update-gitlab-pages-to-the-new-patch-version-if-required"></a>

### 将 GitLab Pages 更新到新的补丁版本（如需要）

如果您使用 GitLab Pages，请将 GitLab Pages 更新到新的补丁版本：

```shell
cd /home/git/gitlab-pages

sudo -u git -H git fetch --all --tags
sudo -u git -H git checkout v$(</home/git/gitlab/GITLAB_PAGES_VERSION)
sudo -u git -H make
```

<a id="install-or-update-gitlab-elasticsearch-indexer"></a>

### 安装或更新 `gitlab-elasticsearch-indexer`

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

要安装或更新 `gitlab-elasticsearch-indexer`，请遵循[安装说明](../integration/advanced_search/elasticsearch.md#install-an-elasticsearch-or-aws-opensearch-cluster)。

<a id="start-gitlab"></a>

### 启动极狐GitLab

要启动极狐GitLab，请运行以下命令：

```shell
# For systems running systemd
sudo systemctl start gitlab.target
sudo systemctl restart nginx.service

# For systems running SysV init
sudo service gitlab start
sudo service nginx restart
```

<a id="check-gitlab-and-its-environment"></a>

### 检查极狐GitLab 及其环境

要检查极狐GitLab 及其环境是否配置正确，请运行：

```shell
cd /home/git/gitlab

sudo -u git -H bundle exec rake gitlab:env:info RAILS_ENV=production
```

要确保没有遗漏任何内容，请使用以下命令运行更彻底的检查：

```shell
sudo -u git -H bundle exec rake gitlab:check RAILS_ENV=production
```

<a id="make-sure-background-migrations-are-finished"></a>

### 确保后台迁移已完成

[检查后台迁移的状态](background_migrations.md)并确保它们已完成。
