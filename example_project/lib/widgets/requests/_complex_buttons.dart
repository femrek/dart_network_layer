part of 'request_buttons_section.dart';

class _ComplexButtons extends StatelessWidget {
  const _ComplexButtons({
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
      ],
    );
  }
}
