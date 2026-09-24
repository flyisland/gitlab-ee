---
stage: Create
group: Source Code
info: "To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments"
disqus_identifier: 'https://docs.gitlab.com/ee/workflow/workflow.html'
---

# 功能分支工作流 **(BASIC ALL)**

1. 克隆项目:

   ```shell
   git clone git@example.com:project-name.git
   ```

2. 创建功能分支:

   ```shell
   git checkout -b feature_name
   ```

3. 编写代码并提交:

   ```shell
   git commit -am "My feature is ready"
   ```

4. 推送分支到极狐GitLab:

   ```shell
   git push origin feature_name
   ```

5. 在提交页面检查您的代码。

6. 创建一个合并请求。

7. 您的组长审查代码并合并到主干分支。
