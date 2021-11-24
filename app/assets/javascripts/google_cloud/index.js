import Vue from 'vue';
import App from './components/app.vue';

export default () => {
  const root = '#js-google-cloud';
  const element = document.querySelector(root);
  const props = JSON.parse(element.getAttribute('data'));
  return new Vue({ el: root, render: (createElement) => createElement(App, { props }) });
};
