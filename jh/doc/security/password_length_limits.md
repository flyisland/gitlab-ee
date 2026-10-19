---
stage: Software Supply Chain Security
group: Authentication
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: 自定义密码长度限制
---

{{< details >}}

- Tier: 基础版, 专业版, 旗舰版
- Offering: 私有化部署

{{< /details >}}

极狐 GitLab 默认支持以下长度的密码：

- 最小：8 个字符
- 最大：128 个字符

您只能更改密码的最小长度。更改最小长度不会影响现有用户的密码。现有用户不会被要求重置密码以符合新的限制。新限制仅在新用户注册时以及现有用户执行密码重置时适用。

<a id="modify-minimum-password-length"></a>

## 修改最小密码长度

用户密码长度默认设置为至少 8 个字符。

使用极狐 GitLab UI 更改最小密码长度的方法：

1. 在左侧边栏底部，选择 **管理员**。
1. 选择 **设置 > 常规**。
1. 展开 **注册限制**。
1. 输入一个大于或等于 `8` 的 **最小密码长度** 值。
1. 选择 **保存更改**。
