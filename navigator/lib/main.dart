import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:navigator/common/routers/names.dart';
import 'package:navigator/common/routers/pages.dart';
import 'package:navigator/common/services/geolocation_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await initializeService();
  runApp(const MyApp());
}

// this will be used as notification channel id
const notificationChannelId = 'my_foreground';

// this will be used for notification id, So you can update your custom notification with this id.
const notificationId = 888;

// Future<void> initializeService() async {
//   final service = FlutterBackgroundService();

//   const AndroidNotificationChannel channel = AndroidNotificationChannel(
//     notificationChannelId, // id
//     'MY FOREGROUND SERVICE', // title
//     description:
//         'This channel is used for important notifications.', // description
//     importance: Importance.low, // importance must be at low or higher level
//   );

//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   await flutterLocalNotificationsPlugin
//       .resolvePlatformSpecificImplementation<
//           AndroidFlutterLocalNotificationsPlugin>()
//       ?.createNotificationChannel(channel);

//   await service.configure(
//     androidConfiguration: AndroidConfiguration(
//       // this will be executed when app is in foreground or background in separated isolate
//       onStart: onStart,

//       // auto start service
//       autoStart: true,
//       isForegroundMode: true,

//       notificationChannelId:
//           notificationChannelId, // this must match with notification channel you created above.
//       initialNotificationTitle: 'AWESOME SERVICE',
//       initialNotificationContent: 'Initializing',
//       foregroundServiceNotificationId: notificationId,
//     ),
//     iosConfiguration: IosConfiguration(
//       // auto start service
//       autoStart: true,

//       // this will be executed when app is in foreground in separated isolate
//       onForeground: onStart,

//       // you have to enable background fetch capability on xcode project
//       // onBackground: onIosBackground,
//     ),
//   );

//   service.startService();
// }

// Future<void> onStart(ServiceInstance service) async {
//   // Only available for flutter 3.0.0 and later
//   DartPluginRegistrant.ensureInitialized();
//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();
//   flutterLocalNotificationsPlugin.show(
//     notificationId,
//     'COOL SERVICE',
//     'EME ${DateTime.now()}',
//     const NotificationDetails(
//       android: AndroidNotificationDetails(
//         notificationChannelId,
//         'MY FOREGROUND SERVICE',
//         icon: 'ic_bg_service_small',
//         ongoing: true,
//       ),
//     ),
//   );
//   // bring to foreground
//   // Timer.periodic(const Duration(seconds: 1), (timer) async {
//   //   flutterLocalNotificationsPlugin.show(
//   //     notificationId,
//   //     'COOL SERVICE',
//   //     'Awesome ${DateTime.now()}',
//   //     const NotificationDetails(
//   //       android: AndroidNotificationDetails(
//   //         notificationChannelId,
//   //         'MY FOREGROUND SERVICE',
//   //         icon: 'ic_bg_service_small',
//   //         ongoing: true,
//   //       ),
//   //     ),
//   //   );
//   // });
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: RouteNames.home,
      getPages: RoutePages.list,
    );
  }
}
