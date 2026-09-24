---
stage: GitLab Delivery
group: Build
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 软件包许可
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

<a id="license"></a>

## 许可

尽管极狐GitLab 本身基于 MIT 许可，Linux 软件包源码根据 Apache-2.0 许可发布。

<a id="license-file-location"></a>

## 许可证文件位置

从 8.11 版本开始，Linux 软件包包含捆绑在包中的所有软件的许可信息。

安装软件包后，每个单独捆绑库的许可证可以在 `/opt/gitlab/LICENSES` 目录中找到。

还有一个 `LICENSE` 文件汇总了所有许可证。此汇总许可证可以在 `/opt/gitlab/LICENSE` 文件中找到。

从 9.2 版本开始，Linux 软件包附带了 `dependency_licenses.json` 文件，其中包含所有捆绑软件的版本和许可信息，包括软件库、Rails 应用程序使用的 Ruby gems 以及前端组件所需的 JavaScript 库。由于采用 JSON 格式，极狐GitLab 可以解析此文件并将其用于自动检查或验证。该文件位于 `/opt/gitlab/dependency_licenses.json`。

从 11.3 版本开始，我们还把许可证信息发布到了网上，地址为：<https://gitlab-org.gitlab.io/omnibus-gitlab/licenses.html>

<a id="checking-licenses"></a>

## 检查许可证

Linux 软件包由许多软件构成，包含受多种不同许可证约束的代码。这些许可证的提供和汇总方式如前所述。

从 8.13 版本开始，极狐GitLab 在 Linux 软件包安装过程中增加了额外步骤。`license_check` 步骤调用 `lib/gitlab/tasks/license_check.rake`，它会将汇总的 `LICENSE` 文件与脚本顶部数组中列出的当前已批准许可证和有疑问许可证清单进行比对。该脚本会为 Linux 软件包中的每个软件组件输出 `良好`、`未知` 或 `检查` 之一。

- `良好`：表示该许可证适用于极狐GitLab 和 Linux 软件包中的所有使用场景。
- `未知`：表示该许可证不在“良好”或“不良”列表中，应立即审查其使用影响。
- `检查`：表示该许可证可能与极狐GitLab 本身不兼容，因此应检查其在 Linux 软件包中的使用方式，以确保合规性。

此列表源自极狐GitLab 开发文档中关于许可的规定。然而，由于 Linux 软件包的性质，这些许可证的适用方式可能有所不同。例如 `git` 和 `rsync`。请参见 [GNU 许可证常见问题解答](https://www.gnu.org/licenses/gpl-faq.en.html#MereAggregation)。

<a id="license-acknowledgments"></a>

## 许可证致谢

<a id="libjpeg-turbo---bsd-3-clause-license"></a>

### libjpeg-turbo - BSD 3 条款许可证

本软件部分基于 Independent JPEG Group 的工作。

<a id="trademark-usage"></a>

## 商标使用

在极狐GitLab 文档中，可能会引用第三方技术和/或第三方实体的商标。引用第三方技术和/或实体仅用于说明极狐GitLab 软件如何与此类第三方技术交互或结合使用的示例。
所有商标、材料、文档和其他知识产权均属于任何/所有此类第三方。

<a id="trademark-requirements"></a>

### 商标要求

极狐GitLab 商标的使用必须遵守我们指南（随时更新）中规定的标准。
CHEF® 及所有 Chef 标志归 Progress Software Corporation 所有，必须按照 [Progress Software 商标使用政策](https://www.progress.com/legal/trademarks) 使用。

在文档中首次使用极狐GitLab 或第三方商标时，应包含 (R) 符号，例如“使用 Chef(R) 进行配置……”。后续出现时可省略该符号。

如果商标所有者要求特殊的声明或商标使用要求，应当在上文中注明此类声明或要求。

