export const loadScript = (url, onloadCallback) => {
  return new Promise((resolve) => {
    const script = document.createElement('script');
    script.src = url;
    script.onload = () => onloadCallback(resolve);
    document.head.appendChild(script);
  });
};
