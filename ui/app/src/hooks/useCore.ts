import {
  createStore,
  createApi,
  createActions,
  createPoolFinder,
} from "ui-core";

const api = createApi(
  process.env.VUE_APP_DEPLOYMENT_TAG,
  process.env.VUE_APP_SIFCHAIN_ASSET_TAG,
  process.env.VUE_APP_ETHEREUM_ASSET_TAG
);
const store = createStore();
const actions = createActions({ store, api });
const poolFinder = createPoolFinder(store);

export function useCore() {
  return {
    store,
    api,
    actions,
    poolFinder,
  };
}
