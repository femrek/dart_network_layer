part of 'request_buttons_section.dart';

class _BulkButtons extends StatelessWidget {
  const _BulkButtons({
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
      ],
    );
  }
}
