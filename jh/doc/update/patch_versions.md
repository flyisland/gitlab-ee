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

## 前提条件

更新前：

1. 你必须[阅读必需信息并执行必需步骤](plan_your_upgrade.md)。
1. [备份](../administration/backup_restore/_index.md)你的自编译实例。

<a id="update-a-self-compiled-instance-with-a-patch-version"></a>

## 使用补丁版本更新自编译实例

要使用补丁版本更新自编译实例：

1. 考虑在更新期间[启用维护模式](../administration/maintenance_mode/_index.md)。
1. 暂停[正在运行的 CI/CD 流水线和作业](plan_your_upgrade.md#pause-cicd-pipelines-and-jobs)。
1. [升级极狐GitLab Runner](https://gitlab.cn/docs/runner/install/)到与目标极狐GitLab版本相同的版本。
1. 按照本页说明更新极狐GitLab。

更新后：

1. 取消暂停[正在运行的 CI/CD 流水线和作业](plan_your_upgrade.md#pause-cicd-pipelines-and-jobs)。
1. 如果已启用，请[关闭维护模式](../administration/maintenance_mode/_index.md#disable-maintenance-mode)。
1. 运行[健康检查](plan_your_upgrade.md#run-upgrade-health-checks)。

<a id="stop-gitlab-server"></a>

### 停止极狐GitLab 服务器

要停止极狐GitLab 服务器：

```shell
# 对于运行 systemd 的系统
sudo systemctl stop gitlab.target

# 对于运行 SysV init 的系统
sudo service gitlab stop
```

<a id="get-latest-code-for-the-stable-branch"></a>

### 获取稳定分支的最新代码

在以下命令中，将 `LATEST_TAG` 替换为要更新到的极狐GitLab 标签。例如 `v8.0.3`。

1. 检查当前版本：

   ```shell
   cat VERSION
   ```

1. 获取所有可用标签列表：

   ```shell
   git tag -l 'v*.[0-9]' --sort='v:refname'
   ```

1. 为当前主版本和次版本选择一个补丁版本。
1. 检出要使用的补丁版本代码：

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

# 如果你在安装或之前升级时尚未执行过
sudo -u git -H bundle config set --local deployment 'true'
sudo -u git -H bundle config set --local without 'development test kerberos'

# 更新 gem
sudo -u git -H bundle install

# 可选：清理旧 gem
sudo -u git -H bundle clean

# 运行数据库迁移
sudo -u git -H bundle exec rake db:migrate RAILS_ENV=production

# 清理资产和缓存
sudo -u git -H bundle exec rake yarn:install gitlab:assets:clean gitlab:assets:compile cache:clear RAILS_ENV=production NODE_ENV=production NODE_OPTIONS="--max_old_space_size=4096"
```

<a id="update-gitlab-workhorse-to-the-new-patch-version"></a>

### 更新 GitLab Workhorse 到新补丁版本

要将 GitLab Workhorse 更新到新补丁版本：

```shell
cd /home/git/gitlab

sudo -u git -H bundle exec rake "gitlab:workhorse:install[/home/git/gitlab-workhorse]" RAILS_ENV=production
```

<a id="update-gitaly-to-the-new-patch-version"></a>

### 更新 Gitaly 到新补丁版本

要将 Gitaly 更新到新补丁版本：

```shell
cd /home/git/gitlab

sudo -u git -H bundle exec rake "gitlab:gitaly:install[/home/git/gitaly,/home/git/repositories]" RAILS_ENV=production
```

<a id="update-gitlab-shell-to-the-new-patch-version"></a>

### 更新 GitLab Shell 到新补丁版本

要将 GitLab Shell 更新到新补丁版本：

```shell
cd /home/git/gitlab-shell

sudo -u git -H git fetch --all --tags
sudo -u git -H git checkout v$(</home/git/gitlab/GITLAB_SHELL_VERSION) -b v$(</home/git/gitlab/GITLAB_SHELL_VERSION)
sudo -u git -H make build
```

<a id="update-gitlab-pages-to-the-new-patch-version-if-required"></a>

### 更新 GitLab Pages 到新补丁版本（如果需要）

如果正在使用 GitLab Pages，请将 GitLab Pages 更新到新补丁版本：

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

要安装或更新 `gitlab-elasticsearch-indexer`，请按照
[安装说明](../integration/advanced_search/elasticsearch.md#install-an-elasticsearch-or-aws-opensearch-cluster)操作。

<a id="start-gitlab"></a>

### 启动极狐GitLab

要启动极狐GitLab，运行以下命令：

```shell
# 对于运行 systemd 的系统
sudo systemctl start gitlab.target
sudo systemctl restart nginx.service

# 对于运行 SysV init 的系统
sudo service gitlab start
sudo service nginx restart
```

<a id="check-gitlab-and-its-environment"></a>

### 检查极狐GitLab 及其环境

要检查极狐GitLab 及其环境是否配置正确，运行：

```shell
cd /home/git/gitlab

sudo -u git -H bundle exec rake gitlab:env:info RAILS_ENV=production
```

为确保没有遗漏，运行更全面的检查：

```shell
sudo -u git -H bundle exec rake gitlab:check RAILS_ENV=production
```

<a id="make-sure-background-migrations-are-finished"></a>

### 确保后台迁移已完成

[检查后台迁移的状态](background_migrations.md)并确保它们已完成。