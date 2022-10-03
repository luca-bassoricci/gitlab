import Vue from 'vue';
import ProjectApp from './project_app.vue';

export function addProjectBody(projectId, mainApp, mainAppProps) {
  console.log('Adding Project Body ' + projectId);

  new Vue({
    el: '.layout-page',
    render(r) {
      return r(ProjectApp, {
        props: {
          projectId,
        },
        scopedSlots: {
          main: (slotProps) => {
            return r(mainApp, mainAppProps);
          },
        },
      });
    },
  });
}
