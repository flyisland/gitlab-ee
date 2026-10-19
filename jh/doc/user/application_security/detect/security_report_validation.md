---
stage: Application Security Testing
group: Static Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 安全报告验证
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

安全报告的内容在添加到数据库之前会经过验证。这可以防止将损坏的漏洞数据摄取到数据库中。未通过验证的报告会连同验证错误消息一起列在流水线的 **安全** 标签页中。

验证依据[报告模式](https://gitlab.com/gitlab-org/security-products/security-report-schemas/-/tree/master/dist)进行，具体使用报告中声明的模式版本：

- 如果安全报告指定了受支持的模式版本，极狐GitLab 会使用该版本进行验证。
- 如果安全报告使用了已弃用的版本，极狐GitLab 会尝试使用该版本进行验证，
  并在验证结果中添加弃用警告。
- 如果安全报告使用了报告模式的受支持 MAJOR-MINOR 版本，但 PATCH
  版本与任何内置版本都不匹配，极狐GitLab 会尝试使用该模式最新的
  内置 PATCH 版本进行验证。
  - 例如：安全报告使用版本 14.1.1，但最新的内置版本是 14.1.0。极狐GitLab
    将使用模式版本 14.1.0 进行验证。
- 如果安全报告使用的版本不受支持，极狐GitLab 会尝试使用您的安装中
  可用的最早模式版本进行验证，但不会摄取该报告。
- 如果安全报告未指定模式版本，极狐GitLab 会尝试使用极狐GitLab 中可用的
  最早模式版本进行验证。由于 `version` 属性是必填项，
  在这种情况下验证总是失败，但也可能存在其他验证错误。

有关受支持和已弃用的模式版本的详细信息，请查看[模式验证器源代码](https://gitlab.com/gitlab-org/ruby/gems/gitlab-security_report_schemas/-/blob/main/supported_versions)。
