---
stage: Create
group: Remote Development
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
description: Create the infrastructure needed to support GitLab Workspaces for on-demand, cloud-based development environments.
title: '教程：在 AWS 上设置工作空间基础设施'
---

<!-- vale gitlab_base.FutureTense = NO -->

本教程将指导你使用 [OpenTofu](https://opentofu.org/)（一个通过基础设施即代码（IaC）实现的 Terraform 开源分支）在 AWS 上完成极狐GitLab 工作空间基础设施的设置。

<a id="before-you-begin"></a>

## 准备工作

要跟随本教程，你必须具备：

- 一个 Amazon Web Services (AWS) 账户。
- 一个用于工作空间环境的域名。

要设置极狐GitLab 工作空间基础设施：

1. [派生仓库](#fork-the-repository)
1. [设置 AWS 凭证](#set-up-aws-credentials)
1. [准备域名和证书](#prepare-domain-and-certificates)
1. [创建所需的密钥](#create-required-keys)
1. [创建极狐GitLab Kubernetes 代理令牌](#create-a-gitlab-agent-for-kubernetes-token)
1. [配置极狐GitLab OAuth](#configure-gitlab-oauth)
1. [配置 CI/CD 变量](#configure-cicd-variables)
1. [更新极狐GitLab Kubernetes 代理配置](#update-the-gitlab-agent-for-kubernetes-configuration)
1. [运行流水线](#run-the-pipeline)
1. [配置 DNS 记录](#configure-dns-records)
1. [授权代理](#authorize-the-agent)
1. [创建工作空间并验证设置](#create-a-workspace-and-verify-setup)

<a id="fork-the-repository"></a>

## 派生仓库

首先，你需要创建基础设施设置仓库的副本，以便为你的环境进行配置。

> [!note]
> 无法从个人命名空间中的项目创建工作空间。请将仓库派生到顶级群组或子群组。

要派生仓库：

1. 转到 [工作空间基础设施设置 AWS](https://jihulab.com/gitlab-cn/workspaces/examples/workspaces-infrastructure-setup-aws) 仓库。
1. [创建派生](../project/repository/forking_workflow.md#create-a-fork)。

<a id="set-up-aws-credentials"></a>

## 设置 AWS 凭证

接下来，在 AWS 中设置必要的权限，以便基础设施能够正确配置。

要设置 AWS 凭证：

1. 创建一个 [IAM 用户](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users.html) 或 [IAM 角色](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles.html)。
1. 分配以下权限：

   ```json
   {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Sid": "VisualEditor0",
         "Effect": "Allow",
         "Action": [
           "ec2:*",
           "eks:*",
           "elasticloadbalancing:*",
           "autoscaling:*",
           "cloudwatch:*",
           "logs:*",
           "kms:DescribeKey",
           "kms:TagResource",
           "kms:UntagResource",
           "kms:ListResourceTags",
           "kms:CreateKey",
           "kms:CreateAlias",
           "kms:ListAliases",
           "kms:DeleteAlias",
           "iam:AddRoleToInstanceProfile",
           "iam:AttachRolePolicy",
           "iam:CreateInstanceProfile",
           "iam:CreateRole",
           "iam:CreateServiceLinkedRole",
           "iam:GetRole",
           "iam:ListAttachedRolePolicies",
           "iam:ListRolePolicies",
           "iam:ListRoles",
           "iam:PassRole",
           "iam:DetachRolePolicy",
           "iam:ListInstanceProfilesForRole",
           "iam:DeleteRole",
           "iam:CreateOpenIDConnectProvider",
           "iam:CreatePolicy",
           "iam:TagOpenIDConnectProvider",
           "iam:GetPolicy",
           "iam:GetPolicyVersion",
           "iam:GetOpenIDConnectProvider",
           "iam:DeleteOpenIDConnectProvider",
           "iam:ListPolicyVersions",
           "iam:DeletePolicy"
         ],
         "Resource": "*"
       }
     ]
   }
   ```

1. 为用户或角色[创建访问密钥](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html)。
1. 保存你的访问密钥 ID 和秘密访问密钥。稍后配置 CI/CD 变量时需要用到它们。

<a id="prepare-domain-and-certificates"></a>

## 准备域名和证书

为了使你的工作空间可访问，你需要一个域名和 TLS 证书来保护连接。

要准备域名和证书：

1. 购买一个域名或使用现有域名用于你的工作空间环境。
1. 为以下内容创建 TLS 证书：
   - 极狐GitLab 工作空间代理域。例如，`workspaces.example.dev`。
   - 极狐GitLab 工作空间代理通配符域。例如，`*.workspaces.example.dev`。

更多信息，请参见[生成 TLS 证书](set_up_gitlab_agent_and_proxies.md#generate-tls-certificates)。

<a id="create-required-keys"></a>

## 创建所需的密钥

现在，你需要为身份验证和 SSH 连接创建安全密钥。

要创建所需的密钥：

1. 生成一个由随机字母、数字和特殊字符组成的签名密钥。例如，运行：

   ```shell
   openssl rand -base64 32
   ```

1. 生成 SSH 主机密钥：

   ```shell
   ssh-keygen -f ssh-host-key -N '' -t rsa
   ```

<a id="create-a-gitlab-agent-for-kubernetes-token"></a>

## 创建极狐GitLab Kubernetes 代理令牌

极狐GitLab Kubernetes 代理将你的 AWS Kubernetes 集群连接到极狐GitLab。

要为代理创建令牌：

1. 转到你的群组。
1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **运维** > **Kubernetes 集群**。
1. 选择 **连接集群**。
1. 输入代理名称并保存以供稍后使用。例如，`gitlab-workspaces-agentk-eks`。
1. 选择 **创建并注册**。
1. 保存令牌和极狐GitLab 中继（KAS）地址以供稍后使用。
1. 选择 **继续**。

<a id="configure-gitlab-oauth"></a>

## 配置极狐GitLab OAuth

接下来，设置 OAuth 身份验证以安全访问工作空间。

要配置极狐GitLab OAuth：

1. 在右上角，选择你的头像。
1. 选择 **编辑个人资料**。
1. 在左侧边栏中，选择 **访问** > **应用**。
1. 向下滚动到 **OAuth 应用**。
1. 选择 **添加新应用**。
1. 更新以下设置：

   - 名称：极狐GitLab 工作空间代理
   - 重定向 URI：例如，`https://workspaces.example.dev/auth/callback`。替换为你自定义的域名。
   - 选中 **机密** 复选框。
   - 范围：`api`、`read_user`、`openid` 和 `profile`。

1. 选择 **保存应用**。
1. 保存 **应用 ID** 和 **密钥** 用于你的 CI/CD 变量。
1. 选择 **继续**。

<a id="configure-cicd-variables"></a>

## 配置 CI/CD 变量

现在，你需要将必要的变量添加到 CI/CD 配置中，以便基础设施流水线可以运行。

要配置 CI/CD 变量：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的项目。
1. 在左侧边栏中，选择 **设置** > **CI/CD**。
1. 展开 **变量**。
1. 在 **项目变量** 部分，添加以下必需的变量：

   | 变量 | 值 |
   |------|-----|
   | `AWS_ACCESS_KEY_ID` | AWS 访问密钥 ID。 |
   | `AWS_SECRET_ACCESS_KEY` | AWS 秘密访问密钥。 |
   | `TF_VAR_agent_token` | 极狐GitLab Kubernetes 代理令牌。 |
   | `TF_VAR_kas_address` | 极狐GitLab 中继（KAS）地址。如果在极狐GitLab 私有化部署实例上，则为必需。例如，`wss://kas.gitlab.com`。 |
   | `TF_VAR_workspaces_proxy_auth_client_id` | OAuth 应用客户端 ID。 |
   | `TF_VAR_workspaces_proxy_auth_client_secret` | OAuth 应用密钥。 |
   | `TF_VAR_workspaces_proxy_auth_redirect_uri` | OAuth 回调 URL。例如，`https://workspaces.example.dev/auth/callback`。 |
   | `TF_VAR_workspaces_proxy_auth_signing_key` | 你生成的签名密钥。 |
   | `TF_VAR_workspaces_proxy_domain` | 工作空间代理的域名。 |
   | `TF_VAR_workspaces_proxy_domain_cert` | 代理域的 TLS 证书。 |
   | `TF_VAR_workspaces_proxy_domain_key` | 代理域的 TLS 密钥。 |
   | `TF_VAR_workspaces_proxy_ssh_host_key` | 你生成的 SSH 主机密钥。 |
   | `TF_VAR_workspaces_proxy_wildcard_domain` | 工作空间的通配符域。 |
   | `TF_VAR_workspaces_proxy_wildcard_domain_cert` | 通配符域的 TLS 证书。 |
   | `TF_VAR_workspaces_proxy_wildcard_domain_key` | 通配符域的 TLS 密钥。 |

1. 可选。添加以下任何变量以自定义你的部署：

   | 变量 | 值 |
   |------|-----|
   | `TF_VAR_region` | AWS 区域。 |
   | `TF_VAR_zones` | AWS 可用区。 |
   | `TF_VAR_name` | 资源名称前缀。 |
   | `TF_VAR_cluster_endpoint_public_access` | 集群端点的公共访问。 |
   | `TF_VAR_cluster_node_instance_type` | Kubernetes 节点的 EC2 实例类型。 |
   | `TF_VAR_cluster_node_count_min` | 工作节点的最小数量。 |
   | `TF_VAR_cluster_node_count_max` | 工作节点的最大数量。 |
   | `TF_VAR_cluster_node_count` | 工作节点的数量。 |
   | `TF_VAR_cluster_node_labels` | 应用于集群节点的标签映射。 |
   | `TF_VAR_agent_namespace` | 代理的 Kubernetes 命名空间。 |
   | `TF_VAR_workspaces_proxy_namespace` | 工作空间代理的 Kubernetes 命名空间。 |
   | `TF_VAR_workspaces_proxy_ingress_class_name` | Ingress 类名称。 |
   | `TF_VAR_ingress_nginx_namespace` | Ingress-NGINX 的 Kubernetes 命名空间。 |

干得好！你已经为基础设施部署配置了所有必要的变量。

<a id="update-the-gitlab-agent-for-kubernetes-configuration"></a>

## 更新极狐GitLab Kubernetes 代理配置

现在，你需要配置极狐GitLab Kubernetes 代理以支持工作空间。

要更新代理配置：

1. 在你的派生仓库中，打开 `.gitlab/agents/gitlab-workspaces-agentk-eks/config.yaml` 文件。

   > [!note]
   > 包含 `config.yaml` 文件的目录必须与你在[创建极狐GitLab Kubernetes 代理令牌](#create-a-gitlab-agent-for-kubernetes-token)步骤中创建的代理名称匹配。

1. 使用以下必需字段更新文件：

   ```yaml
   remote_development:
     enabled: true
     dns_zone: "workspaces.example.dev"  # 替换为你的域名
   ```

   更多配置选项，请参见[工作空间设置](settings.md)。

1. 提交并将这些更改推送到你的仓库。

<a id="run-the-pipeline"></a>

## 运行流水线

是时候部署你的基础设施了。你将运行 CI/CD 流水线以在 AWS 中创建所有必要的资源。

要运行流水线：

1. 在你的极狐GitLab 项目中创建新流水线：
   1. 在左侧边栏中，选择 **构建** > **流水线**。
   1. 选择 **新建流水线** 并再次选择 **新建流水线** 以确认。
1. 验证 `plan` 作业成功，然后手动触发 `apply` 作业。

当 OpenTofu 代码运行时，它会在 AWS 中创建以下资源：

- 一个虚拟私有云（VPC）。
- 一个 Elastic Kubernetes Service（EKS）集群。
- 一个极狐GitLab Kubernetes 代理 Helm 发布。
- 一个极狐GitLab 工作空间代理 Helm 发布。
- 一个 Ingress NGINX Helm 发布。

太棒了！你的基础设施正在部署中。这可能需要一些时间才能完成。

<a id="configure-dns-records"></a>

## 配置 DNS 记录

现在基础设施已部署，你需要配置 DNS 记录以指向你的新环境。

要配置 DNS 记录：

1. 从流水线输出中获取 Ingress-NGINX 负载均衡器地址：

   ```shell
   kubectl get services -n ingress-nginx ingress-nginx-controller
   ```

1. 创建将你的域名指向此地址的 DNS 记录。例如：
   - `workspaces.example.dev` → 负载均衡器 IP 地址
   - `*.workspaces.example.dev` → 负载均衡器 IP 地址

<a id="authorize-the-agent"></a>

## 授权代理

接下来，你将授权极狐GitLab Kubernetes 代理连接到你的极狐GitLab 实例。

要授权代理：

1. 在顶部栏中，选择 **搜索或跳转到** 并找到你的群组。
1. 在左侧边栏中，选择 **设置** > **工作空间**。
1. 在 **群组代理** 部分，选择 **所有代理** 选项卡。
1. 从可用代理列表中，找到状态为 **已阻止** 的代理，然后选择 **允许**。
1. 在确认对话框中，选择 **允许代理**。

<a id="create-a-workspace-and-verify-setup"></a>

## 创建工作空间并验证设置

最后，让我们通过创建一个测试工作空间来确保一切正常工作。

要验证你的工作空间设置：

1. 按照[创建工作空间](configuration.md#create-a-workspace)中的步骤创建新工作空间。
1. 在你的项目中，选择 **代码**。
1. 选择你的工作空间名称。
1. 通过打开 Web IDE、访问终端或对项目文件进行更改来与工作空间交互。

恭喜！你已成功在 AWS 上设置了极狐GitLab 工作空间基础设施。你的用户现在可以为他们的项目创建开发工作空间环境。

如果遇到任何问题，请检查日志以获取更多详细信息，并参考[工作空间故障排查](workspaces_troubleshooting.md)获取指导。

