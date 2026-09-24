---
stage: Application Security Testing
group: Secret Detection
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: 客户端侧密钥检测
---

{{< details >}}

- Tier: 基础版, 专业版, 旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

{{< history >}}

- 引入于极狐GitLab 15.11。
- 使用自定义前缀检测个人访问令牌引入于极狐GitLab 16.1。仅限私有化部署。

{{< /history >}}

<a id="client-side-secret-detection"></a>

客户端密钥检测

创建议题、提出合并请求或撰写评论时，可能会不小心发布一个密钥。例如，可能会粘贴 API 请求的详细信息或包含身份验证令牌的环境变量。如果密钥泄露，可能会被用来造成伤害。

客户端密钥检测有助于减少这种情况发生的风险。当编辑议题或合并请求中的描述或评论时，极狐GitLab 会检查其是否包含密钥。如果发现密钥，将显示警告信息。然后可以编辑描述或评论以删除密钥后再发布消息，或者按原样添加描述或评论。此检查在浏览器中进行，因此除非将其添加到极狐GitLab，否则密钥不会泄露给其他人。此检查始终处于开启状态，无需进行设置。

客户端密钥检测仅检查以下内容中的密钥：

- 议题或合并请求中的评论。
- 议题或合并请求的描述。

仅支持极狐GitLab 个人访问令牌的自定义前缀密钥。有关客户端密钥检测覆盖的密钥类型的更多信息，请参阅[Detected secrets](../../detected_secrets.md)。
