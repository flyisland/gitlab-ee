---
stage: Plan
group: Work Items
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Gmail 操作
description: "为极狐GitLab 通知配置 Gmail 操作。"
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

极狐GitLab 支持[电子邮件中的 Google 操作](https://developers.google.com/workspace/gmail/markup/actions/actions-overview)。
配置此集成后，需要执行操作的电子邮件会在 Gmail 中标记出来。

要实现此功能，您必须在 Google 注册。有关说明，请参阅
[向 Google 注册](https://developers.google.com/workspace/gmail/markup/registering-with-google)。

此过程包含许多步骤。请确保您满足 Google 设定的所有要求，以免您的应用被 Google 拒绝。

尤其请注意：

<!-- vale gitlab_base.InclusiveLanguage = NO -->

- 极狐GitLab 用于发送通知电子邮件的邮箱必须：
  - 具有“从您的域持续发送大量邮件的记录（至少每天向 Gmail 发送数百封邮件，持续数周）”。
  - 用户的垃圾邮件投诉率非常低。
- 电子邮件必须使用 DKIM 或 SPF 进行身份验证。
- 在提交最终表单（**Gmail Schema 白名单请求**）之前，您必须
  从生产服务器发送一封真实电子邮件。这意味着您必须找到
  一种从您注册的电子邮件地址发送此电子邮件的方法。您可以通过
  从您注册的电子邮件地址转发真实电子邮件来实现此目的。您也可以进入极狐GitLab 服务器上的 Rails 控制台，
  从那里触发发送电子邮件。

<!-- vale gitlab_base.InclusiveLanguage = YES -->

您可以在[此 GitLab.com 议题](https://gitlab.com/gitlab-org/gitlab-foss/-/issues/1517)中查看按照“向 Google 注册”文档中列出的所有步骤进行操作的效果。
