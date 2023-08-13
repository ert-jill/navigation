import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:latlong2/latlong.dart';
import 'package:open_route_service/open_route_service.dart';

class GeoLocationService extends GetxService {
  LocationPermission?
      permissionGranted; //flag for app if permitted to use the device location
  RxBool serviceEnabled =
      false.obs; //flag for location sevice if enabled or not
  RxBool start = false.obs; //flag for service if started or not
  RxBool isPause = false.obs; //flag if service is pause
  RxDouble totalDistance = RxDouble(0); //travelled distance
  RxDouble speed = RxDouble(0); //travel speed
  RxDouble elevation = RxDouble(0); //travel gained elevation
  RxDouble userHeading = 0.0.obs; //user heading
  RxString value = ''.obs; // location value
  Position? previousPosition; //current fecth position
  FlutterBackgroundService? travelService; //travel service

  //late RxList<LatLng> routePoints = <LatLng>[].obs; //route location points (route platting)
  late RxList<LatLng> travelPoints =
      <LatLng>[].obs; //travel location points (travel platting)

  // Initialize the OpenRouteService with your API key.
  final OpenRouteService client = OpenRouteService(
      apiKey: '5b3ce3597851110001cf62483f89f1fe46024deda2c32872cdc8df76r');
  final mapController = MapController();

  // Example coordinates to test between
  static const double startLat = 10.372292771427695;
  static const double startLng = 123.94775671528134;
  static const double endLat = 10.373346928132957;
  static const double endLng = 123.9546083754571;

  //Play or Pause action
  setPlayPause(bool value) {
    isPause.value = value;
    if (travelService != null && start.value) {
      if (isPause.value) {
        travelService!.invoke('pause');
      } else {
        travelService!.invoke('resume');
      }
    }
  }

  //Start or End Travel action
  StartEndTravel(bool isStart) async {
    start.value = isStart;
    if (isStart) {
      permissionGranted = await Geolocator.checkPermission();
      if (permissionGranted == LocationPermission.denied) {
        permissionGranted = await Geolocator.requestPermission();
        if (permissionGranted == LocationPermission.denied) {
          start.value = false;
          return;
        }
      }
      if (permissionGranted == LocationPermission.whileInUse ||
          permissionGranted == LocationPermission.always) {
        serviceEnabled.value = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled.value) {
          await Geolocator.openLocationSettings();
          Geolocator.getServiceStatusStream().listen((event) async {
            //not to start when location is desabled and not start
            if (event == ServiceStatus.disabled && !start.value) {
              start.value = false;
              serviceEnabled.value = false;
              return;
            }
            //pause when started and location is disabled
            else if (event == ServiceStatus.disabled &&
                start.value &&
                travelService != null) {
              if (travelService != null) {
                travelService!.invoke('pause');
              }
            }
            //resume when started and location is enabled
            else if (event == ServiceStatus.enabled &&
                start.value &&
                travelService != null) {
              travelService!.invoke('resume');
            }
            //else
            else {
              serviceEnabled.value = true;
              travelService = await initializeBackgroundService();
            }
          });
        } else {
          travelService = await initializeBackgroundService();
        }
      } else {}
    } else if (travelService != null) {
      travelService!.invoke('stopService');
      isPause.value = false;
      start.value = false;
    }
  }

  // @override
  // void onInit() async {
  // Form Route between coordinates
  // await FlutterMapTileCaching.initialise();
  // final List<ORSCoordinate> routeCoordinates =
  //     await client.directionsRouteCoordsGet(
  //   profileOverride: ORSProfile.cyclingMountain,
  //   startCoordinate: ORSCoordinate(latitude: startLat, longitude: startLng),
  //   endCoordinate: ORSCoordinate(latitude: endLat, longitude: endLng),
  // );
  // client.elevationPointPost(geometry: geometry)
  // routePoints.value = routeCoordinates
  //     .map((coordinate) => LatLng(coordinate.latitude, coordinate.longitude))
  //     .toList();

  //   super.onInit();
  // }

  Future<FlutterBackgroundService> initializeBackgroundService() async {
    final service = FlutterBackgroundService();

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      notificationChannelId, // id
      'MY FOREGROUND SERVICE', // title
      description:
          'This channel is used for important notifications.', // description
      importance: Importance.high, // importance must be at low or higher level
    );

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/bike');

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        // this will be executed when app is in foreground or background in separated isolate
        onStart: startFetchingLocationAndCalculateDistance,

        // auto start service
        autoStart: true,
        isForegroundMode: true,

        notificationChannelId:
            notificationChannelId, // this must match with notification channel you created above.
        initialNotificationTitle: 'BC Travel',
        initialNotificationContent: 'Initializing...',
        foregroundServiceNotificationId: notificationId,
      ),
      iosConfiguration: IosConfiguration(
        // auto start service
        autoStart: true,

        // this will be executed when app is in foreground in separated isolate
        onForeground: startFetchingLocationAndCalculateDistance,

        // you have to enable background fetch capability on xcode project
        // onBackground: onIosBackground,
      ),
    );

    service.on('update').listen((event) async {
      speed.value = event?['previousPosition']['speed'].toDouble() * 3.6;
      userHeading.value = event?['previousPosition']['heading']?.toDouble();
      previousPosition = Position(
          longitude: event?['previousPosition']['longitude'].toDouble(),
          latitude: event?['previousPosition']['latitude'].toDouble(),
          timestamp: DateTime.fromMillisecondsSinceEpoch(
              event?['previousPosition']['timestamp']),
          accuracy: event?['previousPosition']['accuracy'].toDouble(),
          altitude: event?['previousPosition']['altitude'].toDouble(),
          heading: event?['previousPosition']['heading'].toDouble(),
          speed: event?['previousPosition']['speed'].toDouble(),
          speedAccuracy:
              event?['previousPosition']['speedAccuracy']?.toDouble() ?? 0.0);
      travelPoints.add(LatLng(event?['previousPosition']['latitude'].toDouble(),
          event?['previousPosition']['longitude'].toDouble()));
      totalDistance.value = event?['totalDistance'].toDouble();
      value.value = event?['value'];
    });

    service.startService();
    return service;
    // service.invoke('stopService');
  }
}

