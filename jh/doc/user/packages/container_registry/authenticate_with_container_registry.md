---
stage: Package
group: Container Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: 了解如何使用您的极狐GitLab 登录凭据、令牌或 CI/CD 变量（例如 CI 作业令牌）向容器镜像仓库进行身份验证。
title: 向容器镜像仓库进行身份验证
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

要向容器镜像仓库进行身份验证，您可以使用：

- 极狐GitLab 用户名和密码（如果启用了 2FA，则不可用）
- [个人访问令牌](../../profile/personal_access_tokens.md)
- [部署令牌](../../project/deploy_tokens/_index.md)
- [项目访问令牌](../../project/settings/project_access_tokens.md)
- [群组访问令牌](../../group/settings/group_access_tokens.md)
- [GitLab CLI](https://gitlab.cn/docs/cli/)

对于基于令牌的身份验证方法，所需的最低范围：

- 对于读取（拉取）访问，必须为 `read_registry`
- 对于写入（推送）访问，必须为 `write_registry` 和 `read_registry`

> [!note]
> 管理员模式不适用于向容器镜像仓库进行身份验证。如果您是启用了管理员模式的管理员，
> 并且创建了没有 `admin_mode` 范围的个人访问令牌，
> 即使启用了管理员模式，该令牌也能正常工作。有关更多信息，请参阅
> [管理员模式](../../../administration/settings/sign_in_restrictions.md#admin-mode)。

<a id="authenticate-with-username-and-password"></a>

## 使用用户名和密码进行身份验证

> [!note]
> 如果您已在账户上启用[双因素身份验证 (2FA)](../../profile/account/two_factor_authentication.md)
> （包括电子邮件 OTP），则必须[使用令牌进行身份验证](#authenticate-with-a-token)。

要使用您的用户名和密码进行身份验证，请运行 `docker login` 命令：

```shell
docker login registry.example.com -u <username> -p <password>
```

出于安全原因，建议使用 `--password-stdin` 标志而不是 `-p`：

```shell
echo "<password>" | docker login registry.example.com -u <username> --password-stdin
```

<a id="authenticate-with-a-token"></a>

## 使用令牌进行身份验证

要使用令牌进行身份验证，请运行 `docker login` 命令：

```shell
TOKEN=<token>
echo "$TOKEN" | docker login registry.example.com -u <username> --password-stdin
```

身份验证后，客户端会缓存凭据。后续操作会发出授权请求，返回 JWT 令牌，该令牌仅被授权执行指定操作。令牌的有效期：

- 在极狐GitLab 私有化部署上，[默认为 5 分钟](../../../administration/packages/container_registry.md#increase-token-duration)
- 在 JihuLab.com 上为 15 分钟

<a id="use-gitlab-cicd-to-authenticate"></a>

## 使用极狐GitLab CI/CD 进行身份验证

要使用 CI/CD 向容器镜像仓库进行身份验证，您可以使用：

- `CI_REGISTRY_USER` 和 `CI_REGISTRY_PASSWORD` CI/CD 变量。

  `CI_REGISTRY_USER` 包含一个作业级别的用户，该用户对容器镜像仓库具有读写访问权限，
  而 `CI_REGISTRY_PASSWORD` 保存其自动创建的密码。

  ```shell
  echo "$CI_REGISTRY_PASSWORD" | docker login $CI_REGISTRY -u $CI_REGISTRY_USER --password-stdin
  ```

- 一个 [CI 作业令牌](../../../ci/jobs/ci_job_token.md)。

  此令牌对运行作业的项目容器镜像仓库具有读取（拉取）和写入（推送）访问权限。
  [CI/CD 作业令牌允许名单](../../../ci/jobs/ci_job_token.md#control-job-token-access-to-your-project)控制对其他项目镜像仓库的访问。

  ```shell
  echo "$CI_JOB_TOKEN" | docker login $CI_REGISTRY -u $CI_REGISTRY_USER --password-stdin
  ```

  您还可以使用 `gitlab-ci-token` 方案：

  ```shell
  echo "$CI_JOB_TOKEN" | docker login $CI_REGISTRY -u gitlab-ci-token --password-stdin
  ```

- 一个 [极狐GitLab 部署令牌](../../project/deploy_tokens/_index.md#gitlab-deploy-token)，其最低范围为：
  - 对于读取（拉取）访问，为 `read_registry`。
  - 对于写入（推送）访问，为 `read_registry` 和 `write_registry`。

  ```shell
  echo "$CI_DEPLOY_PASSWORD" | docker login $CI_REGISTRY -u $CI_DEPLOY_USER --password-stdin
  ```

- 一个个人访问令牌，其最低范围为：
  - 对于读取（拉取）访问，为 `read_registry`。
  - 对于写入（推送）访问，为 `read_registry` 和 `write_registry`。

  ```shell
  echo "<access_token>" | docker login $CI_REGISTRY -u <username> --password-stdin
  ```

<a id="troubleshooting"></a>

## 故障排除

<a id="error-docker-login-command-fails-with-access-forbidden"></a>

### 错误：`docker login` 命令失败并显示 `access forbidden`

容器镜像仓库会将极狐GitLab API URL 返回给 Docker 客户端
以验证凭据。Docker 客户端使用基本身份验证，因此请求包含
`Authorization` 请求头。如果发送到
镜像仓库配置中 `token_realm` 所配置的 `/jwt/auth` 端点的请求中缺少 `Authorization` 请求头，
您会收到 `access forbidden` 错误消息。

例如：

```plaintext
> docker login gitlab.example.com:4567

Username: user
Password:
Error response from daemon: Get "https://gitlab.company.com:4567/v2/": denied: access forbidden
```

要避免此错误，请确保 `Authorization` 请求头未被从请求中剥离。例如，极狐GitLab 前面的代理可能会重定向到 `/jwt/auth` 端点。

有关 Docker 客户端凭据验证的更多信息，请参阅[容器镜像仓库架构](../../../administration/packages/container_registry.md#container-registry-architecture)。

<a id="error-docker-login-fails-with-an-authentication-error"></a>

### 错误：`docker login` 因身份验证错误而失败

当极狐GitLab 拒绝 `docker login` 请求时，Docker 客户端会显示一个包含错误代码和消息的 JSON 错误信封。

要解决该错误，请识别错误代码并按照说明操作：

- `UNAUTHORIZED` (`401`)：极狐GitLab 无法验证凭据。要解决：
  - 确认密码或令牌正确且未过期。
  - 确认个人访问令牌或部署令牌具有用于拉取访问的 `read_registry` 范围，
    或具有用于推送访问的 `read_registry` 和 `write_registry` 范围。
  - 如果账户使用双因素身份验证，请使用令牌而不是密码进行身份验证。有关更多信息，请参阅[使用令牌进行身份验证](#authenticate-with-a-token)。
- `DENIED` (`403`)：极狐GitLab 拒绝访问。检查消息：
  - `access forbidden`：凭据有效，但不授予镜像仓库访问权限。确认
    令牌具有 `read_registry` 范围（对于推送访问，还需具有 `write_registry`），并且
    您的角色允许访问项目的镜像仓库。
  - `Pushing to protected repository path forbidden`：目标路径受
    容器镜像仓库保护规则保护。
  - `Access denied: too many failed authentication attempts from this network`：滥用
    保护已阻止您的网络。请等待封锁解除，或从
    其他网络重试。
  - `Access denied: too many distinct sources for this account`：该账户曾从
    过多 IP 地址使用。请检查该账户的使用位置，然后合并或错开
    请求。
- `UNSUPPORTED` (`404`)：极狐GitLab 无法识别请求的身份验证服务。要解决：
  - 验证镜像仓库令牌服务配置是否正确。

如果 Docker 客户端反而报告 `unexpected end of JSON input`，则响应体为空或包含无效的 JSON：

<a id="error-unexpected-end-of-json-input"></a>

### 错误：`unexpected end of JSON input`

当极狐GitLab 前面的代理或负载均衡器剥离响应体时，您可能会收到以下错误：

```plaintext
Error response from daemon: error parsing HTTP <status> response body: unexpected end of JSON input: ""
```

要解决此问题，请检查 Docker 客户端和极狐GitLab 之间的请求路径。

<a id="error-unauthorized-authentication-required-when-pushing-large-images"></a>

### 错误：推送大型镜像时出现 `unauthorized: authentication required`

推送大型镜像时，您可能会看到类似如下的身份验证错误：

```shell
docker push gitlab.example.com/myproject/docs:latest
The push refers to a repository [gitlab.example.com/myproject/docs]
630816f32edb: Preparing
530d5553aec8: Preparing
...
4b0bab9ff599: Waiting
d1c800db26c7: Waiting
42755cf4ee95: Waiting
unauthorized: authentication required
```

当您的身份验证令牌在镜像推送完成之前过期时，会发生此错误。默认情况下，极狐GitLab 私有化部署实例上容器镜像仓库的令牌在五分钟后过期。在 JihuLab.com 上，令牌过期时间为 15 分钟。
