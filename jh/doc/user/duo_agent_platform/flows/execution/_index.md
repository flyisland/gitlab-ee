---
stage: Agent Foundations
group: Agent Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 配置 CI/CD 环境、设置脚本、缓存、ID 令牌以及执行极狐GitLab Duo Agent Platform 任务流的 Runner。
title: 配置任务流执行
---

{{< details >}}

- Tier: [基础版](../../../../subscriptions/gitlab_credits.md#for-the-free-tier)，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

任务流使用 Agent 来执行任务。

- 从极狐GitLab UI 执行的任务流使用 CI/CD。
- 在 IDE 中执行的任务流在本地运行。

您可以配置任务流使用 CI/CD 执行的环境。
您也可以[使用自己的 Runner](#configure-runners-to-execute-flows)，并在作业中[指定变量](execution-variables.md)。

<a id="executor-architecture"></a>

## 执行器架构

当任务流在 CI/CD 中运行时，Runner 会：

1. 从 `npm` 注册表下载 `@gitlab/duo-cli` 软件包。
1. 运行极狐GitLab Duo CLI，该 CLI 使用 WebSocket 连接到极狐GitLab Duo Workflow Service。
1. 根据 AI 模型的指令执行工具（文件操作、Git 命令）。

执行器版本由极狐GitLab 管理，并作为常规发布的一部分进行更新。

<a id="configure-cicd-execution"></a>

## 配置 CI/CD 执行

要自定义任务流在 CI/CD 中的执行方式，请在您的项目中创建 Agent 配置文件。

有关支持的键及其类型的列表，请参阅 [`agent-config.yml` 参考](agent-config-yaml.md)。

> [!note]
> 您不能使用预定义的 CI/CD 变量来配置 `agent-config.yml`。
> 您必须为执行任务流的作业使用[变量](execution-variables.md#available-variables)。

<a id="create-the-agent-configuration-file"></a>

### 创建 Agent 配置文件

1. 在您项目的代码仓库中，创建一个 `.gitlab/duo/` 文件夹。
1. 在该文件夹中，创建一个名为 `agent-config.yml` 的配置文件。
1. 添加您需要的配置选项。
1. 将文件提交并推送到您的默认分支。

当任务流在您项目的 CI/CD 中运行时，将应用该配置。

有关完整 `agent-config.yml` 文件的示例，请参阅 [`agent-config.yml` 参考](agent-config-yaml.md#complete-example)。

> [!note]
> 配置文件以只读方式从项目的默认分支读取。
> 提交到其他分支的文件将被忽略，即使任务流从这些分支运行也是如此。

<a id="configure-setup-scripts"></a>

### 配置设置脚本

您可以定义在任务流执行之前运行的设置脚本。这对于安装依赖项、配置环境或初始化非常有用。

要添加设置脚本，请在 `agent-config.yml` 文件中添加以下命令：

```yaml
setup_script:
  - apt-get update && apt-get install -y curl
  - pip install -r requirements.txt
  - echo "Setup complete"
```

这些命令完成以下操作：

- 在主工作流命令之前运行。
- 按指定顺序执行。
- 可以是单个命令或命令数组。

`setup_script` 的用户上下文取决于 Docker 镜像。默认的极狐GitLab 镜像以 `root` 身份运行。自定义镜像以镜像的 `USER` 指令中定义的用户身份运行。如果您的 `setup_script` 需要 root 访问权限（例如，安装系统软件包），请确保您的自定义镜像已相应配置。

> [!warning]
> `setup_script` 命令在应用 SRT 之前运行，并在其外部执行。
> 这些命令可以访问任务流中的所有环境变量，包括触发用户的 OAuth 令牌、服务令牌和身份详细信息。
> 有关安全模型和推荐的保护措施，请参阅
> [`agent-config.yml` 的安全影响](security-considerations.md#security-implications-of-agent-configyml)。

<a id="configure-caching"></a>

### 配置缓存

要配置缓存以加快后续任务流的运行，请配置 `agent-config.yml` 文件，以在两次执行之间保留文件和目录。缓存对于依赖项文件夹（如 `node_modules` 或 Python 虚拟环境）非常有用。

<a id="basic-cache-configuration"></a>

#### 基本缓存配置

要缓存特定路径，请在您的 `agent-config.yml` 文件中添加以下内容：

```yaml
cache:
  paths:
    - node_modules/
    - .npm/
```

<a id="cache-with-keys"></a>

#### 带键的缓存

您可以使用缓存键为不同场景创建不同的缓存。缓存键有助于确保缓存基于您项目的状态。

<a id="use-a-string-key"></a>

##### 使用字符串键

```yaml
cache:
  key: my-project-cache
  paths:
    - vendor/
    - .bundle/
```

<a id="use-file-based-cache-keys"></a>

##### 使用基于文件的缓存键

根据文件内容（如锁文件）创建动态缓存键。当这些文件更改时，会创建新缓存。这会生成指定文件的 SHA 校验和：

```yaml
cache:
  key:
    files:
      - package-lock.json
      - yarn.lock
  paths:
    - node_modules/
```

<a id="use-a-prefix-with-file-based-keys"></a>

##### 将前缀与基于文件的键结合使用

将前缀与为缓存键文件计算的 SHA 结合使用：

```yaml
cache:
  key:
    files:
      - package-lock.json
    prefix: $CI_JOB_NAME
  paths:
    - node_modules/
    - .npm/
```

在此示例中，如果作业名称为 `test` 且 SHA 校验和为 `abc123`，则缓存键变为 `test-abc123`。

<a id="cache-limitations"></a>

#### 缓存限制

- 您最多可以指定两个文件用于缓存键生成。如果指定了更多文件，则仅使用前两个。
- 缓存 `paths` 字段是必需的。没有路径的缓存配置无效。
- 缓存键支持 `prefix` 字段中的 CI/CD 变量。

<a id="configure-id-tokens"></a>

### 配置 ID 令牌

要从任务流向第三方服务进行身份验证，请配置
[ID 令牌](../../../../ci/secrets/id_token_authentication.md)。

ID 令牌是 JSON Web 令牌 (JWT)，由极狐GitLab CI/CD 生成并注入到运行任务流的作业中，
用于无密钥的 OpenID Connect (OIDC) 身份验证，无需存储长期凭据。
例如，您可以使用 ID 令牌从密钥管理器检索密钥，或对二进制文件和 Git 提交进行签名。

要配置 ID 令牌，请在 `agent-config.yml` 文件中添加一个 `id_tokens` 块。
每个令牌都需要一个 `aud`（受众）声明：

```yaml
id_tokens:
  VAULT_ID_TOKEN:
    aud: https://vault.example.com

network_policy:
  allowed_domains:
    - vault.example.com
```

`aud` 声明可以是单个字符串或字符串列表：

```yaml
id_tokens:
  MY_ID_TOKEN:
    aud:
      - https://first.service.example.com
      - https://second.service.example.com

network_policy:
  allowed_domains:
    - first.service.example.com
    - second.service.example.com
```

每个令牌在任务流作业中作为使用令牌名称的环境变量可用。
对于前面的示例，任务流可以使用 `$VAULT_ID_TOKEN` 和 `$MY_ID_TOKEN`。

如果令牌名称与配置中其他位置声明的变量名称匹配，则 ID 令牌优先。

> [!warning]
> ID 令牌是一种凭据，可授予对信任其 `aud` 声明的任何服务的访问权限。
> 为每个令牌设置尽可能窄的 `aud` 值，以便受损令牌能够
> 尽可能少地通过身份验证访问服务。由于配置文件是从默认分支读取的，
> 请应用[推荐的保护措施](security-considerations.md#recommended-protections)来控制
> 谁可以更改任务流可以请求的令牌。

有关令牌负载以及如何配置与第三方服务的信任的更多信息，
请参阅[使用 ID 令牌进行 OpenID Connect (OIDC) 身份验证](../../../../ci/secrets/id_token_authentication.md)。

<a id="configure-runners-to-execute-flows"></a>

## 配置 Runner 以执行任务流

使用 CI/CD 的任务流在 Runner 上运行。

在 JihuLab.com 上，任务流可以使用极狐GitLab 提供的[托管 Runner](../../../../ci/runners/hosted_runners/_index.md)。这些默认已启用。

您也可以选择为任务流配置自己的 Runner。

> [!note]
> 如果您的顶级群组已启用 [IP 地址限制](../../../group/access_and_permissions.md#restrict-group-access-by-ip-address)，
> 则托管 Runner 不能用于任务流。托管 Runner 使用来自云提供商池的动态 IP 地址，
> 无法添加到您群组的 IP 允许列表中。相反，请在顶级群组配置您自己的群组 Runner。

要为任务流配置您自己的 Runner：

1. 创建一个[实例 Runner](../../../../ci/runners/runners_scope.md) 或分配给顶级群组的群组 Runner。如果您希望任务流使用项目 Runner 或分配给子群组的群组 Runner，请关闭 `duo_runner_restrictions` 功能标志（仅限极狐GitLab 私有化部署）。
1. 向 Runner 添加 `gitlab--duo` 标签，以便其获取任务流的作业。如果 Runner 没有此标签，则带有任务流的作业将无限期排队。
   使用以下任一方法：
   - 创建 Runner 时，在 **标签** 字段中输入 `gitlab--duo`。
   - 对于现有 Runner，[编辑 Runner 可以运行的作业](../../../../ci/runners/configure_runners.md#control-jobs-that-a-runner-can-run)
     并在 **标签** 字段中输入 `gitlab--duo`。
   - 如果您使用 `config.toml` 文件配置 Runner，请将标签添加到 `[[runners]]` 部分：
     <!-- markdownlint-disable MD044 -->

     ```toml
     [[runners]]
       executor = "docker"
       tags = ["gitlab--duo"]
     ```

     <!-- markdownlint-enable MD044 -->
1. 将 Runner 配置为使用支持 Docker 镜像的[执行器](https://gitlab.cn/docs/runner/executors/)，例如 `docker`、`docker-autoscaler` 或 `kubernetes`。
   不支持 `shell` 执行器。
1. 如果您的顶级群组已启用 [IP 地址限制](../../../group/access_and_permissions.md#restrict-group-access-by-ip-address)，
   请将 Runner 的 IP 地址添加到您群组的 IP 允许列表中，以便 Runner 可以访问该群组。
1. 仅限极狐GitLab 私有化部署。确保 Runner 可以访问任务流所需的服务：
   - [允许从极狐GitLab 实例发起出站连接](../../../../administration/gitlab_duo/configure/_index.md#allow-outbound-connections-from-the-gitlab-instance-to-gitlab-duo)到 Agent Platform。
   - [允许从 Runner 发起出站连接](../../../../administration/gitlab_duo/configure/_index.md#allow-connections-from-the-runner)到 Agent Platform。
   - 对于证书链中包含自签名证书的实例，请完成
     [额外的极狐GitLab Duo CLI 配置](../../../gitlab_duo_cli/use.md#certificate-errors)。

<a id="use-the-execution-environment-sandbox-to-secure-flows"></a>

### 使用执行环境沙箱保护任务流

对于网络和文件系统隔离，请使用[执行环境沙箱](../../environment_sandbox.md)
来保护在 Runner 上执行的任务流。

要使用沙箱，您必须使用以下镜像之一：

- Agent Platform 的默认 Docker 基础镜像
- 安装了 SRT 的自定义镜像

要将 Runner 配置为使用沙箱，请在您的 [Runner 配置](https://gitlab.cn/docs/runner/configuration/advanced-configuration/)中设置 `privileged = true`。

例如：
<!-- markdownlint-disable MD044 -->

```toml
[[runners]]
  executor = "docker"
  tags = ["gitlab--duo"]
  [runners.docker]
    privileged = true
```

<!-- markdownlint-enable MD044 -->
您不能将沙箱与以下镜像一起使用：

- 未安装 SRT 的自定义镜像
- 加固的 UBI 9 Minimal 镜像
