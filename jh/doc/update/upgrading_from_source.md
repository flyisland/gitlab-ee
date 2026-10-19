---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 升级自编译实例
description: 升级单节点自编译实例。
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

将自编译实例升级到更高版本的极狐GitLab。

<a id="prerequisites"></a>

## 先决条件

升级前：

1. 您必须[阅读必需信息并执行必需步骤](plan_your_upgrade.md)。
1. 查看 Ruby、Node.js、Go 和 PostgreSQL 的[软件要求](../install/self_compiled/_index.md#software-requirements)。

<a id="upgrade-a-self-compiled-instance"></a>

## 升级自编译实例

要升级自编译实例：

1. 考虑在升级期间[开启维护模式](../administration/maintenance_mode/_index.md)。
1. 暂停[正在运行的 CI/CD 流水线和作业](plan_your_upgrade.md#pause-cicd-pipelines-and-jobs)。
1. 将[极狐GitLab Runner](https://gitlab.cn/docs/runner/install/) 升级到与目标极狐GitLab 版本相同的版本。
1. 按照本页的说明升级极狐GitLab。

升级后：

1. 取消暂停[正在运行的 CI/CD 流水线和作业](plan_your_upgrade.md#pause-cicd-pipelines-and-jobs)。
1. 如果已启用，[关闭维护模式](../administration/maintenance_mode/_index.md#disable-maintenance-mode)。
1. 运行[升级健康检查](plan_your_upgrade.md#run-upgrade-health-checks)。

<a id="create-a-backup"></a>

### 创建备份

先决条件：

- 确保已安装 `rsync`。

要创建备份：

```shell
cd /home/git/gitlab

sudo -u git -H bundle exec rake gitlab:backup:create RAILS_ENV=production
```

<a id="stop-gitlab"></a>

### 停止极狐GitLab

要停止极狐GitLab：

```shell
# For systems running systemd
sudo systemctl stop gitlab.target

# For systems running SysV init
sudo service gitlab stop
```

<a id="update-ruby"></a>

### 更新 Ruby

如果需要更高版本的 Ruby，您必须更新 Ruby：

1. 要检查您当前的 Ruby 版本，请运行：

   ```shell
   ruby -v
   ```

1. 有关更新到更高版本 Ruby 的说明，请参阅
   [Ruby 安装说明](https://www.ruby-lang.org/en/documentation/installation/)。

<a id="update-nodejs"></a>

### 更新 Node.js

如果需要更高版本的 Node.js，您必须更新 Node.js：

1. 要检查您当前的 Node.js 版本，请运行：

   ```shell
   node -v
   ```

1. 有关更新到更高版本 Node.js 的说明，请参阅
   [Node.js 下载说明](https://nodejs.org/en/download)。

极狐GitLab 还需要 Yarn `>= v1.10.0` 来管理 JavaScript 依赖项。更多信息，请参阅
[Yarn 网站](https://classic.yarnpkg.com/en/docs/install)。

<a id="update-go"></a>

### 更新 Go

如果需要更高版本的 Go，您必须更新 Go：

1. 要检查您当前的 Go 版本，请运行：

   ```shell
   go version
   ```

1. 有关更新到更高版本 Go 的说明，请参阅
   [Go 安装说明](https://go.dev/doc/install)。

<a id="update-git"></a>

### 更新 Git

您应使用 Gitaly 提供的 Git 版本。更多信息，请参阅
[极狐GitLab 的 Git 安装说明](../install/self_compiled/_index.md#git)。

<a id="update-postgresql"></a>

### 更新 PostgreSQL

如果需要更高版本的 PostgreSQL，您必须更新 PostgreSQL：

1. 要检查您当前的 PostgreSQL 版本，请运行：

   ```shell
   pg_ctl --version
   ```

1. 有关更新到更高版本 PostgreSQL 的说明，请参阅
   [PostgreSQL 升级文档](https://www.postgresql.org/docs/16/upgrading.html)。
1. 确保您已安装所需的 [PostgreSQL 扩展](../install/requirements.md#postgresql)。

<a id="update-the-gitlab-codebase"></a>

### 更新极狐GitLab 代码库

要更新您的极狐GitLab 代码库克隆：

1. 获取代码仓库元数据：

   ```shell
   cd /home/git/gitlab

   sudo -u git -H git fetch --all --prune
   sudo -u git -H git checkout -- Gemfile.lock db/structure.sql locale
   ```

1. 检出您要升级到的版本对应的分支：

   {{< tabs >}}

   {{< tab title="GitLab Enterprise Edition" >}}

   ```shell
   cd /home/git/gitlab

   sudo -u git -H git checkout <BRANCH-ee>
   ```

   {{< /tab >}}

   {{< tab title="GitLab Community Edition" >}}

   ```shell
   cd /home/git/gitlab

   sudo -u git -H git checkout <BRANCH>
   ```

   {{< /tab >}}

   {{< /tabs >}}

<a id="update-configuration-files"></a>

### 更新配置文件

极狐GitLab 升级可能需要更新以下配置：

- `gitlab.yml`
- `database.yml`
- NGINX（或 Apache）
- SMTP
- systemd
- SysV

以下各节介绍如何确定是否需要更新配置。

<a id="new-configuration-for-gitlabyml"></a>

#### `gitlab.yml`的新配置

[`gitlab.yml`](https://jihulab.com/gitlab-cn/gitlab/-/blob/master/config/gitlab.yml.example) 可能有新的配置选项。

1. 查看可能的新配置：

   ```shell
   cd /home/git/gitlab
   git diff origin/PREVIOUS_BRANCH:config/gitlab.yml.example origin/BRANCH:config/gitlab.yml.example
   ```

1. 将新配置手动应用到您当前的 `gitlab.yml`。

<a id="new-configuration-for-databaseyml"></a>

#### `database.yml`的新配置

[`database.yml`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/config/database.yml.postgresql) 可能有新的配置选项。

1. 查看可能的新配置：

   ```shell
   cd /home/git/gitlab
   git diff origin/PREVIOUS_BRANCH:config/database.yml.postgresql origin/BRANCH:config/database.yml.postgresql
   ```

1. 将新配置手动应用到您当前的 `database.yml`。

<a id="new-configuration-for-nginx-or-apache"></a>

#### NGINX 或 Apache 的新配置

确保您仍与最新的 NGINX 配置变更保持同步：

```shell
cd /home/git/gitlab

# For HTTPS configurations
git diff origin/PREVIOUS_BRANCH:lib/support/nginx/gitlab-ssl origin/BRANCH:lib/support/nginx/gitlab-ssl

# For HTTP configurations
git diff origin/PREVIOUS_BRANCH:lib/support/nginx/gitlab origin/BRANCH:lib/support/nginx/gitlab
```

极狐GitLab 应用不再在您的安装中设置 Strict-Transport-Security。要继续使用它，您必须在
NGINX 配置中启用它。

如果您使用 Apache 而不是 NGINX，请参阅更新后的 [Apache 模板](https://gitlab.com/gitlab-org/gitlab-recipes/tree/master/web-server/apache)。由于 Apache 不支持位于 Unix 套接字后面的上游，您必须通过
[`/etc/default/gitlab`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/support/init.d/gitlab.default.example#L38) 让 GitLab Workhorse 监听 TCP 端口。

<a id="smtp-configuration"></a>

#### SMTP 配置

如果您使用 SMTP 发送邮件，必须将以下行添加到 `config/initializers/smtp_settings.rb`：

```ruby
ActionMailer::Base.delivery_method = :smtp
```

有关示例，请参阅 [`smtp_settings.rb.sample`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/config/initializers/smtp_settings.rb.sample#L13)。

<a id="configure-systemd-units"></a>

#### 配置 systemd 单元

1. 检查 systemd 单元是否已更新：

   ```shell
   cd /home/git/gitlab

   git diff origin/PREVIOUS_BRANCH:lib/support/systemd origin/BRANCH:lib/support/systemd
   ```

1. 将它们复制过来：

   ```shell
   sudo mkdir -p /usr/local/lib/systemd/system
   sudo cp lib/support/systemd/* /usr/local/lib/systemd/system/
   sudo systemctl daemon-reload
   ```

<a id="configure-sysv-init-script"></a>

#### 配置 SysV init 脚本

[`gitlab.default.example`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/support/init.d/gitlab.default.example) 可能有新的配置选项。

1. 查看可能的新配置：

   ```shell
   cd /home/git/gitlab

   git diff origin/PREVIOUS_BRANCH:lib/support/init.d/gitlab.default.example origin/BRANCH:lib/support/init.d/gitlab.default.example
   ```

1. 将它们手动应用到您当前的 `/etc/default/gitlab`。

确保您仍与最新的 init 脚本变更保持同步：

```shell
cd /home/git/gitlab

sudo cp lib/support/init.d/gitlab /etc/init.d/gitlab
```

如果您在将 systemd 作为 init 运行的系统上使用 init 脚本，因为您尚未切换到原生 systemd 单元，请运行：

```shell
sudo systemctl daemon-reload
```

<a id="install-libraries-and-run-migrations"></a>

### 安装库并运行迁移

要安装库并运行迁移：

1. 安装所需的库：

   ```shell
   cd /home/git/gitlab

   # If you haven't done so during installation or a previous upgrade already
   sudo -u git -H bundle config set --local deployment 'true'
   sudo -u git -H bundle config set --local without 'development test kerberos'

   # Update gems
   sudo -u git -H bundle install

   # Optional: clean up old gems
   sudo -u git -H bundle clean
   ```

1. 运行迁移：

   ```shell
   # Run database migrations
   sudo -u git -H bundle exec rake db:migrate RAILS_ENV=production

   # Update node dependencies and recompile assets
   sudo -u git -H bundle exec rake yarn:install gitlab:assets:clean gitlab:assets:compile RAILS_ENV=production NODE_ENV=production NODE_OPTIONS="--max_old_space_size=4096"

   # Clean up cache
   sudo -u git -H bundle exec rake cache:clear RAILS_ENV=production
   ```

<a id="update-gitlab-shell"></a>

### 更新 GitLab Shell

要更新 GitLab Shell，请运行以下命令：

```shell
cd /home/git/gitlab-shell

sudo -u git -H git fetch --all --tags --prune
sudo -u git -H git checkout v$(</home/git/gitlab/GITLAB_SHELL_VERSION)
sudo -u git -H make build
```

<a id="update-gitlab-workhorse"></a>

### 更新 GitLab Workhorse

要安装并编译 GitLab Workhorse，请运行以下命令：

```shell
cd /home/git/gitlab

sudo -u git -H bundle exec rake "gitlab:workhorse:install[/home/git/gitlab-workhorse]" RAILS_ENV=production
```

<a id="update-gitaly"></a>

### 更新 Gitaly

在升级应用服务器之前，先将 Gitaly 服务器升级到较新版本。这可以防止应用服务器上的 gRPC 客户端
发送旧版 Gitaly 不支持的 RPC。

如果 Gitaly 位于其自己的服务器上，或者您使用 Gitaly 集群（Praefect），请参阅[零停机升级](zero_downtime.md)。

在构建过程中，Gitaly [会编译并嵌入 Git 二进制文件](https://gitlab.com/gitlab-org/gitaly/-/issues/6089)，这需要额外的依赖项。

```shell
# Install dependencies
sudo apt-get install -y libcurl4-openssl-dev libexpat1-dev gettext libz-dev libssl-dev libpcre2-dev build-essential

# Fetch Gitaly source with Git and compile with Go
cd /home/git/gitlab
sudo -u git -H bundle exec rake "gitlab:gitaly:install[/home/git/gitaly,/home/git/repositories]" RAILS_ENV=production
```

<a id="update-gitlab-pages"></a>

### 更新 GitLab Pages

要安装并编译 GitLab Pages：

```shell
cd /home/git/gitlab-pages

sudo -u git -H git fetch --all --tags --prune
sudo -u git -H git checkout v$(</home/git/gitlab/GITLAB_PAGES_VERSION)
sudo -u git -H make
```

<a id="post-upgrade-steps"></a>

### 升级后步骤

升级后：

1. [启动极狐GitLab 和 NGINX](#start-gitlab-and-nginx)。
1. [检查极狐GitLab 状态](#check-gitlab-status)。

<a id="start-gitlab-and-nginx"></a>

#### 启动极狐GitLab 和 NGINX

要启动极狐GitLab 和 NGINX：

```shell
# For systems running systemd
sudo systemctl start gitlab.target
sudo systemctl restart nginx.service

# For systems running SysV init
sudo service gitlab start
sudo service nginx restart
```

<a id="check-gitlab-status"></a>

#### 检查极狐GitLab 状态

要检查极狐GitLab 的状态：

1. 检查极狐GitLab 及其环境是否配置正确：

   ```shell
   cd /home/git/gitlab
   sudo -u git -H bundle exec rake gitlab:env:info RAILS_ENV=production
   ```

1. 为确保您没有遗漏任何内容，请运行更彻底的检查：

   ```shell
   cd /home/git/gitlab

   sudo -u git -H bundle exec rake gitlab:check RAILS_ENV=production
   ```

如果所有项目均为绿色，那么恭喜您，升级已完成！

<a id="troubleshooting"></a>

## 故障排除

如果您在升级过程中遇到问题，请尝试以下各节中的一些步骤。

<a id="revert-the-code-to-the-previous-version"></a>

### 将代码还原到之前的版本

要还原到之前的版本，您必须遵循之前版本的升级指南。

例如，如果您已升级到极狐GitLab 19.2 并想还原回 19.1，请遵循从 19.0 升级到 19.1 的指南。

还原时：

- 您不应遵循数据库迁移指南，因为备份已经迁移到之前的版本。
- 如果您运行了数据库迁移，则必须在降级后恢复备份。代码版本必须与所使用的模式版本兼容。较旧的模式在备份中。

<a id="restore-from-a-backup"></a>

### 从备份恢复

要从备份恢复：

```shell
cd /home/git/gitlab

sudo -u git -H bundle exec rake gitlab:backup:restore RAILS_ENV=production
```

如果您有多个备份 `*.tar` 文件，请将 `BACKUP=timestamp_of_backup` 添加到上一个代码块。
