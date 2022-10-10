import setHighlightClass from 'ee_else_ce/search/highlight_blob_search_result';
import { queryToObject } from '~/lib/utils/url_utility';
import refreshCounts from '~/pages/search/show/refresh_counts';
import { initSidebar, sidebarInitState } from './sidebar';
import { initSearchSort } from './sort';
import createStore from './store';
import { initTopbar } from './topbar';
import { initBlobRefSwitcher } from './under_topbar';

export const initSearchApp = () => {
  const query = queryToObject(window.location.search);
  const navigation = sidebarInitState();

  const store = createStore({ query, navigation });

  initTopbar(store);
  initSidebar(store);
  initSearchSort(store);

  setHighlightClass(query.search); // Code Highlighting
  initBlobRefSwitcher(); // Code Search Branch Picker

  if (!gon.features?.searchPageVerticalNav) {
    refreshCounts(); // Other Scope Tab Counts
  }
};
