import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class BluetoothHandler {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<BluetoothDevice> foundDevices = [];

  void startBluetoothProcess(BuildContext context) {
    foundDevices.clear(); // Temizleme işlemi her başlatıldığında yapılsın.

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Bluetooth Paylaşım"),
          content: foundDevices.isEmpty
              ? const Text("Cihazlar burada görüntülenecek...")
              : ListView.builder(
                  itemCount: foundDevices.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(foundDevices[index].name),
                      subtitle: const Text(""),
                      onTap: () async {
                        //CONNECT TO THE DEVICE
                        await foundDevices[index].connect();
                      },
                    );
                  },
                ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Kapat"),
            ),
            ElevatedButton(
              onPressed: () {
                //Navigator.of(context).pop();
                scanDevices();
              },
              child: const Text("Tara"),
            ),
          ],
        );
      },
    );
  }

  Future scanDevices() async {
    //foundDevices.add(device);
    flutterBlue.startScan(timeout: const Duration(seconds: 4));

    flutterBlue.scanResults.listen((List<ScanResult> results) {
      // Listen to scan results
      var subscription = flutterBlue.scanResults.listen((results) {
        if(results.isEmpty){
          debugPrint('BOŞ BULUNMADI');

        }
        // do something with scan results
        for (ScanResult r in results) {
          debugPrint('${r.device.name} found! rssi: ${r.rssi}');
        }
      });

      // Stop scanning
      flutterBlue.stopScan();
    });
  }
}
