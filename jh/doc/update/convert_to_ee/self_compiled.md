---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 将自编译的基础版实例转换为企业版
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

您可以将现有的自编译实例从基础版（CE）转换为企业版（EE）。

这些说明假设您已正确配置并测试了自编译的极狐GitLab 基础版安装。

<a id="convert-from-ce-to-ee"></a>

## 将基础版转换为企业版

在以下说明中，请替换：

- `EE_BRANCH` 为您所使用的版本对应的企业版分支。企业版分支名称格式为 `major-minor-stable-ee`。
  例如 `17-7-stable-ee`。
- `CE_BRANCH` 为基础版分支。基础版分支名称格式为 `major-minor-stable`。
  例如 `17-7-stable`。

<a id="backup"></a>

### 备份

要备份极狐GitLab，请输入：

```shell
cd /home/git/gitlab
sudo -u git -H bundle exec rake gitlab:backup:create RAILS_ENV=production
```

<a id="stop-gitlab-server"></a>

### 停止 极狐GitLab 服务器

要停止极狐GitLab 服务器，请输入：

```shell
sudo service gitlab stop
```

<a id="get-the-ee-code"></a>

### 获取企业版代码

要获取企业版代码，请输入：

```shell
cd /home/git/gitlab
sudo -u git -H git remote add -f ee https://jihulab.com/gitlab-cn/gitlab.git
sudo -u git -H git checkout EE_BRANCH
```

<a id="install-libraries-and-run-migrations"></a>

### 安装库并运行迁移

要安装库并运行迁移，请输入：

```shell
cd /home/git/gitlab

# 如果您在安装期间或之前的升级中尚未执行此操作
sudo -u git -H bundle config set --local deployment 'true'
sudo -u git -H bundle config set --local without 'development test kerberos'

# 更新 gems
sudo -u git -H bundle install

# 可选：清理旧 gems
sudo -u git -H bundle clean

# 运行数据库迁移
sudo -u git -H bundle exec rake db:migrate RAILS_ENV=production

# 更新节点依赖并重新编译资产
sudo -u git -H bundle exec rake yarn:install gitlab:assets:clean gitlab:assets:compile RAILS_ENV=production NODE_ENV=production NODE_OPTIONS="--max_old_space_size=4096"

# 清理缓存
sudo -u git -H bundle exec rake cache:clear RAILS_ENV=production
```

<a id="install-gitlab-elasticsearch-indexer"></a>

### 安装 `gitlab-elasticsearch-indexer`

{{< details >}}

- Tier: 专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

要安装 `gitlab-elasticsearch-indexer`，请遵循[安装说明](../../integration/advanced_search/elasticsearch.md#install-an-elasticsearch-or-aws-opensearch-cluster)。

<a id="start-the-application"></a>

### 启动应用程序

要启动应用程序，请输入：

```shell
sudo service gitlab start
sudo service nginx restart
```

<a id="check-application-status"></a>

### 检查应用程序状态

检查极狐GitLab 及其环境是否已正确配置：

```shell
sudo -u git -H bundle exec rake gitlab:env:info RAILS_ENV=production
```

为确保您没有遗漏任何内容，请运行更全面的检查：

```shell
sudo -u git -H bundle exec rake gitlab:check RAILS_ENV=production
```

如果所有项目均为绿色，那么恭喜，升级完成！

<a id="revert-back-to-ce"></a>

## 回退至基础版

如果在转换至企业版时遇到问题并想回退至基础版：

1. 将代码回退至之前的版本：

   ```shell
   cd /home/git/gitlab
   sudo -u git -H git checkout CE_BRANCH
   ```

1. 从备份恢复：

   ```shell
   cd /home/git/gitlab
   sudo -u git -H bundle exec rake gitlab:backup:restore RAILS_ENV=production
   ```

有关将企业版实例回退至基础版的信息，请参见[如何从企业版回退至基础版](revert.md)。