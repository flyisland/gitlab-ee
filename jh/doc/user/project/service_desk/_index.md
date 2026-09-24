---
stage: Plan
group: Project Management
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 服务台
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

> [!note]
> 该功能未进行积极开发，但欢迎[社区贡献](https://gitlab.cn/community/contribute/)。
> 若要确定该功能是否满足您的需求，请浏览现有文档。
> 降低服务台优先级的决定是为了专注于构建和扩展工作项框架，服务台类别也将从中长期受益。
>
> 有关将服务台迁移至工作项框架的信息，请参见[史诗 10772](https://gitlab.com/groups/gitlab-org/-/epics/10772)。

通过服务台，您的客户可以通过电子邮件向您发送错误报告、功能请求或一般反馈。服务台提供唯一的电子邮件地址，因此他们无需拥有自己的极狐GitLab 帐户。

服务台邮件会作为新工单在您的极狐GitLab 项目中创建。您的团队可以直接从项目回复，而客户仅通过电子邮件与主题进行交互。

<a id="service-desk-workflow"></a>

## 服务台工作流

例如，假设您为 iOS 或 Android 开发游戏。代码库托管在您的极狐GitLab 实例中，使用极狐GitLab CI/CD 构建和部署。

服务台的工作方式如下：

1. 您向付费客户提供一个特定于项目的电子邮件地址，他们可以直接从应用程序向您发送邮件。
1. 他们发送的每封邮件都会在相应的项目中创建一个工单。
1. 您的团队成员前往服务台工单跟踪器，在这里他们可以看到新的支持请求，并在关联的工单中进行回复。
1. 您的团队与客户沟通，了解请求。
1. 您的团队开始着手实施代码以解决客户的问题。
1. 当您的团队完成实施后，合并请求被合并，工单会自动关闭。

与此同时：

- 客户完全通过电子邮件与您的团队交互，无需访问您的极狐GitLab 实例。
- 您的团队无需离开极狐GitLab（或设置集成）即可跟进客户，从而节省时间。

<a id="related-topics"></a>

## 相关主题

- [配置服务台](configure.md)
  - [提高项目安全性](configure.md#improve-your-projects-security)
  - [自定义发送给外部参与者的电子邮件](configure.md#customize-emails-sent-to-external-participants)
  - [使用自定义模板创建服务台工单](configure.md#use-a-custom-template-for-service-desk-tickets)
  - [支持 Bot 用户](configure.md#support-bot-user)
  - [工单默认可见性](configure.md#default-ticket-visibility)
  - [外部参与者评论时重新打开工单](configure.md#reopen-tickets-when-an-external-participant-comments)
  - [自定义电子邮件地址](configure.md#custom-email-address)
  - [使用额外的服务台别名邮箱](configure.md#use-an-additional-service-desk-alias-email)
  - [在多节点环境中配置邮件接收](configure.md#configure-email-ingestion-in-multi-node-environments)
- [使用服务台](using_service_desk.md)
  - [作为最终用户（工单创建者）](using_service_desk.md#as-an-end-user-ticket-creator)
  - [作为工单回复者](using_service_desk.md#as-a-responder-to-the-ticket)
  - [邮件内容和格式](using_service_desk.md#email-contents-and-formatting)
  - [将常规议题转换为服务台工单](using_service_desk.md#convert-a-regular-issue-to-a-service-desk-ticket)
  - [隐私注意事项](using_service_desk.md#privacy-considerations)
- [外部参与者](external_participants.md)
  - [服务台工单](external_participants.md#service-desk-tickets)
  - [作为外部参与者](external_participants.md#as-an-external-participant)
  - [作为极狐GitLab 用户](external_participants.md#as-a-gitlab-user)

<a id="troubleshooting-service-desk"></a>

## 服务台问题排查

<a id="emails-to-service-desk-do-not-create-tickets"></a>

### 发送至服务台的邮件未创建工单

- 您的邮件可能因包含[极狐GitLab 忽略的电子邮件头](../../../administration/incoming_email.md#rejected-headers)之一而被忽略。
- 如果发件人电子邮件域使用严格的 DKIM 规则，并且将邮件转发到项目特定的服务台地址导致验证失败，邮件可能会被丢弃。
  在邮件头中可以找到典型的 DKIM 失败消息，可能类似于：

  ```plaintext
  dkim=fail (signature did not verify) ... arc=fail
  ```

  具体的失败消息措辞可能因使用的邮件系统或工具而异。
  另请参阅[这篇关于 DKIM 失败的文章](https://automatedemailwarmup.com/blog/dkim-fail/)以了解更多信息和潜在解决方案。

<a id="email-ingestion-doesnt-work-in-1660"></a>

### 在 16.6.0 中邮件接收无法正常工作

极狐GitLab 私有化部署 `16.6.0` 引入了一个回归，阻止 `mail_room`（邮件接收）启动。服务台和其他通过邮件回复的功能无法使用。

解决方法是在您的极狐GitLab 安装中运行以下命令来修补受影响的文件：

{{< tabs >}}

{{< tab title="Linux 软件包 (Omnibus)" >}}

```shell
curl --output /tmp/mailroom.patch --url "https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/137279.diff"
patch -p1 -d /opt/gitlab/embedded/service/gitlab-rails < /tmp/mailroom.patch
gitlab-ctl restart mailroom
```

{{< /tab >}}

{{< tab title="Docker" >}}

```shell
curl --output /tmp/mailroom.patch --url "https://jihulab.com/gitlab-cn/gitlab/-/merge_requests/137279.diff"
cd /opt/gitlab/embedded/service/gitlab-rails
patch -p1 < /tmp/mailroom.patch
gitlab-ctl restart mailroom
```

{{< /tab >}}

{{< /tabs >}}