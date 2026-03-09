import 'package:dart_network_layer_dio/dart_network_layer_dio.dart';
import 'package:example_project/widgets/request_detail_dialog.dart';
import 'package:flutter/material.dart';

/// A single scrollable view that shows in-progress requests at the top,
/// a divider, then completed request history — all merged via
/// [CustomScrollView] with slivers.
class RequestMonitorList extends StatelessWidget {
  /// Creates a [RequestMonitorList].
  const RequestMonitorList({
    required this.progresses,
    required this.history,
    super.key,
  });

  /// Currently active request progress states.
  final List<RequestProgressState> progresses;

  /// Completed request history entries.
  final List<RequestHistoryEntry> history;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reversedHistory = history.reversed.toList();
    final hasProgress = progresses.isNotEmpty;
    final hasHistory = reversedHistory.isNotEmpty;

    return CustomScrollView(
      slivers: [
        // ── In-progress section header ──
        SliverToBoxAdapter(
          child: _SectionHeader(
            icon: Icons.sync,
            label: 'In Progress',
            count: progresses.length,
            color: theme.colorScheme.primary,
          ),
        ),

        // ── In-progress items ──
        if (hasProgress)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            sliver: SliverList.builder(
              itemCount: progresses.length,
              itemBuilder: (context, index) =>
                  _ProgressTile(progress: progresses[index]),
            ),
          )
        else
          const SliverToBoxAdapter(
            child: _EmptyPlaceholder(
              icon: Icons.hourglass_empty,
              label: 'No requests in progress',
            ),
          ),

        // ── Divider ──
        const SliverToBoxAdapter(child: Divider(height: 1)),

        // ── History section header ──
        SliverToBoxAdapter(
          child: _SectionHeader(
            icon: Icons.history,
            label: 'History',
            count: reversedHistory.length,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),

        // ── History items ──
        if (hasHistory)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            sliver: SliverList.builder(
              itemCount: reversedHistory.length,
              itemBuilder: (context, index) =>
                  _HistoryTile(entry: reversedHistory[index]),
            ),
          )
        else
          const SliverToBoxAdapter(
            child: _EmptyPlaceholder(
              icon: Icons.history,
              label: 'No request history',
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared helpers
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  final IconData icon;
  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            '$label ($count)',
            style: theme.textTheme.labelLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyPlaceholder extends StatelessWidget {
  const _EmptyPlaceholder({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28, color: theme.disabledColor),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.disabledColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// In-progress tile
// ─────────────────────────────────────────────────────────────────────────────

class _ProgressTile extends StatelessWidget {
  const _ProgressTile({required this.progress});

  final RequestProgressState progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final command = progress.request;
    final percent = progress.progressPercent;

    final statusIcon = switch (progress.status) {
      ProgressStatus.pending => Icons.schedule,
      ProgressStatus.sending => Icons.upload,
      ProgressStatus.receiving => Icons.download,
      ProgressStatus.success => Icons.check_circle,
      ProgressStatus.unsuccessful => Icons.unpublished_outlined,
      ProgressStatus.error => Icons.error,
      ProgressStatus.cancelled => Icons.cancel,
    };

    final statusColor = switch (progress.status) {
      ProgressStatus.pending => Colors.grey,
      ProgressStatus.sending => Colors.blue,
      ProgressStatus.receiving => Colors.orange,
      ProgressStatus.success => Colors.green,
      ProgressStatus.unsuccessful => Colors.orange,
      ProgressStatus.error => Colors.red,
      ProgressStatus.cancelled => Colors.amber,
    };

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(statusIcon, size: 16, color: statusColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${command.method.value.toUpperCase()} ${command.path}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  progress.status.name.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: statusColor,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.cancel, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Cancel',
                  onPressed: () {
                    try {
                      command.cancel();
                    } on Exception catch (_) {
                      // Already completed or cancelled.
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: progress.unknownTotal ? null : percent,
              backgroundColor: statusColor.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation(statusColor),
            ),
            const SizedBox(height: 2),
            Text(
              progress.unknownTotal
                  ? '${_formatBytes(progress.progress)} / unknown'
                  : '${_formatBytes(progress.progress)} / '
                        '${_formatBytes(progress.total)}'
                        ' (${(percent * 100).toStringAsFixed(1)}%)',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// History tile
// ─────────────────────────────────────────────────────────────────────────────

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.entry});

  final RequestHistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final command = entry.request;

    final statusIcon = switch (entry.status) {
      ProgressStatus.pending => Icons.schedule,
      ProgressStatus.sending => Icons.upload,
      ProgressStatus.receiving => Icons.download,
      ProgressStatus.success => Icons.check_circle,
      ProgressStatus.unsuccessful => Icons.unpublished_outlined,
      ProgressStatus.error => Icons.error,
      ProgressStatus.cancelled => Icons.cancel,
    };

    final statusColor = switch (entry.status) {
      ProgressStatus.pending => Colors.grey,
      ProgressStatus.sending => Colors.blue,
      ProgressStatus.receiving => Colors.orange,
      ProgressStatus.success => Colors.green,
      ProgressStatus.unsuccessful => Colors.orange,
      ProgressStatus.error => Colors.red,
      ProgressStatus.cancelled => Colors.amber,
    };

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: InkWell(
        onTap: () async {
          await showDialog<void>(
            context: context,
            builder: (context) {
              return RequestDetailDialog(data: entry);
            },
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(statusIcon, size: 18, color: statusColor),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${command.method.value.toUpperCase()} ${command.path}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${entry.status.name.toUpperCase()}'
                      '  •  ${_formatDuration(entry.duration)}'
                      '  •  ${_formatTime(entry.endTime)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    if (d.inMilliseconds < 1000) return '${d.inMilliseconds} ms';
    return '${(d.inMilliseconds / 1000).toStringAsFixed(2)} s';
  }

  String _formatTime(DateTime t) {
    return '${t.hour.toString().padLeft(2, '0')}:'
        '${t.minute.toString().padLeft(2, '0')}:'
        '${t.second.toString().padLeft(2, '0')}';
  }
}
