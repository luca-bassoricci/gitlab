/* eslint-disable func-names */
import $ from 'jquery';

import Vue from 'vue';
import CommandPalette from './vue_shared/command_palette/command_palette.vue';

import ContextualSidebar from './contextual_sidebar';
import initFlyOutNav from './fly_out_nav';
import { setNotification } from './whats_new/utils/notification';

import { db } from './lib/apollo/local_db';

function hideEndFade($scrollingTabs) {
  $scrollingTabs.each(function scrollTabsLoop() {
    const $this = $(this);
    $this
      .siblings('.fade-right')
      .toggleClass('scrolling', Math.round($this.width()) < $this.prop('scrollWidth'));
  });
}

function initCommandMenu() {
  // Simple mount of the command menu
  const e = document.createElement('div');
  e.id = 'command-palette-div';
  document.body.appendChild(e);
  new Vue({
    el: '#command-palette-div',
    render(r) {
      return r(CommandPalette, {
        props: {},
      });
    },
  });

  // Count Page activity
  db.table('pages').put(
    {
      url: document.location.href,
      title: document.title.replace(' · GitLab', ''),
      timestamp: new Date(),
    },
    document.location.href,
  );
}

function initDeferred() {
  $(document).trigger('init.scrolling-tabs');

  const appEl = document.getElementById('whats-new-app');
  if (!appEl) return;

  setNotification(appEl);
  document.querySelector('.js-whats-new-trigger').addEventListener('click', () => {
    import(/* webpackChunkName: 'whatsNewApp' */ '~/whats_new')
      .then(({ default: initWhatsNew }) => {
        initWhatsNew(appEl);
      })
      .catch(() => {});
  });

  initCommandMenu();
}

export default function initLayoutNav() {
  const contextualSidebar = new ContextualSidebar();
  contextualSidebar.bindEvents();

  initFlyOutNav();

  // We need to init it on DomContentLoaded as others could also call it
  $(document).on('init.scrolling-tabs', () => {
    const $scrollingTabs = $('.scrolling-tabs').not('.is-initialized');
    $scrollingTabs.addClass('is-initialized');

    $(window)
      .on('resize.nav', () => {
        hideEndFade($scrollingTabs);
      })
      .trigger('resize.nav');

    $scrollingTabs.on('scroll', function tabsScrollEvent() {
      const $this = $(this);
      const currentPosition = $this.scrollLeft();
      const maxPosition = $this.prop('scrollWidth') - $this.outerWidth();

      $this.siblings('.fade-left').toggleClass('scrolling', currentPosition > 0);
      $this.siblings('.fade-right').toggleClass('scrolling', currentPosition < maxPosition - 1);
    });

    $scrollingTabs.each(function scrollTabsEachLoop() {
      const $this = $(this);
      const scrollingTabWidth = $this.width();
      const $active = $this.find('.active');
      const activeWidth = $active.width();

      if ($active.length) {
        const offset = $active.offset().left + activeWidth;

        if (offset > scrollingTabWidth - 30) {
          const scrollLeft = offset - scrollingTabWidth / 2 - activeWidth / 2;

          $this.scrollLeft(scrollLeft);
        }
      }
    });
  });

  requestIdleCallback(initDeferred);
}
