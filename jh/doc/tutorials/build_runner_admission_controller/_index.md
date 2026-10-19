---
stage: Verify
group: Runner Core
info: For assistance with this tutorial, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments-to-other-projects-and-subjects>.
title: '教程：构建 Runner 准入控制器'
---

<!-- vale gitlab_base.FutureTense = NO -->

本教程将指导您构建一个 Runner 准入控制器，用于对 CI/CD 作业执行实施自定义策略。您将使用 Go 创建一个控制器，连接到作业路由器并实现镜像允许名单策略。

本教程中的代码示例改编自
[runner-controller-example](https://gitlab.com/gitlab-org/cluster-integration/runner-controller-example)
代码仓库，该仓库提供了一个完整的参考实现，您可以将其作为起点。

完成本教程后，您将拥有一个可用的准入控制器，它可以：

- 使用 gRPC 连接到作业路由器
- 向极狐GitLab 注册自身
- 接收作业准入请求
- 根据自定义策略评估作业
- 返回准入决策

要构建 Runner 准入控制器：

1. [在极狐GitLab 中创建 Runner 控制器](#create-a-runner-controller-in-gitlab)
1. [为 Runner 控制器设置作用域](#scope-the-runner-controller)
1. [创建 Runner 控制器令牌](#create-a-runner-controller-token)
1. [设置您的 Go 项目](#set-up-your-go-project)
1. [根据 Protobuf 定义生成客户端代码](#generate-client-code-from-protobuf-definitions)
1. [实现身份验证](#implement-authentication)
1. [实现代理注册](#implement-agent-registration)
1. [实现准入循环](#implement-the-admission-loop)
1. [实现准入策略](#implement-an-admission-policy)
1. [使用试运行状态进行测试](#test-with-dry-run-state)
1. [在生产环境中启用](#enable-in-production)

<a id="before-you-begin"></a>

## 开始之前

请确保您具备：

- 带有旗舰版的极狐GitLab 私有化部署
- 对极狐GitLab 实例的管理员访问权限
- 以下任一工具，用于与极狐GitLab API 交互：
  - [GitLab CLI (`glab`)](https://gitlab.cn/docs/cli/) 1.85.0 或更高版本，并使用 `glab auth login` 完成身份验证
  - `curl` 或其他 HTTP 客户端
- 已安装 Go 1.21 或更高版本
- 已安装 [`buf` CLI](https://buf.build/docs/installation/)，用于生成 Protobuf 代码
- 在极狐GitLab 实例上启用以下功能标志：
  - `job_router`
  - `job_router_admission_control`
- 极狐GitLab Runner 18.9 或更高版本，并将 `FF_USE_JOB_ROUTER` 环境变量设置为 `true`。

<a id="create-a-runner-controller-in-gitlab"></a>

## 在极狐GitLab 中创建 Runner 控制器

使用 [Runner 控制器 API](../../api/runner_controllers.md) 创建 Runner 控制器。

从 `dry_run` 状态开始，以便在启用强制执行之前验证控制器行为：

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

保存返回的 `id`，以供下一步使用。

<a id="scope-the-runner-controller"></a>

## 为 Runner 控制器设置作用域

Runner 控制器必须设置作用域才能接收准入请求。如果没有作用域，即使已启用，您的控制器也会保持非活动状态。

在本教程中，将控制器的作用域设置为实例中的所有 Runner：

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

或者，您可以使用 [Runner 控制器 API](../../api/runner_controllers.md) 将控制器的作用域设置为特定 Runner。当您希望控制器仅针对某些 Runner 评估作业时，请使用 Runner 级作用域。

<a id="create-a-runner-controller-token"></a>

## 创建 Runner 控制器令牌

为您的 Runner 控制器创建令牌，以便通过作业路由器进行身份验证：

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

请妥善保存返回的 `token` 值。该令牌仅显示一次。

<a id="set-up-your-go-project"></a>

## 设置您的 Go 项目

创建一个新的 Go 项目：

```shell
mkdir runner-admission-controller
cd runner-admission-controller
go mod init example.com/runner-admission-controller
```

<a id="generate-client-code-from-protobuf-definitions"></a>

## 根据 Protobuf 定义生成客户端代码

您需要根据
[GitLab Agent for Kubernetes](https://gitlab.com/gitlab-org/cluster-integration/gitlab-agent) 代码仓库中的 Protobuf 定义生成 gRPC 客户端代码。
您可以使用任何您喜欢的方法，包括：

- 手动将 `.proto` 文件纳入本地代码，并直接使用 `protoc`。
- 使用 [`buf`](https://buf.build/) 自动获取并生成代码。

有关 Protobuf 定义的详细信息，请参阅 Runner 控制器规范中的[生成客户端代码](https://gitlab.com/gitlab-org/cluster-integration/gitlab-agent/-/blob/master/doc/runner_controller.md#generating-client-code)。

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

这将在 `internal/rpc/` 中生成 gRPC 客户端代码。

<a id="implement-authentication"></a>

## 实现身份验证

Runner 控制器使用 gRPC 元数据请求头通过作业路由器进行身份验证。有关规范详细信息，请参阅 Runner 控制器规范中的[身份验证](https://gitlab.com/gitlab-org/cluster-integration/gitlab-agent/-/blob/master/doc/runner_controller.md#authentication)。

创建一个包含所需请求头的凭据提供程序：

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

向作业路由器注册您的控制器，以便进行存在状态跟踪和监控。请定期重新注册（建议：每 3 分钟一次）以维持存在状态。有关规范详细信息，请参阅 Runner 控制器规范中的
[AgentRegistrar](https://gitlab.com/gitlab-org/cluster-integration/gitlab-agent/-/blob/master/doc/runner_controller.md#agentregistrar)。

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

准入循环从作业路由器接收作业详细信息并发送决策。有关规范详细信息，请参阅 Runner 控制器规范中的
[RunnerControllerService](https://gitlab.com/gitlab-org/cluster-integration/gitlab-agent/-/blob/master/doc/runner_controller.md#runnercontrollerservice)
和[协议流程](https://gitlab.com/gitlab-org/cluster-integration/gitlab-agent/-/blob/master/doc/runner_controller.md#protocol-flow)。

```go
func handleAdmissionRequest(ctx context.Context, client rpc.RunnerControllerServiceClient) error {
    admissionCtx, cancel := context.WithCancel(ctx)
    defer cancel()

    stream, err := client.AdmitJob(admissionCtx)
    if err != nil {
        return err
    }

    // Wait for admission request
    req, err := stream.Recv()
    if err != nil {
        return err
    }

    // Evaluate the job (implement your policy here)
    admitted, reason := evaluateJob(req)

    // Send decision
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
    err = stream.RecvMsg(x) // consume EOF
    if err != io.EOF {
      return err
    }

    return nil
}
```

<a id="implement-an-admission-policy"></a>

## 实现准入策略

实现您的自定义策略逻辑。此示例会拒绝带有 `:latest` 标签的镜像：

```go
func evaluateJob(req *rpc.AdmitJobRequest) (admitted bool, reason string) {
    imageName := req.GetImage().GetName()

    // Reject :latest tags
    if strings.HasSuffix(imageName, ":latest") {
        return false, "images with :latest tag are not allowed"
    }

    // Check allowlist
    allowed := []string{"alpine", "ubuntu", "golang", "ruby", "node", "python"}
    for _, prefix := range allowed {
        if strings.HasPrefix(imageName, prefix) {
            return true, ""
        }
    }

    return false, fmt.Sprintf("image %s is not in the approved list", imageName)
}
```

<a id="test-with-dry-run-state"></a>

## 使用试运行状态进行测试

在控制器运行且处于 `dry_run` 状态时，触发一条 CI/CD 流水线。检查控制器日志，确认它收到了准入请求。对于处于试运行状态的控制器，作业路由器会记录决策，但不会强制执行这些决策。此操作让您可以在启用强制执行之前验证行为并降低部署风险。

<a id="enable-in-production"></a>

## 在生产环境中启用

在 `dry_run` 状态下验证控制器行为后，更新为 `enabled` 状态：

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

现在，您的准入决策会影响作业执行。

<a id="hosting-the-runner-controller"></a>

### 托管 Runner 控制器

Runner 控制器的托管方式由您决定，具体取决于极狐GitLab 实例的规模以及受准入控制影响的作业负载。唯一的要求是 Runner 控制器能够访问极狐GitLab 实例，因为控制器需要连接到该实例。

<a id="next-steps"></a>

## 后续步骤

- 查看[完整示例实现](https://gitlab.com/gitlab-org/cluster-integration/runner-controller-example)。
- 阅读 [Runner 控制器规范](https://gitlab.com/gitlab-org/cluster-integration/gitlab-agent/-/blob/master/doc/runner_controller.md)了解协议详细信息。
- 探索使用 [Open Policy Agent (OPA)](https://www.openpolicyagent.org/) 实现更复杂的策略。
