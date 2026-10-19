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

使用容器扫描时，您可能会遇到以下问题。

<a id="enable-verbose-logging"></a>

## 启用详细日志

当您需要详细了解容器扫描作业执行的操作时，请启用详细输出。有关详情，请参阅[调试级别日志](../troubleshooting_application_security.md#turn-on-debug-level-logging)。

<a id="docker-error-response-from-daemon-failed-to-copy-xattrs"></a>

## `docker: Error response from daemon: failed to copy xattrs`

当 runner 使用 `docker` 执行器且使用了 NFS 时
（例如 `/var/lib/docker` 位于 NFS 挂载点上），容器扫描可能会失败，并出现类似以下内容的错误：

```plaintext
docker: Error response from daemon: failed to copy xattrs: failed to set xattr "security.selinux" on /path/to/file: operation not supported.
```

此错误是由 Docker 中的一个 bug 导致的，该 bug 现已[修复](https://github.com/containerd/continuity/pull/138 "fs: add WithAllowXAttrErrors CopyOpt")。
为避免此错误，请确保 runner 使用的 Docker 版本为 `18.09.03` 或更高版本。有关更多信息，请参阅
[议题 #10241](https://gitlab.com/gitlab-org/gitlab/-/issues/10241 "Investigate why container scanning is not working with NFS mounts")。

<a id="error-gl-container-scanning-reportjson-no-matching-files"></a>

## 错误：`gl-container-scanning-report.json: no matching files`

有关此错误的信息，请参阅[应用安全故障排除通用部分](../../../ci/jobs/job_artifacts_troubleshooting.md#error-message-no-files-to-upload)。

<a id="error-unexpected-status-code-401-unauthorized-not-authorized"></a>

## 错误：`unexpected status code 401 Unauthorized: Not Authorized`

当您扫描来自 AWS ECR 的镜像且未配置 AWS 区域时，可能会出现此错误。扫描器无法获取授权令牌。当您将 `SECURE_LOG_LEVEL` 设置为 `debug` 时，您会看到类似以下内容的日志消息：

```shell
[35mDEBUG[0m failed to get authorization token: MissingRegion: could not find region configuration
```

要解决此问题，请将 `AWS_DEFAULT_REGION` 添加到您的 CI/CD 变量中：

```yaml
variables:
  AWS_DEFAULT_REGION: <AWS_REGION_FOR_ECR>
```

<a id="error-unable-to-open-a-file-open-homegitlabcachetrivyeedbmetadatajson"></a>

## 错误：`unable to open a file: open /home/gitlab/.cache/trivy/ee/db/metadata.json`

压缩后的 Trivy 数据库存储在容器的 `/tmp` 文件夹中，并在运行时解压到 `/home/gitlab/.cache/trivy/{ee|ce}/db`。如果您在 runner 配置中为 `/tmp` 目录设置了卷挂载，则可能会出现此错误。

要解决此问题，请不要绑定 `/tmp` 文件夹，而是绑定 `/tmp`中的特定文件或文件夹（例如 `/tmp/myfile.txt`）。

<a id="error-context-deadline-exceeded"></a>

## 错误：`context deadline exceeded`

此错误表示发生了超时。要解决此问题，请为 `container_scanning` 作业添加 `TRIVY_TIMEOUT` 环境变量，并设置足够长的时长。

<a id="no-vulnerabilities-detected-on-images-based-on-an-old-image"></a>

## 基于旧镜像的镜像上未检测到漏洞

Trivy 不会扫描不再接收任何更新的操作系统镜像。

在 UI 中显示此情况已在[议题 433325](https://gitlab.com/gitlab-org/gitlab/-/issues/433325)中提出。

<a id="expected-vulnerabilities-not-detected"></a>

## 未检测到预期漏洞

默认情况下，Trivy 不会报告[特定语言的发现结果](_index.md#report-language-specific-findings)，因此当镜像没有任何存在漏洞的操作系统依赖项时，可能会生成空报告。要启用特定语言的发现结果，请按照链接文档中的步骤操作，然后重新运行扫描。

<a id="warning-vulnerability-database-was-built-x-days-ago-max-allowed-age-is-y-days"></a>

## 警告：`vulnerability database was built X days ago (max allowed age is Y days)`

您可能会收到类似以下内容的错误消息：

```plaintext
1 error occurred: * the vulnerability database was built 6 days ago (max allowed age is 5 days)
```

当容器扫描镜像的创建时间超过 5 天时，容器扫描会失败。极狐GitLab 每天更新该镜像，但如果您使用的是该镜像的副本（例如在离线环境中），它可能会过时。最新的镜像可确保 Trivy 数据库（存储在该镜像中）保持最新。

要解决此问题，请更新容器扫描镜像。有关详情，请参阅[更新本地容器镜像](_index.md#update-local-container-image)。

<a id="error-unknown-scheme-in-cs_image-allowed-schemes-docker-archive"></a>

## 错误：`Unknown scheme in CS_IMAGE. Allowed schemes: docker, archive`

当 `CS_IMAGE` 环境变量设置了无效或缺失的 URI 方案时，您可能会遇到此错误。

当镜像引用未使用受支持的 URI 方案之一时，会出现此问题。来自镜像仓库的容器镜像必须使用 `docker://` 方案，本地 tar 归档文件必须使用 `archive://` 方案。

如果您扫描的是标准容器镜像，可以省略方案，仅使用镜像名称（例如 `myapp:latest` 或 `registry.example.com/myapp:latest`），因为分析器默认使用
Docker 方案。

请确认 `CS_IMAGE` 变量设置正确，且不包含拼写错误或不受支持的前缀。
