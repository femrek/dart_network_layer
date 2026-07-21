import 'package:dart_network_layer_core/src/request/request_cancel_mixin.dart';
import 'package:test/test.dart';

class _CancelTarget with RequestCancelMixin {}

void main() {
  group('RequestCancelMixin', () {
    test('cancel() before setOnCancel() is a no-op', () {
      final target = _CancelTarget();
      expect(target.cancel, returnsNormally);
    });

    test('cancel() after setOnCancel() invokes the callback once', () {
      var callCount = 0;
      (_CancelTarget()
            // ignore: invalid_use_of_internal_member, testing internal mixin setter
            ..setOnCancel(() => callCount++))
          .cancel();
      expect(callCount, equals(1));
    });

    test('replacing setOnCancel() makes cancel() call the new callback', () {
      var oldCallCount = 0;
      var newCallCount = 0;

      (_CancelTarget()
            // ignore: invalid_use_of_internal_member, first registration
            ..setOnCancel(() => oldCallCount++)
            // ignore: invalid_use_of_internal_member, second registration replaces first
            ..setOnCancel(() => newCallCount++))
          .cancel();

      expect(oldCallCount, equals(0));
      expect(newCallCount, equals(1));
    });

    test('after replacing, the OLD callback is not called', () {
      var oldCalled = false;
      (_CancelTarget()
            // ignore: invalid_use_of_internal_member, initial callback setup
            ..setOnCancel(() => oldCalled = true)
            // ignore: invalid_use_of_internal_member, overwrite with no-op
            ..setOnCancel(() {}))
          .cancel();

      expect(oldCalled, isFalse);
    });

    test('setOnCancel() can be called multiple times without error', () {
      void noop() {}
      expect(() {
        _CancelTarget()
          // ignore: invalid_use_of_internal_member, testing first internal setup
          ..setOnCancel(noop)
          // ignore: invalid_use_of_internal_member, testing second internal setup
          ..setOnCancel(noop);
      }, returnsNormally);
    });
  });
}
