---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Webhook 管理 Rake 任务
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐GitLab 提供用于 webhook 管理的 Rake 任务。

管理员可以允许或阻止对[本地网络的 webhook 请求](../../security/webhooks.md)。

<a id="add-a-webhook-to-all-projects"></a>

## 为所有项目添加 webhook

要为所有项目添加 webhook，请运行：

```shell
# omnibus-gitlab
sudo gitlab-rake gitlab:web_hook:add URL="http://example.com/hook"

# 源代码安装
bundle exec rake gitlab:web_hook:add URL="http://example.com/hook" RAILS_ENV=production
```

<a id="add-a-webhook-to-projects-in-a-namespace"></a>

## 为命名空间中的项目添加 webhook

要为特定命名空间中的所有项目添加 webhook，请运行：

```shell
# omnibus-gitlab
sudo gitlab-rake gitlab:web_hook:add URL="http://example.com/hook" NAMESPACE=<namespace>

# 源代码安装
bundle exec rake gitlab:web_hook:add URL="http://example.com/hook" NAMESPACE=<namespace> RAILS_ENV=production
```

<a id="remove-a-webhook-from-projects"></a>

## 从项目中移除 webhook

要从所有项目中移除 webhook，请运行：

```shell
# omnibus-gitlab
sudo gitlab-rake gitlab:web_hook:rm URL="http://example.com/hook"

# 源代码安装
bundle exec rake gitlab:web_hook:rm URL="http://example.com/hook" RAILS_ENV=production
```

<a id="remove-a-webhook-from-projects-in-a-namespace"></a>

## 从命名空间中的项目移除 webhook

要从特定命名空间中的项目中移除 webhook，请运行：

```shell
# omnibus-gitlab
sudo gitlab-rake gitlab:web_hook:rm URL="http://example.com/hook" NAMESPACE=<namespace>

# 源代码安装
bundle exec rake gitlab:web_hook:rm URL="http://example.com/hook" NAMESPACE=<namespace> RAILS_ENV=production
```

<a id="list-all-webhooks"></a>

## 列出所有 webhook

要列出所有 webhook，请运行：

```shell
# omnibus-gitlab
sudo gitlab-rake gitlab:web_hook:list

# 源代码安装
bundle exec rake gitlab:web_hook:list RAILS_ENV=production
```

<a id="list-webhooks-for-projects-in-a-namespace"></a>

## 列出命名空间中项目的 webhook

要列出指定命名空间中项目的所有 webhook，请运行：

```shell
# omnibus-gitlab
sudo gitlab-rake gitlab:web_hook:list NAMESPACE=<namespace>

# 源代码安装
bundle exec rake gitlab:web_hook:list NAMESPACE=<namespace> RAILS_ENV=production
```