---
stage: Software Supply Chain Security
group: Authorization
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 身份验证
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com

{{< /details >}}

身份验证为极狐GitLab 账号提供了多层安全保障。根据您的[风险评分](../development/integrations/arkose.md)，您可能需要完成最多三个阶段的身份验证才能创建用户账号：

- **所有用户** - 电子邮件验证。
- **中风险用户** - 手机号码验证。
- **高风险用户** - 信用卡验证。

默认情况下，通过 SAML 或 SCIM 预配的用户必须完成电子邮件验证。您可以通过添加自定义域名来[绕过电子邮件验证](../user/group/saml_sso/_index.md#bypass-user-email-confirmation-with-verified-domains)。当用户的电子邮件域名匹配时，极狐GitLab 会自动确认其账号。

如果您在运行 CI/CD 流水线时遇到身份验证错误，请参阅[调试流水线错误](../ci/debugging.md#error-identity-verification-is-required-in-order-to-run-ci-jobs)。

<a id="email-verification"></a>

## 电子邮件验证

要注册账号，您必须提供有效的电子邮件地址。请参阅[让新用户确认电子邮件](user_email_confirmation.md)。

<a id="phone-number-verification"></a>

## 手机号码验证

除电子邮件验证外，您可能还需要提供有效的手机号码，并验证一次性密码（OTP）验证码。

> [!note]
> 您无法使用与已封禁用户关联的手机号码来验证账号。

<a id="country-support"></a>

### 国家/地区支持

部分国家/地区对手机号码验证的支持有限或完全不支持：

- 不支持：无法使用手机验证。
- 部分支持：由于当地法规或执法政策，手机验证可能无法使用。

如果您所在的国家/地区无法使用手机验证，请尝试[信用卡验证](#credit-card-verification)或创建[支持工单](https://gitlab.cn/support)。

| 国家/地区 | 支持级别 |
|---------|---------------|
| 亚美尼亚 | 部分支持 |
| 白俄罗斯 | 部分支持 |
| 柬埔寨 | 部分支持 |
| 中国 | 不支持 |
| 古巴 | 不支持 |
| 斯威士兰 | 部分支持 |
| 海地 | 部分支持 |
| 香港 | 不支持 |
| 伊朗 | 不支持 |
| 哈萨克斯坦 | 部分支持 |
| 肯尼亚 | 部分支持 |
| 科威特 | 部分支持 |
| 澳门 | 不支持 |
| 缅甸 | 部分支持 |
| 尼日利亚 | 部分支持 |
| 朝鲜 | 不支持 |
| 阿曼 | 部分支持 |
| 卡塔尔 | 部分支持 |
| 叙利亚 | 不支持 |
| 坦桑尼亚 | 部分支持 |
| 乌干达 | 部分支持 |
| 乌克兰 | 部分支持 |
| 乌兹别克斯坦 | 部分支持 |

<a id="credit-card-verification"></a>

## 信用卡验证

除电子邮件地址和手机号码外，您可能还需要提供有效的信用卡号来验证您的账号。

极狐GitLab 不会直接存储您的卡片详细信息，也不会收取任何费用。此过程与您所在群组的任何账单信息无关。

您无法使用与已封禁用户关联的信用卡号来验证账号。
