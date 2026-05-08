# dart_network_layer_dio

[GitHub][gh_dart_network_layer_dio] | [pub.dev][pd_dart_network_layer_dio]

Dio implementation of `INetworkInvoker` from
[`dart_network_layer_core`][gh_dart_network_layer_core].

## Guide Status

The old README usage guide is intentionally invalidated.
Use the maintained docs in the root `docs/` folder:

- [Quick Start](../docs/QUICK_START.md)
- [Quick Start with OpenAPI](../docs/QUICK_START_WITH_OPENAPI.md)
- [Sending Files](../docs/SENDING_FILES.md)
- [Receiving Files](../docs/RECIEVING_FILES.md)

## Example Integration

See [`example_project`][gh_example_flutter_dio] for end-to-end usage, including:

- custom invoker extension via `DioNetworkInvoker.fromDio`
- generated OpenAPI command classes
- multipart upload and binary download flows

## License

MIT

[gh_dart_network_layer_core]: https://github.com/femrek/dart_network_layer/tree/main/dart_network_layer_core
[gh_dart_network_layer_dio]: https://github.com/femrek/dart_network_layer/tree/main/dart_network_layer_dio
[pd_dart_network_layer_dio]: https://pub.dev/packages/dart_network_layer_dio
[gh_example_flutter_dio]: https://github.com/femrek/dart_network_layer/tree/main/example_project

