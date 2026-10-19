---
title: 依赖扫描中的恶意软件包检测（测试版）
tier: [ Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated ]
stage: application_security_testing
documentation_link: ../../../user/application_security/gitlab_advisory_database/
work_item: https://gitlab.com/gitlab-org/gitlab/-/work_items/606037
categories: [ Software Composition Analysis ]
level: secondary
---

在之前的极狐GitLab 版本中，依赖扫描仅能发现存在已知 CVE 的软件包。恶意软件包，即通过域名抢注、被入侵的维护者账号或内嵌恶意软件等方式精心构造以造成危害的软件包，不会产生任何检测结果。

极狐GitLab 19.4 引入了恶意软件包检测（测试版）。依赖扫描现在会根据 [GitLab 恶意软件公告](../../../user/application_security/gitlab_advisory_database/_index.md#gitlab-malware-advisories)检查您的依赖项，因此威胁在广为人知之前就能被发现。检测结果会显示在您的依赖项列表和漏洞报告中，并带有红色的 **恶意软件** 标记，严重性始终为“严重”，通过 `GLAM-` ID 标识，而非 CVE。

您还可以使用合并请求审批策略中的[恶意软件规则](../../../user/application_security/policies/merge_request_approval_policies.md#block-malicious-packages-with-the-malware-rule)，在恶意软件包合并之前将其阻止。

您无需进行任何额外设置。覆盖范围适用于[支持的软件包类型](../../../user/application_security/gitlab_advisory_database/_index.md#supported-package-types)：npm、PyPI、Maven、Go、NuGet、Cargo 和 RubyGems。同样的公告也为[持续漏洞扫描](../../../user/application_security/continuous_vulnerability_scanning/_index.md#malicious-packages)提供支持，[离线实例](../../../topics/offline/quick_start_guide.md)则手动下载这些公告。

欢迎在[议题 606036](https://gitlab.com/gitlab-org/gitlab/-/work_items/606036) 上分享反馈。
