import 'package:dart_network_layer_dio/dart_network_layer_dio.dart';
import 'package:flutter/material.dart';

/// A dialog that shows the details of a network request and its response.
class RequestDetailDialog extends StatelessWidget {
  /// Creates an instance of [RequestDetailDialog] with the given [data].
  const RequestDetailDialog({
    required this.data,
    super.key,
  });

  /// The request history entry containing all the details of the request and
  /// response to be displayed in the dialog.
  final RequestHistoryEntry data;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Request ${data.request.method} ${data.request.path}'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Command: ${data.request.path}'),
            const SizedBox(height: 8),
            Text('Status: ${data.status}'),
            const SizedBox(height: 8),
            Text('Start Time: ${data.startTime}'),
            const SizedBox(height: 8),
            Text('End Time: ${data.endTime}'),
            const SizedBox(height: 8),
            Text('Duration: ${data.duration.inMilliseconds} ms'),
            const SizedBox(height: 8),
            Text('Payload: ${data.request.payload}'),
            const SizedBox(height: 8),
            Text('Response: ${_resultToString(data.request.response)}'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  String _resultToString<T extends Schema>(NetworkResult<T>? result) {
    if (result == null) return 'No response';
    switch (result) {
      case final SuccessResponseResult<T> r:
        return 'Success: ${r.statusCode} ${r.data}';
      case final SpecifiedResponseResult<T> r:
        return 'Specified: ${r.statusCode} ${r.data}';
      case final NetworkErrorResult<T> r:
        return 'Error: ${r.error}';
    }
  }
}
