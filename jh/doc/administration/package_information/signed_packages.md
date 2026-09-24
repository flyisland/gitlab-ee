---
stage: GitLab Delivery
group: Build
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 软件包签名
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: 私有化部署

{{< /details >}}

<!-- vale gitlab_base.SubstitutionWarning = NO -->

极狐GitLab 生产的 Linux 软件包是用 [Omnibus](https://github.com/chef/omnibus) 创建的，极狐GitLab 在[自己的 fork](https://gitlab.com/gitlab-org/omnibus) 中增加了使用 `debsigs` 进行 DEB 签名的功能。

<!-- vale gitlab_base.SubstitutionWarning = YES -->

结合已有的 RPM 签名功能，这一补充使极狐GitLab 可以为所有使用 DEB 或 RPM 的受支持发行版提供签名软件包。

这些软件包是在交付到 <https://packages.gitlab.cn> 之前，由极狐GitLab CI 流程生成的，具体可见 [`omnibus-gitlab` 项目](https://gitlab.com/gitlab-org/omnibus-gitlab/blob/master/.gitlab-ci.yml)，以确保软件包在交付给社区之前没有被篡改。

<a id="gnupg-public-keys"></a>

## GnuPG 公钥

所有软件包均采用适合其格式的方法，使用 [GnuPG](https://www.gnupg.org/) 进行签名。用于签名这些软件包的密钥可以在 [MIT PGP 公钥服务器](https://pgp.mit.edu) 上找到，ID 为 [`0x3cfcf9baf27eab47`](https://pgp.mit.edu/pks/lookup?op=vindex&search=0x3CFCF9BAF27EAB47)。

<a id="verifying-signatures"></a>

## 验证签名

关于如何验证极狐GitLab 软件包签名的信息，请参阅[软件包签名](https://gitlab.cn/docs/omnibus/update/package_signatures/)。

<a id="gpg-signature-management"></a>

## GPG 签名管理

关于极狐GitLab 如何管理用于软件包签名的 GPG 密钥，请参阅 [runbooks](https://gitlab.com/gitlab-com/runbooks/-/blob/master/docs/packaging/manage-package-signing-keys.md)。