---
stage: Package
group: Package Registry
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: 构建软件包
---

使用极狐GitLab 软件包仓库安装和构建不同格式的软件包。

## Composer

1. 创建一个名为 `my-composer-package` 的目录，并切换到该目录：

   ```shell
   mkdir my-composer-package && cd my-composer-package
   ```

1. 运行 [`composer init`](https://getcomposer.org/doc/03-cli.md#init) 并回答提示。

   对于命名空间，输入你的唯一[命名空间](../../namespace/_index.md)，例如你的极狐GitLab 用户名或群组名称。

   一个名为 `composer.json` 的文件被创建：

   ```json
   {
     "name": "<namespace>/composer-test",
     "description": "Library XY",
     "type": "library",
     "license": "GPL-3.0-only",
     "authors": [
       {
         "name": "John Doe",
         "email": "john@example.com"
       }
     ],
     "require": {}
   }
   ```

## Conan 1

<a id="install-conan-1"></a>

### 安装 Conan 1

先决条件：

- 你必须安装 Conan 版本 1.x。

按照 [conan.io](https://conan.io/downloads) 上的说明，将 Conan 软件包管理器下载到本地开发环境。

安装完成后，通过运行以下命令验证你可以在终端中使用 Conan：

```shell
conan --version
```

Conan 版本信息将打印在输出中：

```plaintext
Conan version 1.20.5
```

<a id="install-cmake"></a>

### 安装 CMake

当你使用 C++ 和 Conan 进行开发时，可以从许多可用的编译器中选择。此示例使用 CMake 构建系统生成器。

要安装 CMake：

- 对于 Mac，使用 [Homebrew](https://brew.sh/) 并运行 `brew install cmake`。
- 对于其他操作系统，请按照 [cmake.org](https://cmake.org/resources/) 上的说明进行操作。

安装完成后，通过运行以下命令验证你可以在终端中使用 CMake：

```shell
cmake --version
```

输出中将打印 CMake 版本信息。

<a id="create-a-project"></a>

### 创建项目

为了测试软件包仓库，你需要一个 C++ 项目。如果你还没有，可以克隆 Conan [hello world 入门项目](https://github.com/conan-io/hello)。

<a id="build-a-conan-1-package"></a>

### 构建 Conan 1 软件包

要构建软件包：

1. 打开终端并进入项目根目录。
1. 通过运行 `conan new` 并指定软件包名称和版本来生成新配方：

   ```shell
   conan new Hello/0.1 -t
   ```

1. 通过运行 `conan create` 并指定 Conan 用户和频道为配方创建软件包：

   ```shell
   conan create . mycompany/beta
   ```

   > [!note]
   > 如果你使用[实例远程](../conan_1_repository/_index.md#add-a-remote-for-your-instance)，你必须遵循特定的[命名约定](../conan_1_repository/_index.md#package-recipe-naming-convention-for-instance-remotes)。

配方为 `Hello/0.1@mycompany/beta` 的软件包已创建。

有关创建和管理 Conan 软件包的更多详细信息，请参见 [Conan 文档](https://docs.conan.io/en/latest/creating_packages.html)。

## Conan 2

<a id="install-conan-2"></a>

### 安装 Conan 2

先决条件：

- 你必须安装 Conan 版本 2.x。基础版 Conan 2 已可用，未来的改进可以在史诗 8258 中跟踪。

按照 [conan.io](https://docs.conan.io/2/installation.html) 上的说明，将 Conan 软件包管理器安装到本地开发环境。

安装完成后，运行以下命令验证你可以在终端中使用 Conan：

```shell
conan --version
```

Conan 版本信息将打印在输出中：

```plaintext
Conan version 2.17.0
```

<a id="create-conan-2-profile"></a>

### 创建 Conan 2 配置文件

你必须为 Conan 2 定义一个配置文件。如果你已经定义了配置文件，请跳过此步骤。

要创建配置文件，请运行以下命令：

```shell
conan profile detect
```

检查配置文件：

```shell
conan profile list
```

该命令在输出中列出配置文件：

```plaintext
Profiles found in the cache:
default
```

生成的配置文件通常足以入门。有关 Conan 配置文件的更多信息，请参见 [Conan 2 配置文件](https://docs.conan.io/2/reference/config_files/profiles.html#profiles)。

<a id="install-cmake"></a>

### 安装 CMake

当你使用 C++ 和 Conan 进行开发时，可以从许多可用的编译器中选择。以下示例使用 CMake 构建系统生成器。

先决条件：

- 安装 CMake。
  - 对于 macOS，安装 [Homebrew](https://brew.sh/) 并运行 `brew install cmake`。
  - 对于其他操作系统，请按照 [cmake.org](https://cmake.org/resources/) 上的说明进行操作。

安装完成后，通过运行以下命令验证你可以在终端中使用 CMake：

```shell
cmake --version
```

输出中将打印 CMake 版本信息。

<a id="create-a-project"></a>

### 创建项目

先决条件：

- 为了测试软件包仓库，你必须有一个 C++ 项目。

进入本地项目文件夹，使用 `conan new` 命令通过 `cmake_lib` 模板创建一个“Hello World” C++ 库示例项目：

```shell
mkdir hello && cd hello
conan new cmake_lib -d name=hello -d version=0.1
```

有关更高级的示例，请参见 Conan 2 [示例项目](https://github.com/conan-io/examples2)。

<a id="build-a-conan-2-package"></a>

### 构建 Conan 2 软件包

先决条件：

- [创建一个 C++ 项目](#create-a-project)。

要构建软件包：

1. 确保你位于上一节创建的 `hello` 文件夹中。
1. 通过运行 `conan create` 并指定 Conan 用户和频道为配方创建软件包：

   ```shell
   conan create . --channel=beta --user=mycompany
   ```

配方为 `hello/0.1@mycompany/beta` 的软件包已创建。

有关创建和管理 Conan 软件包的更多详细信息，请参见[创建软件包](https://docs.conan.io/2/tutorial/creating_packages)。

## Maven

<a id="install-maven"></a>

### 安装 Maven

所需的最低版本为：

- Java 11.0.5+
- Maven 3.6+

按照 [maven.apache.org](https://maven.apache.org/install.html) 上的说明，为本地开发环境下载并安装 Maven。安装完成后，通过运行以下命令验证你可以在终端中使用 Maven：

```shell
mvn --version
```

输出应类似于：

```plaintext
Apache Maven 3.6.1 (d66c9c0b3152b2e69ee9bac180bb8fcc8e6af555; 2019-04-04T20:00:29+01:00)
Maven home: /Users/<your_user>/apache-maven-3.6.1
Java version: 12.0.2, vendor: Oracle Corporation, runtime: /Library/Java/JavaVirtualMachines/jdk-12.0.2.jdk/Contents/Home
Default locale: en_GB, platform encoding: UTF-8
OS name: "mac os x", version: "10.15.2", arch: "x86_64", family: "mac"
```

<a id="build-a-maven-package"></a>

### 构建 Maven 软件包

1. 打开终端，创建一个目录来存储项目。
1. 从新目录中，运行此 Maven 命令来初始化一个新软件包：

   ```shell
   mvn archetype:generate -DgroupId=com.mycompany.mydepartment -DartifactId=my-project -DarchetypeArtifactId=maven-archetype-quickstart -DinteractiveMode=false
   ```

   参数分别是：

   - `DgroupId`：一个唯一字符串，标识你的软件包。请遵循 [Maven 命名约定](https://maven.apache.org/guides/mini/guide-naming-conventions.html)。
   - `DartifactId`：`JAR` 的名称，附加在 `DgroupId` 的末尾。
   - `DarchetypeArtifactId`：用于创建项目初始结构的原型。
   - `DinteractiveMode`：使用批处理模式创建项目（可选）。

此消息表示项目已成功设置：

```plaintext
...
[INFO] BUILD SUCCESS
...
```

在你运行命令的文件夹中，应该会出现一个新目录。该目录名称应与 `DartifactId` 参数匹配，在此示例中为 `my-project`。

## Gradle

<a id="install-gradle"></a>

### 安装 Gradle

如果你想要创建一个新的 Gradle 项目，你必须安装 Gradle。按照 [gradle.org](https://gradle.org/install/) 上的说明，为本地开发环境下载并安装 Gradle。

在终端中，运行以下命令验证你可以使用 Gradle：

```shell
gradle -version
```

要使用现有的 Gradle 项目，在项目目录中，在 Linux 上执行 `gradlew`，或在 Windows 上执行 `gradlew.bat`。

输出应类似于：

```plaintext
------------------------------------------------------------
Gradle 6.0.1
------------------------------------------------------------

Build time:   2019-11-18 20:25:01 UTC
Revision:     fad121066a68c4701acd362daf4287a7c309a0f5

Kotlin:       1.3.50
Groovy:       2.5.8
Ant:          Apache Ant(TM) version 1.10.7 compiled on September 1 2019
JVM:          11.0.5 (Oracle Corporation 11.0.5+10)
OS:           Windows 10 10.0 amd64
```

<a id="create-a-package"></a>

### 创建软件包

1. 打开终端，创建一个目录来存储项目。
1. 在这个新目录中，运行此命令来初始化一个新软件包：

   ```shell
   gradle init
   ```

   输出应为：

   ```plaintext
   Select type of project to generate:
     1: basic
     2: application
     3: library
     4: Gradle plugin
   Enter selection (default: basic) [1..4]
   ```

1. 输入 `3` 创建一个新的库项目。输出应为：

   ```plaintext
   Select implementation language:
     1: C++
     2: Groovy
     3: Java
     4: Kotlin
     5: Scala
     6: Swift
   ```

1. 输入 `3` 创建一个新的 Java 库项目。输出应为：

   ```plaintext
   Select build script DSL:
     1: Groovy
     2: Kotlin
   Enter selection (default: Groovy) [1..2]
   ```

1. 输入 `1` 创建一个通过 Groovy DSL 描述的 Java 库项目，或输入 `2` 创建一个通过 Kotlin DSL 描述的项目。输出应为：

   ```plaintext
   Select test framework:
     1: JUnit 4
     2: TestNG
     3: Spock
     4: JUnit Jupiter
   ```

1. 输入 `1` 使用 JUnit 4 测试库初始化项目。输出应为：

   ```plaintext
   Project name (default: test):
   ```

1. 输入项目名称或按 <kbd>Enter</kbd> 使用目录名称作为项目名称。

## sbt

<a id="install-sbt"></a>

### 安装 sbt

安装 sbt 以创建新的 sbt 项目。

为你的开发环境安装 sbt：

1. 按照 [scala-sbt.org](https://www.scala-sbt.org/1.x/docs/Setup.html) 上的说明操作。
1. 在终端中，验证你可以使用 sbt：

   ```shell
   sbt --version
   ```

输出类似于：

```plaintext
[warn] Project loading failed: (r)etry, (q)uit, (l)ast, or (i)gnore? (default: r)
sbt script version: 1.9.8
```

<a id="create-a-scala-project"></a>

### 创建 Scala 项目

1. 打开终端，创建一个目录来存储项目。
1. 从新目录中，初始化一个新项目：

   ```shell
   sbt new scala/scala-seed.g8
   ```

   输出为：

   ```plaintext
   Minimum Scala build.

   name [My Something Project]: hello

   Template applied in ./hello
   ```

1. 输入项目名称或按 <kbd>Enter</kbd> 使用目录名称作为项目名称。
1. 打开 `build.sbt` 文件并按照 [sbt 文档](https://www.scala-sbt.org/1.x/docs/Publishing.html) 进行编辑，以将项目发布到软件包仓库。

## npm

<a id="install-npm"></a>

### 安装 npm

按照 [npmjs.com](https://docs.npmjs.com/downloading-and-installing-node-js-and-npm/) 上的说明，在本地开发环境中安装 Node.js 和 npm。

安装完成后，通过运行以下命令验证你可以在终端中使用 npm：

```shell
npm --version
```

npm 版本将显示在输出中：

```plaintext
6.10.3
```

<a id="create-an-npm-package"></a>

### 创建 npm 软件包

1. 创建一个空目录。
1. 进入该目录并通过运行以下命令初始化一个空软件包：

   ```shell
   npm init
   ```

1. 回答问题。确保软件包名称符合[命名约定](../npm_registry/_index.md#naming-convention)，并且作用域为存在仓库的项目或群组。

## Yarn

<a id="install-yarn"></a>

### 安装 Yarn

作为 npm 的替代方案，你可以按照 [classic.yarnpkg.com](https://classic.yarnpkg.com/en/docs/install) 上的说明在本地环境中安装 Yarn。

安装完成后，通过运行以下命令验证你可以在终端中使用 Yarn：

```shell
yarn --version
```

Yarn 版本将显示在输出中：

```plaintext
1.19.1
```

<a id="create-a-package"></a>

### 创建软件包

1. 创建一个空目录。
1. 进入该目录并通过运行以下命令初始化一个空软件包：

   ```shell
   yarn init
   ```

1. 回答问题。确保软件包名称符合[命名约定](../npm_registry/_index.md#naming-convention)，并且作用域为存在仓库的项目或群组。

一个 `package.json` 文件被创建。

## NuGet

<a id="install-nuget"></a>

### 安装 NuGet

按照 [Microsoft](https://learn.microsoft.com/en-us/nuget/install-nuget-client-tools) 的说明安装 NuGet。如果你已安装 [Visual Studio](https://visualstudio.microsoft.com/vs/)，则可能已经安装了 NuGet。

通过运行以下命令验证 [NuGet CLI](https://www.nuget.org/) 是否已安装：

```shell
nuget help
```

输出应类似于：

```plaintext
NuGet Version: 5.1.0.6013
usage: NuGet <command> [args] [options]
Type 'NuGet help <command>' for help on a specific command.

Available commands:

[output truncated]
```

## PyPI

<a id="install-pip-and-twine"></a>

### 安装 pip 和 twine

安装最新版本的 [pip](https://pypi.org/project/pip/) 和 [twine](https://pypi.org/project/twine/)。

<a id="create-a-project"></a>

### 创建项目

创建测试项目。

1. 打开终端。
1. 创建一个名为 `MyPyPiPackage` 的目录，然后进入该目录：

   ```shell
   mkdir MyPyPiPackage && cd MyPyPiPackage
   ```

1. 创建另一个目录并进入：

   ```shell
   mkdir mypypipackage && cd mypypipackage
   ```

1. 在此目录中创建所需的文件：

   ```shell
   touch __init__.py
   touch greet.py
   ```

1. 打开 `greet.py` 文件，然后添加：

   ```python
   def SayHello():
       print("Hello from MyPyPiPackage")
       return
   ```

1. 打开 `__init__.py` 文件，然后添加：

   ```python
   from .greet import SayHello
   ```

1. 要测试代码，在 `MyPyPiPackage` 目录中启动 Python 提示符。

   ```shell
   python
   ```

1. 运行此命令：

   ```python
   >>> from mypypipackage import SayHello
   >>> SayHello()
   ```

表示项目已成功设置的消息：

```plaintext
Python 3.8.2 (v3.8.2:7b3ab5921f, Feb 24 2020, 17:52:18)
[Clang 6.0 (clang-600.0.57)] on darwin
Type "help", "copyright", "credits" or "license" for more information.
>>> from mypypipackage import SayHello
>>> SayHello()
Hello from MyPyPiPackage
```

<a id="create-a-pypi-package"></a>

### 创建 PyPI 软件包

创建项目后，你可以创建软件包。

1. 在终端中，进入 `MyPyPiPackage` 目录。
1. 创建一个 `pyproject.toml` 文件：

   ```shell
   touch pyproject.toml
   ```

   该文件包含所有关于软件包的信息。有关此文件的更多信息，请参见[创建 `pyproject.toml`](https://packaging.python.org/en/latest/tutorials/packaging-projects/#creating-pyproject-toml)。
   由于极狐GitLab 基于 [Python 规范化名称 (PEP-503)](https://www.python.org/dev/peps/pep-0503/#normalized-names) 识别软件包，请确保你的软件包名称符合这些要求。详情请参见[安装部分](../pypi_repository/_index.md#authenticate-with-the-gitlab-package-registry)。

1. 打开 `pyproject.toml` 文件，然后添加基本信息：

   ```toml
   [build-system]
   requires = ["setuptools>=61.0"]
   build-backend = "setuptools.build_meta"

   [project]
   name = "mypypipackage"
   version = "0.0.1"
   authors = [
       { name="Example Author", email="author@example.com" },
   ]
   description = "A small example package"
   requires-python = ">=3.7"
   classifiers = [
      "Programming Language :: Python :: 3",
      "Operating System :: OS Independent",
   ]

   [tool.setuptools.packages]
   find = {}
   ```

1. 保存文件。
1. 安装软件包构建库：

   ```shell
   pip install build
   ```

1. 构建软件包：

   ```shell
   python -m build
   ```

输出应在新创建的 `dist` 文件夹中可见：

```shell
ls dist
```

输出应类似于以下内容：

```plaintext
mypypipackage-0.0.1-py3-none-any.whl mypypipackage-0.0.1.tar.gz
```

软件包现在已准备好发布到软件包仓库。

```