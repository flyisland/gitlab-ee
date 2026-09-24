---
stage: Application Security Testing
group: Composition Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 容器扫描故障排除
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

当使用容器扫描时，您可能会遇到以下问题。

<a id="enable-verbose-logging"></a>

## 启用详细日志记录

当需要查看容器扫描作业的详细操作时，启用详细输出。详情请参阅
[调试级日志记录](../troubleshooting_application_security.md#turn-on-debug-level-logging)。

<a id="docker-error-response-from-daemon-failed-to-copy-xattrs"></a>

## `docker: Error response from daemon: failed to copy xattrs`

当 runner 使用 `docker` 执行器并且使用了 NFS（例如 `/var/lib/docker` 位于 NFS 挂载上），容器扫描可能会失败并显示类似于以下内容的错误：

```plaintext
docker: 守护进程返回错误：复制 xattrs 失败：在 /path/to/file 上设置 xattr "security.selinux" 失败：操作不支持。
```

此错误是由于 Docker 中的一个错误引起的，该错误现已[修复](https://github.com/containerd/continuity/pull/138 "fs: add WithAllowXAttrErrors CopyOpt")。为防止此错误，请确保 runner 使用的 Docker 版本为 `18.09.03` 或更高版本。

<a id="error-gl-container-scanning-reportjson-no-matching-files"></a>

## 错误：`gl-container-scanning-report.json: no matching files`

相关信息，请参阅[通用应用安全故障排除部分](../../../ci/jobs/job_artifacts_troubleshooting.md#error-message-no-files-to-upload)。

<a id="error-unexpected-status-code-401-unauthorized-not-authorized"></a>

## 错误：`unexpected status code 401 Unauthorized: Not Authorized`

当您扫描来自 AWS ECR 的镜像且 AWS 区域未配置时，可能会出现此错误。扫描程序无法检索授权令牌。
当将 `SECURE_LOG_LEVEL` 设置为 `debug` 时，您将看到类似如下的日志消息：

```shell
[35mDEBUG[0m 获取授权令牌失败：MissingRegion：找不到区域配置
```

要解决此问题，请将 `AWS_DEFAULT_REGION` 添加到您的 CI/CD 变量中：

```yaml
variables:
  AWS_DEFAULT_REGION: <AWS_REGION_FOR_ECR>
```

<a id="error-unable-to-open-a-file-open-homegitlabcachetrivyeedbmetadatajson"></a>

## 错误：`unable to open a file: open /home/gitlab/.cache/trivy/ee/db/metadata.json`

压缩的 Trivy 数据库存储在容器的 `/tmp` 文件夹中，并在运行时提取到 `/home/gitlab/.cache/trivy/{ee|ce}/db`。如果您在 runner 配置中对 `/tmp` 目录进行了卷挂载，则可能出现此错误。

要解决此问题，请不要绑定整个 `/tmp` 文件夹，而是绑定 `/tmp` 中的特定文件或文件夹（例如 `/tmp/myfile.txt`）。

<a id="error-context-deadline-exceeded"></a>

## 错误：`context deadline exceeded`

此错误表示超时。要解决此问题，请将 `TRIVY_TIMEOUT` 环境变量添加到 `container_scanning` 作业中，并设置足够长的持续时间。

<a id="no-vulnerabilities-detected-on-images-based-on-an-old-image"></a>

## 基于旧镜像的镜像未检测到漏洞

Trivy 不会扫描不再接收任何更新的操作系统镜像。

<a id="expected-vulnerabilities-not-detected"></a>

## 未检测到预期的漏洞

Trivy 默认不报告[特定语言的发现](_index.md#report-language-specific-findings)，这可能会导致当镜像没有任何易受攻击的操作系统依赖项时，报告为空。要启用特定语言的发现，请按照链接文档中的步骤操作，然后重新运行扫描。

<a id="warning-vulnerability-database-was-built-x-days-ago-max-allowed-age-is-y-days"></a>

## 警告：`vulnerability database was built X days ago (max allowed age is Y days)`

您可能会收到类似如下的错误消息：

```plaintext
发生 1 个错误：* 漏洞数据库是在 6 天前构建的（允许的最长存在时间为 5 天）
```

当容器扫描镜像的创建时间超过 5 天时，容器扫描会失败。极狐GitLab 每天更新该镜像，但如果您使用该镜像的副本（例如在离线环境中），它可能会过时。最新的镜像可确保 Trivy 数据库（存储在镜像中）是最新的。

要解决此问题，请更新容器扫描镜像。详情请参阅[更新本地容器镜像](_index.md#update-local-container-image)。

<a id="error-unknown-scheme-in-csimage-allowed-schemes-docker-archive"></a>

## 错误：`Unknown scheme in CS_IMAGE. Allowed schemes: docker, archive`

当 `CS_IMAGE` 环境变量设置了无效的或缺少 URI 方案时，您可能会遇到此错误。

当镜像引用没有使用支持的方案之一时，就会出现此问题。该方案必须是 `docker://` 方案（用于来自仓库的容器镜像）或 `archive://` 方案（用于本地 tar 归档文件）。

如果您扫描标准容器镜像，可以省略方案，仅使用镜像名称（例如 `myapp:latest` 或 `registry.example.com/myapp:latest`），因为分析器默认使用 Docker 方案。

请验证 `CS_IMAGE` 变量设置正确，且不包含拼写错误或不支持的前缀。