import 'package:dart_network_layer_dio/dart_network_layer_dio.dart';
import 'package:flutter/material.dart';

/// Displays aggregated meta information about all currently progressing
/// requests.
class AggregatedInfoSection extends StatelessWidget {
  /// Creates an instance of [AggregatedInfoSection] with the given [state].
  const AggregatedInfoSection({required this.state, super.key});

  /// The aggregated request state containing information about all currently
  /// progressing requests, such as their total progress and count.
  final AggregatedRequestState? state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeCount = state?.allProgresses.length ?? 0;
    final total = state?.allTotal ?? 0;
    final progress = state?.allProgress ?? 0;
    final percent = state?.allProgressPercent ?? 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border.symmetric(
          horizontal: BorderSide(
            color: theme.colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            'Active: $activeCount',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LinearProgressIndicator(
                  value: total > 0 ? percent : (activeCount > 0 ? null : 0),
                  backgroundColor: theme.colorScheme.primary.withValues(
                    alpha: 0.12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  total > 0
                      ? '${_formatBytes(progress)} / ${_formatBytes(total)}'
                            ' (${(percent * 100).toStringAsFixed(1)}%)'
                      : activeCount > 0
                      ? 'Transferring...'
                      : 'Idle',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
