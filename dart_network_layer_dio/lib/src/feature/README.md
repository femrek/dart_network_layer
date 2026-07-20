# Network Invoker Hierarchy

The network invoker implementations are structured as a hierarchy of base classes, each adding specific layers of functionality. We use mixins extensively to keep concerns separated while assembling them in these sequential base classes.

### The Hierarchy

1. **`Base0NetworkInvokerRequestManaging`** (`base0`)
   - **Responsibility**: Foundational state tracking.
   - **Details**: Maintains the `progresses` tracking state (`AggregatedRequestStateImpl`) so that active requests can be tracked and exposed.

2. **`Base1NetworkInvokerLogger`** (`base1`)
   - **Responsibility**: Request lifecycle management.
   - **Details**: Extends `base0` to add the core request management features via mixins (`MixinManageRequestProgress`, `MixinManageRequestCancel`, `MixinManageRequestHistory`). It also introduces the optional `logger` instance.

3. **`Base2NetworkInvokerInvokeRequest`** (`base2`)
   - **Responsibility**: HTTP client integration and logging.
   - **Details**: Extends `base1` and integrates logging functionality via `MixinLogger`. It also introduces the required `dio` instance, bridging the state management layers to the HTTP execution layers.

4. **`Base3NetworkInvokerDio`** (`base3`)
   - **Responsibility**: Core request execution pipeline.
   - **Details**: Extends `base2` and adds `MixinRequest`, which provides the actual HTTP request invocation logic. This layer processes the payloads, handles parsing based on status codes, and executes the physical network calls.

### Concrete Implementation

- **`DioNetworkInvoker`**
   - **Responsibility**: Public API.
   - **Details**: The final concrete class that developers use. It implements `Base3NetworkInvokerDio` and provides the necessary factory constructors (e.g., `fromBaseUrl`, `fromDio`) for external consumption.
