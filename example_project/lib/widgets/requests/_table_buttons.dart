part of 'request_buttons_section.dart';

class _TableButtons extends StatelessWidget {
  const _TableButtons({
    required this.invoker,
  });

  final DioNetworkInvoker invoker;

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      children: [
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
      ],
    );
  }
}
