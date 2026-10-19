import '~/pages/profiles/notifications/show';

const checkboxes = document.querySelectorAll(
  '.js-wecom-notifications-enabled, .js-feishu-notifications-enabled, .js-dingtalk-notifications-enabled',
);

checkboxes.forEach((checkbox) => {
  checkbox.addEventListener('change', () => {
    checkbox.form?.submit();
  });
});
