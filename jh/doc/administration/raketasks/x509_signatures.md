---
stage: Create
group: Source Code
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: X.509 签名 Rake 任务
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

当[使用 X.509 签名提交](../../user/project/repository/signed_commits/x509.md)时，信任锚点可能会更改，存储在数据库中的签名必须更新。

<a id="update-all-x.509-signatures"></a>

## 更新所有 X.509 签名

此任务：

- 遍历所有使用 X.509 签名的提交。
- 基于当前证书库更新其验证状态。
- 仅修改签名的数据库条目。
- 保持提交不变。

要更新所有 X.509 签名，请运行：

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

```shell
sudo gitlab-rake gitlab:x509:update_signatures
```

{{< /tab >}}

{{< tab title="源码编译（Source）" >}}

```shell
sudo -u git -H bundle exec rake gitlab:x509:update_signatures RAILS_ENV=production
```

{{< /tab >}}

{{< /tabs >}}

<a id="troubleshooting"></a>

## 故障排除

在使用 X.509 证书时，你可能会遇到以下问题。

<a id="error-grpc-deadlineexceeded-during-signature-updates"></a>

### 错误：签名更新期间的 `GRPC::DeadlineExceeded`

在更新 X.509 签名时，你可能会收到一条错误信息，指出 `GRPC::DeadlineExceeded`。

当网络超时或连接问题阻止任务完成时，就会出现此问题。

为了解决此问题，默认情况下任务会自动对每个签名重试最多 5 次。你可以通过设置 `GRPC_DEADLINE_EXCEEDED_RETRY_LIMIT` 环境变量来自定义重试次数限制：

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

```shell
GRPC_DEADLINE_EXCEEDED_RETRY_LIMIT=2 sudo gitlab-rake gitlab:x509:update_signatures
```

{{< /tab >}}

{{< tab title="源码编译（Source）" >}}

```shell
GRPC_DEADLINE_EXCEEDED_RETRY_LIMIT=2 sudo -u git -H bundle exec rake gitlab:x509:update_signatures RAILS_ENV=production
```

{{< /tab >}}

{{< /tabs >}}