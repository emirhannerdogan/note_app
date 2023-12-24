import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothHandler extends StatefulWidget {
  const BluetoothHandler({Key? key}) : super(key: key);

  @override
  _BluetoothHandlerState createState() => _BluetoothHandlerState();
}

class _BluetoothHandlerState extends State<BluetoothHandler> {
  FlutterBlue ble = FlutterBlue.instance;
  List<BluetoothDevice> foundDevices = [];

  void startBluetoothProcess() async {}

  Future scanDevices() async {
    var status = await Permission.bluetoothScan.status;
    var status1 = await Permission.bluetoothConnect.status;
    debugPrint(status.toString());
    debugPrint(status1.toString());

    debugPrint("Taranıyor");
    foundDevices.clear(); // Temizleme işlemi her başlatıldığında yapılsın.
    ble.startScan(timeout: const Duration(seconds: 4)).then((value) {
      debugPrint("Tarama süresi doldu...");
    });

    ble.scanResults.listen((List<ScanResult> results) {
      for (ScanResult r in results) {
        setState(() {
          if (r.device.name != '' && !foundDevices.contains(r.device)) {
            foundDevices.add(r.device);
          }
        });
        debugPrint('${r.device.name} found! rssi: ${r.rssi}');
        debugPrint(r.toString());
        debugPrint(r.advertisementData.toString());
      }
    });
  }

  @override
  void initState() {
    //startBluetoothProcess();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bluetooth"),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              scanDevices();
            },
            child: const Text("Cihazları Tara"),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: foundDevices.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(foundDevices[index].name),
                  subtitle: Text(foundDevices[index].id.toString()),
                  trailing: ElevatedButton(
                    onPressed: () {
                      // Cihazı eşleştir
                    },
                    child: const Text("Eşleştir"),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
