import 'package:flutter/material.dart';

class FilePreviewer extends StatefulWidget {
  const FilePreviewer({Key? key}) : super(key: key);

  @override
  State<FilePreviewer> createState() => _FilePreviewerState();
}

class _FilePreviewerState extends State<FilePreviewer> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
        flex: 1,
        child: Column(
          children: [
            Text('File path:'),
          ],
        ));
  }
}
