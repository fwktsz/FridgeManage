import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../database/database_helper.dart';

class BackupService {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<String> exportData() async {
    final db = await _databaseHelper.database;
    final foods = await db.query('foods');
    final categories = await db.query('categories');

    final backupData = {
      'foods': foods,
      'categories': categories,
      'version': 1,
      'timestamp': DateTime.now().toIso8601String(),
    };

    final file = await _getBackupFile();
    await file.writeAsString(jsonEncode(backupData));
    return file.path;
  }

  Future<File> _getBackupFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'fridge_backup_${DateTime.now().millisecondsSinceEpoch}.json';
    return File('${directory.path}/$fileName');
  }

  Future<void> importData(String path) async {
    // TODO: 实现数据导入功能
  }
} 