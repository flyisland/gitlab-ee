import Vue from 'vue';
import NotificationBanner from './components/notification_banner.vue';

export const initAccountNotification = () => {
  const el = document.querySelector('.js-account-notification-banner');

  if (!el) {
    return false;
  }

  const { daysLeft, updatedAt, customerDotLink } = el.dataset;

  return new Vue({
    el,
    render: (h) =>
      h(NotificationBanner, {
        props: {
          daysLeft,
          updatedAt,
          customerDotLink,
        },
      }),
  });
};
