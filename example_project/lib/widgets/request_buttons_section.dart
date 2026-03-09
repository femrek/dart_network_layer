import 'dart:io';

import 'package:dart_network_layer_dio/dart_network_layer_dio.dart';
import 'package:flutter/material.dart';
import 'package:openapi/api.dart' hide Widget;
import 'package:path_provider/path_provider.dart';

/// Section displaying request buttons in three horizontal-scrolling rows,
/// grouped by API category: Tables, Bulks, and Complexes.
class RequestButtonsSection extends StatelessWidget {
  /// Creates an instance of [RequestButtonsSection] with the given [invoker].
  const RequestButtonsSection({required this.invoker, super.key});

  /// The network invoker used to make API requests when buttons are pressed.
  final DioNetworkInvoker invoker;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRow(
            context,
            label: 'Tables',
            icon: Icons.table_chart,
            color: Colors.indigo,
            buttons: _tableButtons(),
          ),
          const SizedBox(height: 4),
          _buildRow(
            context,
            label: 'Bulks',
            icon: Icons.cloud_upload,
            color: Colors.teal,
            buttons: _bulkButtons(),
          ),
          const SizedBox(height: 4),
          _buildRow(
            context,
            label: 'Complexes',
            icon: Icons.account_tree,
            color: Colors.deepOrange,
            buttons: _complexButtons(),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required List<Widget> buttons,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 64,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            children: buttons,
          ),
        ),
      ],
    );
  }

  List<Widget> _tableButtons() {
    return [
      _RequestButton(
        label: 'List Tables',
        icon: Icons.list,
        onPressed: () => invoker.request(
          ListTablesCommand(
            start: 0,
            end: 10,
            allParams: {},
          ),
        ),
      ),
      _RequestButton(
        label: 'Get Table #1',
        icon: Icons.search,
        onPressed: () => invoker.request(GetTableCommand(id: 1)),
      ),
      _RequestButton(
        label: 'Create Table',
        icon: Icons.add,
        onPressed: () => invoker.request(
          CreateTableCommand(
            tableCreateDTO: TableCreateDTO(
              name: 'New Table',
              capacity: 4,
            ),
          ),
        ),
      ),
      _RequestButton(
        label: 'Update Table #1',
        icon: Icons.edit,
        onPressed: () => invoker.request(
          UpdateTableCommand(
            id: 1,
            requestBody: {'name': 'Updated Table', 'capacity': 8},
          ),
        ),
      ),
      _RequestButton(
        label: 'Delete Table #1',
        icon: Icons.delete,
        onPressed: () => invoker.request(DeleteTableCommand(id: 1)),
      ),
      _RequestButton(
        label: 'Get Many [1,2,3]',
        icon: Icons.checklist,
        onPressed: () => invoker.request(GetManyTablesCommand(id: [1, 2, 3])),
      ),
      _RequestButton(
        label: 'Delete Many [1,2]',
        icon: Icons.delete_sweep,
        onPressed: () => invoker.request(DeleteManyTablesCommand(id: [1, 2])),
      ),
      _RequestButton(
        label: 'Update Many [1,2]',
        icon: Icons.edit_note,
        onPressed: () => invoker.request(
          UpdateManyTablesCommand(
            id: [1, 2],
            requestBody: {'status': 'reserved'},
          ),
        ),
      ),
      _RequestButton(
        label: 'Get Ref (category/1)',
        icon: Icons.link,
        onPressed: () => invoker.request(
          GetManyReferenceByTablesCommand(
            target: 'category',
            targetId: '1',
            start: 0,
            end: 10,
            allParams: {},
          ),
        ),
      ),
    ];
  }

  List<Widget> _bulkButtons() {
    return [
      _RequestButton(
        label: 'Bulk Download',
        icon: Icons.download,
        onPressed: () => invoker.request(
          BulkDownloadCommand(datasetId: 'sample-dataset'),
        ),
      ),
      _RequestButton(
        label: 'Bulk Upload',
        icon: Icons.upload,
        onPressed: () async {
          final dir = await getApplicationCacheDirectory();
          final filePath = '${dir.path}/hn_ss.jpg';
          final file = File(filePath);
          await invoker.request(
            BulkUploadCommand(
              file: FileMultipartFileSchema(
                filename: 'hn_ss.jpg',
                filePath: filePath,
                length: file.lengthSync(),
              ),
              metadata: UploadMetadata(
                overwrite: false,
                targetTable: 'sample_table',
              ),
            ),
          );
        },
      ),
      _RequestButton(
        label: 'Get Job Status',
        icon: Icons.pending_actions,
        onPressed: () => invoker.request(
          GetJobStatusCommand(jobId: '1', level: GetJobStatusLevelEnum.FULL),
        ),
      ),
      _RequestButton(
        label: 'Image Download',
        icon: Icons.image,
        onPressed: () async {
          final dir = await getApplicationCacheDirectory();
          final filePath = '${dir.path}/hn_ss.jpg';
          await invoker.request(
            GetSampleImageCommand(
              binaryResponseType: FileBinaryResponse(filePath),
            ),
          );
        },
      ),
    ];
  }

  List<Widget> _complexButtons() {
    return [
      _RequestButton(
        label: 'Get Widgets',
        icon: Icons.widgets,
        onPressed: () => invoker.request(GetWidgetsCommand(page: 1)),
      ),
      _RequestButton(
        label: 'Patch Record #1',
        icon: Icons.auto_fix_high,
        onPressed: () => invoker.request(
          PatchRecordCommand(
            id: '1',
            body: {'field': 'patched_value'},
          ),
        ),
      ),
      _RequestButton(
        label: 'Category Tree',
        icon: Icons.account_tree,
        onPressed: () => invoker.request(
          ProcessCategoryTreeCommand(
            categoryNode: CategoryNode(
              categoryName: 'Root',
              subCategories: [
                CategoryNode(categoryName: 'Child A'),
                CategoryNode(
                  categoryName: 'Child B',
                  subCategories: [
                    CategoryNode(categoryName: 'Grandchild B1'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ];
  }
}

class _RequestButton extends StatelessWidget {
  const _RequestButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ActionChip(
        avatar: Icon(icon, size: 18),
        label: Text(label),
        onPressed: onPressed,
      ),
    );
  }
}
