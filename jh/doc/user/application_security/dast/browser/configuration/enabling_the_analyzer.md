---
type: reference, howto
stage: Application Security Testing
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 启用分析器
---

要运行 DAST 扫描：

- 阅读运行 DAST 扫描的[要求](../_index.md)条件。
- 在你的 CI/CD 流水线中创建一个 [DAST 任务](#create-a-dast-cicd-job)。
- 如果你的应用程序需要，以用户身份进行[认证](authentication.md)。

DAST 任务在 DAST CI/CD 模板文件中由 `image` 关键字定义的 Docker 容器中运行。
当你运行该任务时，DAST 会连接到由 `DAST_TARGET_URL` 变量指定的目标应用程序，
并使用嵌入式浏览器爬取该站点。

<a id="create-a-dast-cicd-job"></a>

## 创建 DAST CI/CD 任务

{{< history >}}

- 该模板在 极狐GitLab 16.0 中更新至 DAST_VERSION: 4。
- 该模板在 极狐GitLab 17.0 中更新至 DAST_VERSION: 5。
- 该模板在 极狐GitLab 18.0 中更新至 DAST_VERSION: 6。

{{< /history >}}

要将 DAST 扫描添加到你的应用程序，请使用在 极狐GitLab DAST CI/CD 模板文件中定义的 DAST 任务。
模板的更新会随 极狐GitLab 升级提供，让你能够受益于任何改进和新增内容。

前提条件：

- 对项目具有开发者、维护者或所有者角色。

要创建 CI/CD 任务：

1. 在顶部栏上，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **构建** > **流水线编辑器**。

   如果不存在 `.gitlab-ci.yml` 文件，选择 **配置流水线**，然后删除示例内容。
1. 包含适当的 CI/CD 模板：

   - [`DAST.gitlab-ci.yml`](https://jihulab.com/gitlab-cn/gitlab/-/blob/master/lib/gitlab/ci/templates/Security/DAST.gitlab-ci.yml)：
     DAST CI/CD 模板的稳定版本。
   - [`DAST.latest.gitlab-ci.yml`](https://jihulab.com/gitlab-cn/gitlab/-/blob/master/lib/gitlab/ci/templates/Security/DAST.latest.gitlab-ci.yml)：
     DAST 模板的最新版本。

   > [!warning]
   > 模板的最新版本可能包含破坏性变更。除非需要仅在最新模板中提供的功能，否则请使用稳定模板。

1. 将 `dast` 阶段添加到 极狐GitLab CI/CD 阶段配置中。
1. 通过以下方法之一定义 DAST 要扫描的 URL：

   - 设置 `DAST_TARGET_URL` [CI/CD 变量](../../../../../ci/yaml/_index.md#variables)。
     如果设置，该值优先级最高。

   - 在项目根目录的 `environment_url.txt` 文件中添加 URL 适用于在动态环境中测试。
     要在 极狐GitLab CI/CD 流水线期间动态创建的应用程序上运行 DAST，请将应用程序 URL 写入 `environment_url.txt` 文件。
     DAST 会自动读取该 URL 来查找扫描目标。

     你可以在 [我们的 Auto DevOps CI YAML 示例](https://jihulab.com/gitlab-cn/gitlab/-/blob/master/lib/gitlab/ci/templates/Jobs/Deploy.gitlab-ci.yml) 中查看示例。

例如：

```yaml
stages:
  - dast

include:
  - template: Security/DAST.gitlab-ci.yml

dast:
  variables:
    DAST_TARGET_URL: "https://example.com"
    DAST_AUTH_USERNAME: "test_user"
    DAST_AUTH_USERNAME_FIELD: "name:user[login]"
    DAST_AUTH_PASSWORD_FIELD: "name:user[password]"
```

你必须定义 `DAST_TARGET_URL` 或创建 `environment_url.txt` 文件，DAST 任务才能成功运行。

<a id="network-connectivity"></a>

### 网络连接

你的 runner 必须能够连接到目标应用程序 URL。如果应用程序使用非标准端口，请将其包含在 URL 中。

<a id="after-you-enable-the-analyzer"></a>

## 启用分析器后

当流水线运行时，DAST 任务会：

1. 连接到你的应用程序。
1. 启动 Chromium 浏览器爬取站点。
1. 对发现的页面执行安全检查。

<a id="configure-authentication"></a>

### 配置认证

如果你的应用程序需要用户登录，请配置 DAST 在扫描前进行认证。如果没有认证，DAST 只能扫描公开可访问的页面。

要配置认证，请参见[认证](authentication.md)。

<a id="verify-crawl-coverage"></a>

### 验证爬取覆盖率

首次扫描完成后，请验证 DAST 是否正确发现了你的应用程序页面。

要可视化爬取结果：

- 使用 `DAST_CRAWL_GRAPH` [变量](variables.md) 启用爬取图。
- 查看图表以识别任何缺失的页面或导航路径。
- 如果缺少页面，请调整你的[扫描范围](customize_settings.md#managing-scope)。

<a id="troubleshooting"></a>

### 疑难解答

如果遇到问题：

- 对于设置问题，请参见[设置 DAST](../troubleshooting.md#setting-up-dast)。
- 对于详细的诊断信息，请参见[诊断日志](../troubleshooting.md#diagnostic-logs)。
- 对于连接故障排除，请参见 [runner 无法连接到目标应用程序](../troubleshooting.md#runner-cannot-connect-to-target-application)。