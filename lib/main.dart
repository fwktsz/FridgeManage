import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/food_provider.dart';
import 'pages/main_container.dart';
import 'pages/onboarding_page.dart';
import 'database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    try {
      await DatabaseHelper().database;
    } catch (e) {
      print('Error initializing database: $e');
    }
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      // Web平台显示提示信息
      return MaterialApp(
        title: '今天吃点啥',
        home: Scaffold(
          body: Center(
            child: Text('Web版本暂不支持，请使用Windows、Android或iOS版本'),
          ),
        ),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FoodProvider()),
      ],
      child: MaterialApp(
        title: '今天吃点啥',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.grey[100],
        ),
        home: FutureBuilder<bool>(
          future: _checkIfShowOnboarding(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            return snapshot.data == true ? OnboardingPage() : MainContainer();
          },
        ),
      ),
    );
  }

  Future<bool> _checkIfShowOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final hasShownOnboarding = prefs.getBool('has_shown_onboarding') ?? false;
    return !hasShownOnboarding;  // 如果没有显示过，则返回true
  }
} 