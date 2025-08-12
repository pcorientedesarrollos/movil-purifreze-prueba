// lib/main.dart

import 'package:flutter/material.dart';
import 'location_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simulador de Recorrido',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const TrackingScreen(),
    );
  }
}

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final LocationService _locationService = LocationService();
  final TextEditingController _rutaIdController = TextEditingController();

  bool _isTracking = false;
  String _statusMessage = 'Introduce un ID de Ruta para comenzar.';

  void _start() {
    if (_rutaIdController.text.isEmpty) {
      setState(() {
        _statusMessage = 'Error: El ID de Ruta no puede estar vacío.';
      });
      return;
    }

    final idRuta = int.tryParse(_rutaIdController.text);
    if (idRuta == null) {
      setState(() {
        _statusMessage = 'Error: El ID de Ruta debe ser un número.';
      });
      return;
    }

    _locationService.startTracking(idRuta);
    setState(() {
      _isTracking = true;
      _statusMessage =
          'Recorrido iniciado para la Ruta #$idRuta. Enviando coordenadas...';
    });
  }

  void _stop() {
    _locationService.stopTracking();
    setState(() {
      _isTracking = false;
      _statusMessage =
          'Recorrido detenido. Introduce un ID para iniciar de nuevo.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simulador de Repartidor')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _rutaIdController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'ID de la Ruta',
                border: OutlineInputBorder(),
              ),
              enabled: !_isTracking,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isTracking ? null : _start,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text(
                'Iniciar Recorrido',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: !_isTracking ? null : _stop,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text(
                'Detener Recorrido',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              _statusMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
