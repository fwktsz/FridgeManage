import 'package:flutter/material.dart';

class ErrorHandler {
  static void handleDatabaseError(dynamic error) {
    print('数据库错误: $error');
    // 可以添加本地日志记录
  }

  static void handleUIError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
} 