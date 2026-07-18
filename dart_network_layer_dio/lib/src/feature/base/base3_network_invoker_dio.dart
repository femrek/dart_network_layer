import 'package:dart_network_layer_dio/dart_network_layer_dio.dart';
import 'package:dart_network_layer_dio/src/feature/base/base2_network_invoker_logger.dart';
import 'package:dart_network_layer_dio/src/feature/l3_ logging/mixin_logger.dart';

/// Third-level implementation adding logging capability.
///
/// This abstract class represents the third layer of the network invoker
/// hierarchy. It integrates logging functionality via [MixinLogger].
abstract class Base3NetworkInvokerDio extends Base2NetworkInvokerLogger
    with MixinLogger
    implements INetworkInvoker {
  /// Creates a new instance with the provided [dio] instance.
  Base3NetworkInvokerDio(super.dio);
}
