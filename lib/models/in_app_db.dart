import 'package:compressor/db/db.dart';
import 'package:hive/hive.dart';

class InAppDb {
  String filePath;
  String compressedDate;
  InAppDb({required this.filePath, required this.compressedDate});

  Future<dynamic> addNewFileHistory() async {
    var output = {'code': 200};
    var box = await Hive.openBox<CompressDb>('CompressDb');
    box.add(CompressDb(
        filePath: filePath, compressedDate: DateTime.now().toString()));
    return output;
  }
}
