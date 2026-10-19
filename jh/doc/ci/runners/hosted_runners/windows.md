---
stage: Production Engineering
group: Runners Platform
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: Windows 上的托管 Runner
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com
- Status: 测试版

{{< /details >}}

Windows 上的托管 Runner 通过在 Google Cloud Platform 上启动虚拟机来自动扩缩。此解决方案使用由 GitLab 为[自定义执行器](https://gitlab.cn/docs/runner/executors/custom/)开发的[自动扩缩驱动程序](https://gitlab.com/gitlab-org/ci-cd/custom-executor-drivers/autoscaler/-/blob/main/docs/README.md)。Windows 上的托管 Runner 处于 [测试版](../../../policy/development_stages_support.md#beta) 阶段。

GitLab 持续迭代，以使 Windows Runner 达到稳定状态并[正式发布](../../../policy/development_stages_support.md#generally-available)。您可以在[相关史诗](https://gitlab.com/groups/gitlab-org/-/epics/2162)中关注实现此目标的工作进展。

<a id="machine-types-available-for-windows"></a>

## 适用于 Windows 的机器类型

极狐GitLab 为 Windows 上的托管 Runner 提供以下机器类型。

| Runner 标签                  | vCPU | 内存 | 存储 |
| --------------------------- | ----- | ------ | ------- |
| `saas-windows-medium-amd64` | 2     | 7.5 GB | 75 GB   |

<a id="supported-windows-versions"></a>

## 支持的 Windows 版本

Windows Runner 虚拟机实例不使用极狐GitLab Docker 执行器。这意味着您无法在流水线配置中指定 [`image`](../../yaml/_index.md#image) 或 [`services`](../../yaml/_index.md#services)。

镜像构建运行时会安装最新的 Docker 版本，您可以在 shell Runner 作业中使用原生的 Docker 命令。

您可以在以下 Windows 版本之一中执行作业：

| 版本      | 状态 |
|--------------|--------|
| Windows 2022 | `GA`   |

<a id="available-runtimes"></a>

## 可用的运行时

以下文件列出了可用的预装软件：

- [Chocolatey](https://gitlab.com/gitlab-org/ci-cd/shared-runners/images/gcp/windows-containers/-/blob/main/cookbooks/chocolatey/recipes/default.rb)，可用于执行其他安装。
- [Git、Git LFS 和 GitLab Runner](https://gitlab.com/gitlab-org/ci-cd/shared-runners/images/gcp/windows-containers/-/tree/main/cookbooks/gitlab-runner-dependencies/recipes)
- 预装的开发工具：
  - [Docker](https://gitlab.com/gitlab-org/ci-cd/shared-runners/images/gcp/windows-containers/-/blob/main/cookbooks/preinstalled-software/recipes/docker.rb)
  - [.NET Core SDK 3.1、Ruby、Go、Node.js、OpenJDK、Python3](https://gitlab.com/gitlab-org/ci-cd/shared-runners/images/gcp/windows-containers/-/blob/main/cookbooks/preinstalled-software/recipes/languages.rb)
  - [7-Zip、Wget、curl、jq、Docker Compose、NuGet CLI、CMake、GitLab CLI (glab)](https://gitlab.com/gitlab-org/ci-cd/shared-runners/images/gcp/windows-containers/-/blob/main/cookbooks/preinstalled-software/recipes/utils.rb)
  - [Visual C 运行时](https://gitlab.com/gitlab-org/ci-cd/shared-runners/images/gcp/windows-containers/-/blob/main/cookbooks/preinstalled-software/recipes/vcpkg.rb)。版本请参见链接文件。
  - [Visual Studio Build Tools](https://gitlab.com/gitlab-org/ci-cd/shared-runners/images/gcp/windows-containers/-/blob/main/cookbooks/preinstalled-software/recipes/visual-studio-build-tools.rb)。版本请参见链接文件。

<a id="net-runtimes"></a>

## .NET 运行时

已安装的 .NET Core SDK 版本和 Visual Studio Build Tools 的具体版本共同决定了预装的 .NET 运行时版本。

以下代码按计划在 [极狐GitLab CI 上的 PowerShell 流水线](https://gitlab.com/guided-explorations/microsoft/powershell/powershell-pipelines-on-gitlab-ci/-/pipelines)中运行，并生成此示例列表：

对于全部三种运行时（`Microsoft.AspNetCore.App`、`Microsoft.NETCore.App`、`Microsoft.WindowsDesktop.App`），可用版本为：

- 3.1.32
- 8.0.24
- 9.0.13

.NET Framework 版本为 4.8.04161。

要了解当前状态，请运行以下代码，或查看 [极狐GitLab CI 上的 PowerShell 流水线](https://gitlab.com/guided-explorations/microsoft/powershell/powershell-pipelines-on-gitlab-ci/-/pipelines)的近期日志：

```powershell

Write-Host "=== Modern .NET (Core 3.1, 5, 6, 7, 8+) runtimes ===" -ForegroundColor Cyan
if (Get-Command dotnet -ErrorAction SilentlyContinue) {
    dotnet --list-runtimes
} else {
    Write-Host "Not present"
}

Write-Host "`n=== .NET Framework versions ===" -ForegroundColor Cyan
$ndp = "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP"
if (Test-Path $ndp) {
    $found = Get-ChildItem $ndp -Recurse |
        Get-ItemProperty -Name Version, Release -ErrorAction SilentlyContinue |
        Where-Object { $_.Version -and $_.PSChildName -notmatch '^S' } |
        Select-Object @{n='Component';e={$_.PSChildName}}, Version, Release |
        Sort-Object Version -Unique
    if ($found) { $found } else { Write-Host "Not present" }
} else {
    Write-Host "Not present"
}
```

<a id="docker-runtimes"></a>

## Docker 运行时

镜像构建运行时会安装最新的 Docker 版本（截至镜像构建日期），您可以在 shell Runner 作业中使用原生的 Docker 命令。

在运行 Docker 命令之前，请使用以下代码启动 Docker 服务。

要了解版本，请运行以下代码，或查看 [极狐GitLab CI 上的 PowerShell 流水线](https://gitlab.com/guided-explorations/microsoft/powershell/powershell-pipelines-on-gitlab-ci/-/pipelines)中的流水线：

```powershell
      $svc = Get-Service -Name docker -ErrorAction SilentlyContinue

      if ($null -eq $svc) {
          Write-Host "Docker service is not installed."
      }
      else {
          if ($svc.Status -eq 'Stopped') {
              Write-Host "Docker service is stopped; starting it..."
              Start-Service -Name docker
              (Get-Service -Name docker).WaitForStatus('Running', '00:00:30')
              Write-Host "Docker service is now $((Get-Service -Name docker).Status)."
          }
          else {
              Write-Host "Docker service is already $($svc.Status); no action taken."
          }

          Write-Host "`n=== Docker client and service version ==="
          if ((Get-Service -Name docker).Status -eq 'Running') {
              docker info
              docker version
          }
      }
```

<a id="supported-shell"></a>

## 支持的 shell

Windows 上的托管 Runner 将 PowerShell 配置为 shell。因此，您的 `.gitlab-ci.yml` 文件的 `script` 部分需要使用 PowerShell 命令。

<a id="elevated-permissions"></a>

## 提升的权限

JihuLab.com 上 Windows 的托管 Runner 以提升的管理员进程运行 CI/CD 作业。此进程允许您在作业执行前安装其他软件或配置操作系统。此权限级别是可接受的，因为 Runner 会为每个单独的作业创建新的虚拟机，并在作业完成后将其丢弃。此过程在安全性和处置方面与容器作业的工作方式基本相同。

<a id="example-gitlab-ciyml-file"></a>

## 示例 `.gitlab-ci.yml` 文件

使用此示例 `.gitlab-ci.yml` 文件开始使用 Windows 上的托管 Runner：

```yaml
.windows_job:
  tags:
    - saas-windows-medium-amd64
  before_script:
    - Set-Variable -Name "time" -Value (date -Format "%H:%m")
    - echo ${time}
    - echo "started by ${GITLAB_USER_NAME} / @${GITLAB_USER_LOGIN}"

build:
  extends:
    - .windows_job
  stage: build
  script:
    - echo "running scripts in the build job"

test:
  extends:
    - .windows_job
  stage: test
  script:
    - echo "running scripts in the test job"
```

<a id="known-issues"></a>

## 已知问题

- 有关测试版功能支持的更多信息，请参见 [测试版](../../../policy/development_stages_support.md#beta)。
- 新 Windows 虚拟机 (VM) 的平均预配时间为五分钟，因此在测试版期间，您可能会注意到 Windows Runner 集群上的构建启动速度较慢。未来版本中提议更新自动扩缩器以启用虚拟机预配。此更新旨在显著缩短在 Windows 集群上预配虚拟机所需的时间。更多信息，请参见 [议题 32](https://gitlab.com/gitlab-org/ci-cd/custom-executor-drivers/autoscaler/-/issues/32)。
- Windows Runner 集群可能偶尔因维护或更新而不可用。
- 作业处于待处理状态的时间可能比 Linux Runner 更长。
- 我们可能会引入破坏性变更，这需要更新使用 Windows Runner 集群的流水线。
