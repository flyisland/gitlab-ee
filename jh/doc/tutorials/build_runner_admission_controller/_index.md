---
stage: Verify
group: Runner Core
info: For assistance with this tutorial, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments-to-other-projects-and-subjects>.
title: 教程：构建一个执行器准入控制器
---

<!-- vale gitlab_base.FutureTense = NO -->

本教程指导你构建一个执行器准入控制器，该控制器可以为 CI/CD 任务执行强制执行自定义策略。你将使用 Go 语言创建一个控制器，该控制器连接到任务路由器并实现镜像白名单策略。

本教程中的代码示例改编自 [runner-controller-example](https://gitlab.com/gitlab-org/cluster-integration/runner-controller-example) 仓库，该仓库提供了一个完整的参考实现，你可以将其作为起点。

在本教程结束时，你将拥有一个可工作的准入控制器，它能：

- 使用 gRPC 连接到任务路由器
- 在极狐GitLab 中注册自身
- 接收任务准入请求
- 根据自定义策略评估任务
- 返回准入决策

要构建一个执行器准入控制器：

1. [在极狐GitLab 中创建一个执行器控制器](#create-a-runner-controller-in-gitlab)
1. [为执行器控制器设置范围](#scope-the-runner-controller)
1. [创建一个执行器控制器令牌](#create-a-runner-controller-token)
1. [设置你的 Go 项目](#set-up-your-go-project)
1. [从 protobuf 定义生成客户端代码](#generate-client-code-from-protobuf-definitions)
1. [实现认证](#implement-authentication)
1. [实现代理注册](#implement-agent-registration)
1. [实现准入循环](#implement-the-admission-loop)
1. [实现准入策略](#implement-an-admission-policy)
1. [使用演练状态进行测试](#test-with-dry-run-state)
1. [在生产环境中启用](#enable-in-production)

<a id="before-you-begin"></a>

## 开始之前

请确保你拥有：

- 具备旗舰版的极狐GitLab 私有化部署实例
- 对你的极狐GitLab 实例具有管理员访问权限
- 以下任意一种与极狐GitLab API 交互的工具：
  - [极狐GitLab CLI (`glab`)](https://gitlab.cn/docs/cli/) 1.85.0 或更高版本，并使用 `glab auth login` 进行认证
  - `curl` 或其他 HTTP 客户端
- 已安装 Go 1.21 或更高版本
- 已安装 [The `buf` CLI](https://buf.build/docs/installation) 用于生成 Protobuf 代码
- 在极狐GitLab 实例上启用了以下功能标志：
  - `job_router`
  - `job_router_admission_control`
- 极狐GitLab 执行器 18.9 或更高版本，并将 `FF_USE_JOB_ROUTER` 环境变量设置为 `true`。

<a id="create-a-runner-controller-in-gitlab"></a>

## 在极狐GitLab 中创建一个执行器控制器

使用 [runner controllers API](../../api/runner_controllers.md) 来创建一个执行器控制器。

从 `dry_run` 状态开始，以便在启用强制执行之前验证你的控制器行为：

{{< tabs >}}

{{< tab title="GitLab CLI" >}}

```shell
glab runner-controller create --description "Image allowlist controller" --state dry_run
```

{{< /tab >}}

{{< tab title="curl" >}}

```shell
curl --request POST \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Content-Type: application/json" \
     --data '{"description": "Image allowlist controller", "state": "dry_run"}' \
     --url "https://gitlab.example.com/api/v4/runner_controllers"
```

{{< /tab >}}

{{< /tabs >}}

保存返回的 `id` 以便下一步使用。

<a id="scope-the-runner-controller"></a>

## 为执行器控制器设置范围

执行器控制器必须设置范围才能接收准入请求。如果没有范围，你的控制器即使已启用也保持非活跃状态。

在本教程中，将控制器范围设置为实例中的所有执行器：

{{< tabs >}}

{{< tab title="GitLab CLI" >}}

```shell
glab runner-controller scope create <controller_id> --instance
```

{{< /tab >}}

{{< tab title="curl" >}}

```shell
curl --request POST \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --url "https://gitlab.example.com/api/v4/runner_controllers/<controller_id>/scopes/instance"
```

{{< /tab >}}

{{< /tabs >}}

或者，你可以使用 [Runner controllers API](../../api/runner_controllers.md) 将控制器范围设置为特定的执行器。当你希望控制器仅为某些执行器评估任务时，可以使用执行器级别的范围界定。

<a id="create-a-runner-controller-token"></a>

## 创建一个执行器控制器令牌

为你的执行器控制器创建一个令牌，用于向任务路由器进行认证：

{{< tabs >}}

{{< tab title="GitLab CLI" >}}

```shell
glab runner-controller token create <controller_id> --description "Production token"
```

{{< /tab >}}

{{< tab title="curl" >}}

```shell
curl --request POST \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Content-Type: application/json" \
     --data '{"description": "Production token"}' \
     --url "https://gitlab.example.com/api/v4/runner_controllers/<controller_id>/tokens"
```

{{< /tab >}}

{{< /tabs >}}

安全地保存返回的 `token` 值。此令牌仅显示一次。

<a id="set-up-your-go-project"></a>

## 设置你的 Go 项目

创建一个新的 Go 项目：

```shell
mkdir runner-admission-controller
cd runner-admission-controller
go mod init example.com/runner-admission-controller
```

<a id="generate-client-code-from-protobuf-definitions"></a>

## 从 protobuf 定义生成客户端代码

你需要从 [GitLab Agent for Kubernetes](https://gitlab.com/gitlab-org/cluster-integration/gitlab-agent) 仓库中的 Protobuf 定义生成 gRPC 客户端代码。
你可以使用你偏好的任何方法，包括：

- 手动引入 `.proto` 文件并直接使用 `protoc`。
- 使用 [`buf`](https://buf.build/) 自动获取并生成代码。

有关 Protobuf 定义的详细信息，请参阅执行器控制器规范中的 [generating client code](https://gitlab.com/gitlab-org/cluster-integration/gitlab-agent/-/blob/master/doc/runner_controller.md#generating-client-code)。

本教程使用 `buf`。创建 `buf.gen.yaml`：

```yaml
version: v2

managed:
  enabled: true

  disable:
    - module: buf.build/bufbuild/protovalidate

  override:
    - file_option: go_package
      value: internal/rpc

inputs:
  - git_repo: https://gitlab.com/gitlab-org/cluster-integration/gitlab-agent.git
    branch: master

plugins:
  - local: ["go", "run", "google.golang.org/protobuf/cmd/protoc-gen-go@v1.36.10"]
    out: .
  - local: ["go", "run", "google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.5.1"]
    out: .
```

生成代码：

```shell
buf generate
```

这将在 `internal/rpc/` 目录下创建 gRPC 客户端代码。

<a id="implement-authentication"></a>

## 实现认证

执行器控制器使用 gRPC 元数据头向任务路由器进行认证。
有关规范详细信息，请参阅执行器控制器规范中的 [Authentication](https://gitlab.com/gitlab-org/cluster-integration/gitlab-agent/-/blob/master/doc/runner_controller.md#authentication)。

创建一个包含所需头的凭证提供程序：

```go
type tokenCredentials struct {
    token string
}

func (t *tokenCredentials) GetRequestMetadata(ctx context.Context, uri ...string) (map[string]string, error) {
    return map[string]string{
        "authorization":     "Bearer " + t.token,
        "gitlab-agent-type": "runnerc",
    }, nil
}

func (t *tokenCredentials) RequireTransportSecurity() bool {
    return true
}
```

使用以下代码创建 gRPC 连接：

```go
conn, err := grpc.NewClient(kasAddress,
    grpc.WithTransportCredentials(credentials.NewTLS(nil)),
    grpc.WithPerRPCCredentials(&tokenCredentials{token: agentToken}),
)
```

<a id="implement-agent-registration"></a>

## 实现代理注册

向任务路由器注册你的控制器，以进行存在跟踪和监控。
定期重新注册（推荐：每 3 分钟一次）以保持存在状态。
有关规范详细信息，请参阅执行器控制器规范中的 [AgentRegistrar](https://gitlab.com/gitlab-org/cluster-integration/gitlab-agent/-/blob/master/doc/runner_controller.md#agentregistrar)。

```go
func registerAgent(ctx context.Context, conn *grpc.ClientConn, instanceID int64) error {
    client := rpc.NewAgentRegistrarClient(conn)

    _, err := client.Register(ctx, &rpc.RegisterRequest{
        Meta: &rpc.Meta{
            Version:      "1.0.0",
            GitRef:       "main",
            Architecture: runtime.GOARCH,
        },
        InstanceId: instanceID,
    })
    return err
}
```

<a id="implement-the-admission-loop"></a>

## 实现准入循环

准入循环接收来自任务路由器的任务详细信息并发送决策。
有关规范详细信息，请参阅执行器控制器规范中的 [RunnerControllerService](https://gitlab.com/gitlab-org/cluster-integration/gitlab-agent/-/blob/master/doc/runner_controller.md#runnercontrollerservice) 和 [Protocol Flow](https://gitlab.com/gitlab-org/cluster-integration/gitlab-agent/-/blob/master/doc/runner_controller.md#protocol-flow)。

```go
func handleAdmissionRequest(ctx context.Context, client rpc.RunnerControllerServiceClient) error {
    admissionCtx, cancel := context.WithCancel(ctx)
    defer cancel()

    stream, err := client.AdmitJob(admissionCtx)
    if err != nil {
        return err
    }

    // 等待准入请求
    req, err := stream.Recv()
    if err != nil {
        return err
    }

    // 评估任务（在此实现你的策略）
    admitted, reason := evaluateJob(req)

    // 发送决策
    var resp *rpc.AdmitJobResponse
    if admitted {
        resp = &rpc.AdmitJobResponse{
            AdmissionResponse: &rpc.AdmitJobResponse_Admitted{Admitted: &rpc.Admitted{}},
        }
    } else {
        resp = &rpc.AdmitJobResponse{
            AdmissionResponse: &rpc.AdmitJobResponse_Rejected{
                Rejected: &rpc.Rejected{Reason: reason},
            },
        }
    }

    if err := stream.Send(resp); err != nil {
        return err
    }

    _ = stream.CloseSend()
    var x any
    err = stream.RecvMsg(x) // 消耗 EOF
    if err != io.EOF {
      return err
    }

    return nil
}
```

<a id="implement-an-admission-policy"></a>

## 实现准入策略

实现你的自定义策略逻辑。此示例拒绝使用 `:latest` 标签的镜像：

```go
func evaluateJob(req *rpc.AdmitJobRequest) (admitted bool, reason string) {
    imageName := req.GetImage().GetName()

    // 拒绝 :latest 标签
    if strings.HasSuffix(imageName, ":latest") {
        return false, "不允许使用带有 :latest 标签的镜像"
    }

    // 检查白名单
    allowed := []string{"alpine", "ubuntu", "golang", "ruby", "node", "python"}
    for _, prefix := range allowed {
        if strings.HasPrefix(imageName, prefix) {
            return true, ""
        }
    }

    return false, fmt.Sprintf("镜像 %s 不在批准列表中", imageName)
}
```

<a id="test-with-dry-run-state"></a>

## 使用演练状态进行测试

在你的控制器运行并处于 `dry_run` 状态时，触发一个 CI/CD 流水线。
检查你的控制器日志以验证它是否收到准入请求。
任务路由器会记录决策，但不会对处于演练状态的控制器强制执行这些决策。
此操作允许你在启用强制执行之前验证行为并降低部署风险。

<a id="enable-in-production"></a>

## 在生产环境中启用

在 `dry_run` 状态下验证你的控制器行为后，更新到 `enabled` 状态：

{{< tabs >}}

{{< tab title="GitLab CLI" >}}

```shell
glab runner-controller update <controller_id> --state enabled
```

{{< /tab >}}

{{< tab title="curl" >}}

```shell
curl --request PUT \
     --header "PRIVATE-TOKEN: <your_access_token>" \
     --header "Content-Type: application/json" \
     --data '{"state": "enabled"}' \
     --url "https://gitlab.example.com/api/v4/runner_controllers/<controller_id>"
```

{{< /tab >}}

{{< /tabs >}}

现在你的准入决策会影响任务执行。

<a id="hosting-the-runner-controller"></a>

### 托管执行器控制器

执行器控制器的托管方式取决于极狐GitLab 实例的规模以及受准入控制影响的任务负载。
唯一的要求是执行器控制器可以访问极狐GitLab 实例，因为这是它连接的目标。

## 下一步

- 查看 [complete example implementation](https://gitlab.com/gitlab-org/cluster-integration/runner-controller-example)。
- 阅读 [runner controller specification](https://gitlab.com/gitlab-org/cluster-integration/gitlab-agent/-/blob/master/doc/runner_controller.md) 以获取协议详细信息。
- 探索使用 [Open Policy Agent (OPA)](https://www.openpolicyagent.org/) 来构建更复杂的策略。