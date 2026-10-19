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

当[使用 X.509 签名提交](../../user/project/repository/signed_commits/x509.md)时，信任锚可能会发生变化，数据库中存储的签名必须更新。

<a id="update-all-x509-signatures"></a>

## 更新所有 X.509 签名

此任务会：

- 遍历所有使用 X.509 签名的提交。
- 根据当前证书存储更新其验证状态。
- 仅修改签名的数据库条目。
- 保持提交不变。

要更新所有 X.509 签名，请运行：

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

```shell
sudo gitlab-rake gitlab:x509:update_signatures
```

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

```shell
sudo -u git -H bundle exec rake gitlab:x509:update_signatures RAILS_ENV=production
```

{{< /tab >}}

{{< /tabs >}}

<a id="troubleshooting"></a>

## 故障排除

使用 X.509 证书时，您可能会遇到以下问题。

<a id="error-grpcdeadlineexceeded-during-signature-updates"></a>

### 错误：签名更新期间出现 `GRPC::DeadlineExceeded`

更新 X.509 签名时，您可能会收到一条指出 `GRPC::DeadlineExceeded`的错误。

当网络超时或连接问题导致任务无法完成时，会出现此问题。

要解决此问题，该任务默认会对每个签名自动重试最多 5 次。您可以通过设置 `GRPC_DEADLINE_EXCEEDED_RETRY_LIMIT` 环境变量来自定义重试次数上限：

{{< tabs >}}

{{< tab title="Linux 软件包（Omnibus）" >}}

```shell
GRPC_DEADLINE_EXCEEDED_RETRY_LIMIT=2 sudo gitlab-rake gitlab:x509:update_signatures
```

{{< /tab >}}

{{< tab title="自行编译（源代码）" >}}

```shell
GRPC_DEADLINE_EXCEEDED_RETRY_LIMIT=2 sudo -u git -H bundle exec rake gitlab:x509:update_signatures RAILS_ENV=production
```

{{< /tab >}}

{{< /tabs >}}
