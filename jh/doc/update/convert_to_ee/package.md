---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.jihulab.com/handbook/product/ux/technical-writing/#assignments>
title: 将 Linux 软件包基础版实例转换为企业版
---

{{< details >}}

- 层级：基础版、专业版、旗舰版
- 产品：私有化部署

{{< /details >}}

你可以将现有的 Linux 软件包实例从基础版 (CE) 转换为企业版 (EE)。转换时，只需在基础版实例上安装企业版的 Linux 软件包即可。

CE 转 EE 不需要版本完全一致。例如，从 CE 18.0 转换到 EE 18.1 是可行的。但**推荐**使用相同版本进行升级（例如 CE 18.1 到 EE 18.1）。

> [!warning]
> 从 CE 转换为 EE 后，如果还打算再次使用 EE，就不要回退到 CE。回退到 CE 可能导致[数据库问题](package_troubleshooting.md#500-error-when-accessing-project-repository-settings)，届时可能需要支持团队介入处理。

<a id="convert-from-ce-to-ee"></a>

## 从基础版转换到企业版

要将 Linux 软件包基础版实例转换为企业版：

1. 创建[极狐GitLab 备份](../../administration/backup_restore/backup_gitlab.md)。
1. 查看已安装的极狐GitLab 版本：

   {{< tabs >}}

   {{< tab title="Debian/Ubuntu" >}}

   ```shell
   sudo apt-cache policy gitlab-ce | grep Installed
   ```

   记下返回的版本号。

   {{< /tab >}}

   {{< tab title="CentOS/RHEL" >}}

   ```shell
   sudo rpm -q gitlab-ce
   ```

   记下返回的版本号。

   {{< /tab >}}

   {{< /tabs >}}

1. 添加 `gitlab-ee` [Apt 或 Yum 仓库](https://packages.jihulab.com/ui/browse/gitlab/gitlab-jh)。以下命令会检测你的操作系统版本并自动配置对应的仓库。

   {{< tabs >}}

   {{< tab title="Debian/Ubuntu" >}}

   ```shell
   curl --silent "https://packages.jihulab.com/install/repositories/gitlab/gitlab-jh/script.deb.sh" | sudo bash
   ```

   {{< /tab >}}

   {{< tab title="CentOS/RHEL" >}}

   ```shell
   curl --silent "https://packages.jihulab.com/install/repositories/gitlab/gitlab-jh/script.rpm.sh" | sudo bash
   ```

   {{< /tab >}}

   {{< /tabs >}}

   如果想要使用 `dpkg` 或 `rpm` 而非 `apt-get` 或 `yum`，请参阅[使用下载的软件包升级](../package/_index.md#upgrade-with-a-downloaded-package)。

1. 安装 `gitlab-ee` Linux 包。安装过程中会自动卸载你极狐GitLab 上的 `gitlab-ce` 包。

   {{< tabs >}}

   {{< tab title="Debian/Ubuntu" >}}

   ```shell
   ## 确保仓库是最新的
   sudo apt-get update

   ## 使用第 1 步中记下的版本号安装软件包
   sudo apt-get install gitlab-ee=18.1.0-jh.0

   ## 重新配置极狐GitLab
   sudo gitlab-ctl reconfigure
   ```

   {{< /tab >}}

   {{< tab title="CentOS/RHEL" >}}

   ```shell
   ## 使用第 1 步中记下的版本号安装软件包
   sudo yum install gitlab-ee-18.1.0-jh.0.el9.x86_64

   ## 重新配置极狐GitLab
   sudo gitlab-ctl reconfigure
   ```

   {{< /tab >}}

   {{< /tabs >}}

1. [上传许可证](../../administration/license.md)以激活企业版。
1. 确认极狐GitLab 运行正常之后，可以删除旧的 Community Edition 仓库：

   {{< tabs >}}

   {{< tab title="Debian/Ubuntu" >}}

   ```shell
   sudo rm /etc/apt/sources.list.d/gitlab_gitlab-ce.list
   ```

   {{< /tab >}}

   {{< tab title="CentOS/RHEL" >}}

   ```shell
   sudo rm /etc/yum.repos.d/gitlab_gitlab-ce.repo
   ```

   {{< /tab >}}

   {{< /tabs >}}

1. （可选）[配置 Elasticsearch 集成](../../integration/advanced_search/elasticsearch.md)，以便启用[高级搜索](../../user/search/advanced_search.md)。

就这样！你现在可以使用极狐GitLab 企业版了！若要升级到更新的版本，请参考[升级 Linux 软件包实例](_index.md)。

<a id="revert-back-to-ce"></a>

## 回退到基础版

关于将企业版实例回退到基础版的信息，请参阅[如何从企业版回退到基础版](revert.md)。