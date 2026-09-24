---
stage: Verify
group: Pipeline Authoring
info: To determine the technical writer assigned to the Stage/Group associated with this page, see <https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments>
title: CI/CD 缓存示例
---

{{< details >}}

- Tier: 基础版，专业版，旗舰版
- Offering: JihuLab.com，私有化部署

{{< /details >}}

使用缓存可以避免每次运行作业时都下载依赖和构建产物。通过重用之前下载的内容，缓存可以加快 CI/CD 流水线的速度。

更多示例，请参见[极狐GitLab CI/CD 模板](https://jihulab.com/gitlab-cn/gitlab/-/tree/master/lib/gitlab/ci/templates)。

<a id="cache-strategies"></a>

## 缓存策略

这些示例展示了在作业和分支之间共享缓存的不同方法。

<a id="share-caches-between-jobs-in-the-same-branch"></a>

### 在同一分支的作业间共享缓存

要让每个分支中的作业使用相同的缓存，请使用 `key: $CI_COMMIT_REF_SLUG` 定义缓存：

```yaml
cache:
  key: $CI_COMMIT_REF_SLUG
```

此配置可防止您意外覆盖缓存。但是，合并请求的第一个流水线会比较慢。下次向分支推送提交时，缓存会被重用，作业运行速度更快。

要启用按作业和按分支缓存：

```yaml
cache:
  key: "$CI_JOB_NAME-$CI_COMMIT_REF_SLUG"
```

要启用按阶段和按分支缓存：

```yaml
cache:
  key: "$CI_JOB_STAGE-$CI_COMMIT_REF_SLUG"
```

<a id="share-caches-across-jobs-in-different-branches"></a>

### 在不同分支的作业间共享缓存

要在所有分支和所有作业之间共享缓存，请为所有内容使用相同的键：

```yaml
cache:
  key: one-key-to-rule-them-all
```

要在分支之间共享缓存，但为每个作业提供唯一的缓存：

```yaml
cache:
  key: $CI_JOB_NAME
```

<a id="use-a-variable-to-control-a-jobs-cache-policy"></a>

### 使用变量控制作业的缓存策略

{{< history >}}

- 在极狐GitLab 16.1 中引入。

{{< /history >}}

为了减少仅在拉取策略上有所不同的重复作业，您可以使用 [CI/CD 变量](../variables/_index.md)。

例如：

```yaml
conditional-policy:
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
      variables:
        POLICY: pull-push
    - if: $CI_COMMIT_BRANCH != $CI_DEFAULT_BRANCH
      variables:
        POLICY: pull
  stage: build
  cache:
    key: gems
    policy: $POLICY
    paths:
      - vendor/bundle
  script:
    - echo "This job pulls and pushes the cache depending on the branch"
    - echo "Downloading dependencies..."
```

在此示例中，作业的缓存策略是：

- 对默认分支的更改使用 `pull-push`。
- 对其他分支的更改使用 `pull`。

<a id="cache-dependencies"></a>

## 缓存依赖

这些示例展示了如何按编程语言缓存常见依赖。

<a id="nodejs"></a>

### Node.js

如果您的项目使用 [npm](https://www.npmjs.com/) 安装 Node.js 依赖，以下示例定义了一个默认 `cache`，以便所有作业继承它。默认情况下，npm 将缓存数据存储在主文件夹 (`~/.npm`) 中。但是，您[不能缓存项目目录之外的内容](../yaml/_index.md#cachepaths)。相反，请告诉 npm 使用 `./.npm`，并按分支缓存它：

```yaml
default:
  image: node:latest
  cache:  # Cache modules in between jobs
    key: $CI_COMMIT_REF_SLUG
    paths:
      - .npm/
  before_script:
    - npm ci --cache .npm --prefer-offline

test_async:
  script:
    - node ./specs/start.js ./specs/async.spec.js
```

<a id="compute-the-cache-key-from-the-lock-file"></a>

#### 根据锁定文件计算缓存键

您可以使用 [`cache:key:files`](../yaml/_index.md#cachekeyfiles) 从 `package-lock.json` 或 `yarn.lock` 等锁定文件计算缓存键，并在多个作业中重用。

```yaml
default:
  cache:  # Cache modules using lock file
    key:
      files:
        - package-lock.json
    paths:
      - .npm/
```

<a id="yarn-with-offline-mirror"></a>

### 使用离线镜像的 Yarn

如果您使用 [Yarn](https://yarnpkg.com/)，可以使用 [`yarn-offline-mirror`](https://classic.yarnpkg.com/blog/2016/11/24/offline-mirror/) 来缓存压缩的 `node_modules` tarball。由于需要压缩的文件更少，缓存生成速度更快：

```yaml
job:
  script:
    - echo 'yarn-offline-mirror ".yarn-cache/"' >> .yarnrc
    - echo 'yarn-offline-mirror-pruning true' >> .yarnrc
    - yarn install --frozen-lockfile --no-progress
  cache:
    key:
      files:
        - yarn.lock
    paths:
      - .yarn-cache/
```

<a id="php"></a>

### PHP

如果您的项目使用 [Composer](https://getcomposer.org/) 安装 PHP 依赖，以下示例定义了一个默认 `cache`，以便所有作业继承它。PHP 库模块安装在 `vendor/` 中，并按分支缓存：

```yaml
default:
  image: php:latest
  cache:  # Cache libraries in between jobs
    key: $CI_COMMIT_REF_SLUG
    paths:
      - vendor/
  before_script:
    # Install and run Composer
    - curl --show-error --silent "https://getcomposer.org/installer" | php
    - php composer.phar install

test:
  script:
    - vendor/bin/phpunit --configuration phpunit.xml --coverage-text --colors=never
```

<a id="python"></a>

### Python

如果您的项目使用 [pip](https://pip.pypa.io/en/stable/) 安装 Python 依赖，以下示例定义了一个默认 `cache`，以便所有作业继承它。pip 的缓存定义在 `.cache/pip/` 下，并按分支缓存：

```yaml
default:
  image: python:latest
  cache:                      # Pip's cache doesn't store the python packages
    paths:                    # https://pip.pypa.io/en/stable/topics/caching/
      - .cache/pip
  before_script:
    - python -V               # Print out python version for debugging
    - pip install virtualenv
    - virtualenv venv
    - source venv/bin/activate

variables:  # Change pip's cache directory to be inside the project directory because GitLab can only cache local items.
  PIP_CACHE_DIR: "$CI_PROJECT_DIR/.cache/pip"

test:
  script:
    - python setup.py test
    - pip install ruff
    - ruff --format=gitlab .
```

<a id="ruby"></a>

### Ruby

如果您的项目使用 [Bundler](https://bundler.io) 安装 gem 依赖，以下示例定义了一个默认 `cache`，以便所有作业继承它。Gem 安装在 `vendor/ruby/` 中，并按分支缓存：

```yaml
default:
  image: ruby:latest
  cache:                                            # Cache gems in between builds
    key: $CI_COMMIT_REF_SLUG
    paths:
      - vendor/ruby
  before_script:
    - ruby -v                                       # Print out ruby version for debugging
    - bundle config set --local path 'vendor/ruby'  # The location to install the specified gems to
    - bundle install -j $(nproc)                    # Install dependencies into ./vendor/ruby

rspec:
  script:
    - rspec spec
```

如果您有需要不同 gem 的作业，请在全局 `cache` 定义中使用 `prefix` 关键字。此配置会为每个作业生成不同的缓存。

例如，测试作业可能不需要与部署到生产环境的作业相同的 gem：

```yaml
default:
  cache:
    key:
      files:
        - Gemfile.lock
      prefix: $CI_JOB_NAME
    paths:
      - vendor/ruby

test_job:
  stage: test
  before_script:
    - bundle config set --local path 'vendor/ruby'
    - bundle install --without production
  script:
    - bundle exec rspec

deploy_job:
  stage: production
  before_script:
    - bundle config set --local path 'vendor/ruby'   # The location to install the specified gems to
    - bundle install --without test
  script:
    - bundle exec deploy
```

<a id="go"></a>

### Go

如果您的项目使用 [Go Modules](https://go.dev/wiki/Modules) 安装 Go 依赖，以下示例在 `go-cache` 模板中定义了 `cache`，任何作业都可以扩展。Go 模块安装在 `${GOPATH}/pkg/mod/` 中，并为所有 `go` 项目缓存：

```yaml
.go-cache:
  variables:
    GOPATH: $CI_PROJECT_DIR/.go
  before_script:
    - mkdir -p .go
  cache:
    paths:
      - .go/pkg/mod/

test:
  image: golang:latest
  extends: .go-cache
  script:
    - go test ./... -v -short
```

<a id="cache-build-artifacts-and-downloads"></a>

## 缓存构建产物和下载

这些示例展示了如何缓存编译对象和下载文件以加快构建速度。

<a id="cache-cc-compilation-using-ccache"></a>

### 使用 Ccache 缓存 C/C++ 编译

如果您正在编译 C/C++ 项目，可以使用 [Ccache](https://ccache.dev/) 来加快构建时间。Ccache 通过缓存以前的编译并检测何时再次进行相同的编译来加快重新编译速度。在构建像 Linux 内核这样的大型项目时，您可以期望显著加快编译速度。

使用 `cache` 在作业之间重用创建的缓存，例如：

```yaml
job:
  cache:
    paths:
      - ccache
  before_script:
    - export PATH="/usr/lib/ccache:$PATH"  # Override compiler path with ccache (this example is for Debian)
    - export CCACHE_DIR="${CI_PROJECT_DIR}/ccache"
    - export CCACHE_BASEDIR="${CI_PROJECT_DIR}"
    - export CCACHE_COMPILERCHECK=content  # Compiler mtime might change in the container, use checksums instead
  script:
    - ccache --zero-stats || true
    - time make                            # Actually build your code while measuring time and cache efficiency.
    - ccache --show-stats || true
```

如果您在单个仓库中有多个项目，则无需为每个项目设置单独的 `CCACHE_BASEDIR`。

<a id="cache-downloads-with-curl"></a>

### 使用 cURL 缓存下载

如果您的项目使用 [cURL](https://curl.se/) 下载依赖或文件，您可以缓存下载的内容。当有更新的下载可用时，文件会自动更新。

```yaml
job:
  script:
    - curl --remote-time --time-cond .curl-cache/caching.md --output .curl-cache/caching.md "https://gitlab.cn/docs/ci/caching/"
  cache:
    paths:
      - .curl-cache/
```

在此示例中，cURL 从网络服务器下载文件并将其保存到 `.curl-cache/` 中的本地文件。`--remote-time` 标志保存服务器报告的最后修改时间，cURL 使用 `--time-cond` 将其与缓存文件的时间戳进行比较。如果远程文件具有更新的时间戳，则本地缓存会自动更新。