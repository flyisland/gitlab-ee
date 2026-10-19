---
stage: Verify
group: Pipeline Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 测试均衡 API
---

{{< details >}}

- Tier: 旗舰版
- Offering: JihuLab.com，私有化部署
- Status: 实验

{{< /details >}}

> [!flag]
> 此功能的可用性由功能标志控制。
> 此功能可用于测试，但尚未准备好用于生产环境。

使用此 API 可根据测试时长，将测试分配到 [`parallel:`](../ci/yaml/_index.md#parallel) CI/CD 作业的各个节点上，使每个节点大致在同一时间完成。

测试拆分是分配到各节点的工作单元。按文件拆分时，每个测试拆分就是一个测试文件。节点使用其静态测试拆分预先填充共享待处理池，然后在完成时反复请求按时长预算分配的测试拆分批次。较快的节点会承担更多工作。当节点被重试时，它会收到最初分配给它的那组完全相同的测试拆分。

两个端点：

- 必须从正在运行的并行作业中调用，并使用
  [CI/CD 作业令牌](../ci/jobs/ci_job_token.md)（`CI_JOB_TOKEN`）进行身份验证。
- 当调用作业未使用 `parallel:` 关键字时，返回 `422 Unprocessable Entity`。
- 对于创建时间超过 30 天的流水线，返回 `422 Unprocessable Entity`，因为测试
  均衡数据（包括重试）自流水线创建起仅保留 30 天。

<a id="initialize-test-balancing-for-a-parallel-job"></a>

## 为并行作业初始化测试均衡

使用调用方的静态测试拆分预先填充该作业组的共享待处理池，并领取第一批测试拆分。如果该节点已经领取了测试拆分（例如，当作业被重试或从崩溃中恢复时），则原样返回之前领取的测试集，并忽略 `test_splits` 参数。

当预先填充会使该作业组的共享池超过 50,000 个测试拆分时，此端点返回
`422 Unprocessable Entity`。

```plaintext
POST /job/test_balancing/initialize
```

支持的属性：

| 属性                         | 类型            | 是否必需 | 描述 |
|-----------------------------------|-----------------|----------|-------------|
| `test_splits`                     | array of hashes | 是      | 分配给此节点的静态拆分的测试拆分。最多 1,000 个条目。 |
| `test_splits[].path`              | string          | 是      | 测试拆分的路径，相对于代码仓库根目录。最多 1024 个字符。 |
| `test_splits[].expected_duration` | float           | 否       | 测试拆分的预期时长，以秒为单位。未提供时默认为 300。 |

如果成功，返回 [`201 Created`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性                         | 类型   | 描述 |
|-----------------------------------|--------|-------------|
| `mode`                            | string | 当池已预先填充并领取了第一批时为 `seed`，当重放之前领取的测试集时为 `retry`。 |
| `test_splits`                     | array  | 该节点应运行的测试拆分。在 `retry` 时，为完整的原始测试集。 |
| `test_splits[].path`              | string | 测试拆分的路径，相对于代码仓库根目录。 |
| `test_splits[].expected_duration` | float  | 预先填充时的预期时长，以秒为单位。未提供时默认为 300。 |

示例请求：

```shell
curl --request POST \
  --header "JOB-TOKEN: $CI_JOB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{"test_splits": [{"path": "spec/models/user_spec.rb", "expected_duration": 12.5}]}' \
  --url "https://gitlab.example.com/api/v4/job/test_balancing/initialize"
```

示例响应：

```json
{
  "mode": "seed",
  "test_splits": [
    {
      "path": "spec/models/user_spec.rb",
      "expected_duration": 12.5
    }
  ]
}
```

<a id="request-the-next-batch-of-tests"></a>

## 请求下一批测试

以原子方式为调用节点领取一批按时长预算分配的待处理测试拆分，最慢的优先。`test_splits` 数组为空表示队列已排空，该节点应停止请求批次。

服务器根据共享池中剩余的总预期时长自动选择批次大小。当剩余时长较多时，服务器返回较大的批次以减少请求数量。随着池逐渐排空，服务器返回较小的批次，以使工作在各节点之间保持均衡。

```plaintext
POST /job/test_balancing/request
```

此端点不接受任何属性。

如果成功，返回 [`201 Created`](rest/troubleshooting.md#status-codes) 以及以下响应属性：

| 属性                         | 类型   | 描述 |
|-----------------------------------|--------|-------------|
| `test_splits`                     | array  | 该节点应运行的测试拆分。队列排空时为空。 |
| `test_splits[].path`              | string | 测试拆分的路径，相对于代码仓库根目录。 |
| `test_splits[].expected_duration` | float  | 预先填充时的预期时长，以秒为单位。未提供时默认为 300。 |

示例请求：

```shell
curl --request POST \
  --header "JOB-TOKEN: $CI_JOB_TOKEN" \
  --url "https://gitlab.example.com/api/v4/job/test_balancing/request"
```

示例响应：

```json
{
  "test_splits": [
    {
      "path": "spec/features/login_spec.rb",
      "expected_duration": 210.4
    }
  ]
}
```
