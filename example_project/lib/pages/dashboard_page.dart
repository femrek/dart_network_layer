import 'package:dart_network_layer_dio/dart_network_layer_dio.dart';
import 'package:example_project/widgets/aggregated_info_section.dart';
import 'package:example_project/widgets/request_monitor_list.dart';
import 'package:example_project/widgets/requests/request_buttons_section.dart';
import 'package:flutter/material.dart';

/// The main dashboard page that shows request buttons and request monitoring.
class DashboardPage extends StatefulWidget {
  /// Creates an instance of [DashboardPage] with an instance of api client.
  const DashboardPage({
    required this.apiClient,
    super.key,
  });

  /// The API client used to make requests and monitor their progress/history.
  final DioNetworkInvoker apiClient;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final DioNetworkInvoker _invoker = widget.apiClient;

  AggregatedRequestState? _aggregatedState;
  List<RequestHistoryEntry> _history = [];

  @override
  void initState() {
    super.initState();

    // Set the progress callback to update the UI on every progress change.
    _invoker.onUpdateRequestProgress = _onProgressUpdate;
    _invoker.onHistoryUpdate = _historyUpdate;
  }

  void _onProgressUpdate(AggregatedRequestState state) {
    if (mounted) {
      setState(() {
        _aggregatedState = state;
      });
    }
  }

  void _historyUpdate(List<RequestHistoryEntry> history) {
    if (mounted) {
      setState(() {
        _history = history;
      });
    }
  }

  @override
  void dispose() {
    _invoker.onUpdateRequestProgress = null;
    _invoker.onHistoryUpdate = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inProgress = _aggregatedState?.allProgresses ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Layer Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cancel_outlined),
            tooltip: 'Cancel All',
            onPressed: () => _invoker.cancelAll(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Top half: request buttons in three rows with horizontal scroll
          RequestButtonsSection(invoker: _invoker),

          AggregatedInfoSection(state: _aggregatedState),

          // Bottom half: merged in-progress + history via CustomScrollView
          Expanded(
            child: RequestMonitorList(
              progresses: inProgress,
              history: _history,
            ),
          ),
        ],
      ),
    );
  }
}
