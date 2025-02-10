import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/backup_service.dart';
import '../pages/category_manage_page.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final BackupService _backupService = BackupService();
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('设置'),
      ),
      body: ListView(
        children: [
          _buildBackupSettings(),
          Divider(),
          _buildAboutSection(),
          ListTile(
            leading: Icon(Icons.category),
            title: Text('分类管理'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CategoryManagePage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBackupSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            '数据管理',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListTile(
          title: Text('导出数据'),
          trailing: Icon(Icons.arrow_forward_ios),
          onTap: () async {
            try {
              final path = await _backupService.exportData();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('数据已导出到: $path')),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('导出失败: $e')),
              );
            }
          },
        ),
        ListTile(
          title: Text('导入数据'),
          trailing: Icon(Icons.arrow_forward_ios),
          onTap: () {
            // TODO: 实现数据导入功能
          },
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            '关于',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListTile(
          title: Text('版本'),
          trailing: Text('1.0.0'),
        ),
        ListTile(
          title: Text('隐私政策'),
          trailing: Icon(Icons.arrow_forward_ios),
          onTap: () {
            // TODO: 跳转到隐私政策页面
          },
        ),
        ListTile(
          title: Text('用户协议'),
          trailing: Icon(Icons.arrow_forward_ios),
          onTap: () {
            // TODO: 跳转到用户协议页面
          },
        ),
      ],
    );
  }
} 