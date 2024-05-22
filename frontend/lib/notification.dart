import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin notifications =
    FlutterLocalNotificationsPlugin();

//1. 앱로드시 실행할 기본설정
Future<void> initNotification(BuildContext context) async {
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
    requestSoundPermission: true,
    requestBadgePermission: true,
    requestAlertPermission: true,
  );

  const InitializationSettings initializationSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );

  await notifications.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      if (response.payload != null && response.payload!.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const NewPage(),
          ),
        );
      }
    },
  );
}

//2. 이 함수 원하는 곳에서 실행하면 알림 뜸
Future<void> showNotification() async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'unique_channel_id', // 유니크한 알림 채널 ID
    '알림종류 설명', // 알림 종류 설명
    priority: Priority.high, // 중요도
    importance: Importance.max, // 중요도
    color: Color.fromARGB(255, 255, 0, 0), // 알림 색상
  );

  const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
    presentAlert: true, // 알림 여부
    presentBadge: true, // 뱃지 여부
    presentSound: true, // 소리 여부
  );

  await notifications.show(
    1,
    '제목1',
    '내용1',
    const NotificationDetails(android: androidDetails, iOS: iosDetails),
    payload: '부가정보',
  );
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Local Notifications',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    initNotification(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Local Notifications'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: showNotification,
          child: const Text('Show Notification'),
        ),
      ),
    );
  }
}

class NewPage extends StatelessWidget {
  const NewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Page'),
      ),
      body: const Center(
        child: Text('This is a new page'),
      ),
    );
  }
}
