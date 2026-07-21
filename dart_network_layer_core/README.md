# dart_network_layer_core

[GitHub][gh_dart_network_layer_core] | [pub.dev][pd_dart_network_layer_core]

Core contracts and schema abstractions for Dart Network Layer.

## Guide Status

The old README walkthrough has been intentionally invalidated.
Use the maintained docs in the root `docs/` folder:

- [Quick Start](../docs/QUICK_START.md)
- [Quick Start with OpenAPI](../docs/QUICK_START_WITH_OPENAPI.md)
- [Sending Files](../docs/SENDING_FILES.md)
- [Receiving Files](../docs/RECEIVING_FILES.md)

## What This Package Provides

- `INetworkInvoker` contract (`send` API)
- `RequestCommand<T>` request definition model
- `Schema` and `SchemaFactory` abstractions
- `NetworkResult<T>` response result hierarchy

For a production-ready implementation, use
[`dart_network_layer_dio`][gh_dart_network_layer_dio].

## License

MIT

[gh_dart_network_layer_core]: https://github.com/femrek/dart_network_layer/tree/main/dart_network_layer_core
[pd_dart_network_layer_core]: https://pub.dev/packages/dart_network_layer_core
[gh_dart_network_layer_dio]: https://github.com/femrek/dart_network_layer/tree/main/dart_network_layer_dio

