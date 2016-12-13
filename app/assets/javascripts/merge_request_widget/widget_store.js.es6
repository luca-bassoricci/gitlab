//= require ./approvals/stores/approvals_store

(() => {
  let singleton;

  class MergeRequestWidgetStore {
    constructor(rootEl) {
      if (!singleton) {
        singleton = gl.MergeRequestWidget.Store = this;
        this.init(rootEl);
      }
      return singleton;
    }

    init(rootEl) {
      this.rootEl = rootEl;
      this.dataset = rootEl.dataset;
      this.data = {};

      // init other widget stores here
      this.initApprovals();
    }

    initApprovals() {
      gl.ApprovalsStore = new gl.ApprovalsStore(this);
      this.assignToData('approvals', this.dataset.approvals);
    }

    assignToData(key, val) {
      this.data[key] = {};
      return Object.assign(this.data[key], val);
    }
  }
  gl.MergeRequestWidgetStore = MergeRequestWidgetStore;
})(window.gl || (window.gl = {}));
