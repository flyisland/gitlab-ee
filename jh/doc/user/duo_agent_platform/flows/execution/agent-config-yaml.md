---
stage: Agent Foundations
group: Agent Execution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 关于 Agent 配置文件中支持的键的参考，该文件用于配置任务流在 CI/CD 中的执行方式。
title: Agent 配置文件语法
---

{{< details >}}

- Tier: [基础版](../../../../subscriptions/gitlab_credits.md#for-the-free-tier)，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

`agent-config.yml` 文件用于配置任务流在您项目的 CI/CD 中的执行方式。
请将该文件放置在项目代码仓库的 `.gitlab/duo/agent-config.yml` 路径下。

有关用法的更多信息，请参阅[配置任务流执行](_index.md)。

> [!note]
> 该配置文件以只读方式从项目的默认分支读取。
> 提交到其他分支的文件会被忽略，即使任务流从这些分支运行也是如此。

<a id="supported-keys"></a>

## 支持的键

| 键 | 类型 | 描述 |
|-----|------|-------------|
| `image` | 字符串 | 用于任务流执行的 Docker 镜像。最少 1 个字符，最多 512 个字符。 |
| `setup_script` | 字符串或字符串数组 | 在任务流开始前运行的 Shell 命令。 |
| `network_policy` | 对象 | 执行环境的网络访问规则。有关更多信息，请参阅[配置网络策略](../../environment_sandbox.md#configure-a-network-policy)。 |
| `network_policy.allowed_domains` | 字符串数组 | 任务流可以访问的域名。最多 1000 条。 |
| `network_policy.denied_domains` | 字符串数组 | 任务流无法访问的域名。最多 1000 条。 |
| `network_policy.include_recommended_allowed` | 布尔值 | 包含极狐GitLab 推荐的允许域名。默认值：`false`。 |
| `network_policy.allow_all_unix_sockets` | 布尔值 | 允许所有 Unix 套接字连接。默认值：`false`。 |
| `cache` | 对象 | 在任务流运行之间保留的文件和目录。有关更多信息，请参阅[配置缓存](_index.md#configure-caching)。 |
| `cache.paths` | 字符串或字符串数组 | 要缓存的路径。必须设置才能使缓存生效。 |
| `cache.key` | 字符串或对象 | 缓存键。如果省略，则使用默认键。 |
| `cache.key.files` | 字符串数组 | 用于生成基于 SHA 的缓存键的文件。最多 2 个文件。 |
| `cache.key.prefix` | 字符串 | 与文件 SHA 组合形成缓存键的前缀。需要 `files`。 |

<a id="complete-example"></a>

## 完整示例

以下示例使用了所有可用的配置选项：

```yaml
# Custom Docker image
image: python:3.11

# Setup script to run before the flow
setup_script:
  - apt-get update && apt-get install -y build-essential
  - pip install --upgrade pip
  - pip install -r requirements.txt

# Cache configuration
cache:
  key:
    files:
      - requirements.txt
      - Pipfile.lock
    prefix: python-deps
  paths:
    - .cache/pip
    - venv/

# Network configuration
network_policy:
  include_recommended_allowed: true
  allow_all_unix_sockets: true
  allowed_domains:
    - my-own-site.com
  denied_domains:
    - malicious.com
```
