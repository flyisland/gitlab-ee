---
stage: Software Supply Chain Security
group: Authorization
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: IP 地址限制
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

IP 地址限制有助于防止恶意用户通过多个 IP 地址隐藏其活动。

极狐GitLab 维护着一个列表，记录了用户在指定时间段内用于发出请求的唯一 IP 地址。当达到指定的限制时，用户从新 IP 地址发出的任何请求都将被拒绝，并返回 `403 Forbidden` 错误。

当用户在指定时间段内未再从该 IP 地址发出任何请求时，该 IP 地址将从列表中清除。

> [!note]
> 当 runner 以特定用户身份运行 CI/CD 作业时，runner 的 IP 地址也会存储在该用户的唯一 IP 地址列表中。因此，每个用户的 IP 地址限制应考虑已配置的活跃 runner 数量。

<a id="configure-ip-address-restrictions"></a>

## 配置 IP 地址限制

前提条件：

- 管理员访问权限。

1. 在右上角，选择 **管理员**。
1. 在左侧边栏，选择 **设置** > **报告**。
1. 展开 **垃圾信息和反机器人保护**。
1. 更新 IP 地址限制设置：
   1. 勾选 **限制来自多个 IP 地址的登录** 复选框以启用 IP 地址限制。
   1. 在 **每个用户 IP 地址数** 字段中输入一个数字，大于或等于 `1`。此数字指定在指定时间段内，用户可以从中访问极狐GitLab 的唯一 IP 地址的最大数量，超过此数量后来自新 IP 地址的请求将被拒绝。
   1. 在 **IP 地址过期时间** 字段中输入一个数字，大于或等于 `0`。此数字指定一个 IP 地址计入用户限制的时间（以秒为单位），从最后一次请求的时间开始计算。
1. 选择 **保存更改**。

