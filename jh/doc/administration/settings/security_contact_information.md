---
stage: Software Supply Chain Security
group: Compliance
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: yes
title: 提供公开的安全联系方式
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

组织可以通过提供公开的联系方式，促进安全问题的负责任披露。极狐GitLab 支持为此使用 [`security.txt`](https://securitytxt.org/) 文件。

管理员可以使用极狐GitLab UI 或
[REST API](../../api/settings.md#update-application-settings) 添加 `security.txt` 文件。
添加的任何内容都可在 `https://gitlab.example.com/.well-known/security.txt` 处获取。查看此文件无需身份验证。

要配置 `security.txt` 文件：

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **通用**。
1. 展开**添加安全联系方式**。
1. 在 **security.txt 内容**中，按照 <https://securitytxt.org/> 中记录的
   格式输入安全联系方式。
1. 选择**保存更改**。

有关收到报告后如何响应的信息，请参阅[响应安全事件](../../security/responding_to_security_incidents.md)。

<a id="example-securitytxt-file"></a>

## 示例 `security.txt` 文件

此信息的格式记录在 <https://securitytxt.org/> 中。
一个示例 `security.txt` 文件为：

```plaintext
Contact: mailto:security@example.com
Expires: 2024-12-31T23:59Z
```
