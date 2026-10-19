import Tracking from '~/tracking';

export const downloadCsv = ({ fileName, url, fileData }) => {
  let href = url;

  if (fileData) {
    href = `data:text/csv;charset=utf-8,%EF%BB%BF${fileData}`;
  }

  const anchor = document.createElement('a');
  anchor.download = fileName;
  anchor.href = href;
  anchor.click();
};

export const trackingPerformanceLoaded = () => {
  Tracking.event(document.body.dataset.page, 'page_fetch');
};
