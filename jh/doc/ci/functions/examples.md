---
stage: Verify
group: CI Functions Platform
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 极狐GitLab Functions 示例
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Status: Experiment

{{< /details >}}

以下示例使用 Google distroless 镜像，该镜像包含 `ca-certificates`，但没有软件包管理器或 shell。
你可以使用任何已安装受信任 CA 根证书的镜像。

<a id="echo-a-message"></a>

## 回显消息

回显一条消息，供后续步骤使用。
完整源代码请参见 [echo](https://jihulab.com/gitlab-cn/ci-cd/runner-tools/gitlab-functions-examples/echo)。

函数定义：

```yaml
spec:
  inputs:
    message:
      type: string
      default: "Hello World!"
      description: "要打印到标准输出的消息"
  outputs:
    message:
      type: string
---
exec:
  command:
    - ${{ func_dir }}/echo
    - --message
    - ${{ inputs.message }}
    - --output-file
    - ${{ output_file }}
```

用法：

```yaml
my-job:
  image: gcr.io/distroless/static-debian12
  run:
    - name: echo_hi
      func: registry.gitlab.com/gitlab-org/ci-cd/runner-tools/gitlab-functions-examples/echo:1
      inputs:
        message: "你好，${{ vars.GITLAB_USER_NAME }}"
    - name: echo_repeat
      func: registry.gitlab.com/gitlab-org/ci-cd/runner-tools/gitlab-functions-examples/echo:1
      inputs:
        message: "echo_hi 步骤说：${{ steps.echo_hi.outputs.message }}"
```

输出：

```shell
运行步骤 name=echo_hi
Hi, Zhang Wei
运行步骤 name=echo_repeat
echo_hi 步骤说：Hi, Zhang Wei
```

<a id="produce-a-random-value"></a>

## 生成随机值

生成一个随机值，供后续步骤使用。
完整源代码请参见 [random](https://jihulab.com/gitlab-cn/ci-cd/runner-tools/gitlab-functions-examples/random)。

函数定义：

```yaml
spec:
  outputs:
    random_value:
      type: string
---
exec:
  command:
    - ${{ func_dir }}/random
    - --output-file
    - ${{ output_file }}
```

用法：

```yaml
my-job:
  image: gcr.io/distroless/static-debian12
  run:
    - name: random
      func: registry.gitlab.com/gitlab-org/ci-cd/runner-tools/gitlab-functions-examples/random:1
    - name: print_random
      func: registry.gitlab.com/gitlab-org/ci-cd/runner-tools/gitlab-functions-examples/echo:1
      inputs:
        message: "随机值为：${{ steps.random.outputs.random_value }}"
```

输出：

```shell
运行步骤 name=random
运行步骤 name=print_random
随机值为：DVhV5vcd2BjDDtpV
```

<a id="extract-fields-from-json"></a>

## 从 JSON 中提取字段

运行 `jq` 来过滤 JSON 输入。
完整源代码请参见 [jq](https://jihulab.com/gitlab-cn/ci-cd/runner-tools/gitlab-functions-examples/jq)。

函数定义：

```yaml
spec:
  inputs:
    filter:
      type: string
      default: "."
    input:
      type: string
      default: "{}"
    input_file:
      type: string
      default: ""
  outputs:
    result:
      type: struct
---
exec:
  command:
    - ${{ func_dir }}/jq-wrapper
    - --func-dir
    - ${{ func_dir }}
    - --filter
    - ${{ inputs.filter }}
    - --input
    - ${{ inputs.input }}
    - --input-file
    - ${{ inputs.input_file }}
    - --output-file
    - ${{ output_file }}
```

用法：

```yaml
my-job:
  image: gcr.io/distroless/static-debian12
  run:
    - name: jq
      func: registry.gitlab.com/gitlab-org/ci-cd/runner-tools/gitlab-functions-examples/jq:1
      inputs:
        input: |
          {"users":[
            {"name":"Alice","role":"admin"},
            {"name":"Bob","role":"viewer"},
            {"name":"Carol","role":"admin"}
          ]}
        filter: '[.users[] | select(.role == "admin") | .name]'
    - name: print_admins
      func: registry.gitlab.com/gitlab-org/ci-cd/runner-tools/gitlab-functions-examples/echo:1
      inputs:
        message: "管理员：${{ steps.jq.outputs.result.value }}"
```

输出：

```shell
运行步骤 name=jq
运行步骤 name=print_admins
管理员：["Alice", "Carol"]
```

<a id="authenticate-to-docker"></a>

## 向 Docker 认证

创建 Docker 配置，并将其作为环境变量 `DOCKER_AUTH_CONFIG` 的值，供后续函数使用。
完整源代码请参见 [Docker Auth](https://jihulab.com/gitlab-cn/ci-cd/runner-tools/gitlab-functions-examples/docker-auth)。

函数定义：

```yaml
spec:
  inputs:
    registry:
      type: string
      default: ""
      description: "注册表 URL"
    username:
      type: string
      default: ""
      description: "认证类型的用户名"
    password:
      type: string
      default: ""
      description: "认证类型的密码"
    helper_name:
      type: string
      default: ""
      description: "凭证助手名称"
    store_name:
      type: string
      default: ""
      description: "默认凭证存储名称"
    config_file:
      type: string
      default: ""
      description: "现有 config.json 的路径（默认：~/.docker/config.json）"
  outputs:
    auth:
      type: struct
---
env:
  DOCKER_PASSWORD: ${{ inputs.password }}
exec:
  work_dir: ${{ func_dir }}
  command:
    - ${{ func_dir }}/docker-auth
    - --registry
    - ${{ inputs.registry }}
    - --username
    - ${{ inputs.username }}
    - --helper-name
    - ${{ inputs.helper_name }}
    - --store-name
    - ${{ inputs.store_name }}
    - --config
    - ${{ inputs.config_file }}
    - --output-file
    - ${{ output_file }}
    - --export-file
    - ${{ export_file }}
```

用法：

```yaml
build-image:
  image: gcr.io/distroless/static-debian12
  run:
    - name: auth_to_my_registry
      func: registry.gitlab.com/gitlab-org/ci-cd/runner-tools/gitlab-functions-examples/docker-auth:1
      inputs:
        registry: my.registry.com
        username: ${{ vars.MY_REGISTRY_USER }}
        password: ${{ vars.MY_REGISTRY_PASSWORD }}
    - name: my_func
      func: my.registry.com/my-function:latest  # 需要认证才能拉取镜像
```

输出：

```shell
运行步骤 name=auth_to_my_registry
为注册表 my.registry.com 添加了基本认证
Docker 认证配置完成
运行步骤 name=my_func
...
```