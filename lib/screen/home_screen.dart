import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late BitmapDescriptor customIcon;

  Future<String> checkPermission() async {
    final isLocationEnabled = await Geolocator.isLocationServiceEnabled();

    if (!isLocationEnabled) {
      return '위치 서비스를 활성화해 주세요.';
    }

    LocationPermission checkedPermission = await Geolocator.checkPermission();

    if (checkedPermission == LocationPermission.denied) {
      checkedPermission = await Geolocator.requestPermission();

      if (checkedPermission == LocationPermission.denied) {
        return '위치 권한을 허가해주세요.';
      }
    }

    if (checkedPermission == LocationPermission.deniedForever) {
      return '앱의 위치 권한을 설정에서 허가해주세요.';
    }
    return '위치 권한이 허가 되었습니다.';
  }

  static const LatLng restaurant = LatLng(33.3525369, 126.668243);

  static const CameraPosition initialPosition = CameraPosition(
    zoom: 9,
    target: restaurant,
  );

  Future<List<Marker>> _createMarkersFromJsonFile(String path) async {
    String jsonString = await rootBundle.loadString(path);
    Map<String, dynamic> map = jsonDecode(jsonString);
    List<dynamic> data = map['item'];

    List<Marker> markers = [];

    for (var i = 0; i < data.length; i++) {
      if (data[i]['laCrdnt'] != null && data[i]['loCrdnt'] != null) {
        double lat = double.parse(data[i]['laCrdnt']);
        double lon = double.parse(data[i]['loCrdnt']);
        String markerId = data[i]['dataCd'];
        String bsshNm = data[i]['bsshNm'];

        Marker marker = Marker(
          markerId: MarkerId(markerId),
          position: LatLng(lat, lon),
          infoWindow: InfoWindow(title: bsshNm),
          icon: customIcon,
        );

        markers.add(marker);
      }
    }

    return markers;
  }

  void _loadMarkers() async {
    List<Marker> markers =
        await _createMarkersFromJsonFile('assets/json/rawData.json');

    setState(
      () {
        _markers = Set<Marker>.from(markers);
      },
    );
  }

  static final Circle circle = Circle(
    circleId: const CircleId('choolCheckCircle'),
    center: restaurant,
    fillColor: Colors.blue.withOpacity(0.5),
    radius: 100,
    strokeColor: Colors.blue,
    strokeWidth: 1,
  );

  Set<Marker> _markers = {};

  Future<void> addCustomIcon() async {
    final imageConfiguration = createLocalImageConfiguration(
      context,
      size: const Size(50, 50),
    );

    customIcon = await BitmapDescriptor.fromAssetImage(
      imageConfiguration,
      'assets/images/restaurant.png',
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    addCustomIcon().then((_) {
      _loadMarkers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: renderAppBar(),
      body: FutureBuilder<String>(
        future: checkPermission(),
        builder: (context, snapshot) {
          if (!snapshot.hasData &&
              snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.data == "위치 권한이 허가 되었습니다.") {
            return Column(
              children: [
                Expanded(
                  flex: 2,
                  child: GoogleMap(
                    myLocationEnabled: true,
                    initialCameraPosition: initialPosition,
                    markers: _markers,
                    circles: {circle},
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.timelapse_outlined,
                        color: Colors.blue,
                        size: 50.0,
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final curPosition =
                              await Geolocator.getCurrentPosition();

                          final distance = Geolocator.distanceBetween(
                              curPosition.latitude,
                              curPosition.longitude,
                              restaurant.latitude,
                              restaurant.longitude);

                          bool canCheck = distance < 100;

                          // ignore: use_build_context_synchronously
                          showDialog(
                              context: context,
                              builder: (_) {
                                return AlertDialog(
                                  title: const Text('출근하기'),
                                  content: Text(canCheck
                                      ? '출근을 하시겠습니까?'
                                      : '출근할 수 없는 위치입니다.'),
                                  actions: [
                                    TextButton(
                                        onPressed: () {},
                                        child: const Text('취소'))
                                  ],
                                );
                              });
                        },
                        child: const Text('출근하기'),
                      )
                    ],
                  ),
                )
              ],
            );
          }

          return Center(
            child: Text(
              snapshot.data.toString(),
            ),
          );
        },
      ),
    );
  }
}

AppBar renderAppBar() {
  return AppBar(
    backgroundColor: Colors.white,
    centerTitle: true,
    title: const Text(
      '그돈이면 제주도 갑니다.',
      style: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}
