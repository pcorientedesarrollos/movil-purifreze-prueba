// lib/location_service.dart

import 'dart:async';
import 'dart:convert';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

class LocationService {
  // Reemplaza esta URL con la IP de tu máquina donde corre el backend de NestJS.
  // Si usas el emulador de Android, usa '10.0.2.2'.
  // Si usas un dispositivo físico, usa la IP de tu PC en la red local (ej. '192.168.1.100').
  final String _apiUrl = 'https://1ccd21bd3f27.ngrok-free.app/geo-recorrido';

  Location _location = Location();
  StreamSubscription<LocationData>? _locationSubscription;

  Future<void> startTracking(int idRuta) async {
    // 1. Pedir permisos
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        return; // El usuario no activó el GPS
      }
    }

    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return; // El usuario no dio permisos
      }
    }

    // 2. Iniciar el stream de datos de ubicación
    _locationSubscription = _location.onLocationChanged.listen((
      LocationData currentLocation,
    ) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        print(
          'Enviando ubicación para ruta $idRuta: ${currentLocation.latitude}, ${currentLocation.longitude}',
        );
        _sendLocation(
          idRuta,
          currentLocation.latitude!,
          currentLocation.longitude!,
        );
      }
    });
  }

  void stopTracking() {
    // 3. Detener el stream
    _locationSubscription?.cancel();
    _locationSubscription = null;
    print('Seguimiento detenido.');
  }

  Future<void> _sendLocation(int idRuta, double lat, double lng) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'idRuta': idRuta,
          'latitud': lat,
          'longitud': lng,
        }),
      );

      if (response.statusCode == 201) {
        print('Ubicación enviada correctamente.');
      } else {
        print(
          'Error al enviar ubicación: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Excepción al enviar ubicación: $e');
    }
  }
}
