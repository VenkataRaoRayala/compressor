import 'package:hive/hive.dart';
part 'db.g.dart';

@HiveType(typeId: 1)
class CompressDb {
  CompressDb({required this.filePath, required this.compressedDate});
  @HiveField(0)
  String filePath;
  @HiveField(1)
  String compressedDate;
}
