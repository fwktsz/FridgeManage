import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> initPlatformDatabase() async {
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
} 