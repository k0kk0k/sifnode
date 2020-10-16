# Structure

We are following architecture influenced by clean architecture.

https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html

<img src="FEArchitecture.png" />

The main premise here is that we have a domain consisting of actions and entities which communicate with the outside world over `api` and `store` channels.

| Section         | Description                                                                                                   |
| --------------- | ------------------------------------------------------------------------------------------------------------- |
| `core/actions`  | Actions, (aka usecases, interactors, commands) These hold the business logic and policies for the application |
| `core/entities` | Application data types.                                                                                       |
| `core/api`      | Input/output services. This is where you write and read data to wallets remote endpoints, rpc etc.            |
| `core/store`    | Shared reactive state between the `actions` and the view                                                      |
| `app`           | View application that renders UI                                                                              |

Every part of this system is designed to facilitate easy testing.

### Testing Actions

Actions can be grouped arbitrarily by domain aggregate and may have their dependencies injected using the supplied creator. You ask for your api and store keys by using the given TS types.

```ts
// Generic params specify what API the service expects
type ActionContext<ServiceKeys, StoreKeys>
```

```ts
export default function createAction({
  api,
  store,
}: ActionContext<"WalletService" | "TokenService", "WalletStore">) {
  return {
    async disconnectWallet() {
      await api.WalletService.disconnect();
      store.WalletStore.isConnected = false;
      store.WalletStore.balances = [];
      await api.TokenService.purgeTokens();
    },
  };
}
```

The reason we do it this way is that in testing we only need to give the action creator exactly what it needs.

```ts
const actions = createAction({ api: { WalletService: fakeWalletService } });

// Then under test the wallet service runs with it's dependencies
actions.disconnectWallet();
```

### Testing Blockchain Driven Api

In the same way that Actions have their dependencies injected we can inject dependencies to our services layer.

```ts
export default function createFooService(context: FooServiceContext) {
  return {
    async doStuff() {
      const web3 = await context.getWeb3();
      // ...
    },
  };
}
```

### Etherium based blockchain development.

To test our blockchain backed apps we use ganache-cli and truffle to create a local etherium chain that is migrated to contain a couple of fake tokens.

You can find the token contracts [here](../chains/ethereum/contracts).

Our API setup asks for getters to supply environment information. It may make sense to convert this to a function that returns a config object we inject everywhere.

To test manually run the app using serve which includes ganache running in the background

```bash
./ui> yarn app:serve
```

Make note of the first private key that gets generated:

<img src="./ganache-keys.png" />

Then fire up the app on http://localhost:8080/.

Go to metamask. Click on the right corner menu and select "Import Account"

<img src="./metamask1.png" width="300" />

Paste your private key there and you will load up your account on metamask.

<img src="./metamask2.png" width="300" />

Hit import and select this account. Be sure to have this account selected. Reload the page click the connect wallet button and run through the procedure to connect your wallet in metamask.

You should see the balances of your wallet in the application.

### Testing stores

Stores are created using factory functions so that their state can be set upon creation. The store is the state our view responds to. It makes sense to test the actions and resultant store effects together as a usecase as we require no further dependencies. We can supply stores to actions in a similar way to the way we supply apis.

### Testing Views

Testing views is not as important as testing core code so we can defer to e2e testing for that. That is why it is ok to share configured action and store instances with Vue components. However complex render functionality or computed properties should be contained within stores or render actions.