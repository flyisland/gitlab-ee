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

极狐GitLab 会维护一份列表，记录用户在指定时间段内发起请求所使用的唯一 IP 地址。当达到指定限制后，该用户从新 IP 地址发起的任何请求都会被拒绝，并返回 `403 Forbidden` 错误。

如果在指定时间段内用户未再从某个 IP 地址发起请求，该 IP 地址就会从列表中清除。

> [!note]
> 当 Runner 以特定用户身份运行 CI/CD 作业时，Runner 的 IP 地址也会记录到该用户的唯一 IP 地址列表中。
> 因此，每用户 IP 地址数量限制应考虑到已配置的活动 Runner 数量。

<a id="configure-ip-address-restrictions"></a>

## 配置 IP 地址限制

先决条件：

- 管理员访问权限。

1. 在右上角，选择**管理员**。
1. 在左侧边栏中，选择**设置** > **报告**。
1. 展开**垃圾信息和反机器人保护**。
1. 更新 IP 地址限制设置：
   1. 选中**限制从多个 IP 地址登录**复选框以启用 IP 地址限制。
   1. 在**每用户 IP 地址数**字段中输入一个大于或等于 `1`的数字。该数字指定在指定时间段内，
      用户最多可以从多少个唯一 IP 地址访问极狐GitLab，超过该数量后，来自新 IP 地址的请求将被拒绝。
   1. 在 **IP 地址过期时间**字段中输入一个大于或等于 `0`的数字。该数字指定一个 IP 地址计入用户限制的
      时间（以秒为单位），从最后一次请求的时间开始计算。
1. 选择**保存更改**。
