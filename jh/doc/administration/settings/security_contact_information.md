---
stage: Software Supply Chain Security
group: Compliance
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
gitlab_dedicated: yes
title: 提供公开的安全联系信息
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

{{< history >}}

- 在极狐GitLab 16.7 中引入。

{{< /history >}}

组织可以通过提供公开联系信息来促进负责任地披露安全问题。极狐GitLab 支持使用 [`security.txt`](https://securitytxt.org/) 文件来实现此目的。

管理员可以使用极狐GitLab UI 或 [REST API](../../api/settings.md#update-application-settings) 添加 `security.txt` 文件。添加的任何内容均可在 `https://gitlab.example.com/.well-known/security.txt` 访问，无需进行身份验证即可查看此文件。

要配置 `security.txt` 文件：

1. 在右上角，选择 **管理员**。
1. 在左侧边栏中，选择 **设置** > **通用**。
1. 展开 **添加安全联系信息**。
1. 在 **security.txt 内容** 中，按照 <https://securitytxt.org/> 中记录的格式输入安全联系信息。
1. 选择 **保存更改**。

有关收到报告后如何响应的信息，请参阅 [响应安全事件](../../security/responding_to_security_incidents.md)。

<a id="example-security-txt-file"></a>

## 示例 `security.txt` 文件

此信息的格式在 <https://securitytxt.org/> 中有记录。一个示例 `security.txt` 文件如下：

```plaintext
联系方式: mailto:security@example.com
过期时间: 2024-12-31T23:59Z
```

