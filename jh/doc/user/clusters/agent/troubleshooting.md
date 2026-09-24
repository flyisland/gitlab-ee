---
stage: Verify
group: Runner Core
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab Kubernetes Agent 故障排除
---

在使用极狐GitLab Kubernetes Agent 时，您可能会遇到一些需要排查的问题。

您可以先查看服务日志：

```shell
kubectl logs -f -l=app.kubernetes.io/name=gitlab-agent -n gitlab-agent
```

如果您是极狐GitLab 管理员，还可以查看[极狐GitLab Kubernetes Agent 服务器日志](../../../administration/clusters/kas.md#troubleshooting)。

<a id="transport-error-while-dialing-failed-to-websocket-dial"></a>

## 传输：拨号时出错，无法进行 WebSocket 拨号

```json
{
  "level": "warn",
  "time": "2020-11-04T10:14:39.368Z",
  "msg": "GetConfiguration failed",
  "error": "rpc error: code = Unavailable desc = connection error: desc = \"transport: Error while dialing failed to WebSocket dial: failed to send handshake request: Get \\\"https://gitlab-kas:443/-/kubernetes-agent\\\": dial tcp: lookup gitlab-kas on 10.60.0.10:53: no such host\""
}
```

此错误表明 `kas-address` 与您的代理 Pod 之间存在连接问题。请确认 `kas-address` 地址正确。

```json
{
  "level": "error",
  "time": "2021-06-25T21:15:45.335Z",
  "msg": "Reverse tunnel",
  "mod_name": "reverse_tunnel",
  "error": "Connect(): rpc error: code = Unavailable desc = connection error: desc= \"transport: Error while dialing failed to WebSocket dial: expected handshake response status code 101 but got 301\""
}
```

此错误发生在 `kas-address` 末尾未包含斜杠时。请确保 `wss` 或 `ws` URL 以斜杠结尾，例如 `wss://极狐GitLab.host.tld:443/-/kubernetes-agent/` 或 `ws://极狐GitLab.host.tld:80/-/kubernetes-agent/`。

<a id="error-while-dialing-failed-to-websocket-dial-failed-to-send-handshake-request"></a>

## 拨号时出错，无法进行 WebSocket 拨号：发送握手请求失败

```json
{
  "level": "warn",
  "time": "2020-10-30T09:50:51.173Z",
  "msg": "GetConfiguration failed",
  "error": "rpc error: code = Unavailable desc = connection error: desc = \"transport: Error while dialing failed to WebSocket dial: failed to send handshake request: Get \\\"https://极狐GitLabhost.tld:443/-/kubernetes-agent\\\": net/http: HTTP/1.x transport connection broken: malformed HTTP response \\\"\\\\x00\\\\x00\\\\x06\\\\x04\\\\x00\\\\x00\\\\x00\\\\x00\\\\x00\\\\x00\\\\x05\\\\x00\\\\x00@\\\\x00\\\"\""
}
```

当代理端配置了 `wss` 作为 `kas-address`，但代理服务器无法通过 `wss` 访问时，会出现此错误。请确保两侧使用了相同的协议方案。

<a id="decompressor-is-not-installed-for-grpc-encoding"></a>

## 未安装用于 grpc-encoding 的解压缩器

```json
{
  "level": "warn",
  "time": "2020-11-05T05:25:46.916Z",
  "msg": "GetConfiguration.Recv failed",
  "error": "rpc error: code = Unimplemented desc = grpc: Decompressor is not installed for grpc-encoding \"gzip\""
}
```

当代理版本高于代理服务器（KAS）版本时，会出现此错误。请确保 `agentk` 和代理服务器版本一致。

<a id="certificate-signed-by-unknown-authority"></a>

## 由未知颁发机构签名的证书

```json
{
  "level": "error",
  "time": "2021-02-25T07:22:37.158Z",
  "msg": "Reverse tunnel",
  "mod_name": "reverse_tunnel",
  "error": "Connect(): rpc error: code = Unavailable desc = connection error: desc = \"transport: Error while dialing failed to WebSocket dial: failed to send handshake request: Get \\\"https://极狐GitLabhost.tld:443/-/kubernetes-agent/\\\": x509: certificate signed by unknown authority\""
}
```

当您的极狐GitLab 实例使用了内部证书颁发机构签名的证书，而代理不信任该机构时，会出现此错误。

要解决此问题，您可以通过[自定义 Helm 安装](install/_index.md#customize-the-helm-installation)将 CA 证书文件提供给代理。在 `helm install` 命令中添加 `--set-file config.kasCaCert=my-custom-ca.pem`。该文件应为有效的 PEM 或 DER 编码证书。

当您使用 `config.kasCaCert` 值部署 `agentk` 时，证书会被添加到 `configmap` 中，并且证书文件会挂载到 `/etc/ssl/certs` 目录下。

例如，使用 `kubectl get configmap -lapp=gitlab-agent -o yaml` 命令的输出：

```yaml
apiVersion: v1
items:
- apiVersion: v1
  data:
    ca.crt: |-
      -----BEGIN CERTIFICATE-----
      MIIFmzCCA4OgAwIBAgIUE+FvXfDpJ869UgJitjRX7HHT84cwDQYJKoZIhvcNAQEL
      ...truncated certificate...
      GHZCTQkbQyUwBWJOUyOxW1lro4hWqtP4xLj8Dpq1jfopH72h0qTGkX0XhFGiSaM=
      -----END CERTIFICATE-----
  kind: ConfigMap
  metadata:
    annotations:
      meta.helm.sh/release-name: self-signed
      meta.helm.sh/release-namespace: gitlab-agent-self-signed
    creationTimestamp: "2023-03-07T20:12:26Z"
    labels:
      app: gitlab-agent
      app.kubernetes.io/managed-by: Helm
      app.kubernetes.io/name: gitlab-agent
      app.kubernetes.io/version: v15.9.0
      helm.sh/chart: gitlab-agent-1.11.0
    name: self-signed-gitlab-agent
    resourceVersion: "263184207"
kind: List
```

您可能会在极狐GitLab 应用服务器的[代理服务器（KAS）日志](../../../administration/logs/_index.md#gitlab-agent-server-for-kubernetes-logs)中看到类似错误：

```json
{"level":"error","time":"2023-03-07T20:19:48.151Z","msg":"AgentInfo()","grpc_service":"gitlab.agent.agent_configuration.rpc.AgentConfiguration","grpc_method":"GetConfiguration","error":"Get \"https://gitlab.example.com/api/v4/internal/kubernetes/agent_info\": x509: certificate signed by unknown authority"}
```

要解决此问题，请在 `/etc/gitlab/trusted-certs` 目录中[安装内部 CA 的公共证书](https://gitlab.cn/docs/omnibus/settings/ssl/#install-custom-public-certificates)。

或者，您可以配置代理服务器（KAS）从自定义目录读取证书。将以下配置添加到 `/etc/gitlab/gitlab.rb`：

```ruby
gitlab_kas['env'] = {
   'SSL_CERT_DIR' => "/opt/gitlab/embedded/ssl/certs/"
 }
```

应用更改：

1. 重新配置极狐GitLab。

   ```shell
   sudo gitlab-ctl reconfigure
   ```

1. 重启 `gitlab-kas`。

   ```shell
   gitlab-ctl restart gitlab-kas
   ```

<a id="error-failed-to-register-agent-pod"></a>

## 错误：`无法注册代理 Pod`

代理 Pod 日志可能会显示错误消息 `无法注册代理 Pod。请确保代理版本与服务器版本匹配`。

要解决此问题，请确保代理版本与极狐GitLab 版本一致。

如果版本匹配但错误仍然存在：

1. 使用 `gitlab-ctl status gitlab-kas` 确认 `gitlab-kas` 正在运行。
1. 检查 `gitlab-kas` [日志](../../../administration/logs/_index.md#gitlab-agent-server-for-kubernetes-logs)，确保代理运行正常。

<a id="failed-to-perform-vulnerability-scan-on-workload-jobsbatch-already-exists"></a>

## 对工作负载执行漏洞扫描失败：jobs.batch 已存在

```json
{
  "level": "error",
  "time": "2022-06-22T21:03:04.769Z",
  "msg": "Failed to perform vulnerability scan on workload",
  "mod_name": "starboard_vulnerability",
  "error": "running scan job: creating job: jobs.batch \"scan-vulnerabilityreport-b8d497769\" already exists"
}
```

极狐GitLab Kubernetes Agent 通过创建作业来扫描每个工作负载以执行漏洞扫描。如果扫描被中断，这些作业可能会残留，需要清理后才能运行新的作业。您可以通过以下命令清理这些作业：

```shell
kubectl delete jobs -l app.kubernetes.io/managed-by=starboard -n gitlab-agent
```

<a id="parse-error-during-installation"></a>

## 安装过程中的解析错误

安装代理时，您可能会遇到如下错误：

```shell
Error: parse error at (gitlab-agent/templates/observability-secret.yaml:1): unclosed action
```

此错误通常由不兼容的 Helm 版本导致。要解决此问题，请确保您使用的 Helm 版本[与您的 Kubernetes 版本兼容](_index.md#supported-kubernetes-versions-for-gitlab-features)。

<a id="gitlab-agent-server-unauthorized-error-on-dashboard-for-kubernetes"></a>

## Kubernetes 仪表板上的 `极狐GitLab Agent 服务器：未经授权` 错误

在[Kubernetes 仪表板](../../../ci/environments/kubernetes_dashboard.md)页面上出现类似 `极狐GitLab Agent 服务器：未授权。追踪 ID：<...>` 的错误，可能由以下原因引起：

- 代理配置文件中 `user_access` 条目不存在或配置错误。请参阅[向用户授予 Kubernetes 访问权限](user_access.md)进行修正。
- 浏览器中存在多个 [`_gitlab_kas` Cookie](../../../administration/clusters/kas.md#kubernetes-api-proxy-cookie) 并被发送给 KAS。最常见的原因是同一站点上托管了多个极狐GitLab 实例。

  例如，`gitlab.com` 设置了针对 `kas.gitlab.com` 的 `_gitlab_kas` Cookie，但该 Cookie 也被发送到了 `kas.staging.gitlab.com`，从而导致 `staging.gitlab.com` 出错。

  临时解决方法：从浏览器 Cookie 存储中删除 `gitlab.com` 的 `_gitlab_kas` Cookie。
- 极狐GitLab 和 KAS 运行在不同的站点上。例如，极狐GitLab 在 `gitlab.example.com`，而 KAS 在 `kas.example.com`。极狐GitLab 不支持这种使用方式。

<a id="agent-version-mismatch"></a>

## 代理版本不匹配

在极狐GitLab 中，于 Kubernetes 集群页面的 **代理** 选项卡上，您可能会看到一条警告：`代理版本不匹配：集群内各 Pod 的代理版本不一致。`

此警告可能是由于 Kubernetes Agent 服务器（`kas`）缓存了较旧的代理版本导致的。由于 `kas` 会定期删除过时的代理版本，您应至少等待 20 分钟，让代理与极狐GitLab 完成协调。

如果警告仍然存在，请更新集群上安装的代理。

<a id="kubernetes-api-proxy-response-headers-are-lost-or-blocked"></a>

## Kubernetes API 代理响应头丢失或被阻止

当通过 Kubernetes API 代理从 Kubernetes 集群发送给用户时，HTTP 响应头可能会被阻止。

此错误通常发生在响应头未包含在 KAS 的默认允许列表中时。

有关如何解决此问题的步骤，请参阅[被阻止的响应头](../../../administration/clusters/kas.md#error-blocked-kubernetes-api-proxy-response-header)。