---
stage: Create
group: Code Review
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Instance administrators can configure a custom issue closing pattern for their GitLab instance.
title: 议题关闭模式
---

<a id="issue-closing-pattern"></a>

# 议题关闭模式

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

> [!note]
> 关于议题关闭模式的用户文档，请参见 [自动关闭议题](../user/project/issues/managing_issues.md#closing-issues-automatically)。

当提交或合并请求解决了一个或多个议题时，极狐GitLab 可以在提交或合并请求合并到项目默认分支时关闭这些议题。
[默认议题关闭模式](../user/project/issues/managing_issues.md#default-closing-pattern)
涵盖了广泛的词汇，管理员可以根据需要配置词汇列表。

<a id="change-the-issue-closing-pattern"></a>

## 更改议题关闭模式

要更改默认的议题关闭模式以满足你的需求：

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

1. 编辑 `/etc/gitlab/gitlab.rb` 并更改 `gitlab_rails['gitlab_issue_closing_pattern']` 值：

   ```ruby
   gitlab_rails['gitlab_issue_closing_pattern'] = /<regular_expression>/.source
   ```

1. 保存文件并重新配置极狐GitLab：

   ```shell
   sudo gitlab-ctl reconfigure
   ```

{{< /tab >}}

{{< tab title="Helm chart（Kubernetes）" >}}

1. 导出 Helm 值：

   ```shell
   helm get values gitlab > gitlab_values.yaml
   ```

1. 编辑 `gitlab_values.yaml` 并更改 `issueClosingPattern` 值：

   ```yaml
   global:
     appConfig:
       issueClosingPattern: "<regular_expression>"
   ```

1. 保存文件并应用新值：

   ```shell
   helm upgrade -f gitlab_values.yaml gitlab gitlab/gitlab
   ```

{{< /tab >}}

{{< tab title="Docker" >}}

1. 编辑 `docker-compose.yml` 并更改 `gitlab_rails['gitlab_issue_closing_pattern']` 值：

   ```yaml
   version: "3.6"
   services:
     gitlab:
       environment:
         GITLAB_OMNIBUS_CONFIG: |
           gitlab_rails['gitlab_issue_closing_pattern'] = /<regular_expression>/.source
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   docker compose up -d
   ```

{{< /tab >}}

{{< tab title="自编译（源码）" >}}

1. 编辑 `/home/git/gitlab/config/gitlab.yml` 并更改 `issue_closing_pattern` 值：

   ```yaml
   production: &base
     gitlab:
       issue_closing_pattern: "<regular_expression>"
   ```

1. 保存文件并重启极狐GitLab：

   ```shell
   # 对于使用 systemd 的系统
   sudo systemctl restart gitlab.target

   # 对于使用 SysV init 的系统
   sudo service gitlab restart
   ```

{{< /tab >}}

{{< /tabs >}}

要测试议题关闭模式，请使用 [Rubular](https://rubular.com)。
Rubular 无法理解 `%{issue_ref}`。在测试你的模式时，请将此字符串替换为 `#\d+`，它仅匹配本地议题引用，如 `#123`。