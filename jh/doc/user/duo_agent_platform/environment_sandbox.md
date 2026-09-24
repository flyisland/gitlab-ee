---
stage: AI-powered
group: Agent Foundations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 远程执行环境沙箱
---

{{< history >}}

- Introduced in 极狐GitLab 18.7 [带有功能标志](../../administration/feature_flags/_index.md) 命名为 `ai_duo_agent_platform_network_firewall` 和 `ai_dap_executor_connects_over_ws`
- 功能标志 `ai_duo_agent_platform_network_firewall` enabled in 极狐GitLab 18.7.
- 功能标志 `ai_dap_executor_connects_over_ws` enabled in 极狐GitLab 18.7.
- Generally available in 极狐GitLab 18.8.
- `network_policy` 设置 introduced in 极狐GitLab 18.10.
- `allow_all_unix_sockets` 网络策略设置 introduced in 极狐GitLab 18.11.

{{< /history >}}

执行环境沙箱提供应用级别的网络和文件系统隔离，保护极狐GitLab Duo Agent Platform 远程 flow 免受未授权网络访问和数据泄露。它旨在帮助防止数据泄露尝试、从外部来源加载恶意代码以及未经授权的数据收集，同时保持合法 flow 操作所需的连接性。

<a id="when-the-sandbox-is-applied"></a>

## 何时应用沙箱

