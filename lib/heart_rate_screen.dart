import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter/material.dart';

class HeartRateScreen extends StatefulWidget {
  @override
  _HeartRateScreenState createState() => _HeartRateScreenState();
}

class _HeartRateScreenState extends State<HeartRateScreen> {
  StreamSubscription? _scanSubscription;
  StreamSubscription? _connectionSubscription;
  StreamSubscription<List<int>>? _heartRateSubscription;
  BluetoothDevice? _device;
  BluetoothCharacteristic? _heartRateCharacteristic;

  // State variable for the latest heart rate data
  int _heartRate = 0;
  List<int> _heartRates = [];

  @override
  void initState() {
    super.initState();

    // Start scanning for devices when the screen is initialized
    print('Starting scan');
    _startScan();
  }

  List<FlSpot> get _heartRateData {
  List<FlSpot> data = [];
  for (int i = 0; i < _heartRates.length; i++) {
    data.add(FlSpot(i.toDouble(), _heartRates[i].toDouble()));
  }
  return data;
}

  // Function to start scanning for devices
  void _startScan() {
    _scanSubscription = FlutterBlue.instance.scan().listen((scanResult) {
      print('Found device: ${scanResult.device.name}');
      if (scanResult.device.name == 'Movesense 192830000693') {
        // Stop scanning once we've found a device
        print('Stopping scan');
        _scanSubscription?.cancel();
        _scanSubscription = null;

        // Connect to the device
        _connectToDevice(scanResult.device);
      }
    });
  }

  // Function to connect to the device
  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      print('Connecting to device ${device.name}');
      await device.connect();
      print('Connected to device ${device.name}');
      _device = device; // add this line to set the _device variable
      List<BluetoothService> services = await device.discoverServices();
      print('Discovered ${services.length} services');

      for (BluetoothService service in services) {
        print('Service: ${service.uuid}');

        for (BluetoothCharacteristic characteristic in service.characteristics) {
          print('Characteristic: ${characteristic.uuid}');

          if (characteristic.uuid.toString() ==
              '00002a37-0000-1000-8000-00805f9b34fb') {
            print('Subscribing to heart rate characteristic');
            characteristic.setNotifyValue(true);
            _heartRateSubscription = characteristic.value.listen((value) {
              int heartRate = value[1];
              print('Heart rate: $heartRate');
              print('Before setting state, _heartRate = $_heartRate');
              setState(() {
                _heartRate = heartRate;
                _heartRates.add(heartRate);
              });
              print('After setting state, _heartRate = $_heartRate');
            });
          }
        }
      }
    } catch (e) {
      print('Error connecting to device ${device.name}: $e');
    }
  }

  // Function to disconnect from the device
   // Function to disconnect from the device
  void _disconnectFromDevice() async {
    if (_device != null) {
      // Unsubscribe from heart rate data
      print('Unsubscribing from heart rate characteristic');
      await _heartRateSubscription?.cancel();

      // Disconnect from the device
      print('Disconnecting from device: ${_device!.name}');
      await _device!.disconnect();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Heart Rate'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 1,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Heart rate',
                    style: TextStyle(
                      fontSize: 32.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    '$_heartRate bpm',
                    style: TextStyle(
                      fontSize: 48.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            
            child: Container(
              margin: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 1.0),
                borderRadius: BorderRadius.circular(8.0),
              ),

              
 child: SizedBox(
  height: (MediaQuery.of(context).size.height * 0.3),
  child:LineChart(
  LineChartData(
    lineTouchData: LineTouchData(enabled: false),
    lineBarsData: [
      LineChartBarData(
        
        spots: _heartRateData,
        isCurved: true,
        color: Colors.blue,
        barWidth: 4.0,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          color: Colors.blue.withOpacity(0.2),
        ),
      ),
    ],
titlesData: FlTitlesData(
  leftTitles: AxisTitles(sideTitles: SideTitles( showTitles: true,
  reservedSize: 30,
  getTitlesWidget: (value, meta) => Text('$value', style: TextStyle(color: Colors.black, fontSize: 8)),
  )),
  topTitles: AxisTitles(sideTitles: SideTitles( showTitles: false)),
  bottomTitles: AxisTitles(sideTitles: SideTitles( showTitles: true,
  reservedSize: 30,
  getTitlesWidget: (value, meta) => Text('$value', style: TextStyle(color: Colors.black, fontSize: 8))
  )),
  rightTitles: AxisTitles(sideTitles: SideTitles( showTitles: false)),
),




    minY: 55,
    maxX: 80,
    gridData: FlGridData(
      show: true,
      horizontalInterval: 20,
      getDrawingHorizontalLine: (value) {
        return FlLine(
          color: Colors.grey.withOpacity(0.5),
          strokeWidth: 1.0,
        );
      },
    ),
  ),
),
              ),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _disconnectFromDevice,
        tooltip: 'Disconnect',
        child: Icon(Icons.bluetooth_disabled),
      ),
    );
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _connectionSubscription?.cancel();
    _heartRateSubscription?.cancel();
    _disconnectFromDevice();
    super.dispose();
  }
}
