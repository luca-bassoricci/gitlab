import Vue from 'vue';
import mountComponent from 'spec/helpers/vue_mount_component_helper';
import Button from '~/ide/components/new_dropdown/button.vue';

describe('IDE new entry dropdown button component', () => {
  let Component;
  let vm;

  beforeAll(() => {
    Component = Vue.extend(Button);
  });

  beforeEach(() => {
    vm = mountComponent(Component, {
      label: 'Testing',
      icon: 'doc-new',
    });

    spyOn(vm, '$emit');
  });

  afterEach(() => {
    vm.$destroy();
  });

  it('renders button with label', () => {
    expect(vm.$el.textContent).toContain('Testing');
  });

  it('renders icon', () => {
    expect(vm.$el.querySelector('.ic-doc-new')).not.toBe(null);
  });

  it('emits click event', () => {
    // eslint-disable-next-line no-jquery/no-event-shorthand
    vm.$el.click();

    expect(vm.$emit).toHaveBeenCalledWith('click');
  });

  it('hides label if showLabel is false', done => {
    vm.showLabel = false;

    vm.$nextTick(() => {
      expect(vm.$el.textContent).not.toContain('Testing');

      done();
    });
  });

  describe('tooltipTitle', () => {
    it('returns empty string when showLabel is true', () => {
      expect(vm.tooltipTitle).toBe('');
    });

    it('returns label', done => {
      vm.showLabel = false;

      vm.$nextTick(() => {
        expect(vm.tooltipTitle).toBe('Testing');

        done();
      });
    });
  });
});