// this will be used as notification channel id
const notificationChannelId = 'my_foreground';
// this will be used for notification id, So you can update your custom notification with this id.
const notificationId = 888;

@pragma('vm:entry-point')
Future<void> _onSelectNotification(NotificationResponse n) async {
  print(n.actionId);
  // if (payload == 'stop_action') {
  //   // Call your function here when the "Stop" action is clicked
  //   print('Stop action clicked');
  //   // Replace the print statement with your function call
  // }
}

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}

@pragma('vm:entry-point')
Future<void> startFetchingLocationAndCalculateDistance(
    ServiceInstance service) async {
  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();
  Position? previousPosition;
  double totalDistance = 0;
  bool isPause = false;
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/bike');

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onDidReceiveBackgroundNotificationResponse: _onSelectNotification);

  LocationSettings locationSettings;
  if (defaultTargetPlatform == TargetPlatform.android) {
    locationSettings = AndroidSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 0,
      forceLocationManager: true,
      intervalDuration: const Duration(seconds: 1),
    );
  } else {
    locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 0,
    );
  }

  StreamSubscription<Position> getPositionStream =
      Geolocator.getPositionStream(locationSettings: locationSettings)
          .listen((Position currentPosition) {
    if (previousPosition != null) {
      double distance = Geolocator.distanceBetween(
        previousPosition!.latitude,
        previousPosition!.longitude,
        currentPosition.latitude,
        currentPosition.longitude,
      );
      totalDistance += distance;
    }
    previousPosition = currentPosition;
    service.invoke('update', {
      "previousPosition": previousPosition,
      "totalDistance": totalDistance,
      "value": currentPosition.toString()
    });

    flutterLocalNotificationsPlugin.show(
      notificationId,
      'BC Travel',
      'Distance: ${(totalDistance / 1000).toStringAsFixed(3)} KM   Speed: ${(previousPosition!.speed.toDouble() * 3.6).toStringAsFixed(0)} KM/H',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          notificationChannelId, 'MY FOREGROUND SERVICE',
          largeIcon: DrawableResourceAndroidBitmap('@mipmap/bike'),
          ongoing: true,
          // actions: [AndroidNotificationAction("0", "Stop",icon:)]
        ),
      ),
    );
  });

  //stop the location stream and the background service
  service.on('stopService').listen((event) {
    getPositionStream.cancel();
    service.stopSelf();
  });

  //pause the location stream
  service.on('pause').listen((event) {
    getPositionStream.pause();
    flutterLocalNotificationsPlugin.show(
      notificationId,
      'BC Travel',
      'Distance: ${(totalDistance / 1000).toPrecision(3)} KM   Speed: ${(previousPosition!.speed.toDouble() * 3.6).toStringAsFixed(0)} KM/H Paused!!!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          notificationChannelId, 'MY FOREGROUND SERVICE',
          largeIcon: DrawableResourceAndroidBitmap('@mipmap/bike'),
          ongoing: true,
          // actions: [AndroidNotificationAction("0", "Stop",icon:)]
        ),
      ),
    );
  });

  //resume the location stream
  service.on('resume').listen((event) {
    getPositionStream.resume();
  });
}
