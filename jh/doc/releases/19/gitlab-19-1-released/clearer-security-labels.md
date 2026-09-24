---
title: 漏洞详情中更清晰、符合安全行业标准的标签
stage: application_security_testing
level: secondary
tier: [ Ultimate ]
offering: [ gitlab_com, self_managed, gitlab_dedicated ]
documentation_link: "../../../user/application_security/vulnerabilities/"
work_item: "https://gitlab.com/groups/gitlab-org/-/work_items/21978"
categories: [ Vulnerability Management ]
---

在极狐GitLab 19.1 中，漏洞结果详情页面为扫描结果使用了一致、描述性强且符合安全行业标准的术语：

- **Scanner** 现在为 **检测来源**
- **EPSS** 现在为 **利用概率 (EPSS)**
- **Has Known Exploit (KEV)** 现在为 **已知已利用 (CISA KEV)**
- **Reachable** 现在为 **可达性**
- **Image** 现在为 **容器镜像**（容器扫描）
- **Location** 现在为 **受影响位置**
- **URL** 现在为 **受影响端点**（DAST、API 模糊测试）
- **Method** 现在为 **HTTP 方法**（DAST、API 模糊测试）
- **Solution** 现在为 **修复指导**
- **Links** 现在为 **参考信息**
