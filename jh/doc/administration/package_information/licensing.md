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

## 许可证

极狐GitLab 本身采用 MIT 许可证，而 Linux 软件包的源代码采用 Apache-2.0 许可证。

<a id="license-file-location"></a>

## 许可证文件位置

从 8.11 版本开始，Linux 软件包中包含该软件包内所有软件的许可证信息。

安装该软件包后，每个单独捆绑库的许可证可在 `/opt/gitlab/LICENSES` 目录中找到。

此外还有一个 `LICENSE` 文件，其中汇总了所有许可证。该汇总许可证可在 `/opt/gitlab/LICENSE` 文件中找到。

从 9.2 版本开始，Linux 软件包随附一个 `dependency_licenses.json` 文件，其中包含所有捆绑软件的版本和许可证信息，包括软件库、Rails 应用使用的 Ruby gem，以及前端组件所需的 JavaScript 库。由于该文件采用 JSON 格式，极狐GitLab 可以解析该文件并将其用于自动检查或验证。该文件位于
`/opt/gitlab/dependency_licenses.json`。

从 11.3 版本开始，我们还提供了在线许可证信息，网址为：<https://gitlab-org.gitlab.io/omnibus-gitlab/licenses.html>

<a id="checking-licenses"></a>

## 检查许可证

Linux 软件包由许多软件组成，其中包含的代码受许多不同许可证的约束。这些许可证按前述方式提供并汇总。

从 8.13 版本开始，极狐GitLab 在 Linux 软件包安装过程中增加了一个步骤。`license_check` 步骤会调用 `lib/gitlab/tasks/license_check.rake`，该脚本会将汇总的 `LICENSE` 文件与脚本顶部数组中列出的当前已批准和有疑问的许可证列表进行比对。对于属于 Linux 软件包的每个软件，该脚本会输出 `Good`、`Unknown` 或 `Check` 之一。

- `Good`：表示该许可证已批准用于极狐GitLab 和 Linux 软件包中的所有使用类型。
- `Unknown`：表示该许可证未在“good”或“bad”列表中识别出来，
  应立即审查其使用影响。
- `Check`：表示该许可证可能与极狐GitLab 本身不兼容，
  因此应检查其在 Linux 软件包中的使用方式，以确保合规。

该列表来源于 GitLab 关于许可的开发文档。不过，由于 Linux 软件包的性质，这些许可证的适用方式可能有所不同，例如 `git` 和 `rsync`。请参阅 [GNU 许可证常见问题解答](https://www.gnu.org/licenses/gpl-faq.en.html#MereAggregation)

<a id="license-acknowledgments"></a>

## 许可证致谢

<a id="libjpeg-turbo---bsd-3-clause-license"></a>

### libjpeg-turbo - BSD 3-clause 许可证

本软件部分基于 Independent JPEG Group 的工作成果。

<a id="trademark-usage"></a>

## 商标使用

在极狐GitLab 文档中，可能会提及第三方技术和/或第三方实体的商标。提及第三方技术和/或实体仅用于举例说明极狐GitLab 软件如何与此类第三方技术交互或结合使用。所有商标、材料、文档及其他知识产权均归相应第三方所有。

<a id="trademark-requirements"></a>

### 商标要求

使用 GitLab 商标必须遵守我们指南中规定的标准（该指南会不时更新）。
CHEF® 及所有 Chef 商标归 Progress Software Corporation 所有，必须按照 [Progress Software 商标使用政策](https://www.progress.com/legal/trademarks) 使用。

在文档中使用 GitLab 或第三方商标时，请在首次出现时包含 (R) 符号，例如“Chef(R) 用于配置……”。后续出现时可省略该符号。

如果商标所有者要求特定的声明或商标要求，则应在上述内容中说明该声明或要求。
