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

安全报告在将内容添加到数据库之前会进行验证。这可以防止将损坏的漏洞数据录入数据库。验证失败的报告会列在流水线的 **安全** 标签页中，并显示验证错误消息。

根据[报告模式](https://jihulab.com/gitlab-cn/security-products/security-report-schemas/-/tree/master/dist)进行验证，依据报告中声明的模式版本：

- 如果安全报告指定了一个支持的模式版本，极狐GitLab 使用此版本进行验证。
- 如果安全报告使用了一个已弃用的版本，极狐GitLab 尝试对该版本进行验证，并在验证结果中添加弃用警告。
- 如果安全报告使用了报告模式支持的主版本.次版本，但补丁版本与任何内置版本都不匹配，极狐GitLab 会尝试根据最新的内置补丁版本模式进行验证。
  - 示例：安全报告使用版本 14.1.1，但最新的内置版本是 14.1.0。极狐GitLab 将根据模式版本 14.1.0 进行验证。
- 如果安全报告使用了一个不支持的版本，极狐GitLab 会尝试根据你安装环境中可用的最早模式版本进行验证，但不会录入该报告。
- 如果安全报告未指定模式版本，极狐GitLab 会尝试根据极狐GitLab 中可用的最早模式版本进行验证。因为 `version` 属性是必填项，在这种情况下验证总会失败，但也可能同时存在其他验证错误。

有关支持和已弃用模式版本的详细信息，请查看[模式验证器源代码](https://jihulab.com/gitlab-cn/ruby/gems/gitlab-security_report_schemas/-/blob/main/supported_versions)。