---
stage: Plan
group: Work Items
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 服务台
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

> [!note]
> 此功能目前未在积极开发中，但欢迎
> [社区贡献](https://about.gitlab.com/community/contribute/)。
> 要判断该功能当前形态是否满足您的需求，请浏览现有文档，或查看
> [服务台类别的未关闭议题](https://gitlab.com/gitlab-org/gitlab/-/issues/?sort=updated_desc&state=opened&label_name%5B%5D=Category%3AService%20Desk&first_page_size=100)
> 以了解尚未完成的工作。
> 降低服务台优先级这一决定，是为了
> 专注于构建和扩展工作项框架，
> 服务台类别长期来看也将从中受益。
>
> 有关将服务台迁移到工作项框架的信息，
> 请参见 [史诗 10772](https://gitlab.com/groups/gitlab-org/-/epics/10772)。

借助服务台，您的客户可以通过电子邮件向您发送缺陷报告、功能请求或一般反馈。服务台提供唯一的电子邮件地址，因此他们不需要自己的极狐GitLab 账号。

服务台邮件会在您的极狐GitLab 项目中创建为新工单。您的团队可以直接从项目中回复，而客户仅通过电子邮件参与讨论串。


<a id="service-desk-workflow"></a>

## 服务台工作流

例如，假设您为 iOS 或 Android 开发一款游戏。代码库托管在您的极狐GitLab 实例中，并通过极狐GitLab CI/CD 构建和部署。

以下是服务台为您工作的方式：

1. 您向付费客户提供项目专属的电子邮件地址，他们可以直接从应用程序中向您发送邮件。
1. 他们发送的每封电子邮件都会在相应项目中创建一个工单。
1. 您的团队成员前往服务台工单跟踪器，在那里他们可以查看新的支持请求并在关联工单中回复。
1. 您的团队与客户沟通以了解请求。
1. 您的团队开始编写代码以解决客户的问题。
1. 当您的团队完成实现后，合并请求被合并，工单会自动关闭。

与此同时：

- 客户完全通过电子邮件与您的团队互动，无需访问您的极狐GitLab 实例。
- 您的团队无需离开极狐GitLab（或设置集成）即可跟进客户，从而节省时间。

<a id="troubleshooting-service-desk"></a>

## 服务台故障排除

<a id="emails-to-service-desk-do-not-create-tickets"></a>

### 发送到服务台的电子邮件未创建工单

- 您的电子邮件可能被忽略，因为它们包含
  [极狐GitLab 会忽略的电子邮件标头](../../../administration/incoming_email.md#rejected-headers)之一。
- 如果发件人电子邮件域使用严格的 DKIM 规则，并且由于将电子邮件转发到项目专属的服务台地址而导致验证失败，电子邮件可能会被丢弃。
  典型的 DKIM 失败消息（可在电子邮件标头中找到）可能如下所示：

  ```plaintext
  dkim=fail (signature did not verify) ... arc=fail
  ```

  失败消息的确切措辞可能因所使用的具体电子邮件系统或工具而异。
  另请参见[这篇关于 DKIM 失败的文章](https://automatedemailwarmup.com/blog/dkim-fail/)以获取更多信息和潜在解决方案。

<a id="email-ingestion-doesnt-work-in-1660"></a>

### 16.6.0 中电子邮件接收无法工作

极狐GitLab 私有化部署 `16.6.0` 引入了一个回归问题，导致 `mail_room`（电子邮件接收）无法启动。服务台和其他通过电子邮件回复的功能无法工作。
[议题 432257](https://gitlab.com/gitlab-org/gitlab/-/issues/432257) 跟踪此问题的修复。

变通方法是在您的极狐GitLab 安装中运行以下命令以修补受影响的文件：

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

```shell
curl --output /tmp/mailroom.patch --url "https://gitlab.com/gitlab-org/gitlab/-/merge_requests/137279.diff"
patch -p1 -d /opt/gitlab/embedded/service/gitlab-rails < /tmp/mailroom.patch
gitlab-ctl restart mailroom
```

{{< /tab >}}

{{< tab title="Docker" >}}

```shell
curl --output /tmp/mailroom.patch --url "https://gitlab.com/gitlab-org/gitlab/-/merge_requests/137279.diff"
cd /opt/gitlab/embedded/service/gitlab-rails
patch -p1 < /tmp/mailroom.patch
gitlab-ctl restart mailroom
```

{{< /tab >}}

{{< /tabs >}}