当使用安装了 Anthropic Sandbox Runtime (SRT) 的兼容 Docker 镜像时，将自动应用执行环境沙箱。这包括使用默认极狐GitLab Docker 镜像（版本 [v0.0.6](https://gitlab.com/gitlab-org/duo-workflow/default-docker-image/-/tags/v0.0.6) 及更高版本）或[安装了 SRT 的自定义镜像](#install-anthropic-sandbox-runtime-srt-on-a-custom-image)。

沙箱在以下情况下启用：

- Docker 镜像中可用的 Anthropic Sandbox Runtime (SRT)。
- 极狐GitLab Duo Agent Platform 会话在 runner 上执行（本地环境不做沙箱处理）。

有关默认和自定义镜像配置之间的 CI/CD 变量差异，请参阅
[Flow 执行变量](flows/execution_variables.md)。

<a id="prerequisites"></a>

## 先决条件

要使用执行环境沙箱，你需要：

- 在项目中启用 极狐GitLab Duo Agent Platform。
- 启用特权 runner 模式。这是[沙箱正常工作所必需的](flows/execution.md#configure-runners)。
- 兼容的 Docker 镜像：可以是版本 `v0.0.6` 或更高版本的[默认极狐GitLab Docker 镜像](https://gitlab.com/gitlab-org/duo-workflow/default-docker-image/container_registry)，也可以是[安装了 Anthropic Sandbox Runtime (SRT) 的自定义镜像](#install-anthropic-sandbox-runtime-srt-on-a-custom-image)。

<a id="how-it-works"></a>

## 工作原理

执行环境沙箱使用 [Anthropic Sandbox Runtime (SRT)](https://github.com/anthropic-experimental/sandbox-runtime) 来包装 flow 执行，提供以下保护：

- 网络隔离：拦截所有在离开执行环境前的网络请求，并根据允许的域列表进行验证。
- 文件系统限制：限制对特定目录的读写访问，并阻止访问敏感文件。
- 优雅回退：如果 SRT 不可用或缺少所需的操作系统权限，flow 将直接运行并显示警告消息。

<a id="install-anthropic-sandbox-runtime-srt-on-a-custom-image"></a>

## 在自定义镜像上安装 Anthropic Sandbox Runtime (SRT)

如果你使用自定义镜像，例如配置了 [`agent-config.yml`](flows/execution.md#create-the-configuration-file) 的镜像，则必须安装 Anthropic SRT 版本 `0.0.20` 或更高版本，并在环境中可用。

SRT 通过 `npm` 提供，包名为 `@anthropic-ai/sandbox-runtime`。以下示例展示了在 Dockerfile 中的安装阶段：

```dockerfile
# 安装 srt 沙箱，清除缓存并验证
ARG SANDBOX_RUNTIME_VERSION=0.0.20
RUN npm cache clean --force && \
    npm install -g @anthropic-ai/sandbox-runtime@${SANDBOX_RUNTIME_VERSION} && \
    test -s "$(npm root -g)/@anthropic-ai/sandbox-runtime/package.json" && \
    srt --version

```

运行时，runner 会检查 SRT 是否可用且正常工作：

```shell
$ if which srt > /dev/null; then
$ echo "发现 SRT，正在创建配置..."
发现 SRT，正在创建配置...
$ echo '{"network":{"allowedDomains":["host.docker.internal","localhost","jihulab.com","*.jihulab.com","duo-workflow.jihulab.com"],"deniedDomains":[],"allowAllUnixSockets":false},"filesystem":{"denyRead":["~/.ssh"],"allowWrite":["./","/tmp/gitlab_duo_agent_platform"],"denyWrite":[],"allowGitConfig":true}}' > /tmp/gitlab_duo_agent_platform/srt-settings.json
$ echo "正在测试 SRT 沙箱能力..."
正在测试 SRT 沙箱能力...
```

运行时可能会出现以下错误，这可能表示 SRT 所需的依赖不可用：

```shell
警告：发现 SRT，但无法创建沙箱（权限不足），直接运行命令
```

要解决此问题：

1. 使用 bash 通过以下命令验证镜像：

   ```shell
   docker run --rm -it <image>:<tag> /bin/bash
   ```

1. 使用 `srt`：

   ```shell
   srt ls
   ```

1. 如果显示如下错误，则必须在自定义镜像中安装其他依赖：

   ```shell
   Error: 此系统上不可用沙箱依赖。需要：ripgrep (rg)、bubblewrap (bwrap) 和 socat。
   ```

<a id="network-and-filesystem-restrictions"></a>

## 网络和文件系统限制

应用执行环境沙箱时，将强制执行以下限制。

<a id="configure-sandbox-settings"></a>

### 配置沙箱设置

使用 [`agent-config.yml`](flows/execution.md#create-the-configuration-file) 文件来配置一些沙箱设置。

默认情况下，沙箱允许访问以下配置：

- 默认允许的域列表。这些是自动配置的，无法更改或更新。

<a id="environment-variables"></a>

### 环境变量

只有运行 DAP 和 Git 操作所需的环境变量和参数可以从沙箱环境访问。

<a id="filesystem-configuration"></a>

### 文件系统配置

沙箱强制执行以下文件系统限制：

- 读取限制：阻止 SSH 密钥 (`~/.ssh`)。
- 写入允许：当前目录 (`./`) 和临时目录 (`/tmp/gitlab_duo_agent_platform`)。
- Git 配置访问：允许。

<a id="configure-a-network-policy"></a>

### 配置网络策略

SRT 包含在默认的极狐GitLab 提供的 Docker 镜像中。你也可以
[在自定义镜像上安装 SRT](#install-anthropic-sandbox-runtime-srt-on-a-custom-image)。

安装 SRT 后，flow 默认只能访问以下域。
这些域始终允许，无法删除：

- `localhost`
- `host.docker.internal`
- 你的极狐GitLab 实例域名（例如 `jihulab.com`，`*.jihulab.com`）
- 极狐GitLab Duo Workflow Service 域名

如果你使用未安装 SRT 的自定义镜像，
则不会应用网络限制，flow 可以访问从 runner 可达的任何域。

要允许或拒绝其他域，请在你的 `agent-config.yml` 文件中添加一个 `network_policy`。

> [!note]
> `network_policy` 不允许在 `allowed_domains` 或 `denied_domains` 中使用 `"*"`。SRT 不支持开放所有网络流量。
> 但是，允许在域中使用通配符，例如 `"*.domain.com"`。

```yaml
network_policy:
  include_recommended_allowed: true # 默认值：false
  allow_all_unix_sockets: true      # 默认值：false
  allowed_domains:
    - my-own-site.com
  denied_domains:
    - malicious.com
```

<a id="allow-unix-socket-access"></a>

#### 允许 Unix 套接字访问

使用 `allow_all_unix_sockets` 设置授权 flow 访问主机上的所有 Unix 域套接字。此功能默认禁用。

> [!warning]
> 启用 `allow_all_unix_sockets` 会授予对所有 Unix 套接字的访问权。仅在必要时且仅在受信任的环境中启用。

<a id="turn-on-allowed-domains"></a>

### 开启允许的域

要允许你的 flow 访问用于软件包仓库和开发工具的一组外部域，
请开启 `include_recommended_allowed` 设置。

此设置默认禁用 (`false`)。要开启它，请在 `agent-config.yml` 文件中将 `include_recommended_allowed` 设置为 `true`。

> [!warning]
> 启用 `include_recommended_allowed` 会允许网络访问大量外部域。这些出口端点可能被用于从环境中窃取数据。仅在必要时且仅在受信任的环境中启用。

此设置开启对以下域的访问：

- `github.com`
- `www.github.com`
- `api.github.com`
- `npm.pkg.github.com`
- `raw.githubusercontent.com`
- `pkg-npm.githubusercontent.com`
- `objects.githubusercontent.com`
- `codeload.github.com`
- `avatars.githubusercontent.com`
- `camo.githubusercontent.com`
- `gist.github.com`
- `gitlab.com`
- `www.gitlab.com`
- `registry.gitlab.com`
- `bitbucket.org`
- `www.bitbucket.org`
- `api.bitbucket.org`
- `registry-1.docker.io`
- `auth.docker.io`
- `index.docker.io`
- `hub.docker.com`
- `www.docker.com`
- `production.cloudflare.docker.com`
- `download.docker.com`
- `gcr.io`
- `*.gcr.io`
- `ghcr.io`
- `mcr.microsoft.com`
- `*.data.mcr.microsoft.com`
- `public.ecr.aws`
- `cloud.google.com`
- `accounts.google.com`
- `gcloud.google.com`
- `storage.googleapis.com`
- `compute.googleapis.com`
- `container.googleapis.com`
- `artifactregistry.googleapis.com`
- `cloudresourcemanager.googleapis.com`
- `oauth2.googleapis.com`
- `www.googleapis.com`
- `login.microsoftonline.com`
- `packages.microsoft.com`
- `dotnet.microsoft.com`
- `dot.net`
- `dev.azure.com`
- `s3.amazonaws.com`
- `*.s3.amazonaws.com`
- `*.codeartifact.amazonaws.com`
- `*.s3.api.aws`
- `*.codeartifact.api.aws`
- `download.oracle.com`
- `yum.oracle.com`
- `registry.npmjs.org`
- `www.npmjs.com`
- `www.npmjs.org`
- `npmjs.com`
- `npmjs.org`
- `yarnpkg.com`
- `registry.yarnpkg.com`
- `pypi.org`
- `www.pypi.org`
- `files.pythonhosted.org`
- `pythonhosted.org`
- `test.pypi.org`
- `pypi.python.org`
- `pypa.io`
- `www.pypa.io`
- `rubygems.org`
- `www.rubygems.org`
- `api.rubygems.org`
- `index.rubygems.org`
- `ruby-lang.org`
- `www.ruby-lang.org`
- `rubyonrails.org`
- `www.rubyonrails.org`
- `rvm.io`
- `get.rvm.io`
- `crates.io`
- `www.crates.io`
- `index.crates.io`
- `static.crates.io`
- `rustup.rs`
- `static.rust-lang.org`
- `www.rust-lang.org`
- `proxy.golang.org`
- `sum.golang.org`
- `index.golang.org`
- `golang.org`
- `www.golang.org`
- `goproxy.io`
- `pkg.go.dev`
- `maven.org`
- `repo.maven.org`
- `central.maven.org`
- `repo1.maven.org`
- `jcenter.bintray.com`
- `gradle.org`
- `www.gradle.org`
- `services.gradle.org`
- `plugins.gradle.org`
- `kotlin.org`
- `www.kotlin.org`
- `spring.io`
- `repo.spring.io`
- `packagist.org`
- `www.packagist.org`
- `repo.packagist.org`
- `nuget.org`
- `www.nuget.org`
- `api.nuget.org`
- `pub.dev`
- `api.pub.dev`
- `hex.pm`
- `www.hex.pm`
- `cpan.org`
- `www.cpan.org`
- `metacpan.org`
- `www.metacpan.org`
- `api.metacpan.org`
- `cocoapods.org`
- `www.cocoapods.org`
- `cdn.cocoapods.org`
- `haskell.org`
- `www.haskell.org`
- `hackage.haskell.org`
- `swift.org`
- `www.swift.org`
- `archive.ubuntu.com`
- `security.ubuntu.com`
- `ubuntu.com`
- `www.ubuntu.com`
- `*.ubuntu.com`
- `ppa.launchpad.net`
- `launchpad.net`
- `www.launchpad.net`
- `dl.k8s.io`
- `pkgs.k8s.io`
- `k8s.io`
- `www.k8s.io`
- `releases.hashicorp.com`
- `apt.releases.hashicorp.com`
- `rpm.releases.hashicorp.com`
- `archive.releases.hashicorp.com`
- `hashicorp.com`
- `www.hashicorp.com`
- `repo.anaconda.com`
- `conda.anaconda.org`
- `anaconda.org`
- `www.anaconda.com`
- `anaconda.com`
- `continuum.io`
- `apache.org`
- `www.apache.org`
- `archive.apache.org`
- `downloads.apache.org`
- `eclipse.org`
- `www.eclipse.org`
- `download.eclipse.org`
- `nodejs.org`
- `www.nodejs.org`
- `sourceforge.net`
- `*.sourceforge.net`
- `packagecloud.io`
- `*.packagecloud.io`
- `json-schema.org`
- `www.json-schema.org`
- `json.schemastore.org`
- `www.schemastore.org`
- `*.modelcontextprotocol.io`

<a id="warnings-and-fallback-behavior"></a>

## 警告和回退行为

如果沙箱不可用或无法应用：

- flow 直接运行，没有沙箱保护
- CI 作业日志中显示一条警告消息，并附有 runner 配置指导的链接

这确保了即使无法启用沙箱，flow 也能继续执行，同时提醒你注意这一情况。