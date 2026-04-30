import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  MapType _currentMapType = MapType.satellite;
  DateTime _selectedDate = DateTime.now();
  double _calculatedArea = 0.0;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(16.0544, 108.2022),
    zoom: 12,
  );

  void _analyzeCrops() {
    // TODO: Gửi request đến FastAPI để chạy mô hình U-Net
    // Cập nhật kết quả diện tích và Overlay mask lên bản đồ
    setState(() {
      _calculatedArea = 125.5; // Ví dụ kết quả trả về
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đang phân tích dữ liệu viễn thám...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giám sát Nông nghiệp Đà Nẵng'),
        backgroundColor: Colors.green[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.layers),
            onPressed: () {
              setState(() {
                _currentMapType = _currentMapType == MapType.satellite
                    ? MapType.normal
                    : MapType.satellite;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            mapType: _currentMapType,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
          Positioned(
            bottom: 20,
            left: 10,
            right: 10,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Thời gian phân tích:",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.calendar_today),
                          label: Text(
                            "${_selectedDate.month}/${_selectedDate.year}",
                          ),
                          onPressed: () async {
                            // Chọn thời gian để phân tích biến động
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (date != null)
                              setState(() => _selectedDate = date);
                          },
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Diện tích cây trồng: ",
                          style: TextStyle(color: Colors.green[900]),
                        ),
                        Text(
                          "$_calculatedArea ha",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: _analyzeCrops,
                      icon: const Icon(Icons.analytics),
                      label: const Text("BẮT ĐẦU PHÂN TÍCH"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 45),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
