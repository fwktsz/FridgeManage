import 'dart:io' show Platform;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../repositories/food_repository.dart';
import '../models/food.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final FoodRepository _foodRepository = FoodRepository();

  NotificationService._internal();

  Future<void> initialize() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;

    // 初始化时区数据
    tz.initializeTimeZones();

    // 初始化通知设置
    final androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    final initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) async {
        // 点击通知时的处理逻辑，可以跳转到相关页面
        print('Notification clicked: ${details.payload}');
      },
    );

    // 请求通知权限
    await _requestPermissions();

    // 设置定时通知
    await _scheduleFixedTimeNotifications();
  }

  Future<void> _requestPermissions() async {
    if (Platform.isIOS) {
      await _notifications.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      await androidImplementation?.requestPermission();
    }
  }

  Future<void> _scheduleFixedTimeNotifications() async {
    // 取消所有现有的通知
    await _notifications.cancelAll();

    // 设置通知时间：6点、10点、14点、16点、20点
    final times = [
      Time(6, 0),  // 早上6点
      Time(10, 0), // 上午10点
      Time(14, 0), // 下午2点
      Time(16, 0), // 下午4点
      Time(20, 0), // 晚上8点
    ];

    for (var time in times) {
      await _notifications.zonedSchedule(
        time.hour, // 使用小时作为通知ID
        '食材状态提醒',
        '让我们检查一下临期和过期的食材',
        _nextInstanceOfTime(time),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'food_check',
            '食材检查',
            channelDescription: '定时检查食材状态',
            importance: Importance.high,
            priority: Priority.high,
            styleInformation: BigTextStyleInformation(''),
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  tz.TZDateTime _nextInstanceOfTime(Time time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  Future<void> checkExpiringFoods() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;

    final foods = await _foodRepository.getExpiringFoods();
    if (foods.isEmpty) return;

    // 分类统计
    int expiredCount = 0;
    int expiringCount = 0;
    final now = DateTime.now();
    
    for (var food in foods) {
      if (now.isAfter(food.expiryDate)) {
        expiredCount++;
      } else {
        expiringCount++;
      }
    }

    // 生成通知内容
    final StringBuffer content = StringBuffer();
    if (expiredCount > 0) {
      content.writeln('已过期食材: $expiredCount 个');
    }
    if (expiringCount > 0) {
      content.writeln('临期食材: $expiringCount 个');
    }
    content.writeln('\n点击查看详情');

    // 发送通知
    final androidDetails = AndroidNotificationDetails(
      'food_expiry',
      '食材过期提醒',
      channelDescription: '提醒食材即将过期',
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(content.toString()),
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      0,
      '食材状态提醒',
      content.toString(),
      details,
    );
  }
} 