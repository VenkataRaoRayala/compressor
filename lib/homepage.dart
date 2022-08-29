import 'dart:io';

import 'package:compressor/db/db.dart';
import 'package:compressor/file_preview.dart';
import 'package:compressor/models/in_app_db.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:share_plus/share_plus.dart';
import 'package:video_compress/video_compress.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isFileSelected = false;
  int fileType = -1;
  String filePath = '';
  final GlobalKey _widgetKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  bool isCompressing = false;
  late Subscription subscription;
  double progress = 0;
  List<CompressDb> compressedFiles = [];
  @override
  void initState() {
    subscription = VideoCompress.compressProgress$.subscribe((p) {
      setState(() {
        progress = p;
      });
    });
    loadData();
  }

  void loadData() async {
    final box = await Hive.openBox<CompressDb>('CompressDb');
    setState(() {
      compressedFiles = box.values.toList();
    });
  }

  Future<void> displayOverlay() async {
    RenderBox renderBox =
        _widgetKey.currentContext!.findRenderObject() as RenderBox;
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);
    print(offset);
    OverlayState overlayState = Overlay.of(context)!;

    _overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
              left: offset.dx,
              top: offset.dy + size.height + 5.0,
              width: size.width,
              child: Material(
                elevation: 4.0,
                child: ListView(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  children: <Widget>[
                    ListTile(
                      onTap: () async {
                        setState(() {
                          fileType = 1;
                        });
                        getFile(fileType)
                            .then((value) => _overlayEntry!.remove());
                      },
                      title: Text('Image'),
                    ),
                    ListTile(
                      onTap: () async {
                        setState(() {
                          fileType = 2;
                        });

                        getFile(fileType)
                            .then((value) => _overlayEntry!.remove());
                      },
                      title: Text('Video'),
                    )
                  ],
                ),
              ),
            ));
    overlayState.insert(_overlayEntry!);
  }

  Future<void> getFile(int fileType) async {
    if (fileType == 1) {
      FilePickerResult? result = await FilePicker.platform
          .pickFiles(type: FileType.image, allowMultiple: false);
      setState(() {
        if (result != null) {
          File file = File(result.files.single.path!);
          filePath = file.path.toString();
        }
      });
    }
    if (fileType == 2) {
      FilePickerResult? result =
          await FilePicker.platform.pickFiles(type: FileType.video);
      setState(() {
        if (result != null) {
          File file = File(result.files.single.path!);
          filePath = file.path.toString();
        }

        print(filePath);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Color.fromARGB(255, 125, 110, 201),
            title: Text('kCompressor'),
          ),
          body: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  height: 80,
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 2,
                        child: filePath.isEmpty
                            ? Text('Choose your file')
                            : Text(filePath),
                      ),
                      Container(
                        height: 40,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Color.fromARGB(255, 57, 53, 53),
                            ),
                            key: _widgetKey,
                            onPressed: () async {
                              //get image and video file from files
                              await displayOverlay();
                            },
                            child: Text('Choose')),
                      )
                    ],
                  ),
                ),
                InkWell(
                  onTap: () async {
                    if (filePath.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please select the file')));
                    } else {
                      setState(() {
                        isCompressing = true;
                      });
                      if (fileType == 1) {
                        print(filePath);
                        final directory =
                            await path_provider.getExternalStorageDirectory();
                        final folderPath =
                            directory!.path.toString() + '/image compressor';
                        if (await Directory(folderPath).exists()) {
                          File compressedFile =
                              await FlutterNativeImage.compressImage(
                            filePath,
                            quality: 80,
                          );
                          print(compressedFile.path);
                          final file1 = await compressedFile.copy(folderPath +
                              '/${compressedFile.path.split('/').last}');
                          print(file1.path);
                          await compressedFile.delete();
                          InAppDb inAppDb = InAppDb(
                              filePath: file1.path.toString(),
                              compressedDate: DateTime.now().toString());
                          await inAppDb.addNewFileHistory();
                          loadData();
                        } else {
                          Directory(folderPath)
                              .create()
                              .then((dir) => print(dir.path));
                          File compressedFile =
                              await FlutterNativeImage.compressImage(
                            filePath,
                            quality: 80,
                          );
                          print(compressedFile.path);
                          final file1 = await compressedFile.copy(folderPath +
                              '/${compressedFile.path.split('/').last}');
                          print(file1.path);
                          await compressedFile.delete();

                          InAppDb inAppDb = InAppDb(
                              filePath: file1.path.toString(),
                              compressedDate: DateTime.now().toString());
                          await inAppDb.addNewFileHistory();
                          loadData();
                        }
                        setState(() {
                          filePath = '';
                          progress = 0;
                          isCompressing = false;
                        });
                      }
                      if (fileType == 2) {
                        final file = await VideoCompress.compressVideo(filePath,
                            quality: VideoQuality.LowQuality,
                            includeAudio: true);

                        print(file!.path);
                        setState(() {
                          filePath = '';
                          subscription.unsubscribe;
                          progress = 0;
                          isCompressing = false;
                        });
                        InAppDb inAppDb = InAppDb(
                            filePath: file.path.toString(),
                            compressedDate: DateTime.now().toString());
                        await inAppDb.addNewFileHistory();
                        loadData();
                      }
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: Color.fromARGB(255, 125, 110, 201),
                        borderRadius: BorderRadius.circular(10.0)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: !isCompressing
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text('Compress'),
                                SizedBox(
                                  width: 20.0,
                                ),
                                SvgPicture.asset(
                                  'assets/svg/process_icon.svg',
                                  fit: BoxFit.scaleDown,
                                )
                              ],
                            )
                          : Center(
                              child: Stack(
                                children: [
                                  Center(
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      child: CircularProgressIndicator(
                                          value: progress / 100,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.black)),
                                    ),
                                  ),
                                  Center(
                                      child: Padding(
                                    padding: const EdgeInsets.only(top: 12.0),
                                    child: Text(
                                      progress.toStringAsFixed(0),
                                      style: TextStyle(fontSize: 12.0),
                                    ),
                                  ))
                                ],
                              ),
                            ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text('Recent'),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                      itemCount: compressedFiles.length,
                      itemBuilder: ((context, index) {
                        return ListTile(
                          leading: Icon(Icons.toc_sharp),
                          title: Text(
                            compressedFiles[index].filePath.split('/').last,
                            style: TextStyle(
                                fontSize: 12.0, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(compressedFiles[index].compressedDate,
                              style: TextStyle(fontSize: 10.0)),
                          trailing: IconButton(
                              splashRadius: 10.0,
                              iconSize: 20,
                              onPressed: () async {
                                await Share.shareFiles(
                                    [compressedFiles[index].filePath]);
                              },
                              icon: Icon(Icons.share)),
                        );
                      })),
                )
              ],
            ),
          ),
        ));
  }
}
