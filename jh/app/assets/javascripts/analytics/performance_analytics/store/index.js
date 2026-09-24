import Vue from 'vue';
import Vuex from 'vuex';
import * as actions from 'jh/analytics/performance_analytics/store/actions';
import * as getters from 'jh/analytics/performance_analytics/store/getters';
import createState from 'jh/analytics/performance_analytics/store/state';
import mutations from 'jh/analytics/performance_analytics/store/mutations';

Vue.use(Vuex);

export default (initialState) =>
  new Vuex.Store({
    actions,
    getters,
    state: createState(initialState),
    mutations,
  });
