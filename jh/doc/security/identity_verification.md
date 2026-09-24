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

{{< history >}}

- 在极狐GitLab 15.4 中引入，作为一个功能标志，名为 `identity_verification`，默认禁用。
- 在极狐GitLab 16.0 中于 JihuLab.com 上启用。
- 在极狐GitLab 16.11 中 GA。功能标志 `identity_verification` 已移除。

{{< /history >}}

身份验证为极狐GitLab 账户提供了多层安全保护。
根据你的[风险评分](../integration/arkose.md)，你可能需要完成最多三个阶段的验证才能注册账户：

- **所有用户** - 电子邮件验证。
- **中风险用户** - 电话号码验证。
- **高风险用户** - 信用卡验证。

默认情况下，通过 SAML 或 SCIM 预配的用户必须完成电子邮件验证。你可以通过添加自定义域来[绕过电子邮件验证](../user/group/saml_sso/_index.md#bypass-user-email-confirmation-with-verified-domains)。
极狐GitLab 会在用户电子邮件域匹配时自动确认用户账户。

如果在运行 CI/CD 流水线时遇到身份验证错误，请参阅[调试流水线错误](../ci/debugging.md#error-identity-verification-is-required-in-order-to-run-ci-jobs)。

<a id="email-verification"></a>

## 电子邮件验证

要注册账户，你必须提供有效的电子邮件地址。请参阅[让新用户确认电子邮件](user_email_confirmation.md)。

<a id="phone-number-verification"></a>

## 电话号码验证

除了电子邮件验证之外，你还可能被要求提供有效的电话号码并验证一次性密码 (OTP) 码。

> [!note]
> 你无法使用与被禁用户关联的电话号码验证账户。

<a id="country-support"></a>

### 国家/地区支持

一些国家/地区对电话号码验证的支持有限或完全不支持：

- 不支持：电话验证不可用。
- 部分支持：由于地方法规或执法政策，电话验证可能无法使用。

如果你所在的国家/地区电话验证不可用，请尝试[信用卡验证](#credit-card-verification) 或创建[支持工单](https://gitlab.cn/support)。

| 国家/地区 | 支持级别 |
|---------|-------------|
| 亚美尼亚 | 部分支持 |
| 孟加拉国 | 不支持 |
| 白俄罗斯 | 部分支持 |
| 柬埔寨 | 部分支持 |
| 中国 | 不支持 |
| 古巴 | 不支持 |
| 埃斯瓦蒂尼 | 部分支持 |
| 海地 | 部分支持 |
| 香港 | 不支持 |
| 印度尼西亚 | 不支持 |
| 伊朗 | 不支持 |
| 哈萨克斯坦 | 部分支持 |
| 肯尼亚 | 部分支持 |
| 科威特 | 部分支持 |
| 澳门 | 不支持 |
| 马来西亚 | 不支持 |
| 墨西哥 | 部分支持 |
| 缅甸 | 部分支持 |
| 尼日利亚 | 部分支持 |
| 朝鲜 | 不支持 |
| 阿曼 | 部分支持 |
| 巴基斯坦 | 不支持 |
| 菲律宾 | 部分支持 |
| 卡塔尔 | 部分支持 |
| 俄罗斯 | 不支持 |
| 沙特阿拉伯 | 不支持 |
| 南非 | 部分支持 |
| 叙利亚 | 不支持 |
| 坦桑尼亚 | 部分支持 |
| 泰国 | 部分支持 |
| 土耳其 | 部分支持 |
| 乌干达 | 部分支持 |
| 乌克兰 | 部分支持 |
| 阿拉伯联合酋长国 | 不支持 |
| 乌兹别克斯坦 | 部分支持 |
| 越南 | 不支持 |

<a id="credit-card-verification"></a>

## 信用卡验证

除了电子邮件地址和电话号码外，你还可能需要提供有效的信用卡号来验证你的账户。

极狐GitLab 不会直接存储你的卡片详情，也不会收取任何费用。此过程与你群组的任何计费信息无关。

你无法使用与被禁用户关联的信用卡号验证账户。