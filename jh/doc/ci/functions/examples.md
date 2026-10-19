---
stage: Verify
group: CI Functions Platform
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: GitLab Functions 示例
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署
- Status: 实验

{{< /details >}}

以下示例使用 Google distroless 镜像，该镜像包含 `ca-certificates`，但没有软件包管理器或 shell。您可以使用任何已安装受信任 CA 根证书的镜像。

<a id="echo-a-message"></a>

## 回显消息

回显一条消息，供后续步骤使用。完整源代码请参见 [echo](https://gitlab.com/gitlab-org/ci-cd/runner-tools/gitlab-functions-examples/echo)。

函数定义：

```yaml
spec:
  inputs:
    message:
      type: string
      default: "Hello World!"
      description: "The message to print to stdout"
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
        message: "Hi, ${{ vars.GITLAB_USER_NAME }}"
    - name: echo_repeat
      func: registry.gitlab.com/gitlab-org/ci-cd/runner-tools/gitlab-functions-examples/echo:1
      inputs:
        message: "The echo_hi step said: ${{ steps.echo_hi.outputs.message }}"
```

输出：

```shell
Running step name=echo_hi
Hi, Zhang Wei
Running step name=echo_repeat
The echo_hi step said: Hi, Zhang Wei
```

<a id="produce-a-random-value"></a>

## 生成随机值

生成一个随机值，供后续步骤使用。完整源代码请参见 [random](https://gitlab.com/gitlab-org/ci-cd/runner-tools/gitlab-functions-examples/random)。

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
        message: "The random value is: ${{ steps.random.outputs.random_value }}"
```

输出：

```shell
Running step name=random
Running step name=print_random
The random value is: DVhV5vcd2BjDDtpV
```

<a id="extract-fields-from-json"></a>

## 从 JSON 中提取字段

运行 `jq` 以过滤 JSON 输入。完整源代码请参见 [jq](https://gitlab.com/gitlab-org/ci-cd/runner-tools/gitlab-functions-examples/jq)。

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
        message: "Admins: ${{ steps.jq.outputs.result.value }}"
```

输出：

```shell
Running step name=jq
Running step name=print_admins
Admins: ["Alice", "Carol"]
```

<a id="authenticate-to-docker"></a>

## 向 Docker 进行身份认证

创建 Docker 配置，并将其作为环境变量 `DOCKER_AUTH_CONFIG`的值添加，以供后续函数使用。
完整源代码请参见 [Docker Auth](https://gitlab.com/gitlab-org/ci-cd/runner-tools/gitlab-functions-examples/docker-auth)。

函数定义：

```yaml
spec:
  inputs:
    registry:
      type: string
      default: ""
      description: "registry URL"
    username:
      type: string
      default: ""
      description: "username for auth type"
    password:
      type: string
      default: ""
      description: "password for auth type"
    helper_name:
      type: string
      default: ""
      description: "credential helper name"
    store_name:
      type: string
      default: ""
      description: "default credential store name"
    config_file:
      type: string
      default: ""
      description: "path to existing config.json (default: ~/.docker/config.json)"
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
      func: my.registry.com/my-function:latest  # requires auth to fetch an image
```

输出：

```shell
Running step name=auth_to_my_registry
added basic auth for registry my.registry.com
docker auth configuration complete
Running step name=my_func
...
```
