# Network Invoker Hierarchy

The network invoker implementations are structured as a hierarchy of base classes, each adding specific layers of functionality:

- **Base0RequestManagingNetworkInvoker** (`base0`) - Request state tracking
- **Base1InvokeRequestNetworkInvoker** (`base1`) - Progress tracking, cancellation, and history
- **Base2NetworkInvokerLogger** (`base2`) - Base for MixinLogger (Logging capabilities)
- **Base3NetworkInvokerDio** (`base3`) - Base for DioNetworkInvoker (Request execution using Dio)
- **DioNetworkInvoker** (concrete) - Public API with factory constructors
